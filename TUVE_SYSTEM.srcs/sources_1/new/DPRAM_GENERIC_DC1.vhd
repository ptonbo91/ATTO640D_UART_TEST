-- THIS CODE IS CONFIDENTIAL AND CANNOT BE DISTRIBUTED
----------------------------------------------------------------
-- Copyright     : ALSE - http://alse-fr.com
-- Contact       : info@alse-fr.com
-- Module        : DPRAM_GENERIC_SC
-- Description   : Universal True Dual Port RAM Dual Clock
----------------------------------------------------------------
-- Author        : E. LAURENDEAU
-- Date          : Feb 2012
-- Version       : 2012.02
---------------------------------------------------
--
-- 2012.02  : Updated with SIMPLE_DP Generic in order to have only a read & a write port
--            Added Generates in order to make the ram extracted by synplify for Lattice devices
--
-- 2011.12  : Initial Revision
--


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-------------------------------
entity DPRAM_GENERIC_DC1 is
-------------------------------
  Generic (
    ADDR_WIDTH      :     Positive := 12;           -- RAM Address Width
    DATA_WIDTH      :     Positive := 12;           -- RAM Data Width
    RAM_STYLE_PARAM :     String   := "block";  -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
    BYPASS_RW       :     Boolean  := true;        -- Returned Write Data when Read and Write at same address
    SIMPLE_DP       :     Boolean  := true;        -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
    SINGLE_CLK      :     Boolean  := true;        -- Advertise that A_CLK = B_CLK
    OUTPUT_REG      :     Boolean  := false         -- Output Registered if True
  );
  Port (
    A_CLK       : In  Std_Logic:='0';
    A_ADDR      : In  Std_Logic_Vector(ADDR_WIDTH-1   downto 0):= (Others => '0');
    A_WRREQ     : In  Std_Logic:='0';
    A_WRDATA    : In  Std_Logic_Vector(DATA_WIDTH-1   downto 0):= (Others => '0');
    A_RDREQ     : In  Std_Logic:='1';
    A_RDDATA    : Out Std_Logic_Vector(DATA_WIDTH-1   downto 0);
    B_CLK       : In  Std_Logic:='0';
    B_ADDR      : In  Std_Logic_Vector(ADDR_WIDTH-1   downto 0):= (Others => '0');
    B_WRREQ     : In  Std_Logic:='0';
    B_WRDATA    : In  Std_Logic_Vector(DATA_WIDTH-1   downto 0):= (Others => '0');
    B_RDREQ     : In  Std_Logic:='1';
    B_RDDATA    : Out Std_Logic_Vector(DATA_WIDTH-1   downto 0)
  );
-------------------------------
begin
  assert ((SIMPLE_DP and not BYPASS_RW) or (not SIMPLE_DP) or (SINGLE_CLK)) report "DPRAM_GENERIC_DC1 : BYPASS_RW must be FALSE when SIMPLE_DP is TRUE if A_CLK /= B_CLK" severity error;
end entity DPRAM_GENERIC_DC1;
-------------------------------


-------------------------------------------
architecture RTL of DPRAM_GENERIC_DC1 is
-------------------------------------------

  -- mem is the signal that defines the RAM
  type MEM_t is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal MEM     : MEM_t := (others => (others => '0'));


  attribute ram_style  : string; -- Synplify                               -- syn_ramstyle
  attribute ram_style  of MEM : signal is RAM_STYLE_PARAM;


  signal A_RDDOUT         : std_logic_vector(A_RDDATA'range);
  signal B_RDDOUT         : std_logic_vector(B_RDDATA'range);

---------
begin
---------


------------------------------------------
-- Simple DUAL PORT
------------------------------------------
gSIMPLE_DP : If (SIMPLE_DP = True) Generate

  -- -------------------------------
  --  PORT A Management
  -- -------------------------------

  -- Inference Mode, to use Memory Blocks
  process(A_CLK)
  begin
    if rising_edge(A_CLK) then
      if (A_WRREQ = '1') then
        MEM(to_integer(unsigned(A_ADDR))) <= A_WRDATA;
      end if;
      A_RDDOUT <= (Others => '0');
    end if;
  end process;


  -- -------------------------------
  --  PORT B Management
  -- -------------------------------

  -- Inference Mode, to use Memory Blocks
  process(B_CLK)
  begin
    if rising_edge(B_CLK) then
      if (B_RDREQ = '1') then
        --if (BYPASS_RW and (A_WRREQ = '1') and (A_ADDR = B_ADDR)) then
        -- B_RDDOUT <= A_WRDATA;
        --else
          B_RDDOUT <= MEM(to_integer(unsigned(B_ADDR)));
        -- end if;
      end if;
    end if;
  end process;

End Generate;




------------------------------------------
-- True DUAL PORT
------------------------------------------
gTRUE_DP : If (SIMPLE_DP = False) Generate

  -- -------------------------------
  --  PORT A Management
  -- -------------------------------

  -- Inference Mode, to use Memory Blocks
  process(A_CLK)
  begin
    if rising_edge(A_CLK) then
      if (A_WRREQ = '1') then
        MEM(to_integer(unsigned(A_ADDR))) <= A_WRDATA;
      end if;
      if (A_RDREQ = '1') then
        if (BYPASS_RW and A_WRREQ = '1') then
          A_RDDOUT <= A_WRDATA;
        else
          A_RDDOUT <= MEM(to_integer(unsigned(A_ADDR)));
        end if;
      end if;
    end if;
  end process;


  -- -------------------------------
  --  PORT B Management
  -- -------------------------------

  -- Inference Mode, to use Memory Blocks
  process(B_CLK)
  begin
    if rising_edge(B_CLK) then
      if (B_WRREQ = '1') then
        MEM(to_integer(unsigned(B_ADDR))) <= B_WRDATA;
      end if;
      if (B_RDREQ = '1') then
        if (BYPASS_RW and B_WRREQ = '1') then
          B_RDDOUT <= B_WRDATA;
        else
          B_RDDOUT <= MEM(to_integer(unsigned(B_ADDR)));
        end if;
      end if;
    end if;
  end process;

End Generate;




-------------------------------------------------------------------------



  -- -------------------------------
  --  OUTPUT REGISTERED
  -- -------------------------------
  OUTPUT_REGISTERED : if OUTPUT_REG generate
    process(A_CLK)
    begin
      if rising_edge(A_CLK) then
        A_RDDATA <= A_RDDOUT;
      end if;
    end process;
    process(B_CLK)
    begin
      if rising_edge(B_CLK) then
        B_RDDATA <= B_RDDOUT;
      end if;
    end process;
  end generate OUTPUT_REGISTERED;



  -- -------------------------------
  --  OUTPUT NOT REGISTERED
  -- -------------------------------
  OUTPUT_COMB : if not OUTPUT_REG generate
    A_RDDATA <= A_RDDOUT;
    B_RDDATA <= B_RDDOUT;
  end generate OUTPUT_COMB;


------------------------
end architecture RTL;
------------------------

