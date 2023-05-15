------------------------------------------------------------------------------
-- Copyright        : ALSE - http://alse-fr.com
-- Contact          : info@alse-fr.com
-- Project Name     : Tonboimaging - Thermal Camera Project
-- Block Name       : DMA_WRITE_BT656
-- Description      : DMA Write Master to Memory Controller
-- Author           : E.LAURENDEAU
-- Date of creation : 16/12/2013
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Design Notes : Master Write Interface with SRAM
--  16 Bits words are written in SRAM, so input data on 8bits are doubled
--  Each frame is written in a SRAM Buffer (number given by MEM_IMG_BUF)
--  Supported Resolutions :
--  -> QVGA : 384*288 = 110592 pixels 
--  ->  VGA : 640*480 = 307200 pixels
--  Beware to choose correct ADDR_BUFx values depending the image size
--  ADDR_BUFx generic values are set in THERMAL_CAM_PACK.vhd file
------------------------------------------------------------------------------


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

----------------------------------
entity DMA_WRITE_BT656 is
----------------------------------
  generic (
    ADDR_BUF0 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 0
    ADDR_BUF1 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 1
    ADDR_BUF2 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 2
    DMA_SIZE_BITS: positive:= 5;
    WR_SIZE   : positive range 1 to 16 := 4  -- Write Burst Size for Memory Write Requests    
  );
  port (
    CLK            : in  std_logic;                      -- Module Clock
    RST            : in  std_logic;                      -- Module Reset (async active high) 
    IMG_FLIP_V      : in  std_logic;                      -- IMAGE FLIP VERTICALLY
    IMG_FLIP_H      : in  std_logic;                      -- IMAGE FLIP HORIZONTALLY   
    IMG_SHIFT_VERT  : in std_logic_vector(9 downto 0); 
    -- Source Input Flux (sync'ed on CLK)               
    SRC_V          : in  std_logic;                      -- Source New Frame
    SRC_H          : in  std_logic;                      -- Source New Line
    SRC_EOI        : in  std_logic;                      -- Source End of Image
    SRC_DAV        : in  std_logic;                      -- Source Data Valid
    SRC_DATA       : in  std_logic_vector( 7 downto 0);  -- Source Data
    SRC_XSIZE      : in  std_logic_vector( 9 downto 0);  -- Source X Size (max 1023)
    SRC_YSIZE      : in  std_logic_vector( 9 downto 0);  -- Source Y Size (max 1023)
    -- Memory Image Info                                
    MEM_IMG_SOI    : out std_logic;                      -- Memory Image Picture Start
    MEM_IMG_BUF    : out std_logic_vector( 1 downto 0);  -- Memory Image Picture Buffer
    MEM_IMG_XSIZE  : out std_logic_vector( 9 downto 0);  -- Memory Image Picture X Size (max 1023)
    MEM_IMG_YSIZE  : out std_logic_vector( 9 downto 0);  -- Memory Image Picture Y Size (max 1023)
    -- Avalon DMA Master interface to Memory Controller 
    DMA_WRREADY    : in  std_logic;                      -- DMA Write Ready
    DMA_WRREQ      : out std_logic;                      -- DMA Write Request
    DMA_WRBURST    : out std_logic;                      -- DMA Write Request
    DMA_WRSIZE     : out std_logic_vector(DMA_SIZE_BITS-1 downto 0);  -- DMA Write Request Size
    DMA_WRADDR     : out std_logic_vector(31 downto 0);  -- DMA Write Address
    DMA_WRDATA     : out std_logic_vector(31 downto 0);  -- DMA Write Data
--    DMA_ADDR_DEC   : out std_logic;                      -- DMA ADDRESS DECREMENT
    DMA_WRBE       : out std_logic_vector( 3 downto 0);   -- DMA Write Data Byte enable
    DMA_WRITE_FREE : out std_logic                        
  );
----------------------------------
end entity DMA_WRITE_BT656;
----------------------------------


---------------------------------------
architecture RTL of DMA_WRITE_BT656 is
---------------------------------------
COMPONENT TOII_TUVE_ila

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

signal probe_dma_bt656 : std_logic_vector(127 downto 0);



--signal DMA_WRADDR_temp     : std_logic_vector(31 downto 0);
--signal DMA_ADDR_PICT_temp : std_logic_vector(31 downto 0);
--signal DMA_ADDR_BASE_temp :  std_logic_vector(31 downto 0);
----signal frame_cnt : unsigned(15 downto 0);
--signal DMA_WRFSM_Temp : std_logic_vector(2 downto 0);


  constant FIFO_DEPTH : positive := 9 ;  -- 2**FIFO_DEPTH words in the FIFO
  constant FIFO_WSIZE : positive := 32;  -- FIFO word bits
  signal FIFO_SEL     : std_logic_vector(1 downto 0);
  signal FIFO_EN      : std_logic;
  signal FIFO_CLR     : std_logic;
  signal FIFO_WR      : std_logic;
  signal FIFO_IN      : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_FUL     : std_logic;
  signal FIFO_NB      : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal FIFO_EMP     : std_logic;
  signal FIFO_RD      : std_logic;
  signal FIFO_OUT     : std_logic_vector(FIFO_WSIZE-1 downto 0);

  type DMA_WRFSM_t is ( s_Reset,s_WAIT_H,s_WRITE1, s_WRITE2, s_WAIT );
  signal DMA_WRFSM     : DMA_WRFSM_t;
  signal DMA_CNT       : unsigned(DMA_WRSIZE'range);
  signal DMA_ADDR_PICT : unsigned(DMA_WRADDR'range);
  signal DMA_ADDR_IMG  : unsigned(MEM_IMG_BUF'range);
  signal DMA_ADDR_BASE : unsigned(DMA_WRADDR'range);

  signal MEM_IMG_SOIi : std_logic;
  signal LIN_NO :  unsigned(SRC_YSIZE'range);
--  signal LIN_CNT :  unsigned(SRC_YSIZE'range);
  signal DMA_ADDR_PIX : unsigned(SRC_XSIZE'range);

  signal LATCH_IMG_FLIP_V : std_logic;
  signal LATCH_IMG_FLIP_H : std_logic;

  constant RAM_ADDR_WIDTH: positive := 11;
  constant RAM_DATA_WIDTH: positive := SRC_DATA'length;

  signal RAM_WRREQ : std_logic;
  signal RAM_RDREQ : std_logic;
  signal RAM_DAV : std_logic;
  signal RAM_RDADDR: std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
  signal RAM_WRADDR: std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
  signal RAM_RDDATA: std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
  signal RAM_WRDATA: std_logic_vector(RAM_DATA_WIDTH-1 downto 0);

  signal BUF_SELECT: std_logic;
  signal START_READ_RAM: std_logic;
  signal READ_BUF_SELECT: std_logic;
  --signal HFLIP_EN_REG: std_logic;

  type READ_RAM_FSM_t is (RAM_IDLE, RAM_READ);
  signal READ_RAM_FSM: READ_RAM_FSM_t;

  signal WAIT_CNT: unsigned(15 downto 0);
  signal LATCH_IMG_SHIFT_VERT : unsigned(9 downto 0);

--attribute mark_debug : string;
----attribute mark_debug of DMA_WRADDR_temp: signal is "TRUE";
----attribute mark_debug of DMA_ADDR_PICT_temp: signal is "TRUE";
----attribute mark_debug of DMA_ADDR_BASE_temp: signal is "TRUE";
------attribute mark_debug of frame_cnt: signal is "TRUE";
--attribute mark_debug of DMA_WRFSM   : signal is "TRUE";
----attribute mark_debug of LATCH_IMG_FLIP_H : signal is "TRUE";
----attribute mark_debug of LATCH_IMG_FLIP_V : signal is "TRUE";
----attribute mark_debug of IMG_FLIP_H : signal is "TRUE";
----attribute mark_debug of IMG_FLIP_V : signal is "TRUE";
----attribute mark_debug of LIN_NO : signal is "TRUE";
----attribute mark_debug of LIN_CNT : signal is "TRUE";
--attribute mark_debug of DMA_ADDR_PIX : signal is "TRUE";
--attribute mark_debug of LIN_NO : signal is "TRUE";
--attribute mark_debug of DMA_CNT : signal is "TRUE";
--attribute mark_debug of FIFO_SEL  : signal is "TRUE"; 
--attribute mark_debug of FIFO_EN   : signal is "TRUE"; 
--attribute mark_debug of FIFO_CLR  : signal is "TRUE"; 
--attribute mark_debug of FIFO_WR   : signal is "TRUE"; 
--attribute mark_debug of FIFO_IN   : signal is "TRUE"; 
--attribute mark_debug of FIFO_FUL  : signal is "TRUE"; 
--attribute mark_debug of FIFO_NB   : signal is "TRUE"; 
--attribute mark_debug of FIFO_EMP  : signal is "TRUE"; 
--attribute mark_debug of FIFO_RD   : signal is "TRUE"; 
--attribute mark_debug of FIFO_OUT  : signal is "TRUE"; 
--attribute mark_debug of SRC_V     : signal is "TRUE";   
--attribute mark_debug of SRC_H     : signal is "TRUE";   
--attribute mark_debug of SRC_EOI   : signal is "TRUE";   
--attribute mark_debug of SRC_DAV   : signal is "TRUE";   

--------
begin
--------

 process(CLK, RST)
  begin
    if(RST='1') then
      RAM_WRREQ <= '0';
      RAM_RDREQ <= '0';
      RAM_WRADDR <= (others=>'0');
      RAM_RDADDR <= (others=>'0');
      RAM_WRDATA <= (others=>'0');
      LATCH_IMG_FLIP_H <= '0';
      FIFO_EN  <= '0';
      FIFO_SEL <= "00";
      FIFO_WR  <= '0';
      FIFO_IN  <= (others => '0');
      BUF_SELECT <= '0';
      READ_BUF_SELECT <= '1';
      START_READ_RAM <= '0';
    elsif (rising_edge(CLK)) then
      FIFO_WR <= '0';
      RAM_WRREQ <= '0';
      --RAM_RDREQ <= '0';
      START_READ_RAM <= '0';
      RAM_DAV <= RAM_RDREQ;
      if(SRC_V='1') then
        FIFO_SEL <= "00";
        FIFO_EN <= '1';
        FIFO_IN  <= (others => '0');
        LATCH_IMG_FLIP_H <= IMG_FLIP_H;
        BUF_SELECT  <= '0';
        READ_BUF_SELECT <= '1';

        if(IMG_FLIP_H='1') then
          RAM_WRADDR <= '0' & std_logic_vector(unsigned(SRC_XSIZE)-1);
        else
          RAM_WRADDR <= '0' & std_logic_vector(to_unsigned(0, RAM_WRADDR'length -1));
        end if;
      end if;
      if(LATCH_IMG_FLIP_H='1') then
        --if(SRC_H='1') then
        --  RAM_WRADDR <= BUF_SELECT & std_logic_vector(unsigned(SRC_XSIZE)-1);
        --  BUF_SELECT <= not BUF_SELECT;
        --end if;
        if(SRC_DAV='1') then
          RAM_WRDATA <= SRC_DATA;
          RAM_WRREQ <= '1';
        end if;
        if(RAM_WRREQ='1') then
          RAM_WRADDR <= std_logic_vector(unsigned(RAM_WRADDR) -1);
        end if;
        if(RAM_WRADDR(RAM_WRADDR'length-2 downto 0)=std_logic_vector(to_unsigned(0, RAM_WRADDR'length-1)) and RAM_WRREQ='1') then
            START_READ_RAM <= '1';
            READ_BUF_SELECT <= not READ_BUF_SELECT;
            BUF_SELECT <= not BUF_SELECT;
        end if;
        if(START_READ_RAM='1') then
            RAM_WRADDR <= BUF_SELECT & std_logic_vector(unsigned(SRC_XSIZE)-1);
        end if;
      else 
        --if(SRC_H='1') then
        --  RAM_WRADDR <= BUF_SELECT & std_logic_vector(to_unsigned(0, RAM_WRADDR'length -1));
        --  BUF_SELECT <= not BUF_SELECT;
        --end if;
        if(SRC_DAV='1') then
          RAM_WRDATA <= SRC_DATA;
          RAM_WRREQ <= '1';
        end if;
        if(RAM_WRREQ='1') then
          RAM_WRADDR <= std_logic_vector(unsigned(RAM_WRADDR) + 1);
        end if;
        if(RAM_WRADDR(RAM_WRADDR'length-2 downto 0)=std_logic_vector(unsigned(SRC_XSIZE)-1) and RAM_WRREQ='1') then
            START_READ_RAM <= '1';
            READ_BUF_SELECT <= not READ_BUF_SELECT;
            BUF_SELECT <= not BUF_SELECT;
        end if;
        if(START_READ_RAM='1') then
            RAM_WRADDR <= BUF_SELECT & std_logic_vector(to_unsigned(0, RAM_WRADDR'length -1));
        end if;
      end if;

      case READ_RAM_FSM is
        when RAM_IDLE =>
          RAM_RDREQ <= '0';
          if(START_READ_RAM='1') then
            READ_RAM_FSM <= RAM_READ;
            RAM_RDADDR <= READ_BUF_SELECT & std_logic_vector(to_unsigned(0, RAM_RDADDR'length-1));
            RAM_RDREQ <= '1';
          end if;

        when RAM_READ =>
          RAM_RDADDR <= std_logic_vector(unsigned(RAM_RDADDR) + 1);
          RAM_RDREQ <= '1';
          if(RAM_RDADDR(RAM_RDADDR'length-2 downto 0)=std_logic_vector(unsigned(SRC_XSIZE)-1) and RAM_RDREQ='1') then
            READ_RAM_FSM <= RAM_IDLE;
            RAM_RDREQ <= '0';
          end if;
            
      end case;

      if(RAM_DAV='1') then
        if FIFO_SEL = "00" then
          FIFO_SEL <= "01";
          FIFO_IN(7 downto 00) <= RAM_RDDATA;
        elsif FIFO_SEL = "01" then
          FIFO_SEL <= "10";
          FIFO_IN(15 downto 8) <= RAM_RDDATA;
        elsif FIFO_SEL = "10" then
          FIFO_SEL <= "11";
          FIFO_IN(23 downto 16) <= RAM_RDDATA;
        else
          FIFO_WR <= FIFO_EN;
          FIFO_SEL <= "00";
          FIFO_IN(31 downto 24) <= RAM_RDDATA;
        end if;
      end if;
    end if;
  end process;



  MATRIX_DBLINE : entity WORK.DPRAM_GENERIC_DC
    generic map (
      ADDR_WIDTH => RAM_ADDR_WIDTH,  -- RAM Address Width
      DATA_WIDTH => RAM_DATA_WIDTH,  -- RAM Data Width
      BYPASS_RW   =>     false,        -- Returned Write Data when Read and Write at same address
      SIMPLE_DP   =>     false,        -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
      SINGLE_CLK  =>     true,         -- Advertise that A_CLK = B_CLK
      OUTPUT_REG  =>     false         -- Output Registered if True
    )
    port map (
      -- Port A - Write Only
      A_CLK    => CLK            ,
      A_WRREQ  => RAM_WRREQ     ,
      A_ADDR   => RAM_WRADDR    ,
      A_WRDATA => RAM_WRDATA    ,
      A_RDDATA => open           ,
      -- Port B - Read Only
      B_CLK    => CLK            ,
      B_WRREQ  => '0'            ,  -- Read Only
      B_WRDATA => (others => '0'),
      B_RDREQ  => RAM_RDREQ     ,
      B_ADDR   => RAM_RDADDR    ,
      B_RDDATA => RAM_RDDATA
    );        

       
  -- FIFO to store data 
  i_DMA_WRFIFO : entity WORK.FIFO_GENERIC_SC
    generic map (
      FIFO_DEPTH => FIFO_DEPTH,
      FIFO_WIDTH => FIFO_WSIZE,
      SHOW_AHEAD => true      ,
      USE_EAB    => true
    )
    port map (
      CLK    => CLK     ,
      RST    => RST     ,
      CLR    => FIFO_CLR,
      WRREQ  => FIFO_WR ,
      WRDATA => FIFO_IN ,
      FULL   => FIFO_FUL,
      USEDW  => FIFO_NB ,
      EMPTY  => FIFO_EMP,
      RDREQ  => FIFO_RD ,
      RDDATA => FIFO_OUT
    ); 
      
  -- Clear the Fifo
  FIFO_CLR <= SRC_V;
    
  assert not ( FIFO_FUL = '1' and FIFO_WR = '1' )
    report "[DMA_WRITE_BT656] WRITE while FIFO Full !!!" severity failure;

  FIFO_RD <= not FIFO_EMP and DMA_WRREADY when DMA_WRFSM = s_WRITE2 else '0';

  -- ---------------------------------
  --  DMA Master Write Process
  -- ---------------------------------
  process(CLK, RST)
  begin
    if RST = '1' then
      MEM_IMG_SOIi  <= '0';
      DMA_CNT       <= to_unsigned(WR_SIZE, DMA_CNT'length);
      DMA_ADDR_IMG  <= to_unsigned(2, DMA_ADDR_IMG'length);
      DMA_ADDR_PICT <= (others => '0');
      DMA_ADDR_BASE <= (others => '0');
      DMA_WRREQ     <= '0';
      DMA_WRBURST   <= '0';
      DMA_WRFSM     <= s_Reset;
      LIN_NO        <= (others => '0');
      DMA_ADDR_PIX  <= (others => '0');
      LATCH_IMG_FLIP_V <= '0'; 
      LATCH_IMG_SHIFT_VERT <= (others => '0');
      DMA_WRITE_FREE <= '1';
      
    elsif rising_edge(CLK) then
      
      DMA_WRREQ     <= '0';
      MEM_IMG_SOIi  <= '0';

      case DMA_WRFSM is
        when s_Reset =>
          if  SRC_V = '1' then
              LATCH_IMG_SHIFT_VERT <= unsigned(IMG_SHIFT_VERT);
              DMA_WRFSM     <= s_WAIT_H;
              DMA_WRITE_FREE <= '1';
              MEM_IMG_SOIi <= '1';
              DMA_CNT      <= to_unsigned(WR_SIZE, DMA_CNT'length);
              if DMA_ADDR_IMG = 2 then
                DMA_ADDR_IMG <= "00";
              else
                DMA_ADDR_IMG <= DMA_ADDR_IMG + 1;
              end if;
              DMA_ADDR_PICT <= (others => '0');            
              if(IMG_FLIP_V='1')then
                LIN_NO <=  (unsigned(SRC_YSIZE)-unsigned(IMG_SHIFT_VERT)) -1;
                LATCH_IMG_FLIP_V <= '1';
              else
                LIN_NO <=  (others => '0');
                LATCH_IMG_FLIP_V <= '0';
              end if;
          end if;    
             
        -- Make request when enough word are in FIFO
        when s_WAIT_H =>      

          DMA_ADDR_PICT <= x"000" & unsigned(SRC_XSIZE)*unsigned(LIN_NO+ LATCH_IMG_SHIFT_VERT) ; 
          DMA_ADDR_PIX  <= (others => '0');
          
          DMA_WRFSM     <= s_WRITE1;
          DMA_WRITE_FREE <= '0';
            
        when s_WRITE1 =>
          DMA_WRBURST <= '0';         
          
          if unsigned(FIFO_NB) >= DMA_CNT and FIFO_EMP = '0' then
            DMA_WRREQ   <= '1';
            DMA_WRBURST <= '1';
            DMA_CNT     <= to_unsigned(WR_SIZE, DMA_CNT'length);
            DMA_WRFSM   <= s_WRITE2;
          end if;
        
        when s_WRITE2 =>
          if DMA_WRREADY = '1' then
            DMA_WRBURST <= '0';
          end if;
          DMA_WRREQ <= '1';
          if DMA_CNT = 1 and DMA_WRREADY = '1' then
            DMA_ADDR_PICT <= DMA_ADDR_PICT + WR_SIZE*4;
            DMA_CNT       <= to_unsigned(WR_SIZE, DMA_CNT'length);
            DMA_WRREQ     <= '0';
            DMA_WRFSM     <= s_WAIT;
            DMA_ADDR_PIX  <= DMA_ADDR_PIX  + WR_SIZE*4;
          elsif FIFO_RD = '1' then
            DMA_CNT <= DMA_CNT - 1;
          end if;

        when s_WAIT =>
          if DMA_CNT = 0 then
            if (DMA_ADDR_PIX >= unsigned(SRC_XSIZE)) then
                DMA_ADDR_PIX  <= (others => '0'); 
                if(LATCH_IMG_FLIP_V='1')then
                  if(LIN_NO = to_unsigned(0, LIN_NO'length)) then
                    DMA_WRFSM <= s_RESET;
                  else
                    DMA_WRFSM <= s_WAIT_H;
                  end if;
                  LIN_NO        <= LIN_NO - 1; 
                else
                  if(LIN_NO = (unsigned(SRC_YSIZE)-unsigned(LATCH_IMG_SHIFT_VERT)) -1)then
                    DMA_WRFSM <= s_RESET;
                  else
                    DMA_WRFSM <= s_WAIT_H;
                  end if;
                  LIN_NO        <= LIN_NO + 1;
                end if; 
            else
                DMA_WRFSM <= s_WRITE1;  
            end if;
                DMA_CNT   <= to_unsigned(WR_SIZE, DMA_CNT'length);
                DMA_WRITE_FREE <= '0'; 
          else
            DMA_CNT <= DMA_CNT - 1;
          end if;

      end case;
      
      -- Base Address Computation for Frame Buffers
      case to_integer(DMA_ADDR_IMG) is
        when 0 => DMA_ADDR_BASE <= ADDR_BUF0;
        when 1 => DMA_ADDR_BASE <= ADDR_BUF1;
        when 2 => DMA_ADDR_BASE <= ADDR_BUF2;
        when others => null;
      end case;      

      if  SRC_V = '1' then
        LATCH_IMG_SHIFT_VERT <= unsigned(IMG_SHIFT_VERT);
        DMA_WRFSM     <= s_WAIT_H;
        DMA_WRITE_FREE <= '1';
        MEM_IMG_SOIi <= '1';
        DMA_CNT      <= to_unsigned(WR_SIZE, DMA_CNT'length);
        if DMA_ADDR_IMG = 2 then
          DMA_ADDR_IMG <= "00";
        else
          DMA_ADDR_IMG <= DMA_ADDR_IMG + 1;
        end if;
        DMA_ADDR_PICT <= (others => '0');
        if(IMG_FLIP_V='1')then
          LIN_NO <=  (unsigned(SRC_YSIZE)-unsigned(IMG_SHIFT_VERT)) -1;
          LATCH_IMG_FLIP_V <= '1';
        else
          LIN_NO <=  (others => '0');
          LATCH_IMG_FLIP_V <= '0';
        end if;             
      end if;      
      
    end if;
  end process;

  
  -- -----------------------
  --  DMA Write Outputs
  -- -----------------------
  DMA_WRADDR <= std_logic_vector(DMA_ADDR_BASE + DMA_ADDR_PICT);
--  DMA_WRADDR_temp <= std_logic_vector(DMA_ADDR_BASE + DMA_ADDR_PICT);
--  DMA_ADDR_PICT_temp <= std_logic_vector(DMA_ADDR_PICT);
--  DMA_ADDR_BASE_temp <= std_logic_vector(DMA_ADDR_BASE);
  DMA_WRSIZE <= std_logic_vector(to_unsigned(WR_SIZE, DMA_WRSIZE'length));
--  DMA_ADDR_DEC <= '0' when (LATCH_IMG_FLIP_H='0') else '1';
  DMA_WRDATA <= FIFO_OUT;
  DMA_WRBE   <= (others => '1');

  -- -----------------------
  --  Memory Info Outputs
  -- -----------------------
  MEM_IMG_SOI   <= MEM_IMG_SOIi;
  MEM_IMG_BUF   <= std_logic_vector(DMA_ADDR_IMG);
  MEM_IMG_XSIZE <= SRC_XSIZE;
  MEM_IMG_YSIZE <= std_logic_vector(unsigned(SRC_YSIZE)- unsigned(LATCH_IMG_SHIFT_VERT));



--  probe_dma_bt656(3 downto 0) <= std_logic_vector(to_unsigned(DMA_WRFSM_t'POS(DMA_WRFSM), 4));
--  probe_dma_bt656(12 downto 4) <= FIFO_NB;
--  probe_dma_bt656(14 downto 13) <=FIFO_SEL;
--  probe_dma_bt656(15) <=FIFO_EN; 
--  probe_dma_bt656(16) <=FIFO_CLR;
--  probe_dma_bt656(17) <=FIFO_WR ;
--  probe_dma_bt656(18) <=FIFO_FUL;
--  probe_dma_bt656(19) <=FIFO_EMP;
--  probe_dma_bt656(20) <=FIFO_RD ;
--  probe_dma_bt656(26 downto 21) <=std_logic_vector(DMA_CNT);
--  probe_dma_bt656(27) <= DMA_WRREADY;
--  probe_dma_bt656(95 downto 28)<= (others => '0');

  
----  probe_dma_bt656(31 downto 0)<=  DMA_WRADDR_temp;
----  probe_dma_bt656(63 downto 32)<= DMA_ADDR_PICT_temp; 
----  probe_dma_bt656(85 downto 64)<= DMA_ADDR_BASE_temp(21 downto 0);
----  probe_dma_bt656(95 downto 86)<= std_logic_vector(LIN_NO);
--  probe_dma_bt656(97 downto 96)<= std_logic_vector(DMA_ADDR_IMG);
--  probe_dma_bt656(98)<= RST;
----  probe_dma_bt656(114 downto 99)<= std_logic_vector(frame_cnt);
--  probe_dma_bt656(108 downto 99) <= std_logic_vector(DMA_ADDR_PIX);
--  probe_dma_bt656(118 downto 109) <= std_logic_vector(LIN_NO);
----  probe_dma_bt656(121 downto 119)<= DMA_WRFSM_Temp;
--  probe_dma_bt656(121 downto 119)<= (others => '0');
--  probe_dma_bt656(122)<= SRC_V;
--  probe_dma_bt656(123)<= SRC_H;
--  probe_dma_bt656(124)<= SRC_EOI;
--  probe_dma_bt656(125)<= SRC_DAV; 
----  probe_dma_bt656(126)<= LATCH_IMG_FLIP_H;
----  probe_dma_bt656(127)<= LATCH_IMG_FLIP_V;

----  probe_dma_bt656(124)<= IMG_FLIP_H;
----  probe_dma_bt656(125)<= IMG_FLIP_V;
--  probe_dma_bt656(127 downto 126)<= (others => '0');
    
--    i_ila_DMA_BT656: TOII_TUVE_ila
--    PORT MAP (
--        clk => CLK,
--        probe0 => probe_dma_bt656
--    );


--------------------------
end architecture RTL;
--------------------------