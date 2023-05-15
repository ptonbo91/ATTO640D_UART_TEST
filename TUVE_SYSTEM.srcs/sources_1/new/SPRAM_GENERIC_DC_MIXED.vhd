-- THIS CODE IS CONFIDENTIAL AND CANNOT BE DISTRIBUTED
----------------------------------------------------------------
-- Copyright     : TONBO - http://tonboimaging.com
-- Contact       : info@tonboimaging.com
-- Module        : SPRAM_GENERIC_DC_MIXED
-- Description   : Universal Pseudo Dual Mixed Width Port RAM 
----------------------------------------------------------------
-- Author        : Aneesh M U
-- Date          : Jul 2016
-- Version       : 2016.07
---------------------------------------------------
--
-- 2016.07       : This is Simple Mixed Width Port RAM. Be careful with
--                 with the ratio of the Port widths.
--                 This code works with higher WR Data Port width and 
--                 and Samller RD Data Port width.      
--                 Supported Widths
--                 are a power of 2 and correspondigly the address bits  
--                 should be present. For eg. if the RD Data width is 16
--                 bits and WR Data Width is 64 bits, then the ratio of 
--                 address bits should be accordingly defined. i.e. if 
--                 WR Address is 8 bits then the RD Address is 10 bits.

--                 The module is not guranteed to work with non-power of 2
--                 Data widths and incorrect RD and WR address bits. Use
--                 Carefully. The following has been tested with Altera 
--                 Cyclone V device.  

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-------------------------------
entity SPRAM_GENERIC_DC_MIXED is
-------------------------------
  Generic (
    RD_ADDR_WIDTH  :     Positive :=  10;          -- RAM Read Address Width
    WR_ADDR_WIDTH  :     Positive :=  8;           -- RAM Write Address Width
    RD_DATA_WIDTH  :     Positive := 16;           -- RAM Read Data Width
    WR_DATA_WIDTH  :     Positive := 64;           -- RAM Write Data Width
    RAM_STYLE      :     String   := "block";           -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
    OUTPUT_REG     :     Boolean  := false            -- Output Registered if True
  );
  Port (
    CLK          : In  Std_Logic:='0';
    WR_ADDR      : In  Std_Logic_Vector(WR_ADDR_WIDTH-1   downto 0):= (Others => '0');
    WR_WRREQ     : In  Std_Logic:='0';
    WR_WRDATA    : In  Std_Logic_Vector(WR_DATA_WIDTH-1   downto 0):= (Others => '0');
    RD_ADDR      : In  Std_Logic_Vector(RD_ADDR_WIDTH-1   downto 0):= (Others => '0');
    RD_RDREQ     : In  Std_Logic:='1';                                                    -- By 
    RD_RDDATA    : Out Std_Logic_Vector(RD_DATA_WIDTH-1   downto 0)
  );
-------------------------------
end entity SPRAM_GENERIC_DC_MIXED;
-------------------------------


-------------------------------------------
architecture RTL of SPRAM_GENERIC_DC_MIXED is
-------------------------------------------

  -- mem is the signal that defines the RAM

  type MEM_t is array (0 to 2**WR_ADDR_WIDTH-1) of std_logic_vector(WR_DATA_WIDTH-1 downto 0);
  shared variable MEM     : MEM_t;

  attribute syn_ramstyle  : string; -- Synplify
  attribute syn_ramstyle  of MEM : variable is RAM_STYLE;

  signal RD_RDDOUT         : std_logic_vector(WR_WRDATA'range);
  signal k                 : integer:=0;

---------
begin
---------


------------------------------------------
-- Simple Pseudo-DUAL PORT
------------------------------------------

  -- -------------------------------
  --  PORT A Management
  -- -------------------------------

  -- Inference Mode, to use Memory Blocks
  process(CLK)
  begin
    if rising_edge(CLK) then
      if (WR_WRREQ = '1') then
        MEM(to_integer(unsigned(WR_ADDR))) := WR_WRDATA;
      end if;
    end if;
  end process;


  -- -------------------------------
  --  PORT B Management
  -- -------------------------------

  -- Inference Mode, to use Memory Blocks
  process(CLK)
  begin
    if rising_edge(CLK) then
      if (RD_RDREQ = '1') then
        RD_RDDOUT <= MEM(to_integer(unsigned(RD_ADDR(RD_ADDR_WIDTH-1 downto RD_ADDR_WIDTH-WR_ADDR_WIDTH)))); -- Use only higher bits of RD Address
        k<=to_integer(unsigned(RD_ADDR(RD_ADDR_WIDTH-WR_ADDR_WIDTH-1 downto 0)))*RD_DATA_WIDTH;              -- Remmber the lower bits of Address
      end if;
    end if;
  end process;


  -- -------------------------------
  --  OUTPUT REGISTERED
  -- -------------------------------
  OUTPUT_REGISTERED : if OUTPUT_REG generate
    process(CLK)
    begin

      if rising_edge(CLK) then
        RD_RDDATA <= RD_RDDOUT(k+RD_DATA_WIDTH-1 downto k); -- Select the Word to send to the RD port
      end if;
    end process;
  end generate OUTPUT_REGISTERED;



  -- -------------------------------
  --  OUTPUT NOT REGISTERED
  -- -------------------------------
  OUTPUT_COMB : if not OUTPUT_REG generate
    RD_RDDATA <= RD_RDDOUT(k+RD_DATA_WIDTH-1 downto k);  -- Select the Word to send to the RD port
  end generate OUTPUT_COMB;


------------------------
end architecture RTL;
------------------------

