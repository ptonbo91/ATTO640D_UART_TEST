library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.THERMAL_CAM_PACK.all;
Library xpm;
use xpm.vcomponents.all;
use ieee.numeric_std;

entity NUC1pt is
GENERIC(
  bit_width       : integer   := 14;
  DataWidth       : integer   := 14;
  FIFO_DEPTH      : integer   := 10;
  FIFO_WIDTH      : integer   := 14;
  VIDEO_XSIZE     : integer   := 640;
  VIDEO_YSIZE     : integer   := 512;
  PIX_BITS        : integer   := 10;
  LIN_BITS        : integer   := 10;
  DMA_ADDR_BITS   : positive  := 32;
  DMA_SIZE_BITS   : positive  := 5;
  DMA_DATA_BITS   : positive  := 32;
  capture_frames_1  : integer   := 5;   -- 2**capture_frames is the number of total images captured
  GAIN_DIV_W      : positive := 28

  );

PORT(
  -- Clock and Asynchronous Reset
  CLK                 : in STD_LOGIC;
  RST                 : in STD_LOGIC;
  ENABLE_NUC1pCalib   : in  std_logic; 
  --enable_filter       : in std_logic;
  gain_enable         : in std_logic;
  start_gain_calc     : in std_logic;
  select_gain_addr    : in std_logic;
  done_gain_calc      : out std_logic;
--  sel_high_low        : in std_logic;
  sel_temp_range      : in std_logic_vector(1 downto 0);
  GAIN_TABLE_SEL      : in std_logic;                      -- select gain table
  capture_frames      : in STD_LOGIC_VECTOR (3 downto 0) ; -- 2**capture_frames is the number of total images captured
  cold_img_sum        : in STD_LOGIC_VECTOR (63 downto 0) ;
  hot_img_sum         : in STD_LOGIC_VECTOR (63 downto 0) ;
  bpc_th              : in std_logic_vector(15 downto 0);
  -- Input and Output Ports
  VIDEO_I_V     : in STD_LOGIC;
  VIDEO_I_H     : in STD_LOGIC;
  VIDEO_I_EOI   : in STD_LOGIC;
  VIDEO_I_DAV   : in STD_LOGIC;
  VIDEO_I_DATA  : in STD_LOGIC_VECTOR (bit_width-1 downto 0);

--  VIDEO_O_V     : out STD_LOGIC;
--  VIDEO_O_H     : out STD_LOGIC;
--  VIDEO_O_EOI   : out STD_LOGIC;
--  VIDEO_O_DAV   : out STD_LOGIC;
--  VIDEO_O_DATA  : out STD_LOGIC_VECTOR (bit_width-1 downto 0);

  DMA0_WRREADY : in   std_logic;              --- write port
  DMA0_WRREQ   : out  std_logic;
  DMA0_WRADDR  : out  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
  DMA0_WRSIZE  : out  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
  DMA0_WRDATA  : out  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
  DMA0_WRBE    : out  std_logic_vector(DMA_DATA_BITS/8-1 downto 0);
  DMA0_WRBURST : OUT STD_LOGIC;

  done_offset : OUT std_logic;

  DMA1_RDREQ   : out   std_logic;             -- read port
  DMA1_RDADDR  : out  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
  DMA1_RDSIZE  : out  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
  DMA1_RDREADY : in  std_logic;
  DMA1_RDDAV   : in   std_logic;
  DMA1_RDDATA  : in   std_logic_vector(DMA_DATA_BITS  -1 downto 0);
  
--  NUC_DEBUG    : out  std_logic_vector(31 downto 0);

--  count_temp : out std_logic_vector (31 downto 0);
--  MAX_PIXELS_Temp : out std_logic_vector (19 downto 0);
--  frame_counter_temp : out std_logic_vector(31 downto 0);
--  DMA_SRCDAV_Temp : out std_logic;
--  USEDW_0_temp : out std_logic_vector(9 downto 0);
--  USEDW_1_temp : out std_logic_vector(9 downto 0);
 
  offset_img_avg: out std_logic_vector(15 downto 0) 
);
end entity NUC1pt;

architecture RTL of NUC1pt is

--COMPONENT TOII_TUVE_ila

--PORT (
--	clk : IN STD_LOGIC;



--	probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
--);
--END COMPONENT;


--signal VIDEO_I_XCNT   :  STD_LOGIC_VECTOR (9 downto 0);
--signal VIDEO_I_YCNT   :  STD_LOGIC_VECTOR (9 downto 0);
--signal VIDEO_O_XCNT   :  STD_LOGIC_VECTOR (9 downto 0);
--signal VIDEO_O_YCNT   :  STD_LOGIC_VECTOR (9 downto 0);

--type VIDEO_NUC_FSM_t is (s_IDLE,s_WAIT_FRAME,s_FIRST_FRAME,s_INT_FRAME,s_AVG,s_DIV1,s_DIV2,s_SET_GAINADDR,s_READ_GAIN,s_SET_SADDR,s_READ_SVAL,s_WAITOFFSET,s_WRITEOFFSET1,s_WRITEOFFSET2,s_WRITEOFFSET3);--,s_WRITEOFFSET3,s_WRITEOFFSET4);
--signal VIDEO_NUC_FSM   : VIDEO_NUC_FSM_t;

--type VIDEO_NUC_FSM_t is (s_IDLE,s_WAIT_FRAME,s_WAIT_FRAME1,s_FIRST_FRAME,s_INT_FRAME,s_DIV1,s_DIV2,s_SET_GAINADDR,s_READ_GAIN,s_SET_SADDR,s_READ_SVAL,s_WAITOFFSET,s_WRITEOFFSET1,s_WRITEOFFSET2,s_WRITEOFFSET3,
--                         s_COLD_IMG_AVG_CAL,s_WAIT_COLD_IMG_AVG_CAL,s_HOT_IMG_AVG_CAL,s_WAIT_HOT_IMG_AVG_CAL,s_WAIT_FRAME_GAIN,s_SET_GAINADDR_COOL,s_READ_GAIN_COOL,s_SET_GAINADDR_HOT,s_READ_GAIN_HOT,s_WAITGAIN_HOT,s_CALCGAIN,s_WRITEGAIN);--,s_WRITEOFFSET3,s_WRITEOFFSET4);
--signal VIDEO_NUC_FSM   : VIDEO_NUC_FSM_t;


type VIDEO_NUC_FSM_t is (s_IDLE,s_WAIT_FRAME,s_WAIT_FRAME1,s_FIRST_FRAME,s_INT_FRAME,s_DIV1,s_DIV2,s_WRITE_OFFSET_IMG_AVG,s_WRITE_OFFSET_IMG_AVG_WAIT,
                         s_COLD_IMG_AVG_CAL,s_WAIT_COLD_IMG_AVG_CAL,s_HOT_IMG_AVG_CAL,s_WAIT_HOT_IMG_AVG_CAL,s_WAIT_FRAME_GAIN,s_SET_GAINADDR_COOL,s_READ_GAIN_COOL,s_SET_GAINADDR_HOT,s_READ_GAIN_HOT,s_WAITGAIN_HOT,s_CALCGAIN,s_WRITEGAIN);--,s_WRITEOFFSET3,s_WRITEOFFSET4);
signal VIDEO_NUC_FSM   : VIDEO_NUC_FSM_t;

-------------------------------------------------
--  Line FIFO 0 Control, Data and Status Signals
-------------------------------------------------
signal WRREQ_0  : STD_LOGIC;
--signal WRDATA_0 : STD_LOGIC_VECTOR (DataWidth-1 downto 0);
signal WRDATA_0 : STD_LOGIC_VECTOR (31 downto 0);
signal RDREQ_0  : STD_LOGIC;
--signal RDDATA_0 : STD_LOGIC_VECTOR (DataWidth-1 downto 0);
signal RDDATA_0 : STD_LOGIC_VECTOR (31 downto 0);
signal USEDW_0  : STD_LOGIC_VECTOR(9 downto 0);
signal FULL_0   : STD_LOGIC;
signal EMPTY_0  : STD_LOGIC;

-------------------------------------------------
--  Line FIFO 1 Control, Data and Status Signals
-------------------------------------------------
signal WRREQ_1  : STD_LOGIC;
signal WRDATA_1 : STD_LOGIC_VECTOR (31 downto 0);
signal RDREQ_1  : STD_LOGIC;
signal RDDATA_1 : STD_LOGIC_VECTOR (31 downto 0);
signal USEDW_1  : STD_LOGIC_VECTOR(9 downto 0);
signal FULL_1   : STD_LOGIC;
signal EMPTY_1  : STD_LOGIC;

-------------------------------------------------
--  Line FIFO 2 Control, Data and Status Signals
-------------------------------------------------
signal WRREQ_2  : STD_LOGIC;
signal WRDATA_2 : STD_LOGIC_VECTOR (31 downto 0);
signal RDREQ_2  : STD_LOGIC;
signal RDDATA_2 : STD_LOGIC_VECTOR (31 downto 0);
signal USEDW_2  : STD_LOGIC_VECTOR(4 downto 0);
signal FULL_2   : STD_LOGIC;
signal EMPTY_2  : STD_LOGIC;

-------------------------------------------------
--  Line FIFO 3 Control, Data and Status Signals
-------------------------------------------------
signal WRREQ_3  : STD_LOGIC;
signal WRDATA_3 : STD_LOGIC_VECTOR (31 downto 0);
signal RDREQ_3  : STD_LOGIC;
signal RDDATA_3 : STD_LOGIC_VECTOR (31 downto 0);
signal USEDW_3  : STD_LOGIC_VECTOR(4 downto 0);
signal FULL_3   : STD_LOGIC;
signal EMPTY_3  : STD_LOGIC;


-------------------------------------------------
--Enable signals
--------------------------------------------------
signal enable_validframe : std_logic;
--------------------------------------------------
--DMA_Write signals
signal DMA_SRCV          : std_logic;
signal DMA_SRCH          : std_logic;
signal DMA_SRCEOI        : std_logic;
signal DMA_SRCDAV        : std_logic;
signal DMA_SRCDAV_d      : std_logic;
signal DMA_SRCDATA       : std_logic_vector(31 downto 0);
signal DMA_SRCXSIZE      : std_logic_vector(9 downto 0);
signal DMA_SRCYSIZE      : std_logic_vector(9 downto 0);
-------------------------------------------------------------------
signal MEM_IMG_SOI_1        :std_logic; -- Not used in Memory to scaler
signal MEM_IMG_BUF          :std_logic_vector(1 downto 0);
signal MEM_IMG_XSIZE_1      :std_logic_vector(9 downto 0);
signal MEM_IMG_YSIZE_1      :std_logic_vector(9 downto 0);
-------------------------------------------------------------------
signal frame_counter    : integer := 0;
signal gain_counter     : integer := 0;
signal s_counter        : integer := 0 ;
signal VIDEO_I_DAVr     : std_logic; 
signal VIDEO_I_DAVrr    : std_logic;
signal VIDEO_I_DATAr    : std_logic_vector(15 downto 0);
signal VIDEO_I_EOIr     : std_logic;
signal VIDEO_I_Hr       : std_logic;
--signal VIDEO_I_DATA_l0  : std_logic_vector(bit_width-1 downto 0);
--signal VIDEO_I_DATA_l0_d: std_logic_vector(bit_width-1 downto 0);
--signal VIDEO_I_DATA_l1  : std_logic_vector(31 downto 0);
--signal VIDEO_I_DATA_l1_d: std_logic_vector(31 downto 0);
--signal add_frames       : std_logic_vector(31 downto 0);

--signal VIDEO_DATAcal    : std_logic_vector(31 downto 0);
signal VIDEO_UNFILTERED    : std_logic_vector(13 downto 0);
signal VIDEO_UNFILTERED1    : std_logic_vector(13 downto 0);
signal VIDEO_UNFILTERED_dav   : std_logic;
signal VIDEO_UNFILTERED_dav_d   : std_logic;
--signal VIDEO_O_DATAi : std_logic_vector(bit_width-1 downto 0);
--signal VIDEO_O_DAVi :std_logic;

--Blurring filter signals

--signal VIDEO_I_FILT_V      : std_logic;
--signal VIDEO_I_FILT_H      : std_logic;
--signal VIDEO_I_FILT_EOI    : STD_LOGIC;
--signal VIDEO_I_FILT_DAV    : STD_LOGIC;
--signal VIDEO_I_FILT_DATA   : std_logic_vector(13 downto 0);


--signal VIDEO_O_FILT_V      : std_logic;
--signal VIDEO_O_FILT_H      : std_logic;
--signal VIDEO_O_FILT_EOI    : STD_LOGIC;
--signal VIDEO_O_FILT_EOIr   : STD_LOGIC;
--signal VIDEO_O_FILT_DAV    : STD_LOGIC;
--signal VIDEO_O_FILT_DAVr   : STD_LOGIC;
--signal VIDEO_O_FILT_DATA   : std_logic_vector(bit_width-1 downto 0);
--signal VIDEO_O_FILT_DATAr  : std_logic_vector(bit_width-1 downto 0);

--signal AV_KERN_ADDR_1       : std_logic_vector (7 downto 0);
--signal AV_KERN_WR_1         : std_logic;
--signal AV_KERN_WRDATA_1     : std_logic_vector (7 downto 0);
--signal AV_KERN_WRDATA_1_TEMP: std_logic_vector (31 downto 0);

--signal validpix             : std_logic;
signal addframe_dav         : std_logic;
signal addframe_dav_d       : std_logic;
--signal addframe_dav_d2      : std_logic;
--signal video_addframe_DAVr  : std_logic;
  
--signal VIDEO_AVG_XCNT       : STD_LOGIC_VECTOR (9 downto 0);
--signal VIDEO_AVG_XCNTr      : STD_LOGIC_VECTOR (9 downto 0);
--signal VIDEO_AVG_YCNT       : STD_LOGIC_VECTOR (9 downto 0);
--signal VIDEO_AVG_YCNTr      : STD_LOGIC_VECTOR (9 downto 0);
--signal VIDEO_AVG_DAV        : std_logic;
--signal VIDEO_AVG_EOI        : std_logic;
--signal VIDEO_DATAavg        : std_logic_vector(bit_width-1 downto 0);


--memory to scaler signals
signal SCALER_REQ_V         : std_logic;
signal SCALER_REQ_H         : std_logic;

signal SCALER_REQ_XSIZE     : std_logic_vector(9 downto 0);
signal SCALER_REQ_YSIZE     : std_logic_vector(9 downto 0);
signal SCALER_V             : std_logic;
signal SCALER_H             : std_logic;
signal SCALER_EOI           : std_logic;
signal SCALER_DAV           : std_logic;
signal SCALER_DATA_1        : std_logic_vector(31 downto 0);
--signal SCALER_XSIZE         : std_logic_vector(PIX_BITS-1 downto 0);
--signal SCALER_YSIZE         : std_logic_vector(LIN_BITS-1 downto 0);
--signal SCALER_XCNT          : std_logic_vector(PIX_BITS-1 downto 0);
--signal SCALER_YCNT          : std_logic_vector(LIN_BITS-1 downto 0);
--signal SCALER_PIX_OFF_1     : std_logic_vector(PIX_BITS-1 downto 0) := (others => '0');  -- Scaler asking memory_to_scaler to start sending data from a particular pixel in the line
signal SCALER_FIFO_EMP      : STD_LOGIC;
signal SCALER_RUN           : std_logic;


signal DMA_RDREQ_0        : std_logic;
signal DMA_RDADDR_0       : std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_RDSIZE_0       : std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_RDREADY_0      : std_logic;
signal DMA_RDDAV_0        : std_logic;
signal DMA_RDDATA_0       : std_logic_vector(DMA_DATA_BITS  -1 downto 0);

signal DMA_RDREQ_1        : std_logic;
signal DMA_RDADDR_1       : std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_RDSIZE_1       : std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_RDREADY_1      : std_logic;
signal DMA_RDDAV_1        : std_logic;
signal DMA_RDDATA_1       : std_logic_vector(DMA_DATA_BITS  -1 downto 0);

signal video_eoi         : std_logic;
signal count             : integer := 0;

--subtype file_name_type is STRING(1 to 20) ;
--type string_array_type is array (1 to 1000)  of file_name_type;
--shared variable string_array: string_array_type;
--signal check : std_logic;

signal SRC_EOI: std_logic;
signal SRC_EOI_d: std_logic;
signal SRC_EOI_d2: std_logic;

signal AEMPTY_0, AEMPTY_1,AEMPTY_2,AEMPTY_3 : std_logic;

signal AFULL_0, AFULL_1: std_logic;

signal start_div : std_logic;
signal dvsr      : std_logic_vector(63 downto 0);
signal dvnd      : std_logic_vector(63 downto 0);
signal done_tick : STD_LOGIC;
signal quo       : STD_LOGIC_VECTOR(63 downto 0);
signal rmd       : STD_LOGIC_VECTOR(63 downto 0);


signal start_div1 : std_logic;
signal dvsr1      : std_logic_vector(GAIN_DIV_W -1 downto 0);
signal dvnd1      : std_logic_vector(GAIN_DIV_W -1 downto 0);
signal done_tick1 : std_logic;
signal quo1       : std_logic_vector(GAIN_DIV_W -1 downto 0);
signal rmd1       : std_logic_vector(GAIN_DIV_W -1 downto 0);


signal start_div2 : std_logic;
signal dvsr2      : std_logic_vector(GAIN_DIV_W -1 downto 0);
signal dvnd2      : std_logic_vector(GAIN_DIV_W -1 downto 0);
signal done_tick2 : std_logic;
signal quo2       : std_logic_vector(GAIN_DIV_W -1 downto 0);
signal rmd2       : std_logic_vector(GAIN_DIV_W -1 downto 0);

----signal offset_1         : std_logic_vector(15 downto 0);
----signal offset_2         : std_logic_vector(15 downto 0);
--signal Gain_value_1     : std_logic_vector(31 downto 0);
--signal Gain_value_1_d1  : std_logic_vector(31 downto 0);
--signal Gain_value_1_d2  : std_logic_vector(31 downto 0);
--signal Gain_value_1_d3  : std_logic_vector(31 downto 0);
--signal Gain_value_2     : std_logic_vector(31 downto 0);
--signal Gain_value_2_d1  : std_logic_vector(31 downto 0);
--signal Gain_value_2_d2  : std_logic_vector(31 downto 0); 
--signal Gain_value_2_d3  : std_logic_vector(31 downto 0);
--signal svalue_1         : std_logic_vector(31 downto 0);
--signal svalue_2         : std_logic_vector(31 downto 0);
--signal svalue_1_d1      : std_logic_vector(31 downto 0);

signal Average_FILT : STD_LOGIC_VECTOR(63 downto 0);
--signal DATA_SIZE     : positive;
--signal BPP           : positive;

--signal DMA1_RDADDR0  : unsigned(31 downto 0) := x"3000_0000";
--signal DMA1_RDADDR1  : unsigned(31 downto 0) := x"4000_0000"; 


signal DMA1_RDADDR0  : unsigned(31 downto 0) := unsigned (ADDR_OFFM_NUC1PT);
signal DMA1_RDADDR1  : unsigned(31 downto 0) := unsigned (ADDR_GAIN_BADPIX_A);
--signal DMA1_RDADDR1  : unsigned(31 downto 0) := unsigned (ADDR_GAIN_BADPIX_D);
 
signal MEM_ADDR : unsigned(31 downto 0) := unsigned (ADDR_OFFM_NUC1PT);

signal offset_counter :  integer := 0;
signal pixcounter :  integer := 0; 
signal offsetstate :  std_logic ;

--constant ADDR_VIDEO_BUF4 : unsigned(31 downto 0) := x"3000_0000"; 
signal done_gain_calc_1 : std_logic;
signal done_offset_1 : std_logic;
--signal offset_0 : std_logic_vector(15 downto 0) := (others => '0');
signal trigger :  std_logic;
signal enable_delayed : std_logic := '0';
signal enable_delayed_n : std_logic := '0';
signal enable_delayed_and : std_logic := '0';
signal FIFOCLR_0 : std_logic;
signal FIFOCLR_1 : std_logic;
signal FIFOCLR_2 : std_logic;
signal FIFOCLR_3 : std_logic;
--signal offset2_counter :  integer;
--signal davcounter : integer;
signal DMA_WRITEDONE : std_logic;
signal MAX_PIXELS : unsigned(19 downto 0);
--signal src_dav_temp :integer := 0;

signal temp_capture_frames : std_logic_vector(7 downto 0);
--signal init_capture_frames : std_logic_vector(7 downto 0);
--signal srcdav_cnt : unsigned (19 downto 0);
signal DMA_SRCDATA_Temp       : std_logic_vector(31 downto 0);
signal DMA_SRCDATA_write_en : std_logic;
--signal probe0 : std_logic_vector(127 downto 0);
--signal VIDEO_NUC_FSM_Temp1:std_logic_vector(4 downto 0);

--signal  DMA_SRCDATA1_Temp : std_logic_vector(15 downto 0);
--signal  DMA_SRCDATA2_Temp : std_logic_vector(15 downto 0);

signal avg_hot  : std_logic_vector(15 downto 0);
signal avg_cool : std_logic_vector(15 downto 0);
signal pix1_bad : std_logic;
signal pix2_bad : std_logic;

signal img_avg_cal_done: std_logic;

signal SEL_DMA_MUX :  std_logic;

signal first_two_pix      : std_logic;
signal FIRST_TWO_PIX_DATA : std_logic_vector(31 downto 0);

signal off_img_wrsdram_address       : std_logic_vector(DMA_ADDR_BITS  -1 downto 0); 
signal off_img_wrsdram_burstcount    : std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal off_img_wrsdram_write         : std_logic;
signal off_img_wrsdram_writeburst    : std_logic;
signal off_img_wrsdram_writedata     : std_logic_vector(DMA_DATA_BITS  -1 downto 0); 
signal off_img_wrsdram_waitrequest   : std_logic;

signal offset_img_avg_temp : std_logic_vector(15 downto 0) ;

signal DMA0_WRREADY_1 :   std_logic;              --- write port          
signal DMA0_WRREQ_1   :   std_logic;                                      
signal DMA0_WRADDR_1  :   std_logic_vector(DMA_ADDR_BITS  -1 downto 0);   
signal DMA0_WRSIZE_1  :   std_logic_vector(DMA_SIZE_BITS  -1 downto 0);   
signal DMA0_WRDATA_1  :   std_logic_vector(DMA_DATA_BITS  -1 downto 0);    
signal DMA0_WRBURST_1 :   STD_LOGIC;       

signal first_bad_pix  : std_logic;                                


--signal   VIDEO_NUC_FSM_Temp :std_logic_vector(4 downto 0);
--ATTRIBUTE MARK_DEBUG : string;
--ATTRIBUTE MARK_DEBUG of  frame_counter   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  Average_FILT   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_NUC_FSM_Temp1   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  DMA_SRCDATA1_Temp   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  DMA_SRCDATA2_Temp   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_UNFILTERED_dav   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_UNFILTERED_dav_d   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  FIFOCLR_0   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  FIFOCLR_1   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  SRC_EOI   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  SRC_EOI_d   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  SRC_EOI_d2   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  DMA_SRCEOI   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of gain_enable      : SIGNAL IS "TRUE";                              
--ATTRIBUTE MARK_DEBUG of start_gain_calc  : SIGNAL IS "TRUE";                          
--ATTRIBUTE MARK_DEBUG of select_gain_addr : SIGNAL IS "TRUE";                         
--ATTRIBUTE MARK_DEBUG of done_gain_calc_1 : SIGNAL IS "TRUE";                         
--ATTRIBUTE MARK_DEBUG of VIDEO_I_V        : SIGNAL IS "TRUE";                                
--ATTRIBUTE MARK_DEBUG of VIDEO_I_H        : SIGNAL IS "TRUE";                                
--ATTRIBUTE MARK_DEBUG of VIDEO_I_EOI      : SIGNAL IS "TRUE";                              
--ATTRIBUTE MARK_DEBUG of VIDEO_I_DAV      : SIGNAL IS "TRUE";                              
--ATTRIBUTE MARK_DEBUG of done_offset_1    : SIGNAL IS "TRUE";                            
--ATTRIBUTE MARK_DEBUG of ENABLE_NUC1pCalib: SIGNAL IS "TRUE";                                        
--ATTRIBUTE MARK_DEBUG of enable_validframe: SIGNAL IS "TRUE";                        
--ATTRIBUTE MARK_DEBUG of enable_delayed_and: SIGNAL IS "TRUE";                       
--ATTRIBUTE MARK_DEBUG of DMA0_WRREADY: SIGNAL IS "TRUE";                             
--ATTRIBUTE MARK_DEBUG of DMA1_RDDAV: SIGNAL IS "TRUE";                               
--ATTRIBUTE MARK_DEBUG of DMA1_RDREADY: SIGNAL IS "TRUE";                             
--ATTRIBUTE MARK_DEBUG of DMA_SRCDAV: SIGNAL IS "TRUE";                               
--ATTRIBUTE MARK_DEBUG of MAX_PIXELS: SIGNAL IS "TRUE";             
--ATTRIBUTE MARK_DEBUG of count: SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of SRC_EOI: SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of dvnd1: SIGNAL IS "TRUE";                                
--ATTRIBUTE MARK_DEBUG of dvnd2: SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of start_div1: SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of start_div2: SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of dvsr1: SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of done_tick1 : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of done_tick2 : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of avg_cool: SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of avg_hot: SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of GAIN_TABLE_SEL: SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of hot_img_sum : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of dvsr: SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of done_tick : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of cold_img_sum : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of start_div: SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of dvnd: SIGNAL IS "TRUE"; 

--------
begin
--------
--USEDW_0_temp <= USEDW_0;
--USEDW_1_temp <= USEDW_1;
--MAX_PIXELS_Temp  <= std_logic_vector(MAX_PIXELS);
----MAX_PIXELS_Temp <= Average_FILT(63 downto 44);
----MAX_PIXELS_Temp<=DMA_SRCDATA;
--frame_counter_temp <= std_logic_vector(to_unsigned (frame_counter,frame_counter_temp'length));
--count_temp         <= std_logic_vector (to_unsigned(count,count_temp'length));
----count_temp         <= std_logic_vector (to_unsigned(src_dav_temp,count_temp'length));
----count_temp <= std_logic_vector (to_unsigned(davcounter,count_temp'length));
----count_temp <=Average_FILT(44 downto 13);
--DMA_SRCDAV_Temp    <= DMA_SRCDAV;    
--VIDEO_NUC_FSM_Temp <= std_logic_vector(to_unsigned(VIDEO_NUC_FSM_t'POS(VIDEO_NUC_FSM), 5));     

--NUC_DEBUG <= VIDEO_NUC_FSM_Temp       &
--             done_offset_1            &
--             done_gain_calc_1         &
--             SCALER_DAV               &
--             RDREQ_0                  &
--             WRREQ_0                  &
--             RDREQ_1                  &
--             WRREQ_1                  &
--             done_tick                &
--             VIDEO_UNFILTERED_dav_d   &
--             VIDEO_UNFILTERED_dav     &
--             DMA0_WRREQ_1             &
--             DMA0_WRBURST_1           &
--             DMA0_WRREADY_1           &
--             DMA_RDREADY_0            &
--             DMA_RDREQ_0              &
--             DMA_RDDAV_0              &
--             SCALER_V                 &
--             SCALER_H                 &
--             SCALER_DAV               &
--             SCALER_EOI               &
--             SCALER_RUN               &
--             SCALER_REQ_V             &
--             SCALER_REQ_H             &
--             DMA_SRCV                 &
--             DMA_SRCH                 &
--             DMA_SRCEOI               &
--             DMA_SRCDAV ;


            
--VIDEO_NUC_FSM_Temp <=  "00000" when VIDEO_NUC_FSM = s_IDLE else
--                       "00001" when VIDEO_NUC_FSM = s_WAIT_FRAME else
--                       "00010" when VIDEO_NUC_FSM = s_WAIT_FRAME1 else
--                       "00011" when VIDEO_NUC_FSM = s_FIRST_FRAME else
--                       "00100" when VIDEO_NUC_FSM = s_INT_FRAME else
--                       --"00100" when VIDEO_NUC_FSM = s_AVG else
--                       "00101" when VIDEO_NUC_FSM = s_DIV1 else
--                       "00110" when VIDEO_NUC_FSM = s_DIV2 else
--                       "00111" when VIDEO_NUC_FSM = s_SET_GAINADDR else
--                       "01000" when VIDEO_NUC_FSM = s_READ_GAIN else
--                       "01001" when VIDEO_NUC_FSM = s_SET_SADDR else
--                       "01010" when VIDEO_NUC_FSM = s_READ_SVAL else
                                           
--                       "01011" when VIDEO_NUC_FSM = s_WAITOFFSET else
--                       "01100" when VIDEO_NUC_FSM = s_WRITEOFFSET1 else
--                       "01101" when VIDEO_NUC_FSM = s_WRITEOFFSET2 else
--                       "01110" when VIDEO_NUC_FSM = s_WRITEOFFSET3 else
                       
--                       "01111" when VIDEO_NUC_FSM = s_SET_GAINADDR_COOL else
--                       "10000" when VIDEO_NUC_FSM = s_READ_GAIN_COOL else
--                       "10001" when VIDEO_NUC_FSM = s_SET_GAINADDR_HOT else
--                       "10010" when VIDEO_NUC_FSM = s_READ_GAIN_HOT else
--                       "10011" when VIDEO_NUC_FSM = s_WAITGAIN_HOT else
--                       "10100" when VIDEO_NUC_FSM = s_CALCGAIN else
--                       "10101" when VIDEO_NUC_FSM = s_WRITEGAIN else
--                       "10110" when VIDEO_NUC_FSM = s_WAIT_FRAME_GAIN else
--                       "10111" when  VIDEO_NUC_FSM = s_COLD_IMG_AVG_CAL else
--                       "11000" when  VIDEO_NUC_FSM = s_WAIT_COLD_IMG_AVG_CAL  else
--                       "11001" when  VIDEO_NUC_FSM = s_HOT_IMG_AVG_CAL else
--                       "11010" when  VIDEO_NUC_FSM = s_WAIT_HOT_IMG_AVG_CAL else
--                       "11111";

        

    DMA0_WRREADY_1              <=   '0'                       when  SEL_DMA_MUX = '1' else  DMA0_WRREADY;
    off_img_wrsdram_waitrequest <= not DMA0_WRREADY            when  SEL_DMA_MUX = '1' else  '0' ;
    DMA0_WRREQ                  <= off_img_wrsdram_write       when  SEL_DMA_MUX = '1' else  DMA0_WRREQ_1  ;
    DMA0_WRADDR                 <= off_img_wrsdram_address     when  SEL_DMA_MUX = '1' else  DMA0_WRADDR_1 ;
    DMA0_WRSIZE                 <= off_img_wrsdram_burstcount  when  SEL_DMA_MUX = '1' else  DMA0_WRSIZE_1 ;
    DMA0_WRDATA                 <= off_img_wrsdram_writedata   when  SEL_DMA_MUX = '1' else  DMA0_WRDATA_1 ;
    DMA0_WRBURST                <= off_img_wrsdram_writeburst  when  SEL_DMA_MUX = '1' else  DMA0_WRBURST_1;

    DMA1_RDREQ   <=  DMA_RDREQ_0   when offsetstate = '0'  else DMA_RDREQ_1  ;          
    DMA1_RDADDR  <=  DMA_RDADDR_0  when offsetstate = '0'  else DMA_RDADDR_1 ;
    DMA1_RDSIZE  <=  DMA_RDSIZE_0  when offsetstate = '0'  else DMA_RDSIZE_1 ;

    DMA_RDREADY_0 <=  DMA1_RDREADY;-- when offsetstate = '0'  else '0';
    DMA_RDDAV_0   <=  DMA1_RDDAV;--   when offsetstate = '0'  else '0';
    DMA_RDDATA_0  <=  DMA1_RDDATA;--  when offsetstate = '0'  else (others => '0');
 
    DMA_RDREADY_1 <=  DMA1_RDREADY;-- when offsetstate = '1'  else '0';
    DMA_RDDAV_1   <=  DMA1_RDDAV;--   when offsetstate = '1'  else '0';
    DMA_RDDATA_1  <=  DMA1_RDDATA;--  when offsetstate = '1'  else (others => '0');


  enable_delayed_and <= ENABLE_NUC1pCalib and not enable_delayed;




  --process(CLK,RST)
  --begin
  --  if RST = '1' then
  --    frame_counter   <= 0;
  --  elsif rising_edge(CLK) then
  --    if VIDEO_I_V = '1' then
  --        frame_counter  <= frame_counter + 1;
  --    end if;
  --  end if;
  --end process;

  spatial_avg : process(CLK,RST)
  variable offset_1 : std_logic_vector(31 downto 0);
  variable offset_2 : std_logic_vector(31 downto 0);
--  variable offset_3 : std_logic_vector(31 downto 0);
--  variable offset_4 : std_logic_vector(31 downto 0);
--  variable offset_5 : std_logic_vector(31 downto 0);
  
  variable pix_diff1: std_logic_vector(GAIN_DIV_W -1 downto 0);
  variable pix_diff2: std_logic_vector(GAIN_DIV_W -1 downto 0);
  variable avg_diff : std_logic_vector(GAIN_DIV_W -1 downto 0);
  --variable VIDEO_UNFILTERED_Temp : std_logic_vector(31 downto 0);
  variable DMA_SRCDATA1 :std_logic_vector(15 downto 0);
  variable DMA_SRCDATA2 :std_logic_vector(15 downto 0);
  
   
  begin
  if RST = '1' then

      VIDEO_NUC_FSM       <= s_IDLE;
      enable_validframe   <= '0';   
      WRREQ_0             <= '0';
      RDREQ_0             <= '0';
      WRREQ_1             <= '0';
      RDREQ_1             <= '0';                               
      DMA_SRCV            <= '0'; 
      SCALER_REQ_V        <= '0';
      SCALER_REQ_H        <= '0';
--      validpix            <= '0';
      addframe_dav        <= '0'; 
      addframe_dav_d      <= '0'; 
--      addframe_dav_d2     <= '0';
--      VIDEO_AVG_EOI       <= '0';
      SRC_EOI             <= '0';
      count               <=  0;
--      add_frames     <= (others=>'0');
      RDREQ_1            <= '0'; 
   --   VIDEO_I_FILT_V     <= '0';
    --VIDEO_I_FILT_H     <= '0';
    --VIDEO_I_FILT_DAV   <= '0';
    --VIDEO_I_FILT_DATA  <= (others=>'0');
    --VIDEO_I_FILT_EOI   <= '0';
      Average_FILT       <= (others => '0');
      start_div          <= '0';
      start_div1         <= '0';
      start_div2         <= '0';
      dvsr               <= (others => '0');
      dvsr1              <= (others => '0');
      dvsr2              <= (others => '0');
      dvnd               <= (others => '0');
      dvnd1              <= (others => '0');
      dvnd2              <= (others => '0');  
      WRREQ_2             <= '0';
      WRREQ_3             <= '0';
      DMA_SRCDAV_d        <= '0';
      done_offset_1       <= '0';
      done_gain_calc_1    <= '0';
      VIDEO_UNFILTERED_dav <= '0';
      VIDEO_UNFILTERED_dav_d <= '0';
      enable_delayed      <= '0';
      pixcounter  <= 0;
      frame_counter <= 0;
      FIFOCLR_0 <= '0';
      FIFOCLR_1 <= '0';
--      davcounter <= 0;
      DMA1_RDADDR0 <= unsigned (ADDR_OFFM_NUC1PT);
      DMA1_RDADDR1 <= unsigned (ADDR_GAIN_BADPIX_A);
      --DMA1_RDADDR1 <= unsigned (ADDR_GAIN_BADPIX_D);
      MEM_ADDR     <= unsigned (ADDR_OFFM_NUC1PT);
      --srcdav_cnt <= (others => '0');
      gain_counter <= 0;
      offsetstate <= '0';
      s_counter   <= 0;
      DMA_RDREQ_1 <= '0';
      temp_capture_frames <= x"08";
--      init_capture_frames <= x"01";
      offset_img_avg <= (others => '0');
      DMA_SRCDATA_write_en <= '0';
      DMA_SRCDATA_temp  <= (others => '0');
      avg_hot <= (others => '0');
      avg_cool<= (others => '0');
      pix1_bad <= '0';
      pix2_bad <= '0';
      img_avg_cal_done <= '0';
      first_two_pix <= '0';
      FIRST_TWO_PIX_DATA <= (others => '0');     
      SEL_DMA_MUX        <= '0'; 
      off_img_wrsdram_address     <= (others => '0');     
      off_img_wrsdram_burstcount  <= (others => '0');     
      off_img_wrsdram_write       <= '0';     
      off_img_wrsdram_writeburst  <= '0';     
      off_img_wrsdram_writedata   <= (others => '0');    
      first_bad_pix               <= '0'; 
  elsif rising_edge(CLK) then
     
     if(done_tick = '1')then
        offset_img_avg       <= quo(15 downto 0);
        offset_img_avg_temp  <= quo(15 downto 0);
--        if gain_enable = '1' then
--            if select_gain_addr = '0'then
--                avg_cool  <= quo(15 downto 0);
--            else  
--                avg_hot  <= quo(15 downto 0);  
--            end if;
--        end if;    
     end if;
          
     WRREQ_0             <= '0';
     RDREQ_0             <= '0';  
     VIDEO_I_DAVr        <= VIDEO_I_DAV;
     VIDEO_I_DAVrr       <= VIDEO_I_DAVr;
     --VIDEO_I_DATAr       <= VIDEO_I_DATA;
     VIDEO_I_EOIr        <= VIDEO_I_EOI;
     VIDEO_I_Hr          <= VIDEO_I_H ;
     DMA_SRCV            <= '0'; 
     SCALER_REQ_V        <= '0';
     DMA_SRCXSIZE        <= std_logic_vector(to_unsigned(VIDEO_XSIZE/2,DMA_SRCXSIZE'length));
     DMA_SRCYSIZE        <= std_logic_vector(to_unsigned(VIDEO_YSIZE,DMA_SRCYSIZE'length));
--     validpix            <= '0';
     addframe_dav        <= '0'; 
--     VIDEO_AVG_EOI       <= '0';
     SRC_EOI             <= '0';
     SRC_EOI_d           <= '0';
     SRC_EOI_d2          <= '0'; 
     WRREQ_1             <= '0'; 
     RDREQ_1             <= '0';
     WRREQ_2             <= '0'; 
     RDREQ_2             <= '0';
     WRREQ_3             <= '0'; 
     RDREQ_3             <= '0';
     start_div           <= '0';
     start_div1          <= '0';
     start_div2          <= '0'; 
     addframe_dav_d      <= '0';
--     addframe_dav_d2     <= '0';
     --offsetstate         <= '0';
     DMA_SRCEOI          <= '0';
     VIDEO_UNFILTERED_dav <= '0';
     VIDEO_UNFILTERED_dav_d <= '0';
     done_offset_1        <= '0';
     done_gain_calc_1     <= '0';
     FIFOCLR_0 <= '0';
     FIFOCLR_1 <= '0';
     FIFOCLR_2 <= '0';
     FIFOCLR_3 <= '0';


    enable_delayed <=  ENABLE_NUC1pCalib;
    case capture_frames is
        when x"0" =>
            VIDEO_I_DATAr <= std_logic_vector(resize(unsigned(VIDEO_I_DATA(bit_width-1 downto 0)),VIDEO_I_DATAr'length)); 
        when x"1" =>
            VIDEO_I_DATAr <= std_logic_vector(resize(unsigned(VIDEO_I_DATA(bit_width-1 downto 1)),VIDEO_I_DATAr'length));
        when x"2" =>
            VIDEO_I_DATAr <= std_logic_vector(resize(unsigned(VIDEO_I_DATA(bit_width-1 downto 2)),VIDEO_I_DATAr'length)); 
        when x"3" =>
            VIDEO_I_DATAr <= std_logic_vector(resize(unsigned(VIDEO_I_DATA(bit_width-1 downto 3)),VIDEO_I_DATAr'length));
        when x"4" =>
            VIDEO_I_DATAr <= std_logic_vector(resize(unsigned(VIDEO_I_DATA(bit_width-1 downto 4)),VIDEO_I_DATAr'length)); 
        when x"5" =>
            VIDEO_I_DATAr <= std_logic_vector(resize(unsigned(VIDEO_I_DATA(bit_width-1 downto 5)),VIDEO_I_DATAr'length));
        when x"6" =>
            VIDEO_I_DATAr <= std_logic_vector(resize(unsigned(VIDEO_I_DATA(bit_width-1 downto 6)),VIDEO_I_DATAr'length)); 
        when others  =>
            VIDEO_I_DATAr <= std_logic_vector(resize(unsigned(VIDEO_I_DATA(bit_width-1 downto 6)),VIDEO_I_DATAr'length));      
    end case;
    
    --enable_delayed_n <= not enable_delayed;

    case VIDEO_NUC_FSM is

      when s_IDLE =>
        offsetstate <= '0';
        frame_counter <= 0;
--        davcounter <= 0;
        count <= 0;
        first_two_pix <= '0';
        SEL_DMA_MUX   <= '0';
--        DMA1_RDADDR0 <= unsigned (ADDR_OFFM_NUC1PT);
--        DMA1_RDADDR1 <= unsigned (ADDR_GAIN_BADPIX_A);
        if start_gain_calc = '1'then
          --VIDEO_NUC_FSM <= s_SET_GAINADDR_COOL;
          --VIDEO_NUC_FSM <= s_WAIT_FRAME_GAIN;
          VIDEO_NUC_FSM   <= s_COLD_IMG_AVG_CAL; 
          DMA_SRCDAV_d  <= '0';
          DMA1_RDADDR0 <= unsigned (ADDR_IMG_HOT); -- IMG HOT
          DMA1_RDADDR1 <= unsigned (ADDR_IMG_COLD); -- IMG COOL 
          MEM_ADDR     <= unsigned (ADDR_GAIN);
        elsif  enable_delayed_and = '1' then
          if gain_enable = '1' then
            if select_gain_addr = '0'then
                DMA1_RDADDR0 <= unsigned (ADDR_IMG_COLD);
                MEM_ADDR     <= unsigned (ADDR_IMG_COLD);
            else
                DMA1_RDADDR0 <= unsigned (ADDR_IMG_HOT);
                MEM_ADDR     <= unsigned (ADDR_IMG_HOT);
            end if;     
          else
            DMA1_RDADDR0 <= unsigned (ADDR_OFFM_NUC1PT);
            if(GAIN_TABLE_SEL = '1')then
              DMA1_RDADDR1 <= unsigned(ADDR_GAIN);
            elsif (sel_temp_range = "11")then
              DMA1_RDADDR1 <= unsigned(ADDR_GAIN_BADPIX_A);
            elsif (sel_temp_range = "10")then
              DMA1_RDADDR1 <= unsigned(ADDR_GAIN_BADPIX_A);     
            elsif (sel_temp_range = "01")then
              DMA1_RDADDR1 <= unsigned(ADDR_GAIN_BADPIX_A);
            else
              DMA1_RDADDR1 <= unsigned(ADDR_GAIN_BADPIX_A); 
            end if;              
--            elsif (sel_high_low = '1')then
--              DMA1_RDADDR1 <= unsigned(ADDR_GAIN_BADPIX_B);
--            else
--              DMA1_RDADDR1 <= unsigned(ADDR_GAIN_BADPIX_A); 
--            end if;
            --DMA1_RDADDR1 <= unsigned (ADDR_GAIN_BADPIX_A);
            --DMA1_RDADDR1 <= unsigned (ADDR_GAIN_BADPIX_D);
            MEM_ADDR     <= unsigned (ADDR_OFFM_NUC1PT);
          end if;
          Average_FILT <= (others => '0');
          DMA_SRCDAV_d  <= '0';
          VIDEO_NUC_FSM <= s_WAIT_FRAME; 
          
          if unsigned(capture_frames) = 0 then
            temp_capture_frames  <= x"01";
          elsif unsigned(capture_frames) = 1 then
            temp_capture_frames  <= x"02";  
          elsif unsigned(capture_frames) = 2 then
            temp_capture_frames  <= x"04";
          elsif unsigned(capture_frames) = 3 then
            temp_capture_frames  <= x"08";            
          elsif unsigned(capture_frames) = 4 then
            temp_capture_frames  <= x"10";                            
          elsif unsigned(capture_frames) = 5 then
            temp_capture_frames  <= x"20";               
          elsif unsigned(capture_frames) = 6 then
            temp_capture_frames  <= x"40";
          else   
            temp_capture_frames  <= x"40";     
          end if;
                                  
          
       --   if capture_frames < x"7" and capture_frames /= x"0" then
       --    temp_capture_frames <= to_stdlogicvector(to_bitvector(init_capture_frames) sll (to_integer(unsigned(capture_frames))));
       --   else
       --    temp_capture_frames <= x"40";
       --   end if;
        elsif ENABLE_NUC1pCalib = '0' then
          DMA_SRCDAV_d  <= '0';
          VIDEO_NUC_FSM <= s_IDLE;
          --done_offset_1 <= '1';
        end if;
        
      when s_COLD_IMG_AVG_CAL =>
        start_div <= '1';
        dvnd <= cold_img_sum;
        dvsr <= std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE,dvsr'length));
        VIDEO_NUC_FSM <= s_WAIT_COLD_IMG_AVG_CAL;
      
      when s_WAIT_COLD_IMG_AVG_CAL =>
        if(done_tick = '1')then
            avg_cool  <= quo(15 downto 0);
            VIDEO_NUC_FSM <= s_HOT_IMG_AVG_CAL;
        end if;    
      
      when s_HOT_IMG_AVG_CAL =>  
        start_div <= '1';
        dvnd <= hot_img_sum;
        dvsr <= std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE,dvsr'length));
        VIDEO_NUC_FSM <= s_WAIT_HOT_IMG_AVG_CAL;
          
      when s_WAIT_HOT_IMG_AVG_CAL =>
        if(done_tick = '1')then
          avg_hot  <= quo(15 downto 0);
          VIDEO_NUC_FSM <=  s_WAIT_FRAME_GAIN;
        end if;
      
      when  s_WAIT_FRAME_GAIN =>
        if VIDEO_I_V = '1'  then
            VIDEO_NUC_FSM <= s_SET_GAINADDR_COOL;
            DMA_SRCV <= '1'; 
            offsetstate <= '1';
            FIFOCLR_2 <= '1';
            FIFOCLR_3 <= '1';
            first_bad_pix  <= '1'; 
        else
            VIDEO_NUC_FSM <= s_WAIT_FRAME_GAIN;
        end if;   
         
      when s_WAIT_FRAME =>
         offsetstate <= '0';
         if VIDEO_I_V = '1'  then
            frame_counter <=  frame_counter + 1;
            enable_validframe <= '1';
        
          if frame_counter = 0 then
            if MAX_PIXELS = 0 then
                VIDEO_NUC_FSM <= s_FIRST_FRAME;
                DMA_SRCV <= '1';
            end if;    
          elsif frame_counter< to_integer(unsigned(temp_capture_frames))then
          --elsif frame_counter< 2**capture_frames_1 then
          --elsif frame_counter< 32 then
            --if MAX_PIXELS = 0 then
                VIDEO_NUC_FSM <= s_INT_FRAME;
                FIFOCLR_0 <= '1';
                FIFOCLR_1 <= '1';
                SCALER_REQ_V  <= '1'; 
                DMA_SRCV <= '1';
            --end if;
         elsif frame_counter >= to_integer(unsigned(temp_capture_frames)) then
         -- elsif frame_counter >=  2**capture_frames_1 then
         -- elsif frame_counter >= 32 then
            --if MAX_PIXELS = 0 then
                --SCALER_REQ_V  <= '1'; 
                --DMA_SRCV <= '1';
                --VIDEO_NUC_FSM <= s_AVG;
                
                VIDEO_NUC_FSM <= s_DIV1;
                --src_dav_temp <= 0;
            --end if;   
--            if MAX_PIXELS = 0 then
--            VIDEO_NUC_FSM <= s_IDLE;
--            done_offset_1 <= '1';
--            end if;
          end if;

        end if;
     
      when s_WAIT_FRAME1 =>
        if MAX_PIXELS = 0 then
            VIDEO_NUC_FSM <= s_WAIT_FRAME;
       end if;    
      
      
       

      when s_FIRST_FRAME =>

        offsetstate <= '0';
        DMA_SRCH     <= VIDEO_I_Hr;
        DMA_SRCEOI   <= VIDEO_I_EOIr;
        WRREQ_0      <= '0';
        RDREQ_0      <= '0';
    
        if  enable_validframe = '1' then
          
            --DMA_SRCDAV   <= VIDEO_I_DAVr;
           if(VIDEO_I_DAVr = '1') then
               
               DMA_SRCDATA_temp <= VIDEO_I_DATAr & DMA_SRCDATA_temp(31 downto 16);
               DMA_SRCDATA_write_en <= not DMA_SRCDATA_write_en;
               if(DMA_SRCDATA_write_en = '1')then
                   DMA_SRCDATA <= VIDEO_I_DATAr & DMA_SRCDATA_temp(31 downto 16);
                   DMA_SRCDAV  <= '1';       
               else 
                   DMA_SRCDAV  <= '0';
               end if;
               if(frame_counter = to_integer(unsigned(temp_capture_frames))) then
                   Average_FILT  <= std_logic_vector(unsigned(Average_FILT)+unsigned(VIDEO_I_DATAr));
                   if(first_two_pix = '0' and DMA_SRCDATA_write_en = '1')then
                       FIRST_TWO_PIX_DATA      <=  VIDEO_I_DATAr & DMA_SRCDATA_temp(31 downto 16);    
                       first_two_pix           <= '1';
                   end if;
               end if;   
               
            else 
               DMA_SRCDAV  <= '0';
            end if; 
     
             
--          if(VIDEO_I_DAVr = '1')then
--            srcdav_cnt   <= srcdav_cnt + 1;
--          end if;
        end if;
          --DMA_SRCDATA  <= std_logic_vector(resize(unsigned(VIDEO_I_DATAr),DMA_SRCDATA'length));
        if VIDEO_I_EOIr = '1' then
          enable_validframe <= '0';
        end if;
        if enable_validframe = '0'  then
                VIDEO_NUC_FSM <= s_WAIT_FRAME1;     
        end if;

     
      when s_INT_FRAME =>
            offsetstate      <= '0';
            addframe_dav_d   <= addframe_dav; 
--            addframe_dav_d2  <= addframe_dav_d; 
            VIDEO_UNFILTERED_dav_d<= VIDEO_UNFILTERED_dav;
            SRC_EOI_d        <= SRC_EOI;
            SRC_EOI_d2       <= SRC_EOI_d;
            
            if  enable_validframe = '1' then
               if(VIDEO_I_DAVr = '1') then
                   DMA_SRCDATA_temp <= VIDEO_I_DATAr & DMA_SRCDATA_temp(31 downto 16);
                   DMA_SRCDATA_write_en <= not DMA_SRCDATA_write_en;
                   if(DMA_SRCDATA_write_en = '1')then
                       WRDATA_0 <= VIDEO_I_DATAr & DMA_SRCDATA_temp(31 downto 16);
                       WRREQ_0  <= '1';       
                   else 
                       WRREQ_0  <= '0';
                   end if;
                else 
                   WRREQ_0  <= '0';
                end if; 
              
             
            end if;              
            --WRDATA_0         <= VIDEO_I_DATAr;
            --WRREQ_0          <= VIDEO_I_DAVr and enable_validframe;
            SCALER_REQ_H     <= VIDEO_I_Hr;
            SCALER_REQ_XSIZE <= std_logic_vector(to_unsigned(VIDEO_XSIZE/2,SCALER_REQ_XSIZE'length));
            SCALER_REQ_YSIZE <= std_logic_vector(to_unsigned(VIDEO_YSIZE,SCALER_REQ_YSIZE'length));
            WRREQ_1          <= SCALER_DAV;
            WRDATA_1         <= SCALER_DATA_1;
            --DMA_SRCDATA      <= std_logic_vector(resize(unsigned(RDDATA_0) + unsigned(RDDATA_1), DMA_SRCDATA'length));
            DMA_SRCDATA1 := std_logic_vector(unsigned(RDDATA_0(15 downto 0)) + unsigned(RDDATA_1(15 downto 0)));
            DMA_SRCDATA2 := std_logic_vector(unsigned(RDDATA_0(31 downto 16)) + unsigned(RDDATA_1(31 downto 16)));
            
            DMA_SRCDATA      <=  DMA_SRCDATA2 & DMA_SRCDATA1;

            if(frame_counter = to_integer(unsigned(temp_capture_frames))) then
                if VIDEO_UNFILTERED_dav_d = '1' then 
                    Average_FILT  <= std_logic_vector(unsigned(Average_FILT)+unsigned(DMA_SRCDATA1) + unsigned(DMA_SRCDATA2));
--                    DMA_SRCDATA1_Temp <= DMA_SRCDATA1;
--                    DMA_SRCDATA2_Temp <= DMA_SRCDATA2;
                    if(first_two_pix = '0')then
                        FIRST_TWO_PIX_DATA      <=  DMA_SRCDATA2 & DMA_SRCDATA1;    
                        first_two_pix           <= '1';
                    end if;

                 
                end if;
            end if;
            
--            if SCALER_DAV = '1' then
--              davcounter <= davcounter +1 ; 
--            end if;
            --if VIDEO_I_Hr = '1' then
              --davcounter <= 0;
            --end if;
            

            
            
            --if ((EMPTY_0='0' and AEMPTY_0='0') or (unsigned(USEDW_0) = to_unsigned(1,USEDW_0'length)  and WRREQ_0='0' and RDREQ_0='0')) and 
            --   ((EMPTY_1='0' and AEMPTY_1='0') or (unsigned(USEDW_1) = to_unsigned(1,USEDW_1'length) and WRREQ_1='0' and RDREQ_1='0')) and 
            --  count < VIDEO_XSIZE * VIDEO_YSIZE then
            if((unsigned(USEDW_0) >= to_unsigned(16,USEDW_0'length)) and (unsigned(USEDW_1) >= to_unsigned(16,USEDW_1'length))) or (count>= ((VIDEO_XSIZE * VIDEO_YSIZE)/2)-16)then
               RDREQ_0         <= '1';
               RDREQ_1         <= '1';
               addframe_dav <= '1'; 
               count  <= count + 1;
               --if davcounter =VIDEO_XSIZE * VIDEO_YSIZE then
               --  count <= 0;
               --end if; 
               if count = ((VIDEO_XSIZE * VIDEO_YSIZE)/2)-1 then
                SRC_EOI <='1';
                count <= 0; 
               end if;     
               VIDEO_UNFILTERED_dav <= '1';
            else
               RDREQ_0         <= '0';
               RDREQ_1         <= '0';
               addframe_dav    <= '0'; 
               VIDEO_UNFILTERED_dav <= '0';
            end if;

              --video_addframe_DAVr <= addframe_dav;
               DMA_SRCDAV   <= addframe_dav_d;
               DMA_SRCH     <=  SCALER_H;
               DMA_SRCXSIZE <= std_logic_vector(to_unsigned(VIDEO_XSIZE/2,DMA_SRCXSIZE'length));
               DMA_SRCYSIZE <= std_logic_vector(to_unsigned(VIDEO_YSIZE,DMA_SRCYSIZE'length)); 
               DMA_SRCEOI   <=  SRC_EOI_d2; 
            --writing back the added data into the memory
            
            if VIDEO_I_EOIr = '1' then
                enable_validframe <= '0';
            end if;
            


            if DMA_SRCEOI = '1' then              
                VIDEO_NUC_FSM <= s_WAIT_FRAME1;
--                davcounter <= 0;
            end if;
            
            
            

--      when s_AVG =>
--          offsetstate <= '0';
--          --fetch the data from the memory and divide each pixel value by capture_frames to get the average value(temporally)
--          -- generate x and y counts. Give those to blurring module as well as Scaler_H
--          if VIDEO_I_EOIr='1' then
--            enable_validframe <='0';
--          end if;

--          SCALER_REQ_H <= VIDEO_I_Hr and enable_validframe;
  
--          if  SCALER_DAV = '1' then
--            --VIDEO_UNFILTERED    <= SCALER_DATA_1(capture_frames_1+bit_width-1 downto capture_frames_1);
--           --VIDEO_UNFILTERED_Temp  := to_stdlogicvector(to_bitvector(SCALER_DATA_1) srl (to_integer(unsigned(capture_frames))));
--           --VIDEO_UNFILTERED       <= VIDEO_UNFILTERED_Temp(13 downto 0);
----           if unsigned(capture_frames) = 0 then
----              VIDEO_UNFILTERED  <= SCALER_DATA_1(1+bit_width-1 downto 1);
             
----           elsif unsigned(capture_frames) = 1 then
----             VIDEO_UNFILTERED  <= SCALER_DATA_1(1+bit_width-1 downto 1); 

----           elsif unsigned(capture_frames) = 2 then
----             VIDEO_UNFILTERED  <= SCALER_DATA_1(2+bit_width-1 downto 2);

----           elsif unsigned(capture_frames) = 3 then
----             VIDEO_UNFILTERED  <= SCALER_DATA_1(3+bit_width-1 downto 3);
         
----           elsif unsigned(capture_frames) = 4 then
----             VIDEO_UNFILTERED  <= SCALER_DATA_1(4+bit_width-1 downto 4);
                         
----           elsif unsigned(capture_frames) = 5 then
----             VIDEO_UNFILTERED  <= SCALER_DATA_1(5+bit_width-1 downto 5);
             
----           elsif unsigned(capture_frames) = 6 then
----             VIDEO_UNFILTERED  <= SCALER_DATA_1(6+bit_width-1 downto 6);

----           else   
----             VIDEO_UNFILTERED  <= SCALER_DATA_1(6+bit_width-1 downto 6);
  
----           end if;
--            VIDEO_UNFILTERED <= SCALER_DATA_1(13 downto 0);
--            VIDEO_UNFILTERED1 <= SCALER_DATA_1(29 downto 16);
--            --temp_capture_frames <= to_stdlogicvector(to_bitvector(init_capture_frames) sll (to_integer(unsigned(capture_frames))));
--            VIDEO_UNFILTERED_dav <= '1';
--            src_dav_temp <= src_dav_temp +1;
--          end if;


--          --DMA_SRCDATA  <= std_logic_vector(resize(unsigned(VIDEO_UNFILTERED), DMA_SRCDATA'length));
--          DMA_SRCDATA  <= "00"& VIDEO_UNFILTERED1 & "00" & VIDEO_UNFILTERED;
--          DMA_SRCDAV   <= VIDEO_UNFILTERED_dav;

                 
--        if VIDEO_UNFILTERED_dav = '1' then 
--          Average_FILT  <= std_logic_vector(unsigned(Average_FILT)+unsigned(VIDEO_UNFILTERED) + unsigned(VIDEO_UNFILTERED1));
--        end if;

--        if SCALER_EOI = '1' then
--          VIDEO_NUC_FSM <= s_DIV1;
--        end if;

      when s_DIV1 =>
     
      offsetstate <= '0';
         if MAX_PIXELS = 0 then
          start_div <= '1';
          dvnd <= Average_FILT;
          dvsr <= std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE,dvsr'length));
          --VIDEO_NUC_FSM <= s_DIV2;
--          if(gain_enable = '1') then
--            VIDEO_NUC_FSM <= s_idle;
--            done_offset_1 <= '1';
--          else  
--            VIDEO_NUC_FSM <= s_DIV2;
--          end if;
          VIDEO_NUC_FSM <= s_DIV2;
         else 
          VIDEO_NUC_FSM <= s_DIV1;
         end if;
--         if MAX_PIXELS = 0 then
--          VIDEO_NUC_FSM <= s_idle;
--           done_offset_1 <= '1';
--         else 
--            VIDEO_NUC_FSM <= s_DIV1;
--         end if;  
           
      when s_DIV2 =>
         offsetstate <= '0';
--         if done_tick = '1'  then
--           if(gain_enable = '1') then
--               VIDEO_NUC_FSM <= s_idle;
--               done_offset_1 <= '1';
--           else 
--               DMA_SRCV <= '1';  --- for writing offset back into the memory.
--              -- VIDEO_NUC_FSM <= s_IDLE;
--               offsetstate <= '1';
--               FIFOCLR_2 <= '1';
--               FIFOCLR_3 <= '1';
--               VIDEO_NUC_FSM <= s_SET_GAINADDR;
--               DMA_SRCXSIZE <= std_logic_vector(to_unsigned(VIDEO_XSIZE/2,DMA_SRCXSIZE'length));
--           end if;   
           if done_tick = '1'  then
              img_avg_cal_done <= '1';
              VIDEO_NUC_FSM    <= s_DIV2;
           end if; 
           
           if VIDEO_I_EOI = '1' and img_avg_cal_done = '1' then
            if(gain_enable = '1') then
               VIDEO_NUC_FSM <= s_idle;
               done_offset_1 <= '1';
            else
               VIDEO_NUC_FSM <= s_WRITE_OFFSET_IMG_AVG;
               SEL_DMA_MUX <= '1';
            end if;
               
               FIFOCLR_2 <= '1';
               FIFOCLR_3 <= '1';          
               img_avg_cal_done <= '0';
           end if;
           
     when s_WRITE_OFFSET_IMG_AVG =>
            off_img_wrsdram_address    <= ADDR_OFFM_NUC1PT;  
            off_img_wrsdram_burstcount <= std_logic_Vector(to_unsigned(1, off_img_wrsdram_burstcount'length));
            off_img_wrsdram_write      <= '1';
            off_img_wrsdram_writeburst <= '1';
            off_img_wrsdram_writedata  <= FIRST_TWO_PIX_DATA(31 downto 16)&  offset_img_avg_temp; 
            VIDEO_NUC_FSM              <= s_WRITE_OFFSET_IMG_AVG_WAIT;
     
     when s_WRITE_OFFSET_IMG_AVG_WAIT =>      
            if (off_img_wrsdram_waitrequest = '0') then 
              off_img_wrsdram_writeburst <= '0';
              off_img_wrsdram_writedata  <= (others=>'0') ;
              off_img_wrsdram_write      <= '0';
              VIDEO_NUC_FSM              <= s_idle;
              done_offset_1              <= '1';
            else
              VIDEO_NUC_FSM              <= s_WRITE_OFFSET_IMG_AVG_WAIT;
            end if;
            
             
                      
              
           
--         end if; 

--    when s_SET_GAINADDR =>

--         offsetstate <= '1';
--         DMA_SRCDAV <= '0';
--         pixcounter <= pixcounter + 1;
--         DMA_RDADDR_1  <= std_logic_vector(DMA1_RDADDR1) ;
--         DMA1_RDADDR1  <= DMA1_RDADDR1+32; --,DMA1_RDADDR'length);
--         DMA_RDSIZE_1  <=  std_logic_vector(to_unsigned(8, DMA_RDSIZE_1'length));
--         DMA_RDREQ_1   <= '1';  
--         gain_counter  <=  8;
--         if pixcounter < (VIDEO_XSIZE*VIDEO_YSIZE/16) then
--            VIDEO_NUC_FSM <= s_READ_GAIN;
--         else 
--             DMA_RDREQ_1   <= '0';
--             if MAX_PIXELS = 0 then
--                pixcounter <= 0;
--                VIDEO_NUC_FSM <= s_IDLE;
--                done_offset_1 <= '1';

--             end if;
--         end if;

--      when s_READ_GAIN =>
--          offsetstate <= '1';
--          WRREQ_2 <= '0';
--          if DMA_RDREADY_1 = '1' then -- Read Accepted
--            DMA_RDREQ_1    <= '0';
--          end if;
--          if DMA_RDDAV_1 = '1' and gain_counter > 0 then
--            WRREQ_2       <= '1';
--            WRDATA_2      <= DMA_RDDATA_1 ;
--            gain_counter  <= gain_counter - 1;
--            VIDEO_NUC_FSM <= s_READ_GAIN;
--          elsif gain_counter = 0 then
--            WRREQ_2 <= '0';
--            VIDEO_NUC_FSM <= s_SET_SADDR;
--          end if; 

--      when s_SET_SADDR =>
--          offsetstate   <= '1';
--          DMA_RDADDR_1   <= std_logic_vector(DMA1_RDADDR0); 
--          --DMA1_RDADDR0  <= DMA1_RDADDR0 + 64; --,DMA1_RDADDR'length);
--          DMA1_RDADDR0  <= DMA1_RDADDR0 + 32; --,DMA1_RDADDR'length);
--          --DMA_RDSIZE_1  <=  std_logic_vector(to_unsigned(16, DMA_RDSIZE_1'length));
--          DMA_RDSIZE_1  <=  std_logic_vector(to_unsigned(8, DMA_RDSIZE_1'length));
--          DMA_RDREQ_1   <= '1';
--          --s_counter     <=  16;
--          s_counter     <=  8;
--          VIDEO_NUC_FSM <= s_READ_SVAL;

--      when s_READ_SVAL =>
--        offsetstate <= '1';
--          -- WRREQ_3 <= '0'; -- shouldn't be there ??

--          if DMA_RDREADY_1 = '1' then -- Read Accepted
--            DMA_RDREQ_1    <= '0';
--          end if;
--          if DMA_RDDAV_1 = '1' and s_counter > 0 then 
--            WRREQ_3       <= '1';
--            WRDATA_3      <= DMA_RDDATA_1 ;
--            s_counter     <= s_counter - 1;
--            VIDEO_NUC_FSM <= s_READ_SVAL;
--          elsif s_counter = 0 then
--            WRREQ_3 <= '0';
--            offset_counter <= 8;
--            --offset_counter <= 8;
--            RDREQ_2       <= '1';
--            RDREQ_3       <= '1';
--            VIDEO_NUC_FSM <= s_WAITOFFSET;
--          end if; 

--      when s_WAITOFFSET => 
--           VIDEO_NUC_FSM <= s_WRITEOFFSET1;
--           DMA_SRCDAV <= '0';

--      when s_WRITEOFFSET1 =>
--          offsetstate <= '1';
          
--          if offset_counter > 0 then
    
--           --if (offset_counter /= 8) then
--           -- DMA_SRCDAV <= '1';
--           --else
--           -- DMA_SRCDAV <= '0';
--           --end if;                         
--           --DMA_SRCDAV    <= '1';
--           offset_1      := std_logic_vector(signed("0000" & quo(15 downto 0) & "000000000000") - signed(RDDATA_2(15 downto 0))*signed(RDDATA_3(15 downto 0)));
--           offset_2      := std_logic_vector(signed("0000" & quo(15 downto 0) & "000000000000") - signed(RDDATA_2( 31 downto 16 ))*signed(RDDATA_3( 31 downto 16 )));
--          --offset_1      := std_logic_vector(signed(RDDATA_2(15 downto 0))*signed(RDDATA_3(15 downto 0)) - signed("0000" & quo(15 downto 0) & "000000000000"));
          
--           --DMA_SRCDATA   <= (offset_1(27 downto 12) & offset_0);
--           RDREQ_2       <=   '0';     
--           --RDREQ_3       <=   '1';
--           RDREQ_3       <=   '0';
--           VIDEO_NUC_FSM <= s_WRITEOFFSET2;
--          else
--           --DMA_SRCDAV <= '1';
--           --offset_5      := std_logic_vector(signed("0000" & quo(15 downto 0) & "000000000000") - signed(RDDATA_2(63 downto 48))*signed(RDDATA_3(47 downto 32)));
--           ----offset_1      := std_logic_vector(resize(resize(shift_left(signed(quo(27 downto 0),12)),DMA_SRCDATA'length) - signed(RDDATA_2(31 downto 16))*signed(RDDATA_3(15 downto 0)),28));
--           --DMA_SRCDATA   <= (offset_5(27 downto 12) & offset_0);  
--           VIDEO_NUC_FSM <= s_SET_GAINADDR;
--          end if;

--          when s_WRITEOFFSET2 =>
--           VIDEO_NUC_FSM <= s_WRITEOFFSET3;

--          when s_WRITEOFFSET3 =>

--           offsetstate <= '1';
--           DMA_SRCDAV  <= '1';
--           --offset_2      := std_logic_vector(signed("0000" & quo(15 downto 0) & "000000000000") - signed(RDDATA_2( 31 downto 16 ))*signed(RDDATA_3( 15 downto 0 )));
           
--           --offset_2      := std_logic_vector(signed(RDDATA_2(31 downto 16))*signed(RDDATA_3(15 downto 0))- signed("0000" & quo(15 downto 0) & "000000000000"));
--           DMA_SRCDATA <= ( offset_2(27 downto 12) & offset_1(27 downto 12));
--           --RDREQ_2 <= '0';
--           --RDREQ_3 <= '0';
--           --VIDEO_NUC_FSM  <= s_WRITEOFFSET3; 
--          offset_counter <= offset_counter - 1;
--          if offset_counter=1 then 
--            RDREQ_2       <= '0';
--            RDREQ_3       <= '0';
--            VIDEO_NUC_FSM <= s_WAITOFFSET;
--          else
--           RDREQ_2       <= '1';
--           RDREQ_3       <= '1';
--           VIDEO_NUC_FSM <= s_WAITOFFSET;
--          end if;
          
       when s_SET_GAINADDR_COOL =>
 
          offsetstate <= '1';
          DMA_SRCDAV <= '0';
          pixcounter <= pixcounter + 1;
          DMA_RDADDR_1  <= std_logic_vector(DMA1_RDADDR1) ;
          DMA1_RDADDR1  <= DMA1_RDADDR1+32; --,DMA1_RDADDR'length);
          DMA_RDSIZE_1  <=  std_logic_vector(to_unsigned(8, DMA_RDSIZE_1'length));
          DMA_RDREQ_1   <= '1';  
          gain_counter  <=  8;
          if pixcounter < (VIDEO_XSIZE*VIDEO_YSIZE/16) then
             --VIDEO_NUC_FSM <= s_READ_GAIN;
             VIDEO_NUC_FSM <= s_READ_GAIN_COOL;
          else 
              DMA_RDREQ_1   <= '0';
              if MAX_PIXELS = 0 and VIDEO_I_EOI = '1' then
                 pixcounter <= 0;
                 VIDEO_NUC_FSM <= s_IDLE;
                 done_gain_calc_1 <= '1';
                 
              end if;
          end if;
 
       when s_READ_GAIN_COOL =>
           offsetstate <= '1';
           WRREQ_2 <= '0';
           if DMA_RDREADY_1 = '1' then -- Read Accepted
             DMA_RDREQ_1    <= '0';
           end if;
           if DMA_RDDAV_1 = '1' and gain_counter > 0 then
             WRREQ_2       <= '1';
             WRDATA_2      <= DMA_RDDATA_1 ;
             gain_counter  <= gain_counter - 1;
             --VIDEO_NUC_FSM <= s_READ_GAIN;
             VIDEO_NUC_FSM <= s_READ_GAIN_COOL;
           elsif gain_counter = 0 then
             WRREQ_2 <= '0';
             --VIDEO_NUC_FSM <= s_SET_SADDR;
             VIDEO_NUC_FSM <=s_SET_GAINADDR_HOT;
           end if; 
 
       --when s_SET_SADDR =>
       when s_SET_GAINADDR_HOT =>
           offsetstate   <= '1';
           DMA_RDADDR_1   <= std_logic_vector(DMA1_RDADDR0); 
           --DMA1_RDADDR0  <= DMA1_RDADDR0 + 64; --,DMA1_RDADDR'length);
           DMA1_RDADDR0  <= DMA1_RDADDR0 + 32; --,DMA1_RDADDR'length);
           --DMA_RDSIZE_1  <=  std_logic_vector(to_unsigned(16, DMA_RDSIZE_1'length));
           DMA_RDSIZE_1  <=  std_logic_vector(to_unsigned(8, DMA_RDSIZE_1'length));
           DMA_RDREQ_1   <= '1';
           --s_counter     <=  16;
           s_counter     <=  8;
           --VIDEO_NUC_FSM <= s_READ_SVAL;
           VIDEO_NUC_FSM <= s_READ_GAIN_HOT;
 
      -- when s_READ_SVAL =>
      when s_READ_GAIN_HOT =>
           offsetstate <= '1';
           -- WRREQ_3 <= '0'; -- shouldn't be there ??
 
           if DMA_RDREADY_1 = '1' then -- Read Accepted
             DMA_RDREQ_1    <= '0';
           end if;
           if DMA_RDDAV_1 = '1' and s_counter > 0 then 
             WRREQ_3       <= '1';
             WRDATA_3      <= DMA_RDDATA_1 ;
             s_counter     <= s_counter - 1;
             --VIDEO_NUC_FSM <= s_READ_SVAL;
             VIDEO_NUC_FSM <= s_READ_GAIN_HOT;
           elsif s_counter = 0 then
             WRREQ_3 <= '0';
             offset_counter <= 8;
             --offset_counter <= 8;
             RDREQ_2       <= '1';
             RDREQ_3       <= '1';
             --VIDEO_NUC_FSM <= s_WAITOFFSET;
             VIDEO_NUC_FSM <= s_WAITGAIN_HOT;
           end if; 
 
       --when s_WAITOFFSET => 
       when s_WAITGAIN_HOT =>
            --VIDEO_NUC_FSM <= s_WRITEOFFSET1;
            VIDEO_NUC_FSM <= s_CALCGAIN;
            DMA_SRCDAV <= '0';
 
       --when s_WRITEOFFSET1 =>
       when s_CALCGAIN =>
           offsetstate <= '1';
           
           if offset_counter > 0 then
     
            --if (offset_counter /= 8) then
            -- DMA_SRCDAV <= '1';
            --else
            -- DMA_SRCDAV <= '0';
            --end if;                         
            --DMA_SRCDAV    <= '1';
           -- offset_1      := std_logic_vector(signed("0000" & quo(15 downto 0) & "000000000000") - signed(RDDATA_2(15 downto 0))*signed(RDDATA_3(15 downto 0)));
           --offset_2      := std_logic_vector(signed("0000" & quo(15 downto 0) & "000000000000") - signed(RDDATA_2( 31 downto 16 ))*signed(RDDATA_3( 31 downto 16 )));
           if(unsigned(RDDATA_3(15 downto 0)) > unsigned(RDDATA_2(15 downto 0)))then
            pix_diff1 := "000000000000" & std_logic_vector(unsigned(RDDATA_3(15 downto 0)) - unsigned(RDDATA_2(15 downto 0)  ));
           else
            pix_diff1 := x"0000000";
           end if;
           if(unsigned(RDDATA_3(31 downto 16)) > unsigned(RDDATA_2(31 downto 16)))then
            pix_diff2 := "000000000000" &std_logic_vector(unsigned(RDDATA_3(31 downto 16)) - unsigned(RDDATA_2(31 downto 16) ));
           else
            pix_diff2 := x"0000000";
           end if;           
           
--           pix_diff1 := "000000000000" & std_logic_vector(unsigned(RDDATA_3(15 downto 0)) - unsigned(RDDATA_2(15 downto 0)  ));
--           pix_diff2 := "000000000000" &std_logic_vector(unsigned(RDDATA_3(31 downto 16)) - unsigned(RDDATA_2(31 downto 16) ));
           avg_diff  := std_logic_vector(unsigned(avg_hot) - unsigned(avg_cool))& "000000000000";
            --offset_1      := std_logic_vector(signed(RDDATA_2(15 downto 0))*signed(RDDATA_3(15 downto 0)) - signed("0000" & quo(15 downto 0) & "000000000000"));
            
            start_div1 <= '1';
            dvnd1      <= avg_diff;--Average_FILT;
            if((unsigned(pix_diff1) <= unsigned(x"000" &bpc_th)) or first_bad_pix='1') then
                dvsr1      <= x"0000001";
                pix1_bad   <= '1';  
                first_bad_pix <= '0';
            else 
                dvsr1      <= pix_diff1;--std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE,dvsr'length));
                pix1_bad   <= '0';
            end if;
                
            
            start_div2 <= '1';
            dvnd2      <= avg_diff;--std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE,dvsr'length));
            if(unsigned(pix_diff2)<= unsigned(x"000" & bpc_th)) then
                dvsr2      <= x"0000001";
                pix2_bad   <= '1';
            else  
                dvsr2      <= pix_diff2;--std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE,dvsr'length));
                pix2_bad   <= '0';
            end if;
            
            
           
            --DMA_SRCDATA   <= (offset_1(27 downto 12) & offset_0);
            RDREQ_2       <=   '0';     
            --RDREQ_3       <=   '1';
            RDREQ_3       <=   '0';
            --VIDEO_NUC_FSM <= s_WRITEOFFSET2;
            VIDEO_NUC_FSM <= s_WRITEGAIN;
           else
            --DMA_SRCDAV <= '1';
            --offset_5      := std_logic_vector(signed("0000" & quo(15 downto 0) & "000000000000") - signed(RDDATA_2(63 downto 48))*signed(RDDATA_3(47 downto 32)));
            ----offset_1      := std_logic_vector(resize(resize(shift_left(signed(quo(27 downto 0),12)),DMA_SRCDATA'length) - signed(RDDATA_2(31 downto 16))*signed(RDDATA_3(15 downto 0)),28));
            --DMA_SRCDATA   <= (offset_5(27 downto 12) & offset_0);  
            VIDEO_NUC_FSM <= s_SET_GAINADDR_COOL;
           end if;
 
           --when s_WRITEOFFSET2 =>
          when s_WRITEGAIN =>
            if done_tick1 = '1' and done_tick2 = '1'then
               offsetstate <= '1';
               DMA_SRCDAV  <= '1';
               pix1_bad <= '0';
               pix2_bad <= '0';
               --DMA_SRCDATA <= ( offset_2(27 downto 12) & offset_1(27 downto 12));
               if(pix1_bad = '1' and pix2_bad = '1' )then
                DMA_SRCDATA    <= '1'& quo2(14 downto 0) & '1' & quo1(14 downto 0);
               elsif(pix1_bad = '1')then
                DMA_SRCDATA    <= quo2(15 downto 0) & '1' & quo1(14 downto 0);
               elsif(pix2_bad = '1')then
                DMA_SRCDATA    <= '1'& quo2(14 downto 0) & quo1(15 downto 0);
               else
                DMA_SRCDATA    <= quo2(15 downto 0) & quo1(15 downto 0); 
               end if;
               
               offset_counter <= offset_counter - 1;
               
               if offset_counter=1 then 
                 RDREQ_2       <= '0';
                 RDREQ_3       <= '0';
               else
                RDREQ_2       <= '1';
                RDREQ_3       <= '1';
               end if;
               --VIDEO_NUC_FSM <= s_WAITOFFSET;
               VIDEO_NUC_FSM <= s_WAITGAIN_HOT;
          else
             VIDEO_NUC_FSM <= s_WRITEGAIN;
          end if;
        end case;

      if  enable_delayed_and = '1' then
          Average_FILT <= (others => '0');
          DMA_SRCDAV_d  <= '0';
          VIDEO_NUC_FSM <= s_WAIT_FRAME;
--          davcounter <= 0;
          frame_counter <= 0;
          count <= 0;
      end if;

  end if;
end process;


i_DMA_WRITE : entity WORK.DMA_WRITE_1
generic map (
--  ADDR_BUF0 => unsigned (ADDR_OFFM_NUC1PT),--ADDR_VIDEO_BUF4,
--  ADDR_BUF1 => unsigned (ADDR_OFFM_NUC1PT),--ADDR_VIDEO_BUF4,
--  ADDR_BUF2 => unsigned (ADDR_OFFM_NUC1PT),--ADDR_VIDEO_BUF4,
  --DATA_SIZE => DATA_SIZE ,-- Number of bytes in the Data Lane
  --BPP       => BPP,-- Number of bytes per pixel
  DMA_SIZE_BITS => DMA_SIZE_BITS,
  WR_SIZE   => 16
  )
port map (
  CLK           => CLK               ,
  RST           => RST               ,

  BUF0_LOCK_READER     => '0'        ,
  BUF1_LOCK_READER     => '0'        ,
  BUF2_LOCK_READER     => '0'        ,

  BUF0_LOCK_WRITER     => open       ,
  BUF1_LOCK_WRITER     => open       ,
  BUF2_LOCK_WRITER     => open       ,
  
  ADDR_BUF0     => MEM_ADDR,
--  ADDR_BUF1     => MEM_ADDR,
--  ADDR_BUF2     => MEM_ADDR,
  SRC_V         => DMA_SRCV          ,
  SRC_H         => DMA_SRCH          ,
  SRC_EOI       => DMA_SRCEOI        ,
  SRC_DAV       => DMA_SRCDAV        ,
  SRC_DATA      => DMA_SRCDATA       ,
  SRC_XSIZE     => DMA_SRCXSIZE,
  SRC_YSIZE     => DMA_SRCYSIZE,
  MEM_IMG_SOI   => MEM_IMG_SOI_1     ,
  MEM_IMG_BUF   => MEM_IMG_BUF       ,
  MEM_IMG_XSIZE => MEM_IMG_XSIZE_1   ,
  MEM_IMG_YSIZE => MEM_IMG_YSIZE_1   ,
  DMA_WRREQ     => DMA0_WRREQ_1        ,
  DMA_WRBURST   => DMA0_WRBURST_1      ,
  DMA_WRSIZE    => DMA0_WRSIZE_1       ,
  DMA_WRADDR    => DMA0_WRADDR_1       ,
  DMA_WRDATA    => DMA0_WRDATA_1       ,
  DMA_WRBE      => DMA0_WRBE         ,
  DMA_WRREADY   => DMA0_WRREADY_1      ,
  MAX_PIXELS_1  => MAX_PIXELS

  ); 



i_MEMORY_TO_SCALER : entity WORK.MEMORY_TO_SCALER_1 
 generic map (
--   ADDR_BUF0     => unsigned (ADDR_OFFM_NUC1PT)  ,
--   ADDR_BUF1     => unsigned (ADDR_OFFM_NUC1PT)  ,
--   ADDR_BUF2     => unsigned (ADDR_OFFM_NUC1PT)  ,
   DMA_SIZE_BITS => DMA_SIZE_BITS,
   PIX_BITS      => PIX_BITS         ,
   LIN_BITS      => LIN_BITS         ,
   RD_SIZE       => 16
 )
 port map (
   CLK             => CLK               , 
   RST             => RST               , 
   --MEM_IMG_SOI     =>  MEM_IMG_SOI_1   ,  -- Memory Image Picture Start  
   
   ADDR_BUF0     => MEM_ADDR,
   ADDR_BUF1     => MEM_ADDR,
   ADDR_BUF2     => MEM_ADDR,
    
   MEM_IMG_BUF     => MEM_IMG_BUF       , 
   MEM_IMG_XSIZE   => MEM_IMG_XSIZE_1   , 
   MEM_IMG_YSIZE   => MEM_IMG_YSIZE_1   , 
   DMA_RDREADY     => DMA_RDREADY_0      ,
   DMA_RDREQ       => DMA_RDREQ_0        ,
   DMA_RDSIZE      => DMA_RDSIZE_0       ,
   DMA_RDADDR      => DMA_RDADDR_0       ,
   DMA_RDDAV       => DMA_RDDAV_0        ,  
   DMA_RDDATA      => DMA_RDDATA_0       ,

   SCALER_RUN       => SCALER_RUN        , 
   SCALER_REQ_V     => SCALER_REQ_V      , 
   SCALER_REQ_H     => SCALER_REQ_H      ,
--   SCALER_PIX_OFF   => SCALER_PIX_OFF_1  ,
   SCALER_REQ_XSIZE => SCALER_REQ_XSIZE,
   SCALER_REQ_YSIZE => SCALER_REQ_YSIZE,
   SCALER_V         => SCALER_V          , 
   SCALER_H         => SCALER_H          , 
   SCALER_DAV       => SCALER_DAV        ,
   SCALER_EOI       => SCALER_EOI      ,  
   SCALER_DATA      => SCALER_DATA_1     , 
--   SCALER_XSIZE     => SCALER_XSIZE      ,      
--   SCALER_YSIZE     => SCALER_YSIZE      ,      
--   SCALER_XCNT      => SCALER_XCNT       ,     
--   SCALER_YCNT      => SCALER_YCNT       ,
   SCALER_FIFO_EMP => SCALER_FIFO_EMP  

 );

 i_div : entity WORK.div
 generic map(
  W    => 64,
  CBIT => 7
  )
 port map(

  clk  => CLK,
  reset => RST,
  start => start_div ,
  dvsr =>  dvsr, 
  dvnd => dvnd,
  done_tick => done_tick,
  quo => quo, 
  rmd => rmd
  );
i_div1 : entity WORK.div
    generic map(
    W    => GAIN_DIV_W,
    CBIT => 5
    )
    port map(
    clk   => CLK,
    reset => RST,
    start => start_div1 ,
    dvsr  => dvsr1, 
    dvnd  => dvnd1,
    done_tick => done_tick1,
    quo => quo1, 
    rmd => rmd1
    );

i_div2 : entity WORK.div
 generic map(
  W    => GAIN_DIV_W,
  CBIT => 5
  )
 port map(

  clk   => CLK,
  reset => RST,
  start => start_div2 ,
  dvsr  => dvsr2, 
  dvnd  => dvnd2,
  done_tick => done_tick2,
  quo => quo2, 
  rmd => rmd2
  ); 

-- xpm_fifo_sync: Synchronous FIFO
-- Xilinx Parameterized Macro, Version 2017.4
--xpm_fifo_Line_0 : xpm_fifo_sync
--  generic map (

--    FIFO_MEMORY_TYPE         => "block",           --string; "auto", "block", "distributed", or "ultra" ;
--    ECC_MODE                 => "no_ecc",         --string; "no_ecc" or "en_ecc";
--    FIFO_WRITE_DEPTH         => 32,             --positive integer
--    WRITE_DATA_WIDTH         => 14,               --positive integer
--    WR_DATA_COUNT_WIDTH      => 6,               --positive integer
--    PROG_FULL_THRESH         => 10,               --positive integer
--    FULL_RESET_VALUE         => 0,                --positive integer; 0 or 1;
--    USE_ADV_FEATURES         => "1f1f",           --string; "0000" to "1F1F";
--    READ_MODE                => "std",            --string; "std" or "fwft";
--    FIFO_READ_LATENCY        => 1,                --positive integer;
--    READ_DATA_WIDTH          => 14,               --positive integer
--    RD_DATA_COUNT_WIDTH      => 6,               --positive integer
--    PROG_EMPTY_THRESH        => 10,               --positive integer
--    DOUT_RESET_VALUE         => "0",              --string
--    WAKEUP_TIME              => 0                 --positive integer; 0 or 2;
--  )
--  port map (

--    rst              => RST,
--    wr_clk           => CLK,
--    wr_en            => WRREQ_0,
--    din              => WRDATA_0,
--    full             => FULL_0,
--    overflow         => open,
--    wr_rst_busy      => open,
--    prog_full        => open,
--    wr_data_count    => USEDW_0,
--    almost_full      => open,
--    wr_ack           => open,
--    rd_en            => RDREQ_0,
--    dout             => RDDATA_0,
--    empty            => EMPTY_0,
--    underflow        => open,
--    rd_rst_busy      => open,
--    prog_empty       => open,
--    rd_data_count    => open,
--    almost_empty     => AEMPTY_0,
--    data_valid       => open,
--    sleep            => '0',
--    injectsbiterr    => '0',
--    injectdbiterr    => '0',
--    sbiterr          => open,
--    dbiterr          => open
--  );

-- End of xpm_fifo_sync_inst instance declaration
			
		



Line_0: entity WORK.FIFO_GENERIC_SC
GENERIC MAP(
  FIFO_DEPTH  => 10,
  FIFO_WIDTH  => 32,--DataWidth,
  USE_EAB   => true,
  SHOW_AHEAD  => False
)
PORT MAP(
  CLK     => CLK,
  RST     => RST,
  CLR     => FIFOCLR_0,

  WRREQ   => WRREQ_0,
  WRDATA  => WRDATA_0,

  RDREQ   => RDREQ_0,
  RDDATA  => RDDATA_0,  

  USEDW => USEDW_0,
  FULL  => FULL_0,
  EMPTY => EMPTY_0,
  AEMPTY  => AEMPTY_0
  );
--Line_0 : entity work.alt_fifo_0 PORT MAP (
--    clock  => CLK,
--    data   => WRDATA_0,
--    rdreq  => RDREQ_0,
--    sclr   => FIFOCLR_0,
--    wrreq  => WRREQ_0,
--    almost_empty   => AEMPTY_0,
--    almost_full  => AFULL_0,
--    empty  => EMPTY_0,
--    full   => FULL_0,
--    q  => RDDATA_0,
--    usedw  => USEDW_0
--  );


--xpm_fifo_Line_1 : xpm_fifo_sync
--  generic map (

--    FIFO_MEMORY_TYPE         => "block",           --string; "auto", "block", "distributed", or "ultra" ;
--    ECC_MODE                 => "no_ecc",         --string; "no_ecc" or "en_ecc";
--    FIFO_WRITE_DEPTH         => 32,             --positive integer
--    WRITE_DATA_WIDTH         => 32,               --positive integer
--    WR_DATA_COUNT_WIDTH      => 6,               --positive integer
--    PROG_FULL_THRESH         => 10,               --positive integer
--    FULL_RESET_VALUE         => 0,                --positive integer; 0 or 1;
--    USE_ADV_FEATURES         => "1f1f",           --string; "0000" to "1F1F";
--    READ_MODE                => "std",            --string; "std" or "fwft";
--    FIFO_READ_LATENCY        => 1,                --positive integer;
--    READ_DATA_WIDTH          => 32,               --positive integer
--    RD_DATA_COUNT_WIDTH      => 6,               --positive integer
--    PROG_EMPTY_THRESH        => 10,               --positive integer
--    DOUT_RESET_VALUE         => "0",              --string
--    WAKEUP_TIME              => 0                 --positive integer; 0 or 2;
--  )
--  port map (

--    rst              => RST,
--    wr_clk           => CLK,
--    wr_en            => WRREQ_1,
--    din              => WRDATA_1,
--    full             => FULL_1,
--    overflow         => open,
--    wr_rst_busy      => open,
--    prog_full        => open,
--    wr_data_count    => USEDW_1,
--    almost_full      => open,
--    wr_ack           => open,
--    rd_en            => RDREQ_1,
--    dout             => RDDATA_1,
--    empty            => EMPTY_1,
--    underflow        => open,
--    rd_rst_busy      => open,
--    prog_empty       => open,
--    rd_data_count    => open,
--    almost_empty     => AEMPTY_1,
--    data_valid       => open,
--    sleep            => '0',
--    injectsbiterr    => '0',
--    injectdbiterr    => '0',
--    sbiterr          => open,
--    dbiterr          => open
--  );





Line_1: entity WORK.FIFO_GENERIC_SC
  GENERIC MAP(
    FIFO_DEPTH  => 10,
    FIFO_WIDTH  => 32,
    USE_EAB   => true,
    SHOW_AHEAD  => False
  )
  PORT MAP(
    CLK     => CLK,
    RST     => RST,
    CLR     => FIFOCLR_1,

    WRREQ   => WRREQ_1,
    WRDATA  => WRDATA_1,

    RDREQ   => RDREQ_1,
    RDDATA  => RDDATA_1,  
    USEDW   => USEDW_1,
    FULL    => FULL_1,
    EMPTY   => EMPTY_1,
    AEMPTY  => AEMPTY_1
  );

--Line_1 : entity work.alt_fifo PORT MAP (
--    clock  => CLK,
--    data   => WRDATA_1,
--    rdreq  => RDREQ_1,
--    sclr   => FIFOCLR_1,
--    wrreq  => WRREQ_1,
--    almost_empty   => AEMPTY_1,
--    almost_full  => AFULL_1,
--    empty  => EMPTY_1,
--    full   => FULL_1,
--    q  => RDDATA_1,
--    usedw  => USEDW_1
--  );

Line_2: entity WORK.FIFO_GENERIC_SC
GENERIC MAP(
  FIFO_DEPTH  => 5,
  FIFO_WIDTH  => 32,
  USE_EAB   => true,
  SHOW_AHEAD  => false
)
PORT MAP(
  CLK     => CLK,
  RST     => RST,
  CLR     => FIFOCLR_2,

  WRREQ   => WRREQ_2,
  WRDATA  => WRDATA_2,

  RDREQ   => RDREQ_2,
  RDDATA  => RDDATA_2,  

  USEDW   => USEDW_2,
  FULL    => FULL_2,
  EMPTY   => EMPTY_2,
  AEMPTY  => AEMPTY_2
  );

Line_3: entity WORK.FIFO_GENERIC_SC
  GENERIC MAP(
    FIFO_DEPTH  => 5,
    FIFO_WIDTH  => 32,
    USE_EAB     => true,
    SHOW_AHEAD  => false
  )
  PORT MAP(
    CLK     => CLK,
    RST     => RST,
    CLR     => FIFOCLR_3,

    WRREQ   => WRREQ_3,
    WRDATA  => WRDATA_3,

    RDREQ   => RDREQ_3,
    RDDATA  => RDDATA_3,  
    USEDW   => USEDW_3,
    FULL    => FULL_3,
    EMPTY   => EMPTY_3,
    AEMPTY  => AEMPTY_3
  );

  -- -----------------------------
  --  Video Outputs
  -- -----------------------------
  --VIDEO_O_V     <= VIDEO_O_FILT_V;
  --VIDEO_O_H     <= VIDEO_O_FILT_H;
  --VIDEO_O_DAV   <= VIDEO_O_FILT_DAV;
  --VIDEO_O_DATA  <= VIDEO_O_FILT_DATA;
  --VIDEO_O_EOI   <= VIDEO_O_FILT_EOI;
  done_offset    <= done_offset_1;
  done_gain_calc <= done_gain_calc_1;
-----------------------------
--probe0(31 downto 0)<= Average_FILT(43 downto 12) ;
--probe0(63 downto 32)<=std_logic_vector(to_unsigned (frame_counter,32));
--probe0(79 downto 64)<=DMA_SRCDATA1_Temp ;
--probe0(95 downto 80)<=DMA_SRCDATA2_Temp;
--probe0(100 downto 96)<= VIDEO_NUC_FSM_Temp1;
--probe0(101)<=ENABLE_NUC1pCalib;
--probe0(102)<= VIDEO_I_V;
--probe0(103)<= VIDEO_I_H;
--probe0(104)<= VIDEO_I_EOI;
--probe0(105)<= VIDEO_I_DAV;
--probe0(106)<= done_offset_1;
--probe0(120 downto 107)<= VIDEO_I_DATA;
--probe0(121)<= VIDEO_UNFILTERED_dav;
--probe0(122)<= VIDEO_UNFILTERED_dav_d;
--probe0(123)<= SCALER_REQ_H;
--probe0(124)<= DMA_SRCEOI ;
--probe0(125)<= SRC_EOI;
--probe0(126) <= FIFOCLR_0;
--probe0(127) <= FIFOCLR_1;




 

--probe0(0)            <=  gain_enable;       
--probe0(1)            <=  start_gain_calc;   
--probe0(2)            <=  select_gain_addr;  
--probe0(3)            <=  done_gain_calc_1;    
--probe0(4)            <=  VIDEO_I_V;
--probe0(5)            <=  VIDEO_I_H;
--probe0(6)            <=  VIDEO_I_EOI;
--probe0(7)            <=  VIDEO_I_DAV;
--probe0(8)            <=  done_offset_1;
--probe0(9)            <=  ENABLE_NUC1pCalib;
--probe0(14 downto 10) <=  VIDEO_NUC_FSM_Temp1;
--probe0(15)           <=  enable_validframe;
--probe0(16)           <=  done_tick;
--probe0(17)           <=  DMA0_WRREADY;
--probe0(18)           <=  DMA1_RDDAV;
--probe0(19)           <=  DMA1_RDREADY;
--probe0(20)           <=  DMA_SRCDAV;
----probe0(36 downto 21) <=  avg_hot;
----probe0(52 downto 37) <=  avg_cool;
--probe0(60 downto 21)<= cold_img_sum(39 downto 0);
--probe0(61)           <=  GAIN_TABLE_SEL;
--probe0(125 downto 62)<= dvnd;
----probe0(117 downto 86)<= hot_img_sum; 
--probe0(126)          <= start_div;
--probe0(127)          <= start_div1;
----probe0(127 downto 120)<= cold_img_sum(39 downto 32);--dvnd2(15 downto 0);

--i_NUC1pt_ila: TOII_TUVE_ila
--PORT MAP (
--	clk => CLK,
--	probe0 => probe0
--);

end architecture RTL;
-----------------------------