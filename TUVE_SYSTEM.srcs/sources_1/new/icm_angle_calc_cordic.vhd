----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2022 10:51:40 AM
-- Design Name: 
-- Module Name: icm_angle_calc_cordic - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_Unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity icm_angle_calc_cordic is
 Port ( 
        clk       : in std_logic;
        rst       : in std_logic;
        magneto_x : in std_logic_vector(15 downto 0);---inputs for magneto_meter 
        magneto_y : in std_logic_vector(15 downto 0);
        magneto_z : in std_logic_vector(15 downto 0 );
        conv_factor : in std_logic_vector(31 downto 0);
        yaw_radians: out std_logic_vector(31 downto 0);
        yaw_degree : out std_logic_vector(15 downto 0)      -- 0 to 360   
  );  
end icm_angle_calc_cordic;

architecture Behavioral of icm_angle_calc_cordic is


COMPONENT atan_cordic
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_cartesian_tvalid : IN STD_LOGIC;
    s_axis_cartesian_tlast : IN STD_LOGIC;
    s_axis_cartesian_tdata : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tlast : OUT STD_LOGIC;
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
COMPONENT fixed_int16_to_float_single
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tlast : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tlast : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
COMPONENT div_floating_point
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_a_tlast : IN STD_LOGIC;
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tlast : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT float_single_to_fixed_48_46
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tlast : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
    m_axis_result_tlast : OUT STD_LOGIC
  );
END COMPONENT;


COMPONENT radian_fixed_32_29_to_float_single
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_a_tlast : IN STD_LOGIC;
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tlast : OUT STD_LOGIC
  );
END COMPONENT;


COMPONENT mul_float
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_a_tlast : IN STD_LOGIC;
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tlast : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT degree_float_single_to_fixed_16_7
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_a_tlast : IN STD_LOGIC;
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_result_tlast : OUT STD_LOGIC
  );
END COMPONENT;

signal  aclken :  STD_LOGIC;
signal  s_axis_a_tlast :  STD_LOGIC;
signal  m_axis_result_tlast_fixed :  STD_LOGIC;
signal  m_axis_result_tlast_float :  STD_LOGIC;
signal  m_axis_result_tlast_float_division :  STD_LOGIC;
signal  s_axis_cartesian_tlast    :  STD_LOGIC;
signal  s_axis_cartesian_tvalid    :  STD_LOGIC;
--    signal  s_axis_a_tready    :  STD_LOGIC;
signal  m_axis_dout_tlast         :  STD_LOGIC;
signal m_axis_result_tvalid_float :  STD_LOGIC;
signal m_axis_result_tvalid_conv_factor_float :  STD_LOGIC:= '1';
signal m_axis_result_tvalid_fixed :  STD_LOGIC;
signal m_axis_result_tvalid_float_div :  STD_LOGIC;
signal m_axis_result_tdata_div  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal m_axis_result_tdata_float :  STD_LOGIC_VECTOR(31 DOWNTO 0);
--    signal m_axis_result_tdata_float_divisor :  STD_LOGIC_VECTOR(31 DOWNTO 0):= x"46FFE000";

signal m_axis_result_tdata_fixed :  STD_LOGIC_VECTOR(47 DOWNTO 0);

signal m_axis_dout_tvalid_cordic      :  STD_LOGIC;
signal m_axis_dout_tdata_cordic       :  STD_LOGIC_VECTOR(31 DOWNTO 0);

signal yaw_angle_in_radians : std_logic_vector(31 downto 0);

signal magneto_in : std_logic_vector(15 downto 0):= (others=>'0');
signal magneto_in_valid : std_logic;
signal magneto_y_x_append : std_logic_vector(95 downto 0 );

type cor_cal is (idle,fixed_to_float_state_x,fixed_to_float_state_x_done,float_to_fixed_state_x,fixed_to_float_state_y,fixed_to_float_state_y_done,float_to_fixed_state_y,float_state_y_division,yaw_in,yaw_out,yaw_radians_fixed_to_float,yaw_degree_conv_360_calc,yaw_degree_calc);
signal state_cal : cor_cal ;
signal fixed_x : STD_LOGIC_VECTOR(47 DOWNTO 0);
signal fixed_y : STD_LOGIC_VECTOR(47 DOWNTO 0);
    
signal s_axis_angle_radian_float_tvalid : std_logic;      
signal s_axis_angle_radian_flaot_tlast  : std_logic;        
signal s_axis_angle_radian_float_tdata  : std_logic_vector(31 downto 0);         
signal s_axis_mul_conatnt_float_tvalid  : std_logic;         
signal s_axis_mul_conatnt_flaot_tlast   : std_logic;         
signal s_axis_mul_conatnt_float_tdata   : std_logic_vector(31 downto 0);    

signal s_axis_angle_radian_fixed_tvalid : std_logic;   
signal s_axis_angle_radian_fixed_tlast  : std_logic;   
signal s_axis_angle_radian_fixed_tdata  : std_logic_vector(31 downto 0);   
--signal s_axis_angle_radian_float_tvalid : std_logic;   
signal s_axis_angle_radian_float_tlast  : std_logic;   
--signal s_axis_angle_radian_float_tdata  : std_logic_vector(31 downto 0);   
       
signal m_axis_angle_degree_float_tvalid       : std_logic;         
signal m_axis_angle_degree_float_tlast        : std_logic;         
signal m_axis_angle_degree_float_tdata        : std_logic_vector(31 downto 0);        

signal m_axis_angle_degree_fixed_tvalid       : std_logic;         
signal m_axis_angle_degree_fixed_tlast        : std_logic;         
signal m_axis_angle_degree_fixed_tdata        : std_logic_vector(15 downto 0);  
    
signal yaw_degree_conv_360                    : signed(9 downto 0);


begin

yaw_radians <= yaw_angle_in_radians ;

process(clk,rst)
begin 
    if rst = '1' then
        magneto_y_x_append <=(others =>'0');
        yaw_angle_in_radians <=(others =>'0');
        fixed_x <=(others =>'0');
        fixed_y <=(others =>'0');
        magneto_in_valid  <= '0';
        s_axis_a_tlast    <= '0';
        s_axis_cartesian_tvalid    <= '0';
        s_axis_cartesian_tlast    <= '0';

        
    elsif (rising_edge (clk))then     
     case state_cal is 
     when idle => 
                        magneto_y_x_append <=(others =>'0');
                        yaw_angle_in_radians <=yaw_angle_in_radians;
                        state_cal <= fixed_to_float_state_x ;  
                        magneto_in_valid  <= '0';
                        s_axis_a_tlast    <= '0';
                        s_axis_cartesian_tvalid    <= '0';
     when fixed_to_float_state_x=>if magneto_in_valid  = '1' then 
                                        magneto_in_valid <= '0';
                                        state_cal <= float_to_fixed_state_x;
                                        s_axis_a_tlast    <= '1';
                                  else 
                                        magneto_in   <= magneto_x ; 
                                        magneto_in_valid <= '1';
                                        state_cal <= fixed_to_float_state_x;
                                        s_axis_a_tlast    <= '0';
                                  end if ; 
  
    when float_to_fixed_state_x =>  if m_axis_result_tvalid_fixed  = '1' then
                                         s_axis_a_tlast    <= '0';
                                         state_cal <= fixed_to_float_state_y;
                                         fixed_x <= m_axis_result_tdata_fixed(47 downto 0);
                                         magneto_in_valid <= '0';
                                    else 
                                         state_cal <= float_to_fixed_state_x;
                                         magneto_in_valid <= '0';
                                    end if ;
   
                                     
     when fixed_to_float_state_y => if magneto_in_valid  = '1' then 
                                        magneto_in_valid <= '0';
                                        state_cal <= float_to_fixed_state_y;
                                        s_axis_a_tlast    <= '1';
                                  else 
                                        magneto_in   <= magneto_y ; 
                                        magneto_in_valid <= '1';
                                        state_cal <= fixed_to_float_state_y;
                                        s_axis_a_tlast    <= '0';
                                  end if ; 
  when float_to_fixed_state_y    =>  if m_axis_result_tvalid_fixed  = '1' then
                                         s_axis_a_tlast    <= '0';
                                         state_cal <= yaw_in;
                                         fixed_y <= m_axis_result_tdata_fixed(47 downto 0);
                                         magneto_in_valid <= '0';
                                    else 
                                         state_cal <= float_to_fixed_state_y;
                                         magneto_in_valid <= '0';
                                    end if ;
                                        
     when yaw_in                     =>                                
                                            magneto_y_x_append <=  fixed_y & fixed_x ; 
                                            s_axis_a_tlast    <= '0';
                                            state_cal <= yaw_out ;
                                            s_axis_cartesian_tvalid    <= '1';
                                            s_axis_cartesian_tlast    <= '1';
     when yaw_out                     => if m_axis_dout_tvalid_cordic = '1' then 
                                            yaw_angle_in_radians <= m_axis_dout_tdata_cordic ; 
                                            s_axis_a_tlast    <= '0';
                                            state_cal <= yaw_degree_conv_360_calc;--idle ;
                                            s_axis_cartesian_tlast    <= '0';
                                         else 
                                            yaw_angle_in_radians <= yaw_angle_in_radians ; 
                                            s_axis_a_tlast    <= '0';
                                            state_cal <= yaw_out ;                                            
                                         end if ;    
                                         s_axis_cartesian_tvalid    <= '0';
     when yaw_degree_conv_360_calc =>
        if(m_axis_angle_degree_fixed_tvalid='1')then
            if(m_axis_angle_degree_fixed_tdata(15)='1')then
              yaw_degree_conv_360 <= to_signed(360,10) + signed(m_axis_angle_degree_fixed_tdata(15) & m_axis_angle_degree_fixed_tdata(15 downto 7)); 
            else
              yaw_degree_conv_360 <= signed(m_axis_angle_degree_fixed_tdata(15) & m_axis_angle_degree_fixed_tdata(15 downto 7));
            end if;    
            state_cal <= yaw_degree_calc;
        end if;
        
     
     when yaw_degree_calc =>  
            yaw_degree <= std_logic_vector("0000000" &yaw_degree_conv_360(8 downto 0));     
            state_cal <= idle;                              
                                         
     when others                       =>  state_cal <= idle ;                                                       
     end case ;
    
    end if ;

end process ;

  
i_fixed_int16_to_float_single: fixed_int16_to_float_single
  PORT MAP (
    aclk => clk,
    s_axis_a_tlast => s_axis_a_tlast,
    s_axis_a_tvalid      => magneto_in_valid,
    s_axis_a_tdata       => magneto_in,
    m_axis_result_tvalid => m_axis_result_tvalid_float,
    m_axis_result_tlast => m_axis_result_tlast_float,
    m_axis_result_tdata  => m_axis_result_tdata_float
  );

i_div_floating_point: div_floating_point
  PORT MAP (
    aclk => clk,
    s_axis_a_tvalid => m_axis_result_tvalid_float,
    s_axis_a_tlast => m_axis_result_tlast_float,
    s_axis_a_tdata => m_axis_result_tdata_float,
    s_axis_b_tvalid =>m_axis_result_tvalid_float,--m_axis_result_tvalid_conv_factor_float,
    s_axis_b_tdata =>conv_factor ,
    m_axis_result_tvalid => m_axis_result_tvalid_float_div,
    m_axis_result_tlast => m_axis_result_tlast_float_division,
    m_axis_result_tdata => m_axis_result_tdata_div
  ); 
i_float_single_to_fixed_48_46: float_single_to_fixed_48_46
  PORT MAP (
    aclk => clk,
    s_axis_a_tlast => m_axis_result_tlast_float_division,
    s_axis_a_tvalid => m_axis_result_tvalid_float_div,
    s_axis_a_tdata => m_axis_result_tdata_div,
    m_axis_result_tvalid => m_axis_result_tvalid_fixed,
    m_axis_result_tdata => m_axis_result_tdata_fixed,
    m_axis_result_tlast => m_axis_result_tlast_fixed
    
  );

i_atan_cordic: atan_cordic
  PORT MAP (
    aclk => clk,
    s_axis_cartesian_tvalid => s_axis_cartesian_tvalid,
    s_axis_cartesian_tlast => s_axis_cartesian_tlast,
    s_axis_cartesian_tdata => magneto_y_x_append,
    m_axis_dout_tvalid => m_axis_dout_tvalid_cordic,
    m_axis_dout_tlast => m_axis_dout_tlast,
    m_axis_dout_tdata => m_axis_dout_tdata_cordic
  );

i_radian_fixed_32_29_to_float_single : radian_fixed_32_29_to_float_single
  PORT MAP (
    aclk                 => clk,
    s_axis_a_tvalid      => m_axis_dout_tvalid_cordic,--s_axis_angle_radian_fixed_tvalid,
    s_axis_a_tlast       => m_axis_dout_tlast,
    s_axis_a_tdata       => m_axis_dout_tdata_cordic,--s_axis_angle_radian_fixed_tdata,
    m_axis_result_tvalid => s_axis_angle_radian_float_tvalid,
    m_axis_result_tlast  => s_axis_angle_radian_float_tlast,
    m_axis_result_tdata  => s_axis_angle_radian_float_tdata
  );


angle_radian_to_degree : mul_float
  PORT MAP (
    aclk                 => clk,
    s_axis_a_tvalid      => s_axis_angle_radian_float_tvalid,
    s_axis_a_tlast       => s_axis_angle_radian_float_tlast,
    s_axis_a_tdata       => s_axis_angle_radian_float_tdata,
    s_axis_b_tvalid      => s_axis_angle_radian_float_tvalid,
    s_axis_b_tdata       => x"42651746",--s_axis_mul_conatnt_float_tdata,
    m_axis_result_tvalid => m_axis_angle_degree_float_tvalid,
    m_axis_result_tlast  => m_axis_angle_degree_float_tlast,
    m_axis_result_tdata  => m_axis_angle_degree_float_tdata
  );
  

i_degree_float_single_to_fixed_16_7 : degree_float_single_to_fixed_16_7
  PORT MAP (
    aclk                 => clk,
    s_axis_a_tvalid      => m_axis_angle_degree_float_tvalid,
    s_axis_a_tdata       => m_axis_angle_degree_float_tdata,
    s_axis_a_tlast       => m_axis_angle_degree_float_tlast,
    m_axis_result_tvalid => m_axis_angle_degree_fixed_tvalid,
    m_axis_result_tdata  => m_axis_angle_degree_fixed_tdata,
    m_axis_result_tlast  => m_axis_angle_degree_fixed_tlast
  );

end Behavioral;
