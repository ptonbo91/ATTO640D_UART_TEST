----------------------------------------------------------------
-- Copyright    : ALSE - http://alse-fr.com
-- Contact      : info@alse-fr.com
-- Block Name   : FIFO_GENERIC_SC
-- Description  : Universal Single Clock Fifo
-- Authors      : E. LAURENDEAU / G.JOLI
-- Version      : 2012.07
----------------------------------------------------------------
--
-- 2012.07      : Critical Fix for EMPTY / FULL Fifo RD/WR
--                Added ALLOW_RDWRFULL & ALLOW_RDWREMPTY generics
--                Fixed SHOWAHEAD for when reading while empty
--
-- 2012.01      : Alternative "Home" Implementation
--
-- 2011.12      : Original Release Based on OpenCore Code
--
----------------------------------------------------------------

Library IEEE;
    Use IEEE.std_logic_1164.all;
    Use IEEE.numeric_std.all;



-------------------------------
Entity FIFO_GENERIC_SC Is
-------------------------------
  Generic (
    FIFO_DEPTH      :     Positive :=  8;               -- 2**FIFO_DEPTH = Number of Words in FIFO
    FIFO_WIDTH      :     Positive := 36;               -- FIFO Words Number of Bits
    AEMPTY_LEVEL    :     Natural  :=  0;
    AFULL_LEVEL     :     Natural  :=  0;
    ALLOW_RDWRFULL  :     Boolean  := False;            -- True allows RDWR when FULL
    ALLOW_RDWREMPTY :     Boolean  := True;             -- True allows RDWR when EMPTY
    ALLOW_OVER      :     Boolean  := False;
    ALLOW_UNDER     :     Boolean  := False;
    RAM_STYLE       :     string   := "block";      -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
    SHOW_AHEAD      :     Boolean  := True;
    USE_EAB         :     Boolean  := True
  );
  Port (
    CLK             : In  Std_Logic;
    RST             : In  Std_Logic;
    CLR             : In  Std_Logic := '0';
    --
    WRREQ           : In  Std_Logic;
    WRDATA          : In  Std_Logic_Vector(FIFO_WIDTH-1 downto 0);
    --
    RDREQ           : In  Std_Logic;
    RDDATA          : Out Std_Logic_Vector(FIFO_WIDTH-1 downto 0);
    --
    EMPTY           : Out Std_Logic;
    FULL            : Out Std_Logic;
    USEDW           : Out Std_Logic_Vector(FIFO_DEPTH-1 downto 0);
    AFULL           : Out Std_Logic;  
    AEMPTY          : Out Std_Logic   
  );
-------------------------------
End Entity FIFO_GENERIC_SC;
-------------------------------


-------------------------------------------
Architecture RTL Of FIFO_GENERIC_SC Is
-------------------------------------------

  --
  Type FIFO_RAM_t     is array (0 to 2**FIFO_DEPTH-1) of Std_Logic_Vector(FIFO_WIDTH-1 downto 0);
  Signal FIFO_RAM     : FIFO_RAM_t;

  --
  Signal FIFO_WRREQ   : Std_Logic;
  Signal FIFO_WRADDR  : Unsigned(FIFO_DEPTH-1 downto 0);
  Signal FIFO_RDADDR  : Unsigned(FIFO_DEPTH-1 downto 0);
  Signal FIFO_RDREQ   : Std_Logic;
  Signal FIFO_EMPTY   : Std_Logic;
  Signal FIFO_FULL    : Std_Logic;
  Signal FIFO_CNT     : Unsigned(FIFO_DEPTH   downto 0);
  Signal FIFO_AEMPTY  : Std_Logic;
  Signal FIFO_AFULL   : Std_Logic;

---------
begin
---------

  -- -------------------------------
  --  Dual Port Ram - Single Clock
  -- -------------------------------

  -- Inference Mode, to use Memory Blocks
  RAM_MEMORY_BLOCKS : If (USE_EAB) Generate
    i_FIFO_RAM : Entity WORK.DPRAM_GENERIC_DC
      Generic Map (
        ADDR_WIDTH  => FIFO_DEPTH                     ,
        DATA_WIDTH  => FIFO_WIDTH                     ,
        RAM_STYLE   => RAM_STYLE                      ,
        SINGLE_CLK  => true                           ,
        BYPASS_RW   => false                          ,
        SIMPLE_DP   => true                           ,
        OUTPUT_REG  => false
      )
      Port Map (
        A_CLK       => CLK                            ,
        A_ADDR      => STD_LOGIC_VECTOR(FIFO_WRADDR)  ,
        A_WRREQ     => FIFO_WRREQ                     ,
        A_WRDATA    => WRDATA                         ,
        A_RDREQ     => '0'                            ,
        A_RDDATA    => open                           ,
        B_CLK       => CLK                            ,
        B_ADDR      => STD_LOGIC_VECTOR(FIFO_RDADDR)  ,
        B_WRREQ     => '0'                            ,
        B_WRDATA    => (others => '0')                ,
        B_RDREQ     => FIFO_RDREQ                     ,
        B_RDDATA    => RDDATA
      );
  End Generate RAM_MEMORY_BLOCKS;


  -- NON Inference Mode, to use Logic Cells
  RAM_REGISTERS : if (not USE_EAB) generate
    Process(CLK, RST)
    Begin
      If (RST = '1') Then
        RDDATA   <= (others => '0');
        FIFO_RAM <= (others => (others => '0'));
      Elsif rising_edge(CLK) Then
        If (FIFO_WRREQ = '1') Then
          FIFO_RAM(to_integer(FIFO_WRADDR)) <= WRDATA;
        End if;
        If (FIFO_RDREQ = '1') Then
          RDDATA <= FIFO_RAM(to_integer(FIFO_RDADDR));
        End If;
      End If;
    End Process;
  End Generate RAM_REGISTERS;



  ---------------------------------------------------
  -- Fifo Management Logic
  ---------------------------------------------------

  --
  Process(RST, CLK)
  Begin
    If (RST = '1') Then
      --
      FIFO_WRADDR <= (Others => '0');
      FIFO_RDADDR <= (Others => '0');
      --
      FIFO_EMPTY  <= '1';
      FIFO_FULL   <= '0';
      FIFO_CNT    <= (Others => '0');
      FIFO_AEMPTY <= '1';
      FIFO_AFULL  <= '0';

    ElsIf RISING_EDGE(CLK) Then

      -- FIFO_WRADDR Management
      If (FIFO_WRREQ = '1') And ((FIFO_FULL  = '0') Or (ALLOW_OVER = True) Or ((FIFO_RDREQ = '1') And (ALLOW_OVER = False) And (ALLOW_RDWRFULL = True))) Then
          FIFO_WRADDR <= FIFO_WRADDR + 1;
      End If;

      -- FIFO_RDADDR Management
      If (FIFO_RDREQ = '1') And ((FIFO_EMPTY = '0') Or (ALLOW_UNDER = True)) Then
          FIFO_RDADDR <= FIFO_RDADDR + 1;
      End If;

      -- FIFO_EMPTY Management when RD/WR
      If  (FIFO_WRREQ = '1') And (FIFO_RDREQ = '1') Then
        If (ALLOW_RDWREMPTY = True) Then
          FIFO_EMPTY <= '0';
        End If;
      End If;

      -- FIFO_FULL  & FIFO_CNT Management
      If  (FIFO_WRREQ = '1') And (FIFO_RDREQ = '0') Then
        --
        If (FIFO_FULL = '0') Then
          --
          FIFO_CNT    <= FIFO_CNT + 1;
          FIFO_EMPTY  <= '0';
          --
          If (FIFO_WRADDR + 1 = FIFO_RDADDR) Then
            FIFO_FULL   <= '1';
          End If;
        End If;
      End If;

      -- FIFO_EMPTY & FIFO_CNT Management
      If (FIFO_WRREQ = '0') And (FIFO_RDREQ = '1') Then
        --
        If (FIFO_EMPTY = '0') Then
          --
          FIFO_CNT    <= FIFO_CNT - 1;
          FIFO_FULL   <= '0';
          --
          If (FIFO_RDADDR + 1 = FIFO_WRADDR) Then
            FIFO_EMPTY  <= '1';
          End If;
        End If;
      End If;

      -- FIFO_AEMPTY Management
      If (FIFO_CNT <= AEMPTY_LEVEL) Then
        FIFO_AEMPTY <= '1';
      Else
        FIFO_AEMPTY <= FIFO_EMPTY;
      End If;

      -- FIFO_AFULL Management
      If (FIFO_CNT >= AFULL_LEVEL) Then
        FIFO_AFULL  <= '1';
      Else
        FIFO_AFULL  <= FIFO_FULL;
      End If;


      -- CLR Management
      If (CLR = '1') Then
        --
        FIFO_WRADDR <= (Others => '0');
        FIFO_RDADDR <= (Others => '0');
        --
        FIFO_EMPTY  <= '1';
        FIFO_FULL   <= '0';
        FIFO_CNT    <= (Others => '0');
        FIFO_AEMPTY <= '1';
        FIFO_AFULL  <= '0';
      End If;
    End If;
  End Process;
  ---------------------------------------------------


  --
  FIFO_WRREQ  <= WRREQ                              When (ALLOW_OVER = True) Else
                 WRREQ And (not FIFO_FULL or RDREQ) When (ALLOW_OVER = False) And (ALLOW_RDWRFULL = True) Else
                 WRREQ And (not FIFO_FULL)          When (ALLOW_OVER = False) And (ALLOW_RDWRFULL = False) Else
                 '0';


  -- ----------------------------------------------
  -- ----------------------------------------------
  --  SHOWAHEAD MODE or NOT
  -- ----------------------------------------------
  -- ----------------------------------------------

  --  SHOWAHEAD MODE ENABLED
  SHOWAHEAD_ON : If SHOW_AHEAD Generate
    Signal USEDWi : std_logic_vector(FIFO_DEPTH Downto 0);
  Begin

    --
    i_FIFO_SHOWAHEAD : Entity WORK.FIFO_SHOWAHEAD
      Port Map (
        CLOCK   => CLK                        ,
        RESET   => RST                        ,
        F_CLEAR => CLR                        ,
        F_EMPTY => FIFO_EMPTY                 ,
        F_USED  => STD_LOGIC_VECTOR(FIFO_CNT) ,
        F_RDEN  => FIFO_RDREQ                 ,
        EMPTY   => EMPTY                      ,
        USED    => USEDWi                     ,
        RDEN    => RDREQ
      );

    --
    USEDW      <= USEDWi(FIFO_DEPTH-1 downto 0);

    --
    Process(FIFO_FULL, RDREQ)
    Begin
      If (ALLOW_RDWRFULL = True) Then
        FULL <= FIFO_FULL And not RDREQ;
      Else
        FULL <= FIFO_FULL;
      End If;
    End Process;

    --
    Process(FIFO_EMPTY, USEDWi)
    Begin
      AEMPTY <= '0';
      If (FIFO_EMPTY = '1') or (UNSIGNED(USEDWi) <= AEMPTY_LEVEL) Then
        AEMPTY <= '1';
      End If;
    End Process;

    --
    Process(FIFO_FULL, USEDWi)
    Begin
      AFULL <= '0';
      If (FIFO_FULL = '1') or (UNSIGNED(USEDWi) >= AFULL_LEVEL) Then
        AFULL <= '1';
      End If;
    End Process;

  End Generate SHOWAHEAD_ON;

  --  SHOWAHEAD MODE DISABLED
  SHOWAHEAD_OFF : If not SHOW_AHEAD Generate
    --
    FIFO_RDREQ  <= RDREQ;
    EMPTY       <= FIFO_EMPTY;
    FULL        <= FIFO_FULL and not RDREQ            When (ALLOW_RDWRFULL = True) Else
                   FIFO_FULL;
    USEDW       <= STD_LOGIC_VECTOR(FIFO_CNT(FIFO_DEPTH-1 downto 0));
    AEMPTY      <= FIFO_AEMPTY;
    AFULL       <= FIFO_AFULL;
  End Generate SHOWAHEAD_OFF;


------------------------
End Architecture RTL;
------------------------

