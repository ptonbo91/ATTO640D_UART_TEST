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

entity icm_calibration is
  Port ( 
            CLK                         : in std_logic; 
            RST                         : in std_logic; 
            TICK_1S                     : in std_logic; 
            start_calibration           : in std_logic; 
            magneto_x                   : in std_logic_vector(15 downto 0); 
            magneto_y                   : in std_logic_vector(15 downto 0);
            magneto_z                   : in std_logic_vector(15 downto 0);
            magneto_x_crr               : out std_logic_vector(15 downto 0);
            magneto_y_crr               : out std_logic_vector(15 downto 0);
            magneto_z_crr               : out std_logic_vector(15 downto 0);
            calibration_done            : buffer std_logic
              
  );
end icm_calibration;

architecture Behavioral of icm_calibration is
type state is (idle,magneto_y_calibration, magneto_y_calibration1,magneto_y_calibration2,magneto_z_calibration,magneto_z_calibration1,magneto_z_calibration2,time_cnt);
signal calib_state : state ;
    signal x_large  : signed  (15 downto 0)   :="1000000100001100"  ;
    signal x_small  : signed  (15 downto 0)   :="0111111011110100"  ;
    signal y_large  : signed  (15 downto 0)   :="1000000100001100"  ;
    signal y_small  : signed  (15 downto 0)   :="0111111011110100"  ;
    signal z_large  : signed  (15 downto 0)   :="1000000100001100"  ;
    signal z_small  : signed  (15 downto 0)   :="0111111011110100"  ;
    
    signal x_adj  : signed  (15 downto 0)  ;
    signal y_adj  : signed  (15 downto 0)  ;
    signal z_adj  : signed  (15 downto 0)  ;
    
    signal x_adj_i  : signed  (15 downto 0)  ;
    signal y_adj_i  : signed  (15 downto 0)  ;
    signal z_adj_i  : signed  (15 downto 0)  ;

    signal start_time_cnt   : std_logic;
    signal calib_done_timeout_cnt   : std_logic_vector(3 downto 0);
    signal probe0 : std_logic_vector(127 downto 0);
    
COMPONENT TOII_TUVE_ila

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;
    
begin

         
process(clk,rst)
begin  
    if rst = '1' then 
        magneto_x_crr   <= (others=>'0');
        magneto_y_crr   <= (others=>'0');
        magneto_z_crr   <= (others=>'0');
        x_adj           <= (others=>'0');  
        y_adj           <= (others=>'0');  
        z_adj           <= (others=>'0');  
        x_adj_i         <= (others=>'0');  
        y_adj_i         <= (others=>'0');  
        z_adj_i         <= (others=>'0');  
        start_time_cnt  <= '0';
        calibration_done<= '0'; 
        calib_done_timeout_cnt <= x"0";
    elsif (rising_edge(CLK))then 
         magneto_x_crr  <=  std_logic_vector (signed(magneto_x) - x_adj) ;
         magneto_y_crr  <=  std_logic_vector (signed(magneto_y) - y_adj) ;
         magneto_z_crr  <=  std_logic_vector (signed(magneto_z) - z_adj) ;
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
        
        case calib_state is 
           when idle                    =>if start_calibration = '0' then  
                                            calib_state   <= idle;
                                            start_time_cnt <= '0';
                                          else 
                                            calib_state <= magneto_y_calibration;
                                            start_time_cnt <= '1';
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
                            y_adj_i <= (y_large) + (y_small);
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
                            z_adj_i <= (z_large) + (z_small);
                            calib_state <= magneto_z_calibration2;
 
           when  magneto_z_calibration2=> 
                            z_adj <= shift_right(z_adj_i,1);        
                            calib_state <= time_cnt;        
           when time_cnt => 
                               
                            if( calib_done_timeout_cnt=9)then
                                calib_state <= idle;
                                start_time_cnt <= '0';
                                calibration_done<= '1';
                            else
                                calib_state <= magneto_y_calibration;
                                calibration_done<= '0';                                 
                            end if ;
        end case;
    end if ;


end process ;

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
