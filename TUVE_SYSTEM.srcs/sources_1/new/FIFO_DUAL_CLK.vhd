----------------------------------------------------------------
-- Copyright    : Tonbo Imaging Pvt. Ltd.
-- Block Name   : FIFO_GENERIC_DC
-- Description  : Universal Dual Clock Fifo
-- Author       : ARDRA SINGH
-- Version      : 2016.1
----------------------------------------------------------------
--
-- 2016.1       : Original Release Based on ALSE's FIFO_GENERIC_SC
--
-- Take care    : If PIX_BITS is changed, you will need to modify the gray code conversion in 
--                this module according to the number of bits.
----------------------------------------------------------------

Library IEEE;
Use IEEE.std_logic_1164.all;
Use IEEE.numeric_std.all;

-------------------------------
Entity FIFO_DUAL_CLK Is
-------------------------------
  Generic (
    FIFO_DEPTH      : Positive := 11;               -- 2**FIFO_DEPTH = Number of Words in FIFO
    FIFO_WIDTH      : Positive := 14;               -- FIFO Words Number of Bits
    RAM_STYLE       : string   := "block"       -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
  );
  Port (
    CLK_WR          : In  Std_Logic;
    RST_WR          : In  Std_Logic;
    CLR_WR          : In  Std_Logic;
    WRREQ           : In  Std_Logic;
    WRDATA          : In  Std_Logic_Vector(FIFO_WIDTH-1 downto 0);
    --
    CLK_RD          : In  Std_Logic;
    RST_RD          : In  Std_Logic;
    CLR_RD          : In  Std_Logic;
    RDREQ           : In  Std_Logic;
    RDDATA          : Out Std_Logic_Vector(FIFO_WIDTH-1 downto 0);
    EMPTY_RD        : Out Std_Logic;
    FIFO_CNT_RD     : Out Std_Logic_Vector(FIFO_DEPTH-1 downto 0)
  );
-------------------------------
End Entity FIFO_DUAL_CLK;
-------------------------------


-------------------------------------------
Architecture RTL Of FIFO_DUAL_CLK Is
-------------------------------------------

  Signal FIFO_WRREQ             : Std_Logic;
  Signal FIFO_WRADDR            : Std_Logic_Vector(FIFO_DEPTH-1 downto 0);
  Signal FIFO_WRADDR_GRAY       : Std_Logic_Vector(FIFO_DEPTH-1 downto 0);
  Signal FIFO_WRADDR_ON_RD_GRAY : Std_Logic_Vector(FIFO_DEPTH-1 downto 0);
  Signal FIFO_WRADDR_ON_RD      : Std_Logic_Vector(FIFO_DEPTH-1 downto 0);
  Signal FIFO_RDADDR            : Std_Logic_Vector(FIFO_DEPTH-1 downto 0);
  Signal FIFO_CNT               : Unsigned(FIFO_DEPTH-1 downto 0);
  Signal FIFO_RDREQ             : Std_Logic;
  Signal FIFO_EMPTY             : Std_Logic;

---------
begin
---------

  -- -------------------------------
  --  Dual Port Ram - Dual Clock
  -- -------------------------------

    i_FIFO_RAM : Entity WORK.DPRAM_GENERIC_DC
      Generic Map (
        ADDR_WIDTH  => FIFO_DEPTH                     ,
        DATA_WIDTH  => FIFO_WIDTH                     ,
        RAM_STYLE   => RAM_STYLE                      ,
        SINGLE_CLK  => false                          ,
        BYPASS_RW   => false                          ,
        SIMPLE_DP   => true                           ,
        OUTPUT_REG  => false
      )
      Port Map (
        A_CLK       => CLK_WR                         ,
        A_ADDR      => FIFO_WRADDR                    ,
        A_WRREQ     => FIFO_WRREQ                     ,
        A_WRDATA    => WRDATA                         ,
        A_RDREQ     => '0'                            ,
        A_RDDATA    => open                           ,
        B_CLK       => CLK_RD                         ,
        B_ADDR      => FIFO_RDADDR                    ,
        B_WRREQ     => '0'                            ,
        B_WRDATA    => (others => '0')                ,
        B_RDREQ     => FIFO_RDREQ                     ,
        B_RDDATA    => RDDATA
      );

  ---------------------------------------------------
  -- Fifo Write Management Logic
  ---------------------------------------------------
  Process(RST_WR, CLK_WR)
  Begin
    If (RST_WR = '1') Then
      --
      FIFO_WRADDR <= (Others => '0');

    ElsIf RISING_EDGE(CLK_WR) Then

      -- FIFO_WRADDR Management
      If (FIFO_WRREQ = '1') Then
          FIFO_WRADDR <= Std_Logic_Vector(Unsigned(FIFO_WRADDR) + 1);
      End If;
    
      -- CLR Management
      If (CLR_WR = '1') Then
        --
        FIFO_WRADDR <= (Others => '0');
      End If;
    End If;
  End Process;  
  
  ---------------------------------------------------
  -- Binary to Gray Code Conversion
  ---------------------------------------------------
  --FIFO_WRADDR_GRAY(0)  <= FIFO_WRADDR(0) xor FIFO_WRADDR(1) ;
  --FIFO_WRADDR_GRAY(1)  <= FIFO_WRADDR(1) xor FIFO_WRADDR(2) ;
  --FIFO_WRADDR_GRAY(2)  <= FIFO_WRADDR(2) xor FIFO_WRADDR(3) ;
  --FIFO_WRADDR_GRAY(3)  <= FIFO_WRADDR(3) xor FIFO_WRADDR(4) ;
  --FIFO_WRADDR_GRAY(4)  <= FIFO_WRADDR(4) xor FIFO_WRADDR(5) ;
  --FIFO_WRADDR_GRAY(5)  <= FIFO_WRADDR(5) xor FIFO_WRADDR(6) ;
  --FIFO_WRADDR_GRAY(6)  <= FIFO_WRADDR(6) xor FIFO_WRADDR(7) ;
  --FIFO_WRADDR_GRAY(7)  <= FIFO_WRADDR(7) xor FIFO_WRADDR(8) ;
  --FIFO_WRADDR_GRAY(8)  <= FIFO_WRADDR(8) xor FIFO_WRADDR(9) ;
  --FIFO_WRADDR_GRAY(9)  <= FIFO_WRADDR(9); --xor FIFO_WRADDR(10);
  --FIFO_WRADDR_GRAY(10) <= FIFO_WRADDR(10)                   ;
  gen_xor1:
  for i in 0 to FIFO_DEPTH-2 generate
    FIFO_WRADDR_GRAY(i) <= FIFO_WRADDR(i) xor FIFO_WRADDR(i+1);
  end generate gen_xor1;
  FIFO_WRADDR_GRAY(FIFO_DEPTH-1)<= FIFO_WRADDR(FIFO_DEPTH-1);

  ---------------------------------------------------
  -- Gray Code to Binary Conversion
  ---------------------------------------------------
  ----FIFO_WRADDR_ON_RD(10) <= FIFO_WRADDR_ON_RD_GRAY(10)                          ;
  --FIFO_WRADDR_ON_RD(9)  <= FIFO_WRADDR_ON_RD_GRAY(9); --xor FIFO_WRADDR_ON_RD(10) ;
  --FIFO_WRADDR_ON_RD(8)  <= FIFO_WRADDR_ON_RD_GRAY(8) xor FIFO_WRADDR_ON_RD(9)  ;
  --FIFO_WRADDR_ON_RD(7)  <= FIFO_WRADDR_ON_RD_GRAY(7) xor FIFO_WRADDR_ON_RD(8)  ;
  --FIFO_WRADDR_ON_RD(6)  <= FIFO_WRADDR_ON_RD_GRAY(6) xor FIFO_WRADDR_ON_RD(7)  ;
  --FIFO_WRADDR_ON_RD(5)  <= FIFO_WRADDR_ON_RD_GRAY(5) xor FIFO_WRADDR_ON_RD(6)  ;
  --FIFO_WRADDR_ON_RD(4)  <= FIFO_WRADDR_ON_RD_GRAY(4) xor FIFO_WRADDR_ON_RD(5)  ;
  --FIFO_WRADDR_ON_RD(3)  <= FIFO_WRADDR_ON_RD_GRAY(3) xor FIFO_WRADDR_ON_RD(4)  ;
  --FIFO_WRADDR_ON_RD(2)  <= FIFO_WRADDR_ON_RD_GRAY(2) xor FIFO_WRADDR_ON_RD(3)  ;
  --FIFO_WRADDR_ON_RD(1)  <= FIFO_WRADDR_ON_RD_GRAY(1) xor FIFO_WRADDR_ON_RD(2)  ;
  --FIFO_WRADDR_ON_RD(0)  <= FIFO_WRADDR_ON_RD_GRAY(0) xor FIFO_WRADDR_ON_RD(1)  ;
  
  gen_xor2:
  for j in 0 to FIFO_DEPTH-2 generate
    FIFO_WRADDR_ON_RD(j) <= FIFO_WRADDR_ON_RD_GRAY(j) xor FIFO_WRADDR_ON_RD(j+1) ;
  end generate gen_xor2;
  FIFO_WRADDR_ON_RD(FIFO_DEPTH-1)<=FIFO_WRADDR_ON_RD_GRAY(FIFO_DEPTH-1);
  
  ---------------------------------------------------
  -- Fifo Read Management Logic
  ---------------------------------------------------
  Process(RST_RD, CLK_RD)
  Begin
    If (RST_RD = '1') Then
      --
      FIFO_RDADDR <= (Others => '0');
    ElsIf RISING_EDGE(CLK_RD) Then

      -- FIFO_RDADDR Management
      If (FIFO_RDREQ = '1') And (FIFO_EMPTY = '0') Then
          FIFO_RDADDR <= Std_Logic_Vector(Unsigned(FIFO_RDADDR) + 1);
      End If;

      -- CLR Management
      If (CLR_RD = '1') Then
        --
        FIFO_RDADDR <= (Others => '0');
      End If;

    End If;
  End Process;

  -- FIFO_EMPTY and FIFO_CNT Management
  FIFO_EMPTY <= '1' when (FIFO_RDADDR = FIFO_WRADDR_ON_RD) else
                '0';
  FIFO_CNT   <= Unsigned(FIFO_WRADDR_ON_RD) - Unsigned(FIFO_RDADDR);             
           
---------------------------------------------------

  FIFO_WRREQ  <= WRREQ;
  FIFO_RDREQ  <= RDREQ And (not FIFO_EMPTY);
  EMPTY_RD    <= FIFO_EMPTY;
  FIFO_CNT_RD <= Std_Logic_Vector(FIFO_CNT);
  
  -- ------------------------
  --  META_HARDEN INSTANTIATIONS
  -- ------------------------
   
  i_META_HARDEN_WRADDR : entity WORK.META_HARDEN_VECTOR
   Generic map (
    bit_width  => FIFO_DEPTH
   )
    Port map (
    CLK_DST    => CLK_RD                 ,
    RST_DST    => RST_RD                 ,
    SIGNAL_SRC => FIFO_WRADDR_GRAY       ,
    SIGNAL_DST => FIFO_WRADDR_ON_RD_GRAY  
    );

------------------------
End Architecture RTL;
------------------------

