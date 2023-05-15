---------------------------------------------------------------
-- Copyright    : ALSE - http://alse-fr.com
-- Contact      : info@alse-fr.com
-- Project Name : Tonboimaging - Thermal Camera Project
-- Block Name   : BAD_PIX_REMOV
-- Description  : Bad Pixel Removal Algorithm
-- Author       : E. LAURENDEAU
-- Date         : Jan 2014
----------------------------------------------------------------


-------------------------------------------------------------------------------
-- Design Notes :
-- * v2014.01 : Initial Version
-- * Bad Pixel Removal is done by averaging the neighboorood pixels
--   on a 3x3 area, and replacing the defected pixel
--   (marked as Bad by the VIDEO_I_BAD input)
-- * Fully Synchronous, consumes 3 lines of 2**PIX_BITS x D_BITS words + 
--   1 FIFO of 2**PIX_BITS x (D_BITS + PIX_BITS) words (for line correction) 
-- * H_CORR_ON generic : if true, the module will patch the corrected pixels
--   in the line used for next line correction : better results, but consumes
--   more memory blocks : (1 FIFO of 2**H_CORR_MAX x (D_BITS + PIX_BITS) words
--   (in case a full line correction has to be performed) 
--  * H_CORR_MAX : if H_CORR_ON is true, specify the FIFO size for storing 
--    the Maximum Number of Bad Pixels in a line (max value = PIX_BITS)  
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- This version works for any interframe time. It also does not skip the first 
-- input line like the original ALSE BAD_PIX_REMOV module.
-------------------------------------------------------------------------------

  use WORK.THERMAL_CAM_PACK.all;
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
--  use IEEE.std_logic_unsigned.all;
--  use IEEE.math_real.all;



----------------------------------
entity BAD_PIX_REMOV_PIPELINED_1 is
----------------------------------
  
  generic ( 

    bit_width   : positive := 13;                                      -- One less than the number of bits in a pixel 
    PIX_BITS    : positive := 10;                                      -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS    : positive := 10;                                      -- 2**LIN_BITS = Maximum Number of  lines in an image
    H_CORR_ON   : boolean  := true;                                    -- If true, algorithm corrects pixels in neighboorhood for next line
    H_CORR_MAX  : positive := 10;                                      -- 2**H_CORR_MAX = FIFO Depth Size if H_CORR_ON true (max value = PIX_BITS)
    CC_GAP      : integer := 17;                                      -- Minimum value is 1 for DPHE to work properly
    VIDEO_XSIZE : integer  := 642;
    VIDEO_YSIZE : integer  := 480
  );

  port (

    -- Clock and Reset
    CLK           : in  std_logic;                                    -- Module Clock
    RST           : in  std_logic;                                    -- Module Reset (asynch'ed active high)
    ENABLE        : in  std_logic;                                          -- BAD_PIX_REMOV performed if '1', otherwise bypass

    -- Video Input
    VIDEO_I_V     : in  std_logic;                                    -- Video Input   Vertical Synchro
    VIDEO_I_H     : in  std_logic;                                    -- Video Input Horizontal Synchro
    VIDEO_I_EOI   : in  std_logic;                                    -- Video Input End Of Image
    VIDEO_I_DAV   : in  std_logic;                                    -- Video Input Pixel Valid
    VIDEO_I_DATA  : in  std_logic_vector(bit_width downto 0);         -- Video Input Pixel Data
    VIDEO_I_BAD   : in  std_logic;                                    -- Video Input Pixel Bad  
    --VIDEO_I_XSIZE : in  std_logic_vector(PIX_BITS-1 downto 0);        -- Video X Size
    --VIDEO_I_YSIZE : in  std_logic_vector(LIN_BITS-1 downto 0);        -- Video Y Size
    --VIDEO_I_XCNT  : in  std_logic_vector(PIX_BITS-1 downto 0);        -- Video X Pixel Counter (1st pixel = 0)
    --VIDEO_I_YCNT  : in  std_logic_vector(LIN_BITS-1 downto 0);        -- Video Y Line  Counter (1st line  = 0)

    -- Video Output
    VIDEO_O_V     : out std_logic;                                    -- Video Output   Vertical Synchro
    VIDEO_O_H     : out std_logic;                                    -- Video Output Horizontal Synchro
    VIDEO_O_EOI   : out std_logic;                                    -- Video Output End Of Image
    VIDEO_O_DAV   : out std_logic;                                    -- Video Output Pixel Valid
    VIDEO_O_DATA  : out std_logic_vector(bit_width downto 0)         -- Video Output Pixel Data
    --VIDEO_O_XSIZE : out std_logic_vector(PIX_BITS-1 downto 0);        -- Video X Size
    --VIDEO_O_YSIZE : out std_logic_vector(LIN_BITS-1 downto 0);        -- Video Y Size
    --VIDEO_O_XCNT  : out std_logic_vector(PIX_BITS-1 downto 0);        -- Video X Pixel Counter (1st pixel = 0)
    --VIDEO_O_YCNT  : out std_logic_vector(LIN_BITS-1 downto 0)         -- Video Y Line  Counter (1st line  = 0)

  );
------------------------------- 
end entity BAD_PIX_REMOV_PIPELINED_1;
-------------------------------

-------------------------------------------
architecture RTL of BAD_PIX_REMOV_PIPELINED_1 is


COMPONENT TOII_TUVE_ila

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(240 DOWNTO 0)
);
END COMPONENT;

  signal probe0 : std_logic_vector(240 downto 0);
  --Signal for x and y count
  signal VIDEO_I_XCNT  :  std_logic_vector(PIX_BITS-1 downto 0);        -- Video X Pixel Counter (1st pixel = 0)
  signal VIDEO_I_YCNT  :  std_logic_vector(LIN_BITS-1 downto 0);        -- Video Y Line  Counter (1st line  = 0)
  signal VIDEO_O_XCNT  :  std_logic_vector(PIX_BITS-1 downto 0);        -- Video X Pixel Counter (1st pixel = 0)
  signal VIDEO_O_YCNT  :  std_logic_vector(LIN_BITS-1 downto 0);        -- Video Y Line  Counter (1st line  = 0)

 --signal VIDEO_I_BAD  :  std_logic;                              
-------------------------------------------
  
  constant MATRIX_SIZE : positive := 3;  -- Neighboorhood used for Algorithm : 3x3

  constant D_BITS         : positive := bit_width+1;
  constant RAM_ADDR_WIDTH : positive := PIX_BITS;
  constant RAM_DATA_WIDTH : positive := D_BITS+1;  -- +1 for bad pixel bit

  signal count : unsigned(5 downto 0);
  
  signal VIDEO_I_DAVr     : std_logic;
  signal VIDEO_I_DAVrr    : std_logic;
  signal VIDEO_I_DATAr    : std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
  signal VIDEO_I_DATArr   : std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
  signal VIDEO_I_YCNTr    : unsigned(VIDEO_I_YCNT'range);
  
  -- Signals for the 3x3 or 5x5 lines
  type RAM_DATA_t is array (0 to MATRIX_SIZE-1) of std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
  signal RAM_WREN_0       : std_logic;
  signal RAM_WRREQ_0      : std_logic_vector(0 to MATRIX_SIZE-1);
  signal RAM_WRLIN_0      : unsigned(0 to VIDEO_XSIZE-1);
  signal RAM_WRADD_0      : unsigned(RAM_ADDR_WIDTH-1 downto 0);
  signal RAM_RDADD_0      : unsigned(RAM_ADDR_WIDTH-1 downto 0);
  signal RAM_RDADDr_0     : unsigned(RAM_ADDR_WIDTH-1 downto 0);
  signal RAM_WRDATA_0     : RAM_DATA_t;
  signal RAM_WRDATN_0     : std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
  signal RAM_RDDATA_0     : RAM_DATA_t;

  signal RAM_WREN_1       : std_logic;
  signal RAM_WRREQ_1      : std_logic_vector(0 to MATRIX_SIZE-1);
  signal RAM_WRLIN_1      : unsigned(0 to VIDEO_YSIZE-1);
  signal RAM_WRADD_1      : unsigned(RAM_ADDR_WIDTH-1 downto 0);
  signal RAM_RDADD_1      : unsigned(RAM_ADDR_WIDTH-1 downto 0);
  signal RAM_RDADDr_1     : unsigned(RAM_ADDR_WIDTH-1 downto 0);
  signal RAM_WRDATA_1     : RAM_DATA_t;
  signal RAM_WRDATN_1     : std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
  signal RAM_RDDATA_1     : RAM_DATA_t;

  type RAM_WRFSM_t is ( s_IDLE, s_STORE_INPUT_LINE, s_STORE_EXTRA_LINE, 
                        s_STORE_EXTRA_PIXELS, s_WAIT_ALGO_XEND, s_CORRECT );
  signal RAM_WRFSM        : RAM_WRFSM_t;  
  signal oNEW_PIX         : std_logic;
  signal oNEW_DATA        : RAM_DATA_t;
  
  -- Misc Signals
  signal LAST_LINE        : std_logic;
  signal FIRST_LINE       : std_logic;
             
  -- Extra Signals
  signal EXTRA_LIN        : std_logic;
  signal EXTRA_H          : std_logic;
  signal EXTRA_DAV        : std_logic;
  signal EXTRA_DAVr       : std_logic;
  
  -- Video Output Signals
  type VIDEO_O_FSM_t is ( s_IDLE, s_START, s_Y_FIRST, s_Y_NEW, s_X_ALGO ); 
  signal VIDEO_O_FSM      : VIDEO_O_FSM_t;
  signal VIDEO_O_DAVi     : std_logic;                     
  signal VIDEO_O_DATAi    : std_logic_vector(VIDEO_O_DATA'range);
  signal VIDEO_O_DAVEN    : std_logic;                     
  signal VIDEO_O_XEND     : std_logic;                     
  signal VIDEO_O_XSIZi    : unsigned(0 to VIDEO_XSIZE-1);
  signal VIDEO_O_YSIZi    : unsigned(0 to VIDEO_YSIZE-1);
  signal VIDEO_O_XCNTi    : unsigned(VIDEO_O_XCNT'range);  
  signal VIDEO_O_YCNTi    : unsigned(VIDEO_O_YCNT'range);   

  -- Algorithm Signals
  constant ALGO_PIPE_CLKS : positive := 4;  -- Pipeline Clock Cycles
  signal ALGO_ND          : std_logic_vector(ALGO_PIPE_CLKS-1 downto 0);
  type ALGO_PIXC_t is array (ALGO_PIPE_CLKS downto 0) of unsigned(RAM_DATA_WIDTH-1 downto 0);
  signal ALGO_PIXC        : ALGO_PIXC_t;
  signal ALGO_XCNT        : unsigned( 1 downto 0);  
  type ROW_SUM_t is array (0 to MATRIX_SIZE-1) of unsigned(D_BITS+MATRIX_SIZE-2 downto 0);
  type ROW_CNT_t is array (0 to MATRIX_SIZE-1) of integer range 0 to MATRIX_SIZE;
  signal MAT_SUM          : unsigned(D_BITS+MATRIX_SIZE downto 0);
  signal MAT_SUM2         : unsigned(D_BITS+MATRIX_SIZE downto 0);
  signal MAT_CNT          : integer range 0 to MATRIX_SIZE*MATRIX_SIZE;
  signal MAT_CNT2          : integer range 0 to MATRIX_SIZE*MATRIX_SIZE;
  signal multiplier       : unsigned(17 downto 0);
  signal ALGO_AVRG        : unsigned(VIDEO_O_DATAi'length-1 downto 0);
  signal ROW_SUM          : ROW_SUM_t;
  signal ROW_CNT          : ROW_CNT_t;
  
  -- Correction Signals
  signal CORRECT_DAV      : std_logic;
  signal CORRECT_WRREQ_0  : std_logic;
  signal CORRECT_WRDATA_0 : std_logic_vector(RAM_DATA_WIDTH-1 downto 0);

  signal CORRECT_WRREQ_1  : std_logic;
  signal CORRECT_WRDATA_1 : std_logic_vector(RAM_DATA_WIDTH-1 downto 0);

  signal mem_wr_no        : std_logic;
  signal mem_rd_no        : std_logic;
  signal DAV_EOL          : std_logic;
  signal DAV_EOLr         : std_logic;
  signal DAV_EOLrr        : std_logic;
  signal switch_mem_wr_no : std_logic;

  -- FIFO Signals
  constant FIFO_DEPTH     : positive := H_CORR_MAX ;     -- 2**FIFO_DEPTH words in the FIFO
  constant FIFO_WSIZE     : positive := D_BITS+PIX_BITS; -- Data + Address
  signal FIFO_CLR         : std_logic;
  signal FIFO_WR          : std_logic;
  signal FIFO_IN          : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_FUL         : std_logic;
  signal FIFO_NB          : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal FIFO_EMP         : std_logic;
  signal FIFO_RD          : std_logic;
  signal FIFO_OUT         : std_logic_vector(FIFO_WSIZE-1 downto 0);

  type rand_x is array (0 to 49) of integer range 0 to 641;
  signal xcorr : rand_x;
  type rand_y is array (0 to 49) of integer  range 0 to 479;
  signal ycorr : rand_y;
--signal xcorr : real := 0.0;
--signal ycorr : real := 0.0;

ATTRIBUTE MARK_DEBUG : string;

ATTRIBUTE MARK_DEBUG of VIDEO_I_V           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_H           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_EOI         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_DAV         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_DATA        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_BAD         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_O_DAVi        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_O_DATAi       : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_DAVr        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_DAVrr       : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_DATAr       : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_DATArr      : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_XCNT        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_YCNT        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_I_YCNTr       : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIRST_LINE          : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of mem_wr_no           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_WREN_0          : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_WRADD_0         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_WRLIN_0         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_WREN_1          : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_WRADD_1         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_WRLIN_1         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of DAV_EOL             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of DAV_EOLr            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of DAV_EOLrr           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_RDADD_0         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_RDADDr_0        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_RDADD_1         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_RDADDr_1        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of EXTRA_H             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of EXTRA_DAV           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of EXTRA_DAVr          : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of CORRECT_WRREQ_0     : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of CORRECT_WRDATA_0    : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of CORRECT_WRREQ_1     : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of CORRECT_WRDATA_1    : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of EXTRA_LIN           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of LAST_LINE            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of count               : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of RAM_WRFSM           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of oNEW_PIX            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of oNEW_DATA           : SIGNAL IS "TRUE";        
ATTRIBUTE MARK_DEBUG of switch_mem_wr_no    : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_O_XEND        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIFO_IN             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIFO_CLR            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIFO_WR             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIFO_FUL            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIFO_NB             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIFO_EMP            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIFO_RD             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of FIFO_OUT            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_O_FSM         : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of ROW_CNT             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of ROW_SUM             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of ALGO_PIXC           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of MAT_SUM             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of MAT_CNT             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of MAT_SUM2            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of MAT_CNT2            : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of multiplier          : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of ALGO_ND             : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of ENABLE              : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of ALGO_AVRG           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_O_DAVEN       : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of ALGO_XCNT           : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of VIDEO_O_XCNTi       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_O_YCNTi       : SIGNAL IS "TRUE";
  
--------
begin
-------

-- To increment the input X and Y count. --Only needed for uncooled pipeline

   process(CLK,RST)
  begin
    if RST = '1' then
      VIDEO_I_XCNT <= (others => '0');
      VIDEO_I_YCNT <= (others => '0');
    elsif rising_edge(CLK) then
      if VIDEO_I_V = '1' then
       VIDEO_I_XCNT <= (others => '0');
       VIDEO_I_YCNT <= (others => '0');
      end if;
      if VIDEO_I_DAV = '1' then
        VIDEO_I_XCNT <= std_logic_vector(unsigned(VIDEO_I_XCNT) + 1 );
        if unsigned(VIDEO_I_XCNT) = VIDEO_XSIZE-1 then
          VIDEO_I_XCNT <= (others => '0');
          VIDEO_I_YCNT  <= std_logic_vector(unsigned(VIDEO_I_YCNT) + 1) ;
        end if;
      end if;
      --if VIDEO_I_H = '1' then
      --  VIDEO_I_XCNT  <= (others => '0');
      --  VIDEO_I_YCNT  <= VIDEO_I_YCNT + 1 ;
      --end if;
       if unsigned(VIDEO_I_YCNT) = VIDEO_YSIZE then
         VIDEO_I_YCNT <= (others => '0');
        end if;
    end if;

end process;

  -- -----------------------------------------------------------
  --  Input Data Pixels registered, to match RAM Read Latency
  -- -----------------------------------------------------------
  process(CLK, RST)
  begin
    if RST = '1' then
      VIDEO_I_DAVr   <= '0';
      VIDEO_I_DAVrr  <= '0';
      VIDEO_I_DATAr  <= (others => '0');
      VIDEO_I_DATArr <= (others => '0');
      VIDEO_I_YCNTr  <= (others => '0');
    elsif rising_edge(CLK) then
      if VIDEO_I_H = '1' then
        VIDEO_I_YCNTr <= unsigned(VIDEO_I_YCNT);
      end if;
      VIDEO_I_DAVr   <= VIDEO_I_DAV;
      VIDEO_I_DAVrr  <= VIDEO_I_DAVr;
      VIDEO_I_DATAr  <= VIDEO_I_BAD & VIDEO_I_DATA;
      VIDEO_I_DATArr <= VIDEO_I_DATAr;
    end if;
  end process;


     
    --process(ENABLE)

    --variable seed1,seed2: positive;                          -- seed values for random generator               
    --variable x : real := 641.0;                        -- the range of random values created will be 0 to 641 as xsize is 642.
    --variable y : real := 479.0;                        -- the range of random values created will be 0 to 479 as ysize is 479.
    --variable x_rand: real;
    --variable y_rand: real;      

    --begin

    --if ENABLE = '1' then
      
    --  for i in 0 to 49 loop
    --    uniform(seed1, seed2, x_rand);                     -- generate random number
    --    xcorr(i) <= integer(x_rand*x);                       -- rescale to 0..1000, convert integer part

    --    uniform(seed1,seed2,y_rand);
    --    ycorr(i) <= integer(y_rand*y);
    --  end loop;

    -- end if;
    -- end process;
     
    ----To generate Bad pixels. These are not the true bad pixels. Just for simulation purposes.
    -- process(CLK,RST)
    -- begin
    --  if VIDEO_I_DAV = '1' then
    --   for i in 0 to 49 loop
    --       if VIDEO_I_XCNT = xcorr(i) and VIDEO_I_YCNT = ycorr(i) then
    --     VIDEO_I_BAD <= '1';
    --    exit; -- check if this is correct.
    --    else
    --     VIDEO_I_BAD <= '0';
    --    end if; 
    --   end loop;  
    --  end if; 
    --end process;


  -- Generating RAM Write/Read Addresses
  process(CLK, RST)
  begin
    if RST = '1' then
      LAST_LINE      <= '0'; 
      FIRST_LINE     <= '0';
      EXTRA_H        <= '0';
      EXTRA_DAV      <= '0';
      EXTRA_DAVr     <= '0';
      EXTRA_LIN      <= '0';
      CORRECT_WRREQ_0 <= '0';
      CORRECT_WRDATA_0 <= (others => '0');
      RAM_WREN_0     <= '0';
      RAM_WRDATN_0   <= (others => '0');
      RAM_WRADD_0    <= (others => '0');
      RAM_RDADD_0    <= (others => '0');
      RAM_RDADDr_0   <= (others => '0');
      RAM_WRLIN_0    <= (others => '0');
      CORRECT_WRREQ_1<= '0';
      CORRECT_WRDATA_1<= (others => '0');
      RAM_WREN_1     <= '0';
      RAM_WRDATN_1   <= (others => '0');
      RAM_WRADD_1    <= (others => '0');
      RAM_RDADD_1    <= (others => '0');
      RAM_RDADDr_1   <= (others => '0');
      RAM_WRLIN_1    <= (others => '0');
      mem_wr_no      <= '0';
      switch_mem_wr_no <= '0';
      DAV_EOL        <= '0';
      DAV_EOLr       <= '0';
      DAV_EOLrr      <= '0';
      count          <= (others => '0');
      RAM_WRFSM      <= s_IDLE;      
    elsif rising_edge(CLK) then





      if VIDEO_I_V = '1' then  -- when new image is received
        FIRST_LINE <= '1';
        if mem_wr_no = '0' then
          RAM_WRLIN_0  <= (others => '0');
        else
          RAM_WRLIN_1  <= (others => '0');
        end if;
      end if;

      if VIDEO_I_H = '1' then  
        if mem_wr_no = '0' then
          RAM_WRADD_0  <= (others => '0');
          RAM_RDADD_0  <= (others => '0');
          RAM_RDADDr_0 <= (others => '0');
        else
          RAM_WRADD_1  <= (others => '0');
          RAM_RDADD_1  <= (others => '0');
          RAM_RDADDr_1 <= (others => '0');
        end if;
      end if;

      -- The following section stores the first (MATRIX_SIZE-1) lines coming after VIDEO_I_V into their respective RAMs
      if VIDEO_I_YCNTr < MATRIX_SIZE-1 then

        if VIDEO_I_DAV = '1' and (unsigned(VIDEO_I_XCNT) = to_unsigned(VIDEO_XSIZE-1,VIDEO_I_XCNT'length)) then 
          DAV_EOL <= '1';
        else 
          DAV_EOL <= '0';
        end if;

        if mem_wr_no = '0' then
          if VIDEO_I_DAV = '1' or DAV_EOLr = '1' then
            if RAM_RDADD_0 < VIDEO_O_XSIZi then
              RAM_RDADD_0 <= RAM_RDADD_0 + 1;
            end if;
          end if;
          if VIDEO_I_DAVr = '1' then
            RAM_WRDATN_0 <= VIDEO_I_DATAr;
          elsif DAV_EOLrr = '1' then
            RAM_WRDATN_0 <= (D_BITS => '1', others => '0'); -- say this is bad pixel
          end if;
          if RAM_WREN_0 = '1' and RAM_WRADD_0 = VIDEO_O_XSIZi then -- End of Storing 
            if FIRST_LINE = '1' then
              RAM_WRLIN_0 <= RAM_WRLIN_0 + 2;                      -- Storing 0th Bad Pixel Line and 1st data line will take place simultaneously (from 2nd frame onwards)
              FIRST_LINE <= '0';
            else 
              RAM_WRLIN_0 <= RAM_WRLIN_0 + 1;
            end if;
          end if;
        else
          if VIDEO_I_DAV = '1' or DAV_EOLr = '1' then
            if RAM_RDADD_1 < VIDEO_O_XSIZi then
              RAM_RDADD_1 <= RAM_RDADD_1 + 1;
            end if;
          end if;
          if VIDEO_I_DAVr = '1' then
            RAM_WREN_1 <= '1';
            RAM_WRDATN_1 <= VIDEO_I_DATAr;
          elsif DAV_EOLrr = '1' then
            RAM_WREN_1 <= '1';
            RAM_WRDATN_1 <= (D_BITS => '1', others => '0'); -- say this is bad pixel
          end if;
          if RAM_WREN_1 = '1' and RAM_WRADD_1 = VIDEO_O_XSIZi then -- End of Storing 
            if FIRST_LINE = '1' then
              RAM_WRLIN_1 <= RAM_WRLIN_1 + 2;                      -- Storing 0th Bad Pixel Line and 1st data line will take place simultaneously (from 2nd frame onwards)
              FIRST_LINE <= '0';
            else 
              RAM_WRLIN_1 <= RAM_WRLIN_1 + 1;
            end if;
          end if;
        end if;
      end if;

      if VIDEO_I_YCNTr < MATRIX_SIZE-1 and (VIDEO_I_DAVr = '1' or DAV_EOLrr = '1') then
        if mem_wr_no = '0' then
          RAM_WREN_0 <= '1';
        else
          RAM_WREN_1 <= '1';
        end if;
      else
        RAM_WREN_0 <= '0';
        RAM_WREN_1 <= '0';
      end if;

      DAV_EOLr <= DAV_EOL;
      DAV_EOLrr <= DAV_EOLr;
    
      -- Default Assignments
      EXTRA_H       <= '0';
      EXTRA_DAV     <= '0';
      EXTRA_DAVr    <= EXTRA_DAV;  -- To cope with Read Address 2 CLK cycles delayed
      CORRECT_WRREQ_0<= '0';
      CORRECT_WRREQ_1<= '0';
      
      -- Write Address is always : Read Address delayed by 2 CLK cycles
      RAM_RDADDr_0  <= RAM_RDADD_0;
      RAM_WRADD_0   <= RAM_RDADDr_0;

      -- Write Address is always : Read Address delayed by 2 CLK cycles
      RAM_RDADDr_1  <= RAM_RDADD_1;
      RAM_WRADD_1   <= RAM_RDADDr_1;
      
      case RAM_WRFSM is
      
        -- Waiting for 3rd line of new image
        when s_IDLE => 
          if VIDEO_I_H = '1' then
            if unsigned(VIDEO_I_YCNT) = VIDEO_O_YSIZi-1  then
              LAST_LINE <= '1';  -- Last line Detection
            end if;
            if mem_wr_no = '0' then
              RAM_WRADD_0  <= (others => '0');
              RAM_RDADD_0  <= (others => '0');
              RAM_RDADDr_0 <= (others => '0');
            else
              RAM_WRADD_1  <= (others => '0');
              RAM_RDADD_1  <= (others => '0');
              RAM_RDADDr_1 <= (others => '0');
            end if;
            if unsigned(VIDEO_I_YCNT) >= MATRIX_SIZE-1 then
              RAM_WRFSM  <= s_STORE_INPUT_LINE;
            end if;              
          elsif EXTRA_LIN = '1' then
            EXTRA_H    <= '1';
            if mem_wr_no = '1' then
              RAM_WRADD_0  <= (others => '0');
              RAM_RDADD_0  <= (others => '0');
              RAM_RDADDr_0 <= (others => '0');
            else
              RAM_WRADD_1  <= (others => '0');
              RAM_RDADD_1  <= (others => '0');
              RAM_RDADDr_1 <= (others => '0');
            end if;
            if EXTRA_H = '1' then 
              EXTRA_DAV <= '1';
              count <= (others => '0');
              RAM_WRFSM <= s_STORE_EXTRA_LINE;
            end if;
          end if;
            
        -- Storing a Real Video Input line
        when s_STORE_INPUT_LINE => 
          -- Store Real Pixels for this line
          if mem_wr_no = '0' then
            RAM_WREN_0   <= VIDEO_I_DAVr;
            RAM_WRDATN_0 <= VIDEO_I_DATAr; 
            if VIDEO_I_DAV = '1' then
              if RAM_RDADD_0 < VIDEO_O_XSIZi-1 then
                RAM_RDADD_0 <= RAM_RDADD_0 + 1;
              end if;
            end if;
            -- End of Storing all the VIDEO_O_XSIZi pixels ?
            if RAM_WREN_0 = '1' and RAM_WRADD_0 = VIDEO_O_XSIZi-1 then 
              count <= (others => '0');
              RAM_WRFSM <= s_STORE_EXTRA_PIXELS; 
            end if;
          else
            RAM_WREN_1   <= VIDEO_I_DAVr;
            RAM_WRDATN_1 <= VIDEO_I_DATAr;
            if VIDEO_I_DAV = '1' then
              if RAM_RDADD_1 < VIDEO_O_XSIZi-1 then
                RAM_RDADD_1 <= RAM_RDADD_1 + 1;
              end if;
            end if;
            -- End of Storing all the VIDEO_O_XSIZi pixels ?
            if RAM_WREN_1 = '1' and RAM_WRADD_1 = VIDEO_O_XSIZi-1 then 
              RAM_WRFSM <= s_STORE_EXTRA_PIXELS; 
            end if; 
          end if;           
            
        -- Storing an Extra line with only Bad Pixels
        when s_STORE_EXTRA_LINE =>
          if mem_wr_no = '1' then
              -- Generates EXTRA_DAV : Exactly VIDEO_O_XSIZi  
            if count = CC_GAP then
              if RAM_RDADD_0 < VIDEO_O_XSIZi-1 then
                RAM_RDADD_0 <= RAM_RDADD_0 + 1;
                EXTRA_DAV <= '1';
              end if;
              count <= (others => '0');
            else
              count <= count + 1;
            end if;
              -- Store Bad Pixels for this line
            RAM_WREN_0   <= EXTRA_DAVr;
            RAM_WRDATN_0 <= (D_BITS => '1', others => '0'); -- say this line is bad pixels
            -- End of Storing all the VIDEO_O_XSIZi pixels ?
            if RAM_WREN_0 = '1' and RAM_WRADD_0 = VIDEO_O_XSIZi-1 then 
              RAM_WRFSM <= s_STORE_EXTRA_PIXELS; 
            end if;
          else
              -- Generates EXTRA_DAV : Exactly VIDEO_O_XSIZi  
            if count = CC_GAP then
              if RAM_RDADD_1 < VIDEO_O_XSIZi-1 then
                RAM_RDADD_1 <= RAM_RDADD_1 + 1;
                EXTRA_DAV <= '1';
              end if;
              count <= (others => '0');
            else
              count <= count + 1;
            end if;
              -- Store Bad Pixels for this line
            RAM_WREN_1   <= EXTRA_DAVr;
            RAM_WRDATN_1 <= (D_BITS => '1', others => '0'); -- say this line is bad pixels
            -- End of Storing all the VIDEO_O_XSIZi pixels ?
            if RAM_WREN_1 = '1' and RAM_WRADD_1 = VIDEO_O_XSIZi-1 then 
              count <= (others => '0');
              RAM_WRFSM <= s_STORE_EXTRA_PIXELS; 
            end if;
          end if;
            
        -- Generating 1 Extra Pixel at End of Line :
        when s_STORE_EXTRA_PIXELS => 
          if (mem_wr_no = '0' and EXTRA_LIN = '1') or (mem_wr_no = '1' and EXTRA_LIN = '0') then
              -- Store Extra "Bad Pixels" at End of Line
            if RAM_RDADD_1 < VIDEO_O_XSIZi then
              EXTRA_DAV <= '1';
              RAM_RDADD_1 <= RAM_RDADD_1 + 1;
            end if; 
            RAM_WREN_1   <= EXTRA_DAVr;
            RAM_WRDATN_1 <= (D_BITS => '1', others => '0'); -- say this is bad pixels
            if RAM_WREN_1 = '1' and RAM_WRADD_1 = VIDEO_O_XSIZi then -- End of Storing 
              RAM_WRLIN_1 <= RAM_WRLIN_1 + 1;
              if LAST_LINE = '1' and EXTRA_LIN = '0' then
                switch_mem_wr_no <= '1';
                LAST_LINE <= '0';
                EXTRA_LIN <= '1';  -- will need to generate extra lines
              elsif EXTRA_LIN = '1' then
                if RAM_WRLIN_1 = VIDEO_O_YSIZi+MATRIX_SIZE-1 then
                  EXTRA_LIN <= '0';
                end if;
              end if;
              -- Where to go ?
              if RAM_WRLIN_1 = VIDEO_O_YSIZi+MATRIX_SIZE-1 then -- Start/End of Image
                RAM_WRFSM <= s_IDLE; 
              else  -- Go check if any correction are needed
                RAM_WRFSM <= s_WAIT_ALGO_XEND;
              end if;
            end if;
          elsif (mem_wr_no = '0' and EXTRA_LIN = '0') or (mem_wr_no = '1' and EXTRA_LIN = '1') then
              -- Store Extra "Bad Pixels" at End of Line
            if RAM_RDADD_0 < VIDEO_O_XSIZi then
              EXTRA_DAV <= '1';
              RAM_RDADD_0 <= RAM_RDADD_0 + 1;
            end if; 
            RAM_WREN_0   <= EXTRA_DAVr;
            RAM_WRDATN_0 <= (D_BITS => '1', others => '0'); -- say this is bad pixel
            if RAM_WREN_0 = '1' and RAM_WRADD_0 = VIDEO_O_XSIZi then -- End of Storing 
              RAM_WRLIN_0 <= RAM_WRLIN_0 + 1;
              if LAST_LINE = '1' and EXTRA_LIN = '0' then
                switch_mem_wr_no <= '1';
                LAST_LINE <= '0';
                EXTRA_LIN <= '1';  -- will need to generate extra lines
              elsif EXTRA_LIN = '1' then
                if RAM_WRLIN_0 = VIDEO_O_YSIZi+MATRIX_SIZE-1 then
                  EXTRA_LIN <= '0';
                end if;
              end if;
              -- Where to go ?
              if RAM_WRLIN_0 = VIDEO_O_YSIZi+MATRIX_SIZE-1 then -- End of Image
                RAM_WRFSM <= s_IDLE; 
              else  -- Go check if any correction are needed
                RAM_WRFSM <= s_WAIT_ALGO_XEND;
              end if;
            end if;
          end if;
            
        -- Wait End of Line
        when s_WAIT_ALGO_XEND =>
          if VIDEO_O_XEND = '1' then
            if H_CORR_ON then
              RAM_WRFSM <= s_CORRECT;
            else
              if switch_mem_wr_no = '1' then
                mem_wr_no <= not mem_wr_no;
                switch_mem_wr_no <= '0';
              end if;
              RAM_WRFSM <= s_IDLE;
            end if;
          end if;
            
        -- Correct Bad Pixels corrected by Algorithm,
        -- so that they are not Bad Pixels anymore for next line computation !
        when s_CORRECT => 
          if H_CORR_ON then    
            if VIDEO_I_V = '1' then
                if switch_mem_wr_no = '1' then
                  mem_wr_no <= not mem_wr_no;
                  switch_mem_wr_no <= '0';
                end if;
                RAM_WRFSM <= s_IDLE;
            end if;
            if VIDEO_I_H = '1' then                      -- in case it arrives and we didn't have time to correct all pixels !
              if unsigned(VIDEO_I_YCNT) >= MATRIX_SIZE then
                RAM_WRFSM  <= s_STORE_INPUT_LINE;  
              end if;            
            elsif FIFO_EMP = '1' then
              RAM_WRFSM <= s_IDLE; 
              if switch_mem_wr_no = '1' then
                mem_wr_no <= not mem_wr_no;
                switch_mem_wr_no <= '0';
              end if;
            elsif FIFO_RD = '1' then
              if (mem_wr_no = '0' and EXTRA_LIN = '1') or (mem_wr_no = '1' and EXTRA_LIN = '0') then      
                CORRECT_WRREQ_1  <= '1';
                CORRECT_WRDATA_1 <= '0' & FIFO_OUT(D_BITS-1 downto 0); -- "Good pixel" & "the Value"
                RAM_WRADD_1      <= unsigned(FIFO_OUT(D_BITS+PIX_BITS-1 downto D_BITS)); -- Where ?
              elsif (mem_wr_no = '0' and EXTRA_LIN = '0') or (mem_wr_no = '1' and EXTRA_LIN = '1') then
                CORRECT_WRREQ_0  <= '1';
                CORRECT_WRDATA_0 <= '0' & FIFO_OUT(D_BITS-1 downto 0); -- "Good pixel" & "the Value"
                RAM_WRADD_0      <= unsigned(FIFO_OUT(D_BITS+PIX_BITS-1 downto D_BITS)); -- Where ?
              end if;
            end if;
          end if;  -- if H_CORR_ON then 
            
      end case;

      if VIDEO_I_YCNTr < MATRIX_SIZE-1 then
        if mem_wr_no = '0' then
          if RAM_WREN_0 = '1' and RAM_WRADD_0 = VIDEO_O_XSIZi then -- End of Storing 
            if FIRST_LINE = '0' then
              RAM_WRFSM <= s_IDLE;
            end if;
          end if;
        else
          if RAM_WREN_1 = '1' and RAM_WRADD_1 = VIDEO_O_XSIZi then -- End of Storing 
            if FIRST_LINE = '0' then
              RAM_WRFSM <= s_IDLE;
            end if;
          end if;
        end if;
      end if;
        
    end if;
  end process;

  -- Managing RAM Write Data here :
  -- Line N is a copy of RAM_WRDATN (managed above)
  -- Lines (N-1, N-2, etc ...) are a copy of previous lines (N, N-1, etc ...)  
  process(RAM_RDDATA_0, RAM_WREN_0, RAM_WRDATN_0, CORRECT_WRREQ_0, CORRECT_WRDATA_0)
  begin
    -- Write Requests
    for I in 0 to MATRIX_SIZE-1 loop 
      RAM_WRREQ_0(I) <= RAM_WREN_0;
    end loop;
    RAM_WRDATA_0(MATRIX_SIZE-1) <= RAM_WRDATN_0;
    -- For previous lines, copy previous line
    for I in 1 to MATRIX_SIZE-1 loop 
      RAM_WRDATA_0(I-1) <= RAM_RDDATA_0(I);
    end loop;
    -- Correction ? (done at end of line)
    if CORRECT_WRREQ_0 = '1' then
      RAM_WRREQ_0(0)  <= '1';
      RAM_WRDATA_0(0) <= CORRECT_WRDATA_0;
    end if;
  end process;

  process(RAM_RDDATA_1, RAM_WREN_1, RAM_WRDATN_1, CORRECT_WRREQ_1, CORRECT_WRDATA_1)
  begin
    -- Write Requests
    for I in 0 to MATRIX_SIZE-1 loop 
      RAM_WRREQ_1(I) <= RAM_WREN_1;
    end loop;
    RAM_WRDATA_1(MATRIX_SIZE-1) <= RAM_WRDATN_1;
    -- For previous lines, copy previous line
    for I in 1 to MATRIX_SIZE-1 loop 
      RAM_WRDATA_1(I-1) <= RAM_RDDATA_1(I);
    end loop;
    -- Correction ? (done at end of line)
    if CORRECT_WRREQ_1 = '1' then
      RAM_WRREQ_1(0)  <= '1';
      RAM_WRDATA_1(0) <= CORRECT_WRDATA_1;
    end if;
  end process;
    

  -- -----------------------------------------------------
  --  MATRIX_SIZE Lines Buffering 
  -- -----------------------------------------------------
  RAM_LINES_GEN_0 : for I in 0 to MATRIX_SIZE-1 generate
    i_BUFFER_LINES_0 : entity WORK.DPRAM_GENERIC_DC
      generic map (
        ADDR_WIDTH => RAM_ADDR_WIDTH,  
        DATA_WIDTH => RAM_DATA_WIDTH,  
        BYPASS_RW  => false         ,  
        SIMPLE_DP  => false         ,  
        OUTPUT_REG => true             
      )
      port map (
        -- Port A - Write Only
        A_CLK    => CLK            ,
        A_WRREQ  => RAM_WRREQ_0(I)   ,
        A_ADDR   => std_logic_vector(RAM_WRADD_0),
        A_WRDATA => RAM_WRDATA_0(I)  ,
        A_RDDATA => open           ,
        -- Port B - Read Only 
        B_CLK    => CLK            ,
        B_WRREQ  => '0'            , 
        B_WRDATA => (others => '0'),
        B_ADDR   => std_logic_vector(RAM_RDADD_0),
        B_RDDATA => RAM_RDDATA_0(I)
      );
   end generate RAM_LINES_GEN_0;

  -- -----------------------------------------------------
  --  MATRIX_SIZE Lines Buffering 
  -- -----------------------------------------------------
  RAM_LINES_GEN_1 : for I in 0 to MATRIX_SIZE-1 generate
    i_BUFFER_LINES_1 : entity WORK.DPRAM_GENERIC_DC
      generic map (
        ADDR_WIDTH => RAM_ADDR_WIDTH,  
        DATA_WIDTH => RAM_DATA_WIDTH,  
        BYPASS_RW  => false         ,  
        SIMPLE_DP  => false         ,  
        OUTPUT_REG => true             
      )
      port map (
        -- Port A - Write Only
        A_CLK    => CLK            ,
        A_WRREQ  => RAM_WRREQ_1(I)   ,
        A_ADDR   => std_logic_vector(RAM_WRADD_1),
        A_WRDATA => RAM_WRDATA_1(I)  ,
        A_RDDATA => open           ,
        -- Port B - Read Only 
        B_CLK    => CLK            ,
        B_WRREQ  => '0'            , 
        B_WRDATA => (others => '0'),
        B_ADDR   => std_logic_vector(RAM_RDADD_1),
        B_RDDATA => RAM_RDDATA_1(I)
      );
   end generate RAM_LINES_GEN_1;
  
  -- Algorithm Data Inputs
  oNEW_PIX <= RAM_WRREQ_0(0) when mem_rd_no = '0' and RAM_WRFSM /= s_CORRECT else 
              RAM_WRREQ_1(0) when mem_rd_no = '1' and RAM_WRFSM /= s_CORRECT else 
              '0';
  process(RAM_RDDATA_0, RAM_RDDATA_1, mem_rd_no)
  begin
    for I in 0 to MATRIX_SIZE-1 loop
      if mem_rd_no = '0' then
        oNEW_DATA(I) <= RAM_RDDATA_0(I);
      else
        oNEW_DATA(I) <= RAM_RDDATA_1(I);
      end if;
    end loop;
  end process;

  -- ---------------------------------------
  --  FIFO to store Corrected Data
  -- ---------------------------------------
  GEN_CORRECT_FIFO : if H_CORR_ON generate
  
    FIFO_CLR <= VIDEO_I_H;
    --
    FIFO_WR  <= CORRECT_DAV and not FIFO_FUL;
    FIFO_IN  <= std_logic_vector(VIDEO_O_XCNTi(PIX_BITS-1 downto 0)) & VIDEO_O_DATAi;
    --                            
    assert not ( FIFO_FUL = '1' and FIFO_WR = '1' )
    report "[BAD_PIX_REMOV] WRITE while FIFO Full !!!" severity failure;
    --
    i_BADP_FIFO : entity WORK.FIFO_GENERIC_SC
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
        
    FIFO_RD <= not FIFO_EMP when RAM_WRFSM = s_CORRECT else '0';
    
  end generate GEN_CORRECT_FIFO;
  
  -- -------------------------------------------------------
  --  Computing Bad Pixel Algorithm
  -- -------------------------------------------------------
  VIDEO_out_process : process(CLK, RST)
    variable vROW_SUM  : unsigned(D_BITS+MATRIX_SIZE-2 downto 0);
    variable vROW_CNT  : integer range 0 to MATRIX_SIZE;
  begin                            
    if RST = '1' then
      ALGO_ND       <= (others => '0');
      ALGO_XCNT     <= (others => '0');
      ALGO_PIXC     <= (others => (others => '0'));
      ALGO_AVRG     <= (others => '0'); 
      ROW_SUM       <= (others => (others => '0'));
      ROW_CNT       <= (others =>  0 );
      MAT_SUM       <= (others => '0');
      MAT_CNT       <=  0 ;
      CORRECT_DAV   <= '0';
      VIDEO_O_V     <= '0';
      VIDEO_O_H     <= '0';
      VIDEO_O_EOI   <= '0';
      VIDEO_O_DAVEN <= '0';
      VIDEO_O_DAVi  <= '0';
      VIDEO_O_DATAi <= (others => '0');
      VIDEO_O_XSIZi <= (others => '0');
      VIDEO_O_XEND  <= '0';
      VIDEO_O_YSIZi <= (others => '0');
      VIDEO_O_XCNTi <= (others => '0');
      VIDEO_O_YCNTi <= (others => '0');
      mem_rd_no      <= '0';
      VIDEO_O_FSM   <= s_IDLE;
    elsif rising_edge(CLK) then
        
      -- Output Pïxels Counter
      if VIDEO_O_DAVi = '1' then
        VIDEO_O_XCNTi <= VIDEO_O_XCNTi + 1;  
      end if;

      -- Default Assignments
      CORRECT_DAV   <= '0';
      VIDEO_O_V     <= '0';
      VIDEO_O_H     <= '0';
      VIDEO_O_EOI   <= '0';
      VIDEO_O_DAVi  <= '0';
      VIDEO_O_XEND  <= '0';

      if VIDEO_I_V = '1' then
        VIDEO_O_XSIZi <= to_unsigned(VIDEO_XSIZE,VIDEO_O_XSIZi'length); -- Latch X Size
        VIDEO_O_YSIZi <= to_unsigned(VIDEO_YSIZE,VIDEO_O_YSIZi'length); -- Latch Y Size
      end if;
              
      case VIDEO_O_FSM is
  
        -- Wait for the New Frame Start 
        when s_IDLE =>
          if (VIDEO_I_H = '1' and unsigned(VIDEO_I_YCNT) = MATRIX_SIZE-1) then
            VIDEO_O_FSM <= s_START;    
          end if;

        when s_START =>
          VIDEO_O_V     <= '1';
          VIDEO_O_XCNTi <= (others => '0');
          VIDEO_O_YCNTi <= (others => '1'); -- so that the 1st line is numbered 0     
          VIDEO_O_FSM <= s_Y_FIRST; 

        when s_Y_FIRST =>
          ROW_SUM       <= (others => (others => '0'));
          ROW_CNT       <= (others =>  0 );
          ALGO_PIXC     <= (others => (others => '0'));
          ALGO_XCNT     <= (others => '0');
          VIDEO_O_XCNTi <= (others => '0');
          VIDEO_O_DAVEN <= '0';
          VIDEO_O_H     <= '1';
          VIDEO_O_YCNTi <= VIDEO_O_YCNTi + 1;
          VIDEO_O_FSM   <= s_X_ALGO;   
          ALGO_ND       <= (others => '0' );  
  
        -- When we start, it means we have the 1st video input line readable 
        -- in the o_NEW_DATA(1) signal line (o_NEW_DATA(0) is 0's, o_NEW_DATA(2) is the 2nd line) 
        when s_Y_NEW =>
          ROW_SUM       <= (others => (others => '0'));
          ROW_CNT       <= (others =>  0 );
          ALGO_PIXC     <= (others => (others => '0'));
          ALGO_XCNT     <= (others => '0');
          VIDEO_O_XCNTi <= (others => '0');
          VIDEO_O_DAVEN <= '0';
          if (VIDEO_I_H = '1' and unsigned(VIDEO_I_YCNT) >= MATRIX_SIZE-1) or EXTRA_H = '1' then
            VIDEO_O_H     <= '1';
            VIDEO_O_YCNTi <= VIDEO_O_YCNTi + 1;
            VIDEO_O_FSM   <= s_X_ALGO;       
            ALGO_ND       <= (others => '0' );     
          end if;

        -- Waits for the End of Computation for that line
        when s_X_ALGO =>
        
          -- Generating the Enable bits for the pipeline
          ALGO_ND <= ALGO_ND(ALGO_ND'high-1 downto 0) & oNEW_PIX;

          -- New Pixel from RAM
          if oNEW_PIX = '1' then
            -- Propagate "Center pixel"
            ALGO_PIXC(0) <= unsigned(oNEW_DATA(1)); 
            -- Compute the Sum of the not bad pixels for this new column (vertically) : result available when ALGO_ND(0) = '1'
            vROW_SUM := (others => '0'); 
            vROW_CNT := 0; 
            -- Add pixel ?
            for I in 0 to MATRIX_SIZE-1 loop
              if oNEW_DATA(I)(oNEW_DATA(I)'high) = '0' then -- Good Pixel
                vROW_SUM := vROW_SUM + unsigned(oNEW_DATA(I)(D_BITS-1 downto 0));
                vROW_CNT := vROW_CNT + 1;  -- Increase number of pixels used in the sum
              end if;     
            end loop;
            -- Set Sum for each Row
            ROW_SUM(MATRIX_SIZE-1) <= vROW_SUM;
            -- Set Nuber of Valid Pixels for each Row
            ROW_CNT(MATRIX_SIZE-1) <= vROW_CNT;          
            -- Shift previous Results
            for I in 1 to MATRIX_SIZE-1 loop
              ROW_SUM(I-1) <= ROW_SUM(I);
              ROW_CNT(I-1) <= ROW_CNT(I);
            end loop; 
          end if;
          
          -- ALGO_INx have the values now : Computes Y Row Sum (ROW_SUM) + Y Row Valid Pixels (ROW_CNT)
          if ALGO_ND(0) = '1' then          
            ALGO_PIXC(1) <= ALGO_PIXC(0);
            -- Compute the Total Sum 
            MAT_SUM <= resize(ROW_SUM(0),MAT_SUM'length) + ROW_SUM(1) + ROW_SUM(2);
            -- Compute the Total Number of Valid Pixels 
            MAT_CNT <= ROW_CNT(0) + ROW_CNT(1) + ROW_CNT(2); 
          end if;  
          
          -- Now we have the Total Sum of neighboorhood (MAT_SUM) and the number of Valid pixels (MAT_CNT) 
          if ALGO_ND(1) = '1' then
            ALGO_PIXC(2) <= ALGO_PIXC(1); 
            MAT_SUM2 <= MAT_SUM;
            MAT_CNT2 <= MAT_CNT;                                                                                             
            case MAT_CNT is                                                                                                           
              when 8 => multiplier <= "000100000000000000";                              -- (2^17) / 8                            
              when 7 => multiplier <= "000100100100100100";                              -- (2^17) / 7
              when 6 => multiplier <= "000101010101010101";                              -- (2^17) / 6
              when 5 => multiplier <= "000110011001100110";                              -- (2^17) / 5
              when 4 => multiplier <= "001000000000000000";                              -- (2^17) / 4
              when 3 => multiplier <= "001010101010101010";                              -- (2^17) / 3
              when 2 => multiplier <= "010000000000000000";                              -- (2^17) / 2
              when 1 => multiplier <= "100000000000000000";                              -- (2^17) / 1
              when others => null;
            end case; 
          end if;
          
          -- Now we have the Total Sum of neighboorhood (MAT_SUM) and the number of Valid pixels (MAT_CNT) 
          if ALGO_ND(2) = '1' then
            ALGO_PIXC(3) <= ALGO_PIXC(2);   
            if ENABLE = '1' and ALGO_PIXC(3)(ALGO_PIXC(3)'high) = '1' then               -- Do the following multiplication only if Bad Pixel needs to be replaced
              ALGO_AVRG <= resize(shift_right((MAT_SUM2 * multiplier), 17), ALGO_AVRG'length);                      -- MAT_SUM / MAT_CNT
            end if;
          end if;
          
          -- Now we have the Avrg and the Bad Pixel Info
          if ALGO_ND(3) = '1' then
            ALGO_PIXC(4) <= ALGO_PIXC(3);
            if ALGO_XCNT >= 0 then
              VIDEO_O_DAVEN <= '1';
            else
              ALGO_XCNT <= ALGO_XCNT + 1;
            end if;
            VIDEO_O_DAVi <= VIDEO_O_DAVEN;
            if ENABLE = '0' then
              VIDEO_O_DATAi <= std_logic_vector(ALGO_PIXC(4)(D_BITS-1 downto 0));
            elsif ALGO_PIXC(4)(ALGO_PIXC(4)'high) = '0' then -- Good Pixel
              VIDEO_O_DATAi <= std_logic_vector(ALGO_PIXC(4)(D_BITS-1 downto 0));
            else
              -- Output Corrected Pixel !
              VIDEO_O_DATAi <= std_logic_vector(ALGO_AVRG);
              -- Store it in the FIFO that containts Bad Pixel Corrections to do
              CORRECT_DAV   <= '1';
            end if;
          end if;
        
          -- End of Horizontal Computation ?
          if VIDEO_O_XCNTi = VIDEO_O_XSIZi then
            VIDEO_O_XEND <= '1';
            -- End of Vertical Computation ?
            if VIDEO_O_YCNTi = VIDEO_O_YSIZi-1 then
              VIDEO_O_EOI <= '1';
              VIDEO_O_FSM <= s_IDLE;
              mem_rd_no <= not mem_rd_no;
            else
              VIDEO_O_FSM <= s_Y_NEW;              
            end if;
          end if;

      end case;

      if (VIDEO_I_H = '1' and unsigned(VIDEO_I_YCNT) = MATRIX_SIZE-1) then
        VIDEO_O_FSM <= s_START;    
      end if;
      
    end if;
  end process VIDEO_out_process;

  -- -----------------------------
  --  Video Outputs
  -- -----------------------------
  VIDEO_O_DAV   <= VIDEO_O_DAVi;
  VIDEO_O_DATA  <= VIDEO_O_DATAi;
  --VIDEO_XSIZE <= std_logic_vector(VIDEO_O_XSIZi);
  --VIDEO_YSIZE <= std_logic_vector(VIDEO_O_YSIZi);
  --VIDEO_XSIZE <= to_integer(VIDEO_O_XSIZi);
  --VIDEO_YSIZE <=  to_integer(VIDEO_O_YSIZi);
  VIDEO_O_XCNT  <= std_logic_vector(VIDEO_O_XCNTi);
  VIDEO_O_YCNT  <= std_logic_vector(VIDEO_O_YCNTi);



--probe0(0) <= VIDEO_I_V        ; 
--probe0(1) <= VIDEO_I_H        ; 
--probe0(2) <= VIDEO_I_EOI      ; 
--probe0(3) <= VIDEO_I_DAV      ; 
--probe0(17 downto 4) <= VIDEO_O_DATAi     ; 
--probe0(18) <= VIDEO_I_BAD      ; 
--probe0(19) <= VIDEO_O_DAVi     ; 
--probe0(33 downto 20) <= VIDEO_I_DATA    ; 
----probe0(34) <= VIDEO_I_DAVr     ; 
--probe0(34) <= VIDEO_I_DAVrr    ; 
--probe0(37 downto 35) <= std_logic_vector(to_unsigned(VIDEO_O_FSM_t'POS(VIDEO_O_FSM), 3));
--probe0(38) <= FIFO_CLR         ; 
--probe0(39) <= FIFO_WR          ; 
--probe0(40) <= FIFO_FUL         ; 
----probe0(0) <= FIFO_NB          ; 
--probe0(41) <= FIFO_EMP         ; 
--probe0(42) <= FIFO_RD          ; 
--probe0(43) <= switch_mem_wr_no ; 
--probe0(44) <= VIDEO_O_XEND     ; 
--probe0(45) <= oNEW_PIX         ; 
--probe0(46) <= EXTRA_LIN        ; 
--probe0(47) <= LAST_LINE        ; 
--probe0(48) <= EXTRA_DAVr       ; 
----probe0(49 downto 36) <= VIDEO_I_DATAr    ; 
--probe0(63 downto 49) <= VIDEO_I_DATArr   ; 
--probe0(73 downto 64) <= std_logic_vector(VIDEO_O_XCNTi);--VIDEO_I_XCNT     ; 
--probe0(83 downto 74) <= std_logic_vector(VIDEO_O_YCNTi);--VIDEO_I_YCNT     ; 
--probe0(98 downto 84) <= std_logic_vector(ALGO_PIXC(4)); 
--probe0(99) <= FIRST_LINE       ; 
--probe0(100) <= mem_wr_no        ; 
--probe0(101) <= RAM_WREN_0       ; 
--probe0(111 downto 102) <= std_logic_vector(RAM_WRADD_0); 
----probe0(118 downto 109)<= std_logic_vector(RAM_WRLIN_0); 
----probe0(118 downto 112) <= (others=>'0');
--probe0(112) <= RAM_WREN_1       ; 
--probe0(122 downto 113) <= std_logic_vector(RAM_WRADD_1); 
----probe0(138 downto 130) <= std_logic_vector(RAM_WRLIN_1); 
----probe0(138 downto 130) <=(others=>'0');
----probe0(123) <= DAV_EOL          ; 
----probe0(124) <= DAV_EOLr         ; 
----probe0(125) <= DAV_EOLrr        ; 
--probe0(132 downto 123) <= std_logic_vector(RAM_RDADD_0 ); 
--probe0(147 downto 133) <= RAM_WRDATA_0(0); 
--probe0(157 downto 148) <= std_logic_vector(RAM_RDADD_1); 
--probe0(172 downto 158) <= RAM_WRDATA_1(0); 
----probe0(166) <= EXTRA_H          ; 
----probe0(167) <= EXTRA_DAV        ; 
----probe0(193 downto 184) <=(others=>'0');
----probe0(195) <= CORRECT_WRREQ_0  ; 
----probe0(201 downto 196) <= CORRECT_WRDATA_0 ; 
----probe0(202) <= CORRECT_WRREQ_1  ; 
----probe0(218 downto 203) <= CORRECT_WRDATA_1 ; 
----probe0(168) <= ENABLE           ; 
----probe0(0) <= ALGO_AVRG        ; 
--probe0(173) <= VIDEO_O_DAVEN    ; 
--probe0(177 downto 174) <= std_logic_vector(ALGO_ND)            ; 
--probe0(180 downto 178) <= std_logic_vector(to_unsigned(RAM_WRFSM_t'POS(RAM_WRFSM), 3)); 
--probe0(195 downto 181) <= oNEW_DATA(1); 
--probe0(219 downto 196) <= FIFO_IN          ; 
--probe0(240 downto 220) <=  (others=>'0')  ; 
----probe0(280 downto 278) <= ;     
----probe0(0) <= ROW_CNT          ; 
----probe0(0) <= ROW_SUM          ; 
----probe0(0) <= ALGO_PIXC        ; 
----probe0(0) <= MAT_SUM          ; 
----probe0(0) <= MAT_CNT          ; 
----probe0(0) <= MAT_SUM2         ; 
----probe0(0) <= MAT_CNT2         ; 
----probe0(0) <= multiplier       ; 
----probe0(0) <= ALGO_ND          ; 

----probe0(0) <= ALGO_XCNT        ; 

--i_TOII_TUVE_ila: TOII_TUVE_ila
--PORT MAP (
--	clk => CLK,
--	probe0 => probe0
--);

  
-----------------------------
end architecture RTL;
-----------------------------

