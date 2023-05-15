------------------------------------------------------------------------------
-- Copyright        : ALSE - http://alse-fr.com
-- Contact          : info@alse-fr.com
-- Project Name     : Tonboimaging - Thermal Camera Project
-- Block Name       : DMA_WRITE_1
-- Description      : DMA Write Master to Memory Controller
-- Author           : E.LAURENDEAU
-- Date of creation : 16/12/2013
------------------------------------------------------------------------------
-- Copyright    : Tonbo Imaging Pvt Ltd
-- Project Name : Tonboimaging - Thermal Camera Project
-- Block Name   : THERMAL_CAM_TOP
-- Description  : Top Level 
-- Author       : ANEESH M U
-- Date         : Jul 2016
-- Revision     : 3.0
-------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Design Notes : Master Write Interface with DDR3/SRAM (AVALON BUS)
--  16 Bits words are written in DDR3/SRAM, so input data on 8bits are doubled
--  Each frame is written in a SRAM Buffer (number given by MEM_IMG_BUF)
--  Supported Resolutions :
--  -> QVGA : 384*288 = 110592 pixels 
--  ->  VGA : 640*480 = 307200 pixels
--  Beware to choose correct ADDR_BUFx values depending the image size
--  ADDR_BUFx generic values are set in THERMAL_CAM_PACK.vhd file
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STd.all;
USE ieee.STD_LOGIC_UNSIGNED.ALL;



----------------------------------
entity DMA_WRITE_1 is
----------------------------------
  generic (
--    ADDR_BUF0 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 0
--    ADDR_BUF1 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 1
--    ADDR_BUF2 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 2
    DMA_SIZE_BITS: positive:=5;
    DATA_SIZE : positive:= 4;   -- Number of bytes in the Data Lane
    BPP       : positive:= 4;   -- Number of bytes per pixel
    WR_SIZE   : positive range 1 to 16 := 4  -- Write Burst Size for Memory Write Requests    
  );
  port (
    CLK            : in  std_logic;                      -- Module Clock
    RST            : in  std_logic;                      -- Module Reset (async active high) 
    ADDR_BUF0      : in unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 0
--    ADDR_BUF1      : in unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 1
--    ADDR_BUF2      : in unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 2
    -- Buffer Lock Signals used only when ethernet streaming is enabled
    BUF0_LOCK_READER      : in std_logic;
    BUF1_LOCK_READER      : in std_logic;
    BUF2_LOCK_READER      : in std_logic;

    BUF0_LOCK_WRITER      : out std_logic;
    BUF1_LOCK_WRITER      : out std_logic;
    BUF2_LOCK_WRITER      : out std_logic;

    -- Source Input Flux (sync'ed on CLK)               
    SRC_V          : in  std_logic;                      -- Source New Frame
    SRC_H          : in  std_logic;                      -- Source New Line
    SRC_EOI        : in  std_logic;                      -- Source End of Image
    SRC_DAV        : in  std_logic;                      -- Source Data Valid
    SRC_DATA       : in  std_logic_vector( 31 downto 0);  -- Source Data
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
    DMA_WRBE       : out std_logic_vector(3 downto 0);   -- DMA Write Data Byte enable
    MAX_PIXELS_1   : out unsigned(19 downto 0)
   );
----------------------------------
end entity DMA_WRITE_1;
----------------------------------

---------------------------------------
architecture RTL of DMA_WRITE_1 is
---------------------------------------
--COMPONENT ila_0

--PORT (
--	clk : IN STD_LOGIC;



--	probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
--);
--END COMPONENT;


--  signal probe3 : std_logic_vector(127 downto 0);
   
  constant FIFO_DEPTH : positive := 9 ;  -- 2**FIFO_DEPTH words in the FIFO
  constant FIFO_WSIZE : positive := 32;  -- FIFO word bits
  --signal FIFO_SEL     : std_logic_vector(1 downto 0);
  signal FIFO_EN      : std_logic;
  signal FIFO_CLR     : std_logic;
  signal FIFO_WR      : std_logic;
  signal FIFO_IN      : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_FUL     : std_logic;
  signal FIFO_NB      : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal FIFO_EMP     : std_logic;
  signal FIFO_RD      : std_logic;
  signal FIFO_OUT     : std_logic_vector(FIFO_WSIZE-1 downto 0);

  type DMA_WRFSM_t is (s_IDLE, s_WRITE1, s_WRITE2, s_WAIT );
  signal DMA_WRFSM     : DMA_WRFSM_t;
  signal DMA_CNT       : unsigned(DMA_WRSIZE'range);
  signal DMA_ADDR_PICT : unsigned(DMA_WRADDR'range);
  signal DMA_ADDR_IMG  : unsigned(MEM_IMG_BUF'range);
  signal DMA_ADDR_BASE : unsigned(DMA_WRADDR'range);

  signal WR_SIZE_D : unsigned(DMA_WRSIZE'range);
  signal MAX_PIXELS : unsigned(SRC_XSIZE'length+SRC_YSIZE'length-1 downto 0);
--Enable Frame and Line number at the starting of each line 
--signal FRAME_COUNTER: unsigned(31 downto 0);
--signal LINE_COUNTER: unsigned(31 downto 0);

  signal MEM_IMG_SOIi : std_logic;
--  signal srcdav_cnt : unsigned (19 downto 0);
  

--------
begin
--------
           

  -- DMA Write Master FIFO
  process(CLK, RST)
  begin
    if RST = '1' then
      FIFO_EN  <= '0';
     -- FIFO_SEL <= "00";
      FIFO_WR  <= '0';
      FIFO_IN  <= (others => '0');
--      srcdav_cnt <= (others => '0');
    elsif rising_edge(CLK) then
      FIFO_WR  <= '0';

      if SRC_V = '1' then
        FIFO_EN  <= '1';
       -- FIFO_SEL <= "00";
        FIFO_IN  <= (others => '0');
--        srcdav_cnt <= (others => '0');
        

    -- Uncomment the following code to insert Frame and Line number before each line of a frame.  
	  -- elsif SRC_H='1' then
    --     FIFO_WR <= FIFO_EN;
    --     FIFO_IN <=  std_logic_vector(resize(unsigned(FRAME_COUNTER),DMA_WRDATA'length/2)) & 
    --                 std_logic_vector(resize(unsigned(LINE_COUNTER+1),DMA_WRDATA'length/2));
      elsif SRC_DAV = '1' then
        -- FIFO_SEL <= not FIFO_SEL;
        --if FIFO_SEL = "00" then
		      --FIFO_SEL <= "01";
          FIFO_IN(31 downto 00) <= SRC_DATA;
		    --elsif FIFO_SEL = "01" then
          FIFO_WR <= FIFO_EN;
--          srcdav_cnt   <= srcdav_cnt + 1;
		      --FIFO_SEL <= "00";

        --  FIFO_IN(63 downto 32) <= SRC_DATA;
        --end if;

      end if;
    end if;
  end process;
       
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
    report "[DMA_WRITE_1] WRITE while FIFO Full !!!" severity failure;

  FIFO_RD <= not FIFO_EMP and DMA_WRREADY when DMA_WRFSM = s_WRITE2 else '0';

  -- ---------------------------------
  --  DMA Master Write Process
  -- ---------------------------------
  process(CLK, RST)
  variable PIXEL_PER_BEAT: integer:= DATA_SIZE/BPP;
  begin
    if RST = '1' then
      MEM_IMG_SOIi  <= '0';
      DMA_CNT       <= to_unsigned(WR_SIZE, DMA_CNT'length);
      DMA_ADDR_IMG  <= (others => '0');
      DMA_ADDR_PICT <= (others => '0');
      DMA_ADDR_BASE <= (others => '0');
      DMA_WRREQ     <= '0';
      DMA_WRBURST   <= '0';
      --Enable 
	    --LINE_COUNTER  <= (others => '0');
      --FRAME_COUNTER <= (others=>'0');
      DMA_WRFSM     <= s_IDLE;
      BUF0_LOCK_WRITER <='0';
      BUF1_LOCK_WRITER <='0';
      BUF2_LOCK_WRITER <='0';
      WR_SIZE_D <= to_unsigned(WR_SIZE, DMA_CNT'length);
      MAX_PIXELS_1 <= (others => '0');

    elsif rising_edge(CLK) then

      DMA_WRREQ     <= '0';
      MEM_IMG_SOIi  <= '0';
      
      case DMA_WRFSM is

        when s_IDLE =>
          if SRC_V='1' then --and ENABLE='1' then
            DMA_WRFSM<=s_WRITE1;
            MAX_PIXELS <= unsigned(SRC_XSIZE)*unsigned(SRC_YSIZE);
            WR_SIZE_D <= to_unsigned(WR_SIZE, WR_SIZE_D'length);
          end if;


        -- Make request when enough word are in FIFO
        when s_WRITE1 =>
            DMA_WRBURST <= '0';         
            --
            if unsigned(FIFO_NB) >= DMA_CNT and FIFO_EMP = '0' then
              DMA_WRREQ   <= '1';
              DMA_WRBURST <= '1';
              --DMA_CNT     <= to_unsigned(WR_SIZE, DMA_CNT'length);
              DMA_CNT     <= WR_SIZE_D;
              MAX_PIXELS <= MAX_PIXELS - WR_SIZE_D*4/BPP;

              DMA_WRFSM   <= s_WRITE2;
            end if;

        when s_WRITE2 =>
            if DMA_WRREADY = '1' then
              DMA_WRBURST <= '0';
            end if;
            DMA_WRREQ <= '1';
            if DMA_CNT = 1 and DMA_WRREADY = '1' then
              DMA_ADDR_PICT <= DMA_ADDR_PICT + WR_SIZE_D*4;
              --DMA_CNT       <= to_unsigned(WR_SIZE, DMA_CNT'length);
              DMA_CNT       <= to_unsigned(WR_SIZE/2, DMA_CNT'length);
              DMA_WRREQ     <= '0';
              DMA_WRFSM     <= s_WAIT;
            elsif FIFO_RD = '1' then
              DMA_CNT <= DMA_CNT - 1;
            end if;

        when s_WAIT =>
            if DMA_CNT = 0 then
              MAX_PIXELS_1  <= MAX_PIXELS;
              if MAX_PIXELS*BPP<WR_SIZE then
                DMA_CNT   <= resize(unsigned(MAX_PIXELS)/PIXEL_PER_BEAT, DMA_CNT'length);
                WR_SIZE_D <= resize(unsigned(MAX_PIXELS)/PIXEL_PER_BEAT, DMA_CNT'length);
              else
                DMA_CNT   <= to_unsigned(WR_SIZE, DMA_CNT'length);
              end if;
              DMA_WRFSM <= s_WRITE1;
            else
              DMA_CNT <= DMA_CNT - 1;
            end if;

      end case;
      
      -- Base Address Computation for Frame Buffers
      case to_integer(DMA_ADDR_IMG) is
        when 0 => DMA_ADDR_BASE <= ADDR_BUF0;
        when 1 => DMA_ADDR_BASE <= ADDR_BUF0;
        when 2 => DMA_ADDR_BASE <= ADDR_BUF0;
        when others => null;
      end case;      

      -- New Frame Management
      -- with Frame Buffer Locks (Assuming there not more than 1 readers)
      if SRC_V = '1' then --and ENABLE='1' then
        MEM_IMG_SOIi <= '1';
        DMA_CNT      <= to_unsigned(WR_SIZE, DMA_CNT'length);
        MAX_PIXELS <= unsigned(SRC_XSIZE)*unsigned(SRC_YSIZE);
        WR_SIZE_D <= to_unsigned(WR_SIZE, WR_SIZE_D'length);
        if DMA_ADDR_IMG = 2 and BUF0_LOCK_READER='0' then
          DMA_ADDR_IMG <= "00";
          BUF2_LOCK_WRITER <= '0';
          BUF0_LOCK_WRITER <= '1';
        elsif DMA_ADDR_IMG=2 and BUF0_LOCK_READER='1' then
          DMA_ADDR_IMG <= "01";
          BUF2_LOCK_WRITER <= '0';
          BUF1_LOCK_WRITER <= '1';
        elsif DMA_ADDR_IMG = 1 and BUF2_LOCK_READER='0' then
          DMA_ADDR_IMG <= "10";
          BUF1_LOCK_WRITER <= '0';
          BUF2_LOCK_WRITER <= '1';
        elsif DMA_ADDR_IMG=1 and BUF2_LOCK_READER='1' then
          DMA_ADDR_IMG <= "00";
          BUF1_LOCK_WRITER <= '0';
          BUF0_LOCK_WRITER <= '1';
        elsif DMA_ADDR_IMG = 0 and BUF1_LOCK_READER='0' then
          DMA_ADDR_IMG <= "01";
          BUF0_LOCK_WRITER <= '0';
          BUF1_LOCK_WRITER <= '1';
        elsif DMA_ADDR_IMG=0 and BUF1_LOCK_READER='1' then
          DMA_ADDR_IMG <= "10";
          BUF0_LOCK_WRITER <= '0';
          BUF2_LOCK_WRITER <= '1';
        else
          DMA_ADDR_IMG <= DMA_ADDR_IMG;
        end if;
        DMA_ADDR_PICT <= (others => '0');
        DMA_WRFSM     <= s_WRITE1;
      end if;
	  

	  -- Uncomment for enabling the Line number and Frmae number appending.
      -- if SRC_V = '1' then
      --   MEM_IMG_SOIi <= '1';

      --   DMA_ADDR_PICT <= (others => '0');
      --   DMA_WRFSM     <= s_WRITE1;
      --   if FRAME_COUNTER=to_unsigned(1024,FRAME_COUNTER'length) then
      --     FRAME_COUNTER <= (others=>'0');
      --   else
      --     FRAME_COUNTER <= FRAME_COUNTER+1;
      --   end if;

      -- end if;

      -- if SRC_H = '1' then
      --   if LINE_COUNTER=511 then
      --     LINE_COUNTER<=(others=>'0');
      --   else
      --     LINE_COUNTER<= LINE_COUNTER+1;
      --   end if;
      -- end if;
      
    end if;
  end process;

  
  -- -----------------------
  --  DMA Write Outputs
  -- -----------------------
  DMA_WRADDR <= std_logic_vector(DMA_ADDR_BASE + DMA_ADDR_PICT);
  DMA_WRSIZE <= std_logic_vector(WR_SIZE_D);
  DMA_WRDATA <= FIFO_OUT;
  DMA_WRBE   <= (others => '1');

  -- -----------------------
  --  Memory Info Outputs
  -- -----------------------
  MEM_IMG_SOI   <= MEM_IMG_SOIi;
  MEM_IMG_BUF   <= std_logic_vector(DMA_ADDR_IMG);
  MEM_IMG_XSIZE <= SRC_XSIZE;
  MEM_IMG_YSIZE <= SRC_YSIZE;
  
  
  

--  probe3(0)  <= FIFO_CLR;
--  probe3(1)  <= FIFO_WR ;
--  probe3(2)  <= FIFO_FUL;
--  probe3(3)  <= FIFO_EMP;
--  probe3(4)  <= FIFO_RD ;
--  probe3(24 downto 5)<= std_logic_vector(MAX_PIXELS);
--  probe3(25) <= SRC_DAV;
--  probe3(26) <= FIFO_EN;
--  probe3(46 downto 27) <= std_logic_vector(srcdav_cnt);
--  probe3(127 downto 47)<=(others => '1');
  
--  i_ila_3: ila_0
--  PORT MAP (
--      clk => CLK,
--      probe0 => probe3
--  );

--------------------------
end architecture RTL;
--------------------------
