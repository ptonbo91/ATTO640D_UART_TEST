----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.10.2022 19:31:51
-- Design Name: 
-- Module Name: calibration - Behavioral
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

entity icm_soft_calibration is
  Port ( 
            CLK                         : in std_logic; 
            RST                         : in std_logic; 
            TICK_1S                     : in std_logic; 
            start_calibration           : in std_logic; 
--            magneto_x                   : in std_logic_vector(15 downto 0); 
            magneto_y                   : in std_logic_vector(15 downto 0);
            magneto_z                   : in std_logic_vector(15 downto 0);
--            magneto_x_crr               : out std_logic_vector(15 downto 0);
            magneto_y_crr               : out std_logic_vector(15 downto 0);
            magneto_z_crr               : out std_logic_vector(15 downto 0);
            calibration_done            : out std_logic
              
  );
end icm_soft_calibration;

architecture Behavioral of icm_soft_calibration is

COMPONENT fixed_int16_to_float_single
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT div_floating_point
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tready : OUT STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT mult_floating_point
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT float_single_to_fixed_int16
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

type state is (idle, 
               magneto_y_calibration, magneto_y_calibration1,magneto_y_calibration2,
               magneto_z_calibration,magneto_z_calibration1,magneto_z_calibration2,
               time_cnt,st_avg_soft,
               st_fixed_to_float_avg_soft_start,st_fixed_to_float_avg_soft_done,
               st_fixed_to_float_y_adj_start,st_fixed_to_float_y_adj_done,
               st_fixed_to_float_z_adj_start,st_fixed_to_float_z_adj_done,
               st_fixed_to_float_magneto_y_start,st_fixed_to_float_magneto_y_done,
               st_fixed_to_float_magneto_z_start,st_fixed_to_float_magneto_z_done,
               st_float_div_y_start,st_float_div_y_done,
               st_float_div_z_start,st_float_div_z_done,
               st_float_mult_y_start,st_float_mult_y_done,
               st_float_mult_z_start,st_float_mult_z_done,               
               st_float_to_fixed_y_start, st_float_to_fixed_y_done,
               st_float_to_fixed_z_start, st_float_to_fixed_z_done
                );
signal calib_state : state ;
--    signal x_large  : signed  (15 downto 0)   :="1000000100001100"  ;
--    signal x_small  : signed  (15 downto 0)   :="0111111011110100"  ;
    signal y_large  : signed  (15 downto 0)   :="1000000100001100"  ;
    signal y_small  : signed  (15 downto 0)   :="0111111011110100"  ;
    signal z_large  : signed  (15 downto 0)   :="1000000100001100"  ;
    signal z_small  : signed  (15 downto 0)   :="0111111011110100"  ;
    
--    signal x_adj  : signed  (15 downto 0)  ;
    signal y_adj  : signed  (15 downto 0)  ;
    signal z_adj  : signed  (15 downto 0)  ;
    
--    signal x_adj_i  : signed  (15 downto 0)  ;
    signal y_adj_i            : signed  (15 downto 0)  ;
    signal z_adj_i            : signed  (15 downto 0)  ;
    
    signal sum_y_z_adj        : signed(15 downto 0);
    signal avg_soft_adj       : signed(15 downto 0);
    signal avg_soft_adj_float : std_logic_vector(31 downto 0);
    signal y_adj_float        : std_logic_vector(31 downto 0); 
    signal z_adj_float        : std_logic_vector(31 downto 0); 
    signal magneto_y_float    : std_logic_vector(31 downto 0);
    signal magneto_z_float    : std_logic_vector(31 downto 0); 

    signal start_time_cnt   : std_logic;
    signal calib_done_timeout_cnt   : std_logic_vector(3 downto 0);
--    signal probe0 : std_logic_vector(127 downto 0);
    
--COMPONENT TOII_TUVE_ila

--PORT (
--  clk : IN STD_LOGIC;



--  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
--);
--END COMPONENT;



signal s_axis_fixed_tvalid            : std_logic;
signal s_axis_fixed_tdata             : std_logic_vector(15 downto 0);
signal m_axis_result_tvalid_float     : std_logic;
signal m_axis_result_tdata_float      : std_logic_vector(31 downto 0);

signal s_axis_float_dividend_tvalid   : std_logic := '0' ;
signal s_axis_float_dividend_tready   : std_logic;  
signal s_axis_float_dividend_tdata    : std_logic_vector(31 downto 0);  
signal s_axis_float_divisor_tvalid    : std_logic := '0' ; 
signal s_axis_float_divisor_tready    : std_logic;
signal s_axis_float_divisor_tdata     : std_logic_vector(31 downto 0); 

signal m_axis_result_tvalid_float_div : std_logic;     
signal m_axis_result_tdata_float_div  : std_logic_vector(31 downto 0);               
  
signal scale_y : std_logic_vector(31 downto 0);  
signal scale_z : std_logic_vector(31 downto 0);  


signal s_axis_float_mult_a_tvalid : std_logic;
signal s_axis_float_mult_a_tdata  : std_logic_vector(31 downto 0);    
signal s_axis_float_mult_b_tvalid : std_logic;   
signal s_axis_float_mult_b_tdata  : std_logic_vector(31 downto 0);   
signal m_axis_result_mult_tvalid  : std_logic;  
signal m_axis_result_mult_tdata   : std_logic_vector(31 downto 0);    

signal mult_magneto_y_float : std_logic_vector(31 downto 0);
signal mult_magneto_z_float : std_logic_vector(31 downto 0);

signal mult_magneto_y_fixed : std_logic_vector(31 downto 0);
signal mult_magneto_z_fixed : std_logic_vector(31 downto 0);

signal s_axis_float_tvalid : std_logic; 
signal s_axis_float_tdata  : std_logic_vector(31 downto 0); 
signal m_axis_fixed_tvalid : std_logic; 
signal m_axis_fixed_tdata  : std_logic_vector(15 downto 0); 

signal latch_start_calibration : std_logic;    
begin

         
process(clk,rst)
begin  
    if rst = '1' then 
--        magneto_x_crr   <= (others=>'0');
        magneto_y_crr   <= (others=>'0');
        magneto_z_crr   <= (others=>'0');
--        x_adj           <= (others=>'0');  
--        y_adj           <= (others=>'0');  
--        z_adj           <= (others=>'0');  
--        x_adj_i         <= (others=>'0');  
        y_adj_i         <= (others=>'0');  
        z_adj_i         <= (others=>'0');  
        y_adj           <= (others=>'0'); 
        z_adj           <= (others=>'0');
        sum_y_z_adj     <= (others=>'0');
        scale_y         <= x"3F800000";
        scale_z         <= x"3F800000";
        start_time_cnt  <= '0';
        calibration_done<= '0'; 
        calib_done_timeout_cnt <= x"0";  
        calib_state     <= idle;
        latch_start_calibration <= '0';
    elsif (rising_edge(CLK))then 

        if(tick_1s = '1' ) then  
        
--            if(start_time_cnt = '1' and calib_done_timeout_cnt < 10 )then
            if(start_time_cnt = '1' )then
                calib_done_timeout_cnt <= calib_done_timeout_cnt + '1'; 
--            elsif(start_time_cnt = '1' and calib_done_timeout_cnt >= 10 )then
--                calib_done_timeout_cnt <= x"0";
            else
                calib_done_timeout_cnt <= x"0" ;
            end if;    
--        else 
--            calib_done_timeout_cnt <= calib_done_timeout_cnt ;
            
        end   if;                    
        
        if(start_calibration='1')then
            latch_start_calibration <= '1';
        end if;
        
        case calib_state is 
           when idle                    =>if latch_start_calibration = '1' then  
                                            calib_state             <= magneto_y_calibration;
                                            start_time_cnt          <= '1';
                                            latch_start_calibration <= '0';
                                          else 
                                            calib_state    <= st_fixed_to_float_magneto_y_start;--idle;
                                            start_time_cnt <= '0';
                                          end if ; 
                                          calibration_done <= '0';
                                          
           when  magneto_y_calibration=> 
                                               calib_state <= magneto_y_calibration1;
                                               if (y_large < signed(magneto_y) )then 
                                                    y_large <= signed(magneto_y);
                                               end if;
                                               if(y_small > signed(magneto_y) )then 
                                                    y_small <= signed(magneto_y);
                                               end if ; 
                                                 
           when  magneto_y_calibration1=> 
                            y_adj_i <= (y_large) - (y_small);
                            calib_state <= magneto_y_calibration2;
 
           when  magneto_y_calibration2=> 
                            y_adj <= shift_right(y_adj_i,1);      
                            calib_state <= magneto_z_calibration;   
                                            
           when magneto_z_calibration   => 
                                             calib_state <= magneto_z_calibration1;
                                               if (z_large < signed(magneto_z) )then 
                                                    z_large <= signed(magneto_z);
                                               end if;
                                               if(z_small > signed(magneto_z) )then 
                                                    z_small <= signed(magneto_z);
                                               end if ; 
                                                
                                                
  
           when  magneto_z_calibration1=> 
                            z_adj_i <= (z_large) - (z_small);
                            calib_state <= magneto_z_calibration2;
 
           when  magneto_z_calibration2=> 
                            z_adj <= shift_right(z_adj_i,1);        
                            calib_state <= time_cnt;        
           when time_cnt => 
                               
                            if( calib_done_timeout_cnt=10)then
                                calib_state <= st_avg_soft;
                                sum_y_z_adj <= y_adj + z_adj;
                                start_time_cnt <= '0';
                            else
                                calib_state <= magneto_y_calibration;                                
                            end if ;
                            
           when st_avg_soft =>
                    avg_soft_adj <= shift_right(sum_y_z_adj,1);   
                    calib_state  <= st_fixed_to_float_avg_soft_start;
                     
           when st_fixed_to_float_avg_soft_start =>
                    s_axis_fixed_tvalid <= '1';
                    s_axis_fixed_tdata  <= std_logic_vector(avg_soft_adj);
                    calib_state         <= st_fixed_to_float_avg_soft_done; 
           
           when st_fixed_to_float_avg_soft_done =>        
                    s_axis_fixed_tvalid <= '0';  
                    if(m_axis_result_tvalid_float ='1')then
                        avg_soft_adj_float <= m_axis_result_tdata_float;
                        calib_state        <= st_fixed_to_float_y_adj_start;
                    end if;   
                      

           when st_fixed_to_float_y_adj_start =>
                    s_axis_fixed_tvalid <= '1';
                    s_axis_fixed_tdata  <= std_logic_vector(y_adj);
                    calib_state         <= st_fixed_to_float_y_adj_done; 
           
           when st_fixed_to_float_y_adj_done =>        
                    s_axis_fixed_tvalid <= '0'; 
                    if(m_axis_result_tvalid_float ='1')then
                        y_adj_float <= m_axis_result_tdata_float;
                        calib_state <= st_fixed_to_float_z_adj_start;
                    end if;   

           when st_fixed_to_float_z_adj_start =>
                    s_axis_fixed_tvalid <= '1';
                    s_axis_fixed_tdata  <= std_logic_vector(z_adj);
                    calib_state         <= st_fixed_to_float_z_adj_done; 
           
           when st_fixed_to_float_z_adj_done =>        
                    s_axis_fixed_tvalid <= '0';  
                    if(m_axis_result_tvalid_float ='1')then
                        z_adj_float  <= m_axis_result_tdata_float;
                        calib_state  <= st_float_div_y_start;
                    end if;                                           
                                        
           when st_float_div_y_start =>
                s_axis_float_dividend_tvalid <= '1';
                s_axis_float_dividend_tdata  <= avg_soft_adj_float;
                s_axis_float_divisor_tvalid  <= '1';
                s_axis_float_divisor_tdata   <= y_adj_float;       
                calib_state                  <= st_float_div_y_done;   

           when st_float_div_y_done =>
                if(s_axis_float_dividend_tready ='1')then 
                    s_axis_float_dividend_tvalid <= '0';
                end if;    
                if(s_axis_float_divisor_tready ='1')then 
                    s_axis_float_divisor_tvalid <= '0';
                end if;  
                if(m_axis_result_tvalid_float_div ='1')then    
                    scale_y     <= m_axis_result_tdata_float_div;                 
                    calib_state <= st_float_div_z_start;  
                end if;

           when st_float_div_z_start =>
                s_axis_float_dividend_tvalid <= '1';
                s_axis_float_dividend_tdata  <= avg_soft_adj_float;
                s_axis_float_divisor_tvalid  <= '1';
                s_axis_float_divisor_tdata   <= z_adj_float;       
                calib_state                  <= st_float_div_z_done;   

           when st_float_div_z_done =>
                if(s_axis_float_dividend_tready ='1')then 
                    s_axis_float_dividend_tvalid <= '0';
                end if;    
                if(s_axis_float_divisor_tready ='1')then 
                    s_axis_float_divisor_tvalid <= '0';
                end if;  
                if(m_axis_result_tvalid_float_div ='1')then    
                    scale_z          <= m_axis_result_tdata_float_div;     
                    calibration_done <= '1';            
                    calib_state <= st_fixed_to_float_magneto_y_start;  
                end if;


          when st_fixed_to_float_magneto_y_start =>
                    calibration_done <= '0'; 
                    s_axis_fixed_tvalid <= '1';
                    s_axis_fixed_tdata  <= std_logic_vector(magneto_y);
                    calib_state         <= st_fixed_to_float_magneto_y_done; 
           
           when st_fixed_to_float_magneto_y_done =>        
                    s_axis_fixed_tvalid <= '0';   
                    if(m_axis_result_tvalid_float ='1')then
                        magneto_y_float <= m_axis_result_tdata_float;
                        calib_state  <= st_fixed_to_float_magneto_z_start;
                    end if;   
                    
           when st_fixed_to_float_magneto_z_start =>
                    s_axis_fixed_tvalid <= '1';
                    s_axis_fixed_tdata  <= std_logic_vector(magneto_z);
                    calib_state         <= st_fixed_to_float_magneto_z_done; 
           
           when st_fixed_to_float_magneto_z_done =>        
                    s_axis_fixed_tvalid <= '0';  
                    if(m_axis_result_tvalid_float ='1')then
                        magneto_z_float <= m_axis_result_tdata_float;
                        calib_state     <= st_float_mult_y_start;
                    end if;  

           when st_float_mult_y_start =>
                s_axis_float_mult_a_tvalid <= '1';
                s_axis_float_mult_a_tdata  <= scale_y;
                s_axis_float_mult_b_tvalid <= '1';
                s_axis_float_mult_b_tdata  <= magneto_y_float;
                calib_state                <= st_float_mult_y_done;
 
           when st_float_mult_y_done =>
                s_axis_float_mult_a_tvalid <= '0';
                s_axis_float_mult_b_tvalid <= '0';
                if(m_axis_result_mult_tvalid ='1')then    
                    mult_magneto_y_float <= m_axis_result_mult_tdata;                 
                    calib_state          <= st_float_mult_z_start;  
                end if;            

           when st_float_mult_z_start =>
                s_axis_float_mult_a_tvalid <= '1';
                s_axis_float_mult_a_tdata  <= scale_z;
                s_axis_float_mult_b_tvalid <= '1';
                s_axis_float_mult_b_tdata  <= magneto_z_float;
                calib_state                <= st_float_mult_z_done;
 
           when st_float_mult_z_done =>
                s_axis_float_mult_a_tvalid <= '0';
                s_axis_float_mult_b_tvalid <= '0';
                if(m_axis_result_mult_tvalid ='1')then    
                    mult_magneto_z_float <= m_axis_result_mult_tdata;                 
                    calib_state          <= st_float_to_fixed_y_start;  
                end if;       

          when st_float_to_fixed_y_start =>
                    s_axis_float_tvalid <= '1';
                    s_axis_float_tdata  <= mult_magneto_y_float;
                    calib_state         <= st_float_to_fixed_y_done; 
           
           when st_float_to_fixed_y_done =>        
                    s_axis_float_tvalid <= '0'; 
                    if(m_axis_fixed_tvalid ='1')then
                        magneto_y_crr <= m_axis_fixed_tdata;
                        calib_state <= st_float_to_fixed_z_start;
                    end if;   
                    
          when st_float_to_fixed_z_start =>
                    s_axis_float_tvalid <= '1';
                    s_axis_float_tdata  <= mult_magneto_z_float;
                    calib_state         <= st_float_to_fixed_z_done; 
           
           when st_float_to_fixed_z_done =>        
                    s_axis_float_tvalid <= '0'; 
                    if(m_axis_fixed_tvalid ='1')then
                        magneto_z_crr <= m_axis_fixed_tdata;
                        calib_state <= idle;
                    end if;   

        end case;
    end if ;

end process ;

i_fixed_int16_to_float_single: fixed_int16_to_float_single
  PORT MAP (
    aclk => CLK,
    s_axis_a_tvalid      => s_axis_fixed_tvalid,
    s_axis_a_tdata       => s_axis_fixed_tdata,
    m_axis_result_tvalid => m_axis_result_tvalid_float,
    m_axis_result_tdata  => m_axis_result_tdata_float
  );

i_div_floating_point: div_floating_point
  PORT MAP (
    aclk => clk,
    s_axis_a_tvalid      => s_axis_float_dividend_tvalid, 
    s_axis_a_tready      => s_axis_float_dividend_tready,
    s_axis_a_tdata       => s_axis_float_dividend_tdata,
    s_axis_b_tvalid      => s_axis_float_divisor_tvalid,
    s_axis_b_tready      => s_axis_float_divisor_tready,
    s_axis_b_tdata       => s_axis_float_divisor_tdata,
    m_axis_result_tvalid => m_axis_result_tvalid_float_div,
    m_axis_result_tdata  => m_axis_result_tdata_float_div
  ); 

i_mult_floating_point : mult_floating_point
  PORT MAP (
    aclk                 => clk,
    s_axis_a_tvalid      => s_axis_float_mult_a_tvalid,
    s_axis_a_tdata       => s_axis_float_mult_a_tdata,
    s_axis_b_tvalid      => s_axis_float_mult_b_tvalid,
    s_axis_b_tdata       => s_axis_float_mult_b_tdata,
    m_axis_result_tvalid => m_axis_result_mult_tvalid,
    m_axis_result_tdata  => m_axis_result_mult_tdata
  );

i_float_single_to_fixed_int16 : float_single_to_fixed_int16
  PORT MAP (
    aclk                 => clk,
    s_axis_a_tvalid      => s_axis_float_tvalid,
    s_axis_a_tdata       => s_axis_float_tdata,
    m_axis_result_tvalid => m_axis_fixed_tvalid,
    m_axis_result_tdata  => m_axis_fixed_tdata
  );

--probe0(15 downto 0)<= magneto_y;
--probe0(31 downto 16)<= magneto_z;
--probe0(47 downto 32)<= std_logic_vector(z_adj);
--probe0(63 downto 48)<= std_logic_vector(y_adj);
--probe0(79 downto 64)<= std_logic_vector(y_large);
--probe0(95 downto 80)<= std_logic_vector(y_small);
--probe0(111 downto 96)<= std_logic_vector(z_large);
--probe0(112)<= start_time_cnt;
--probe0(113)<= start_calibration;
--probe0(114)<= tick_1s;
--probe0(115)<= calibration_done;
--probe0(118 downto 116)<= std_logic_vector(to_unsigned(state'POS(calib_state), 3));
--probe0(127 downto 119)<= (others=>'0');
----probe0(127 downto 112)<= std_logic_vector(z_small);

----    signal start_time_cnt   : std_logic;
----    signal calib_done_timeout_cnt   : std_logic_vector(3 downto 0);

--i_TOII_TUVE_ila: TOII_TUVE_ila
--PORT MAP (
--  clk => CLK,
--  probe0 => probe0
--);

end Behavioral;
