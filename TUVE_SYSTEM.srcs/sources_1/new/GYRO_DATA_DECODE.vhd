----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2022 05:25:10 PM
-- Design Name: 
-- Module Name: GYRO_DATA - Behavioral
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
 use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GYRO_DATA_DECODE is
  Port (
  CLK              : in std_logic;
  RST              : in std_logic;
  YAW              : in std_logic_vector(15 downto 0);
  YAW_OFFSET       : in std_logic_vector(15 downto 0);
  PITCH            : in std_logic_vector(15 downto 0);
  PITCH_OFFSET     : in std_logic_vector(15 downto 0);
  CORRECTED_YAW    : buffer std_logic_vector(15 downto 0);
  CORRECTED_PITCH  : buffer std_logic_vector(15 downto 0)
   );




end GYRO_DATA_DECODE;

architecture Behavioral of GYRO_DATA_DECODE is

component GYRO_DIV is
  PORT(
    aclk                  :in std_logic;
    s_axis_divisor_tvalid : in std_logic;
    s_axis_divisor_tdata : in std_logic_vector(15 downto 0);
    s_axis_dividend_tvalid : in std_logic;
    s_axis_dividend_tdata : in std_logic_vector(15 downto 0);
    m_axis_dout_tvalid : out std_logic;
    m_axis_dout_tdata  : out std_logic_vector(31 downto 0)
  );
end component;

----------------------------
COMPONENT TOII_TUVE_ila

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;
----------------------------

signal probe0: std_logic_vector(127 downto 0);

signal DECODED_YAW_TEMP : signed(15 downto 0);
signal DECODED_YAW_CORRECTED : signed(15 downto 0);

signal DECODED_PITCH_TEMP : signed(15 downto 0);     
signal DECODED_PITCH_CORRECTED : signed(15 downto 0);

signal DIVIDEND_VALID   : std_logic;
signal DIVIDEND         : std_logic_vector(15 downto 0);
signal DIV_OUT : std_logic_vector(31 downto 0);
signal DIV_OUT_VALID : std_logic;


type state_t is (st_idle,st_yaw_div_start, st_yaw_div_done,st_pitch_div_start, st_pitch_div_done,st_yaw_pitch_offset,st_yaw_pitch_correction,st_yaw_pitch_correction1);
signal state : state_t;

ATTRIBUTE MARK_DEBUG : string;

ATTRIBUTE MARK_DEBUG of YAW                     : SIGNAL IS "TRUE";                   
ATTRIBUTE MARK_DEBUG of PITCH                   : SIGNAL IS "TRUE";                   
ATTRIBUTE MARK_DEBUG of CORRECTED_YAW           : SIGNAL IS "TRUE";                   
ATTRIBUTE MARK_DEBUG of CORRECTED_PITCH         : SIGNAL IS "TRUE";                   
ATTRIBUTE MARK_DEBUG of DECODED_YAW_CORRECTED   : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DECODED_PITCH_CORRECTED : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of DECODED_YAW_TEMP        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DECODED_PITCH_TEMP      : SIGNAL IS "TRUE";
      



begin


--DECODED_PITCH    <= std_logic_vector((not unsigned(PITCH)) + 1) when(PITCH(15)= '1') else PITCH;

process(clk,rst) begin
    if(RST='1')then
        state <= st_idle;
        DIVIDEND_VALID <= '0';
        DIVIDEND <=x"0000";
    elsif rising_edge(clk)then
        case state is
            when st_idle =>
                DIVIDEND_VALID <= '0';
                state <= st_yaw_div_start;
                
            when st_yaw_div_start =>
                DIVIDEND_VALID <= '1';
                DIVIDEND <= YAW;
                state <= st_yaw_div_done;
            
            when st_yaw_div_done =>
                DIVIDEND_VALID <= '0';
                if(DIV_OUT_VALID = '1')then                    
                    DECODED_YAW_TEMP <= signed(DIV_OUT(31 downto 16))+to_signed(180,16);
                    state          <= st_pitch_div_start;
                end if;
            
            when st_pitch_div_start =>
                DIVIDEND_VALID <= '1';
                DIVIDEND       <= PITCH;
                state          <= st_pitch_div_done;
            
            when st_pitch_div_done =>
                DIVIDEND_VALID <= '0';
                if(DIV_OUT_VALID = '1')then                   
                    DECODED_PITCH_TEMP <= signed(DIV_OUT(31 downto 16));
                    state              <= st_yaw_pitch_offset;
                end if;
                
            
            when st_yaw_pitch_offset =>
--                DECODED_YAW_CORRECTED   <= DECODED_YAW_TEMP - to_signed(62,16);
                DECODED_YAW_CORRECTED   <= DECODED_YAW_TEMP - signed(YAW_OFFSET);  
--                DECODED_PITCH_CORRECTED <= x"0000" - (DECODED_PITCH_TEMP+to_signed(90,16)); 
                DECODED_PITCH_CORRECTED <= (DECODED_PITCH_TEMP+to_signed(180,16))+signed(PITCH_OFFSET); 
                state          <= st_yaw_pitch_correction; 
                
            when st_yaw_pitch_correction  =>   
                if(DECODED_YAW_CORRECTED(15)='1')then
                    CORRECTED_YAW  <= std_logic_vector(( (DECODED_YAW_CORRECTED)) + 360);                           
                else
                    CORRECTED_YAW  <= std_logic_Vector(DECODED_YAW_CORRECTED);          
                end if;
                
--                if(DECODED_PITCH_CORRECTED < -90)then
--                    CORRECTED_PITCH       <= std_logic_vector(x"0000"-( (DECODED_PITCH_TEMP) - 90));
--                else
--                    CORRECTED_PITCH       <= std_logic_Vector(DECODED_PITCH_CORRECTED); 
--                end if;  
               if(DECODED_PITCH_CORRECTED > to_signed(360,16))then
                DECODED_PITCH_CORRECTED <= DECODED_PITCH_CORRECTED - to_signed(360,16);              
               end if;   
                                      
                state          <= st_yaw_pitch_correction1;             
            
            when st_yaw_pitch_correction1 =>
                if(DECODED_PITCH_CORRECTED < 180)then
                    CORRECTED_PITCH       <= std_logic_vector(x"0000"-( (DECODED_PITCH_CORRECTED) - 90));
                else
                    CORRECTED_PITCH       <= std_logic_Vector(to_signed(270,16) - DECODED_PITCH_CORRECTED); 
                end if;      
                state          <= st_idle;           
        end case;
    end if;
    
end process;


i_gyro_div : GYRO_DIV
  PORT MAP (
    aclk =>  CLK,
    s_axis_divisor_tvalid => '1',
    s_axis_divisor_tdata => x"0064",
    s_axis_dividend_tvalid => DIVIDEND_VALID,
    s_axis_dividend_tdata => DIVIDEND,
    m_axis_dout_tvalid => DIV_OUT_VALID,
    m_axis_dout_tdata => DIV_OUT
  );
  

--    --DECODED_YAW_TEMP <= signed(YAW)/100+to_signed(180,16);
--        DECODED_YAW_CORRECTED <= DECODED_YAW_TEMP - to_signed(62,16); 
--        DECODED_YAW       <= std_logic_vector(( (DECODED_YAW_CORRECTED)) + 360) when(DECODED_YAW_CORRECTED(15)= '1') else std_logic_Vector(DECODED_YAW_CORRECTED);             
        
--        --DECODED_PITCH_TEMP <= signed(PITCH)/100;
--        DECODED_PITCH_CORRECTED <= x"0000" - (DECODED_PITCH_TEMP+to_signed(90,16)); 
--        DECODED_PITCH       <= std_logic_vector(x"0000"-( (DECODED_PITCH_TEMP) - 90)) when(DECODED_PITCH_CORRECTED<-90) else std_logic_Vector(DECODED_PITCH_CORRECTED);             
        

--pitch_div : div_gen_0
--  PORT MAP (
--    aclk =>  CLK,
--    s_axis_divisor_tvalid => '1',
--    s_axis_divisor_tdata => x"0064",
--    s_axis_dividend_tvalid => PITCH_VALID,
--    s_axis_dividend_tdata => PITCH,
--    m_axis_dout_tvalid => PITCH_DIV_OUT_VALID,
--    m_axis_dout_tdata => PITCH_DIV_OUT
--  );

--probe0(15 downto 0)     <= YAW;
--probe0(31 downto 16)    <= PITCH;
--probe0(47 downto 32)    <= CORRECTED_YAW;
--probe0(63 downto 48)    <= CORRECTED_PITCH;
--probe0(79 downto 64)    <= std_logic_vector(DECODED_YAW_CORRECTED);
--probe0(95 downto 80)    <= std_logic_vector(DECODED_PITCH_CORRECTED);
--probe0(111 downto 96)   <= std_logic_vector(DECODED_YAW_TEMP);
--probe0(127 downto 112)  <= std_logic_vector(DECODED_PITCH_TEMP);
----probe0(127 downto 96)  <= (others=>'0');



--i_TOII_TUVE_ila: TOII_TUVE_ila
--PORT MAP (
--  clk => CLK,
--  probe0 => probe0
--);

end Behavioral;