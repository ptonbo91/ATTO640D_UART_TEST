---------------------------------------------------------------
-- Copyright    : ALSE - http://alse-fr.com
-- Contact      : info@alse-fr.com
-- Project Name : Tonboimaging - Thermal Camera Project
-- Block Name   : NUC
-- Description  : NUC Algorithm
-- Author       : E. LAURENDEAU
-- Date         : Dec 2013
----------------------------------------------------------------

-- Copyright    : Tonbo Imaging Pvt Ltd
-- Project Name : Tonboimaging - Thermal Camera Project
-- Block Name   : THERMAL_CAM_TOP
-- Description  : Top Level 
-- Author       : ANEESH M U
-- Date         : Jul 2016
-- Revision     : 3.0
-------------------------------------------------------------------------------
-- Design Notes :
-- * v2013.12 : Initial Version
-- * NUC(I,j) = (Input_Image(I,j) * Gain_Matrix(I,j) ) - Offset Matrix (I,j)
--   > Input_Image(I,j) is 14bits wide, coming from Camera In
--   > Gain_Matrix(I,j) is  7bits wide, read from DDR3/SRAM memory
--   > Bad_Pixel(I,j)   is  1bits wide, read from DDR3/SRAM memory
--   > Offset_Matrix(I,j) is 32bits wide, read from DDR3/SRAM memory
--     and computed here in the module, depending the Temperature

-- Supported Resolutions :
-- QVGA : 384*288 = 110592 pixels (need : PIX_BITS= 9, LIN_BITS= 9)
-- VGA  : 640*480 = 307200 pixels (need : PIX_BITS=10, LIN_BITS=10, need a bigger memory)
-- XGA  : 1024*768 = 786432 pixels (need : PIX_BITS=11, LIN_BITS=10, need a much bigger memory)

-- REMove the line temp_range = 10 , @ 273. It is for testing alone.

-- Base address for the NUC tables are in THERMAL_CAM_PACK.vhd FILE 

  use WORK.THERMAL_CAM_PACK.all;
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
----------------------------
entity NUC is
----------------------------

  generic (
    bit_width            : positive := 13;
    PIX_BITS             : positive := 10;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS             : positive := 10; 
    VIDEO_YSIZE          : integer := 480;
    VIDEO_XSIZE          : integer := 642;                   -- 2**LIN_BITS = Maximum Number of  lines in an image 
    DMA_SIZE_BITS        : positive:= 5;
    RD_SIZE              : positive range 1 to 64 := 4        -- Read Burst Size for Memory Read Requests
  );

  port (

    -- Clock and Reset
    CLK           : in  std_logic;                      -- Module Clock
    RST           : in  std_logic;                      -- Module Reset (asynch'ed active high)
    ENABLE_NUC    : in  std_logic;                      -- NUC Algorithm performed if '1', otherwise bypass
    ENABLE_BADPIX : in  std_logic;                      -- Bad Pixel Info is outputted if '1', otherwise bypass
    ZFORCE_BADPIX : in  std_logic;                      -- Bad Pixel is forced to 0's when VIDEO_O_BAD = '1'
    APPLY_NUC1ptCalib : in std_logic;                   -- NUC 1-POINT APPLY
    OFFSET_IMG_AVG: in std_logic_vector(15 downto 0);
    update_gfid_gsk         : out std_logic;  
    new_gfid_gsk_start_addr : out std_logic_vector(5 downto 0);
    sensor_init_data_len    : in std_logic_vector(5 downto 0);  

--    sel_high_low   : out std_logic;
--    sel_temp_range : in std_logic;
--    sel_temp_range_en :in std_logic;

    sel_temp_range_out   : out std_logic_vector(1 downto 0);
    force_temp_range : in std_logic_vector(1 downto 0);
    force_temp_range_en :in std_logic;
    
    
    
    GAIN_TABLE_SEL : in std_logic;
    -- Temperature Information                          -- Used only for uncooled systems. For Cooled systems this 
                                                        -- information is not used since temperature is assumed to 
                                                        -- be constant.                                                        
    TEMPERATURE   : in  std_logic_vector(15 downto 0);  -- Temperature Current Value
--    TEMP_A_MIN    : in  std_logic_vector(15 downto 0);  -- Temperature Range A Min Value
--    TEMP_A_MAX    : in  std_logic_vector(15 downto 0);  -- Temperature Range A Max Value
--    TEMP_B_MIN    : in  std_logic_vector(15 downto 0);  -- Temperature Range B Min Value
--    TEMP_B_MAX    : in  std_logic_vector(15 downto 0);  -- Temperature Range B Max Value
--    TEMP_C_MIN    : in  std_logic_vector(15 downto 0);  -- Temperature Range C Min Value
--    TEMP_C_MAX    : in  std_logic_vector(15 downto 0);  -- Temperature Range C Max Value
--    TEMP_D_MIN    : in  std_logic_vector(15 downto 0);  -- Temperature Range D Min Value
--    TEMP_D_MAX    : in  std_logic_vector(15 downto 0);  -- Temperature Range D Max Value

    --Fixed Offset
    PIX_OFFSET    : in  std_logic_vector(31 downto 0);  -- Value subtracted from (Pixel*Gain-Offset) 

    -- Video Input
    VIDEO_I_V     : in  std_logic;                      -- Video Input   Vertical Synchro
    VIDEO_I_H     : in  std_logic;                      -- Video Input Horizontal Synchro
    VIDEO_I_EOI   : in  std_logic;                      -- Video Input End Of Image
    VIDEO_I_DAV   : in  std_logic;                      -- Video Input Data Valid
    VIDEO_I_DATA  : in  std_logic_vector(bit_width downto 0);  -- Video Input Data
    --VIDEO_XSIZE : in  std_logic_vector(PIX_BITS-1 downto 0);  -- Video X Size
    --VIDEO_YSIZE : in  std_logic_vector(LIN_BITS-1 downto 0);  -- Video Y Size
    --VIDEO_I_XCNT  : in  std_logic_vector(PIX_BITS-1 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
    --VIDEO_I_YCNT  : in  std_logic_vector(LIN_BITS-1 downto 0);  -- Video Y Line  Counter (1st line  = 0)

    -- DMA Master Read Interface to Memory Controller
    DMA_RDREADY   : in  std_logic;                      -- DMA Ready Request
    DMA_RDREQ     : out std_logic;                      -- DMA Read Request
    DMA_RDSIZE    : out std_logic_vector(DMA_SIZE_BITS-1 downto 0);  -- DMA Request Size
    DMA_RDADDR    : out std_logic_vector(31 downto 0);  -- DMA Master Address
    DMA_RDDAV     : in  std_logic;                      -- DMA Read Data Valid
    DMA_RDDATA    : in  std_logic_vector(31 downto 0);  -- DMA Read Data

    -- Video Output
    VIDEO_O_V     : out std_logic;                      -- Video Output   Vertical Synchro
    VIDEO_O_H     : out std_logic;                      -- Video Output Horizontal Synchro
    VIDEO_O_EOI   : out std_logic;                      -- Video Output End Of Image
    VIDEO_O_DAV   : out std_logic;                      -- Video Output Data Valid
    VIDEO_O_DATA  : out std_logic_vector(bit_width downto 0);  -- Video Output Data
    VIDEO_O_BAD   : out std_logic;                      -- Video Output Bad Pixel


    update_device_id_reg_en      : in std_logic;    
    update_device_id_reg         : in std_logic_vector (31 downto 0);     
    temperature_write_data       : in std_logic_vector (7 downto 0);
    temperature_write_data_valid : in std_logic;
    temperature_rd_data          : out std_logic_vector(15 downto 0); -- output
    temperature_rd_data_valid    : out std_logic; -- outpur
    temperature_rd_rq            : in std_logic; --//input
    temperature_wr_addr          : in std_logic_vector (7 downto 0); -- input
    temperature_wr_rq            : in std_logic; --//input
    STORE_TEMP_AVG_FRAME         : in  std_logic_vector(15 downto 0);--//input
    CUR_GAIN_TABLE               : out std_logic_vector(2 downto 0);
    CUR_OFFSET_TABLE             : out std_logic_vector(6 downto 0);
    CUR_TEMP_AREA                : out std_logic_vector(1 downto 0)
--    TEMP_RANGE_Check : out std_logic_vector (6 downto 0)    
    --VIDEO_O_XSIZE : out std_logic_vector(PIX_BITS-1 downto 0);  -- Video X Size
    --VIDEO_O_YSIZE : out std_logic_vector(LIN_BITS-1 downto 0);  -- Video Y Size
    --VIDEO_O_XCNT  : out std_logic_vector(PIX_BITS-1 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
    --VIDEO_O_YCNT  : out std_logic_vector(LIN_BITS-1 downto 0)   -- Video Y Line  Counter (1st line  = 0)

  );

-------------------------------
end entity NUC;
-------------------------------

-------------------------------------------
architecture RTL of NUC is
-------------------------------------------
COMPONENT TOII_TUVE_ila

PORT (
    clk : IN STD_LOGIC;



    probe0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0)
);
END COMPONENT;
  -- Temperature Signals
  signal nuc_probe: std_logic_vector(255 downto 0);

  signal TEMP_RANGE : unsigned(6 downto 0);
  signal TEMP_RANGE_DD : unsigned(6 downto 0);
  signal TEMP_RANGE_D : unsigned(6 downto 0);
--  signal TEMP_CUR_s : signed(TEMPERATURE'length downto 0);  -- +1bit for signed conversion
--  signal TEMP_RES_s : signed(14+12-1 downto 0);
--  signal TEMP_CALC  : signed(9 downto 0);  -- format 8.2 signed : -128 to +127, with 2bits for fractional part
--  signal TEMP_SQ    : signed(TEMP_CALC'length*2-1 downto 0);
  
  -- DMA Read      
  type DMA_RDFSM_t is ( s_IDLE, s_WAIT_FOR_H, s_COMPUTE_TEMPERATURE1, s_COMPUTE_TEMPERATURE2, s_COMPUTE_TEMPERATURE3,
                        s_GET_GAIN_START_ADDR, s_GET_GAIN_MATRIX, 
                        s_GET_OFFSET_MATRIX_START_ADDR, s_GET_OFFSET_MATRIX, 
                        s_NEXT_LINE, s_GET_LINE_PARAM );
  signal DMA_RDFSM      : DMA_RDFSM_t;
  signal DMA_RDGOTO     : DMA_RDFSM_t;
  
  signal DMA_ADDR_PIX   : unsigned(PIX_BITS+1 downto 0);    -- pixels max * 2 (Because 32bits per pixel required)
  signal DMA_ADDR_LIN   : unsigned(LIN_BITS-1 downto 0);    -- lines max
  signal DMA_ADDR_START : unsigned(DMA_ADDR_LIN'length+DMA_ADDR_PIX'length-1 downto 0); 
  signal DMA_ADDR_PICT  : unsigned(DMA_ADDR_LIN'length+DMA_ADDR_PIX'length-1 downto 0); --temporary signal
  signal DMA_ADDR_BASE  : unsigned(DMA_RDADDR'range);       -- Base address signal
  signal DMA_ADDR_BASE_GAIN  : unsigned(DMA_RDADDR'range);       -- Base address signal
  signal DMA_ADDR_BASE_GAIN_TEMP  : unsigned(DMA_RDADDR'range);       -- Base address signal 
  signal DMA_RDEND      : unsigned(DMA_ADDR_PIX'range);     -- End address signal


  -- FIFO Signals
  constant FIFO_DEPTH : positive := PIX_BITS+1;  -- 1 line, +1bit for 32bits for one pixel
  constant FIFO_WSIZE : positive := 32; 
  signal FIFO_CLR     : std_logic;
  signal FIFO_WR      : std_logic;
  signal FIFO_IN      : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_FUL     : std_logic;
  signal FIFO_NB      : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal FIFO_EMP     : std_logic;
  signal FIFO_RD      : std_logic;
  signal FIFO_SEL     : std_logic_vector(1 downto 0);
  signal FIFO_SEL2    : std_logic;
  signal FIFO_OUT     : std_logic_vector(FIFO_WSIZE-1 downto 0);

  -- RAM Write FSM    
  type RAM_WRFSM_t is ( s_IDLE, s_NEW_LINE, s_STORE_GAIN_MATRIX, s_STORE_OFFM1_MATRIX,s_STORE_OFFM2_MATRIX );
  signal RAM_WRFSM : RAM_WRFSM_t;
  signal RAM_WRST  : std_logic;
  signal RAM_WRSEL : std_logic;

  -- Both Gain and OffsetMatrix have same size (to store two lines)  
  constant RAMS_ADDR_WIDTH : positive := PIX_BITS+1; -- 1 line, +1 for Double Buffer
  signal RAM_RDSEL : std_logic;
  signal RAM_RDCNT : unsigned(RAMS_ADDR_WIDTH-2 downto 0);

  -- Gain Data Size in bits : 15bits, 3.12 format
  constant GAIN_DATA_SIZE : positive := 15;
  
  -- Gain Matrix RAM Signals
  constant GAIN_DATA_WIDTH : positive := GAIN_DATA_SIZE + 1; -- +1 because we also store the bad pixel information (1bit) here 
  signal GAIN_WRREQ  : std_logic;
  signal GAIN_WRCNT  : unsigned(RAMS_ADDR_WIDTH-2-1 downto 0);  
  signal GAIN_WRADDR : std_logic_vector(RAMS_ADDR_WIDTH-1-1 downto 0); -- This is because we are using mixed port ram. Thus write 
                                                                       -- address is 2bits less than RD address
  signal GAIN_WRDATA : std_logic_vector(FIFO_WSIZE-1 downto 0);        -- Write data port is same width as FIFO port size.
  signal GAIN_RDADDR : std_logic_vector(RAMS_ADDR_WIDTH-1 downto 0);
  signal GAIN_RDDATA : std_logic_vector(GAIN_DATA_WIDTH-1 downto 0);
  signal GAIN_RDDATA_D : std_logic_vector(GAIN_DATA_WIDTH-1 downto 0);
  -- Offset Matrix RAM Signals
  constant OFFM_DATA_WIDTH : positive := 16;
  signal OFFM1_WRREQ  : std_logic;
  signal OFFM1_WRCNT  : unsigned(RAMS_ADDR_WIDTH-2-1 downto 0);
  signal OFFM1_WRADDR : std_logic_vector(RAMS_ADDR_WIDTH-1-1 downto 0); -- This is because we are using mixed port ram. Thus write 
                                                                       -- address is 1bit less than RD address
  signal OFFM1_WRDATA   : std_logic_vector(FIFO_WSIZE-1 downto 0);        -- Write data port is same width as FIFO port size.
  signal OFFM1_RDADDR   : std_logic_vector(RAMS_ADDR_WIDTH-1 downto 0);
  signal OFFM1_RDDATA   : std_logic_vector(OFFM_DATA_WIDTH-1 downto 0);


  signal OFFM2_WRREQ    : std_logic;
  signal OFFM2_WRCNT    : unsigned(RAMS_ADDR_WIDTH-2-1 downto 0);
  signal OFFM2_WRADDR   : std_logic_vector(RAMS_ADDR_WIDTH-1-1 downto 0); -- This is because we are using mixed port ram. Thus write 
                                                                       -- address is 1bit less than RD address
  signal OFFM2_WRDATA   : std_logic_vector(FIFO_WSIZE-1 downto 0);        -- Write data port is same width as FIFO port size.
  signal OFFM2_RDADDR   : std_logic_vector(RAMS_ADDR_WIDTH-1 downto 0);
  signal OFFM2_RDDATA   : std_logic_vector(OFFM_DATA_WIDTH-1 downto 0);

  signal offset_1 : signed(31 downto 0);
  signal offset_2 : signed(31 downto 0);
  
  -- Offset a,b,c Signals
--  signal OFFM_NEW    : std_logic;                                      -- Pipeline signals, currently not used.
--  signal OFFM_DAV    : std_logic;
--  signal OFFM_DAV2   : std_logic;
--  signal OFFM_A      : signed(06 downto 00);  -- -0064 to +0063
--  signal OFFM_B      : signed(10 downto 00);  -- -1000 to +1000
--  signal OFFM_C      : signed(FIFO_WSIZE-1 downto 00);  -- -5000 to +5000
--  signal OFFM_MUL1_O : signed(OFFM_A'length+TEMP_SQ'length-1 downto 0);
--  signal OFFM_MUL2_O : signed(OFFM_B'length+TEMP_CALC'length-1 downto 0);
--  signal OFFM_MUL2_m : signed(OFFM_MUL2_O'range);
--  signal OFFM_ACCUM  : signed(OFFM_C'range);
--  signal OFFM_RES    : signed(OFFM_C'range);

  -- Video Output Signals
  signal ENABLE_NUC_l : std_logic;
  type VIDEO_O_FSM_t is ( s_IDLE, s_BYPASS, s_NEW_LINE, s_COMPUTE_LINE );
  signal VIDEO_O_FSM   : VIDEO_O_FSM_t;
  
  signal VIDEO_O_NEW   : std_logic;
  signal VIDEO_O_TEMP  : unsigned(VIDEO_I_DATA'length+GAIN_DATA_SIZE-1 downto 0);  
  signal VIDEO_O_RES   : signed(VIDEO_O_TEMP'length +2 downto 0);
  signal VIDEO_O_BADi  : std_logic;                     
  signal VIDEO_O_DAVi  : std_logic;                     
  signal VIDEO_O_XSIZi : unsigned(PIX_BITS-1 downto 0);
  signal VIDEO_O_YSIZi : unsigned(LIN_BITS-1 downto 0);
  signal VIDEO_O_XCNTi : unsigned(PIX_BITS-1 downto 0);  
  signal VIDEO_O_YCNTi : unsigned(LIN_BITS-1 downto 0);

  -- Pipeline Signals
  signal VIDEO_I_DAVd : std_logic;
  signal VIDEO_I_DAVd1 : std_logic;
  signal VIDEO_I_DAVd2 : std_logic;
  signal VIDEO_I_DAVd3 : std_logic;
  
  -- Pipeline Signals
  signal GAIN_RDADDRd : std_logic_vector(RAMS_ADDR_WIDTH-1 downto 0);
  signal OFFM1_RDADDRd : std_logic_vector(RAMS_ADDR_WIDTH-1 downto 0);
  signal OFFM2_RDADDRd : std_logic_vector(RAMS_ADDR_WIDTH-1 downto 0);
  
  -- Pipeline Signals
  signal VIDEO_I_DATAd : std_logic_vector(VIDEO_I_DATA'range);
  signal VIDEO_I_DATAd1 : std_logic_vector(VIDEO_I_DATA'range);
  signal VIDEO_I_DATAd2 : std_logic_vector(VIDEO_I_DATA'range);
  signal VIDEO_I_DATAd3 : std_logic_vector(VIDEO_I_DATA'range);
  
  signal VIDEO_I_XCNT  :  std_logic_vector(PIX_BITS-1 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
  signal VIDEO_I_YCNT  :  std_logic_vector(LIN_BITS-1 downto 0);  -- Video Y Line  Counter (1st line  = 0)
  

  
  signal offset_matrix_rd_done : std_logic;
  
--  signal check_DMA_RDFSM :std_logic_vector(3 downto 0);
--  signal check_RAM_WRFSM :std_logic_vector(3 downto 0);
  
  signal temperature_offset : std_logic_vector(15 downto 0);
  signal temperature_diff : std_logic_vector(15 downto 0);
  
  signal start_div : std_logic;
  signal dvsr      : std_logic_vector(31 downto 0);
  signal dvnd      : std_logic_vector(31 downto 0);
  signal done_tick : STD_LOGIC;
  signal quo       : STD_LOGIC_VECTOR(31 downto 0);
  signal rmd       : STD_LOGIC_VECTOR(31 downto 0);
  signal mult_factor_temp : STD_LOGIC_VECTOR(31 downto 0);
  signal mult_factor1 : STD_LOGIC_VECTOR(31 downto 0);
  signal mult_factor2 : STD_LOGIC_VECTOR(31 downto 0);
  
  
  type TEMPERATURE_MEM_t is array (0 to 127) of std_logic_vector(15 downto 0);
  signal TEMPERATURE_MEM     : TEMPERATURE_MEM_t := (others => (others => '0'));
  

  signal TEMPERATURE_MEM_WR_ADDR : unsigned (7 downto 0);
  signal TEMPERATURE_MEM_RD_ADDR : unsigned (7 downto 0);
  signal temperature_write_data_temp : std_logic_vector(15 downto 0);
  signal temperature_mem_write_en : std_logic;
  
  signal sel_temp_range : std_logic_vector(1 downto 0);
--  signal sel_high_low_temp : std_logic;
  signal flag : std_logic;
  signal gain_flag: std_logic;
--  signal sel_temp_range_flag : std_logic;
  signal temperature_d : std_logic_vector(15 downto 0);
  signal gfid_gsk_update_temp_val1 : std_logic_vector(15 downto 0);
  signal gfid_gsk_update_temp_val2 : std_logic_vector(15 downto 0);
  signal update_gfid_gsk_check: std_logic;
  signal wait_frame_done : std_logic;

  signal sel_temp_range0_flag : std_logic;
  signal sel_temp_range1_flag : std_logic;
  signal sel_temp_range2_flag : std_logic;
  signal sel_temp_range3_flag : std_logic;
  signal range0_flag : std_logic;
  signal range1_flag : std_logic;
  signal range2_flag : std_logic;
  signal range3_flag : std_logic;

  
--  signal sel_temp_range_high_flag : std_logic;
--  signal sel_temp_range_low_flag : std_logic;
 
 
 --- OFFSET CALCULATION --------------------------------------------------------
 
  
  
--  signal OFFIMG1_SUM  : unsigned(33 downto 0);
--  signal OFFIMG2_SUM  : unsigned(33 downto 0); 
  signal OFFIMG1_AVG  : std_logic_vector(15 downto 0);
  signal OFFIMG2_AVG  : std_logic_vector(15 downto 0);

  

--  signal offimg1_dvnd      : std_logic_vector(33 downto 0);
--  signal offimg1_done_tick : STD_LOGIC;
--  signal offimg1_quo       : STD_LOGIC_VECTOR(33 downto 0);
  
--  signal offimg2_dvnd      : std_logic_vector(33 downto 0);
--  signal offimg2_done_tick : STD_LOGIC;
--  signal offimg2_quo       : STD_LOGIC_VECTOR(33 downto 0);

--  signal offimg_dvsr       : std_logic_vector(33 downto 0);
--  signal offimg_start_div : std_logic;
  
  signal APPLY_NUC1ptCalib_D: std_logic;
  
  signal update_offimg_avg : std_logic;
  
  signal VIDEO_I_V_D : std_logic;
  
  signal update_device_id_reg_en_d : std_logic;
------------------------------------------------------------------------------------  
--  ATTRIBUTE MARK_DEBUG : string;
--  ATTRIBUTE MARK_DEBUG of  offset_matrix_rd_done: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OFFM1_WRREQ: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OFFM2_WRREQ: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OFFM1_WRDATA: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OFFM2_WRDATA: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OFFM1_WRCNT: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OFFM2_WRCNT: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  check_DMA_RDFSM: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  check_RAM_WRFSM: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  TEMP_RANGE: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  VIDEO_O_RES: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  temperature_offset: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  temperature_diff: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  mult_factor1: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  VIDEO_O_YCNTi: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  TEMP_RANGE_D: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  mult_factor_temp : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  quo : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  TEMP_RANGE_DD: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  update_gfid_gsk_check : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  flag : SIGNAL IS "TRUE";

--  ATTRIBUTE MARK_DEBUG of  gfid_gsk_update_temp_val1 : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  gfid_gsk_update_temp_val2 : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OFFM2_RDDATA : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OFFM1_RDDATA : SIGNAL IS "TRUE";
  
  
--  ATTRIBUTE MARK_DEBUG of  VIDEO_I_V: SIGNAL IS "TRUE";  
--  ATTRIBUTE MARK_DEBUG of  VIDEO_I_H : SIGNAL IS "TRUE";  
--  ATTRIBUTE MARK_DEBUG of VIDEO_I_DAV :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of VIDEO_I_EOI: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of DMA_RDREADY: SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of done_tick : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of start_div : SIGNAL IS "TRUE";

--ATTRIBUTE MARK_DEBUG of TEMPERATURE            : SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of offset_matrix_rd_done  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_I_V              : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_I_H              : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_I_DAV            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_I_EOI            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of DMA_RDREADY            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of DMA_RDDAV              : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of OFFM1_WRREQ            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of OFFM2_WRREQ            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of mult_factor1           : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of ENABLE_NUC             : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of APPLY_NUC1ptCalib      : SIGNAL IS "TRUE";
----ATTRIBUTE MARK_DEBUG of offimg_start_div       : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of ENABLE_NUC_l           : SIGNAL IS "TRUE";   
--ATTRIBUTE MARK_DEBUG of VIDEO_I_DAVd2          : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_I_DAVd1          : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_I_DAVd           : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_O_DAVi           : SIGNAL IS "TRUE";
----ATTRIBUTE MARK_DEBUG of offimg1_done_tick      : SIGNAL IS "TRUE";
----ATTRIBUTE MARK_DEBUG of offimg2_done_tick      : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of OFFIMG2_AVG            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of OFFIMG1_AVG            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_O_RES            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of OFFM1_RDDATA           : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of OFFM2_RDDATA           : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of mult_factor2           : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_O_YCNTi          : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_O_XCNTi          : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of GAIN_RDDATA            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_I_DATA           : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of VIDEO_O_FSM            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of DMA_RDFSM              : SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of DMA_ADDR_START         : SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of DMA_RDDATA             : SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of DMA_ADDR_PICT          : SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of DMA_ADDR_BASE          : SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of DMA_ADDR_BASE_GAIN     : SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of DMA_ADDR_LIN           : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of dvnd                   : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of dvsr                   : SIGNAL IS "TRUE"; 
--------
begin
--------


--offimg_dvsr  <= std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE,offimg_dvsr'length));
sel_temp_range_out <= sel_temp_range;
--sel_high_low <= sel_high_low_temp;
--check_DMA_RDFSM <=     "0000" when DMA_RDFSM = s_IDLE else
--                       "0001" when DMA_RDFSM = s_WAIT_FOR_H else
--                       "0010" when DMA_RDFSM = s_COMPUTE_TEMPERATURE1 else
--                       "0011" when DMA_RDFSM = s_COMPUTE_TEMPERATURE2 else
--                       "0100" when DMA_RDFSM = s_COMPUTE_TEMPERATURE3 else
--                       "0101" when DMA_RDFSM = s_GET_GAIN_START_ADDR else
--                       "0110" when DMA_RDFSM = s_GET_GAIN_MATRIX else
--                       "0111" when DMA_RDFSM = s_GET_OFFSET_MATRIX_START_ADDR else
--                       "1000" when DMA_RDFSM = s_GET_OFFSET_MATRIX else
--                       "1001" when DMA_RDFSM = s_NEXT_LINE else
--                       "1010" when DMA_RDFSM = s_GET_LINE_PARAM  else
--                       "1111";
 
                       
--check_RAM_WRFSM  <=      "0000" when RAM_WRFSM = s_IDLE else
--                         "0001" when RAM_WRFSM = s_NEW_LINE else
--                         "0010" when RAM_WRFSM = s_STORE_GAIN_MATRIX else
--                         "0011" when RAM_WRFSM = s_STORE_OFFM1_MATRIX else
--                         "0100" when RAM_WRFSM = s_STORE_OFFM2_MATRIX  else
--                         "1111";



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

--process(CLK,RST)
--begin
--    if RST = '1' then
--        TEMPERATURE_MEM_WR_ADDR <= (others => '0');
--        temperature_write_data_temp <= (others => '0');
--        temperature_mem_write_en <= '0';
--    elsif rising_edge(CLK) then
--        if(temperature_write_data_valid = '1') then
--            temperature_write_data_temp <= temperature_write_data & temperature_write_data_temp(15 downto 8);
--            temperature_mem_write_en <= not temperature_mem_write_en;
--            if(temperature_mem_write_en = '1')then
--                TEMPERATURE_MEM(to_integer(TEMPERATURE_MEM_WR_ADDR)) <= temperature_write_data & temperature_write_data_temp(15 downto 8);
--                TEMPERATURE_MEM_WR_ADDR <= TEMPERATURE_MEM_WR_ADDR + 1;
--            else 
--                TEMPERATURE_MEM_WR_ADDR <= TEMPERATURE_MEM_WR_ADDR ;
--            end if;     
--        end if;
        
               
--    end if;
--end process;
process(CLK,RST)
begin
  if RST = '1' then
      TEMPERATURE_MEM_WR_ADDR <= (others => '0');
      temperature_write_data_temp <= (others => '0');
      temperature_mem_write_en <= '0';
      TEMPERATURE_MEM_RD_ADDR <= (others => '0');
      update_device_id_reg_en_d <= '0';
  elsif rising_edge(CLK) then
      update_device_id_reg_en_d <=update_device_id_reg_en;
      if(temperature_write_data_valid = '1') then
          temperature_write_data_temp <= temperature_write_data & temperature_write_data_temp(15 downto 8);
          temperature_mem_write_en <= not temperature_mem_write_en;
          if(temperature_mem_write_en = '1')then
              TEMPERATURE_MEM(to_integer(TEMPERATURE_MEM_WR_ADDR)) <= temperature_write_data & temperature_write_data_temp(15 downto 8);
              TEMPERATURE_MEM_WR_ADDR <= TEMPERATURE_MEM_WR_ADDR + 1;
          else 
              TEMPERATURE_MEM_WR_ADDR <= TEMPERATURE_MEM_WR_ADDR;
          end if;   
          temperature_rd_data_valid <= '0';  
      elsif(temperature_rd_rq = '1')then
           temperature_rd_data       <= TEMPERATURE_MEM(to_integer(TEMPERATURE_MEM_RD_ADDR));
           temperature_rd_data_valid <= '1';
           TEMPERATURE_MEM_RD_ADDR   <= TEMPERATURE_MEM_RD_ADDR + 1;
      elsif(temperature_wr_rq = '1')then
            TEMPERATURE_MEM(to_integer(unsigned(temperature_wr_addr)))<=  STORE_TEMP_AVG_FRAME;           
            temperature_rd_data_valid <= '0';
      elsif(update_device_id_reg_en = '1')then
            TEMPERATURE_MEM(126)<=  update_device_id_reg(15 downto 0);                  
      elsif(update_device_id_reg_en_d = '1')then
            TEMPERATURE_MEM(127)<=  update_device_id_reg(31 downto 16); 
      else      
            temperature_rd_data_valid <= '0';
      end if;
          
  end if;
end process;

  -- ---------------------------------
  --  DMA Master Read Process
  -- ---------------------------------
  -- This prepares the Data for Gain and Offset Matrixes
  -- This process is always computing with one line 
  -- in advance compared to the input video
  -- (vertical synchro is used to start preparing the 1st line)
  process(CLK, RST)
  variable TEMP_RANGE_SEL : unsigned(6 downto 0);
  begin
    if RST = '1' then
--      TEMP_CUR_s     <= (others => '0');
--      TEMP_RES_s     <= (others => '0');
--      TEMP_CALC      <= (others => '0');
--      TEMP_SQ        <= (others => '0');
      TEMP_RANGE     <= (others => '0');
      FIFO_CLR       <= '0';
      RAM_WRST       <= '0';
      DMA_RDREQ      <= '0';
      DMA_RDEND      <= (others => '0');
      DMA_ADDR_PIX   <= (others => '0');
      DMA_ADDR_LIN   <= (others => '0');
      DMA_ADDR_START <= (others => '0');
      DMA_ADDR_PICT  <= (others => '0');
      DMA_ADDR_BASE  <= (others => '0');
      DMA_RDFSM      <= s_IDLE;
      DMA_ADDR_BASE_GAIN <= unsigned(ADDR_GAIN_BADPIX_A);
      DMA_ADDR_BASE_GAIN_TEMP <= unsigned(ADDR_GAIN_BADPIX_A);
      offset_matrix_rd_done <= '0';
      mult_factor_temp  <= (others => '0');
      mult_factor1      <= (others => '0');
      mult_factor2      <= (others => '0');
      start_div         <= '0';
      dvnd              <= (others => '0');
      dvsr              <= (others => '1');
      update_gfid_gsk <= '0';
      update_gfid_gsk_check <= '0';
      flag            <= '0';
      new_gfid_gsk_start_addr <= (others => '0');
      temperature_d <= (others => '0');
      sel_temp_range <= "00";
--      sel_high_low_temp <= '0';
      wait_frame_done <= '0';
      gain_flag   <= '0';
      sel_temp_range0_flag <= '0';
      sel_temp_range1_flag <= '0';
      sel_temp_range2_flag <= '0';
      sel_temp_range3_flag <= '0';      
--      sel_temp_range_low_flag <= '0';
--      sel_temp_range_high_flag <= '0';
      range0_flag          <= '0'; 
      range1_flag          <= '0'; 
      range2_flag          <= '0'; 
      range3_flag          <= '0'; 

      CUR_TEMP_AREA  <= "00";
      CUR_GAIN_TABLE <= "000";
      CUR_OFFSET_TABLE <= (others=>'0');
      VIDEO_I_V_D <= '0';

    elsif rising_edge(CLK) then

      FIFO_CLR      <= '0';
      RAM_WRST      <= '0';
      update_gfid_gsk <= '0';
      update_gfid_gsk_check <= '0';
      VIDEO_I_V_D      <= VIDEO_I_V;
      
      if VIDEO_I_V_D = '1' then              
        start_div <= '1';
--        if( (wait_frame_done = '1') and (unsigned(temperature_d)> unsigned(TEMPERATURE_MEM(to_integer(unsigned(temperature_data_len) - 1)))) and (unsigned(temperature_d)< unsigned(TEMPERATURE_MEM(to_integer(unsigned(temperature_data_len) - 2))))) then
--            if flag = '1'then
--                dvnd <= x"0000" & x"0000";   -- dvnd = 2^16 * temperature_offset
--                dvsr <= x"0000" & x"0001";  
--            else      
--                dvnd <= x"ffff" & x"0000";   -- dvnd = 2^16 * temperature_offset
--                dvsr <= x"0000" & x"0001";                  
--            end if; 
--        else
--            dvnd <= temperature_offset & x"0000";   -- dvnd = 2^16 * temperature_offset
--            dvsr <= x"0000" & temperature_diff;
--        end if;
        
        dvnd <= temperature_offset & x"0000";   -- dvnd = 2^16 * temperature_offset
        dvsr <= x"0000" & temperature_diff;
        mult_factor2 <= mult_factor_temp;
        mult_factor1 <= std_logic_vector(to_unsigned(65535,32) - unsigned(mult_factor_temp)); -- mult_factor2 = 2^16-mult_factor_temp
        
      else
        start_div <= '0'; 
        if done_tick = '1' then
             mult_factor_temp <= quo;          
        end if;
      end if;
      
      
      
      
      
      case DMA_RDFSM is

        -- Wait for New Frame Flag to arrive here
        when s_IDLE =>
            DMA_RDREQ    <= '0';
            DMA_ADDR_PIX <= (others => '0');
            DMA_ADDR_LIN <= to_unsigned(1,DMA_ADDR_LIN'length);
            -- Enable this by uncommenting to use temperature table switch
            -- Computes the Offset Matrix abc to read depending the temperature
            -- if unsigned(TEMPERATURE)=DETECT_DATA1 then -->= signed(TEMP_A_MIN) and signed(TEMPERATURE) < signed(TEMP_A_MAX) then
              -- TEMP_RANGE <= "00";
            -- end if;
            -- if unsigned(TEMPERATURE)=DETECT_DATA2 then -->= signed(TEMP_B_MIN) and signed(TEMPERATURE) < signed(TEMP_B_MAX) then
              -- TEMP_RANGE <= "00";
            -- end if;
            -- if unsigned(TEMPERATURE)=DETECT_DATA3 then -->= signed(TEMP_C_MIN) and signed(TEMPERATURE) < signed(TEMP_C_MAX) then
              -- TEMP_RANGE <= "11";
            -- end if;
            -- if unsigned(TEMPERATURE)=DETECT_DATA4 then -->= signed(TEMP_D_MIN) and signed(TEMPERATURE) < signed(TEMP_D_MAX) then
              -- TEMP_RANGE <= "11";
            -- end if;
            --TEMP_RANGE <= "00"; -- Comment this when uncommenting the above portion of the code.
            --gfid_gsk_update_temp_val1  <= TEMPERATURE_MEM(to_integer(unsigned(temperature_data_len) - 2));
            --gfid_gsk_update_temp_val2  <= TEMPERATURE_MEM(to_integer(unsigned(temperature_data_len) - 1));
            
           temperature_d <= temperature;
 
           if (force_temp_range_en = '1')then
                if (force_temp_range = "11" and sel_temp_range3_flag = '0')then
                  update_gfid_gsk          <= '1';
                  new_gfid_gsk_start_addr  <= std_logic_vector(unsigned(TEMP_RANGE3_SENSOR_INIT_GFID_ADDR)) ; 
                 -- new_gfid_gsk_start_addr <= std_logic_vector(unsigned(sensor_init_data_len) - 2) ; 
                  sel_temp_range0_flag     <= '0'; 
                  sel_temp_range1_flag     <= '0'; 
                  sel_temp_range2_flag     <= '0'; 
                  sel_temp_range3_flag     <= '1'; 
                  sel_temp_range           <= "11";
                  DMA_ADDR_BASE_GAIN       <= unsigned(ADDR_GAIN_BADPIX_A);
                  DMA_ADDR_BASE_GAIN_TEMP  <= unsigned(ADDR_GAIN_BADPIX_A);
                  CUR_GAIN_TABLE           <= "011";
                  CUR_TEMP_AREA            <= "11";
                elsif (force_temp_range = "10" and sel_temp_range2_flag = '0')then
                  update_gfid_gsk          <= '1';
                  new_gfid_gsk_start_addr  <= std_logic_vector(unsigned(TEMP_RANGE2_SENSOR_INIT_GFID_ADDR)) ; 
                 -- new_gfid_gsk_start_addr <= std_logic_vector(unsigned(sensor_init_data_len) - 2) ; 
                  sel_temp_range0_flag     <= '0'; 
                  sel_temp_range1_flag     <= '0'; 
                  sel_temp_range2_flag     <= '1'; 
                  sel_temp_range3_flag     <= '0'; 
                  sel_temp_range           <= "10";
                  DMA_ADDR_BASE_GAIN       <= unsigned(ADDR_GAIN_BADPIX_A);
                  DMA_ADDR_BASE_GAIN_TEMP  <= unsigned(ADDR_GAIN_BADPIX_A);
                  CUR_GAIN_TABLE           <= "010";
                  CUR_TEMP_AREA            <= "10";
                elsif (force_temp_range = "01" and sel_temp_range1_flag = '0')then
                  update_gfid_gsk          <= '1';
                  new_gfid_gsk_start_addr  <= std_logic_vector(unsigned(TEMP_RANGE1_SENSOR_INIT_GFID_ADDR)) ; 
                 -- new_gfid_gsk_start_addr <= std_logic_vector(unsigned(sensor_init_data_len) - 2) ; 
                  sel_temp_range0_flag     <= '0'; 
                  sel_temp_range1_flag     <= '1'; 
                  sel_temp_range2_flag     <= '0'; 
                  sel_temp_range3_flag     <= '0'; 
                  sel_temp_range           <= "01";
                  DMA_ADDR_BASE_GAIN       <= unsigned(ADDR_GAIN_BADPIX_A);
                  DMA_ADDR_BASE_GAIN_TEMP  <= unsigned(ADDR_GAIN_BADPIX_A);
                  CUR_GAIN_TABLE           <= "001";
                  CUR_TEMP_AREA            <= "01";
                elsif (force_temp_range = "00" and sel_temp_range0_flag = '0')then
                  update_gfid_gsk          <= '1';
                  new_gfid_gsk_start_addr  <= std_logic_vector(unsigned(TEMP_RANGE0_SENSOR_INIT_GFID_ADDR)) ;
                  sel_temp_range0_flag     <= '1'; 
                  sel_temp_range1_flag     <= '0'; 
                  sel_temp_range2_flag     <= '0'; 
                  sel_temp_range3_flag     <= '0'; 
                  sel_temp_range           <= "00";
                  DMA_ADDR_BASE_GAIN       <= unsigned(ADDR_GAIN_BADPIX_A);
                  DMA_ADDR_BASE_GAIN_TEMP  <= unsigned(ADDR_GAIN_BADPIX_A);
                  CUR_GAIN_TABLE           <= "000";
                  CUR_TEMP_AREA            <= "00";
                end if;
                TEMP_RANGE_SEL := to_unsigned(14,7);
            else
                if(wait_frame_done ='1')then        
                  if(sel_temp_range = "00")then        
                    CUR_TEMP_AREA  <= "00";
                    if((unsigned(temperature)>=(unsigned(TEMPERATURE_MEM(10))))) then
                        if(unsigned(temperature)>=(unsigned(TEMPERATURE_MEM(0)))) then
                            TEMP_RANGE_SEL := to_unsigned(0,7);
                            temperature_offset <= x"0000";
                            temperature_diff   <= x"0001";
                            sel_temp_range     <= "00"; 
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(0)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(1))) then
                            TEMP_RANGE_SEL := to_unsigned(1,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(1)));
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(0)) - unsigned(TEMPERATURE_MEM(1)));
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(1)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(2))) then
                            TEMP_RANGE_SEL := to_unsigned(2,7); 
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(2)));
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(1)) - unsigned(TEMPERATURE_MEM(2)));                                
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(2)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(3))) then
                            TEMP_RANGE_SEL := to_unsigned(3,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(3)));
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(2)) - unsigned(TEMPERATURE_MEM(3)));                                
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(3)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(4))) then
                            TEMP_RANGE_SEL := to_unsigned(4,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(4)));
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(3)) - unsigned(TEMPERATURE_MEM(4)));
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(4)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(5))) then
                            TEMP_RANGE_SEL := to_unsigned(5,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(5)));
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(4)) - unsigned(TEMPERATURE_MEM(5)));    
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(5)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(6))) then
                            TEMP_RANGE_SEL := to_unsigned(6,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(6)));       
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(5)) - unsigned(TEMPERATURE_MEM(6))); 
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(6)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(7))) then
                            TEMP_RANGE_SEL := to_unsigned(7,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(7)));       
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(6)) - unsigned(TEMPERATURE_MEM(7)));
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(7)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(8))) then
                            TEMP_RANGE_SEL := to_unsigned(8,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(8)));       
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(7)) - unsigned(TEMPERATURE_MEM(8)));
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(8)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(9))) then
                            TEMP_RANGE_SEL := to_unsigned(9,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(9)));       
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(8)) - unsigned(TEMPERATURE_MEM(9)));
                        elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(9)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(10))) then
                            TEMP_RANGE_SEL := to_unsigned(10,7);
                            temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(10)));       
                            temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(9)) - unsigned(TEMPERATURE_MEM(10)));
                        end if;    
                    else    
                            sel_temp_range  <= "01"; 
                    end if;                     
                 elsif(sel_temp_range = "01")then              
                        CUR_TEMP_AREA  <= "01";
                        if(unsigned(temperature)>=unsigned(TEMPERATURE_MEM(24)))then
                            if(unsigned(temperature)>=(unsigned(TEMPERATURE_MEM(11)))) then
                                TEMP_RANGE_SEL := to_unsigned(11,7);
                                temperature_offset <= x"0000";
                                temperature_diff   <= x"0001";
                                sel_temp_range     <= "00";
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(11)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(12))) then
                                TEMP_RANGE_SEL := to_unsigned(12,7); 
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(12)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(11)) - unsigned(TEMPERATURE_MEM(12)));
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(12)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(13))) then
                                TEMP_RANGE_SEL := to_unsigned(13,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(13)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(12)) - unsigned(TEMPERATURE_MEM(13)));
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(13)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(14))) then
                                TEMP_RANGE_SEL := to_unsigned(14,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(14)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(13)) - unsigned(TEMPERATURE_MEM(14)));         
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(14)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(15))) then
                                TEMP_RANGE_SEL := to_unsigned(15,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(15)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(14)) - unsigned(TEMPERATURE_MEM(15)));
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(15)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(16))) then
                                TEMP_RANGE_SEL := to_unsigned(16,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(16)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(15)) - unsigned(TEMPERATURE_MEM(16)));                           
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(16)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(17))) then
                                TEMP_RANGE_SEL := to_unsigned(17,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(17)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(16)) - unsigned(TEMPERATURE_MEM(17))); 
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(17)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(18))) then
                                TEMP_RANGE_SEL := to_unsigned(18,7); 
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(18)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(17)) - unsigned(TEMPERATURE_MEM(18)));             
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(18)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(19))) then
                                TEMP_RANGE_SEL := to_unsigned(19,7); 
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(19)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(18)) - unsigned(TEMPERATURE_MEM(19)));                                   
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(19)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(20))) then
                                TEMP_RANGE_SEL := to_unsigned(20,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(20)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(19)) - unsigned(TEMPERATURE_MEM(20)));
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(20)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(21))) then
                                TEMP_RANGE_SEL := to_unsigned(21,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(21)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(20)) - unsigned(TEMPERATURE_MEM(21)));   
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(21)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(22))) then
                                TEMP_RANGE_SEL := to_unsigned(22,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(22)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(21)) - unsigned(TEMPERATURE_MEM(22)));
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(22)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(23))) then
                                TEMP_RANGE_SEL := to_unsigned(23,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(23)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(22)) - unsigned(TEMPERATURE_MEM(23)));                          
                            elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(23)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(24))) then
                                TEMP_RANGE_SEL := to_unsigned(24,7);
                                temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(24)));       
                                temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(23)) - unsigned(TEMPERATURE_MEM(24)));
                            end if; 
                         else    
                                sel_temp_range  <= "10"; 
                         end if;                  
                    elsif(sel_temp_range = "10")then
                             CUR_TEMP_AREA  <= "10";
                             if(unsigned(temperature)>=unsigned(TEMPERATURE_MEM(37)))then
                                 if(unsigned(temperature)>=(unsigned(TEMPERATURE_MEM(25)))) then
                                     TEMP_RANGE_SEL := to_unsigned(25,7);
                                     temperature_offset <= x"0000";
                                     temperature_diff   <= x"0001";
                                     sel_temp_range     <= "01";
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(25)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(26))) then
                                     TEMP_RANGE_SEL := to_unsigned(26,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(26)));       
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(25)) - unsigned(TEMPERATURE_MEM(26)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(26)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(27))) then
                                     TEMP_RANGE_SEL := to_unsigned(27,7); 
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(27)));       
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(26)) - unsigned(TEMPERATURE_MEM(27)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(27)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(28))) then
                                     TEMP_RANGE_SEL := to_unsigned(28,7); 
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(28)));       
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(27)) - unsigned(TEMPERATURE_MEM(28)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(28)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(29))) then
                                     TEMP_RANGE_SEL := to_unsigned(29,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(29)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(28)) - unsigned(TEMPERATURE_MEM(29)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(29)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(30))) then
                                     TEMP_RANGE_SEL := to_unsigned(30,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(30)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(29)) - unsigned(TEMPERATURE_MEM(30)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(30)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(31))) then
                                     TEMP_RANGE_SEL := to_unsigned(31,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(31)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(30)) - unsigned(TEMPERATURE_MEM(31)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(31)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(32))) then
                                     TEMP_RANGE_SEL := to_unsigned(32,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(32)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(31)) - unsigned(TEMPERATURE_MEM(32)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(32)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(33))) then
                                     TEMP_RANGE_SEL := to_unsigned(33,7);  
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(33)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(32)) - unsigned(TEMPERATURE_MEM(33)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(33)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(34))) then
                                     TEMP_RANGE_SEL := to_unsigned(34,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(34)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(33)) - unsigned(TEMPERATURE_MEM(34))); 
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(34)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(35))) then
                                     TEMP_RANGE_SEL := to_unsigned(35,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(35)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(34)) - unsigned(TEMPERATURE_MEM(35)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(35)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(36))) then
                                     TEMP_RANGE_SEL := to_unsigned(36,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(36)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(35)) - unsigned(TEMPERATURE_MEM(36)));
                                 elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(36)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(37))) then
                                     TEMP_RANGE_SEL := to_unsigned(37,7);
                                     temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(37)));        
                                     temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(36)) - unsigned(TEMPERATURE_MEM(37)));
                                 end if;
                             else    
                                 sel_temp_range  <= "11"; 
                             end if;                 
                          else              
                             CUR_TEMP_AREA  <= "11";
                             if(unsigned(temperature)>=unsigned(TEMPERATURE_MEM(38)))then 
                                 TEMP_RANGE_SEL := to_unsigned(38,7);
                                 temperature_offset <= x"0000";          
                                 temperature_diff   <= x"0001";
                                 sel_temp_range     <= "10";        
                             elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(38)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(39))) then
                                 TEMP_RANGE_SEL := to_unsigned(39,7);
                                 temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(39)));        
                                 temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(38)) - unsigned(TEMPERATURE_MEM(39)));         
                             elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(39)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(40))) then
                                 TEMP_RANGE_SEL := to_unsigned(40,7);
                                 temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(40)));        
                                 temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(39)) - unsigned(TEMPERATURE_MEM(40)));         
                             elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(40)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(41))) then
                                 TEMP_RANGE_SEL := to_unsigned(41,7);
                                 temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(41)));        
                                 temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(40)) - unsigned(TEMPERATURE_MEM(41)));         
                             elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(41)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(42))) then
                                 TEMP_RANGE_SEL := to_unsigned(42,7);
                                 temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(42)));        
                                 temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(41)) - unsigned(TEMPERATURE_MEM(42)));         
                             elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(42)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(43))) then
                                 TEMP_RANGE_SEL := to_unsigned(43,7);
                                 temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(43)));        
                                 temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(42)) - unsigned(TEMPERATURE_MEM(43)));         
                             elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(43)) and unsigned(temperature)>= unsigned(TEMPERATURE_MEM(44))) then
                                 TEMP_RANGE_SEL := to_unsigned(44,7);
                                 temperature_offset <=  std_logic_vector(unsigned(temperature) - unsigned(TEMPERATURE_MEM(44)));        
                                 temperature_diff   <=  std_logic_vector(unsigned(TEMPERATURE_MEM(43)) - unsigned(TEMPERATURE_MEM(44)));         
                             elsif(unsigned(temperature)<unsigned(TEMPERATURE_MEM(44))) then
                                 TEMP_RANGE_SEL := to_unsigned(44,7);
                                 temperature_offset <= x"0000";          
                                 temperature_diff <= x"0001"; 
                                 sel_temp_range  <= "11";                                     
                             end if;                            
                         end if;
                     else
                       TEMP_RANGE_SEL := to_unsigned(14,7);
                     end if;    
                 end if;
            
--            if(PIX_OFFSET(31) = '1')then
--                TEMP_RANGE_D <= TEMP_RANGE_SEL - unsigned(PIX_OFFSET(6 downto 0));
--            else
--                TEMP_RANGE_D <= TEMP_RANGE_SEL + unsigned(PIX_OFFSET(6 downto 0));
--            end if;

            if(PIX_OFFSET(31) = '1')then
                TEMP_RANGE_D <= unsigned(PIX_OFFSET(6 downto 0));
                CUR_OFFSET_TABLE <= PIX_OFFSET(6 downto 0);
                temperature_offset <= x"0000";          
                temperature_diff <= x"0001";
            else
                TEMP_RANGE_D <= TEMP_RANGE_SEL;
                CUR_OFFSET_TABLE <= std_logic_vector(TEMP_RANGE_SEL);
            end if;
            
--            TEMP_RANGE_D <= TEMP_RANGE_SEL;
--            CUR_OFFSET_TABLE <= std_logic_vector(TEMP_RANGE_SEL);             
             --TEMP_RANGE_D <= TEMP_RANGE_SEL;
            --TEMP_RANGE <= temp_range_gen(TEMPERATURE) + unsigned(PIX_OFFSET(5 downto 0));
            
            --TEMP_RANGE <= TEMP_RANGE_SEL + unsigned(PIX_OFFSET(6 downto 0));
            
            -- New Frame is arriving !
            if VIDEO_I_V = '1' and (ENABLE_NUC = '1' or ENABLE_BADPIX = '1') then
            --XSIZE is latched in VIDEO_O_XSIZi (see process below)
              FIFO_CLR   <= '1';
--              TEMP_CUR_s <= signed('0' & TEMPERATURE); -- Latch current Temperature
              DMA_RDFSM  <= s_WAIT_FOR_H;
              offset_matrix_rd_done <= '0';
              APPLY_NUC1ptCalib_D <= APPLY_NUC1ptCalib;
--              TEMP_RANGE_DD <= TEMP_RANGE_D;
--              TEMP_RANGE    <= TEMP_RANGE_DD;        
            end if;
            
            

          when s_WAIT_FOR_H =>
            if VIDEO_I_H = '1' then
              DMA_RDFSM <= s_COMPUTE_TEMPERATURE1;
            end if;

        -- Compute the signed Temperature between -128 and +127
        -- Tonbo Board ADC Temperature measures give :
        -- -40° => TEMPERATURE = 60618
        --   0° => TEMPERATURE = 62585
        -- +60° => TEMPERATURE = 65535
        -- We have 100° of amplitude for an ADC amplitude of (65535 - 60618) = 4917
        -- Formula is :  (TEMPERATURE - 62585) / ((65535 - 60618) / 100) 
        -- Formula is :  (TEMPERATURE - 62585) / 49.17 
        -- Formula is : ((TEMPERATURE - 62585) * 1333) / 2^16 (for HW implementation)
        -- Formula is : ((TEMPERATURE - 62585) * 1333) / 2^14 (for HW implementation and format 8.2)
        
-- (Following states do nothing when we are using cooled cameras, as temperature does not have any effects on tables.)        
-- (You might need to modify this accordingly when different temperature is used.)
        -- First compute : TEMPERATURE - 62585
        when s_COMPUTE_TEMPERATURE1 =>
            --TEMP_RANGE <= "01";
--            TEMP_CUR_s <= TEMP_CUR_s - 62585;
            DMA_RDFSM  <= s_COMPUTE_TEMPERATURE2;

        -- Then compute : (TEMPERATURE - 62585) * 1333
        -- (TEMPERATURE - 62585) is kept on 14bits only, this is enough
        when s_COMPUTE_TEMPERATURE2 =>
--            TEMP_RES_s <= TEMP_CUR_s(13 downto 0) * to_signed(1333, 12);
            DMA_RDFSM  <= s_COMPUTE_TEMPERATURE3;

        -- Then compute : ((TEMPERATURE - 62585) * 1333) / 2**14 (format 8.2 signed)
        when s_COMPUTE_TEMPERATURE3 =>
            -- Temperature on 10 bits, format  signed
--            TEMP_CALC <= TEMP_RES_s(23 downto 14);  
            -- Computing here the (Temperature)² T*T
--            TEMP_SQ  <= TEMP_RES_s(23 downto 14) * TEMP_RES_s(23 downto 14);
            -- Go Compute the Line Start Address for Gain Matrix
            DMA_RDFSM <= s_GET_GAIN_START_ADDR;

--   (DDR3 Memory access through avalon buffer starts here. )            
        -- Computing here the Next line Start Address (VIDEO_O_XSIZi  )
        when s_GET_GAIN_START_ADDR =>
            DMA_ADDR_START <= DMA_ADDR_LIN * to_unsigned(to_integer(VIDEO_O_XSIZi)*2, DMA_ADDR_PIX'length); -- 2 bytes of Gain data . Therefore Xsize*2 bytes.
            DMA_RDFSM      <= s_GET_GAIN_MATRIX;

        -- Read the Gain Matrix values here
        when s_GET_GAIN_MATRIX =>
            RAM_WRST      <= '1';  -- Will start the RAM_WRFSM !
            --DMA_ADDR_BASE <= unsigned(ADDR_GAIN_BADPIX_A);   -- Comment this line when you need to use it on uncooled sytems.
            DMA_ADDR_BASE <= DMA_ADDR_BASE_GAIN;
            -- and Uncomment the following peice of code.
            -- case TEMP_RANGE is
              --when "00" => DMA_ADDR_BASE <= ADDR_GAIN_BADPIX_A;
              --when "01" => DMA_ADDR_BASE <= ADDR_GAIN_BADPIX_B;
              --when "10" => DMA_ADDR_BASE <= ADDR_GAIN_BADPIX_C;
              -- when "11" => DMA_ADDR_BASE <= ADDR_GAIN_BADPIX_B;
              -- when others => null;
            -- end case;
            DMA_ADDR_PICT <= DMA_ADDR_START;  -- start address
            DMA_RDREQ     <= '1';  -- initiate the Read in Memory
            DMA_RDFSM     <= s_GET_LINE_PARAM;
            DMA_RDEND     <= to_unsigned(to_integer(VIDEO_O_XSIZi)*2, DMA_RDEND'length);  -- 2 bytes of Gain data per pixel is needed. Therefore Xsize*2 bytes.
            DMA_RDGOTO    <= s_GET_OFFSET_MATRIX_START_ADDR;

        -- Computing here the Next line Start Address 
        when s_GET_OFFSET_MATRIX_START_ADDR =>
            DMA_ADDR_START <= DMA_ADDR_LIN * to_unsigned(to_integer(VIDEO_O_XSIZi)*2, DMA_ADDR_PIX'length); -- 4 bytes of offset data. Therefore Xsize*4 bytes.
            DMA_RDFSM      <= s_GET_OFFSET_MATRIX;

        -- Read the Offset Matrix (a,b,c) values here
        when s_GET_OFFSET_MATRIX =>        
            --DMA_ADDR_BASE <= unsigned(ADDR_OFFM_TEMP_A);  -- Comment this line when you need to use it on uncooled sytems.
            -- and Uncomment the following peice of code.
            -- case TEMP_RANGE is
              -- when "00" => DMA_ADDR_BASE <= ADDR_OFFM_TEMP_A;
              --when "01" => DMA_ADDR_BASE <= ADDR_OFFM_TEMP_B;
              --when "10" => DMA_ADDR_BASE <= ADDR_OFFM_TEMP_C;
              -- when "11" => DMA_ADDR_BASE <= ADDR_OFFM_TEMP_B;
              -- when others => null;
            -- end case;
            offset_matrix_rd_done <= '1';
            
            
            if APPLY_NUC1ptCalib_D = '1' then
                DMA_ADDR_BASE <= unsigned(ADDR_OFFM_NUC1PT);
                CUR_OFFSET_TABLE <= "1111111";         
            else
                if(offset_matrix_rd_done = '1')then
                    DMA_ADDR_BASE <= DMA_ADDR_BASE - ADDR_OFFM_OFFSET;
                else
                    DMA_ADDR_BASE <= get_offset_addr(TEMP_RANGE);
                end if;
            end if;    
            DMA_ADDR_PICT <= DMA_ADDR_START;
            DMA_RDREQ  <= '1';  -- initiate the Read in Memory
            DMA_RDFSM  <= s_GET_LINE_PARAM;
            DMA_RDEND  <= to_unsigned(to_integer(VIDEO_O_XSIZi)*2, DMA_RDEND'length);  -- *4, because 4 bytes of offset data per pixel needed
            
            if(offset_matrix_rd_done = '1')then
                DMA_RDGOTO <= s_NEXT_LINE;
            else    
                DMA_RDGOTO <= s_GET_OFFSET_MATRIX_START_ADDR;
            end if;      
        -- Wait for next line
        when s_NEXT_LINE =>  
            if VIDEO_I_H = '1' then   -- Next line
              FIFO_CLR   <= '1';  -- to be sure we always restart from an empty fifo
              DMA_ADDR_PIX <= (others => '0');
              offset_matrix_rd_done <= '0';
              if (unsigned(DMA_ADDR_LIN)=(unsigned(VIDEO_O_YSIZi)-1)) then
                DMA_ADDR_LIN<= to_unsigned(0,DMA_ADDR_LIN'length);
                --TEMP_RANGE_DD <= TEMP_RANGE_D; 
                TEMP_RANGE    <= TEMP_RANGE_D; 
                wait_frame_done <= '1';
              if(wait_frame_done = '1')then 
                  if (sel_temp_range = "11" and range3_flag = '0' and force_temp_range_en = '0')then
                     update_gfid_gsk         <= '1';
                     new_gfid_gsk_start_addr <= std_logic_vector(unsigned(TEMP_RANGE3_SENSOR_INIT_GFID_ADDR)) ; 
                     range0_flag    <= '0'; 
                     range1_flag    <= '0'; 
                     range2_flag    <= '0'; 
                     range3_flag    <= '1';  
                     DMA_ADDR_BASE_GAIN      <= unsigned(ADDR_GAIN_BADPIX_A);
                     DMA_ADDR_BASE_GAIN_TEMP <= unsigned(ADDR_GAIN_BADPIX_A);
                     CUR_GAIN_TABLE          <= "011";
                  elsif (sel_temp_range = "10" and  range2_flag = '0' and force_temp_range_en = '0')then
                     update_gfid_gsk         <= '1';
                     new_gfid_gsk_start_addr <= std_logic_vector(unsigned(TEMP_RANGE2_SENSOR_INIT_GFID_ADDR)) ; 
                     range0_flag    <= '0'; 
                     range1_flag    <= '0'; 
                     range2_flag    <= '1'; 
                     range3_flag    <= '0';  
                     DMA_ADDR_BASE_GAIN      <= unsigned(ADDR_GAIN_BADPIX_A);
                     DMA_ADDR_BASE_GAIN_TEMP <= unsigned(ADDR_GAIN_BADPIX_A);
                     CUR_GAIN_TABLE          <= "010";
                  elsif (sel_temp_range = "01" and  range1_flag = '0' and force_temp_range_en = '0')then
                    update_gfid_gsk         <= '1';
                    new_gfid_gsk_start_addr <= std_logic_vector(unsigned(TEMP_RANGE1_SENSOR_INIT_GFID_ADDR)) ; 
                    range0_flag    <= '0'; 
                    range1_flag    <= '1'; 
                    range2_flag    <= '0'; 
                    range3_flag    <= '0'; 
                    DMA_ADDR_BASE_GAIN      <= unsigned(ADDR_GAIN_BADPIX_A);
                    DMA_ADDR_BASE_GAIN_TEMP <= unsigned(ADDR_GAIN_BADPIX_A);
                    CUR_GAIN_TABLE          <= "001";
                  elsif (sel_temp_range = "00" and  range0_flag = '0' and force_temp_range_en = '0')then
                    update_gfid_gsk         <= '1';
                    new_gfid_gsk_start_addr <= std_logic_vector(unsigned(TEMP_RANGE0_SENSOR_INIT_GFID_ADDR)) ;
                    range0_flag    <= '1'; 
                    range1_flag    <= '0'; 
                    range2_flag    <= '0'; 
                    range3_flag    <= '0'; 
                    DMA_ADDR_BASE_GAIN      <= unsigned(ADDR_GAIN_BADPIX_A);
                    DMA_ADDR_BASE_GAIN_TEMP <= unsigned(ADDR_GAIN_BADPIX_A);
                    CUR_GAIN_TABLE          <= "000";
                  else
                      if(GAIN_TABLE_SEL = '1')then
                          DMA_ADDR_BASE_GAIN <= unsigned(ADDR_GAIN);
                          CUR_GAIN_TABLE  <= "100";
                          if(gain_flag = '0')then
                              DMA_ADDR_BASE_GAIN_TEMP <= DMA_ADDR_BASE_GAIN;
                              gain_flag <= '1';
                          else
                              DMA_ADDR_BASE_GAIN_TEMP <= DMA_ADDR_BASE_GAIN_TEMP;
                          end if;    
                      else
                          gain_flag <= '0';
                          DMA_ADDR_BASE_GAIN <= DMA_ADDR_BASE_GAIN_TEMP; 
                      end if;
                    end if;
                 end if;               
              else
                DMA_ADDR_LIN <= DMA_ADDR_LIN + 1;
              end if;
              DMA_RDFSM    <= s_GET_GAIN_START_ADDR;
            end if;                 
--                if(wait_frame_done = '1')then  
--                    if(unsigned(temperature_d)<= unsigned(TEMPERATURE_MEM(to_integer(unsigned(temperature_data_len) - 1)))) then
--                        if flag ='0' then
--                            update_gfid_gsk <= '1';
--                            update_gfid_gsk_check <= '1';
--                            flag <= not flag;    
--                        end if;    
--                        new_gfid_gsk_start_addr <= std_logic_vector(unsigned(sensor_init_data_len) - 3) ;    
--                    elsif(unsigned(temperature_d)>= unsigned(TEMPERATURE_MEM(to_integer(unsigned(temperature_data_len) - 2)))) then
--                        if flag = '1' then
--                            update_gfid_gsk <= '1';
--                            update_gfid_gsk_check <= '1';
--                            flag <= not flag;
--                        end if;
--                        new_gfid_gsk_start_addr <= std_logic_vector(unsigned(sensor_init_data_len) - 6) ; 
--                    end if;
--                end if;     
                
--              else
--                DMA_ADDR_LIN <= DMA_ADDR_LIN + 1;
--              end if;
--              DMA_RDFSM    <= s_GET_GAIN_START_ADDR;
--            end if;

        -- Common Routine : Make Read requests from DDR3/SRAM memory for "a Line of Parameters"
        when s_GET_LINE_PARAM =>
            
            if DMA_RDREADY = '1' then -- Read Accepted
              DMA_ADDR_PICT <= DMA_ADDR_PICT + RD_SIZE*4;   --*8 because 8 bytes are read at once(64 bit data bus)
              if DMA_ADDR_PIX + RD_SIZE*4 = DMA_RDEND then  -- End of Reading this line
                DMA_RDREQ    <= '0';  ---**************** DMA_RDREQ    <= '0';
                DMA_ADDR_PIX <= (others => '0');
                DMA_RDFSM    <= DMA_RDGOTO;
              else
                DMA_ADDR_PIX <= DMA_ADDR_PIX  + RD_SIZE*4;  --*8 because 8 bytes are read at once(64 bit data bus)
                DMA_RDREQ <= '1';
                DMA_RDFSM    <= s_GET_LINE_PARAM;
              end if;
            else
              DMA_ADDR_PICT<=DMA_ADDR_PICT;
              DMA_RDREQ <= '1';
              DMA_RDFSM    <= s_GET_LINE_PARAM;
            end if;

      end case;
                  
      -- Clear FSM on End Of Image
      if VIDEO_I_EOI = '1' then 
        DMA_RDFSM <= s_IDLE;
      end if;
      
    end if;
  end process;


  -- -----------------------
  --  DMA Read Outputs
  -- -----------------------
  DMA_RDADDR <= std_logic_vector(DMA_ADDR_BASE + DMA_ADDR_PICT);   
  DMA_RDSIZE <= std_logic_vector(to_unsigned(RD_SIZE, DMA_RDSIZE'length));

                   
  -- Capture data from DDR3/SRAM and store it in internal FIFO to 
  -- absorb the DDR3/SRAM burst and variable latencies.

  -- -----------------------------------------------------
  --  NUC FIFO to store Matrix data before processing 
  -- -----------------------------------------------------
  FIFO_WR <= DMA_RDDAV ;        
  FIFO_IN <= DMA_RDDATA;  
  --
  i_NUC_FIFO : entity WORK.FIFO_GENERIC_SC
    generic map (
      FIFO_DEPTH => FIFO_DEPTH,
      FIFO_WIDTH => FIFO_WSIZE,
      SHOW_AHEAD => false      ,
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
      
  assert not ( FIFO_FUL = '1' and FIFO_WR = '1' )
    report "[NUC] WRITE while FIFO Full !!!" severity failure;

--  Fetch data from FIFO and Fill up the pingpong line buffers for Gain and Offset Data

  -- -------------------------------------------------------
  --  Storing Gain & Offset Matrix Values in internal RAMs
  -- -------------------------------------------------------
  -- This prepares the Data for Gain and Offset Matrixes
  -- This process is always computing with one line 
  -- in advance compared to the input video
  -- (vertical synchro is used to start preparing the 1st line)
  RAM_WR_process : process(CLK, RST)
--    variable vOFFM_RES : signed(OFFM_RES'length downto 0);
  begin
    if RST = '1' then
      FIFO_SEL    <= "00";
      FIFO_SEL2   <= '0';
      FIFO_RD     <= '0';
      GAIN_WRREQ  <= '0';  
      GAIN_WRCNT  <= (others => '0');  
--      OFFM_NEW    <= '0';
--      OFFM_DAV    <= '0';
--      OFFM_DAV2   <= '0';
--      OFFM_A      <= (others => '0');
--      OFFM_B      <= (others => '0');
--      OFFM_MUL1_O <= (others => '0');
--      OFFM_MUL2_O <= (others => '0');
--      OFFM_MUL2_m <= (others => '0');
--      OFFM_ACCUM  <= (others => '0');      
--      OFFM_RES    <= (others => '0');      
      OFFM1_WRREQ  <= '0';  
      OFFM1_WRCNT  <= (others => '0');  
      OFFM2_WRREQ  <= '0';  
      OFFM2_WRCNT  <= (others => '0'); 

      RAM_WRSEL   <= '0';
      RAM_WRFSM   <= s_IDLE;
    elsif rising_edge(CLK) then

      FIFO_RD     <= '0';
      GAIN_WRREQ  <= '0'; 
      OFFM1_WRREQ <= '0';
      OFFM2_WRREQ <= '0';

      if RAM_WRFSM=s_STORE_GAIN_MATRIX and FIFO_EMP='0' then
       GAIN_WRREQ <= FIFO_RD;
      end if;

      if RAM_WRFSM=s_STORE_OFFM1_MATRIX and FIFO_EMP='0' then
       OFFM1_WRREQ <= FIFO_RD;
      end if;
      
      if RAM_WRFSM=s_STORE_OFFM2_MATRIX and FIFO_EMP='0' then
       OFFM2_WRREQ <= FIFO_RD;
      end if;

      
      -- Gain Matrix Write Pointer
      if GAIN_WRREQ = '1' then
        GAIN_WRCNT <= GAIN_WRCNT + 1;  
      end if;
      
      -- Offset Matrix Write Pointer
      if OFFM1_WRREQ = '1' then
        OFFM1_WRCNT <= OFFM1_WRCNT + 1;  
      end if;

      if OFFM2_WRREQ = '1' then
        OFFM2_WRCNT <= OFFM2_WRCNT + 1;  
      end if;
      
      case RAM_WRFSM is

        -- Wait for the New Frame Start 
        when s_IDLE =>
            if VIDEO_I_V = '1' and (ENABLE_NUC = '1' or ENABLE_BADPIX = '1') then
              RAM_WRSEL <= '0';  -- so that the 1st line is stored in buffer 0  
              RAM_WRFSM <= s_NEW_LINE;
            end if;

        -- Wait for the Start Flag, or End Of Image
        when s_NEW_LINE =>
            if RAM_WRST = '1' then
              FIFO_SEL   <= "00";
              FIFO_SEL2  <= '0';
              GAIN_WRCNT <= (others => '0');  
              OFFM1_WRCNT <= (others => '0');  
              OFFM2_WRCNT <= (others => '0');
              RAM_WRSEL  <= not RAM_WRSEL;  
              RAM_WRFSM  <= s_STORE_GAIN_MATRIX;
            end if;

        -- Store the Gain Matrix in RAM
        -- Extracting 64bits word from FIFO = 4 16bits Gain (+ bad pixel) Values
        when s_STORE_GAIN_MATRIX =>
            if GAIN_WRREQ='1' and GAIN_WRCNT = VIDEO_O_XSIZi/2-1 then  -- End of Line !-- Since there are 640*16/64 Reads
              RAM_WRFSM <= s_STORE_OFFM1_MATRIX;
            elsif FIFO_EMP = '0' then 
                FIFO_RD     <= '1';
            end if;

        -- Extracting two 16bits word from FIFO to get a,b,c Values
        -- Store the Offset Matrix in RAM
        -- Computing the Offset Matrix Values
        when s_STORE_OFFM1_MATRIX =>
            if OFFM1_WRREQ='1' and OFFM1_WRCNT = VIDEO_O_XSIZi/2-1 then  -- End of Line !-- Since there are 640*32/64 Reads
              RAM_WRFSM <= s_STORE_OFFM2_MATRIX;
            elsif FIFO_EMP = '0'  then
              FIFO_RD     <= '1';
            end if;
        
        
        when s_STORE_OFFM2_MATRIX =>
            if OFFM2_WRREQ='1' and OFFM2_WRCNT = VIDEO_O_XSIZi/2-1 then  -- End of Line !-- Since there are 640*32/64 Reads
              RAM_WRFSM <= s_NEW_LINE;
            elsif FIFO_EMP = '0'  then
              FIFO_RD     <= '1';
            end if;
            

      end case;

      -- Clear FSM on End Of Image
      if VIDEO_I_EOI = '1' then 
        RAM_WRFSM <= s_IDLE;
      end if;
      
      -- Uncomment following piece of code and for uncooled systems. Necessary pipeline signals 
      -- might change to accomodate the extra clock cycle for offset generation using temp data.

      -- ------------------------------------------------------------------
      --  Computing the Offset Matrix Values : OM(I,j) = a*T²+b*T+C
      -- ------------------------------------------------------------------
      -- This computation can process a new (a,b,c) input on each clock cycle
      -- Pipelined in 3 steps
      -- Output truncated on 14bits
      
      --OFFM_DAV   <= '0';
      --OFFM_DAV2  <= '0';
      --OFFM_WRREQ <= '0';  
      ---- Step 1
      --if OFFM_NEW = '1' then  -- New a,b,c values
      --  OFFM_DAV    <= '1';
      --  OFFM_MUL1_O <= OFFM_A * TEMP_SQ;   -- a*T²
      --  OFFM_MUL2_O <= OFFM_B * TEMP_CALC; -- b*T
      --  OFFM_ACCUM  <= resize(OFFM_C, OFFM_ACCUM'length);  -- load result with C
      --end if;
      ---- Step 2
      --if OFFM_DAV = '1' then 
      --  OFFM_DAV2   <= '1';
      --  OFFM_MUL2_m <= OFFM_MUL2_O;              -- memorize b*T
      --  OFFM_RES    <= OFFM_ACCUM ;--+ OFFM_MUL1_O(OFFM_MUL1_O'high downto 4); -- a*T² + c 
      --end if;
      ---- Step 3, with saturation
      --if OFFM_DAV2 = '1' then 
      --  OFFM_WRREQ <= '1';
      --  -- Computation
      --  vOFFM_RES := resize(OFFM_RES, vOFFM_RES'length);-- + OFFM_MUL2_m(OFFM_MUL2_m'high downto 2); -- a*T² + b*T + c
      -- -- Since there are 640*16/64 ReadsSaturation
      --  --if vOFFM_RES > 2**(OFFM_WRDATA'length-1)-1 then
      --  --  OFFM_WRDATA <= std_logic_vector(to_signed(2**(OFFM_WRDATA'length-1)-1, OFFM_WRDATA'length)); 
      --  --elsif vOFFM_RES < -2**(OFFM_WRDATA'length-1) then
      --  --  OFFM_WRDATA <= std_logic_vector(to_signed(-2**(OFFM_WRDATA'length-1), OFFM_WRDATA'length)); 
      --  --else
      --    OFFM_WRDATA <= std_logic_vector(vOFFM_RES(OFFM_WRDATA'length-1 downto 0)); 
      --  --end if;
      --end if;
            
    end if;
  end process RAM_WR_process;

    ---- Double Line Buffer for Gain Matrix

  GAIN_WRDATA <= FIFO_OUT;
  OFFM1_WRDATA <= FIFO_OUT;
  OFFM2_WRDATA <= FIFO_OUT;

  GAIN_MATRIX_DBLINE : entity WORK.SPRAM_GENERIC_DC_MIXED
    generic map (
      RD_ADDR_WIDTH => RAMS_ADDR_WIDTH,  -- RAM Address Width
      WR_ADDR_WIDTH => RAMS_ADDR_WIDTH-1, -- since read data port is 4 times smaller
      RD_DATA_WIDTH => GAIN_DATA_WIDTH,  -- RAM Data Width
      WR_DATA_WIDTH => FIFO_WSIZE,
      OUTPUT_REG => true              -- Output Registered if True
    )
    port map (
      CLK       => CLK,
      -- Port A - Write Only
      WR_WRREQ  => GAIN_WRREQ     ,
      WR_ADDR   => GAIN_WRADDR    ,
      WR_WRDATA => GAIN_WRDATA    ,

      -- Port B - Read Only  
      RD_ADDR   => GAIN_RDADDRd   ,
      RD_RDDATA => GAIN_RDDATA
    );

  GAIN_WRADDR <= RAM_WRSEL & std_logic_vector(GAIN_WRCNT);
  GAIN_RDADDR <= RAM_RDSEL & std_logic_vector(RAM_RDCNT);


  OFFSET_MATRIX1_DBLINE : entity WORK.SPRAM_GENERIC_DC_MIXED
    generic map (
      RD_ADDR_WIDTH => RAMS_ADDR_WIDTH,  -- RAM Address Width
      WR_ADDR_WIDTH => RAMS_ADDR_WIDTH-1, -- since read data port is 2 times smaller
      RD_DATA_WIDTH => OFFM_DATA_WIDTH,  -- RAM Data Width
      WR_DATA_WIDTH => FIFO_WSIZE,
      OUTPUT_REG => true              -- Output Registered if True
    )
    port map (
      -- Port A - Write Only
      CLK      => CLK            ,
      WR_WRREQ  => OFFM1_WRREQ     ,
      WR_ADDR   => OFFM1_WRADDR    ,
      WR_WRDATA => OFFM1_WRDATA    ,
      -- Port B - Read Only
      RD_ADDR   => OFFM1_RDADDRd    ,
      RD_RDDATA => OFFM1_RDDATA
    );

  OFFM1_WRADDR <= RAM_WRSEL & std_logic_vector(OFFM1_WRCNT);
  OFFM1_RDADDR <= RAM_RDSEL & std_logic_vector(RAM_RDCNT);

  
  OFFSET_MATRIX2_DBLINE : entity WORK.SPRAM_GENERIC_DC_MIXED
    generic map (
      RD_ADDR_WIDTH => RAMS_ADDR_WIDTH,  -- RAM Address Width
      WR_ADDR_WIDTH => RAMS_ADDR_WIDTH-1, -- since read data port is 2 times smaller
      RD_DATA_WIDTH => OFFM_DATA_WIDTH,  -- RAM Data Width
      WR_DATA_WIDTH => FIFO_WSIZE,
      OUTPUT_REG => true              -- Output Registered if True
    )
    port map (
      -- Port A - Write Only
      CLK      => CLK            ,
      WR_WRREQ  => OFFM2_WRREQ     ,
      WR_ADDR   => OFFM2_WRADDR    ,
      WR_WRDATA => OFFM2_WRDATA    ,
      -- Port B - Read Only
      RD_ADDR   => OFFM2_RDADDRd    ,
      RD_RDDATA => OFFM2_RDDATA
    );

  OFFM2_WRADDR <= RAM_WRSEL & std_logic_vector(OFFM2_WRCNT);
  OFFM2_RDADDR <= RAM_RDSEL & std_logic_vector(RAM_RDCNT);

  -- -------------------------------------------------------
  --  Computing NUC algo on the fly !
  -- -------------------------------------------------------
  -- This process reads the already prepared Gain / Offset Matrix values
  -- from internal ram buffers, and perform on the fly : 
  -- NUC(I,j) = (Input Image(I,j) * Gain Matrix(I,j)) – Offset Matrix (I,j)
  -- It also outputs the Bad Pixel information on the VIDEO_O_BAD output
  VIDEO_out_process : process(CLK, RST)
    variable vVIDEO_DATA : signed(VIDEO_O_TEMP'length + 5 downto 0);
    variable wavg_OFFM_RDDATA : signed(OFFM_DATA_WIDTH-1 downto 0);
    variable mult_OFFM1_RDDATA : signed((2*OFFM_DATA_WIDTH) downto 0);
    variable mult_OFFM2_RDDATA : signed((2*OFFM_DATA_WIDTH) downto 0);
    variable mult_OFFM_RDDATA_ADD : signed((2*OFFM_DATA_WIDTH)+1 downto 0);
--    variable offset_1 : std_logic_vector(31 downto 0);
--    variable offset_2 : std_logic_vector(31 downto 0);

  begin
    if RST = '1' then
      ENABLE_NUC_l  <= '0';
      RAM_RDSEL     <= '0';
      RAM_RDCNT     <= (others => '0');
      VIDEO_O_NEW   <= '0';
      VIDEO_O_TEMP  <= (others => '0');
      VIDEO_O_RES   <= (others => '0');
      VIDEO_O_V     <= '0';
      VIDEO_O_H     <= '0';
      VIDEO_O_EOI   <= '0';
      VIDEO_O_DAVi  <= '0';
      VIDEO_O_DATA  <= (others => '0');
      VIDEO_O_BADi  <= '0';
      VIDEO_O_BAD   <= '0';
      VIDEO_O_XSIZi <= (others => '0');
      VIDEO_O_YSIZi <= (others => '0');
      VIDEO_O_XCNTi <= (others => '0');
      VIDEO_O_YCNTi <= (others => '0');
      VIDEO_O_FSM   <= s_IDLE;
      VIDEO_I_DAVd <='0';
      VIDEO_I_DAVd1 <='0';
      VIDEO_I_DAVd2 <='0';
      VIDEO_I_DAVd3 <='0';

      GAIN_RDADDRd  <= (others=>'0');
      OFFM1_RDADDRd <= (others=>'0');
      OFFM2_RDADDRd <= (others=>'0');
      
      VIDEO_I_DATAd  <= (others=>'0');
      VIDEO_I_DATAd1 <= (others=>'0');
      VIDEO_I_DATAd2 <= (others=>'0');
      VIDEO_I_DATAd3 <= (others=>'0');
      
--      offimg_start_div <= '0';
      
--      OFFIMG1_SUM      <= (others=>'0');
      OFFIMG1_AVG      <= (others=>'0');
--      offimg1_dvnd     <= (others=>'0');
      
--      OFFIMG2_SUM      <= (others=>'0');
      OFFIMG2_AVG      <= (others=>'0'); 
--      offimg2_dvnd     <= (others=>'0');
      update_offimg_avg<= '0';
      
    elsif rising_edge(CLK) then
      
      VIDEO_I_DAVd <='0';
      VIDEO_I_DAVd1 <='0';
      VIDEO_I_DAVd2 <='0';
      VIDEO_I_DAVd3 <='0';
      -- Gain / Offset Matrix Read Pointer
      if VIDEO_I_DAV = '1' then
        RAM_RDCNT <= RAM_RDCNT + 1;  
      end if;
      
      -- Output Pïxels Counter
      if VIDEO_O_DAVi = '1' then
        VIDEO_O_XCNTi <= VIDEO_O_XCNTi + 1;  
      end if;

      -- Default Assignments
      VIDEO_O_V    <= '0';
      VIDEO_O_H    <= '0';
      VIDEO_O_EOI  <= '0';
      VIDEO_O_NEW  <= '0';
      VIDEO_O_DAVi <= '0';
      VIDEO_O_BADi <= '0';
      VIDEO_O_BAD  <= '0';
      
--      if APPLY_NUC1ptCalib_D = '1' then
--        OFFIMG1_AVG <= OFFSET_IMG_AVG;
--        OFFIMG2_AVG <= OFFSET_IMG_AVG;
--      else
--          if(offimg1_done_tick = '1') then
--            OFFIMG1_AVG <= offimg1_quo(15 downto 0)  ;
--          else
--            OFFIMG1_AVG <= OFFIMG1_AVG;
--          end if;
                
--          if(offimg2_done_tick = '1') then     
--            OFFIMG2_AVG <= offimg2_quo (15 downto 0) ;  
--          else
--            OFFIMG2_AVG <= OFFIMG2_AVG;
--          end if;  
--      end if;
      
             
      case VIDEO_O_FSM is
  
        -- Wait for the New Frame Start 
        when s_IDLE =>
            VIDEO_O_XSIZi <= to_unsigned(VIDEO_XSIZE,VIDEO_O_XSIZi'length); -- Latch X Size
            VIDEO_O_YSIZi <= to_unsigned(VIDEO_YSIZE,VIDEO_O_YSIZi'length); -- Latch Y Size
            VIDEO_O_XCNTi <= (others => '0');
            VIDEO_O_YCNTi <= (others => '1'); -- so that the 1st line is numbered 0
            if VIDEO_I_V = '1' then
              VIDEO_O_V   <= '1';  -- Say : new output image !
              if (ENABLE_NUC = '1' or ENABLE_BADPIX = '1') then  -- do the Processing !
                ENABLE_NUC_l <= ENABLE_NUC;
                RAM_RDSEL    <= '1';   -- so that the 1st line is read from buffers 0  
                VIDEO_O_FSM  <= s_NEW_LINE;
                update_offimg_avg <= '1';
              else
                VIDEO_O_FSM  <= s_BYPASS;
              end if;
            end if;
--            offimg_start_div <= '0';

        -- Bypass : copy the Video input directly         
        when s_BYPASS =>
            VIDEO_O_H     <= VIDEO_I_H   ;
            VIDEO_O_EOI   <= VIDEO_I_EOI ;
            VIDEO_O_DAVi  <= VIDEO_I_DAV ;
            VIDEO_O_DATA  <= VIDEO_I_DATA;
          --VIDEO_O_XCNTi is managed above the FSM (same as if no bypass)
            VIDEO_O_YCNTi <= unsigned(VIDEO_I_YCNT);
            VIDEO_O_BAD   <= '0'; -- No bad pixel generation !
            if VIDEO_I_H = '1' then
              VIDEO_O_XCNTi <= (others=> '0');
            end if;
            if VIDEO_I_EOI = '1' then
              VIDEO_O_FSM <= s_IDLE;
            end if;
  
        -- Wait for the new line Flag
        when s_NEW_LINE =>
            if VIDEO_I_H = '1' then
              RAM_RDSEL     <= not RAM_RDSEL;  
              RAM_RDCNT     <= (others => '0');  -- Point on 1st Gain/Offset Matrix pixels
              --
              VIDEO_O_H     <= '1';  -- Say : new output line !
              VIDEO_O_YCNTi <= VIDEO_O_YCNTi + 1;
              VIDEO_O_XCNTi <= (others => '0');
              VIDEO_O_FSM   <= s_COMPUTE_LINE;
            end if;

        -- Compute the line with NUC Algorithm, only if ENABLE_NUC_l is asserted
        -- NUC(I,j) = (Input Image(I,j) * Gain Matrix(I,j)) – Offset Matrix (I,j)
        -- Otherwise, just output the bad pixel information
        when s_COMPUTE_LINE =>
            -- Data Processing : step 1

            -- Memory reading takes 2 clk cycles. Thus it is necessary to delay the capturing by at least 1 clk cycle.
            -- This delay has been added to accomodate for pixel clock of 40MHz on a system clock of 108MHz

            if VIDEO_I_DAV ='1' then
              VIDEO_I_DAVd <='1';
              GAIN_RDADDRd <= GAIN_RDADDR;
              OFFM1_RDADDRd <= OFFM1_RDADDR;
              OFFM2_RDADDRd <= OFFM2_RDADDR;
              VIDEO_I_DATAd <= VIDEO_I_DATA;
            end if;

            if VIDEO_I_DAVd ='1' then
              VIDEO_I_DAVd1 <='1';
              VIDEO_I_DATAd1 <= VIDEO_I_DATAd;
            end if;

            if VIDEO_I_DAVd1 ='1' then
              VIDEO_I_DAVd2 <='1';
              VIDEO_I_DATAd2 <= VIDEO_I_DATAd1;
            end if;

            if VIDEO_I_DAVd2 ='1' then
              VIDEO_I_DAVd3 <='1';
              VIDEO_I_DATAd3 <= VIDEO_I_DATAd2;
              
              if APPLY_NUC1ptCalib_D = '1' then
                  OFFIMG1_AVG <= OFFSET_IMG_AVG;
                  OFFIMG2_AVG <= OFFSET_IMG_AVG;
              elsif(update_offimg_avg = '1')then
                update_offimg_avg <= '0';
                OFFIMG1_AVG       <= "00" & OFFM1_RDDATA(13 downto 0);
                OFFIMG2_AVG       <= "00" & OFFM2_RDDATA(13 downto 0);
              end if;  
              offset_1       <= (signed("0000" & unsigned(OFFIMG1_AVG(15 downto 0)) & "000000000000") - signed(GAIN_RDDATA(15 downto 0))*signed(OFFM1_RDDATA(15 downto 0)));
              offset_2       <= (signed("0000" & unsigned(OFFIMG2_AVG(15 downto 0)) & "000000000000") - signed(GAIN_RDDATA(15 downto 0))*signed(OFFM2_RDDATA(15 downto 0)));
              GAIN_RDDATA_D  <= GAIN_RDDATA;
--              OFFIMG1_SUM <= unsigned(OFFM1_RDDATA) +  OFFIMG1_SUM;
--              OFFIMG2_SUM <= unsigned(OFFM2_RDDATA) +  OFFIMG2_SUM;
            end if;
            
            if VIDEO_I_DAVd3 = '1' then  -- New Input Pixel
              VIDEO_O_NEW  <= ENABLE_NUC_l;     -- for the NUC pipeline
              VIDEO_O_BADi <= GAIN_RDDATA_D(15);  -- get the Bad Pixel information
              -- Compute : Input Image(I,j) * Gain Matrix(I,j) as an unsigned
              VIDEO_O_TEMP <= unsigned(GAIN_RDDATA_D(14 downto 0)) * unsigned(VIDEO_I_DATAd3);
              -- Load the Offset Matrix, in signed result 

              
--              mult_OFFM1_RDDATA := resize((signed('0' & mult_factor1(15 downto 0))) * (signed(OFFM1_RDDATA(15 downto 0))),mult_OFFM1_RDDATA'length);
--              mult_OFFM2_RDDATA := resize((signed('0' & mult_factor2(15 downto 0))) * (signed(OFFM2_RDDATA(15 downto 0))),mult_OFFM2_RDDATA'length);
              
--              mult_OFFM1_RDDATA := resize((signed('0' & mult_factor1(15 downto 0))) * (signed(OFFM1_RDDATA(15 downto 0))),mult_OFFM1_RDDATA'length);
--              mult_OFFM2_RDDATA := resize((signed('0' & mult_factor2(15 downto 0))) * (signed(OFFM2_RDDATA(15 downto 0))),mult_OFFM2_RDDATA'length);            

--              offset_1       := std_logic_Vector(signed("0000" & unsigned(OFFIMG1_AVG(15 downto 0)) & "000000000000") - signed(GAIN_RDDATA(15 downto 0))*signed(OFFM1_RDDATA(15 downto 0)));
--              offset_2       := std_logic_Vector(signed("0000" & unsigned(OFFIMG2_AVG(15 downto 0)) & "000000000000") - signed(GAIN_RDDATA(15 downto 0))*signed(OFFM2_RDDATA(15 downto 0)));
--              GAIN_RDDATA_D  <= GAIN_RDDATA;
--              OFFIMG1_SUM <= unsigned(OFFM1_RDDATA) +  OFFIMG1_SUM;
--              OFFIMG2_SUM <= unsigned(OFFM2_RDDATA) +  OFFIMG2_SUM;   

              mult_OFFM1_RDDATA := resize((signed('0' & mult_factor1(15 downto 0))) * (signed(offset_1(27 downto 12))),mult_OFFM1_RDDATA'length);
              mult_OFFM2_RDDATA := resize((signed('0' & mult_factor2(15 downto 0))) * (signed(offset_2(27 downto 12))),mult_OFFM2_RDDATA'length);            
              
              mult_OFFM_RDDATA_ADD := resize((signed(mult_OFFM1_RDDATA) + signed(mult_OFFM2_RDDATA)),mult_OFFM_RDDATA_ADD'length);
              wavg_OFFM_RDDATA     := resize(signed(shift_right(mult_OFFM_RDDATA_ADD,16)),wavg_OFFM_RDDATA'length);
              
              --wavg_OFFM_RDDATA := resize(signed(shift_right(mult_OFFM1_RDDATA,16)) + signed(shift_right(mult_OFFM2_RDDATA,16)),wavg_OFFM_RDDATA'length);  
              --wavg_OFFM_RDDATA := signed(OFFM1_RDDATA(15 downto 0)) + signed(OFFM2_RDDATA(15 downto 0));
              
              if APPLY_NUC1ptCalib_D = '1' then
--                VIDEO_O_RES  <= resize(signed(OFFM1_RDDATA(15 downto 0)), VIDEO_O_RES'length);  -- add 3bits because format 4.3
                VIDEO_O_RES  <= resize(signed(offset_1(27 downto 12)), VIDEO_O_RES'length);  -- add 3bits because format 4.3
              else
                VIDEO_O_RES  <= resize(signed(wavg_OFFM_RDDATA(15 downto 0)), VIDEO_O_RES'length);  -- add 3bits because format 4.3
              end if;
              --VIDEO_O_RES  <= resize(signed(OFFM1_RDDATA(15 downto 0)), VIDEO_O_RES'length);  -- add 3bits because format 4.3
              
              -- if NUC was not Enabled but BAD PIXEL info was, then directly output it
              if ENABLE_NUC_l = '0' then
                VIDEO_O_DAVi <= '1';  -- New Pixel valid
                VIDEO_O_BADi <= '0';
                VIDEO_O_BAD  <= GAIN_RDDATA_D(15);  -- output the Bad Pixel information now
                if ZFORCE_BADPIX = '1' and GAIN_RDDATA_D(15) = '1' then
                  VIDEO_O_DATA <= (others => '0'); 
                else
                  VIDEO_O_DATA <= VIDEO_I_DATAd3;
                end if;
              end if;
              
            end if;
            -- Data Processing : step 2  
            if VIDEO_O_NEW = '1' then  
              VIDEO_O_DAVi <= '1';  -- New Pixel valid
              VIDEO_O_BAD  <= VIDEO_O_BADi;
              -- Compute (Input Image(I,j) * Gain Matrix(I,j) ) – Offset Matrix (I,j),
              -- in a VHDL variable, so that we can do the saturation in the same CLK cycle
              vVIDEO_DATA := resize(signed('0' & VIDEO_O_TEMP), vVIDEO_DATA'length) + resize(signed(VIDEO_O_RES & x"000"),vVIDEO_DATA'length);
              -- Saturation : no negative result, or nothing greater than data output bus size
              --**********************************************************
              if vVIDEO_DATA(vVIDEO_DATA'high downto 12) < 0 then
                VIDEO_O_DATA <= (others => '0');
              elsif vVIDEO_DATA(vVIDEO_DATA'high downto 12) > 2**VIDEO_O_DATA'length-1 then
                VIDEO_O_DATA <= (others => '1');
              else
                VIDEO_O_DATA <= std_logic_vector(vVIDEO_DATA(25 downto 12));
              end if;
              if ZFORCE_BADPIX = '1' and VIDEO_O_BADi = '1' then
                VIDEO_O_DATA <= (others => '0'); 
              end if;
              --************************************************************
            end if;
            -- End of Line / Image Management
            if VIDEO_O_XCNTi = VIDEO_O_XSIZi then  -- End of Line Detection              
              if VIDEO_O_YCNTi = VIDEO_O_YSIZi-1 then  -- End of Image Detection
                VIDEO_O_EOI <= '1';
                VIDEO_O_FSM <= s_IDLE;
                
--                offimg_start_div  <= '1';
--                offimg1_dvnd      <= std_logic_vector(OFFIMG1_SUM);
--                offimg2_dvnd      <= std_logic_vector(OFFIMG2_SUM);
--                OFFIMG1_SUM       <= (others=>'0');
--                OFFIMG2_SUM       <= (others=>'0');
                
              else
                VIDEO_O_FSM <= s_NEW_LINE;   -- go wait another line
              end if;
            end if;
   
      end case;       
      
    end if;
  end process VIDEO_out_process;

  -- -----------------------------
  --  Video Outputs
  -- -----------------------------
  VIDEO_O_DAV   <= VIDEO_O_DAVi;
  --VIDEO_O_XSIZE <= std_logic_vector(VIDEO_O_XSIZi);
  --VIDEO_O_YSIZE <= std_logic_vector(VIDEO_O_YSIZi);
  --VIDEO_O_XCNT  <= std_logic_vector(VIDEO_O_XCNTi);
  --VIDEO_O_YCNT  <= std_logic_vector(VIDEO_O_YCNTi);
 

 i_nuc_div : entity WORK.div
 generic map(
  W    => 32,
  CBIT => 6
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


 
-- nuc_probe(0) <= offset_matrix_rd_done;
-- nuc_probe(1) <= VIDEO_I_V;
-- nuc_probe(2) <= VIDEO_I_H;
-- nuc_probe(3) <= VIDEO_I_DAV;
-- nuc_probe(4) <= VIDEO_I_EOI;
-- nuc_probe(5) <= DMA_RDREADY;
-- nuc_probe(6) <= DMA_RDDAV; 
-- nuc_probe(7) <= OFFM1_WRREQ;
-- nuc_probe(8) <= OFFM2_WRREQ;
-- nuc_probe(24 downto 9)  <= mult_factor2(15 downto 0);
-- nuc_probe(40 downto 25) <=  mult_factor1(15 downto 0);
-- --nuc_probe(49 downto 41) <=std_logic_vector(OFFM1_WRCNT);
-- --nuc_probe(49 downto 41) <=std_logic_vector(OFFM2_WRCNT);
---- nuc_probe(47 downto 41) <= std_logic_vector(TEMP_RANGE_DD);
-- nuc_probe(41) <=  ENABLE_NUC;
-- nuc_probe(42) <=  APPLY_NUC1ptCalib;
-- nuc_probe(43) <=  offimg_start_div;
---- nuc_probe(44) <=  ENABLE_NUC_l;
-- nuc_probe(47 downto 44) <= std_logic_vector(to_unsigned(DMA_RDFSM_t'POS(DMA_RDFSM), 4));

-- nuc_probe(48) <= VIDEO_I_DAVd2;--temperature_data_len ;--OFFM1_WRADDR; 
-- nuc_probe(49) <= VIDEO_I_DAVd1;--temperature_data_len ;--OFFM1_WRADDR; 
-- nuc_probe(50) <= VIDEO_I_DAVd;--temperature_data_len ;--OFFM1_WRADDR; 
-- nuc_probe(51) <= VIDEO_O_DAVi;
-- nuc_probe(52) <= done_tick;--offimg1_done_tick;
-- nuc_probe(53) <= start_div;--offimg2_done_tick;
---- nuc_probe(54) <= VIDEO_O_DAVi;
---- nuc_probe(55) <= update_gfid_gsk_check ;
---- nuc_probe(56) <= flag ;
-- nuc_probe(69 downto 54) <=OFFIMG1_AVG;
---- nuc_probe(67 downto 57) <= (others=>'0');
-- --nuc_probe(67 downto 58) <= OFFM2_WRADDR; 
-- nuc_probe(76 downto 70) <= std_logic_vector(TEMP_RANGE_D);
---- nuc_probe(77 downto 75) <= (others=>'0');--check_RAM_WRFSM(2 downto 0); 
----nuc_probe(85 downto 70) <=OFFM1_RDDATA; --OFFIMG1_AVG;
-- nuc_probe(83 downto 77) <= std_logic_vector(TEMP_RANGE);
-- nuc_probe(85 downto 84) <= (others=>'0');
---- nuc_probe(85) <=  ENABLE_NUC;
-- nuc_probe(117 downto 86) <= mult_factor_temp;
---- nuc_probe(117 downto 86) <= std_logic_vector(VIDEO_O_RES);
-- --nuc_probe(133 downto 118) <= gfid_gsk_update_temp_val1;
-- --nuc_probe(149 downto 134) <= gfid_gsk_update_temp_val2;
-- --nuc_probe(149 downto 148)<= (others=>'0');
---- nuc_probe(133 downto 118) <= OFFM1_RDDATA;
---- nuc_probe(149 downto 134) <= OFFM2_RDDATA;
---- nuc_probe(139 downto 118) <= std_logic_vector(DMA_ADDR_PICT);
-- nuc_probe(133 downto 118) <= temperature_diff;
-- nuc_probe(143 downto 134) <= std_logic_vector(DMA_ADDR_LIN);
-- nuc_probe(159 downto 144) <= OFFIMG2_AVG;
---- nuc_probe(181 downto 150) <= std_logic_vector(DMA_ADDR_BASE);
-- nuc_probe(175 downto 160) <= temperature_offset;--OFFM1_RDDATA;
---- nuc_probe(181 downto 166) <= OFFM1_RDDATA;
---- nuc_probe(181 downto 166) <= (others=>'0');
---- nuc_probe(181 downto 166) <= mult_factor2(15 downto 0);
---- nuc_probe(191 downto 182) <= std_logic_vector(VIDEO_O_YCNTi);
-- nuc_probe(191 downto 176) <= dvnd(31 downto 16);
-- nuc_probe(193 downto 192) <= std_logic_vector(to_unsigned(VIDEO_O_FSM_t'POS(VIDEO_O_FSM), 2));--(others=>'0');--check_DMA_RDFSM; 
-- nuc_probe(207 downto 194) <= TEMPERATURE(13 downto 0);--GAIN_RDDATA(15 downto 0);
-- nuc_probe(223 downto 208) <= dvsr(15 downto 0);--OFFM2_RDDATA;--VIDEO_I_DATA;
---- nuc_probe(233 downto 224) <= std_logic_vector(VIDEO_O_XCNTi);
---- nuc_probe(255 downto 234) <= std_logic_vector(DMA_ADDR_START);
-- nuc_probe(255 downto 224) <= quo;
  
-- DMA_ADDR_BASE_GAIN;
-- DMA_ADDR_BASE_GAIN_TEMP
 
-- ADDR_OFFM_NUC1PT
 
-- i_nuc: TOII_TUVE_ila
--  PORT MAP (
--      clk => CLK,
--      probe0 => nuc_probe
--  );
  
--i_div_offimg1 : entity WORK.div
-- generic map(
--  W    => 34,
--  CBIT => 6
--  )
-- port map(

--  clk       => CLK,
--  reset     => RST,
--  start     => offimg_start_div ,
--  dvsr      => offimg_dvsr, 
--  dvnd      => offimg1_dvnd,
--  done_tick => offimg1_done_tick,
--  quo       => offimg1_quo, 
--  rmd       => open
--  );  

--i_div_offimg2 : entity WORK.div
-- generic map(
--  W    => 34,
--  CBIT => 6
--  )
-- port map(

--  clk       => CLK,
--  reset     => RST,
--  start     => offimg_start_div ,
--  dvsr      => offimg_dvsr, 
--  dvnd      => offimg2_dvnd,
--  done_tick => offimg2_done_tick,
--  quo       => offimg2_quo, 
--  rmd       => open
--  );  


-----------------------------
end architecture RTL;
-----------------------------