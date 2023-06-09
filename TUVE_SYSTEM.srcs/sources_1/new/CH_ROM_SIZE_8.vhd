----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2018 02:27:04 PM
-- Design Name: 
-- Module Name: CH_ROM - RTL
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
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- Listing 13.1
-- ROM with synchonous read (inferring Block RAM)
-- character ROM
--   - 8-by-16 (8-by-2^4) font
--   - 128 (2^7) characters
--   - ROM size: 512-by-8 (2^11-by-8) bits
--               16K bits: 1 BRAM



entity CH_ROM_SIZE_8 is
   generic(
          ADDR_WIDTH: positive;
          DATA_WIDTH: positive
    );
   port(
   clk : in std_logic;
   addr: in std_logic_vector(ADDR_WIDTH -1 downto 0);
   data: out std_logic_vector(DATA_WIDTH-1 downto 0)
);
end CH_ROM_SIZE_8;

architecture RTL of CH_ROM_SIZE_8 is

   signal addr_reg: std_logic_vector(ADDR_WIDTH-1 downto 0);
   type rom_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
   
   -- ROM definition - 2^11-by-8
   constant ROM: rom_type := (
				"0000000000000000",  ----  00
				"0000000000000000",  ----  00
				"0000000000000000",  ----  11
				"0000000000000000",  ----  11
				"0000000000000000",  ----  22
				"0000000000000000",  ----  22
				"0000000000000000",  ----  33
				"0000000000000000",  ----  33
				"0000000000000000",  ----  44
				"0000000000000000",  ----  44
				"0000000000000000",  ----  55
				"0000000000000000",  ----  55
				"0000000000000000",  ----  66
				"0000000000000000",  ----  66
				"0000000000000000",  ----  77  
				"0000000000000000",  ----  77  
				
				


				"0000000000000000",  ----  00                
				"0000000000000000",  ----  00                
				"0000001111000000",  ----  11        ****
				"0000001111000000",  ----  11        ****
				"0000001111000000",  ----  22        ****
				"0000001111000000",  ----  22        ****
				"0000000000000000",  ----  33  
				"0000000000000000",  ----  33  
				"0000000000000000",  ----  44            
				"0000000000000000",  ----  44            
				"0000001111000000",  ----  55        ****
				"0000001111000000",  ----  55        ****
				"0000001111000000",  ----  66        ****  
				"0000001111000000",  ----  66        ****  
				"0000000000000000",  ----  77        
				"0000000000000000",  ----  77        




				----  ccooddee  xx3300
				----  ccooddee  xx3300


				"0011111111110000",  ----  00    **********
				"0011111111110000",  ----  00    **********
				"1111000000111100",  ----  11  ****      ****
				"1111000000111100",  ----  11  ****      ****
				"1111000011111100",  ----  22  ****    ******
				"1111000011111100",  ----  22  ****    ******
				"1111001111111100",  ----  33  ****  ********
				"1111001111111100",  ----  33  ****  ********
				"1111111100111100",  ----  44  ********  ****
				"1111111100111100",  ----  44  ********  ****
				"1111110000111100",  ----  55  ******    ****
				"1111110000111100",  ----  55  ******    ****
				"1111000000111100",  ----  66  ****      ****
				"1111000000111100",  ----  66  ****      ****
				"0011111111110000",  ----  77    **********
				"0011111111110000",  ----  77    **********


				----  ccooddee  xx3311
				----  ccooddee  xx3311


				"0000001111000000",  ----  00        ****  
				"0000001111000000",  ----  00        ****  
				"0000111111000000",  ----  11      ******
				"0000111111000000",  ----  11      ******
				"0011111111000000",  ----  22    ********  
				"0011111111000000",  ----  22    ********  
				"0000001111000000",  ----  33        ****
				"0000001111000000",  ----  33        ****
				"0000001111000000",  ----  44        ****
				"0000001111000000",  ----  44        ****
				"0000001111000000",  ----  55        ****
				"0000001111000000",  ----  55        ****
				"0000001111000000",  ----  66        ****
				"0000001111000000",  ----  66        ****
				"0011111111111100",  ----  77    ************
				"0011111111111100",  ----  77    ************






				----  ccooddee  xx3322
				----  ccooddee  xx3322
				"0011111111110000",  ----  00    **********
				"0011111111110000",  ----  00    **********
				"1111000000111100",  ----  11  ****      ****
				"1111000000111100",  ----  11  ****      ****
				"0000000000111100",  ----  22            ****
				"0000000000111100",  ----  22            ****
				"0000000011110000",  ----  33          ****
				"0000000011110000",  ----  33          ****
				"0000111111000000",  ----  44      ******
				"0000111111000000",  ----  44      ******
				"0011110000000000",  ----  55  ****
				"0011110000000000",  ----  55  ****
				"0011110000111100",  ----  66  ****      ****
				"0011110000111100",  ----  66  ****      ****
				"0011111111111100",  ----  77  **************
				"0011111111111100",  ----  77  **************




				----  ccooddee  xx3333
				----  ccooddee  xx3333
				"0011111111110000",  ----  00    **********
				"0011111111110000",  ----  00    **********
				"1111000000111100",  ----  11  ****      ****
				"1111000000111100",  ----  11  ****      ****
				"0000000000111100",  ----  22            ****
				"0000000000111100",  ----  22            ****
				"0000111111110000",  ----  33      ********      
				"0000111111110000",  ----  33      ********      
				"0000111111110000",  ----  44      ********
				"0000111111110000",  ----  44      ********
				"0000000000111100",  ----  55            ****
				"0000000000111100",  ----  55            ****
				"1111000000111100",  ----  66  ****      ****
				"1111000000111100",  ----  66  ****      ****
				"0011111111110000",  ----  77    **********
				"0011111111110000",  ----  77    **********
		
		


				----  ccooddee  xx3344
				----  ccooddee  xx3344


				"0000000011110000",  ----  00          ****
				"0000000011110000",  ----  00          ****
				"0000001111110000",  ----  11        ******
				"0000001111110000",  ----  11        ******
				"0000111111110000",  ----  22      ********
				"0000111111110000",  ----  22      ********
				"0011110011110000",  ----  33    ****  ****
				"0011110011110000",  ----  33    ****  ****
				"1111000011110000",  ----  44  ****    ****
				"1111000011110000",  ----  44  ****    ****
				"1111111111111100",  ----  55  **************
				"1111111111111100",  ----  55  **************
				"0000000011110000",  ----  66          ****
				"0000000011110000",  ----  66          ****
				"0000001111111100",  ----  77        ********
				"0000001111111100",  ----  77        ********




				----  ccooddee  xx3355
				----  ccooddee  xx3355


				"1111111111111100",  ----  00  **************
				"1111111111111100",  ----  00  **************
				"1111000000000000",  ----  11  ****
				"1111000000000000",  ----  11  ****
				"1111000000000000",  ----  22  ****
				"1111000000000000",  ----  22  ****
				"1111111111110000",  ----  33  ************
				"1111111111110000",  ----  33  ************
				"0000000000111100",  ----  44            ****
				"0000000000111100",  ----  44            ****
				"0000000000111100",  ----  55            ****
				"0000000000111100",  ----  55            ****
				"1111000000111100",  ----  66  ****      ****
				"1111000000111100",  ----  66  ****      ****
				"0011111111110000",  ----  77    **********
				"0011111111110000",  ----  77    **********




				----  ccooddee  xx3366
				----  ccooddee  xx3366


				"0000111111000000",  ----  00      ******
				"0000111111000000",  ----  00      ******
				"0011110000000000",  ----  11    ****
				"0011110000000000",  ----  11    ****
				"1111000000000000",  ----  22  ****
				"1111000000000000",  ----  22  ****
				"1111000000000000",  ----  33  ****
				"1111000000000000",  ----  33  ****
				"1111111111110000",  ----  44  ************
				"1111111111110000",  ----  44  ************
				"1111000000111100",  ----  55  ****      ****
				"1111000000111100",  ----  55  ****      ****
				"1111000000111100",  ----  66  ****      ****
				"1111000000111100",  ----  66  ****      ****
				"0011111111110000",  ----  77    **********
				"0011111111110000",  ----  77    **********




				----  ccooddee  xx3377
				----  ccooddee  xx3377
				"1111111111111100",  ----  00  **************
				"1111111111111100",  ----  00  **************
				"1111000000111100",  ----  11  ****      ****
				"1111000000111100",  ----  11  ****      ****
				"0000000000111100",  ----  22            ****
				"0000000000111100",  ----  22            ****
				"0000000011110000",  ----  33          ****
				"0000000011110000",  ----  33          ****
				"0000001111000000",  ----  44        ****
				"0000001111000000",  ----  44        ****
				"0000111100000000",  ----  55      ****
				"0000111100000000",  ----  55      ****
				"0000111100000000",  ----  66      ****
				"0000111100000000",  ----  66      ****
				"0000111100000000",  ----  77      ****
				"0000111100000000",  ----  77      ****




				----  ccooddee  xx3388
				----  ccooddee  xx3388
				"0011111111110000",  ----  00    **********
				"0011111111110000",  ----  00    **********
				"1111000000111100",  ----  11  ****      ****
				"1111000000111100",  ----  11  ****      ****
				"1111000000111100",  ----  22  ****      ****
				"1111000000111100",  ----  22  ****      ****
				"0011111111110000",  ----  33    **********
				"0011111111110000",  ----  33    **********
				"0011111111110000",  ----  44    **********
				"0011111111110000",  ----  44    **********
				"1111000000111100",  ----  55  ****      ****
				"1111000000111100",  ----  55  ****      ****
				"1111000000111100",  ----  66  ****      ****
				"1111000000111100",  ----  66  ****      ****
				"0011111111110000",  ----  77    **********
				"0011111111110000",  ----  77    **********




				----  ccooddee  xx3399
				----  ccooddee  xx3399


				"0011111111110000",  ----  00    **********
				"0011111111110000",  ----  00    **********
				"1111000000111100",  ----  11  ****      ****
				"1111000000111100",  ----  11  ****      ****
				"1111000000111100",  ----  22  ****      ****
				"1111000000111100",  ----  22  ****      ****
				"0011111111111100",  ----  33    ************
				"0011111111111100",  ----  33    ************
				"0000000000111100",  ----  44            ****
				"0000000000111100",  ----  44            ****
				"0000000011110000",  ----  55          ****
				"0000000011110000",  ----  55          ****
				"0000001111000000",  ----  66        ****
				"0000001111000000",  ----  66        ****
				"0011111100000000",  ----  77    ******
				"0011111100000000",  ----  77    ******




				"0000000000000000",  ----  00                    
				"0000000000000000",  ----  00                    
				"0011110000001111",  ----  11    ****      ****
				"0011110000001111",  ----  11    ****      ****
				"0011110000111100",  ----  22    ****    ****
				"0011110000111100",  ----  22    ****    ****
				"0000000011110000",  ----  33          ****
				"0000000011110000",  ----  33          ****
				"0000001111000000",  ----  44        ****  
				"0000001111000000",  ----  44        ****  
				"0000111100001111",  ----  55      ****    ****
				"0000111100001111",  ----  55      ****    ****
				"0011110000001111",  ----  66    ****      ****
				"0011110000001111",  ----  66    ****      ****
				"0000000000000000",  ----  77  
				"0000000000000000",  ----  77  


				"0000001100000000",  ----  00        **        
				"0000001100000000",  ----  00        **        
				"0000111100000000",  ----  11      ****
				"0000111100000000",  ----  11      ****
				"0011110000000000",  ----  22    ****
				"0011110000000000",  ----  22    ****
				"1111111111111111",  ----  33  ****************
				"1111111111111111",  ----  33  ****************
				"0000000011111100",  ----  44          ******  
				"0000000011111100",  ----  44          ******  
				"0000000011110000",  ----  55          ****
				"0000000011110000",  ----  55          ****
				"0000001111000000",  ----  66        ****  
				"0000001111000000",  ----  66        ****  
				"0000001100000000",  ----  77        **
				"0000001100000000",  ----  77        **


				"0000001100000000",  ----  00        **        
				"0000001100000000",  ----  00        **        
				"0000111100000000",  ----  11      ****
				"0000111100000000",  ----  11      ****
				"0011110000000000",  ----  22    ****
				"0011110000000000",  ----  22    ****
				"1111111111111111",  ----  33  ****************
				"1111111111111111",  ----  33  ****************
				"0000000011111100",  ----  44          ******  
				"0000000011111100",  ----  44          ******  
				"0000000011110000",  ----  55          ****
				"0000000011110000",  ----  55          ****
				"0000001111000000",  ----  66        ****  
				"0000001111000000",  ----  66        ****  
				"0000001100000000",  ----  77        **
				"0000001100000000",  ----  77        **


				"0000001100000000",  ----  00        **        
				"0000001100000000",  ----  00        **        
				"0000111100000000",  ----  11      ****
				"0000111100000000",  ----  11      ****
				"0011110000000000",  ----  22    ****
				"0011110000000000",  ----  22    ****
				"1111111111111111",  ----  33  ****************
				"1111111111111111",  ----  33  ****************
				"0000000011111100",  ----  44          ******  
				"0000000011111100",  ----  44          ******  
				"0000000011110000",  ----  55          ****
				"0000000011110000",  ----  55          ****
				"0000001111000000",  ----  66        ****  
				"0000001111000000",  ----  66        ****  
				"0000001100000000",   ----  77        **				
				"0000001100000000"   ----  77        **

   );
begin
   -- addr register to infer block RAM
   process(clk)
   begin
    if rising_edge(clk) then
        addr_reg <= addr;
    end if;    
   end process;
   data <= ROM(to_integer(unsigned(addr_reg)));

end RTL;