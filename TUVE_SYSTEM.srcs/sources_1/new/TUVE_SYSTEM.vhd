----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/23/2018 05:20:28 PM
-- Design Name: 
-- Module Name: Top_Test_TOII_TUVE - Behavioral
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
use WORK.THERMAL_CAM_PACK.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Library xpm;
use xpm.vcomponents.all;

Library UNISIM;
use UNISIM.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TUVE_SYSTEM is
generic (
  CAPTURE                   : boolean := TRUE;
  OLED_EN                   : boolean := TRUE;
  MIPI_EN                   : boolean := FALSE;
  USB_EN                    : boolean := FALSE;
  EK_EN                     : boolean := FALSE;
  CALIB_EN                  : boolean := FALSE;
  bitdepth                  : positive := 12;
  BIT_WIDTH                 : positive := 14;     -- Number of bits in a pixe
  
--  image_width_full          : positive := 648;
--  temp_pixels_left          : natural := 3;  
--  temp_pixels_right         : natural := 3;
--  exclude_left              : natural := 0;
--  exclude_right             : natural := 2;

  VIDEO_XSIZE               : integer  := 640;
  VIDEO_YSIZE               : integer  := 480;
  
  SENSOR_XSIZE              : integer  := 664;
  SENSOR_YSIZE              : integer  := 519;
  VIDEO_X_OFFSET_PAL        : integer  :=  38;--320;--64;--80;
  VIDEO_Y_OFFSET_PAL        : integer  :=  48;--160;--0;--60; 
--  VIDEO_X_OFFSET            : integer  :=  38;
--  VIDEO_Y_OFFSET            : integer  :=  48;
  VIDEO_X_OFFSET_OLED       : integer  :=  160;--320;--64;--80;
  VIDEO_Y_OFFSET_OLED       : integer  :=  120;--160;--0;--60; 
  VIDEO_X_OFFSET_NTSC       : integer  :=  38;
  VIDEO_Y_OFFSET_NTSC       : integer  :=   0;
  VIDEO_ADD_BORDER_XSIZE_PAL  : natural  :=  716; 
  VIDEO_ADD_BORDER_YSIZE_PAL  : natural  :=  576;   
  VIDEO_ADD_BORDER_XSIZE_NTSC : natural  :=  716; 
  VIDEO_ADD_BORDER_YSIZE_NTSC : natural  :=  480;--484; 
--  USB_VIDEO_XSIZE           : natural :=640;
--  USB_VIDEO_YSIZE           : natural :=480;
  VIDEO_ADD_LEFT_PIX        : natural := 0;
  VIDEO_ADD_RIGHT_PIX       : natural := 0;
  PIX_BITS                  : positive :=  10;     -- 2**PIX_BITS = Maximum Number of pixels in a line
  LIN_BITS                  : positive :=  10;     -- 2**LIN_BITS = Maximum Number of  lines in an image
  SRAM_TEST                 : boolean  := FALSE;  -- Disable Video and Enable SRAM Tester if true
  DEBUG                     : boolean  := FALSE;  -- True for Simulation only
  DEBUG_TIMEOUT             : positive := 10;     -- Value in ms after which we say Timeout (if DEBUG = true)
  DMA_ADDR_BITS             : positive := 32;
  DMA_SIZE_BITS             : positive := 6;
  DMA_DATA_BITS             : positive := 32;
  fixedp_width              : positive := 24;
  Clip_Threshold_Init_Value : positive := 1900
  );
 Port ( 
     FPGA_27MHz_CLK             : in    STD_LOGIC;

     FPGA_SDRAM_CLK             : out   STD_LOGIC;
     FPGA_SDRAM_DQM             : out   STD_LOGIC_VECTOR (3 DOWNTO 0);
     FPGA_SDRAM_RAS_N           : out   STD_LOGIC;
     FPGA_SDRAM_CAS_N           : out   STD_LOGIC;
     FPGA_SDRAM_WE_N            : out   STD_LOGIC;
     FPGA_SDRAM_CKE             : out   STD_LOGIC;
     FPGA_SDRAM_CS_N            : out   STD_LOGIC;
     FPGA_SDRAM_A               : out   STD_LOGIC_VECTOR (13 DOWNTO 0);
     FPGA_SDRAM_D               : inout STD_LOGIC_VECTOR (31 DOWNTO 0);
     FPGA_SDRAM_BA              : out   STD_LOGIC_VECTOR(1 DOWNTO 0);

     FPGA_DAC_P                 : out   STD_LOGIC_VECTOR (7 DOWNTO 0);
     FPGA_DAC_CLK               : out   STD_LOGIC;
     FPGA_DAC_VSYNC             : out   STD_LOGIC;
     FPGA_DAC_HSYNC             : out   STD_LOGIC;
     FPGA_DAC_SFL               : out   STD_LOGIC;
     DAC_FILTER_DIS             : out   STD_LOGIC;
     DAC_RESET                  : out   STD_LOGIC;
     
     FPGA_I2C1_SCL              : inout STD_LOGIC;
     FPGA_I2C1_SDA              : inout STD_LOGIC;
     
     FPGA_B2B_M_I2C2_SCL        : inout STD_LOGIC;
     FPGA_B2B_M_I2C2_SDA        : inout STD_LOGIC;
     
     TH_SNR_ADR                 : out   STD_LOGIC;
     TH_SNR_DRDY_INT            : in    STD_LOGIC;
     
     FPGA_B2B_M_BT656_D         : out   STD_LOGIC_VECTOR (7 DOWNTO 0);
--     FPGA_B2B_M_BT656_D         : in   STD_LOGIC_VECTOR (7 DOWNTO 0);
     FPGA_B2B_M_BT656_CLK       : out   STD_LOGIC;
     


--     FPGA_B2B_M_SD_DAT0         : inout STD_LOGIC;
     FPGA_B2B_M_SD_DAT0         : out STD_LOGIC;
     FPGA_B2B_M_SD_DAT1         : in STD_LOGIC;
     FPGA_B2B_M_SD_DAT2         : inout STD_LOGIC;
     FPGA_B2B_M_SD_DAT3         : in STD_LOGIC;
     FPGA_B2B_M_SD_SDCD         : in STD_LOGIC;
     FPGA_B2B_M_SD_CMD          : out STD_LOGIC;
     FPGA_B2B_M_SD_CLK          : out STD_LOGIC;

     FPGA_B2B_M_GPIO1           : inout STD_LOGIC;
     FPGA_B2B_M_GPIO2           : inout STD_LOGIC;
     FPGA_B2B_M_GPIO3           : inout STD_LOGIC;
     
     FPGA_LDO_VA4_EN            : out   STD_LOGIC;
     FPGA_LDO_VD2_EN            : out   STD_LOGIC;
     
--     FPGA_B2B_M_UART_TX         : out   STD_LOGIC;
--     FPGA_B2B_M_UART_RX         : in    STD_LOGIC;

     FPGA_B2B_M_UART_TX         : inout   STD_LOGIC;
     FPGA_B2B_M_UART_RX         : inout   STD_LOGIC;     

     FPGA_B2B_M_PVO8            : out   STD_LOGIC;
     FPGA_B2B_M_PVO9            : out   STD_LOGIC;
     FPGA_B2B_M_PVO10           : out   STD_LOGIC;
     FPGA_B2B_M_PVO11           : out   STD_LOGIC;
     FPGA_B2B_M_PVO12           : out   STD_LOGIC;
     FPGA_B2B_M_PVO13           : out   STD_LOGIC;
     FPGA_B2B_M_PVO14           : out   STD_LOGIC;
     FPGA_B2B_M_PVO15           : out   STD_LOGIC;
     FPGA_B2B_M_PVO_VSYNC       : out   STD_LOGIC;
     FPGA_B2B_M_PVO_HSYNC       : out   STD_LOGIC;

     SNSR_FPGA_NRST_SPI_CS      : out   STD_LOGIC;
     SNSR_FPGA_SEQTRIG          : out   STD_LOGIC;
     SNSR_FPGA_MASTER_CLK       : out   STD_LOGIC;
     SNSR_FPGA_PIXEL_CLK        : in    STD_LOGIC;
     SNSR_FPGA_LINEVALID        : in    STD_LOGIC;
     SNSR_FPGA_FRAMEVALID       : in    STD_LOGIC;
     SNSR_FPGA_RFU              : in    STD_LOGIC;
     SNSR_FPGA_I2C2_SCL_SPI_SCK : inout   STD_LOGIC;
     SNSR_FPGA_I2C2_SDA_SPI_SDO : inout   STD_LOGIC;
     SNSR_FPGA_DATA             : in    STD_LOGIC_VECTOR (15 DOWNTO 0);
     
--     SNSR_PIXCLKIN: out STD_LOGIC;
--     SNSR_CMD0_1  : out STD_LOGIC;
--     SNSR_CMD2_3  : out STD_LOGIC;
--     SNSR_BIT0_1  : out STD_LOGIC;
--     SNSR_BIT2_3  : out STD_LOGIC;
--     SNSR_BIT4_5  : out STD_LOGIC;
--     SNSR_BIT6_7  : out STD_LOGIC;


--     SNSR_SSC     : in STD_LOGIC;
--     SNSR_FB0_1   : in STD_LOGIC;
--     SNSR_OUT0_1  : in STD_LOGIC;
--     SNSR_OUT2_3  : in STD_LOGIC;
--     SNSR_OUT4_5  : in STD_LOGIC;
--     SNSR_OUT6_7  : in STD_LOGIC;
--     SNSR_OUT8_9  : in STD_LOGIC;
--     SNSR_OUT10_11: in STD_LOGIC;
--     SNSR_OUT12_13: in STD_LOGIC;

--     FPGA_RX_BNO_TX : in  STD_LOGIC;   
--     FPGA_TX_BNO_RX : out STD_LOGIC;   
--     BNO_RST        : out STD_LOGIC;  
--     BNO_INT        : in  STD_LOGIC;  
--     BNO_PS1        : out STD_LOGIC;  
--     BNO_PS0        : out STD_LOGIC;
     
     FPGA_SPI_DQ0 : inout std_logic;
     FPGA_SPI_DQ1 : inout std_logic;
     FPGA_SPI_DQ2 : inout std_logic;
     FPGA_SPI_DQ3 : inout std_logic;
     FPGA_SPI_CS  : out   std_logic;
     mipi_phy_if_clk_hs_n  : out std_logic;
     mipi_phy_if_clk_hs_p  : out std_logic;
     mipi_phy_if_clk_lp_n  : out std_logic;
     mipi_phy_if_clk_lp_p  : out std_logic;
     mipi_phy_if_data_hs_n : out std_logic_vector(0 downto 0);
     mipi_phy_if_data_hs_p : out std_logic_vector(0 downto 0);
     mipi_phy_if_data_lp_n : out std_logic_vector(0 downto 0);
     mipi_phy_if_data_lp_p : out std_logic_vector(0 downto 0) 
        
    
 );
end TUVE_SYSTEM;


architecture Behavioral of TUVE_SYSTEM is

component sensor_controller_top is
generic (
    SENSOR_XSIZE      : positive:= 664;
    SENSOR_YSIZE      : positive:= 519
  );
port (
    clk                   : in std_logic;
    rst                   : in std_logic;
    mclk                  : in std_logic;
    rst_m                 : in std_logic;
    area_switch_done      : in std_logic;
    low_to_high_temp_area_switch : in std_logic;
    high_to_low_temp_area_switch : in std_logic;
    lo_to_hi_area_global_offset_force_val : in std_logic_vector(15 downto 0);
    hi_to_lo_area_global_offset_force_val : in std_logic_vector(15 downto 0);
    BAD_BLIND_PIX_LOW_TH                  : in std_logic_vector(BIT_WIDTH-1 downto 0);
    BAD_BLIND_PIX_HIGH_TH                 : in std_logic_vector(BIT_WIDTH-1 downto 0);
    blind_badpix_remove_en: in std_logic;
    dark_pix_th           : in std_logic_vector(BIT_WIDTH-1 downto 0);
    saturated_pix_th      : in std_logic_vector(BIT_WIDTH-1 downto 0);
    addr_coarse_offset    : in std_logic_vector(31 downto 0);
    sensor_pixclk         : out std_logic;
    sensor_cmd            : out std_logic_vector(1 downto 0);
    sensor_data           : out std_logic_vector(3 downto 0);
    sensor_ssclk          : in std_logic;
    sensor_framing        : in std_logic;
    sensor_video_data     : in std_logic_vector(6 downto 0);
    av_sensor_waitrequest : out std_logic;
    av_sensor_write       : in std_logic;
    av_sensor_writedata   : in std_logic_vector(31 downto 0);
    av_sensor_address     : in std_logic_vector(5 downto 0);
    av_sensor_read        : in std_logic;
    av_sensor_readdata    : out std_logic_vector(31 downto 0);
    av_sensor_readdatavalid: out std_logic;
    av_coarse_waitrequest : in std_logic;
	av_coarse_read 		  : out std_logic;
	av_coarse_address 	  : out std_logic_vector( 31 downto 0);
	av_coarse_size 		  : out std_logic_vector(5 downto 0);
	av_coarse_readdatavalid: in std_logic;
	av_coarse_readdata 	  :	in std_logic_vector(31 downto 0);

    raw_video_v             : out std_logic;
    raw_video_h             : out std_logic;
    raw_video_dav           : out std_logic;
    raw_video_data          : out std_logic_vector(16-1 downto 0);
    raw_video_eoi           : out std_logic;
    raw_video_xsize         : out std_logic_vector(PIX_BITS-1 downto 0);
    raw_video_ysize         : out std_logic_vector(LIN_BITS-1 downto 0);

    meta1_avg               : out std_logic_vector(13 downto 0);
    meta2_avg               : out std_logic_vector(13 downto 0);
    meta3_avg               : out std_logic_vector(13 downto 0);


    video_o_v             : out std_logic;
    video_o_h             : out std_logic;
    video_o_dav           : out std_logic;
    video_o_dav_with_temp : out std_logic;
    video_o_data          : out std_logic_vector(BIT_WIDTH-1 downto 0);
    video_o_eoi           : out std_logic;
    video_o_xsize         : out std_logic_vector(PIX_BITS-1 downto 0);
    video_o_ysize         : out std_logic_vector(LIN_BITS-1 downto 0);
    video_o_xsize_with_temp : out std_logic_vector(PIX_BITS-1 downto 0);
    video_o_ysize_with_temp : out std_logic_vector(LIN_BITS-1 downto 0);
    temp_sense_offset     : out std_logic_vector(3 downto 0)
  );
end component;


component snapshot_controller is
  generic( 
    PIX_BITS : positive := 10;
  LIN_BITS :positive := 10;
  WR_SIZE :positive := 16;
  DMA_SIZE_BITS: positive:=5
  );
  port(
  clk         : in std_logic;
  rst         : in std_logic;

  channel_in  : in std_logic_vector(2 downto 0);
  mode_in     : in std_logic_vector(2 downto 0);
  
  single_snapshot     : in std_logic;     
--  continuous_snapshot : in std_logic; 
  burst_snapshot      : in std_logic; 
  burst_capture_size  : in std_logic_vector(7 downto 0);
  snapshot_counter    : in std_logic_vector(7 downto 0);    
  

  trigger     : in std_logic;
  busy_out    : out std_logic;
    
  done_out    : out std_logic;

  total_frames: in std_logic_vector(7 downto 0);

  src_1_v     : in std_logic;
  src_1_h     : in std_logic;
  src_1_eoi   : in std_logic;
  src_1_dav   : in std_logic;
  src_1_data  : in std_logic_vector(15 downto 0);
  src_1_xsize : in std_logic_vector(PIX_BITS-1 downto 0);
  src_1_ysize : in std_logic_vector(LIN_BITS-1 downto 0);

  src_2_v     : in std_logic;
  src_2_h     : in std_logic;
  src_2_eoi   : in std_logic;
  src_2_dav   : in std_logic;
  src_2_data  : in std_logic_vector(15 downto 0);
  src_2_xsize : in std_logic_vector(PIX_BITS-1 downto 0);
  src_2_ysize : in std_logic_vector(LIN_BITS-1 downto 0);

  src_3_v     : in std_logic;
  src_3_h     : in std_logic;
  src_3_eoi   : in std_logic;
  src_3_dav   : in std_logic;
  src_3_data  : in std_logic_vector(7 downto 0);
  src_3_xsize : in std_logic_vector(PIX_BITS-1 downto 0);
  src_3_ysize : in std_logic_vector(LIN_BITS-1 downto 0);

  src_4_v     : in std_logic;
  src_4_h     : in std_logic;
  src_4_eoi   : in std_logic;
  src_4_dav   : in std_logic;
  src_4_data  : in std_logic_vector(15 downto 0);
  src_4_xsize : in std_logic_vector(PIX_BITS-1 downto 0);
  src_4_ysize : in std_logic_vector(LIN_BITS-1 downto 0);
    
  dma_wrready : in std_logic;
  dma_wrreq   : out std_logic;  
  dma_wrburst : out std_logic;
  dma_wrsize  : out std_logic_vector(DMA_SIZE_BITS-1 downto 0); 
  dma_wraddr  : out std_logic_vector(31 downto 0); 
  dma_wrdata  : out std_logic_vector(31 downto 0); 
  dma_wrbe    : out std_logic_vector(3 downto 0)
  
);
end component;

  component nuc_controller is
  generic (
    VIDEO_XSIZE : positive:=640;
    VIDEO_YSIZE : positive:=480;
    SIZE_BITS : positive:=6;
    bit_width: positive:=13
  );
  port(
  clk : in std_logic;
  rst : in std_logic;

  en_nuc : in std_logic;
  en_nuc_1pt : in std_logic;
  en_unity_gain : in std_logic;
  en_nuc_1pt_mode2 : in std_logic;
  
  force_temp_range_en : in std_logic;
  force_temp_range    : in std_logic_vector(2 downto 0);

  tick1s : in std_logic;
  temp_range_update_timeout : in std_logic_vector(15 downto 0); 
  auto_shutter_timeout      : in std_logic_Vector(15 downto 0);
  sensor_power_on_init_done : in std_logic; 
  temperature_threshold      : in std_logic_vector(15 downto 0);
  
  --// Master AVALON interface for fetching and storing tables
  av_ready        : in std_logic;
  av_read         : out std_logic;
  av_write        : out std_logic;
  av_wrburst      : out std_logic;
  av_size         : out std_logic_vector(SIZE_BITS-1 downto 0);
  av_address      : out std_logic_vector(31 downto 0);
  av_writedata    : out std_logic_vector(31 downto 0);
  av_wrbe         : out std_logic_vector(3 downto 0);
  av_rddatavalid  : in std_logic;
  av_readdata     : in std_logic_vector(31 downto 0);


  --// Master AVALON interface for reading gain tables
  dma1_rdready    : in  std_logic;                      -- DMA Ready Request
  dma1_rdreq      : out std_logic;                      -- DMA Read Request
  dma1_rdsize     : out std_logic_vector(DMA_SIZE_BITS-1 downto 0);  -- DMA Request Size
  dma1_rdaddr     : out std_logic_vector(31 downto 0);  -- DMA Master Address
  dma1_rddav      : in  std_logic;                      -- DMA Read Data Valid
  dma1_rddata     : in  std_logic_vector(31 downto 0);  -- DMA Read Data
  --// Master AVALON interface for reading offset tables
  dma2_rdready    : in  std_logic;                      -- DMA Ready Request
  dma2_rdreq      : out std_logic;                      -- DMA Read Request
  dma2_rdsize     : out std_logic_vector(DMA_SIZE_BITS-1 downto 0);  -- DMA Request Size
  dma2_rdaddr     : out std_logic_vector(31 downto 0);  -- DMA Master Address
  dma2_rddav      : in  std_logic;                      -- DMA Read Data Valid
  dma2_rddata     : in  std_logic_vector(31 downto 0);  -- DMA Read Data

  video_i_v       : in  std_logic;                      -- Video Input   Vertical Synchro
  video_i_h       : in  std_logic;                      -- Video Input Horizontal Synchro
  video_i_eoi     : in  std_logic;                      -- Video Input End Of Image
  video_i_dav     : in  std_logic;                      -- Video Input Data Valid
  video_i_data    : in  std_logic_vector(bit_width downto 0);  -- Video Input Data

  video_o_v       : out std_logic;                      -- Video Output   Vertical Synchro
  video_o_h       : out std_logic;                      -- Video Output Horizontal Synchro
  video_o_eoi     : out std_logic;                      -- Video Output End Of Image
  video_o_dav     : out std_logic;                      -- Video Output Data Valid
  video_o_data    : out std_logic_vector(bit_width downto 0);  -- Video Output Data
  video_o_bad     : out std_logic;                      -- Video Output Bad Pixel

  update_gallery_img_valid_reg_en      : in std_logic;    
  update_gallery_img_valid_reg         : in std_logic_vector (71 downto 0);     
  temperature_write_data               : in std_logic_vector (7 downto 0);
  temperature_write_data_valid         : in std_logic;
  temperature_rd_data                  : out std_logic_vector(15 downto 0); -- output
  temperature_rd_data_valid            : out std_logic; -- outpur
  temperature_rd_rq                    : in std_logic; --//input
  temperature_wr_addr                  : in std_logic_vector (7 downto 0); -- input
  temperature_wr_rq                    : in std_logic; --//input
  STORE_TEMP_AVG_FRAME                 : in  std_logic_vector(15 downto 0);--//input

  ADDR_COARSE_OFFSET : out std_logic_vector(31 downto 0);
  update_sensor_param         : out std_logic;
  new_sensor_param_start_addr : out std_logic_vector(5 downto 0);
  CUR_TEMP_AREA    : out std_logic_vector(2 downto 0);    
  temp_sense_offset : in std_logic_vector(3 downto 0);
  take_snapshot_reg : out std_logic;
  area_switch_done  : out std_logic;
  low_to_high_temp_area_switch : out std_logic;
  high_to_low_temp_area_switch : out std_logic;
  MUX_NUC_MODE                 : in std_logic_vector(1 downto 0);
  MUX_BLADE_MODE               : in std_logic_vector(1 downto 0);
  toggle_gpio                  : out std_logic;
  calc_done                    : out std_logic;
  calc_busy                    : out std_logic;
  temp_data       : in std_logic_vector(15 downto 0)

  );

  end component;


  component snap_img_avg is             --  module snap_img_avg (
  port( clk : in std_logic;              --  input clk,    // Clock
        rst : in std_logic;              --  input rst,  // Asynchronous reset active high
        
        av_ready : in std_logic;
        av_read : out std_logic;
        av_write : out std_logic;
        av_wrburst : out std_logic;
        av_size : out std_logic_vector(5 downto 0);
        av_address : out std_logic_vector(31 downto 0);
        av_writedata : out std_logic_vector(31 downto 0);
        av_wrbe : out std_logic_vector(3 downto 0);
        av_rddatavalid : in std_logic;
        av_readdata : in std_logic_vector(31 downto 0);

        avl_waitrequest : out std_logic;
        avl_write : in std_logic;
        avl_writedata : in std_logic_vector(31 downto 0);
        avl_address : in std_logic_vector(3 downto 0);
        avl_read : in std_logic;
        avl_readdatavalid : out std_logic;
        avl_readdata : out std_logic_vector(31 downto 0)
);
end component;

component update_coarse_offset is
port (
  clk     : in std_logic;
  rst     : in std_logic;
  target_value_threshold :in std_logic_vector(15 downto 0);

  av_ready : in std_logic;
  av_read : out std_logic;
  av_write : out std_logic;
  av_wrburst : out std_logic;
  av_size : out std_logic_vector(5 downto 0);
  av_address : out std_logic_vector(31 downto 0);
  av_writedata : out std_logic_vector(31 downto 0);
  av_wrbe : out std_logic_vector(3 downto 0);
  av_rddatavalid : in std_logic;
  av_readdata : in std_logic_vector(31 downto 0);

  avl_waitrequest : out std_logic;
  avl_write : in std_logic;
  avl_writedata : in std_logic_vector(31 downto 0);
  avl_address : in std_logic_vector(3 downto 0);
  avl_read : in std_logic;
  avl_readdatavalid : out std_logic;
  avl_readdata : out std_logic_vector(31 downto 0)
  
);
end component;

component SPI_Slave_Comm  is
--  generic(SPI_MODE : natural := 0
--  );
  port (
   rst              : in std_logic;
   clk              : in std_logic;
   spi_mode         : in std_logic_vector(1 downto 0);
   spi_sclk         : in std_logic;
   spi_miso         : out std_logic;
   spi_mosi         : in std_logic;
   spi_ss           : in std_logic;
   read_data_valid  : out std_logic;    
   read_data        : out std_logic_vector(7 downto 0); 
   write_data_valid : in std_logic;  
   write_data       : in std_logic_vector(7 downto 0) 
   );
end component;

component SPI_SLAVE_DATA_DECODE is
 generic(DATA_WIDTH : positive := 8);
  port (
   rst                    : in   std_logic;
   clk                    : in   std_logic;
   data_in_valid          : in   std_logic;    
   data_in                : in   std_logic_vector(7 downto 0); 
   data_out_valid         : out  std_logic;    
   data_out               : out  std_logic_vector(7 downto 0); 
   debug_reg              : out  std_logic_vector(7 downto 0);
   usb_video_data_out_sel : out  std_logic;
   pal_ntsc_sel           : out  std_logic
   );
end component;


component Sensor_Temp_Extract is
generic(
Total_Temperature_Byte: positive := 4;
shift_right_bit       : positive:=2;
VIDEO_XSIZE           : positive :=  VIDEO_XSIZE;
VIDEO_YSIZE           : positive :=  VIDEO_YSIZE
);

port(
    clk                     :in std_logic; -- //input             
    reset                   :in std_logic; -- //input             
    Sensor_Linevalid        :in std_logic;  -- //input             
    Sensor_Framevalid       :in std_logic; --//input            
    Sensor_Data_Valid       :in std_logic; --//input             
    Sensor_Data             :in std_logic_vector(15 downto 0);        --// input      [15:0] 
    Sensor_Temperature       :out std_logic_vector(31 downto 0)   --//  output reg [31:0] 
   );
end component;
-------------------------------------------------------------------------------------------


component img_info is
generic(
VIDEO_XSIZE           : positive :=  VIDEO_XSIZE;
VIDEO_YSIZE           : positive :=  VIDEO_YSIZE;
BIT_WIDTH             : positive :=  BIT_WIDTH
);

port(
    clk                     :in std_logic; -- //input             
    reset                   :in std_logic; -- //input             
    Sensor_Linevalid        :in std_logic;  -- //input             
    Sensor_Framevalid       :in std_logic; --//input   
    Sensor_EOI              :in std_logic; --//input         
    Sensor_Data_Valid       :in std_logic; --//input             
    Sensor_Data             :in std_logic_vector(BIT_WIDTH -1 downto 0);        --// input      [15:0] 
    Img_Min_Limit           :in std_logic_vector(BIT_WIDTH -1 downto 0); 
    Img_Max_Limit           :in std_logic_vector(BIT_WIDTH -1 downto 0); 
    Img_Avg                 :out std_logic_vector(BIT_WIDTH -1 downto 0)   --//  output reg [31:0] 
   );
end component;

 

component filter3x3_blur is
generic(
    bitwidth    : positive :=  8 ;
    VIDEO_XSIZE : positive :=  VIDEO_XSIZE;
        VIDEO_YSIZE : positive :=  VIDEO_YSIZE;       
      PIX_BITS    : positive :=  PIX_BITS;
      LIN_BITS    : positive :=  LIN_BITS
);

port(
  clk          :in  std_logic; -- //input     
  rst          :in  std_logic; -- //input     

  av_wr        :in  std_logic; -- //input     
    av_addr      :in  std_logic_vector(7 downto 0); -- //input     
    av_data      :in  std_logic_vector(15 downto 0); -- //input     
    av_busy      :out  std_logic; -- //output     

  video_i_v    :in  std_logic; -- //input       
  video_i_h    :in  std_logic; -- //input       
  video_i_eoi  :in  std_logic; -- //input       
  video_i_dav  :in  std_logic; -- //input       
  video_i_data :in  std_logic_vector(7 downto 0); -- //input     

  video_o_v    :out std_logic; -- //output      
  video_o_h    :out std_logic; -- //output      
  video_o_eoi  :out std_logic; -- //output      
  video_o_dav  :out std_logic; -- //output      
  video_o_data :out std_logic_vector(7 downto 0) -- //output    
   );
end component;



component filter3x3_sharp_edge is
generic(
    bitwidth    : positive :=  8 ;
    VIDEO_XSIZE : positive :=  VIDEO_XSIZE;
        VIDEO_YSIZE : positive :=  VIDEO_YSIZE;       
      PIX_BITS    : positive :=  PIX_BITS;
      LIN_BITS    : positive :=  LIN_BITS
);

port(
  clk          :in  std_logic; -- //input     
  rst          :in  std_logic; -- //input     

  av_wr        :in  std_logic; -- //input     
    av_addr      :in  std_logic_vector(7 downto 0); -- //input     
    av_data      :in  std_logic_vector(15 downto 0); -- //input     
    av_busy      :out  std_logic; -- //output     

  video_i_v    :in  std_logic; -- //input       
  video_i_h    :in  std_logic; -- //input       
  video_i_eoi  :in  std_logic; -- //input       
  video_i_dav  :in  std_logic; -- //input       
  video_i_data :in  std_logic_vector(7 downto 0); -- //input     

  video_o_v    :out std_logic; -- //output      
  video_o_h    :out std_logic; -- //output      
  video_o_eoi  :out std_logic; -- //output      
  video_o_dav  :out std_logic; -- //output      
  video_o_data :out std_logic_vector(7 downto 0) -- //output      
   );
end component;


--component Sensor_Temp_Extract is
--port(
--    clk                     :in std_logic; -- //input             
--    reset                   :in std_logic; -- //input             
--    Sensor_Linevalid        :in std_logic;  -- //input             
--    Sensor_Framevalid       :in std_logic; --//input            
--    Sensor_Data_Valid       :in std_logic; --//input             
--    Sensor_Data             :in std_logic_vector(15 downto 0);        --// input      [15:0] 
--    Sensor_Temperature       :out std_logic_vector(31 downto 0)   --//  output reg [31:0] 
--   );
--end component;

--component Top_Test_Qspi_Flash is
--port(
--    clk             :in std_logic; -- //input  
--    reset           :in std_logic; -- //input
--    Start_QSPI_Module : in std_logic; --//input
--    FPGA_SPI_DQ0    :inout std_logic;--//inout 
--    FPGA_SPI_DQ1    :inout std_logic; --//inout 
--    FPGA_SPI_DQ2    :inout std_logic;--//inout 
--    FPGA_SPI_DQ3    :inout std_logic;--//inout 
--    FPGA_SPI_CS     :out std_logic;--//output 
--    write_data      :in std_logic_vector(7 downto 0); --input
--    write_data_valid:in std_logic; -- //input
--    read_sdram_data_rq:out std_logic;--//output 
--    write_sdram_data_rq:out std_logic; -- //output
--    sdram_write_done : in std_logic; --// input
--    read_data_valid :out std_logic;--//output 
--    read_data       :out std_logic_vector(7 downto 0);--//output reg [7:0]
--    rx_rd_fifo_rq   :in std_logic;
--    rx_rd_fifo_data :out std_logic_vector(7 downto 0)--//output reg [7:0]
--    );
--end component;

----------------------
component temp_extract is
----------------------
  generic(
    BIT_WIDTH            : positive := BIT_WIDTH;
    PIX_BITS             : positive := PIX_BITS;    
    LIN_BITS             : positive := LIN_BITS;
--    image_width_full     : positive := image_width_full;
--    temp_pixels_left     : natural := temp_pixels_left;
--    temp_pixels_right    : natural := temp_pixels_right;
--    exclude_left         : natural := exclude_left;
--    exclude_right        : natural := exclude_right;
    VIDEO_XSIZE          : positive := VIDEO_XSIZE;
    VIDEO_YSIZE          : positive := VIDEO_YSIZE
  );
  port(
   clk                   : in std_logic;
   rst                   : in std_logic;
   image_width_full      : in std_logic_vector(PIX_BITS-1 downto 0); 
   temp_pixels_left      : in std_logic_vector(PIX_BITS-1 downto 0); 
   temp_pixels_right     : in std_logic_vector(PIX_BITS-1 downto 0);   
   video_i_v             : in std_logic;
   video_i_h             : in std_logic;
   video_i_dav           : in std_logic;
   video_i_eoi           : in std_logic;
   video_i_data          : in std_logic_vector(BIT_WIDTH-1 downto 0);
   exclude_left          : in std_logic_vector(7 downto 0);
   exclude_right         : in std_logic_vector(7 downto 0);
--   IMG_FLIP_H            : in std_logic;
   video_o_v             : out std_logic;
   video_o_h             : out std_logic;
   video_o_dav           : out std_logic;
   video_o_eoi           : out std_logic;
   video_o_data          : out std_logic_vector(BIT_WIDTH-1 downto 0);
   temp_valid            : out std_logic;
   temp_data             : out std_logic_vector(BIT_WIDTH-1 downto 0);
   temp_avg_line         : out std_logic_vector(BIT_WIDTH-1 downto 0);
   temp_avg_frame        : out std_logic_vector(BIT_WIDTH-1 downto 0)
  );
--------------  
end component;
--------------------

-------------- -----------------------
component Top_CLHE_Impl_With_BRAM_IP is
-------------------------------------

generic (
 VIDEO_I_DATA_WIDTH        :positive := 12;
 HIST_BIN_WIDTH            :positive :=  19;
 CDF_BIN_WIDTH             :positive :=  19;
 VIDEO_OUT_DATA_WIDTH      :positive :=  8;
 NUMBER_OUT_LEVELS         :positive := 256;
 NUMBER_OF_ITR             :positive :=  12;
 NUMBER_IN_LEVELS          :positive :=  4096;
 NUMBER_OF_IN_PIXELS       :positive := 308160;
 MIN_PIXEL_COUNT           :positive :=  3081; --(0.01 * 308160),
 MAX_PIXEL_COUNT           :positive :=  305078; --(0.99 * 308160),
 MAX_DIFFERENCE_PERCENTAGE :positive := 4;
 MULT_FACTOR               :positive := 54
  );
port (
   VIDEO_I_PCLK                   : in std_logic;
   RESET                          : in std_logic;
   VIDEO_I_VSYNC                  : in std_logic;
   VIDEO_I_HSYNC                  : in std_logic;
   VIDEO_I_DAV                    : in std_logic;
   VIDEO_I_DATA                   : in std_logic_vector(11 downto 0);
   VIDEO_I_EOI                    : in std_logic;
   Clip_Threshold                 : in std_logic_vector(18 downto 0);  
   VIDEO_OUT_VSYNC                : out std_logic;
   VIDEO_OUT_HSYNC                : out std_logic;
   VIDEO_OUT_DAV                  : out std_logic;
   CLHE_OUT                       : out std_logic_vector(7 downto 0);
   VIDEO_OUT_EOI                  : out std_logic;
   Temp_PING_PONG_Excess_Pixel    : out std_logic_vector(18 downto 0);
   Temp_Pixel_Count               : out std_logic_vector(18 downto 0) 
   --VIDEO_O_XCNT                   : out std_logic_vector(9 downto 0);
   --VIDEO_O_YCNT                   : out std_logic_vector(9 downto 0)
  );
  end component;
  
----------------------------------------------

component IMG_SHIFT_VERT_CONTROLLER is 
 generic( 
   PIX_BITS             : positive := 10;--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
   LIN_BITS             : positive := 10;--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image   
   DATA_BITS            : positive := 24; --
   VIDEO_XSIZE          : positive := VIDEO_XSIZE;
   VIDEO_YSIZE          : positive := VIDEO_YSIZE;         
   VIDEO_SCALE_XSIZE    : positive := 640;  
   VIDEO_SCALE_YSIZE    : positive := 480 
  );
 port(
     CLK                   : in std_logic;
     RST                   : in std_logic;
     IMG_SHIFT_VERT        : in std_logic_vector(LIN_BITS-1 downto 0);
     SCALER_RUN            : in std_logic;
     SCALER_REQ_V          : in  std_logic; 
     SCALER_REQ_H          : in  std_logic;
--     SCALER_FIELD          : in  std_logic;
     SCALER_LINE_NO        : in  std_logic_vector(LIN_BITS-1 downto 0);
     SCALER_REQ_XSIZE      : in  std_logic_vector(PIX_BITS-1 downto 0);
     SCALER_REQ_YSIZE      : in  std_logic_vector(LIN_BITS-1 downto 0);
     IN_Y_OFF              : in  std_logic_vector(LIN_BITS-1 downto 0);
     IMG_SHIFT_REQ_V       : out std_logic;
     IMG_SHIFT_REQ_H       : out std_logic;
--     IMG_SHIFT_FIELD       : out std_logic;
     IMG_SHIFT_LINE_NO     : out std_logic_vector(LIN_BITS-1 downto 0);
     IMG_SHIFT_REQ_XSIZE   : out std_logic_vector(PIX_BITS-1 downto 0);
     IMG_SHIFT_REQ_YSIZE   : out  std_logic_vector(LIN_BITS-1 downto 0);
     IMG_SHIFT_I_V         : in  std_logic;
     IMG_SHIFT_I_H         : in  std_logic;
     IMG_SHIFT_I_DAV       : in  std_logic;
     IMG_SHIFT_I_DATA      : in  std_logic_vector(7 downto 0);
     IMG_SHIFT_I_EOI       : in  std_logic;
     IMG_SHIFT_I_XSIZE     : in  std_logic_vector(PIX_BITS-1 downto 0);
     IMG_SHIFT_I_YSIZE     : in  std_logic_vector(LIN_BITS-1 downto 0);    
     IMG_SHIFT_O_V         : out  std_logic;   
     IMG_SHIFT_O_H         : out  std_logic;   
     IMG_SHIFT_O_EOI       : out  std_logic;
     IMG_SHIFT_O_DAV       : out  std_logic; 
     IMG_SHIFT_O_DATA      : out std_logic_vector(7 downto 0);
     IMG_SHIFT_O_XCNT      : out std_logic_Vector(10 downto 0);
     IMG_SHIFT_O_YCNT      : out std_logic_Vector(9 downto 0)    
   
     );
  end component;  
    
  
----------------------------------------------  
------------------------------------

component Add_Border is 
 generic( 
   PIX_BITS             : positive := 10;--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
   LIN_BITS             : positive := 10;--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image   
   DATA_BITS            : positive := 24; --
   VIDEO_XSIZE          : positive := VIDEO_XSIZE;
   VIDEO_YSIZE          : positive := VIDEO_YSIZE;         
   VIDEO_SCALE_XSIZE    : positive := 640;  
   VIDEO_SCALE_YSIZE    : positive := 480 
  );
 port(
     CLK : in std_logic;
     RST : in std_logic;
     SCALER_RUN : in std_logic;
     ZOOM_ENABLE: in std_logic;
     ZOOM_ENABLE_LATCH: out std_logic;
     fit_to_screen_en  : in std_logic;
     RETICLE_ENABLE : in std_logic;
     RETICLE_ENABLE_LATCH : out std_logic;
     OSD_ENABLE     : in std_logic;
     OSD_ENABLE_LATCH : out std_logic;
     CROP_START         : in std_logic;
     IMG_CROP_LEFT      : in std_logic_vector(PIX_BITS-1 downto 0); 
     IMG_CROP_RIGHT     : in std_logic_vector(PIX_BITS-1 downto 0); 
     IMG_CROP_TOP       : in std_logic_vector(LIN_BITS-1 downto 0); 
     IMG_CROP_BOTTOM    : in std_logic_vector(LIN_BITS-1 downto 0); 


--     IMG_SHIFT_LR_UPDATE  : in std_logic;
--     IMG_SHIFT_LR_SEL     : in std_logic;
--     IMG_SHIFT_LR         : in std_logic_vector(PIX_BITS-1 downto 0);
--     IMG_SHIFT_UD_UPDATE  : in std_logic;
--     IMG_SHIFT_UD_SEL     : in std_logic;
--     IMG_SHIFT_UD         : in std_logic_vector(LIN_BITS-1 downto 0);
     
     BT656_REQ_V          : in  std_logic; 
     BT656_REQ_H          : in  std_logic;
     BT656_FIELD          : in  std_logic;
     BT656_LINE_NO        : in  std_logic_vector(LIN_BITS-1 downto 0);
     BT656_REQ_XSIZE      : in  std_logic_vector(PIX_BITS-1 downto 0);
     BT656_REQ_YSIZE      : in  std_logic_vector(LIN_BITS-1 downto 0);
     ADD_BORDER_REQ_V     : out std_logic;
     ADD_BORDER_REQ_H     : out std_logic;
     ADD_BORDER_FIELD     : out std_logic;
     ADD_BORDER_LINE_NO   : out std_logic_vector(LIN_BITS-1 downto 0);
     ADD_BORDER_REQ_XSIZE : out std_logic_vector(PIX_BITS-1 downto 0);
     ADD_BORDER_REQ_YSIZE : out  std_logic_vector(LIN_BITS-1 downto 0);
     ADD_BORDER_I_V       : in  std_logic;
     ADD_BORDER_I_H       : in  std_logic;
     ADD_BORDER_I_DAV     : in  std_logic;
     ADD_BORDER_I_DATA    : in  std_logic_vector(7 downto 0);--std_logic_vector(23 downto 0);
     ADD_BORDER_I_EOI     : in  std_logic;
     ADD_BORDER_I_XSIZE   : in  std_logic_vector(PIX_BITS-1 downto 0);
     ADD_BORDER_I_YSIZE   : in  std_logic_vector(LIN_BITS-1 downto 0); 
     RETICLE_OFFSET_X     : out  std_logic_vector(PIX_BITS-1 downto 0);
     RETICLE_OFFSET_Y     : out  std_logic_vector(LIN_BITS-1 downto 0);
--     IMG_SHIFT_POS_X      : out  std_logic_vector(PIX_BITS-1 downto 0);
--     IMG_SHIFT_POS_Y      : out  std_logic_vector(LIN_BITS-1 downto 0);
     
     ADD_BORDER_O_V       : out  std_logic;   
     ADD_BORDER_O_H       : out  std_logic;   
     ADD_BORDER_O_EOI     : out  std_logic;
     ADD_BORDER_O_DAV     : out  std_logic; 
     ADD_BORDER_O_DATA    : out  std_logic_vector(7 downto 0) --std_logic_vector(23 downto 0)   
--     ADD_BORDER_O_XSIZE   : out  std_logic_vector(PIX_BITS-1 downto 0);
--     ADD_BORDER_O_YSIZE   : out  std_logic_vector(LIN_BITS-1 downto 0)      
     );
  end component;  
  
-- component  ADD_LOGO is
--  generic ( 
--    PIX_BITS  :positive := 10;
--    LIN_BITS  :positive := 10;
--    DATA_BITS :positive := 24;
--    LOGO_INIT_MEM_ADDR_BIT_WIDTH :positive := 13;
--    LOGO_INIT_MEM_DATA_BIT_WIDTH :positive := 2 ;
--    LOGO_XSIZE :positive := 40;
--    LOGO_YSIZE :positive := 40           
--  );
--  port(
--  CLK                 : in  std_logic;    
--  RST                 : in  std_logic;
--  LOGO_EN             : in  std_logic;
--  ADD_LOGO_I_V        : in  std_logic;
--  ADD_LOGO_I_H        : in  std_logic;
--  ADD_LOGO_I_EOI      : in  std_logic;
--  ADD_LOGO_I_DAV      : in  std_logic;
--  ADD_LOGO_I_DATA     : in  std_logic_vector(23 downto 0);
--  ADD_LOGO_I_XSIZE    : in  std_logic_vector(PIX_BITS-1 downto 0);
--  ADD_LOGO_I_YSIZE    : in  std_logic_vector(LIN_BITS-1 downto 0);
--  ADD_LOGO_I_FIELD    : in  std_logic;
--  LOGO_POS_X          : in  std_logic_vector(PIX_BITS-1 downto 0);
--  LOGO_POS_Y          : in  std_logic_vector(LIN_BITS-1 downto 0);
--  LOGO_COLOR_INFO1    : in  std_logic_vector(23 downto 0);
--  LOGO_COLOR_INFO2    : in  std_logic_vector(23 downto 0);
--  ADD_LOGO_O_V        : out  std_logic;
--  ADD_LOGO_O_H        : out  std_logic;
--  ADD_LOGO_O_EOI      : out  std_logic;
--  ADD_LOGO_O_DAV      : out  std_logic;
--  ADD_LOGO_O_DATA     : out  std_logic_vector(23 downto 0)
----  ADD_LOGO_O_XSIZE    : out  std_logic_vector(PIX_BITS-1 downto 0);
----  ADD_LOGO_O_YSIZE    : out  std_logic_vector(LIN_BITS-1 downto 0)
                   
--  );
--   end component;  

---------------------------
-- component bt656_gen_new is
-- generic(
--           LIN_BITS :positive := LIN_BITS;
--           PIX_BITS :positive := PIX_BITS;
--           VIDEO_IN_XSIZE :positive := VIDEO_XSIZE;
--           VIDEO_IN_YSIZE :positive := VIDEO_YSIZE
-- );
-- port (
--         clk  : in std_logic;
--         reset: in std_logic;
--         video_i_v: in std_logic;
--         video_i_h: in std_logic;
--         video_i_dav: in std_logic;
--         video_i_data: in std_logic_vector(7 downto 0);
--         video_i_eoi: in std_logic;
     
--         bt656_run: in std_logic;
--         bt656_req_v: out std_logic;
--         bt656_req_h: out std_logic;
--         bt656_line_no: out std_logic_vector(LIN_BITS-1 downto 0);
--         bt656_req_xsize: out std_logic_vector(PIX_BITS-1 downto 0);
--         bt656_req_ysize: out std_logic_vector(LIN_BITS-1 downto 0);
--         PAL_nNTSC: in std_logic;
--         clk27    : in std_logic;       
--         bt656_data : out std_logic_vector(7 downto 0)
--     );
--end component;
--  component bt656_gen_new2 is
--  generic(
--    PIX_BITS : integer :=10;
--    LIN_BITS : integer :=10
--    );
--  port(
--      clk                     : in std_logic;
--      reset                   : in std_logic;
--      video_i_v               : in std_logic;
--      video_i_h               : in std_logic;
--      video_i_dav             : in std_logic;
--      video_i_data            : in std_logic_vector(15 downto 0);
--      video_i_eoi             : in std_logic;
--      video_i_xsize       : in std_logic_vector(PIX_BITS-1 downto 0);
--      video_i_ysize       : in std_logic_vector(LIN_BITS-1 downto 0);
          
--      bt656_run               : in std_logic;
--      bt656_req_v             : out std_logic;
--      bt656_req_h             : out std_logic;
--      bt656_field         : out std_logic;
--      bt656_line_no           : out std_logic_vector(LIN_BITS-1 downto 0);
--      bt656_req_xsize         : out std_logic_vector(PIX_BITS-1 downto 0);
--      bt656_req_ysize         : out std_logic_vector(LIN_BITS-1 downto 0);
--      PAL_nNTSC               : in std_logic;
          
--      clk27           : in std_logic;
--      bt656_data              : out std_logic_vector(7 downto 0)
--    );
--  end component;
---------------------------------
  component bt656_gen_new2 is
  generic(
    PIX_BITS : integer :=10;
    LIN_BITS : integer :=10
    );
  port(
      clk                     : in std_logic;
      reset                   : in std_logic;
--      fit_to_screen_en        : in std_logic;
--      latch_fit_to_screen_en  : out std_logic;      
      scaling_disable         : in std_logic;
      latch_scaling_disable   : out std_logic;
      img_up_shift_vert       : in std_logic_Vector(9 downto 0);
      latch_img_up_shift_vert : out std_logic_Vector(9 downto 0);
      add_border_i_xsize      : out std_logic_vector(PIX_BITS-1 downto 0);
      add_border_i_ysize      : out std_logic_vector(LIN_BITS-1 downto 0);
      video_i_v               : in std_logic;
      video_i_h               : in std_logic;
      video_i_dav             : in std_logic;
      video_i_data            : in std_logic_vector(15 downto 0);
      video_i_eoi             : in std_logic;
      video_i_xsize       : in std_logic_vector(PIX_BITS-1 downto 0);
      video_i_ysize       : in std_logic_vector(LIN_BITS-1 downto 0);
          
      bt656_run               : in std_logic;
      bt656_req_v             : out std_logic;
      bt656_req_h             : out std_logic;
      bt656_field         : out std_logic;
      bt656_line_no           : out std_logic_vector(LIN_BITS-1 downto 0);
      bt656_req_xsize         : out std_logic_vector(PIX_BITS-1 downto 0);
      bt656_req_ysize         : out std_logic_vector(LIN_BITS-1 downto 0);
      PAL_nNTSC               : in std_logic;
          
      clk27           : in std_logic;
      rst27           : in std_logic;
      bt656_data              : out std_logic_vector(7 downto 0)
    );
  end component;
-----------------------------

--  component image_shift_control is
--  generic(
--    PIX_BITS  : integer :=10;
--    LIN_BITS  : integer :=10;
--    DATA_BITS : integer :=16
--    );
--  port(
--      clk                     : in std_logic;
--      rst                     : in std_logic;
--      img_shift_vert          : in std_logic_vector(LIN_BITS-1 downto 0);
--      video_i_v               : in std_logic;
--      video_i_h               : in std_logic;
--      video_i_dav             : in std_logic;
--      video_i_data            : in std_logic_vector(7 downto 0);
--      video_i_eoi             : in std_logic;
--      video_i_xsize           : in std_logic_vector(PIX_BITS-1 downto 0);
--      video_i_ysize           : in std_logic_vector(LIN_BITS-1 downto 0);
--      video_req_xsize         : in std_logic_vector(PIX_BITS-1 downto 0);
--      video_req_ysize         : in std_logic_vector(LIN_BITS-1 downto 0);          
--      add_left_pix            : in std_logic_vector(PIX_BITS-1 downto 0);
--      add_right_pix           : in std_logic_vector(LIN_BITS-1 downto 0);  
--      video_o_v               : out std_logic;
--      video_o_h               : out std_logic;
--      video_o_eoi             : out std_logic;
--      video_o_dav             : out std_logic;
--      video_o_data            : out std_logic_vector(7 downto 0)        
      
--    );
--  end component;
-------------------------------


  component usb_video_data_input_gen is
  generic(
    PIX_BITS  : integer :=10;
    LIN_BITS  : integer :=10;
    DATA_BITS : integer :=16
    );
  port(
      clk                     : in std_logic;
      rst                     : in std_logic;
      video_i_v               : in std_logic;
      video_i_h               : in std_logic;
      video_i_dav             : in std_logic;
      video_i_data            : in std_logic_vector(15 downto 0);
      video_i_eoi             : in std_logic;
      video_i_xsize           : in std_logic_vector(PIX_BITS-1 downto 0);
      video_i_ysize           : in std_logic_vector(LIN_BITS-1 downto 0);
      video_req_xsize         : in std_logic_vector(PIX_BITS-1 downto 0);
      video_req_ysize         : in std_logic_vector(LIN_BITS-1 downto 0);          
      add_left_pix            : in std_logic_vector(PIX_BITS-1 downto 0);
      add_right_pix           : in std_logic_vector(LIN_BITS-1 downto 0);  
      video_o_v               : out std_logic;
      video_o_h               : out std_logic;
      video_o_eoi             : out std_logic;
      video_o_dav             : out std_logic;
      video_o_data            : out std_logic_vector(15 downto 0)        
      
    );
  end component;
-----------------------------


--  component vsync_hsync_16bit_data is
--  generic(
--    PIX_BITS : integer :=10;
--    LIN_BITS : integer :=10
--    );
--  port(
--      clk                     : in std_logic;
--      reset                   : in std_logic;
--      tick1s                  : in std_logic;
--      video_i_v               : in std_logic;
--      video_i_h               : in std_logic;
--      video_i_dav             : in std_logic;
--      video_i_data            : in std_logic_vector(15 downto 0);
--      video_i_eoi             : in std_logic;
--      video_i_xsize       : in std_logic_vector(PIX_BITS-1 downto 0);
--      video_i_ysize       : in std_logic_vector(LIN_BITS-1 downto 0);
          
--      bt656_run               : in std_logic;
--      bt656_req_v             : in std_logic;
--      bt656_req_h             : in std_logic;

--      PAL_nNTSC               : in std_logic;
          
--      pclk                  : in std_logic;
--      video_o_frame_valid     : out std_logic;
--      video_o_line_valid      : out std_logic; 
--      video_o_data            : out std_logic_vector(15 downto 0)
--    );
--  end component;
-----------------------------

  component vsync_hsync_16bit_data is
  generic(
    PIX_BITS : integer :=10;
    LIN_BITS : integer :=10
    );
  port(
      clk                     : in std_logic;
      reset                   : in std_logic;
      tick1s                  : in std_logic;
      video_i_v               : in std_logic;
      video_i_h               : in std_logic;
      video_i_dav             : in std_logic;
      video_i_data            : in std_logic_vector(15 downto 0);
      video_i_eoi             : in std_logic;
      video_i_xsize       : in std_logic_vector(PIX_BITS-1 downto 0);
      video_i_ysize       : in std_logic_vector(LIN_BITS-1 downto 0);
          
      bt656_run               : in std_logic;
      bt656_req_v             : in std_logic;
      bt656_req_h             : in std_logic;

      PAL_nNTSC               : in std_logic;
          
      pclk                  : in std_logic;
      video_o_frame_pulse     : out std_logic;
      video_o_frame_valid     : out std_logic;
      video_o_line_valid      : out std_logic; 
      video_o_data            : out std_logic_vector(15 downto 0)
    );
  end component;
-----------------------------


----------------------------
component sdram_top_av is
------------------------------
generic (       AV_FREQ :positive := SYS_FREQ;
                SDRAM_FREQ :positive := SDRAM_FREQ;
                APP_AW   :positive := 32; -- // Application Address Width
                APP_AW_VALID  :positive := 26;-- // Application Valid Address Width 26bits for 512Mb SDRAM
                APP_DW   :positive := 32;  --// Application Data Width 
                APP_BW   :positive := 4;  -- // Application Byte Width
                APP_RW   :positive := 5;   --// Application Request Width
                SDR_DW   :positive := 32;  --// SDR Data Width 
                SDR_BW  :positive := 4   --// SDR Byte Width
               
);
port (   
           av_rst_i          : in std_logic;
           av_clk_i          : in std_logic;
           av_busy_o         : out std_logic;
           av_addr_i         : in std_logic_vector(APP_AW-1 downto 0);
           av_size_i         : in std_logic_vector(APP_RW-1 downto 0);
           av_wr_i           : in std_logic;
           av_wrburst_i      : in std_logic;
           av_data_i         : in std_logic_vector(APP_DW-1 downto 0);
--           av_addr_dec       : in std_logic;
           av_byteenable_i   : in std_logic_vector(APP_BW-1 downto 0);
           av_rd_i           : in std_logic;
           av_data_o         : out std_logic_vector(APP_AW-1 downto 0);
           av_rddav_o        : out std_logic;

           sdram_init_done   : out std_logic;

           sdram_clk    : in std_logic;
           sdram_resetn : in std_logic;
           sdr_cs_n     : out std_logic;
           sdr_cke      : out std_logic;
           sdr_ras_n    : out std_logic;
           sdr_cas_n    : out std_logic;
           sdr_we_n     : out std_logic;
           sdr_dqm      : out std_logic_vector(SDR_BW-1 downto 0);
           sdr_ba       : out std_logic_vector(1 downto 0);
           sdr_addr     : out std_logic_vector(12 downto 0);
           sdr_dq       : inout std_logic_vector(SDR_DW-1 downto 0)
);  
end component;
-----------------------------

  component HD_TEST_PATTERN_GEN is
  port(
    hd_clk  : in std_logic;
    rst     : in std_logic;
    hsync   : out std_logic;
    vsync   : out std_logic;
    data_enable : out std_logic;
    hd_data : out std_logic_vector(15 downto 0)
  ); 
 end component;

----------------------------
component TOII_TUVE_clk_wiz
port
 (-- Clock in ports
  clk_in1           : in     std_logic;
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_out3          : out    std_logic;
  clk_out4          : out    std_logic;
  clk_out5          : out    std_logic;
  clk_out6          : out    std_logic;
  clk_out7          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic
 );
end component;

component mipi_csi_ip_clock
port
 (-- Clock in ports
  clk_in1           : in     std_logic;
  -- Clock out ports
  clk_out1          : out    std_logic;

  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic
 );
end component;
----------------------------
--component clk_gen
--port
-- (-- Clock in ports
--  clk_in1           : in     std_logic;
--  -- Clock out ports
--  clk_out1          : out    std_logic;
--  -- Status and control signals
--  reset             : in     std_logic;
--  locked            : out    std_logic
-- );
--end component;
----------------------------
COMPONENT TOII_TUVE_ila

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;
----------------------------
----------------------------
component bno_packet_rx is
port(
clk                   : in  std_logic;
rst                   : in  std_logic;
trigger               : in  std_logic;
av_uart_readdata      : in  std_logic_vector(7 downto 0);
av_uart_readdatavalid : in  std_logic;
av_uart_waitrequest   : in  std_logic;
av_uart_address       : out std_logic_vector(7 downto 0);
av_uart_read          : out std_logic;
yaw                   : out std_logic_vector(15 downto 0);
pitch                 : out std_logic_vector(15 downto 0);
roll                  : out std_logic_vector(15 downto 0);
x_accel               : out std_logic_vector(15 downto 0);
y_accel               : out std_logic_vector(15 downto 0);
z_accel               : out std_logic_vector(15 downto 0);
crc_error             : out std_logic;
bno_data_valid        : out std_logic
);
end component;
----------------------------
component regs_master is
generic(
   SYS_FREQ   : positive := SYS_FREQ;
--   SPI_FREQ  : positive :=  SPI_FREQ;
   I2C_FREQ   : positive := I2C_FREQ;
   PIX_BITS   :positive := 10;
   LIN_BITS   :positive := 10;
   VIDEO_XSIZE : positive := VIDEO_XSIZE;
   VIDEO_YSIZE : positive := VIDEO_YSIZE;
   DMA_SIZE_BITS: positive := 5
   
  );
port(

  clk                     : in std_logic;
  rst                     : in std_logic;
  clk_27mhz               : in std_logic;
  rst_27mhz               : in std_logic;
  sel_oled_analog_video_out : in std_logic;
  coarse_offset_calib_start : in std_logic; 
  product_sel             : in std_logic;
  bat_adc_en              : in std_logic;
  trigger                 : in std_logic;
  sensor_trigger          : out std_logic;
  sensor_power_on_init_done : out std_logic; 
  adv_reset_n             : out std_logic;
  tick_1ms                : in std_logic;
  tick_1us                : in std_logic;
  tick_1s                 : in std_logic;
  PAL_nNTSC_SEL_DONE      : in std_logic;
  PAL_nNTSC               : in std_logic;
  pal_ntsc_sel            : in std_logic;
  standby_en_valid        : in std_logic;
  standby_en              : in std_logic;
  oled_reset              : out std_logic;
  oled_power_off          : out std_logic;
  OLED_VGN_TEST           : in std_logic_vector(31 downto 0); 
  OLED_GAMMA_TABLE_SEL    : in std_logic_vector (7 downto 0);
  OLED_POS_V              : in std_logic_vector(7 downto 0);
  OLED_POS_V_VALID        : in std_logic;
  OLED_POS_H              : in std_logic_vector(8 downto 0);
  OLED_POS_H_VALID        : in std_logic;
  OLED_BRIGHTNESS         : in std_logic_vector(7 downto 0);
  OLED_BRIGHTNESS_VALID   : in std_logic;  
  OLED_CONTRAST           : in std_logic_vector(7 downto 0);
  OLED_CONTRAST_VALID     : in std_logic; 
  OLED_IDRF               : in std_logic_vector(7 downto 0);
  OLED_IDRF_VALID         : in std_logic; 
  OLED_DIMCTL             : in std_logic_vector(7 downto 0);
  OLED_DIMCTL_VALID       : in std_logic; 
  OLED_IMG_FLIP           : in std_logic_vector(7 downto 0);
  OLED_IMG_FLIP_VALID     : in std_logic;
  OLED_CATHODE_VOLTAGE    : in std_logic_vector(7 downto 0);
  OLED_CATHODE_VOLTAGE_VALID : in std_logic;
  OLED_ROW_START_MSB      : in std_logic_vector(7 downto 0);
  OLED_ROW_START_MSB_VALID: in std_logic;
  OLED_ROW_START_LSB      : in std_logic_vector(7 downto 0);
  OLED_ROW_START_LSB_VALID: in std_logic;
  OLED_ROW_END_MSB        : in std_logic_vector(7 downto 0);
  OLED_ROW_END_MSB_VALID  : in std_logic;
  OLED_ROW_END_LSB        : in std_logic_vector(7 downto 0);
  OLED_ROW_END_LSB_VALID  : in std_logic;        
--  OLED_REG_DATA_IN        : in std_logic_vector(7 downto 0);
   
  ADV_DEV_ADDR            : out std_logic_vector(7 downto 0);
  OLED_DEV_ADDR           : out std_logic_vector(7 downto 0); 
  BAT_GAUGE_DEV_ADDR      : out std_logic_vector(7 downto 0);
  BAT_ADC_DEV_ADDR        : out std_logic_vector(7 downto 0);
  OLED_VGN_ADC_DEV_ADDR   : out std_logic_vector(7 downto 0);
  MAX_VGN_SETTLE_TIME     : in  std_logic_vector(7 downto 0);
  MAX_OLED_VGN_RD_PERIOD  : in  std_logic_vector(15 downto 0);
  MAX_BAT_PARAM_RD_PERIOD : in  std_logic_vector(15 downto 0);

  bat_control_reg_data    : out std_logic_vector(7 downto 0);
  bat_status_reg_data     : out std_logic_vector(7 downto 0);
  bat_temp_reg_data       : out std_logic_vector(15 downto 0);
  bat_voltage_reg_data    : out std_logic_vector(15 downto 0);
  bat_acc_charge_reg_data : out std_logic_vector(15 downto 0);

  magneto_x_data          : out std_logic_vector(15 downto 0);
  magneto_y_data          : out std_logic_vector(15 downto 0);
  magneto_z_data          : out std_logic_vector(15 downto 0);

  accel_x_data            : out std_logic_vector(15 downto 0);
  accel_y_data            : out std_logic_vector(15 downto 0);
  accel_z_data            : out std_logic_vector(15 downto 0);
    
  qspi_init_cmd_done      : out std_logic;  
  BT656_START             : out std_logic;
  video_start             : out std_logic;
  battery_disp_start      : out std_logic;
  LOGO_WR_EN              : out std_logic_vector(0 downto 0);
  LOGO_WR_DATA            : out std_logic_vector(31 downto 0);
  RETICLE_WR_EN           : out std_logic_vector(0 downto 0);
  RETICLE_WR_DATA         : out std_logic_vector(31 downto 0);
  RETICLE_OFFSET_WR_EN    : out std_logic_vector(0 downto 0);
  RETICLE_OFFSET_WR_DATA  : out std_logic_vector(31 downto 0);
    
  DMA_WRITE_FREE          : in std_logic;
  RETICLE_POS_X           : in std_logic_vector( PIX_BITS downto 0);
  RETICLE_POS_Y           : in std_logic_vector( LIN_BITS-1 downto 0);
  RETICLE_OFFSET_X        : in std_logic_vector( PIX_BITS downto 0);
  RETICLE_OFFSET_Y        : in std_logic_vector( LIN_BITS-1 downto 0);
  
  update_sensor_param         : in std_logic;
  new_sensor_param_start_addr : in std_logic_vector(5 downto 0); 
  sensor_init_data_len    : out std_logic_vector(5 downto 0); 

  snap_trigger          : out std_logic;
  snap_channel          : out std_logic_vector(2 downto 0);
  snap_mode             : out std_logic_vector(2 downto 0);
  snap_done             : in std_logic;
  snap_image_numbers    : out std_logic_vector(7 downto 0);
  single_snapshot_en    : in std_logic; 
--  continuous_snapshot_en: in std_logic;
  burst_snapshot_en     : in std_logic;
  burst_capture_size    : in std_logic_Vector(7 downto 0);
  snapshot_counter      : in std_logic_vector(7 downto 0);
  snapshot_save_done    : out std_logic;
  osd_snapshot_delete_en: in std_logic;
  gallery_img_number    : in std_logic_vector(7 downto 0);     
  snapshot_delete_done  : out std_logic;
  gallery_img_valid_save_done : out std_logic;
  gallery_img_valid     : out std_logic_vector(71 downto 0);
  gallery_img_valid_en  : out std_logic;
  
  SNSR_FPGA_NRST_SPI_CS          : out std_logic;
  SNSR_FPGA_I2C2_SCL_SPI_SCK     : inout std_logic;
  SNSR_FPGA_I2C2_SDA_SPI_SDO     : inout std_logic;
--  mux_zoom_mode                  : in std_logic_vector(2 downto 0);
  reticle_sel                    : in std_logic_vector(6 downto 0);
  qspi_reticle_transfer_rq       : in std_logic; 
  qspi_reticle_transfer_rq_ack   : out std_logic; 
  qspi_reticle_transfer_done     : out std_logic;
  OSD_MARK_BP                    : in std_logic;
  OSD_MARK_BP_VALID              : in std_logic;
  OSD_UNMARK_BP                  : in std_logic;
  OSD_UNMARK_BP_VALID            : in std_logic;
  OSD_SAVE_BP                    : in std_logic;
  OSD_LOAD_USER_SETTINGS         : in std_logic;
  OSD_LOAD_FACTORY_SETTINGS      : in std_logic;
  OSD_SAVE_USER_SETTINGS         : in std_logic;
  user_settings_mem_wr_addr      : in std_logic_vector(7 downto 0);
  user_settings_mem_wr_data      : in std_logic_vector(31 downto 0);
  user_settings_mem_wr_req       : in std_logic;
  user_settings_mem_rd_req       : in std_logic;
  user_settings_mem_rd_addr      : in std_logic_vector(7 downto 0);
  user_settings_mem_rd_data      : out std_logic_vector(31 downto 0);
  user_settings_init_start       : out std_logic;
  user_settings_init_done        : in std_logic;
  
  av_uart_address: out std_logic_vector(7 downto 0);
  av_uart_read: out std_logic;
  av_uart_readdata: in std_logic_vector(31 downto 0);
  av_uart_readdatavalid: in std_logic;
  av_uart_write: out std_logic;
  av_uart_writedata: out std_logic_vector(31 downto 0);
  av_uart_waitrequest: in std_logic;
  av_fpga_address: out std_logic_vector(31 downto 0);
  av_fpga_read: out std_logic;
  av_fpga_readdata: in std_logic_vector(31 downto 0);
  av_fpga_readdatavalid: in std_logic;
  av_fpga_write: out std_logic;
  av_fpga_writedata: out std_logic_vector(31 downto 0);
  av_fpga_waitrequest: in std_logic;
  av_rdsdram_address: out std_logic_vector(31 downto 0);
  av_rdsdram_read: out std_logic;
  av_rdsdram_readdata: in std_logic_vector(31 downto 0);
  av_rdsdram_readdatavalid: in std_logic;
  av_rdsdram_burstcount: out std_logic_vector(DMA_SIZE_BITS-1 downto 0);
  av_rdsdram_waitrequest: in std_logic;
  av_wrsdram_address: out std_logic_vector(31 downto 0);
  av_wrsdram_write: out std_logic;
  av_wrsdram_writeburst: out std_logic;
  av_wrsdram_writedata: out std_logic_vector(31 downto 0);
  av_wrsdram_burstcount: out std_logic_vector(DMA_SIZE_BITS-1 downto 0);
  av_wrsdram_byteenable: in std_logic_vector(3 downto 0);
  av_wrsdram_waitrequest: in std_logic;

  av_i2c_address: out std_logic_vector(15 downto 0);
  av_i2c_read: out std_logic;
  av_i2c_readdata: in std_logic_vector(15 downto 0);
  av_i2c_readdatavalid: in std_logic;
  av_i2c_write: out std_logic;
  av_i2c_writedata: out std_logic_vector(15 downto 0);
  av_i2c_waitrequest: in std_logic;
  av_i2c_data_16_en : out std_logic;
  i2c_ack_error     : in std_logic;
  
--  av_sensor_address: out  std_logic_vector(31 downto 0);
--  av_sensor_read: out std_logic;
--  av_sensor_readdata: in std_logic_vector(31 downto 0);
--  av_sensor_readdatavalid: in std_logic;
--  av_sensor_write: out std_logic;
--  av_sensor_writedata: out std_logic_vector(31 downto 0);
--  av_sensor_waitrequest: in std_logic;
--  av_sensor_write1: out std_logic;
--  av_sensor_writedata1: out std_logic_vector(31 downto 0);
--  av_sensor_address1: out  std_logic_vector(31 downto 0);
--  av_sensor_i2c_address: out  std_logic_vector(31 downto 0);
--  av_sensor_i2c_read: out std_logic;
--  av_sensor_i2c_readdata: in std_logic_vector(7 downto 0);
--  av_sensor_i2c_readdatavalid: in std_logic;
--  av_sensor_i2c_write: out std_logic;
--  av_sensor_i2c_writedata: out std_logic_vector(7 downto 0);
--  av_sensor_i2c_waitrequest: in std_logic;

--  av_spi_address: out std_logic_vector(7 downto 0);
--  av_spi_read: in std_logic;
--  av_spi_readdata: in std_logic_vector(31 downto 0);
--  av_spi_readdatavalid: in std_logic;
--  av_spi_write: out std_logic;
--  av_spi_writedata: out std_logic_vector(31 downto 0);
--  av_spi_waitrequest: in std_logic;
  sd_bus_busy_o: in std_logic;
  sd_bus_addr_i: out std_logic_vector(31 downto 0);
  sd_bus_rd_i: out std_logic;
  sd_bus_data_o: in std_logic_vector(7 downto 0);
  sd_bus_hndShk_o: in std_logic;
  sd_bus_wr_i: out std_logic;
  sd_bus_data_i: out std_logic_vector(7 downto 0);
  sd_bus_hndShk_i: out std_logic;
  sd_bus_error_o: in std_logic_vector(15 downto 0);
  FPGA_SPI_DQ0    :inout std_logic;--//inout 
  FPGA_SPI_DQ1    :inout std_logic; --//inout 
  FPGA_SPI_DQ2    :inout std_logic;--//inout 
  FPGA_SPI_DQ3    :inout std_logic;--//inout 
  FPGA_SPI_CS     :out std_logic;--//output
  
  gallery_img_rd_qspi_wr_sdram_en : in std_logic;
  ch_img_rd_qspi_wr_sdram_en : in std_logic;
  ch_img_sdram_addr : in std_logic_vector(31 downto 0);
  ch_img_qspi_addr  : in std_logic_vector(31 downto 0);
  ch_img_len        : in std_logic_vector(31 downto 0);
  ch_img_sum        : out std_logic_vector(63 downto 0);

--  device_id         : out std_logic_vector(31 downto 0); 
  PRDCT_NAME_WRITE_DATA        : out std_logic_vector(7 downto 0);
  PRDCT_NAME_WRITE_DATA_VALID  : out std_logic;

  temperature_write_data       : out std_logic_vector (7 downto 0);--//output
  temperature_write_data_valid : out std_logic;--//output
  temperature_rd_data          : in std_logic_vector(15 downto 0); -- input
  temperature_rd_data_valid    : in std_logic; -- input
  temperature_rd_rq            : out std_logic; --//output
  temperature_wr_addr          : out std_logic_vector (7 downto 0);--//output
  temperature_wr_rq            : out std_logic; --//output
  control_sdram_write_start_stop : out std_logic;
  shutter_en                   : in std_logic;
  toggle_gpio                  : in std_logic;
  nuc1pt_start_in              : in std_logic;
  nuc1pt_done                  : in std_logic;
  nuc1pt_start                 : out std_logic
  );
end component;


COMPONENT mipi_csi2_tx_subsystem_0
  PORT (
    s_axis_aclk : IN STD_LOGIC;
    s_axis_aresetn : IN STD_LOGIC;
    dphy_clk_200M : IN STD_LOGIC;
    txclkesc_out : OUT STD_LOGIC;
    oserdes_clk_out : OUT STD_LOGIC;
    oserdes_clk90_out : OUT STD_LOGIC;
    txbyteclkhs : OUT STD_LOGIC;
    oserdes_clkdiv_out : OUT STD_LOGIC;
    system_rst_out : OUT STD_LOGIC;
    mmcm_lock_out : OUT STD_LOGIC;
    cl_tst_clk_out : OUT STD_LOGIC;
    dl_tst_clk_out : OUT STD_LOGIC;
    interrupt : OUT STD_LOGIC;
    s_axi_araddr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_arready : OUT STD_LOGIC;
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_awaddr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_awready : OUT STD_LOGIC;
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rready : IN STD_LOGIC;
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wready : OUT STD_LOGIC;
    s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_wvalid : IN STD_LOGIC;
    mipi_video_if_mipi_vid_di : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    mipi_video_if_mipi_vid_enable : IN STD_LOGIC;
    mipi_video_if_mipi_vid_framenum : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    mipi_video_if_mipi_vid_hsync : IN STD_LOGIC;
    mipi_video_if_mipi_vid_linenum : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    mipi_video_if_mipi_vid_pixel : IN STD_LOGIC_VECTOR(41 DOWNTO 0);
    mipi_video_if_mipi_vid_vc : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    mipi_video_if_mipi_vid_vsync : IN STD_LOGIC;
    mipi_video_if_mipi_vid_wc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    mipi_phy_if_clk_hs_n : OUT STD_LOGIC;
    mipi_phy_if_clk_hs_p : OUT STD_LOGIC;
    mipi_phy_if_clk_lp_n : OUT STD_LOGIC;
    mipi_phy_if_clk_lp_p : OUT STD_LOGIC;
    mipi_phy_if_data_hs_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    mipi_phy_if_data_hs_p : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    mipi_phy_if_data_lp_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    mipi_phy_if_data_lp_p : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

component  mipi_csi_ip_controller
port (
 m_axi_aclk    : in  std_logic;
 m_axi_aresetn : in  std_logic;
 m_axi_awaddr  : out std_logic_vector(7 downto 0);
 m_axi_awvalid : out std_logic;
 m_axi_awready : in  std_logic;
 m_axi_wdata   : out std_logic_vector(31 downto 0);
 m_axi_wstrb   : out std_logic_vector(3 downto 0);
 m_axi_wvalid  : out std_logic;
 m_axi_wready  : in  std_logic;
 m_axi_bresp   : in  std_logic_vector(1 downto 0);
 m_axi_bvalid  : in  std_logic;
 m_axi_bready  : out std_logic;
 m_axi_araddr  : out std_logic_vector(7 downto 0);
 m_axi_arvalid : out std_logic;
 m_axi_arready : in  std_logic;
 m_axi_rdata   : in  std_logic_vector(31 downto 0);
 m_axi_rresp   : in  std_logic_vector(1 downto 0);
 m_axi_rvalid  : in  std_logic;
 m_axi_rready  : out std_logic;
 resetn        : out std_logic
    );
end component;

signal m_axi_aclk    :  std_logic;
signal m_axi_aresetn :  std_logic;
signal m_axi_awaddr  :  std_logic_vector(7 downto 0);
signal m_axi_awvalid :  std_logic;
signal m_axi_awready :  std_logic;
signal m_axi_wdata   :  std_logic_vector(31 downto 0);
signal m_axi_wstrb   :  std_logic_vector(3 downto 0);
signal m_axi_wvalid  :  std_logic;
signal m_axi_wready  :  std_logic;
signal m_axi_bresp   :  std_logic_vector(1 downto 0);
signal m_axi_bvalid  :  std_logic;
signal m_axi_bready  :  std_logic;
signal m_axi_araddr  :  std_logic_vector(7 downto 0);
signal m_axi_arvalid :  std_logic;
signal m_axi_arready :  std_logic;
signal m_axi_rdata   :  std_logic_vector(31 downto 0);
signal m_axi_rresp   :  std_logic_vector(1 downto 0);
signal m_axi_rvalid  :  std_logic;
signal m_axi_rready  :  std_logic;
signal csi_tx_ip_ready :  std_logic;

signal video_o_data_concat : std_logic_vector(41 downto 0);

signal SDRAM_RSTN: std_logic;
---Sensor 
signal Sensor_Linevalid_Out  : std_logic;
signal Sensor_Framevalid_Out : std_logic;
signal Sensor_Data_Out       : std_logic_vector(15 downto 0);
signal SNSR_FPGA_MASTER_CLK_En : std_logic;
signal Sensor_Data_Valid    : std_logic;

signal Sensor_Temperature : STD_LOGIC_VECTOR(31 downto 0);

--QSPI
--signal Start_QSPI_Module : std_logic;
--signal read_data_valid : std_logic;
--signal read_data : std_logic_vector(7 downto 0);
--signal qspi_wr_data : std_logic_vector(7 downto 0); 
--signal qspi_wr_data_valid : std_logic;      
--signal read_sdram_data_rq : std_logic;      
--signal write_sdram_data_rq : std_logic; 
--signal sdram_write_done   : std_logic;
--signal qspi_rx_rd_fifo_rq : std_logic;
--signal qspi_rx_rd_fifo_data : std_logic_vector(7 downto 0);


signal SENSOR_CMD_S: std_logic_vector(1 downto 0);
signal SENSOR_DATA_S: std_logic_vector(3 downto 0);
signal SENSOR_VIDEO_DATA_S: std_logic_vector(6 downto 0);
signal SENSOR_FRAMING_S: STD_LOGIC;

-- Video In VIDEO_IN_GENERIC
signal video_start      : std_logic;
signal battery_disp_start : std_logic;
signal VIDEO_I_V_SN     : std_logic;
signal VIDEO_I_H_SN     : std_logic;
signal VIDEO_I_EOI_SN   : std_logic;
signal VIDEO_I_DAV_SN   : std_logic;
signal VIDEO_I_DAV_WITH_TEMP_SN   : std_logic;
signal VIDEO_I_DATA_SN  : std_logic_vector (BIT_WIDTH-1 downto 0);
signal VIDEO_I_DATA_SN_1: std_logic_vector (15 downto 0);
signal VIDEO_I_XSIZE_SN : std_logic_vector(PIX_BITS-1 downto 0);
signal VIDEO_I_YSIZE_SN : std_logic_vector(LIN_BITS-1 downto 0);
signal VIDEO_I_XSIZE_WITH_TEMP_SN : std_logic_vector(PIX_BITS-1 downto 0);
signal VIDEO_I_YSIZE_WITH_TEMP_SN : std_logic_vector(LIN_BITS-1 downto 0);

signal raw_video_v     : std_logic;
signal raw_video_h     : std_logic;
signal raw_video_dav   : std_logic;
signal raw_video_data  : std_logic_vector(15 downto 0);
signal raw_video_eoi   : std_logic;
signal raw_video_xsize : std_logic_vector(PIX_BITS-1 downto 0);
signal raw_video_ysize : std_logic_vector(LIN_BITS-1 downto 0);

signal i_raw_video_v     : std_logic;
signal i_raw_video_h     : std_logic;
signal i_raw_video_dav   : std_logic;
signal i_raw_video_data  : std_logic_vector(15 downto 0);
signal i_raw_video_eoi   : std_logic;
signal i_raw_video_v_d     : std_logic;
signal i_raw_video_h_d     : std_logic;
signal i_raw_video_dav_d   : std_logic;
signal i_raw_video_data_d  : std_logic_vector(15 downto 0);
signal i_raw_video_eoi_d   : std_logic;
signal y_cnt : unsigned(9 downto 0);
-- Temperature Extraction Signals
signal VIDEO_O_V_TE         : std_logic;        
signal VIDEO_O_H_TE         : std_logic;    
signal VIDEO_O_DAV_TE       : std_logic;
signal VIDEO_O_EOI_TE       : std_logic;  
signal VIDEO_O_DATA_TE      : std_logic_vector(BIT_WIDTH-1 downto 0); 
signal TEMP_VALID           : std_logic;  
signal TEMP_DATA            : std_logic_vector(BIT_WIDTH-1 downto 0);     
signal TEMP_AVG_LINE        : std_logic_vector(BIT_WIDTH-1 downto 0); 
signal TEMP_AVG_FRAME       : std_logic_vector(BIT_WIDTH-1 downto 0); 




--Bad Pixel correction output Signals
signal VIDEO_O_BADP_V     : std_logic;
signal VIDEO_O_BADP_H     : std_logic;
signal VIDEO_O_BADP_EOI   : std_logic;
signal VIDEO_O_BADP_DAV   : std_logic; 
signal VIDEO_O_BADP_DATA  : std_logic_vector( BIT_WIDTH-1 downto 0);
signal VIDEO_O_BADP_DATA1 : std_logic_vector(15 downto 0);

signal VIDEO_O_ROW_V     : std_logic;
signal VIDEO_O_ROW_H     : std_logic;
signal VIDEO_O_ROW_EOI   : std_logic;
signal VIDEO_O_ROW_DAV   : std_logic; 
signal VIDEO_O_ROW_DATA  : std_logic_vector( BIT_WIDTH-1 downto 0);
signal VIDEO_O_ROW_BAD   : std_logic;

signal ENABLE_SNUC       : std_logic;
signal ENABLE_SNUC_VALID : std_logic;
signal THRESHOLD_SOBL    : std_logic_vector(7 downto 0);
signal ALPHA             : std_logic_vector(7 downto 0);


signal VIDEO_I_NUC_V     : std_logic;
signal VIDEO_I_NUC_H     : std_logic;
signal VIDEO_I_NUC_EOI   : std_logic;
signal VIDEO_I_NUC_DAV   : std_logic;
signal VIDEO_I_NUC_DATA  : std_logic_vector( bit_width-1 downto 0);

signal VIDEO_I_NUC_DATA_1: std_logic_vector(15 downto 0);

-- Video Output NUC Signals
signal VIDEO_O_NUC_V     : std_logic;
signal VIDEO_O_NUC_H     : std_logic;
signal VIDEO_O_NUC_EOI   : std_logic;
signal VIDEO_O_NUC_DAV   : std_logic;
signal VIDEO_O_NUC_DATA  : std_logic_vector( bit_width-1 downto 0);
signal VIDEO_O_NUC_BAD   : std_logic;
signal VIDEO_O_NUC_XSIZE : std_logic_vector( PIX_BITS-1 downto 0);
signal VIDEO_O_NUC_YSIZE : std_logic_vector( LIN_BITS-1 downto 0);
signal VIDEO_O_NUC_XCNT  : std_logic_vector( PIX_BITS-1 downto 0);
signal VIDEO_O_NUC_YCNT  : std_logic_vector( LIN_BITS-1 downto 0);


signal CUR_GAIN_TABLE   : std_logic_vector(2 downto 0);
signal CUR_OFFSET_TABLE : std_logic_vector (6 downto 0);
signal CUR_TEMP_AREA    : std_logic_vector (2 downto 0);

-- Video Output NUC1pt Signals
signal GAIN_TABLE_SEL     : std_logic;
signal sel_temp_range_out : std_logic_vector(1 downto 0);
signal force_temp_range   : std_logic_vector(2 downto 0);
signal force_temp_range_en: std_logic;
--signal sel_high_low       : std_logic;
--signal sel_temp_range     : std_logic;
--signal sel_temp_range_en  : std_logic;
signal ENABLE_NUC1ptCalib : std_logic;
signal NUC1pt_done_offset : std_logic;
signal APPLY_NUC1ptCalib  : std_logic;

signal APPLY_NUC1ptCalib2  : std_logic;
signal APPLY_NUC1ptCalib2_1  : std_logic;
signal APPLY_NUC1ptCalib2_c  : std_logic;
--signal APPLY_NUC1ptCalib_D: std_logic;
signal OSD_COARSE_OFFSET_CALIB_START : std_logic;
signal START_NUC1PTCALIB_VALID : std_logic;
signal OSD_START_NUC1PTCALIB : std_logic;
signal OSD_START_NUC1PT2CALIB : std_logic;
signal OSD_START_NUC1PTCALIB_D : std_logic;
signal OSD_START_NUC1PTCALIB_POS_EDGE : std_logic;
signal OSD_START_NUC1PTCALIB_NEG_EDGE : std_logic;
signal DMA_NUC1PT_MUX     : std_logic;
signal CONTROL_SDRAM_WRITE_START_STOP: std_logic;
signal shutter_control_sdram_write_start_stop : std_logic;
signal stop_sdram_write_seminuc : std_logic;
signal frame_cnt_to_start_sdram_write : unsigned(7 downto 0);
signal WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE : std_logic_vector(7 downto 0);
signal ENABLE_NUC_D       : std_logic;
signal Start_NUC1ptCalib : std_logic;
signal Start_NUC1ptCalib_D : std_logic;
signal Start_NUC1ptCalib_POS_EDGE : std_logic;
type VIDEO_NUC1PT_FSM_t is (s_NUC1PT_IDLE,s_NUC1PT_CALIB_START,s_NUC1PT_Wait,s_READ_COLD_IMG,s_WAIT_READ_COLD_IMG,s_READ_HOT_IMG,s_WAIT_READ_HOT_IMG,s_GAIN_CALIB_START,s_GAIN_CALIB_Wait);
signal VIDEO_NUC1PT_FSM   : VIDEO_NUC1PT_FSM_t;
--signal VIDEO_NUC1PT_FSM_Temp : std_logic_vector (3 downto 0);

signal NUC_MODE         : std_logic_vector(1 downto 0);
signal NUC_MODE_VALID   : std_logic;
signal BLADE_MODE       : std_logic_vector(1 downto 0);
signal BLADE_MODE_VALID : std_logic;

signal OSD_START_CALIB      : std_logic;
signal OSD_NUC_MODE         : std_logic_vector(1 downto 0);
signal OSD_NUC_MODE_VALID   : std_logic;
signal OSD_BLADE_MODE       : std_logic_vector(1 downto 0);
signal OSD_BLADE_MODE_VALID : std_logic;

signal MUX_NUC_MODE         : std_logic_vector(1 downto 0);
signal MUX_NUC_MODE_VALID   : std_logic;
signal MUX_BLADE_MODE       : std_logic_vector(1 downto 0);  

signal cold_img_sum : std_logic_vector(63 downto 0);
signal hot_img_sum  : std_logic_vector(63 downto 0);

signal auto_nuc1pt_start : std_logic;
signal auto_nuc1pt_done : std_logic;
--signal count_temp  :  std_logic_vector (31 downto 0);
--signal frame_counter_temp :  std_logic_vector(31 downto 0);
--signal DMA_SRCDAV_Temp : std_logic;
signal frame_counter            : unsigned(15 downto 0);
signal FRAME_COUNTER_NUC1PT_DELAY: std_logic_vector(15 downto 0);
signal AUTO_SHUTTER_TIMEOUT     :  std_logic_vector(15 downto 0);
signal do_nuc1pt_at_power_on    : std_logic;
signal start_gain_calc          : std_logic;
signal done_gain_calc           : std_logic;
signal Start_GAINCalib_POS_EDGE : std_logic;
signal Start_GAINCalib_D        : std_logic;
signal Start_GAINCalib          : std_logic;


signal NUC1pt_Time_Out_Cnt :integer;
signal NUC1pt_Reset : std_logic;
signal NUC1pt_Force_Reset : std_logic;
signal NUC1pt_Capture_Frames      : STD_LOGIC_VECTOR (3 downto 0) ;
signal gain_enable : std_logic;
signal gain_enable_d : std_logic;
signal select_gain_addr_d : std_logic;
signal select_gain_addr : std_logic;
signal offset_img_avg : STD_LOGIC_VECTOR (15 downto 0) ;

signal bpc_th : STD_LOGIC_VECTOR (15 downto 0) ;

--signal USEDW_0_temp : std_logic_vector(9 downto 0);
--signal USEDW_1_temp : std_logic_vector(9 downto 0);

--signal VIDEO_NUC_FSM_Temp : std_logic_vector(4 downto 0);
--signal MAX_PIXELS_Temp : std_logic_vector(19 downto 0);  

signal VIDEO_O_NUC1pt_V     : std_logic;
signal VIDEO_O_NUC1pt_H     : std_logic;
signal VIDEO_O_NUC1pt_EOI   : std_logic;
signal VIDEO_O_NUC1pt_DAV   : std_logic;
signal VIDEO_O_NUC1pt_DATA  : std_logic_vector( bit_width-1 downto 0);

signal DMA_NUC1pt_WRBURST_s :  std_logic;  
signal DMA_NUC1pt_WRREADY_s :  std_logic;
signal DMA_NUC1pt_WRREQ_s   :  std_logic;
signal DMA_NUC1pt_WRADDR_s  :  std_logic_vector(DMA_ADDR_BITS-1 downto 0);
signal DMA_NUC1pt_WRSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_NUC1pt_WRDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
signal DMA_NUC1pt_WRBE_s    :  std_logic_vector(DMA_DATA_BITS/8-1 downto 0);

signal DMA_NUC1pt_RDREQ_s   :  std_logic;
signal DMA_NUC1pt_RDADDR_s  :  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_NUC1pt_RDSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_NUC1pt_RDREADY_s :  std_logic;
signal DMA_NUC1pt_RDDAV_s   :  std_logic;
signal DMA_NUC1pt_RDDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);


-- Temperature Signals
signal TEMPERATURE : std_logic_vector(15 downto 0);
signal temperature_offset : std_logic_vector(15 downto 0);
signal sub_add_temp_offset : std_logic;
--signal TEMP_A_MIN  : std_logic_vector(15 downto 0);
--signal TEMP_A_MAX  : std_logic_vector(15 downto 0);
--signal TEMP_B_MIN  : std_logic_vector(15 downto 0);
--signal TEMP_B_MAX  : std_logic_vector(15 downto 0);
--signal TEMP_C_MIN  : std_logic_vector(15 downto 0);
--signal TEMP_C_MAX  : std_logic_vector(15 downto 0);
--signal TEMP_D_MIN  : std_logic_vector(15 downto 0);
--signal TEMP_D_MAX  : std_logic_vector(15 downto 0);


--signal TEMP_RANGE_Check :std_logic_vector(6 downto 0);
--ATTRIBUTE MARK_DEBUG : string;
--ATTRIBUTE MARK_DEBUG of TEMP_RANGE_Check: SIGNAL IS "TRUE";

signal ENABLE_BADPIXINFO : std_logic;
signal ZFORCE_BADPIXINFO : std_logic;
signal AGC_FILT_SEL     :std_logic;
signal BADP_FILT_SEL    :std_logic;

--signal PIX_OFFSET      : std_logic_vector(31 downto 0);
signal OFFSET_TBALE_FORCE      : std_logic_vector(31 downto 0);
-- Filter
signal VIDEO_I_FILT_V     : std_logic;
signal VIDEO_I_FILT_H     : std_logic;
signal VIDEO_I_FILT_EOI   :STD_LOGIC;
signal VIDEO_I_FILT_DAV   : STD_LOGIC;
--signal VIDEO_I_FILT_DATA  :std_logic_vector(bit_width-1 downto 0);
signal VIDEO_I_FILT_DATA  :std_logic_vector (7 downto 0);
signal VIDEO_I_FILT_XSIZE :STD_LOGIC_VECTOR (PIX_BITS-1 downto 0); 
signal VIDEO_I_FILT_YSIZE :STD_LOGIC_VECTOR (LIN_BITS-1 downto 0); 
signal VIDEO_I_FILT_XCNT  :STD_LOGIC_VECTOR (PIX_BITS-1 downto 0);
signal VIDEO_I_FILT_YCNT  :STD_LOGIC_VECTOR (LIN_BITS-1 downto 0);

signal VIDEO_O_FILT_V     : std_logic;
signal VIDEO_O_FILT_H     : std_logic;
signal VIDEO_O_FILT_EOI   : STD_LOGIC;
signal VIDEO_O_FILT_DAV   : STD_LOGIC;
--signal VIDEO_O_FILT_DATA  :std_logic_vector(BIT_WIDTH-1 downto 0);
signal VIDEO_O_FILT_DATA  :std_logic_vector (7 downto 0);
signal VIDEO_O_FILT_XSIZE :STD_LOGIC_VECTOR (PIX_BITS-1 downto 0); 
signal VIDEO_O_FILT_YSIZE :STD_LOGIC_VECTOR (LIN_BITS-1 downto 0); 
signal VIDEO_O_FILT_XCNT  :STD_LOGIC_VECTOR (PIX_BITS-1 downto 0);
signal VIDEO_O_FILT_YCNT  :STD_LOGIC_VECTOR (LIN_BITS-1 downto 0);


signal VIDEO_O_SFILT_V     : std_logic;
signal VIDEO_O_SFILT_H     : std_logic;
signal VIDEO_O_SFILT_EOI   : STD_LOGIC;
signal VIDEO_O_SFILT_DAV   : STD_LOGIC;
--signal VIDEO_O_SFILT_DATA  :std_logic_vector(BIT_WIDTH-1 downto 0);
signal VIDEO_O_SFILT_DATA  :std_logic_vector (7 downto 0);
signal VIDEO_O_SFILT_XSIZE :STD_LOGIC_VECTOR (PIX_BITS-1 downto 0); 
signal VIDEO_O_SFILT_YSIZE :STD_LOGIC_VECTOR (LIN_BITS-1 downto 0); 
signal VIDEO_O_SFILT_XCNT  :STD_LOGIC_VECTOR (PIX_BITS-1 downto 0);
signal VIDEO_O_SFILT_YCNT  :STD_LOGIC_VECTOR (LIN_BITS-1 downto 0); 

--signal ENABLE_SHARPENING_FILTER : STD_LOGIC; 

signal AV_KERN_ADDR       : std_logic_vector (7 downto 0);
signal AV_KERN_WR         : std_logic;
signal AV_KERN_WRDATA     : std_logic_vector (fixedp_width -1 downto 0);
signal AV_KERN_WRDATA_TEMP: std_logic_vector (31 downto 0);

signal AV_KERN_ADDR_SFILT       : std_logic_vector (7 downto 0);
signal AV_KERN_WR_SFILT         : std_logic;
signal AV_KERN_WRDATA_SFILT     : std_logic_vector (23 downto 0);


--CLHE signals
signal VIDEO_O_CLHE_V      : STD_LOGIC;
signal VIDEO_O_CLHE_H      : STD_LOGIC;
signal VIDEO_O_CLHE_DAV    : STD_LOGIC;
signal VIDEO_O_CLHE_EOI    : STD_LOGIC;             
signal VIDEO_O_CLHE_DATA   : STD_LOGIC_VECTOR (7 downto 0); 
signal VIDEO_O_CLHE_DATA_1 : STD_LOGIC_VECTOR (13 downto 0);   
signal Clip_Threshold      : std_logic_vector (18 downto 0) ;
signal VIDEO_CLHE_XCNT     : STD_LOGIC_VECTOR (PIX_BITS-1 downto 0); 
signal VIDEO_CLHE_YCNT     : STD_LOGIC_VECTOR (LIN_BITS-1 downto 0);

signal Temp_PING_PONG_Excess_Pixel : std_logic_vector (18 downto 0);
signal Temp_Pixel_Count : std_logic_vector (18 downto 0);


-- DPHE_lighter Signals
signal VIDEO_O_DAV_DPHE_l: std_logic;
signal VIDEO_O_DATA_DPHE_l: std_logic_vector(7 downto 0);
signal VIDEO_O_DATA_DPHE_ll: std_logic_vector(bit_width downto 0);
signal VIDEO_O_H_DPHE_l: std_logic;
signal VIDEO_O_V_DPHE_l: std_logic;
--signal VIDEO_O_XSIZE_DPHE_l: std_logic_vector(9 downto 0);
--signal VIDEO_O_YSIZE_DPHE_l: std_logic_vector(9 downto 0);
--signal VIDEO_O_XCNT_DPHE_l: std_logic_vector(9 downto 0);
--signal VIDEO_O_YCNT_DPHE_l: std_logic_vector(9 downto 0);
signal VIDEO_O_EOI_DPHE_l: std_logic;

-- DPHE Control Signals
signal CNTRL_MIN_DPHE   : std_logic_vector(23 downto 0);
signal CNTRL_MAX_DPHE   : std_logic_vector(23 downto 0);
signal CNTRL_HIST1_DPHE : std_logic_vector(23 downto 0);
signal CNTRL_HIST2_DPHE : std_logic_vector(23 downto 0);
signal CNTRL_CLIP_DPHE  : std_logic_vector(23 downto 0);
--signal MAX_LIMITER_DPHE : std_logic_vector(23 downto 0);

signal MAX_LIMITER_DPHE           : std_logic_vector(7 downto 0);
signal MAX_LIMITER_DPHE_VALID     : std_logic;
signal OSD_MAX_LIMITER_DPHE       : std_logic_vector(7 downto 0);
signal OSD_MAX_LIMITER_DPHE_VALID : std_logic;
signal MUX_MAX_LIMITER_DPHE       : std_logic_vector(7 downto 0);
signal MAX_LIMITER_DPHE_MUL       : std_logic_vector(23 downto 0);
signal MULTIPLIER_MAX_LIMITER_DPHE: std_logic_vector(15 downto 0);

signal MUL_MAX_LIMITER_DPHE           : std_logic_vector(7 downto 0);
signal MUL_MAX_LIMITER_DPHE_VALID     : std_logic;
signal OSD_MUL_MAX_LIMITER_DPHE       : std_logic_vector(7 downto 0);
signal OSD_MUL_MAX_LIMITER_DPHE_VALID : std_logic;
signal MUX_MUL_MAX_LIMITER_DPHE       : std_logic_vector(7 downto 0);

signal adaptive_clipping_mode : std_logic;

signal roi_x_offset     : std_logic_vector (PIX_BITS-1 downto 0);  
signal roi_y_offset     : std_logic_vector (LIN_BITS-1 downto 0); 
signal roi_x_size       : std_logic_vector (PIX_BITS-1 downto 0);
signal roi_y_size       : std_logic_vector (LIN_BITS-1 downto 0); 
signal linear_hist_en   : std_logic;  
signal max_gain         : std_logic_vector (7 downto 0); 
signal roi_mode         : std_logic; 

-- HIST_EQUALZATION Signals

signal IMG_MIN : std_logic_Vector(BIT_WIDTH-1 downto 0);
signal IMG_MAX : std_logic_Vector(BIT_WIDTH-1 downto 0);

--signal VIDEO_I_HIST_V    : std_logic; 
--signal VIDEO_I_HIST_H    : std_logic; 
--signal VIDEO_I_HIST_EOI  : std_logic; 
--signal VIDEO_I_HIST_DAV  : std_logic; 
--signal VIDEO_I_HIST_DATA : std_logic_vector(BIT_WIDTH-1 downto 0);

signal VIDEO_O_V_HISTEQ     : std_logic;     
signal VIDEO_O_H_HISTEQ     : std_logic;    
signal VIDEO_O_EOI_HISTEQ   : std_logic;   
signal VIDEO_O_DAV_HISTEQ   : std_logic;   
signal VIDEO_O_DATA_HISTEQ  : std_logic_vector(7 downto 0);  
----signal VIDEO_O_XCNT_HISTEQ  : std_logic_vector(PIX_BITS-1 downto 0);     
----signal VIDEO_O_YCNT_HISTEQ  : std_logic_vector(LIN_BITS-1 downto 0);  
----signal VIDEO_O_XSIZE_HISTEQ : std_logic_vector(PIX_BITS-1 downto 0);  
----signal VIDEO_O_YSIZE_HISTEQ : std_logic_vector(LIN_BITS-1 downto 0);
signal CNTRL_IPP            : std_logic_vector(7 downto 0);
signal CNTRL_IPP_VALID      : std_logic; 
signal CNTRL_MAX_GAIN       : std_logic_vector(7 downto 0);
signal CNTRL_MAX_GAIN_VALID  : std_logic; 
--signal CNTRL_IPP            : std_logic_vector(23 downto 0); 
--signal CNTRL_MAX_GAIN       : std_logic_vector(23 downto 0);      
signal CNTRL_MIN_HISTEQ     : std_logic_vector(23 downto 0);    
signal CNTRL_MAX_HISTEQ     : std_logic_vector(23 downto 0);     
signal CNTRL_HISTORY_HISTEQ : std_logic_vector(23 downto 0);

signal OSD_CNTRL_IPP            : std_logic_vector(7 downto 0);
signal OSD_CNTRL_IPP_VALID      : std_logic;
signal OSD_CNTRL_MAX_GAIN       : std_logic_vector(7 downto 0);
signal OSD_CNTRL_MAX_GAIN_VALID : std_logic;

signal MUX_CNTRL_IPP            : std_logic_vector(7 downto 0);
signal CNTRL_IPP_MUL            : std_logic_vector(23 downto 0);
signal MUX_CNTRL_MAX_GAIN       : std_logic_vector(7 downto 0);
signal CNTRL_MAX_GAIN_MUL       : std_logic_vector(23 downto 0);


-- VIDEO OUT MUX CLHE or DPHE 
signal AGC_MODE_SEL : std_logic_vector(1 downto 0);
signal AGC_MODE_SEL_VALID: std_logic;
signal VIDEO_OUT_MUX_SEL : std_logic_vector(1 downto 0);


--- VIDEO MIRE
signal VIDEO_O_V_MIRE: STD_LOGIC;
signal VIDEO_O_H_MIRE: STD_LOGIC;
signal VIDEO_O_EOI_MIRE: STD_LOGIC;
signal VIDEO_O_DAV_MIRE: STD_LOGIC;
signal VIDEO_O_DATA_MIRE :STD_LOGIC_VECTOR (7 downto 0);


-- DMA 

signal DMA_WRITE_FREE : std_logic;

signal DMA_W1_RDREADY_1, DMA_R1_RDREADY_1, DMA_W0_WRREADY_1 : std_logic;



signal DMA_W0_WRBURST_s :  std_logic;  
signal DMA_W0_WRREADY_s :  std_logic;
signal DMA_W0_WRREQ_s   :  std_logic;
signal DMA_W0_WRADDR_s  :  std_logic_vector(DMA_ADDR_BITS-1 downto 0);
signal DMA_W0_WRSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_W0_WRDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
signal DMA_W0_WRBE_s    :  std_logic_vector(DMA_DATA_BITS/8-1 downto 0);
--signal DMA_W0_ADDR_DEC_s: std_logic;

signal DMA_W1_WRBURST_s :  std_logic;  
signal DMA_W1_WRREADY_s :  std_logic;
signal DMA_W1_WRREQ_s   :  std_logic;
signal DMA_W1_WRADDR_s  :  std_logic_vector(DMA_ADDR_BITS-1 downto 0);
signal DMA_W1_WRSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_W1_WRDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
signal DMA_W1_WRBE_s    :  std_logic_vector(DMA_DATA_BITS/8-1 downto 0);


signal DMA_W2_WRBURST_s :  std_logic;  
signal DMA_W2_WRREADY_s :  std_logic;
signal DMA_W2_WRREQ_s   :  std_logic;
signal DMA_W2_WRADDR_s  :  std_logic_vector(DMA_ADDR_BITS-1 downto 0);
signal DMA_W2_WRSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_W2_WRDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
signal DMA_W2_WRBE_s    :  std_logic_vector(DMA_DATA_BITS/8-1 downto 0);
--------------------------------------------------------------------

signal DMA_R0_RDREQ_s   :  std_logic;
signal DMA_R0_RDADDR_s  :  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_R0_RDSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_R0_RDREADY_s :  std_logic;
signal DMA_R0_RDDAV_s   :  std_logic;
signal DMA_R0_RDDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
  ------------------------------------------------------------------
signal DMA_R1_RDREQ_s   :  std_logic;
signal DMA_R1_RDADDR_s  :  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_R1_RDSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_R1_RDREADY_s :  std_logic;
signal DMA_R1_RDDAV_s   :  std_logic;
signal DMA_R1_RDDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
  ------------------------------------------------------------------
signal DMA_R2_RDREQ_s   :  std_logic;
signal DMA_R2_RDADDR_s  :  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_R2_RDSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_R2_RDREADY_s :  std_logic;
signal DMA_R2_RDDAV_s   :  std_logic;
signal DMA_R2_RDDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);

signal DMA_R3_RDREQ_s   :  std_logic;                                   
signal DMA_R3_RDADDR_s  :  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_R3_RDSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_R3_RDREADY_s :  std_logic;                                   
signal DMA_R3_RDDAV_s   :  std_logic;                                   
signal DMA_R3_RDDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);

------------------------------------------------------------------
signal DMA_R4_RDREQ_s   :  std_logic;
signal DMA_R4_RDADDR_s  :  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_R4_RDSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_R4_RDREADY_s :  std_logic;
signal DMA_R4_RDDAV_s   :  std_logic;
signal DMA_R4_RDDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
------------------------------------------------------------------
signal DMA_R5_RDREQ_s   :  std_logic;
signal DMA_R5_RDADDR_s  :  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_R5_RDSIZE_s  :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_R5_RDREADY_s :  std_logic;
signal DMA_R5_RDDAV_s   :  std_logic;
signal DMA_R5_RDDATA_s  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);  
------------------------------------------------------------------  

signal DMA_RW6_READY_s    : std_logic;
signal DMA_RW6_RDREQ_s    : std_logic; 
signal DMA_RW6_WRREQ_s    : std_logic;
signal DMA_RW6_WRBURST_s  : std_logic;
signal DMA_RW6_WRBE_s     : std_logic_vector(DMA_DATA_BITS/8-1 downto 0);
signal DMA_RW6_WRDATA_s   : std_logic_vector(DMA_DATA_BITS  -1 downto 0);
signal DMA_RW6_ADDR_s     : std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_RW6_SIZE_s     : std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_RW6_RDDAV_s    : std_logic;
signal DMA_RW6_RDDATA_s   : std_logic_vector(DMA_DATA_BITS  -1 downto 0);

signal DMA_RW6_READY_s1    : std_logic;
signal DMA_RW6_RDREQ_s1    : std_logic; 
signal DMA_RW6_WRREQ_s1    : std_logic;
signal DMA_RW6_WRBURST_s1  : std_logic;
signal DMA_RW6_WRBE_s1     : std_logic_vector(DMA_DATA_BITS/8-1 downto 0);
signal DMA_RW6_WRDATA_s1   : std_logic_vector(DMA_DATA_BITS  -1 downto 0);
signal DMA_RW6_ADDR_s1     : std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_RW6_SIZE_s1     : std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_RW6_RDDAV_s1    : std_logic;
signal DMA_RW6_RDDATA_s1   : std_logic_vector(DMA_DATA_BITS  -1 downto 0);

signal DMA_RW6_READY_s2    : std_logic;
signal DMA_RW6_RDREQ_s2    : std_logic; 
signal DMA_RW6_WRREQ_s2    : std_logic;
signal DMA_RW6_WRBURST_s2  : std_logic;
signal DMA_RW6_WRBE_s2     : std_logic_vector(DMA_DATA_BITS/8-1 downto 0);
signal DMA_RW6_WRDATA_s2   : std_logic_vector(DMA_DATA_BITS  -1 downto 0);
signal DMA_RW6_ADDR_s2     : std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_RW6_SIZE_s2     : std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_RW6_RDDAV_s2    : std_logic;
signal DMA_RW6_RDDATA_s2   : std_logic_vector(DMA_DATA_BITS  -1 downto 0);

------------------------------------------------------------------  

------------------------------------------------------------------
signal DMA_WRITE   :  std_logic;
signal DMA_WRBURST :  std_logic;
signal DMA_READ    :  std_logic;
signal DMA_RDDAV   :  std_logic;
signal DMA_READY   :  std_logic;
signal DMA_BUSY    :  std_logic;
signal DMA_WRDATA  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
signal DMA_ADDR    :  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
signal DMA_SIZE    :  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
signal DMA_WRBE    :  std_logic_vector(DMA_DATA_BITS/8-1 downto 0);
signal DMA_RDDATA  :  std_logic_vector(DMA_DATA_BITS  -1 downto 0); 
--signal DMA_ADDR_DEC:  std_logic;
------------------------------------------------------------------

signal IMG_FLIP_V  : std_logic;
signal IMG_FLIP_H  : std_logic;

signal MUX_IMG_FLIP_V  : std_logic;
signal MUX_IMG_FLIP_H  : std_logic;

signal    hd_data          : std_logic_vector(15 downto 0);
signal    bt656_data      : std_logic_vector( 7 downto 0);
signal    SCALER_RUN       : std_logic;
signal    SCALER_REQ_V     : std_logic;
signal    SCALER_REQ_H     : std_logic;
signal    SCALER_LIN_NO   : std_logic_vector( LIN_BITS-1 downto 0);
signal    SCALER_REQ_XSIZE : std_logic_vector( 10 downto 0);
signal    SCALER_REQ_YSIZE : std_logic_vector( LIN_BITS-1 downto 0);
signal    SCALER_PIX_OFF : std_logic_vector(10 downto 0);

signal    SCALER_V  : std_logic;
signal    SCALER_H  : std_logic;
signal    SCALER_DAV  : std_logic;
signal    SCALER_EOI  : std_logic;
signal    SCALER_DATA : std_logic_vector(7 downto 0);
signal    SCALER_XSIZE  : std_logic_vector( 10 downto 0);
signal    SCALER_YSIZE: std_logic_vector( LIN_BITS-1 downto 0);
signal    SCALER_XCNT : std_logic_vector( 10 downto 0);
signal    SCALER_YCNT : std_logic_vector( LIN_BITS-1 downto 0);
signal    SCALER_FIFO_EMP  : std_logic;
signal    MEM_IMG_BUF : std_logic_Vector(1 downto 0);
signal    MEM_IMG_BUF_Temp: std_logic_Vector(1 downto 0);
signal    MEM_IMG_BUF_SEL : std_logic_Vector(1 downto 0);
signal    MEM_IMG_XSIZE : std_logic_Vector(9 downto 0);
signal    MEM_IMG_YSIZE : std_logic_Vector(9 downto 0);
signal    SCALER_O_V  : std_logic;
signal    SCALER_O_H  : std_logic;
signal    SCALER_O_DAV  : std_logic;
signal    SCALER_O_DATA : std_logic_vector(7 downto 0);
signal    SCALER_O_DATA_1 : std_logic_vector(15 downto 0);
--signal    SCALER_O_DATA1 : std_logic_vector(23 downto 0);
signal    SCALER_O_EOI  : std_logic;
signal    SCALER_O_XSIZE  : std_logic_vector( 10 downto 0);
signal    SCALER_O_YSIZE  : std_logic_vector( 9 downto 0);

signal    IMG_SHIFT_REQ_V   : std_logic;
signal    IMG_SHIFT_REQ_H   : std_logic;
signal    IMG_SHIFT_LIN_NO  : std_logic_vector(9 downto 0);
signal    IMG_SHIFT_REQ_XSIZE : std_logic_Vector(10 downto 0);
signal    IMG_SHIFT_REQ_YSIZE : std_logic_Vector(9 downto 0);
signal    IMG_UP_SHIFT_VERT       : std_logic_vector(9 downto 0);
signal    LATCH_IMG_UP_SHIFT_VERT : std_logic_vector(9 downto 0);
 
signal    IMG_SHIFT_O_V     : std_logic;
signal    IMG_SHIFT_O_H     : std_logic;
signal    IMG_SHIFT_O_DAV   : std_logic;
signal    IMG_SHIFT_O_DATA  : std_logic_vector(7 downto 0);
signal    IMG_SHIFT_O_EOI   : std_logic;
signal    IMG_SHIFT_O_XSIZE : std_logic_vector( 10 downto 0);
signal    IMG_SHIFT_O_YSIZE : std_logic_vector( 9 downto 0);
signal    IMG_SHIFT_O_XCNT  : std_logic_vector(10 downto 0);
signal    IMG_SHIFT_O_YCNT  : std_logic_vector( 9 downto 0);


signal    SCALER_BIL_REQ_H : std_logic;
signal    SCALER_BIL_REQ_V : std_logic;
signal    SCALER_BIL_REQ_XSIZE : std_logic_vector(10 downto 0);
signal    SCALER_BIL_REQ_YSIZE : std_logic_vector(LIN_BITS-1 downto 0);
signal    SCALER_BIL_LINE_NO : std_logic_vector(LIN_BITS-1 downto 0);

signal    SCALER_BIL_REQ_H_MUX     : std_logic;
signal    SCALER_BIL_REQ_V_MUX     : std_logic;
signal    SCALER_BIL_REQ_XSIZE_MUX : std_logic_vector(10 downto 0);
signal    SCALER_BIL_REQ_YSIZE_MUX : std_logic_vector(LIN_BITS-1 downto 0);
signal    SCALER_BIL_LINE_NO_MUX   : std_logic_vector(LIN_BITS-1 downto 0);
signal    latch_fit_to_screen_en   : std_logic;
signal    fit_to_screen_en         : std_logic; 
signal    fit_to_screen_en_valid   : std_logic;
signal    osd_fit_to_screen_en       : std_logic;
signal    osd_fit_to_screen_en_valid : std_logic;  
signal    mux_fit_to_screen_en       : std_logic;

signal    scaling_disable          : std_logic;
signal    osd_scaling_disable      : std_logic;
signal    osd_scaling_disable_valid: std_logic;
signal    mux_scaling_disable      : std_logic;
signal    latch_mux_scaling_disable: std_logic;
signal    scaling_disable_valid    : std_logic;

signal POLARITY : std_logic_vector(1 downto 0);
signal POLARITY_VALID  : std_logic;
signal BH_OFFSET    : std_logic_vector(7 downto 0);
signal VIDEO_O_V_P  : std_logic;
signal VIDEO_O_H_P  : std_logic;
signal VIDEO_O_EOI_P : std_logic;
signal VIDEO_O_DAV_P: std_logic;
signal VIDEO_O_DATA_P: std_logic_vector(7 downto 0);
--signal VIDEO_O_DATA_P: std_logic_vector(13 downto 0);
--signal    VIDEO_O_DATA_P1 : std_logic_vector(23 downto 0); 
signal VIDEO_O_XCNT_P: std_logic_vector( PIX_BITS-1 downto 0);
signal VIDEO_O_XSIZE_P : std_logic_vector( PIX_BITS-1 downto 0);
signal VIDEO_O_YSIZE_P :  std_logic_vector( LIN_BITS-1 downto 0);
signal VIDEO_O_YCNT_P:  std_logic_vector( LIN_BITS-1 downto 0);

signal BRIGHTNESS        : std_logic_vector(7 downto 0);  
signal BRIGHTNESS_VALID  : std_logic; 
signal CONTRAST          : std_logic_vector(7 downto 0); 
signal CONTRAST_VALID    : std_logic; 
signal BRIGHTNESS_OFFSET : std_logic_vector(7 downto 0); 
signal CONTRAST_OFFSET   : std_logic_vector(7 downto 0); 
signal CONSTANT_CB_CR    : std_logic_vector(15 downto 0); 


signal VIDEO_O_V_BC     : std_logic;
signal VIDEO_O_H_BC     : std_logic;
signal VIDEO_O_EOI_BC   : std_logic;
signal VIDEO_O_DAV_BC   : std_logic;
signal VIDEO_O_DATA_BC  : std_logic_vector(7 downto 0);
signal VIDEO_O_DATA_BC1 : std_logic_vector(15 downto 0);
signal VIDEO_O_XCNT_BC  : std_logic_vector( PIX_BITS-1 downto 0);
signal VIDEO_O_XSIZE_BC : std_logic_vector( PIX_BITS-1 downto 0);
signal VIDEO_O_YSIZE_BC : std_logic_vector( LIN_BITS-1 downto 0);
signal VIDEO_O_YCNT_BC  : std_logic_vector( LIN_BITS-1 downto 0);


signal VIDEO_O_V_CP  : std_logic;
signal VIDEO_O_H_CP  : std_logic;
signal VIDEO_O_EOI_CP : std_logic;
signal VIDEO_O_DAV_CP: std_logic;
signal VIDEO_O_DATA_CP: std_logic_vector(23 downto 0);
signal VIDEO_O_XCNT_CP: std_logic_vector(10 downto 0);
signal VIDEO_O_XSIZE_CP : std_logic_vector(10 downto 0);
signal VIDEO_O_YSIZE_CP : std_logic_vector(9 downto 0);
signal VIDEO_O_YCNT_CP: std_logic_vector(9 downto 0);

signal cp_min_value : std_logic_vector (7 downto 0);
signal cp_max_value : std_logic_vector (7 downto 0);
-- YCbCR SIGNALS-----
--signal LUT_MODE : std_logic_vector(3 downto 0);
signal VIDEO_O_V_4  : std_logic;
signal VIDEO_O_H_4  : std_logic;
signal VIDEO_O_EOI_4 : std_logic;
signal VIDEO_O_DAV_4: std_logic;
--signal VIDEO_O_DATA_4: std_logic_vector(23 downto 0);
signal VIDEO_O_DATA_4: std_logic_vector(7 downto 0);
signal VIDEO_O_XCNT_4: std_logic_vector(10 downto 0);
signal VIDEO_O_XSIZE_4 : std_logic_vector(10 downto 0);
signal VIDEO_O_YSIZE_4 : std_logic_vector(9 downto 0);
signal VIDEO_O_YCNT_4: std_logic_vector(9 downto 0);


signal    VIDEO_O_V_OSD     : std_logic;                    
signal    VIDEO_O_H_OSD     : std_logic;                    
signal    VIDEO_O_DAV_OSD   : std_logic;                    
signal    VIDEO_O_EOI_OSD   : std_logic;                    
--signal    VIDEO_O_DATA_OSD  : std_logic_vector(23 downto 0);
signal    VIDEO_O_DATA_OSD  : std_logic_vector(7 downto 0);

signal    VIDEO_O_V_OLED_OSD     : std_logic;                     
signal    VIDEO_O_H_OLED_OSD     : std_logic;                     
signal    VIDEO_O_DAV_OLED_OSD   : std_logic;                     
signal    VIDEO_O_EOI_OLED_OSD   : std_logic;                     
--signal    VIDEO_O_DATA_OLED_OSD  : std_logic_vector(23 downto 0); 
signal    VIDEO_O_DATA_OLED_OSD  : std_logic_vector(7 downto 0); 

signal    VIDEO_O_V_OSD1     : std_logic;                    
signal    VIDEO_O_H_OSD1     : std_logic;                    
signal    VIDEO_O_DAV_OSD1   : std_logic;                    
signal    VIDEO_O_EOI_OSD1   : std_logic;                    
--signal    VIDEO_O_DATA_OSD1  : std_logic_vector(23 downto 0);
signal    VIDEO_O_DATA_OSD1  : std_logic_vector(7 downto 0);

signal    VIDEO_O_V_INFO_DISP     : std_logic;                    
signal    VIDEO_O_H_INFO_DISP     : std_logic;                    
signal    VIDEO_O_DAV_INFO_DISP   : std_logic;                    
signal    VIDEO_O_EOI_INFO_DISP   : std_logic;                    
--signal    VIDEO_O_DATA_INFO_DISP  : std_logic_vector(23 downto 0);
signal    VIDEO_O_DATA_INFO_DISP  : std_logic_vector(7 downto 0);
signal    VIDEO_O_POS_X_INFO_DISP : std_logic_vector(10 downto 0);
signal    VIDEO_O_POS_Y_INFO_DISP : std_logic_vector(LIN_BITS-1 downto 0);


signal    ENABLE_BATTERY_DISP       : std_logic;
signal    MUX_ENABLE_BATTERY_DISP   : std_logic;
signal    ENABLE_BAT_PER_DISP       : std_logic;
signal    MUX_ENABLE_BAT_PER_DISP   : std_logic;
signal    ENABLE_BAT_CHG_SYMBOL     : std_logic;
signal    MUX_ENABLE_BAT_CHG_SYMBOL : std_logic;

--signal    BATTERY_PERCENTAGE          : std_logic_vector(7 downto 0);
signal    BATTERY_CONTROL             : std_logic_vector( 7 downto 0);
signal    BATTERY_STATUS              : std_logic_vector( 7 downto 0);
signal    BATTERY_TEMPERATURE         : std_logic_vector(15 downto 0);
signal    BATTERY_VOLTAGE             : std_logic_vector(15 downto 0);
signal    BATTERY_ACC_CHARGE          : std_logic_vector(15 downto 0);
signal    BATTERY_DISP_TG_WAIT_FRAMES : std_logic_vector( 7 downto 0); 
signal    BATTERY_PIX_MAP             : std_logic_vector( 7 downto 0);
signal    BATTERY_CHARGING_START      : std_logic;
signal    BATTERY_CHARGE_INC          : std_logic_vector(15 downto 0);

signal    VIDEO_O_V_BATTERY_DISP     : std_logic;                    
signal    VIDEO_O_H_BATTERY_DISP     : std_logic;                    
signal    VIDEO_O_DAV_BATTERY_DISP   : std_logic;                    
signal    VIDEO_O_EOI_BATTERY_DISP   : std_logic;                    
--signal    VIDEO_O_DATA_BATTERY_DISP  : std_logic_vector(23 downto 0);
signal    VIDEO_O_DATA_BATTERY_DISP  : std_logic_vector(7 downto 0);

signal    BATTERY_DISP_COLOR_INFO      : std_logic_vector(23 downto 0);
signal    BATTERY_DISP_CH_COLOR_INFO1  : std_logic_vector(23 downto 0);
signal    BATTERY_DISP_CH_COLOR_INFO2  : std_logic_vector(23 downto 0);
signal    BATTERY_DISP_POS_X           : std_logic_vector( 10 downto 0);
signal    BATTERY_DISP_POS_Y           : std_logic_vector( LIN_BITS-1 downto 0);
signal    BATTERY_DISP_POS_X_PN        : std_logic_vector( 10 downto 0);
signal    BATTERY_DISP_POS_Y_PN        : std_logic_vector( LIN_BITS-1 downto 0);
signal    BATTERY_DISP_REQ_XSIZE       : std_logic_vector( 10 downto 0);
signal    BATTERY_DISP_REQ_YSIZE       : std_logic_vector( LIN_BITS-1 downto 0);
signal    BATTERY_DISP_X_OFFSET        : std_logic_vector( 10 downto 0);
signal    BATTERY_DISP_Y_OFFSET        : std_logic_vector( LIN_BITS-1 downto 0);

signal    BAT_PER_DISP_COLOR_INFO      : std_logic_vector(23 downto 0);         
signal    BAT_PER_DISP_CH_COLOR_INFO1  : std_logic_vector(23 downto 0);         
signal    BAT_PER_DISP_CH_COLOR_INFO2  : std_logic_vector(23 downto 0);         
signal    BAT_PER_DISP_POS_X           : std_logic_vector( 10 downto 0);
signal    BAT_PER_DISP_POS_Y           : std_logic_vector( LIN_BITS-1 downto 0);
signal    BAT_PER_DISP_POS_X_PN        : std_logic_vector( 10 downto 0);
signal    BAT_PER_DISP_POS_Y_PN        : std_logic_vector( LIN_BITS-1 downto 0);
signal    BAT_PER_DISP_REQ_XSIZE       : std_logic_vector( 10 downto 0);
signal    BAT_PER_DISP_REQ_YSIZE       : std_logic_vector( LIN_BITS-1 downto 0);
signal    BAT_CHG_SYMBOL_POS_OFFSET    : std_logic_vector( 11 downto 0);

signal    BAT_PER_CONV_REG1            : std_logic_vector(23 downto 0);
signal    BAT_PER_CONV_REG2            : std_logic_vector(23 downto 0);
signal    BAT_PER_CONV_REG3            : std_logic_vector(23 downto 0);
signal    BAT_PER_CONV_REG4            : std_logic_vector(23 downto 0);
signal    BAT_PER_CONV_REG5            : std_logic_vector(23 downto 0);
signal    BAT_PER_CONV_REG6            : std_logic_vector(23 downto 0);

signal    CB_BAR_EN                   : std_logic;
signal    ENABLE_B_BAR_DISP           : std_logic;
signal    MUX_ENABLE_B_BAR_DISP       : std_logic;
signal    ENABLE_C_BAR_DISP           : std_logic;
signal    MUX_ENABLE_C_BAR_DISP       : std_logic;
signal    CB_BAR_DISP_COLOR_INFO      : std_logic_vector(23 downto 0);
--signal    CB_BAR_DISP_CH_COLOR_INFO1  : std_logic_vector(23 downto 0);
--signal    CB_BAR_DISP_CH_COLOR_INFO2  : std_logic_vector(23 downto 0);
signal    B_BAR_DISP_POS_X            : std_logic_vector( PIX_BITS-1 downto 0);
signal    B_BAR_DISP_POS_Y            : std_logic_vector( LIN_BITS-1 downto 0);
signal    B_BAR_DISP_POS_X_PN         : std_logic_vector( PIX_BITS-1 downto 0);
signal    B_BAR_DISP_POS_Y_PN         : std_logic_vector( LIN_BITS-1 downto 0);
signal    B_BAR_DISP_REQ_XSIZE        : std_logic_vector( PIX_BITS-1 downto 0);
signal    B_BAR_DISP_REQ_YSIZE        : std_logic_vector( LIN_BITS-1 downto 0);
signal    B_BAR_DISP_X_OFFSET         : std_logic_vector( PIX_BITS-1 downto 0);
signal    B_BAR_DISP_Y_OFFSET         : std_logic_vector( LIN_BITS-1 downto 0);
signal    C_BAR_DISP_POS_X            : std_logic_vector( PIX_BITS-1 downto 0);
signal    C_BAR_DISP_POS_Y            : std_logic_vector( LIN_BITS-1 downto 0);
signal    C_BAR_DISP_POS_X_PN         : std_logic_vector( PIX_BITS-1 downto 0);
signal    C_BAR_DISP_POS_Y_PN         : std_logic_vector( LIN_BITS-1 downto 0);
signal    C_BAR_DISP_REQ_XSIZE        : std_logic_vector( PIX_BITS-1 downto 0);
signal    C_BAR_DISP_REQ_YSIZE        : std_logic_vector( LIN_BITS-1 downto 0);
signal    C_BAR_DISP_X_OFFSET         : std_logic_vector( PIX_BITS-1 downto 0);
signal    C_BAR_DISP_Y_OFFSET         : std_logic_vector( LIN_BITS-1 downto 0);
signal    VIDEO_O_V_CB_BAR_DISP       : std_logic;                    
signal    VIDEO_O_H_CB_BAR_DISP       : std_logic;                    
signal    VIDEO_O_DAV_CB_BAR_DISP     : std_logic;                    
signal    VIDEO_O_EOI_CB_BAR_DISP     : std_logic;                    
signal    VIDEO_O_DATA_CB_BAR_DISP    : std_logic_vector(23 downto 0);


signal    ENABLE_OSD: std_logic;
signal    ENABLE_OSD_LATCH: std_logic;
signal    ENABLE_OSD_LATCH1: std_logic;
signal    ENABLE_OSD_D: std_logic;
signal    ENABLE_OSD_DD: std_logic;

signal    OSD_EN_OUT : std_logic;

signal    OSD_POS_Y_SET : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_SET : std_logic_vector( 10 downto 0);

signal    INFO_DISP_POS_Y_SET : std_logic_vector( LIN_BITS-1 downto 0);
signal    INFO_DISP_POS_X_SET : std_logic_vector( 10 downto 0);

signal    BATTERY_DISP_POS_Y_SET : std_logic_vector( LIN_BITS-1 downto 0);
signal    BATTERY_DISP_POS_X_SET : std_logic_vector( 10 downto 0);

signal    OSD_TIMEOUT        : std_logic_Vector(15 downto 0);
signal    OSD_COLOR_INFO     : std_logic_vector(23 downto 0);
signal    OSD_CH_COLOR_INFO1 : std_logic_vector(23 downto 0);
signal    OSD_CH_COLOR_INFO2 : std_logic_vector(23 downto 0);
signal    CURSOR_COLOR_INFO  : std_logic_vector(23 downto 0);
signal    CURSOR_POS         : std_logic_vector( 7 downto 0);
signal    OSD_POS_X_LY1      : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY1      : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY2      : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY2      : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY3      : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY3      : std_logic_vector( LIN_BITS-1 downto 0);

signal    OLED_OSD_POS_X_LY1     : std_logic_vector( PIX_BITS-1 downto 0);
signal    OLED_OSD_POS_Y_LY1     : std_logic_vector( LIN_BITS-1 downto 0);
signal    OLED_OSD_POS_X_LY1_PN  : std_logic_vector( PIX_BITS-1 downto 0);
signal    OLED_OSD_POS_Y_LY1_PN  : std_logic_vector( LIN_BITS-1 downto 0);

signal    BPR_OSD_POS_X_LY1      : std_logic_vector( PIX_BITS-1 downto 0);
signal    BPR_OSD_POS_Y_LY1      : std_logic_vector( LIN_BITS-1 downto 0);
signal    BPR_OSD_POS_X_LY1_PN   : std_logic_vector( PIX_BITS-1 downto 0);
signal    BPR_OSD_POS_Y_LY1_PN   : std_logic_vector( LIN_BITS-1 downto 0);

signal    GYRO_DATA_DISP_POS_X_LY1 : std_logic_vector( 10 downto 0);
signal    GYRO_DATA_DISP_POS_Y_LY1 : std_logic_vector( LIN_BITS-1 downto 0);
signal    GYRO_DATA_DISP_POS_X_LY2 : std_logic_vector( 10 downto 0);
signal    GYRO_DATA_DISP_POS_Y_LY2 : std_logic_vector( LIN_BITS-1 downto 0);

signal    GYRO_DATA_DISP_POS_X_LY1_PN : std_logic_vector( 10 downto 0);
signal    GYRO_DATA_DISP_POS_Y_LY1_PN : std_logic_vector( LIN_BITS-1 downto 0);
signal    GYRO_DATA_DISP_POS_X_LY2_PN : std_logic_vector( 10 downto 0);
signal    GYRO_DATA_DISP_POS_Y_LY2_PN : std_logic_vector( LIN_BITS-1 downto 0);

signal    OSD_POS_X_LY1_MODE1 : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY1_MODE1 : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY2_MODE1 : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY2_MODE1 : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY3_MODE1 : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY3_MODE1 : std_logic_vector( LIN_BITS-1 downto 0);

signal    OSD_POS_X_LY1_MODE1_PN : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY1_MODE1_PN : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY2_MODE1_PN : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY2_MODE1_PN : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY3_MODE1_PN : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY3_MODE1_PN : std_logic_vector( LIN_BITS-1 downto 0);


signal    OSD_POS_X_LY1_MODE2 : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY1_MODE2 : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY2_MODE2 : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY2_MODE2 : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY3_MODE2 : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY3_MODE2 : std_logic_vector( LIN_BITS-1 downto 0);

signal    OSD_POS_X_LY1_MODE2_PN : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY1_MODE2_PN : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY2_MODE2_PN : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY2_MODE2_PN : std_logic_vector( LIN_BITS-1 downto 0);
signal    OSD_POS_X_LY3_MODE2_PN : std_logic_vector( 10 downto 0);
signal    OSD_POS_Y_LY3_MODE2_PN : std_logic_vector( LIN_BITS-1 downto 0);



signal    ENABLE_INFO_DISP             : std_logic;
signal    ENABLE_SN_INFO_DISP          : std_logic;
signal    MUX_ENABLE_SN_INFO_DISP      : std_logic;
signal    MUX_ENABLE_INFO_DISP         : std_logic;
signal    RETICLE_POS_INFO_DISP_EN     : std_logic;
signal    MUX_RETICLE_POS_INFO_DISP_EN : std_logic;
signal    RETICLE_SEL_EN               : std_logic;
signal    MUX_RETICLE_SEL_INFO_DISP_EN : std_logic;
signal    ENABLE_PRESET_INFO_DISP      : std_logic;
signal    MUX_ENABLE_PRESET_INFO_DISP  : std_logic;
signal    AGC_MODE_INFO_DISP_EN        : std_logic;
signal    MUX_AGC_MODE_INFO_DISP_EN    : std_logic;
signal    AGC_MODE_DISP                : std_logic_vector(3 downto 0);
signal    CONTRAST_MODE_INFO_DISP_EN   : std_logic;
signal    CONTRAST_MODE                : std_logic_Vector(3 downto 0);
signal    INFO_DISP_COLOR_INFO         : std_logic_vector(23 downto 0);
signal    INFO_DISP_CH_COLOR_INFO1     : std_logic_vector(23 downto 0);
signal    INFO_DISP_CH_COLOR_INFO2     : std_logic_vector(23 downto 0);
signal    INFO_DISP_POS_X              : std_logic_vector( 10 downto 0);
signal    INFO_DISP_POS_Y              : std_logic_vector( LIN_BITS-1 downto 0);
signal    INFO_DISP_POS_X_PN           : std_logic_vector( 10 downto 0);
signal    INFO_DISP_POS_Y_PN           : std_logic_vector( LIN_BITS-1 downto 0);
signal    CONTRAST_MODE_INFO_DISP_POS_X: std_logic_vector( PIX_BITS-1 downto 0);
signal    CONTRAST_MODE_INFO_DISP_POS_Y: std_logic_vector( LIN_BITS-1 downto 0);
signal    CONTRAST_MODE_INFO_DISP_POS_X_PN: std_logic_vector( PIX_BITS-1 downto 0);
signal    CONTRAST_MODE_INFO_DISP_POS_Y_PN: std_logic_vector( LIN_BITS-1 downto 0);
signal    SN_INFO_DISP_POS_X           : std_logic_vector( PIX_BITS-1 downto 0);
signal    SN_INFO_DISP_POS_Y           : std_logic_vector( LIN_BITS-1 downto 0);
signal    SN_INFO_DISP_POS_X_PN        : std_logic_vector( PIX_BITS-1 downto 0);
signal    SN_INFO_DISP_POS_Y_PN        : std_logic_vector( LIN_BITS-1 downto 0);
signal    PRESET_INFO_DISP_POS_X       : std_logic_vector( PIX_BITS-1 downto 0);
signal    PRESET_INFO_DISP_POS_Y       : std_logic_vector( LIN_BITS-1 downto 0);
signal    PRESET_INFO_DISP_POS_X_PN    : std_logic_vector( PIX_BITS-1 downto 0);
signal    PRESET_INFO_DISP_POS_Y_PN    : std_logic_vector( LIN_BITS-1 downto 0);


signal    PRDCT_NAME_WRITE_DATA_VALID : std_logic;
signal    PRDCT_NAME_WRITE_DATA       : std_logic_vector(7 downto 0);

signal    MENU_SEL_CENTER   : std_logic;
signal    MENU_SEL_LEFT     : std_logic;
signal    MENU_SEL_RIGHT    : std_logic;
signal    MENU_SEL_UP       : std_logic;
signal    MENU_SEL_DN       : std_logic;

signal    MENU_SEL_CENTER_U : std_logic;
signal    MENU_SEL_LEFT_U   : std_logic;
signal    MENU_SEL_RIGHT_U  : std_logic;
signal    MENU_SEL_UP_U     : std_logic;
signal    MENU_SEL_DN_U     : std_logic;

--signal    main_menu_sel     : std_logic;
--signal    ADVANCE_MENU_TRIG_IN     : std_logic;
--signal    ADVANCE_MENU_TRIG_IN_REG : std_logic;
signal    OLED_MENU_EN             : std_logic;
signal    MUX_OLED_MENU_EN         : std_logic;  
signal    OLED_MENU_EN_OUT         : std_logic;
signal    BPR_MENU_EN              : std_logic;
signal    MUX_BPR_MENU_EN          : std_logic;
--signal    MUX_ADVANCE_MENU_TRIG_IN : std_logic;
signal    toggle_menu_loc          : std_logic;
signal    mux_toggle_menu_loc      : std_logic;

signal    RETICLE_XSIZE  : std_logic_vector( PIX_BITS-1 downto 0);
signal    RETICLE_YSIZE  : std_logic_vector( LIN_BITS-1 downto 0);
--signal    RETICLE_XCNT : std_logic_vector( PIX_BITS-1 downto 0);
--signal    RETICLE_YCNT : std_logic_vector( LIN_BITS-1 downto 0);
signal    RETICLE_WR_EN    : std_logic_vector( 0 downto 0);
signal    RETICLE_WR_DATA  : std_logic_vector(31 downto 0);

signal    RETICLE_OFFSET_WR_EN    : std_logic_vector( 0 downto 0);
signal    RETICLE_OFFSET_WR_DATA  : std_logic_vector(31 downto 0);

signal    RETICLE_OFFSET_RD_REQ   : std_logic;
signal    RETICLE_OFFSET_RD_ADDR  : std_logic_vector(3 downto 0);
signal    RETICLE_OFFSET_RD_DATA  : std_logic_vector(31 downto 0);

--signal    RETICLE_FIFO_EMP  : std_logic;
signal    RETICLE_COLOR_SEL       : std_logic_vector(2 downto 0);
signal    RETICLE_COLOR_SEL_VALID : std_logic;
signal    MUX_RETICLE_COLOR_SEL   : std_logic_vector(2 downto 0);
signal    RETICLE_COLOR_TH        : std_logic_vector(15 downto 0);          
signal    COLOR_SEL_WINDOW_XSIZE  : std_logic_vector(PIX_BITS-1 downto 0); 
signal    COLOR_SEL_WINDOW_YSIZE  : std_logic_vector(LIN_BITS-1 downto 0); 

signal    ENABLE_RETICLE      : std_logic;
signal    ENABLE_RETICLE_VALID: std_logic;
signal    ENABLE_RETICLE_LATCH: std_logic;
signal    ENABLE_RETICLE_D    : std_logic;
signal    ENABLE_RETICLE_DD   : std_logic;
signal    RETICLE_DIS         : std_logic;
signal    RETICLE_DIS_DONE    : std_logic;
signal    RETICLE_TYPE        : std_logic_vector(3 downto 0);
signal    RETICLE_TYPE_VALID  : std_logic;
signal    reticle_sel_out     : std_logic_Vector(6 downto 0);
signal    RETICLE_SEL         : std_logic_vector(3 downto 0);
signal    MUX_RETICLE_TYPE_SEL: std_logic_vector(6 downto 0); 
signal    RETICLE_SEL_VALID   : std_logic;

signal    VIDEO_O_V_RET     : std_logic;
signal    VIDEO_O_H_RET     : std_logic;
signal    VIDEO_O_DAV_RET   : std_logic;
signal    VIDEO_O_EOI_RET   : std_logic;
--signal    VIDEO_O_DATA_RET  : std_logic_vector(23 downto 0);
signal    VIDEO_O_DATA_RET  : std_logic_vector(7 downto 0);
signal    VIDEO_O_DATA_RET1  : std_logic_vector(23 downto 0);
--signal    VIDEO_O_XSIZE_RET : std_logic_vector( PIX_BITS-1 downto 0);
--signal    VIDEO_O_YSIZE_RET : std_logic_vector( LIN_BITS-1 downto 0);
signal    qspi_reticle_transfer_rq : std_logic;
signal    qspi_reticle_transfer_done : std_logic;
signal    qspi_reticle_transfer_rq_ack : std_logic;
signal    RETICLE_POS_X_SET : std_logic_vector( PIX_BITS downto 0);
signal    RETICLE_POS_Y_SET : std_logic_vector( LIN_BITS-1 downto 0);

signal    RETICLE_COLOR_INFO1  : std_logic_vector(23 downto 0);
signal    RETICLE_COLOR_INFO2  : std_logic_vector(23 downto 0);
signal    RETICLE_POS_YX       : std_logic_Vector(23 downto 0);
signal    RETICLE_POS_YX_VALID : std_logic;
signal    RETICLE_POS_X        : std_logic_vector( PIX_BITS-1 downto 0);
signal    RETICLE_POS_X_VALID  : std_logic;
signal    RETICLE_POS_Y        : std_logic_vector( LIN_BITS-1 downto 0);
signal    RETICLE_POS_Y_VALID  : std_logic;


signal    reticle_pos_x_out    : std_logic_vector( 10 downto 0);
signal    reticle_pos_y_out    : std_logic_vector( LIN_BITS-1 downto 0);

signal    reticle_pos_x_out1   : std_logic_vector( 10 downto 0);
signal    reticle_pos_y_out1   : std_logic_vector( LIN_BITS-1 downto 0);

signal    RETICLE_IMG_XSIZE : std_logic_vector( PIX_BITS-1 downto 0);
signal    RETICLE_IMG_YSIZE : std_logic_vector( LIN_BITS-1 downto 0);

signal    PRESET_SEL          : std_logic_vector(3 downto 0);
signal    PRESET_SEL_VALID    : std_logic;
signal    PRESET_P1_POS       : std_logic_vector(23 downto 0);
signal    PRESET_P1_POS_VALID : std_logic;
signal    PRESET_P2_POS       : std_logic_vector(23 downto 0);
signal    PRESET_P2_POS_VALID : std_logic;
signal    PRESET_P3_POS       : std_logic_vector(23 downto 0);
signal    PRESET_P3_POS_VALID : std_logic;
signal    PRESET_P4_POS       : std_logic_vector(23 downto 0);
signal    PRESET_P4_POS_VALID : std_logic;

--signal    RETICLE_CENTER_EN : std_logic;

signal ADD_BORDER_REQ_V     : std_logic;
signal ADD_BORDER_REQ_H     : std_logic;
signal ADD_BORDER_FIELD     : std_logic;
signal ADD_BORDER_REQ_XSIZE : std_logic_vector(PIX_BITS downto 0);
signal ADD_BORDER_REQ_YSIZE : std_logic_vector(LIN_BITS-1 downto 0);
signal ADD_BORDER_LINE_NO   : std_logic_vector(LIN_BITS-1 downto 0);
signal ADD_BORDER_I_XSIZE   : std_logic_vector(PIX_BITS downto 0);
signal ADD_BORDER_I_YSIZE   : std_logic_vector(LIN_BITS-1 downto 0);
signal BT656_ADD_BORDER_I_XSIZE   : std_logic_vector(PIX_BITS downto 0);
signal BT656_ADD_BORDER_I_YSIZE   : std_logic_vector(LIN_BITS-1 downto 0);
--signal IMG_SHIFT_LR_UPDATE : std_logic;
--signal IMG_SHIFT_LR_SEL    : std_logic;
--signal IMG_SHIFT_LR        : std_logic_vector(PIX_BITS-1 downto 0);
--signal IMG_SHIFT_UD_UPDATE : std_logic;
--signal IMG_SHIFT_UD_SEL    : std_logic;
--signal IMG_SHIFT_UD        : std_logic_vector(LIN_BITS-1 downto 0);

signal IMG_SHIFT_VERT        : std_logic_vector(LIN_BITS-1 downto 0);
signal IMG_SHIFT_VERT_VALID  : std_logic;

signal OSD_IMG_SHIFT_VERT        : std_logic_vector(LIN_BITS-1 downto 0);
signal OSD_IMG_SHIFT_VERT_VALID  : std_logic;

signal MUX_IMG_SHIFT_VERT : std_logic_vector(LIN_BITS-1 downto 0);
signal MUX_IMG_SHIFT_VERT1: std_logic_vector(LIN_BITS-1 downto 0);
signal IMG_CROP_LEFT      : std_logic_vector(PIX_BITS-1 downto 0);  
signal IMG_CROP_RIGHT     : std_logic_vector(PIX_BITS-1 downto 0); 
signal IMG_CROP_TOP       : std_logic_vector(LIN_BITS-1 downto 0); 
signal IMG_CROP_BOTTOM    : std_logic_vector(LIN_BITS-1 downto 0); 



--signal ADD_BORDER_I_V     : std_logic;    
--signal ADD_BORDER_I_H     : std_logic;
--signal ADD_BORDER_I_DAV   : std_logic;
--signal ADD_BORDER_I_DATA  : std_logic_vector(23 downto 0);
--signal ADD_BORDER_I_EOI   : std_logic;

signal ADD_BORDER_O_V     : std_logic;   
signal ADD_BORDER_O_H     : std_logic;   
signal ADD_BORDER_O_EOI   : std_logic;   
signal ADD_BORDER_O_DAV   : std_logic;   
--signal ADD_BORDER_O_DATA  : std_logic_vector(23 downto 0);
signal ADD_BORDER_O_DATA  : std_logic_vector(7 downto 0);
signal ADD_BORDER_O_XSIZE : std_logic_vector(PIX_BITS-1 downto 0);
signal ADD_BORDER_O_YSIZE : std_logic_vector(LIN_BITS-1 downto 0);


signal ADD_BORDER_O_V_MUX     : std_logic;   
signal ADD_BORDER_O_H_MUX     : std_logic;   
signal ADD_BORDER_O_EOI_MUX   : std_logic;   
signal ADD_BORDER_O_DAV_MUX   : std_logic;   
--signal ADD_BORDER_O_DATA_MUX  : std_logic_vector(23 downto 0);
signal ADD_BORDER_O_DATA_MUX  : std_logic_vector(7 downto 0);

signal RETICLE_OFFSET_X   : std_logic_vector(PIX_BITS downto 0);
signal RETICLE_OFFSET_Y   : std_logic_vector(LIN_BITS-1 downto 0);
--signal IMG_SHIFT_POS_X    : std_logic_vector(PIX_BITS-1 downto 0);
--signal IMG_SHIFT_POS_Y    : std_logic_vector(PIX_BITS-1 downto 0);

signal LOGO_WR_EN    : std_logic_vector( 0 downto 0);
signal LOGO_WR_DATA  : std_logic_vector(31 downto 0);

signal LOGO_ENABLE_START : std_logic;

signal    LOGO_IMG_XSIZE : std_logic_vector( 10 downto 0);
signal    LOGO_IMG_YSIZE : std_logic_vector( LIN_BITS-1 downto 0);

signal ENABLE_LOGO       : std_logic;
signal ENABLE_LOGO_VALID : std_logic;
signal LOGO_POS_X      : std_logic_vector(10 downto 0);       
signal LOGO_POS_Y      : std_logic_vector(LIN_BITS-1 downto 0);     
signal LOGO_POS_X_PN   : std_logic_vector(10 downto 0);       
signal LOGO_POS_Y_PN   : std_logic_vector(LIN_BITS-1 downto 0);    
signal ADD_LOGO_O_V    : std_logic; 
signal ADD_LOGO_O_H    : std_logic; 
signal ADD_LOGO_O_EOI  : std_logic; 
signal ADD_LOGO_O_DAV  : std_logic; 
--signal ADD_LOGO_O_DATA : std_logic_vector(23 downto 0);
signal ADD_LOGO_O_DATA : std_logic_vector(7 downto 0);
signal ADD_LOGO_O_XSIZE: std_logic_vector(PIX_BITS-1 downto 0); 
signal ADD_LOGO_O_YSIZE: std_logic_vector(LIN_BITS-1 downto 0); 
signal LOGO_COLOR_INFO1: std_logic_vector(23 downto 0);
signal LOGO_COLOR_INFO2: std_logic_vector(23 downto 0);




signal VIDEO_V_PROC        : std_logic;                    
signal VIDEO_H_PROC        : std_logic;                    
signal VIDEO_EOI_PROC      : std_logic;                    
signal VIDEO_DAV_PROC      : std_logic;                    
--signal VIDEO_DATA_PROC     : std_logic_vector(15 downto 0);
signal VIDEO_DATA_PROC     : std_logic_vector(7 downto 0);

signal USB_V               : std_logic;                    
signal USB_H               : std_logic;                    
signal USB_EOI             : std_logic;                    
signal USB_DAV             : std_logic;                    
signal USB_DATA            : std_logic_vector(15 downto 0);

signal MIPI_USB_V               : std_logic;                    
signal MIPI_USB_H               : std_logic;                    
signal MIPI_USB_EOI             : std_logic;                    
signal MIPI_USB_DAV             : std_logic;                    
signal MIPI_USB_DATA            : std_logic_vector(15 downto 0);

--signal sel_raw         : std_logic;
--signal latch_sel_raw   : std_logic;
signal force_analog_video_out           : std_logic;
signal sel_oled_analog_video_out        : std_logic; -- switch between analog video and oled video
signal sel_oled_analog_video_out_valid  : std_logic; 

signal sel_oled_analog_video_out_done   : std_logic;

signal display_mode_force_sel_done  : std_logic;

signal osd_sel_oled_analog_video_out        : std_logic; 
signal osd_sel_oled_analog_video_out_valid  : std_logic; 

signal OSD_SIGHT_MODE       : std_logic_vector(1 downto 0);
signal OSD_SIGHT_MODE_VALID : std_logic;

signal SIGHT_MODE       : std_logic_vector(1 downto 0);
signal SIGHT_MODE_VALID : std_logic;

signal MUX_SIGHT_MODE       : std_logic_vector(1 downto 0);
signal MUX_SIGHT_MODE_VALID : std_logic;

signal TP_GEN_16BIT_RST           : std_logic;
signal MUX_BT656_REQ_V     : std_logic;
signal MUX_BT656_REQ_H     : std_logic;
signal MUX_BT656_REQ_XSIZE : std_logic_vector(PIX_BITS downto 0);   
signal MUX_BT656_REQ_YSIZE : std_logic_vector(LIN_BITS-1 downto 0); 
signal MUX_BT656_REQ_LINE_NO: std_logic_vector(LIN_BITS-1 downto 0);       

signal  MUX_ADD_BORDER_I_XSIZE : std_logic_vector(PIX_BITS downto 0);   
signal  MUX_ADD_BORDER_I_YSIZE : std_logic_vector(LIN_BITS-1 downto 0);  

signal BT656_REQ_V     : std_logic;
--signal BT656_REQ_PnN   : std_logic;
signal BT656_FIELD     : std_logic;
signal BT656_REQ_H     : std_logic;
signal PAL_nNTSC       : std_logic;

signal BT656_XSIZE     : std_logic_vector(PIX_BITS-1 downto 0);
signal BT656_YSIZE     : std_logic_vector(LIN_BITS-1 downto 0);

signal BT656_REQ_XSIZE : std_logic_vector(PIX_BITS downto 0);
signal BT656_REQ_YSIZE : std_logic_vector(LIN_BITS-1 downto 0);
signal BT656_LINE_NO : std_logic_vector(LIN_BITS-1 downto 0);
signal BT656_START   : std_logic;
signal BT656_RST     : std_logic;

signal BT656_V               : std_logic;
signal BT656_H               : std_logic;
signal BT656_EOI             : std_logic;
signal BT656_DAV             : std_logic;
signal BT656_DATA_1          : std_logic_vector(15 downto 0);
signal BT656_DATA_2          : std_logic_vector(15 downto 0);
signal BT656_DATA_1_temp     : std_logic_vector (15 downto 0);
signal ENABLE_ZOOM_START     : std_logic;
signal ENABLE_ZOOM           : std_logic;
signal ENABLE_ZOOM_LATCH     : std_logic;
signal ZOOM_MODE             : std_logic_vector(2 downto 0);
signal ZOOM_MODE_VALID       : std_logic;

signal IN_X_SIZE       : std_logic_vector(10 downto 0);
signal IN_Y_SIZE       : std_logic_vector(LIN_BITS-1 downto 0);           
signal IN_X_OFF        : std_logic_vector(10 downto 0);
signal IN_Y_OFF        : std_logic_vector(LIN_BITS-1 downto 0);
signal OUT_X_SIZE      : std_logic_vector(10 downto 0);
signal OUT_Y_SIZE      : std_logic_vector(LIN_BITS-1 downto 0);


-- I2C Comm Module Avalon Interface
signal I2C_DELAY_REG        : STD_LOGIC_VECTOR (15 downto 0);
signal I2C_ADDRESS          : STD_LOGIC_VECTOR (6 downto 0);
signal I2C_REG_ADDRESS      : STD_LOGIC_VECTOR (7 downto 0);
signal I2C_ReadEN           : STD_LOGIC;
signal I2C_WriteEN          : STD_LOGIC;
signal I2C_WriteData        : STD_LOGIC_VECTOR (15 downto 0);
signal I2C_Busy             : STD_LOGIC;
signal I2C_ReadData         : STD_LOGIC_VECTOR (15 downto 0);
signal I2C_ReadDAV          : STD_LOGIC;
signal I2C_ADDRESS_combined : std_logic_vector(15 downto 0);


-- I2C LINES FOR ADV AND TEMPERATURE SNSOR

signal I2C_ReadEN_1     : STD_LOGIC;
signal I2C_WriteEN_1    : STD_LOGIC;
signal I2C_Busy_1       : STD_LOGIC;
signal I2C_ReadData_1   : STD_LOGIC_VECTOR (15 downto 0);
signal I2C_ReadDAV_1    : STD_LOGIC;
signal i2c_ack_error    : std_logic;

-- I2C LINES FOR OLED
signal I2C_ReadEN_2     : STD_LOGIC;
signal I2C_WriteEN_2    : STD_LOGIC;
signal I2C_Busy_2       : STD_LOGIC;
signal I2C_ReadData_2   : STD_LOGIC_VECTOR (15 downto 0);
signal I2C_ReadDAV_2    : STD_LOGIC;

signal DATA_16_EN     : STD_LOGIC;
signal I2C_DATA_16_EN : STD_LOGIC;

signal OLED_DEV_ADDR           : std_logic_Vector(7 downto 0);
signal ADV_DEV_ADDR            : std_logic_Vector(7 downto 0);
signal BAT_GAUGE_DEV_ADDR      : std_logic_vector(7 downto 0);
signal BAT_ADC_DEV_ADDR        : std_logic_vector(7 downto 0);
signal OLED_VGN_ADC_DEV_ADDR   : std_logic_Vector(7 downto 0);
signal MAX_VGN_SETTLE_TIME     : std_logic_Vector(7 downto 0);
signal MAX_OLED_VGN_RD_PERIOD  : std_logic_Vector(15 downto 0);
signal MAX_BAT_PARAM_RD_PERIOD : std_logic_vector(15 downto 0);

signal update_sensor_param     : std_logic;
signal new_sensor_param_start_addr :  std_logic_vector(5 downto 0);
signal sensor_init_data_len :  std_logic_vector(5 downto 0);



signal  save_user_settings_cmd_osd     : std_logic;
signal  save_user_settings_en_osd_done : std_logic;

signal  user_settings_mem_wr_addr   : std_logic_vector(7 downto 0);  
signal  user_settings_mem_wr_data   : std_logic_vector(31 downto 0); 
signal  user_settings_mem_wr_req    : std_logic;  
signal  user_settings_mem_wr_req1   : std_logic;                    
signal  user_settings_mem_rd_req    : std_logic;                     
signal  user_settings_mem_rd_addr   : std_logic_vector(7 downto 0);  
signal  user_settings_mem_rd_data   : std_logic_vector(31 downto 0);
signal  user_settings_init_start    : std_logic;


signal  trigger2:  std_logic;
signal  av_uart2_address:  std_logic_vector(7 downto 0);
signal  av_uart2_read:  std_logic;
signal  av_uart2_readdata:  std_logic_vector(31 downto 0);
signal  av_uart2_readdatavalid:  std_logic;
signal  av_uart2_write:  std_logic;
signal  av_uart2_writedata:  std_logic_vector(31 downto 0);
signal  av_uart2_waitrequest:  std_logic;
signal  trigger:  std_logic;
signal  av_uart_address:  std_logic_vector(7 downto 0);
signal  av_uart_read:  std_logic;
signal  av_uart_readdata:  std_logic_vector(31 downto 0);
signal  av_uart_readdatavalid:  std_logic;
signal  av_uart_write:  std_logic;
signal  av_uart_writedata:  std_logic_vector(31 downto 0);
signal  av_uart_waitrequest:  std_logic;
signal  av_fpga_address:  std_logic_vector(31 downto 0);
signal  av_fpga_read:  std_logic;
signal  av_fpga_readdata:  std_logic_vector(31 downto 0);
signal  av_fpga_readdatavalid:  std_logic;
signal  av_fpga_write:  std_logic;
signal  av_fpga_writedata:  std_logic_vector(31 downto 0);
signal  av_fpga_waitrequest:  std_logic;
signal  av_rdsdram_address_s:  std_logic_vector(31 downto 0);
signal  av_rdsdram_read_s:  std_logic;
signal  av_rdsdram_readdata_s:  std_logic_vector(31 downto 0);
signal  av_rdsdram_readdatavalid_s:  std_logic;
signal  av_rdsdram_burstcount_s:  std_logic_vector(DMA_SIZE_BITS-1 downto 0);
signal  av_rdsdram_waitrequest_s:  std_logic;
signal  av_wrsdram_address_s:  std_logic_vector(31 downto 0);
signal  av_wrsdram_write_s:  std_logic;
signal  av_wrsdram_writeburst_s: std_logic;
signal  av_wrsdram_writedata_s:  std_logic_vector(31 downto 0);
signal  av_wrsdram_burstcount_s:  std_logic_vector(DMA_SIZE_BITS-1 downto 0);
signal  av_wrsdram_byteenable_s:  std_logic_vector(3 downto 0);
signal  av_wrsdram_waitrequest_s:  std_logic;
signal  av_i2c_address:  std_logic_vector(15 downto 0);
signal  av_i2c_read:  std_logic;
signal  av_i2c_readdata:  std_logic_vector(15 downto 0);
signal  av_i2c_readdatavalid:  std_logic;
signal  av_i2c_write:  std_logic;
signal  av_i2c_writedata:  std_logic_vector(15 downto 0);
signal  av_i2c_waitrequest:  std_logic;

--signal  sensor_i2c_address:  std_logic_vector(31 downto 0);
--signal  sensor_i2c_read:  std_logic;
--signal  sensor_i2c_readdata:  std_logic_vector(7 downto 0);
--signal  sensor_i2c_readdatavalid:  std_logic;
--signal  sensor_i2c_write:  std_logic;
--signal  sensor_i2c_writedata:  std_logic_vector(7 downto 0);
--signal  sensor_i2c_waitrequest:  std_logic;

signal  av_spi_address:  std_logic_vector(7 downto 0);
signal  av_spi_read:  std_logic;
signal  av_spi_readdata:  std_logic_vector(31 downto 0);
signal  av_spi_readdatavalid:  std_logic;
signal  av_spi_write:  std_logic;
signal  av_spi_writedata:  std_logic_vector(31 downto 0);
signal  av_spi_waitrequest:  std_logic;
signal  sd_bus_busy_o:  std_logic;
signal  sd_bus_addr_i:  std_logic_vector(31 downto 0);
signal  sd_bus_rd_i:  std_logic;
signal  sd_bus_data_o:  std_logic_vector(7 downto 0);
signal  sd_bus_hndShk_o:  std_logic;
signal  sd_bus_wr_i:  std_logic;
signal  sd_bus_data_i:  std_logic_vector(7 downto 0);
signal  sd_bus_hndShk_i:  std_logic;
signal  sd_bus_error_o:  std_logic_vector(15 downto 0);
signal  ch_img_rd_qspi_wr_sdram_en : std_logic;           
signal  ch_img_sdram_addr : std_logic_vector(31 downto 0);
signal  ch_img_qspi_addr  : std_logic_vector(31 downto 0);
signal  ch_img_len        : std_logic_vector(31 downto 0);
signal  ch_img_sum : std_logic_vector(63 downto 0);

--signal device_id     : std_logic_vector(31 downto 0);

signal update_device_id_reg : std_logic_vector(31 downto 0);
signal update_device_id_reg_en : std_logic;

signal  temperature_write_data : std_logic_vector(7 downto 0);      
signal  temperature_write_data_valid : std_logic;
signal  temperature_rd_data : std_logic_vector(15 downto 0);      
signal  temperature_rd_data_valid : std_logic;
signal  temperature_rd_rq : std_logic;
signal  temperature_wr_addr : std_logic_vector(7 downto 0);  
signal  temperature_wr_rq : std_logic;
signal  STORE_TEMP_AVG_FRAME : std_logic_vector(15 downto 0);

signal GYRO_DATA_UPDATE_TIMEOUT      : std_logic_vector(15 downto 0);
signal GYRO_DATA_DISP_EN             : std_logic;
signal GYRO_DATA_DISP_EN_VALID       : std_logic;
signal GYRO_CALIB_EN                 : std_logic;
signal OSD_GYRO_DATA_DISP_EN         : std_logic;
signal OSD_GYRO_DATA_DISP_EN_VALID   : std_logic;
signal OSD_GYRO_CALIB_EN             : std_logic;
signal OSD_GYRO_CALIB_EN_VALID       : std_logic;
signal GYRO_DATA_DISP_MODE           : std_logic;
signal MUX_GYRO_DATA_DISP_EN         : std_logic;
signal MUX_GYRO_DATA_DISP_EN_AND     : std_logic;
signal GYRO_CALIB_DONE               : std_logic;
signal GYRO_SOFT_CALIB_DONE          : std_logic;
signal MUX_GYRO_CALIB_EN             : std_logic;

signal GYRO_CALIB_STATUS             : std_logic;

signal MAGNETO_X_DATA        : std_logic_vector(15 downto 0);
signal MAGNETO_Y_DATA        : std_logic_vector(15 downto 0);
signal MAGNETO_Z_DATA        : std_logic_vector(15 downto 0);
signal MAGNETO_X_DATA_CORR   : std_logic_vector(15 downto 0);
signal MAGNETO_Y_DATA_CORR   : std_logic_vector(15 downto 0);
signal MAGNETO_Z_DATA_CORR   : std_logic_vector(15 downto 0);
signal MAGNETO_Y_DATA_SOFT_CORR   : std_logic_vector(15 downto 0);
signal MAGNETO_Z_DATA_SOFT_CORR   : std_logic_vector(15 downto 0);


signal ACCEL_X_DATA          : std_logic_vector(15 downto 0); 
signal ACCEL_Y_DATA          : std_logic_vector(15 downto 0); 
signal ACCEL_Z_DATA          : std_logic_vector(15 downto 0); 
signal yaw                   : std_logic_vector(15 downto 0);
signal pitch                 : std_logic_vector(15 downto 0);
signal roll                  : std_logic_vector(15 downto 0);
signal x_accel               : std_logic_vector(15 downto 0);
signal y_accel               : std_logic_vector(15 downto 0);
signal z_accel               : std_logic_vector(15 downto 0);
signal crc_error             : std_logic;
signal bno_data_valid        : std_logic;

signal yaw_offset                      : std_logic_vector(15 downto 0);
signal pitch_offset                    : std_logic_vector(15 downto 0);
signal corrected_yaw                   : std_logic_vector(15 downto 0);
signal corrected_pitch                 : std_logic_vector(15 downto 0);

signal    VIDEO_O_V_GYRO_DATA_DISP     : std_logic;                    
signal    VIDEO_O_H_GYRO_DATA_DISP     : std_logic;                    
signal    VIDEO_O_DAV_GYRO_DATA_DISP   : std_logic;                    
signal    VIDEO_O_EOI_GYRO_DATA_DISP   : std_logic;                    
--signal    VIDEO_O_DATA_GYRO_DATA_DISP  : std_logic_vector(23 downto 0);
signal    VIDEO_O_DATA_GYRO_DATA_DISP  : std_logic_vector(7 downto 0);



signal  sensor_address:  std_logic_vector(31 downto 0);
signal  sensor_read:  std_logic;
signal  sensor_readdata:  std_logic_vector(31 downto 0);
signal  sensor_readdatavalid:  std_logic;
signal  sensor_write:  std_logic;
signal  sensor_writedata:  std_logic_vector(31 downto 0);
signal  sensor_waitrequest:  std_logic;
signal  sensor_write1:  std_logic;
signal  sensor_writedata1:  std_logic_vector(31 downto 0);
signal  sensor_address1:  std_logic_vector(31 downto 0);

signal  sensor_write_mux:  std_logic;
signal  sensor_writedata_mux:  std_logic_vector(31 downto 0);
signal  sensor_address_mux:  std_logic_vector(31 downto 0);

signal  coarse_waitrequest 		: std_logic;
signal  coarse_read 		  	: std_logic;
signal  coarse_address 	  		: std_logic_vector( 31 downto 0);
signal  coarse_size 		  	: std_logic_vector(5 downto 0);
signal  coarse_readdatavalid 	: std_logic;
signal  coarse_readdata 	  	: std_logic_vector(31 downto 0);

signal  meta1_avg               : std_logic_vector(13 downto 0); 
signal  meta2_avg               : std_logic_vector(13 downto 0); 
signal  meta3_avg               : std_logic_vector(13 downto 0); 
signal  temp_sense_offset       : std_logic_vector(3 downto 0);

signal BPR_DISP_EN_TIME_GAP           : std_logic_vector(15 downto 0);   -- in milli seconds  
signal OLED_DISP_EN_TIME_GAP          : std_logic_vector(15 downto 0);   -- in milli seconds      
signal MAX_PRESET_SAVE_OK_DISP_FRAMES : std_logic_vector(15 downto 0);   --  MSB - SAVE DISPLAY FRAMES (Minimum 1-frame) , LSB -OK DISPLAY FRAMES (Minimum 1-frame) 
signal MAX_RELEASE_WAIT_TIME          : std_logic_Vector(11 downto 0);   -- in milli seconds
signal MIN_TIME_GAP_PRESS_RELEASE     : std_logic_Vector(11 downto 0);   -- in milli seconds
signal MAX_UP_DOWN_PRESS_TIME         : std_logic_vector(15 downto 0);   -- in milli seconds
signal MAX_MENU_DOWN_PRESS_TIME       : std_logic_vector(15 downto 0);   -- in milli seconds
signal LONG_PRESS_STEP_SIZE           : std_logic_vector(11 downto 0);   


-- SPI Comm Module Avalon Interface
--signal SPI_WriteEN      : STD_LOGIC;
--signal SPI_WriteData        : STD_LOGIC_VECTOR (31 downto 0);
--signal SPI_ADDRESS        : STD_LOGIC_VECTOR (7 downto 0);
--signal SPI_ReadEN         : STD_LOGIC;
--signal SPI_ReadData     : STD_LOGIC_VECTOR (31 downto 0);
--signal SPI_WaitReq      : STD_LOGIC;
--signal SPI_ReadDAV      : STD_LOGIC;


signal VIDEO_CTRL_REG        : std_logic_vector (31 downto 0);
signal NUC1PT_CTRL_REG       : std_logic_vector (31 downto 0);
signal FPGA_VERSION_REG      : std_logic_vector (31 downto 0); ---- to release new firmware, increase this reg value by 1
signal ENABLE_TP          : std_logic;
signal VIDEO_IN_MUX          : std_logic;
signal VIDEO_IN_MUX_SEL      : std_logic;
--signal ENABLE_LUT        : std_logic;
signal ENABLE_CP        : std_logic;
signal ENABLE_NUC        : std_logic;
signal ENABLE_UNITY_GAIN: std_logic;
signal ENABLE_BADPIXREM  : std_logic;
signal SELECT_CL_RAW_PROCESSED: std_logic;
signal SELECT_VIDEO_OUT: std_logic_vector(2 downto 0);


signal ENABLE_UNITY_GAIN_C: std_logic;
signal ENABLE_UNITY_GAIN2: std_logic;

signal ENABLE_SMOOTHING_FILTER : std_logic;
signal ENABLE_SMOOTHING_FILTER_VALID : std_logic;
signal ENABLE_SHARPENING_FILTER : STD_LOGIC; 
signal ENABLE_SHARPENING_FILTER_VALID : STD_LOGIC; 

signal SHARPNESS       : std_logic_vector (3 downto 0);   
signal SHARPNESS_VALID : std_logic;  

signal ENABLE_EDGE_FILTER       : STD_LOGIC;
signal ENABLE_EDGE_FILTER_VALID : STD_LOGIC;
signal EDGE_THRESHOLD           : std_logic_vector (BIT_WIDTH-1 downto 0);

signal av_wr_sharp_edge      : std_logic ;     
signal av_addr_sharp_edge : std_logic_vector(7 downto 0) ;  
signal av_data_sharp_edge : std_logic_vector(15 downto 0); 
signal av_busy_sharp_edge    : std_logic ;
signal av_wr_blur            : std_logic ;
signal av_addr_blur       : std_logic_vector(7 downto 0) ; 
signal av_data_blur       : std_logic_vector(15 downto 0); 
signal av_busy_blur          : std_logic ;



--signal ENABLE_FILTER : std_logic;
signal POR_REQ_IN  : std_logic;

--signal LUT_MODE : std_logic_vector(4 downto 0);
signal ENABLE_BRIGHT_CONTRAST       : std_logic;
signal ENABLE_BRIGHT_CONTRAST_START : std_logic;
signal SELECT_CONTRAST_ALGO: std_logic_vector(1 downto 0);
signal ENABLE_AGC : std_logic;
signal nuc_en : std_logic;

signal CP_TYPE : std_logic_vector(4 downto 0);
signal CP_TYPE_VALID : std_logic;

signal SATURATED_PIX_TH : std_logic_vector (BIT_WIDTH-1 downto 0);
signal DARK_PIX_TH      : std_logic_vector (BIT_WIDTH-1 downto 0);
signal BAD_BLIND_PIX_LOW_TH : std_logic_vector (BIT_WIDTH-1 downto 0);
signal BAD_BLIND_PIX_HIGH_TH: std_logic_vector (BIT_WIDTH-1 downto 0);
signal blind_badpix_remove_en : std_logic;

--type FPGA_REG_FSM_t is  ( s_IDLE, s_LUTS_READ );
signal FPGA_WRREQ   : std_logic;
signal FPGA_RDREQ   : std_logic;
signal FPGA_ADDR    : std_logic_vector(31 downto 0);
signal FPGA_WRDATA  : std_logic_vector(31 downto 0);
signal FPGA_BUSY    : std_logic;
signal FPGA_RDDAV   : std_logic;
signal FPGA_RDDATA  : std_logic_vector(31 downto 0);
signal FPGA_WAITREQ : std_logic;


signal TICK1MS       : std_logic;
signal TICK1S        : std_logic;
signal TICK1US       : std_logic;

signal sdram_init_done : std_logic;
signal qspi_init_cmd_done : std_logic;
signal qspi_init_cmd_done_n : std_logic;

-- Clock and rest
signal RST : std_logic;
signal CLK : std_logic;
signal CLK_100MHZ : std_logic;
signal CLK_100MHZ_PS_225 : std_logic;
signal CLK_27MHZ : std_logic;
signal CLK_33MHZ : std_logic; 
--signal CLK_6MHZ : std_logic;
--signal CLK_39_5MHZ : std_logic;
signal SENSOR_MCLK : std_logic;
signal CLK_54MHZ : std_logic;
signal CLK_148_5MHZ : std_logic;
signal CLK_74_25MHZ : std_logic;
signal CLK_200MHZ: std_logic;
signal RST_27MHZ : std_logic;
signal locked : std_logic;
signal probe0 : std_logic_vector(127 downto 0);
signal RST_CNT : integer;
signal RST_N : std_logic;
--signal RST_CNT1 : integer;
signal start: std_logic;


--signal  SNSR_FPGA_I2C2_SCL_SPI_SCK_1 : STD_LOGIC;
--signal  SNSR_FPGA_I2C2_SDA_SPI_SDO_1 : STD_LOGIC;
--signal  SNSR_FPGA_NRST_SPI_CS_1 : STD_LOGIC;

signal FPGA_SDRAM_A_s : std_logic_vector(12 downto 0);
signal FPGA_SDRAM_BA_s   : STD_LOGIC_VECTOR(1 DOWNTO 0);

signal frame_cnt1 :unsigned(7 downto 0);
signal frame_cnt2 :unsigned(7 downto 0);
signal frame_cnt3 :unsigned(7 downto 0);
signal MEM_IMG_SOI : std_logic;
--signal DELAY_CNT : unsigned(15 downto 0);

signal VIDEO_MUX_OUT_V     : std_logic;
signal VIDEO_MUX_OUT_H     : std_logic;
signal VIDEO_MUX_OUT_EOI   : std_logic;
signal VIDEO_MUX_OUT_DAV   : std_logic;
signal VIDEO_MUX_OUT_DATA  : std_logic_vector( 7 downto 0);
signal VIDEO_MUX_OUT_BAD   : std_logic;
signal VIDEO_MUX_OUT_XSIZE : std_logic_vector( PIX_BITS-1 downto 0);
signal VIDEO_MUX_OUT_YSIZE : std_logic_vector( LIN_BITS-1 downto 0);


signal start_sflt : std_logic;

signal INV_CLK_27MHZ : std_logic;

--signal restart_sensor : std_logic;

signal IMG_AVG : std_logic_Vector(BIT_WIDTH-1 downto 0);
signal Img_Min_Limit : std_logic_Vector(BIT_WIDTH-1 downto 0);
signal Img_Max_Limit : std_logic_Vector(BIT_WIDTH-1 downto 0);


signal    OSD_DIS : std_logic;
signal    OSD_DIS_DONE : std_logic;

signal    OSD_AGC_MODE_SEL   : std_logic_vector( 1 downto 0);
signal    OSD_DZOOM          : std_logic_vector(2 downto 0);
signal    OSD_BRIGHTNESS     : std_logic_vector( 7 downto 0);   
signal    OSD_CONTRAST       : std_logic_vector( 7 downto 0);
signal    OSD_RETICLE_ENABLE : std_logic;
signal    OSD_RETICLE_COLOR_SEL : std_logic_vector(2 downto 0);
signal    OSD_RETICLE_TYPE   : std_logic_vector(3 downto 0);
signal    OSD_RETICLE_POS_YX : std_logic_vector(23 downto 0);
signal    BPR_RETICLE_POS_YX : std_logic_vector(23 downto 0);
signal    OSD_RETICLE_POS_X  : std_logic_vector(PIX_BITS-1 downto 0);
signal    OSD_RETICLE_POS_Y  : std_logic_vector(LIN_BITS-1 downto 0);
signal    OSD_RETICLE_SEL    : std_logic_vector(3 downto 0);

signal    OSD_PRESET_SEL    : std_logic_vector(3 downto 0);
signal    OSD_PRESET_P1_POS : std_logic_vector(23 downto 0);
signal    OSD_PRESET_P2_POS : std_logic_vector(23 downto 0);
signal    OSD_PRESET_P3_POS : std_logic_vector(23 downto 0);
signal    OSD_PRESET_P4_POS : std_logic_vector(23 downto 0);

signal    OSD_OLED_BRIGHTNESS                : std_logic_vector(7 downto 0);
signal    OSD_OLED_BRIGHTNESS_VALID          : std_logic;

signal    OSD_OLED_CONTRAST                  : std_logic_vector(7 downto 0);
signal    OSD_OLED_CONTRAST_VALID            : std_logic;

signal    OSD_OLED_DIMCTL                : std_logic_vector(7 downto 0);
signal    OSD_OLED_DIMCTL_VALID          : std_logic;
signal    OSD_OLED_GAMMA_TABLE_SEL       : std_logic_vector(7 downto 0);
signal    OSD_OLED_GAMMA_TABLE_SEL_VALID : std_logic;
signal    OSD_OLED_POS_V                 : std_logic_vector(7 downto 0);
signal    OSD_OLED_POS_V_VALID           : std_logic;
signal    OSD_OLED_POS_H                 : std_logic_vector(8 downto 0);
signal    OSD_OLED_POS_H_VALID           : std_logic;

signal    OSD_POLARITY  : std_logic_vector(1 downto 0);
signal    OSD_DDE_SEL   : std_logic_vector(3 downto 0);
--signal    OSD_DDE_SEL_1 : std_logic_vector(23 downto 0);
--signal    OSD_DDE_SEL_VALID : std_logic;
--signal    OSD_DDE_EN   : std_logic;
signal    OSD_CP_TYPE       : std_logic_vector(4 downto 0);
signal    OSD_LOGO_EN       : std_logic;
signal    OSD_SNUC_EN       : std_logic;
signal    OSD_EDGE_EN       : std_logic;
signal    OSD_SMOOTHING_EN  : std_logic;
signal    OSD_SHARPNESS     : std_logic_vector(3 downto 0);

signal    OSD_DZOOM_VALID            : std_logic;
signal    OSD_AGC_MODE_SEL_VALID     : std_logic;
signal    OSD_BRIGHTNESS_VALID       : std_logic; 
signal    OSD_CONTRAST_VALID         : std_logic;
signal    OSD_RETICLE_ENABLE_VALID   : std_logic;
signal    OSD_RETICLE_COLOR_SEL_VALID: std_logic;
signal    OSD_RETICLE_TYPE_VALID     : std_logic;
signal    OSD_RETICLE_POS_YX_VALID   : std_logic;
signal    BPR_RETICLE_POS_YX_VALID   : std_logic;
signal    OSD_RETICLE_POS_XY_SAVE_EN : std_logic;
signal    OSD_RETICLE_POS_X_VALID    : std_logic;
signal    OSD_RETICLE_POS_Y_VALID    : std_logic;
signal    OSD_RETICLE_SEL_VALID      : std_logic;

signal    BPR_DISP_EN                : std_logic;

signal    OSD_PRESET_SEL_VALID    : std_logic;
signal    OSD_PRESET_P1_POS_VALID : std_logic;
signal    OSD_PRESET_P2_POS_VALID : std_logic;
signal    OSD_PRESET_P3_POS_VALID : std_logic;
signal    OSD_PRESET_P4_POS_VALID : std_logic;

signal    OSD_POLARITY_VALID         : std_logic;
signal    OSD_LOGO_EN_VALID          : std_logic;
signal    OSD_CP_TYPE_VALID          : std_logic;
signal    OSD_SNUC_EN_VALID          : std_logic;
signal    OSD_SMOOTHING_EN_VALID     : std_logic;
signal    OSD_EDGE_EN_VALID          : std_logic;
signal    OSD_SHARPNESS_VALID        : std_logic;

signal    OSD_MARK_BP                    : std_logic; 
signal    OSD_MARK_BP_VALID              : std_logic;
signal    OSD_UNMARK_BP                  : std_logic;
signal    OSD_UNMARK_BP_VALID            : std_logic;
signal    OSD_SAVE_BP                    : std_logic;
signal    OSD_LOAD_USER_SETTINGS         : std_logic;
signal    OSD_LOAD_FACTORY_SETTINGS      : std_logic;
signal    OSD_SAVE_USER_SETTINGS         : std_logic;
signal    DISPLAY_MODE_SAVE_USER_SETTINGS: std_logic;
signal    MUX_OSD_SAVE_USER_SETTINGS     : std_logic;
signal    OSD_OLED_SAVE_USER_SETTINGS    : std_logic; 
signal    MUX_OSD_OLED_SAVE_USER_SETTINGS: std_logic;
signal    RETICLE_SAVE_USER_SETTINGS     : std_logic;
--signal    OSD_DDE_EN_VALID           : std_logic;
signal    OSD_LASER_EN                   : std_logic; 
signal    OSD_LASER_EN_VALID             : std_logic; 
signal    OSD_STANDBY_EN                 : std_logic; 
signal    OSD_STANDBY_EN_VALID           : std_logic; 
signal    CMD_STANDBY_EN                 : std_logic;
--signal    CMD_OLED_RESET                 : std_logic;      
signal    oled_reinit_en                 : std_logic;
--signal    cmd_oled_reinit_en             : std_logic;
signal    adv_sleep_mode_en              : std_logic;
--signal    cmd_adv_sleep_mode_en          : std_logic;

signal   OSD_FIRING_MODE                 : std_logic;
signal   OSD_FIRING_MODE_VALID           : std_logic;
signal   FIRING_MODE                     : std_logic;
signal   FIRING_MODE_VALID               : std_logic;
signal   MUX_FIRING_MODE                 : std_logic;
signal   OSD_DISTANCE_SEL                : std_logic_vector(3 downto 0);
signal   OSD_DISTANCE_SEL_VALID          : std_logic;
signal   DISTANCE_SEL                    : std_logic_vector(3 downto 0);
signal   DISTANCE_SEL_VALID              : std_logic;
signal   MUX_DISTANCE_SEL                : std_logic_vector(3 downto 0);
signal   MUX_DISTANCE_SEL_VALID          : std_logic;   

signal DISP_MUX_ZOOM_MODE      : std_logic_vector(2 downto 0);
signal MUX_ZOOM_MODE           : std_logic_vector(2 downto 0);
signal MUX_AGC_MODE_SEL        : std_logic_vector(1 downto 0);
signal MUX_BRIGHTNESS          : std_logic_vector( 7 downto 0);
signal MUX_CONTRAST            : std_logic_vector( 7 downto 0);
signal MUX_BRIGHTNESS_MAP      : std_logic_vector( 7 downto 0);
signal MUX_CONTRAST_MAP        : std_logic_vector( 7 downto 0);
signal MUX_RETICLE_TYPE        : std_logic_vector(3 downto 0);
signal MUX_CP_TYPE             : std_logic_vector(4 downto 0);
signal MUX_RETICLE_POS_YX      : std_logic_vector(23 downto 0);
signal MUX_RETICLE_POS_YX1     : std_logic_vector(23 downto 0);
signal MUX_RETICLE_POS_X       : std_logic_vector(PIX_BITS -1 downto 0);
signal MUX_RETICLE_POS_Y       : std_logic_vector(LIN_BITS -1 downto 0);
signal MUX_RETICLE_SEL         : std_logic_vector(3 downto 0);
signal MUX_PRESET_SEL          : std_logic_vector(3 downto 0);
signal MUX_PRESET_P1_POS       : std_logic_vector(23 downto 0);
signal MUX_PRESET_P2_POS       : std_logic_vector(23 downto 0);
signal MUX_PRESET_P3_POS       : std_logic_vector(23 downto 0);
signal MUX_PRESET_P4_POS       : std_logic_vector(23 downto 0);

signal MUX_OLED_BRIGHTNESS          : std_logic_vector(7 downto 0);
signal MUX_OLED_BRIGHTNESS_VALID    : std_logic;
signal MUX_OLED_BRIGHTNESS_MAP      : std_logic_vector(7 downto 0);
signal MUX_OLED_BRIGHTNESS_MAP_VALID: std_logic;

signal MUX_OLED_CONTRAST           : std_logic_vector(7 downto 0);
signal MUX_OLED_CONTRAST_VALID     : std_logic;
signal MUX_OLED_CONTRAST_MAP       : std_logic_vector(7 downto 0);
signal MUX_OLED_CONTRAST_MAP_VALID : std_logic;

signal MUX_OLED_DIMCTL         : std_logic_vector(7 downto 0);
signal MUX_OLED_DIMCTL_VALID   : std_logic;
signal MUX_OLED_GAMMA_TABLE_SEL: std_logic_vector(7 downto 0);
signal MUX_OLED_POS_H          : std_logic_vector(8 downto 0);
signal MUX_OLED_POS_H_VALID   : std_logic;
signal MUX_OLED_POS_V          : std_logic_vector(7 downto 0);
signal MUX_OLED_POS_V_VALID   : std_logic;

signal MUX_POLARITY_START      : std_logic_vector(1 downto 0); 
signal MUX_POLARITY            : std_logic_vector(1 downto 0);
signal MUX_DDE_SEL             : std_logic_vector (3 downto 0);
signal MUX_ENABLE_LOGO         : std_logic;
signal MUX_ENABLE_SNUC         : std_logic;
signal MUX_ENABLE_SNUC_1       : std_logic;
signal ENABLE_SNUC_FORCE       : std_logic;
signal MUX_ENABLE_SMOOTHING    : std_logic;
signal MUX_ENABLE_EDGE         : std_logic;
signal MUX_SHARPNESS           : std_logic_vector(3 downto 0);
signal MUX_RETICLE_ENABLE      : std_logic;
signal MUX_RETICLE_ENABLE1     : std_logic;
signal MUX_CP_ENABLE           : std_logic;
signal MUX_DDE_SEL_ENABLE      : std_logic;
signal MUX_DDE_SEL_1           : std_logic_vector(23 downto 0);
signal MUX_DDE_SEL_VALID       : std_logic;


type   user_settings_st_t is (s_user_settings_idle,s_user_settings_init_mem_rd,s_user_settings_mem_rd_wait,s_user_settings_reg_init);--s_user_settings_init_mem_wr);
signal user_settings_st   : user_settings_st_t;

signal user_settings_init_done : std_logic;

signal rd_count : unsigned(8 downto 0);

signal PAL_nNTSC_SEL_DONE    : std_logic;
signal OLED_GAMMA_TABLE_SEL        : std_logic_vector(7 downto 0);
signal OLED_GAMMA_TABLE_SEL_VALID  : std_logic;
signal OLED_POS_V                  : std_logic_vector(7 downto 0);
signal OLED_POS_H                  : std_logic_vector(8 downto 0);
signal OLED_BRIGHTNESS             : std_logic_vector(7 downto 0);
signal OLED_CONTRAST               : std_logic_vector(7 downto 0);
signal OLED_IDRF                   : std_logic_vector(7 downto 0);        
signal OLED_DIMCTL                 : std_logic_vector(7 downto 0);
signal OLED_IMG_FLIP               : std_logic_vector(7 downto 0);
signal OLED_IMG_H_FLIP             : std_logic_vector(7 downto 0);
signal OLED_CATHODE_VOLTAGE        : std_logic_vector(7 downto 0);
signal OLED_ROW_START_MSB          : std_logic_vector(7 downto 0);
signal OLED_ROW_START_LSB          : std_logic_vector(7 downto 0);
signal OLED_ROW_END_MSB            : std_logic_vector(7 downto 0);
signal OLED_ROW_END_LSB            : std_logic_vector(7 downto 0);
signal OLED_POS_V_VALID            : std_logic;
signal OLED_POS_H_VALID            : std_logic;
signal OLED_BRIGHTNESS_VALID       : std_logic;
signal OLED_CONTRAST_VALID         : std_logic;
signal OLED_IDRF_VALID             : std_logic;        
signal OLED_DIMCTL_VALID           : std_logic;
signal OLED_IMG_FLIP_VALID         : std_logic;
signal OLED_CATHODE_VOLTAGE_VALID  : std_logic;
signal OLED_IMG_H_FLIP_VALID       : std_logic;
signal OLED_ROW_START_MSB_VALID    : std_logic;
signal OLED_ROW_START_LSB_VALID    : std_logic;
signal OLED_ROW_END_MSB_VALID      : std_logic;
signal OLED_ROW_END_LSB_VALID      : std_logic;
signal OLED_ROW_START_MSB_VALID_D    : std_logic;
signal OLED_ROW_START_LSB_VALID_D    : std_logic;
signal OLED_ROW_END_MSB_VALID_D      : std_logic;
signal OLED_ROW_END_LSB_VALID_D      : std_logic;
signal OLED_ROW_START_LSB_VALID_DD    : std_logic;
signal OLED_ROW_END_MSB_VALID_DD      : std_logic;
signal OLED_ROW_END_LSB_VALID_DD      : std_logic;
signal OLED_ROW_END_MSB_VALID_DDD      : std_logic;
signal OLED_ROW_END_LSB_VALID_DDD      : std_logic;
signal OLED_ROW_END_LSB_VALID_DDDD      : std_logic;
--signal OLED_REG_DATA               : std_logic_vector(7 downto 0);
signal toggle_osd_flip : std_logic;
signal toggle_osd_flip_d : std_logic;
signal toggle_osd_flip_pos_edge : std_logic;
signal toggle_osd_flip_neg_edge : std_logic;
signal osd_flip_update_done : std_logic;
signal apply_osd_flip_time_cnt : unsigned(15 downto 0);
signal GPIO_I_1: std_logic;
signal GPIO_I_2: std_logic;
signal GPIO_I_3: std_logic;
signal GPIO_I_4: std_logic;
signal GPIO_I_5: std_logic;

-- Pulse Outputs
signal CENTER_KEY_PRESS: std_logic;
signal DOWN_KEY_PRESS  : std_logic;
signal UP_KEY_PRESS    : std_logic;
signal RIGHT_KEY_PRESS : std_logic;
signal LEFT_KEY_PRESS  : std_logic;


signal CENTER_KEY_LONG_PRESS: std_logic;
signal DOWN_KEY_LONG_PRESS  : std_logic;
signal UP_KEY_LONG_PRESS    : std_logic;
signal RIGHT_KEY_LONG_PRESS : std_logic;
signal LEFT_KEY_LONG_PRESS  : std_logic;

signal CENTER_KEY_LONG_PRESS_LEVEL: std_logic;
signal DOWN_KEY_LONG_PRESS_LEVEL  : std_logic;
signal UP_KEY_LONG_PRESS_LEVEL    : std_logic;
signal RIGHT_KEY_LONG_PRESS_LEVEL : std_logic;
signal LEFT_KEY_LONG_PRESS_LEVEL  : std_logic;

signal CENTER_DOWN_KEY_LONG_PRESS : std_logic;
signal CENTER_UP_KEY_LONG_PRESS   : std_logic;
signal DOWN_UP_KEY_LONG_PRESS     : std_logic;

signal OSD_MODE : std_logic_vector(3 downto 0);
signal OLED_RESET  : std_logic;
signal OLED_RESET1  : std_logic;
signal OLED_DATAEN : std_logic;
signal OLED_POWER_EN : std_logic;
signal OLED_POWER_OFF : std_logic;
signal LASER_EN       : std_logic;
signal LASER_EN_VALID : std_logic;
signal MUX_LASER_EN   : std_logic;
signal POWER_OFF_EN   : std_logic;
signal OSD_POWER_OFF_EN   : std_logic;



signal debouncer_en : std_logic;

signal apply_nuc1pt_time_cnt : unsigned(15 downto 0);
signal NUC_TIME_GAP          : std_logic_vector(15 downto 0);
signal toggle_nuc1pt         : std_logic; 
--type nuc_hot_key_control_st_t is (s_idle,s_wait_press,s_wait_release);
--signal nuc_hot_key_control_st   : nuc_hot_key_control_st_t;    

signal agc_mode_info_disp_time_cnt : unsigned(15 downto 0);
signal MAX_AGC_MODE_INFO_DISP_TIME : std_logic_vector(15 downto 0);

signal MAX_SDRAM_WR_START_WAIT : std_logic_vector(15 downto 0);
signal sdram_wr_start_cnt      : unsigned(15 downto 0);
signal sdram_wr_start          : std_logic;

signal image_width_full     : std_logic_vector(PIX_BITS-1 downto 0);
signal temp_pixels_left     : std_logic_vector(PIX_BITS-1 downto 0);
signal temp_pixels_right    : std_logic_vector(PIX_BITS-1 downto 0);
signal exclude_right        : std_logic_vector(7 downto 0); 
signal exclude_left         : std_logic_vector(7 downto 0); 

signal product_sel          : std_logic;
signal bat_adc_en           : std_logic;
signal temp_range_update_timeout : std_logic_vector(15 downto 0);

--signal CLK_13_5_MHZ  : std_logic;
--signal INV_CLK_13_5_MHZ  : std_logic;

signal video_o_vsync : std_logic;
signal video_o_hsync : std_logic;
signal video_o_de    : std_logic;
signal video_o_frame_valid : std_logic;
signal video_o_frame_pulse : std_logic;
signal video_o_line_valid  : std_logic;
signal video_o_data  : std_logic_vector(15 downto 0);
signal pix_cnt_out   : std_logic_Vector(9 downto 0);
signal line_cnt_out  : std_logic_Vector(9 downto 0);
signal fifo_usedw    : std_logic_vector(14 downto 0);
signal TP_16BIT_RST  : std_logic; 
signal sel_color_tp  : std_logic;

signal USB_VIDEO_XSIZE : std_logic_vector(PIX_BITS-1 downto 0);
signal USB_VIDEO_YSIZE : std_logic_vector(LIN_BITS-1 downto 0);

signal MIPI_USB_VIDEO_XSIZE : std_logic_vector(PIX_BITS-1 downto 0);
signal MIPI_USB_VIDEO_YSIZE : std_logic_vector(LIN_BITS-1 downto 0);

signal HDC_2010_ADDR   : std_logic_vector(7 downto 0);
signal SHUTTER_ADDR    : std_logic_vector(7 downto 0);
signal BAT_ADC_ADDR    : std_logic_vector(7 downto 0);

signal spi_mode             : std_logic_vector(1 downto 0);
signal spi_read_data_valid  : std_logic; 
signal spi_read_data        : std_logic_vector(7 downto 0);
signal spi_write_data_valid : std_logic; 
signal spi_write_data       : std_logic_vector(7 downto 0);  
signal spi_slave_debug_reg  : std_logic_vector(7 downto 0);  

signal usb_video_data_out_sel : std_logic; 
signal usb_video_data_out_sel_mux : std_logic; 
signal usb_video_data_out_sel_reg : std_logic;
signal mipi_video_data_out_sel : std_logic; 
signal parallel_16bit_en      : std_logic;
signal shutter_en             : std_logic;
signal lens_shutter_en        : std_logic;
signal pal_ntsc_sel           : std_logic; 

type SNAPSHOT_FSM_t is (s_SNAPSHOT_IDLE,s_WAIT_DMA_FREE,s_SNAPSHOT_WAIT,s_WAIT_DMA_FREE1,s_SNAPSHOT_WAIT1,s_WAIT_DMA_FREE2,s_SNAPSHOT_WAIT2,s_WAIT_DMA_FREE3);
signal SNAPSHOT_FSM   : SNAPSHOT_FSM_t;
    
signal stop_dma_write : std_logic;
signal stop_dma_write2 : std_logic;
signal stop_dma_write_c : std_logic;  
signal MEM_IMG_BUF_SEL1 : std_logic_vector(1 downto 0);

signal MEM_IMG_BUF_SEL2 : std_logic_vector(1 downto 0);

signal snapshot_trigger: std_logic;
signal snapshot_trigger_latch: std_logic;
signal snapshot_mode: std_logic_vector(2 downto 0);
signal snapshot_channel: std_logic_vector(2 downto 0);
signal snapshot_done: std_logic;
signal snapshot_busy: std_logic;
signal snapshot_total_frames: std_logic_vector(7 downto 0);


signal snapshot_trigger_c: std_logic;
signal snapshot_mode_c: std_logic_vector(2 downto 0);
signal snapshot_channel_c: std_logic_vector(2 downto 0);
signal snapshot_done_c: std_logic;
signal snapshot_total_frames_c: std_logic_vector(7 downto 0);

signal snapshot_ctrl_mux: std_logic;

signal OSD_SNAPSHOT_COUNTER       : std_logic_vector(7 downto 0);
signal OSD_SNAPSHOT_COUNTER_VALID : std_logic;
signal OSD_SINGLE_SNAPSHOT        : std_logic;
--signal OSD_CONTINUOUS_SNAPSHOT    : std_logic;
signal OSD_BURST_SNAPSHOT        : std_logic;
signal OSD_SNAPSHOT_DELETE_EN     : std_logic;
--signal OSD_GALLERY_IMG_VALID              : std_logic_vector(63 downto 0);

signal single_snapshot            : std_logic;       
--signal continuous_snapshot        : std_logic; 
signal burst_snapshot             : std_logic; 
signal burst_capture_size         : std_logic_vector(7 downto 0); 
signal snapshot_counter           : std_logic_vector(7 downto 0);      

signal single_snapshot_latch      : std_logic;       
--signal continuous_snapshot_latch  : std_logic; 
signal burst_snapshot_latch  : std_logic; 

signal single_snapshot_en         : std_logic;  
signal burst_snapshot_en          : std_logic;      
--signal continuous_snapshot_en     : std_logic;

signal snapshot_save_done : std_logic; 
signal snapshot_delete_done : std_logic; 
signal gallery_img_valid_save_done : std_logic;
signal UART_Rx : std_logic;
signal UART_TX : std_logic;
signal UART_EN : std_logic;
signal UART_EN_TINEOUT : unsigned(7 downto 0);

signal update_coarse_offset_write: std_logic;
signal update_coarse_offset_writedata: std_logic_vector(31 downto 0);
signal update_coarse_offset_address : std_logic_vector(3 downto 0);


signal snap_img_avg_write: std_logic;
signal snap_img_avg_writedata: std_logic_vector(31 downto 0);
signal snap_img_avg_address : std_logic_vector(3 downto 0);

signal select_co_bus: std_logic;
signal TARGET_VALUE_THRESHOLD: std_logic_vector(15 downto 0);


signal Start_NUC1ptCalib2: std_logic;
signal Start_NUC1ptCalib2_D: std_logic;
signal Start_NUC1ptCalib2_POS_EDGE: std_logic;
signal RETICLE_DIS_2: std_logic;
signal OSD_DIS_2: std_logic;

--type nuc1ptm2_fsm_t is (n_idle, n_en_unity_gain, n_en_unity_gain2, n_take_snapshot1, n_take_snapshot2, n_wait_secs);
--signal nuc1ptm2_fsm: nuc1ptm2_fsm_t;

type nuc1ptm2_fsm_t is (n_idle, n_en_unity_gain, n_en_unity_gain2, n_take_snapshot1, n_take_snapshot2, n_wait_secs, n_disable_sdram_write_snsr_video, n_wait_seminuc_disable);
signal nuc1ptm2_fsm: nuc1ptm2_fsm_t;

signal snapshot_nuc_total_frames: std_logic_vector(7 downto 0);
signal snapshot_nuc_trigger: std_logic;
signal snapshot_nuc_mode:std_logic_vector(2 downto 0);
signal snapshot_nuc_channel: std_logic_vector(2 downto 0);
signal snapshot_nuc_done: std_logic;
--signal frame_delay_cnt :unsigned(3 downto 0);

signal sec_counter: unsigned(3 downto 0);
signal milli_sec_counter: unsigned(3 downto 0);

ATTRIBUTE MARK_DEBUG : string;

--ATTRIBUTE MARK_DEBUG of  VIDEO_I_NUC_V          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_NUC_H          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_NUC_DAV        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_NUC_EOI        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_NUC_DATA       : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_NUC_V          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_NUC_H          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_NUC_EOI        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_NUC_DAV        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_NUC_DATA       : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_NUC_BAD        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_ROW_V          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_ROW_H          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_ROW_DAV        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_ROW_BAD        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_ROW_EOI        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_BADP_V         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_BADP_H         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_BADP_EOI       : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_BADP_DAV       : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_BADP_DATA      : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_V_P            : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_H_P            : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_DAV_P          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_DATA_P         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_EOI_P          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_FILT_V         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_FILT_H         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_FILT_EOI       : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_FILT_DAV       : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_FILT_DATA      : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_V               : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_H               : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_DAV             : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_DATA            : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_O_V             : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_O_H             : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_O_DAV           : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_O_DATA          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SCALER_O_EOI           : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_V_BC           : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_H_BC           : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_DAV_BC         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_DATA_BC        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_O_EOI_BC         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_V_SN           : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_H_SN           : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_DAV_SN         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_DATA_SN        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_EOI_SN         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SNSR_FPGA_PIXEL_CLK    : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SNSR_FPGA_LINEVALID    : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  SNSR_FPGA_FRAMEVALID   : SIGNAL IS "TRUE";  
--ATTRIBUTE MARK_DEBUG of  SNSR_FPGA_DATA         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  polarity               : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  ENABLE_BADPIXREM       : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  ENABLE_SNUC            : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  ENABLE_NUC_D           : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  offset_img_avg         : SIGNAL IS "TRUE"; 

signal OLED_VGN_TEST : std_logic_vector(31 downto 0);
signal disable_update_sensor_param : std_logic;

signal ADDR_COARSE_OFFSET : std_logic_vector(31 downto 0);

--signal counter : unsigned(31 downto 0);
--signal SN_CNT : unsigned(31 downto 0);
--signal MIPI_IN_CNT : unsigned(31 downto 0);
--signal BT656_V_CNT : unsigned(31 downto 0);
--type fsm_test_st is (idle,wait_sn,wait_bt656_v,wait_mipi_in,done_st);
--signal test_st   : fsm_test_st;
--signal DMA_ADDR_IMG_OUT: std_logic_vector(1 downto 0);

ATTRIBUTE MARK_DEBUG of ENABLE_UNITY_GAIN2        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of ENABLE_UNITY_GAIN_C       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of snapshot_ctrl_mux         : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of snapshot_nuc_trigger      : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of snapshot_nuc_mode         : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of snapshot_nuc_channel      : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of nuc1ptm2_fsm              : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of APPLY_NUC1ptCalib2        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of Start_NUC1ptCalib2        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of Start_NUC1ptCalib2_D      : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_I_NUC_V             : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of snapshot_done_c           : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of OSD_START_NUC1PT2CALIB    : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of snapshot_trigger_c        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of stop_dma_write2           : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of stop_dma_write_c          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of DMA_WRITE_FREE            : SIGNAL IS "TRUE";

signal GALLERY_ENABLE        : std_logic;           
signal GALLERY_IMG_NUMBER  : std_logic_vector(7 downto 0);
signal gallery_img_valid   : std_logic_vector(71 downto 0);
signal gallery_img_valid_en: std_logic;
signal OSD_GALLERY_IMG_VALID       : std_logic_vector(71 downto 0);
signal OSD_GALLERY_IMG_VALID_EN    : std_logic;
signal OSD_LOAD_GALLERY            : std_logic;
signal gallery_img_rd_qspi_wr_sdram_en : std_logic;
signal sensor_power_on_init_done : std_logic; 
signal area_switch_done : std_logic;
signal low_to_high_temp_area_switch : std_logic;
signal high_to_low_temp_area_switch : std_logic;
signal lo_to_hi_area_global_offset_force_val : std_logic_vector(15 downto 0);
signal hi_to_lo_area_global_offset_force_val : std_logic_vector(15 downto 0);
signal toggle_gpio           : std_logic;
signal latch_toggle_gpio     : std_logic;
signal nuc1pt_start_in       : std_logic;
signal temperature_threshold : std_logic_vector(15 downto 0);
signal offset_poly_calc_done : std_logic;
signal offset_poly_calc_busy : std_logic; 

type state is (idle,wait_run,wait_h_gen,gen_rq_h,pixel_count,wait_v_gen);
signal fsm_scaler : state;
signal line_ct : unsigned (10 downto 0);
signal pix_ct : unsigned (10 downto 0);
signal wait_h : unsigned (8 downto 0);
signal wait_v : unsigned (15 downto 0);
signal wait_frame_time : unsigned (20 downto 0);

ATTRIBUTE MARK_DEBUG of video_o_frame_valid : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of video_o_line_valid  : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of video_o_de          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of video_o_vsync       : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of video_o_hsync       : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_BIL_REQ_V    : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_BIL_LINE_NO  : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_BIL_REQ_H    : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_O_V          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_O_H          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_O_EOI        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_O_DAV        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of line_ct             : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of pix_ct              : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_V            : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of BT656_START         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of SCALER_V            : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of SCALER_DAV          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of pix_cnt_out         : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of line_cnt_out        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of fsm_scaler          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of frame_cnt1          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of frame_cnt2          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of frame_cnt3          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of TICK1S              : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of SCALER_REQ_V        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of SCALER_REQ_H        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of SCALER_LIN_NO       : SIGNAL IS "TRUE";

begin

clk_wiz:If (OLED_EN = TRUE or USB_EN = TRUE or EK_EN = TRUE) Generate
i_TOII_TUVE_clk_wiz : TOII_TUVE_clk_wiz
   port map ( 

   -- Clock in ports
   clk_in1  => FPGA_27MHz_CLK,
  -- Clock out ports  
   clk_out1 => CLK_27MHZ,
   clk_out2 => SENSOR_MCLK, 
   clk_out3 => CLK_100MHZ,  -- 99 Mhz actual
   clk_out4 => CLK_100MHZ_PS_225,
   clk_out5 => CLK_54MHZ, --66 Mhz
   clk_out6 => CLK_148_5MHZ, 
   clk_out7 => CLK_74_25MHZ, 
  -- Status and control signals                
   reset => '0',
   locked => locked            
 );
end generate; 

clk_wiz1:If (MIPI_EN = TRUE) Generate
i_TOII_TUVE_clk_wiz : TOII_TUVE_clk_wiz
   port map ( 

   -- Clock in ports
   clk_in1  => FPGA_27MHz_CLK,
  -- Clock out ports  
   clk_out1 => CLK_27MHZ,
   clk_out2 => SENSOR_MCLK, 
   clk_out3 => CLK_100MHZ,  -- 99 Mhz actual
   clk_out4 => CLK_100MHZ_PS_225,
   clk_out5 => CLK_54MHZ, --66 Mhz
  -- Status and control signals                
   reset => '0',
   locked => open            
 );
end generate; 

MIPI_CLK_GEN :If (MIPI_EN = TRUE) Generate
 i_mipi_csi_ip_clock : mipi_csi_ip_clock
   port map ( 

   -- Clock in ports
   clk_in1  => CLK_54MHZ,
  -- Clock out ports  
   clk_out1 => CLK_200MHZ,               
   reset => '0',
   locked => locked            
 );
 end generate;

--i_TOII_TUVE_clk_wiz : TOII_TUVE_clk_wiz
--   port map ( 

--   -- Clock in ports
--   clk_in1  => FPGA_27MHz_CLK,
--  -- Clock out ports  
--   clk_out1 => CLK_100MHZ,--CLK_27MHZ,
--   clk_out2 => CLK_27MHZ,--SENSOR_MCLK, -- 22 MHZ
--   clk_out3 => CLK_54MHZ,--CLK_100MHZ,  -- 99 Mhz actual
--   clk_out4 => SENSOR_MCLK,
----   clk_out5 => CLK_54MHZ,
--  -- Status and control signals                
--   reset => '0',
--   locked => locked            
-- );



process(FPGA_27MHz_CLK, locked)
--process(CLK_54MHZ, locked)
    begin
    if locked = '0' then
        RST <= '1';
        RST_CNT <= 0;
        SNSR_FPGA_MASTER_CLK_En <= '0'; 
--        FPGA_LDO_VA4_EN      <= '1'; 
--        FPGA_LDO_VD2_EN      <= '1'; 
        FPGA_LDO_VA4_EN      <= '0'; 
        FPGA_LDO_VD2_EN      <= '0';         
        OLED_RESET           <= '0';  
        OLED_POWER_EN        <= '0';
--        BNO_RST              <= '0';
--        CLK_13_5_MHZ         <= '0';
--        RST_CNT1 <= 0;    
    elsif rising_edge(FPGA_27MHz_CLK) then
--    elsif rising_edge(CLK_54MHZ) then  
--        CLK_13_5_MHZ <= not CLK_13_5_MHZ;   
        if RST_CNT = 13_500_000 then
--        if RST_CNT = 27_000_000 then
             SNSR_FPGA_MASTER_CLK_En <= '1';
--             FPGA_LDO_VA4_EN      <= '1'; 
             OLED_POWER_EN        <= '1';
--             BNO_RST              <= '1';
             
        end if;
--        if RST_CNT = 15_000_000 then
--            FPGA_LDO_VD2_EN      <= '1';
--        end if;          
              
        if RST_CNT = 17_550_000 then  -- Around 360 ms delay
--        if RST_CNT = 34_100_000 then
            RST_CNT        <= RST_CNT;
            RST            <= '0'; 
            OLED_RESET     <= '1';               
        else
            RST_CNT    <= RST_CNT + 1;
            RST        <= '1';
            OLED_RESET <= '0';
        end if;

        FPGA_LDO_VA4_EN         <= '1'; 
        FPGA_LDO_VD2_EN         <= '1';  
                 
    end if;
end process;  

RST_N <= not RST;
--process(CLK_33MHZ, locked)
----process(CLK_54MHZ, locked)
--    begin
--    if locked = '0' then
--        CLK_33MHZ <= '0';
--    elsif rising_edge(CLK_54MHZ) then  
--        CLK_33MHZ <= not CLK_33MHZ;                 
--   end if;
--end process;  


--xpm_cdc_async_rst_27MHz : xpm_cdc_async_rst
--   generic map (
--      DEST_SYNC_FF => 4,    -- DECIMAL; range: 2-10
--      INIT_SYNC_FF => 0,    -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
--      RST_ACTIVE_HIGH => 1  -- DECIMAL; 0=active low reset, 1=active high reset
--   )
--   port map (
--      dest_arst => RST_27MHz, 
--      dest_clk => CLK_27MHZ,   -- 1-bit input: Destination clock.
--      src_arst => RST    -- 1-bit input: Source asynchronous reset signal.
--   );  

SNSR_FPGA_MASTER_CLK <= SNSR_FPGA_MASTER_CLK_En and SENSOR_MCLK;
SNSR_FPGA_SEQTRIG    <= '0';
--FPGA_SDRAM_CLK       <= CLK_100MHZ ;
FPGA_SDRAM_CLK       <= CLK_100MHZ_PS_225;
CLK                  <= CLK_54MHZ;--CLK_74_25MHZ;--CLK_54MHZ;--CLK_39_5MHZ;--CLK_27MHZ ;
INV_CLK_27MHZ        <= not CLK_27MHZ ;
--debug_gen : If (MIPI_EN = TRUE) Generate
--    FPGA_B2B_M_GPIO1 <= video_o_frame_pulse;--SCALER_REQ_V;--VIDEO_MUX_OUT_V and (not qspi_init_cmd_done_n);--VIDEO_I_V_SN;
--    FPGA_B2B_M_GPIO2 <= video_o_frame_pulse;
--    FPGA_B2B_M_GPIO3 <= SCALER_REQ_V; --BT656_V;
-- process(CLK, RST)begin
--        if RST = '1' then
--           counter  <= (others=>'0');
--           test_st  <= idle; 
--        elsif rising_edge(CLK) then  
--            case test_st is
--                when  idle =>
--                    test_st <= wait_sn;
--                when  wait_sn =>
----                    if(VIDEO_I_V_SN = '1')then
----                    if(VIDEO_MUX_OUT_V = '1'  and qspi_init_cmd_done_n = '0') then
--                      test_st <= wait_bt656_v;
--                      SN_CNT  <= MIPI_IN_CNT - BT656_V_CNT;
----                      SN_CNT  <= counter;
----                    end if;  
----                when  wait_bt656_v =>
------                    if(BT656_V = '1')then 
------                   if(SCALER_REQ_V = '1')then
----                    if(DMA_ADDR_IMG_OUT = "00")then
----                      test_st <= wait_mipi_in;
----                      BT656_V_CNT  <= counter;
----                    end if; 
                      
----                when  wait_mipi_in =>
----                   if(video_o_frame_pulse = '1')then
----                    test_st <= done_st;
----                    MIPI_IN_CNT <= counter;
----                   end if; 

--                when  wait_bt656_v =>
----                    if(BT656_V = '1')then 
--                   if(SCALER_REQ_V = '1')then
----                   if(MIPI_USB_V = '1') then                      
----                    if (MEM_IMG_BUF = "00")then
----                    if(DMA_ADDR_IMG_OUT = "00")then
----                    if(DMA_ADDR_IMG_OUT = "00")then
----                   if(VIDEO_I_V_SN = '1')then
--                      test_st <= wait_mipi_in;
--                      BT656_V_CNT  <= counter;
--                    end if; 
                      
--                when  wait_mipi_in =>
----                   if(video_o_frame_pulse = '1')then
--                   if(BT656_V = '1')then 
                   
----                   if (VIDEO_V_PROC = '1') then
----                   if(DMA_ADDR_IMG_OUT = "01")then
----                  if (MEM_IMG_BUF = "01")then
----                    if(VIDEO_O_V_BC = '1')then
--                        test_st <= wait_sn;
--                        MIPI_IN_CNT <= counter;
--                        counter <= (others=>'0');
--                   end if; 
--                when done_st =>
--                    test_st <= done_st;
                                        
                   
--            end case;        
--            if TICK1US = '1' then
--              counter <= counter + 1;  
--            end if;
            
--        end if;
--  end process;  
    
    
    
--end generate;
JEOS_INTR_GEN : If (EK_EN = TRUE) Generate
    FPGA_B2B_M_SD_DAT2 <= toggle_gpio;
end generate;

oled_keypad_gen : If (OLED_EN = TRUE) Generate
--OLED_DATAEN          <= '0';
adv_sleep_mode_en    <= (OSD_STANDBY_EN)     and OSD_STANDBY_EN_VALID;
--adv_sleep_mode_en    <= cmd_adv_sleep_mode_en;
oled_reinit_en       <= (not OSD_STANDBY_EN) and OSD_STANDBY_EN_VALID;
--oled_reinit_en       <= cmd_oled_reinit_en;
FPGA_B2B_M_SD_CMD    <= OLED_POWER_EN and (not OLED_POWER_OFF);
--FPGA_B2B_M_SD_CMD    <= OLED_POWER_EN and (not OSD_STANDBY_EN);
--FPGA_B2B_M_SD_CMD    <= OLED_POWER_EN and (not CMD_STANDBY_EN);
FPGA_B2B_M_GPIO1     <= OLED_RESET and (not OLED_RESET1);
--FPGA_B2B_M_GPIO1     <= OLED_RESET and (not CMD_OLED_RESET);
FPGA_B2B_M_GPIO2     <= OLED_DATAEN;
FPGA_B2B_M_GPIO3     <= not (POWER_OFF_EN or OSD_POWER_OFF_EN);

--BNO_PS1 <= '0';      
--BNO_PS0 <= '1'; 

FPGA_B2B_M_SD_CLK    <= MUX_LASER_EN;

GPIO_I_1 <= FPGA_B2B_M_SD_SDCD;
GPIO_I_2 <= FPGA_B2B_M_SD_DAT3;
GPIO_I_3 <= FPGA_B2B_M_SD_DAT2;
GPIO_I_4 <= FPGA_B2B_M_SD_DAT1;
--GPIO_I_5 <= FPGA_B2B_M_SD_DAT0;
FPGA_B2B_M_SD_DAT0 <= '0';

debouncer_en <= RST or (not qspi_init_cmd_done) or product_sel;



i_debouncer: entity work.debouncer
  generic map(
      FREQ => SYS_FREQ,
      SETTLE_TIME=> 20 ms,
      PULLUP=>'0'
--      MIN_TIME_GAP_PRESS_RELEASE => to_unsigned(30,12)
    )
  port map(
      clk      => CLK,
      rst      => debouncer_en,
      tick1ms  => TICK1MS,
      tick1s   => TICK1S,
      MIN_TIME_GAP_PRESS_RELEASE     => MIN_TIME_GAP_PRESS_RELEASE,
      max_release_wait_time          => MAX_RELEASE_WAIT_TIME,
      max_gpio_o_2_3_long_press_time => MAX_UP_DOWN_PRESS_TIME,
      max_gpio_o_1_2_long_press_time => MAX_MENU_DOWN_PRESS_TIME,
      max_gpio_o_1_3_long_press_time => MAX_MENU_DOWN_PRESS_TIME,
      long_press_step_size           => LONG_PRESS_STEP_SIZE,
      gpio_i_1 => GPIO_I_1,
      gpio_i_2 => GPIO_I_2,
      gpio_i_3 => GPIO_I_3,
      gpio_i_4 => GPIO_I_4,
      gpio_i_5 => GPIO_I_5,

    -- Pulse Outputs
      gpio_o_1_pulse      => CENTER_KEY_PRESS, -- CENTER KEY
      gpio_o_2_pulse      => DOWN_KEY_PRESS  , -- DOWN KEY
      gpio_o_3_pulse      => UP_KEY_PRESS    , -- UP KEY
      gpio_o_4_pulse      => RIGHT_KEY_PRESS , -- RIGHT KEY
      gpio_o_5_pulse      => LEFT_KEY_PRESS  , -- LEFT KEY
      
      gpio_o_1_long_press_pulse => CENTER_KEY_LONG_PRESS,
      gpio_o_2_long_press_pulse => DOWN_KEY_LONG_PRESS,
      gpio_o_3_long_press_pulse => UP_KEY_LONG_PRESS,
      gpio_o_4_long_press_pulse => RIGHT_KEY_LONG_PRESS,
      gpio_o_5_long_press_pulse => LEFT_KEY_LONG_PRESS,

      gpio_o_1_long_press_level => CENTER_KEY_LONG_PRESS_LEVEL,
      gpio_o_2_long_press_level => DOWN_KEY_LONG_PRESS_LEVEL,
      gpio_o_3_long_press_level => UP_KEY_LONG_PRESS_LEVEL,
      gpio_o_4_long_press_level => RIGHT_KEY_LONG_PRESS_LEVEL,
      gpio_o_5_long_press_level => LEFT_KEY_LONG_PRESS_LEVEL,

      gpio_o_1_2_long_press_pulse => CENTER_DOWN_KEY_LONG_PRESS, --toggle_menu_loc,
      gpio_o_1_3_long_press_pulse => CENTER_UP_KEY_LONG_PRESS,   --toggle_menu_loc,
      gpio_o_2_3_long_press_pulse => toggle_menu_loc --ADVANCE_MENU_TRIG_IN --DOWN_UP_KEY_LONG_PRESS     

    );
    
  pal_ntsc_sel <= PAL_nNTSC;
end generate;
usb_spi_slave_gen : If (USB_EN = TRUE) Generate
i_SPI_Slave_Comm : SPI_Slave_Comm
--  generic map(SPI_MODE =>0)
  port map(
   rst              => rst,    -- FPGA Reset
   clk              => clk,    -- FPGA Clock
   spi_mode         => spi_mode,
   spi_sclk         => FPGA_B2B_M_GPIO1,--FPGA_B2B_M_BT656_D(0),--FPGA_B2B_M_GPIO1,
   spi_miso         => FPGA_B2B_M_SD_DAT0,--FPGA_B2B_M_BT656_CLK,--FPGA_B2B_M_SD_DAT0,
   spi_mosi         => FPGA_B2B_M_GPIO3,--FPGA_B2B_M_BT656_D(1),--FPGA_B2B_M_SD_DAT0,
   spi_ss           => FPGA_B2B_M_GPIO2,--FPGA_B2B_M_BT656_D(2),--FPGA_B2B_M_GPIO2,
   read_data_valid  => spi_read_data_valid,    -- Data Valid pulse (1 clock cycle)
   read_data        => spi_read_data,  -- Byte received on MOSI
   write_data_valid => spi_write_data_valid,  -- Data Valid pulse to register write_data
   write_data       => spi_write_data        -- Byte to serialize to MISO.
   );


i_SPI_SLAVE_DATA_DECODE : SPI_SLAVE_DATA_DECODE
  generic map(DATA_WIDTH=>8)
  port map(
   rst                    => rst,   
   clk                    => clk,    
   data_in_valid          => spi_read_data_valid,    -- Data Valid pulse (1 clock cycle)
   data_in                => spi_read_data,  -- Byte received on MOSI
   data_out_valid         => spi_write_data_valid,
   data_out               => spi_write_data, 
   debug_reg              => spi_slave_debug_reg,
   usb_video_data_out_sel => usb_video_data_out_sel,
   pal_ntsc_sel           => pal_ntsc_sel
   );

 end generate;

i_FDIV: entity work.FDIV
generic map(  FCLK => SYS_FREQ)
port map( 
     CLK       => CLK,--CLK_27MHZ,
     RST       => RST,
     CLR       => '0',
     TICK1US   => TICK1US,
     TICK10US  =>  open,
     TICK100US =>  open,
     TICK1MS   =>  TICK1MS,
     TICK1S    =>  TICK1S
  );

user_settings_mem_wr_req1 <= user_settings_mem_wr_req and BT656_START; 
      
i_regs_master : regs_master
 generic map(
SYS_FREQ  => SYS_FREQ,
--SPI_FREQ  => SPI_FREQ,
I2C_FREQ  => I2C_FREQ,
PIX_BITS    => PIX_BITS   ,
LIN_BITS    => LIN_BITS   ,
VIDEO_XSIZE => VIDEO_XSIZE,
VIDEO_YSIZE => VIDEO_YSIZE,
DMA_SIZE_BITS => DMA_SIZE_BITS

)
  port map(
        clk                   => CLK,--CLK_27MHZ,
        rst                   => RST,
        clk_27mhz             => CLK_27MHZ,
        rst_27mhz             => RST,
        sel_oled_analog_video_out => sel_oled_analog_video_out,
        coarse_offset_calib_start => OSD_COARSE_OFFSET_CALIB_START,
        product_sel           => product_sel,
        bat_adc_en            => bat_adc_en,
        trigger               => trigger,
        sensor_trigger        => open,--SNSR_FPGA_SEQTRIG,
        sensor_power_on_init_done => sensor_power_on_init_done,
        adv_reset_n           => DAC_RESET,
        tick_1ms              => TICK1MS,
        tick_1us              => TICK1US,
        tick_1s               => TICK1S,
        PAL_nNTSC_SEL_DONE    => PAL_nNTSC_SEL_DONE,
        PAL_nNTSC             => PAL_nNTSC, 
        pal_ntsc_sel          => pal_ntsc_sel,
--        adv_sleep_mode_en     => adv_sleep_mode_en,
--        oled_reinit_en        => oled_reinit_en,
        standby_en_valid      => OSD_STANDBY_EN_VALID,
        standby_en            => OSD_STANDBY_EN,
        oled_reset            => OLED_RESET1,
        oled_power_off        => OLED_POWER_OFF, 
        OLED_VGN_TEST         => OLED_VGN_TEST,
        OLED_GAMMA_TABLE_SEL  => MUX_OLED_GAMMA_TABLE_SEL,
        OLED_POS_V            => MUX_OLED_POS_V,
        OLED_POS_V_VALID      => MUX_OLED_POS_V_VALID,
        OLED_POS_H            => MUX_OLED_POS_H,
        OLED_POS_H_VALID      => MUX_OLED_POS_H_VALID,
        OLED_BRIGHTNESS       => MUX_OLED_BRIGHTNESS_MAP,    
        OLED_BRIGHTNESS_VALID => MUX_OLED_BRIGHTNESS_MAP_VALID,  
        OLED_CONTRAST         => MUX_OLED_CONTRAST_MAP,
        OLED_CONTRAST_VALID   => MUX_OLED_CONTRAST_MAP_VALID  , 
        OLED_IDRF             => OLED_IDRF,
        OLED_IDRF_VALID       => OLED_IDRF_VALID      , 
        OLED_DIMCTL           => MUX_OLED_DIMCTL,   
        OLED_DIMCTL_VALID     => MUX_OLED_DIMCTL_VALID    , 
        OLED_IMG_FLIP         => OLED_IMG_H_FLIP,
        OLED_IMG_FLIP_VALID   => OLED_IMG_H_FLIP_VALID, 
        OLED_CATHODE_VOLTAGE  => OLED_CATHODE_VOLTAGE,
        OLED_CATHODE_VOLTAGE_VALID => OLED_CATHODE_VOLTAGE_VALID, 
        OLED_ROW_START_MSB       => OLED_ROW_START_MSB,
        OLED_ROW_START_MSB_VALID => OLED_ROW_START_MSB_VALID_D,
        OLED_ROW_START_LSB       => OLED_ROW_START_LSB,
        OLED_ROW_START_LSB_VALID => OLED_ROW_START_LSB_VALID_DD,        
        OLED_ROW_END_MSB         => OLED_ROW_END_MSB,
        OLED_ROW_END_MSB_VALID   => OLED_ROW_END_MSB_VALID_DDD,        
        OLED_ROW_END_LSB         => OLED_ROW_END_LSB,
        OLED_ROW_END_LSB_VALID   => OLED_ROW_END_LSB_VALID_DDDD,        
--        OLED_REG_DATA_IN      => OLED_REG_DATA    , 
        ADV_DEV_ADDR          => ADV_DEV_ADDR,
        OLED_DEV_ADDR         => OLED_DEV_ADDR,
        BAT_GAUGE_DEV_ADDR    => BAT_GAUGE_DEV_ADDR,
        BAT_ADC_DEV_ADDR      => BAT_ADC_DEV_ADDR,
        OLED_VGN_ADC_DEV_ADDR => OLED_VGN_ADC_DEV_ADDR,
        MAX_VGN_SETTLE_TIME    => MAX_VGN_SETTLE_TIME,
        MAX_OLED_VGN_RD_PERIOD => MAX_OLED_VGN_RD_PERIOD,
        MAX_BAT_PARAM_RD_PERIOD=> MAX_BAT_PARAM_RD_PERIOD,
        bat_control_reg_data   =>  BATTERY_CONTROL    ,
        bat_status_reg_data    =>  BATTERY_STATUS     ,
        bat_temp_reg_data      =>  BATTERY_TEMPERATURE,
        bat_voltage_reg_data   =>  BATTERY_VOLTAGE    ,
        bat_acc_charge_reg_data=>  BATTERY_ACC_CHARGE ,    
        magneto_x_data         =>  MAGNETO_X_DATA,   
        magneto_y_data         =>  MAGNETO_Y_DATA,   
        magneto_z_data         =>  MAGNETO_Z_DATA, 
        accel_x_data           =>  ACCEL_X_DATA, 
        accel_y_data           =>  ACCEL_Y_DATA, 
        accel_z_data           =>  ACCEL_Z_DATA,           
        qspi_init_cmd_done    => qspi_init_cmd_done,
        BT656_START           => BT656_START,
        video_start           => video_start ,
        battery_disp_start    => battery_disp_start,
        LOGO_WR_EN            => LOGO_WR_EN,
        LOGO_WR_DATA          => LOGO_WR_DATA,        
        RETICLE_WR_EN         => RETICLE_WR_EN,
        RETICLE_WR_DATA       => RETICLE_WR_DATA,
        RETICLE_OFFSET_WR_EN  => RETICLE_OFFSET_WR_EN,
        RETICLE_OFFSET_WR_DATA=> RETICLE_OFFSET_WR_DATA, 
        DMA_WRITE_FREE        => DMA_WRITE_FREE,
 
        RETICLE_POS_X      => RETICLE_POS_X_SET,
        RETICLE_POS_Y      => RETICLE_POS_Y_SET,
        RETICLE_OFFSET_X   => RETICLE_OFFSET_X,
        RETICLE_OFFSET_Y   => RETICLE_OFFSET_Y,
        
        update_sensor_param         => update_sensor_param,        
        new_sensor_param_start_addr => new_sensor_param_start_addr,
        sensor_init_data_len    => sensor_init_data_len,

        -------------------With I2C --------------------------------------------------------//dcs//
        SNSR_FPGA_NRST_SPI_CS      => SNSR_FPGA_NRST_SPI_CS,  --output  
        SNSR_FPGA_I2C2_SCL_SPI_SCK => SNSR_FPGA_I2C2_SCL_SPI_SCK,  --inout 
        SNSR_FPGA_I2C2_SDA_SPI_SDO => SNSR_FPGA_I2C2_SDA_SPI_SDO, -- inout
        ----------        
        
        snap_trigger                => snapshot_trigger,
        snap_channel                => snapshot_channel,
        snap_mode                   => snapshot_mode,
        snap_done                   => snapshot_done,
        snap_image_numbers          => snapshot_total_frames,
        single_snapshot_en          => single_snapshot_en,
--        continuous_snapshot_en      => continuous_snapshot_en,
        burst_snapshot_en           => burst_snapshot_en,
        burst_capture_size          => burst_capture_size,
        snapshot_counter            => snapshot_counter,
        snapshot_save_done          => snapshot_save_done,
        gallery_img_number          => GALLERY_IMG_NUMBER,
        osd_snapshot_delete_en      => OSD_SNAPSHOT_DELETE_EN,
        snapshot_delete_done        => snapshot_delete_done,
        gallery_img_valid_save_done => gallery_img_valid_save_done,
        gallery_img_valid           => gallery_img_valid,
        gallery_img_valid_en        => gallery_img_valid_en,
        
--        mux_zoom_mode              => MUX_ZOOM_MODE,
        reticle_sel                => reticle_sel_out,
        qspi_reticle_transfer_done => qspi_reticle_transfer_done,
        qspi_reticle_transfer_rq_ack => qspi_reticle_transfer_rq_ack,
        qspi_reticle_transfer_rq   => qspi_reticle_transfer_rq,  
        
        OSD_MARK_BP                    =>   OSD_MARK_BP               ,
        OSD_MARK_BP_VALID              =>   OSD_MARK_BP_VALID         ,
        OSD_UNMARK_BP                  =>   OSD_UNMARK_BP             ,
        OSD_UNMARK_BP_VALID            =>   OSD_UNMARK_BP_VALID       ,
        OSD_SAVE_BP                    =>   OSD_SAVE_BP               ,
        OSD_LOAD_USER_SETTINGS         =>   OSD_LOAD_USER_SETTINGS    ,
        OSD_LOAD_FACTORY_SETTINGS      =>   OSD_LOAD_FACTORY_SETTINGS ,
        OSD_SAVE_USER_SETTINGS         =>   MUX_OSD_SAVE_USER_SETTINGS, --OSD_SAVE_USER_SETTINGS --MUX_OSD_OLED_SAVE_USER_SETTINGS    ,

        user_settings_mem_wr_addr      => user_settings_mem_wr_addr  ,
        user_settings_mem_wr_data      => user_settings_mem_wr_data  ,
        user_settings_mem_wr_req       => user_settings_mem_wr_req1  ,
        user_settings_mem_rd_req       => user_settings_mem_rd_req   ,
        user_settings_mem_rd_addr      => user_settings_mem_rd_addr  ,
        user_settings_mem_rd_data      => user_settings_mem_rd_data  ,  
        user_settings_init_start       => user_settings_init_start   ,   
        user_settings_init_done        => user_settings_init_done    ,

        av_uart_address       => av_uart_address,
        av_uart_read          => av_uart_read ,
        av_uart_readdata      => av_uart_readdata ,
        av_uart_readdatavalid => av_uart_readdatavalid ,
        av_uart_write         => av_uart_write ,
        av_uart_writedata     => av_uart_writedata ,
        av_uart_waitrequest   => av_uart_waitrequest ,
        
        av_fpga_address       => FPGA_ADDR, 
        av_fpga_read          => FPGA_RDREQ,
        av_fpga_readdata      => FPGA_RDDATA,
        av_fpga_readdatavalid => FPGA_RDDAV,
        av_fpga_write         => FPGA_WRREQ,
        av_fpga_writedata     => FPGA_WRDATA,
        av_fpga_waitrequest   => FPGA_WAITREQ,
        
        av_rdsdram_address       => av_rdsdram_address_s  ,
        av_rdsdram_read          => av_rdsdram_read_s ,
        av_rdsdram_readdata      => av_rdsdram_readdata_s ,
        av_rdsdram_readdatavalid => av_rdsdram_readdatavalid_s ,
        av_rdsdram_burstcount    => av_rdsdram_burstcount_s ,
        av_rdsdram_waitrequest   => av_rdsdram_waitrequest_s ,
        av_wrsdram_address       => av_wrsdram_address_s ,
        av_wrsdram_write         => av_wrsdram_write_s ,
        av_wrsdram_writeburst    => av_wrsdram_writeburst_s ,
        av_wrsdram_writedata     => av_wrsdram_writedata_s ,
        av_wrsdram_burstcount    => av_wrsdram_burstcount_s ,
        av_wrsdram_byteenable    => av_wrsdram_byteenable_s ,
        av_wrsdram_waitrequest   => av_wrsdram_waitrequest_s,

        av_i2c_address       => I2C_ADDRESS_combined,
        av_i2c_read          => I2C_ReadEN,
        av_i2c_readdata      => I2C_ReadData,
        av_i2c_readdatavalid => I2C_ReadDAV,
        av_i2c_write         => I2C_WriteEN,
        av_i2c_writedata     => I2C_WriteData,
        av_i2c_waitrequest   => I2C_Busy,
        av_i2c_data_16_en    => I2C_DATA_16_EN,
        i2c_ack_error        => i2c_ack_error,

--        av_sensor_address       => sensor_address,
--        av_sensor_read          => sensor_read,
--        av_sensor_readdata      => sensor_readdata,
--        av_sensor_readdatavalid => sensor_readdatavalid,
--        av_sensor_write         => sensor_write,
--        av_sensor_writedata     => sensor_writedata,
--        av_sensor_waitrequest   => sensor_waitrequest,

--        av_sensor_write1         => sensor_write1,
--        av_sensor_writedata1     => sensor_writedata1,
--        av_sensor_address1       => sensor_address1,


--        av_sensor_i2c_address       => sensor_i2c_address,
--        av_sensor_i2c_read          => sensor_i2c_read,
--        av_sensor_i2c_readdata      => sensor_i2c_readdata,
--        av_sensor_i2c_readdatavalid => sensor_i2c_readdatavalid,
--        av_sensor_i2c_write         => sensor_i2c_write,
--        av_sensor_i2c_writedata     => sensor_i2c_writedata,
--        av_sensor_i2c_waitrequest   => sensor_i2c_waitrequest,
       
--        av_spi_address       => SPI_ADDRESS,
--        av_spi_read          => SPI_ReadEN,
--        av_spi_readdata      => SPI_ReadData,
--        av_spi_readdatavalid => SPI_ReadDAV,
--        av_spi_write         => SPI_WriteEN,
--        av_spi_writedata     => SPI_WriteData,
--        av_spi_waitrequest   => SPI_WaitReq,
        
        sd_bus_busy_o   => sd_bus_busy_o ,
        sd_bus_addr_i   => sd_bus_addr_i ,
        sd_bus_rd_i     => sd_bus_rd_i ,
        sd_bus_data_o   => sd_bus_data_o,
        sd_bus_hndShk_o => sd_bus_hndShk_o ,
        sd_bus_wr_i     => sd_bus_wr_i ,
        sd_bus_data_i   => sd_bus_data_i,
        sd_bus_hndShk_i => sd_bus_hndShk_i ,
        sd_bus_error_o  => sd_bus_error_o,
        
        FPGA_SPI_DQ0    => FPGA_SPI_DQ0,--//inout 
        FPGA_SPI_DQ1    => FPGA_SPI_DQ1, --//inout 
        FPGA_SPI_DQ2    => FPGA_SPI_DQ2,--//inout 
        FPGA_SPI_DQ3    => FPGA_SPI_DQ3,--//inout 
        FPGA_SPI_CS     => FPGA_SPI_CS, --//output 
        
        gallery_img_rd_qspi_wr_sdram_en => gallery_img_rd_qspi_wr_sdram_en,
        ch_img_rd_qspi_wr_sdram_en    => ch_img_rd_qspi_wr_sdram_en,
        ch_img_sdram_addr             => ch_img_sdram_addr         ,
        ch_img_qspi_addr              => ch_img_qspi_addr          ,
        ch_img_len                    => ch_img_len                ,
        ch_img_sum                    => ch_img_sum,
 
--        device_id                     => device_id,
        PRDCT_NAME_WRITE_DATA        => PRDCT_NAME_WRITE_DATA,
        PRDCT_NAME_WRITE_DATA_VALID  => PRDCT_NAME_WRITE_DATA_VALID,
        temperature_write_data       => temperature_write_data,
        temperature_write_data_valid => temperature_write_data_valid,
        temperature_rd_data          => temperature_rd_data,
        temperature_rd_data_valid    => temperature_rd_data_valid,
        temperature_rd_rq            => temperature_rd_rq,
        temperature_wr_addr          => temperature_wr_addr,
        temperature_wr_rq            => temperature_wr_rq,
        control_sdram_write_start_stop => shutter_control_sdram_write_start_stop,
        shutter_en                   => shutter_en,
        toggle_gpio                  => toggle_gpio, -- latch_toggle_gpio
        nuc1pt_start_in              => nuc1pt_start_in,--OSD_START_NUC1PT2CALIB,--OSD_START_NUC1PTCALIB,--OSD_START_NUC1PT2CALIB,   
        nuc1pt_done                  => auto_nuc1pt_done,--snapshot_nuc_done,--NUC1pt_done_offset,--snapshot_nuc_done, 
        nuc1pt_start                 => auto_nuc1pt_start        
        
    );

MUX_OSD_SAVE_USER_SETTINGS <= OSD_SAVE_USER_SETTINGS or DISPLAY_MODE_SAVE_USER_SETTINGS;

FPGA_WAITREQ <=  FPGA_BUSY;
OSD_START_NUC1PTCALIB_POS_EDGE <= OSD_START_NUC1PTCALIB and not OSD_START_NUC1PTCALIB_D;
OSD_START_NUC1PTCALIB_NEG_EDGE <= not OSD_START_NUC1PTCALIB and OSD_START_NUC1PTCALIB_D;

toggle_osd_flip_pos_edge <= toggle_osd_flip and not toggle_osd_flip_d;
toggle_osd_flip_neg_edge <= not toggle_osd_flip and toggle_osd_flip_d;

process(CLK, RST)
    begin
    if RST = '1' then
      image_width_full         <= std_logic_vector(to_unsigned(648,image_width_full'length));
      temp_pixels_left         <= std_logic_vector(to_unsigned(3,temp_pixels_left'length));
      temp_pixels_right        <= std_logic_vector(to_unsigned(3,temp_pixels_right'length));
      exclude_right            <= std_logic_vector(to_unsigned(2,exclude_right'length));
      exclude_left             <= std_logic_vector(to_unsigned(0,exclude_left'length));
      FPGA_RDDAV               <= '0';
      VIDEO_CTRL_REG           <= x"00000005" ;
      OLED_GAMMA_TABLE_SEL     <= x"00";
      OLED_POS_V               <= x"18";
      OLED_POS_H               <= std_logic_vector(to_unsigned(52,OLED_POS_H'length));
      OLED_BRIGHTNESS          <= x"32";--x"80";
      MUX_OLED_BRIGHTNESS      <= x"32";--x"80";
      MUX_OLED_BRIGHTNESS_MAP  <= x"80";
      OLED_CONTRAST            <= x"32";--x"80";
      MUX_OLED_CONTRAST        <= x"32";--x"80";
      MUX_OLED_BRIGHTNESS_MAP  <= x"80";
      OLED_IDRF                <= x"35";
      OLED_DIMCTL              <= x"69";
      OLED_IMG_FLIP            <= x"00";  --x"70";
      OLED_IMG_H_FLIP          <= x"C1";
      OLED_CATHODE_VOLTAGE     <= x"FA";
      OLED_ROW_START_MSB       <= x"02";
      OLED_ROW_START_LSB       <= x"D7";
      OLED_ROW_END_MSB         <= x"00";
      OLED_ROW_END_LSB         <= x"08";
      toggle_osd_flip          <= '0';
      toggle_osd_flip_d        <= '0';
      osd_flip_update_done     <= '0';
      apply_osd_flip_time_cnt  <= (others=>'0');
      LASER_EN                 <= '0';
      MUX_LASER_EN             <= '0'; 
      LASER_EN_VALID           <= '0';
      MAX_VGN_SETTLE_TIME      <= x"32";
      MAX_OLED_VGN_RD_PERIOD   <= x"0384";
      MAX_BAT_PARAM_RD_PERIOD  <= x"01a4";
      OLED_POS_V_VALID         <= '0';
      OLED_POS_H_VALID         <= '0';
      OLED_BRIGHTNESS_VALID    <= '0';
      OLED_CONTRAST_VALID      <= '0';
      OLED_IDRF_VALID          <= '0';
      OLED_DIMCTL_VALID        <= '0';
      OLED_IMG_FLIP_VALID      <= '0';
      OLED_IMG_H_FLIP_VALID    <= '0';
      OLED_CATHODE_VOLTAGE_VALID<= '0';
      OLED_ROW_START_MSB_VALID <= '0';
      OLED_ROW_START_LSB_VALID <= '0';
      OLED_ROW_END_MSB_VALID   <= '0';
      OLED_ROW_END_LSB_VALID   <= '0';
      OLED_ROW_START_MSB_VALID_D  <= '0';
      OLED_ROW_START_LSB_VALID_D  <= '0';
      OLED_ROW_END_MSB_VALID_D    <= '0';
      OLED_ROW_END_LSB_VALID_D    <= '0';
      OLED_ROW_START_LSB_VALID_DD <= '0';
      OLED_ROW_END_MSB_VALID_DD   <= '0';
      OLED_ROW_END_LSB_VALID_DD   <= '0';
      OLED_ROW_END_MSB_VALID_DDD  <= '0';
      OLED_ROW_END_LSB_VALID_DDD  <= '0';
      OLED_ROW_END_LSB_VALID_DDDD <= '0';       
      ENABLE_TP                <= '0' ;
      ENABLE_NUC               <= '1' ;
      APPLY_NUC1ptCalib2       <= '0' ;
      ENABLE_SNUC              <= '0' ;
      ENABLE_BADPIXREM         <= '1' ;
      blind_badpix_remove_en   <= '0' ;
--      POLARITY                 <= '0' ;
      ENABLE_SHARPENING_FILTER <= '1' ;
      ENABLE_SMOOTHING_FILTER  <= '0' ;
      ENABLE_EDGE_FILTER_VALID <= '0' ;
      ENABLE_ZOOM              <= '1' ;
      ENABLE_BRIGHT_CONTRAST   <= '1' ;
      ENABLE_CP                <= '0' ;
      ENABLE_LOGO              <= '1' ;
      ENABLE_RETICLE           <= '0' ;
      ENABLE_RETICLE_VALID     <= '0' ;
      PAL_nNTSC                <= '1' ;  
      ENABLE_EDGE_FILTER       <= '0';     
      NUC1pt_Capture_Frames    <= x"5"; 
      THRESHOLD_SOBL           <= x"03";
      BPC_TH                   <= x"0032";


      NUC1PT_CTRL_REG     <= (others => '0');   
--      FPGA_VERSION_REG    <= x"00000003"; -- to release new firmware, increase this reg value by 1
      FPGA_VERSION_REG    <= x"00_E4_00_02"; -- 00= Shutterless calib 04 = for trap MIPI --01 = Emagine Oled Mono display (ARJUN)-- 00 reserved -- 00 revision
      FPGA_RDDATA         <= (others => '0');
--      Clip_Threshold      <= STD_LOGIC_VECTOR(to_unsigned(Clip_Threshold_Init_Value, Clip_Threshold'length));--x"0076c";
--      MIN_PIXEL_COUNT_PER <= std_logic_vector(to_unsigned(10,MIN_PIXEL_COUNT_PER'length));
--      MAX_PIXEL_COUNT_PER <= std_logic_vector(to_unsigned(990,MAX_PIXEL_COUNT_PER'length));
      OFFSET_TBALE_FORCE          <= (others=>'0');
      MAX_LIMITER_DPHE            <=  std_logic_vector(to_unsigned(10,MAX_LIMITER_DPHE'length));
      MAX_LIMITER_DPHE_VALID      <= '0';
      MUL_MAX_LIMITER_DPHE        <=  std_logic_vector(to_unsigned(2,MUL_MAX_LIMITER_DPHE'length));
      MUL_MAX_LIMITER_DPHE_VALID  <= '0';
      CNTRL_MIN_DPHE              <=  std_logic_vector(to_unsigned(10,CNTRL_MIN_DPHE'length));            
      CNTRL_MAX_DPHE              <=  std_logic_vector(to_unsigned(950,CNTRL_MAX_DPHE'length));            
      CNTRL_HIST1_DPHE            <=  std_logic_vector(to_unsigned(5,CNTRL_HIST1_DPHE'length));          
      CNTRL_HIST2_DPHE            <=  std_logic_vector(to_unsigned(10,CNTRL_HIST2_DPHE'length));             
      CNTRL_CLIP_DPHE             <=  std_logic_vector(to_unsigned(25,CNTRL_CLIP_DPHE'length));  
      CNTRL_IPP                   <=  std_logic_vector(to_unsigned(50,CNTRL_IPP'length)); 
      CNTRL_IPP_VALID             <= '0';
      CNTRL_MAX_GAIN              <=  std_logic_vector(to_unsigned(19,CNTRL_MAX_GAIN'length)); 
      CNTRL_MAX_GAIN_VALID        <= '0';
      CNTRL_MIN_HISTEQ            <=  std_logic_vector(to_unsigned(1,CNTRL_MIN_HISTEQ'length));
      CNTRL_MAX_HISTEQ            <=  std_logic_vector(to_unsigned(99,CNTRL_MAX_HISTEQ'length));
      CNTRL_HISTORY_HISTEQ        <=  std_logic_vector(to_unsigned(25,CNTRL_HISTORY_HISTEQ'length));
      MUX_MAX_LIMITER_DPHE        <=  std_logic_vector(to_unsigned(10,MUX_MAX_LIMITER_DPHE'length));
      MUX_MUL_MAX_LIMITER_DPHE    <=  std_logic_vector(to_unsigned(2,MUX_MAX_LIMITER_DPHE'length));
      MUX_CNTRL_IPP               <=  std_logic_vector(to_unsigned(50,MUX_CNTRL_IPP'length)); 
      MUX_CNTRL_MAX_GAIN          <=  std_logic_vector(to_unsigned(19,MUX_CNTRL_MAX_GAIN'length)); 
      MAX_LIMITER_DPHE_MUL        <=  std_logic_vector(to_unsigned(500,MAX_LIMITER_DPHE_MUL'length)); 
      MULTIPLIER_MAX_LIMITER_DPHE <=  std_logic_vector(to_unsigned(100,MULTIPLIER_MAX_LIMITER_DPHE'length)); 
      CNTRL_MAX_GAIN_MUL          <=  std_logic_vector(to_unsigned(12160,CNTRL_MAX_GAIN_MUL'length)); 
      CNTRL_IPP_MUL               <=  std_logic_vector(to_unsigned(50,CNTRL_IPP_MUL'length)); 
   
      NUC1pt_Capture_Frames       <= x"5";  
      THRESHOLD_SOBL              <= x"03";
      ALPHA                       <= x"20"; 
      OSD_MODE                    <= x"0";
      OSD_TIMEOUT                 <= x"0bb8";
      OSD_COLOR_INFO              <= x"508080";
      OSD_CH_COLOR_INFO1          <= x"EB8080";
      OSD_CH_COLOR_INFO2          <= x"108080";
      CURSOR_COLOR_INFO           <= x"EB8080";
--      CURSOR_POS                <= x"0";
      OSD_POS_X_LY1_MODE1         <= std_logic_vector(to_unsigned(200,OSD_POS_X_LY1_MODE1'length));--std_logic_vector(to_unsigned( 50,OSD_POS_X_LY1_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY1_MODE1         <= std_logic_vector(to_unsigned(240,OSD_POS_Y_LY1_MODE1'length));--std_logic_vector(to_unsigned(208,OSD_POS_Y_LY1_MODE1'length)); 
      OSD_POS_X_LY2_MODE1         <= std_logic_vector(to_unsigned(270,OSD_POS_X_LY2_MODE1'length));--std_logic_vector(to_unsigned( 50,OSD_POS_X_LY2_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY2_MODE1         <= std_logic_vector(to_unsigned(380,OSD_POS_Y_LY2_MODE1'length));--std_logic_vector(to_unsigned(360,OSD_POS_Y_LY2_MODE1'length)); 
      OSD_POS_X_LY3_MODE1         <= std_logic_vector(to_unsigned(270,OSD_POS_X_LY3_MODE1'length));--std_logic_vector(to_unsigned( 50,OSD_POS_X_LY3_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY3_MODE1         <= std_logic_vector(to_unsigned(380,OSD_POS_Y_LY3_MODE1'length));--std_logic_vector(to_unsigned(360,OSD_POS_Y_LY3_MODE1'length)); 
      OSD_POS_X_LY1_MODE1_PN      <= std_logic_vector(to_unsigned(288,OSD_POS_X_LY1_MODE1_PN'length)); --std_logic_vector(to_unsigned( 50,OSD_POS_X_LY1_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY1_MODE1_PN      <= std_logic_vector(to_unsigned(170,OSD_POS_Y_LY1_MODE1_PN'length)); --std_logic_vector(to_unsigned(208,OSD_POS_Y_LY1_MODE1'length)); 
      OSD_POS_X_LY2_MODE1_PN      <= std_logic_vector(to_unsigned(288,OSD_POS_X_LY2_MODE1_PN'length)); --std_logic_vector(to_unsigned( 50,OSD_POS_X_LY2_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY2_MODE1_PN      <= std_logic_vector(to_unsigned(170,OSD_POS_Y_LY2_MODE1_PN'length)); --std_logic_vector(to_unsigned(360,OSD_POS_Y_LY2_MODE1'length)); 
      OSD_POS_X_LY3_MODE1_PN      <= std_logic_vector(to_unsigned(288,OSD_POS_X_LY3_MODE1_PN'length)); --std_logic_vector(to_unsigned( 50,OSD_POS_X_LY3_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY3_MODE1_PN      <= std_logic_vector(to_unsigned(170,OSD_POS_Y_LY3_MODE1_PN'length)); --std_logic_vector(to_unsigned(360,OSD_POS_Y_LY3_MODE1'length)); 
      OSD_POS_X_LY1_MODE2         <= std_logic_vector(to_unsigned(50,OSD_POS_X_LY1_MODE2'length));--std_logic_vector(to_unsigned(295,OSD_POS_X_LY1_MODE2'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY1_MODE2         <= std_logic_vector(to_unsigned(240,OSD_POS_Y_LY1_MODE2'length));--std_logic_vector(to_unsigned(208,OSD_POS_Y_LY1_MODE2'length)); 
      OSD_POS_X_LY2_MODE2         <= std_logic_vector(to_unsigned(120,OSD_POS_X_LY2_MODE2'length));--std_logic_vector(to_unsigned(174,OSD_POS_X_LY2_MODE2'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY2_MODE2         <= std_logic_vector(to_unsigned(380,OSD_POS_Y_LY2_MODE2'length));--std_logic_vector(to_unsigned(360,OSD_POS_Y_LY2_MODE2'length)); 
      OSD_POS_X_LY3_MODE2         <= std_logic_vector(to_unsigned(120,OSD_POS_X_LY3_MODE2'length));--std_logic_vector(to_unsigned(278,OSD_POS_X_LY3_MODE2'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY3_MODE2         <= std_logic_vector(to_unsigned(380,OSD_POS_Y_LY3_MODE2'length));--std_logic_vector(to_unsigned(360,OSD_POS_Y_LY3_MODE2'length)); 
      OSD_POS_X_LY1_MODE2_PN      <= std_logic_vector(to_unsigned(188,OSD_POS_X_LY1_MODE2_PN'length));--std_logic_vector(to_unsigned(295,OSD_POS_X_LY1_MODE2'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY1_MODE2_PN      <= std_logic_vector(to_unsigned(170,OSD_POS_Y_LY1_MODE2_PN'length));--std_logic_vector(to_unsigned(208,OSD_POS_Y_LY1_MODE2'length)); 
      OSD_POS_X_LY2_MODE2_PN      <= std_logic_vector(to_unsigned(188,OSD_POS_X_LY2_MODE2_PN'length));--std_logic_vector(to_unsigned(174,OSD_POS_X_LY2_MODE2'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY2_MODE2_PN      <= std_logic_vector(to_unsigned(170,OSD_POS_Y_LY2_MODE2_PN'length));--std_logic_vector(to_unsigned(360,OSD_POS_Y_LY2_MODE2'length)); 
      OSD_POS_X_LY3_MODE2_PN      <= std_logic_vector(to_unsigned(188,OSD_POS_X_LY3_MODE2_PN'length));--std_logic_vector(to_unsigned(278,OSD_POS_X_LY3_MODE2'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OSD_POS_Y_LY3_MODE2_PN      <= std_logic_vector(to_unsigned(170,OSD_POS_Y_LY3_MODE2_PN'length));--std_logic_vector(to_unsigned(360,OSD_POS_Y_LY3_MODE2'length)); 

      OLED_OSD_POS_X_LY1          <= std_logic_vector(to_unsigned(38,OLED_OSD_POS_X_LY1'length));--std_logic_vector(to_unsigned( 50,OSD_POS_X_LY1_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      OLED_OSD_POS_Y_LY1          <= std_logic_vector(to_unsigned(480,OLED_OSD_POS_Y_LY1'length));--std_logic_vector(to_unsigned(208,OSD_POS_Y_LY1_MODE1'length));
      OLED_OSD_POS_X_LY1_PN       <= std_logic_vector(to_unsigned(38,OLED_OSD_POS_X_LY1_PN'length));       
      OLED_OSD_POS_Y_LY1_PN       <= std_logic_vector(to_unsigned(384,OLED_OSD_POS_Y_LY1_PN'length));
--      OLED_OSD_POS_X_LY1          <= std_logic_vector(to_unsigned(200,OSD_POS_X_LY1'length));--std_logic_vector(to_unsigned( 50,OSD_POS_X_LY1_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
--      OLED_OSD_POS_Y_LY1          <= std_logic_vector(to_unsigned(480,OSD_POS_Y_LY1'length));--std_logic_vector(to_unsigned(208,OSD_POS_Y_LY1_MODE1'length));  
      BPR_OSD_POS_X_LY1           <= std_logic_vector(to_unsigned(38,BPR_OSD_POS_X_LY1'length));--std_logic_vector(to_unsigned( 50,OSD_POS_X_LY1_MODE1'length)); --std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      BPR_OSD_POS_Y_LY1           <= std_logic_vector(to_unsigned(530,BPR_OSD_POS_Y_LY1'length));--std_logic_vector(to_unsigned(208,OSD_POS_Y_LY1_MODE1'length));
      BPR_OSD_POS_X_LY1_PN        <= std_logic_vector(to_unsigned(38,BPR_OSD_POS_X_LY1_PN'length));        
      BPR_OSD_POS_Y_LY1_PN        <= std_logic_vector(to_unsigned(434,BPR_OSD_POS_Y_LY1_PN'length));
      GYRO_DATA_DISP_POS_X_LY1    <= std_logic_vector(to_unsigned(645,GYRO_DATA_DISP_POS_X_LY1'length));
      GYRO_DATA_DISP_POS_Y_LY1    <= std_logic_vector(to_unsigned(50,GYRO_DATA_DISP_POS_Y_LY1'length));
      GYRO_DATA_DISP_POS_X_LY1_PN <= std_logic_vector(to_unsigned(645,GYRO_DATA_DISP_POS_X_LY1_PN'length));
      GYRO_DATA_DISP_POS_Y_LY1_PN <= std_logic_vector(to_unsigned(50 ,GYRO_DATA_DISP_POS_Y_LY1_PN'length));
      GYRO_DATA_DISP_POS_X_LY2    <= std_logic_vector(to_unsigned(292,GYRO_DATA_DISP_POS_X_LY2'length));
      GYRO_DATA_DISP_POS_Y_LY2    <= std_logic_vector(to_unsigned(50 ,GYRO_DATA_DISP_POS_Y_LY2'length));
      GYRO_DATA_DISP_POS_X_LY2_PN <= std_logic_vector(to_unsigned(645,GYRO_DATA_DISP_POS_X_LY2_PN'length));
      GYRO_DATA_DISP_POS_Y_LY2_PN <= std_logic_vector(to_unsigned(50 ,GYRO_DATA_DISP_POS_Y_LY2_PN'length));
      
      INFO_DISP_POS_X             <= std_logic_vector(to_unsigned(292,INFO_DISP_POS_X'length));--std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      INFO_DISP_POS_Y             <= std_logic_vector(to_unsigned(508,INFO_DISP_POS_Y'length));
      INFO_DISP_POS_X_PN          <= std_logic_vector(to_unsigned(80,INFO_DISP_POS_X_PN'length));        
      INFO_DISP_POS_Y_PN          <= std_logic_vector(to_unsigned(4,INFO_DISP_POS_Y_PN'length));
      CONTRAST_MODE_INFO_DISP_POS_X<= std_logic_vector(to_unsigned(300,CONTRAST_MODE_INFO_DISP_POS_X'length));
      CONTRAST_MODE_INFO_DISP_POS_Y<= std_logic_vector(to_unsigned(332,CONTRAST_MODE_INFO_DISP_POS_Y'length));    
      CONTRAST_MODE_INFO_DISP_POS_X_PN<= std_logic_vector(to_unsigned(300,CONTRAST_MODE_INFO_DISP_POS_X_PN'length));
      CONTRAST_MODE_INFO_DISP_POS_Y_PN<= std_logic_vector(to_unsigned(236,CONTRAST_MODE_INFO_DISP_POS_Y_PN'length));   
      SN_INFO_DISP_POS_X          <= std_logic_vector(to_unsigned(64,SN_INFO_DISP_POS_X'length));--std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      SN_INFO_DISP_POS_Y          <= std_logic_vector(to_unsigned(390,SN_INFO_DISP_POS_Y'length));
      SN_INFO_DISP_POS_X_PN       <= std_logic_vector(to_unsigned(64,SN_INFO_DISP_POS_X_PN'length));--std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      SN_INFO_DISP_POS_Y_PN       <= std_logic_vector(to_unsigned(294,SN_INFO_DISP_POS_Y_PN'length));
      PRESET_INFO_DISP_POS_X      <= std_logic_vector(to_unsigned(645,PRESET_INFO_DISP_POS_X'length));--std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      PRESET_INFO_DISP_POS_Y      <= std_logic_vector(to_unsigned(50,PRESET_INFO_DISP_POS_Y'length));
      PRESET_INFO_DISP_POS_X_PN   <= std_logic_vector(to_unsigned(645,PRESET_INFO_DISP_POS_X_PN'length));--std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
      PRESET_INFO_DISP_POS_Y_PN   <= std_logic_vector(to_unsigned(2,PRESET_INFO_DISP_POS_Y_PN'length));
      INFO_DISP_COLOR_INFO        <= x"108080";
      INFO_DISP_CH_COLOR_INFO1    <= x"EB8080";
      INFO_DISP_CH_COLOR_INFO2    <= x"508080";
      ENABLE_INFO_DISP            <= '0'; 
      ENABLE_SN_INFO_DISP         <= '0';
      ENABLE_PRESET_INFO_DISP     <= '0';
      ENABLE_BATTERY_DISP         <= '0';
      ENABLE_BAT_PER_DISP         <= '0';
      ENABLE_BAT_CHG_SYMBOL       <= '0';
--      BATTERY_PERCENTAGE          <= x"32";
      BATTERY_DISP_TG_WAIT_FRAMES <= x"10";
      BATTERY_PIX_MAP             <= x"02";
      BATTERY_CHARGING_START      <= '0';
      BATTERY_CHARGE_INC          <= x"c009"; -- LSB INTERVAL , MSB INC STEP SIZE
      BATTERY_DISP_POS_X          <= std_logic_vector(to_unsigned(580,BATTERY_DISP_POS_X'length));
      BATTERY_DISP_POS_Y          <= std_logic_vector(to_unsigned( 58,BATTERY_DISP_POS_Y'length));
      BATTERY_DISP_POS_X_PN       <= std_logic_vector(to_unsigned(580,BATTERY_DISP_POS_X_PN'length));
      BATTERY_DISP_POS_Y_PN       <= std_logic_vector(to_unsigned( 10,BATTERY_DISP_POS_Y_PN'length));
      BATTERY_DISP_REQ_XSIZE      <= std_logic_vector(to_unsigned( 50,BATTERY_DISP_REQ_XSIZE 'length));
      BATTERY_DISP_REQ_YSIZE      <= std_logic_vector(to_unsigned( 16,BATTERY_DISP_REQ_YSIZE 'length));
      BATTERY_DISP_COLOR_INFO     <= x"508080";
      BATTERY_DISP_CH_COLOR_INFO1 <= x"EB8080";
      BATTERY_DISP_CH_COLOR_INFO2 <= x"108080";
      BATTERY_DISP_X_OFFSET       <= std_logic_vector(to_unsigned(4,BATTERY_DISP_X_OFFSET 'length));
      BATTERY_DISP_Y_OFFSET       <= std_logic_vector(to_unsigned(4,BATTERY_DISP_Y_OFFSET 'length));
      BAT_PER_DISP_POS_X          <= std_logic_vector(to_unsigned(592,BAT_PER_DISP_POS_X'length));
      BAT_PER_DISP_POS_Y          <= std_logic_vector(to_unsigned( 62,BAT_PER_DISP_POS_Y'length));
      BAT_PER_DISP_POS_X_PN       <= std_logic_vector(to_unsigned(592,BAT_PER_DISP_POS_X_PN'length));
      BAT_PER_DISP_POS_Y_PN       <= std_logic_vector(to_unsigned( 14,BAT_PER_DISP_POS_Y_PN'length));
      BAT_PER_DISP_REQ_XSIZE      <= std_logic_vector(to_unsigned( 60,BAT_PER_DISP_REQ_XSIZE 'length));
      BAT_PER_DISP_REQ_YSIZE      <= std_logic_vector(to_unsigned(  8,BAT_PER_DISP_REQ_YSIZE 'length));
      BAT_PER_CONV_REG1           <= x"648000";
      BAT_PER_CONV_REG2           <= x"4B8888";
      BAT_PER_CONV_REG3           <= x"328CCD";
      BAT_PER_CONV_REG4           <= x"199555";
      BAT_PER_CONV_REG5           <= x"0A9DDE";
      BAT_PER_CONV_REG6           <= x"05A666";
      BAT_PER_DISP_COLOR_INFO     <= x"358080";
      BAT_PER_DISP_CH_COLOR_INFO1 <= x"EB8080";
      BAT_PER_DISP_CH_COLOR_INFO2 <= x"108080";

      BAT_CHG_SYMBOL_POS_OFFSET   <= std_logic_vector(to_unsigned(12,BAT_CHG_SYMBOL_POS_OFFSET'length));      
      ENABLE_BAT_PER_DISP        <= '0';
      ENABLE_BAT_CHG_SYMBOL      <= '0';
      ENABLE_B_BAR_DISP          <= '0';
      ENABLE_C_BAR_DISP          <= '0';
      B_BAR_DISP_POS_X           <= std_logic_vector(to_unsigned(260,B_BAR_DISP_POS_X'length));
      B_BAR_DISP_POS_Y           <= std_logic_vector(to_unsigned(232,B_BAR_DISP_POS_Y'length));
      B_BAR_DISP_POS_X_PN        <= std_logic_vector(to_unsigned(260,B_BAR_DISP_POS_X_PN'length));
      B_BAR_DISP_POS_Y_PN        <= std_logic_vector(to_unsigned(184,B_BAR_DISP_POS_Y_PN'length));
      B_BAR_DISP_REQ_XSIZE       <= std_logic_vector(to_unsigned( 12,B_BAR_DISP_REQ_XSIZE 'length));
      B_BAR_DISP_REQ_YSIZE       <= std_logic_vector(to_unsigned(130,B_BAR_DISP_REQ_YSIZE 'length));
      B_BAR_DISP_X_OFFSET        <= std_logic_vector(to_unsigned(  0,B_BAR_DISP_X_OFFSET 'length));
      B_BAR_DISP_Y_OFFSET        <= std_logic_vector(to_unsigned(  0,B_BAR_DISP_Y_OFFSET 'length));      
      C_BAR_DISP_POS_X           <= std_logic_vector(to_unsigned(302,C_BAR_DISP_POS_X'length));
      C_BAR_DISP_POS_Y           <= std_logic_vector(to_unsigned(400,C_BAR_DISP_POS_Y'length));
      C_BAR_DISP_POS_X_PN        <= std_logic_vector(to_unsigned(302,C_BAR_DISP_POS_X_PN'length));
      C_BAR_DISP_POS_Y_PN        <= std_logic_vector(to_unsigned(352,C_BAR_DISP_POS_Y_PN'length));
      C_BAR_DISP_REQ_XSIZE       <= std_logic_vector(to_unsigned(130,C_BAR_DISP_REQ_XSIZE 'length));
      C_BAR_DISP_REQ_YSIZE       <= std_logic_vector(to_unsigned( 12,C_BAR_DISP_REQ_YSIZE 'length));
      C_BAR_DISP_X_OFFSET        <= std_logic_vector(to_unsigned(  0,C_BAR_DISP_X_OFFSET 'length));
      C_BAR_DISP_Y_OFFSET        <= std_logic_vector(to_unsigned(  0,C_BAR_DISP_Y_OFFSET 'length)); 
      CB_BAR_DISP_COLOR_INFO     <= x"EB8080";
--      CB_BAR_DISP_CH_COLOR_INFO1 <= x"EB8080";
--      CB_BAR_DISP_CH_COLOR_INFO2 <= x"108080";
      FIRING_MODE                 <= '0';
      FIRING_MODE_VALID           <= '0';
      MUX_FIRING_MODE             <= '0';
      DISTANCE_SEL                <= std_logic_vector(to_unsigned(  0,DISTANCE_SEL'length)); 
      DISTANCE_SEL_VALID          <= '0';
      MUX_DISTANCE_SEL_VALID      <= '0';
      MUX_DISTANCE_SEL            <= std_logic_vector(to_unsigned(  0,DISTANCE_SEL'length)); 
      RETICLE_COLOR_SEL           <= std_logic_vector(to_unsigned(  0,RETICLE_COLOR_SEL'length)); 
      RETICLE_COLOR_SEL_VALID     <= '0';
      MUX_RETICLE_COLOR_SEL       <= std_logic_vector(to_unsigned(  0,RETICLE_COLOR_SEL'length)); 
      RETICLE_COLOR_TH            <= x"8F71";
      COLOR_SEL_WINDOW_XSIZE      <= std_logic_vector(to_unsigned(16,COLOR_SEL_WINDOW_XSIZE 'length));
      COLOR_SEL_WINDOW_YSIZE      <= std_logic_vector(to_unsigned(16,COLOR_SEL_WINDOW_YSIZE 'length));
      RETICLE_COLOR_INFO1         <= x"EB8080"; 
      RETICLE_COLOR_INFO2         <= x"108080"; --x"00EB8080"
      RETICLE_POS_YX              <= x"0ef13f";--x"11f165";
      RETICLE_POS_YX_VALID        <= '0';
--      RETICLE_POS_X               <= std_logic_vector(to_unsigned(357,RETICLE_POS_X'length));--std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
--      RETICLE_POS_X_VALID         <= '0';
--      RETICLE_POS_Y               <= std_logic_vector(to_unsigned(287,RETICLE_POS_Y'length));--std_logic_vector(to_unsigned(180,RETICLE_POS_Y'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_YSIZE/2,RETICLE_POS_Y'length));  
--      RETICLE_POS_Y_VALID         <= '0';
      PRESET_SEL                  <= x"0";       
      PRESET_SEL_VALID            <= '0';
      PRESET_P1_POS               <= x"0ef13f";  --- lower 12 bit horz pos ,upper 12 bit vert pos
      PRESET_P1_POS_VALID         <= '0';
      PRESET_P2_POS               <= x"0ef1cd";  --- lower 12 bit horz pos ,upper 12 bit vert pos
      PRESET_P2_POS_VALID         <= '0';
      PRESET_P3_POS               <= x"16b13f";  --- lower 12 bit horz pos ,upper 12 bit vert pos
      PRESET_P3_POS_VALID         <= '0';
      PRESET_P4_POS               <= x"0ef0b0";  --- lower 12 bit horz pos ,upper 12 bit vert pos
      PRESET_P4_POS_VALID         <= '0';

      LOGO_COLOR_INFO1            <= x"EB8080"; 
      LOGO_COLOR_INFO2            <= x"52f05a"; --x"108080";
      LOGO_POS_X                  <= std_logic_vector(to_unsigned(44,LOGO_POS_X'length)); --std_logic_vector(to_unsigned(16,LOGO_POS_X'length));        
      LOGO_POS_Y                  <= std_logic_vector(to_unsigned(550,LOGO_POS_Y'length)); --std_logic_vector(to_unsigned(540,LOGO_POS_Y'length)); 
      LOGO_POS_X_PN               <= std_logic_vector(to_unsigned(16,LOGO_POS_X_PN'length));
      LOGO_POS_Y_PN               <= std_logic_vector(to_unsigned(502,LOGO_POS_Y_PN'length));  
      ZOOM_MODE                   <= "000";
      BRIGHTNESS                  <= std_logic_vector(to_unsigned(5,BRIGHTNESS'length));--std_logic_vector(to_unsigned(15,BRIGHTNESS'length)); --std_logic_vector(to_unsigned(30,BRIGHTNESS'length));
      BRIGHTNESS_VALID            <= '0';  
      BRIGHTNESS_OFFSET           <= std_logic_vector(to_unsigned(35,BRIGHTNESS_OFFSET'length)); --std_logic_vector(to_unsigned(20,BRIGHTNESS'length));
      CONTRAST                    <= std_logic_vector(to_unsigned(5,BRIGHTNESS'length));--std_logic_vector(to_unsigned(15,CONTRAST'length));  --std_logic_vector(to_unsigned(30,CONTRAST'length));
      CONTRAST_VALID              <= '0';
      CONTRAST_OFFSET             <= std_logic_vector(to_unsigned(35,CONTRAST_OFFSET'length)); --std_logic_vector(to_unsigned(20,CONTRAST'length));
      CONSTANT_CB_CR              <= x"8080";
      AGC_MODE_SEL                <= "00";
      AGC_MODE_SEL_VALID          <= '0';
      ZOOM_MODE_VALID             <= '0';
      POLARITY                    <= "00";
      POLARITY_VALID              <= '0';
      BH_OFFSET                   <= std_logic_vector(to_unsigned(100,BH_OFFSET'length));--std_logic_vector(to_unsigned(30,BH_OFFSET'length));
      GAIN_TABLE_SEL              <= '0'; 
--      sel_temp_range           <= '0';
--      sel_temp_range_en        <= '0';
      force_temp_range            <= "000";
      force_temp_range_en         <= '0'; 

--      AV_KERN_ADDR_SFILT       <= x"00";
--      DDE_SEL                  <= x"0";
--      DDE_SEL_VALID             <= '0';  
--      VIDEO_IN_MUX              <= '0'; 
      ENABLE_SNUC_VALID              <= '0';
      ENABLE_SMOOTHING_FILTER_VALID  <= '0';
      ENABLE_SHARPENING_FILTER_VALID <= '0';
      ENABLE_LOGO_VALID         <= '0';
      CP_TYPE                   <= "00000";
      CP_TYPE_VALID        <= '0';
      ENABLE_BRIGHT_CONTRAST    <= '1';
--      ENABLE_SMOOTH_FILTER             <= '0';
--      VIDEO_OUT_MUX             <= '0';
      RETICLE_TYPE              <= x"0";  
      RETICLE_SEL               <= x"0";
      RETICLE_TYPE_VALID        <= '0';
      cp_min_value              <= x"00";
      cp_max_value              <= x"ff";
--      IMG_SHIFT_LR_UPDATE <= '0';
--      IMG_SHIFT_UD_UPDATE <= '0';
--      IMG_SHIFT_LR_SEL         <= '0';
--      IMG_SHIFT_LR             <= std_logic_vector(to_unsigned(0,IMG_SHIFT_LR'length));
--      IMG_SHIFT_UD_SEL         <= '0';
--      IMG_SHIFT_UD             <= std_logic_vector(to_unsigned(0,IMG_SHIFT_UD'length));
      IMG_UP_SHIFT_VERT        <= std_logic_vector(to_unsigned(0,IMG_UP_SHIFT_VERT'length));   
      IMG_SHIFT_VERT           <= std_logic_vector(to_unsigned(0,IMG_SHIFT_VERT'length));   
      IMG_SHIFT_VERT_VALID     <= '0';
      MUX_IMG_SHIFT_VERT       <= std_logic_vector(to_unsigned(0,MUX_IMG_SHIFT_VERT'length)); 
      IMG_CROP_LEFT            <= std_logic_vector(to_unsigned(0,IMG_CROP_LEFT'length));   
      IMG_CROP_RIGHT           <= std_logic_vector(to_unsigned(0,IMG_CROP_RIGHT'length));   
      IMG_CROP_TOP             <= std_logic_vector(to_unsigned(0,IMG_CROP_TOP'length));   
      IMG_CROP_BOTTOM          <= std_logic_vector(to_unsigned(0,IMG_CROP_BOTTOM'length));   
      fit_to_screen_en         <= '0';
      scaling_disable          <= '0';
      mux_scaling_disable      <= '0';
      fit_to_screen_en_valid   <= '0';
      scaling_disable_valid    <= '0';
      mux_fit_to_screen_en     <= '0';

      roi_x_offset             <= std_logic_vector(to_unsigned(0,roi_x_offset'length));
      roi_y_offset             <= std_logic_vector(to_unsigned(0,roi_y_offset'length));
      roi_x_size               <= std_logic_vector(to_unsigned(VIDEO_XSIZE,roi_x_size'length));
      roi_y_size               <= std_logic_vector(to_unsigned(VIDEO_YSIZE,roi_y_size'length));
      max_gain                 <= x"40";
      roi_mode                 <= '0';       
      IMG_FLIP_H               <= '0';
      IMG_FLIP_V               <= '0';
      Start_GAINCalib          <= '0';
      Start_NUC1ptCalib        <= '0';
      START_NUC1PTCALIB_VALID  <= '0';
      APPLY_NUC1ptCalib        <= '0';--'0';
      gain_enable              <= '0';
      MENU_SEL_CENTER_U        <= '0';
      MENU_SEL_LEFT_U          <= '0';
      MENU_SEL_RIGHT_U         <= '0';
      MENU_SEL_UP_U            <= '0';
      MENU_SEL_DN_U            <= '0';      
      MENU_SEL_CENTER           <= '0';
      MENU_SEL_LEFT             <= '0';
      MENU_SEL_RIGHT            <= '0';
      MENU_SEL_UP               <= '0';
      MENU_SEL_DN               <= '0';  
      OLED_MENU_EN              <= '0'; 
      BPR_MENU_EN               <= '0';    
      
--      exclude_right            <= x"02";
--      exclude_left             <= x"00";     
--      restart_sensor           <= '0';  
      Img_Min_Limit            <= std_logic_vector(to_unsigned(0,Img_Min_Limit'length));
      Img_Max_Limit            <= std_logic_vector(to_unsigned(16383,Img_Max_Limit'length));    
      update_device_id_reg     <= x"12345678";--(others => '0');  
--      update_device_id_reg_en  <= '0';

      user_settings_mem_wr_addr <= (others => '0');
      user_settings_mem_wr_data <= (others => '0');
      user_settings_mem_wr_req  <= '0';
      user_settings_mem_rd_req  <= '0';
      user_settings_mem_rd_addr <= (others => '0');  
      user_settings_st          <= s_user_settings_idle; 


      rd_count                 <= (others => '0');     
      
      MUX_ZOOM_MODE            <=  "000"; 
      MUX_AGC_MODE_SEL         <=  "00";       
      MUX_BRIGHTNESS           <=  std_logic_vector(to_unsigned(5,MUX_BRIGHTNESS'length));           
      MUX_CONTRAST             <=  std_logic_vector(to_unsigned(5,MUX_CONTRAST'length));                     
      MUX_RETICLE_TYPE         <=  x"0";  
      MUX_RETICLE_POS_YX       <=  x"0ef13f";--x"11f165";   
--      MUX_RETICLE_POS_X        <=  std_logic_vector(to_unsigned(357,RETICLE_POS_X'length)); 
--      MUX_RETICLE_POS_Y        <=  std_logic_vector(to_unsigned(287,RETICLE_POS_X'length));  
      MUX_RETICLE_SEL          <=  x"0"; 
      MUX_POLARITY             <=  "00";      
--        MUX_DDE_SEL              <=  x"0";    
      MUX_SHARPNESS            <=  x"0";
      MUX_ENABLE_SNUC          <=  '0';
      MUX_ENABLE_SMOOTHING     <=  '0';
      MUX_ENABLE_EDGE          <=  '0';
      MUX_CP_TYPE              <=  "00000"; 
      MUX_ENABLE_LOGO          <=  '1';
      PAL_nNTSC_SEL_DONE       <=  '0'; 
--      OLED_REG_DATA            <=  x"00";
      OLED_POS_V_VALID         <=  '0';
      OLED_POS_H_VALID         <=  '0';
      OLED_BRIGHTNESS_VALID    <=  '0';
      OLED_CONTRAST_VALID      <=  '0';
      OLED_IDRF_VALID          <=  '0';
      OLED_DIMCTL_VALID        <=  '0';  
      OLED_IMG_FLIP_VALID      <= '0';  
      OLED_CATHODE_VOLTAGE_VALID <= '0';
      OLED_GAMMA_TABLE_SEL_VALID <= '0';
      user_settings_init_done  <=  '0'; 
--      main_menu_sel            <=  '0';
--      ADVANCE_MENU_TRIG_IN_REG <=  '0';     
      av_wr_sharp_edge         <=  '0';
      av_addr_sharp_edge       <=  x"00";
      av_data_sharp_edge       <=  x"0000";
      av_wr_blur               <=  '0';
      av_addr_blur             <=  x"00";
      av_data_blur             <=  x"0000";
      SHARPNESS                <=  x"0";
      SHARPNESS_VALID          <=  '0';
      MAX_RELEASE_WAIT_TIME    <= x"0c8";
      MIN_TIME_GAP_PRESS_RELEASE<= x"01e";
      MAX_UP_DOWN_PRESS_TIME   <= x"0bb8";
      MAX_MENU_DOWN_PRESS_TIME <= x"07d0";
      LONG_PRESS_STEP_SIZE     <= x"020";
      MAX_PRESET_SAVE_OK_DISP_FRAMES <= x"280a"; --  MSB - SAVE DISPLAY FRAMES , LSB -OK DISPLAY FRAMES 
      OLED_DISP_EN_TIME_GAP    <= x"0bb8";
      BPR_DISP_EN_TIME_GAP     <= x"0bb8";
      MUX_OLED_POS_V_VALID     <= '0';
      MUX_OLED_POS_H_VALID     <= '0';
      MUX_OLED_DIMCTL_VALID    <= '0';
      MUX_OLED_BRIGHTNESS_VALID    <= '0';
      MUX_OLED_BRIGHTNESS_MAP_VALID<= '0';
      MUX_OLED_CONTRAST_VALID      <= '0'; 
      MUX_OLED_CONTRAST_MAP_VALID  <= '0'; 
      MUX_OLED_DIMCTL          <= x"69";
      MUX_OLED_GAMMA_TABLE_SEL <= x"00";
      MUX_OLED_POS_H           <= std_logic_vector(to_unsigned(52,MUX_OLED_POS_H'length));
      MUX_OLED_POS_V           <= x"18";
      I2C_DELAY_REG            <= std_logic_vector(to_unsigned(0,I2C_DELAY_REG'length)); 
      FRAME_COUNTER_NUC1PT_DELAY <= std_logic_vector(to_unsigned(0,FRAME_COUNTER_NUC1PT_DELAY'length));  
      AUTO_SHUTTER_TIMEOUT       <= std_logic_vector(to_unsigned(120,AUTO_SHUTTER_TIMEOUT'length)); 
      RETICLE_SEL_EN           <= '0';
      RETICLE_SAVE_USER_SETTINGS <= '0';
      apply_nuc1pt_time_cnt    <= x"0000";
      NUC_TIME_GAP             <= std_logic_vector(to_unsigned(3000,NUC_TIME_GAP'length));  
--      nuc_hot_key_control_st   <= s_idle;
      toggle_nuc1pt            <= '0';
      OLED_VGN_TEST            <= (others=>'0');
      AGC_MODE_INFO_DISP_EN       <= '0';
      agc_mode_info_disp_time_cnt <= (others=>'0');
      MAX_AGC_MODE_INFO_DISP_TIME <=  std_logic_vector(to_unsigned(1000,MAX_AGC_MODE_INFO_DISP_TIME'length));
      BT656_XSIZE <= std_logic_Vector(to_unsigned(716,BT656_XSIZE'length));
      BT656_YSIZE <= std_logic_Vector(to_unsigned(576,BT656_YSIZE'length));
      product_sel <= '0';
      sel_oled_analog_video_out <= '0';
      sel_oled_analog_video_out_valid <= '0';
      sel_oled_analog_video_out_done <= '0';
      display_mode_force_sel_done  <= '0';
      SIGHT_MODE_VALID <='0';
      SIGHT_MODE       <= "00";
      DISPLAY_MODE_SAVE_USER_SETTINGS <= '0';
      bat_adc_en  <= '0';
      parallel_16bit_en       <= '0';
      shutter_en              <= '0';
      lens_shutter_en         <= '0';
      force_analog_video_out  <= '0';
      mipi_video_data_out_sel <= '0';
      usb_video_data_out_sel_reg <= '0';
      spi_mode    <= "00";
      OSD_START_NUC1PTCALIB_D <= '0';
      SATURATED_PIX_TH <= std_logic_Vector(to_unsigned(16250,SATURATED_PIX_TH'length));
      DARK_PIX_TH      <= std_logic_Vector(to_unsigned(133,DARK_PIX_TH'length));
      BAD_BLIND_PIX_LOW_TH  <= std_logic_Vector(to_unsigned(1000,BAD_BLIND_PIX_LOW_TH'length));
      BAD_BLIND_PIX_HIGH_TH <= std_logic_Vector(to_unsigned(13000,BAD_BLIND_PIX_HIGH_TH'length));
      update_coarse_offset_write <= '0';
      update_coarse_offset_address <= x"0";
      update_coarse_offset_writedata <= (others=>'0'); 
      snap_img_avg_write <= '0';
      snap_img_avg_address <= x"0";
      snap_img_avg_writedata <= (others=>'0'); 
      TARGET_VALUE_THRESHOLD <= std_logic_Vector(to_unsigned(1000,TARGET_VALUE_THRESHOLD'length));
      select_co_bus <= '0';
      temp_range_update_timeout <= std_logic_Vector(to_unsigned(120,temp_range_update_timeout'length));
      GYRO_DATA_UPDATE_TIMEOUT  <= std_logic_Vector(to_unsigned(500,GYRO_DATA_UPDATE_TIMEOUT'length)); 
      GYRO_DATA_DISP_EN         <= '0';
      GYRO_DATA_DISP_EN_VALID   <= '0';
      GYRO_DATA_DISP_MODE       <= '0';
      MUX_GYRO_DATA_DISP_EN     <= '0';
      burst_capture_size        <= std_logic_Vector(to_unsigned(64,burst_capture_size'length));
      CMD_STANDBY_EN            <= '0';
--      cmd_adv_sleep_mode_en     <= '0';
--      cmd_oled_reinit_en        <= '0';
--      CMD_OLED_RESET            <= '0'; 
      lo_to_hi_area_global_offset_force_val <= std_logic_Vector(to_unsigned(41660,lo_to_hi_area_global_offset_force_val'length));
      hi_to_lo_area_global_offset_force_val <= std_logic_Vector(to_unsigned(46360,hi_to_lo_area_global_offset_force_val'length));
      temperature_threshold                 <= std_logic_vector(to_unsigned(150,temperature_threshold 'length));
      sub_add_temp_offset                   <= '0';
      temperature_offset                    <= std_logic_vector(to_unsigned(0,temperature_offset 'length));
      NUC_MODE                              <= "00";
      BLADE_MODE                            <= "00";  
      NUC_MODE_VALID                        <= '0'; 
      BLADE_MODE_VALID                      <= '0';   
      MUX_NUC_MODE                          <= "00";
      MUX_NUC_MODE_VALID                    <= '0';
      MUX_BLADE_MODE                        <= "00"; 
--      IN_X_OFF                              <= std_logic_vector(to_unsigned(0,IN_X_OFF 'length));
--      IN_Y_OFF                              <= std_logic_vector(to_unsigned(0,IN_Y_OFF 'length));
      yaw_offset                            <= std_logic_vector(to_unsigned(62,yaw_offset 'length));
      pitch_offset                          <= std_logic_vector(to_unsigned( 6,pitch_offset 'length));
      WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE <= std_logic_vector(to_unsigned(12,WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE 'length));
      GYRO_CALIB_EN                         <= '0';
      GYRO_CALIB_STATUS                     <= '0';
      MUX_GYRO_CALIB_EN                     <= '0';
    elsif rising_edge(CLK) then
--        cmd_adv_sleep_mode_en <= '0';
--        cmd_oled_reinit_en    <= '0';
        GYRO_CALIB_EN               <= '0';
        NUC_MODE_VALID              <= '0';
        MUX_NUC_MODE_VALID          <= '0'; 
        BLADE_MODE_VALID            <= '0';   
        MAX_LIMITER_DPHE_VALID      <= '0';
        MUL_MAX_LIMITER_DPHE_VALID  <= '0';
        CNTRL_MAX_GAIN_VALID        <= '0';
        CNTRL_IPP_VALID             <= '0';
        toggle_osd_flip_d <= toggle_osd_flip;
        OSD_START_NUC1PTCALIB_D <= OSD_START_NUC1PTCALIB;
        START_NUC1PTCALIB_VALID <= '0';
        FPGA_RDDAV <= '0';
        GYRO_DATA_DISP_EN_VALID <= '0';
        fit_to_screen_en_valid   <= '0';
        scaling_disable_valid    <= '0';
        LASER_EN_VALID      <= '0';        
        ZOOM_MODE_VALID     <= '0';
        AGC_MODE_SEL_VALID  <= '0';
        BRIGHTNESS_VALID    <= '0';
        CONTRAST_VALID      <= '0';
        RETICLE_TYPE_VALID  <= '0';
        RETICLE_POS_YX_VALID<= '0';
--        RETICLE_POS_X_VALID <= '0';
--        RETICLE_POS_Y_VALID <= '0';
        RETICLE_SEL_VALID   <= '0';
        PRESET_SEL_VALID <= '0';
        PRESET_P1_POS_VALID <= '0';
        PRESET_P2_POS_VALID <= '0';
        PRESET_P3_POS_VALID <= '0';
        PRESET_P4_POS_VALID <= '0';


        POLARITY_VALID      <= '0';
        ENABLE_LOGO_VALID   <= '0';
        ENABLE_RETICLE_VALID<= '0'; 
        RETICLE_COLOR_SEL_VALID <= '0';
        FIRING_MODE_VALID   <= '0';
        DISTANCE_SEL_VALID  <= '0';
        MUX_DISTANCE_SEL_VALID <= '0';
        ENABLE_SNUC_VALID   <= '0';
        CP_TYPE_VALID       <= '0';
        SHARPNESS_VALID     <=  '0';

        AV_KERN_WR_SFILT    <= '0'; 
--        IMG_SHIFT_LR_UPDATE <= '0';
--        IMG_SHIFT_UD_UPDATE <= '0';
        Start_GAINCalib          <= '0';
        Start_NUC1ptCalib        <= '0';
        Start_NUC1ptCalib2       <= '0';
        gain_enable              <= '0';
--        restart_sensor           <= '0';
--        RETICLE_CENTER_EN        <= '0';
--        update_device_id_reg_en  <= '0';
        user_settings_mem_wr_req <= '0';
        MENU_SEL_CENTER_U        <= '0';
        MENU_SEL_LEFT_U          <= '0';
        MENU_SEL_RIGHT_U         <= '0';
        MENU_SEL_UP_U            <= '0';
        MENU_SEL_DN_U            <= '0';
        MENU_SEL_UP              <= '0';
        MENU_SEL_DN              <= '0';
        MENU_SEL_LEFT            <= '0';
        MENU_SEL_RIGHT           <= '0';
        MENU_SEL_CENTER          <= '0';
        OLED_MENU_EN             <= '0'; 
        BPR_MENU_EN              <= '0';  
--        ADVANCE_MENU_TRIG_IN_REG <= '0';      
        IMG_SHIFT_VERT_VALID       <= '0';
        OLED_GAMMA_TABLE_SEL_VALID <= '0';
        OLED_POS_V_VALID         <= '0';
        MUX_OLED_POS_V_VALID     <= '0';
        OLED_POS_H_VALID         <= '0';
        MUX_OLED_POS_H_VALID     <= '0';
        OLED_BRIGHTNESS_VALID    <= '0';
        OLED_CONTRAST_VALID      <= '0';
        OLED_IDRF_VALID          <= '0';
        OLED_DIMCTL_VALID        <= '0';
        OLED_IMG_FLIP_VALID      <= '0';   
        OLED_IMG_H_FLIP_VALID    <= '0';
        OLED_CATHODE_VOLTAGE_VALID <= '0';
        OLED_ROW_START_MSB_VALID <= '0';
        OLED_ROW_START_LSB_VALID <= '0';  
        OLED_ROW_END_MSB_VALID   <= '0';  
        OLED_ROW_END_LSB_VALID   <= '0';  
        MUX_OLED_DIMCTL_VALID    <= '0'; 
        MUX_OLED_BRIGHTNESS_VALID<= '0';   
        MUX_OLED_CONTRAST_VALID  <= '0'; 
        av_wr_sharp_edge         <= '0';
        av_wr_blur               <= '0';  
        ENABLE_SHARPENING_FILTER_VALID <= '0';
        ENABLE_SMOOTHING_FILTER_VALID  <= '0';
        ENABLE_EDGE_FILTER_VALID       <= '0' ; 
        RETICLE_SAVE_USER_SETTINGS     <= '0';
        update_coarse_offset_write <= '0';
        snap_img_avg_write  <= '0';
        sel_oled_analog_video_out_valid <= '0';
        DISPLAY_MODE_SAVE_USER_SETTINGS  <= '0';
        SIGHT_MODE_VALID <= '0';
        MUX_SIGHT_MODE_VALID <= '0';


      case user_settings_st is
        when s_user_settings_idle =>             
            if(user_settings_init_start = '1')then
                user_settings_st           <= s_user_settings_init_mem_rd;
            else
                user_settings_st <= s_user_settings_idle;
            end if;
            user_settings_mem_rd_req <= '0';  
            rd_count                 <= (others => '0'); 
            user_settings_init_done  <= '0';   
           
        when s_user_settings_init_mem_rd => 
            if(rd_count = 256) then
                user_settings_st          <= s_user_settings_idle;
                user_settings_mem_rd_req  <= '0';
                user_settings_mem_rd_addr <= (others=>'0');
                user_settings_init_done   <= '1'; --1 cycle pulse to indicate user setting init done 
            else
                user_settings_mem_rd_req  <= '1';
                user_settings_mem_rd_addr <= std_logic_vector(rd_count(7 downto 0));  
                user_settings_st          <= s_user_settings_mem_rd_wait; 
            end if;
        when s_user_settings_mem_rd_wait =>  
            user_settings_mem_rd_req <= '0';
            rd_count                 <= rd_count + 1;  
            user_settings_st         <= s_user_settings_reg_init; 
        when s_user_settings_reg_init => 
            user_settings_st  <= s_user_settings_init_mem_rd;
            
            case user_settings_mem_rd_data(31 downto 24) is 

                 when SET_PAL_NTSC_MODE =>
                    PAL_nNTSC              <= user_settings_mem_rd_data(0);
                    if(user_settings_mem_rd_data(0)='1')then
--                        BT656_XSIZE <= std_logic_Vector(to_unsigned(716,BT656_XSIZE'length));
--                        BT656_YSIZE <= std_logic_Vector(to_unsigned(576,BT656_YSIZE'length));
                          BT656_XSIZE <=std_logic_Vector(to_unsigned(VIDEO_ADD_BORDER_XSIZE_PAL,BT656_XSIZE'length));
                          BT656_YSIZE <=std_logic_Vector(to_unsigned(VIDEO_ADD_BORDER_YSIZE_PAL,BT656_YSIZE'length));
                    else 
--                        BT656_XSIZE <= std_logic_Vector(to_unsigned(716,BT656_XSIZE'length));
--                        BT656_YSIZE <= std_logic_Vector(to_unsigned(480,BT656_YSIZE'length));
                          BT656_XSIZE <=std_logic_Vector(to_unsigned(VIDEO_ADD_BORDER_XSIZE_NTSC,BT656_XSIZE'length));
                          BT656_YSIZE <=std_logic_Vector(to_unsigned(VIDEO_ADD_BORDER_YSIZE_NTSC,BT656_YSIZE'length));
                    end if;
                    PAL_nNTSC_SEL_DONE     <= '1';

                  when SET_IMAGE_WIDTH_FULL =>
                    image_width_full <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                    
                  when SET_TEMP_PIXELS_LEFT_RIGHT =>
                    temp_pixels_right <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                    temp_pixels_left  <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);

                  when SET_EXCLUDE_LEFT_RIGHT =>
                    exclude_right  <= user_settings_mem_rd_data(7 downto 0);
                    exclude_left   <= user_settings_mem_rd_data(7+12 downto 12);    
                                     
                  when SET_PRODUCT_SEL  => 
                    product_sel    <= user_settings_mem_rd_data(0);
--                    sel_raw        <= user_settings_mem_rd_data(1);
                    spi_mode       <= user_settings_mem_rd_data(2 downto 1);
                    bat_adc_en     <= user_settings_mem_rd_data(4);
                    parallel_16bit_en <= user_settings_mem_rd_data(5);
                    shutter_en     <= user_settings_mem_rd_data(6);
                    lens_shutter_en <= user_settings_mem_rd_data(7); 
                    force_analog_video_out <=user_settings_mem_rd_data(8); 
                                     
                  when SET_OLED_ANALOG_VIDEO_OUT_SEL  => 
                    if(sel_oled_analog_video_out_done='0')then
                        sel_oled_analog_video_out          <= user_settings_mem_rd_data(0);
                        sel_oled_analog_video_out_valid    <= '1';
                    end if;
                    sel_oled_analog_video_out_done     <= '1';

                  when SET_LASER_EN =>
                    LASER_EN <= '0';--user_settings_mem_rd_data(0);
                    LASER_EN_VALID <= '1';
                  
                  when SET_SNAPSHOT_BURST_MODE_CAPTURE_SIZE =>
                    burst_capture_size <= user_settings_mem_rd_data(7 downto 0);   
                                               
                  when SET_MIPI_VIDEO_OUT_SEL =>
                    mipi_video_data_out_sel    <= user_settings_mem_rd_data(0);
                    usb_video_data_out_sel_reg <= user_settings_mem_rd_data(1);
  
                  when SET_TEMP_RANGE_UPDATE_TIMEOUT =>
                    temp_range_update_timeout <= user_settings_mem_rd_data(15 downto 0);  

                  when SET_SIGHT_MODE =>
                    SIGHT_MODE       <= user_settings_mem_rd_data(1 downto 0);
                    SIGHT_MODE_VALID <= '1';                    
--                when SET_MODULE_EN_DIS =>
--                     ENABLE_TP                     <= user_settings_mem_rd_data(0);
--                     ENABLE_NUC                    <= user_settings_mem_rd_data(1);
--                     ENABLE_SNUC                   <= user_settings_mem_rd_data(2);
--                     ENABLE_BADPIXREM              <= user_settings_mem_rd_data(3);
--                     POLARITY                      <= user_settings_mem_rd_data(4);
--                     ENABLE_SMOOTHING_FILTER       <= user_settings_mem_rd_data(5);
--                     ENABLE_SMOOTHING_FILTER_VALID <= '1';
--                     ENABLE_SHARPENING_FILTER   <= user_settings_mem_rd_data(6);
----                     ENABLE_SHARPENING_FILTER_VALID <= '1';  
--                     if(user_settings_mem_rd_data(11) = '1')then
--                         av_wr_sharp_edge    <= '1';
--                         av_addr_sharp_edge  <= x"00";
--                         av_data_sharp_edge  <= x"0003";                  
--                         av_wr_blur          <= '1';
--                         av_addr_blur        <= x"00";
--                         av_data_blur        <= x"0001"; 
--                     else
--                         if(user_settings_mem_rd_data(5)='1')then
--                             av_wr_blur          <= '1';
--                             av_addr_blur        <= x"00";
--                             av_data_blur        <= x"0001";                         
--                         end if;
--                         av_wr_sharp_edge    <= '1';
--                         av_addr_sharp_edge  <= x"00";
--                         av_data_sharp_edge  <= x"0001";  
----                         if(user_settings_mem_rd_data(6)='1')then
----                             av_wr_sharp_edge    <= '1';
----                             av_addr_sharp_edge  <= x"00";
----                             av_data_sharp_edge  <= x"0001";                                                   
----                         end if;
--                     end if;    
--                     ENABLE_ZOOM            <= user_settings_mem_rd_data(7);
--                     ENABLE_BRIGHT_CONTRAST <= user_settings_mem_rd_data(8);
----                     ENABLE_CP              <= user_settings_mem_rd_data(9);
--                     ENABLE_LOGO            <= user_settings_mem_rd_data(10);
----                     ENABLE_RETICLE         <= user_settings_mem_rd_data(11);
--                     ENABLE_EDGE_FILTER     <= user_settings_mem_rd_data(11);                                          
--                     PAL_nNTSC              <= user_settings_mem_rd_data(12);
                      
--                     POLARITY_VALID         <= '1';
--                     ENABLE_LOGO_VALID      <= '1';
--                     ENABLE_SNUC_VALID      <= '1';
--                     PAL_nNTSC_SEL_DONE     <= '1';
                 
                      
--                     ENABLE_NUC                    <= user_settings_mem_rd_data(1);
--                     ENABLE_SNUC                   <= user_settings_mem_rd_data(2);
--                     ENABLE_BADPIXREM              <= user_settings_mem_rd_data(3);
--                     POLARITY                      <= user_settings_mem_rd_data(4);                

                    
                 when SET_TEST_PATTERN_EN   => 
                    ENABLE_TP                    <= user_settings_mem_rd_data(0);
                     
                 when SET_NUC_EN            => 
                    ENABLE_NUC                    <= user_settings_mem_rd_data(0);
--                    ENABLE_UNITY_GAIN             <= user_settings_mem_rd_data(1);
                    
                 when SET_SOFTNUC_EN        => 
                    ENABLE_SNUC            <= user_settings_mem_rd_data(0);
                    ENABLE_SNUC_VALID      <= '1';

                 when SET_LOGO_EN           => 
                    ENABLE_LOGO            <= user_settings_mem_rd_data(0); 
                    ENABLE_LOGO_VALID      <= '1';
                 when SET_RETICLE_EN =>  
                    ENABLE_RETICLE            <= user_settings_mem_rd_data(0);   
                    ENABLE_RETICLE_VALID      <= '1';      
                 
                 when SET_BADPIXREM_EN      => 
                    ENABLE_BADPIXREM        <= user_settings_mem_rd_data(0);
                    blind_badpix_remove_en  <= user_settings_mem_rd_data(1);
 
                 when SET_BRIGHT_CONTRAST_EN      => 
                    ENABLE_BRIGHT_CONTRAST  <= user_settings_mem_rd_data(0);

                 when SET_ZOOM_EN =>
                    ENABLE_ZOOM            <= user_settings_mem_rd_data(0);

                 when SET_POLARITY =>
                    POLARITY               <= user_settings_mem_rd_data(1 downto 0);
                    POLARITY_VALID         <= '1';

                 when SET_BH_OFFSET =>
                    BH_OFFSET              <= user_settings_mem_rd_data(7 downto 0);  

                 when SET_SMOOTH_FILTER_EN =>
                    ENABLE_SMOOTHING_FILTER       <= user_settings_mem_rd_data(0);
                    ENABLE_SMOOTHING_FILTER_VALID <= '1';
                    av_wr_blur          <= '1';
                    av_addr_blur        <= x"00";
                    if(user_settings_mem_rd_data(0)='1' or MUX_ENABLE_EDGE = '1')then
                        av_data_blur        <= x"0001";
                    else
                        av_data_blur        <= x"0000"; 
                    end if;    

                 when SET_EDGE_FILTER_EN =>
                    ENABLE_EDGE_FILTER       <= user_settings_mem_rd_data(0);
                    ENABLE_EDGE_FILTER_VALID <= '1';
                    if(user_settings_mem_rd_data(0)='1')then
                         av_wr_sharp_edge    <= '1';
                         av_addr_sharp_edge  <= x"00";
                         av_data_sharp_edge  <= x"0003";                  
                         av_wr_blur          <= '1';
                         av_addr_blur        <= x"00";
                         av_data_blur        <= x"0001"; 
                     else
                         av_wr_sharp_edge    <= '1';
                         av_addr_sharp_edge  <= x"00";
                         av_data_sharp_edge  <= x"0001";  
                         av_wr_blur          <= '1';
                         av_addr_blur        <= x"00";
                         if(MUX_ENABLE_SMOOTHING = '1')then
                            av_data_blur        <= x"0001";
                         else
                            av_data_blur        <= x"0000";
                         end if;                             
                     end if;    

                  when SET_IMG_SHIFT_VERT =>
--                     IMG_SHIFT_VERT     <=  user_settings_mem_rd_data(LIN_BITS-1 downto 0); 
                    if(unsigned(user_settings_mem_rd_data(LIN_BITS-1 downto 0))> 255)then
                       IMG_SHIFT_VERT       <= std_logic_vector(to_unsigned(255,10)); 
                    else
                       IMG_SHIFT_VERT       <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                    end if; 
                    IMG_SHIFT_VERT_VALID<= '1'; 

                  when SET_IMG_UP_SHIFT_VERT =>
                     IMG_UP_SHIFT_VERT     <=  user_settings_mem_rd_data(LIN_BITS-1 downto 0);  
--                     IMG_UP_SHIFT_VERT_VALID<= '1';  
                     
                 when SET_NUC1PT_CAPTURE_FRAMES =>
                     NUC1pt_Capture_Frames  <= user_settings_mem_rd_data(3 downto 0);                     
     
                 when SET_THRESHOLD_SOBL =>
                     THRESHOLD_SOBL <= user_settings_mem_rd_data(7 downto 0);                 
 
                 when SET_BPC_TH  =>
                     BPC_TH <= user_settings_mem_rd_data(15 downto 0);

                 when SET_SHARPNESS  =>                                     
--                     AV_KERN_ADDR_SFILT        <= user_settings_mem_rd_data(23 downto 16); 
--                     AV_KERN_WR_SFILT          <= '1';
--                     AV_KERN_WRDATA_SFILT      <=  x"00" &user_settings_mem_rd_data(15 downto 0);
                     SHARPNESS           <=  user_settings_mem_rd_data(3 downto 0);  
                     SHARPNESS_VALID     <=  '1';
                     av_wr_sharp_edge    <= '1';
                     av_addr_sharp_edge  <= x"02";
                     av_data_sharp_edge  <= x"000" & user_settings_mem_rd_data(3 downto 0); 

                 when SET_EDGE_LEVEL  =>                                     
--                     AV_KERN_ADDR_SFILT        <= user_settings_mem_rd_data(23 downto 16);  
--                     AV_KERN_WR_SFILT          <= '1';
--                     AV_KERN_WRDATA_SFILT      <=  x"00" &user_settings_mem_rd_data(15 downto 0);
                     av_wr_sharp_edge    <= '1';
                     av_addr_sharp_edge  <= x"01";
                     av_data_sharp_edge  <= user_settings_mem_rd_data(15 downto 0); 

                 when SET_OLED_IMG_FLIP =>
                     OLED_IMG_FLIP <= user_settings_mem_rd_data(7 downto 0);

                 when SET_IMG_FLIP =>
                     IMG_FLIP_H <= user_settings_mem_rd_data(0);
                     IMG_FLIP_V <= user_settings_mem_rd_data(1);

                 --when SET_IMG_SHIFT_POS_X =>
                 
                 --when SET_IMG_SHIFT_POS_Y =>

                 when SET_ZOOM_MODE =>
                     ZOOM_MODE      <= user_settings_mem_rd_data(2 downto 0);   
                     ZOOM_MODE_VALID <= '1';               
 
                 when SET_BRIGHTNESS =>
                     BRIGHTNESS <= user_settings_mem_rd_data(7 downto 0); 
                     BRIGHTNESS_VALID <= '1';                
                 
                 when SET_BRIGHTNESS_OFFSET =>
                     BRIGHTNESS_OFFSET <= user_settings_mem_rd_data(7 downto 0);  
 
                 when SET_CONTRAST =>
                     CONTRAST   <= user_settings_mem_rd_data(7 downto 0);
                     CONTRAST_VALID <= '1';

                 when SET_CONSTANT_CB_CR =>                                   
                     CONSTANT_CB_CR <= user_settings_mem_rd_data(15 downto 0); 
                                      
                 when SET_CONTRAST_OFFSET =>
                     CONTRAST_OFFSET <= user_settings_mem_rd_data(7 downto 0); 
                 
                 when SET_COLOR_PALETTE_MODE =>
                     CP_TYPE          <= user_settings_mem_rd_data(4 downto 0);
                     CP_TYPE_VALID <= '1';
                      
                 when SET_CP_MIN_MAX_VAL =>
                     CP_MIN_VALUE <= user_settings_mem_rd_data(7 downto 0);
                     CP_MAX_VALUE <= user_settings_mem_rd_data(23 downto 16);     
                      
                 when SET_LOGO_POS_X  =>  
--                    if(PAL_nNTSC= '1')then 
                    if(sel_oled_analog_video_out = '0')then
                     LOGO_POS_X       <= user_settings_mem_rd_data(10 downto 0);  
                     LOGO_POS_X_PN    <= user_settings_mem_rd_data(10+12 downto 12);        
                    else
                     LOGO_POS_X       <= user_settings_mem_rd_data(10+12 downto 12);  
                     LOGO_POS_X_PN    <= user_settings_mem_rd_data(10 downto 0);     
                    end if;
                 when SET_LOGO_POS_Y =>  
--                    if(PAL_nNTSC= '1')then 
                    if(sel_oled_analog_video_out = '0')then
                     LOGO_POS_Y       <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);  
                     LOGO_POS_Y_PN    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);  
                    else
                     LOGO_POS_Y       <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12); 
                     LOGO_POS_Y_PN    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0); 
                    end if;  
                 when SET_LOGO_COLOR1   =>
                     LOGO_COLOR_INFO1 <=  user_settings_mem_rd_data(23 downto 0);
                 
                 when SET_LOGO_COLOR2   =>
                     LOGO_COLOR_INFO2 <=  user_settings_mem_rd_data(23 downto 0);                        

                 when SET_NUC_MODE   =>
                     NUC_MODE       <=  user_settings_mem_rd_data(1 downto 0);
                     NUC_MODE_VALID <= '1';
                 
                 when SET_BLADE_MODE   =>
                     BLADE_MODE       <=  user_settings_mem_rd_data(1 downto 0); 
                     BLADE_MODE_VALID <= '1';
                     

                 when SET_RETICLE_SEL =>  
                     RETICLE_SEL <= user_settings_mem_rd_data(3 downto 0);
                     RETICLE_SEL_VALID <= '1';
                     
                 when SET_RETICLE_TYPE =>  
                     RETICLE_TYPE       <= user_settings_mem_rd_data(3 downto 0);
                     RETICLE_TYPE_VALID <= '1';
                       
                 when SET_RETICLE_POS_X  =>  
                     RETICLE_POS_YX(11 downto 0) <= "00" & user_settings_mem_rd_data(PIX_BITS-1 downto 0); 
                     RETICLE_POS_YX(23 downto 12)<= "00" & user_settings_mem_rd_data(12+PIX_BITS-1 downto 12); 
                     RETICLE_POS_YX_VALID        <= '1';  
--                     RETICLE_POS_X       <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);  
--                     RETICLE_POS_X_VALID <= '1';      
                 
--                 when SET_RETICLE_POS_Y =>    
--                     RETICLE_POS_Y       <= user_settings_mem_rd_data(LIN_BITS-1 downto 0); 
--                     RETICLE_POS_Y_VALID <= '1';   

                 when SET_RETICLE_COLOR_SEL =>  
                    RETICLE_COLOR_SEL       <= user_settings_mem_rd_data(2 downto 0);   
                    RETICLE_COLOR_SEL_VALID <= '1'; 
                      
                 when SET_RETICLE_COLOR1   =>
                     RETICLE_COLOR_INFO1 <= user_settings_mem_rd_data(23 downto 0);
                 
                 when SET_RETICLE_COLOR2   =>
                     RETICLE_COLOR_INFO2 <= user_settings_mem_rd_data(23 downto 0); 

                 when SET_RETICLE_COLOR_TH =>
                     RETICLE_COLOR_TH    <= user_settings_mem_rd_data(15 downto 0);    

                 when SET_COLOR_SEL_WINDOW_XSIZE =>
                     COLOR_SEL_WINDOW_XSIZE <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);

                 when SET_COLOR_SEL_WINDOW_YSIZE =>
                     COLOR_SEL_WINDOW_YSIZE <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);

                 when SET_FIRING_MODE =>
                     FIRING_MODE       <= user_settings_mem_rd_data(0);  
                     FIRING_MODE_VALID <= '1';

                 when SET_FIRING_DISTANCE =>
                     DISTANCE_SEL       <= user_settings_mem_rd_data(3 downto 0);  
                     DISTANCE_SEL_VALID <= '1';
                                          
                 when SET_PRESET_SEL    => 
                     PRESET_SEL          <= user_settings_mem_rd_data(3 downto 0);   
                     PRESET_SEL_VALID    <= '1';

                 when SET_PRESET_P1_POS => 
                     PRESET_P1_POS       <= user_settings_mem_rd_data(23 downto 0);
                     PRESET_P1_POS_VALID <= '1';                

                 when SET_PRESET_P2_POS => 
                     PRESET_P2_POS       <= user_settings_mem_rd_data(23 downto 0); 
                     PRESET_P2_POS_VALID <= '1';   

                 when SET_PRESET_P3_POS => 
                     PRESET_P3_POS       <= user_settings_mem_rd_data(23 downto 0); 
                     PRESET_P3_POS_VALID <= '1';      

                 when SET_PRESET_P4_POS => 
                     PRESET_P4_POS       <= user_settings_mem_rd_data(23 downto 0);         
                     PRESET_P4_POS_VALID <= '1';

                 when SET_AGC_MODE   => 
                     AGC_MODE_SEL <= user_settings_mem_rd_data(1 downto 0);
                     AGC_MODE_SEL_VALID  <= '1';

                 when SET_AGC_MAX_GAIN =>                                                                              
                     MAX_GAIN     <= user_settings_mem_rd_data(7 downto 0);                            

                 when SET_MAX_LIMITER_DPHE =>
                     MAX_LIMITER_DPHE          <= user_settings_mem_rd_data(7 downto 0);      
                     MAX_LIMITER_DPHE_VALID    <= '1';

                 when SET_MUL_MAX_LIMITER_DPHE =>
                     MUL_MAX_LIMITER_DPHE       <= user_settings_mem_rd_data(7 downto 0);      
                     MUL_MAX_LIMITER_DPHE_VALID <= '1';

                 when SET_CNTRL_MIN_DPHE =>
                     CNTRL_MIN_DPHE            <= user_settings_mem_rd_data(23 downto 0); 
 
                 when SET_CNTRL_MAX_DPHE =>
                     CNTRL_MAX_DPHE            <= user_settings_mem_rd_data(23 downto 0); 
 
                 when SET_CNTRL_HIST1_DPHE =>
                     CNTRL_HIST1_DPHE          <= user_settings_mem_rd_data(23 downto 0);
                 
                 when SET_CNTRL_HIST2_DPHE =>
                     CNTRL_HIST2_DPHE          <= user_settings_mem_rd_data(23 downto 0);  
                 
                 when SET_CNTRL_CLIP_DPHE =>
                     CNTRL_CLIP_DPHE           <= user_settings_mem_rd_data(23 downto 0);  
                        
                 when SET_CNTRL_MIN_HISTEQ =>
                     CNTRL_MIN_HISTEQ          <= user_settings_mem_rd_data(23 downto 0); 
                      
                 when SET_CNTRL_MAX_HISTEQ =>
                     CNTRL_MAX_HISTEQ          <= user_settings_mem_rd_data(23 downto 0);    
                   
                 when SET_CNTRL_HISTORY_HISTEQ =>
                     CNTRL_HISTORY_HISTEQ      <= user_settings_mem_rd_data(23 downto 0); 

                 when SET_CNTRL_MAX_GAIN =>
                     CNTRL_MAX_GAIN            <= user_settings_mem_rd_data(7 downto 0); 
                     CNTRL_MAX_GAIN_VALID      <= '1';

                 when SET_CNTRL_IPP =>
                     CNTRL_IPP                 <= user_settings_mem_rd_data(7 downto 0); 
                     CNTRL_IPP_VALID           <= '1';

                 when SET_ROI_MODE =>                     
                    ROI_MODE        <= user_settings_mem_rd_data(0); 

                 when SET_GYRO_DATA_UPDATE_TIMEOUT =>                     
                    GYRO_DATA_UPDATE_TIMEOUT       <= user_settings_mem_rd_data(15 downto 0);
                                        
                 when SET_GYRO_DATA_DISP_EN =>                     
                    GYRO_DATA_DISP_EN       <= user_settings_mem_rd_data(0);
                    GYRO_DATA_DISP_MODE     <= user_settings_mem_rd_data(1);
                    GYRO_DATA_DISP_EN_VALID <= '1'; 

                 when SET_OLED_GAMMA_TABLE_SEL => 
                   OLED_GAMMA_TABLE_SEL       <= user_settings_mem_rd_data(7 downto 0);
                   OLED_GAMMA_TABLE_SEL_VALID <= '1';
        
                 when SET_OLED_POS_V =>                     
                   OLED_POS_V       <= user_settings_mem_rd_data(7 downto 0); 
--                   OLED_REG_DATA    <= user_settings_mem_rd_data(7 downto 0); 
                   OLED_POS_V_VALID <= '1';
                   
                 when SET_OLED_POS_H =>                     
                   OLED_POS_H       <= user_settings_mem_rd_data(8 downto 0);  
--                   OLED_REG_DATA    <= user_settings_mem_rd_data(7 downto 0); 
                   OLED_POS_H_VALID <= '1';
                            
                 when SET_OLED_BRIGHTNESS =>                     
                   OLED_BRIGHTNESS       <= user_settings_mem_rd_data(7 downto 0);
--                   OLED_REG_DATA         <= user_settings_mem_rd_data(7 downto 0);
                   OLED_BRIGHTNESS_VALID <= '1';
                   
                 when SET_OLED_CONTRAST =>                     
                   OLED_CONTRAST       <= user_settings_mem_rd_data(7 downto 0);
--                   OLED_REG_DATA       <= user_settings_mem_rd_data(7 downto 0);
                   OLED_CONTRAST_VALID <= '1';
                   
                 when SET_OLED_IDRF =>                     
                   OLED_IDRF       <= user_settings_mem_rd_data(7 downto 0);
--                   OLED_REG_DATA   <= user_settings_mem_rd_data(7 downto 0);
                   OLED_IDRF_VALID <= '1';
        
                 when SET_OLED_DIMCTL =>                     
                   OLED_DIMCTL       <= user_settings_mem_rd_data(7 downto 0);
--                   OLED_REG_DATA     <= user_settings_mem_rd_data(7 downto 0);
                   OLED_DIMCTL_VALID <= '1';
--                   MUX_OLED_DIMCTL_VALID <= '1';
--                 when SET_MAX_VGN_SETTLE_TIME =>
--                   MAX_VGN_SETTLE_TIME       <= user_settings_mem_rd_data(7 downto 0);      
                 
                 when SET_OLED_CATHODE_VOLTAGE =>
                   OLED_CATHODE_VOLTAGE       <= user_settings_mem_rd_data(7 downto 0);    
                   OLED_CATHODE_VOLTAGE_VALID <= '1';  
                 when SET_MAX_OLED_VGN_RD_PERIOD =>
                   MAX_OLED_VGN_RD_PERIOD    <= user_settings_mem_rd_data(15 downto 0);                     

                 when SET_MAX_BAT_PARAM_RD_PERIOD =>
                   MAX_BAT_PARAM_RD_PERIOD   <= user_settings_mem_rd_data(15 downto 0);   
                   
--                 when SET_ROI_X_OFFSET    =>
--                     ROI_X_OFFSET <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                                         
--                 when SET_ROI_Y_OFFSET    =>
--                     ROI_Y_OFFSET <=  user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                                       
--                 when SET_ROI_X_SIZE =>
--                     ROI_X_SIZE   <= user_settings_mem_rd_data(PIX_BITS-1 downto 0); 
                                   
--                 when SET_ROI_Y_SIZE =>   
--                     ROI_Y_SIZE   <= user_settings_mem_rd_data(LIN_BITS-1 downto 0); 

                 when  SET_OSD_TIMEOUT =>                       
                       OSD_TIMEOUT          <= user_settings_mem_rd_data(15 downto 0);
        
                 when  SET_OSD_COLOR_INFO =>                       
                       OSD_COLOR_INFO       <= user_settings_mem_rd_data(23 downto 0);
                                
                 when  SET_CURSOR_COLOR_INFO =>
                       CURSOR_COLOR_INFO    <= user_settings_mem_rd_data(23 downto 0);
        
                 when  SET_OSD_CH_COLOR_INFO1 =>                       
                       OSD_CH_COLOR_INFO1   <= user_settings_mem_rd_data(23 downto 0);
        
                 when  SET_OSD_CH_COLOR_INFO2 =>                       
                       OSD_CH_COLOR_INFO2   <= user_settings_mem_rd_data(23 downto 0);   
        
                 when  SET_OSD_MODE =>         
                       OSD_MODE             <= user_settings_mem_rd_data(3 downto 0);
                      
                 when  SET_OSD_POS_X_LY1_MODE1 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_X_LY1_MODE1    <= user_settings_mem_rd_data(10 downto 0);
                        OSD_POS_X_LY1_MODE1_PN <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        OSD_POS_X_LY1_MODE1    <= user_settings_mem_rd_data(10+12 downto 12);
                        OSD_POS_X_LY1_MODE1_PN <= user_settings_mem_rd_data(10 downto 0);
                       end if;
                 when  SET_OSD_POS_Y_LY1_MODE1 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_Y_LY1_MODE1    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        OSD_POS_Y_LY1_MODE1_PN <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        OSD_POS_Y_LY1_MODE1    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        OSD_POS_Y_LY1_MODE1_PN <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if;
                 when  SET_OSD_POS_X_LY2_MODE1 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_X_LY2_MODE1    <= user_settings_mem_rd_data(10 downto 0);
                        OSD_POS_X_LY2_MODE1_PN <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        OSD_POS_X_LY2_MODE1    <= user_settings_mem_rd_data(10+12 downto 12);
                        OSD_POS_X_LY2_MODE1_PN <= user_settings_mem_rd_data(10 downto 0);
                       end if;
                 when  SET_OSD_POS_Y_LY2_MODE1 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_Y_LY2_MODE1    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        OSD_POS_Y_LY2_MODE1_PN <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        OSD_POS_Y_LY2_MODE1    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        OSD_POS_Y_LY2_MODE1_PN <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if;
        
                 when  SET_OSD_POS_X_LY3_MODE1 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_X_LY3_MODE1    <= user_settings_mem_rd_data(10 downto 0);
                        OSD_POS_X_LY3_MODE1_PN <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        OSD_POS_X_LY3_MODE1    <= user_settings_mem_rd_data(10+12 downto 12);
                        OSD_POS_X_LY3_MODE1_PN <= user_settings_mem_rd_data(10 downto 0);
                       end if; 
                 
                 when  SET_OSD_POS_Y_LY3_MODE1 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_Y_LY3_MODE1    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        OSD_POS_Y_LY3_MODE1_PN <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        OSD_POS_Y_LY3_MODE1    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        OSD_POS_Y_LY3_MODE1_PN <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if; 
        
                 when  SET_OSD_POS_X_LY1_MODE2 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_X_LY1_MODE2    <= user_settings_mem_rd_data(10 downto 0);
                        OSD_POS_X_LY1_MODE2_PN <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        OSD_POS_X_LY1_MODE2    <= user_settings_mem_rd_data(10+12 downto 12);
                        OSD_POS_X_LY1_MODE2_PN <= user_settings_mem_rd_data(10 downto 0);
                       end if;
                 when  SET_OSD_POS_Y_LY1_MODE2 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_Y_LY1_MODE2    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        OSD_POS_Y_LY1_MODE2_PN <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        OSD_POS_Y_LY1_MODE2    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        OSD_POS_Y_LY1_MODE2_PN <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if; 
                       
                 when  SET_OSD_POS_X_LY2_MODE2 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_X_LY2_MODE2    <= user_settings_mem_rd_data(10 downto 0);
                        OSD_POS_X_LY2_MODE2_PN <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        OSD_POS_X_LY2_MODE2    <= user_settings_mem_rd_data(10+12 downto 12);
                        OSD_POS_X_LY2_MODE2_PN <= user_settings_mem_rd_data(10 downto 0);
                       end if; 
                 
                 when  SET_OSD_POS_Y_LY2_MODE2 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_Y_LY2_MODE2    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        OSD_POS_Y_LY2_MODE2_PN <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        OSD_POS_Y_LY2_MODE2    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        OSD_POS_Y_LY2_MODE2_PN <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if; 
        
                 when  SET_OSD_POS_X_LY3_MODE2 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_X_LY3_MODE2    <= user_settings_mem_rd_data(10 downto 0);
                        OSD_POS_X_LY3_MODE2_PN <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        OSD_POS_X_LY3_MODE2    <= user_settings_mem_rd_data(10+12 downto 12);
                        OSD_POS_X_LY3_MODE2_PN <= user_settings_mem_rd_data(10 downto 0);
                       end if; 
                 
                 when  SET_OSD_POS_Y_LY3_MODE2 =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OSD_POS_Y_LY3_MODE2    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        OSD_POS_Y_LY3_MODE2_PN <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        OSD_POS_Y_LY3_MODE2    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        OSD_POS_Y_LY3_MODE2_PN <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if; 
                 
                 when SET_TEMPERATURE_OFFSET  =>
                       temperature_offset <= user_settings_mem_rd_data(15 downto 0);
                       sub_add_temp_offset<= user_settings_mem_rd_data(16);
                       
                 when SET_TEMPERATURE_THRESHOLD =>
                       temperature_threshold <= user_settings_mem_rd_data(15 downto 0);
                 
                 when   SET_LO_TO_HI_AREA_GLOBAL_OFFSET_FORCE_VAL =>
                       lo_to_hi_area_global_offset_force_val <= user_settings_mem_rd_data(15 downto 0);
                 
                 when   SET_HI_TO_LO_AREA_GLOBAL_OFFSET_FORCE_VAL =>
                       hi_to_lo_area_global_offset_force_val <= user_settings_mem_rd_data(15 downto 0);
                
                 when  SET_ENABLE_SN_INFO_DISP =>
                       ENABLE_SN_INFO_DISP   <= user_settings_mem_rd_data(0);

                 when  SET_ENABLE_INFO_DISP =>
                       ENABLE_INFO_DISP     <= user_settings_mem_rd_data(0);
                 
                 when  SET_ENABLE_PRESET_INFO_DISP =>
                       ENABLE_PRESET_INFO_DISP     <= user_settings_mem_rd_data(0);
        
                 when  SET_INFO_DISP_COLOR_INFO =>
                       INFO_DISP_COLOR_INFO <= user_settings_mem_rd_data(23 downto 0);
        
                 when  SET_INFO_DISP_CH_COLOR_INFO1 =>                       
                       INFO_DISP_CH_COLOR_INFO1 <= user_settings_mem_rd_data(23 downto 0);
        
                 when  SET_INFO_DISP_CH_COLOR_INFO2 =>                       
                       INFO_DISP_CH_COLOR_INFO2 <= user_settings_mem_rd_data(23 downto 0);    
                       
                 when  SET_INFO_DISP_POS_X =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        INFO_DISP_POS_X     <= user_settings_mem_rd_data(10 downto 0);
                        INFO_DISP_POS_X_PN  <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        INFO_DISP_POS_X     <= user_settings_mem_rd_data(10+12 downto 12);
                        INFO_DISP_POS_X_PN  <= user_settings_mem_rd_data(10 downto 0);
                       end if;  
                 when  SET_INFO_DISP_POS_Y =>
 --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        INFO_DISP_POS_Y     <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        INFO_DISP_POS_Y_PN  <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        INFO_DISP_POS_Y     <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        INFO_DISP_POS_Y_PN  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if;    
                 when  SET_SN_INFO_DISP_POS_X =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        SN_INFO_DISP_POS_X     <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                        SN_INFO_DISP_POS_X_PN  <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                       else
                        SN_INFO_DISP_POS_X     <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                        SN_INFO_DISP_POS_X_PN  <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                       end if;
                 when  SET_SN_INFO_DISP_POS_Y =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        SN_INFO_DISP_POS_Y     <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        SN_INFO_DISP_POS_Y_PN  <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        SN_INFO_DISP_POS_Y     <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        SN_INFO_DISP_POS_Y_PN  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if;
                 when  SET_PRESET_INFO_DISP_POS_X =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        PRESET_INFO_DISP_POS_X     <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                        PRESET_INFO_DISP_POS_X_PN  <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                       else
                        PRESET_INFO_DISP_POS_X     <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                        PRESET_INFO_DISP_POS_X_PN  <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                       end if;
                 when  SET_PRESET_INFO_DISP_POS_Y =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        PRESET_INFO_DISP_POS_Y     <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        PRESET_INFO_DISP_POS_Y_PN  <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        PRESET_INFO_DISP_POS_Y     <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        PRESET_INFO_DISP_POS_Y_PN  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if; 

                 when  SET_CONTRAST_MODE_INFO_DISP_POS_X =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        CONTRAST_MODE_INFO_DISP_POS_X     <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                        CONTRAST_MODE_INFO_DISP_POS_X_PN  <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                       else
                        CONTRAST_MODE_INFO_DISP_POS_X     <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                        CONTRAST_MODE_INFO_DISP_POS_X_PN  <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                       end if;
                       
                 when  SET_CONTRAST_MODE_INFO_DISP_POS_Y =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        CONTRAST_MODE_INFO_DISP_POS_Y     <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        CONTRAST_MODE_INFO_DISP_POS_Y_PN  <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        CONTRAST_MODE_INFO_DISP_POS_Y     <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        CONTRAST_MODE_INFO_DISP_POS_Y_PN  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if;
                 when  SET_ENABLE_BATTERY_DISP =>
                       ENABLE_BATTERY_DISP <= user_settings_mem_rd_data(0);
        
--                 when  SET_BATTERY_PERCENTAGE =>
--                       BATTERY_PERCENTAGE  <= user_settings_mem_rd_data(7 downto 0);
                 when  SET_BATTERY_DISP_TG_WAIT_FRAMES =>
                         BATTERY_DISP_TG_WAIT_FRAMES <= user_settings_mem_rd_data(7 downto 0);
                 
                 when  SET_BATTERY_PIX_MAP =>
                       BATTERY_PIX_MAP     <= user_settings_mem_rd_data(7 downto 0);

                 when  SET_BATTERY_CHARGE_INC =>
                       BATTERY_CHARGE_INC        <= user_settings_mem_rd_data(15 downto 0);                                              
 
                  when SET_TARGET_VALUE_THRESHOLD =>
                       TARGET_VALUE_THRESHOLD    <= user_settings_mem_rd_data(15 downto 0);
        
                 when  SET_BATTERY_DISP_COLOR_INFO =>
                       BATTERY_DISP_COLOR_INFO      <= user_settings_mem_rd_data(23 downto 0);
        
                 when  SET_BATTERY_DISP_CH_COLOR_INFO1 =>                       
                       BATTERY_DISP_CH_COLOR_INFO1  <= user_settings_mem_rd_data(23 downto 0);
        
                 when  SET_BATTERY_DISP_CH_COLOR_INFO2 =>                       
                       BATTERY_DISP_CH_COLOR_INFO2  <= user_settings_mem_rd_data(23 downto 0);  
                       
                 when  SET_BATTERY_DISP_POS_X =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        BATTERY_DISP_POS_X      <= user_settings_mem_rd_data(10 downto 0);
                        BATTERY_DISP_POS_X_PN   <= user_settings_mem_rd_data(10+12 downto 12);                     
                       else
                        BATTERY_DISP_POS_X      <= user_settings_mem_rd_data(10+12 downto 12);
                        BATTERY_DISP_POS_X_PN   <= user_settings_mem_rd_data(10 downto 0);
                       end if;
                 when  SET_BATTERY_DISP_POS_Y =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        BATTERY_DISP_POS_Y      <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        BATTERY_DISP_POS_Y_PN   <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        BATTERY_DISP_POS_Y      <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        BATTERY_DISP_POS_Y_PN   <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if; 
                        
                 when  SET_BATTERY_DISP_REQ_XSIZE =>
                       BATTERY_DISP_REQ_XSIZE  <= user_settings_mem_rd_data(10 downto 0);
                 
                 when  SET_BATTERY_DISP_REQ_YSIZE =>
                       BATTERY_DISP_REQ_YSIZE  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       
                 when  SET_BATTERY_DISP_X_OFFSET=>
                       BATTERY_DISP_X_OFFSET  <= user_settings_mem_rd_data(10 downto 0);
                 
                 when  SET_BATTERY_DISP_Y_OFFSET =>
                       BATTERY_DISP_Y_OFFSET  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);

                 when  SET_ENABLE_BAT_PER_DISP =>
                       ENABLE_BAT_PER_DISP       <= user_settings_mem_rd_data(0);

                 when  SET_BAT_PER_DISP_COLOR_INFO =>
                       BAT_PER_DISP_COLOR_INFO   <= user_settings_mem_rd_data(23 downto 0);
        
                 when  SET_BAT_PER_DISP_CH_COLOR_INFO1 =>                       
                       BAT_PER_DISP_CH_COLOR_INFO1 <= user_settings_mem_rd_data(23 downto 0);
        
                 when  SET_BAT_PER_DISP_CH_COLOR_INFO2 =>                       
                       BAT_PER_DISP_CH_COLOR_INFO2 <= user_settings_mem_rd_data(23 downto 0);  
        
                 when  SET_BAT_PER_DISP_POS_X =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        BAT_PER_DISP_POS_X        <= user_settings_mem_rd_data(10 downto 0);
                        BAT_PER_DISP_POS_X_PN     <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        BAT_PER_DISP_POS_X        <= user_settings_mem_rd_data(10+12 downto 12);
                        BAT_PER_DISP_POS_X_PN     <= user_settings_mem_rd_data(10 downto 0);
                       end if; 
                 when  SET_BAT_PER_DISP_POS_Y =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        BAT_PER_DISP_POS_Y        <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);   
                        BAT_PER_DISP_POS_Y_PN     <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        BAT_PER_DISP_POS_Y        <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);  
                        BAT_PER_DISP_POS_Y_PN     <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);    
                       end if; 
                 when  SET_BAT_PER_DISP_REQ_XSIZE =>
                       BAT_PER_DISP_REQ_XSIZE    <= user_settings_mem_rd_data(10 downto 0); 
        
                 when  SET_BAT_PER_DISP_REQ_YSIZE =>
                       BAT_PER_DISP_REQ_YSIZE    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
        
                 when  SET_ENABLE_BAT_CHG_SYMBOL =>
                       ENABLE_BAT_CHG_SYMBOL     <= user_settings_mem_rd_data(0);
        
                 when  SET_BAT_CHG_SYMBOL_POS_OFFSET =>
                       BAT_CHG_SYMBOL_POS_OFFSET <= user_settings_mem_rd_data(11 downto 0);

                 when  SET_BAT_PER_CONV_REG1 =>
                       BAT_PER_CONV_REG1 <= user_settings_mem_rd_data(23 downto 0);

                 when  SET_BAT_PER_CONV_REG2 =>
                       BAT_PER_CONV_REG2 <= user_settings_mem_rd_data(23 downto 0);                

                 when  SET_BAT_PER_CONV_REG3 =>
                       BAT_PER_CONV_REG3 <= user_settings_mem_rd_data(23 downto 0);

                 when  SET_BAT_PER_CONV_REG4 =>
                       BAT_PER_CONV_REG4 <= user_settings_mem_rd_data(23 downto 0);

                 when  SET_BAT_PER_CONV_REG5 =>
                       BAT_PER_CONV_REG5 <= user_settings_mem_rd_data(23 downto 0);                                              

                 when  SET_BAT_PER_CONV_REG6 =>
                       BAT_PER_CONV_REG6 <= user_settings_mem_rd_data(23 downto 0);
                       
                 when  SET_OLED_OSD_POS_X_LY1 =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OLED_OSD_POS_X_LY1        <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                        OLED_OSD_POS_X_LY1_PN     <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                       else
                        OLED_OSD_POS_X_LY1        <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                        OLED_OSD_POS_X_LY1_PN     <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                       end if; 
                 when  SET_OLED_OSD_POS_Y_LY1 =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        OLED_OSD_POS_Y_LY1        <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        OLED_OSD_POS_Y_LY1_PN     <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        OLED_OSD_POS_Y_LY1        <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        OLED_OSD_POS_Y_LY1_PN     <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if;  
 
                 when  SET_BPR_OSD_POS_X_LY1 =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        BPR_OSD_POS_X_LY1        <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                        BPR_OSD_POS_X_LY1_PN     <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                       else
                        BPR_OSD_POS_X_LY1        <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                        BPR_OSD_POS_X_LY1_PN     <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                       end if; 
        
                 when  SET_BPR_OSD_POS_Y_LY1 =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        BPR_OSD_POS_Y_LY1        <= user_settings_mem_rd_data(LIN_BITS-1 downto 0); 
                        BPR_OSD_POS_Y_LY1_PN     <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12); 
                       else
                        BPR_OSD_POS_Y_LY1        <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12); 
                        BPR_OSD_POS_Y_LY1_PN     <= user_settings_mem_rd_data(LIN_BITS-1 downto 0); 
                       end if; 
--                 when  SET_IMG_Y_OFFSET =>
--                        IN_Y_OFF        <= user_settings_mem_rd_data(9 downto 0); 

                 when  SET_GYRO_DATA_DISP_POS_X_LY1 =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        GYRO_DATA_DISP_POS_X_LY1    <= user_settings_mem_rd_data(10 downto 0);
                        GYRO_DATA_DISP_POS_X_LY1_PN <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        GYRO_DATA_DISP_POS_X_LY1    <= user_settings_mem_rd_data(10+12 downto 12);
                        GYRO_DATA_DISP_POS_X_LY1_PN <= user_settings_mem_rd_data(10 downto 0);
                       end if; 
        
                 when  SET_GYRO_DATA_DISP_POS_Y_LY1 =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        GYRO_DATA_DISP_POS_Y_LY1    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        GYRO_DATA_DISP_POS_Y_LY1_PN <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        GYRO_DATA_DISP_POS_Y_LY1    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        GYRO_DATA_DISP_POS_Y_LY1_PN <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if; 

                 when  SET_GYRO_DATA_DISP_POS_X_LY2 =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        GYRO_DATA_DISP_POS_X_LY2    <= user_settings_mem_rd_data(10 downto 0);
                        GYRO_DATA_DISP_POS_X_LY2_PN <= user_settings_mem_rd_data(10+12 downto 12);
                       else
                        GYRO_DATA_DISP_POS_X_LY2    <= user_settings_mem_rd_data(10+12 downto 12);
                        GYRO_DATA_DISP_POS_X_LY2_PN <= user_settings_mem_rd_data(10 downto 0);
                       end if; 
        
                 when  SET_GYRO_DATA_DISP_POS_Y_LY2 =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        GYRO_DATA_DISP_POS_Y_LY2    <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                        GYRO_DATA_DISP_POS_Y_LY2_PN <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       else
                        GYRO_DATA_DISP_POS_Y_LY2    <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                        GYRO_DATA_DISP_POS_Y_LY2_PN <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       end if; 
                
                 when SET_UPDATE_DEVICE_ID_REG1 =>
                       update_device_id_reg(23 downto 0) <= user_settings_mem_rd_data(23 downto 0);
--                       update_device_id_reg_en           <= '1';
                 
                 when SET_UPDATE_DEVICE_ID_REG2 =>
                       update_device_id_reg(31 downto 24) <= user_settings_mem_rd_data(7 downto 0);
--                       update_device_id_reg_en            <= '1';
                
--                 when SET_VIDEO_CTRL =>
--                        VIDEO_CTRL_REG                   <= x"00" &user_settings_mem_rd_data(23 downto 0);
                
                 when  SET_ENABLE_B_BAR_DISP =>
                       ENABLE_B_BAR_DISP <= user_settings_mem_rd_data(0);                                             
 
                 when  SET_ENABLE_C_BAR_DISP =>
                       ENABLE_C_BAR_DISP <= user_settings_mem_rd_data(0);        
                 
                 when  SET_CB_BAR_DISP_COLOR_INFO =>
                       CB_BAR_DISP_COLOR_INFO      <= user_settings_mem_rd_data(23 downto 0);
        
--                 when  SET_CB_BAR_DISP_CH_COLOR_INFO1 =>                       
--                       CB_BAR_DISP_CH_COLOR_INFO1  <= user_settings_mem_rd_data(23 downto 0);
        
--                 when  SET_CB_BAR_DISP_CH_COLOR_INFO2 =>                       
--                       CB_BAR_DISP_CH_COLOR_INFO2  <= user_settings_mem_rd_data(23 downto 0);  
                       
                 when  SET_B_BAR_DISP_POS_X =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        B_BAR_DISP_POS_X      <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                        B_BAR_DISP_POS_X_PN   <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                       else
                        B_BAR_DISP_POS_X      <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                        B_BAR_DISP_POS_X_PN   <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                       end if; 
                 
--                 when  SET_B_BAR_DISP_POS_Y =>
--                       if(PAL_nNTSC= '1')then
--                        B_BAR_DISP_POS_Y      <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
--                        B_BAR_DISP_POS_Y_PN   <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
--                       else
--                        B_BAR_DISP_POS_Y      <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
--                        B_BAR_DISP_POS_Y_PN   <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
--                       end if; 
         
                        
--                 when  SET_B_BAR_DISP_REQ_XSIZE =>
--                       B_BAR_DISP_REQ_XSIZE  <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                 
                 when  SET_B_BAR_DISP_REQ_YSIZE =>
                       B_BAR_DISP_REQ_YSIZE  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       
--                 when  SET_B_BAR_DISP_X_OFFSET=>
--                       B_BAR_DISP_X_OFFSET  <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                 
                 when  SET_B_BAR_DISP_Y_OFFSET =>
                       B_BAR_DISP_Y_OFFSET  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                
                 when  SET_C_BAR_DISP_POS_X =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        C_BAR_DISP_POS_X      <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                       else
                        C_BAR_DISP_POS_X      <= user_settings_mem_rd_data(PIX_BITS-1+12 downto 12);
                       end if; 
                 
                 when  SET_C_BAR_DISP_POS_Y =>
  --                    if(PAL_nNTSC= '1')then 
                       if(sel_oled_analog_video_out = '0')then
                        C_BAR_DISP_POS_Y      <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);
                       else
                        C_BAR_DISP_POS_Y      <= user_settings_mem_rd_data(LIN_BITS-1+12 downto 12);
                       end if; 
         
                        
                 when  SET_C_BAR_DISP_REQ_XSIZE =>
                       C_BAR_DISP_REQ_XSIZE  <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                 
--                 when  SET_C_BAR_DISP_REQ_YSIZE =>
--                       C_BAR_DISP_REQ_YSIZE  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);

                 when  SET_WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE =>
                       WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE <= user_settings_mem_rd_data(7 downto 0);  
                                              
--                 when  SET_B_BAR_DISP_X_OFFSET=>
--                       B_BAR_DISP_X_OFFSET  <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);
                 
--                 when  SET_C_BAR_DISP_X_OFFSET =>
--                       C_BAR_DISP_X_OFFSET  <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);

--                 when  SET_GYRO_CALIB_START =>
--                       GYRO_CALIB_EN  <= user_settings_mem_rd_data(0);

                 when SET_YAW_OFFSET =>
                       yaw_offset    <= user_settings_mem_rd_data(15 downto 0);
         
                 when SET_PITCH_OFFSET =>
                       pitch_offset <= user_settings_mem_rd_data(15 downto 0);

                 when SET_MAX_RELEASE_WAIT_TIME =>                             
                       MAX_RELEASE_WAIT_TIME   <= user_settings_mem_rd_data(11 downto 0);  

                 when SET_MIN_TIME_GAP_PRESS_RELEASE =>                             
                       MIN_TIME_GAP_PRESS_RELEASE <= user_settings_mem_rd_data(11 downto 0);                        
                                                                                                 
                 when SET_MAX_UP_DOWN_PRESS_TIME =>                            
                       MAX_UP_DOWN_PRESS_TIME   <= user_settings_mem_rd_data(15 downto 0);   
                                                                               
                 when SET_MAX_MENU_DOWN_PRESS_TIME =>                          
                       MAX_MENU_DOWN_PRESS_TIME <= user_settings_mem_rd_data(15 downto 0);   
                                                                               
                 when SET_LONG_PRESS_STEP_SIZE =>                              
                       LONG_PRESS_STEP_SIZE     <= user_settings_mem_rd_data(11 downto 0);   
                 
                 when SET_MAX_PRESET_SAVE_OK_DISP_FRAMES =>
                       MAX_PRESET_SAVE_OK_DISP_FRAMES <= user_settings_mem_rd_data(15 downto 0);    
                 
                 when SET_OLED_DISP_EN_TIME_GAP  =>
                       OLED_DISP_EN_TIME_GAP  <= user_settings_mem_rd_data(15 downto 0); 

                 when SET_BPR_DISP_EN_TIME_GAP  =>
                       BPR_DISP_EN_TIME_GAP  <= user_settings_mem_rd_data(15 downto 0); 
                                        
                 when SET_MAX_AGC_MODE_INFO_DISP_TIME => 
                       MAX_AGC_MODE_INFO_DISP_TIME <= user_settings_mem_rd_data(15 downto 0);       

                 when SET_NUC_TIME_GAP =>
                       NUC_TIME_GAP <= user_settings_mem_rd_data(15 downto 0); 

                 when SET_IMG_CROP_LEFT =>
                    IMG_CROP_LEFT             <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);   

                 when SET_IMG_CROP_RIGHT =>
                    IMG_CROP_RIGHT            <= user_settings_mem_rd_data(PIX_BITS-1 downto 0);             

                 when SET_IMG_CROP_TOP =>
                    IMG_CROP_TOP              <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);                          

                 when SET_IMG_CROP_BOTTOM =>
                    IMG_CROP_BOTTOM           <= user_settings_mem_rd_data(LIN_BITS-1 downto 0);  

                 when SET_FIT_TO_SCREEN_EN =>                                         
--                    fit_to_screen_en          <= user_settings_mem_rd_data(0); 
--                    fit_to_screen_en_valid    <= '1';          
                    scaling_disable         <= user_settings_mem_rd_data(1); 
                    scaling_disable_valid   <= '1'; 
                 when  SET_I2C_DELAY_REG => 
                       I2C_DELAY_REG <= user_settings_mem_rd_data(15 downto 0);  

                 when SET_AUTO_SHUTTER_TIMEOUT =>
                       AUTO_SHUTTER_TIMEOUT <= user_settings_mem_rd_data(15 downto 0); 
                       
                 when SET_FRAME_COUNTER_NUC1PT_DELAY =>
                       FRAME_COUNTER_NUC1PT_DELAY <= user_settings_mem_rd_data(15 downto 0); 
                                           
                 when others =>     
              end case;    
          
      
          when others =>     
        end case;                 


      if FPGA_WRREQ = '1' then
        case FPGA_ADDR(7 downto 0) is

          when SET_IMAGE_WIDTH_FULL =>
--            image_width_full          <= FPGA_WRDATA(PIX_BITS-1 downto 0);
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_IMAGE_WIDTH_FULL;  
            user_settings_mem_wr_data <= SET_IMAGE_WIDTH_FULL & x"000" & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0);          
           
          when SET_TEMP_PIXELS_LEFT_RIGHT =>
--            temp_pixels_right         <= FPGA_WRDATA(PIX_BITS-1 downto 0);
--            temp_pixels_left          <= FPGA_WRDATA(PIX_BITS-1+12 downto 12); 
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_TEMP_PIXELS_LEFT_RIGHT;  
            user_settings_mem_wr_data <= SET_TEMP_PIXELS_LEFT_RIGHT & FPGA_WRDATA(23 downto 0);            

          when SET_EXCLUDE_LEFT_RIGHT =>
--            exclude_right             <= FPGA_WRDATA(7 downto 0); 
--            exclude_left              <= FPGA_WRDATA(7+12 downto 12); 
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_EXCLUDE_LEFT_RIGHT;  
            user_settings_mem_wr_data <= SET_EXCLUDE_LEFT_RIGHT & FPGA_WRDATA(23 downto 0);                  

          when SET_PRODUCT_SEL  => 
--            product_sel               <= FPGA_WRDATA(0);   
--            sel_raw                   <=  FPGA_WRDATA(1);     
--            spi_mode       <= user_settings_mem_rd_data(2 downto 1);
--            bat_adc_en                <= FPGA_WRDATA(4); 
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_PRODUCT_SEL;  
            user_settings_mem_wr_data <= SET_PRODUCT_SEL & x"000" & "000" &FPGA_WRDATA(8 downto 0);  

          when SET_OLED_ANALOG_VIDEO_OUT_SEL  => 
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_OLED_ANALOG_VIDEO_OUT_SEL;  
            user_settings_mem_wr_data <= SET_OLED_ANALOG_VIDEO_OUT_SEL & x"00000" &"000" &FPGA_WRDATA(0);  
            

         when SET_SIGHT_MODE =>
            SIGHT_MODE                <= FPGA_WRDATA(1 downto 0);
            SIGHT_MODE_VALID          <= '1';    
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_SIGHT_MODE;  
            user_settings_mem_wr_data <= SET_SIGHT_MODE & x"00000" &"00" &FPGA_WRDATA(1 downto 0); 
         
          when SET_LASER_EN =>
            LASER_EN                  <= FPGA_WRDATA(0);  
            LASER_EN_VALID            <= '1';
--            user_settings_mem_wr_req  <= '1';
--            user_settings_mem_wr_addr <= SET_LASER_EN;  
--            user_settings_mem_wr_data <= SET_LASER_EN & x"00000" & "000" &FPGA_WRDATA(0);  

          when SET_SNAPSHOT_BURST_MODE_CAPTURE_SIZE =>
            burst_capture_size        <= FPGA_WRDATA(7 downto 0);  
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_SNAPSHOT_BURST_MODE_CAPTURE_SIZE;  
            user_settings_mem_wr_data <= SET_SNAPSHOT_BURST_MODE_CAPTURE_SIZE & x"0000" & FPGA_WRDATA(7 downto 0);  
                        
          when SET_MIPI_VIDEO_OUT_SEL =>
            mipi_video_data_out_sel   <= FPGA_WRDATA(0);
            usb_video_data_out_sel_reg<= FPGA_WRDATA(1);
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_MIPI_VIDEO_OUT_SEL;  
            user_settings_mem_wr_data <= SET_MIPI_VIDEO_OUT_SEL & x"00000" & "00" &FPGA_WRDATA(1) &FPGA_WRDATA(0);  

          when SET_TEMP_RANGE_UPDATE_TIMEOUT =>
            temp_range_update_timeout <= FPGA_WRDATA(15 downto 0);
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_TEMP_RANGE_UPDATE_TIMEOUT;  
            user_settings_mem_wr_data <= SET_TEMP_RANGE_UPDATE_TIMEOUT & x"00" & FPGA_WRDATA(15 downto 0);
                    
        
          when SET_UPDATE_DEVICE_ID_REG1 =>
            update_device_id_reg(23 downto 0) <= FPGA_WRDATA(23 downto 0);
--            update_device_id_reg_en           <= '1';
            user_settings_mem_wr_req          <= '1';
            user_settings_mem_wr_addr         <= SET_UPDATE_DEVICE_ID_REG1;  
            user_settings_mem_wr_data         <= SET_UPDATE_DEVICE_ID_REG1 & FPGA_WRDATA(23 downto 0);

          when SET_UPDATE_DEVICE_ID_REG2 =>
            update_device_id_reg(31 downto 24)<= FPGA_WRDATA(7 downto 0);
--            update_device_id_reg_en          <= '1';
            user_settings_mem_wr_req         <= '1';
            user_settings_mem_wr_addr        <= SET_UPDATE_DEVICE_ID_REG2;  
            user_settings_mem_wr_data        <= SET_UPDATE_DEVICE_ID_REG2 & x"0000" & FPGA_WRDATA(7 downto 0);


          when SET_VIDEO_CTRL =>
            VIDEO_CTRL_REG                   <= FPGA_WRDATA;
--            user_settings_mem_wr_req         <= '1';
--            user_settings_mem_wr_addr        <= SET_VIDEO_CTRL;  
--            user_settings_mem_wr_data        <= SET_VIDEO_CTRL & FPGA_WRDATA(23 downto 0);
--          when SET_TEST_PATTERN_EN =>   
--            ENABLE_TP                 <= FPGA_WRDATA(0);
--            user_settings_mem_wr_req  <= '1';
--            user_settings_mem_wr_addr <= x"00";  
--            user_settings_mem_wr_data <= x"0F00" & "000" &PAL_nNTSC & ENABLE_RETICLE  & ENABLE_LOGO  
--                                         & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                                         & ENABLE_SHARPENING_FILTER & ENABLE_SMOOTH_FILTER 
--                                         & POLARITY & ENABLE_BADPIXREM & ENABLE_SNUC
--                                         & ENABLE_NUC &FPGA_WRDATA(0) ;      

          when SET_NUC_EN => 
            ENABLE_NUC                <= FPGA_WRDATA(0);
            ENABLE_UNITY_GAIN         <= FPGA_WRDATA(1);

            snap_img_avg_write        <= '1';
            snap_img_avg_address      <= x"0";
            snap_img_avg_writedata    <= FPGA_WRDATA;

--            user_settings_mem_wr_req  <= '1';
--            user_settings_mem_wr_addr <= SET_NUC_EN;  
--            user_settings_mem_wr_data <= SET_NUC_EN & x"00000" & "000" & FPGA_WRDATA(0);
--            user_settings_mem_wr_addr <= x"0F"; 
--            user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE & MUX_ENABLE_LOGO  
--                                         & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                                         & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING
--                                         & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
--                                         & FPGA_WRDATA(0) &ENABLE_TP ;             
          when SET_SOFTNUC_EN =>     
            ENABLE_SNUC               <=  FPGA_WRDATA(0); 
            ENABLE_SNUC_VALID         <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_SOFTNUC_EN; 
            user_settings_mem_wr_data <= SET_SOFTNUC_EN & x"00000" & "000" & FPGA_WRDATA(0);                                          
                                           
            
          when SET_BADPIXREM_EN => 
            ENABLE_BADPIXREM          <= FPGA_WRDATA(0);   
            blind_badpix_remove_en    <= FPGA_WRDATA(1); 
            user_settings_mem_wr_req  <= '1'; 
            user_settings_mem_wr_addr <= SET_BADPIXREM_EN; 
            user_settings_mem_wr_data <= SET_BADPIXREM_EN & x"00000" & "00" & FPGA_WRDATA(1 downto 0);               
            --user_settings_mem_wr_addr <= x"0F"; 
            --user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE  & MUX_ENABLE_LOGO  
            --                             & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
            --                             & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
            --                             & MUX_POLARITY & FPGA_WRDATA(0) & MUX_ENABLE_SNUC
            --                             & ENABLE_NUC &ENABLE_TP ;              
                      
          when SET_POLARITY =>
            POLARITY                  <= FPGA_WRDATA(1 downto 0);  
            POLARITY_VALID            <= '1';
            user_settings_mem_wr_req  <= '1';  
            user_settings_mem_wr_addr <= SET_POLARITY; 
            user_settings_mem_wr_data <= SET_POLARITY & x"00000" & "00" & FPGA_WRDATA(1 downto 0);  
            --user_settings_mem_wr_addr <= x"0F"; 
            --user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE  & MUX_ENABLE_LOGO  
            --                             & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
            --                             & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
            --                             & FPGA_WRDATA(0) & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
            --                             & ENABLE_NUC &ENABLE_TP ;  

          when SET_BH_OFFSET =>
            BH_OFFSET                 <= FPGA_WRDATA(7 downto 0);  
            user_settings_mem_wr_req  <= '1';  
            user_settings_mem_wr_addr <= SET_BH_OFFSET; 
            user_settings_mem_wr_data <= SET_BH_OFFSET & x"0000" & FPGA_WRDATA(7 downto 0); 
            
          when SET_SMOOTH_FILTER_EN   =>
            if(MUX_ENABLE_EDGE = '1')then
                av_wr_blur                   <= '1';      
                av_addr_blur                 <= x"00"; 
                av_data_blur                 <= x"0001" ;   
                ENABLE_SMOOTHING_FILTER      <= MUX_ENABLE_SMOOTHING; 
                ENABLE_SMOOTHING_FILTER_VALID<= '1'; 
            else   
                av_wr_blur                    <= '1';      
                av_addr_blur                  <= x"00"; 
                av_data_blur                  <= x"000" & "000" & FPGA_WRDATA(0);  
                ENABLE_SMOOTHING_FILTER       <= FPGA_WRDATA(0);   
                ENABLE_SMOOTHING_FILTER_VALID <= '1'; 
                user_settings_mem_wr_req      <= '1';  
                user_settings_mem_wr_addr     <= SET_SMOOTH_FILTER_EN; 
                user_settings_mem_wr_data     <= SET_SMOOTH_FILTER_EN & x"00000" & "000" & FPGA_WRDATA(0);             
            end if;

            --user_settings_mem_wr_addr     <= x"0F"; 
            --user_settings_mem_wr_data     <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE & MUX_ENABLE_LOGO  
            --                                 & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
            --                                 & ENABLE_SHARPENING_FILTER & FPGA_WRDATA(0) 
            --                                 & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
            --                                 & ENABLE_NUC &ENABLE_TP ;  
                       
--          when SET_SHARPNENING_FILTER_EN =>
----            ENABLE_SHARPENING_FILTER      <= FPGA_WRDATA(0);  
--            ENABLE_SHARPENING_FILTER       <= FPGA_WRDATA(0);  
--            ENABLE_SHARPENING_FILTER_VALID <= '1';
--            av_wr_sharp_edge               <= '1';      
--            av_addr_sharp_edge             <= x"00";    
--            av_data_sharp_edge             <= x"000" & "000" & FPGA_WRDATA(0);                 
        
--            user_settings_mem_wr_req       <= '1';    
--            user_settings_mem_wr_addr      <= x"00"; 
--            user_settings_mem_wr_data      <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE  & MUX_ENABLE_LOGO  
--                                              & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                                              & FPGA_WRDATA(0) & MUX_ENABLE_SMOOTHING 
--                                              & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
--                                              & ENABLE_NUC &ENABLE_TP ;  
          when SET_ZOOM_EN  =>    
            ENABLE_ZOOM               <= FPGA_WRDATA(0);                      
            user_settings_mem_wr_req  <= '1'; 
            user_settings_mem_wr_addr <= SET_ZOOM_EN; 
            user_settings_mem_wr_data <= SET_ZOOM_EN & x"00000" & "000" & FPGA_WRDATA(0);   
            --user_settings_mem_wr_addr <= x"0F"; 
            --user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE & MUX_ENABLE_LOGO  
            --                             & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & FPGA_WRDATA(0)  
            --                             & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
            --                             & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
            --                             & ENABLE_NUC &ENABLE_TP ; 
                        
          when SET_BRIGHT_CONTRAST_EN =>   
            ENABLE_BRIGHT_CONTRAST    <= FPGA_WRDATA(0);     
            OLED_VGN_TEST             <= FPGA_WRDATA;                 
            user_settings_mem_wr_req  <= '1';  
            user_settings_mem_wr_addr <= SET_BRIGHT_CONTRAST_EN; 
            user_settings_mem_wr_data <= SET_BRIGHT_CONTRAST_EN & x"00000" & "000" & FPGA_WRDATA(0);  
            --user_settings_mem_wr_addr <= x"0F"; 
            --user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE  & MUX_ENABLE_LOGO  
            --                             & ENABLE_CP & FPGA_WRDATA(0) & ENABLE_ZOOM  
            --                             & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
            --                             & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
            --                             & ENABLE_NUC &ENABLE_TP ;   
 
--          when SET_COLOR_PALETTE_EN =>  
--            ENABLE_CP                 <= FPGA_WRDATA(0);  
--            user_settings_mem_wr_req  <= '1';    
--            user_settings_mem_wr_addr <= x"00"; 
--            user_settings_mem_wr_data <= x"0F00" & "000" &PAL_nNTSC & ENABLE_RETICLE  & ENABLE_LOGO  
--                                         & FPGA_WRDATA(0) & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                                         & ENABLE_SHARPENING_FILTER & ENABLE_SMOOTH_FILTER 
--                                         & POLARITY & ENABLE_BADPIXREM & ENABLE_SNUC
--                                         & ENABLE_NUC &ENABLE_TP;  
                                         
          when SET_LOGO_EN => 
            ENABLE_LOGO               <= FPGA_WRDATA(0);  
            ENABLE_LOGO_VALID         <= '1';               
            user_settings_mem_wr_req  <= '1';   
            user_settings_mem_wr_addr <= SET_LOGO_EN; 
            user_settings_mem_wr_data <= SET_LOGO_EN & x"00000" & "000" & FPGA_WRDATA(0); 
            --user_settings_mem_wr_addr <= x"0F"; 
            --user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE  & FPGA_WRDATA(0)  
            --                             & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
            --                             & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
            --                             & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
            --                             & ENABLE_NUC &ENABLE_TP ;   
              

          when SET_RETICLE_EN =>  
             ENABLE_RETICLE            <= FPGA_WRDATA(0);     
             ENABLE_RETICLE_VALID      <= '1';   
             user_settings_mem_wr_req  <= '1';     
             user_settings_mem_wr_addr <= SET_RETICLE_EN; 
             user_settings_mem_wr_data <= SET_RETICLE_EN & x"00000" & "000" & FPGA_WRDATA(0);                       

          when SET_EDGE_FILTER_EN   =>

              ENABLE_EDGE_FILTER        <= FPGA_WRDATA(0);  
              ENABLE_EDGE_FILTER_VALID  <= '1';
            
              if(FPGA_WRDATA(0)='0')then
--                  ENABLE_SMOOTH_FILTER     <= ENABLE_SMOOTHING_FILTER;
--                  ENABLE_SHARPENING_FILTER <= ENABLE_SHARPENING_FILTER;
--                 av_wr_blur          <= '1';
--                 av_addr_blur        <= x"00";
--                 av_data_blur        <= x"0000";
                  av_wr_blur          <= '1';      
                  av_addr_blur        <= x"00";    
                  av_data_blur        <= x"000" & "000" & MUX_ENABLE_SMOOTHING;  
--                  av_wr_sharp_edge    <= '1';      
--                  av_addr_sharp_edge  <= x"00";    
--                  av_data_sharp_edge  <= x"000" & "000" & ENABLE_SHARPENING_FILTER;  
                  av_wr_sharp_edge    <= '1';
                  av_addr_sharp_edge  <= x"00";
                  av_data_sharp_edge  <= x"0001";                                        
              else
--                  ENABLE_SMOOTH_FILTER      <= '1';   
--                  ENABLE_SHARPENING_FILTER  <= '1';        
                  av_wr_blur          <= '1';      
                  av_addr_blur        <= x"00";    
                  av_data_blur        <= x"0001";  
                  av_wr_sharp_edge    <= '1';      
                  av_addr_sharp_edge  <= x"00";    
                  av_data_sharp_edge  <= x"0003";         
              end if;    
                        
              user_settings_mem_wr_req  <= '1';  
              user_settings_mem_wr_addr <= SET_EDGE_FILTER_EN; 
              user_settings_mem_wr_data <= SET_EDGE_FILTER_EN & x"00000" & "000" & FPGA_WRDATA(0);  
              --user_settings_mem_wr_addr <= x"0F"; 
              --user_settings_mem_wr_data <= x"0F00" & "000"  & PAL_nNTSC &FPGA_WRDATA(0)  & MUX_ENABLE_LOGO  
              --                             & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
              --                             & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
              --                             & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
              --                             & ENABLE_NUC &ENABLE_TP ;  


          when SET_PAL_NTSC_MODE   =>
--              PAL_nNTSC                 <= FPGA_WRDATA(0);
              user_settings_mem_wr_req  <= '1';    
              user_settings_mem_wr_addr <= SET_PAL_NTSC_MODE; 
              user_settings_mem_wr_data <= SET_PAL_NTSC_MODE & x"00000" & "000" & FPGA_WRDATA(0);              
              --user_settings_mem_wr_addr <= x"0F"; 
              --user_settings_mem_wr_data <= x"0F00" & "000"  &FPGA_WRDATA(0)  & MUX_ENABLE_EDGE  & MUX_ENABLE_LOGO  
              --                             & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
              --                             & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
              --                             & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
              --                             & ENABLE_NUC &ENABLE_TP ;             

          when SET_NUC1PT_CAPTURE_FRAMES =>
            NUC1pt_Capture_Frames     <= FPGA_WRDATA(3 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= x"92"; 
            user_settings_mem_wr_data <= SET_NUC1PT_CAPTURE_FRAMES &  x"00000" & FPGA_WRDATA(3 downto 0);

          when SET_THRESHOLD_SOBL =>
            THRESHOLD_SOBL            <= FPGA_WRDATA(7 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= x"13"; 
            user_settings_mem_wr_data <= SET_THRESHOLD_SOBL &  x"0000" & FPGA_WRDATA(7 downto 0); 
  
          when SET_BPC_TH =>
            BPC_TH                    <= FPGA_WRDATA(15 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= x"68"; 
            user_settings_mem_wr_data <= SET_BPC_TH &  x"00" & FPGA_WRDATA(15 downto 0);          
---------------------------------------------------------------------------------------------------------------------
          when SET_SHARPNESS  =>                
--            AV_KERN_ADDR_SFILT        <= FPGA_WRDATA(23 downto 16); 
--            AV_KERN_WR_SFILT          <= '1';
--            AV_KERN_WRDATA_SFILT      <= x"00" & FPGA_WRDATA(15 downto 0);
            SHARPNESS           <= FPGA_WRDATA(3 downto 0);  
            SHARPNESS_VALID     <= '1';
            av_wr_sharp_edge    <= '1';      
            av_addr_sharp_edge  <= x"02";    
            av_data_sharp_edge  <= x"000" &FPGA_WRDATA(3 downto 0);   
            
            
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_SHARPNESS; 
            user_settings_mem_wr_data <= SET_SHARPNESS & x"00000" &FPGA_WRDATA(3 downto 0);            
            
          when SET_EDGE_LEVEL  =>                
--            AV_KERN_ADDR_SFILT        <= FPGA_WRDATA(23 downto 16);  
--            AV_KERN_WR_SFILT          <= '1';
--            AV_KERN_WRDATA_SFILT      <= x"00" & FPGA_WRDATA(15 downto 0);
            av_wr_sharp_edge    <= '1';      
            av_addr_sharp_edge  <= x"01";    
            av_data_sharp_edge  <= FPGA_WRDATA(15 downto 0);   
                        
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_EDGE_LEVEL; 
            user_settings_mem_wr_data <= SET_EDGE_LEVEL & x"00" &FPGA_WRDATA(15 downto 0); 
-----------------------------------------------------------------------------------------------------------------------
          when SET_OLED_IMG_FLIP =>
            OLED_IMG_FLIP             <= FPGA_WRDATA(7 downto 0);
            OLED_IMG_FLIP_VALID       <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_OLED_IMG_FLIP; 
            user_settings_mem_wr_data <= SET_OLED_IMG_FLIP &  x"0000" &  FPGA_WRDATA(7 downto 0); 
            
          when SET_IMG_FLIP =>
            IMG_FLIP_H                <= FPGA_WRDATA(0);  
            IMG_FLIP_V                <= FPGA_WRDATA(1);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_IMG_FLIP; 
            user_settings_mem_wr_data <= SET_IMG_FLIP &  x"00000" & "00" &FPGA_WRDATA(1 downto 0); 


-------------------------------------------------------------------------------------------------------------------------
--          when SET_IMG_SHIFT_POS_X =>
--            user_settings_mem_wr_req  <= '1';                                                      
--            user_settings_mem_wr_addr <= x"05";                                                    
--            user_settings_mem_wr_data <= SET_IMG_SHIFT_POS_X &  x"000" & "00" &IMG_SHIFT_POS_X; 
          
--          when SET_IMG_SHIFT_POS_Y =>
--            user_settings_mem_wr_req  <= '1';                                                      
--            user_settings_mem_wr_addr <= x"06";                                                    
--            user_settings_mem_wr_data <= SET_IMG_SHIFT_POS_Y &  x"000" & "00" &IMG_SHIFT_POS_Y; 
            
----------------------------------------------------------------------------------------------------------------------- 
          when SET_ZOOM_MODE =>
            ZOOM_MODE                 <= FPGA_WRDATA(2 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_ZOOM_MODE; 
            user_settings_mem_wr_data <= SET_ZOOM_MODE &  x"00000" & "0" &FPGA_WRDATA(2 downto 0);
            ZOOM_MODE_VALID           <= '1';

          when SET_BRIGHTNESS =>
            BRIGHTNESS                <= FPGA_WRDATA(7 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_BRIGHTNESS; 
            user_settings_mem_wr_data <= SET_BRIGHTNESS &  x"0000" &FPGA_WRDATA(7 downto 0);
            BRIGHTNESS_VALID          <= '1';  
 
           when SET_BRIGHTNESS_OFFSET  =>
            BRIGHTNESS_OFFSET         <= FPGA_WRDATA(7 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_BRIGHTNESS_OFFSET; 
            user_settings_mem_wr_data <= SET_BRIGHTNESS_OFFSET &  x"0000" &FPGA_WRDATA(7 downto 0);
                 
          when SET_CONTRAST_OFFSET =>
            CONTRAST_OFFSET           <= FPGA_WRDATA(7 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CONTRAST_OFFSET; 
            user_settings_mem_wr_data <= SET_CONTRAST_OFFSET & x"0000" & FPGA_WRDATA(7 downto 0);   
                 
          when SET_CONTRAST =>
            CONTRAST                  <= FPGA_WRDATA(7 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CONTRAST; 
            user_settings_mem_wr_data <= SET_CONTRAST & x"0000" & FPGA_WRDATA(7 downto 0);   
            CONTRAST_VALID            <= '1';   

          when SET_CONSTANT_CB_CR =>                                                             
            CONSTANT_CB_CR            <= FPGA_WRDATA(15 downto 0);                                 
            user_settings_mem_wr_req  <= '1';                                                     
            user_settings_mem_wr_addr <= SET_CONSTANT_CB_CR;                                     
            user_settings_mem_wr_data <= SET_CONSTANT_CB_CR & x"00" & CONSTANT_CB_CR(15 downto 0); 
                              
          when SET_COLOR_PALETTE_MODE =>   
            CP_TYPE                   <= FPGA_WRDATA(4 downto 0);  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_COLOR_PALETTE_MODE; 
            user_settings_mem_wr_data <= SET_COLOR_PALETTE_MODE &  x"0000" & "000" &FPGA_WRDATA(4 downto 0); 
            CP_TYPE_VALID <= '1';
  
          when SET_CP_MIN_MAX_VAL =>
            CP_MIN_VALUE              <= FPGA_WRDATA(7 downto 0);
            CP_MAX_VALUE              <= FPGA_WRDATA(23 downto 16);  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CP_MIN_MAX_VAL; 
            user_settings_mem_wr_data <= SET_CP_MIN_MAX_VAL  &FPGA_WRDATA(23 downto 0);   


          when SET_LOGO_POS_X =>   
            LOGO_POS_X                <= FPGA_WRDATA( 10 downto 0);  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_LOGO_POS_X; 
--            if(PAL_nNTSC= '1')then
            if(sel_oled_analog_video_out = '0')then            
             user_settings_mem_wr_data <= SET_LOGO_POS_X &  "0" & LOGO_POS_X_PN & "0" &FPGA_WRDATA( 10 downto 0);     
            else
             user_settings_mem_wr_data <= SET_LOGO_POS_X &  "0" & FPGA_WRDATA(10 downto 0)& "0" & LOGO_POS_X_PN;
            end if;                     
          when SET_LOGO_POS_Y =>   
            LOGO_POS_Y                <= FPGA_WRDATA( LIN_BITS-1 downto 0);   
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_LOGO_POS_Y; 
--            if(PAL_nNTSC= '1')then
            if(sel_oled_analog_video_out = '0')then 
             user_settings_mem_wr_data <= SET_LOGO_POS_Y &  "00" & LOGO_POS_Y_PN & "00" &FPGA_WRDATA( LIN_BITS-1 downto 0);     
            else
             user_settings_mem_wr_data <= SET_LOGO_POS_Y &  "00" & FPGA_WRDATA( LIN_BITS-1 downto 0)& "00" & LOGO_POS_Y_PN;
            end if;   
              
          when SET_LOGO_COLOR1 =>   
            LOGO_COLOR_INFO1          <= FPGA_WRDATA(23 downto 0);  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_LOGO_COLOR1; 
            user_settings_mem_wr_data <= SET_LOGO_COLOR1 &   FPGA_WRDATA(23 downto 0); 
            
                               
          when SET_LOGO_COLOR2 =>   
            LOGO_COLOR_INFO2          <= FPGA_WRDATA(23 downto 0);                
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_LOGO_COLOR2; 
            user_settings_mem_wr_data <= SET_LOGO_COLOR2 &  FPGA_WRDATA(23 downto 0); 


          when SET_NUC_MODE   =>
            NUC_MODE                  <=  FPGA_WRDATA(1 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_NUC_MODE; 
            user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &FPGA_WRDATA(1 downto 0); 
            NUC_MODE_VALID <= '1';
                 
          when SET_BLADE_MODE   =>
            BLADE_MODE                <=  FPGA_WRDATA(1 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_BLADE_MODE; 
            user_settings_mem_wr_data <= SET_BLADE_MODE&  x"00000" &"00"  &FPGA_WRDATA(1 downto 0);
            BLADE_MODE_VALID <= '1';

          when SET_RETICLE_SEL =>  
            RETICLE_SEL               <= FPGA_WRDATA(3 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_RETICLE_SEL; 
            user_settings_mem_wr_data <= SET_RETICLE_SEL &  x"00000"  &FPGA_WRDATA(3 downto 0);  
            RETICLE_SEL_VALID        <= '1';

          when SET_RETICLE_TYPE =>  
            RETICLE_TYPE              <= FPGA_WRDATA(3 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_RETICLE_TYPE; 
            user_settings_mem_wr_data <= SET_RETICLE_TYPE &  x"00000"  &FPGA_WRDATA(3 downto 0);  
            RETICLE_TYPE_VALID        <= '1';
            
          when SET_RETICLE_POS_X =>   
            RETICLE_POS_YX(11 downto 0) <= "00" & FPGA_WRDATA( PIX_BITS-1 downto 0);
            RETICLE_POS_YX(23 downto 12)<= MUX_RETICLE_POS_YX(23 downto 12);
--            RETICLE_POS_X             <= FPGA_WRDATA( PIX_BITS-1 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_RETICLE_POS_X; 
--            user_settings_mem_wr_data <= SET_RETICLE_POS_X &  x"000" & "00" &FPGA_WRDATA( PIX_BITS-1 downto 0); 
            user_settings_mem_wr_data <= SET_RETICLE_POS_X &  MUX_RETICLE_POS_YX(23 downto 12) & "00" &FPGA_WRDATA( PIX_BITS-1 downto 0);  
            RETICLE_POS_YX_VALID      <= '1';
--            RETICLE_POS_X_VALID       <= '1';
                                     
          when SET_RETICLE_POS_Y =>   
            RETICLE_POS_YX(23 downto 12) <= "00" & FPGA_WRDATA( LIN_BITS-1 downto 0);
            RETICLE_POS_YX(11 downto 0)  <= MUX_RETICLE_POS_YX(11 downto 0);
--            RETICLE_POS_Y             <= FPGA_WRDATA( LIN_BITS-1 downto 0);
            user_settings_mem_wr_req  <= '1';    
--            user_settings_mem_wr_addr <= SET_RETICLE_POS_Y; 
--            user_settings_mem_wr_data <= SET_RETICLE_POS_Y &  x"000" & "00" & FPGA_WRDATA( LIN_BITS-1 downto 0);  
            user_settings_mem_wr_addr <= SET_RETICLE_POS_X;
            user_settings_mem_wr_data <= SET_RETICLE_POS_X & "00" & FPGA_WRDATA( LIN_BITS-1 downto 0) & MUX_RETICLE_POS_YX(11 downto 0);   
            RETICLE_POS_YX_VALID       <= '1';
--            RETICLE_POS_Y_VALID       <= '1';

          when SET_RETICLE_COLOR_SEL =>  
             RETICLE_COLOR_SEL         <= FPGA_WRDATA(2 downto 0);     
             RETICLE_COLOR_SEL_VALID   <= '1';   
             user_settings_mem_wr_req  <= '1';     
             user_settings_mem_wr_addr <= SET_RETICLE_COLOR_SEL; 
             user_settings_mem_wr_data <= SET_RETICLE_COLOR_SEL & x"00000" & "0" & FPGA_WRDATA(2 downto 0); 
                       
          when SET_RETICLE_COLOR1 =>   
            RETICLE_COLOR_INFO1       <= FPGA_WRDATA(23 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_RETICLE_COLOR1; 
            user_settings_mem_wr_data <= SET_RETICLE_COLOR1 & FPGA_WRDATA(23 downto 0);   
                             
          when SET_RETICLE_COLOR2 =>   
            RETICLE_COLOR_INFO2       <= FPGA_WRDATA(23 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_RETICLE_COLOR2; 
            user_settings_mem_wr_data <= SET_RETICLE_COLOR2 &  FPGA_WRDATA(23 downto 0);   

          when SET_RETICLE_COLOR_TH =>
            RETICLE_COLOR_TH          <= FPGA_WRDATA(15 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_RETICLE_COLOR_TH; 
            user_settings_mem_wr_data <= SET_RETICLE_COLOR_TH & x"00" & FPGA_WRDATA(15 downto 0);      

          when SET_COLOR_SEL_WINDOW_XSIZE =>
            COLOR_SEL_WINDOW_XSIZE    <= FPGA_WRDATA(PIX_BITS-1 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_COLOR_SEL_WINDOW_XSIZE; 
            user_settings_mem_wr_data <= SET_COLOR_SEL_WINDOW_XSIZE & x"000" & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0);

          when SET_COLOR_SEL_WINDOW_YSIZE =>
            COLOR_SEL_WINDOW_YSIZE    <= FPGA_WRDATA(LIN_BITS-1 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_COLOR_SEL_WINDOW_YSIZE; 
            user_settings_mem_wr_data <= SET_COLOR_SEL_WINDOW_YSIZE & x"000" & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);

          when SET_FIRING_MODE =>
            FIRING_MODE               <= FPGA_WRDATA(0);  
            FIRING_MODE_VALID         <= '1';  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_FIRING_MODE; 
            user_settings_mem_wr_data <= SET_FIRING_MODE & x"00000" & "000" &FPGA_WRDATA(0); 

          when SET_FIRING_DISTANCE =>
            DISTANCE_SEL              <= FPGA_WRDATA(3 downto 0);  
            DISTANCE_SEL_VALID        <= '1';  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_FIRING_DISTANCE; 
            user_settings_mem_wr_data <= SET_FIRING_DISTANCE & x"00000" & FPGA_WRDATA(3 downto 0); 
            
          when SET_PRESET_SEL    => 
            PRESET_SEL                <= FPGA_WRDATA(3 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_PRESET_SEL; 
            user_settings_mem_wr_data <= SET_PRESET_SEL &  x"00000" &FPGA_WRDATA(3 downto 0); 
            PRESET_SEL_VALID          <= '1';  

          when SET_PRESET_P1_POS => 
            PRESET_P1_POS             <= FPGA_WRDATA(23 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_PRESET_P1_POS; 
            user_settings_mem_wr_data <= SET_PRESET_P1_POS &  FPGA_WRDATA(23 downto 0);    
            PRESET_P1_POS_VALID       <= '1';            

          when SET_PRESET_P2_POS => 
            PRESET_P2_POS             <= FPGA_WRDATA(23 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_PRESET_P2_POS; 
            user_settings_mem_wr_data <= SET_PRESET_P2_POS &  FPGA_WRDATA(23 downto 0);
            PRESET_P2_POS_VALID       <= '1'; 

          when SET_PRESET_P3_POS => 
            PRESET_P3_POS             <= FPGA_WRDATA(23 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_PRESET_P3_POS; 
            user_settings_mem_wr_data <= SET_PRESET_P3_POS &  FPGA_WRDATA(23 downto 0);
            PRESET_P3_POS_VALID       <= '1'; 

          when SET_PRESET_P4_POS => 
            PRESET_P4_POS             <= FPGA_WRDATA(23 downto 0);    
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_PRESET_P4_POS; 
            user_settings_mem_wr_data <= SET_PRESET_P4_POS &  FPGA_WRDATA(23 downto 0);
            PRESET_P4_POS_VALID       <= '1'; 
                                    
          when SET_AGC_MODE=>
            AGC_MODE_SEL              <= FPGA_WRDATA(1 downto 0);  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_AGC_MODE; 
            user_settings_mem_wr_data <= SET_AGC_MODE &  x"00000" & "00" &FPGA_WRDATA(1 downto 0);    
            AGC_MODE_SEL_VALID        <= '1';
            
          when SET_AGC_MAX_GAIN =>                                                                              
            MAX_GAIN                  <= FPGA_WRDATA(7 downto 0);                                                           
            user_settings_mem_wr_req  <= '1';                                                                
            user_settings_mem_wr_addr <= SET_AGC_MAX_GAIN;                                                              
            user_settings_mem_wr_data <= SET_AGC_MAX_GAIN & x"0000" & FPGA_WRDATA(7 downto 0); 


          when SET_MAX_LIMITER_DPHE =>
            MAX_LIMITER_DPHE          <= FPGA_WRDATA(7 downto 0);     
            MAX_LIMITER_DPHE_VALID    <= '1';   
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_MAX_LIMITER_DPHE; 
            user_settings_mem_wr_data <= SET_MAX_LIMITER_DPHE &  x"0000" & FPGA_WRDATA(7 downto 0); 

          when SET_MUL_MAX_LIMITER_DPHE =>
            MUL_MAX_LIMITER_DPHE       <= FPGA_WRDATA(7 downto 0);     
            MUL_MAX_LIMITER_DPHE_VALID <= '1';   
            user_settings_mem_wr_req   <= '1';    
            user_settings_mem_wr_addr  <= SET_MUL_MAX_LIMITER_DPHE; 
            user_settings_mem_wr_data  <= SET_MUL_MAX_LIMITER_DPHE &  x"0000" & FPGA_WRDATA(7 downto 0); 

          when SET_CNTRL_MIN_DPHE =>
            CNTRL_MIN_DPHE            <= FPGA_WRDATA(23 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_MIN_DPHE; 
            user_settings_mem_wr_data <= SET_CNTRL_MIN_DPHE &  FPGA_WRDATA(23 downto 0); 
          
          when SET_CNTRL_MAX_DPHE =>
            CNTRL_MAX_DPHE            <= FPGA_WRDATA(23 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_MAX_DPHE; 
            user_settings_mem_wr_data <= SET_CNTRL_MAX_DPHE &  FPGA_WRDATA(23 downto 0);  
          
          when SET_CNTRL_HIST1_DPHE =>
            CNTRL_HIST1_DPHE          <= FPGA_WRDATA(23 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_HIST1_DPHE; 
            user_settings_mem_wr_data <= SET_CNTRL_HIST1_DPHE &  FPGA_WRDATA(23 downto 0);   
          
          when SET_CNTRL_HIST2_DPHE =>
            CNTRL_HIST2_DPHE          <= FPGA_WRDATA(23 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_HIST2_DPHE; 
            user_settings_mem_wr_data <= SET_CNTRL_HIST2_DPHE &  FPGA_WRDATA(23 downto 0);           
          
          when SET_CNTRL_CLIP_DPHE =>
            CNTRL_CLIP_DPHE           <= FPGA_WRDATA(23 downto 0);  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_CLIP_DPHE; 
            user_settings_mem_wr_data <= SET_CNTRL_CLIP_DPHE &  FPGA_WRDATA(23 downto 0);      
                 
          when SET_CNTRL_MIN_HISTEQ =>
            CNTRL_MIN_HISTEQ          <= FPGA_WRDATA(23 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_MIN_HISTEQ; 
            user_settings_mem_wr_data <= SET_CNTRL_MIN_HISTEQ &  FPGA_WRDATA(23 downto 0);               
          
          when SET_CNTRL_MAX_HISTEQ =>
            CNTRL_MAX_HISTEQ          <= FPGA_WRDATA(23 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_MAX_HISTEQ; 
            user_settings_mem_wr_data <= SET_CNTRL_MAX_HISTEQ &  FPGA_WRDATA(23 downto 0); 
            
          when SET_CNTRL_HISTORY_HISTEQ =>
            CNTRL_HISTORY_HISTEQ      <= FPGA_WRDATA(23 downto 0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_HISTORY_HISTEQ;
            user_settings_mem_wr_data <= SET_CNTRL_HISTORY_HISTEQ &  FPGA_WRDATA(23 downto 0); 

          when SET_CNTRL_MAX_GAIN =>
            CNTRL_MAX_GAIN            <= FPGA_WRDATA(7 downto 0); 
            CNTRL_MAX_GAIN_VALID      <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_MAX_GAIN; 
            user_settings_mem_wr_data <= SET_CNTRL_MAX_GAIN & x"0000" &FPGA_WRDATA(7 downto 0);

          when SET_CNTRL_IPP =>
            CNTRL_IPP                 <= FPGA_WRDATA(7 downto 0); 
            CNTRL_IPP_VALID           <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_CNTRL_IPP; 
            user_settings_mem_wr_data <= SET_CNTRL_IPP & x"0000" &FPGA_WRDATA(7 downto 0);

          when SET_ROI_MODE =>                     
            ROI_MODE                  <= FPGA_WRDATA(0); 
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_ROI_MODE; 
            user_settings_mem_wr_data <= SET_ROI_MODE & x"00000" & "000"& FPGA_WRDATA(0); 

--          when SET_ROI_X_OFFSET    =>
--            ROI_X_OFFSET              <= FPGA_WRDATA(PIX_BITS-1 downto 0);
--            user_settings_mem_wr_req  <= '1';    
--            user_settings_mem_wr_addr <= x"21"; 
--            user_settings_mem_wr_data <= SET_ROI_X_OFFSET & x"000" & "00"& FPGA_WRDATA(PIX_BITS-1 downto 0);              
                          
--          when SET_ROI_Y_OFFSET    =>
--            ROI_Y_OFFSET              <=  FPGA_WRDATA(LIN_BITS-1 downto 0);
--            user_settings_mem_wr_req  <= '1';    
--            user_settings_mem_wr_addr <= x"22"; 
--            user_settings_mem_wr_data <= SET_ROI_Y_OFFSET & x"000" & "00"& FPGA_WRDATA(LIN_BITS-1 downto 0); 
                                
--          when SET_ROI_X_SIZE =>
--            ROI_X_SIZE                <= FPGA_WRDATA(PIX_BITS-1 downto 0); 
--            user_settings_mem_wr_req  <= '1';    
--            user_settings_mem_wr_addr <= x"23"; 
--            user_settings_mem_wr_data <= SET_ROI_X_SIZE & x"000" & "00"& FPGA_WRDATA(PIX_BITS-1 downto 0); 
                            
--          when SET_ROI_Y_SIZE =>   
--            ROI_Y_SIZE                <= FPGA_WRDATA(LIN_BITS-1 downto 0); 
--            user_settings_mem_wr_req  <= '1';    
--            user_settings_mem_wr_addr <= x"24"; 
--            user_settings_mem_wr_data <= SET_ROI_Y_SIZE & x"000" & "00"& FPGA_WRDATA(LIN_BITS-1 downto 0);                 

          when SET_GYRO_DATA_UPDATE_TIMEOUT =>                     
               GYRO_DATA_UPDATE_TIMEOUT   <= FPGA_WRDATA(15 downto 0);
               user_settings_mem_wr_req   <= '1';    
               user_settings_mem_wr_addr  <= SET_GYRO_DATA_UPDATE_TIMEOUT; 
               user_settings_mem_wr_data  <= SET_GYRO_DATA_UPDATE_TIMEOUT & x"00"& FPGA_WRDATA(15 downto 0); 
            
          when SET_GYRO_DATA_DISP_EN =>
               GYRO_DATA_DISP_EN          <= FPGA_WRDATA(0);
               GYRO_DATA_DISP_MODE        <= FPGA_WRDATA(1);
               GYRO_DATA_DISP_EN_VALID    <= '1'; 
               user_settings_mem_wr_req   <= '1';    
               user_settings_mem_wr_addr  <= SET_GYRO_DATA_DISP_EN; 
               user_settings_mem_wr_data  <= SET_GYRO_DATA_DISP_EN & x"00000" & "00" &FPGA_WRDATA(1 downto 0); 
            
          when SET_OLED_GAMMA_TABLE_SEL => 
            OLED_GAMMA_TABLE_SEL       <= FPGA_WRDATA(7 downto 0);
            OLED_GAMMA_TABLE_SEL_VALID <= '1';
            user_settings_mem_wr_req   <= '1';    
            user_settings_mem_wr_addr  <= SET_OLED_GAMMA_TABLE_SEL; 
            user_settings_mem_wr_data  <= SET_OLED_GAMMA_TABLE_SEL & x"0000" & FPGA_WRDATA(7 downto 0);   

          when SET_OLED_POS_V =>                     
            OLED_POS_V                <= FPGA_WRDATA(7 downto 0) ;
--            OLED_REG_DATA             <= FPGA_WRDATA(7 downto 0) ;
            OLED_POS_V_VALID          <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_OLED_POS_V; 
            user_settings_mem_wr_data <= SET_OLED_POS_V & x"0000" & FPGA_WRDATA(7 downto 0);   
            
            
          when SET_OLED_POS_H =>                     
            OLED_POS_H                <= FPGA_WRDATA(8 downto 0) ;
--            OLED_REG_DATA             <= FPGA_WRDATA(7 downto 0) ;
            OLED_POS_H_VALID          <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_OLED_POS_H; 
            user_settings_mem_wr_data <= SET_OLED_POS_H & x"000" & "000" & FPGA_WRDATA(8 downto 0);               
 
          when SET_OLED_BRIGHTNESS =>                     
            OLED_BRIGHTNESS           <= FPGA_WRDATA(7 downto 0) ;
--            OLED_REG_DATA             <= FPGA_WRDATA(7 downto 0) ;
            OLED_BRIGHTNESS_VALID     <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_OLED_BRIGHTNESS; 
            user_settings_mem_wr_data <= SET_OLED_BRIGHTNESS & x"0000" & FPGA_WRDATA(7 downto 0);               
            
          when SET_OLED_CONTRAST =>                     
            OLED_CONTRAST             <= FPGA_WRDATA(7 downto 0) ;
--            OLED_REG_DATA             <= FPGA_WRDATA(7 downto 0) ;
            OLED_CONTRAST_VALID       <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_OLED_CONTRAST; 
            user_settings_mem_wr_data <= SET_OLED_CONTRAST & x"0000" & FPGA_WRDATA(7 downto 0);  

            
          when SET_OLED_IDRF =>                     
            OLED_IDRF                 <= FPGA_WRDATA(7 downto 0) ;
--            OLED_REG_DATA             <= FPGA_WRDATA(7 downto 0) ;
            OLED_IDRF_VALID           <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_OLED_IDRF; 
            user_settings_mem_wr_data <= SET_OLED_IDRF & x"0000" & FPGA_WRDATA(7 downto 0);  

          when SET_OLED_DIMCTL =>                     
            OLED_DIMCTL               <= FPGA_WRDATA(7 downto 0);
--            OLED_REG_DATA             <= FPGA_WRDATA(7 downto 0);
            OLED_DIMCTL_VALID         <= '1';
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_OLED_DIMCTL; 
            user_settings_mem_wr_data <= SET_OLED_DIMCTL & x"0000" & FPGA_WRDATA(7 downto 0);  
         
--         when SET_MAX_VGN_SETTLE_TIME =>
--           MAX_VGN_SETTLE_TIME       <= FPGA_WRDATA(7 downto 0); 
--           user_settings_mem_wr_req  <= '1';    
--           user_settings_mem_wr_addr <= SET_MAX_VGN_SETTLE_TIME; 
--           user_settings_mem_wr_data <= SET_MAX_VGN_SETTLE_TIME & x"0000" & FPGA_WRDATA(7 downto 0);  

         when SET_OLED_CATHODE_VOLTAGE =>
           OLED_CATHODE_VOLTAGE      <= FPGA_WRDATA(7 downto 0); 
           OLED_CATHODE_VOLTAGE_VALID<= '1';
           user_settings_mem_wr_req  <= '1';    
           user_settings_mem_wr_addr <= SET_OLED_CATHODE_VOLTAGE; 
           user_settings_mem_wr_data <= SET_OLED_CATHODE_VOLTAGE & x"0000" & FPGA_WRDATA(7 downto 0);  

         when SET_MAX_OLED_VGN_RD_PERIOD =>
           MAX_OLED_VGN_RD_PERIOD    <= FPGA_WRDATA(15 downto 0); 
           user_settings_mem_wr_req  <= '1';    
           user_settings_mem_wr_addr <= SET_MAX_OLED_VGN_RD_PERIOD; 
           user_settings_mem_wr_data <= SET_MAX_OLED_VGN_RD_PERIOD & x"00" & FPGA_WRDATA(15 downto 0);  

         when SET_MAX_BAT_PARAM_RD_PERIOD =>
           MAX_BAT_PARAM_RD_PERIOD   <= FPGA_WRDATA(15 downto 0);  
           user_settings_mem_wr_req  <= '1';    
           user_settings_mem_wr_addr <= SET_MAX_BAT_PARAM_RD_PERIOD; 
           user_settings_mem_wr_data <= SET_MAX_BAT_PARAM_RD_PERIOD & x"00" & FPGA_WRDATA(15 downto 0); 

--          when SET_FPGA_VERSION =>
--            FPGA_VERSION_REG    <= FPGA_WRDATA;

--          when SET_CLIP_THRESHOLD =>
--            Clip_Threshold      <= FPGA_WRDATA(18 downto 0);
            
          when SET_OFFSET_TBALE_FORCE =>
            OFFSET_TBALE_FORCE <= FPGA_WRDATA;

          when SET_NUC_TIME_GAP =>
            NUC_TIME_GAP <= FPGA_WRDATA(15 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_NUC_TIME_GAP; 
            user_settings_mem_wr_data <= SET_NUC_TIME_GAP & x"00" & FPGA_WRDATA(15 downto 0);   
 
          when SET_NUC1PT_CTRL =>
            if(FPGA_WRDATA(2) = '1') then
                Start_NUC1ptCalib <= FPGA_WRDATA(0);
                gain_enable       <= '1';
                APPLY_NUC1ptCalib <= FPGA_WRDATA(1);
            else
                gain_enable       <= '0';    
                if(MUX_BLADE_MODE = "00")then
                    if(FPGA_WRDATA(0)= '1')then
                        Start_NUC1ptCalib         <= '1';  
                        APPLY_NUC1ptCalib         <= '1';
                        APPLY_NUC1ptCalib2        <= '0';
                        START_NUC1PTCALIB_VALID   <= '1';
                        NUC_MODE                  <= "10";
                        NUC_MODE_VALID            <= '1';
                        user_settings_mem_wr_req  <= '1';    
                        user_settings_mem_wr_addr <= SET_NUC_MODE;
                        user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"10";            
                    elsif(FPGA_WRDATA(3)= '1')then
                        APPLY_NUC1ptCalib2        <= '1';
                        Start_NUC1ptCalib2        <= '1';
                        APPLY_NUC1ptCalib         <= '0';
                        NUC_MODE                  <= "01";
                        NUC_MODE_VALID            <= '1';
                        user_settings_mem_wr_req  <= '1';    
                        user_settings_mem_wr_addr <= SET_NUC_MODE;
                        user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"01";
                         
                    else
                        if(FPGA_WRDATA(1) = '0' and FPGA_WRDATA(4) = '0')then
                            APPLY_NUC1ptCalib  <= '0';
                            APPLY_NUC1ptCalib2 <= '0';
                            NUC_MODE                  <= "00";
                            NUC_MODE_VALID            <= '1';
                            user_settings_mem_wr_req  <= '1';    
                            user_settings_mem_wr_addr <= SET_NUC_MODE;
                            user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"00";
                        end if;
                    end if;    
            
                elsif(MUX_BLADE_MODE = "11")then
                    if(FPGA_WRDATA(0)= '1')then
                        NUC_MODE                  <= "10";
                        user_settings_mem_wr_req  <= '1';    
                        user_settings_mem_wr_addr <= SET_NUC_MODE;
                        user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"10";
                        NUC_MODE_VALID <= '1';
                    elsif(FPGA_WRDATA(3)= '1')then    
                        NUC_MODE                  <= "01";
                        NUC_MODE_VALID            <= '1';
                        user_settings_mem_wr_req  <= '1';    
                        user_settings_mem_wr_addr <= SET_NUC_MODE;
                        user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"01";
                                   
                    else
                        if(FPGA_WRDATA(1) = '0' and FPGA_WRDATA(4) = '0')then
                            NUC_MODE                  <= "00";
                            NUC_MODE_VALID            <= '1';
                            user_settings_mem_wr_req  <= '1';    
                            user_settings_mem_wr_addr <= SET_NUC_MODE;
                            user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"00";
                        end if;            
                    end if;
                else
                    if(FPGA_WRDATA(4 downto 0) = "00000") then
                        NUC_MODE                  <= "00";
                        NUC_MODE_VALID            <= '1';
                        user_settings_mem_wr_req  <= '1';    
                        user_settings_mem_wr_addr <= SET_NUC_MODE;
                        user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"00";
                    end if;
                   
                end if;    
            
            end if;    
          
--            --NUC1PT_CTRL_REG  <= FPGA_WRDATA; 
----            Start_NUC1ptCalib <= FPGA_WRDATA(0);
--            gain_enable       <= FPGA_WRDATA(2);
----            if(MUX_NUC_MODE = "10" and MUX_BLADE_MODE = "00")then
--            if(MUX_BLADE_MODE = "00")then
--                Start_NUC1ptCalib <= FPGA_WRDATA(0);                
--                if((FPGA_WRDATA(0)= '1') and (FPGA_WRDATA(2)= '0'))then
--                    APPLY_NUC1ptCalib <= '1';
--                    START_NUC1PTCALIB_VALID <= '1';
--                    NUC_MODE                  <=  "10";
--                    user_settings_mem_wr_req  <= '1';    
--                    user_settings_mem_wr_addr <= SET_NUC_MODE; 
--                    user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"10"; 
--                    NUC_MODE_VALID <= '1';
--                else
--                    APPLY_NUC1ptCalib <= FPGA_WRDATA(1);
--                end if;
--            elsif(MUX_BLADE_MODE = "11")then
--                if(FPGA_WRDATA(2)= '1')then
--                    Start_NUC1ptCalib <= FPGA_WRDATA(0);        
--                end if;               
--                if((FPGA_WRDATA(0)= '1') and (FPGA_WRDATA(2)= '0'))then
--                    NUC_MODE                  <=  "10";
--                    user_settings_mem_wr_req  <= '1';    
--                    user_settings_mem_wr_addr <= SET_NUC_MODE; 
--                    user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"10"; 
--                    NUC_MODE_VALID <= '1';
--                end if;             
--            else
--                if(FPGA_WRDATA(2)= '1')then
--                    Start_NUC1ptCalib <= FPGA_WRDATA(0);        
--                end if;                             
--                APPLY_NUC1ptCalib <= '0';
--            end if;    
            
----            if(MUX_NUC_MODE = "01" and MUX_BLADE_MODE = "00")then
--            if(MUX_BLADE_MODE = "00")then
--                Start_NUC1ptCalib2 <= FPGA_WRDATA(3);
--                if(FPGA_WRDATA(3)='1' and FPGA_WRDATA(2)='0') then
--                  APPLY_NUC1ptCalib2 <= '1';
--    --              START_NUC1PT2CALIB_VALID <= '1';
--                    NUC_MODE                  <=  "01";
--                    user_settings_mem_wr_req  <= '1';    
--                    user_settings_mem_wr_addr <= SET_NUC_MODE; 
--                    user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"01"; 
--                    NUC_MODE_VALID <= '1';    
--                else 
--                  APPLY_NUC1ptCalib2 <= FPGA_WRDATA(4);
--                end if;
--            elsif(MUX_BLADE_MODE = "11")then
--                if(FPGA_WRDATA(3)='1' and FPGA_WRDATA(2)='0') then
--                    NUC_MODE                  <=  "01";
--                    user_settings_mem_wr_req  <= '1';    
--                    user_settings_mem_wr_addr <= SET_NUC_MODE; 
--                    user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" &"00"  &"01"; 
--                    NUC_MODE_VALID <= '1';    
--                end if;            
--            else 
--                APPLY_NUC1ptCalib2 <= '0';
--            end if;        

          when SET_GAIN_TABLE_SEL =>
            GAIN_TABLE_SEL <=   FPGA_WRDATA(0);
            
          when SET_GAIN_CALC_CTRL =>
            Start_GAINCalib   <= FPGA_WRDATA(0);
          
          when SET_GAIN_IMG_STORE_ADDR => 
            select_gain_addr <= FPGA_WRDATA(0);    
            
          when SET_TEMP_RANGE =>
            force_temp_range    <=  FPGA_WRDATA(2 downto 0);
            force_temp_range_en <=  FPGA_WRDATA(3); 
            

              
              
              
              
--              user_settings_mem_wr_req  <= '1';    
--              user_settings_mem_wr_addr <= x"00"; 
--              user_settings_mem_wr_data <= x"0F00" & "000" &PAL_nNTSC & ENABLE_RETICLE  & MUX_ENABLE_LOGO  
--                                           & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                                           & ENABLE_SHARPENING_FILTER & FPGA_WRDATA(0) 
--                                           & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
--                                           & ENABLE_NUC &ENABLE_TP ;              
            
                  
--          when SET_IMG_SHIFT_LEFT =>
--            IMG_SHIFT_LR  <=  FPGA_WRDATA(PIX_BITS-1 downto 0); 
--            IMG_SHIFT_LR_SEL  <= '0'; 
--            IMG_SHIFT_LR_UPDATE <= '1';  
           
--          when SET_IMG_SHIFT_RIGHT =>
--            IMG_SHIFT_LR  <=  FPGA_WRDATA(PIX_BITS-1 downto 0); 
--            IMG_SHIFT_LR_SEL  <= '1';
--            IMG_SHIFT_LR_UPDATE <= '1';                
           
--          when SET_IMG_SHIFT_UP =>
--            IMG_SHIFT_UD     <=  FPGA_WRDATA(LIN_BITS-1 downto 0);    
--            IMG_SHIFT_UD_SEL <= '0';
--            IMG_SHIFT_UD_UPDATE <= '1';
                
--          when SET_IMG_SHIFT_DOWN =>
--            IMG_SHIFT_UD     <=  FPGA_WRDATA(LIN_BITS-1 downto 0);  
--            IMG_SHIFT_UD_SEL <= '1';
--            IMG_SHIFT_UD_UPDATE <= '1'; 
            
--          when SET_PIX_POS =>
--            exclude_right <= FPGA_WRDATA(15 DOWNTO 8);
--            exclude_left  <= FPGA_WRDATA(7 DOWNTO 0);

         when SET_IMG_SHIFT_VERT =>
            if(unsigned(FPGA_WRDATA(LIN_BITS-1 downto 0))> 255)then
               IMG_SHIFT_VERT       <= std_logic_vector(to_unsigned(255,10)); 
            else
               IMG_SHIFT_VERT       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
            end if;
             
            IMG_SHIFT_VERT_VALID <= '1';   
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_IMG_SHIFT_VERT; 
            user_settings_mem_wr_data <= SET_IMG_SHIFT_VERT &  x"000" & "00" &FPGA_WRDATA( LIN_BITS-1 downto 0);   
 
         when SET_IMG_UP_SHIFT_VERT =>
            IMG_UP_SHIFT_VERT       <= FPGA_WRDATA(LIN_BITS-1 downto 0);  
--            IMG_UP_SHIFT_VERT_VALID <= '1';   
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_IMG_UP_SHIFT_VERT; 
            user_settings_mem_wr_data <= SET_IMG_UP_SHIFT_VERT &  x"000" & "00" &FPGA_WRDATA( LIN_BITS-1 downto 0);  
                        
         when SET_IMG_CROP_LEFT =>
            IMG_CROP_LEFT             <= FPGA_WRDATA(PIX_BITS-1 downto 0);  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_IMG_CROP_LEFT; 
            user_settings_mem_wr_data <= SET_IMG_CROP_LEFT &  x"000" & "00" &FPGA_WRDATA( PIX_BITS-1 downto 0);   

         when SET_IMG_CROP_RIGHT =>
            IMG_CROP_RIGHT            <= FPGA_WRDATA(PIX_BITS-1 downto 0);  
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_IMG_CROP_RIGHT; 
            user_settings_mem_wr_data <= SET_IMG_CROP_RIGHT &  x"000" & "00" &FPGA_WRDATA( PIX_BITS-1 downto 0);             

         when SET_IMG_CROP_TOP =>
            IMG_CROP_TOP              <= FPGA_WRDATA(LIN_BITS-1 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_IMG_CROP_TOP; 
            user_settings_mem_wr_data <= SET_IMG_CROP_TOP &  x"000" & "00" &FPGA_WRDATA( LIN_BITS-1 downto 0);                             

         when SET_IMG_CROP_BOTTOM =>
            IMG_CROP_BOTTOM           <= FPGA_WRDATA(LIN_BITS-1 downto 0);
            user_settings_mem_wr_req  <= '1';    
            user_settings_mem_wr_addr <= SET_IMG_CROP_BOTTOM; 
            user_settings_mem_wr_data <= SET_IMG_CROP_BOTTOM &  x"000" & "00" &FPGA_WRDATA( LIN_BITS-1 downto 0);                 

         when SET_FIT_TO_SCREEN_EN =>                                         
--            fit_to_screen_en          <= FPGA_WRDATA(0); 
--            fit_to_screen_en_valid    <= '1'; 
            scaling_disable           <= FPGA_WRDATA(1); 
            scaling_disable_valid     <= '1'; 
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_FIT_TO_SCREEN_EN;  
            user_settings_mem_wr_data <= SET_FIT_TO_SCREEN_EN & x"00000" & "00" &FPGA_WRDATA(1 downto 0); 
                        
         when SET_OSD_EN =>
               if(FPGA_WRDATA(0) = '1')then
                 if(ENABLE_OSD = '0')then
                    ENABLE_OSD <= '1';        
                 else
                    ENABLE_OSD <= '0';
                 end if;
               else
                  ENABLE_OSD   <= ENABLE_OSD;
               end if;

         when  SET_OSD_TIMEOUT =>                       
               OSD_TIMEOUT               <= FPGA_WRDATA(15 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_TIMEOUT; 
               user_settings_mem_wr_data <= SET_OSD_TIMEOUT & x"00" & FPGA_WRDATA(15 downto 0);   

         when  SET_OSD_COLOR_INFO =>                       
               OSD_COLOR_INFO            <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_COLOR_INFO; 
               user_settings_mem_wr_data <= SET_OSD_COLOR_INFO & FPGA_WRDATA(23 downto 0); 

         when  SET_CURSOR_COLOR_INFO =>
               CURSOR_COLOR_INFO         <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_CURSOR_COLOR_INFO;
               user_settings_mem_wr_data <= SET_CURSOR_COLOR_INFO & FPGA_WRDATA(23 downto 0); 

         when  SET_OSD_CH_COLOR_INFO1 =>                       
               OSD_CH_COLOR_INFO1        <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_CH_COLOR_INFO1; 
               user_settings_mem_wr_data <= SET_OSD_CH_COLOR_INFO1 & FPGA_WRDATA(23 downto 0); 

         when  SET_OSD_CH_COLOR_INFO2 =>                       
               OSD_CH_COLOR_INFO2        <= FPGA_WRDATA(23 downto 0);   
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_CH_COLOR_INFO2; 
               user_settings_mem_wr_data <= SET_OSD_CH_COLOR_INFO2 & FPGA_WRDATA(23 downto 0); 

         when  SET_OSD_MODE =>         
               OSD_MODE                  <= FPGA_WRDATA(3 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_MODE; 
               user_settings_mem_wr_data <= SET_OSD_MODE & x"00000" & FPGA_WRDATA(3 downto 0);  

         when  SET_OSD_POS_X_LY1_MODE1 =>
               OSD_POS_X_LY1_MODE1       <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_X_LY1_MODE1; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY1_MODE1 & "0" &OSD_POS_X_LY1_MODE1_PN & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY1_MODE1 & "0" & FPGA_WRDATA(10 downto 0) & "0" &OSD_POS_X_LY1_MODE1_PN ; 
               end if;
         when  SET_OSD_POS_Y_LY1_MODE1 =>
               OSD_POS_Y_LY1_MODE1       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_Y_LY1_MODE1;
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY1_MODE1 & "00" & OSD_POS_Y_LY1_MODE1_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY1_MODE1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & OSD_POS_Y_LY1_MODE1_PN; 
               end if;               
               
         when  SET_OSD_POS_X_LY2_MODE1 =>
               OSD_POS_X_LY2_MODE1       <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_X_LY2_MODE1; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY2_MODE1 & "0" &OSD_POS_X_LY2_MODE1_PN & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY2_MODE1 & "0" & FPGA_WRDATA(10 downto 0) & "0" &OSD_POS_X_LY2_MODE1_PN ; 
               end if;           
         
         when  SET_OSD_POS_Y_LY2_MODE1 =>
               OSD_POS_Y_LY2_MODE1       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_Y_LY2_MODE1; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY2_MODE1 & "00" & OSD_POS_Y_LY2_MODE1_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY2_MODE1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & OSD_POS_Y_LY2_MODE1_PN; 
               end if;                

         when  SET_OSD_POS_X_LY3_MODE1 =>
               OSD_POS_X_LY3_MODE1       <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_X_LY3_MODE1; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY3_MODE1 & "0" &OSD_POS_X_LY3_MODE1_PN & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY3_MODE1 & "0" & FPGA_WRDATA(10 downto 0) & "0" &OSD_POS_X_LY3_MODE1_PN ; 
               end if;               
         
         when  SET_OSD_POS_Y_LY3_MODE1 =>
               OSD_POS_Y_LY3_MODE1       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_Y_LY3_MODE1; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY3_MODE1 & "00" & OSD_POS_Y_LY3_MODE1_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY3_MODE1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & OSD_POS_Y_LY3_MODE1_PN; 
               end if;                 

         when  SET_OSD_POS_X_LY1_MODE2 =>
               OSD_POS_X_LY1_MODE2       <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_X_LY1_MODE2; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY1_MODE2 & "0" &OSD_POS_X_LY1_MODE2_PN & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY1_MODE2 & "0" & FPGA_WRDATA(10 downto 0) & "0" &OSD_POS_X_LY1_MODE2_PN ; 
               end if;           
         
         when  SET_OSD_POS_Y_LY1_MODE2 =>
               OSD_POS_Y_LY1_MODE2       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_Y_LY1_MODE2; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY1_MODE2 & "00" & OSD_POS_Y_LY1_MODE2_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY1_MODE2 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & OSD_POS_Y_LY1_MODE2_PN; 
               end if;                    
               
         when  SET_OSD_POS_X_LY2_MODE2 =>
               OSD_POS_X_LY2_MODE2       <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_X_LY2_MODE2; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY2_MODE2 & "0" &OSD_POS_X_LY2_MODE2_PN & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY2_MODE2 & "0" & FPGA_WRDATA(10 downto 0) & "0" &OSD_POS_X_LY2_MODE2_PN ; 
               end if;                
         
         when  SET_OSD_POS_Y_LY2_MODE2 =>
               OSD_POS_Y_LY2_MODE2       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_Y_LY2_MODE2; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY2_MODE2 & "00" & OSD_POS_Y_LY2_MODE2_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY2_MODE2 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & OSD_POS_Y_LY2_MODE2_PN; 
               end if;           

         when  SET_OSD_POS_X_LY3_MODE2 =>
               OSD_POS_X_LY3_MODE2       <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_X_LY3_MODE2; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY3_MODE2 & "0" &OSD_POS_X_LY3_MODE2_PN & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_OSD_POS_X_LY3_MODE2 & "0" & FPGA_WRDATA(10 downto 0) & "0" &OSD_POS_X_LY3_MODE2_PN ; 
               end if;                    
         
         when  SET_OSD_POS_Y_LY3_MODE2 =>
               OSD_POS_Y_LY3_MODE2       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OSD_POS_Y_LY3_MODE2; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY3_MODE2 & "00" & OSD_POS_Y_LY3_MODE2_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_OSD_POS_Y_LY3_MODE2 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & OSD_POS_Y_LY3_MODE2_PN; 
               end if;    

        when SET_TEMPERATURE_OFFSET  =>
               temperature_offset <= FPGA_WRDATA(15 downto 0);
               sub_add_temp_offset<= FPGA_WRDATA(16);
               user_settings_mem_wr_req  <= '1'; 
               user_settings_mem_wr_addr <= SET_TEMPERATURE_OFFSET ; 
               user_settings_mem_wr_data <= SET_TEMPERATURE_OFFSET  & x"0" & "000" & FPGA_WRDATA(16 downto 0);  
                     
        when SET_TEMPERATURE_THRESHOLD =>
               temperature_threshold     <= FPGA_WRDATA(15 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_TEMPERATURE_THRESHOLD ; 
               user_settings_mem_wr_data <= SET_TEMPERATURE_THRESHOLD  & x"00" & FPGA_WRDATA(15 downto 0);  
                                                
         
        when   SET_LO_TO_HI_AREA_GLOBAL_OFFSET_FORCE_VAL =>
               lo_to_hi_area_global_offset_force_val <= FPGA_WRDATA(15 downto 0);
               user_settings_mem_wr_req              <= '1';    
               user_settings_mem_wr_addr             <= SET_LO_TO_HI_AREA_GLOBAL_OFFSET_FORCE_VAL; 
               user_settings_mem_wr_data             <= SET_LO_TO_HI_AREA_GLOBAL_OFFSET_FORCE_VAL & x"00" & FPGA_WRDATA(15 downto 0);  
                         
        when   SET_HI_TO_LO_AREA_GLOBAL_OFFSET_FORCE_VAL =>
               hi_to_lo_area_global_offset_force_val <= FPGA_WRDATA(15 downto 0);
               user_settings_mem_wr_req              <= '1';    
               user_settings_mem_wr_addr             <= SET_HI_TO_LO_AREA_GLOBAL_OFFSET_FORCE_VAL; 
               user_settings_mem_wr_data             <= SET_HI_TO_LO_AREA_GLOBAL_OFFSET_FORCE_VAL & x"00" & FPGA_WRDATA(15 downto 0);  
                   
         when  SET_OLED_OSD_POS_X_LY1 =>
               OLED_OSD_POS_X_LY1        <= FPGA_WRDATA(PIX_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OLED_OSD_POS_X_LY1; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OLED_OSD_POS_X_LY1 & "00" & OLED_OSD_POS_X_LY1_PN & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_OLED_OSD_POS_X_LY1 & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0) & "00" & OLED_OSD_POS_X_LY1_PN; 
               end if; 

         when  SET_OLED_OSD_POS_Y_LY1 =>
               OLED_OSD_POS_Y_LY1        <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_OLED_OSD_POS_Y_LY1;
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_OLED_OSD_POS_Y_LY1 & "00" & OLED_OSD_POS_Y_LY1_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);                
               else
                user_settings_mem_wr_data <= SET_OLED_OSD_POS_Y_LY1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & OLED_OSD_POS_Y_LY1_PN;     
               end if; 
         when  SET_BPR_OSD_POS_X_LY1 =>
               BPR_OSD_POS_X_LY1         <= FPGA_WRDATA(PIX_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BPR_OSD_POS_X_LY1; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_BPR_OSD_POS_X_LY1 & "00" & BPR_OSD_POS_X_LY1_PN & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_BPR_OSD_POS_X_LY1 & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0) & "00" & BPR_OSD_POS_X_LY1_PN;
               end if;

         when  SET_BPR_OSD_POS_Y_LY1 =>
               BPR_OSD_POS_Y_LY1         <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BPR_OSD_POS_Y_LY1;
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_BPR_OSD_POS_Y_LY1 & "00" & BPR_OSD_POS_Y_LY1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_BPR_OSD_POS_Y_LY1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0)  & "00" & BPR_OSD_POS_Y_LY1 ; 
               end if; 
      
--         when  SET_IMG_Y_OFFSET =>
--               IN_Y_OFF                  <= FPGA_WRDATA(9 downto 0); 
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_IMG_Y_OFFSET; 
               user_settings_mem_wr_data <= SET_IMG_Y_OFFSET & x"000" & "00" & FPGA_WRDATA(9 downto 0);      
         
         when  SET_GYRO_DATA_DISP_POS_X_LY1 =>
               GYRO_DATA_DISP_POS_X_LY1  <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_GYRO_DATA_DISP_POS_X_LY1;
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_POS_X_LY1 & "0" & GYRO_DATA_DISP_POS_X_LY1 & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_POS_X_LY1 & "0" & FPGA_WRDATA(10 downto 0)  & "0" & GYRO_DATA_DISP_POS_X_LY1 ; 
               end if; 
               
         when  SET_GYRO_DATA_DISP_POS_Y_LY1 =>
               GYRO_DATA_DISP_POS_Y_LY1  <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_GYRO_DATA_DISP_POS_Y_LY1;
 --            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_POS_Y_LY1 & "00" & GYRO_DATA_DISP_POS_Y_LY1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_POS_Y_LY1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0)  & "00" & GYRO_DATA_DISP_POS_Y_LY1 ; 
               end if; 

         when  SET_GYRO_DATA_DISP_POS_X_LY2 =>
               GYRO_DATA_DISP_POS_X_LY2  <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_GYRO_DATA_DISP_POS_X_LY2;
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_POS_X_LY2 & "0" & GYRO_DATA_DISP_POS_X_LY2 & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_POS_X_LY2 & "0" & FPGA_WRDATA(10 downto 0)  & "0" & GYRO_DATA_DISP_POS_X_LY2 ; 
               end if; 
               
         when  SET_GYRO_DATA_DISP_POS_Y_LY2 =>
               GYRO_DATA_DISP_POS_Y_LY2  <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_GYRO_DATA_DISP_POS_Y_LY2;
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_POS_Y_LY2 & "00" & GYRO_DATA_DISP_POS_Y_LY1 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_POS_Y_LY2 & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0)  & "00" & GYRO_DATA_DISP_POS_Y_LY2 ; 
               end if; 

         when  SET_ENABLE_SN_INFO_DISP =>
               ENABLE_SN_INFO_DISP       <= FPGA_WRDATA(0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_ENABLE_SN_INFO_DISP; 
               user_settings_mem_wr_data <= SET_ENABLE_SN_INFO_DISP & x"00000" & "000" & FPGA_WRDATA(0); 

         when  SET_ENABLE_INFO_DISP =>
               ENABLE_INFO_DISP          <= FPGA_WRDATA(0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_ENABLE_INFO_DISP; 
               user_settings_mem_wr_data <= SET_ENABLE_INFO_DISP & x"00000" & "000" & FPGA_WRDATA(0); 

         when  SET_ENABLE_PRESET_INFO_DISP =>
               ENABLE_PRESET_INFO_DISP          <= FPGA_WRDATA(0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_ENABLE_PRESET_INFO_DISP; 
               user_settings_mem_wr_data <= SET_ENABLE_PRESET_INFO_DISP & x"00000" & "000" & FPGA_WRDATA(0); 

         when  SET_INFO_DISP_COLOR_INFO =>
               INFO_DISP_COLOR_INFO      <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_INFO_DISP_COLOR_INFO; 
               user_settings_mem_wr_data <= SET_INFO_DISP_COLOR_INFO & FPGA_WRDATA(23 downto 0); 

         when  SET_INFO_DISP_CH_COLOR_INFO1 =>                       
               INFO_DISP_CH_COLOR_INFO1  <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_INFO_DISP_CH_COLOR_INFO1; 
               user_settings_mem_wr_data <= SET_INFO_DISP_CH_COLOR_INFO1 & FPGA_WRDATA(23 downto 0); 

         when  SET_INFO_DISP_CH_COLOR_INFO2 =>                       
               INFO_DISP_CH_COLOR_INFO2  <= FPGA_WRDATA(23 downto 0);    
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_INFO_DISP_CH_COLOR_INFO2; 
               user_settings_mem_wr_data <= SET_INFO_DISP_CH_COLOR_INFO2 & FPGA_WRDATA(23 downto 0); 
               
         when  SET_INFO_DISP_POS_X =>
               INFO_DISP_POS_X           <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_INFO_DISP_POS_X; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_INFO_DISP_POS_X & "0" & INFO_DISP_POS_X_PN & "0" & FPGA_WRDATA(10 downto 0);                 
               else
                user_settings_mem_wr_data <= SET_INFO_DISP_POS_X & "0" & FPGA_WRDATA(10 downto 0) & "0" & INFO_DISP_POS_X_PN ;  
               end if;
         when  SET_INFO_DISP_POS_Y =>
               INFO_DISP_POS_Y           <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_INFO_DISP_POS_Y; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_INFO_DISP_POS_Y & "00" & INFO_DISP_POS_Y_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_INFO_DISP_POS_Y & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & INFO_DISP_POS_Y_PN;
               end if;                

         when  SET_SN_INFO_DISP_POS_X =>
               SN_INFO_DISP_POS_X        <= FPGA_WRDATA(PIX_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_SN_INFO_DISP_POS_X; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_SN_INFO_DISP_POS_X & "00" & SN_INFO_DISP_POS_X_PN & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0);                 
               else
                user_settings_mem_wr_data <= SET_SN_INFO_DISP_POS_X & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0) & "00" & SN_INFO_DISP_POS_X_PN;  
               end if;
         when  SET_SN_INFO_DISP_POS_Y =>
               SN_INFO_DISP_POS_Y        <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_SN_INFO_DISP_POS_Y; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_SN_INFO_DISP_POS_Y & "00" & SN_INFO_DISP_POS_Y_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_SN_INFO_DISP_POS_Y & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & SN_INFO_DISP_POS_Y_PN;
               end if; 

         when  SET_PRESET_INFO_DISP_POS_X =>
               PRESET_INFO_DISP_POS_X    <= FPGA_WRDATA(PIX_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_PRESET_INFO_DISP_POS_X; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_PRESET_INFO_DISP_POS_X & "00" & PRESET_INFO_DISP_POS_X_PN & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_PRESET_INFO_DISP_POS_X & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0) & "00" & PRESET_INFO_DISP_POS_X_PN; 
               end if;                 
         
         when  SET_PRESET_INFO_DISP_POS_Y =>
               PRESET_INFO_DISP_POS_Y    <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_PRESET_INFO_DISP_POS_Y; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_PRESET_INFO_DISP_POS_Y & "00" & PRESET_INFO_DISP_POS_Y_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  
               else
                user_settings_mem_wr_data <= SET_PRESET_INFO_DISP_POS_Y & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & PRESET_INFO_DISP_POS_Y_PN ; 
               end if;                

         when  SET_CONTRAST_MODE_INFO_DISP_POS_X =>
               CONTRAST_MODE_INFO_DISP_POS_X <= FPGA_WRDATA(PIX_BITS-1 downto 0);
               user_settings_mem_wr_req      <= '1';    
               user_settings_mem_wr_addr     <= SET_CONTRAST_MODE_INFO_DISP_POS_X; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_CONTRAST_MODE_INFO_DISP_POS_X & "00" & CONTRAST_MODE_INFO_DISP_POS_X_PN & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_CONTRAST_MODE_INFO_DISP_POS_X & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0) & "00" & CONTRAST_MODE_INFO_DISP_POS_X_PN ; 
               end if; 

         when  SET_CONTRAST_MODE_INFO_DISP_POS_Y =>
               CONTRAST_MODE_INFO_DISP_POS_Y <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req      <= '1';    
               user_settings_mem_wr_addr     <= SET_CONTRAST_MODE_INFO_DISP_POS_Y; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_CONTRAST_MODE_INFO_DISP_POS_Y & "00" & CONTRAST_MODE_INFO_DISP_POS_Y_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_CONTRAST_MODE_INFO_DISP_POS_Y & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & CONTRAST_MODE_INFO_DISP_POS_Y_PN ; 
               end if; 

         when  SET_ENABLE_BATTERY_DISP =>
               ENABLE_BATTERY_DISP       <= FPGA_WRDATA(0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_ENABLE_BATTERY_DISP; 
               user_settings_mem_wr_data <= SET_ENABLE_BATTERY_DISP & x"00000" & "000" & FPGA_WRDATA(0); 

--         when  SET_BATTERY_PERCENTAGE =>
--               BATTERY_PERCENTAGE  <= FPGA_WRDATA(7 downto 0);

         when  SET_BATTERY_DISP_TG_WAIT_FRAMES =>
                 BATTERY_DISP_TG_WAIT_FRAMES <= FPGA_WRDATA(7 downto 0);
--                 BATTERY_VOLTAGE             <= FPGA_WRDATA(23 downto 8);
                 user_settings_mem_wr_req    <= '1';    
                 user_settings_mem_wr_addr   <= SET_BATTERY_DISP_TG_WAIT_FRAMES; 
                 user_settings_mem_wr_data   <= SET_BATTERY_DISP_TG_WAIT_FRAMES & x"0000" & FPGA_WRDATA(7 downto 0); 
         
         when  SET_BATTERY_PIX_MAP =>
               BATTERY_PIX_MAP           <= FPGA_WRDATA(7 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_PIX_MAP; 
               user_settings_mem_wr_data <= SET_BATTERY_PIX_MAP & x"0000" & FPGA_WRDATA(7 downto 0); 

         when  SET_BATTERY_CHARGING_START =>
               BATTERY_CHARGING_START  <= FPGA_WRDATA(0);

         when  SET_BATTERY_CHARGE_INC =>
               BATTERY_CHARGE_INC        <= FPGA_WRDATA(15 downto 0);               
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_CHARGE_INC; 
               user_settings_mem_wr_data <= SET_BATTERY_CHARGE_INC & x"00" &FPGA_WRDATA(15 downto 0);                

         when  SET_TARGET_VALUE_THRESHOLD =>
               TARGET_VALUE_THRESHOLD    <= FPGA_WRDATA(15 downto 0);               
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_TARGET_VALUE_THRESHOLD; 
               user_settings_mem_wr_data <= SET_TARGET_VALUE_THRESHOLD & x"00" &FPGA_WRDATA(15 downto 0); 

         when  SET_BATTERY_DISP_COLOR_INFO =>
               BATTERY_DISP_COLOR_INFO   <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_DISP_COLOR_INFO; 
               user_settings_mem_wr_data <= SET_BATTERY_DISP_COLOR_INFO & FPGA_WRDATA(23 downto 0); 

         when  SET_BATTERY_DISP_CH_COLOR_INFO1 =>                       
               BATTERY_DISP_CH_COLOR_INFO1 <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req    <= '1';    
               user_settings_mem_wr_addr   <= SET_BATTERY_DISP_CH_COLOR_INFO1; 
               user_settings_mem_wr_data   <= SET_BATTERY_DISP_CH_COLOR_INFO1 & FPGA_WRDATA(23 downto 0); 

         when  SET_BATTERY_DISP_CH_COLOR_INFO2 =>                       
               BATTERY_DISP_CH_COLOR_INFO2 <= FPGA_WRDATA(23 downto 0);  
               user_settings_mem_wr_req    <= '1';    
               user_settings_mem_wr_addr   <= SET_BATTERY_DISP_CH_COLOR_INFO2; 
               user_settings_mem_wr_data   <= SET_BATTERY_DISP_CH_COLOR_INFO2 & FPGA_WRDATA(23 downto 0); 

         when  SET_BATTERY_DISP_POS_X =>
               BATTERY_DISP_POS_X        <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_DISP_POS_X; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_BATTERY_DISP_POS_X & "0" & BATTERY_DISP_POS_X_PN  & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_BATTERY_DISP_POS_X & "0" & FPGA_WRDATA(10 downto 0) & "0" & BATTERY_DISP_POS_X_PN;
               end if;
         when  SET_BATTERY_DISP_POS_Y =>
               BATTERY_DISP_POS_Y  <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_DISP_POS_Y; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_BATTERY_DISP_POS_Y & "00" & BATTERY_DISP_POS_Y_PN  & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_BATTERY_DISP_POS_Y & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & BATTERY_DISP_POS_Y_PN;
               end if;  
                
         when  SET_BATTERY_DISP_REQ_XSIZE =>
               BATTERY_DISP_REQ_XSIZE    <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_DISP_REQ_XSIZE; 
               user_settings_mem_wr_data <= SET_BATTERY_DISP_REQ_XSIZE & x"000" & "0" & FPGA_WRDATA(10 downto 0); 

         when  SET_BATTERY_DISP_REQ_YSIZE =>
               BATTERY_DISP_REQ_YSIZE    <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_DISP_REQ_YSIZE; 
               user_settings_mem_wr_data <= SET_BATTERY_DISP_REQ_YSIZE & x"000" & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  

         when  SET_BATTERY_DISP_X_OFFSET=>
               BATTERY_DISP_X_OFFSET     <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_DISP_X_OFFSET; 
               user_settings_mem_wr_data <= SET_BATTERY_DISP_X_OFFSET & x"000" & "0" & FPGA_WRDATA(10 downto 0); 

         when  SET_BATTERY_DISP_Y_OFFSET =>
               BATTERY_DISP_Y_OFFSET     <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BATTERY_DISP_Y_OFFSET; 
               user_settings_mem_wr_data <= SET_BATTERY_DISP_Y_OFFSET & x"000" & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);                 

         when  SET_ENABLE_BAT_PER_DISP =>
               ENABLE_BAT_PER_DISP       <= FPGA_WRDATA(0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_ENABLE_BAT_PER_DISP; 
               user_settings_mem_wr_data <= SET_ENABLE_BAT_PER_DISP & x"00000" & "000" & FPGA_WRDATA(0); 

         when  SET_BAT_PER_DISP_COLOR_INFO =>
               BAT_PER_DISP_COLOR_INFO   <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_DISP_COLOR_INFO; 
               user_settings_mem_wr_data <= SET_BAT_PER_DISP_COLOR_INFO & FPGA_WRDATA(23 downto 0); 

         when  SET_BAT_PER_DISP_CH_COLOR_INFO1 =>                       
               BAT_PER_DISP_CH_COLOR_INFO1 <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req    <= '1';    
               user_settings_mem_wr_addr   <= SET_BAT_PER_DISP_CH_COLOR_INFO1; 
               user_settings_mem_wr_data   <= SET_BAT_PER_DISP_CH_COLOR_INFO1 & FPGA_WRDATA(23 downto 0); 

         when  SET_BAT_PER_DISP_CH_COLOR_INFO2 =>                       
               BAT_PER_DISP_CH_COLOR_INFO2 <= FPGA_WRDATA(23 downto 0);  
               user_settings_mem_wr_req    <= '1';    
               user_settings_mem_wr_addr   <= SET_BAT_PER_DISP_CH_COLOR_INFO2; 
               user_settings_mem_wr_data   <= SET_BAT_PER_DISP_CH_COLOR_INFO2 & FPGA_WRDATA(23 downto 0); 

         when  SET_BAT_PER_DISP_POS_X =>
               BAT_PER_DISP_POS_X        <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_DISP_POS_X; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_BAT_PER_DISP_POS_X & "0" & BAT_PER_DISP_POS_X_PN  & "0" & FPGA_WRDATA(10 downto 0); 
               else
                user_settings_mem_wr_data <= SET_BAT_PER_DISP_POS_X & "0" & FPGA_WRDATA(10 downto 0) & "0" & BAT_PER_DISP_POS_X_PN;
               end if;   

         when  SET_BAT_PER_DISP_POS_Y =>
               BAT_PER_DISP_POS_Y        <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_DISP_POS_Y; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_BAT_PER_DISP_POS_Y & "00" & BAT_PER_DISP_POS_Y_PN  & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_BAT_PER_DISP_POS_Y & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & BAT_PER_DISP_POS_Y_PN;
               end if;     
                
         when  SET_BAT_PER_DISP_REQ_XSIZE =>
               BAT_PER_DISP_REQ_XSIZE    <= FPGA_WRDATA(10 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_DISP_REQ_XSIZE; 
               user_settings_mem_wr_data <= SET_BAT_PER_DISP_REQ_XSIZE & x"000" & "0" & FPGA_WRDATA(10 downto 0); 

         when  SET_BAT_PER_DISP_REQ_YSIZE =>
               BAT_PER_DISP_REQ_YSIZE    <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_DISP_REQ_YSIZE; 
               user_settings_mem_wr_data <= SET_BAT_PER_DISP_REQ_YSIZE & x"000" & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  

         when  SET_ENABLE_BAT_CHG_SYMBOL =>
               ENABLE_BAT_CHG_SYMBOL     <= FPGA_WRDATA(0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_ENABLE_BAT_CHG_SYMBOL; 
               user_settings_mem_wr_data <= SET_ENABLE_BAT_CHG_SYMBOL & x"00000" & "000" & FPGA_WRDATA(0); 

         when  SET_BAT_CHG_SYMBOL_POS_OFFSET =>
               BAT_CHG_SYMBOL_POS_OFFSET <= FPGA_WRDATA(11 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_CHG_SYMBOL_POS_OFFSET; 
               user_settings_mem_wr_data <= SET_BAT_CHG_SYMBOL_POS_OFFSET & x"000" & FPGA_WRDATA(11 downto 0); 

         when  SET_BAT_PER_CONV_REG1 =>
               BAT_PER_CONV_REG1         <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_CONV_REG1; 
               user_settings_mem_wr_data <= SET_BAT_PER_CONV_REG1 & FPGA_WRDATA(23 downto 0); 

         when  SET_BAT_PER_CONV_REG2 =>
               BAT_PER_CONV_REG2         <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_CONV_REG2; 
               user_settings_mem_wr_data <= SET_BAT_PER_CONV_REG2 & FPGA_WRDATA(23 downto 0); 

         when  SET_BAT_PER_CONV_REG3 =>
               BAT_PER_CONV_REG3         <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_CONV_REG3; 
               user_settings_mem_wr_data <= SET_BAT_PER_CONV_REG3 & FPGA_WRDATA(23 downto 0); 

         when  SET_BAT_PER_CONV_REG4 =>
               BAT_PER_CONV_REG4         <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_CONV_REG4; 
               user_settings_mem_wr_data <= SET_BAT_PER_CONV_REG4 & FPGA_WRDATA(23 downto 0); 

         when  SET_BAT_PER_CONV_REG5 =>
               BAT_PER_CONV_REG5         <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_CONV_REG5; 
               user_settings_mem_wr_data <= SET_BAT_PER_CONV_REG5 & FPGA_WRDATA(23 downto 0); 

         when  SET_BAT_PER_CONV_REG6 =>
               BAT_PER_CONV_REG6         <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_BAT_PER_CONV_REG6; 
               user_settings_mem_wr_data <= SET_BAT_PER_CONV_REG6 & FPGA_WRDATA(23 downto 0); 

         when  SET_ENABLE_B_BAR_DISP =>
               ENABLE_B_BAR_DISP       <= FPGA_WRDATA(0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_ENABLE_B_BAR_DISP; 
               user_settings_mem_wr_data <= SET_ENABLE_B_BAR_DISP & x"00000" & "000" & FPGA_WRDATA(0);

         when  SET_ENABLE_C_BAR_DISP =>
               ENABLE_C_BAR_DISP       <= FPGA_WRDATA(0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_ENABLE_C_BAR_DISP; 
               user_settings_mem_wr_data <= SET_ENABLE_C_BAR_DISP & x"00000" & "000" & FPGA_WRDATA(0);
               
         when  SET_CB_BAR_DISP_COLOR_INFO =>
               CB_BAR_DISP_COLOR_INFO   <= FPGA_WRDATA(23 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_CB_BAR_DISP_COLOR_INFO; 
               user_settings_mem_wr_data <= SET_CB_BAR_DISP_COLOR_INFO & FPGA_WRDATA(23 downto 0); 

         when  SET_B_BAR_DISP_POS_X =>
               B_BAR_DISP_POS_X          <= FPGA_WRDATA(PIX_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_B_BAR_DISP_POS_X; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_B_BAR_DISP_POS_X & "00" & B_BAR_DISP_POS_X_PN & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_B_BAR_DISP_POS_X & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0) & "00" & B_BAR_DISP_POS_X_PN ;
               end if;
--         when  SET_B_BAR_DISP_POS_Y =>
--               B_BAR_DISP_POS_Y          <= FPGA_WRDATA(LIN_BITS-1 downto 0);
--               user_settings_mem_wr_req  <= '1';    
--               user_settings_mem_wr_addr <= SET_B_BAR_DISP_POS_Y; 
--               if(PAL_nNTSC= '1')then
--                user_settings_mem_wr_data <= SET_B_BAR_DISP_POS_Y & "00" & B_BAR_DISP_POS_Y_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0); 
--               else
--                user_settings_mem_wr_data <= SET_B_BAR_DISP_POS_Y & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & B_BAR_DISP_POS_Y_PN ;
--               end if;  
                
--         when  SET_B_BAR_DISP_REQ_XSIZE =>
--               B_BAR_DISP_REQ_XSIZE      <= FPGA_WRDATA(PIX_BITS-1 downto 0);
--               user_settings_mem_wr_req  <= '1';    
--               user_settings_mem_wr_addr <= SET_B_BAR_DISP_REQ_XSIZE; 
--               user_settings_mem_wr_data <= SET_B_BAR_DISP_REQ_XSIZE & x"000" & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 

         when  SET_B_BAR_DISP_REQ_YSIZE =>
               B_BAR_DISP_REQ_YSIZE      <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_B_BAR_DISP_REQ_YSIZE; 
               user_settings_mem_wr_data <= SET_B_BAR_DISP_REQ_YSIZE & x"000" & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  

--         when  SET_B_BAR_DISP_X_OFFSET=>
--               B_BAR_DISP_X_OFFSET       <= FPGA_WRDATA(PIX_BITS-1 downto 0);
--               user_settings_mem_wr_req  <= '1';    
--               user_settings_mem_wr_addr <= SET_B_BAR_DISP_X_OFFSET; 
--               user_settings_mem_wr_data <= SET_B_BAR_DISP_X_OFFSET & x"000" & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 

         when  SET_B_BAR_DISP_Y_OFFSET =>
               B_BAR_DISP_Y_OFFSET       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_B_BAR_DISP_Y_OFFSET; 
               user_settings_mem_wr_data <= SET_B_BAR_DISP_Y_OFFSET & x"000" & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);                 
         when  SET_C_BAR_DISP_POS_X =>
               C_BAR_DISP_POS_X          <= FPGA_WRDATA(PIX_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_C_BAR_DISP_POS_X; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_C_BAR_DISP_POS_X & "00" & C_BAR_DISP_POS_X_PN & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_C_BAR_DISP_POS_X & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0) & "00" & C_BAR_DISP_POS_X_PN ;
               end if;

         when  SET_C_BAR_DISP_POS_Y =>
               C_BAR_DISP_POS_Y          <= FPGA_WRDATA(LIN_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_C_BAR_DISP_POS_Y; 
--            if(PAL_nNTSC= '1')then
               if(sel_oled_analog_video_out = '0')then 
                user_settings_mem_wr_data <= SET_C_BAR_DISP_POS_Y & "00" & C_BAR_DISP_POS_Y_PN & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0); 
               else
                user_settings_mem_wr_data <= SET_C_BAR_DISP_POS_Y & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0) & "00" & C_BAR_DISP_POS_Y_PN ;
               end if;   
                
         when  SET_C_BAR_DISP_REQ_XSIZE =>
               C_BAR_DISP_REQ_XSIZE      <= FPGA_WRDATA(PIX_BITS-1 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_C_BAR_DISP_REQ_XSIZE; 
               user_settings_mem_wr_data <= SET_C_BAR_DISP_REQ_XSIZE & x"000" & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 

--         when  SET_C_BAR_DISP_REQ_YSIZE =>
--               C_BAR_DISP_REQ_YSIZE      <= FPGA_WRDATA(LIN_BITS-1 downto 0);
--               user_settings_mem_wr_req  <= '1';    
--               user_settings_mem_wr_addr <= SET_C_BAR_DISP_REQ_YSIZE; 
--               user_settings_mem_wr_data <= SET_C_BAR_DISP_REQ_YSIZE & x"000" & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);  

         when  SET_WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE =>
               WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE      <= FPGA_WRDATA(7 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE; 
               user_settings_mem_wr_data <= SET_WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE & x"0000" & FPGA_WRDATA(7 downto 0);  


--         when  SET_C_BAR_DISP_X_OFFSET=>
--               C_BAR_DISP_X_OFFSET       <= FPGA_WRDATA(PIX_BITS-1 downto 0);
--               user_settings_mem_wr_req  <= '1';    
--               user_settings_mem_wr_addr <= SET_C_BAR_DISP_X_OFFSET; 
--               user_settings_mem_wr_data <= SET_C_BAR_DISP_X_OFFSET & x"000" & "00" & FPGA_WRDATA(PIX_BITS-1 downto 0); 

         when  SET_GYRO_CALIB_START =>
               GYRO_CALIB_EN             <= FPGA_WRDATA(0);
--               user_settings_mem_wr_req  <= '1';    
--               user_settings_mem_wr_addr <= SET_GYRO_CALIB_START; 
--               user_settings_mem_wr_data <= SET_GYRO_CALIB_START & x"00000" & "000" & FPGA_WRDATA(0); 


--         when  SET_C_BAR_DISP_Y_OFFSET =>
--               C_BAR_DISP_Y_OFFSET       <= FPGA_WRDATA(LIN_BITS-1 downto 0);
--               user_settings_mem_wr_req  <= '1';    
--               user_settings_mem_wr_addr <= SET_C_BAR_DISP_Y_OFFSET; 
--               user_settings_mem_wr_data <= SET_C_BAR_DISP_Y_OFFSET & x"000" & "00" & FPGA_WRDATA(LIN_BITS-1 downto 0);          

         when SET_YAW_OFFSET =>
               yaw_offset   <= FPGA_WRDATA(15 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_YAW_OFFSET; 
               user_settings_mem_wr_data <= SET_YAW_OFFSET & x"00"& FPGA_WRDATA(15 downto 0); 
         
         when SET_PITCH_OFFSET =>
               pitch_offset <= FPGA_WRDATA(15 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_PITCH_OFFSET; 
               user_settings_mem_wr_data <= SET_PITCH_OFFSET & x"00"& FPGA_WRDATA(15 downto 0); 

         when  SET_I2C_DELAY_REG => 
               I2C_DELAY_REG <= FPGA_WRDATA(15 downto 0);
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_I2C_DELAY_REG; 
               user_settings_mem_wr_data <= SET_I2C_DELAY_REG & x"00"& FPGA_WRDATA(15 downto 0); 

         when SET_AUTO_SHUTTER_TIMEOUT =>
               AUTO_SHUTTER_TIMEOUT      <= FPGA_WRDATA(15 downto 0); 
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_AUTO_SHUTTER_TIMEOUT; 
               user_settings_mem_wr_data <= SET_AUTO_SHUTTER_TIMEOUT & x"00"& FPGA_WRDATA(15 downto 0); 
                        
         when SET_FRAME_COUNTER_NUC1PT_DELAY =>
               FRAME_COUNTER_NUC1PT_DELAY <= FPGA_WRDATA(15 downto 0); 
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_FRAME_COUNTER_NUC1PT_DELAY; 
               user_settings_mem_wr_data <= SET_FRAME_COUNTER_NUC1PT_DELAY & x"00"& FPGA_WRDATA(15 downto 0);         
         
         when  SET_MENU_SEL_CENTER =>
               MENU_SEL_CENTER_U       <= FPGA_WRDATA(0);
        
         when  SET_MENU_SEL_LEFT =>
               MENU_SEL_LEFT_U       <= FPGA_WRDATA(0);
--               cmd_adv_sleep_mode_en  <= FPGA_WRDATA(0);
--               if(FPGA_WRDATA(0) = '1')then
--                   if(main_menu_sel = '1')then            
--                    main_menu_sel         <= '0';
--                   else               
--                    main_menu_sel         <= '1';
--                   end if; 
--               end if; 
         when  SET_MENU_SEL_RIGHT =>
               MENU_SEL_RIGHT_U         <= FPGA_WRDATA(0);
--               RETICLE_OFFSET_RD_ADDR   <= FPGA_WRDATA(3 downto 0);
--               RETICLE_OFFSET_RD_REQ    <= FPGA_WRDATA(4);
--               CMD_STANDBY_EN         <= FPGA_WRDATA(0);
--               cmd_oled_reinit_en     <= FPGA_WRDATA(1);
--               CMD_OLED_RESET         <= FPGA_WRDATA(2);
--               ADVANCE_MENU_TRIG_IN_REG <= FPGA_WRDATA(0);
--               if(FPGA_WRDATA(0) = '1')then
--                   if(advance_menu_sel = '1')then            
--                    advance_menu_sel         <= '0';
--                   else               
--                    advance_menu_sel         <= '1';
--                   end if; 
--               end if; 

         when  SET_MENU_SEL_UP =>                    
               MENU_SEL_UP_U         <= FPGA_WRDATA(0);

         when  SET_MENU_SEL_DN =>
               MENU_SEL_DN_U         <= FPGA_WRDATA(0);
               
         when SET_MAX_RELEASE_WAIT_TIME =>    
               MAX_RELEASE_WAIT_TIME     <= FPGA_WRDATA(11 downto 0);  
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_MAX_RELEASE_WAIT_TIME; 
               user_settings_mem_wr_data <= SET_MAX_RELEASE_WAIT_TIME & x"000"& FPGA_WRDATA(11 downto 0);           
               
              
         when SET_MIN_TIME_GAP_PRESS_RELEASE  =>    
               MIN_TIME_GAP_PRESS_RELEASE<= FPGA_WRDATA(11 downto 0);  
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_MIN_TIME_GAP_PRESS_RELEASE ; 
               user_settings_mem_wr_data <= SET_MIN_TIME_GAP_PRESS_RELEASE  & x"000"& FPGA_WRDATA(11 downto 0);  

         when SET_MAX_UP_DOWN_PRESS_TIME =>    
               MAX_UP_DOWN_PRESS_TIME    <= FPGA_WRDATA(15 downto 0);  
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_MAX_UP_DOWN_PRESS_TIME; 
               user_settings_mem_wr_data <= SET_MAX_UP_DOWN_PRESS_TIME & x"00" &FPGA_WRDATA(15 downto 0); 

         when SET_MAX_MENU_DOWN_PRESS_TIME =>    
               MAX_MENU_DOWN_PRESS_TIME  <= FPGA_WRDATA(15 downto 0);  
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_MAX_MENU_DOWN_PRESS_TIME; 
               user_settings_mem_wr_data <= SET_MAX_MENU_DOWN_PRESS_TIME & x"00"& FPGA_WRDATA(15 downto 0); 

         when SET_LONG_PRESS_STEP_SIZE =>    
               LONG_PRESS_STEP_SIZE      <= FPGA_WRDATA(11 downto 0);                
               user_settings_mem_wr_req  <= '1';    
               user_settings_mem_wr_addr <= SET_LONG_PRESS_STEP_SIZE; 
               user_settings_mem_wr_data <= SET_LONG_PRESS_STEP_SIZE & x"000"& FPGA_WRDATA(11 downto 0); 

         when SET_MAX_PRESET_SAVE_OK_DISP_FRAMES =>    
               MAX_PRESET_SAVE_OK_DISP_FRAMES  <= FPGA_WRDATA(15 downto 0);  
               user_settings_mem_wr_req        <= '1';    
               user_settings_mem_wr_addr       <= SET_MAX_PRESET_SAVE_OK_DISP_FRAMES; 
               user_settings_mem_wr_data       <= SET_MAX_PRESET_SAVE_OK_DISP_FRAMES & x"00" &FPGA_WRDATA(15 downto 0); 

         when SET_OLED_DISP_EN_TIME_GAP  =>
               OLED_DISP_EN_TIME_GAP           <= FPGA_WRDATA(15 downto 0); 
               user_settings_mem_wr_req        <= '1';    
               user_settings_mem_wr_addr       <= SET_OLED_DISP_EN_TIME_GAP; 
               user_settings_mem_wr_data       <= SET_OLED_DISP_EN_TIME_GAP & x"00" &FPGA_WRDATA(15 downto 0); 

         when SET_BPR_DISP_EN_TIME_GAP  =>
               BPR_DISP_EN_TIME_GAP            <= FPGA_WRDATA(15 downto 0); 
               user_settings_mem_wr_req        <= '1';    
               user_settings_mem_wr_addr       <= SET_BPR_DISP_EN_TIME_GAP; 
               user_settings_mem_wr_data       <= SET_BPR_DISP_EN_TIME_GAP & x"00" &FPGA_WRDATA(15 downto 0);  
         
         when SET_MAX_AGC_MODE_INFO_DISP_TIME => 
               MAX_AGC_MODE_INFO_DISP_TIME     <= FPGA_WRDATA(15 downto 0);                
               user_settings_mem_wr_req        <= '1';    
               user_settings_mem_wr_addr       <= SET_MAX_AGC_MODE_INFO_DISP_TIME; 
               user_settings_mem_wr_data       <= SET_MAX_AGC_MODE_INFO_DISP_TIME & x"00" &FPGA_WRDATA(15 downto 0); 
         
         when SET_DARK_PIX_TH =>
               DARK_PIX_TH <= FPGA_WRDATA(BIT_WIDTH-1 downto 0);
               
         when SET_SATURATED_PIX_TH =>
               SATURATED_PIX_TH <= FPGA_WRDATA(BIT_WIDTH-1 downto 0);

         when SET_BAD_BLIND_PIX_LOW_TH =>
               BAD_BLIND_PIX_LOW_TH  <= FPGA_WRDATA(BIT_WIDTH-1 downto 0);
               
         when SET_BAD_BLIND_PIX_HIGH_TH  =>
               BAD_BLIND_PIX_HIGH_TH  <= FPGA_WRDATA(BIT_WIDTH-1 downto 0);

          when SET_CO_TRIGGER_CALC =>
              update_coarse_offset_write <= '1';
              update_coarse_offset_address <= x"0";
              update_coarse_offset_writedata <= FPGA_WRDATA;

          when SET_CO_PIX_ADDR =>
              update_coarse_offset_write <= '1';
              update_coarse_offset_address <= x"1";
              update_coarse_offset_writedata <= FPGA_WRDATA;

          when SET_CO_CO_ADDR =>
              update_coarse_offset_write <= '1';
              update_coarse_offset_address <= x"2";
              update_coarse_offset_writedata <= FPGA_WRDATA;

          when SET_CO_CALC_MODE =>
              update_coarse_offset_write <= '1';
              update_coarse_offset_address <= x"6";
              update_coarse_offset_writedata <= FPGA_WRDATA;

          when SET_CO_DC =>
              update_coarse_offset_write <= '1';
              update_coarse_offset_address <= x"7";
              update_coarse_offset_writedata <= FPGA_WRDATA;

          when SET_CO_MODE =>
              select_co_bus <= FPGA_WRDATA(0);            
              
          when others =>
        end case;

      elsif FPGA_RDREQ = '1' then
        FPGA_RDDAV <= '1';        
        
        case FPGA_ADDR(7 downto 0) is
          when GET_VIDEO_CTRL =>
            FPGA_RDDATA <= VIDEO_CTRL_REG;

          when GET_IMAGE_WIDTH_FULL =>
            FPGA_RDDATA <=  x"00000" & "00" & image_width_full;
            
          when GET_TEMP_PIXELS_LEFT_RIGHT =>
            FPGA_RDDATA <=  x"00" & "00" & temp_pixels_left & "00" & temp_pixels_right;

          when GET_EXCLUDE_LEFT_RIGHT =>
            FPGA_RDDATA <=  x"0000" & exclude_left & exclude_right;

          when GET_PRODUCT_SEL  => 
            FPGA_RDDATA <= x"00000"&"000" & force_analog_video_out &lens_shutter_en & shutter_en & parallel_16bit_en & bat_adc_en & "0" & spi_mode  & product_sel;

          when GET_OLED_ANALOG_VIDEO_OUT_SEL  =>
            FPGA_RDDATA <= x"0000000" & "000" & sel_oled_analog_video_out ;

          when GET_LASER_EN  =>
            FPGA_RDDATA <= x"0000000" & "000" & MUX_LASER_EN;
          
          when GET_SNAPSHOT_BURST_MODE_CAPTURE_SIZE =>
            FPGA_RDDATA <= x"000000" & burst_capture_size ;
            
          when GET_MIPI_VIDEO_OUT_SEL =>
            FPGA_RDDATA <= x"00000" & spi_slave_debug_reg & "0"& usb_video_data_out_sel & usb_video_data_out_sel_reg & mipi_video_data_out_sel;
            
          when GET_TEMP_RANGE_UPDATE_TIMEOUT =>
            FPGA_RDDATA <=  x"0000" & temp_range_update_timeout;
        
--          when RESTART_SENSOR_CMD =>
--            FPGA_RDDATA   <= x"0000000" & "000" &restart_sensor;
          when GET_UPDATE_DEVICE_ID_REG1 =>
            FPGA_RDDATA   <= x"00" & update_device_id_reg(23 downto 0) ;
          
          when GET_UPDATE_DEVICE_ID_REG2 =>
            FPGA_RDDATA   <= x"000000" &update_device_id_reg(31 downto 24) ; 
        
--          when GET_DEVICE_ID =>
--            FPGA_RDDATA   <= device_id ;

          when GET_OLED_GAMMA_TABLE_SEL => 
            FPGA_RDDATA  <= x"000000" & MUX_OLED_GAMMA_TABLE_SEL;

          when GET_OLED_POS_V =>                     
            FPGA_RDDATA  <= x"000000" & MUX_OLED_POS_V;

          when GET_OLED_POS_H =>                     
            FPGA_RDDATA  <= x"00000" &"000"& MUX_OLED_POS_H;
 
          when GET_OLED_BRIGHTNESS =>                     
            FPGA_RDDATA  <= x"000000" & MUX_OLED_BRIGHTNESS;
 
          when GET_OLED_CONTRAST =>                     
            FPGA_RDDATA  <= x"000000" & MUX_OLED_CONTRAST;

          when GET_OLED_IDRF =>                     
            FPGA_RDDATA  <= x"000000" & OLED_IDRF;

          when GET_OLED_DIMCTL =>                     
            FPGA_RDDATA  <= x"000000" & MUX_OLED_DIMCTL;      
            
--          when GET_MAX_VGN_SETTLE_TIME  =>
--            FPGA_RDDATA  <= x"000000" & MAX_VGN_SETTLE_TIME; 

          when GET_OLED_CATHODE_VOLTAGE  =>
            FPGA_RDDATA  <= x"000000" & OLED_CATHODE_VOLTAGE;
                        
          when GET_MAX_OLED_VGN_RD_PERIOD  =>
            FPGA_RDDATA  <= x"0000" & MAX_OLED_VGN_RD_PERIOD; 
                
          when GET_MAX_BAT_PARAM_RD_PERIOD  =>
            FPGA_RDDATA  <= x"0000" & MAX_BAT_PARAM_RD_PERIOD; 
                  
                        
--          when GET_MODULE_EN_DIS =>
--            FPGA_RDDATA   <=  x"0F00" & "00" &PAL_nNTSC & MUX_ENABLE_EDGE  & MUX_ENABLE_LOGO  
--                              & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                              & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
--                              & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
--                              & ENABLE_NUC &ENABLE_TP;
          when GET_SIGHT_MODE =>
            FPGA_RDDATA <= x"0000000" & "00" & SIGHT_MODE;    
                              
          when GET_TEST_PATTERN_EN =>   
            FPGA_RDDATA   <= x"0000000" & "000" &ENABLE_TP ;
          when GET_NUC_EN => 
            FPGA_RDDATA   <= x"0000000" & "00"&ENABLE_UNITY_GAIN &ENABLE_NUC;            
          when GET_SOFTNUC_EN =>     
            FPGA_RDDATA   <= x"0000000" & "000" &MUX_ENABLE_SNUC ; 
          when GET_POLARITY =>
            FPGA_RDDATA   <= x"0000000" & "00" &MUX_POLARITY ;
          when GET_BH_OFFSET =>
            FPGA_RDDATA   <= x"000000" & BH_OFFSET; 
          when GET_RETICLE_EN =>  
            FPGA_RDDATA   <= x"0000000" & "000" &MUX_RETICLE_ENABLE   ;     
          when GET_COLOR_PALETTE_EN =>  
            FPGA_RDDATA   <= x"0000000" & "000" &MUX_CP_ENABLE  ;
          when GET_LOGO_EN => 
            FPGA_RDDATA   <= x"0000000" & "000" &MUX_ENABLE_LOGO   ;         
          when GET_BADPIXREM_EN => 
            FPGA_RDDATA   <= x"0000000" & "00" & blind_badpix_remove_en &ENABLE_BADPIXREM ;       
          when GET_SHARPNENING_FILTER_EN =>
            FPGA_RDDATA   <= x"0000000" & "000" &ENABLE_SHARPENING_FILTER;
          when GET_BRIGHT_CONTRAST_EN =>   
--            FPGA_RDDATA   <= x"0000000" & "000" &ENABLE_BRIGHT_CONTRAST;
          when GET_SMOOTH_FILTER_EN   =>
            FPGA_RDDATA   <= x"0000000" & "000" &MUX_ENABLE_SMOOTHING   ;
            FPGA_RDDATA   <= OLED_VGN_TEST;
          when GET_EDGE_FILTER_EN   =>
            FPGA_RDDATA   <= x"0000000" & "000" &MUX_ENABLE_EDGE   ;
          when GET_PAL_NTSC_MODE   =>
            FPGA_RDDATA   <= x"0000000" & "000" & PAL_nNTSC  ;

          when GET_ZOOM_EN  =>    
            FPGA_RDDATA   <= x"0000000" & "000" & ENABLE_ZOOM;      
          when GET_NUC1PT_CAPTURE_FRAMES =>
            FPGA_RDDATA <= x"0000000" & NUC1pt_Capture_Frames ;    
          when GET_THRESHOLD_SOBL =>
            FPGA_RDDATA <= x"000000" & THRESHOLD_SOBL ;
          when GET_BPC_TH =>
            FPGA_RDDATA <= x"0000" & BPC_TH;    
            
          when GET_SHARPNESS =>                 
            FPGA_RDDATA <= x"0000000" & MUX_SHARPNESS;  
              
          when GET_EDGE_LEVEL =>                  
            FPGA_RDDATA <= x"0000" & "00" &EDGE_THRESHOLD;           
                             
--          when GET_SHARPNESS =>                 
--            FPGA_RDDATA <= AV_KERN_ADDR_SFILT & AV_KERN_WRDATA_SFILT;  
          when GET_OLED_IMG_FLIP =>
            FPGA_RDDATA <= x"000000" & OLED_IMG_FLIP;   
          when GET_IMG_FLIP =>
            FPGA_RDDATA <= x"0000000" & "00" & IMG_FLIP_V &  IMG_FLIP_H;  
          when GET_ZOOM_MODE =>
            FPGA_RDDATA <= x"0000000" & "0" & MUX_ZOOM_MODE;            
          when GET_BRIGHTNESS =>
            FPGA_RDDATA <= x"000000" & MUX_BRIGHTNESS ;  
          when GET_BRIGHTNESS_OFFSET =>
            FPGA_RDDATA <= x"000000" & BRIGHTNESS_OFFSET ;  
          when GET_CONTRAST_OFFSET =>
            FPGA_RDDATA <= x"000000" & CONTRAST_OFFSET ;                                         
          when GET_CONTRAST =>
            FPGA_RDDATA <= x"000000" &MUX_CONTRAST;   
          when GET_CONSTANT_CB_CR =>                      
            FPGA_RDDATA <= x"0000" & CONSTANT_CB_CR ; 
          when GET_COLOR_PALETTE_MODE =>   
            FPGA_RDDATA   <= x"000000" & "000" & MUX_CP_TYPE;
          when GET_CP_MIN_MAX_VAL =>         
            FPGA_RDDATA <= x"00" & CP_MAX_VALUE & x"00" & CP_MIN_VALUE;  
          when GET_LOGO_POS_X =>   
            FPGA_RDDATA <= x"00000" & "0" & LOGO_POS_X ;       
          when GET_LOGO_POS_Y =>   
            FPGA_RDDATA <= x"00000" & "00" & LOGO_POS_Y ; 
          when GET_LOGO_COLOR1 =>   
            FPGA_RDDATA <= x"00" & LOGO_COLOR_INFO1;             
          when GET_LOGO_COLOR2 =>   
            FPGA_RDDATA <= x"00" & LOGO_COLOR_INFO2;  
          when GET_NUC_MODE =>   
            FPGA_RDDATA   <= x"0000000" & "00" & MUX_NUC_MODE;            
          when GET_BLADE_MODE =>   
            FPGA_RDDATA   <= x"0000000" & "00" & MUX_BLADE_MODE;              
          when GET_RETICLE_SEL =>  
            FPGA_RDDATA <= x"0000000"  & MUX_RETICLE_SEL; 
          when GET_RETICLE_TYPE =>  
            FPGA_RDDATA <= x"0000000"  & MUX_RETICLE_TYPE;  
          when GET_RETICLE_POS_X =>   
            FPGA_RDDATA <= x"00000" & MUX_RETICLE_POS_YX(11 downto 0) ;      
          when GET_RETICLE_POS_Y =>   
            FPGA_RDDATA <= x"00000" & MUX_RETICLE_POS_YX(23 downto 12) ;
          when GET_RETICLE_COLOR_SEL =>  
            FPGA_RDDATA   <= x"0000000" & "0" &MUX_RETICLE_COLOR_SEL  ; 
          when GET_RETICLE_COLOR1 =>
            FPGA_RDDATA <= x"00" & RETICLE_COLOR_INFO1;
          when GET_RETICLE_COLOR2 =>
            FPGA_RDDATA <= x"00" & RETICLE_COLOR_INFO2; 
          when GET_RETICLE_COLOR_TH =>
            FPGA_RDDATA <= x"0000" & RETICLE_COLOR_TH;
          when GET_COLOR_SEL_WINDOW_XSIZE =>
            FPGA_RDDATA <= x"00000" & "00" & COLOR_SEL_WINDOW_XSIZE;
          when GET_COLOR_SEL_WINDOW_YSIZE =>
            FPGA_RDDATA <= x"00000" & "00" & COLOR_SEL_WINDOW_YSIZE;            
          when GET_FIRING_MODE =>
            FPGA_RDDATA <= x"0000000" & "000" & MUX_FIRING_MODE;
          when GET_FIRING_DISTANCE =>
            FPGA_RDDATA <= x"0000000"  & MUX_DISTANCE_SEL;
          when GET_PRESET_SEL =>
            FPGA_RDDATA <= x"0000000" & MUX_PRESET_SEL; 
          when GET_PRESET_P1_POS =>
            FPGA_RDDATA <= x"00" & MUX_PRESET_P1_POS;  
          when GET_PRESET_P2_POS =>
            FPGA_RDDATA <= x"00" & MUX_PRESET_P2_POS;  
          when GET_PRESET_P3_POS =>
            FPGA_RDDATA <= x"00" & MUX_PRESET_P3_POS;              
          when GET_PRESET_P4_POS =>
            FPGA_RDDATA <= x"00" & MUX_PRESET_P4_POS;            
          when GET_AGC_MODE=>
            FPGA_RDDATA   <= x"0000000" & "00" &MUX_AGC_MODE_SEL ;
          when  GET_AGC_MAX_GAIN =>   
            FPGA_RDDATA <= x"000000"&  MAX_GAIN  ;
          when GET_MAX_LIMITER_DPHE =>
            FPGA_RDDATA <= x"000000" &MUX_MAX_LIMITER_DPHE ;  
          when GET_MUL_MAX_LIMITER_DPHE =>
            FPGA_RDDATA <= x"000000" &MUX_MUL_MAX_LIMITER_DPHE ;  
          when GET_CNTRL_MIN_DPHE =>
            FPGA_RDDATA <= x"00" &CNTRL_MIN_DPHE  ;
          when GET_CNTRL_MAX_DPHE =>
            FPGA_RDDATA <= x"00" &CNTRL_MAX_DPHE   ;
          when GET_CNTRL_HIST1_DPHE =>
            FPGA_RDDATA <= x"00" &CNTRL_HIST1_DPHE ;
          when GET_CNTRL_HIST2_DPHE =>
            FPGA_RDDATA <= x"00" &CNTRL_HIST2_DPHE ;
          when GET_CNTRL_CLIP_DPHE =>
            FPGA_RDDATA <= x"00" &CNTRL_CLIP_DPHE ;
          when GET_CNTRL_MIN_HISTEQ =>
            FPGA_RDDATA <= x"00" &CNTRL_MIN_HISTEQ;  
          when GET_CNTRL_MAX_HISTEQ =>
            FPGA_RDDATA <= x"00" &CNTRL_MAX_HISTEQ;    
          when GET_CNTRL_HISTORY_HISTEQ =>
            FPGA_RDDATA <= x"00" &CNTRL_HISTORY_HISTEQ; 
          when GET_CNTRL_MAX_GAIN =>
            FPGA_RDDATA <= x"000000" &MUX_CNTRL_MAX_GAIN; 
          when GET_CNTRL_IPP =>
            FPGA_RDDATA <= x"000000" &MUX_CNTRL_IPP; 
                        
          when  GET_ROI_MODE =>                     
            FPGA_RDDATA <= x"0000000" & "000" &ROI_MODE   ;
--          when  GET_ROI_X_OFFSET    =>
--            FPGA_RDDATA <= x"00000" & "00" & ROI_X_OFFSET ;              
--          when  GET_ROI_Y_OFFSET    =>
--            FPGA_RDDATA <= x"00000" & "00" & ROI_Y_OFFSET;             
--          when  GET_ROI_X_SIZE =>
--            FPGA_RDDATA <= x"00000" & "00" & ROI_X_SIZE ;              
--          when  GET_ROI_Y_SIZE =>   
--            FPGA_RDDATA <= x"00000" & "00" & ROI_Y_SIZE ; 
          when GET_GYRO_DATA_UPDATE_TIMEOUT =>
            FPGA_RDDATA <= x"0000" &  GYRO_DATA_UPDATE_TIMEOUT; 
          when GET_GYRO_DATA_DISP_EN =>
            FPGA_RDDATA <= x"0000000" & "00" &  GYRO_DATA_DISP_MODE & MUX_GYRO_DATA_DISP_EN; 
            
          when GET_FPGA_VERSION =>
            FPGA_RDDATA    <= FPGA_VERSION_REG;
--          when GET_CLIP_THRESHOLD =>
--            FPGA_RDDATA <= x"000" & '0' &Clip_Threshold;
          when GET_OFFSET_TBALE_FORCE =>
            FPGA_RDDATA <= OFFSET_TBALE_FORCE; 
          when GET_NUC_TIME_GAP =>
            FPGA_RDDATA <= x"0000" &NUC_TIME_GAP;        
          when GET_NUC1PT_CTRL =>
            FPGA_RDDATA <= x"000000" & "000"  & APPLY_NUC1ptCalib2 &Start_NUC1ptCalib2 & gain_enable & APPLY_NUC1ptCalib &Start_NUC1ptCalib ;         
          when GET_GAIN_TABLE_SEL =>
            FPGA_RDDATA <= x"0000000" & "000" & GAIN_TABLE_SEL;        
          when GET_GAIN_CALC_CTRL =>
            FPGA_RDDATA <=  x"0000000" & "000" &Start_GAINCalib ;        
          when GET_GAIN_IMG_STORE_ADDR => 
            FPGA_RDDATA <=  x"0000000" & "000" & select_gain_addr;       
          when GET_TEMP_RANGE =>
            FPGA_RDDATA <= x"0000000"  & force_temp_range_en & force_temp_range;
--          When GET_IMG_SHIFT_POS_X =>
--            FPGA_RDDATA<= x"00000" & "00" &IMG_SHIFT_POS_X;       
--          When GET_IMG_SHIFT_POS_Y =>      
--            FPGA_RDDATA<= x"00000" & "00" &IMG_SHIFT_POS_Y; 
--          when GET_IMG_SHIFT_LEFT =>
--            FPGA_RDDATA <= IMG_SHIFT_LR_SEL & "000" & x"0000" & "00" & IMG_SHIFT_LR;              
--          when GET_IMG_SHIFT_RIGHT =>
--            FPGA_RDDATA <= IMG_SHIFT_LR_SEL & "000" & x"0000" & "00" &IMG_SHIFT_LR ;                  
--          when GET_IMG_SHIFT_UP =>
--            FPGA_RDDATA <= IMG_SHIFT_UD_SEL & "000" & x"0000" & "00" & IMG_SHIFT_UD;                  
--          when GET_IMG_SHIFT_DOWN =>
--            FPGA_RDDATA <= IMG_SHIFT_UD_SEL & "000" & x"0000" & "00" &IMG_SHIFT_UD ;       

          when GET_IMG_SHIFT_VERT =>
            FPGA_RDDATA <= x"00000" & "00" & IMG_SHIFT_VERT; 

          when GET_IMG_UP_SHIFT_VERT =>
            FPGA_RDDATA <= x"00000" & "00" & IMG_UP_SHIFT_VERT;

          when GET_IMG_CROP_LEFT =>
            FPGA_RDDATA <=  x"00000" & "00" & IMG_CROP_LEFT ;  
          when GET_IMG_CROP_RIGHT =>
            FPGA_RDDATA <=  x"00000" & "00" & IMG_CROP_RIGHT ; 
          when GET_IMG_CROP_TOP =>
            FPGA_RDDATA <=  x"00000" & "00" & IMG_CROP_TOP ;              
          when GET_IMG_CROP_BOTTOM =>
            FPGA_RDDATA <=  x"00000" & "00" & IMG_CROP_BOTTOM ; 
          
          when GET_FIT_TO_SCREEN_EN =>
            FPGA_RDDATA <=  x"0000000" & "00" & mux_scaling_disable & mux_fit_to_screen_en;
                   
          when GET_OFFSET_TABLE_AVG =>  
            FPGA_RDDATA <= x"0000" & offset_img_avg;            
          when GET_IMG_MIN =>
            FPGA_RDDATA <= x"0000" & "00" &IMG_MIN;
          when GET_IMG_MAX =>   
            FPGA_RDDATA <= x"0000" & "00" &IMG_MAX;  
          when GET_IMG_AVG =>
            FPGA_RDDATA <= x"0000" & "00" &IMG_AVG;              
          when GET_CUR_OFF_TABLE =>  
            FPGA_RDDATA <= x"000000" & '0' & CUR_OFFSET_TABLE;
          when GET_CUR_GAIN_TABLE =>
            FPGA_RDDATA <= x"0000000" & '0' &CUR_GAIN_TABLE;
          when GET_CUR_TEMP_AREA  =>     
            FPGA_RDDATA <= x"0000000" & "0" &CUR_TEMP_AREA;                     
--          when GET_PIX_POS =>
--            FPGA_RDDATA<=  x"0000" & exclude_right & exclude_left; 
         when GET_TEMP_AVG_FRAME =>
           -- FPGA_RDDATA <= Sensor_Temperature;
            FPGA_RDDATA <= x"0000" & TEMPERATURE;      
 
         when  GET_OSD_COLOR_INFO =>
             FPGA_RDDATA  <= x"00" & OSD_COLOR_INFO ;

         when  GET_CURSOR_COLOR_INFO =>
             FPGA_RDDATA  <= x"00" & CURSOR_COLOR_INFO ;
             
         when  GET_OSD_CH_COLOR_INFO1 =>
             FPGA_RDDATA  <= x"00" & OSD_CH_COLOR_INFO1 ; 

         when  GET_OSD_CH_COLOR_INFO2 =>
             FPGA_RDDATA  <= x"00" & OSD_CH_COLOR_INFO2 ;  
         
         when  GET_OSD_MODE =>
             FPGA_RDDATA  <= x"0000000" & OSD_MODE ;   

         when  GET_OSD_POS_X_LY1_MODE1 =>
             FPGA_RDDATA  <= x"00000" & "0" & OSD_POS_X_LY1_MODE1 ;
             
         when  GET_OSD_POS_Y_LY1_MODE1 =>
             FPGA_RDDATA  <= x"00000" & "00" & OSD_POS_Y_LY1_MODE1 ;

         when  GET_OSD_POS_X_LY2_MODE1 =>
             FPGA_RDDATA  <= x"00000" & "0" & OSD_POS_X_LY2_MODE1 ;
       
         when  GET_OSD_POS_Y_LY2_MODE1 =>
             FPGA_RDDATA  <= x"00000" & "00" & OSD_POS_Y_LY2_MODE1 ;
 
         when  GET_OSD_POS_X_LY3_MODE1 =>
             FPGA_RDDATA  <= x"00000" & "0" & OSD_POS_X_LY3_MODE1 ;
       
         when  GET_OSD_POS_Y_LY3_MODE1 =>
             FPGA_RDDATA  <= x"00000" & "00" & OSD_POS_Y_LY3_MODE1 ;

         when  GET_OSD_POS_X_LY1_MODE2 =>
             FPGA_RDDATA  <= x"00000" & "0" & OSD_POS_X_LY1_MODE2 ;
             
         when  GET_OSD_POS_Y_LY1_MODE2 =>
             FPGA_RDDATA  <= x"00000" & "00" & OSD_POS_Y_LY1_MODE2 ;

         when  GET_OSD_POS_X_LY2_MODE2 =>
             FPGA_RDDATA  <= x"00000" & "0" & OSD_POS_X_LY2_MODE2 ;
       
         when  GET_OSD_POS_Y_LY2_MODE2 =>
             FPGA_RDDATA  <= x"00000" & "00" & OSD_POS_Y_LY2_MODE2 ;
 
         when  GET_OSD_POS_X_LY3_MODE2 =>
             FPGA_RDDATA  <= x"00000" & "0" & OSD_POS_X_LY3_MODE2 ;
       
         when  GET_OSD_POS_Y_LY3_MODE2 =>
             FPGA_RDDATA  <= x"00000" & "00" & OSD_POS_Y_LY3_MODE2 ;

        when GET_TEMPERATURE_OFFSET  =>
             FPGA_RDDATA  <=  x"000" & "000" & sub_add_temp_offset & temperature_offset ;
                  
         when GET_TEMPERATURE_THRESHOLD =>
             FPGA_RDDATA  <= x"0000" & temperature_threshold ;   

         when GET_LO_TO_HI_AREA_GLOBAL_OFFSET_FORCE_VAL =>
             FPGA_RDDATA  <= x"0000" & lo_to_hi_area_global_offset_force_val;

         when GET_HI_TO_LO_AREA_GLOBAL_OFFSET_FORCE_VAL =>
             FPGA_RDDATA  <= x"0000" & hi_to_lo_area_global_offset_force_val;
                          
         when  GET_OLED_OSD_POS_X_LY1 =>
             FPGA_RDDATA  <= x"00000" & "00" & OLED_OSD_POS_X_LY1 ;
             
         when  GET_OLED_OSD_POS_Y_LY1 =>
             FPGA_RDDATA  <= x"00000" & "00" & OLED_OSD_POS_Y_LY1 ;

         when  GET_BPR_OSD_POS_X_LY1 =>
             FPGA_RDDATA  <= x"00000" & "00" & BPR_OSD_POS_X_LY1 ;
             
         when  GET_BPR_OSD_POS_Y_LY1 =>
             FPGA_RDDATA  <= x"00000" & "00" & BPR_OSD_POS_Y_LY1 ;

--         when  GET_IMG_Y_OFFSET =>
--             FPGA_RDDATA  <= x"00000" & "00" & IN_Y_OFF  ;


         when  GET_GYRO_DATA_DISP_POS_X_LY1 =>
             FPGA_RDDATA  <= x"00000" & "0" & GYRO_DATA_DISP_POS_X_LY1 ;
 
         when  GET_GYRO_DATA_DISP_POS_Y_LY1 =>
             FPGA_RDDATA  <= x"00000" & "00" & GYRO_DATA_DISP_POS_Y_LY1 ;            

         when  GET_GYRO_DATA_DISP_POS_X_LY2 =>
             FPGA_RDDATA  <= x"00000" & "0" & GYRO_DATA_DISP_POS_X_LY2 ;
 
         when  GET_GYRO_DATA_DISP_POS_Y_LY2 =>
             FPGA_RDDATA  <= x"00000" & "00" & GYRO_DATA_DISP_POS_Y_LY2 ;              

         when  GET_OSD_TIMEOUT =>
             FPGA_RDDATA  <= x"0000" & OSD_TIMEOUT ;             

         when  GET_ENABLE_SN_INFO_DISP =>
             FPGA_RDDATA  <= x"0000000" & "000" & MUX_ENABLE_SN_INFO_DISP ;

         when  GET_ENABLE_INFO_DISP =>
             FPGA_RDDATA  <= x"0000000" & "000" & ENABLE_INFO_DISP ;

         when  GET_ENABLE_PRESET_INFO_DISP =>
             FPGA_RDDATA  <= x"0000000" & "000" & MUX_ENABLE_PRESET_INFO_DISP ;
       
         when  GET_INFO_DISP_COLOR_INFO =>
             FPGA_RDDATA  <= x"00" & INFO_DISP_COLOR_INFO ;

         when  GET_INFO_DISP_CH_COLOR_INFO1 =>
             FPGA_RDDATA  <= x"00" & INFO_DISP_CH_COLOR_INFO1 ;

         when  GET_INFO_DISP_CH_COLOR_INFO2 =>
             FPGA_RDDATA  <= x"00" & INFO_DISP_CH_COLOR_INFO2 ;
             
         when  GET_INFO_DISP_POS_X =>
             FPGA_RDDATA  <= x"00000" & "0" & INFO_DISP_POS_X ;
       
         when  GET_INFO_DISP_POS_Y =>
             FPGA_RDDATA  <= x"00000" & "00" & INFO_DISP_POS_Y ;

         when  GET_SN_INFO_DISP_POS_X =>
             FPGA_RDDATA  <= x"00000" & "00" & SN_INFO_DISP_POS_X ;
       
         when  GET_SN_INFO_DISP_POS_Y =>
             FPGA_RDDATA  <= x"00000" & "00" & SN_INFO_DISP_POS_Y ;

         when  GET_PRESET_INFO_DISP_POS_X =>
             FPGA_RDDATA  <= x"00000" & "00" & PRESET_INFO_DISP_POS_X ;
       
         when  GET_PRESET_INFO_DISP_POS_Y =>
             FPGA_RDDATA  <= x"00000" & "00" & PRESET_INFO_DISP_POS_Y ;

         when  GET_CONTRAST_MODE_INFO_DISP_POS_X =>
             FPGA_RDDATA  <= x"00000" & "00" & CONTRAST_MODE_INFO_DISP_POS_X ;
       
         when  GET_CONTRAST_MODE_INFO_DISP_POS_Y =>
             FPGA_RDDATA  <= x"00000" & "00" & CONTRAST_MODE_INFO_DISP_POS_Y ;
             
         when  GET_ENABLE_BATTERY_DISP =>
             FPGA_RDDATA  <= x"0000000" & "000" & MUX_ENABLE_BATTERY_DISP ;

             
--         when  GET_BATTERY_PERCENTAGE =>                              
--             FPGA_RDDATA  <= x"000000" & BATTERY_PERCENTAGE ;

         when  GET_BATTERY_DISP_TG_WAIT_FRAMES=> 
             FPGA_RDDATA  <= x"000000" & BATTERY_DISP_TG_WAIT_FRAMES; 
--             FPGA_RDDATA  <= x"00"& BATTERY_VOLTAGE & BATTERY_DISP_TG_WAIT_FRAMES; 
 
         when  GET_BATTERY_PIX_MAP =>                              
             FPGA_RDDATA  <= x"000000" & BATTERY_PIX_MAP ;
 
         when  GET_BATTERY_CHARGING_START =>                              
             FPGA_RDDATA  <= x"0000000" & "000" & BATTERY_CHARGING_START ;
             
         when  GET_BATTERY_CHARGE_INC =>                              
             FPGA_RDDATA  <= x"0000"  & BATTERY_CHARGE_INC ; 
--             FPGA_RDDATA  <= x"00" & BATTERY_DISP_TG_WAIT_FRAMES   & BATTERY_VOLTAGE;             

         when GET_TARGET_VALUE_THRESHOLD =>
             FPGA_RDDATA  <= x"0000"  & TARGET_VALUE_THRESHOLD ; 
              
         when  GET_BATTERY_DISP_COLOR_INFO =>
             FPGA_RDDATA  <= x"00" & BATTERY_DISP_COLOR_INFO ;

         when  GET_BATTERY_DISP_CH_COLOR_INFO1 =>
             FPGA_RDDATA  <= x"00" & BATTERY_DISP_CH_COLOR_INFO1 ;

         when  GET_BATTERY_DISP_CH_COLOR_INFO2 =>
             FPGA_RDDATA  <= x"00" & BATTERY_DISP_CH_COLOR_INFO2 ;

         when  GET_BATTERY_DISP_POS_X =>
             FPGA_RDDATA  <= x"00000" & "0" & BATTERY_DISP_POS_X ;
       
         when  GET_BATTERY_DISP_POS_Y =>
             FPGA_RDDATA  <= x"00000" & "00" & BATTERY_DISP_POS_Y ;

         when  GET_BATTERY_DISP_REQ_XSIZE =>
             FPGA_RDDATA  <= x"00000" & "0" & BATTERY_DISP_REQ_XSIZE ;
       
         when  GET_BATTERY_DISP_REQ_YSIZE =>
             FPGA_RDDATA  <= x"00000" & "00" & BATTERY_DISP_REQ_YSIZE ;
             
         when  GET_BATTERY_DISP_X_OFFSET =>
             FPGA_RDDATA  <= x"00000" & "0" & BATTERY_DISP_X_OFFSET ;
       
         when  GET_BATTERY_DISP_Y_OFFSET =>
             FPGA_RDDATA  <= x"00000" & "00" & BATTERY_DISP_Y_OFFSET ;
         
         when  GET_ENABLE_BAT_PER_DISP =>                                  
             FPGA_RDDATA  <= x"0000000" & "000" & MUX_ENABLE_BAT_PER_DISP ;

         when  GET_BAT_PER_DISP_COLOR_INFO =>
             FPGA_RDDATA  <= x"00" & BAT_PER_DISP_COLOR_INFO ;

         when  GET_BAT_PER_DISP_CH_COLOR_INFO1 =>
             FPGA_RDDATA  <= x"00" & BAT_PER_DISP_CH_COLOR_INFO1 ;

         when  GET_BAT_PER_DISP_CH_COLOR_INFO2 =>
             FPGA_RDDATA  <= x"00" & BAT_PER_DISP_CH_COLOR_INFO2 ;

         when  GET_BAT_PER_DISP_POS_X =>
             FPGA_RDDATA  <= x"00000" & "0" & BAT_PER_DISP_POS_X ;
       
         when  GET_BAT_PER_DISP_POS_Y =>
             FPGA_RDDATA  <= x"00000" & "00" & BAT_PER_DISP_POS_Y ;

         when  GET_BAT_PER_DISP_REQ_XSIZE =>
             FPGA_RDDATA  <= x"00000" & "0" & BAT_PER_DISP_REQ_XSIZE ;
       
         when  GET_BAT_PER_DISP_REQ_YSIZE =>
             FPGA_RDDATA  <= x"00000" & "00" & BAT_PER_DISP_REQ_YSIZE ;

         when  GET_ENABLE_BAT_CHG_SYMBOL =>                                  
             FPGA_RDDATA  <= x"0000000" & "000" & MUX_ENABLE_BAT_CHG_SYMBOL ;

         when  GET_BAT_CHG_SYMBOL_POS_OFFSET =>
             FPGA_RDDATA  <= x"00000"  & BAT_CHG_SYMBOL_POS_OFFSET ;

        when  GET_BAT_PER_CONV_REG1  =>
             FPGA_RDDATA  <= x"00"& BAT_PER_CONV_REG1 ;
        
        when  GET_BAT_PER_CONV_REG2  =>
             FPGA_RDDATA  <= x"00"& BAT_PER_CONV_REG2 ;
        
        when  GET_BAT_PER_CONV_REG3  =>
             FPGA_RDDATA  <= x"00"& BAT_PER_CONV_REG3 ;             
        
        when  GET_BAT_PER_CONV_REG4  =>
             FPGA_RDDATA  <= x"00"& BAT_PER_CONV_REG4 ;
        
        when  GET_BAT_PER_CONV_REG5  =>
             FPGA_RDDATA  <= x"00"& BAT_PER_CONV_REG5 ;

        when  GET_BAT_PER_CONV_REG6  =>
             FPGA_RDDATA  <= x"00"& BAT_PER_CONV_REG6 ;

        when  GET_ENABLE_B_BAR_DISP =>
             FPGA_RDDATA  <= x"0000000" & "000" & MUX_ENABLE_B_BAR_DISP ;

        when  GET_ENABLE_C_BAR_DISP =>
             FPGA_RDDATA  <= x"0000000" & "000" & MUX_ENABLE_C_BAR_DISP ;
             
         when  GET_CB_BAR_DISP_COLOR_INFO =>
             FPGA_RDDATA  <= x"00" & CB_BAR_DISP_COLOR_INFO ;


         when  GET_B_BAR_DISP_POS_X =>
             FPGA_RDDATA  <= x"00000" & "00" & B_BAR_DISP_POS_X ;
       
--         when  GET_B_BAR_DISP_POS_Y =>
--             FPGA_RDDATA  <= x"00000" & "00" & B_BAR_DISP_POS_Y ;

--         when  GET_B_BAR_DISP_REQ_XSIZE =>
--             FPGA_RDDATA  <= x"00000" & "00" & B_BAR_DISP_REQ_XSIZE ;
       
         when  GET_B_BAR_DISP_REQ_YSIZE =>
             FPGA_RDDATA  <= x"00000" & "00" & B_BAR_DISP_REQ_YSIZE ;
             
--         when  GET_B_BAR_DISP_X_OFFSET =>
--             FPGA_RDDATA  <= x"00000" & "00" & B_BAR_DISP_X_OFFSET ;
       
         when  GET_B_BAR_DISP_Y_OFFSET =>
             FPGA_RDDATA  <= x"00000" & "00" & B_BAR_DISP_Y_OFFSET ;  

         when  GET_C_BAR_DISP_POS_X =>
             FPGA_RDDATA  <= x"00000" & "00" & C_BAR_DISP_POS_X ;
       
         when  GET_C_BAR_DISP_POS_Y =>
             FPGA_RDDATA  <= x"00000" & "00" & C_BAR_DISP_POS_Y ;

         when  GET_C_BAR_DISP_REQ_XSIZE =>
             FPGA_RDDATA  <= x"00000" & "00" & C_BAR_DISP_REQ_XSIZE ;
       
--         when  GET_C_BAR_DISP_REQ_YSIZE =>
--             FPGA_RDDATA  <= x"00000" & "00" & C_BAR_DISP_REQ_YSIZE ;

         when  GET_WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE =>
             FPGA_RDDATA  <= x"000000"  & WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE ;
                          
--         when  GET_C_BAR_DISP_X_OFFSET =>
--             FPGA_RDDATA  <= x"00000" & "00" & C_BAR_DISP_X_OFFSET ;

         when  GET_GYRO_CALIB_STATUS =>
             FPGA_RDDATA  <= x"0000000" & "000" & GYRO_CALIB_STATUS ;
       
--         when  GET_C_BAR_DISP_Y_OFFSET =>
--             FPGA_RDDATA  <= x"00000" & "00" & C_BAR_DISP_Y_OFFSET ;  
       
         when  GET_MENU_SEL_CENTER =>
             FPGA_RDDATA  <= x"0000000" & "000" & MENU_SEL_CENTER;

         when  GET_MENU_SEL_LEFT =>
             FPGA_RDDATA  <= x"0000000" & "000" & MENU_SEL_LEFT;
--             FPGA_RDDATA <= RETICLE_OFFSET_RD_DATA;
         when  GET_MENU_SEL_RIGHT =>
             FPGA_RDDATA <= x"0000000" & "000" & MENU_SEL_RIGHT ;
--             FPGA_RDDATA <=  x"000000" & "000" &RETICLE_OFFSET_RD_REQ & RETICLE_OFFSET_RD_ADDR;
--             FPGA_RDDATA <= std_logic_vector(SN_CNT);

         when  GET_MENU_SEL_UP =>
             FPGA_RDDATA  <= x"0000000" & "000" & MENU_SEL_UP;             
--             FPGA_RDDATA <= std_logic_vector(BT656_V_CNT);

         when  GET_MENU_SEL_DN =>
             FPGA_RDDATA <= x"0000000" & "000" & MENU_SEL_DN ;
--             FPGA_RDDATA <= std_logic_vector(MIPI_IN_CNT);
             
         when GET_MAX_RELEASE_WAIT_TIME =>    
               FPGA_RDDATA <= x"00000" &MAX_RELEASE_WAIT_TIME ; 
        
         when GET_MIN_TIME_GAP_PRESS_RELEASE =>
               FPGA_RDDATA <= x"00000" &MIN_TIME_GAP_PRESS_RELEASE;       
               
         when GET_MAX_UP_DOWN_PRESS_TIME =>    
               FPGA_RDDATA <= x"0000" &MAX_UP_DOWN_PRESS_TIME ; 

         when GET_MAX_MENU_DOWN_PRESS_TIME =>    
               FPGA_RDDATA <= x"0000" &MAX_MENU_DOWN_PRESS_TIME ;      

         when GET_LONG_PRESS_STEP_SIZE =>    
               FPGA_RDDATA <= x"00000" &LONG_PRESS_STEP_SIZE ;  
 
         when GET_MAX_PRESET_SAVE_OK_DISP_FRAMES =>    
               FPGA_RDDATA <= x"0000" &MAX_PRESET_SAVE_OK_DISP_FRAMES ;              

         when GET_OLED_DISP_EN_TIME_GAP =>    
               FPGA_RDDATA <= x"0000" &OLED_DISP_EN_TIME_GAP ;                     

         when GET_BPR_DISP_EN_TIME_GAP =>    
               FPGA_RDDATA <= x"0000" &BPR_DISP_EN_TIME_GAP ; 
         
         when GET_MAX_AGC_MODE_INFO_DISP_TIME =>
               FPGA_RDDATA <= x"0000" &MAX_AGC_MODE_INFO_DISP_TIME ;  
--               FPGA_RDDATA <= OSD_GALLERY_IMG_VALID(63 downto 32);
               
         when  GET_I2C_DELAY_REG => 
               FPGA_RDDATA <= x"0000" &I2C_DELAY_REG ;  
--               FPGA_RDDATA <= OSD_GALLERY_IMG_VALID(31 downto 0);   

         when  GET_AUTO_SHUTTER_TIMEOUT =>
               FPGA_RDDATA <= x"0000" &AUTO_SHUTTER_TIMEOUT ; 
                                          
         when  GET_FRAME_COUNTER_NUC1PT_DELAY => 
               FPGA_RDDATA <= x"0000" &FRAME_COUNTER_NUC1PT_DELAY ;  
         
         when GET_SNAPSHOT_COUNTER => 
               FPGA_RDDATA <= x"000000" & OSD_SNAPSHOT_COUNTER; 
          
         when GET_DARK_PIX_TH =>
               FPGA_RDDATA <= x"0000" & "00" &DARK_PIX_TH ;
--               FPGA_RDDATA <= x"0000" & "00" &BAD_BLIND_PIX_LOW_TH;
               
         when GET_SATURATED_PIX_TH =>
               FPGA_RDDATA <= x"0000" & "00" &SATURATED_PIX_TH; 
--               FPGA_RDDATA <= x"0000" & "00" &BAD_BLIND_PIX_HIGH_TH;

         when GET_BAD_BLIND_PIX_LOW_TH =>
               FPGA_RDDATA <= x"0000" & "00" &BAD_BLIND_PIX_LOW_TH;
               
         when GET_BAD_BLIND_PIX_HIGH_TH =>
               FPGA_RDDATA <= x"0000" & "00" &BAD_BLIND_PIX_HIGH_TH;

         when GET_YAW =>
--               FPGA_RDDATA <= x"0000" & yaw; 
--               FPGA_RDDATA <= corrected_yaw & yaw; 
--               FPGA_RDDATA <= X"0000" & MAGNETO_X_DATA;
               FPGA_RDDATA <= MAGNETO_X_DATA & yaw;
         
         when GET_PITCH =>
--               FPGA_RDDATA <= x"0000" & pitch;
--               FPGA_RDDATA <= corrected_pitch & pitch; 
               FPGA_RDDATA <= X"0000" & MAGNETO_Y_DATA;   

         when GET_ROLL =>
--               FPGA_RDDATA <= x"0000" & roll; 
               FPGA_RDDATA <= X"0000" & MAGNETO_Z_DATA;   
                        
         when GET_X_ACCEL =>                            
--               FPGA_RDDATA <= x"0000" & x_accel;      
               FPGA_RDDATA <= x"0000" & ACCEL_X_DATA;   
                                                        
         when GET_Y_ACCEL =>                            
--               FPGA_RDDATA <= x"0000" & y_accel;      
               FPGA_RDDATA <= x"0000" & ACCEL_Y_DATA;   
                                                        
         when GET_Z_ACCEL =>                            
--               FPGA_RDDATA <= x"0000" & z_accel;      
               FPGA_RDDATA <= x"0000" & ACCEL_Z_DATA;   

         when GET_YAW_OFFSET =>
               FPGA_RDDATA <= x"0000" & yaw_offset; 
         
         when GET_PITCH_OFFSET =>
               FPGA_RDDATA <= x"0000" & pitch_offset;
               
          when others =>
             FPGA_RDDATA    <= x"FFFF_FFFF";
        end case;
      end if;
      
      if(toggle_menu_loc = '1')then
        if(OSD_MODE = x"0")then
            OSD_MODE <=x"1";
        elsif(OSD_MODE =x"1")then
            OSD_MODE <=x"0";
        end if;    
      end if;
      
      
      if(OSD_MODE = x"1")then
       OSD_POS_X_LY1 <= OSD_POS_X_LY1_MODE2;
       OSD_POS_Y_LY1 <= OSD_POS_Y_LY1_MODE2;
       OSD_POS_X_LY2 <= OSD_POS_X_LY2_MODE2;
       OSD_POS_Y_LY2 <= OSD_POS_Y_LY2_MODE2;
       OSD_POS_X_LY3 <= OSD_POS_X_LY3_MODE2;
       OSD_POS_Y_LY3 <= OSD_POS_Y_LY3_MODE2;
      else
       OSD_POS_X_LY1 <= OSD_POS_X_LY1_MODE1; 
       OSD_POS_Y_LY1 <= OSD_POS_Y_LY1_MODE1;
       OSD_POS_X_LY2 <= OSD_POS_X_LY2_MODE1;
       OSD_POS_Y_LY2 <= OSD_POS_Y_LY2_MODE1;
       OSD_POS_X_LY3 <= OSD_POS_X_LY3_MODE1;
       OSD_POS_Y_LY3 <= OSD_POS_Y_LY3_MODE1;
      end if;
      
      if(RIGHT_KEY_PRESS = '1' and RIGHT_KEY_LONG_PRESS_LEVEL = '0')then
--      if(UP_KEY_LONG_PRESS = '1' and OSD_EN_OUT = '0')then
        MUX_LASER_EN <= not MUX_LASER_EN;
--        user_settings_mem_wr_req  <= '1';
--        user_settings_mem_wr_addr <= SET_LASER_EN;  
--        user_settings_mem_wr_data <= SET_LASER_EN & x"00000" & "000" & (not MUX_LASER_EN); 
      elsif(OSD_LASER_EN_VALID = '1')then
        MUX_LASER_EN <= OSD_LASER_EN;                                                      
--        user_settings_mem_wr_req  <= '1';                                              
--        user_settings_mem_wr_addr <= SET_LASER_EN;                                     
--        user_settings_mem_wr_data <= SET_LASER_EN & x"00000" & "000" & OSD_LASER_EN;       
      elsif(LASER_EN_VALID = '1')then
        MUX_LASER_EN <= LASER_EN;
      end if;

      
----      if(RIGHT_KEY_LONG_PRESS_LEVEL = '1' )then
----        if(TICK1MS = '1')then
----            if(apply_osd_flip_time_cnt >= unsigned(NUC_TIME_GAP))then
----                apply_osd_flip_time_cnt<= apply_osd_flip_time_cnt;
----            else
----                apply_osd_flip_time_cnt <=  apply_osd_flip_time_cnt + 1;
----            end if;    
----        end if;
----        if(apply_osd_flip_time_cnt >= unsigned(NUC_TIME_GAP))then
--        if(CENTER_UP_KEY_LONG_PRESS = '1')then   
--            osd_flip_update_done <='1'; 
--            if(osd_flip_update_done ='0')then
----                if (toggle_osd_flip = '0')then
--                if(OLED_IMG_FLIP = x"00")then
--                    toggle_osd_flip           <= '1';
--                    OLED_IMG_FLIP             <= x"03";--x"73";
--                    OLED_IMG_FLIP_VALID       <= '1';
--                    user_settings_mem_wr_req  <= '1';    
--                    user_settings_mem_wr_addr <= SET_OLED_IMG_FLIP; 
--                    user_settings_mem_wr_data <= SET_OLED_IMG_FLIP &  x"0000" & x"03" ;--x"73"; 
                    
--                else
--                    toggle_osd_flip           <= '0';
--                    OLED_IMG_FLIP             <= x"00";--x"70";
--                    OLED_IMG_FLIP_VALID       <= '1';
--                    user_settings_mem_wr_req  <= '1';    
--                    user_settings_mem_wr_addr <= SET_OLED_IMG_FLIP; 
--                    user_settings_mem_wr_data <= SET_OLED_IMG_FLIP &  x"0000" & x"00";-- x"70";            
--                end if;
--            end if; 
----         end if;     
--      else
--        osd_flip_update_done    <= '0';   
----        apply_osd_flip_time_cnt <= (others=>'0');
--      end if;
      
--      if(OLED_IMG_FLIP_VALID = '1')then
--      --if(toggle_osd_flip_pos_edge = '1')then  -- add for dealy , after oled_img_flip reg write
--          if(OLED_IMG_FLIP = x"03")then
--                IMG_FLIP_H                <= '1';  
--                IMG_FLIP_V                <= '1';    
--                user_settings_mem_wr_req  <= '1';    
--                user_settings_mem_wr_addr <= SET_IMG_FLIP; 
--                user_settings_mem_wr_data <= SET_IMG_FLIP &  x"00000" & "00" &"11"; 
--                OLED_IMG_H_FLIP           <= x"C0";
--                OLED_IMG_H_FLIP_VALID     <= '1';
--                OLED_ROW_START_MSB        <= x"00";
--                OLED_ROW_START_MSB_VALID  <= '1';
--                OLED_ROW_START_LSB        <= x"08";
--                OLED_ROW_START_LSB_VALID  <= '1';
--                OLED_ROW_END_MSB          <= x"02";
--                OLED_ROW_END_MSB_VALID     <= '1';
--                OLED_ROW_END_LSB          <= x"D7";
--                OLED_ROW_END_LSB_VALID     <= '1';
                
--    --      elsif(toggle_osd_flip_neg_edge = '1')then
--          else
--                IMG_FLIP_H                <= '0';  
--                IMG_FLIP_V                <= '0';    
--                user_settings_mem_wr_req  <= '1';    
--                user_settings_mem_wr_addr <= SET_IMG_FLIP; 
--                user_settings_mem_wr_data <= SET_IMG_FLIP &  x"00000" & "00" &"00";   
--                OLED_IMG_H_FLIP           <= x"C1";
--                OLED_IMG_H_FLIP_VALID     <= '1';
--                OLED_ROW_START_MSB        <= x"02";
--                OLED_ROW_START_MSB_VALID  <= '1';
--                OLED_ROW_START_LSB        <= x"D7";
--                OLED_ROW_START_LSB_VALID  <= '1';
--                OLED_ROW_END_MSB          <= x"00";
--                OLED_ROW_END_MSB_VALID     <= '1';
--                OLED_ROW_END_LSB          <= x"08";
--                OLED_ROW_END_LSB_VALID     <= '1';    
--          end if;
--      end if; 

      if(MUX_SIGHT_MODE_VALID = '1')then
      --if(toggle_osd_flip_pos_edge = '1')then  -- add for dealy , after oled_img_flip reg write
          if(MUX_SIGHT_MODE = "10")then
                IMG_FLIP_H                <= '1';  
                IMG_FLIP_V                <= '1';              
                user_settings_mem_wr_req  <= '1';    
                user_settings_mem_wr_addr <= SET_IMG_FLIP; 
                user_settings_mem_wr_data <= SET_IMG_FLIP &  x"00000" & "00" &"11"; 
                OLED_IMG_H_FLIP           <= x"C0";
                OLED_IMG_H_FLIP_VALID     <= '1';
                OLED_ROW_START_MSB        <= x"00";
                OLED_ROW_START_MSB_VALID  <= '1';
                OLED_ROW_START_LSB        <= x"08";
                OLED_ROW_START_LSB_VALID  <= '1';
                OLED_ROW_END_MSB          <= x"02";
                OLED_ROW_END_MSB_VALID     <= '1';
                OLED_ROW_END_LSB          <= x"D7";
                OLED_ROW_END_LSB_VALID     <= '1';
                
    --      elsif(toggle_osd_flip_neg_edge = '1')then
          else
                IMG_FLIP_H                <= '0';  
                IMG_FLIP_V                <= '0';    
                user_settings_mem_wr_req  <= '1';    
                user_settings_mem_wr_addr <= SET_IMG_FLIP; 
                user_settings_mem_wr_data <= SET_IMG_FLIP &  x"00000" & "00" &"00";   
                OLED_IMG_H_FLIP           <= x"C1";
                OLED_IMG_H_FLIP_VALID     <= '1';
                OLED_ROW_START_MSB        <= x"02";
                OLED_ROW_START_MSB_VALID  <= '1';
                OLED_ROW_START_LSB        <= x"D7";
                OLED_ROW_START_LSB_VALID  <= '1';
                OLED_ROW_END_MSB          <= x"00";
                OLED_ROW_END_MSB_VALID     <= '1';
                OLED_ROW_END_LSB          <= x"08";
                OLED_ROW_END_LSB_VALID     <= '1';    
          end if;
      end if; 

      OLED_ROW_START_MSB_VALID_D  <= OLED_ROW_START_MSB_VALID;    
      OLED_ROW_START_LSB_VALID_D  <= OLED_ROW_START_LSB_VALID;  
      OLED_ROW_END_MSB_VALID_D    <= OLED_ROW_END_MSB_VALID;
      OLED_ROW_END_LSB_VALID_D    <= OLED_ROW_END_LSB_VALID;    
      OLED_ROW_START_LSB_VALID_DD <= OLED_ROW_START_LSB_VALID_D;  
      OLED_ROW_END_MSB_VALID_DD   <= OLED_ROW_END_MSB_VALID_D;
      OLED_ROW_END_LSB_VALID_DD   <= OLED_ROW_END_LSB_VALID_D;     
      OLED_ROW_END_MSB_VALID_DDD  <= OLED_ROW_END_MSB_VALID_DD;
      OLED_ROW_END_LSB_VALID_DDD  <= OLED_ROW_END_LSB_VALID_DD;   
      OLED_ROW_END_LSB_VALID_DDDD <= OLED_ROW_END_LSB_VALID_DDD;                   
--      if(DOWN_UP_KEY_LONG_PRESS = '1' and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--        BPR_MENU_EN <= '1';
--      end if;
--      if(CENTER_UP_KEY_LONG_PRESS = '1'and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--        OLED_MENU_EN <= '1';
--      end if;
      
--      if(CENTER_DOWN_KEY_LONG_PRESS = '1'and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--        RETICLE_SEL_EN <= '1';
--      elsif(CENTER_KEY_LONG_PRESS = '1' and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '1')then
--        RETICLE_SEL_EN <= '0';
--        RETICLE_SAVE_USER_SETTINGS <= '1';    
--      end if;
      if(osd_sel_oled_analog_video_out_valid = '1')then 
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_OLED_ANALOG_VIDEO_OUT_SEL;  
            user_settings_mem_wr_data <= SET_OLED_ANALOG_VIDEO_OUT_SEL & x"00000" &"000" &osd_sel_oled_analog_video_out;  
      elsif(sel_oled_analog_video_out= '1' and qspi_init_cmd_done ='1' and display_mode_force_sel_done ='0' and force_analog_video_out = '0' and BT656_START ='1')then
            user_settings_mem_wr_req  <= '1';
            user_settings_mem_wr_addr <= SET_OLED_ANALOG_VIDEO_OUT_SEL;  
            user_settings_mem_wr_data <= SET_OLED_ANALOG_VIDEO_OUT_SEL & x"00000" &"000" &'0';  
            display_mode_force_sel_done  <= '1';   
            DISPLAY_MODE_SAVE_USER_SETTINGS <= '1';
      end if;   

      if(OSD_SIGHT_MODE_VALID = '1')then
          MUX_SIGHT_MODE            <= OSD_SIGHT_MODE;
          MUX_SIGHT_MODE_VALID      <= '1';
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_SIGHT_MODE; 
          user_settings_mem_wr_data <= SET_SIGHT_MODE &  x"00000"  & "00" &OSD_SIGHT_MODE;            
      elsif(SIGHT_MODE_VALID = '1')then
          MUX_SIGHT_MODE            <= SIGHT_MODE;
--          MUX_SIGHT_MODE_VALID      <= '1';
      else
          MUX_SIGHT_MODE      <= MUX_SIGHT_MODE;
      end if;
         

--      if(OSD_START_NUC1PTCALIB_POS_EDGE = '1' or do_nuc1pt_at_power_on = '1')then
--      if(OSD_START_NUC1PTCALIB_POS_EDGE = '1' )then
      if((auto_nuc1pt_start = '1' and MUX_NUC_MODE = "10")or(OSD_START_NUC1PTCALIB='1'  and MUX_BLADE_MODE = "00")) then
        APPLY_NUC1ptCalib  <= '1';
        Start_NUC1ptCalib  <= '1';
        APPLY_NUC1ptCalib2 <= '0';
      --elsif(OSD_START_NUC1PTCALIB_NEG_EDGE = '1')then
      --  APPLY_NUC1ptCalib <= '0';
      --  Start_NUC1ptCalib <= '0';       
      end if;

--      if(OSD_START_NUC1PT2CALIB = '1') then
      if((auto_nuc1pt_start = '1' and MUX_NUC_MODE = "01")or(OSD_START_NUC1PT2CALIB='1' and MUX_BLADE_MODE = "00")) then
        APPLY_NUC1ptCalib2 <= '1';
        Start_NUC1ptCalib2 <= '1';
        APPLY_NUC1ptCalib  <= '0';
      end if;
      
--      if(OSD_NUC_MODE = "00")then
      if(MUX_NUC_MODE = "00" and MUX_NUC_MODE_VALID ='1')then
        APPLY_NUC1ptCalib  <= '0';
        APPLY_NUC1ptCalib2 <= '0';
      end if;   
      
      if(OSD_NUC_MODE_VALID= '1')then
          MUX_NUC_MODE              <= OSD_NUC_MODE;
          MUX_NUC_MODE_VALID        <= '1';
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_NUC_MODE; 
          user_settings_mem_wr_data <= SET_NUC_MODE &  x"00000" & "00" & OSD_NUC_MODE(1 downto 0);
      elsif(NUC_MODE_VALID = '1')then     
          MUX_NUC_MODE       <= NUC_MODE;
          MUX_NUC_MODE_VALID <= '1';
      else
          MUX_NUC_MODE       <= MUX_NUC_MODE;
      end if;

      if(OSD_BLADE_MODE_VALID= '1')then
          MUX_BLADE_MODE            <= OSD_BLADE_MODE;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_BLADE_MODE; 
          user_settings_mem_wr_data <= SET_BLADE_MODE &  x"00000" & "00" & OSD_BLADE_MODE(1 downto 0);
      elsif(BLADE_MODE_VALID = '1')then     
          MUX_BLADE_MODE       <= BLADE_MODE;
      else
          MUX_BLADE_MODE       <= MUX_BLADE_MODE;
      end if;
      
         
--      if(UP_KEY_LONG_PRESS_LEVEL = '1' and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--            if(TICK1MS = '1')then
--               if(toggle_nuc1pt= '1')then
--                    if(apply_nuc1pt_time_cnt >= unsigned(NUC_TIME_GAP(13 downto 0)&"00"))then
--                        apply_nuc1pt_time_cnt <= x"0000";                     
--                            toggle_nuc1pt     <= '0';
--                            APPLY_NUC1ptCalib <= '0';
--                            Start_NUC1ptCalib <= '0';    
--                    else
--                        apply_nuc1pt_time_cnt <= apply_nuc1pt_time_cnt +1;
--                    end if;
--                else
--                    if(apply_nuc1pt_time_cnt >= unsigned(NUC_TIME_GAP))then
--                        apply_nuc1pt_time_cnt <= x"0000";                     
--                            toggle_nuc1pt     <= '1';
--                            APPLY_NUC1ptCalib <= '1';
--                            Start_NUC1ptCalib <= '1';    
--                    else
--                        apply_nuc1pt_time_cnt <= apply_nuc1pt_time_cnt +1;
--                    end if;                  
--                end if;      
--            else
--                 apply_nuc1pt_time_cnt <= apply_nuc1pt_time_cnt;           
--            end if;                        
--      else
--        apply_nuc1pt_time_cnt <= x"0000";
--        toggle_nuc1pt         <= '0';
--      end if;
      

      if(OSD_AGC_MODE_SEL_VALID = '1')then
          MUX_AGC_MODE_SEL          <= OSD_AGC_MODE_SEL;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_AGC_MODE; 
          user_settings_mem_wr_data <= SET_AGC_MODE &  x"00000" & "00" &OSD_AGC_MODE_SEL(1 downto 0);
          AGC_MODE_INFO_DISP_EN     <= '1'; 
          agc_mode_info_disp_time_cnt <= (others=>'0');
      elsif(AGC_MODE_SEL_VALID = '1')then
          MUX_AGC_MODE_SEL         <= AGC_MODE_SEL;        
          AGC_MODE_INFO_DISP_EN    <= '1';
          agc_mode_info_disp_time_cnt <= (others=>'0');
      else
          MUX_AGC_MODE_SEL         <= MUX_AGC_MODE_SEL;
          if(AGC_MODE_INFO_DISP_EN = '1')then
              if(TICK1MS = '1')then
                if(agc_mode_info_disp_time_cnt >= unsigned(MAX_AGC_MODE_INFO_DISP_TIME))then
                    AGC_MODE_INFO_DISP_EN       <= '0';
                    agc_mode_info_disp_time_cnt <= (others=>'0');
                else
                    agc_mode_info_disp_time_cnt <= agc_mode_info_disp_time_cnt +1;               
                end if;    
              else
                agc_mode_info_disp_time_cnt <= agc_mode_info_disp_time_cnt;
              end if;
          else
            agc_mode_info_disp_time_cnt <= (others=>'0');       
          end if;      
      end if;

      if(OSD_MAX_LIMITER_DPHE_VALID = '1')then
          MUX_MAX_LIMITER_DPHE      <= OSD_MAX_LIMITER_DPHE;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_MAX_LIMITER_DPHE; 
          user_settings_mem_wr_data <= SET_MAX_LIMITER_DPHE &  x"0000" & OSD_MAX_LIMITER_DPHE(7 downto 0);
      elsif(MAX_LIMITER_DPHE_VALID = '1')then     
          MUX_MAX_LIMITER_DPHE      <= MAX_LIMITER_DPHE;
      else
          MUX_MAX_LIMITER_DPHE      <= MUX_MAX_LIMITER_DPHE;
      end if;

      if(OSD_MUL_MAX_LIMITER_DPHE_VALID = '1')then
          MUX_MUL_MAX_LIMITER_DPHE  <= OSD_MUL_MAX_LIMITER_DPHE;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_MUL_MAX_LIMITER_DPHE; 
          user_settings_mem_wr_data <= SET_MUL_MAX_LIMITER_DPHE &  x"0000" & OSD_MUL_MAX_LIMITER_DPHE(7 downto 0);
      elsif(MUL_MAX_LIMITER_DPHE_VALID = '1')then     
          MUX_MUL_MAX_LIMITER_DPHE      <= MUL_MAX_LIMITER_DPHE;
      else
          MUX_MUL_MAX_LIMITER_DPHE      <= MUX_MUL_MAX_LIMITER_DPHE;
      end if;
      
      if(MUX_AGC_MODE_SEL = "10")then
        if(MUX_MUL_MAX_LIMITER_DPHE = x"00")then
          MULTIPLIER_MAX_LIMITER_DPHE <= std_logic_vector(to_unsigned(25,16));
        else
          MULTIPLIER_MAX_LIMITER_DPHE <= std_logic_vector(unsigned(MUX_MUL_MAX_LIMITER_DPHE)*to_unsigned(50,8)); 
        end if;
      else
        MULTIPLIER_MAX_LIMITER_DPHE <= std_logic_vector(to_unsigned(50,16));
      end if;
      
      MAX_LIMITER_DPHE_MUL        <= std_logic_vector(unsigned(MUX_MAX_LIMITER_DPHE)*unsigned(MULTIPLIER_MAX_LIMITER_DPHE)); 
      CNTRL_MAX_GAIN_MUL          <= std_logic_vector(unsigned(MUX_CNTRL_MAX_GAIN)*to_unsigned(640,16)); 
      CNTRL_IPP_MUL               <= x"0000" & MUX_CNTRL_IPP;  

      if(OSD_CNTRL_MAX_GAIN_VALID = '1')then
          MUX_CNTRL_MAX_GAIN        <= OSD_CNTRL_MAX_GAIN;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_CNTRL_MAX_GAIN; 
          user_settings_mem_wr_data <= SET_CNTRL_MAX_GAIN &  x"0000" & OSD_CNTRL_MAX_GAIN(7 downto 0);
      elsif(CNTRL_MAX_GAIN_VALID = '1')then     
          MUX_CNTRL_MAX_GAIN        <= CNTRL_MAX_GAIN;
      else
          MUX_CNTRL_MAX_GAIN        <= MUX_CNTRL_MAX_GAIN;
      end if;


      if(OSD_CNTRL_IPP_VALID = '1')then
          MUX_CNTRL_IPP             <= OSD_CNTRL_IPP;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_CNTRL_IPP; 
          user_settings_mem_wr_data <= SET_CNTRL_IPP &  x"0000" & OSD_CNTRL_IPP(7 downto 0);
      elsif(CNTRL_IPP_VALID = '1')then     
          MUX_CNTRL_IPP        <= CNTRL_IPP;
      else
          MUX_CNTRL_IPP        <= MUX_CNTRL_IPP;
      end if;


      if(OSD_BRIGHTNESS_VALID = '1')then
          MUX_BRIGHTNESS            <= OSD_BRIGHTNESS;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_BRIGHTNESS; 
          user_settings_mem_wr_data <= SET_BRIGHTNESS &  x"0000" & OSD_BRIGHTNESS(7 downto 0);
      elsif(BRIGHTNESS_VALID = '1')then     
          MUX_BRIGHTNESS         <= BRIGHTNESS;
--      elsif(DOWN_KEY_LONG_PRESS ='1'and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--          if(unsigned(MUX_BRIGHTNESS) =x"0A")then
--            MUX_BRIGHTNESS   <= x"00";
--          else
--            MUX_BRIGHTNESS   <= std_logic_vector(unsigned (MUX_BRIGHTNESS) +1);  
--          end if;  
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_BRIGHTNESS; 
--          user_settings_mem_wr_data <= SET_BRIGHTNESS &  x"0000" & MUX_BRIGHTNESS(7 downto 0);
      else
          MUX_BRIGHTNESS         <= MUX_BRIGHTNESS;
      end if;
      
  
      if(OSD_CONTRAST_VALID = '1')then
          MUX_CONTRAST              <= OSD_CONTRAST;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_CONTRAST; 
          user_settings_mem_wr_data <= SET_CONTRAST &  x"0000" & OSD_CONTRAST(7 downto 0);       
      elsif(CONTRAST_VALID = '1')then
          MUX_CONTRAST         <= CONTRAST;
--      elsif(RIGHT_KEY_LONG_PRESS = '1' and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--          if(unsigned(MUX_CONTRAST) =x"0A")then
--            MUX_CONTRAST   <= x"0A";
--          else
--            MUX_CONTRAST   <= std_logic_vector(unsigned (MUX_CONTRAST) +1);  
--          end if;  
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_CONTRAST; 
--          user_settings_mem_wr_data <= SET_CONTRAST &  x"0000" & MUX_CONTRAST(7 downto 0);      
--      elsif(LEFT_KEY_LONG_PRESS = '1' and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--          if(unsigned(MUX_CONTRAST) =x"00")then
--            MUX_CONTRAST   <= x"00";
--          else
--            MUX_CONTRAST   <= std_logic_vector(unsigned (MUX_CONTRAST) -1);  
--          end if;  
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_CONTRAST; 
--          user_settings_mem_wr_data <= SET_CONTRAST &  x"0000" & MUX_CONTRAST(7 downto 0);  
      else
          MUX_CONTRAST         <= MUX_CONTRAST;
      end if;
      
      if(OSD_DZOOM_VALID = '1')then
          MUX_ZOOM_MODE             <= OSD_DZOOM; 
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_ZOOM_MODE; 
          user_settings_mem_wr_data <= SET_ZOOM_MODE &  x"00000" & "0" &OSD_DZOOM;
      elsif(ZOOM_MODE_VALID = '1')then
          MUX_ZOOM_MODE         <= ZOOM_MODE;
--      elsif(RIGHT_KEY_PRESS = '1' and RIGHT_KEY_LONG_PRESS= '0' and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0'and RETICLE_SEL_EN = '0')then
--          if(unsigned(MUX_ZOOM_MODE) >= to_unsigned(2,MUX_ZOOM_MODE'length))then
--            MUX_ZOOM_MODE <= std_logic_vector(to_unsigned(0,MUX_ZOOM_MODE'length));
--          else  
--            MUX_ZOOM_MODE <= std_logic_vector(unsigned(MUX_ZOOM_MODE) +1);
--          end if; 
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_ZOOM_MODE; 
--          user_settings_mem_wr_data <= SET_ZOOM_MODE &  x"00000" & "0" &MUX_ZOOM_MODE;
      else
          MUX_ZOOM_MODE         <= MUX_ZOOM_MODE;
      end if;     

--      if(LEFT_KEY_PRESS = '1' and LEFT_KEY_LONG_PRESS = '0' and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--        if(RETICLE_COLOR_SEL = '0')then
--            RETICLE_COLOR_SEL <= '1';
--        else
--            RETICLE_COLOR_SEL <= '0';
--        end if;    
--      end if;
      
--      if(OSD_RETICLE_ENABLE_VALID = '1')then
--          MUX_RETICLE_ENABLE        <= OSD_RETICLE_ENABLE;
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_RETICLE_EN; 
--          user_settings_mem_wr_data <= SET_RETICLE_EN &  x"00000"  & "000" &OSD_RETICLE_ENABLE;            
--      elsif(ENABLE_RETICLE_VALID = '1')then
--          MUX_RETICLE_ENABLE      <= ENABLE_RETICLE;
----      elsif(DOWN_KEY_PRESS = '1' and DOWN_KEY_LONG_PRESS = '0' and OSD_EN_OUT = '0'and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
----          MUX_RETICLE_ENABLE        <= not MUX_RETICLE_ENABLE;
----          user_settings_mem_wr_req  <= '1';    
----          user_settings_mem_wr_addr <= SET_RETICLE_EN; 
----          user_settings_mem_wr_data <= SET_RETICLE_EN &  x"00000"  & "000" & (not MUX_RETICLE_ENABLE); 
--      else
--          MUX_RETICLE_ENABLE      <= MUX_RETICLE_ENABLE;
--      end if;

--      if(osd_fit_to_screen_en_valid = '1')then
--          mux_fit_to_screen_en      <= osd_fit_to_screen_en;
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_FIT_TO_SCREEN_EN; 
--          user_settings_mem_wr_data <= SET_FIT_TO_SCREEN_EN &  x"00000"  & "000" & osd_fit_to_screen_en;            
--      elsif(fit_to_screen_en_valid = '1')then
--          mux_fit_to_screen_en <= fit_to_screen_en;
--      else
--          mux_fit_to_screen_en <= mux_fit_to_screen_en;
--      end if;

      if(osd_scaling_disable_valid = '1')then
          mux_scaling_disable       <= osd_scaling_disable;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_FIT_TO_SCREEN_EN; 
          user_settings_mem_wr_data <= SET_FIT_TO_SCREEN_EN &  x"00000"  & "00" & osd_scaling_disable & "0";            
      elsif(scaling_disable_valid = '1')then
          mux_scaling_disable <= scaling_disable;
      else
          mux_scaling_disable <= mux_scaling_disable;
      end if;
      
      if(OSD_FIRING_MODE_VALID = '1')then
          MUX_FIRING_MODE           <= OSD_FIRING_MODE;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_FIRING_MODE; 
          user_settings_mem_wr_data <= SET_FIRING_MODE &  x"00000"  & "000" &OSD_FIRING_MODE;            
      elsif(FIRING_MODE_VALID = '1')then
          MUX_FIRING_MODE      <= FIRING_MODE;
      else
          MUX_FIRING_MODE      <= MUX_FIRING_MODE;
      end if;

      if(OSD_DISTANCE_SEL_VALID = '1')then
          MUX_DISTANCE_SEL          <= OSD_DISTANCE_SEL;
          MUX_DISTANCE_SEL_VALID    <= '1';
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_FIRING_DISTANCE; 
          user_settings_mem_wr_data <= SET_FIRING_DISTANCE &  x"00000" &OSD_DISTANCE_SEL;            
      elsif(DISTANCE_SEL_VALID = '1')then
          MUX_DISTANCE_SEL      <= DISTANCE_SEL;
          MUX_DISTANCE_SEL_VALID<= '1';
      else
          MUX_DISTANCE_SEL      <= MUX_DISTANCE_SEL;
      end if;

      if(OSD_RETICLE_COLOR_SEL_VALID = '1')then
          MUX_RETICLE_COLOR_SEL     <= OSD_RETICLE_COLOR_SEL;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_RETICLE_COLOR_SEL; 
          user_settings_mem_wr_data <= SET_RETICLE_COLOR_SEL &  x"00000"  & "0" &OSD_RETICLE_COLOR_SEL;            
      elsif(RETICLE_COLOR_SEL_VALID = '1')then
          MUX_RETICLE_COLOR_SEL      <= RETICLE_COLOR_SEL;
--      elsif(DOWN_KEY_PRESS = '1' and DOWN_KEY_LONG_PRESS = '0' and OSD_EN_OUT = '0'and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--          MUX_RETICLE_ENABLE        <= not MUX_RETICLE_ENABLE;
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_RETICLE_EN; 
--          user_settings_mem_wr_data <= SET_RETICLE_EN &  x"00000"  & "000" & (not MUX_RETICLE_ENABLE); 
      else
          MUX_RETICLE_COLOR_SEL      <= MUX_RETICLE_COLOR_SEL;
      end if;

      if(OSD_RETICLE_SEL_VALID = '1')then
          MUX_RETICLE_SEL           <= OSD_RETICLE_SEL;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_RETICLE_SEL; 
          user_settings_mem_wr_data <= SET_RETICLE_SEL &  x"00000"  &OSD_RETICLE_SEL;            
      elsif(RETICLE_SEL_VALID = '1')then
          MUX_RETICLE_SEL      <= RETICLE_SEL;
      else
          MUX_RETICLE_SEL      <= MUX_RETICLE_SEL;
      end if;

  
      if(OSD_RETICLE_TYPE_VALID = '1')then
          MUX_RETICLE_TYPE          <= OSD_RETICLE_TYPE;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_RETICLE_TYPE; 
          user_settings_mem_wr_data <= SET_RETICLE_TYPE &  x"00000"  &OSD_RETICLE_TYPE;            
      elsif(RETICLE_TYPE_VALID = '1')then
          MUX_RETICLE_TYPE      <= RETICLE_TYPE;
      else
          MUX_RETICLE_TYPE      <= MUX_RETICLE_TYPE;
      end if;
  
      if(OSD_RETICLE_POS_YX_VALID = '1')then
          MUX_RETICLE_POS_YX        <= OSD_RETICLE_POS_YX;
--          if(OSD_RETICLE_POS_XY_SAVE_EN = '1')then
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_RETICLE_POS_X; 
          user_settings_mem_wr_data <= SET_RETICLE_POS_X & OSD_RETICLE_POS_YX;    
--          end if;          
      elsif(RETICLE_POS_YX_VALID = '1')then    
          MUX_RETICLE_POS_YX      <= RETICLE_POS_YX;
--      elsif(BPR_RETICLE_POS_YX_VALID = '1')then    
--          MUX_RETICLE_POS_YX      <= BPR_RETICLE_POS_YX;
      else
          MUX_RETICLE_POS_YX      <= MUX_RETICLE_POS_YX;
      end if;
  
--      if(OSD_RETICLE_POS_Y_VALID = '1')then
--          MUX_RETICLE_POS_Y         <= OSD_RETICLE_POS_Y;
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_RETICLE_POS_Y; 
--          user_settings_mem_wr_data <= SET_RETICLE_POS_Y &  x"000" & "00" & OSD_RETICLE_POS_Y;          
--      elsif(RETICLE_POS_Y_VALID = '1')then     
--          MUX_RETICLE_POS_Y      <= RETICLE_POS_Y;
--      else
--          MUX_RETICLE_POS_Y      <= MUX_RETICLE_POS_Y;
--      end if;


      if(OSD_PRESET_SEL_VALID = '1')then
          MUX_PRESET_SEL            <= OSD_PRESET_SEL;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_PRESET_SEL; 
          user_settings_mem_wr_data <= SET_PRESET_SEL & x"00000" &OSD_PRESET_SEL;          
      elsif(PRESET_SEL_VALID = '1')then    
          MUX_PRESET_SEL      <= PRESET_SEL;
      else
          MUX_PRESET_SEL      <= MUX_PRESET_SEL;
      end if;

      if(OSD_PRESET_P1_POS_VALID = '1')then
          MUX_PRESET_P1_POS         <= OSD_PRESET_P1_POS;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_PRESET_P1_POS; 
          user_settings_mem_wr_data <= SET_PRESET_P1_POS & OSD_PRESET_P1_POS;          
      elsif(PRESET_P1_POS_VALID = '1')then    
          MUX_PRESET_P1_POS      <= PRESET_P1_POS;
      else
          MUX_PRESET_P1_POS      <= MUX_PRESET_P1_POS;
      end if;

      if(OSD_PRESET_P2_POS_VALID = '1')then
          MUX_PRESET_P2_POS         <= OSD_PRESET_P2_POS;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_PRESET_P2_POS; 
          user_settings_mem_wr_data <= SET_PRESET_P2_POS & OSD_PRESET_P2_POS;          
      elsif(PRESET_P2_POS_VALID = '1')then    
          MUX_PRESET_P2_POS      <= PRESET_P2_POS;
      else
          MUX_PRESET_P2_POS      <= MUX_PRESET_P2_POS;
      end if;

      if(OSD_PRESET_P3_POS_VALID = '1')then
          MUX_PRESET_P3_POS         <= OSD_PRESET_P3_POS;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_PRESET_P3_POS; 
          user_settings_mem_wr_data <= SET_PRESET_P3_POS & OSD_PRESET_P3_POS;          
      elsif(PRESET_P3_POS_VALID = '1')then    
          MUX_PRESET_P3_POS      <= PRESET_P3_POS;
      else
          MUX_PRESET_P3_POS      <= MUX_PRESET_P3_POS;
      end if;

      if(OSD_PRESET_P4_POS_VALID = '1')then
          MUX_PRESET_P4_POS         <= OSD_PRESET_P4_POS;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_PRESET_P4_POS; 
          user_settings_mem_wr_data <= SET_PRESET_P4_POS & OSD_PRESET_P4_POS;          
      elsif(PRESET_P4_POS_VALID = '1')then    
          MUX_PRESET_P4_POS      <= PRESET_P4_POS;
      else
          MUX_PRESET_P4_POS      <= MUX_PRESET_P4_POS;
      end if;

--      if(OSD_OLED_DIMCTL_VALID = '1')then
--          MUX_OLED_DIMCTL           <= OSD_OLED_DIMCTL;
----          OLED_REG_DATA             <= OSD_OLED_DIMCTL;
--          MUX_OLED_DIMCTL_VALID     <= '1';
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_OLED_DIMCTL; 
--          user_settings_mem_wr_data <= SET_OLED_DIMCTL & x"0000" & OSD_OLED_DIMCTL;  
--      elsif(OLED_DIMCTL_VALID = '1')then     
--          MUX_OLED_DIMCTL       <= OLED_DIMCTL;
----          OLED_REG_DATA         <= OLED_DIMCTL;
--          MUX_OLED_DIMCTL_VALID <= '1';
--      else
--          MUX_OLED_DIMCTL       <= MUX_OLED_DIMCTL;
--      end if;      

      if(OSD_OLED_BRIGHTNESS_VALID = '1')then
          MUX_OLED_BRIGHTNESS           <= OSD_OLED_BRIGHTNESS;
--          OLED_REG_DATA             <= OSD_OLED_DIMCTL;
          MUX_OLED_BRIGHTNESS_VALID     <= '1';
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_OLED_BRIGHTNESS; 
          user_settings_mem_wr_data <= SET_OLED_BRIGHTNESS & x"0000" & OSD_OLED_BRIGHTNESS;  
      elsif(OLED_BRIGHTNESS_VALID = '1')then     
          MUX_OLED_BRIGHTNESS       <= OLED_BRIGHTNESS;
--          OLED_REG_DATA         <= OLED_DIMCTL;
          MUX_OLED_BRIGHTNESS_VALID <= '1';
      else
          MUX_OLED_BRIGHTNESS       <= MUX_OLED_BRIGHTNESS;
      end if;     
      
      MUX_OLED_BRIGHTNESS_MAP_VALID  <= MUX_OLED_BRIGHTNESS_VALID;
      MUX_OLED_BRIGHTNESS_MAP        <= std_logic_vector(resize(to_unsigned(28,7)+ unsigned(MUX_OLED_BRIGHTNESS)*2,MUX_OLED_BRIGHTNESS_MAP'length)); 
      MUX_OLED_CONTRAST_MAP_VALID    <= MUX_OLED_CONTRAST_VALID;
      MUX_OLED_CONTRAST_MAP          <= std_logic_vector(resize(to_unsigned(28,7)+ unsigned(MUX_OLED_CONTRAST)*2,MUX_OLED_CONTRAST_MAP'length)); 
      
      
      if(OSD_OLED_CONTRAST_VALID = '1')then
          MUX_OLED_CONTRAST           <= OSD_OLED_CONTRAST;
--          OLED_REG_DATA             <= OSD_OLED_DIMCTL;
          MUX_OLED_CONTRAST_VALID     <= '1';
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_OLED_CONTRAST; 
          user_settings_mem_wr_data <= SET_OLED_CONTRAST & x"0000" & OSD_OLED_CONTRAST;  
      elsif(OLED_CONTRAST_VALID = '1')then     
          MUX_OLED_CONTRAST       <= OLED_CONTRAST;
--          OLED_REG_DATA         <= OLED_DIMCTL;
          MUX_OLED_CONTRAST_VALID <= '1';
      else
          MUX_OLED_CONTRAST       <= MUX_OLED_CONTRAST;
      end if; 
 
      if(OSD_OLED_GAMMA_TABLE_SEL_VALID = '1')then
          MUX_OLED_GAMMA_TABLE_SEL  <= OSD_OLED_GAMMA_TABLE_SEL;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_OLED_GAMMA_TABLE_SEL; 
          user_settings_mem_wr_data <= SET_OLED_GAMMA_TABLE_SEL & x"0000" & OSD_OLED_GAMMA_TABLE_SEL; 
      elsif(OLED_GAMMA_TABLE_SEL_VALID = '1')then     
          MUX_OLED_GAMMA_TABLE_SEL  <= OLED_GAMMA_TABLE_SEL;
      else
          MUX_OLED_GAMMA_TABLE_SEL  <= MUX_OLED_GAMMA_TABLE_SEL;
      end if;  


      if(OSD_IMG_SHIFT_VERT_VALID = '1')then
          MUX_IMG_SHIFT_VERT            <= OSD_IMG_SHIFT_VERT;
--          OLED_REG_DATA             <= OSD_OLED_POS_V;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_IMG_SHIFT_VERT; 
          user_settings_mem_wr_data <= SET_IMG_SHIFT_VERT & x"000" & "00" &OSD_IMG_SHIFT_VERT;   
      elsif(IMG_SHIFT_VERT_VALID = '1')then     
          MUX_IMG_SHIFT_VERT       <= IMG_SHIFT_VERT;
--          OLED_REG_DATA        <= OLED_POS_V;
      else
          MUX_IMG_SHIFT_VERT   <= MUX_IMG_SHIFT_VERT;
      end if;  
 
      if(OSD_OLED_POS_V_VALID = '1')then
          MUX_OLED_POS_V            <= OSD_OLED_POS_V;
--          OLED_REG_DATA             <= OSD_OLED_POS_V;
          MUX_OLED_POS_V_VALID      <= '1';
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_OLED_POS_V; 
          user_settings_mem_wr_data <= SET_OLED_POS_V & x"0000" & OSD_OLED_POS_V;   
      elsif(OLED_POS_V_VALID = '1')then     
          MUX_OLED_POS_V       <= OLED_POS_V;
--          OLED_REG_DATA        <= OLED_POS_V;
          MUX_OLED_POS_V_VALID <= '1';
      else
          MUX_OLED_POS_V   <= MUX_OLED_POS_V;
      end if;   
      
      if(OSD_OLED_POS_H_VALID = '1')then
          MUX_OLED_POS_H            <= OSD_OLED_POS_H;
--          OLED_REG_DATA             <= OSD_OLED_POS_H;
          MUX_OLED_POS_H_VALID      <= '1';
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_OLED_POS_H; 
          user_settings_mem_wr_data <= SET_OLED_POS_H & x"000" &"000" &OSD_OLED_POS_H;                
      elsif(OLED_POS_H_VALID = '1')then     
          MUX_OLED_POS_H       <= OLED_POS_H;
--          OLED_REG_DATA        <= OLED_POS_H;
          MUX_OLED_POS_H_VALID <= '1';
      else
          MUX_OLED_POS_H   <= MUX_OLED_POS_H;
      end if; 

  
      if(OSD_POLARITY_VALID = '1')then
          MUX_POLARITY              <= OSD_POLARITY;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_POLARITY; 
          user_settings_mem_wr_data <= SET_POLARITY & x"00000" & "00" & OSD_POLARITY;             
--          user_settings_mem_wr_addr <= x"0F"; 
--          user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE  & MUX_ENABLE_LOGO  
--                                         & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                                         & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING 
--                                         & OSD_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
--                                         & ENABLE_NUC &ENABLE_TP ;          
      elsif(POLARITY_VALID = '1')then
          MUX_POLARITY     <= POLARITY;
--      elsif(UP_KEY_PRESS = '1' and UP_KEY_LONG_PRESS = '0' and OSD_EN_OUT = '0' and OLED_MENU_EN_OUT = '0' and RETICLE_SEL_EN = '0')then
--          if(MUX_POLARITY = '1')then
--            MUX_POLARITY  <= '0';
--          else
--            MUX_POLARITY  <= '1'; 
--          end if;
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= SET_POLARITY; 
--          user_settings_mem_wr_data <= SET_POLARITY & x"00000" & "000" & MUX_POLARITY;             
      else
          MUX_POLARITY     <= MUX_POLARITY;
      end if;
          
          
--        if(OSD_DDE_SEL_VALID = '1')then
--            MUX_DDE_SEL       <= OSD_DDE_SEL;
--            MUX_DDE_SEL_VALID <= '1';
--        elsif(DDE_SEL_VALID = '1')then
--            MUX_DDE_SEL     <= DDE_SEL;
--            MUX_DDE_SEL_VALID <= '1';
--        else
--            MUX_DDE_SEL       <= MUX_DDE_SEL;
--            MUX_DDE_SEL_VALID <= '0';
--        end if;
      
      if(OSD_SNUC_EN_VALID = '1')then
          MUX_ENABLE_SNUC           <= OSD_SNUC_EN;
          user_settings_mem_wr_req  <= '1';       
          user_settings_mem_wr_addr <= SET_SOFTNUC_EN; 
          user_settings_mem_wr_data <= SET_SOFTNUC_EN & x"00000" & "000" & OSD_SNUC_EN;              
      elsif(ENABLE_SNUC_VALID = '1')then    
          MUX_ENABLE_SNUC    <= ENABLE_SNUC;
      else
          MUX_ENABLE_SNUC    <= MUX_ENABLE_SNUC;
      end if;

      if(OSD_SMOOTHING_EN_VALID = '1')then
          MUX_ENABLE_SMOOTHING      <= OSD_SMOOTHING_EN;
          av_wr_blur                <= '1';
          av_addr_blur              <= x"00";
          av_data_blur              <= x"000" & "000" & OSD_SMOOTHING_EN;           
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_SMOOTH_FILTER_EN; 
          user_settings_mem_wr_data <= SET_SMOOTH_FILTER_EN & x"00000" & "000" & OSD_SMOOTHING_EN;     
      elsif(ENABLE_SMOOTHING_FILTER_VALID = '1')then    
          MUX_ENABLE_SMOOTHING    <= ENABLE_SMOOTHING_FILTER;
      else
          MUX_ENABLE_SMOOTHING    <= MUX_ENABLE_SMOOTHING;
      end if;
      
      if(OSD_SHARPNESS_VALID = '1')then
          MUX_SHARPNESS       <= OSD_SHARPNESS;
          av_wr_sharp_edge    <= '1';      
          av_addr_sharp_edge  <= x"02";    
          av_data_sharp_edge  <= x"000" &OSD_SHARPNESS;   
           
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_SHARPNESS; 
          user_settings_mem_wr_data <= SET_SHARPNESS & x"00000" & OSD_SHARPNESS;  
      elsif(SHARPNESS_VALID = '1')then    
          MUX_SHARPNESS    <= SHARPNESS;
      else
          MUX_SHARPNESS    <= MUX_SHARPNESS;
      end if;

        


--      if(OSD_SHARPENING_EN_VALID = '1')then
--          MUX_ENABLE_SMOOTHING      <= OSD_SHARPENING_EN;
--          av_wr_blur                <= '1';
--          av_addr_blur              <= x"00";
--          av_data_blur              <= x"000" & "000" & OSD_SMOOTHING_EN;           
--          user_settings_mem_wr_req  <= '1';    
--          user_settings_mem_wr_addr <= x"00"; 
--          user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & MUX_ENABLE_EDGE  & MUX_ENABLE_LOGO  
--                                         & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                                         &  & OSD_SMOOTHING_EN
--                                         & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC 
--                                         & ENABLE_NUC &ENABLE_TP ;    
--      elsif(ENABLE_SHARPENING_FILTER_VALID = '1')then    
--          MUX_ENABLE_SMOOTHING    <= ENABLE_SMOOTHING_FILTER;
--      else
--          MUX_ENABLE_SMOOTHING    <= MUX_ENABLE_SMOOTHING;
--      end if;

      if(OSD_EDGE_EN_VALID = '1')then
          MUX_ENABLE_EDGE <= OSD_EDGE_EN;
          if(OSD_EDGE_EN='0')then
--              av_wr_blur          <= '1';      
--              av_addr_blur        <= x"00";    
--              av_data_blur        <= x"0000";            
              av_wr_blur          <= '1';      
              av_addr_blur        <= x"00";    
              av_data_blur        <= x"000" & "000" & MUX_ENABLE_SMOOTHING;  
--              av_wr_sharp_edge    <= '1';      
--              av_addr_sharp_edge  <= x"00";    
--              av_data_sharp_edge  <= x"000" & "000" & ENABLE_SHARPENING_FILTER;       
              av_wr_sharp_edge    <= '1';
              av_addr_sharp_edge  <= x"00";
              av_data_sharp_edge  <= x"0001";                                     
          else    
              av_wr_blur          <= '1';      
              av_addr_blur        <= x"00";    
              av_data_blur        <= x"0001";  
              av_wr_sharp_edge    <= '1';      
              av_addr_sharp_edge  <= x"00";    
              av_data_sharp_edge  <= x"0003";         
          end if;       
          user_settings_mem_wr_req  <= '1';
          user_settings_mem_wr_addr <= SET_EDGE_FILTER_EN; 
          user_settings_mem_wr_data <= SET_EDGE_FILTER_EN & x"00000" & "000" & OSD_EDGE_EN;                
--          user_settings_mem_wr_addr <= x"0F"; 
--          user_settings_mem_wr_data <= x"0F00" & "000"  &PAL_nNTSC & OSD_EDGE_EN  & MUX_ENABLE_LOGO  
--                                         & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
--                                         & ENABLE_SHARPENING_FILTER & MUX_ENABLE_SMOOTHING
--                                         & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC 
--                                         & ENABLE_NUC &ENABLE_TP;    
      elsif(ENABLE_EDGE_FILTER_VALID = '1')then    
          MUX_ENABLE_EDGE    <= ENABLE_EDGE_FILTER;
      else
          MUX_ENABLE_EDGE    <= MUX_ENABLE_EDGE;
      end if;



      if(OSD_CP_TYPE_VALID = '1')then
          MUX_CP_TYPE               <= OSD_CP_TYPE;
          user_settings_mem_wr_req  <= '1';    
          user_settings_mem_wr_addr <= SET_COLOR_PALETTE_MODE; 
          user_settings_mem_wr_data <= SET_COLOR_PALETTE_MODE &  x"0000" & "000" &OSD_CP_TYPE(4 downto 0);        
      elsif(CP_TYPE_VALID = '1')then
          MUX_CP_TYPE      <= CP_TYPE;
      else
          MUX_CP_TYPE      <= MUX_CP_TYPE;
      end if;
   
      --if(OSD_LOGO_EN_VALID = '1')then
      --    MUX_ENABLE_LOGO     <= OSD_LOGO_EN;
      --    user_settings_mem_wr_req  <= '1';    
      --    user_settings_mem_wr_addr <= x"00"; 
      --    user_settings_mem_wr_data <= x"0F00" & "000" &PAL_nNTSC & ENABLE_RETICLE  & OSD_LOGO_EN  
      --                                 & ENABLE_CP & ENABLE_BRIGHT_CONTRAST & ENABLE_ZOOM  
      --                                 & ENABLE_SHARPENING_FILTER & ENABLE_SMOOTH_FILTER 
      --                                 & MUX_POLARITY & ENABLE_BADPIXREM & MUX_ENABLE_SNUC
      --                                 & ENABLE_NUC &ENABLE_TP;         
      --elsif(ENABLE_LOGO_VALID = '1')then
      if(ENABLE_LOGO_VALID = '1')then
          MUX_ENABLE_LOGO    <= ENABLE_LOGO;
      else
          MUX_ENABLE_LOGO     <= MUX_ENABLE_LOGO;
      end if;
      
      MUX_GYRO_CALIB_EN <= OSD_GYRO_CALIB_EN or GYRO_CALIB_EN;
      
      if(MUX_GYRO_CALIB_EN ='1')then
        GYRO_CALIB_STATUS <= '0';
      elsif(GYRO_SOFT_CALIB_DONE = '1')then
        GYRO_CALIB_STATUS <= '1';
      end if;
      
      if(OSD_GYRO_DATA_DISP_EN_VALID = '1')then
        MUX_GYRO_DATA_DISP_EN     <= OSD_GYRO_DATA_DISP_EN;                                                      
        user_settings_mem_wr_req  <= '1';                                              
        user_settings_mem_wr_addr <= SET_GYRO_DATA_DISP_EN;                                     
        user_settings_mem_wr_data <= SET_GYRO_DATA_DISP_EN & x"00000" & "00" & GYRO_DATA_DISP_MODE & OSD_GYRO_DATA_DISP_EN;       
      elsif(GYRO_DATA_DISP_EN_VALID = '1')then
        MUX_GYRO_DATA_DISP_EN <= GYRO_DATA_DISP_EN;
      end if;

      if(CENTER_KEY_PRESS='1') then
        MENU_SEL_CENTER <= '1';
      else
        MENU_SEL_CENTER <= MENU_SEL_CENTER_U;
      end if;

      if(UP_KEY_PRESS='1') then
        MENU_SEL_UP         <= '1';
      else
        MENU_SEL_UP         <= MENU_SEL_UP_U;
      end if;  
      if(DOWN_KEY_PRESS='1') then
        MENU_SEL_DN        <= '1';
      else
        MENU_SEL_DN         <= MENU_SEL_DN_U;
      end if;  

      if(LEFT_KEY_PRESS='1') then
        MENU_SEL_LEFT         <= '1';
--        if(main_menu_sel = '1')then
--            main_menu_sel <= '0';
--        else       
--            main_menu_sel <= '1';
--        end if;
      else
        MENU_SEL_LEFT         <= MENU_SEL_LEFT_U;
      end if;  

      if(RIGHT_KEY_PRESS='1') then
        MENU_SEL_RIGHT         <= '1';
--        ADVANCE_MENU_TRIG_IN   <= '1';
--        if(advance_menu_sel = '1')then
--            advance_menu_sel <= '0';
--        else       
--            advance_menu_sel <= '1';
--        end if;
      else
        MENU_SEL_RIGHT         <= MENU_SEL_RIGHT_U;
      end if;
      
  

    end if;
end process;


process(CLK, RST)
  begin
      if RST = '1' then
        OSD_START_NUC1PTCALIB  <= '0';
        OSD_START_NUC1PT2CALIB <= '0'; 
        nuc1pt_start_in        <= '0';
        latch_toggle_gpio      <= '0';
        auto_nuc1pt_done       <= '0';
      elsif rising_edge(CLK) then 
            nuc1pt_start_in   <= '0';
            auto_nuc1pt_done  <= snapshot_nuc_done or NUC1pt_done_offset;
            if((MUX_NUC_MODE = "10" or MUX_NUC_MODE = "01") and (MUX_BLADE_MODE = "11"))then
                nuc1pt_start_in   <= OSD_START_NUC1PTCALIB or OSD_START_NUC1PT2CALIB;                    
            elsif ((MUX_NUC_MODE = "10" or MUX_NUC_MODE = "01") and (MUX_BLADE_MODE = "01" or MUX_BLADE_MODE = "10"))then
--                latch_toggle_gpio <= toggle_gpio ;
                nuc1pt_start_in   <= do_nuc1pt_at_power_on;   
            end if; 
             
--          if OSD_NUC_MODE_VALID = '1' then
--             if(OSD_NUC_MODE = "10")then --MANUAL (1-PT)
--               if(OSD_BLADE_MODE = "11")then
             if(MUX_NUC_MODE = "10")then --MANUAL (1-PT)
               if(MUX_BLADE_MODE = "11" )then
--                 OSD_START_NUC1PTCALIB <= OSD_START_CALIB or OSD_NUC_MODE_VALID;
                 OSD_START_NUC1PTCALIB <= OSD_START_CALIB or MUX_NUC_MODE_VALID or do_nuc1pt_at_power_on; 
               elsif(MUX_BLADE_MODE = "00" )then
                 OSD_START_NUC1PTCALIB <= OSD_START_CALIB;
               else
                 OSD_START_NUC1PTCALIB <= '0';
               end if;  
--             elsif(OSD_NUC_MODE = "01")then --SEMI-NUC 
--               if(OSD_BLADE_MODE = "11")then
             elsif(MUX_NUC_MODE = "01")then --SEMI-NUC 
               if(MUX_BLADE_MODE = "11" )then
--                 OSD_START_NUC1PT2CALIB <= OSD_START_CALIB or OSD_NUC_MODE_VALID;
                 OSD_START_NUC1PT2CALIB <= OSD_START_CALIB or MUX_NUC_MODE_VALID or do_nuc1pt_at_power_on; 
               elsif(MUX_BLADE_MODE = "00" )then
                 OSD_START_NUC1PT2CALIB <= OSD_START_CALIB;
               else
                 OSD_START_NUC1PT2CALIB <= '0';
               end if;  
             else -- Shutterless
                OSD_START_NUC1PTCALIB  <= '0';
                OSD_START_NUC1PT2CALIB <= '0';                 
             end if;
--          end if;      
      end if;  
  end process;



DAC_FILTER_DIS <='1';
TH_SNR_ADR <= '0';

FPGA_BUSY <= '0';
VIDEO_IN_MUX      <= VIDEO_CTRL_REG(3);   -- '1' > Use Internal Mire (counter) for Video Input, '0' use real Video Input


SELECT_VIDEO_OUT     <= VIDEO_CTRL_REG(2 downto 0); -- Select DPHE if "10" or "11" and Basic AGC if "01" and neither if "00"  

HDC_2010_ADDR   <= x"40";
SHUTTER_ADDR    <= x"52";
--BAT_ADC_ADDR    <= x"51";

I2C_ADDRESS     <= I2C_ADDRESS_combined(14 downto 8);
I2C_REG_ADDRESS <= I2C_ADDRESS_combined(7 downto 0);

I2C_ReadEN_1    <=  I2C_ReadEN     when (I2C_ADDRESS_combined(14 downto 8)= ADV_DEV_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)= HDC_2010_ADDR(6 downto 0))else '0' ;
I2C_WriteEN_1   <=  I2C_WriteEN    when (I2C_ADDRESS_combined(14 downto 8)= ADV_DEV_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)= HDC_2010_ADDR(6 downto 0))else '0' ; 
I2C_ReadEN_2    <=  '0'            when (I2C_ADDRESS_combined(14 downto 8)= ADV_DEV_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)= HDC_2010_ADDR(6 downto 0))else I2C_ReadEN ;
I2C_WriteEN_2   <=  '0'            when (I2C_ADDRESS_combined(14 downto 8)= ADV_DEV_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)= HDC_2010_ADDR(6 downto 0))else I2C_WriteEN; 
I2C_Busy        <=  I2C_Busy_1     when (I2C_ADDRESS_combined(14 downto 8)= ADV_DEV_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)= HDC_2010_ADDR(6 downto 0))else I2C_Busy_2 ;      
I2C_ReadData    <=  I2C_ReadData_1 when (I2C_ADDRESS_combined(14 downto 8)= ADV_DEV_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)= HDC_2010_ADDR(6 downto 0))else I2C_ReadData_2 ;   
I2C_ReadDAV     <=  I2C_ReadDAV_1  when (I2C_ADDRESS_combined(14 downto 8)= ADV_DEV_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)= HDC_2010_ADDR(6 downto 0))else I2C_ReadDAV_2 ; 
DATA_16_EN      <=  I2C_DATA_16_EN when (I2C_ADDRESS_combined(14 downto 8)= OLED_VGN_ADC_DEV_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)= SHUTTER_ADDR(6 downto 0) or I2C_ADDRESS_combined(14 downto 8)=BAT_ADC_DEV_ADDR(6 downto 0))else '0' ;
 
i_I2C_Master_1: ENTITY WORK.I2C_MASTER
  GENERIC MAP(
    input_clk => SYS_FREQ,  --input clock speed from user logic in Hz
    bus_clk   => I2C_FREQ        --speed the i2c bus (scl) will run at in Hz
  )
  PORT MAP(
    clk        => CLK,--CLK_27MHZ,
    reset_n    => RST,
    tick1us    => TICK1US, 
    i2c_delay_reg => I2C_DELAY_REG,
    ena        => '1',
    addr       => I2C_ADDRESS,
    reg_addr   => I2C_REG_ADDRESS,
    read_en    => I2C_ReadEN_1,
    write_en   => I2C_WriteEN_1,
    data_wr    => I2C_WriteData,
    busy       => I2C_Busy_1,
    data_rd    => I2C_ReadData_1,
    read_valid => I2C_ReadDAV_1,
    ack_error  => open,
    data_16_en => '0',
    sda        => FPGA_I2C1_SDA,
    scl        => FPGA_I2C1_SCL
  );


i_I2C_Master_2: ENTITY WORK.I2C_MASTER
  GENERIC MAP(
    input_clk => SYS_FREQ,  --input clock speed from user logic in Hz
    bus_clk   => I2C_FREQ        --speed the i2c bus (scl) will run at in Hz
  )
  PORT MAP(
    clk           => CLK,--CLK_27MHZ,
    reset_n       => RST,
    tick1us       => TICK1US, 
    i2c_delay_reg => I2C_DELAY_REG,
    ena           => '1',
    addr          => I2C_ADDRESS,
    reg_addr      => I2C_REG_ADDRESS,
    read_en       => I2C_ReadEN_2,
    write_en      => I2C_WriteEN_2,
    data_wr       => I2C_WriteData,
    busy          => I2C_Busy_2,
    data_rd       => I2C_ReadData_2,
    read_valid    => I2C_ReadDAV_2,
    ack_error     => i2c_ack_error,
    data_16_en    => DATA_16_EN,
    sda           => FPGA_B2B_M_I2C2_SDA,
    scl           => FPGA_B2B_M_I2C2_SCL
  );


--  i_SPI_Comm: entity WORK.Detector_SPI_Comm
--  GENERIC MAP(
--    CLK_Freq  => SYS_FREQ,  -- Frequency of Input Clock for User Logic (Hz)
--    SPI_Freq  => SPI_FREQ,         -- Frequency of SPI Communication (Hz)
--    Data_Size => 16
--  )
--  PORT MAP(
--    -----------------------------------------
--    --  Device Clock and Asynchronous Reset
--    RST       => RST,
--    CLK       => CLK,
--    -----------------------------------------
--    --  Device FPGA Side I/O
--    WriteData   => SPI_WriteData,
--    Write_EN    => SPI_WriteEN,
--    Read_EN     => SPI_ReadEN,
--    ADDRESS     => SPI_ADDRESS,
--    ReadData    => SPI_ReadData,
--    Wait_Req    => SPI_WaitReq,
--    ReadDataValid => SPI_ReadDAV,
--    -----------------------------------------
--    -- SPI Physical Interface
        

--    SPI_SS_N    => SNSR_FPGA_NRST_SPI_CS_1,
--    SPI_SCLK    => SNSR_FPGA_I2C2_SCL_SPI_SCK_1,
--    SPI_MOSI    => SNSR_FPGA_I2C2_SDA_SPI_SDO_1,
--    SPI_MISO    => '0'
--  );
UART_EN_GEN :If (MIPI_EN = TRUE) Generate
 process(CLK, RST)begin
        if RST = '1' then
          UART_EN_TINEOUT <= (others=>'0');
          UART_EN <= '0';
        elsif rising_edge(CLK) then       
            if TICK1S = '1' then
               if(UART_EN_TINEOUT >= 10)then
                UART_EN <= '1';
                UART_EN_TINEOUT <= UART_EN_TINEOUT;
               else
                UART_EN_TINEOUT<= UART_EN_TINEOUT + 1;
               end if; 
            end if;
        end if;
  end process;  
FPGA_B2B_M_UART_TX <= UART_TX WHEN UART_EN = '1' ELSE 'Z';
UART_RX            <= FPGA_B2B_M_UART_RX WHEN UART_EN = '1' ELSE 'Z';    
end generate;

UART_EN_GEN2 : If (OLED_EN = TRUE or EK_EN = TRUE) Generate
    FPGA_B2B_M_UART_TX <= UART_TX; 
    UART_RX            <= FPGA_B2B_M_UART_RX;
end generate;


UART_EN_GEN3 : If (USB_EN = TRUE) Generate
    FPGA_B2B_M_UART_RX <= UART_TX; 
    UART_RX            <= FPGA_B2B_M_UART_TX;
end generate;


i_UART_PERIPHERAL_CONDUIT : entity work.UART_Peripheral_Conduit
  generic map(
    Fxtal        =>  SYS_FREQ, -- in Hertz
    Baud1        =>  115200,
    Baud2        =>  9600,
    Baud3        =>  19200,
    Baud4        =>  38400,
    Baud5        =>  57600,    
    Baud6        =>  4800,
    Baud7        =>  921600,   
    --BaudSel     :   STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    WordFormat  => "10",
    RS_232_485   => '0', -- '0' -> RS232, '1' -> RS485
    Parity     => '0',
    ModeParity  => '0' 
    )
  port map(
    -----------------------------------------
    --  Device Clock and Asynchronous Reset
    CLK          => CLK,--CLK_27MHZ,
    RST          => RST,
    -----------------------------------------
    --  UART Specifics
    -- BaudSel      : in STD_LOGIC            := '0'; -- Baud Rate Select Baud1 (0) / Baud2 (1)
    -- WordFormat   : in STD_LOGIC_VECTOR (1 downto 0)  := "10";-- 6 bits (00) / 7b (01) / 8b (10)
    -----------------------------------------
    --  Input from HPS to FPGA
    AVS_WriteData    => av_uart_writedata, -- writedata  - Avalon MM
    AVS_Write_EN     => av_uart_write,          -- write    - Avalon MM
    AVS_Read_EN      => av_uart_read,          -- read     - Avalon MM
    AVS_Address      => av_uart_address,  -- AVS_Address    - Avalon MM
    -----------------------------------------
    --  Output from FPGA to HPS
    AVS_ReadData     => av_uart_readdata, -- readdata   - Avalon MM
    AVS_Wait_Req     => av_uart_waitrequest,           -- waitreq    - Avalon MM
    AVS_ReadDAV      => av_uart_readdatavalid,           -- AVS_ReadDAV- Avalon MM
    -----------------------------------------
    --  Serial Input Data from Device to FPGA
    UART_Rx          => UART_Rx,--FPGA_B2B_M_UART_RX,
    -----------------------------------------
    --  Serial Output Data from FPGA to Device
    UART_Tx        => UART_Tx,--FPGA_B2B_M_UART_TX, 
    Trigger_int_signal   => trigger,
    -----------------------------------------
    --  Signals from FPGA to LTC2870
    SEL_232_485     =>  OPEN                        -- FPGA_GPIO_RS232/RS485 = FPGA_GPIO_TE485
    -----------------------------------------       -- Both signals are either 1 or 0 together
    );

--i_UART_PERIPHERAL_CONDUIT_BNO : entity work.UART_Peripheral_Conduit
--  generic map(
--    Fxtal        =>  SYS_FREQ, -- in Hertz
--    Baud1        =>  115200,
--    Baud2        =>  9600,
--    Baud3        =>  19200,
--    Baud4        =>  38400,
--    Baud5        =>  57600,    
--    Baud6        =>  4800,
--    Baud7        =>  921600,   
--    --BaudSel     :   STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
--    WordFormat  => "10",
--    RS_232_485   => '0', -- '0' -> RS232, '1' -> RS485
--    Parity     => '0',
--    ModeParity  => '0' 
--    )
--  port map(
--    -----------------------------------------
--    --  Device Clock and Asynchronous Reset
--    CLK          => CLK,--CLK_27MHZ,
--    RST          => RST,
--    -----------------------------------------
--    --  UART Specifics
--    -- BaudSel      : in STD_LOGIC            := '0'; -- Baud Rate Select Baud1 (0) / Baud2 (1)
--    -- WordFormat   : in STD_LOGIC_VECTOR (1 downto 0)  := "10";-- 6 bits (00) / 7b (01) / 8b (10)
--    -----------------------------------------
--    --  Input from HPS to FPGA
--    AVS_WriteData    => av_uart2_writedata, -- writedata  - Avalon MM
--    AVS_Write_EN     => av_uart2_write,          -- write    - Avalon MM
--    AVS_Read_EN      => av_uart2_read,          -- read     - Avalon MM
--    AVS_Address      => av_uart2_address,  -- AVS_Address    - Avalon MM
--    -----------------------------------------
--    --  Output from FPGA to HPS
--    AVS_ReadData     => av_uart2_readdata, -- readdata   - Avalon MM
--    AVS_Wait_Req     => av_uart2_waitrequest,           -- waitreq    - Avalon MM
--    AVS_ReadDAV      => av_uart2_readdatavalid,           -- AVS_ReadDAV- Avalon MM
--    -----------------------------------------
--    --  Serial Input Data from Device to FPGA
--    UART_Rx          => FPGA_RX_BNO_TX,
--    -----------------------------------------
--    --  Serial Output Data from FPGA to Device
--    UART_Tx        => open,
--    Trigger_int_signal   => trigger2,
--    -----------------------------------------
--    --  Signals from FPGA to LTC2870
--    SEL_232_485     =>  OPEN                        -- FPGA_GPIO_RS232/RS485 = FPGA_GPIO_TE485
--    -----------------------------------------       -- Both signals are either 1 or 0 together
--    );

--i_bno_packet_rx : bno_packet_rx
--  port map(
--    clk                   => clk,
--    rst                   => rst,
--    trigger               => trigger2, 
--    av_uart_readdata      => av_uart2_readdata(7 downto 0),
--    av_uart_readdatavalid => av_uart2_readdatavalid,
--    av_uart_waitrequest   => av_uart2_waitrequest,
--    av_uart_address       => av_uart2_address,
--    av_uart_read          => av_uart2_read, 
--    yaw                   => yaw,
--    pitch                 => roll,--pitch,--  -- gyro mounting is different from original
--    roll                  => pitch,--roll ,--pitch,
--    x_accel               => x_accel,
--    y_accel               => y_accel,
--    z_accel               => z_accel,
--    crc_error             => crc_error,
--    bno_data_valid        => bno_data_valid
--    );


--i_GYRO_DATA_DECODE : entity work.GYRO_DATA_DECODE
--  Port map (
--  CLK              => CLK,
--  RST              => RST,
--  YAW              => yaw,
--  YAW_OFFSET       => yaw_offset,--x"0000",
--  PITCH            => pitch,
--  PITCH_OFFSET     => pitch_offset,--x"0000",
--  CORRECTED_YAW    => corrected_yaw,
--  CORRECTED_PITCH  => corrected_pitch
--   ); 

i_icm_calib : entity work.icm_calibration 
  Port map( 
            CLK                        => CLK,
            RST                        => RST,
            TICK_1S                    => TICK1S,
            start_calibration          => MUX_GYRO_CALIB_EN,--OSD_GYRO_CALIB_EN,
            magneto_x                  => MAGNETO_X_DATA,
            magneto_y                  => MAGNETO_Y_DATA,
            magneto_z                  => MAGNETO_Z_DATA,
            magneto_x_crr              => MAGNETO_X_DATA_CORR,   
            magneto_y_crr              => MAGNETO_Y_DATA_CORR,  
            magneto_z_crr              => MAGNETO_Z_DATA_CORR,  
            calibration_done           => GYRO_CALIB_DONE
              
  );

i_icm_soft_calib : entity work.icm_soft_calibration 
  Port map( 
            CLK                        => CLK,
            RST                        => RST,
            TICK_1S                    => TICK1S,
            start_calibration          => GYRO_CALIB_DONE,
--            magneto_x                  => magneto_x_data_corr,
            magneto_y                  => MAGNETO_Y_DATA_CORR,
            magneto_z                  => MAGNETO_Z_DATA_CORR,
--            magneto_x_crr              => magneto_x_data_corr,   
            magneto_y_crr              => MAGNETO_Y_DATA_SOFT_CORR,  
            magneto_z_crr              => MAGNETO_Z_DATA_SOFT_CORR,  
            calibration_done           => GYRO_SOFT_CALIB_DONE
              
  );

--icm_angle_calc_cordic : entity work.icm_angle_calc_cordic 
--  Port map ( 
  
--            clk              =>    CLK,                 
--            rst              =>    RST ,                
--            magneto_x        =>    magneto_z_data_corr,           
--            magneto_y        =>    magneto_y_data_corr,           
--            magneto_z        =>    magneto_x_data_corr,           
--            conv_factor      =>    x"46FFE000", -- 32752           
--            yaw_radians      =>    open,
--            yaw_degree       =>    yaw         
  
  
  
--  );  

icm_angle_calc_tan_bram  : entity work.icm_angle_calc_tan_bram 
  Port map ( 
  
            clk              =>    CLK,                 
            rst              =>    RST ,                
--            magneto_x        =>    magneto_x_data_soft_corr,           
            magneto_y        =>    MAGNETO_Y_DATA_SOFT_CORR,           
            magneto_z        =>    MAGNETO_Z_DATA_SOFT_CORR,                 
            yaw_degree       =>    yaw          
  );   
  
-- SENSOR_VIDEO_DATA_S <= SNSR_OUT12_13 & SNSR_OUT10_11 & SNSR_OUT8_9 & SNSR_OUT6_7 & SNSR_OUT4_5 & SNSR_OUT2_3 & SNSR_OUT0_1;

-- SNSR_CMD0_1 <= SENSOR_CMD_S(0);
-- SNSR_CMD2_3 <= SENSOR_CMD_S(1);

-- SNSR_BIT0_1 <= SENSOR_DATA_S(0);
-- SNSR_BIT2_3 <= SENSOR_DATA_S(1);
-- SNSR_BIT4_5 <= SENSOR_DATA_S(2);
-- SNSR_BIT6_7 <= SENSOR_DATA_S(3);

-- SENSOR_FRAMING_S <= SNSR_FB0_1;


sensor_write_mux     <= sensor_write or sensor_write1 ;    
sensor_writedata_mux <= sensor_writedata1 when sensor_write1='1' else sensor_writedata;
sensor_address_mux   <= sensor_address1   when sensor_write1 ='1' else sensor_address;  

--sensor_controller_inst: sensor_controller_top
--generic map(
--    SENSOR_XSIZE      => SENSOR_XSIZE,
--    SENSOR_YSIZE      => SENSOR_YSIZE
--  )
--port map(
--    clk                   => CLK,
--    rst                   => RST,
--    mclk                  => SENSOR_MCLK,
--    rst_m                 => RST,--RST_MCLK,
--    area_switch_done      => area_switch_done,
--    low_to_high_temp_area_switch => low_to_high_temp_area_switch,
--    high_to_low_temp_area_switch => high_to_low_temp_area_switch,
--    lo_to_hi_area_global_offset_force_val => lo_to_hi_area_global_offset_force_val,
--    hi_to_lo_area_global_offset_force_val => hi_to_lo_area_global_offset_force_val,
--    BAD_BLIND_PIX_LOW_TH  => BAD_BLIND_PIX_LOW_TH,
--    BAD_BLIND_PIX_HIGH_TH => BAD_BLIND_PIX_HIGH_TH,
--    blind_badpix_remove_en=> blind_badpix_remove_en,
--    dark_pix_th           => DARK_PIX_TH,
--    saturated_pix_th      => SATURATED_PIX_TH,
--    ADDR_COARSE_OFFSET    => ADDR_COARSE_OFFSET,
--    sensor_pixclk         => SNSR_PIXCLKIN,
--    sensor_cmd            => SENSOR_CMD_S,
--    sensor_data           => SENSOR_DATA_S,
--    sensor_ssclk          => SNSR_SSC,
--    sensor_framing        => SENSOR_FRAMING_S,
--    sensor_video_data     => SENSOR_VIDEO_DATA_S,
--    av_sensor_waitrequest => sensor_waitrequest,
--    av_sensor_write       => sensor_write_mux,
--    av_sensor_writedata   => sensor_writedata_mux,
--    av_sensor_address     => sensor_address_mux(5 downto 0),
--    av_sensor_read        => sensor_read, 
--    av_sensor_readdata    => sensor_readdata,
--    av_sensor_readdatavalid => sensor_readdatavalid,
--	av_coarse_waitrequest	=> coarse_waitrequest	,	
--	av_coarse_read			=> coarse_read			,
--	av_coarse_address		=> coarse_address		,
--	av_coarse_size			=> coarse_size			,
--	av_coarse_readdatavalid	=> coarse_readdatavalid	,	
--	av_coarse_readdata		=> coarse_readdata		,	

--    raw_video_v             => raw_video_v    ,
--    raw_video_h             => raw_video_h    ,
--    raw_video_dav           => raw_video_dav  ,
--    raw_video_data          => raw_video_data ,
--    raw_video_eoi           => raw_video_eoi  ,
--    raw_video_xsize         => raw_video_xsize,
--    raw_video_ysize         => raw_video_ysize,
    
--    meta1_avg               => meta1_avg,
--    meta2_avg               => meta2_avg,
--    meta3_avg               => meta3_avg,

--    video_o_v             => VIDEO_I_V_SN,
--    video_o_h             => VIDEO_I_H_SN,
--    video_o_dav           => VIDEO_I_DAV_SN,
--    video_o_dav_with_temp => VIDEO_I_DAV_WITH_TEMP_SN,
--    video_o_data          => VIDEO_I_DATA_SN,
--    video_o_eoi           => VIDEO_I_EOI_SN,
--    video_o_xsize         => VIDEO_I_XSIZE_SN,
--    video_o_ysize         => VIDEO_I_YSIZE_SN,
--    video_o_xsize_with_temp => VIDEO_I_XSIZE_WITH_TEMP_SN,
--    video_o_ysize_with_temp => VIDEO_I_YSIZE_WITH_TEMP_SN,    
--    temp_sense_offset     => temp_sense_offset
--  );     

process(CLK, RST)begin
        if RST = '1' then
          frame_counter <= (others=>'0');
          do_nuc1pt_at_power_on <= '0';
        elsif rising_edge(CLK) then    
                do_nuc1pt_at_power_on <= '0'; 
                if(frame_counter > unsigned(FRAME_COUNTER_NUC1PT_DELAY))then  
                    frame_counter <= frame_counter;
                else
                    if(raw_video_v ='1' and video_start = '1')then
                          frame_counter <= frame_counter +1;                    
                    end if; 
                    if(frame_counter = unsigned(FRAME_COUNTER_NUC1PT_DELAY))then
                        if(frame_counter /= 0)then
                            do_nuc1pt_at_power_on <= '1';
                        end if;
                    end if;
                end if;    
        end if;
  end process;   
  


i_VIDEO_IN_GENERIC : entity WORK.VIDEO_IN_GENERIC
   Generic map (
    bit_width        => BIT_WIDTH            ,
--    VIDEO_XSIZE      => image_width_full     ,
--    VIDEO_YSIZE      => VIDEO_YSIZE          ,
    PIX_BITS         => PIX_BITS             ,
    LIN_BITS         => LIN_BITS   
   )    
    Port map (
    CLK              => CLK,--CLK_27MHZ            
    CLK_ila          => CLK_100MHZ,
    RST              => RST,          
    VIDEO_XSIZE      => std_logic_vector(to_unsigned(640,PIX_BITS)),--image_width_full,
    VIDEO_YSIZE      => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)) ,    
--    video_start      => video_start,
    main_clock       => SNSR_FPGA_PIXEL_CLK ,--CLK,--CLK,--SNSR_FPGA_PIXEL_CLK   ,
    detector_clock   => SNSR_FPGA_LINEVALID,--Sensor_Data_Valid   ,
    vsync            => SNSR_FPGA_FRAMEVALID,--Sensor_Framevalid_Out  ,
    hsync            => SNSR_FPGA_LINEVALID,--Sensor_Linevalid_Out   ,
    video_data       => SNSR_FPGA_DATA(13 downto 0), --//dcs/SNSR_FPGA_DATA(15 downto 2),/  --Sensor_Data_Out(13 downto 0),
    VIDEO_O_V        => VIDEO_I_V_SN          ,
    VIDEO_O_H        => VIDEO_I_H_SN          ,
    VIDEO_O_DAV      => VIDEO_I_DAV_SN        ,
    VIDEO_O_DATA     => VIDEO_I_DATA_SN       ,
    VIDEO_O_EOI      => VIDEO_I_EOI_SN
    );



----------------------------------------------------------------------------------------------
i_Sensor_Temp_Extract :Sensor_Temp_Extract
generic map(
Total_Temperature_Byte => 16,
shift_right_bit        => 4,
VIDEO_XSIZE            => VIDEO_XSIZE,
VIDEO_YSIZE            => VIDEO_YSIZE
)
port map (
    clk                     => SNSR_FPGA_PIXEL_CLK, -- //input             
    reset                   => RST, -- //input             
    Sensor_Linevalid        => SNSR_FPGA_LINEVALID  ,-- //input             
    Sensor_Framevalid       => SNSR_FPGA_FRAMEVALID, --//input            
    Sensor_Data_Valid       => SNSR_FPGA_LINEVALID, --//input             
    Sensor_Data             => SNSR_FPGA_DATA,        --// input      [15:0] //dcs/-SNSR_FPGA_DATA(13 downto 0)//
    Sensor_Temperature      => Sensor_Temperature   --//  output reg [31:0] 
    );
----------------------------------------------------------------------------------------------



--  Temperature Extraction 
  -- ----------------------------
--  i_temp_extract : temp_extract
--    generic map(
--     BIT_WIDTH           => BIT_WIDTH                   ,
--     PIX_BITS            => PIX_BITS                    ,
--     LIN_BITS            => LIN_BITS                    ,
----     image_width_full    => image_width_full            ,
----     temp_pixels_left    => temp_pixels_left            ,
----     temp_pixels_right   => temp_pixels_right           ,
----     exclude_left        => exclude_left                ,
----     exclude_right       => exclude_right               ,
--     VIDEO_XSIZE         => VIDEO_XSIZE                 ,
--     VIDEO_YSIZE         => VIDEO_YSIZE
--    )
--    port map(
--     clk                 => CLK,--CLK_27MHZ                   ,
--     rst                 => RST                         ,
--     image_width_full    => image_width_full            ,
--     temp_pixels_left    => temp_pixels_left            ,
--     temp_pixels_right   => temp_pixels_right           ,     
     
--     video_i_v           => VIDEO_I_V_SN                ,
--     video_i_h           => VIDEO_I_H_SN                ,
--     video_i_dav         => VIDEO_I_DAV_SN              ,
--     video_i_eoi         => VIDEO_I_EOI_SN              ,
--     video_i_data        => VIDEO_I_DATA_SN             ,
--     exclude_left        => exclude_left,
--     exclude_right       => exclude_right,
----     IMG_FLIP_H          => IMG_FLIP_H                  ,
--     video_o_v           => VIDEO_O_V_TE                ,
--     video_o_h           => VIDEO_O_H_TE                ,
--     video_o_dav         => VIDEO_O_DAV_TE              ,
--     video_o_eoi         => VIDEO_O_EOI_TE              ,
--     video_o_data        => VIDEO_O_DATA_TE             ,
--     temp_valid          => TEMP_VALID                  ,
--     temp_data           => TEMP_DATA                   , 
--     temp_avg_line       => TEMP_AVG_LINE               ,  
--     temp_avg_frame      => TEMP_AVG_FRAME  
--    );

--i_temp_extraction: entity WORK.temp_extraction 
--    generic map(
--     BIT_WIDTH           => BIT_WIDTH     ,
--     PIX_BITS            => PIX_BITS       ,
--     LIN_BITS            => LIN_BITS       ,
--     image_width_full    => image_width_full  ,  
--     temp_pixels_left    => temp_pixels_left  ,    
--     temp_pixels_right   => temp_pixels_right ,  
----     exclude_left        => integer := 0        ;
----     exclude_right       => integer := 2        ;
--     VIDEO_XSIZE         => VIDEO_XSIZE     ,
--     VIDEO_YSIZE         => VIDEO_YSIZE
--    )
--    port map(
--     clk                => CLK,--CLK_27MHZ      ;
--     rst                => RST                 ,
--     bypass       => '0'                 ,
--     video_i_v          => VIDEO_I_V_SN        ,
--     video_i_h          => VIDEO_I_H_SN        ,
--     video_i_dav        => VIDEO_I_DAV_SN      ,
--     video_i_eoi        => VIDEO_I_EOI_SN      ,
--     video_i_data       => VIDEO_I_DATA_SN     ,
----     video_i_xsize  =>  , 
----     video_i_ysize    =>  , 
----     video_i_xcount   =>  , 
----     video_i_ycount   =>  , 
--     video_o_v          => VIDEO_O_V_TE      ,
--     video_o_h          => VIDEO_O_H_TE      ,
--     video_o_dav        => VIDEO_O_DAV_TE    ,
--     video_o_eoi        => VIDEO_O_EOI_TE    ,
--     video_o_data       => VIDEO_O_DATA_TE   ,
----     video_o_xsize    => open,
----     video_o_ysize    => open,
----     video_o_xcount   => open,
----     video_o_ycount   => open,
--     temp_valid         => TEMP_VALID    ,
--     temp_data          => TEMP_DATA     , 
--     temp_avg_line      => TEMP_AVG_LINE ,  
--     temp_avg_frame     => TEMP_AVG_FRAME             
--    );


VIDEO_I_DATA_SN_1 <= "00"& VIDEO_I_DATA_SN;

i_img_info :img_info
generic map(
VIDEO_XSIZE            => VIDEO_XSIZE,
VIDEO_YSIZE            => VIDEO_YSIZE,
BIT_WIDTH              => BIT_WIDTH
)
port map (
    clk                     => CLK, -- //input             
    reset                   => RST, -- //input             
    Sensor_Linevalid        => VIDEO_I_V_SN   ,  --VIDEO_O_H_TE  ,-- //input             
    Sensor_Framevalid       => VIDEO_I_H_SN   ,  --VIDEO_O_V_TE, --//input    
    Sensor_EOI              => VIDEO_I_EOI_SN ,  --VIDEO_O_EOI_TE,        
    Sensor_Data_Valid       => VIDEO_I_DAV_SN ,  --VIDEO_O_DAV_TE, --//input             
    Sensor_Data             => VIDEO_I_DATA_SN,  --VIDEO_O_DATA_TE,        --// input      [BIT_WIDTH-1:0] 
    Img_Min_Limit           => Img_Min_Limit,
    Img_Max_Limit           => Img_Max_Limit,
    Img_Avg                 => IMG_AVG  --//  output reg [BIT_WIDTH-1:0] 
    );




i_VIDEO_IN_MIRE_GEN : entity WORK.VIDEO_IN_MIRE_GEN
  generic  map(         
    REQ_XSIZE => VIDEO_XSIZE,--: positive range 16 to 1023:=384; -- Required Output Horizontal Size 
    REQ_YSIZE => VIDEO_YSIZE,--: positive range 16 to 1023:=288; -- Required Output   Vertical Size
    REQ_HBLANK => 1500,--290,--357,--: positive := 1250;          -- CLK cycles for Horizontal Blanking-- 290 for 60fps
    REQ_VBLANK => 1500,--2000,--100,--: positive :=   50;          -- Lines for Vertical Blanking       -2000 for 60fps
    REQ_PIXCLK => 2--0 --: integer  range  0 to 16:=16    -- CLK cycles between 2 VIDEO_O_DAV
  )
  port map (
    CLK            => CLK,--CLK_27MHZ,--  : in  std_logic;                     -- Module Clock
    RST            => RST,--  : in  std_logic;                     -- Module Reset (Asynch Active High)
    TICK1S         => TICK1mS,--  : in std_logic;
    VIDEO_O_XSIZE  =>open,--  : out std_logic_vector(9 downto 0);  -- Video X Size
    VIDEO_O_YSIZE  =>open,--  : out std_logic_vector(9 downto 0);  -- Video Y Size
    VIDEO_O_V      => VIDEO_O_V_MIRE,--  : out std_logic;                     -- Video   Vertical Synchro
    VIDEO_O_H      => VIDEO_O_H_MIRE,--  : out std_logic;                     -- Video Horizontal Synchro
    VIDEO_O_EOI    => VIDEO_O_EOI_MIRE,--  : out std_logic;                     -- Video End of Image
    VIDEO_O_DAV    => VIDEO_O_DAV_MIRE,--  : out std_logic;                     -- Video Pixel Valid Flag
    VIDEO_O_DATA   => VIDEO_O_DATA_MIRE,--  : out std_logic_vector(7 downto 0);  -- Video Pixel Data
    VIDEO_O_XCNT   => open,--  : out std_logic_vector(9 downto 0);  -- Video Pixel Counter (1st pix is 0)
    VIDEO_O_YCNT   => open--  : out std_logic_vector(9 downto 0)   -- Video  Line Counter (1st lin is 0)
  );


process(CLK, RST)
    begin
    if RST = '1' then
        VIDEO_IN_MUX_SEL <= '0'; 
        VIDEO_I_NUC_V    <= '0';
        VIDEO_I_NUC_H    <= '0';
        VIDEO_I_NUC_EOI  <= '0';
        VIDEO_I_NUC_DAV  <= '0';
        VIDEO_I_NUC_DATA <= (others=>'0');
        
    elsif rising_edge(CLK) then  
        if VIDEO_O_NUC_EOI = '1' then
           VIDEO_IN_MUX_SEL <= VIDEO_IN_MUX; 
        end if;
        if  VIDEO_IN_MUX_SEL = '0' then
            VIDEO_I_NUC_V    <=  VIDEO_I_V_SN    ;--VIDEO_O_V_TE;--VIDEO_O_CLHE_V;
            VIDEO_I_NUC_H    <=  VIDEO_I_H_SN    ;--VIDEO_O_H_TE;--VIDEO_O_CLHE_H;
            VIDEO_I_NUC_EOI  <=  VIDEO_I_EOI_SN  ;--VIDEO_O_EOI_TE;--VIDEO_O_CLHE_EOI;
            VIDEO_I_NUC_DAV  <=  VIDEO_I_DAV_SN  ;--VIDEO_O_DAV_TE;--VIDEO_O_CLHE_DAV;
            VIDEO_I_NUC_DATA <=  VIDEO_I_DATA_SN(13 downto 0);
--            VIDEO_I_NUC_DATA <=  VIDEO_I_DATA_SN ;--VIDEO_O_DATA_TE;--"000000" & VIDEO_O_CLHE_DATA;
        else 
            VIDEO_I_NUC_V    <= VIDEO_O_V_MIRE;
            VIDEO_I_NUC_H    <= VIDEO_O_H_MIRE;
            VIDEO_I_NUC_EOI  <= VIDEO_O_EOI_MIRE;
            VIDEO_I_NUC_DAV  <= VIDEO_O_DAV_MIRE;
            VIDEO_I_NUC_DATA <= VIDEO_O_DATA_MIRE & "000000" ;    
        end if;
      end if;  
end process;

TEMPERATURE <= Sensor_Temperature(15 downto 0);
--TEMPERATURE <= "00"& TEMP_AVG_FRAME;

--TEMPERATURE <= "00" & meta1_avg;
--TEMPERATURE <= std_logic_vector(unsigned("00" & meta1_avg) + unsigned(temperature_offset)) when sub_add_temp_offset = '0' else
--               std_logic_vector(unsigned("00" & meta1_avg) - unsigned(temperature_offset));
--TEMPERATURE <= "00000" & meta1_avg(13 downto 3);


av_rdsdram_waitrequest_s    <=  not DMA_R2_RDREADY_s when DMA_NUC1PT_MUX = '0' else '1';
DMA_NUC1pt_RDREADY_s        <=  DMA_R2_RDREADY_s     when DMA_NUC1PT_MUX = '1' else '1';

DMA_R2_RDREQ_s              <=  DMA_NUC1pt_RDREQ_s   when DMA_NUC1PT_MUX = '1' else av_rdsdram_read_s;
DMA_R2_RDADDR_s             <=  DMA_NUC1pt_RDADDR_s  when DMA_NUC1PT_MUX = '1' else av_rdsdram_address_s;
DMA_R2_RDSIZE_s             <=  DMA_NUC1pt_RDSIZE_s  when DMA_NUC1PT_MUX = '1' else av_rdsdram_burstcount_s;

av_rdsdram_readdatavalid_s  <=  DMA_R2_RDDAV_s       when DMA_NUC1PT_MUX = '0' else '0';  
DMA_NUC1pt_RDDAV_s          <=  DMA_R2_RDDAV_s       when DMA_NUC1PT_MUX = '1' else '0'; 

av_rdsdram_readdata_s       <=  DMA_R2_RDDATA_s      when DMA_NUC1PT_MUX = '0' else (others =>'0'); 
DMA_NUC1pt_RDDATA_s         <=  DMA_R2_RDDATA_s      when DMA_NUC1PT_MUX = '1' else (others =>'0'); 


av_wrsdram_waitrequest_s    <= not DMA_W2_WRREADY_s  when DMA_NUC1PT_MUX = '0' else '1';
DMA_NUC1pt_WRREADY_s        <= DMA_W2_WRREADY_s      when DMA_NUC1PT_MUX = '1' else '0';
DMA_W2_WRREQ_s              <= DMA_NUC1pt_WRREQ_s    when DMA_NUC1PT_MUX = '1' else av_wrsdram_write_s;  
DMA_W2_WRBURST_s            <= DMA_NUC1pt_WRBURST_s  when DMA_NUC1PT_MUX = '1' else av_wrsdram_writeburst_s;
DMA_W2_WRADDR_s             <= DMA_NUC1pt_WRADDR_s   when DMA_NUC1PT_MUX = '1' else av_wrsdram_address_s;
DMA_W2_WRSIZE_s             <= DMA_NUC1pt_WRSIZE_s   when DMA_NUC1PT_MUX = '1' else av_wrsdram_burstcount_s;  
DMA_W2_WRDATA_s             <= DMA_NUC1pt_WRDATA_s   when DMA_NUC1PT_MUX = '1' else av_wrsdram_writedata_s; 
DMA_W2_WRBE_s               <= DMA_NUC1pt_WRBE_s     when DMA_NUC1PT_MUX = '1' else av_wrsdram_byteenable_s;





Start_NUC1ptCalib_POS_EDGE <= (not Start_NUC1ptCalib_D) and Start_NUC1ptCalib;
Start_GAINCalib_POS_EDGE   <= (not Start_GAINCalib_D) and Start_GAINCalib;

process(CLK, RST)
    begin
    if RST = '1' then
      ENABLE_NUC1ptCalib <= '0';
      VIDEO_NUC1PT_FSM  <= s_NUC1PT_IDLE;
      DMA_NUC1PT_MUX    <= '0';
      NUC1pt_Time_Out_Cnt <= 0;
      NUC1pt_Force_Reset   <= '0';
      MEM_IMG_BUF_SEL      <= "00";
      gain_enable_d        <= '0';
      RETICLE_DIS          <= '0';
      OSD_DIS              <= '0'; 
      Start_GAINCalib_D    <= '0';
      Start_NUC1ptCalib_D  <= '0';
      select_gain_addr_d   <= '0';
      ch_img_rd_qspi_wr_sdram_en <= '0';
      ch_img_sdram_addr <= (others => '0');
      ch_img_qspi_addr  <= (others => '0');
      ch_img_len        <= std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE*2,ch_img_len'length));
      hot_img_sum       <= (others => '0');
      cold_img_sum      <= (others => '0');
      CONTROL_SDRAM_WRITE_START_STOP <= '0';
      frame_cnt_to_start_sdram_write <= (others => '0');      

    elsif rising_edge(CLK) then
        Start_NUC1ptCalib_D <= Start_NUC1ptCalib;
        Start_GAINCalib_D   <= Start_GAINCalib;

--        if(DMA_NUC1PT_MUX='1')then
        if(MUX_BLADE_MODE = "00")then
--            if(DMA_NUC1PT_MUX ='1' or stop_dma_write2='1' )then
            if(DMA_NUC1PT_MUX ='1' or stop_sdram_write_seminuc='1' )then          
                CONTROL_SDRAM_WRITE_START_STOP <= '1';
                frame_cnt_to_start_sdram_write <= (others => '0');
            else 
                if(VIDEO_MUX_OUT_V = '1')then                  
                    if(frame_cnt_to_start_sdram_write >= unsigned(WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE))then
                        CONTROL_SDRAM_WRITE_START_STOP <= '0';
                    else
                        frame_cnt_to_start_sdram_write <= frame_cnt_to_start_sdram_write +1;
                    end if;
                end if;    
            end if;    
        
        else
            if(shutter_control_sdram_write_start_stop = '1')then
                CONTROL_SDRAM_WRITE_START_STOP <= '1';
                frame_cnt_to_start_sdram_write <= (others => '0');
            else 
                if(VIDEO_MUX_OUT_V = '1')then                  
                    if(frame_cnt_to_start_sdram_write >= unsigned(WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE))then
                        CONTROL_SDRAM_WRITE_START_STOP <= '0';
                    else
                        frame_cnt_to_start_sdram_write <= frame_cnt_to_start_sdram_write +1;
                    end if;
                end if;    
            end if;        
        end if;  
        
        
        case VIDEO_NUC1PT_FSM is
           
          when s_NUC1PT_IDLE =>
            NUC1pt_Force_Reset  <= '0';
            NUC1pt_Time_Out_Cnt <=  0 ;
            ENABLE_NUC1ptCalib  <= '0';
            DMA_NUC1PT_MUX      <= '0';

            
            if Start_GAINCalib_POS_EDGE = '1' then
                gain_enable_d      <= '0';
                select_gain_addr_d <= '0';
                RETICLE_DIS        <= '1';
                OSD_DIS            <= '1';                --VIDEO_NUC1PT_FSM   <= s_GAIN_CALIB_START;
                VIDEO_NUC1PT_FSM   <= s_READ_COLD_IMG;
            elsif Start_NUC1ptCalib_POS_EDGE = '1' then
                VIDEO_NUC1PT_FSM   <= s_NUC1PT_CALIB_START;
                gain_enable_d      <= gain_enable;
                select_gain_addr_d <= select_gain_addr;
                RETICLE_DIS        <= '1';
                OSD_DIS            <= '1';          
            else 
                VIDEO_NUC1PT_FSM   <= s_NUC1PT_IDLE; 
                gain_enable_d      <= '0';  
                RETICLE_DIS        <= '0';
                OSD_DIS            <= '0'; 
                select_gain_addr_d <= '0';
            end if;
          when s_NUC1PT_CALIB_START =>
            if DMA_WRITE_FREE = '1' and RETICLE_DIS_DONE = '1' then
                ENABLE_NUC1ptCalib <= '1';
                VIDEO_NUC1PT_FSM   <= s_NUC1PT_Wait;
                DMA_NUC1PT_MUX     <= '1';
                if(MEM_IMG_BUF = "00")then
                    MEM_IMG_BUF_SEL    <= "10";
                elsif(MEM_IMG_BUF = "01")then 
                    MEM_IMG_BUF_SEL    <= "00";
                elsif(MEM_IMG_BUF = "10")then    
                    MEM_IMG_BUF_SEL    <= "01";
                else
                    MEM_IMG_BUF_SEL    <= "00"; 
                end if;
                STORE_TEMP_AVG_FRAME <= "00" & TEMP_AVG_FRAME;
            else 
                ENABLE_NUC1ptCalib <= '0';
                VIDEO_NUC1PT_FSM   <= s_NUC1PT_CALIB_START;
                DMA_NUC1PT_MUX     <= '0';             
            end if;            
            
          when s_NUC1PT_Wait =>   
            ENABLE_NUC1ptCalib <= '0';                      
            if(NUC1pt_done_offset = '1')then
                VIDEO_NUC1PT_FSM   <= s_NUC1PT_IDLE;
                DMA_NUC1PT_MUX     <= '0';  
                NUC1pt_Time_Out_Cnt <= 0;
                NUC1pt_Force_Reset  <= '0';
            else  
                VIDEO_NUC1PT_FSM   <= s_NUC1PT_Wait;
                DMA_NUC1PT_MUX     <= '1';     
              
            end if; 
            
            when s_READ_COLD_IMG =>
                ch_img_rd_qspi_wr_sdram_en <= '1';
                ch_img_sdram_addr <= ADDR_IMG_COLD;
                ch_img_qspi_addr  <= QSPI_ADDR_IMG_COLD;
                ch_img_len <= std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE*2,ch_img_len'length));
                if(qspi_init_cmd_done = '0')then  
                  VIDEO_NUC1PT_FSM   <= s_WAIT_READ_COLD_IMG;
                end if;  
           
            when s_WAIT_READ_COLD_IMG => 
                ch_img_rd_qspi_wr_sdram_en <= '0'; 
                if(qspi_init_cmd_done = '1')then 
                    VIDEO_NUC1PT_FSM   <= s_READ_HOT_IMG;
                    cold_img_sum <= ch_img_sum;
                end if;
                
            when s_READ_HOT_IMG  => 
                ch_img_rd_qspi_wr_sdram_en <= '1';
                ch_img_sdram_addr <= ADDR_IMG_HOT;
                ch_img_qspi_addr  <= QSPI_ADDR_IMG_HOT;
                ch_img_len <= std_logic_vector(to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE*2,ch_img_len'length));
                if(qspi_init_cmd_done = '0')then
                    VIDEO_NUC1PT_FSM   <= s_WAIT_READ_HOT_IMG; 
                end if;     
            
            when s_WAIT_READ_HOT_IMG =>
                ch_img_rd_qspi_wr_sdram_en <= '0';
                if(qspi_init_cmd_done = '1')then
                    VIDEO_NUC1PT_FSM <= s_GAIN_CALIB_START;
                    hot_img_sum <= ch_img_sum;
                end if;
                
            when s_GAIN_CALIB_START =>
                 if DMA_WRITE_FREE = '1' and RETICLE_DIS_DONE = '1' then
                    start_gain_calc <= '1';
                    VIDEO_NUC1PT_FSM   <= s_GAIN_CALIB_Wait;
                    DMA_NUC1PT_MUX     <= '1';
                    if(MEM_IMG_BUF = "00")then
                        MEM_IMG_BUF_SEL    <= "10";
                    elsif(MEM_IMG_BUF = "01")then 
                        MEM_IMG_BUF_SEL    <= "00";
                    elsif(MEM_IMG_BUF = "10")then    
                        MEM_IMG_BUF_SEL    <= "01";
                    else
                        MEM_IMG_BUF_SEL    <= "00"; 
                    end if;
                else 
                    start_gain_calc <= '0';
                    VIDEO_NUC1PT_FSM   <= s_GAIN_CALIB_START;
                    DMA_NUC1PT_MUX     <= '0';             
                end if;            
                
            when s_GAIN_CALIB_Wait =>   
                  start_gain_calc <= '0';                      
                  if(done_gain_calc = '1')then
                      VIDEO_NUC1PT_FSM   <= s_NUC1PT_IDLE;
                      DMA_NUC1PT_MUX     <= '0';  
                      NUC1pt_Time_Out_Cnt <= 0;
                      NUC1pt_Force_Reset  <= '0';
                  else  
                      VIDEO_NUC1PT_FSM   <= s_GAIN_CALIB_Wait;
                      DMA_NUC1PT_MUX     <= '1';   
                  end if;

        end case;
    end if;
end process;

NUC1pt_Reset <= NUC1pt_Force_Reset or RST ;

 i_NUC1pt :entity work.NUC1pt
GENERIC MAP(
  bit_width       => BIT_WIDTH, --: integer   := 14;
  DataWidth       => 14, --: integer   := 14;
  FIFO_DEPTH      => 10, -- : integer   := 10;
  FIFO_WIDTH      => 14, -- : integer   := 14;
  VIDEO_XSIZE     => VIDEO_XSIZE , -- : integer   := 640;
  VIDEO_YSIZE     => VIDEO_YSIZE, -- : integer   := 512;
  PIX_BITS        => PIX_BITS, -- : integer   := 10;
  LIN_BITS        => LIN_BITS, -- : integer   := 10;
  DMA_ADDR_BITS   => DMA_ADDR_BITS, -- : positive  := 32;
  DMA_SIZE_BITS   => DMA_SIZE_BITS, -- : positive  := 5;
  DMA_DATA_BITS   => DMA_DATA_BITS -- : positive  := 32;
  --capture_frames  => 5 -- : integer   := 1   -- 2**capture_frames is the number of total images captured
  )
PORT MAP(
  -- Clock and Asynchronous Reset
  CLK                => CLK, -- : in STD_LOGIC;
  RST                => RST,--NUC1pt_Reset,--RST, -- : in STD_LOGIC;
  ENABLE_NUC1pCalib  => ENABLE_NUC1ptCalib, -- : in  std_logic; 
  gain_enable        => gain_enable_d, 
  start_gain_calc    => start_gain_calc,
  select_gain_addr   => select_gain_addr_d,
  done_gain_calc     => done_gain_calc,
  sel_temp_range     => sel_temp_range_out,
  GAIN_TABLE_SEL     => GAIN_TABLE_SEL,
  capture_frames     => NUC1pt_Capture_Frames ,
  cold_img_sum       => cold_img_sum,
  hot_img_sum        => hot_img_sum, 
  bpc_th             => bpc_th,
  --enable_filter       : in std_logic;
  
  -- Input and Output Ports
  VIDEO_I_V     => VIDEO_I_NUC_V, --: in STD_LOGIC;
  VIDEO_I_H     => VIDEO_I_NUC_H, --: in STD_LOGIC;
  VIDEO_I_EOI   => VIDEO_I_NUC_EOI, --: in STD_LOGIC;
  VIDEO_I_DAV   => VIDEO_I_NUC_DAV, --: in STD_LOGIC;
  VIDEO_I_DATA  => VIDEO_I_NUC_DATA, --: in STD_LOGIC_VECTOR (bit_width-1 downto 0);

  DMA0_WRREADY => DMA_NUC1pt_WRREADY_s, --: in   std_logic;              --- write port
  DMA0_WRREQ   => DMA_NUC1pt_WRREQ_s, --: out  std_logic;
  DMA0_WRADDR  => DMA_NUC1pt_WRADDR_s, --: out  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
  DMA0_WRSIZE  => DMA_NUC1pt_WRSIZE_s, --: out  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
  DMA0_WRDATA  => DMA_NUC1pt_WRDATA_s, --: out  std_logic_vector(DMA_DATA_BITS  -1 downto 0);
  DMA0_WRBE    => DMA_NUC1pt_WRBE_s, --: out  std_logic_vector(DMA_DATA_BITS/8-1 downto 0);
  DMA0_WRBURST => DMA_NUC1pt_WRBURST_s, --: OUT STD_LOGIC;

  done_offset => NUC1pt_done_offset, --: OUT std_logic;

  DMA1_RDREQ  => DMA_NUC1pt_RDREQ_s, -- : out   std_logic;             -- read port
  DMA1_RDADDR => DMA_NUC1pt_RDADDR_s,  -- : out  std_logic_vector(DMA_ADDR_BITS  -1 downto 0);
  DMA1_RDSIZE => DMA_NUC1pt_RDSIZE_s, -- : out  std_logic_vector(DMA_SIZE_BITS  -1 downto 0);
  DMA1_RDREADY =>DMA_NUC1pt_RDREADY_s,  --: in  std_logic;
  DMA1_RDDAV   =>DMA_NUC1pt_RDDAV_s,   --: in   std_logic;
  DMA1_RDDATA  =>DMA_NUC1pt_RDDATA_s , --: in   std_logic_vector(DMA_DATA_BITS  -1 downto 0)

  offset_img_avg => offset_img_avg
);

ENABLE_NUC_D <= (ENABLE_NUC and (not DMA_NUC1PT_MUX));

calib_gen1: if(CALIB_EN=FALSE) generate

Start_NUC1ptCalib2_POS_EDGE <= (not Start_NUC1ptCalib2_D) and Start_NUC1ptCalib2;

NUC1ptM2_CONTROL: process(CLK, RST) begin
  if(RST='1') then
    nuc1ptm2_fsm <= n_idle;
    RETICLE_DIS_2         <= '0';
    OSD_DIS_2             <= '0';
    ENABLE_UNITY_GAIN2    <= '0';
    snapshot_nuc_channel  <= (others=>'0');
    snapshot_nuc_mode  <= (others=>'0');
    snapshot_nuc_trigger <= '0';
    snapshot_nuc_total_frames <= (others=>'0');
    snapshot_ctrl_mux <= '0';
    Start_NUC1ptCalib2_D <= '0';
    stop_dma_write2 <= '0';
    APPLY_NUC1ptCalib2_1 <= '1';
    MEM_IMG_BUF_SEL2    <= "00";
--    sec_counter <= to_unsigned(0, sec_counter'length);
    milli_sec_counter <= to_unsigned(0, milli_sec_counter'length);
    ENABLE_SNUC_FORCE <= '0';
    stop_sdram_write_seminuc <= '0';
  elsif (rising_edge(CLK)) then
    Start_NUC1ptCalib2_D <= Start_NUC1ptCalib2;
    case(nuc1ptm2_fsm) is
      when n_idle => 
--        if Start_NUC1ptCalib2_POS_EDGE = '1' or (OSD_START_NUC1PT2CALIB='1') then
        if (Start_NUC1ptCalib2_POS_EDGE = '1') then
          RETICLE_DIS_2        <= '1';
          OSD_DIS_2            <= '1';
----          nuc1ptm2_fsm         <= n_wait_secs;
--          nuc1ptm2_fsm         <= n_wait_seminuc_disable;
----          nuc1ptm2_fsm         <= n_en_unity_gain;
----          APPLY_NUC1ptCalib2_1 <= '0';
          nuc1ptm2_fsm         <= n_disable_sdram_write_snsr_video;
        end if;
        stop_sdram_write_seminuc <= '0';
--      when n_wait_secs =>
--          if(offset_poly_calc_busy = '0' and offset_poly_calc_done = '1')then
--            nuc1ptm2_fsm         <= n_en_unity_gain;
--          end if;
----        if(TICK1S='1' and sec_counter=to_unsigned(2, sec_counter'length)) then
----          sec_counter <= to_unsigned(0, sec_counter'length);
----          nuc1ptm2_fsm         <= n_en_unity_gain;
----        elsif(TICK1S='1') then
----          sec_counter <= sec_counter + 1;
----        end if;

      when n_disable_sdram_write_snsr_video =>
        if(DMA_WRITE_FREE = '1')then
            nuc1ptm2_fsm         <= n_wait_seminuc_disable;
            stop_sdram_write_seminuc <= '1';
        else    
            nuc1ptm2_fsm         <= n_disable_sdram_write_snsr_video;
            stop_sdram_write_seminuc <= '0';
        end if;
        
      when n_wait_seminuc_disable =>
--          if(offset_poly_calc_busy = '1' and offset_poly_calc_done = '0')then
--            nuc1ptm2_fsm         <= n_wait_secs;
--          end if;
          if((offset_poly_calc_busy = '1' and offset_poly_calc_done = '0' and VIDEO_I_NUC_H='1') or (offset_poly_calc_busy = '0' and offset_poly_calc_done = '1' and VIDEO_I_NUC_EOI='1'))then
                APPLY_NUC1ptCalib2_1 <= '0';    
                nuc1ptm2_fsm         <= n_wait_secs;             
          end if;

      when n_wait_secs =>    
        if(milli_sec_counter=to_unsigned(2, milli_sec_counter'length)) then
            if(offset_poly_calc_busy = '0' and offset_poly_calc_done = '1' and VIDEO_I_NUC_EOI='1' )then
                nuc1ptm2_fsm         <= n_en_unity_gain;    
                milli_sec_counter  <= to_unsigned(0, milli_sec_counter'length);  
            end if;         
        elsif(TICK1MS='1') then
          milli_sec_counter <= milli_sec_counter + 1;
        end if;
                  
      when n_en_unity_gain =>
        ENABLE_UNITY_GAIN2 <= '1';
        ENABLE_SNUC_FORCE    <= '1';
        
        if(VIDEO_I_NUC_V='1') then
          snapshot_ctrl_mux <= '1';
          nuc1ptm2_fsm         <= n_en_unity_gain2;
        end if;

      when n_en_unity_gain2 =>
        if(VIDEO_I_NUC_V='1') then
          nuc1ptm2_fsm         <= n_take_snapshot1;
          
          snapshot_nuc_total_frames <= std_logic_vector(to_unsigned(1, snapshot_nuc_total_frames'length));
          snapshot_nuc_mode    <= std_logic_vector(to_unsigned(1, snapshot_nuc_mode'length));
          snapshot_nuc_channel <= std_logic_vector(to_unsigned(1, snapshot_nuc_channel'length));
        end if;

      when n_take_snapshot1 =>
        if(DMA_WRITE_FREE='1') then
          stop_dma_write2 <= '1';
          snapshot_nuc_trigger <= '1';
          nuc1ptm2_fsm         <= n_take_snapshot2;

          if(MEM_IMG_BUF = "00")then
              MEM_IMG_BUF_SEL2    <= "10";
          elsif(MEM_IMG_BUF = "01")then 
              MEM_IMG_BUF_SEL2    <= "00";
          elsif(MEM_IMG_BUF = "10")then    
              MEM_IMG_BUF_SEL2    <= "01";
          else
              MEM_IMG_BUF_SEL2    <= "00"; 
          end if;
        end if;


      when n_take_snapshot2 =>
        snapshot_nuc_trigger <= '0';
        if(snapshot_nuc_done='1') then
          stop_dma_write2 <= '0';
          snapshot_ctrl_mux <= '0';
          ENABLE_UNITY_GAIN2 <= '0';
          APPLY_NUC1ptCalib2_1 <= '1';
          RETICLE_DIS_2        <= '0';
          OSD_DIS_2            <= '0';
          nuc1ptm2_fsm <= n_idle;
          ENABLE_SNUC_FORCE    <= '0';
          stop_sdram_write_seminuc <= '0';
        end if;

      when others =>
          nuc1ptm2_fsm <= n_idle;
    end case;
  end if;
end process;--NUC1ptM2_CONTROL

stop_dma_write_c <= stop_dma_write or stop_dma_write2;

snapshot_trigger_c <= snapshot_nuc_trigger when snapshot_ctrl_mux='1' else snapshot_trigger_latch;
snapshot_channel_c <= snapshot_nuc_channel when snapshot_ctrl_mux='1' else snapshot_channel;
snapshot_mode_c <= snapshot_nuc_mode when snapshot_ctrl_mux ='1' else snapshot_mode;
snapshot_total_frames_c <= snapshot_nuc_total_frames when snapshot_ctrl_mux='1' else snapshot_total_frames;
snapshot_done <= snapshot_done_c;
snapshot_nuc_done <=  snapshot_done_c;
    
ENABLE_UNITY_GAIN_C <= ENABLE_UNITY_GAIN or ENABLE_UNITY_GAIN2;

APPLY_NUC1ptCalib2_c <= APPLY_NUC1ptCalib2 and APPLY_NUC1ptCalib2_1;

i_nuc_ctrl: nuc_controller
  generic map(
    VIDEO_XSIZE => VIDEO_XSIZE,
    VIDEO_YSIZE => VIDEO_YSIZE,
    SIZE_BITS => DMA_SIZE_BITS
  )
  port map(
    clk => CLK,
    rst => RST,

    en_nuc => ENABLE_NUC_D,
    en_nuc_1pt => APPLY_NUC1ptCalib,
    en_unity_gain => ENABLE_UNITY_GAIN_C,
    en_nuc_1pt_mode2 => APPLY_NUC1ptCalib2_c,
    force_temp_range_en => force_temp_range_en,
    force_temp_range    => force_temp_range,
    tick1s                    => TICK1S,
    temp_range_update_timeout => temp_range_update_timeout,
    auto_shutter_timeout      => AUTO_SHUTTER_TIMEOUT,
    sensor_power_on_init_done => sensor_power_on_init_done, 
    temperature_threshold     => temperature_threshold, 
    --// Master AVALON interface for fetching and storing tables
    av_ready    =>   DMA_RW6_READY_s1    ,
    av_read     =>   DMA_RW6_RDREQ_s1    ,
    av_write    =>   DMA_RW6_WRREQ_s1    ,
    av_wrburst  =>   DMA_RW6_WRBURST_s1  ,
    av_size     =>   DMA_RW6_SIZE_s1     ,
    av_address  =>   DMA_RW6_ADDR_s1     ,
    av_writedata=>   DMA_RW6_WRDATA_s1   ,
    av_wrbe     =>   DMA_RW6_WRBE_s1     ,
    av_rddatavalid=> DMA_RW6_RDDAV_s1    ,
    av_readdata =>   DMA_RW6_RDDATA_s1   ,


    --// Master AVALON interface for reading gain tables
    dma1_rdready => DMA_R1_RDREADY_s     ,
    dma1_rdreq   => DMA_R1_RDREQ_s       ,
    dma1_rdsize  => DMA_R1_RDSIZE_s      ,
    dma1_rdaddr  => DMA_R1_RDADDR_s      ,
    dma1_rddav   => DMA_R1_RDDAV_s       ,
    dma1_rddata  => DMA_R1_RDDATA_s      ,
    --// Master AVALON interface for reading offset tables
    dma2_rdready =>DMA_R4_RDREADY_s     ,
    dma2_rdreq   =>DMA_R4_RDREQ_s       ,
    dma2_rdsize  =>DMA_R4_RDSIZE_s      ,
    dma2_rdaddr  =>DMA_R4_RDADDR_s      ,
    dma2_rddav   =>DMA_R4_RDDAV_s       ,
    dma2_rddata  =>DMA_R4_RDDATA_s      ,

    video_i_v    => VIDEO_I_NUC_V     ,
    video_i_h    => VIDEO_I_NUC_H     ,
    video_i_eoi  => VIDEO_I_NUC_EOI   ,
    video_i_dav  => VIDEO_I_NUC_DAV   ,
    video_i_data => VIDEO_I_NUC_DATA  ,

    video_o_v    => VIDEO_O_NUC_V     ,
    video_o_h    => VIDEO_O_NUC_H     ,
    video_o_eoi  => VIDEO_O_NUC_EOI   ,
    video_o_dav  => VIDEO_O_NUC_DAV   ,
    video_o_data => VIDEO_O_NUC_DATA  ,
    video_o_bad  => VIDEO_O_NUC_BAD   ,

    update_gallery_img_valid_reg_en => OSD_GALLERY_IMG_VALID_EN,
    update_gallery_img_valid_reg    => OSD_GALLERY_IMG_VALID,
    temperature_write_data          => temperature_write_data,
    temperature_write_data_valid    => temperature_write_data_valid,
    temperature_rd_data             => temperature_rd_data,
    temperature_rd_data_valid       => temperature_rd_data_valid,
    temperature_rd_rq               => temperature_rd_rq,
    temperature_wr_addr             => temperature_wr_addr,
    temperature_wr_rq               => temperature_wr_rq ,
    STORE_TEMP_AVG_FRAME            => STORE_TEMP_AVG_FRAME,
    
    ADDR_COARSE_OFFSET  => ADDR_COARSE_OFFSET,
    update_sensor_param => update_sensor_param,
    new_sensor_param_start_addr => new_sensor_param_start_addr,
    CUR_TEMP_AREA       => CUR_TEMP_AREA,
    temp_sense_offset   => temp_sense_offset,
--    take_snapshot_reg   => burst_snapshot,
    area_switch_done    => area_switch_done,
    low_to_high_temp_area_switch => low_to_high_temp_area_switch,
    high_to_low_temp_area_switch => high_to_low_temp_area_switch,
    MUX_NUC_MODE   => MUX_NUC_MODE,
    MUX_BLADE_MODE => MUX_BLADE_MODE,
    toggle_gpio  => toggle_gpio,
    calc_done    => offset_poly_calc_done,
    calc_busy    => offset_poly_calc_busy,
    temp_data    => TEMPERATURE

  );

end generate;

calib_gen2: if(CALIB_EN=True) generate
snap_img_avg_inst: snap_img_avg
 port map (
  clk => CLK,
  rst => RST,  


  av_ready    =>  DMA_RW6_READY_s1,    
  av_read     =>  DMA_RW6_RDREQ_s1,  
  av_write    =>  DMA_RW6_WRREQ_s1,  
  av_wrburst  =>  DMA_RW6_WRBURST_s1, 
  av_size     =>  DMA_RW6_SIZE_s1,   
  av_address  =>  DMA_RW6_ADDR_s1,   
  av_writedata=>  DMA_RW6_WRDATA_s1, 
  av_wrbe     =>  DMA_RW6_WRBE_s1,   
  av_rddatavalid=>  DMA_RW6_RDDAV_s1 ,
  av_readdata =>  DMA_RW6_RDDATA_s1,  

  avl_waitrequest => open,
  avl_write => snap_img_avg_write,
  avl_writedata => snap_img_avg_writedata,
  avl_address => snap_img_avg_address,
  avl_read => '0',
  avl_readdatavalid => open,
  avl_readdata => open
  
);

i_nuc_ctrl: nuc_controller
  generic map(
    VIDEO_XSIZE => VIDEO_XSIZE,
    VIDEO_YSIZE => VIDEO_YSIZE,
    SIZE_BITS => DMA_SIZE_BITS
  )
  port map(
    clk => CLK,
    rst => RST,

    en_nuc => '0',
    en_nuc_1pt => '0',
    en_unity_gain => '0',
    en_nuc_1pt_mode2 => '0',
    force_temp_range_en => force_temp_range_en,
    force_temp_range    => force_temp_range,
    tick1s                    => TICK1S,
    temp_range_update_timeout => temp_range_update_timeout, 
    auto_shutter_timeout      => AUTO_SHUTTER_TIMEOUT,
    sensor_power_on_init_done => sensor_power_on_init_done, 
    temperature_threshold     => temperature_threshold,  
    --// Master AVALON interface for fetching and storing tables
    av_ready    =>   '1'    ,
    av_read     =>   open    ,
    av_write    =>   open    ,
    av_wrburst  =>   open  ,
    av_size     =>   open     ,
    av_address  =>   open     ,
    av_writedata=>   open   ,
    av_wrbe     =>   open     ,
    av_rddatavalid=> '0'    ,
    av_readdata =>   (others=>'0')   ,


    --// Master AVALON interface for reading gain tables
    dma1_rdready => DMA_R1_RDREADY_s     ,
    dma1_rdreq   => DMA_R1_RDREQ_s       ,
    dma1_rdsize  => DMA_R1_RDSIZE_s      ,
    dma1_rdaddr  => DMA_R1_RDADDR_s      ,
    dma1_rddav   => DMA_R1_RDDAV_s       ,
    dma1_rddata  => DMA_R1_RDDATA_s      ,
    --// Master AVALON interface for reading offset tables
    dma2_rdready =>DMA_R4_RDREADY_s     ,
    dma2_rdreq   =>DMA_R4_RDREQ_s       ,
    dma2_rdsize  =>DMA_R4_RDSIZE_s      ,
    dma2_rdaddr  =>DMA_R4_RDADDR_s      ,
    dma2_rddav   =>DMA_R4_RDDAV_s       ,
    dma2_rddata  =>DMA_R4_RDDATA_s      ,

    video_i_v    => VIDEO_I_NUC_V     ,
    video_i_h    => VIDEO_I_NUC_H     ,
    video_i_eoi  => VIDEO_I_NUC_EOI   ,
    video_i_dav  => VIDEO_I_NUC_DAV   ,
    video_i_data => VIDEO_I_NUC_DATA  ,

    video_o_v    => VIDEO_O_NUC_V     ,
    video_o_h    => VIDEO_O_NUC_H     ,
    video_o_eoi  => VIDEO_O_NUC_EOI   ,
    video_o_dav  => VIDEO_O_NUC_DAV   ,
    video_o_data => VIDEO_O_NUC_DATA  ,
    video_o_bad  => VIDEO_O_NUC_BAD   ,

    update_gallery_img_valid_reg_en => OSD_GALLERY_IMG_VALID_EN,
    update_gallery_img_valid_reg    => OSD_GALLERY_IMG_VALID,
    temperature_write_data          => temperature_write_data,
    temperature_write_data_valid    => temperature_write_data_valid,
    temperature_rd_data             => temperature_rd_data,
    temperature_rd_data_valid       => temperature_rd_data_valid,
    temperature_rd_rq               => temperature_rd_rq,
    temperature_wr_addr             => temperature_wr_addr,
    temperature_wr_rq               => temperature_wr_rq ,
    STORE_TEMP_AVG_FRAME            => STORE_TEMP_AVG_FRAME,
    
    ADDR_COARSE_OFFSET  => ADDR_COARSE_OFFSET,
    update_sensor_param => update_sensor_param,
    new_sensor_param_start_addr => new_sensor_param_start_addr,
    CUR_TEMP_AREA       => CUR_TEMP_AREA,
    temp_sense_offset   => temp_sense_offset,
--    take_snapshot_reg => burst_snapshot,
    area_switch_done  => area_switch_done,
    low_to_high_temp_area_switch => low_to_high_temp_area_switch,
    high_to_low_temp_area_switch => high_to_low_temp_area_switch,
    MUX_NUC_MODE   => MUX_NUC_MODE,
    MUX_BLADE_MODE => MUX_BLADE_MODE,    
    toggle_gpio  => toggle_gpio,   
    calc_done    => offset_poly_calc_done,
    calc_busy    => offset_poly_calc_busy,
    temp_data    => TEMPERATURE

  );

process(CLK, RST) begin
  if(RST='1') then
    stop_dma_write2 <= '0';  
    sec_counter <= (others=>'0');
  elsif (rising_edge(CLK)) then
    if(snap_img_avg_write='1' and snap_img_avg_address=std_logic_vector(to_unsigned(0,snap_img_avg_address'length))  and snap_img_avg_writedata(0)='1') then
      stop_dma_write2 <= '1';  
    end if;

    if(stop_dma_write2='1' and sec_counter=to_unsigned(2, sec_counter'length)) then
      stop_dma_write2 <= '0';  
      sec_counter <= (others=>'0');
    elsif (stop_dma_write_c='1' and TICK1S='1') then
      sec_counter <= sec_counter + 1;
    end if;

  end if;

end process;

stop_dma_write_c <= stop_dma_write or stop_dma_write2;  

snapshot_trigger_c <= snapshot_trigger_latch;
snapshot_channel_c <= snapshot_channel;
snapshot_mode_c <= snapshot_mode;
snapshot_total_frames_c <= snapshot_total_frames;
snapshot_done <= snapshot_done_c;

--end generate;

-- update_coarse_offset_inst: update_coarse_offset  
-- port map (
--  clk => CLK,
--  rst => RST,  
--  target_value_threshold => TARGET_VALUE_THRESHOLD,

--  av_ready    =>  DMA_RW6_READY_s2,    
--  av_read     =>  DMA_RW6_RDREQ_s2,  
--  av_write    =>  DMA_RW6_WRREQ_s2,  
--  av_wrburst  =>  DMA_RW6_WRBURST_s2, 
--  av_size     =>  DMA_RW6_SIZE_s2,   
--  av_address  =>  DMA_RW6_ADDR_s2,   
--  av_writedata=>  DMA_RW6_WRDATA_s2, 
--  av_wrbe     =>  DMA_RW6_WRBE_s2,   
--  av_rddatavalid=>  DMA_RW6_RDDAV_s2 ,
--  av_readdata =>  DMA_RW6_RDDATA_s2,  

--  avl_waitrequest => open,
--  avl_write => update_coarse_offset_write,
--  avl_writedata => update_coarse_offset_writedata,
--  avl_address => update_coarse_offset_address,
--  avl_read => '0',
--  avl_readdatavalid => open,
--  avl_readdata => open
  
--);

end generate;
--DMA_RW6_READY_s    <= DMA_RW6_READY_s2    when select_co_bus='1' else DMA_RW6_READY_s1   ;
DMA_RW6_READY_s2   <= DMA_RW6_READY_s   when select_co_bus='1' else '0';
DMA_RW6_READY_s1   <= DMA_RW6_READY_s   when select_co_bus='0' else '0';

DMA_RW6_RDREQ_s    <= DMA_RW6_RDREQ_s2    when select_co_bus='1' else DMA_RW6_RDREQ_s1   ;
DMA_RW6_WRREQ_s    <= DMA_RW6_WRREQ_s2    when select_co_bus='1' else DMA_RW6_WRREQ_s1   ;
DMA_RW6_WRBURST_s  <= DMA_RW6_WRBURST_s2  when select_co_bus='1' else DMA_RW6_WRBURST_s1 ;
DMA_RW6_WRBE_s     <= DMA_RW6_WRBE_s2     when select_co_bus='1' else DMA_RW6_WRBE_s1    ;
DMA_RW6_WRDATA_s   <= DMA_RW6_WRDATA_s2   when select_co_bus='1' else DMA_RW6_WRDATA_s1  ;
DMA_RW6_ADDR_s     <= DMA_RW6_ADDR_s2     when select_co_bus='1' else DMA_RW6_ADDR_s1    ;
DMA_RW6_SIZE_s     <= DMA_RW6_SIZE_s2     when select_co_bus='1' else DMA_RW6_SIZE_s1    ;

--DMA_RW6_RDDAV_s    <= DMA_RW6_RDDAV_s2    when select_co_bus='1' else DMA_RW6_RDDAV_s1   ;
DMA_RW6_RDDAV_s2    <= DMA_RW6_RDDAV_s    when select_co_bus='1' else '0';
DMA_RW6_RDDAV_s1    <= DMA_RW6_RDDAV_s    when select_co_bus='0' else '0';
--DMA_RW6_RDDATA_s   <= DMA_RW6_RDDATA_s2   when select_co_bus='1' else DMA_RW6_RDDATA_s1  ;
DMA_RW6_RDDATA_s2   <= DMA_RW6_RDDATA_s   when select_co_bus='1' else (others=>'0');
DMA_RW6_RDDATA_s1   <= DMA_RW6_RDDATA_s   when select_co_bus='0' else (others=>'0');

--MUX_ENABLE_SNUC <= '1' when MUX_AGC_MODE_SEL="10" else '0';
MUX_ENABLE_SNUC_1 <= MUX_ENABLE_SNUC and (not ENABLE_SNUC_FORCE);

row_filter_inst: entity work.row_filter_new
  generic map(
        WINDOW  => 7,
        HALFWINDOW => 3,
        BITWIDTH => 14,
        VIDEO_XSIZE => VIDEO_XSIZE,
        VIDEO_YSIZE => VIDEO_YSIZE,
        PIX_BITS =>10,
        LIN_BITS =>9,
        NUM_DIV=>10
        ) 
    port map(
        clk               => CLK,
        rst               => RST,
        clk_100           => CLK_100MHZ,
        enable            => MUX_ENABLE_SNUC_1,
        threshold_mult    => THRESHOLD_SOBL,
--        alpha             => ALPHA,
        video_i_v         => VIDEO_O_NUC_V,
        video_i_h         => VIDEO_O_NUC_H,
        video_i_dav       => VIDEO_O_NUC_DAV,
        video_i_data      => VIDEO_O_NUC_DATA,
        video_i_eoi       => VIDEO_O_NUC_EOI,
        video_i_bad       => VIDEO_O_NUC_BAD,
        video_o_v         => VIDEO_O_ROW_V,
        video_o_h         => VIDEO_O_ROW_H,
        video_o_dav       => VIDEO_O_ROW_DAV,
        video_o_data      => VIDEO_O_ROW_DATA,
        video_o_bad       => VIDEO_O_ROW_BAD,
--        video_o_diff      => open,
        video_o_eoi       => VIDEO_O_ROW_EOI
        --mean_out          => open
    );



   i_BPR1 :entity work.BAD_PIX_REMOV_PIPELINED_1
  generic map (
    bit_width   => BIT_WIDTH-1,
    PIX_BITS    => 10,
    LIN_BITS    => 10,
    H_CORR_ON   => true,       -- H correction enabled
    H_CORR_MAX  => 10,         -- Full line H correction   
    CC_GAP      => 0,          -- Minimum value is 1 for DPHE to work properly
    VIDEO_XSIZE => VIDEO_XSIZE,
    VIDEO_YSIZE => VIDEO_YSIZE

  )
  port map (
    CLK           => CLK,--CLK_27MHZ         ,
    RST           => RST               ,

    ENABLE        => ENABLE_BADPIXREM ,
    VIDEO_I_BAD   => VIDEO_O_ROW_BAD ,--VIDEO_O_NUC_BAD ,--VIDEO_O_ROW_BAD ,--VIDEO_O_ROW_BAD ,--VIDEO_O_NUC_BAD  ,                                             
    VIDEO_I_V     => VIDEO_O_ROW_V   ,--VIDEO_O_NUC_V   ,--VIDEO_O_ROW_V   ,--VIDEO_O_ROW_V   ,--VIDEO_O_NUC_V    ,--VIDEO_O_ROW_V      ,    -- VIDEO_O_NUC_V    ,  
    VIDEO_I_H     => VIDEO_O_ROW_H   ,--VIDEO_O_NUC_H   ,--VIDEO_O_ROW_H   ,--VIDEO_O_ROW_H   ,--VIDEO_O_NUC_H    ,--VIDEO_O_ROW_H      ,    -- VIDEO_O_NUC_H    ,  
    VIDEO_I_EOI   => VIDEO_O_ROW_EOI ,--VIDEO_O_NUC_EOI ,--VIDEO_O_ROW_EOI ,--VIDEO_O_ROW_EOI ,--VIDEO_O_NUC_EOI  ,--VIDEO_O_ROW_EOI    ,    -- VIDEO_O_NUC_EOI  ,  
    VIDEO_I_DAV   => VIDEO_O_ROW_DAV ,--VIDEO_O_NUC_DAV ,--VIDEO_O_ROW_DAV ,--VIDEO_O_ROW_DAV ,--VIDEO_O_NUC_DAV  ,--VIDEO_O_ROW_DAV    ,    -- VIDEO_O_NUC_DAV  ,  
    VIDEO_I_DATA  => VIDEO_O_ROW_DATA,--VIDEO_O_NUC_DATA,--VIDEO_O_ROW_DATA,--VIDEO_O_ROW_DATA,--VIDEO_O_NUC_DATA ,--VIDEO_O_ROW_DATA   ,    -- VIDEO_O_NUC_DATA ,  
                        
    VIDEO_O_V     => VIDEO_O_BADP_V    ,
    VIDEO_O_H     => VIDEO_O_BADP_H    ,
    VIDEO_O_EOI   => VIDEO_O_BADP_EOI  ,
    VIDEO_O_DAV   => VIDEO_O_BADP_DAV  ,
    VIDEO_O_DATA  => VIDEO_O_BADP_DATA 
  );
  
--VIDEO_O_BADP_V      <=   VIDEO_O_NUC_V   ;
--VIDEO_O_BADP_H      <=   VIDEO_O_NUC_H   ;
--VIDEO_O_BADP_EOI    <=   VIDEO_O_NUC_EOI ;
--VIDEO_O_BADP_DAV    <=   VIDEO_O_NUC_DAV ;
--VIDEO_O_BADP_DATA   <=   VIDEO_O_NUC_DATA;

--  i_polarity : entity WORK.POLARITY
--    generic map(
--    bit_width => 13,
--    VIDEO_XSIZE => VIDEO_XSIZE,
--    VIDEO_YSIZE => VIDEO_YSIZE
--    )
--    port map(
--    CLK              => CLK,                                     --  Clock
--    RST              => RST,
  
--    POLARITY           => POLARITY,
  
--    --Input from AGC block
--    VIDEO_I_V     =>  VIDEO_O_BADP_V    ,            
--    VIDEO_I_H     =>  VIDEO_O_BADP_H    ,           
--    VIDEO_I_EOI   =>  VIDEO_O_BADP_EOI  , 
--    VIDEO_I_DAV   =>  VIDEO_O_BADP_DAV  ,          
--    VIDEO_I_DATA  =>  VIDEO_O_BADP_DATA , 
--    VIDEO_I_XSIZE =>  std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),
--    VIDEO_I_YSIZE =>  std_logic_vector(to_unsigned(VIDEO_YSIZE,PIX_BITS)),
  
--    -- Output to ColorConverter block
--    VIDEO_O_V     => VIDEO_O_V_P     ,
--    VIDEO_O_H     => VIDEO_O_H_P     ,
--    VIDEO_O_DAV   => VIDEO_O_DAV_P   ,
--    VIDEO_O_DATA  => VIDEO_O_DATA_P  ,
--    VIDEO_O_EOI   => VIDEO_O_EOI_P   ,
--    VIDEO_O_XSIZE => VIDEO_O_XSIZE_P ,
--    VIDEO_O_YSIZE => VIDEO_O_YSIZE_P    
--    );

--VIDEO_O_BADP_V    <= VIDEO_O_NUC_V    ;
--VIDEO_O_BADP_H    <= VIDEO_O_NUC_H    ;
--VIDEO_O_BADP_EOI  <= VIDEO_O_NUC_EOI  ;
--VIDEO_O_BADP_DAV  <= VIDEO_O_NUC_DAV  ;
--VIDEO_O_BADP_DATA <= VIDEO_O_NUC_DATA ;

--MAX_LIMITER_DPHE_MUL <= std_logic_vector(unsigned(MUX_MAX_LIMITER_DPHE)*to_unsigned(50,16)); 
--CNTRL_MAX_GAIN_MUL   <= std_logic_vector(unsigned(MUX_CNTRL_MAX_GAIN)*to_unsigned(640,16)); 
--CNTRL_IPP_MUL        <= x"0000" & MUX_CNTRL_IPP;  

Inst_DPHE_with_controls :  entity WORK.dphe_with_controls
    generic map (
    
      bit_width                =>  13                 ,     -- one less than the bit_width of pixel_in
      PIX_BITS                 =>  PIX_BITS                  ,     -- 2**PIX_BITS = Maximum Number of pixels in a line
      LIN_BITS                 =>  LIN_BITS                  ,     -- 2**LIN_BITS = Maximum Number of  lines in an image 
      bitdepth_inter           =>  8                         ,     -- bitdepth of pixel stored in intermediate histogram
      bitdepth_out             =>  8                         ,     -- bitdepth of pixel_out
      image_width              =>  VIDEO_XSIZE               ,     -- image width
      image_height             =>  VIDEO_YSIZE                    -- image height
    )
    port map (
      CLK                      =>  CLK                       ,                           
      RST                      =>  RST                       ,    
      pixel_vld                =>  VIDEO_O_BADP_DAV          , --VIDEO_O_NUC_DAV           ,---VIDEO_O_DAV_P             , --VIDEO_O_BADP_DAV          ,  --VIDEO_O_BADP_DAV1          , --VIDEO_I_NUC_DAV           ,             
      pixel_in                 =>  VIDEO_O_BADP_DATA         , --VIDEO_O_NUC_DATA          ,---VIDEO_O_DATA_P            , --VIDEO_O_BADP_DATA         ,  --VIDEO_O_BADP_DATA1         , --VIDEO_I_NUC_DATA          ,
      video_i_h                =>  VIDEO_O_BADP_H            , --VIDEO_O_NUC_H             ,---VIDEO_O_H_P               , --VIDEO_O_BADP_H            ,  --VIDEO_O_BADP_H1            , --VIDEO_I_NUC_H             ,                   
      video_i_v                =>  VIDEO_O_BADP_V            , --VIDEO_O_NUC_V             ,---VIDEO_O_V_P               , --VIDEO_O_BADP_V            ,  --VIDEO_O_BADP_V1            , --VIDEO_I_NUC_V             ,
      video_i_xsize            =>  std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),        
      video_i_ysize            =>  std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),        
      video_o_dav              =>  VIDEO_O_DAV_DPHE_l        ,                                       
      video_o_data             =>  VIDEO_O_DATA_DPHE_l       ,           
      video_o_h                =>  VIDEO_O_H_DPHE_l          ,         
      video_o_v                =>  VIDEO_O_V_DPHE_l          ,        
--      video_o_xcnt             =>  VIDEO_O_XCNT_DPHE_l       ,        
--      video_o_ycnt             =>  VIDEO_O_YCNT_DPHE_l       ,       
--      video_o_xsize            =>  VIDEO_O_XSIZE_DPHE_l      ,       
--      video_o_ysize            =>  VIDEO_O_YSIZE_DPHE_l      ,       
      video_o_eoi              =>  VIDEO_O_EOI_DPHE_l        ,
      dphe_max_limiter         =>  MAX_LIMITER_DPHE_MUL      ,
      cntrl_min_dphe           =>  CNTRL_MIN_DPHE            ,
      cntrl_max_dphe           =>  CNTRL_MAX_DPHE            ,
      cntrl_hist1_dphe         =>  CNTRL_HIST1_DPHE          ,
      cntrl_hist2_dphe         =>  CNTRL_HIST2_DPHE          ,   
      cntrl_clip_dphe          =>  CNTRL_CLIP_DPHE           ,
      roi_x_offset              => roi_x_offset              ,
      roi_y_offset             =>  roi_y_offset              ,
      roi_x_size               =>  roi_x_size                ,
      roi_y_size               =>  roi_y_size                ,
      linear_hist_en           => '0',--MUX_AGC_MODE_SEL(0)           ,
      max_gain                 =>  max_gain                  ,
      roi_mode                 =>  roi_mode                  ,
      adaptive_clipping_mode   =>  adaptive_clipping_mode    ,
      enhance_low_contrast     =>  SELECT_CONTRAST_ALGO(1)    
    );  

  calib_gen3: if(CALIB_EN=FALSE) generate

  i_new_HIST_EQUALIZATION_MinMax : entity WORK.new_HIST_EQUALIZATION_MinMax 
  generic map (
      bitdepth  => 14,
      bit_width => 13,
      VIDEO_XSIZE => VIDEO_XSIZE,
      VIDEO_YSIZE => VIDEO_YSIZE 
  )
  port map(
      CLK              => CLK ,            --  Clock
      RST              => RST ,            --  Reset
      VIDEO_I_V        => VIDEO_O_BADP_V ,    --VIDEO_I_HIST_V ,  
      VIDEO_I_H        => VIDEO_O_BADP_H  ,   --VIDEO_I_HIST_H  , 
      VIDEO_I_EOI      => VIDEO_O_BADP_EOI ,  --VIDEO_I_HIST_EOI ,
      VIDEO_I_DAV      => VIDEO_O_BADP_DAV ,  --VIDEO_I_HIST_DAV ,
      VIDEO_I_DATA     => VIDEO_O_BADP_DATA,  --VIDEO_I_HIST_DATA,
  --    VIDEO_I_XCNT     => std_logic_vector(9 downto 0);
  --    VIDEO_I_YCNT     => std_logic_vector(9 downto 0);
--      VIDEO_I_XSIZE    => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),
--      VIDEO_I_YSIZE    => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),
      VIDEO_O_V        => VIDEO_O_V_HISTEQ,
      VIDEO_O_H        => VIDEO_O_H_HISTEQ,
      VIDEO_O_EOI      => VIDEO_O_EOI_HISTEQ,
      VIDEO_O_DAV      => VIDEO_O_DAV_HISTEQ,
      VIDEO_O_DATA     => VIDEO_O_DATA_HISTEQ,
--      VIDEO_O_XCNT     => VIDEO_O_XCNT_HISTEQ,
--      VIDEO_O_YCNT     => VIDEO_O_YCNT_HISTEQ,
--      VIDEO_O_XSIZE    => VIDEO_O_XSIZE_HISTEQ,
--      VIDEO_O_YSIZE    => VIDEO_O_YSIZE_HISTEQ,
      CNTRL_IPP        => CNTRL_IPP_MUL,
      CNTRL_MAX_GAIN   => CNTRL_MAX_GAIN_MUL,
      CNTRL_MIN        => CNTRL_MIN_HISTEQ,
      CNTRL_MAX        => CNTRL_MAX_HISTEQ,
      CNTRL_HISTORY    => CNTRL_HISTORY_HISTEQ,
      prev_lowVal_out  => IMG_MIN,
      prev_highVal_out => IMG_MAX
  );

  process(CLK, RST)
        begin
        if RST = '1' then
            VIDEO_OUT_MUX_SEL <= "00"; 
        elsif rising_edge(CLK) then  
--            if VIDEO_I_FILT_EOI = '1' then
--            if VIDEO_O_NUC_V = '1' then  
            if VIDEO_O_BADP_V = '1' then
               VIDEO_OUT_MUX_SEL <= MUX_AGC_MODE_SEL; 
            end if;
            if  VIDEO_OUT_MUX_SEL = "01" then

                  VIDEO_I_FILT_V    <=  VIDEO_O_V_HISTEQ;    --VIDEO_O_CLHE_V;
                  VIDEO_I_FILT_H    <=  VIDEO_O_H_HISTEQ;    --VIDEO_O_CLHE_H;
                  VIDEO_I_FILT_EOI  <=  VIDEO_O_EOI_HISTEQ;  --VIDEO_O_CLHE_EOI;
                  VIDEO_I_FILT_DAV  <=  VIDEO_O_DAV_HISTEQ;  --VIDEO_O_CLHE_DAV;
                  VIDEO_I_FILT_DATA <=  VIDEO_O_DATA_HISTEQ; --"000000" & VIDEO_O_CLHE_DATA;                
--                VIDEO_I_FILT_V    <= VIDEO_O_V_DPHE_l;
--                VIDEO_I_FILT_H    <= VIDEO_O_H_DPHE_l;
--                VIDEO_I_FILT_EOI  <= VIDEO_O_EOI_DPHE_l;
--                VIDEO_I_FILT_DAV  <= VIDEO_O_DAV_DPHE_l;
--                VIDEO_I_FILT_DATA <= "000000" & VIDEO_O_DATA_DPHE_l ;                                          
           else
                VIDEO_I_FILT_V    <= VIDEO_O_V_DPHE_l;
                VIDEO_I_FILT_H    <= VIDEO_O_H_DPHE_l;
                VIDEO_I_FILT_EOI  <= VIDEO_O_EOI_DPHE_l;
                VIDEO_I_FILT_DAV  <= VIDEO_O_DAV_DPHE_l;
--                VIDEO_I_FILT_DATA <= "000000" & VIDEO_O_DATA_DPHE_l ;
                VIDEO_I_FILT_DATA <= VIDEO_O_DATA_DPHE_l ;     
                                     
            end if;
          end if;  
    end process;


--VIDEO_I_FILT_V    <= VIDEO_O_V_DPHE_l;                     --VIDEO_I_NUC_V                          ;
--VIDEO_I_FILT_H    <= VIDEO_O_H_DPHE_l;                     --VIDEO_I_NUC_H                          ;
--VIDEO_I_FILT_EOI  <= VIDEO_O_EOI_DPHE_l;                   --VIDEO_I_NUC_EOI                        ;
--VIDEO_I_FILT_DAV  <= VIDEO_O_DAV_DPHE_l;                   --VIDEO_I_NUC_DAV                        ;
----VIDEO_I_FILT_DATA <= "000000" & VIDEO_O_DATA_DPHE_l ;      --"000000" &VIDEO_I_NUC_DATA(13 downto 6);
--VIDEO_I_FILT_DATA <= VIDEO_O_DATA_DPHE_l ;      --"000000" &VIDEO_I_NUC_DATA(13 downto 6);




i_filter3x3_blur: filter3x3_blur
generic map(
    bitwidth    => 8,
    VIDEO_XSIZE => VIDEO_XSIZE,
        VIDEO_YSIZE => VIDEO_YSIZE,
      PIX_BITS    => PIX_BITS,
      LIN_BITS    => LIN_BITS
    )
port map(
  clk          => CLK,
  rst          => RST,

  av_wr        => av_wr_blur     ,
    av_addr      => av_addr_blur,
    av_data      => av_data_blur   ,
    av_busy      => av_busy_blur   ,

  video_i_v    => VIDEO_I_FILT_V    ,   
  video_i_h    => VIDEO_I_FILT_H    ,   
  video_i_eoi  => VIDEO_I_FILT_EOI  ,   
  video_i_dav  => VIDEO_I_FILT_DAV  ,   
  video_i_data => VIDEO_I_FILT_DATA ,  

  video_o_v    => VIDEO_O_FILT_V    ,   
  video_o_h    => VIDEO_O_FILT_H    ,   
  video_o_eoi  => VIDEO_O_FILT_EOI  ,   
  video_o_dav  => VIDEO_O_FILT_DAV  ,   
  video_o_data => VIDEO_O_FILT_DATA  
);


i_filter3x3_sharp_edge: filter3x3_sharp_edge
generic map(
    bitwidth    => 8,
    VIDEO_XSIZE => VIDEO_XSIZE,
        VIDEO_YSIZE => VIDEO_YSIZE,
      PIX_BITS    => PIX_BITS,
      LIN_BITS    => LIN_BITS
    )
port map(
  clk          => CLK,
  rst          => RST,

  av_wr        => av_wr_sharp_edge  ,     
    av_addr      => av_addr_sharp_edge,  
    av_data      => av_data_sharp_edge,  
    av_busy      => av_busy_sharp_edge,  

  video_i_v    => VIDEO_O_FILT_V    , 
  video_i_h    => VIDEO_O_FILT_H    , 
  video_i_eoi  => VIDEO_O_FILT_EOI  , 
  video_i_dav  => VIDEO_O_FILT_DAV  , 
  video_i_data => VIDEO_O_FILT_DATA ,

  video_o_v    => VIDEO_O_SFILT_V ,     
  video_o_h    => VIDEO_O_SFILT_H ,     
  video_o_eoi  => VIDEO_O_SFILT_EOI,    
  video_o_dav  => VIDEO_O_SFILT_DAV ,   
  video_o_data => VIDEO_O_SFILT_DATA 
);


  MUX_POLARITY_START <= MUX_POLARITY when (video_start='1') else "00";
  
  i_polarity : entity WORK.POLARITY
    generic map(
    bit_width => 7,
    VIDEO_XSIZE => VIDEO_XSIZE,
    VIDEO_YSIZE => VIDEO_YSIZE
    )
    port map(
    CLK           => CLK,--CLK_54MHZ,--CLK,                                     --  Clock
    RST           => RST,
  
    POLARITY      => MUX_POLARITY_START,
    BH_OFFSET     => BH_OFFSET,
  
    --Input from AGC block
    VIDEO_I_V     => VIDEO_O_SFILT_V   , 
    VIDEO_I_H     => VIDEO_O_SFILT_H   , 
    VIDEO_I_EOI   => VIDEO_O_SFILT_EOI , 
    VIDEO_I_DAV   => VIDEO_O_SFILT_DAV , 
    VIDEO_I_DATA  => VIDEO_O_SFILT_DATA, 
--    VIDEO_I_XSIZE =>  
--    VIDEO_I_YSIZE =>  
  
    -- Output to ColorConverter block
    VIDEO_O_V     => VIDEO_O_V_P     ,
    VIDEO_O_H     => VIDEO_O_H_P     ,
    VIDEO_O_DAV   => VIDEO_O_DAV_P   ,
    VIDEO_O_DATA  => VIDEO_O_DATA_P  ,
    VIDEO_O_EOI   => VIDEO_O_EOI_P   
--    VIDEO_O_XSIZE => VIDEO_O_XSIZE_P ,
--    VIDEO_O_YSIZE => VIDEO_O_YSIZE_P    
    );
 
---- MUX_BRIGHTNESS_MAP           <= '0' &MUX_BRIGHTNESS(3 downto 0) &"000"; 
---- MUX_CONTRAST_MAP             <= '0' &MUX_CONTRAST(3 downto 0) &"000"; 
 
 
-- MUX_BRIGHTNESS_MAP           <= std_logic_vector(resize(unsigned(MUX_BRIGHTNESS)*3+ unsigned(BRIGHTNESS_OFFSET),MUX_BRIGHTNESS_MAP'length)); 
-- MUX_CONTRAST_MAP             <= std_logic_vector(resize(unsigned(MUX_CONTRAST)*3+ unsigned(CONTRAST_OFFSET),MUX_CONTRAST_MAP'length)); 
 
 MUX_BRIGHTNESS_MAP           <= std_logic_vector(resize(unsigned(MUX_BRIGHTNESS)*10,MUX_BRIGHTNESS_MAP'length)); 
 MUX_CONTRAST_MAP             <= std_logic_vector(resize(unsigned(MUX_CONTRAST)*10,MUX_CONTRAST_MAP'length)); 

 ENABLE_BRIGHT_CONTRAST_START <= ENABLE_BRIGHT_CONTRAST and video_start;
--   ----------------------------
  i_brightness_contrast : entity WORK.BRIGHTNESS_CONTRAST
    generic map(
    bit_width => 7,
    VIDEO_XSIZE => VIDEO_XSIZE,
    VIDEO_YSIZE => VIDEO_YSIZE
    )
    port map(
    CLK              => CLK,--CLK_54MHZ,--CLK,                                     --  Clock
    RST              => RST,
  
    ENABLE           => ENABLE_BRIGHT_CONTRAST_START,
  
    CTRL_BRIGHT      => MUX_BRIGHTNESS_MAP,
    CTRL_CONTRAST    => MUX_CONTRAST_MAP, 
  
    --Input from AGC block
    VIDEO_I_V     => VIDEO_O_V_P     ,   
    VIDEO_I_H     => VIDEO_O_H_P     ,   
    VIDEO_I_EOI   => VIDEO_O_EOI_P   ,   
    VIDEO_I_DAV   => VIDEO_O_DAV_P   ,   
    VIDEO_I_DATA  => VIDEO_O_DATA_P  ,   
--    VIDEO_I_XSIZE => VIDEO_O_XSIZE_P ,   
--    VIDEO_I_YSIZE => VIDEO_O_YSIZE_P ,   
  
    -- Output to ColorConverter block
    VIDEO_O_V     => VIDEO_O_V_BC     ,
    VIDEO_O_H     => VIDEO_O_H_BC     ,
    VIDEO_O_DAV   => VIDEO_O_DAV_BC   ,
    VIDEO_O_DATA  => VIDEO_O_DATA_BC  ,
    VIDEO_O_EOI   => VIDEO_O_EOI_BC   
--    VIDEO_O_XSIZE => VIDEO_O_XSIZE_BC ,
--    VIDEO_O_YSIZE => VIDEO_O_YSIZE_BC    
    );





i_VIDEO_MUX : entity WORK.VIDEO_MUX 
generic map(
    bit_width => 7
  )
port map(
    -- Clock and Reset
      CLK           => CLK,                     -- Module Clock 
      RST           => RST,                -- Module Reset (asynch'ed active high)
      --Channel Select
      Channel_Select=>  SELECT_VIDEO_OUT,
      --Channel 1
      VIDEO_I_V_1     =>  VIDEO_I_V_SN     ,                                  
      VIDEO_I_H_1     =>  VIDEO_I_H_SN     ,                                  
      VIDEO_I_EOI_1   =>  VIDEO_I_EOI_SN   ,                                  
      VIDEO_I_DAV_1   =>  VIDEO_I_DAV_SN   ,                                  
      VIDEO_I_DATA_1  =>  VIDEO_I_DATA_SN(13 downto 6)  ,                                  
      VIDEO_I_XSIZE_1 =>  std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),
      VIDEO_I_YSIZE_1 =>  std_logic_vector(to_unsigned(VIDEO_YSIZE,PIX_BITS)),
                           
    --Channel 2
      VIDEO_I_V_2     => VIDEO_O_BADP_V      ,                                 
      VIDEO_I_H_2     => VIDEO_O_BADP_H      ,                                
      VIDEO_I_EOI_2   => VIDEO_O_BADP_EOI    ,                                
      VIDEO_I_DAV_2   => VIDEO_O_BADP_DAV    ,                                
      VIDEO_I_DATA_2  => VIDEO_O_BADP_DATA(13 downto 6)   ,                                
      VIDEO_I_XSIZE_2 => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)), 
      VIDEO_I_YSIZE_2 => std_logic_vector(to_unsigned(VIDEO_YSIZE,PIX_BITS)), 

    --Channel 3
      VIDEO_I_V_3     =>  VIDEO_O_V_MIRE   ,      -- Video Output   Vertical Synchro  
      VIDEO_I_H_3     =>  VIDEO_O_H_MIRE   , -- Video Output Horizontal Synchro
      VIDEO_I_EOI_3   =>  VIDEO_O_EOI_MIRE , 
      VIDEO_I_DAV_3   =>  VIDEO_O_DAV_MIRE ,  -- Video Output Data Valid
      VIDEO_I_DATA_3  =>  VIDEO_O_DATA_MIRE,  
      VIDEO_I_XSIZE_3 =>  std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),  
      VIDEO_I_YSIZE_3 =>  std_logic_vector(to_unsigned(VIDEO_YSIZE,PIX_BITS)),

    --Channel 4
      VIDEO_I_V_4     =>  VIDEO_I_FILT_V ,               --VIDEO_O_V_DPHE_l,   
      VIDEO_I_H_4     =>  VIDEO_I_FILT_H ,               --VIDEO_O_H_DPHE_l,   
      VIDEO_I_EOI_4   =>  VIDEO_I_FILT_EOI,              --VIDEO_O_EOI_DPHE_l, 
      VIDEO_I_DAV_4   =>  VIDEO_I_FILT_DAV ,             --VIDEO_O_DAV_DPHE_l, 
      VIDEO_I_DATA_4  =>  VIDEO_I_FILT_DATA(7 downto 0) ,--VIDEO_O_DATA_DPHE_l,
      VIDEO_I_XSIZE_4 =>  std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)), 
      VIDEO_I_YSIZE_4 =>  std_logic_vector(to_unsigned(VIDEO_YSIZE,PIX_BITS)),
      
      --Channel 5
      VIDEO_I_V_5     =>  VIDEO_O_FILT_V ,   
      VIDEO_I_H_5     =>  VIDEO_O_FILT_H ,   
      VIDEO_I_EOI_5   =>  VIDEO_O_FILT_EOI,  
      VIDEO_I_DAV_5   =>  VIDEO_O_FILT_DAV , 
      VIDEO_I_DATA_5  =>  VIDEO_O_FILT_DATA(7 downto 0) ,
      VIDEO_I_XSIZE_5 =>  std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)), 
      VIDEO_I_YSIZE_5 =>  std_logic_vector(to_unsigned(VIDEO_YSIZE,PIX_BITS)), 
      
      --Channel 6
      VIDEO_I_V_6     =>  VIDEO_O_V_BC    ,--VIDEO_O_SFILT_V ,   
      VIDEO_I_H_6     =>  VIDEO_O_H_BC    ,--VIDEO_O_SFILT_H ,   
      VIDEO_I_EOI_6   =>  VIDEO_O_EOI_BC  ,--VIDEO_O_SFILT_EOI,  
      VIDEO_I_DAV_6   =>  VIDEO_O_DAV_BC  ,--VIDEO_O_SFILT_DAV , 
      VIDEO_I_DATA_6  =>  VIDEO_O_DATA_BC ,--VIDEO_O_SFILT_DATA(7 downto 0),
      VIDEO_I_XSIZE_6 =>  std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)), 
      VIDEO_I_YSIZE_6 =>  std_logic_vector(to_unsigned(VIDEO_YSIZE,PIX_BITS)), 
      
      --Output Channel
      VIDEO_O_V     =>     VIDEO_MUX_OUT_V     ,                -- Video Output   Vertical Synchro  
      VIDEO_O_H     =>     VIDEO_MUX_OUT_H     ,             -- Video Output Horizontal Synchro
      VIDEO_O_EOI   =>     VIDEO_MUX_OUT_EOI   ,
      VIDEO_O_DAV   =>     VIDEO_MUX_OUT_DAV   ,                 -- Video Output Data Valid
      VIDEO_O_DATA  =>     VIDEO_MUX_OUT_DATA  , 
      VIDEO_O_XSIZE =>     VIDEO_MUX_OUT_XSIZE ,   
      VIDEO_O_YSIZE =>     VIDEO_MUX_OUT_YSIZE
      
  );


end generate;

calib_gen4: if(CALIB_EN=True) generate

VIDEO_MUX_OUT_V      <= VIDEO_O_V_DPHE_l;
VIDEO_MUX_OUT_H      <= VIDEO_O_H_DPHE_l;
VIDEO_MUX_OUT_EOI    <= VIDEO_O_EOI_DPHE_l;
VIDEO_MUX_OUT_DAV    <= VIDEO_O_DAV_DPHE_l;
VIDEO_MUX_OUT_DATA   <= VIDEO_O_DATA_DPHE_l; 
VIDEO_MUX_OUT_XSIZE  <= std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)); 
VIDEO_MUX_OUT_YSIZE  <= std_logic_vector(to_unsigned(VIDEO_YSIZE,PIX_BITS)); 

end generate;

--MAX_SDRAM_WR_START_WAIT <= MAX_AGC_MODE_INFO_DISP_TIME;
--process(CLK, RST)begin
--    if RST = '1' then
--        sdram_wr_start_cnt <= (others=>'0');
--        sdram_wr_start     <= '0';
--    elsif rising_edge(CLK) then
--        if(video_start= '1')then
--            if(sdram_wr_start_cnt >= unsigned(MAX_SDRAM_WR_START_WAIT))then
--                sdram_wr_start     <= '1';  
--                sdram_wr_start_cnt <= sdram_wr_start_cnt;
--            else
--                if(TICK1MS = '1')then
--                    sdram_wr_start_cnt <= sdram_wr_start_cnt +1;
--                else
--                    sdram_wr_start_cnt <= sdram_wr_start_cnt;
--                end if;
--                sdram_wr_start     <= '0';
--            end if;    
--        else
--            sdram_wr_start_cnt <= (others=>'0');
--            sdram_wr_start     <= '0';
--        end if;    
--    end if;
--end process;    


--qspi_init_cmd_done_n <= ((not qspi_init_cmd_done) or (DMA_NUC1PT_MUX)) or (not sdram_wr_start);

--qspi_init_cmd_done_n <= ((not qspi_init_cmd_done) or (DMA_NUC1PT_MUX)) or stop_dma_write_c;
qspi_init_cmd_done_n <= ((not qspi_init_cmd_done) or (CONTROL_SDRAM_WRITE_START_STOP)) or stop_dma_write;

----qspi_init_cmd_done_n <= (not qspi_init_cmd_done);

--MEM_IMG_BUF_Temp     <=  MEM_IMG_BUF when DMA_NUC1PT_MUX = '0' else MEM_IMG_BUF_SEL;
MEM_IMG_BUF_Temp     <=  MEM_IMG_BUF_SEL when DMA_NUC1PT_MUX = '1' else 
                         MEM_IMG_BUF_SEL1 when stop_dma_write = '1'else
                         MEM_IMG_BUF_SEL2 when stop_dma_write2 = '1' else
                         MEM_IMG_BUF;

--process(CLK, RST)
--begin
--    if RST = '1' then
--        frame_delay_cnt <= (others=>'0');
--    else if rising_edge(CLK) then
--     case WR_FRAME_FSM is       
--        when s_WR_FRAME_IDLE =>  
--            qspi_init_cmd_done_n <= (not qspi_init_cmd_done) or (DMA_NUC1PT_MUX);
--            WR_FRAME_FSM         <= s_WR_FRAME_IDLE;
--        if VIDEO_I_FILT_V ='1' then
--            frame_delay_cnt <= frame_delay_cnt + 1;
--        end if;
            
--    end if;
    
--end if;
--end process;    


--i_image_shift_control: image_shift_control
--  generic map(
--          LIN_BITS => PIX_BITS,
--          PIX_BITS => LIN_BITS,
--          DATA_BITS => 8
--  )
--  port map(
--    clk               => CLK,--CLK_54MHZ,--CLK,
--    rst               => qspi_init_cmd_done_n,--RST,
--    img_shift_vert    => MUX_IMG_SHIFT_VERT,
--    video_i_v         => VIDEO_MUX_OUT_V   ,--BT656_V,      --USB_V,   --BT656_V,
--    video_i_h         => VIDEO_MUX_OUT_H   ,--BT656_H,      --USB_H,   --BT656_H,
--    video_i_dav       => VIDEO_MUX_OUT_DAV ,--BT656_DAV,    --USB_DAV, --BT656_DAV,
--    video_i_data      => VIDEO_MUX_OUT_DATA,--BT656_DATA_2, --USB_DATA,--BT656_DATA_2,
--    video_i_eoi       => VIDEO_MUX_OUT_EOI ,--BT656_EOI,    --USB_EOI, --BT656_EOI,
--    video_i_xsize     => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),--std_logic_vector(to_unsigned(716,PIX_BITS)),--BT656_XSIZE,
--    video_i_ysize     => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),--std_logic_vector(to_unsigned(576,LIN_BITS)),--BT656_YSIZE,
--    video_req_xsize   => std_logic_vector(to_unsigned(640,PIX_BITS)),--std_logic_vector(to_unsigned(USB_VIDEO_XSIZE,PIX_BITS)),
--    video_req_ysize   => std_logic_vector(to_unsigned(480,LIN_BITS)),--std_logic_vector(to_unsigned(USB_VIDEO_YSIZE,LIN_BITS)), 
--    add_left_pix      => std_logic_vector(to_unsigned(0,PIX_BITS)),    
--    add_right_pix     => std_logic_vector(to_unsigned(0,LIN_BITS)),   
--    video_o_v         => VIDEO_V_PROC,      
--    video_o_h         => VIDEO_H_PROC,      
--    video_o_eoi       => VIDEO_EOI_PROC, 
--    video_o_dav       => VIDEO_DAV_PROC, 
--    video_o_data      => VIDEO_DATA_PROC
--  ); 

MUX_IMG_FLIP_V <= '0' when (sel_oled_analog_video_out= '1') else IMG_FLIP_V;
MUX_IMG_FLIP_H <= '0' when (sel_oled_analog_video_out= '1') else IMG_FLIP_H;

i_DMA_WRITE_BT656 : entity WORK.DMA_WRITE_BT656 
  generic map(
    ADDR_BUF0 => unsigned(ADDR_VIDEO_BUF0) , --: unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 0
    ADDR_BUF1 => unsigned(ADDR_VIDEO_BUF1) , --: unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 1
    ADDR_BUF2 => unsigned(ADDR_VIDEO_BUF2) , --: unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 2
    DMA_SIZE_BITS => DMA_SIZE_BITS ,
    WR_SIZE   =>  16 --: positive range 1 to 16 := 4  -- Write Burst Size for Memory Write Requests    
  )
  port map (
    CLK           => CLK,--CLK_27MHZ  , -- : in  std_logic;                      -- Module Clock
    RST           => qspi_init_cmd_done_n  , -- : in  std_logic;                      -- Module Reset (async active high) 
    IMG_FLIP_V    => MUX_IMG_FLIP_V,--IMG_FLIP_V, --in std_logic;     -- IMAGE FLIP VERTICALLY
    IMG_FLIP_H    => MUX_IMG_FLIP_H,--IMG_FLIP_H, --in std_logic;     -- IMAGE FLIP HORIZONTALLY    
    IMG_SHIFT_VERT => std_logic_vector(to_unsigned(0,LIN_BITS)), --MUX_IMG_SHIFT_VERT,  
    -- Source Input Flux (sync'ed on CLK)               
    SRC_V         =>  VIDEO_MUX_OUT_V   , --VIDEO_O_V_TE     ,             --VIDEO_O_V_DPHE_l   , --VIDEO_MUX_OUT_V   ,--VIDEO_O_SFILT_V,               --VIDEO_O_FILT_V,                -- VIDEO_I_FILT_V   ,            --VIDEO_O_SFILT_V,               --VIDEO_O_FILT_V,               --VIDEO_O_SFILT_V,               --VIDEO_I_FILT_V   ,              --VIDEO_O_FILT_V,               --VIDEO_O_V_MIRE,--VIDEO_O_FILT_V  , -- : in  std_logic;                      -- Source New Frame
    SRC_H         =>  VIDEO_MUX_OUT_H   , --VIDEO_O_H_TE     ,             --VIDEO_O_H_DPHE_l   , --VIDEO_MUX_OUT_H   ,--VIDEO_O_SFILT_H,               --VIDEO_O_FILT_H,                -- VIDEO_I_FILT_H   ,            --VIDEO_O_SFILT_H,               --VIDEO_O_FILT_H,               --VIDEO_O_SFILT_H,               --VIDEO_I_FILT_H   ,              --VIDEO_O_FILT_H,               --VIDEO_O_H_MIRE,--VIDEO_O_FILT_H , -- : in  std_logic;                      -- Source New Line
    SRC_EOI       =>  VIDEO_MUX_OUT_EOI , --VIDEO_O_EOI_TE   ,             --VIDEO_O_EOI_DPHE_l , --VIDEO_MUX_OUT_EOI ,--VIDEO_O_SFILT_EOI,             --VIDEO_O_FILT_EOI,              -- VIDEO_I_FILT_EOI ,            --VIDEO_O_SFILT_EOI,             --VIDEO_O_FILT_EOI,             --VIDEO_O_SFILT_EOI,             --VIDEO_I_FILT_EOI ,              --VIDEO_O_FILT_EOI,             --VIDEO_O_EOI_MIRE,--VIDEO_O_FILT_EOI   , -- : in  std_logic;                      -- Source End of Image
    SRC_DAV       =>  VIDEO_MUX_OUT_DAV , --VIDEO_O_DAV_TE   ,             --VIDEO_O_DAV_DPHE_l , --VIDEO_MUX_OUT_DAV ,--VIDEO_O_SFILT_DAV,             --VIDEO_O_FILT_DAV,              -- VIDEO_I_FILT_DAV ,            --VIDEO_O_SFILT_DAV,             --VIDEO_O_FILT_DAV,             --VIDEO_O_SFILT_DAV,             --VIDEO_I_FILT_DAV ,              --VIDEO_O_FILT_DAV,             --VIDEO_O_DAV_MIRE,--VIDEO_O_FILT_DAV , -- : in  std_logic;                      -- Source Data Valid
    SRC_DATA      =>  VIDEO_MUX_OUT_DATA, --VIDEO_O_DATA_TE(13 downto 6)  ,--VIDEO_O_DATA_DPHE_l, --VIDEO_MUX_OUT_DATA,--VIDEO_O_SFILT_DATA(7 downto 0),--VIDEO_O_FILT_DATA(7 downto 0), -- VIDEO_I_FILT_DATA(7 downto 0),--VIDEO_O_SFILT_DATA(7 downto 0),--VIDEO_O_FILT_DATA(7 downto 0),--VIDEO_O_SFILT_DATA(7 downto 0),--VIDEO_I_FILT_DATA(7 downto 0),  --VIDEO_O_FILT_DATA(7 downto 0),--VIDEO_O_DATA_MIRE,--VIDEO_O_FILT_DATA(7 downto 0) , -- : in  std_logic_vector( 7 downto 0);  -- Source Data
    SRC_XSIZE     =>  std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),  -- : in  std_logic_vector( 9 downto 0);  -- Source X Size (max 1023)
    SRC_YSIZE     =>  std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),   --: in  std_logic_vector( 9 downto 0);  -- Source Y Size (max 1023)
    -- Memory Image Info                                
    MEM_IMG_SOI   => open   , -- : out std_logic;                      -- Memory Image Picture Start
    MEM_IMG_BUF   => MEM_IMG_BUF   , -- : out std_logic_vector( 1 downto 0);  -- Memory Image Picture Buffer
    MEM_IMG_XSIZE => MEM_IMG_XSIZE   , -- : out std_logic_vector( 9 downto 0);  -- Memory Image Picture X Size (max 1023)
    MEM_IMG_YSIZE => MEM_IMG_YSIZE  , -- : out std_logic_vector( 9 downto 0);  -- Memory Image Picture Y Size (max 1023)
    -- Avalon DMA Master interface to Memory Controller 
    DMA_WRREADY   =>  DMA_W0_WRREADY_s  , -- : in  std_logic;                      -- DMA Write Ready
    DMA_WRREQ     =>  DMA_W0_WRREQ_s  , -- : out std_logic;                      -- DMA Write Request
    DMA_WRBURST   =>  DMA_W0_WRBURST_s  , --: out std_logic;                      -- DMA Write Request
    DMA_WRSIZE    =>  DMA_W0_WRSIZE_s  , -- : out std_logic_vector( 4 downto 0);  -- DMA Write Request Size
    DMA_WRADDR    =>  DMA_W0_WRADDR_s  , -- : out std_logic_vector(31 downto 0);  -- DMA Write Address
    DMA_WRDATA    =>  DMA_W0_WRDATA_s  , -- : out std_logic_vector(31 downto 0);  -- DMA Write Data
--    DMA_ADDR_DEC  =>  DMA_W0_ADDR_DEC_s, -- out std_logic;                                     -- DMA ADDRESS DECREMENT
    DMA_WRBE      =>  DMA_W0_WRBE_s,  -- : out std_logic_vector( 3 downto 0)   -- DMA Write Data Byte enable
    DMA_WRITE_FREE => DMA_WRITE_FREE
  );



process(CLK, RST)
    begin
    if RST = '1' then
      SNAPSHOT_FSM      <= s_SNAPSHOT_IDLE;
      stop_dma_write    <= '0';
      MEM_IMG_BUF_SEL1  <= "00";
      snapshot_trigger_latch <= '0';
      single_snapshot_latch     <= '0';
--      continuous_snapshot_latch <= '0';
      burst_snapshot_latch <= '0';
      single_snapshot_en        <= '0';
--      continuous_snapshot_en    <= '0';
      burst_snapshot_en    <= '0';
      gallery_img_rd_qspi_wr_sdram_en <= '0';
    elsif rising_edge(CLK) then
        snapshot_trigger_latch <= '0';
        single_snapshot_latch     <= '0';
--        continuous_snapshot_latch <= '0';  
        burst_snapshot_latch <= '0';       
        single_snapshot_en        <= '0';
--        continuous_snapshot_en    <= '0';   
        burst_snapshot_en    <= '0';         
        case SNAPSHOT_FSM is          
          when s_SNAPSHOT_IDLE =>
            stop_dma_write    <= '0';   
            if snapshot_trigger = '1' then
                SNAPSHOT_FSM   <= s_WAIT_DMA_FREE;  
            elsif single_snapshot = '1'  then
                SNAPSHOT_FSM   <= s_WAIT_DMA_FREE1;
--            elsif continuous_snapshot = '1' then
            elsif burst_snapshot = '1' then
                SNAPSHOT_FSM   <= s_WAIT_DMA_FREE2;
            elsif OSD_LOAD_GALLERY = '1'then
                SNAPSHOT_FSM   <= s_WAIT_DMA_FREE3;
                gallery_img_rd_qspi_wr_sdram_en <= '1';
            else      
                SNAPSHOT_FSM   <= s_SNAPSHOT_IDLE; 
            end if;
          when s_WAIT_DMA_FREE =>
            if DMA_WRITE_FREE = '1' then
                snapshot_trigger_latch <= '1';
                SNAPSHOT_FSM           <= s_SNAPSHOT_WAIT;
                stop_dma_write         <= '1';
                if(MEM_IMG_BUF = "00")then
                    MEM_IMG_BUF_SEL1    <= "10";
                elsif(MEM_IMG_BUF = "01")then 
                    MEM_IMG_BUF_SEL1    <= "00";
                elsif(MEM_IMG_BUF = "10")then    
                    MEM_IMG_BUF_SEL1    <= "01";
                else
                    MEM_IMG_BUF_SEL1    <= "00"; 
                end if;
            else    
                SNAPSHOT_FSM   <= s_WAIT_DMA_FREE;
                stop_dma_write         <= '0';            
            end if;            
            
          when s_SNAPSHOT_Wait =>                      
            if(snapshot_done = '1')then
                SNAPSHOT_FSM   <= s_SNAPSHOT_IDLE;
                stop_dma_write <= '0';     
            else  
                SNAPSHOT_FSM   <= s_SNAPSHOT_Wait;
                stop_dma_write <= '1';        
            end if; 
            
          when s_WAIT_DMA_FREE1 =>
            if DMA_WRITE_FREE = '1' then
                single_snapshot_latch  <= '1';
                SNAPSHOT_FSM           <= s_SNAPSHOT_WAIT1;
                stop_dma_write         <= '1';
                if(MEM_IMG_BUF = "00")then
                    MEM_IMG_BUF_SEL1    <= "10";
                elsif(MEM_IMG_BUF = "01")then 
                    MEM_IMG_BUF_SEL1    <= "00";
                elsif(MEM_IMG_BUF = "10")then    
                    MEM_IMG_BUF_SEL1    <= "01";
                else
                    MEM_IMG_BUF_SEL1    <= "00"; 
                end if;
            else    
                SNAPSHOT_FSM   <= s_WAIT_DMA_FREE1;
                stop_dma_write         <= '0';            
            end if;            
            
          when s_SNAPSHOT_Wait1 =>                      
            if(snapshot_done = '1')then
                single_snapshot_en <= '1';
                SNAPSHOT_FSM       <= s_SNAPSHOT_IDLE;
                stop_dma_write      <= '0';     
            else  
                single_snapshot_en <= '0';
                SNAPSHOT_FSM   <= s_SNAPSHOT_Wait1;
                stop_dma_write <= '1';        
            end if; 

         when s_WAIT_DMA_FREE2 =>
            if DMA_WRITE_FREE = '1' then
--                continuous_snapshot_latch  <= '1';
                burst_snapshot_latch   <= '1';
                SNAPSHOT_FSM           <= s_SNAPSHOT_WAIT2;
                stop_dma_write         <= '1';
                if(MEM_IMG_BUF = "00")then
                    MEM_IMG_BUF_SEL1    <= "10";
                elsif(MEM_IMG_BUF = "01")then 
                    MEM_IMG_BUF_SEL1    <= "00";
                elsif(MEM_IMG_BUF = "10")then    
                    MEM_IMG_BUF_SEL1    <= "01";
                else
                    MEM_IMG_BUF_SEL1    <= "00"; 
                end if;
            else    
                SNAPSHOT_FSM   <= s_WAIT_DMA_FREE2;
                stop_dma_write         <= '0';            
            end if;            
            
          when s_SNAPSHOT_Wait2 =>                      
            if(snapshot_done = '1')then
--                continuous_snapshot_en <= '1';
                burst_snapshot_en <= '1';
                SNAPSHOT_FSM   <= s_SNAPSHOT_IDLE;
                stop_dma_write <= '0';     
            else  
                SNAPSHOT_FSM   <= s_SNAPSHOT_Wait2;
                stop_dma_write <= '1';  
--                continuous_snapshot_en <= '0';    
                burst_snapshot_en <= '0';   
            end if; 

         when s_WAIT_DMA_FREE3 =>
            if DMA_WRITE_FREE = '1' then
                SNAPSHOT_FSM   <= s_SNAPSHOT_IDLE;
                gallery_img_rd_qspi_wr_sdram_en <= '0'; 
            else    
                SNAPSHOT_FSM   <= s_WAIT_DMA_FREE3;   
                gallery_img_rd_qspi_wr_sdram_en <= '1';         
            end if; 
                       
           

        end case;
    end if;
end process;


single_snapshot     <= OSD_SINGLE_SNAPSHOT;
--continuous_snapshot <= OSD_CONTINUOUS_SNAPSHOT;
burst_snapshot      <= OSD_BURST_SNAPSHOT;
snapshot_counter    <= OSD_SNAPSHOT_COUNTER;

--burst_snapshot      <= ;
--snapshot_counter    <= x"40";
 
 VIDEO_O_BADP_DATA1 <= "00"& VIDEO_O_BADP_DATA;
--  VIDEO_O_BADP_DATA1 <= "00"& VIDEO_O_NUC_DATA;
  i_snap: snapshot_controller 
  generic map( 
    PIX_BITS => PIX_BITS,
  LIN_BITS => LIN_BITS,
  WR_SIZE => 16,
  DMA_SIZE_BITS => DMA_SIZE_BITS
  )
  port map(
  clk         =>  CLK, 
  rst         =>  RST, 

  channel_in  => snapshot_channel_c,
  mode_in     => snapshot_mode_c,

  single_snapshot     => single_snapshot_latch,    
--  continuous_snapshot => continuous_snapshot_latch,
  burst_snapshot      => burst_snapshot_latch,
  burst_capture_size  => burst_capture_size,
  snapshot_counter    => snapshot_counter,


  trigger     => snapshot_trigger_c,
  busy_out    => snapshot_busy,
    
  done_out    => snapshot_done_c,

  total_frames => snapshot_total_frames_c,

  src_1_v     => raw_video_v    ,
  src_1_h     => raw_video_h    ,
  src_1_eoi   => raw_video_eoi  ,
  src_1_dav   => raw_video_dav  ,
  src_1_data  => raw_video_data ,
  src_1_xsize => raw_video_xsize,
  src_1_ysize => raw_video_ysize,

  src_2_v     => VIDEO_O_BADP_V    ,--'0',  VIDEO_O_NUC_V     ,
  src_2_h     => VIDEO_O_BADP_H    ,--'0',  VIDEO_O_NUC_H     ,
  src_2_eoi   => VIDEO_O_BADP_EOI  ,--'0',  VIDEO_O_NUC_EOI   ,
  src_2_dav   => VIDEO_O_BADP_DAV  ,--'0',  VIDEO_O_NUC_DAV   ,
  src_2_data  => VIDEO_O_BADP_DATA1,--VIDEO_O_BADP_DATA1,--(others=>'0'),
  src_2_xsize => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),
  src_2_ysize => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),

  src_3_v     => VIDEO_MUX_OUT_V     ,--VIDEO_I_FILT_V,
  src_3_h     => VIDEO_MUX_OUT_H     ,--VIDEO_I_FILT_H,
  src_3_eoi   => VIDEO_MUX_OUT_EOI   ,--VIDEO_I_FILT_EOI,
  src_3_dav   => VIDEO_MUX_OUT_DAV   ,--VIDEO_I_FILT_DAV,
  src_3_data  => VIDEO_MUX_OUT_DATA  ,--VIDEO_I_FILT_DATA(7 downto 0),
  src_3_xsize => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),--VIDEO_I_FILT_XSIZE,
  src_3_ysize => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),--VIDEO_I_FILT_YSIZE,

  src_4_v     => VIDEO_I_V_SN               , 
  src_4_h     => VIDEO_I_H_SN               ,
  src_4_eoi   => VIDEO_I_EOI_SN             ,
  src_4_dav   => VIDEO_I_DAV_SN             ,-- VIDEO_I_DAV_WITH_TEMP_SN   , --VIDEO_I_DAV_SN   ,
  src_4_data  => VIDEO_I_DATA_SN_1          ,
  src_4_xsize => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),--VIDEO_I_XSIZE_SN           ,--VIDEO_I_XSIZE_WITH_TEMP_SN ,--VIDEO_I_XSIZE_SN ,
  src_4_ysize => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),--VIDEO_I_YSIZE_SN           ,--VIDEO_I_YSIZE_WITH_TEMP_SN ,--VIDEO_I_YSIZE_SN ,
    
  dma_wrready => DMA_W1_WRREADY_s,
  dma_wrreq   => DMA_W1_WRREQ_s,
  dma_wrburst => DMA_W1_WRBURST_s,
  dma_wrsize  => DMA_W1_WRSIZE_s,
  dma_wraddr  => DMA_W1_WRADDR_s,
  dma_wrdata  => DMA_W1_WRDATA_s,
  dma_wrbe    => DMA_W1_WRBE_s
  
);


--process(CLK, RST)begin
--        if RST = '1' then
--          frame_cnt1 <= (others=>'0');
--          frame_cnt2 <= (others=>'0');
--          frame_cnt3 <= (others=>'0');
--        elsif rising_edge(CLK) then       
--            if TICK1S = '1' then
--              frame_cnt1 <= (others=>'0');
--              frame_cnt2 <= (others=>'0');
--              frame_cnt3 <= (others=>'0');
--            else
--                --if(MEM_IMG_SOI = '1')then  
--                if(SCALER_REQ_V ='1')then
--                  if MEM_IMG_BUF ="00"then
--                      frame_cnt1 <= frame_cnt1 +1;
--                  elsif MEM_IMG_BUF ="01"then
--                      frame_cnt2 <= frame_cnt2 +1;
--                  elsif MEM_IMG_BUF ="10"then
--                      frame_cnt3 <= frame_cnt3 +1;
--                  end if;    
--                end if;
--             end if;   
--        end if;
--  end process;   
  
  
  
  --mem_to_scalar_start <= RST or (not ENABLE_BADPIXREM);
  i_MEMORY_TO_SCALER :entity WORK.MEMORY_TO_SCALER 
    generic map(
      ADDR_BUF0 => unsigned(ADDR_VIDEO_BUF0),--: unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 0
      ADDR_BUF1 => unsigned(ADDR_VIDEO_BUF1),--: unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 1
      ADDR_BUF2 => unsigned(ADDR_VIDEO_BUF2),--: unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 2
      SNAPSHOT_IMG_ADDR_BASE => unsigned(ADDR_SNAPSHOT_BASE),
      SNAPSHOT_IMG_ADDR_OFFSET => unsigned(ADDR_SNAPSHOT_OFFSET_2),
      SNAPSHOT_BLANK_IMG_ADDR  => unsigned(SNAPSHOT_BLANK_IMG_ADDR),
      PIX_BITS  => 11,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
      LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image 
      DMA_SIZE_BITS => DMA_SIZE_BITS, 
      RD_SIZE   => 8 --: positive range 1 to 16 := 4  -- Read Burst Size for Memory Read Requests
    )
    port map (
      -- Clock and Reset
      CLK          => CLK,--CLK_54MHZ,--CLK,--CLK_27MHZ    , --: in  std_logic;                              -- Module Clock
      RST          => RST, --mem_to_scalar_start, --qspi_init_cmd_done_n  , --: in  std_logic;                              -- Module Reset (Asynchronous active high)
      En_Pattern   => '0',--DMA_NUC1PT_MUX,
      -- Memory Image Info                                
      --MEM_IMG_SOI   : in  std_logic;                              -- Memory Image Picture Start  
      GALLERY_ENABLE      => GALLERY_ENABLE,
      GALLERY_IMG_NUMBER  => GALLERY_IMG_NUMBER, 
      IMG_VALID           => OSD_GALLERY_IMG_VALID(71 downto 8),
      SNAPSHOT_COUNTER    => OSD_SNAPSHOT_COUNTER,
      MEM_IMG_BUF    => MEM_IMG_BUF_Temp,--MEM_IMG_BUF , --: in  std_logic_vector( 1 downto 0);          -- Memory Image Picture Buffer
      MEM_IMG_XSIZE  => MEM_IMG_XSIZE , -- : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture X Size (max 1023)
      MEM_IMG_YSIZE  => MEM_IMG_YSIZE  , --: in  std_logic_vector( 9 downto 0);          -- Memory Image Picture Y Size (max 1023)
      -- DMA Master Read Interface to Memory Controller
      DMA_RDREADY    => DMA_R0_RDREADY_s, -- : in  std_logic;                              -- DMA Ready Request
      DMA_RDREQ      => DMA_R0_RDREQ_s, -- : out std_logic;                              -- DMA Read Request
      DMA_RDSIZE     => DMA_R0_RDSIZE_s, -- : out std_logic_vector( 4 downto 0);          -- DMA Request Size
      DMA_RDADDR     => DMA_R0_RDADDR_s, -- : out std_logic_vector(31 downto 0);          -- DMA Master Address
      DMA_RDDAV      => DMA_R0_RDDAV_s, -- : in  std_logic;                              -- DMA Read Data Valid
      DMA_RDDATA     => DMA_R0_RDDATA_s, -- : in  std_logic_vector(31 downto 0);          -- DMA Read Data
      -- YCrCb output Flux to Scaler Module               -
      IMG_SHIFT_VERT => std_logic_vector(to_unsigned(0,LIN_BITS)),--MUX_IMG_SHIFT_VERT,
      SCALER_RUN     => SCALER_RUN, --: out std_logic;                              -- Scaler Run
      SCALER_REQ_V   => SCALER_REQ_V , --: in  std_logic;                              -- Scaler New Frame Request
      SCALER_REQ_H   => SCALER_REQ_H, -- : in  std_logic;                              -- Scaler New Line Request
      SCALER_LIN_NO  => SCALER_LIN_NO , --: in  std_logic_vector(LIN_BITS-1 downto 0);  -- Scaler asking memory_to_scaler to send this particular line
      SCALER_PIX_OFF => SCALER_PIX_OFF , --: in  std_logic_vector(PIX_BITS-1 downto 0);  -- Scaler asking memory_to_scaler to start sending data from a particular pixel in the line
      SCALER_REQ_XSIZE=> SCALER_REQ_XSIZE , --: in std_logic_vector(PIX_BITS-1 downto 0);   -- Width of image required by scaler
      SCALER_REQ_YSIZE=> SCALER_REQ_YSIZE, --: in std_logic_vector(LIN_BITS-1 downto 0);   -- Height of image required by scaler
      SCALER_V      =>  SCALER_V, -- : out std_logic;                              -- Scaler New Frame
      SCALER_H      =>  SCALER_H, -- : out std_logic;
      SCALER_DAV    =>  SCALER_DAV, -- : out std_logic;                              -- Scaler New Data
      SCALER_DATA   =>  SCALER_DATA , -- : out std_logic_vector(7 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
      SCALER_EOI    =>  SCALER_EOI,
      SCALER_XSIZE  =>  SCALER_XSIZE, -- : out std_logic_vector( 9 downto 0);          -- Scaler X Size
      SCALER_YSIZE  =>  SCALER_YSIZE , --: out std_logic_vector( 9 downto 0);          -- Scaler Y Size
      SCALER_XCNT   =>  SCALER_XCNT  , --: out std_logic_vector( 9 downto 0);          -- Scaler Pix  Number (start with 0)
      SCALER_YCNT   =>  SCALER_YCNT , --: out std_logic_vector( 9 downto 0);          -- Scaler Line Number (start with 0)
      SCALER_FIFO_EMP=>  SCALER_FIFO_EMP --: out std_logic
--      DMA_ADDR_IMG_OUT => DMA_ADDR_IMG_OUT
    );
  

ENABLE_ZOOM_START   <= ENABLE_ZOOM and video_start;
MUX_RETICLE_POS_YX1 <= BPR_RETICLE_POS_YX when (BPR_DISP_EN = '1') else MUX_RETICLE_POS_YX ; 

 i_zoom_control : entity WORK.zoom_control
generic map ( 
 VIDEO_XSIZE          => VIDEO_XSIZE   ,
 VIDEO_YSIZE          => VIDEO_YSIZE   ,--400,--VIDEO_YSIZE   ,
 PIX_BITS             => 11      ,
 LIN_BITS             => LIN_BITS      ,
 VIDEO_X_OFFSET_PAL   => VIDEO_X_OFFSET_PAL,
 VIDEO_Y_OFFSET_PAL   => VIDEO_Y_OFFSET_PAL,
 VIDEO_X_OFFSET_OLED  => VIDEO_X_OFFSET_OLED,
 VIDEO_Y_OFFSET_OLED  => VIDEO_Y_OFFSET_OLED,
 VIDEO_X_OFFSET_NTSC  => VIDEO_X_OFFSET_NTSC,
 VIDEO_Y_OFFSET_NTSC  => VIDEO_Y_OFFSET_NTSC
)
port map (   
clk               => CLK,--CLK_54MHZ,--CLK                             ,
rst               => RST                             ,
sel_oled_analog_video_out => sel_oled_analog_video_out,
fit_to_screen_en  => latch_fit_to_screen_en          ,
scaling_disable   => latch_mux_scaling_disable,
sight_mode        => MUX_SIGHT_MODE,
zoom_enable       => '1',--ENABLE_ZOOM_LATCH               ,
zoom_mode         => MUX_ZOOM_MODE                   ,
PAL_nNTSC         => PAL_nNTSC                       ,
reticle_pos_x     => MUX_RETICLE_POS_YX1( 10 downto  0),--MUX_RETICLE_POS_X,
reticle_pos_y     => MUX_RETICLE_POS_YX1(21 downto 12),--MUX_RETICLE_POS_Y,
scal_bl_in_x_size => IN_X_SIZE                       ,
scal_bl_in_y_size => IN_Y_SIZE                       ,
scal_bl_in_x_off  => IN_X_OFF                        ,
scal_bl_in_y_off  => IN_Y_OFF                        ,
scal_bl_out_x_size=> OUT_X_SIZE                      ,
scal_bl_out_y_size=> OUT_Y_SIZE                      ,
reticle_pos_x_out => reticle_pos_x_out1,--open              ,
reticle_pos_y_out => reticle_pos_y_out1--open   
);

--reticle_pos_x_out <= reticle_pos_x_out1;
reticle_pos_x_out <= std_logic_Vector(unsigned(reticle_pos_x_out1) + unsigned(RETICLE_OFFSET_RD_DATA(19 downto 12)))                    
                     when (MUX_FIRING_MODE = '1' and MUX_RETICLE_TYPE =x"1" and RETICLE_OFFSET_RD_DATA(20) ='0') else
                     std_logic_Vector(unsigned(reticle_pos_x_out1) - unsigned(RETICLE_OFFSET_RD_DATA(19 downto 12))) 
                     when (MUX_FIRING_MODE = '1' and MUX_RETICLE_TYPE =x"1" and RETICLE_OFFSET_RD_DATA(20) ='1') 
                     else reticle_pos_x_out1; 
reticle_pos_y_out <= std_logic_Vector(unsigned(reticle_pos_y_out1) + unsigned(RETICLE_OFFSET_RD_DATA(30 downto 23)))                    
                     when (MUX_FIRING_MODE = '1' and MUX_RETICLE_TYPE =x"1" and RETICLE_OFFSET_RD_DATA(31) ='0') else
                     std_logic_Vector(unsigned(reticle_pos_y_out1) - unsigned(RETICLE_OFFSET_RD_DATA(30 downto 23))) 
                     when (MUX_FIRING_MODE = '1' and MUX_RETICLE_TYPE =x"1" and RETICLE_OFFSET_RD_DATA(31) ='1') 
                     else reticle_pos_y_out1; 

MUX_IMG_SHIFT_VERT1 <= std_logic_vector(to_unsigned(128,MUX_IMG_SHIFT_VERT1'length)) when sel_oled_analog_video_out ='1' else 
                       std_logic_vector(to_unsigned(128,MUX_IMG_SHIFT_VERT1'length)) when (MUX_SIGHT_MODE /= "01") else
                       MUX_IMG_SHIFT_VERT;

i_IMG_SHIFT_VERT_CONTROLLER : IMG_SHIFT_VERT_CONTROLLER
  generic map( 
   PIX_BITS  => 11,--PIX_BITS,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
   LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image      
   DATA_BITS => 8,
   VIDEO_XSIZE => VIDEO_XSIZE,                  
   VIDEO_YSIZE => VIDEO_YSIZE
   )
 port map(
     CLK                  => CLK,--CLK_54MHZ,---CLK,
     RST                  => RST,
     IMG_SHIFT_VERT       => MUX_IMG_SHIFT_VERT1,--MUX_IMG_SHIFT_VERT,--LATCH_IMG_UP_SHIFT_VERT,
     SCALER_RUN           => SCALER_RUN,
     SCALER_REQ_V         => IMG_SHIFT_REQ_V      ,--BT656_REQ_V    , 
     SCALER_REQ_H         => IMG_SHIFT_REQ_H      ,--BT656_REQ_H    , 
--     SCALER_FIELD         => '0'               ,--BT656_FIELD    , 
     SCALER_LINE_NO       => IMG_SHIFT_LIN_NO    ,--BT656_LINE_NO  , 
     SCALER_REQ_XSIZE     => IMG_SHIFT_REQ_XSIZE  ,--BT656_REQ_XSIZE, 
     SCALER_REQ_YSIZE     => IMG_SHIFT_REQ_YSIZE  ,--BT656_REQ_YSIZE, 
     IN_Y_OFF             => IN_Y_OFF,
     IMG_SHIFT_REQ_V      => SCALER_REQ_V    ,
     IMG_SHIFT_REQ_H      => SCALER_REQ_H    ,
--     IMG_SHIFT_FIELD      => open    ,
     IMG_SHIFT_LINE_NO    => SCALER_LIN_NO  ,
     IMG_SHIFT_REQ_XSIZE  => SCALER_REQ_XSIZE,
     IMG_SHIFT_REQ_YSIZE  => SCALER_REQ_YSIZE, 
     IMG_SHIFT_I_V        => SCALER_V   ,--VIDEO_O_V_RET,
     IMG_SHIFT_I_H        => SCALER_H   ,--VIDEO_O_H_RET,
     IMG_SHIFT_I_DAV      => SCALER_DAV ,--VIDEO_O_DAV_RET,
     IMG_SHIFT_I_DATA     => SCALER_DATA,--VIDEO_O_DATA_RET,
     IMG_SHIFT_I_EOI      => SCALER_EOI ,--VIDEO_O_EOI_RET,
     IMG_SHIFT_I_XSIZE    => SCALER_XSIZE,--STD_LOGIC_VECTOR(to_unsigned(960,11)),--STD_LOGIC_VECTOR(to_unsigned(1152,11)),--STD_LOGIC_VECTOR(to_unsigned(960,11)),--STD_LOGIC_VECTOR(to_unsigned(640,11)),--VIDEO_O_XSIZE_4,--VIDEO_O_XSIZE_RET,
     IMG_SHIFT_I_YSIZE    => SCALER_YSIZE,--STD_LOGIC_VECTOR(to_unsigned(720,10)),--STD_LOGIC_VECTOR(to_unsigned(480,10)),--VIDEO_O_YSIZE_4,--VIDEO_O_YSIZE_RET,
     IMG_SHIFT_O_V        => IMG_SHIFT_O_V     ,   
     IMG_SHIFT_O_H        => IMG_SHIFT_O_H     ,   
     IMG_SHIFT_O_EOI      => IMG_SHIFT_O_EOI   , 
     IMG_SHIFT_O_DAV      => IMG_SHIFT_O_DAV   , 
     IMG_SHIFT_O_DATA     => IMG_SHIFT_O_DATA  ,
     IMG_SHIFT_O_XCNT     => IMG_SHIFT_O_XCNT  ,  
     IMG_SHIFT_O_YCNT     => IMG_SHIFT_O_YCNT    
--     ADD_BORDER_O_XSIZE   => ADD_BORDER_O_XSIZE ,
--     ADD_BORDER_O_YSIZE   => ADD_BORDER_O_YSIZE      
           
     );   


    
  
     i_scaler_bilinear : entity WORK.scaler_bilinear_small
    generic map ( 
      PIX_BITS        => 11     ,
      LIN_BITS        => LIN_BITS     
    )
    port map (   
    CLK               => CLK,--CLK_54MHZ,--CLK          ,
    RST               => RST         ,
    SRC_RUN           => SCALER_RUN         ,
    SRC_REQ_V         => IMG_SHIFT_REQ_V ,--SCALER_REQ_V     ,
    SRC_REQ_H         => IMG_SHIFT_REQ_H ,--SCALER_REQ_H     ,
    SRC_DMA_ADDR_LIN  => IMG_SHIFT_LIN_NO,--SCALER_LIN_NO   ,
    SRC_DMA_ADDR_OFF  => SCALER_PIX_OFF   ,
    SRC_REQ_XSIZE     => IMG_SHIFT_REQ_XSIZE,--SCALER_REQ_XSIZE , 
    SRC_REQ_YSIZE     => IMG_SHIFT_REQ_YSIZE,--SCALER_REQ_YSIZE ,
    SRC_V             => IMG_SHIFT_O_V   ,--SCALER_V           , 
    SRC_DAV           => IMG_SHIFT_O_DAV ,--SCALER_DAV       , 
    SRC_DATA          => IMG_SHIFT_O_DATA,--SCALER_DATA      ,
    SRC_XSIZE         => SCALER_XSIZE,--IMG_SHIFT_O_XSIZE,--SCALER_XSIZE       ,
    SRC_YSIZE         => SCALER_YSIZE,--IMG_SHIFT_O_XSIZE,--SCALER_YSIZE
    SRC_XCNT          => IMG_SHIFT_O_XCNT,--SCALER_XCNT        ,
    SRC_YCNT          => IMG_SHIFT_O_YCNT,--SCALER_YCNT        ,
    SRC_FIFO_EMP      => SCALER_FIFO_EMP    ,
    ZOOM_ENABLE       => '1'                ,--ENABLE_ZOOM_LATCH,--ZOOM_ENABLE        ,
    IN_X_SIZE         => IN_X_SIZE ,--std_logic_Vector(to_unsigned(640,IN_X_SIZE'length)),--IN_X_SIZE          ,
    IN_Y_SIZE         => IN_Y_SIZE ,--std_logic_Vector(to_unsigned(480,IN_Y_SIZE'length)),--IN_Y_SIZE          ,
    IN_X_OFF          => IN_X_OFF  ,--std_logic_Vector(to_unsigned(0,IN_X_OFF'length)   ),--IN_X_OFF           ,
    IN_Y_OFF          => IN_Y_OFF  ,--std_logic_Vector(to_unsigned(0,IN_Y_OFF'length))   ,--IN_Y_OFF           ,
    OUT_X_SIZE        => SCALER_BIL_REQ_XSIZE_MUX,--std_logic_Vector(to_unsigned(800,OUT_X_SIZE'length)),--OUT_X_SIZE         ,
    OUT_Y_SIZE        => SCALER_BIL_REQ_YSIZE_MUX,--std_logic_Vector(to_unsigned(600,OUT_Y_SIZE'length)),--OUT_Y_SIZE         ,
    BT656_REQ_V       => SCALER_BIL_REQ_V_MUX    ,--SCALER_BIL_REQ_V    , --ADD_BORDER_REQ_V    , --BT656_REQ_V       ,
    BT656_REQ_H       => SCALER_BIL_REQ_H_MUX    ,--SCALER_BIL_REQ_H    , --ADD_BORDER_REQ_H    , --BT656_REQ_H       ,
    BT656_FIELD       => '0'                     , --ADD_BORDER_FIELD    , --BT656_FIELD        ,
    BT656_LINE_NO     => SCALER_BIL_LINE_NO_MUX  ,--SCALER_BIL_LINE_NO  , --ADD_BORDER_LINE_NO  ,  -- BT656_LINE_NO     ,
    BT656_REQ_XSIZE   => SCALER_BIL_REQ_XSIZE_MUX,--SCALER_BIL_REQ_XSIZE, --ADD_BORDER_REQ_XSIZE, --BT656_REQ_XSIZE   ,
    BT656_REQ_YSIZE   => SCALER_BIL_REQ_YSIZE_MUX,--SCALER_BIL_REQ_YSIZE, --ADD_BORDER_REQ_YSIZE, --BT656_REQ_YSIZE   ,
    VIDEO_O_V         => SCALER_O_V         ,
    VIDEO_O_H         => SCALER_O_H         ,
    VIDEO_O_DAV       => SCALER_O_DAV       ,
    VIDEO_O_DATA      => SCALER_O_DATA      ,
    VIDEO_O_EOI       => SCALER_O_EOI       ,
    VIDEO_O_XSIZE     => SCALER_O_XSIZE     ,
    VIDEO_O_YSIZE     => SCALER_O_YSIZE     
    );

SCALER_BIL_REQ_V_MUX      <=  ADD_BORDER_REQ_V     when latch_fit_to_screen_en = '0' else SCALER_BIL_REQ_V;   
SCALER_BIL_REQ_H_MUX      <=  ADD_BORDER_REQ_H     when latch_fit_to_screen_en = '0' else SCALER_BIL_REQ_H ;              
SCALER_BIL_LINE_NO_MUX    <=  ADD_BORDER_LINE_NO   when latch_fit_to_screen_en = '0' else SCALER_BIL_LINE_NO;
SCALER_BIL_REQ_XSIZE_MUX  <=  ADD_BORDER_REQ_XSIZE when latch_fit_to_screen_en = '0' else SCALER_BIL_REQ_XSIZE ;
SCALER_BIL_REQ_YSIZE_MUX  <=  ADD_BORDER_REQ_YSIZE when latch_fit_to_screen_en = '0' else SCALER_BIL_REQ_YSIZE ;

  
  --process(CLK, RST)
  --begin
  --    if RST = '1' then
  --       ZOOM_ENABLE_D <= '0'; 
  --       --RETICLE_EN_D <= '0';
  --    elsif rising_edge(CLK) then  
  --      -- if BT656_REQ_V = '1' then
  --        if ADD_BORDER_REQ_V = '1' then
  --            --ZOOM_ENABLE_D <= ZOOM_ENABLE;
  --            ZOOM_ENABLE_D <= ZOOM_ENABLE_LATCH;
  --           -- RETICLE_EN_D <= RETICLE_EN  and ZOOM_ENABLE_D;
  --       end if;      
  --    end if;  
  --end process;

    
 
                                                                
-- MUX_CP_ENABLE <= (MUX_CP_TYPE(0) or MUX_CP_TYPE(1) or MUX_CP_TYPE(2) or MUX_CP_TYPE(3) or MUX_CP_TYPE(4)) and video_start;   
--color_palette:entity work.ColorPalette3
--    generic map(
--        PIX_BITS => 11,
--        LIN_BITS => LIN_BITS
--      )
    
--    port map(
    
      
--      CLK       => CLK,--CLK_54MHZ,--CLK,
--      RST       => RST,
    
--      --Enable
--      ENABLE    => MUX_CP_ENABLE,
--      PALETTE_SELECT      => MUX_CP_TYPE,
--      min_value  => cp_min_value,
--      max_value  => cp_max_value,
    
--      --ENABLE_LUT    => ENABLE_LUT,
--      --LUT_MODE      => LUT_MODE,
--      --Input from AGC block
--      VIDEO_I_V     =>  SCALER_O_V       ,  --VIDEO_O_V_BC     ,--VIDEO_O_V_P     ,    --VIDEO_O_V_BC     ,            
--      VIDEO_I_H     =>  SCALER_O_H       ,  --VIDEO_O_H_BC     ,--VIDEO_O_H_P     ,    --VIDEO_O_H_BC     ,           
--      VIDEO_I_EOI   =>  SCALER_O_EOI     ,   --VIDEO_O_EOI_BC   ,--VIDEO_O_EOI_P   ,    --VIDEO_O_EOI_BC   ,
--      VIDEO_I_DAV   =>  SCALER_O_DAV     ,  --VIDEO_O_DAV_BC   ,--VIDEO_O_DAV_P   ,    --VIDEO_O_DAV_BC   ,          
--      VIDEO_I_DATA  =>  SCALER_O_DATA    ,  --VIDEO_O_DATA_BC  ,--VIDEO_O_DATA_P  ,    --VIDEO_O_DATA_BC  ,
--      VIDEO_I_XSIZE =>  SCALER_O_XSIZE   ,  --VIDEO_O_XSIZE_BC ,--VIDEO_O_XSIZE_P ,    --VIDEO_O_XSIZE_BC ,
--      VIDEO_I_YSIZE =>  SCALER_O_YSIZE   ,  --VIDEO_O_YSIZE_BC ,--VIDEO_O_YSIZE_P ,    --VIDEO_O_YSIZE_BC ,
    
--      -- Output to ColorConverter block
--      VIDEO_O_V     => VIDEO_O_V_CP     ,
--      VIDEO_O_H     => VIDEO_O_H_CP     ,
--      VIDEO_O_EOI   => VIDEO_O_EOI_CP   ,
--      VIDEO_O_DAV   => VIDEO_O_DAV_CP   ,
--      VIDEO_O_DATA  => VIDEO_O_DATA_CP  ,
--      VIDEO_O_XSIZE => VIDEO_O_XSIZE_CP ,
--      VIDEO_O_YSIZE => VIDEO_O_YSIZE_CP    
--      );
      
      
      
--    RGB_2_YCBCR : entity work.rgb2ycbcr 
--    generic map(
--      bit_width => 23,               -- Actually (bit_width - 1)
--      VIDEO_XSIZE  => 960,--800,
--      VIDEO_YSIZE => 720 --600
--      )
    
--    port map(
--      CLK       => CLK,--CLK_54MHZ,--CLK,
--      RST       => RST,
    
--      --Input from Bad Pixel Removal block
--      VIDEO_I_V     =>VIDEO_O_V_CP     ,
--      VIDEO_I_H     =>VIDEO_O_H_CP     ,
--      VIDEO_I_EOI   =>VIDEO_O_EOI_CP   ,
--      VIDEO_I_DAV   =>VIDEO_O_DAV_CP   ,
--      VIDEO_I_DATA  =>VIDEO_O_DATA_CP  ,
--      VIDEO_I_XSIZE =>VIDEO_O_XSIZE_CP ,
--      VIDEO_I_YSIZE =>VIDEO_O_YSIZE_CP ,
--      --VIDEO_I_XCNT  =>VIDEO_O_XCNT_CP  ,
--      --VIDEO_I_YCNT  =>VIDEO_O_YCNT_CP,  
                      
--      -- Output to AGC block
--      VIDEO_O_V     =>VIDEO_O_V_4     ,
--      VIDEO_O_H     =>VIDEO_O_H_4     ,
--      VIDEO_O_EOI   =>VIDEO_O_EOI_4   ,
--      VIDEO_O_DAV   =>VIDEO_O_DAV_4   ,
--      VIDEO_O_DATA  =>VIDEO_O_DATA_4  ,
--      VIDEO_O_XSIZE =>VIDEO_O_XSIZE_4 ,
--      VIDEO_O_YSIZE =>VIDEO_O_YSIZE_4 
--      --VIDEO_O_XCNT  =>VIDEO_O_XCNT_4  ,
--      --VIDEO_O_YCNT  =>VIDEO_O_YCNT_4  
--      );
        

VIDEO_O_V_4       <= SCALER_O_V     ;
VIDEO_O_H_4       <= SCALER_O_H     ;
VIDEO_O_EOI_4     <= SCALER_O_EOI   ;
VIDEO_O_DAV_4     <= SCALER_O_DAV   ;
VIDEO_O_DATA_4    <= SCALER_O_DATA  ;
VIDEO_O_XSIZE_4   <= SCALER_O_XSIZE ;
VIDEO_O_YSIZE_4   <= SCALER_O_YSIZE ;
  
  
  
  process(CLK, RST)
--process(CLK_54MHZ, RST)
  begin
      if RST = '1' then
         RETICLE_DIS_DONE <= '0';
         OSD_DIS_DONE <= '0';
      elsif rising_edge(CLK) then   
--      elsif rising_edge(CLK_54MHZ) then  
          if ADD_BORDER_REQ_V = '1' and ADD_BORDER_FIELD = '0' then
              RETICLE_DIS_DONE  <= '1';  
              OSD_DIS_DONE      <= '1';
          elsif DMA_NUC1PT_MUX = '1'then
              RETICLE_DIS_DONE  <= '0';
              OSD_DIS_DONE      <= '0';
          end if;      
      end if;  
  end process;
  

  ENABLE_RETICLE_D  <= ENABLE_RETICLE_LATCH and (not RETICLE_DIS);
--  RETICLE_IMG_XSIZE <= STD_LOGIC_VECTOR(unsigned(RETICLE_W)/16);-- RETICLE INFO 2 bit per Pixel  bit(1):Reticle output Present, bit(0):Color of Reticle
--  RETICLE_IMG_YSIZE <= STD_LOGIC_VECTOR(unsigned(RETICLE_H));
  RETICLE_IMG_XSIZE <=STD_LOGIC_VECTOR(to_unsigned(RETICLE_W/16,RETICLE_IMG_XSIZE'length)); 
  RETICLE_IMG_YSIZE <=STD_LOGIC_VECTOR(to_unsigned(RETICLE_H,RETICLE_IMG_YSIZE'length)); 
  --SCALER_O_DATA1 <= SCALER_O_DATA & x"80" & x"80";
--  VIDEO_O_DATA_BC1 <= VIDEO_O_DATA_BC & x"80" & x"80";
  
  
  


DMA_R3_RDREQ_s      <= coarse_read;--'0';
DMA_R3_RDADDR_s     <= coarse_address;--(others=>'0');
DMA_R3_RDSIZE_s     <= coarse_size;
coarse_waitrequest  <= not DMA_R3_RDREADY_s;
coarse_readdatavalid<= DMA_R3_RDDAV_s;       
coarse_readdata     <= DMA_R3_RDDATA_s;      

DMA_R5_RDREQ_s      <= '0';
DMA_R5_RDADDR_s     <= (others=>'0');
DMA_R5_RDSIZE_s     <= (others=>'0');


  i_AVALON_ARBITER4_NEW : entity WORK.AVALON_ARBITER4_NEW 
  generic map (
     ADDR_WIDTH  =>  DMA_ADDR_BITS,
     DATA_WIDTH  =>  DMA_DATA_BITS,
     BURST_WIDTH =>  DMA_SIZE_BITS 
  )
  
  port map(
    SEL_OLED_ANALOG_VIDEO_OUT => sel_oled_analog_video_out,
    --  General Inputs
    DMA_W0_CLK     => CLK,--CLK_27MHZ,     --: in  std_logic;                                    -- DMA Clock (half rate)
    DMA_W0_RST     => RST,     --: in  std_logic;                                    -- DMA Asynchronous Reset Active High
    -- Avalon-MM Master 0 - Write Only
    DMA_W0_READY   => DMA_W0_WRREADY_s ,     --: out std_logic;                                    -- DMA0 Ready
    DMA_W0_WRITE   => DMA_W0_WRREQ_s,     --: in  std_logic;                                    -- DMA0 Write   Request
    DMA_W0_WRBURST => DMA_W0_WRBURST_s,     --: in  std_logic;                                    -- DMA0 Write   Request Start of Burst
    DMA_W0_ADDR    => DMA_W0_WRADDR_s ,     --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA0 Address Request
    DMA_W0_SIZE    => DMA_W0_WRSIZE_s,     --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA0 Size    Request
    DMA_W0_WRDATA  => DMA_W0_WRDATA_s,     --: in  std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA0 Write Data
--    DMA_W0_ADDR_DEC=> DMA_W0_ADDR_DEC_s,  -- in   std_logic;                                     -- DMA ADDRESS DECREMENT
    DMA_W0_WRBE    => DMA_W0_WRBE_s,     --: in  std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA0 Write Byte Enable
    -- Avalon-MM Master 1 - Write Only
    DMA_W1_CLK     => CLK,
    DMA_W1_RST     => RST,
    DMA_W1_READY   => DMA_W1_WRREADY_s ,       --: out std_logic;                                    -- DMA1 Ready
    DMA_W1_WRITE   => DMA_W1_WRREQ_s,          --: in  std_logic;                                    -- DMA1 Write   Request
    DMA_W1_WRBURST => DMA_W1_WRBURST_s,        --: in  std_logic;                                    -- DMA1 Write   Request Start of Burst
    DMA_W1_ADDR    => DMA_W1_WRADDR_s ,        --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA1 Address Request
    DMA_W1_SIZE    => DMA_W1_WRSIZE_s,         --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA1 Size    Request
    DMA_W1_WRDATA  => DMA_W1_WRDATA_s,         --: in  std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA1 Write Data
    DMA_W1_WRBE    => DMA_W1_WRBE_s,           --: in  std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA1 Write Byte Enable
    
    DMA_W2_CLK     => CLK,
    DMA_W2_RST     => RST,
    DMA_W2_READY   => DMA_W2_WRREADY_s ,   --: out std_logic;                                    -- DMA1 Ready
    DMA_W2_WRITE   => DMA_W2_WRREQ_s,      --: in  std_logic;                                    -- DMA1 Write   Request
    DMA_W2_WRBURST => DMA_W2_WRBURST_s,    --: in  std_logic;                                    -- DMA1 Write   Request Start of Burst
    DMA_W2_ADDR    => DMA_W2_WRADDR_s ,      --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA1 Address Request
    DMA_W2_SIZE    => DMA_W2_WRSIZE_s,       --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA1 Size    Request
    DMA_W2_WRDATA  => DMA_W2_WRDATA_s,       --: in  std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA1 Write Data
    DMA_W2_WRBE    => DMA_W2_WRBE_s,         --: in  std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA1 Write Byte Enable
    -- Avalon-MM Master 2 - Read Only
    DMA_R0_CLK     => CLK,
    DMA_R0_RST     => RST,
    DMA_R0_READY   => DMA_R0_RDREADY_s,     --: out std_logic;                                    -- DMA2 Ready
    DMA_R0_READ    => DMA_R0_RDREQ_s,     --: in  std_logic;                                    -- DMA2 Read    Request
    DMA_R0_ADDR    => DMA_R0_RDADDR_s,     --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA2 Address Request
    DMA_R0_SIZE    => DMA_R0_RDSIZE_s,     --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA2 Size    Request
    DMA_R0_RDDAV   => DMA_R0_RDDAV_s,     --: out std_logic;                                    -- DMA2 Read Data Valid
    DMA_R0_RDDATA  => DMA_R0_RDDATA_s,     --: out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA2 Read Data
    -- Avalon-MM Master 3 - Read Only
    DMA_R1_CLK     => CLK,
    DMA_R1_RST     => RST,
    DMA_R1_READY   => DMA_R1_RDREADY_s,     --: out std_logic;                                    -- DMA3 Ready
    DMA_R1_READ    => DMA_R1_RDREQ_s,     --: in  std_logic;                                    -- DMA3 Read    Request
    DMA_R1_ADDR    => DMA_R1_RDADDR_s,     --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA3 Address Request
    DMA_R1_SIZE    => DMA_R1_RDSIZE_s,     --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA3 Size    Request
    DMA_R1_RDDAV   => DMA_R1_RDDAV_s,     --: out std_logic;                                    -- DMA3 Read Data Valid
    DMA_R1_RDDATA  => DMA_R1_RDDATA_s,     --: out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA3 Read Data
    
    DMA_R2_CLK     => CLK,
    DMA_R2_RST     => RST,
    DMA_R2_READY   => DMA_R2_RDREADY_s,      --: out std_logic;                                    -- DMA3 Ready
    DMA_R2_READ    => DMA_R2_RDREQ_s,      --: in  std_logic;                                    -- DMA3 Read    Request
    DMA_R2_ADDR    => DMA_R2_RDADDR_s,      --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA3 Address Request
    DMA_R2_SIZE    => DMA_R2_RDSIZE_s,      --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA3 Size    Request
    DMA_R2_RDDAV   => DMA_R2_RDDAV_s,      --: out std_logic;                                    -- DMA3 Read Data Valid
    DMA_R2_RDDATA  => DMA_R2_RDDATA_s,      --: out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA3 Read Data
    
    DMA_R3_CLK     => CLK,
    DMA_R3_RST     => RST,
    DMA_R3_READY   => DMA_R3_RDREADY_s, --DMA_R3_RDREADY_s,      --: out std_logic;                                    -- DMA3 Ready
    DMA_R3_READ    => DMA_R3_RDREQ_s,   --DMA_R3_RDREQ_s,      --: in  std_logic;                                    -- DMA3 Read    Request
    DMA_R3_ADDR    => DMA_R3_RDADDR_s,   --DMA_R3_RDADDR_s,      --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA3 Address Request
    DMA_R3_SIZE    => DMA_R3_RDSIZE_s,   --DMA_R3_RDSIZE_s,      --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA3 Size    Request
    DMA_R3_RDDAV   => DMA_R3_RDDAV_s,    --DMA_R3_RDDAV_s,      --: out std_logic;                                    -- DMA3 Read Data Valid
    DMA_R3_RDDATA  => DMA_R3_RDDATA_s,   --DMA_R3_RDDATA_s,      --: out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA3 Read Data

    DMA_R4_CLK     => CLK,
    DMA_R4_RST     => RST,
    DMA_R4_READY   => DMA_R4_RDREADY_s,     --: out std_logic;                                    -- DMA3 Ready
    DMA_R4_READ    => DMA_R4_RDREQ_s,     --: in  std_logic;                                    -- DMA3 Read    Request
    DMA_R4_ADDR    => DMA_R4_RDADDR_s,     --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA3 Address Request
    DMA_R4_SIZE    => DMA_R4_RDSIZE_s,     --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA3 Size    Request
    DMA_R4_RDDAV   => DMA_R4_RDDAV_s,     --: out std_logic;                                    -- DMA3 Read Data Valid
    DMA_R4_RDDATA  => DMA_R4_RDDATA_s,     --: out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA3 Read Data
    
    DMA_R5_CLK     => CLK,
    DMA_R5_RST     => RST,
    DMA_R5_READY   => DMA_R5_RDREADY_s,     --: out std_logic;                                    -- DMA3 Ready
    DMA_R5_READ    => DMA_R5_RDREQ_s,     --: in  std_logic;                                    -- DMA3 Read    Request
    DMA_R5_ADDR    => DMA_R5_RDADDR_s,     --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA3 Address Request
    DMA_R5_SIZE    => DMA_R5_RDSIZE_s,     --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA3 Size    Request
    DMA_R5_RDDAV   => DMA_R5_RDDAV_s,     --: out std_logic;                                    -- DMA3 Read Data Valid
    DMA_R5_RDDATA  => DMA_R5_RDDATA_s,     --: out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA3 Read Data
    
    DMA_RW6_CLK     => CLK,
    DMA_RW6_RST     => RST,
    DMA_RW6_READY   => DMA_RW6_READY_s,     --: out std_logic;                                    -- DMA3 Ready
    DMA_RW6_READ    => DMA_RW6_RDREQ_s,     --: in  std_logic;                                    -- DMA3 Read    Request
    DMA_RW6_WRITE   => DMA_RW6_WRREQ_s,
    DMA_RW6_WRBURST => DMA_RW6_WRBURST_s,
    DMA_RW6_WRBE    => DMA_RW6_WRBE_s,
    DMA_RW6_WRDATA  => DMA_RW6_WRDATA_s,
    DMA_RW6_ADDR    => DMA_RW6_ADDR_s,     --: in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA3 Address Request
    DMA_RW6_SIZE    => DMA_RW6_SIZE_s,     --: in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA3 Size    Request
    DMA_RW6_RDDAV   => DMA_RW6_RDDAV_s,     --: out std_logic;                                    -- DMA3 Read Data Valid
    DMA_RW6_RDDATA  => DMA_RW6_RDDATA_s,     --: out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA3 Read Data
    
        
    -- Avalon-MM Arbiter Output
    DMA_CLK      => CLK_100MHZ, 
    DMA_RST      => RST,
    DMA_WRITE    => DMA_WRITE,     --: out std_logic;                                    -- DMA  Write   Request
    DMA_WRBURST  => DMA_WRBURST,     --: out std_logic;                                    -- DMA  Write   Request Start of Burst
    DMA_READ     => DMA_READ,     --: out std_logic;                                    -- DMA  Read    Request
    DMA_ADDR     => DMA_ADDR,     --: out std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA  Address Request
    DMA_SIZE     => DMA_SIZE,     --: out std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA  Size    Request
    DMA_WRDATA   => DMA_WRDATA,     --: out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA  Write Data
--    DMA_ADDR_DEC => DMA_ADDR_DEC,   -- out std_logic;                                     -- DMA ADDRESS DECREMENT
    DMA_WRBE     => DMA_WRBE,     --: out std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA  Write Byte Enable
    DMA_READY    => DMA_READY,     --: in  std_logic;                                    -- DMA  Ready
    DMA_RDDAV    => DMA_RDDAV,     --: in  std_logic;                                    -- DMA  Read Data Valid
    DMA_RDDATA   => DMA_RDDATA     --: in  std_logic_vector( DATA_WIDTH  -1 downto 0)    -- DMA  Read Data

  );

DMA_READY <= not DMA_BUSY;
SDRAM_RSTN <= not RST;
-------------------------------------
i_sdram_top_av : sdram_top_av
generic map(    AV_FREQ => SDRAM_FREQ,
                SDRAM_FREQ => SDRAM_FREQ,
                APP_AW   => 32, -- // Application Address Width
                APP_AW_VALID => 26,-- // Application Valid Address Width 26bits for 512Mb SDRAM
                APP_DW   => 32,  --// Application Data Width 
                APP_BW   => 4,  -- // Application Byte Width
                APP_RW   => DMA_SIZE_BITS,   --// Application Request Width
                SDR_DW   => 32,  --// SDR Data Width 
                SDR_BW   => 4   --// SDR Byte Width
               
)
port map(   
           av_rst_i          =>  RST         ,
           av_clk_i          => CLK_100MHZ,

           av_busy_o         => DMA_BUSY        ,
           av_addr_i         => DMA_ADDR        ,
           av_size_i         => DMA_SIZE         ,
           av_wr_i           => DMA_WRITE         ,
           av_wrburst_i      => DMA_WRBURST        ,
           av_data_i         => DMA_WRDATA       ,
--           av_addr_dec       => DMA_ADDR_DEC,
           av_byteenable_i   => DMA_WRBE         ,
           av_rd_i           => DMA_READ         ,
           av_data_o         => DMA_RDDATA          ,
           av_rddav_o        => DMA_RDDAV         ,

           sdram_init_done   => sdram_init_done  ,

           sdram_clk     =>  CLK_100MHZ,
           sdram_resetn  =>  SDRAM_RSTN     ,
           sdr_cs_n      => FPGA_SDRAM_CS_N,
           sdr_cke       => FPGA_SDRAM_CKE,
           sdr_ras_n     => FPGA_SDRAM_RAS_N,
           sdr_cas_n     => FPGA_SDRAM_CAS_N,
           sdr_we_n      => FPGA_SDRAM_WE_N,
           sdr_dqm       => FPGA_SDRAM_DQM,
           sdr_ba        => FPGA_SDRAM_BA_s,
           sdr_addr      => FPGA_SDRAM_A_s, 
           sdr_dq        => FPGA_SDRAM_D      
);       
FPGA_SDRAM_A(13)<= '0';
FPGA_SDRAM_BA <= FPGA_SDRAM_BA_s;
FPGA_SDRAM_A(12 downto 0)<= FPGA_SDRAM_A_s; 



MUX_BT656_REQ_V       <= BT656_REQ_V     when sel_oled_analog_video_out ='1' else SCALER_BIL_REQ_V;
MUX_BT656_REQ_H       <= BT656_REQ_H     when sel_oled_analog_video_out ='1' else SCALER_BIL_REQ_H;
MUX_BT656_REQ_LINE_NO <= BT656_LINE_NO   when sel_oled_analog_video_out ='1' else SCALER_BIL_LINE_NO;
MUX_BT656_REQ_XSIZE   <= BT656_REQ_XSIZE when sel_oled_analog_video_out ='1' else SCALER_BIL_REQ_XSIZE;
MUX_BT656_REQ_YSIZE   <= BT656_REQ_YSIZE when sel_oled_analog_video_out ='1' else SCALER_BIL_REQ_YSIZE;
MUX_ADD_BORDER_I_XSIZE<= BT656_ADD_BORDER_I_XSIZE when sel_oled_analog_video_out ='1' else ADD_BORDER_I_XSIZE;
MUX_ADD_BORDER_I_YSIZE<= BT656_ADD_BORDER_I_YSIZE when sel_oled_analog_video_out ='1' else ADD_BORDER_I_YSIZE;

i_Add_Border : Add_Border
  generic map( 
   PIX_BITS  => 11,--PIX_BITS,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
   LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image      
   DATA_BITS => 8,--24,
   VIDEO_XSIZE         => 960,--800,--720,--960,--1152,--960,--VIDEO_XSIZE                  
   VIDEO_YSIZE         => 720--600--576 --720 --VIDEO_YSIZE
   )
 port map(
     CLK => CLK,--CLK_54MHZ,---CLK,
     RST => RST,
     SCALER_RUN => SCALER_RUN,
     ZOOM_ENABLE => ENABLE_ZOOM_START,
     ZOOM_ENABLE_LATCH => ENABLE_ZOOM_LATCH, --out
     fit_to_screen_en     => latch_fit_to_screen_en,
     RETICLE_ENABLE       => MUX_RETICLE_ENABLE1,
     RETICLE_ENABLE_LATCH => ENABLE_RETICLE_LATCH, --out     
     OSD_ENABLE           => ENABLE_OSD,
     OSD_ENABLE_LATCH     => ENABLE_OSD_LATCH,
     CROP_START           => video_start,
     IMG_CROP_LEFT        => (others=> '0'),--IMG_CROP_LEFT  ,   
     IMG_CROP_RIGHT       => (others=> '0'),--IMG_CROP_RIGHT ,  
     IMG_CROP_TOP         => (others=> '0'),--IMG_CROP_TOP   ,    
     IMG_CROP_BOTTOM      => (others=> '0'),--IMG_CROP_BOTTOM,        
--     IMG_SHIFT_LR_UPDATE  => IMG_SHIFT_LR_UPDATE,
--     IMG_SHIFT_LR_SEL     => IMG_SHIFT_LR_SEL,
--     IMG_SHIFT_LR         => IMG_SHIFT_LR,
--     IMG_SHIFT_UD_UPDATE  => IMG_SHIFT_UD_UPDATE,
--     IMG_SHIFT_UD_SEL     => IMG_SHIFT_UD_SEL,
--     IMG_SHIFT_UD         => IMG_SHIFT_UD, 
     BT656_REQ_V          => MUX_BT656_REQ_V,--SCALER_BIL_REQ_V    ,--BT656_REQ_V    , 
     BT656_REQ_H          => MUX_BT656_REQ_H,-- SCALER_BIL_REQ_H    ,--BT656_REQ_H    , 
     BT656_FIELD          => '0'                 ,--BT656_FIELD    , 
     BT656_LINE_NO        => MUX_BT656_REQ_LINE_NO,-- SCALER_BIL_LINE_NO  ,--BT656_LINE_NO  , 
     BT656_REQ_XSIZE      => MUX_BT656_REQ_XSIZE,-- SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE, 
     BT656_REQ_YSIZE      => MUX_BT656_REQ_YSIZE,-- SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE, 
     ADD_BORDER_REQ_V     => ADD_BORDER_REQ_V,
     ADD_BORDER_REQ_H     => ADD_BORDER_REQ_H,
     ADD_BORDER_FIELD     => ADD_BORDER_FIELD,
     ADD_BORDER_LINE_NO   => ADD_BORDER_LINE_NO,
     ADD_BORDER_REQ_XSIZE => ADD_BORDER_REQ_XSIZE,
     ADD_BORDER_REQ_YSIZE => ADD_BORDER_REQ_YSIZE, 
     ADD_BORDER_I_V       => VIDEO_O_V_4    ,--VIDEO_O_V_RET,
     ADD_BORDER_I_H       => VIDEO_O_H_4    ,--VIDEO_O_H_RET,
     ADD_BORDER_I_DAV     => VIDEO_O_DAV_4  ,--VIDEO_O_DAV_RET,
     ADD_BORDER_I_DATA    => VIDEO_O_DATA_4 ,--VIDEO_O_DATA_RET,
     ADD_BORDER_I_EOI     => VIDEO_O_EOI_4  ,--VIDEO_O_EOI_RET,
     ADD_BORDER_I_XSIZE   => MUX_ADD_BORDER_I_XSIZE,--STD_LOGIC_VECTOR(to_unsigned(960,11)),--STD_LOGIC_VECTOR(to_unsigned(1152,11)),--STD_LOGIC_VECTOR(to_unsigned(960,11)),--STD_LOGIC_VECTOR(to_unsigned(640,11)),--VIDEO_O_XSIZE_4,--VIDEO_O_XSIZE_RET,
     ADD_BORDER_I_YSIZE   => MUX_ADD_BORDER_I_YSIZE,--STD_LOGIC_VECTOR(to_unsigned(720,10)),--STD_LOGIC_VECTOR(to_unsigned(480,10)),--VIDEO_O_YSIZE_4,--VIDEO_O_YSIZE_RET,
     RETICLE_OFFSET_X     => RETICLE_OFFSET_X,--open,
     RETICLE_OFFSET_Y     => RETICLE_OFFSET_Y, 
--     IMG_SHIFT_POS_X      => IMG_SHIFT_POS_X,
--     IMG_SHIFT_POS_Y      => IMG_SHIFT_POS_Y,
     ADD_BORDER_O_V       => ADD_BORDER_O_V     ,   
     ADD_BORDER_O_H       => ADD_BORDER_O_H     ,   
     ADD_BORDER_O_EOI     => ADD_BORDER_O_EOI   , 
     ADD_BORDER_O_DAV     => ADD_BORDER_O_DAV   , 
     ADD_BORDER_O_DATA    => ADD_BORDER_O_DATA     
--     ADD_BORDER_O_XSIZE   => ADD_BORDER_O_XSIZE ,
--     ADD_BORDER_O_YSIZE   => ADD_BORDER_O_YSIZE      
           
     );   

osd_gen: if(OLED_EN = TRUE)generate

ADD_BORDER_O_V_MUX    <=  ADD_BORDER_O_V    when latch_fit_to_screen_en = '0' else VIDEO_O_V_4   ;
ADD_BORDER_O_H_MUX    <=  ADD_BORDER_O_H    when latch_fit_to_screen_en = '0' else VIDEO_O_H_4   ;
ADD_BORDER_O_DAV_MUX  <=  ADD_BORDER_O_DAV  when latch_fit_to_screen_en = '0' else VIDEO_O_DAV_4 ;
ADD_BORDER_O_DATA_MUX <=  ADD_BORDER_O_DATA when latch_fit_to_screen_en = '0' else VIDEO_O_DATA_4;
ADD_BORDER_O_EOI_MUX  <=  ADD_BORDER_O_EOI  when latch_fit_to_screen_en = '0' else VIDEO_O_EOI_4 ;

LOGO_ENABLE_START <=  (MUX_ENABLE_LOGO or MUX_LASER_EN) and video_start ;
LOGO_IMG_XSIZE <= STD_LOGIC_VECTOR(to_unsigned(LOGO_W,LOGO_IMG_XSIZE'length));  -- LOGO INFO 2 bit per Pixel  bit(1):LOGO output Present, bit(0):Color of LOGO
LOGO_IMG_YSIZE <= STD_LOGIC_VECTOR(to_unsigned(LOGO_H,LOGO_IMG_YSIZE'length));


 i_ADD_LOGO :entity WORK.ADD_LOGO    
 generic map(                                                 
   PIX_BITS  => 11,--: positive;                 
   LIN_BITS  => LIN_BITS,--: positive;  
   LOGO_INIT_MEMORY_WR_SIZE =>  ((integer(LOGO_W)*integer(LOGO_H))/8)             
 )                                                     
 port map (                                            
   -- Clock and Reset                                  
   CLK                        => CLK,--CLK_27MHZ    , --: in  std_log
   RST                        => RST, --qspi_init_cmd_done_n  , --: i
--   video_start                => video_start,
--   qspi_reticle_transfer_done => qspi_reticle_transfer_done,
--   qspi_reticle_transfer_rq   => qspi_reticle_transfer_rq,
--   logo_sel                => logo_sel,
   LOGO_WR_EN_IN           => LOGO_WR_EN,
   LOGO_WR_DATA_IN         => LOGO_WR_DATA,
   LOGO_EN                 => LOGO_ENABLE_START, 
--   LOGO_TYPE               => MUX_LOGO_TYPE,                      
   LOGO_COLOR_INFO1        => LOGO_COLOR_INFO1(23 downto 16),         
   LOGO_COLOR_INFO2        => LOGO_COLOR_INFO2(23 downto 16),         
   LOGO_POS_X              => LOGO_POS_X,
   LOGO_POS_Y              => LOGO_POS_Y,            
--   MEM_IMG_XSIZE           => LOGO_IMG_XSIZE,
--   MEM_IMG_YSIZE           => LOGO_IMG_YSIZE,
  
   LOGO_REQ_V              => MUX_BT656_REQ_V,--SCALER_BIL_REQ_V,--BT656_REQ_V  ,
   LOGO_REQ_H              => MUX_BT656_REQ_H,--SCALER_BIL_REQ_H,--BT656_REQ_H  ,
   LOGO_FIELD              => '0',             --BT656_FIELD  ,
   LOGO_REQ_XSIZE          => LOGO_IMG_XSIZE,
   LOGO_REQ_YSIZE          => LOGO_IMG_YSIZE,
                                                       
   VIDEO_IN_V              => ADD_BORDER_O_V_MUX    ,--VIDEO_O_V_4    ,--ADD_BORDER_O_V     , 
   VIDEO_IN_H              => ADD_BORDER_O_H_MUX    ,--VIDEO_O_H_4    ,--ADD_BORDER_O_H     , 
   VIDEO_IN_DAV            => ADD_BORDER_O_DAV_MUX  ,--VIDEO_O_DAV_4  ,--ADD_BORDER_O_DAV   , 
   VIDEO_IN_DATA           => ADD_BORDER_O_DATA_MUX ,--VIDEO_O_DATA_4 ,--ADD_BORDER_O_DATA  ,
   VIDEO_IN_EOI            => ADD_BORDER_O_EOI_MUX  ,--VIDEO_O_EOI_4  ,--ADD_BORDER_O_EOI   , 
   VIDEO_IN_XSIZE          => MUX_BT656_REQ_XSIZE   ,--SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE    , 
   VIDEO_IN_YSIZE          => MUX_BT656_REQ_YSIZE   ,--SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE    , 
                                                                                                       
   LOGO_V                  => ADD_LOGO_O_V    ,
   LOGO_H                  => ADD_LOGO_O_H    ,
   LOGO_DAV                => ADD_LOGO_O_DAV  ,
   LOGO_DATA               => ADD_LOGO_O_DATA ,
   LOGO_EOI                => ADD_LOGO_O_EOI   
--   LOGO_POS_X_OUT          => LOGO_POS_X_SET,             
--   LOGO_POS_Y_OUT          => LOGO_POS_Y_SET            
 );                                      
               

ENABLE_OSD_LATCH1        <= ENABLE_OSD_LATCH and (not OSD_DIS);
--MUX_ADVANCE_MENU_TRIG_IN <= (not OSD_EN_OUT) and  (ADVANCE_MENU_TRIG_IN or ADVANCE_MENU_TRIG_IN_REG);



i_OSD :entity WORK.OSD                                                                                             
 generic map(                                                                                                                                   
 PIX_BITS  => 11,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line                                   
 LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image                                 
 CH_ROM_ADDR_WIDTH => 11,
 CH_ROM_DATA_WIDTH => 16,
 CH_PER_BYTE       => 1
 )                                                                                                                                              
 port map (                                                                                                                                     
   -- Clock and Reset                                                                                                                           
   CLK               => CLK,--CLK_27MHZ    , --: in  std_logic;                              -- Module Clock                                         
   RST               => RST, --qspi_init_cmd_done_n  , --: in  std_logic;                              -- Module Reset (Asynchronous active high)    
   tick1ms           => TICK1MS,
   burst_capture_size => burst_capture_size,
   snapshot_save_done => gallery_img_valid_save_done,--snapshot_save_done,
   snapshot_delete_done => gallery_img_valid_save_done,--snapshot_delete_done,
   gyro_calib_done    => GYRO_SOFT_CALIB_DONE,
   OSD_TIMEOUT       => OSD_TIMEOUT,                                                                                                                                                                                                       
   OSD_COLOR_INFO1   => OSD_COLOR_INFO(23 downto 16), 
   CH_COLOR_INFO1    => OSD_CH_COLOR_INFO1(23 downto 16),                                                                                                 
   CH_COLOR_INFO2    => OSD_CH_COLOR_INFO2(23 downto 16),
   CURSOR_COLOR_INFO => CURSOR_COLOR_INFO(23 downto 16),                                                                                               
   OSD_POS_X_LY1     => OSD_POS_X_LY1,--OSD_POS_X_LY1_MODE1,                                                                                                        
   OSD_POS_Y_LY1     => OSD_POS_Y_LY1,--OSD_POS_Y_LY1_MODE1,  
   OSD_POS_X_LY2     => OSD_POS_X_LY2,--OSD_POS_X_LY2_MODE1,                                                                                                        
   OSD_POS_Y_LY2     => OSD_POS_Y_LY2,--OSD_POS_Y_LY2_MODE1,  
   OSD_POS_X_LY3     => OSD_POS_X_LY3,--OSD_POS_X_LY3_MODE1,                                                                                                        
   OSD_POS_Y_LY3     => OSD_POS_Y_LY3,--OSD_POS_Y_LY3_MODE1,
   MENU_SEL_CENTER   => MENU_SEL_CENTER,
   MENU_SEL_UP       => MENU_SEL_UP,
   MENU_SEL_DN       => MENU_SEL_DN,  
--   main_menu_sel     => main_menu_sel,
--   ADVANCE_MENU_TRIG_IN => MUX_ADVANCE_MENU_TRIG_IN,  --'0',                                                                                                                                                
   CH_IMG_WIDTH_IN      => STD_LOGIC_VECTOR(to_unsigned(16, 11)),--STD_LOGIC_VECTOR(to_unsigned(8, 11)),--RETICLE_IMG_XSIZE,--BT656_REQ_XSIZE,--MEM_IMG_XSIZE , -- : in  std_logic_vector( 9 downto 0);          -- Memory Image     
   CH_IMG_HEIGHT_IN     => STD_LOGIC_VECTOR(to_unsigned(32, LIN_BITS)),--STD_LOGIC_VECTOR(to_unsigned(16, LIN_BITS)),--BT656_REQ_YSIZE,--MEM_IMG_YSIZE  , --: in  std_logic_vector( 9 downto 0);          -- Memory Image                          
   -- YCrCb output Flux to Scaler Module               -                                                                                        
   OSD_REQ_V         => MUX_BT656_REQ_V,--SCALER_BIL_REQ_V,--BT656_REQ_V  ,--ADD_BORDER_REQ_V,   --BT656_REQ_V , --: in  std_logic;                              -- Scaler New Frame Request             
   OSD_REQ_H         => MUX_BT656_REQ_H,--SCALER_BIL_REQ_H,--BT656_REQ_H  ,--ADD_BORDER_REQ_H,   --BT656_REQ_H, -- : in  std_logic;                              -- Scaler New Line Request              
--   OSD_LIN_NO   => BT656_LINE_NO,--ADD_BORDER_LINE_NO, --BT656_LINE_NO , --: in  std_logic_vector(LIN_BITS-1 downto 0);  -- Scaler asking memory_to_scale    
   OSD_FIELD         => '0',--BT656_FIELD  , --ADD_BORDER_FIELD,                                                                                                        
  
   OSD_REQ_XSIZE_LY1   => STD_LOGIC_VECTOR(to_unsigned(260, 11))      ,--STD_LOGIC_VECTOR(to_unsigned(130, 11))      ,--BT656_REQ_XSIZE, --: in std_logic_vector(PIX_BITS-1 downto    
   OSD_REQ_YSIZE_LY1   => STD_LOGIC_VECTOR(to_unsigned(580, LIN_BITS)),--STD_LOGIC_VECTOR(to_unsigned(290, LIN_BITS)),--BT656_REQ_YSIZE, --: in std_logic_vector(LIN_BITS-1 downto    
   OSD_REQ_XSIZE_LY2   => STD_LOGIC_VECTOR(to_unsigned(736, 11))      ,--STD_LOGIC_VECTOR(to_unsigned(368, 11))      ,--BT656_REQ_XSIZE, --: in std_logic_vector(PIX_BITS-1 downto    
   OSD_REQ_YSIZE_LY2   => STD_LOGIC_VECTOR(to_unsigned( 32, LIN_BITS)),--STD_LOGIC_VECTOR(to_unsigned( 16, LIN_BITS)),--BT656_REQ_YSIZE, --: in std_logic_vector(LIN_BITS-1 downto    
   OSD_REQ_XSIZE_LY3   => STD_LOGIC_VECTOR(to_unsigned(322, 11))      ,--STD_LOGIC_VECTOR(to_unsigned(161, 11))      ,--BT656_REQ_XSIZE, --: in std_logic_vector(PIX_BITS-1 downto    
   OSD_REQ_YSIZE_LY3   => STD_LOGIC_VECTOR(to_unsigned( 32, LIN_BITS)),--STD_LOGIC_VECTOR(to_unsigned( 16, LIN_BITS)),--BT656_REQ_YSIZE, --: in std_logic_vector(LIN_BITS-1 downto    
                                                                                                                                                           
   VIDEO_IN_V        => ADD_LOGO_O_V   ,--ADD_BORDER_O_V     ,--ADD_LOGO_O_V    , --ADD_BORDER_O_V    ,--VIDEO_O_V_4    ,--VIDEO_O_V_BC     , --VIDEO_O_V_P     , --SCALER_O_V,                                  
   VIDEO_IN_H        => ADD_LOGO_O_H   ,--ADD_BORDER_O_H     ,--ADD_LOGO_O_H    , --ADD_BORDER_O_H    ,--VIDEO_O_H_4    ,--VIDEO_O_H_BC     , --VIDEO_O_H_P     , --SCALER_O_H,                                  
   VIDEO_IN_DAV      => ADD_LOGO_O_DAV ,--ADD_BORDER_O_DAV   ,--ADD_LOGO_O_DAV  , --ADD_BORDER_O_DAV   ,--VIDEO_O_DAV_4  ,--VIDEO_O_DAV_BC   , --VIDEO_O_DAV_P   , --SCALER_O_DAV,                                
   VIDEO_IN_DATA     => ADD_LOGO_O_DATA,--ADD_BORDER_O_DATA  ,--ADD_LOGO_O_DATA , --ADD_BORDER_O_DATA  ,--VIDEO_O_DATA_4 ,--VIDEO_O_DATA_BC1  , --VIDEO_O_DATA_P1  , --SCALER_O_DATA1,                           
   VIDEO_IN_EOI      => ADD_LOGO_O_EOI ,--ADD_BORDER_O_EOI   ,--ADD_LOGO_O_EOI  , --ADD_BORDER_O_EOI, --VIDEO_O_EOI_4  ,--VIDEO_O_EOI_BC   , --VIDEO_O_EOI_P   , --SCALER_O_EOI,                                
   VIDEO_IN_XSIZE    => MUX_BT656_REQ_XSIZE   ,--SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE    , --ADD_LOGO_O_XSIZE, --ADD_LOGO_O_XSIZE, --ADD_BORDER_O_XSIZE,--VIDEO_O_XSIZE_BC , --VIDEO_O_XSIZE_P , --SCALER_O_XSIZE,                                                 
   VIDEO_IN_YSIZE    => MUX_BT656_REQ_YSIZE   ,--SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE    , --ADD_LOGO_O_YSIZE,--ADD_LOGO_O_YSIZE,  --ADD_BORDER_O_YSIZE,--VIDEO_O_YSIZE_BC ,  --VIDEO_O_YSIZE_P ,  --SCALER_O_YSIZE,                                               
                                                                                                                                                                                                                               
   OSD_V             => VIDEO_O_V_OSD   , -- : out std_logic;                              -- Scaler New Frame                                      
   OSD_H             => VIDEO_O_H_OSD   , -- : out std_logic;                                                                                       
   OSD_DAV           => VIDEO_O_DAV_OSD , -- : out std_logic;                              -- Scaler New Data                                     
   OSD_DATA          => VIDEO_O_DATA_OSD, -- : out std_logic_vector(7 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)             
   OSD_EOI           => VIDEO_O_EOI_OSD ,                                                                                                         
   OSD_POS_X_OUT     => OSD_POS_X_SET,
   OSD_POS_Y_OUT     => OSD_POS_Y_SET,
   CURSOR_POS_OUT    => CURSOR_POS,
   CMD_START_NUC1PTCALIB      => START_NUC1PTCALIB,
   CMD_START_NUC1PTCALIB_VALID=> START_NUC1PTCALIB_VALID,
   CMD_AGC_MODE_SEL           => AGC_MODE_SEL,
   CMD_AGC_MODE_SEL_VALID     => AGC_MODE_SEL_VALID,         
   CMD_BRIGHTNESS             => BRIGHTNESS, 
   CMD_BRIGHTNESS_VALID       => BRIGHTNESS_VALID,                 
   CMD_CONTRAST               => CONTRAST ,  
   CMD_CONTRAST_VALID         => CONTRAST_VALID ,
   CMD_DZOOM                  => ZOOM_MODE,
   CMD_DZOOM_VALID            => ZOOM_MODE_VALID,    
   CMD_RETICLE_COLOR          => RETICLE_COLOR_SEL,
   CMD_RETICLE_COLOR_VALID    => RETICLE_COLOR_SEL_VALID,           
   CMD_RETICLE_TYPE_SEL       => RETICLE_TYPE,
   CMD_RETICLE_TYPE_SEL_VALID => RETICLE_TYPE_VALID, 
   CMD_RETICLE_POS_YX         => RETICLE_POS_YX, 
   CMD_RETICLE_POS_YX_VALID   => RETICLE_POS_YX_VALID,             
--   CMD_RETICLE_POS_X          => RETICLE_POS_X, 
--   CMD_RETICLE_POS_X_VALID    => RETICLE_POS_X_VALID,        
--   CMD_RETICLE_POS_Y          => RETICLE_POS_Y,   
--   CMD_RETICLE_POS_Y_VALID    => RETICLE_POS_Y_VALID,        
   CMD_DISPLAY_LUX            => OLED_BRIGHTNESS,--OLED_DIMCTL,                             
   CMD_DISPLAY_LUX_VALID      => OLED_BRIGHTNESS_VALID,--OLED_DIMCTL_VALID,          
   CMD_DISPLAY_GAIN           => OLED_CONTRAST,--OLED_GAMMA_TABLE_SEL      , 
   CMD_DISPLAY_GAIN_VALID     => OLED_CONTRAST_VALID ,--OLED_GAMMA_TABLE_SEL_VALID, 
   CMD_DISPLAY_VERT           => IMG_SHIFT_VERT,--OLED_POS_V      ,                   
   CMD_DISPLAY_VERT_VALID     => IMG_SHIFT_VERT_VALID,--OLED_POS_V_VALID,           
   CMD_DISPLAY_HORZ           => OLED_POS_H     ,                     
   CMD_DISPLAY_HORZ_VALID     => OLED_POS_H_VALID,           

   CMD_POLARITY               => POLARITY,   
   CMD_POLARITY_VALID         => POLARITY_VALID,           
--   CMD_DDE_SEL                => DDE_SEL,       
--   CMD_DDE_SEL_VALID          => DDE_SEL_VALID,  
   CMD_SNUC_EN                => ENABLE_SNUC,      
   CMD_SNUC_EN_VALID          => ENABLE_SNUC_VALID,
   CMD_SHARPNESS              => SHARPNESS, 
   CMD_SHARPNESS_VALID        => SHARPNESS_VALID,
   CMD_CP_TYPE_SEL            => CP_TYPE,
   CMD_CP_TYPE_SEL_VALID      => CP_TYPE_VALID,    
     
   CMD_LOGO_EN            => ENABLE_LOGO,    
   CMD_LOGO_EN_VALID      => ENABLE_LOGO_VALID, 
   CMD_SMOOTHING_EN       => ENABLE_SMOOTHING_FILTER,
   CMD_SMOOTHING_EN_VALID => ENABLE_SMOOTHING_FILTER_VALID,
   CMD_EDGE_EN            => ENABLE_EDGE_FILTER,
   CMD_EDGE_EN_VALID      => ENABLE_EDGE_FILTER_VALID,    
   CMD_GALLERY_IMG_VALID     => gallery_img_valid,
   CMD_GALLERY_IMG_VALID_EN  => gallery_img_valid_en,  
   CMD_LASER_EN              => LASER_EN         ,
   CMD_LASER_EN_VALID        => LASER_EN_VALID   ,     
   CMD_GYRO_DATA_DISP_EN       => GYRO_DATA_DISP_EN ,
   CMD_GYRO_DATA_DISP_EN_VALID => GYRO_DATA_DISP_EN_VALID , 
   CMD_FIRING_MODE           => FIRING_MODE,
   CMD_FIRING_MODE_VALID     => FIRING_MODE_VALID,   
   CMD_DISPLAY_MODE          => sel_oled_analog_video_out,
   CMD_DISPLAY_MODE_VALID    => sel_oled_analog_video_out_valid,  
   CMD_SIGHT_MODE            => SIGHT_MODE,
   CMD_SIGHT_MODE_VALID      => SIGHT_MODE_VALID, 
--   CMD_FIT_TO_SCREEN_EN      => scaling_disable,--fit_to_screen_en,
--   CMD_FIT_TO_SCREEN_EN_VALID=> scaling_disable_valid,--fit_to_screen_en_valid,
   CMD_MAX_LIMITER_DPHE      => MAX_LIMITER_DPHE,
   CMD_MAX_LIMITER_DPHE_VALID=> MAX_LIMITER_DPHE_VALID,
   CMD_MUL_MAX_LIMITER_DPHE      => MUL_MAX_LIMITER_DPHE,
   CMD_MUL_MAX_LIMITER_DPHE_VALID=> MUL_MAX_LIMITER_DPHE_VALID,
   CMD_CNTRL_MAX_GAIN        => CNTRL_MAX_GAIN,
   CMD_CNTRL_MAX_GAIN_VALID  => CNTRL_MAX_GAIN_VALID,
   CMD_CNTRL_IPP             => CNTRL_IPP,
   CMD_CNTRL_IPP_VALID       => CNTRL_IPP_VALID,
   CMD_NUC_MODE              => NUC_MODE,
   CMD_NUC_MODE_VALID        => NUC_MODE_VALID,
   CMD_BLADE_MODE            => BLADE_MODE,
   CMD_BLADE_MODE_VALID      => BLADE_MODE_VALID,   
   
   OSD_START_NUC1PTCALIB         => OSD_START_CALIB,-- OSD_START_NUC1PT2CALIB,---OSD_START_NUC1PTCALIB,
   OSD_COARSE_OFFSET_CALIB_START => OSD_COARSE_OFFSET_CALIB_START,
   OSD_DZOOM              => OSD_DZOOM,
   OSD_DZOOM_VALID        => OSD_DZOOM_VALID,
   OSD_AGC_MODE_SEL       => OSD_AGC_MODE_SEL,
   OSD_AGC_MODE_SEL_VALID => OSD_AGC_MODE_SEL_VALID,
   OSD_SNAPSHOT_COUNTER   => OSD_SNAPSHOT_COUNTER,
   OSD_SNAPSHOT_COUNTER_VALID => OSD_SNAPSHOT_COUNTER_VALID,
   OSD_BRIGHTNESS         => OSD_BRIGHTNESS,
   OSD_BRIGHTNESS_VALID   => OSD_BRIGHTNESS_VALID,
   OSD_CONTRAST           => OSD_CONTRAST ,
   OSD_CONTRAST_VALID     => OSD_CONTRAST_VALID,
   OSD_RETICLE_COLOR      => OSD_RETICLE_COLOR_SEL,
   OSD_RETICLE_COLOR_VALID=> OSD_RETICLE_COLOR_SEL_VALID,    
   OSD_RETICLE_TYPE_SEL   => OSD_RETICLE_TYPE,
   OSD_RETICLE_TYPE_SEL_VALID => OSD_RETICLE_TYPE_VALID,
   OSD_RETICLE_POS_YX         => OSD_RETICLE_POS_YX,
   OSD_RETICLE_POS_YX_VALID   => OSD_RETICLE_POS_YX_VALID,   
--   OSD_RETICLE_POS_X       => OSD_RETICLE_POS_X,
--   OSD_RETICLE_POS_X_VALID => OSD_RETICLE_POS_X_VALID,
--   OSD_RETICLE_POS_Y       => OSD_RETICLE_POS_Y,
--   OSD_RETICLE_POS_Y_VALID => OSD_RETICLE_POS_Y_VALID,
   OSD_DISPLAY_LUX         => OSD_OLED_BRIGHTNESS,--OSD_OLED_DIMCTL,
   OSD_DISPLAY_LUX_VALID   => OSD_OLED_BRIGHTNESS_VALID,--OSD_OLED_DIMCTL_VALID,
   OSD_DISPLAY_GAIN        => OSD_OLED_CONTRAST,--OSD_OLED_GAMMA_TABLE_SEL,
   OSD_DISPLAY_GAIN_VALID  => OSD_OLED_CONTRAST_VALID,--OSD_OLED_GAMMA_TABLE_SEL_VALID,
   OSD_DISPLAY_VERT        => OSD_IMG_SHIFT_VERT,--OSD_OLED_POS_V      ,
   OSD_DISPLAY_VERT_VALID  => OSD_IMG_SHIFT_VERT_VALID,--OSD_OLED_POS_V_VALID,
   OSD_DISPLAY_HORZ        => OSD_OLED_POS_H     ,
   OSD_DISPLAY_HORZ_VALID  => OSD_OLED_POS_H_VALID,
   OSD_SNUC_EN            => OSD_SNUC_EN,
   OSD_SNUC_EN_VALID      => OSD_SNUC_EN_VALID,
   OSD_SMOOTHING_EN       => OSD_SMOOTHING_EN,
   OSD_SMOOTHING_EN_VALID => OSD_SMOOTHING_EN_VALID,
   OSD_SHARPNESS          => OSD_SHARPNESS,
   OSD_SHARPNESS_VALID    => OSD_SHARPNESS_VALID,
   OSD_POLARITY           => OSD_POLARITY, 
   OSD_POLARITY_VALID     => OSD_POLARITY_VALID,
   OSD_EDGE_EN            => OSD_EDGE_EN,
   OSD_EDGE_EN_VALID      => OSD_EDGE_EN_VALID,   
   OSD_CP_TYPE_SEL           => OSD_CP_TYPE,
   OSD_CP_TYPE_SEL_VALID     => OSD_CP_TYPE_VALID,
   OSD_MARK_BP               => OSD_MARK_BP              ,    
   OSD_MARK_BP_VALID         => OSD_MARK_BP_VALID        ,    
   OSD_UNMARK_BP             => OSD_UNMARK_BP            ,    
   OSD_UNMARK_BP_VALID       => OSD_UNMARK_BP_VALID      ,    
   OSD_SAVE_BP               => OSD_SAVE_BP              ,    
   OSD_LOAD_USER_SETTINGS    => OSD_LOAD_USER_SETTINGS   ,    
   OSD_LOAD_FACTORY_SETTINGS => OSD_LOAD_FACTORY_SETTINGS,    
   OSD_SAVE_USER_SETTINGS    => OSD_SAVE_USER_SETTINGS   ,
   OSD_SINGLE_SNAPSHOT       => OSD_SINGLE_SNAPSHOT,
--   OSD_CONTINUOUS_SNAPSHOT   => OSD_CONTINUOUS_SNAPSHOT,
   OSD_BURST_SNAPSHOT        => OSD_BURST_SNAPSHOT,
   OSD_GALLERY_ENABLE        => GALLERY_ENABLE,
   OSD_GALLERY_IMG_NUMBER    => GALLERY_IMG_NUMBER,
   OSD_GALLERY_IMG_VALID     => OSD_GALLERY_IMG_VALID,
   OSD_GALLERY_IMG_VALID_EN  => OSD_GALLERY_IMG_VALID_EN,
   OSD_SNAPSHOT_DELETE_EN    => OSD_SNAPSHOT_DELETE_EN,
   OSD_LASER_EN              => OSD_LASER_EN         ,
   OSD_LASER_EN_VALID        => OSD_LASER_EN_VALID   , 
   OSD_GYRO_DATA_DISP_EN       => OSD_GYRO_DATA_DISP_EN ,
   OSD_GYRO_DATA_DISP_EN_VALID => OSD_GYRO_DATA_DISP_EN_VALID ,   
   OSD_GYRO_CALIB_EN         => OSD_GYRO_CALIB_EN ,        
   OSD_GYRO_CALIB_EN_VALID   => OSD_GYRO_CALIB_EN_VALID ,           
   OSD_STANDBY_EN            => OSD_STANDBY_EN       ,      
   OSD_STANDBY_EN_VALID      => OSD_STANDBY_EN_VALID ,
   OSD_POWER_OFF_EN          => OSD_POWER_OFF_EN,     
   OSD_LOAD_GALLERY          => OSD_LOAD_GALLERY,   
   OSD_DISTANCE_SEL          => OSD_DISTANCE_SEL,--RETICLE_OFFSET_RD_ADDR,
   OSD_DISTANCE_SEL_VALID    => OSD_DISTANCE_SEL_VALID,--RETICLE_OFFSET_RD_REQ,
   OSD_FIRING_MODE           => OSD_FIRING_MODE,
   OSD_FIRING_MODE_VALID     => OSD_FIRING_MODE_VALID,
   OSD_DISPLAY_MODE          => osd_sel_oled_analog_video_out,
   OSD_DISPLAY_MODE_VALID    => osd_sel_oled_analog_video_out_valid,   
   OSD_SIGHT_MODE            => OSD_SIGHT_MODE,
   OSD_SIGHT_MODE_VALID      => OSD_SIGHT_MODE_VALID,     
--   OSD_FIT_TO_SCREEN_EN      => osd_scaling_disable,--osd_fit_to_screen_en,
--   OSD_FIT_TO_SCREEN_EN_VALID=> osd_scaling_disable_valid,--osd_fit_to_screen_en_valid,
   OSD_MAX_LIMITER_DPHE      => OSD_MAX_LIMITER_DPHE,
   OSD_MAX_LIMITER_DPHE_VALID=> OSD_MAX_LIMITER_DPHE_VALID,
   OSD_MUL_MAX_LIMITER_DPHE      => OSD_MUL_MAX_LIMITER_DPHE,
   OSD_MUL_MAX_LIMITER_DPHE_VALID=> OSD_MUL_MAX_LIMITER_DPHE_VALID,
   OSD_CNTRL_MAX_GAIN        => OSD_CNTRL_MAX_GAIN,
   OSD_CNTRL_MAX_GAIN_VALID  => OSD_CNTRL_MAX_GAIN_VALID,
   OSD_CNTRL_IPP             => OSD_CNTRL_IPP,
   OSD_CNTRL_IPP_VALID       => OSD_CNTRL_IPP_VALID,
   OSD_NUC_MODE              => OSD_NUC_MODE,
   OSD_NUC_MODE_VALID        => OSD_NUC_MODE_VALID,
   OSD_BLADE_MODE            => OSD_BLADE_MODE,
   OSD_BLADE_MODE_VALID      => OSD_BLADE_MODE_VALID,
   
   RETICLE_OFFSET_V          => unsigned(RETICLE_OFFSET_RD_DATA(31 downto 23)),
   RETICLE_OFFSET_H          => unsigned(RETICLE_OFFSET_RD_DATA(20 downto 12)),
   FIRING_DISTANCE           => unsigned(RETICLE_OFFSET_RD_DATA(9 downto 0)),
   OSD_EN_OUT                => OSD_EN_OUT                                                                                                                                                           
 );   
 


MUX_GYRO_DATA_DISP_EN_AND <= MUX_GYRO_DATA_DISP_EN and video_start;
i_GYRO_DATA_DISP :entity WORK.GYRO_DATA_DISP                                                                                             
 generic map(                                                                                                                                   
 PIX_BITS  => 11,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line                                   
 LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image                                 
 CH_ROM_ADDR_WIDTH => 11,--10,
 CH_ROM_DATA_WIDTH => 16,--8,
 CH_PER_BYTE       => 1
 )                                                                                                                                              
 port map (                                                                                                                                     
   -- Clock and Reset                                                                                                                           
   CLK                 => CLK,--CLK_27MHZ    , --: in  std_logic;                              -- Module Clock                                         
   RST                 => RST, --qspi_init_cmd_done_n  , --: in  std_logic;                              -- Module Reset (Asynchronous active high)    
   tick1ms             => TICK1MS,     
   GYRO_DATA_DISP_EN   => MUX_GYRO_DATA_DISP_EN_AND,
   GYRO_DATA_DISP_MODE => GYRO_DATA_DISP_MODE,      
   GYRO_DATA_UPDATE_TIMEOUT => GYRO_DATA_UPDATE_TIMEOUT,                                                                                                                                                                                           
   GYRO_DATA_DISP_COLOR_INFO1 => INFO_DISP_COLOR_INFO(23 downto 16),    
   CH_COLOR_INFO1             => INFO_DISP_CH_COLOR_INFO1(23 downto 16),                                                                                                 
   CH_COLOR_INFO2             => INFO_DISP_CH_COLOR_INFO2(23 downto 16),
                                                                                               
   GYRO_DATA_DISP_POS_X_LY1     => GYRO_DATA_DISP_POS_X_LY1,--OSD_POS_X_LY1_MODE1,     -- vertical display                                                                                                   
   GYRO_DATA_DISP_POS_Y_LY1     => GYRO_DATA_DISP_POS_Y_LY1,--OSD_POS_Y_LY1_MODE1,  
   GYRO_DATA_DISP_POS_X_LY2     => GYRO_DATA_DISP_POS_X_LY2,--OSD_POS_X_LY2_MODE1,     -- Horizontal display                                                                                                   
   GYRO_DATA_DISP_POS_Y_LY2     => GYRO_DATA_DISP_POS_Y_LY2,--OSD_POS_Y_LY2_MODE1,  
                                                                                                                                               
   CH_IMG_WIDTH_IN      => STD_LOGIC_VECTOR(to_unsigned(16, 10)) ,--STD_LOGIC_VECTOR(to_unsigned(8, 10)) ,   
   CH_IMG_HEIGHT_IN     => STD_LOGIC_VECTOR(to_unsigned(32, LIN_BITS)),  --STD_LOGIC_VECTOR(to_unsigned(16, LIN_BITS)),                 
   -- YCrCb output Flux to Scaler Module               -                                                                                        
   GYRO_DATA_DISP_REQ_V         => MUX_BT656_REQ_V,--SCALER_BIL_REQ_V,--BT656_REQ_V  ,                                
   GYRO_DATA_DISP_REQ_H         => MUX_BT656_REQ_H,--SCALER_BIL_REQ_H,--BT656_REQ_H  ,                                        
--   OSD_LIN_NO   => BT656_LINE_NO,    
   GYRO_DATA_DISP_FIELD         => '0',--BT656_FIELD  ,                                                                                                        
  
   GYRO_DATA_DISP_REQ_XSIZE_LY1   => STD_LOGIC_VECTOR(to_unsigned(260, 11)),         --STD_LOGIC_VECTOR(to_unsigned(130, 11)),
   GYRO_DATA_DISP_REQ_YSIZE_LY1   => STD_LOGIC_VECTOR(to_unsigned(80, LIN_BITS)), --STD_LOGIC_VECTOR(to_unsigned(120, LIN_BITS)),   --STD_LOGIC_VECTOR(to_unsigned( 60, LIN_BITS)),
   GYRO_DATA_DISP_REQ_XSIZE_LY2   => STD_LOGIC_VECTOR(to_unsigned(492, 11)),      --STD_LOGIC_VECTOR(to_unsigned(736, 11)),         --STD_LOGIC_VECTOR(to_unsigned(368, 11)),
   GYRO_DATA_DISP_REQ_YSIZE_LY2   => STD_LOGIC_VECTOR(to_unsigned( 32, LIN_BITS)),   --STD_LOGIC_VECTOR(to_unsigned( 16, LIN_BITS)),
                                                                                                                                                      
   VIDEO_IN_V                   => VIDEO_O_V_OSD      , --ADD_LOGO_O_V   ,--ADD_BORDER_O_V     ,--ADD_LOGO_O_V    , --ADD_BORDER_O_V    ,--VIDEO_O_V_4    ,--VIDEO_O_V_BC     , --VIDEO_O_V_P     , --SCALER_O_V,                                  
   VIDEO_IN_H                   => VIDEO_O_H_OSD      , --ADD_LOGO_O_H   ,--ADD_BORDER_O_H     ,--ADD_LOGO_O_H    , --ADD_BORDER_O_H    ,--VIDEO_O_H_4    ,--VIDEO_O_H_BC     , --VIDEO_O_H_P     , --SCALER_O_H,                                  
   VIDEO_IN_DAV                 => VIDEO_O_DAV_OSD    , --ADD_LOGO_O_DAV ,--ADD_BORDER_O_DAV   ,--ADD_LOGO_O_DAV  , --ADD_BORDER_O_DAV   ,--VIDEO_O_DAV_4  ,--VIDEO_O_DAV_BC   , --VIDEO_O_DAV_P   , --SCALER_O_DAV,                                
   VIDEO_IN_DATA                => VIDEO_O_DATA_OSD   , --ADD_LOGO_O_DATA,--ADD_BORDER_O_DATA  ,--ADD_LOGO_O_DATA , --ADD_BORDER_O_DATA  ,--VIDEO_O_DATA_4 ,--VIDEO_O_DATA_BC1  , --VIDEO_O_DATA_P1  , --SCALER_O_DATA1,                           
   VIDEO_IN_EOI                 => VIDEO_O_EOI_OSD    , --ADD_LOGO_O_EOI ,--ADD_BORDER_O_EOI   ,--ADD_LOGO_O_EOI  , --ADD_BORDER_O_EOI, --VIDEO_O_EOI_4  ,--VIDEO_O_EOI_BC   , --VIDEO_O_EOI_P   , --SCALER_O_EOI,                                
   VIDEO_IN_XSIZE               => MUX_BT656_REQ_XSIZE   ,--SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE    , --ADD_LOGO_O_XSIZE, --ADD_LOGO_O_XSIZE, --ADD_BORDER_O_XSIZE,--VIDEO_O_XSIZE_BC , --VIDEO_O_XSIZE_P , --SCALER_O_XSIZE,                                                 
   VIDEO_IN_YSIZE               => MUX_BT656_REQ_YSIZE   ,--SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE    , --ADD_LOGO_O_YSIZE,--ADD_LOGO_O_YSIZE,  --ADD_BORDER_O_YSIZE,--VIDEO_O_YSIZE_BC ,  --VIDEO_O_YSIZE_P ,  --SCALER_O_YSIZE,                                               
                                                                                                                                                                                                                               
   GYRO_DATA_DISP_V             => VIDEO_O_V_GYRO_DATA_DISP   , -- : out std_logic;                                                                  
   GYRO_DATA_DISP_H             => VIDEO_O_H_GYRO_DATA_DISP   , -- : out std_logic;                                                                                       
   GYRO_DATA_DISP_DAV           => VIDEO_O_DAV_GYRO_DATA_DISP , -- : out std_logic;                                                                
   GYRO_DATA_DISP_DATA          => VIDEO_O_DATA_GYRO_DATA_DISP, -- : out std_logic_vector(7 downto 0);                   
   GYRO_DATA_DISP_EOI           => VIDEO_O_EOI_GYRO_DATA_DISP ,                                                                                                         
   
   YAW                          => yaw,--corrected_yaw,--YAW,
   PITCH                        => corrected_pitch--PITCH,                                                                                                                            
--   ROLL                         => ROLL   
 );   



--INFO_DISP_COLOR_INFO        <= x"508080";
--INFO_DISP_CH_COLOR_INFO1    <= x"EB8080";
--INFO_DISP_CH_COLOR_INFO2    <= x"108080";

--INFO_DISP_POS_X             <= std_logic_vector(to_unsigned(294,INFO_DISP_POS_X'length));--std_logic_vector(to_unsigned(240,RETICLE_POS_X'length));  --(others => '0');--std_logic_vector(to_unsigned(VIDEO_XSIZE/2,RETICLE_POS_X'length));        
--INFO_DISP_POS_Y             <= std_logic_vector(to_unsigned(508,INFO_DISP_POS_Y'length));
MUX_ENABLE_INFO_DISP        <= ENABLE_INFO_DISP and video_start;
DISP_MUX_ZOOM_MODE          <= "000" when (MUX_SIGHT_MODE = "01" and sel_oled_analog_video_out='0') else MUX_ZOOM_MODE;
 i_INFO_DISPLAY :entity WORK.INFO_DISPLAY                                                                                            
 generic map(                                                                                                                                   
 PIX_BITS  => 11,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line                                   
 LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image                                 
 CH_ROM_ADDR_WIDTH => 11,--10,
 CH_ROM_DATA_WIDTH => 16,--8,
 CH_PER_BYTE       => 1
 )                                                                                                                                              
 port map (                                                                                                                                     
   -- Clock and Reset                                                                                                                           
   CLK                         => CLK,                                                      
   RST                         => RST,                            
   INFO_DISP_EN                => MUX_ENABLE_INFO_DISP,
   SN_INFO_DISP_EN             => '0',                                                                                                                                                                                               
   PRDCT_NAME_WRITE_DATA_VALID => '0',
   PRDCT_NAME_WRITE_DATA       => (others=>'0'),
   INFO_DISP_COLOR_INFO        => INFO_DISP_COLOR_INFO(23 downto 16), 
   CH_COLOR_INFO1              => INFO_DISP_CH_COLOR_INFO1(23 downto 16),                                                                                                 
   CH_COLOR_INFO2              => INFO_DISP_CH_COLOR_INFO2(23 downto 16),                                                                                              
   INFO_DISP_POS_X             => INFO_DISP_POS_X,                                                                                                        
   INFO_DISP_POS_Y             => INFO_DISP_POS_Y,
   SN_INFO_DISP_POS_X          => (others=>'0'), 
   SN_INFO_DISP_POS_Y          => (others=>'0'),                                                                                                  
   CH_IMG_WIDTH_IN             => STD_LOGIC_VECTOR(to_unsigned(16, 10)),   --STD_LOGIC_VECTOR(to_unsigned(8, 10)),
   CH_IMG_HEIGHT_IN            => STD_LOGIC_VECTOR(to_unsigned(32, LIN_BITS)),--STD_LOGIC_VECTOR(to_unsigned(16, LIN_BITS)),     
                                   
   INFO_DISP_REQ_V             => MUX_BT656_REQ_V,--SCALER_BIL_REQ_V,--BT656_REQ_V  ,--ADD_BORDER_REQ_V,   --BT656_REQ_V , --: in  std_logic;                              -- Scaler New Frame Request             
   INFO_DISP_REQ_H             => MUX_BT656_REQ_H,--SCALER_BIL_REQ_H,--BT656_REQ_H  ,--ADD_BORDER_REQ_H,   --BT656_REQ_H, -- : in  std_logic;                              -- Scaler New Line Request              
   INFO_DISP_FIELD             => '0',--BT656_FIELD  , --ADD_BORDER_FIELD,                                                                                                        
  
   INFO_DISP_REQ_XSIZE1        => STD_LOGIC_VECTOR(to_unsigned(784, 11)), --MENU LAYER3 WIDTH        --STD_LOGIC_VECTOR(to_unsigned(392, 11)), --MENU LAYER3 WIDTH 
   INFO_DISP_REQ_YSIZE1        => STD_LOGIC_VECTOR(to_unsigned( 32, LIN_BITS)),--MENU LAYER3 HEIGHT  --STD_LOGIC_VECTOR(to_unsigned( 16, LIN_BITS)),--MENU LAYER3 HEIGHT  
                                                                                                                                                           
   VIDEO_IN_V                  => VIDEO_O_V_GYRO_DATA_DISP   ,--VIDEO_O_V_OSD    ,
   VIDEO_IN_H                  => VIDEO_O_H_GYRO_DATA_DISP   ,--VIDEO_O_H_OSD    ,
   VIDEO_IN_DAV                => VIDEO_O_DAV_GYRO_DATA_DISP ,--VIDEO_O_DAV_OSD  ,
   VIDEO_IN_DATA               => VIDEO_O_DATA_GYRO_DATA_DISP,--VIDEO_O_DATA_OSD ,
   VIDEO_IN_EOI                => VIDEO_O_EOI_GYRO_DATA_DISP ,--VIDEO_O_EOI_OSD  ,                   
   VIDEO_IN_XSIZE              => MUX_BT656_REQ_XSIZE   ,--SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE, --ADD_LOGO_O_XSIZE,--VIDEO_O_XSIZE_OSD,                                         
   VIDEO_IN_YSIZE              => MUX_BT656_REQ_YSIZE   ,--SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE,--ADD_LOGO_O_YSIZE,--VIDEO_O_YSIZE_OSD,                                       
                                                                                                                                                                                                                       
   INFO_DISP_V                 => VIDEO_O_V_INFO_DISP        , 
   INFO_DISP_H                 => VIDEO_O_H_INFO_DISP        , 
   INFO_DISP_DAV               => VIDEO_O_DAV_INFO_DISP      , 
   INFO_DISP_DATA              => VIDEO_O_DATA_INFO_DISP     , 
   INFO_DISP_EOI               => VIDEO_O_EOI_INFO_DISP      ,                                                                                                         
   INFO_DISP_POS_X_OUT         => VIDEO_O_POS_X_INFO_DISP    ,
   INFO_DISP_POS_Y_OUT         => VIDEO_O_POS_Y_INFO_DISP    ,
   
   DEVICE_ID                   => update_device_id_reg,--(others=>'0'),--device_id,
   MUX_DZOOM                   => DISP_MUX_ZOOM_MODE,--MUX_ZOOM_MODE,
   MUX_AGC_MODE_SEL            => MUX_AGC_MODE_SEL,
   MUX_BRIGHTNESS              => MUX_BRIGHTNESS,
   MUX_CONTRAST                => MUX_CONTRAST ,
   MUX_RETICLE_TYPE            => MUX_RETICLE_TYPE,
   MUX_RETICLE_HORZ            => MUX_RETICLE_POS_YX1(10 downto   0),--MUX_RETICLE_POS_X,
   MUX_RETICLE_VERT            => MUX_RETICLE_POS_YX1(21 downto  12),--MUX_RETICLE_POS_Y,
   MUX_POLARITY                => MUX_POLARITY,  
   MUX_EDGE_EN                 => MUX_ENABLE_EDGE

 );


--MUX_ENABLE_BATTERY_DISP   <= (OSD_EN_OUT or ENABLE_BATTERY_DISP  ) and (not product_sel) and video_start;
--MUX_ENABLE_BAT_PER_DISP   <= (OSD_EN_OUT or ENABLE_BAT_PER_DISP  ) and (not product_sel) and video_start;
--MUX_ENABLE_BAT_CHG_SYMBOL <= (OSD_EN_OUT or ENABLE_BAT_CHG_SYMBOL) and (not product_sel) and video_start; 

MUX_ENABLE_BATTERY_DISP   <= (OSD_EN_OUT or ENABLE_BATTERY_DISP  ) and video_start and battery_disp_start; 
MUX_ENABLE_BAT_PER_DISP   <= (OSD_EN_OUT or ENABLE_BAT_PER_DISP  ) and video_start and battery_disp_start; 
MUX_ENABLE_BAT_CHG_SYMBOL <= (OSD_EN_OUT or ENABLE_BAT_CHG_SYMBOL) and video_start and battery_disp_start; 

i_BATTERY_DISPLAY :entity WORK.BATTERY_DISPLAY                                                                                            
 generic map(                                                                                                                                   
 PIX_BITS  => 11,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line                                   
 LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image                                 
 CH_ROM_ADDR_WIDTH => 11,--10,
 CH_ROM_DATA_WIDTH => 16,--8,
 CH_PER_BYTE       => 1,
 BATTERY_DIV_W     => 8
 )                                                                                                                                              
 port map (                                                                                                                                     
   -- Clock and Reset                                                                                                                          
    clk                         => CLK,--CLK_54MHZ,--CLK,                                           
    rst                         => RST,                  
    OSD_EN_OUT                  => OSD_EN_OUT,                           
    battery_disp_en             => MUX_ENABLE_BATTERY_DISP,                              
    battery_disp_color_info     => BATTERY_DISP_COLOR_INFO(23 downto 16),                          
    ch_color_info1              => BATTERY_DISP_CH_COLOR_INFO1(23 downto 16),                                
    ch_color_info2              => BATTERY_DISP_CH_COLOR_INFO2(23 downto 16),                                
    battery_disp_pos_x          => BATTERY_DISP_POS_X,                               
    battery_disp_pos_y          => BATTERY_DISP_POS_Y,    
    battery_disp_x_offset       => BATTERY_DISP_X_OFFSET,
    battery_disp_y_offset       => BATTERY_DISP_Y_OFFSET,

    bat_per_disp_en             => MUX_ENABLE_BAT_PER_DISP    ,
    bat_per_disp_color_info     => BAT_PER_DISP_COLOR_INFO(23 downto 16)    ,
    bat_per_disp_ch_color_info1 => BAT_PER_DISP_CH_COLOR_INFO1(23 downto 16),
    bat_per_disp_ch_color_info2 => BAT_PER_DISP_CH_COLOR_INFO2(23 downto 16),
    bat_per_disp_pos_x          => BAT_PER_DISP_POS_X         ,
    bat_per_disp_pos_y          => BAT_PER_DISP_POS_Y         ,
    bat_per_disp_req_xsize      => BAT_PER_DISP_REQ_XSIZE     ,
    bat_per_disp_req_ysize      => BAT_PER_DISP_REQ_YSIZE     ,
    
    bat_chg_symbol_en           => MUX_ENABLE_BAT_CHG_SYMBOL  ,
    bat_chg_symbol_pos_offset   => BAT_CHG_SYMBOL_POS_OFFSET  ,
    
    bat_per_conv_reg1           => BAT_PER_CONV_REG1,
    bat_per_conv_reg2           => BAT_PER_CONV_REG2,
    bat_per_conv_reg3           => BAT_PER_CONV_REG3,
    bat_per_conv_reg4           => BAT_PER_CONV_REG4,
    bat_per_conv_reg5           => BAT_PER_CONV_REG5,
    bat_per_conv_reg6           => BAT_PER_CONV_REG6,
                                                    
    ch_img_width                => STD_LOGIC_VECTOR(to_unsigned(16, 10)),  --STD_LOGIC_VECTOR(to_unsigned(8, 10)),    
    ch_img_height               => STD_LOGIC_VECTOR(to_unsigned(32, LIN_BITS)),  --STD_LOGIC_VECTOR(to_unsigned(16, LIN_BITS)),   

    battery_disp_req_v          => MUX_BT656_REQ_V,--SCALER_BIL_REQ_V,--BT656_REQ_V  ,
    battery_disp_req_h          => MUX_BT656_REQ_H,--SCALER_BIL_REQ_H,--BT656_REQ_H  ,
    battery_disp_field          => '0'             ,--BT656_FIELD  ,

    battery_disp_req_xsize      => BATTERY_DISP_REQ_XSIZE, 
    battery_disp_req_ysize      => BATTERY_DISP_REQ_YSIZE,--MENU LAYER3 HEIGHT    

--    battery_percentage          => BATTERY_PERCENTAGE,
    battery_voltage             => BATTERY_VOLTAGE,
    battery_disp_tg_wait_frames => BATTERY_DISP_TG_WAIT_FRAMES,--battery_disp_tg_wait_frames
    battery_pix_map             => BATTERY_PIX_MAP,
    battery_charging_start      => BATTERY_CHARGING_START,
    battery_charge_inc          => BATTERY_CHARGE_INC,
    polarity                    => MUX_POLARITY(0),
    
    video_in_v                  => VIDEO_O_V_INFO_DISP   , 
    video_in_h                  => VIDEO_O_H_INFO_DISP   , 
    video_in_dav                => VIDEO_O_DAV_INFO_DISP , 
    video_in_data               => VIDEO_O_DATA_INFO_DISP, 
    video_in_eoi                => VIDEO_O_EOI_INFO_DISP , 
    video_in_xsize              => MUX_BT656_REQ_XSIZE   ,--SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE ,
    video_in_ysize              => MUX_BT656_REQ_YSIZE   ,--SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE ,

    battery_disp_v_out          => VIDEO_O_V_BATTERY_DISP   ,  
    battery_disp_h_out          => VIDEO_O_H_BATTERY_DISP   ,  
    battery_disp_dav_out        => VIDEO_O_DAV_BATTERY_DISP ,  
    battery_disp_data_out       => VIDEO_O_DATA_BATTERY_DISP,  
    battery_disp_eoi_out        => VIDEO_O_EOI_BATTERY_DISP      
                                                          
 );   
 
end generate; 




----i_MEMORY_TO_OSD_LY2 :entity WORK.MEMORY_TO_OSD_LY2                                                                                             
---- generic map(                                                                                                                                   
---- PIX_BITS  => PIX_BITS,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line                                   
---- LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image                                 
---- CH_ROM_ADDR_WIDTH => 10,
---- CH_ROM_DATA_WIDTH => 8,
---- CH_PER_BYTE       => 1
---- )                                                                                                                                              
---- port map (                                                                                                                                     
----   -- Clock and Reset                                                                                                                           
----   CLK               => CLK,--CLK_27MHZ    , --: in  std_logic;                              -- Module Clock                                         
----   RST               => RST, --qspi_init_cmd_done_n  , --: in  std_logic;                              -- Module Reset (Asynchronous active high)    
----   OSD_EN            => ENABLE_OSD_LATCH1 , --in std_logic                                                                                                                                                                                               
----   OSD_COLOR_INFO1   => OSD_COLOR_INFO, 
----   CH_COLOR_INFO1    => CH_COLOR_INFO1,                                                                                                 
----   CH_COLOR_INFO2    => CH_COLOR_INFO2,                                                                                             
----   OSD_POS_X         => OSD_POS_X_LY2,                                                                                                        
----   OSD_POS_Y         => OSD_POS_Y_LY2,  
----   MENU_SEL_UP       => MENU_SEL_UP_U,
----   MENU_SEL_DN       => MENU_SEL_DN_U,  
----   CURSOR_POS        => CURSOR_POS,                                                                                                                                                  
----   MEM_IMG_XSIZE  => STD_LOGIC_VECTOR(to_unsigned(1, PIX_BITS)),--RETICLE_IMG_XSIZE,--BT656_REQ_XSIZE,--MEM_IMG_XSIZE , -- : in  std_logic_vector( 9 downto 0);          -- Memory Image     
----   MEM_IMG_YSIZE  => STD_LOGIC_VECTOR(to_unsigned(16, LIN_BITS)),--BT656_REQ_YSIZE,--MEM_IMG_YSIZE  , --: in  std_logic_vector( 9 downto 0);          -- Memory Image     
------   -- DMA Master Read Interface to Memory Controller                                                                                            
------   DMA_RDREADY    => DMA_R3_RDREADY_s, -- : in  std_logic;                              -- DMA Ready Request                                    
------   DMA_RDREQ      => DMA_R3_RDREQ_s, -- : out std_logic;                              -- DMA Read Request                                       
------   DMA_RDSIZE     => DMA_R3_RDSIZE_s, -- : out std_logic_vector( 4 downto 0);          -- DMA Request Size                                      
------   DMA_RDADDR     => DMA_R3_RDADDR_s, -- : out std_logic_vector(31 downto 0);          -- DMA Master Address                                    
------   DMA_RDDAV      => DMA_R3_RDDAV_s, -- : in  std_logic;                              -- DMA Read Data Valid                                    
------   DMA_RDDATA     => DMA_R3_RDDATA_s, -- : in  std_logic_vector(31 downto 0);          -- DMA Read Data                                         
----   -- YCrCb output Flux to Scaler Module               -                                                                                        
----   OSD_REQ_V    => BT656_REQ_V  ,--ADD_BORDER_REQ_V,   --BT656_REQ_V , --: in  std_logic;                              -- Scaler New Frame Request             
----   OSD_REQ_H    => BT656_REQ_H  ,--ADD_BORDER_REQ_H,   --BT656_REQ_H, -- : in  std_logic;                              -- Scaler New Line Request              
------   OSD_LIN_NO   => BT656_LINE_NO,--ADD_BORDER_LINE_NO, --BT656_LINE_NO , --: in  std_logic_vector(LIN_BITS-1 downto 0);  -- Scaler asking memory_to_scale    
----   OSD_FIELD    => BT656_FIELD  , --ADD_BORDER_FIELD,                                                                                                        
----   OSD_REQ_XSIZE=> STD_LOGIC_VECTOR(to_unsigned(320, PIX_BITS)),--BT656_REQ_XSIZE, --: in std_logic_vector(PIX_BITS-1 downto    
----   OSD_REQ_YSIZE=> STD_LOGIC_VECTOR(to_unsigned(8, LIN_BITS)),--BT656_REQ_YSIZE, --: in std_logic_vector(LIN_BITS-1 downto    
                                                                                                                                                
----   VIDEO_IN_V     => VIDEO_O_V_OSD    , --ADD_BORDER_O_V    ,--VIDEO_O_V_4    ,--VIDEO_O_V_BC     , --VIDEO_O_V_P     , --SCALER_O_V,                                  
----   VIDEO_IN_H     => VIDEO_O_H_OSD    , --ADD_BORDER_O_H    ,--VIDEO_O_H_4    ,--VIDEO_O_H_BC     , --VIDEO_O_H_P     , --SCALER_O_H,                                  
----   VIDEO_IN_DAV   => VIDEO_O_DAV_OSD  , --ADD_BORDER_O_DAV   ,--VIDEO_O_DAV_4  ,--VIDEO_O_DAV_BC   , --VIDEO_O_DAV_P   , --SCALER_O_DAV,                                
----   VIDEO_IN_DATA  => VIDEO_O_DATA_OSD , --ADD_BORDER_O_DATA  ,--VIDEO_O_DATA_4 ,--VIDEO_O_DATA_BC1  , --VIDEO_O_DATA_P1  , --SCALER_O_DATA1,                           
----   VIDEO_IN_EOI   => VIDEO_O_EOI_OSD, --ADD_BORDER_O_EOI, --VIDEO_O_EOI_4  ,--VIDEO_O_EOI_BC   , --VIDEO_O_EOI_P   , --SCALER_O_EOI,                                
----   VIDEO_IN_XSIZE => BT656_REQ_XSIZE, --ADD_LOGO_O_XSIZE, --ADD_BORDER_O_XSIZE,--VIDEO_O_XSIZE_BC , --VIDEO_O_XSIZE_P , --SCALER_O_XSIZE,                                                 
----   VIDEO_IN_YSIZE => BT656_REQ_YSIZE,--ADD_LOGO_O_YSIZE,  --ADD_BORDER_O_YSIZE,--VIDEO_O_YSIZE_BC ,  --VIDEO_O_YSIZE_P ,  --SCALER_O_YSIZE,                                               
                                                                                                                                                                                                                               
----   OSD_V       =>  VIDEO_O_V_OSD1   , -- : out std_logic;                              -- Scaler New Frame                                      
----   OSD_H       =>  VIDEO_O_H_OSD1   , -- : out std_logic;                                                                                       
----   OSD_DAV     =>  VIDEO_O_DAV_OSD1 , -- : out std_logic;                              -- Scaler New Data                                     
----   OSD_DATA    =>  VIDEO_O_DATA_OSD1, -- : out std_logic_vector(7 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)             
----   OSD_EOI     =>  VIDEO_O_EOI_OSD1 ,                                                                                                         
----   OSD_POS_X_OUT => open,
----   OSD_POS_Y_OUT => open                                                                                                                                      

 
---- );   


--MUX_RETICLE_ENABLE <= (MUX_RETICLE_TYPE(0) or MUX_RETICLE_TYPE(1) or MUX_RETICLE_TYPE(2) or MUX_RETICLE_TYPE(3)) and video_start;
--MUX_RETICLE_ENABLE1  <= (MUX_RETICLE_ENABLE or RETICLE_SEL_EN or BPR_DISP_EN) and video_start;
--MUX_RETICLE_TYPE_SEL <= MUX_ZOOM_MODE & MUX_RETICLE_SEL when (RETICLE_SEL_EN = '1')else
--                        MUX_ZOOM_MODE & x"5"            when ((RETICLE_SEL_EN = '0' and MUX_RETICLE_TYPE = x"0" ) or (BPR_DISP_EN = '1')) else
--                        MUX_ZOOM_MODE & MUX_RETICLE_SEL when (RETICLE_SEL_EN = '0' and MUX_RETICLE_TYPE = x"1");

MUX_RETICLE_ENABLE   <= '0' when (MUX_RETICLE_TYPE =x"0") else '1';  
--MUX_RETICLE_ENABLE1  <= '0'when (RETICLE_SEL_EN = '0' and BPR_DISP_EN= '0' and MUX_RETICLE_TYPE = x"0") else (MUX_RETICLE_ENABLE or RETICLE_SEL_EN or BPR_DISP_EN) and video_start;
MUX_RETICLE_ENABLE1  <=(MUX_RETICLE_ENABLE or RETICLE_SEL_EN or BPR_DISP_EN) and video_start;
--MUX_RETICLE_TYPE_SEL <= MUX_ZOOM_MODE & MUX_RETICLE_SEL when (RETICLE_SEL_EN = '1')else
--                        MUX_ZOOM_MODE & x"5"            when ((RETICLE_SEL_EN = '0' and MUX_RETICLE_TYPE = x"1") or (BPR_DISP_EN = '1')) else
--                        MUX_ZOOM_MODE & MUX_RETICLE_SEL when (RETICLE_SEL_EN = '0' and MUX_RETICLE_TYPE = x"2");
MUX_RETICLE_TYPE_SEL <= "000" & MUX_RETICLE_TYPE when (MUX_SIGHT_MODE ="01" and sel_oled_analog_video_out ='0') else MUX_ZOOM_MODE & MUX_RETICLE_TYPE;

mipi_reticle_gen: if(MIPI_EN = TRUE or USB_EN = TRUE or EK_EN = TRUE)generate
 i_MEMORY_TO_RETICLE_NEW :entity WORK.MEMORY_TO_RETICLE_NEW    
 generic map(                                                 
   PIX_BITS  => PIX_BITS,--: positive;                 
   LIN_BITS  => LIN_BITS,--: positive; 
   RETICLE_INIT_MEMORY_WR_SIZE => ((integer(RETICLE_W)*integer(RETICLE_H))/16),
   VIDEO_X_OFFSET_PAL => VIDEO_X_OFFSET_PAL,
   VIDEO_Y_OFFSET_PAL => VIDEO_Y_OFFSET_PAL,                 
   VIDEO_X_OFFSET_OLED => VIDEO_X_OFFSET_OLED,
   VIDEO_Y_OFFSET_OLED => VIDEO_Y_OFFSET_OLED               
 )                                                     
 port map (                                            
   -- Clock and Reset                                  
   CLK                          => CLK,--CLK_54MHZ,--CLK,--CLK_27MHZ    , --: in  std_log
   RST                          => RST, --qspi_init_cmd_done_n  , --: i
   video_start                  => video_start,
   sel_oled_analog_video_out    => sel_oled_analog_video_out,
   RETICLE_COLOR_SEL            => MUX_RETICLE_COLOR_SEL,--RETICLE_COLOR_SEL,
   RETICLE_COLOR_TH             => RETICLE_COLOR_TH,           
   COLOR_SEL_WINDOW_XSIZE       => COLOR_SEL_WINDOW_XSIZE,
   COLOR_SEL_WINDOW_YSIZE       => COLOR_SEL_WINDOW_YSIZE, 
   qspi_reticle_transfer_done   => qspi_reticle_transfer_done,
   qspi_reticle_transfer_rq_ack => qspi_reticle_transfer_rq_ack,
   qspi_reticle_transfer_rq     => qspi_reticle_transfer_rq,
   reticle_sel                  => reticle_sel_out,
   RETICLE_OFFSET_RD_REQ        => MUX_DISTANCE_SEL_VALID ,--RETICLE_OFFSET_RD_REQ,
   RETICLE_OFFSET_RD_ADDR       => MUX_DISTANCE_SEL,--RETICLE_OFFSET_RD_ADDR,
   RETICLE_OFFSET_RD_DATA       => RETICLE_OFFSET_RD_DATA,
   RETICLE_OFFSET_WR_EN_IN      => RETICLE_OFFSET_WR_EN,
   RETICLE_OFFSET_WR_DATA_IN    => RETICLE_OFFSET_WR_DATA,
   RETICLE_WR_EN_IN             => RETICLE_WR_EN,
   RETICLE_WR_DATA_IN           => RETICLE_WR_DATA,
   RETICLE_EN                   => ENABLE_RETICLE_D, --in std_logic    
   RETICLE_TYPE                 => MUX_RETICLE_TYPE_SEL,--MUX_RETICLE_SEL,       -- MUX_RETICLE_TYPE                
   RETICLE_COLOR_INFO1          => RETICLE_COLOR_INFO1(23 downto 16),         
   RETICLE_COLOR_INFO2          => RETICLE_COLOR_INFO2(23 downto 16),         
   RETICLE_POS_X                => reticle_pos_x_out,--RETICLE_P
   RETICLE_POS_Y                => reticle_pos_y_out,--RETICLE_P              
   MEM_IMG_XSIZE                => RETICLE_IMG_XSIZE,--BT656_REQ_XSIZ
   MEM_IMG_YSIZE                => RETICLE_IMG_YSIZE,--BT656_REQ_YSIZ
  
   RETICLE_REQ_V                => BT656_REQ_V  ,--ADD_BORDER_REQ_V
   RETICLE_REQ_H                => BT656_REQ_H  ,--ADD_BORDER_REQ_H
   RETICLE_FIELD                => BT656_FIELD  , --ADD_BORDER_FIEL
   RETICLE_REQ_XSIZE            => std_logic_vector(to_unsigned(RETICLE_W,PIX_BITS)),--STD_LOGIC_VECTOR(to_
   RETICLE_REQ_YSIZE            => std_logic_vector(to_unsigned(RETICLE_H,LIN_BITS)),--STD_LOGIC_VECTOR(to_
                                                         
   VIDEO_IN_V                   => ADD_BORDER_O_V   ,--VIDEO_O_V_BATTERY_DISP   , --VIDEO_O_V_INFO_DISP      ,--VIDEO_O_V_CB_BAR_DISP    ,--VIDEO_O_V_INFO_DISP    , --VIDEO_O_V_OSD    ,   --VIDEO_O_V_OSD1,   --ADD_LOGO_O_V,   --ADD_BORDER_O_V     , --ADD_LOGO_O
   VIDEO_IN_H                   => ADD_BORDER_O_H   ,--VIDEO_O_H_BATTERY_DISP   , --VIDEO_O_H_INFO_DISP      ,--VIDEO_O_H_CB_BAR_DISP    ,--VIDEO_O_H_INFO_DISP    , --VIDEO_O_H_OSD    ,   --VIDEO_O_H_OSD1,   --ADD_LOGO_O_H,   --ADD_BORDER_O_H     , --ADD_LOGO_O
   VIDEO_IN_DAV                 => ADD_BORDER_O_DAV ,--VIDEO_O_DAV_BATTERY_DISP , --VIDEO_O_DAV_INFO_DISP    ,--VIDEO_O_DAV_CB_BAR_DISP  ,--VIDEO_O_DAV_INFO_DISP  , --VIDEO_O_DAV_OSD  , --VIDEO_O_DAV_OSD1, --ADD_LOGO_O_DAV, --ADD_BORDER_O_DAV   , --ADD_LOGO_O
   VIDEO_IN_DATA                => ADD_BORDER_O_DATA,--VIDEO_O_DATA_BATTERY_DISP, --VIDEO_O_DATA_INFO_DISP   ,--VIDEO_O_DATA_CB_BAR_DISP ,--VIDEO_O_DATA_INFO_DISP , --VIDEO_O_DATA_OSD ,--VIDEO_O_DATA_OSD1,--ADD_LOGO_O_DATA,--ADD_BORDER_O_DATA  , --ADD_LOGO_O
   VIDEO_IN_EOI                 => ADD_BORDER_O_EOI ,--VIDEO_O_EOI_BATTERY_DISP , --VIDEO_O_EOI_INFO_DISP    ,--VIDEO_O_EOI_CB_BAR_DISP  ,--VIDEO_O_EOI_INFO_DISP  , --VIDEO_O_EOI_OSD  , --VIDEO_O_EOI_OSD1, --ADD_LOGO_O_EOI, --ADD_BORDER_O_EOI   , --ADD_LOGO_O
   VIDEO_IN_XSIZE               => BT656_REQ_XSIZE,--VIDEO_O_POS_X_INFO_DISP  ,--BT656_REQ_XSIZE  , --ADD_LOGO_O
   VIDEO_IN_YSIZE               => BT656_REQ_YSIZE,--VIDEO_O_POS_Y_INFO_DISP  ,--BT656_REQ_YSIZE  , --ADD_LOGO_O
                                                                                                         
   RETICLE_V                    => VIDEO_O_V_RET,      -- : out std_logi
   RETICLE_H                    => VIDEO_O_H_RET,      -- : out std_logi
   RETICLE_DAV                  => VIDEO_O_DAV_RET,    -- : out std_lo
   RETICLE_DATA                 => VIDEO_O_DATA_RET ,  -- : out std_
   RETICLE_EOI                  => VIDEO_O_EOI_RET,                
   RETICLE_POS_X_OUT            => RETICLE_POS_X_SET,             
   RETICLE_POS_Y_OUT            => RETICLE_POS_Y_SET            
 );     

end generate;

reticle_gen: if(OLED_EN = TRUE)generate
-- i_MEMORY_TO_RETICLE_NEW :entity WORK.MEMORY_TO_RETICLE_NEW    
-- generic map(                                                 
--   PIX_BITS  => PIX_BITS,--: positive;                 
--   LIN_BITS  => LIN_BITS,--: positive; 
--   RETICLE_INIT_MEMORY_WR_SIZE => ((integer(RETICLE_W)*integer(RETICLE_H))/16),
--   VIDEO_X_OFFSET => VIDEO_X_OFFSET,
--   VIDEO_Y_OFFSET => VIDEO_Y_OFFSET                 
-- )                                                     
-- port map (                                            
--   -- Clock and Reset                                  
--   CLK                          => CLK,--CLK_54MHZ,--CLK,--CLK_27MHZ    , --: in  std_log
--   RST                          => RST, --qspi_init_cmd_done_n  , --: i
--   video_start                  => video_start,
--   RETICLE_COLOR_SEL            => MUX_RETICLE_COLOR_SEL,--RETICLE_COLOR_SEL,
--   RETICLE_COLOR_TH             => RETICLE_COLOR_TH,           
--   COLOR_SEL_WINDOW_XSIZE       => COLOR_SEL_WINDOW_XSIZE,
--   COLOR_SEL_WINDOW_YSIZE       => COLOR_SEL_WINDOW_YSIZE, 
--   qspi_reticle_transfer_done   => qspi_reticle_transfer_done,
--   qspi_reticle_transfer_rq_ack => qspi_reticle_transfer_rq_ack,
--   qspi_reticle_transfer_rq     => qspi_reticle_transfer_rq,
--   reticle_sel                  => reticle_sel_out,
--   RETICLE_OFFSET_RD_REQ        => MUX_DISTANCE_SEL_VALID, --RETICLE_OFFSET_RD_REQ,
--   RETICLE_OFFSET_RD_ADDR       => MUX_DISTANCE_SEL,--RETICLE_OFFSET_RD_ADDR,
--   RETICLE_OFFSET_RD_DATA       => RETICLE_OFFSET_RD_DATA,   
--   RETICLE_OFFSET_WR_EN_IN      => RETICLE_OFFSET_WR_EN,
--   RETICLE_OFFSET_WR_DATA_IN    => RETICLE_OFFSET_WR_DATA,
--   RETICLE_WR_EN_IN             => RETICLE_WR_EN,
--   RETICLE_WR_DATA_IN           => RETICLE_WR_DATA,
--   RETICLE_EN                   => ENABLE_RETICLE_D, --in std_logic    
--   RETICLE_TYPE                 => MUX_RETICLE_TYPE_SEL,--MUX_RETICLE_SEL,       -- MUX_RETICLE_TYPE                
--   RETICLE_COLOR_INFO1          => RETICLE_COLOR_INFO1,         
--   RETICLE_COLOR_INFO2          => RETICLE_COLOR_INFO2,         
--   RETICLE_POS_X                => reticle_pos_x_out,--RETICLE_P
--   RETICLE_POS_Y                => reticle_pos_y_out,--RETICLE_P              
--   MEM_IMG_XSIZE                => RETICLE_IMG_XSIZE,--BT656_REQ_XSIZ
--   MEM_IMG_YSIZE                => RETICLE_IMG_YSIZE,--BT656_REQ_YSIZ
  
--   RETICLE_REQ_V                => SCALER_BIL_REQ_V, --BT656_REQ_V  ,--ADD_BORDER_REQ_V
--   RETICLE_REQ_H                => SCALER_BIL_REQ_H,--BT656_REQ_H  ,--ADD_BORDER_REQ_H
--   RETICLE_FIELD                => '0'             , --BT656_FIELD  , --ADD_BORDER_FIEL
--   RETICLE_REQ_XSIZE            => std_logic_vector(to_unsigned(RETICLE_W,PIX_BITS)),--STD_LOGIC_VECTOR(to_
--   RETICLE_REQ_YSIZE            => std_logic_vector(to_unsigned(RETICLE_H,LIN_BITS)),--STD_LOGIC_VECTOR(to_
                                                         
--   VIDEO_IN_V                   => VIDEO_O_V_BATTERY_DISP   , --VIDEO_O_V_INFO_DISP      ,--VIDEO_O_V_CB_BAR_DISP    ,--VIDEO_O_V_INFO_DISP    , --VIDEO_O_V_OSD    ,   --VIDEO_O_V_OSD1,   --ADD_LOGO_O_V,   --ADD_BORDER_O_V     , --ADD_LOGO_O
--   VIDEO_IN_H                   => VIDEO_O_H_BATTERY_DISP   , --VIDEO_O_H_INFO_DISP      ,--VIDEO_O_H_CB_BAR_DISP    ,--VIDEO_O_H_INFO_DISP    , --VIDEO_O_H_OSD    ,   --VIDEO_O_H_OSD1,   --ADD_LOGO_O_H,   --ADD_BORDER_O_H     , --ADD_LOGO_O
--   VIDEO_IN_DAV                 => VIDEO_O_DAV_BATTERY_DISP , --VIDEO_O_DAV_INFO_DISP    ,--VIDEO_O_DAV_CB_BAR_DISP  ,--VIDEO_O_DAV_INFO_DISP  , --VIDEO_O_DAV_OSD  , --VIDEO_O_DAV_OSD1, --ADD_LOGO_O_DAV, --ADD_BORDER_O_DAV   , --ADD_LOGO_O
--   VIDEO_IN_DATA                => VIDEO_O_DATA_BATTERY_DISP, --VIDEO_O_DATA_INFO_DISP   ,--VIDEO_O_DATA_CB_BAR_DISP ,--VIDEO_O_DATA_INFO_DISP , --VIDEO_O_DATA_OSD ,--VIDEO_O_DATA_OSD1,--ADD_LOGO_O_DATA,--ADD_BORDER_O_DATA  , --ADD_LOGO_O
--   VIDEO_IN_EOI                 => VIDEO_O_EOI_BATTERY_DISP , --VIDEO_O_EOI_INFO_DISP    ,--VIDEO_O_EOI_CB_BAR_DISP  ,--VIDEO_O_EOI_INFO_DISP  , --VIDEO_O_EOI_OSD  , --VIDEO_O_EOI_OSD1, --ADD_LOGO_O_EOI, --ADD_BORDER_O_EOI   , --ADD_LOGO_O
--   VIDEO_IN_XSIZE               => SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE,--VIDEO_O_POS_X_INFO_DISP  ,--BT656_REQ_XSIZE  , --ADD_LOGO_O
--   VIDEO_IN_YSIZE               => SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE,--VIDEO_O_POS_Y_INFO_DISP  ,--BT656_REQ_YSIZE  , --ADD_LOGO_O
                                                                                                         
--   RETICLE_V                    => VIDEO_O_V_RET,      -- : out std_logi
--   RETICLE_H                    => VIDEO_O_H_RET,      -- : out std_logi
--   RETICLE_DAV                  => VIDEO_O_DAV_RET,    -- : out std_lo
--   RETICLE_DATA                 => VIDEO_O_DATA_RET ,  -- : out std_
--   RETICLE_EOI                  => VIDEO_O_EOI_RET,                
--   RETICLE_POS_X_OUT            => RETICLE_POS_X_SET,             
--   RETICLE_POS_Y_OUT            => RETICLE_POS_Y_SET            
-- );                                      
 i_MEMORY_TO_RETICLE_NEW :entity WORK.MEMORY_TO_RETICLE_NEW    
 generic map(                                                 
   PIX_BITS  => 11,--: positive;                 
   LIN_BITS  => LIN_BITS,--: positive; 
   RETICLE_INIT_MEMORY_WR_SIZE => ((integer(RETICLE_W)*integer(RETICLE_H))/16),
   VIDEO_X_OFFSET_PAL => VIDEO_X_OFFSET_PAL,
   VIDEO_Y_OFFSET_PAL => VIDEO_Y_OFFSET_PAL,                 
   VIDEO_X_OFFSET_OLED => VIDEO_X_OFFSET_OLED,
   VIDEO_Y_OFFSET_OLED => VIDEO_Y_OFFSET_OLED
 )                                                     
 port map (                                            
   -- Clock and Reset                                  
   CLK                          => CLK,--CLK_54MHZ,--CLK,--CLK_27MHZ    , --: in  std_log
   RST                          => RST, --qspi_init_cmd_done_n  , --: i
   video_start                  => video_start,
   sel_oled_analog_video_out    => sel_oled_analog_video_out,
   RETICLE_COLOR_SEL            => MUX_RETICLE_COLOR_SEL,--RETICLE_COLOR_SEL,
   RETICLE_COLOR_TH             => RETICLE_COLOR_TH,           
   COLOR_SEL_WINDOW_XSIZE       => COLOR_SEL_WINDOW_XSIZE,
   COLOR_SEL_WINDOW_YSIZE       => COLOR_SEL_WINDOW_YSIZE, 
   qspi_reticle_transfer_done   => qspi_reticle_transfer_done,
   qspi_reticle_transfer_rq_ack => qspi_reticle_transfer_rq_ack,
   qspi_reticle_transfer_rq     => qspi_reticle_transfer_rq,
   reticle_sel                  => reticle_sel_out,
   RETICLE_OFFSET_RD_REQ        => MUX_DISTANCE_SEL_VALID, --RETICLE_OFFSET_RD_REQ,
   RETICLE_OFFSET_RD_ADDR       => MUX_DISTANCE_SEL,--RETICLE_OFFSET_RD_ADDR,
   RETICLE_OFFSET_RD_DATA       => RETICLE_OFFSET_RD_DATA,   
   RETICLE_OFFSET_WR_EN_IN      => RETICLE_OFFSET_WR_EN,
   RETICLE_OFFSET_WR_DATA_IN    => RETICLE_OFFSET_WR_DATA,
   RETICLE_WR_EN_IN             => RETICLE_WR_EN,
   RETICLE_WR_DATA_IN           => RETICLE_WR_DATA,
   RETICLE_EN                   => ENABLE_RETICLE_D, --in std_logic    
   RETICLE_TYPE                 => MUX_RETICLE_TYPE_SEL,--MUX_RETICLE_SEL,       -- MUX_RETICLE_TYPE                
   RETICLE_COLOR_INFO1          => RETICLE_COLOR_INFO1(23 downto 16),         
   RETICLE_COLOR_INFO2          => RETICLE_COLOR_INFO2(23 downto 16),         
   RETICLE_POS_X                => reticle_pos_x_out,--MUX_RETICLE_POS_YX(10 downto 0),--reticle_pos_x_out,--RETICLE_P
   RETICLE_POS_Y                => reticle_pos_y_out,--MUX_RETICLE_POS_YX(21 downto 12),--reticle_pos_y_out,--RETICLE_P              
   MEM_IMG_XSIZE                => RETICLE_IMG_XSIZE,--BT656_REQ_XSIZ
   MEM_IMG_YSIZE                => RETICLE_IMG_YSIZE,--BT656_REQ_YSIZ
  
   RETICLE_REQ_V                => MUX_BT656_REQ_V,--SCALER_BIL_REQ_V, --BT656_REQ_V  ,--ADD_BORDER_REQ_V
   RETICLE_REQ_H                => MUX_BT656_REQ_H,--SCALER_BIL_REQ_H,--BT656_REQ_H  ,--ADD_BORDER_REQ_H
   RETICLE_FIELD                => '0'             , --BT656_FIELD  , --ADD_BORDER_FIEL
   RETICLE_REQ_XSIZE            => std_logic_vector(to_unsigned(RETICLE_W,11)),--STD_LOGIC_VECTOR(to_
   RETICLE_REQ_YSIZE            => std_logic_vector(to_unsigned(RETICLE_H,LIN_BITS)),--STD_LOGIC_VECTOR(to_
                                                         
   VIDEO_IN_V                   => VIDEO_O_V_BATTERY_DISP   ,--ADD_LOGO_O_V   ,--VIDEO_O_V_BATTERY_DISP   , --VIDEO_O_V_INFO_DISP      ,--VIDEO_O_V_CB_BAR_DISP    ,--VIDEO_O_V_INFO_DISP    , --VIDEO_O_V_OSD    ,   --VIDEO_O_V_OSD1,   --ADD_LOGO_O_V,   --ADD_BORDER_O_V     , --ADD_LOGO_O
   VIDEO_IN_H                   => VIDEO_O_H_BATTERY_DISP   ,--ADD_LOGO_O_H   ,--VIDEO_O_H_BATTERY_DISP   , --VIDEO_O_H_INFO_DISP      ,--VIDEO_O_H_CB_BAR_DISP    ,--VIDEO_O_H_INFO_DISP    , --VIDEO_O_H_OSD    ,   --VIDEO_O_H_OSD1,   --ADD_LOGO_O_H,   --ADD_BORDER_O_H     , --ADD_LOGO_O
   VIDEO_IN_DAV                 => VIDEO_O_DAV_BATTERY_DISP ,--ADD_LOGO_O_DAV ,--VIDEO_O_DAV_BATTERY_DISP , --VIDEO_O_DAV_INFO_DISP    ,--VIDEO_O_DAV_CB_BAR_DISP  ,--VIDEO_O_DAV_INFO_DISP  , --VIDEO_O_DAV_OSD  , --VIDEO_O_DAV_OSD1, --ADD_LOGO_O_DAV, --ADD_BORDER_O_DAV   , --ADD_LOGO_O
   VIDEO_IN_DATA                => VIDEO_O_DATA_BATTERY_DISP,--ADD_LOGO_O_DATA,--VIDEO_O_DATA_BATTERY_DISP, --VIDEO_O_DATA_INFO_DISP   ,--VIDEO_O_DATA_CB_BAR_DISP ,--VIDEO_O_DATA_INFO_DISP , --VIDEO_O_DATA_OSD ,--VIDEO_O_DATA_OSD1,--ADD_LOGO_O_DATA,--ADD_BORDER_O_DATA  , --ADD_LOGO_O
   VIDEO_IN_EOI                 => VIDEO_O_EOI_BATTERY_DISP ,--ADD_LOGO_O_EOI ,--VIDEO_O_EOI_BATTERY_DISP , --VIDEO_O_EOI_INFO_DISP    ,--VIDEO_O_EOI_CB_BAR_DISP  ,--VIDEO_O_EOI_INFO_DISP  , --VIDEO_O_EOI_OSD  , --VIDEO_O_EOI_OSD1, --ADD_LOGO_O_EOI, --ADD_BORDER_O_EOI   , --ADD_LOGO_O
   VIDEO_IN_XSIZE               => MUX_BT656_REQ_XSIZE   ,--SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE,--VIDEO_O_POS_X_INFO_DISP  ,--BT656_REQ_XSIZE  , --ADD_LOGO_O
   VIDEO_IN_YSIZE               => MUX_BT656_REQ_YSIZE   ,--SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE,--VIDEO_O_POS_Y_INFO_DISP  ,--BT656_REQ_YSIZE  , --ADD_LOGO_O
                                                                                                         
   RETICLE_V                    => VIDEO_O_V_RET,      -- : out std_logi
   RETICLE_H                    => VIDEO_O_H_RET,      -- : out std_logi
   RETICLE_DAV                  => VIDEO_O_DAV_RET,    -- : out std_lo
   RETICLE_DATA                 => VIDEO_O_DATA_RET ,  -- : out std_
   RETICLE_EOI                  => VIDEO_O_EOI_RET,                
   RETICLE_POS_X_OUT            => RETICLE_POS_X_SET,             
   RETICLE_POS_Y_OUT            => RETICLE_POS_Y_SET            
 );     
end generate;    

--VIDEO_O_DATA_RET1 <= VIDEO_O_DATA_RET(23 downto 16) & CONSTANT_CB_CR;               
VIDEO_O_DATA_RET1 <= VIDEO_O_DATA_RET & CONSTANT_CB_CR; 
i_Y444toY422 : entity WORK.Y444toY422 
generic map(
  bit_width => 23  -- Actually (bit_width - 1)
  )
port map(
  CLK       => CLK,--CLK_54MHZ,--CLK,
  RST       => RST,

  VIDEO_I_V     => VIDEO_O_V_RET    ,   --VIDEO_O_V_BATTERY_DISP   ,--VIDEO_O_V_OSD   ,--VIDEO_O_V_BATTERY_DISP   ,--VIDEO_O_V_INFO_DISP   , --VIDEO_O_V_GYRO_DATA_DISP   ,--VIDEO_O_V_OSD   ,--ADD_LOGO_O_V    ,--VIDEO_O_V_BATTERY_DISP   ,--ADD_BORDER_O_V_MUX   ,--VIDEO_O_V_RET,   --VIDEO_O_V_BATTERY_DISP   ,--VIDEO_O_V_RET,   --VIDEO_O_V_INFO_DISP   , --ADD_BORDER_O_V     ,--VIDEO_O_V_RET,   --ADD_BORDER_O_V     ,--VIDEO_O_V_RET,    --ADD_LOGO_O_V    , --ADD_BORDER_O_V     ,--VIDEO_O_V_RET,
  VIDEO_I_H     => VIDEO_O_H_RET    ,   --VIDEO_O_H_BATTERY_DISP   ,--VIDEO_O_H_OSD   ,--VIDEO_O_H_BATTERY_DISP   ,--VIDEO_O_H_INFO_DISP   , --VIDEO_O_H_GYRO_DATA_DISP   ,--VIDEO_O_H_OSD   ,--ADD_LOGO_O_H    ,--VIDEO_O_H_BATTERY_DISP   ,--ADD_BORDER_O_H_MUX   ,--VIDEO_O_H_RET,   --VIDEO_O_H_BATTERY_DISP   ,--VIDEO_O_H_RET,   --VIDEO_O_H_INFO_DISP   , --ADD_BORDER_O_H     ,--VIDEO_O_H_RET,   --ADD_BORDER_O_H     ,--VIDEO_O_H_RET,    --ADD_LOGO_O_H    , --ADD_BORDER_O_H     ,--VIDEO_O_H_RET,
  VIDEO_I_EOI   => VIDEO_O_EOI_RET  , --VIDEO_O_EOI_BATTERY_DISP ,--VIDEO_O_EOI_OSD ,--VIDEO_O_EOI_BATTERY_DISP ,--VIDEO_O_EOI_INFO_DISP , --VIDEO_O_EOI_GYRO_DATA_DISP ,--VIDEO_O_EOI_OSD ,--ADD_LOGO_O_EOI  ,--VIDEO_O_EOI_BATTERY_DISP ,--ADD_BORDER_O_EOI_MUX ,--VIDEO_O_EOI_RET, --VIDEO_O_EOI_BATTERY_DISP ,--VIDEO_O_EOI_RET, --VIDEO_O_EOI_INFO_DISP , --ADD_BORDER_O_EOI   ,--VIDEO_O_EOI_RET, --ADD_BORDER_O_EOI   ,--VIDEO_O_EOI_RET,  --ADD_LOGO_O_EOI  , --ADD_BORDER_O_EOI   ,--VIDEO_O_EOI_RET,
  VIDEO_I_DAV   => VIDEO_O_DAV_RET  , --VIDEO_O_DAV_BATTERY_DISP ,--VIDEO_O_DAV_OSD ,--VIDEO_O_DAV_BATTERY_DISP ,--VIDEO_O_DAV_INFO_DISP , --VIDEO_O_DAV_GYRO_DATA_DISP ,--VIDEO_O_DAV_OSD ,--ADD_LOGO_O_DAV  ,--VIDEO_O_DAV_BATTERY_DISP ,--ADD_BORDER_O_DAV_MUX ,--VIDEO_O_DAV_RET, --VIDEO_O_DAV_BATTERY_DISP ,--VIDEO_O_DAV_RET, --VIDEO_O_DAV_INFO_DISP,  --ADD_BORDER_O_DAV    ,--VIDEO_O_DAV_RET, --ADD_BORDER_O_DAV   ,--VIDEO_O_DAV_RET,  --ADD_LOGO_O_DAV  , --ADD_BORDER_O_DAV   ,--VIDEO_O_DAV_RET,
  VIDEO_I_DATA  => VIDEO_O_DATA_RET1,--VIDEO_O_DATA_BATTERY_DISP,--VIDEO_O_DATA_OSD,--VIDEO_O_DATA_BATTERY_DISP,--VIDEO_O_DATA_INFO_DISP, --VIDEO_O_DATA_GYRO_DATA_DISP,--VIDEO_O_DATA_OSD,--ADD_LOGO_O_DATA ,--VIDEO_O_DATA_BATTERY_DISP,--ADD_BORDER_O_DATA_MUX,--VIDEO_O_DATA_RET,--VIDEO_O_DATA_BATTERY_DISP,--VIDEO_O_DATA_RET,--VIDEO_O_DATA_INFO_DISP ,--ADD_BORDER_O_DATA ,--VIDEO_O_DATA_RET,--ADD_BORDER_O_DATA  ,--VIDEO_O_DATA_RET, --ADD_LOGO_O_DATA , --ADD_BORDER_O_DATA  ,--VIDEO_O_DATA_RET,
--  VIDEO_I_XSIZE => ADD_LOGO_O_XSIZE, --ADD_BORDER_O_XSIZE ,--VIDEO_O_XSIZE_RET,
--  VIDEO_I_YSIZE => ADD_LOGO_O_YSIZE, --ADD_BORDER_O_YSIZE ,--VIDEO_O_YSIZE_RET,
  --VIDEO_I_XCNT  : in  std_logic_vector( 9 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
  --VIDEO_I_YCNT  : in  std_logic_vector( 9 downto 0);  -- Video Y Line  Counter (1st line  = 0)

  VIDEO_O_V     => BT656_V      ,
  VIDEO_O_H     => BT656_H      ,
  VIDEO_O_EOI   => BT656_EOI      ,
  VIDEO_O_DAV   => BT656_DAV      ,
  VIDEO_O_DATA  => BT656_DATA_1      
--  VIDEO_O_XSIZE => BT656_XSIZE     ,
--  VIDEO_O_YSIZE => BT656_YSIZE      
  --VIDEO_O_XCNT  : out std_logic_vector( 9 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
  --VIDEO_O_YCNT  : out std_logic_vector( 9 downto 0)   -- Video Y Line  Counter (1st line  = 0)
  );


BT656_DATA_2(15 downto 8) <= std_logic_vector(to_unsigned (16,8)) when unsigned(BT656_DATA_1(15 downto 8))< to_unsigned (16,8) else 
                std_logic_vector(to_unsigned (254,8)) when unsigned(BT656_DATA_1(15 downto 8))> to_unsigned (254,8) else
                BT656_DATA_1(15 downto 8);
BT656_DATA_2(7 downto 0) <= std_logic_vector(to_unsigned (16,8)) when unsigned(BT656_DATA_1(7 downto 0))< to_unsigned (16,8) else 
                                std_logic_vector(to_unsigned (254,8)) when unsigned(BT656_DATA_1(7 downto 0))> to_unsigned (254,8) else
                                BT656_DATA_1(7 downto 0);


BT656_RST <=  RST or not(BT656_START) or (not sel_oled_analog_video_out);

-- i_bt656: bt656_gen_new2
--  generic map(
--          LIN_BITS => PIX_BITS,
--          PIX_BITS => LIN_BITS
--  )
--  port map(
--    clk               => CLK,
--    reset             => BT656_RST,--RST,
--    video_i_v         => BT656_V,
--    video_i_h         => BT656_H,
--    video_i_dav       => BT656_DAV,
--    video_i_data      => BT656_DATA_2,
--    video_i_eoi       => BT656_EOI,
--    video_i_xsize     => BT656_XSIZE, --std_logic_vector(to_unsigned(716,PIX_BITS)),--BT656_XSIZE,
--    video_i_ysize     => BT656_YSIZE,--std_logic_vector(to_unsigned(576,LIN_BITS)),--BT656_YSIZE,

--    bt656_run         => SCALER_RUN,
--    bt656_req_v       => BT656_REQ_V,
--    bt656_req_h       => BT656_REQ_H,
--    bt656_field       => BT656_FIELD,
--    bt656_line_no     => BT656_LINE_NO,
--    bt656_req_xsize   => BT656_REQ_XSIZE,
--    bt656_req_ysize   => BT656_REQ_YSIZE,
--    PAL_nNTSC         => PAL_nNTSC,

--    clk27             => CLK_27MHZ,
--    bt656_data        => bt656_data
--  );  

--      latch_fit_to_screen_en <= '0';     
i_bt656: bt656_gen_new2
  generic map(
          LIN_BITS => LIN_BITS,
          PIX_BITS => 11
  )
  port map(
    clk               => CLK,--CLK_54MHZ,--CLK,
    reset             => BT656_RST,--RST,
--    fit_to_screen_en  => mux_fit_to_screen_en,
--    latch_fit_to_screen_en => latch_mux_fit_to_screen_en,    
    scaling_disable  => '1',--mux_scaling_disable,
    latch_scaling_disable => open,--latch_mux_scaling_disable, 
    img_up_shift_vert     => IMG_UP_SHIFT_VERT,
    latch_img_up_shift_vert => LATCH_IMG_UP_SHIFT_VERT,
    add_border_i_xsize    => BT656_ADD_BORDER_I_XSIZE,
    add_border_i_ysize    => BT656_ADD_BORDER_I_YSIZE,
    video_i_v         => BT656_V,
    video_i_h         => BT656_H,
    video_i_dav       => BT656_DAV,
    video_i_data      => BT656_DATA_2,
    video_i_eoi       => BT656_EOI,
    video_i_xsize     => std_logic_vector(to_unsigned(716,11)),--BT656_XSIZE, --std_logic_vector(to_unsigned(716,PIX_BITS)),--BT656_XSIZE,
    video_i_ysize     => std_logic_vector(to_unsigned(576,LIN_BITS)),--BT656_YSIZE,--std_logic_vector(to_unsigned(576,LIN_BITS)),--BT656_YSIZE,

    bt656_run         => SCALER_RUN,
    bt656_req_v       => BT656_REQ_V,--SCALER_BIL_REQ_V,--BT656_REQ_V,
    bt656_req_h       => BT656_REQ_H,--SCALER_BIL_REQ_H,--BT656_REQ_H,
    bt656_field       => BT656_FIELD,
    bt656_line_no     => BT656_LINE_NO,--SCALER_BIL_LINE_NO  ,--BT656_LINE_NO,
    bt656_req_xsize   => BT656_REQ_XSIZE,--SCALER_BIL_REQ_XSIZE,--BT656_REQ_XSIZE,
    bt656_req_ysize   => BT656_REQ_YSIZE,--SCALER_BIL_REQ_YSIZE,--BT656_REQ_YSIZE,
    PAL_nNTSC         => PAL_nNTSC,

    clk27             => CLK_27MHZ,
    rst27             => BT656_RST,
    bt656_data        => bt656_data
  );  
           





                      
-- FPGA_B2B_M_BT656_D  <= bt656_data;        
 FPGA_DAC_P          <= bt656_data;    
 FPGA_DAC_CLK        <=  CLK_27MHZ;
-- FPGA_B2B_M_BT656_CLK <= INV_CLK_27MHZ;--CLK_27MHZ;


----process(CLK, RST)                
----    begin                             
----    if RST = '1' then              
----        USB_V    <= '0';
----        USB_H    <= '0';
----        USB_DAV  <= '0';
----        USB_DATA <= (others=>'0');
----        USB_EOI  <= '0';
----        latch_sel_raw <= '0';  

----    elsif rising_edge(CLK)then
----        if(BT656_EOI = '1')then
----            latch_sel_raw <= sel_raw;
----        end if;    
----        if(latch_sel_raw = '1')then
----            USB_V    <= VIDEO_O_V_TE    ;--VIDEO_I_V_SN   ;
----            USB_H    <= VIDEO_O_H_TE    ;--VIDEO_I_H_SN   ;
----            USB_DAV  <= VIDEO_O_DAV_TE  ;--VIDEO_I_DAV_SN ;
----            USB_DATA <= VIDEO_O_DATA_TE(7 downto 0) & "00" &VIDEO_O_DATA_TE(13 downto 8) ;--"00" &VIDEO_I_DATA_SN;
----            USB_EOI  <= VIDEO_O_EOI_TE; --VIDEO_I_EOI_SN ;
----        else             
----            USB_V    <= BT656_V;      
----            USB_H    <= BT656_H;      
----            USB_DAV  <= BT656_DAV;    
----            USB_DATA <= BT656_DATA_2; 
----            USB_EOI  <= BT656_EOI;     
----        end if;      
----    end if;
----end process;     
    

-- i_usb_video_data_input_gen: usb_video_data_input_gen
--  generic map(
--          LIN_BITS => PIX_BITS,
--          PIX_BITS => LIN_BITS,
--          DATA_BITS => 16
--  )
--  port map(
--    clk               => CLK,--CLK_54MHZ,--CLK,
--    rst               => BT656_RST,--RST,
--    video_i_v         => BT656_V,      --USB_V,   --BT656_V,
--    video_i_h         => BT656_H,      --USB_H,   --BT656_H,
--    video_i_dav       => BT656_DAV,    --USB_DAV, --BT656_DAV,
--    video_i_data      => BT656_DATA_2, --USB_DATA,--BT656_DATA_2,
--    video_i_eoi       => BT656_EOI,    --USB_EOI, --BT656_EOI,
--    video_i_xsize     => BT656_XSIZE, --std_logic_vector(to_unsigned(716,PIX_BITS)),--BT656_XSIZE,
--    video_i_ysize     => BT656_YSIZE,--std_logic_vector(to_unsigned(576,LIN_BITS)),--BT656_YSIZE,
--    video_req_xsize   => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),--std_logic_vector(to_unsigned(USB_VIDEO_XSIZE,PIX_BITS)),
--    video_req_ysize   => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),--std_logic_vector(to_unsigned(USB_VIDEO_YSIZE,LIN_BITS)), 
--    add_left_pix      => std_logic_vector(to_unsigned(VIDEO_ADD_LEFT_PIX,PIX_BITS)),    
--    add_right_pix     => std_logic_vector(to_unsigned(VIDEO_ADD_RIGHT_PIX,LIN_BITS)),   
--    video_o_v         => VIDEO_V_PROC,      
--    video_o_h         => VIDEO_H_PROC,      
--    video_o_eoi       => VIDEO_EOI_PROC, 
--    video_o_dav       => VIDEO_DAV_PROC, 
--    video_o_data      => VIDEO_DATA_PROC
--  );  



----process(CLK, RST)                
----    begin                             
----    if RST = '1' then              
----        USB_V    <= '0';
----        USB_H    <= '0';
----        USB_DAV  <= '0';
----        USB_DATA <= (others=>'0');
----        USB_EOI  <= '0';
----        latch_sel_raw <= '0';  
----        USB_VIDEO_XSIZE <= std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS));
----        USB_VIDEO_YSIZE <= std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS));
----    elsif rising_edge(CLK)then
----        if(USB_EOI_PROC = '1' and latch_sel_raw = '0')then
------            latch_sel_raw <= sel_raw;
----            latch_sel_raw <= FPGA_B2B_M_GPIO3;
----        elsif(VIDEO_I_EOI_SN = '1' and latch_sel_raw = '1')then
----            latch_sel_raw <= FPGA_B2B_M_GPIO3;
----        end if;    
------        if(latch_sel_raw = '1')then
------        if(sel_raw = '1')then
------        if(FPGA_B2B_M_GPIO3 = '1')then
----          if(latch_sel_raw ='1')then
----            USB_V           <= VIDEO_I_V_SN   ;--VIDEO_O_V_TE    ;
----            USB_H           <= VIDEO_I_H_SN   ;--VIDEO_O_H_TE    ;
----            USB_DAV         <= VIDEO_I_DAV_SN ;--VIDEO_O_DAV_TE  ;
----            USB_DATA        <= VIDEO_I_DATA_SN(7 downto 0) & "00" &VIDEO_I_DATA_SN(13 downto 8); -- VIDEO_O_DATA_TE(7 downto 0) & "00" &VIDEO_O_DATA_TE(13 downto 8) ;
----            USB_EOI         <= VIDEO_I_EOI_SN ;--VIDEO_O_EOI_TE;
----            USB_VIDEO_XSIZE <= image_width_full;
----            USB_VIDEO_YSIZE <= std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS));
----        else             
----            USB_V    <= VIDEO_V_PROC;    
----            USB_H    <= VIDEO_H_PROC;     
----            USB_DAV  <= VIDEO_DAV_PROC;   
----            USB_DATA <= VIDEO_DATA_PROC;  
----            USB_EOI  <= VIDEO_EOI_PROC; 
----            USB_VIDEO_XSIZE <= std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS));
----            USB_VIDEO_YSIZE <= std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS));  
----        end if;      
----    end if;
----end process;     
    
--VIDEO_I_DATA_SN_1 <= "00"& VIDEO_I_DATA_SN;

--usb_video_data_out_mux : entity WORK.usb_video_data_out_mux
--  generic map( 

--    PIX_BITS  => PIX_BITS,                   -- 2**PIX_BITS = Maximum Number of pixels in a line
--    LIN_BITS  => LIN_BITS,                   -- 2**LIN_BITS = Maximum Number of  lines in an image  
--    DATA_BITS => 16               
--  )
--  port map(
--    -- Clock and Reset
--    clk                         => CLK                  ,            -- Module Clock
--    rst                         => RST                  ,            -- Module Reset (Asynchronous active high)
--    mux_sel                     => usb_video_data_out_sel,--FPGA_B2B_M_GPIO3     ,            -- USB data out selection signal
--    video_i_v_sn                => VIDEO_I_V_SN         ,
--    video_i_h_sn                => VIDEO_I_H_SN         ,
--    video_i_dav_sn              => VIDEO_I_DAV_SN       ,
--    video_i_data_sn             => VIDEO_I_DATA_SN_1    ,
--    video_i_eoi_sn              => VIDEO_I_EOI_SN       ,
--    video_i_xsize_sn            => image_width_full     ,
--    video_i_ysize_sn            => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),
--    video_v_proc                => VIDEO_V_PROC         ,
--    video_h_proc                => VIDEO_H_PROC         ,
--    video_dav_proc              => VIDEO_DAV_PROC       ,
--    video_data_proc             => VIDEO_DATA_PROC      ,
--    video_eoi_proc              => VIDEO_EOI_PROC       ,
--    video_xsize_proc            => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),
--    video_ysize_proc            => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),
--    disable_update_gfid_gsk     => disable_update_gfid_gsk,
--    usb_v                       => USB_V                ,
--    usb_h                       => USB_H                ,
--    usb_dav                     => USB_DAV              ,
--    usb_data                    => USB_DATA             ,
--    usb_eoi                     => USB_EOI              ,
--    usb_video_xsize             => USB_VIDEO_XSIZE      ,
--    usb_video_ysize             => USB_VIDEO_YSIZE
--  );




-- i_vsync_hsync_16bit_data: vsync_hsync_16bit_data
--  generic map(
--          LIN_BITS => PIX_BITS,
--          PIX_BITS => LIN_BITS
--  )
--  port map(
--    clk               => CLK,--CLK_54MHZ,--CLK,
--    reset             => BT656_RST,--RST,
--    tick1s            => TICK1S,
--    video_i_v         => USB_V,   --BT656_V,
--    video_i_h         => USB_H,   --BT656_H,
--    video_i_dav       => USB_DAV, --BT656_DAV,
--    video_i_data      => USB_DATA,--BT656_DATA_2,
--    video_i_eoi       => USB_EOI, --BT656_EOI,
--    video_i_xsize     => USB_VIDEO_XSIZE,--std_logic_vector(to_unsigned(USB_VIDEO_XSIZE,PIX_BITS)),--BT656_XSIZE, --std_logic_vector(to_unsigned(716,PIX_BITS)),--BT656_XSIZE,
--    video_i_ysize     => USB_VIDEO_YSIZE,--std_logic_vector(to_unsigned(USB_VIDEO_YSIZE,LIN_BITS)),--BT656_YSIZE,--std_logic_vector(to_unsigned(576,LIN_BITS)),--BT656_YSIZE,

--    bt656_run         => SCALER_RUN,
--    bt656_req_v       => BT656_REQ_V,
--    bt656_req_h       => BT656_REQ_H,

--    PAL_nNTSC         => PAL_nNTSC,

--    pclk                => CLK_54MHZ,--CLK_27MHZ,
--    video_o_frame_valid => video_o_frame_valid,
--    video_o_line_valid  => video_o_line_valid,
--    video_o_data        => video_o_data
--  );  
           

----i_TP_GEN_16BIT: entity WORK.TP_GEN_16BIT
----  generic map(
----   REQ_XSIZE => 1280,--800,
----   REQ_YSIZE => 720,--600,
----   TVS       => 2,
----   TAVS      => 5,
----   TAV       => 720,--600,
----   TVIDL     => 2,
----   THS       => 8,
----   TDES      => 12,
----   TLDATA    => 1280,--800,
----   THIDL     => 12,
----   PIX_BITS  => 11,
----   LIN_BITS  => 11
----  )
----  port map(

----    clk                 => CLK_27MHZ,-- CLK_13_5_MHZ,
----    rst                 =>  RST,
----    tick1ms             =>  TICK1S,--'0',--TICK1MS,  
----    sel_color_tp        => sel_color_tp,   
------    video_o_xsize  =>
------    video_o_ysize  =>
----    video_o_vsync       => video_o_vsync, --pulse for oled
----    video_o_hsync       => video_o_hsync, --pulse for oled
----    video_o_frame_valid => video_o_frame_valid, -- high during full frmae
----    video_o_line_valid  => video_o_line_valid,  -- high during full line
----    video_o_de          => video_o_de,
----    video_o_data        => video_o_data,
----    pix_cnt_out         => pix_cnt_out,
----    line_cnt_out        => line_cnt_out
----  );  

process(CLK, RST)begin
        if RST = '1' then
          frame_cnt1 <= (others=>'0');
          frame_cnt2 <= (others=>'0');
          frame_cnt3 <= (others=>'0');
        elsif rising_edge(CLK) then       
            if TICK1S = '1' then
              frame_cnt1 <= (others=>'0');
              frame_cnt2 <= (others=>'0');
              frame_cnt3 <= (others=>'0');
            else
                --if(MEM_IMG_SOI = '1')then  
                if(SCALER_O_V ='1')then
                      frame_cnt1 <= frame_cnt1 +1;
                end if;      
                if SCALER_BIL_REQ_V = '1'then
                      frame_cnt2 <= frame_cnt2 +1;
                end if;      
--                if SCALER_V = '1' then
                if VIDEO_MUX_OUT_V ='1' then
                      frame_cnt3 <= frame_cnt3 +1; 
                end if;
             end if;   
        end if;
  end process;   
     



scaler_rq_gen : If (OLED_EN = TRUE) Generate
process(clk,rst,sel_oled_analog_video_out)
begin 
if RST = '1'  or sel_oled_analog_video_out = '1' then
  SCALER_BIL_REQ_V <= '0';
  SCALER_BIL_REQ_H <= '0';
  line_ct              <= to_unsigned(0,line_ct'length);
  pix_ct               <= to_unsigned(0,pix_ct'length);
--  wait_h <= to_unsigned(160,wait_h'length);
--  wait_v <= to_unsigned(320,wait_v'length);
  wait_h               <= to_unsigned(0,wait_h'length);
  wait_v               <= to_unsigned(0,wait_v'length);
  SCALER_BIL_REQ_XSIZE <= std_logic_vector(to_unsigned(960,SCALER_BIL_REQ_XSIZE'length));--std_logic_vector(to_unsigned(800,SCALER_BIL_REQ_XSIZE'length));--std_logic_vector(to_unsigned(720,SCALER_BIL_REQ_XSIZE'length));--std_logic_vector(to_unsigned(1280,SCALER_BIL_REQ_XSIZE'length)); 
  SCALER_BIL_REQ_YSIZE <= std_logic_vector(to_unsigned(720,SCALER_BIL_REQ_YSIZE'length));--std_logic_vector(to_unsigned(600,SCALER_BIL_REQ_YSIZE'length));--std_logic_vector(to_unsigned(576,SCALER_BIL_REQ_YSIZE'length));--std_logic_vector(to_unsigned(720,SCALER_BIL_REQ_YSIZE'length)); --std_logic_vector(to_unsigned(600,SCALER_BIL_REQ_YSIZE'length));
  SCALER_BIL_LINE_NO   <= std_logic_vector(to_unsigned(0,SCALER_BIL_LINE_NO'length));
  wait_frame_time      <= to_unsigned(1320000,wait_frame_time'length);  -- for 50 fps at 66 MHZ 
  latch_fit_to_screen_en <= '0';
  latch_mux_scaling_disable <= '0';
  LATCH_IMG_UP_SHIFT_VERT   <= std_logic_vector(to_unsigned(0,IMG_UP_SHIFT_VERT'length));
elsif rising_edge(clk) then 
    SCALER_BIL_REQ_V <= '0';
    SCALER_BIL_REQ_H <= '0';
    SCALER_BIL_REQ_XSIZE <= std_logic_vector(to_unsigned(960,SCALER_BIL_REQ_XSIZE'length));--std_logic_vector(to_unsigned(800,SCALER_BIL_REQ_XSIZE'length));--std_logic_vector(to_unsigned(720,SCALER_BIL_REQ_XSIZE'length));--std_logic_vector(to_unsigned(1280,SCALER_BIL_REQ_XSIZE'length));--std_logic_vector(to_unsigned(800,SCALER_BIL_REQ_XSIZE'length));
    SCALER_BIL_REQ_YSIZE <= std_logic_vector(to_unsigned(720,SCALER_BIL_REQ_YSIZE'length));--std_logic_vector(to_unsigned(600,SCALER_BIL_REQ_YSIZE'length));--std_logic_vector(to_unsigned(576,SCALER_BIL_REQ_YSIZE'length));--std_logic_vector(to_unsigned(720,SCALER_BIL_REQ_YSIZE'length)); --std_logic_vector(to_unsigned(600,SCALER_BIL_REQ_YSIZE'length));
    
  case (fsm_scaler) is 
    when idle =>
      line_ct              <= to_unsigned(0,line_ct'length);
      pix_ct               <= to_unsigned(0,pix_ct'length);
      SCALER_BIL_LINE_NO   <= (others=>'0');
      wait_h               <= to_unsigned(0,wait_h'length);
      wait_v               <= to_unsigned(0,wait_v'length);
      wait_frame_time      <= to_unsigned(1320000,wait_frame_time'length); 
      if SCALER_RUN = '1' and BT656_START = '1' then
          fsm_scaler <= wait_run;
      end if;
        
    when wait_run =>
      line_ct <= to_unsigned(0,line_ct'length);
      pix_ct  <= to_unsigned(0,pix_ct'length);
      SCALER_BIL_LINE_NO <= (others=>'0');
      SCALER_BIL_REQ_V <= '1';
      fsm_scaler       <= wait_h_gen;

--      if wait_frame_time >= 1320000 then 
--        SCALER_BIL_REQ_V <= '1';
--        fsm_scaler       <= wait_h_gen;
--        wait_frame_time  <= to_unsigned(0,wait_frame_time'length);
--      else
--        wait_frame_time  <= wait_frame_time + 1;
--      end if;
    
    when wait_h_gen =>
      wait_frame_time <= wait_frame_time +1;
--      if(unsigned(fifo_usedw) < 12800)then
      if((unsigned(fifo_usedw) < 12800) and (wait_h = 0) )then 
        fsm_scaler <= gen_rq_h;
      end if;
      if (wait_h = 0)then  
        wait_h <= (others=>'0');
      else 
        wait_h <= wait_h - 1;
      end if;
--      if (wait_h = 0)then  
--        fsm_scaler <= gen_rq_h;
--      else 
--        wait_h <= wait_h - 1;
--      end if;

    when gen_rq_h =>
      wait_frame_time  <= wait_frame_time +1;
      SCALER_BIL_REQ_H <= '1';
      fsm_scaler       <= pixel_count;
      line_ct          <= line_ct +1;
      pix_ct           <= to_unsigned(0,pix_ct'length);

    when pixel_count =>
      wait_frame_time <= wait_frame_time +1;
--      if SCALER_O_DAV = '1' then
      if ADD_BORDER_O_DAV_MUX = '1' then 
        pix_ct <= pix_ct + 1;
      end if;
--      if (pix_ct = 799) then
--      if (pix_ct = 1279) then
--       if (pix_ct = 719) then
--      if (pix_ct = 1279) then
      if (pix_ct = 959) then
        if line_ct < 720 then
--        if line_ct < 576 then
--        if line_ct < 600 then
          fsm_scaler <= wait_h_gen;
--          wait_h     <= to_unsigned(320,wait_h'length);
--          wait_h <= to_unsigned(200,wait_h'length);
--          wait_h <= to_unsigned(477,wait_h'length);
          SCALER_BIL_LINE_NO <= std_logic_vector(unsigned(SCALER_BIL_LINE_NO) + to_unsigned(1,SCALER_BIL_LINE_NO'length));
--          wait_h <= to_unsigned(160,wait_h'length);
--          wait_h <= to_unsigned(200,wait_h'length);
           wait_h <= to_unsigned(130,wait_h'length);
--          wait_h <= to_unsigned(100,wait_h'length);
        else 
--          fsm_scaler <= WAIT_run;
          fsm_scaler <= wait_v_gen;
--          wait_v     <= to_unsigned(14000,wait_v'length);
          wait_v <= to_unsigned(320,wait_v'length);
        end if;
      end if;
    
    when wait_v_gen =>
      wait_frame_time <= wait_frame_time +1;
      if wait_v = 0 then 
        fsm_scaler <= wait_run;
        latch_fit_to_screen_en <= '0';--mux_fit_to_screen_en;
        latch_mux_scaling_disable <= '0';--mux_scaling_disable;
        LATCH_IMG_UP_SHIFT_VERT   <= IMG_UP_SHIFT_VERT;
--        if(mux_scaling_disable = '1')then
--          ADD_BORDER_I_XSIZE     <= STD_LOGIC_VECTOR(to_unsigned(640,11));
--          ADD_BORDER_I_YSIZE     <= STD_LOGIC_VECTOR(to_unsigned(480,10));  
--        else
--          ADD_BORDER_I_XSIZE     <= STD_LOGIC_VECTOR(to_unsigned(960,11));--STD_LOGIC_VECTOR(to_unsigned(800,11));--STD_LOGIC_VECTOR(to_unsigned(720,11));--STD_LOGIC_VECTOR(to_unsigned(1152,11));
--          ADD_BORDER_I_YSIZE     <= STD_LOGIC_VECTOR(to_unsigned(720,10));--STD_LOGIC_VECTOR(to_unsigned(600,10)) ;--STD_LOGIC_VECTOR(to_unsigned(576,10)) ;--STD_LOGIC_VECTOR(to_unsigned(720,10));           
--        end if;  
          ADD_BORDER_I_XSIZE     <= STD_LOGIC_VECTOR(to_unsigned(960,11));--STD_LOGIC_VECTOR(to_unsigned(800,11));--STD_LOGIC_VECTOR(to_unsigned(720,11));--STD_LOGIC_VECTOR(to_unsigned(1152,11));
          ADD_BORDER_I_YSIZE     <= STD_LOGIC_VECTOR(to_unsigned(720,10));--STD_LOGIC_VECTOR(to_unsigned(600,10)) ;--STD_LOGIC_VECTOR(to_unsigned(576,10)) ;--STD_LOGIC_VECTOR(to_unsigned(720,10));           
      else
        wait_v     <= wait_v -1;
      end if;
      
      
  end case;
end if;
end process;


end generate;
SCALER_O_DATA_1 <= SCALER_O_DATA & x"80";
TP_GEN_16BIT_RST <= RST or sel_oled_analog_video_out;
TO_GEN_16BIT_GEN:If (OLED_EN = TRUE) Generate
i_TP_GEN_16BIT: entity WORK.TP_GEN_16BIT
  generic map(
   REQ_XSIZE => 960,--800,--720,--1280,
   REQ_YSIZE => 720,--600,--576,--720,
   TVS       => 2,--5,--5,--2,
   TAVS      => 5,--44,--25,--5,
   TAV       => 720,--600,--576,--720,--600,
   TVIDL     => 2,--5,--5,--2,
   THS       => 20,--40,--8,
   TDES      => 30,--100,--260,--12,
   TLDATA    => 960,--800,--720,--1280,--800,
   THIDL     => 10,--180,--440,--12,
   PIX_BITS  => 11,--10,
   LIN_BITS  => 10 --10
  )
  port map(

    clk                 => CLK,-- CLK_13_5_MHZ,
    rst                 => TP_GEN_16BIT_RST,--RST,
    tick1ms             => TICK1S,--'0',--TICK1MS,  
    sel_color_tp        => sel_color_tp,   
    video_i_v           => BT656_V     ,--SCALER_O_V     ,--BT656_V     , --SCALER_O_V     , --BT656_V,
    video_i_h           => BT656_H     ,--SCALER_O_H     ,--BT656_H     , --SCALER_O_H     , --BT656_H,
    video_i_dav         => BT656_DAV   ,--SCALER_O_DAV   ,--BT656_DAV   , --SCALER_O_DAV   , --BT656_DAV,
    video_i_data        => BT656_DATA_2,--SCALER_O_DATA_1,--BT656_DATA_2, --SCALER_O_DATA_1, --BT656_DATA_2,
    video_i_eoi         => BT656_EOI   ,--SCALER_O_EOI   ,--BT656_EOI   , --SCALER_O_EOI   , --BT656_EOI,
    video_i_xsize       => std_logic_vector(to_unsigned(960,11)),--std_logic_vector(to_unsigned(720,11)),--std_logic_vector(to_unsigned(1280,11)),--std_logic_vector(to_unsigned(800,PIX_BITS)), --BT656_XSIZE, --std_logic_vector(to_unsigned(716,PIX_BITS)),--BT656_XSIZE,
    video_i_ysize       => std_logic_vector(to_unsigned(720,LIN_BITS)),--std_logic_vector(to_unsigned(576,LIN_BITS)),--std_logic_vector(to_unsigned(720,LIN_BITS)),--std_logic_vector(to_unsigned(600,LIN_BITS)), --BT656_YSIZE,
    pclk                => CLK_74_25MHZ,--CLK,--CLK_54MHZ,--CLK_27MHZ,
    video_o_vsync       => video_o_vsync, --pulse for oled
    video_o_hsync       => video_o_hsync, --pulse for oled
    video_o_frame_valid => video_o_frame_valid, -- high during full frmae
    video_o_line_valid  => video_o_line_valid,  -- high during full line
    video_o_de          => video_o_de,
    video_o_data        => video_o_data,
    pix_cnt_out         => open,
    line_cnt_out        => line_cnt_out,
    fifo_usedw          => fifo_usedw
    
  );  

-- i_TP_GEN_16BIT: entity WORK.TP_GEN_16BIT
--  generic map(
--   REQ_XSIZE => 1280,--800,
--   REQ_YSIZE => 720,--600,
--   TVS       => 5,
--   TAVS      => 25,
--   TAV       => 720,--600,
--   TVIDL     => 5,
--   THS       => 40,
--   TDES      => 260,
--   TLDATA    => 1280,--800,
--   THIDL     => 440,
--   PIX_BITS  => 11,
--   LIN_BITS  => 10
--  )
--  port map(

--    clk            =>  CLK_74_25MHZ,
--    rst            =>  RST,
--    tick1ms         => '0', 
--    sel_color_tp    => '0',
----    video_o_xsize  =>
----    video_o_ysize  =>
--    video_o_vsync  => video_o_vsync,
--    video_o_hsync  => video_o_hsync,
--    video_o_frame_valid => video_o_frame_valid, -- high during full frmae
--    video_o_line_valid  => video_o_line_valid,  -- high during full line    
--    video_o_de     => video_o_de,
--    video_o_data   => video_o_data,
--    pix_cnt_out    => open,
--    line_cnt_out   => open
--  );  
--i_HD_TEST_PATTERN_GEN :HD_TEST_PATTERN_GEN 
--port map(
--    hd_clk  => CLK_74_25MHZ,--CLK_148_5MHZ  ,
--    rst     => RST ,
--    hsync   => video_o_hsync    ,
--    vsync   => video_o_vsync    ,
--    data_enable => video_o_de  ,
--    hd_data => video_o_data --hd_data
--); 
     
FPGA_B2B_M_BT656_CLK <= not CLK_74_25MHZ;--CLK_148_5MHZ;--CLK_27MHZ;--not CLK_54MHZ;--CLK_27MHZ;
FPGA_B2B_M_PVO_VSYNC <= video_o_vsync;--video_o_frame_valid;--video_o_vsync;
FPGA_B2B_M_PVO_HSYNC <= video_o_hsync;--video_o_line_valid;--video_o_de;--video_o_hsync;
FPGA_B2B_M_BT656_D   <= video_o_data(7 downto 0);--hd_data(7 downto 0);--bt656_data;--video_o_data(7 downto 0);
FPGA_B2B_M_PVO8      <= video_o_data(8) ;--hd_data(8) ;--video_o_data(8) ; --video_o_data(0) ;  
FPGA_B2B_M_PVO9      <= video_o_data(9) ;--hd_data(9) ;--video_o_data(9) ; --video_o_data(1) ;  
FPGA_B2B_M_PVO10     <= video_o_data(10);--hd_data(10);--video_o_data(10); --video_o_data(2);   
FPGA_B2B_M_PVO11     <= video_o_data(11);--hd_data(11);--video_o_data(11); --video_o_data(3);   
FPGA_B2B_M_PVO12     <= video_o_data(12);--hd_data(12);--video_o_data(12); --video_o_data(4);   
FPGA_B2B_M_PVO13     <= video_o_data(13);--hd_data(13);--video_o_data(13); --video_o_data(5);   
FPGA_B2B_M_PVO14     <= video_o_data(14);--hd_data(14);--video_o_data(14); --video_o_data(6);   
FPGA_B2B_M_PVO15     <= video_o_data(15);--hd_data(15);--video_o_data(15); --video_o_data(7);   
OLED_DATAEN          <= video_o_de;  
end generate;

video_data_input_gen :If (MIPI_EN = TRUE or USB_EN = TRUE or EK_EN = TRUE) Generate

 i_usb_video_data_input_gen: usb_video_data_input_gen
  generic map(
          LIN_BITS => PIX_BITS,
          PIX_BITS => LIN_BITS,
          DATA_BITS => 16
  )
  port map(
    clk               => CLK,--CLK_54MHZ,--CLK,
    rst               => BT656_RST,--RST,
    video_i_v         => BT656_V,      --USB_V,   --BT656_V,
    video_i_h         => BT656_H,      --USB_H,   --BT656_H,
    video_i_dav       => BT656_DAV,    --USB_DAV, --BT656_DAV,
    video_i_data      => BT656_DATA_2, --USB_DATA,--BT656_DATA_2,
    video_i_eoi       => BT656_EOI,    --USB_EOI, --BT656_EOI,
    video_i_xsize     => BT656_XSIZE, --std_logic_vector(to_unsigned(716,PIX_BITS)),--BT656_XSIZE,
    video_i_ysize     => BT656_YSIZE,--std_logic_vector(to_unsigned(576,LIN_BITS)),--BT656_YSIZE,
    video_req_xsize   => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),--std_logic_vector(to_unsigned(USB_VIDEO_XSIZE,PIX_BITS)),
    video_req_ysize   => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),--std_logic_vector(to_unsigned(USB_VIDEO_YSIZE,LIN_BITS)), 
    add_left_pix      => std_logic_vector(to_unsigned(VIDEO_ADD_LEFT_PIX,PIX_BITS)),    
    add_right_pix     => std_logic_vector(to_unsigned(VIDEO_ADD_RIGHT_PIX,LIN_BITS)),   
    video_o_v         => VIDEO_V_PROC,      
    video_o_h         => VIDEO_H_PROC,      
    video_o_eoi       => VIDEO_EOI_PROC, 
    video_o_dav       => VIDEO_DAV_PROC, 
    video_o_data      => VIDEO_DATA_PROC
  );  

end generate;

mipi_video_data_out_mux_gen :If (MIPI_EN = TRUE ) Generate

VIDEO_O_DATA_BC1 <= VIDEO_O_DATA_BC & x"80";
usb_video_data_out_mux : entity WORK.usb_video_data_out_mux
  generic map( 
    PIX_BITS  => PIX_BITS,                   -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS  => LIN_BITS,                   -- 2**LIN_BITS = Maximum Number of  lines in an image  
    DATA_BITS => 16               
  )  
  port map(
    -- Clock and Reset
    clk                         => CLK                    ,            -- Module Clock
    rst                         => RST                    ,            -- Module Reset (Asynchronous active high)
    mux_sel                     => mipi_video_data_out_sel,--FPGA_B2B_M_GPIO3     ,            -- USB data out selection signal
    video_i_v_sn                => VIDEO_O_BADP_V     ,--VIDEO_O_NUC_V  ,        --VIDEO_I_V_SN         ,
    video_i_h_sn                => VIDEO_O_BADP_H     ,--VIDEO_O_NUC_H  ,        --VIDEO_I_H_SN         ,
    video_i_dav_sn              => VIDEO_O_BADP_DAV   ,--VIDEO_O_NUC_DAV,        --VIDEO_I_DAV_SN       ,
    video_i_data_sn             => VIDEO_O_BADP_DATA1 ,--VIDEO_O_BADP_DATA_1     --VIDEO_I_DATA_SN_1    ,
    video_i_eoi_sn              => VIDEO_O_BADP_EOI   ,--VIDEO_O_NUC_EOI,        --VIDEO_I_EOI_SN       ,       ,
    video_i_xsize_sn            => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)), --image_width_full     ,
    video_i_ysize_sn            => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),
    video_v_proc                => VIDEO_O_V_BC    ,--VIDEO_V_PROC         ,VIDEO_V_PROC         ,
    video_h_proc                => VIDEO_O_H_BC    ,--VIDEO_H_PROC         ,VIDEO_H_PROC         ,
    video_dav_proc              => VIDEO_O_DAV_BC  ,--VIDEO_DAV_PROC       ,VIDEO_DAV_PROC       ,
    video_data_proc             => VIDEO_O_DATA_BC1 ,--VIDEO_DATA_PROC      ,VIDEO_DATA_PROC      ,
    video_eoi_proc              => VIDEO_O_EOI_BC  ,--VIDEO_EOI_PROC       ,VIDEO_EOI_PROC       ,
    video_xsize_proc            => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),
    video_ysize_proc            => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),
    disable_update_gfid_gsk     => open                  ,
    usb_v                       => MIPI_USB_V                ,
    usb_h                       => MIPI_USB_H                ,
    usb_dav                     => MIPI_USB_DAV              ,
    usb_data                    => MIPI_USB_DATA             ,
    usb_eoi                     => MIPI_USB_EOI              ,
    usb_video_xsize             => MIPI_USB_VIDEO_XSIZE      ,
    usb_video_ysize             => MIPI_USB_VIDEO_YSIZE
  );

end generate;

--process(CLK, RST)
--    begin
--    if RST = '1' then
--        i_raw_video_v     <= '0';
--        i_raw_video_h   <= '0';
--        i_raw_video_dav <= '0';
--        i_raw_video_data<= (others=>'0');
--        i_raw_video_eoi <= '0';
--        i_raw_video_v_d   <= '0';
--        i_raw_video_h_d   <= '0';
--        i_raw_video_dav_d <= '0';
--        i_raw_video_data_d<= (others=>'0');
--        i_raw_video_eoi_d <= '0';
--        y_cnt <= (others=>'0');
--    elsif rising_edge(CLK) then
--        if(raw_video_v = '1') then
--            y_cnt <= (others=>'0');
--        elsif(raw_video_h ='1')then
--            y_cnt <= y_cnt + 1;
--        end if;

--        i_raw_video_v    <= raw_video_v   ;
--        i_raw_video_h    <= raw_video_h    ;
--        i_raw_video_dav  <= raw_video_dav  ;
--        i_raw_video_data <= raw_video_data; 
--        i_raw_video_eoi  <= raw_video_eoi ; 
        
--        i_raw_video_v_d    <= raw_video_v; 
--        if(y_cnt < 519)then  
--            i_raw_video_h_d    <= i_raw_video_h ;   
--            i_raw_video_dav_d  <= i_raw_video_dav;  
--            i_raw_video_data_d <= i_raw_video_data;      
--        else
--            i_raw_video_h_d    <= '0' ;   
--            i_raw_video_dav_d  <= '0';  
--            i_raw_video_data_d <= (others=>'0');  
--        end if;            
--        i_raw_video_eoi_d  <= i_raw_video_eoi;
--    end if;
--end process;   


usb_video_data_out_mux_gen :If (USB_EN = TRUE or EK_EN = TRUE ) Generate

--VIDEO_I_DATA_SN_1 <= "00"& VIDEO_I_DATA_SN;

usb_video_data_out_mux : entity WORK.usb_video_data_out_mux
  generic map( 
    PIX_BITS  => PIX_BITS,                   -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS  => LIN_BITS,                   -- 2**LIN_BITS = Maximum Number of  lines in an image  
    DATA_BITS => 16               
  )  
  port map(
    -- Clock and Reset
    clk                         => CLK                    ,            -- Module Clock
    rst                         => RST                    ,            -- Module Reset (Asynchronous active high)
    mux_sel                     => mipi_video_data_out_sel,--FPGA_B2B_M_GPIO3     ,            -- USB data out selection signal
    video_i_v_sn                => VIDEO_O_BADP_V     ,--VIDEO_O_NUC_V  ,        --VIDEO_I_V_SN         ,
    video_i_h_sn                => VIDEO_O_BADP_H     ,--VIDEO_O_NUC_H  ,        --VIDEO_I_H_SN         ,
    video_i_dav_sn              => VIDEO_O_BADP_DAV   ,--VIDEO_O_NUC_DAV,        --VIDEO_I_DAV_SN       ,
    video_i_data_sn             => VIDEO_O_BADP_DATA1 ,--VIDEO_O_BADP_DATA_1     --VIDEO_I_DATA_SN_1    ,
    video_i_eoi_sn              => VIDEO_O_BADP_EOI   ,--VIDEO_O_NUC_EOI,        --VIDEO_I_EOI_SN       ,       ,
    video_i_xsize_sn            => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)), --image_width_full     ,
    video_i_ysize_sn            => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),
    video_v_proc                => VIDEO_V_PROC         ,
    video_h_proc                => VIDEO_H_PROC         ,
    video_dav_proc              => VIDEO_DAV_PROC       ,
    video_data_proc             => VIDEO_DATA_PROC      ,
    video_eoi_proc              => VIDEO_EOI_PROC       ,
    video_xsize_proc            => std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),
    video_ysize_proc            => std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),
    disable_update_gfid_gsk     => open                  ,
    usb_v                       => USB_V                ,
    usb_h                       => USB_H                ,
    usb_dav                     => USB_DAV              ,
    usb_data                    => USB_DATA             ,
    usb_eoi                     => USB_EOI              ,
    usb_video_xsize             => USB_VIDEO_XSIZE      ,
    usb_video_ysize             => USB_VIDEO_YSIZE
  );

usb_video_data_out_sel_mux <= usb_video_data_out_sel or usb_video_data_out_sel_reg;
usb_video_data_out_mux1 : entity WORK.usb_video_data_out_mux
  generic map( 
    PIX_BITS  => PIX_BITS,                   -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS  => LIN_BITS,                   -- 2**LIN_BITS = Maximum Number of  lines in an image  
    DATA_BITS => 16               
  )  
  port map(
    -- Clock and Reset
    clk                         => CLK                    ,            -- Module Clock
    rst                         => RST                    ,            -- Module Reset (Asynchronous active high)
    mux_sel                     => usb_video_data_out_sel_mux,--FPGA_B2B_M_GPIO3     ,            -- USB data out selection signal
    video_i_v_sn                => raw_video_v   , --VIDEO_I_V_SN         ,
    video_i_h_sn                => raw_video_h    , --VIDEO_I_H_SN         ,
    video_i_dav_sn              => raw_video_dav  , --VIDEO_I_DAV_SN       ,
    video_i_data_sn             => raw_video_data , --VIDEO_I_DATA_SN_1    ,
    video_i_eoi_sn              => raw_video_eoi  , --VIDEO_I_EOI_SN       ,      
    video_i_xsize_sn            => raw_video_xsize,--std_logic_vector(to_unsigned(664,PIX_BITS)), -- raw_video_xsize, --image_width_full     ,
    video_i_ysize_sn            => raw_video_ysize,--std_logic_vector(to_unsigned(518,LIN_BITS)), -- raw_video_ysize,
    video_v_proc                => USB_V          ,
    video_h_proc                => USB_H          ,
    video_dav_proc              => USB_DAV        ,
    video_data_proc             => USB_DATA       ,
    video_eoi_proc              => USB_EOI        ,
    video_xsize_proc            => USB_VIDEO_XSIZE,
    video_ysize_proc            => USB_VIDEO_YSIZE,
    disable_update_gfid_gsk     => open                  ,
    usb_v                       => MIPI_USB_V                ,
    usb_h                       => MIPI_USB_H                ,
    usb_dav                     => MIPI_USB_DAV              ,
    usb_data                    => MIPI_USB_DATA             ,
    usb_eoi                     => MIPI_USB_EOI              ,
    usb_video_xsize             => MIPI_USB_VIDEO_XSIZE      ,
    usb_video_ysize             => MIPI_USB_VIDEO_YSIZE
  );


end generate;


video_data_out_vsync_hsync_gen :If (MIPI_EN = TRUE or USB_EN = TRUE or EK_EN = TRUE) Generate
i_vsync_hsync_16bit_data: vsync_hsync_16bit_data
  generic map(
          LIN_BITS => PIX_BITS,
          PIX_BITS => LIN_BITS
  )
  port map(
    clk               => CLK,--CLK_54MHZ,--CLK,
    reset             => BT656_RST,--RST,
    tick1s            => TICK1S,
    video_i_v         => MIPI_USB_V   ,--VIDEO_V_PROC,   --USB_V,   --BT656_V,
    video_i_h         => MIPI_USB_H   ,--VIDEO_H_PROC,   --USB_H,   --BT656_H,
    video_i_dav       => MIPI_USB_DAV ,--VIDEO_DAV_PROC, --USB_DAV, --BT656_DAV,
    video_i_data      => MIPI_USB_DATA,--VIDEO_DATA_PROC,--USB_DATA,--BT656_DATA_2,
    video_i_eoi       => MIPI_USB_EOI ,--VIDEO_EOI_PROC, --USB_EOI, --BT656_EOI,
    video_i_xsize     => MIPI_USB_VIDEO_XSIZE,--std_logic_vector(to_unsigned(VIDEO_XSIZE,PIX_BITS)),--USB_VIDEO_XSIZE,--std_logic_vector(to_unsigned(USB_VIDEO_XSIZE,PIX_BITS)),--BT656_XSIZE, --std_logic_vector(to_unsigned(716,PIX_BITS)),--BT656_XSIZE,
    video_i_ysize     => MIPI_USB_VIDEO_YSIZE,--std_logic_vector(to_unsigned(VIDEO_YSIZE,LIN_BITS)),--USB_VIDEO_YSIZE,--std_logic_vector(to_unsigned(USB_VIDEO_YSIZE,LIN_BITS)),--BT656_YSIZE,--std_logic_vector(to_unsigned(576,LIN_BITS)),--BT656_YSIZE,

    bt656_run         => SCALER_RUN,
    bt656_req_v       => BT656_REQ_V,
    bt656_req_h       => BT656_REQ_H,

    PAL_nNTSC         => PAL_nNTSC,

    pclk                => CLK,--CLK_54MHZ,--CLK_27MHZ,
    video_o_frame_pulse => video_o_frame_pulse,
    video_o_frame_valid => video_o_frame_valid,
    video_o_line_valid  => video_o_line_valid,
    video_o_data        => video_o_data
  );  

--i_TP_GEN_16BIT: entity WORK.TP_GEN_16BIT
--  generic map(
--   REQ_XSIZE => 664,
--   REQ_YSIZE => 518,
--   TVS       => 2,
--   TAVS      => 5,
--   TAV       => 518,
--   TVIDL     => 2,
--   THS       => 8,
--   TDES      => 150,--12,
--   TLDATA    => 664,
--   THIDL     => 150,--12,
--   PIX_BITS  => 10,
--   LIN_BITS  => 10
--  )
--  port map(

--    clk                 => CLK,-- CLK_13_5_MHZ,
--    rst                 => RST,
--    tick1ms             => TICK1S,--'0',--TICK1MS,  
--    sel_color_tp        => sel_color_tp,   
--    video_o_vsync       => video_o_vsync, --pulse for oled
--    video_o_hsync       => video_o_hsync, --pulse for oled
--    video_o_frame_valid => video_o_frame_valid, -- high during full frmae
--    video_o_line_valid  => video_o_line_valid,  -- high during full line
--    video_o_de          => video_o_de,
--    video_o_data        => video_o_data,
--    pix_cnt_out         => pix_cnt_out,
--    line_cnt_out        => line_cnt_out
--  );    
  
FPGA_B2B_M_BT656_CLK <= CLK_54MHZ when parallel_16bit_en = '1' else INV_CLK_27MHZ;--CLK_27MHZ;
FPGA_B2B_M_PVO_VSYNC <= video_o_frame_valid;--video_o_vsync;
FPGA_B2B_M_PVO_HSYNC <= video_o_line_valid;--video_o_de;--video_o_hsync;
FPGA_B2B_M_BT656_D   <= video_o_data(7 downto 0) when parallel_16bit_en = '1' else bt656_data;
FPGA_B2B_M_PVO8      <= video_o_data(8) ; --video_o_data(0) ;  
FPGA_B2B_M_PVO9      <= video_o_data(9) ; --video_o_data(1) ;  
FPGA_B2B_M_PVO10     <= video_o_data(10); --video_o_data(2);   
FPGA_B2B_M_PVO11     <= video_o_data(11); --video_o_data(3);   
FPGA_B2B_M_PVO12     <= video_o_data(12); --video_o_data(4);   
FPGA_B2B_M_PVO13     <= video_o_data(13); --video_o_data(5);   
FPGA_B2B_M_PVO14     <= video_o_data(14); --video_o_data(6);   
FPGA_B2B_M_PVO15     <= video_o_data(15); --video_o_data(7);   
OLED_DATAEN          <= video_o_de;  
  
  
  
end generate;

----i_VIDEO_IN_PATTERN: entity WORK.VIDEO_IN_PATTERN
-------------------------
----  generic map(
----        bit_width         => 13,
----        VIDEO_XSIZE       => 720,--1280,--640,
----        VIDEO_YSIZE       => 576,--720,--480,
----        HBLANK            => 37,
----        VBLANK            => 3840,
----        HSYNC_START_DELAY => 37

----  )
----  port map(
----    -- Clock and Reset
----    CLK          => CLK_27MHZ, 
----    RST          => RST,                     -- Module Reset (asynch'ed active high)
    
----    VSYNC        => video_o_frame_valid,
----    HSYNC        => video_o_line_valid,
----    DVAL         => video_o_de,
----    PIXEL_CLK    => FPGA_B2B_M_BT656_CLK,
----    VIDEO_DATA   => video_o_data(13 downto 0)
----  );

--FPGA_B2B_M_BT656_D   <= bt656_data; 
--FPGA_B2B_M_BT656_CLK <= CLK_27MHZ; 
--INV_CLK_13_5_MHZ     <= not CLK_13_5_MHZ;


MIPI_CSI_IP_GEN  :If (MIPI_EN = TRUE) Generate
i_mipi_csi_ip_controller: mipi_csi_ip_controller
port map(
 m_axi_aclk    => CLK_54MHZ ,
 m_axi_aresetn => RST_N     ,
 m_axi_awaddr  => m_axi_awaddr ,
 m_axi_awvalid => m_axi_awvalid,
 m_axi_awready => m_axi_awready,
 m_axi_wdata   => m_axi_wdata  ,
 m_axi_wstrb   => m_axi_wstrb  ,
 m_axi_wvalid  => m_axi_wvalid ,
 m_axi_wready  => m_axi_wready ,
 m_axi_bresp   => m_axi_bresp  ,
 m_axi_bvalid  => m_axi_bvalid ,
 m_axi_bready  => m_axi_bready ,
 m_axi_araddr  => m_axi_araddr ,
 m_axi_arvalid => m_axi_arvalid,
 m_axi_arready => m_axi_arready,
 m_axi_rdata   => m_axi_rdata  ,
 m_axi_rresp   => m_axi_rresp  ,
 m_axi_rvalid  => m_axi_rvalid ,
 m_axi_rready  => m_axi_rready ,
 resetn        => csi_tx_ip_ready
    );



--video_o_data_concat <= x"000000"& "00" &video_o_data(15 downto 0) ;
video_o_data_concat <= x"000" &"00"& video_o_data(15 downto 8) &"00" & x"0" &video_o_data(7 downto 0) & "00"&x"0";
i_mipi_csi_tx : mipi_csi2_tx_subsystem_0
  PORT MAP (
    s_axis_aclk          => CLK_54MHZ,
    s_axis_aresetn       => RST_N,
    dphy_clk_200M        => CLK_200MHZ,
    txclkesc_out         => open,
    oserdes_clk_out      => open,
    oserdes_clk90_out    => open,
    txbyteclkhs          => open,
    oserdes_clkdiv_out   => open,
    system_rst_out       => open,
    mmcm_lock_out        => open,
    cl_tst_clk_out       => open,
    dl_tst_clk_out       => open,
    interrupt            => open,
    s_axi_araddr         => m_axi_araddr,
    s_axi_arready        => m_axi_arready,
    s_axi_arvalid        => m_axi_arvalid,
    s_axi_awaddr         => m_axi_awaddr,
    s_axi_awready        => m_axi_awready,
    s_axi_awvalid        => m_axi_awvalid,
    s_axi_bready         => m_axi_bready,
    s_axi_bresp          => m_axi_bresp,
    s_axi_bvalid         => m_axi_bvalid,
    s_axi_rdata          => m_axi_rdata,
    s_axi_rready         => m_axi_rready,
    s_axi_rresp          => m_axi_rresp,
    s_axi_rvalid         => m_axi_rvalid,
    s_axi_wdata          => m_axi_wdata,
    s_axi_wready         => m_axi_wready,
    s_axi_wstrb          => m_axi_wstrb,
    s_axi_wvalid         => m_axi_wvalid,
    
    mipi_video_if_mipi_vid_di       => "011110",--Yuv422,--"101101", -- Raw14--"011110",--Yuv422
    mipi_video_if_mipi_vid_enable   => video_o_line_valid,--video_o_de,
    mipi_video_if_mipi_vid_framenum => x"0000",
    mipi_video_if_mipi_vid_hsync    => video_o_line_valid,--video_o_de,
    mipi_video_if_mipi_vid_linenum  => x"0000",
    mipi_video_if_mipi_vid_pixel    => video_o_data_concat,
    mipi_video_if_mipi_vid_vc       => "00",
    mipi_video_if_mipi_vid_vsync    => video_o_frame_pulse,--video_o_vsync,
    mipi_video_if_mipi_vid_wc       => x"0500",--640*2,--x"0460",--640*7/4 (raw14)--"x"0500",-- 640*2, -- x"0640" -- 800*2, 
    
    mipi_phy_if_clk_hs_n  => mipi_phy_if_clk_hs_n,
    mipi_phy_if_clk_hs_p  => mipi_phy_if_clk_hs_p,
    mipi_phy_if_clk_lp_n  => mipi_phy_if_clk_lp_n,
    mipi_phy_if_clk_lp_p  => mipi_phy_if_clk_lp_p,
    mipi_phy_if_data_hs_n => mipi_phy_if_data_hs_n,
    mipi_phy_if_data_hs_p => mipi_phy_if_data_hs_p,
    mipi_phy_if_data_lp_n => mipi_phy_if_data_lp_n,
    mipi_phy_if_data_lp_p => mipi_phy_if_data_lp_p
  );

end generate;


MIPI_IO_GEN  :If (OLED_EN = TRUE or USB_EN = TRUE or EK_EN = TRUE) Generate
   OBUFDS_inst_1 : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
      SLEW => "SLOW")          -- Specify the output slew rate
   port map (
      O => mipi_phy_if_data_hs_p(0),     -- Diff_p output (connect directly to top-level port)
      OB => mipi_phy_if_data_hs_n(0),   -- Diff_n output (connect directly to top-level port)
      I => '0'      -- Buffer input 
   );
      OBUFDS_inst_2 : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
      SLEW => "SLOW")          -- Specify the output slew rate
   port map (
      O => mipi_phy_if_clk_hs_p,     -- Diff_p output (connect directly to top-level port)
      OB => mipi_phy_if_clk_hs_n,   -- Diff_n output (connect directly to top-level port)
      I => '0'      -- Buffer input 
   );
end generate;   

--probe0(0)           <= video_o_frame_valid;
--probe0(1)           <= video_o_line_valid;
--probe0(2)           <= video_o_vsync;
--probe0(3)           <= video_o_hsync;
--probe0(4)           <= video_o_de;
--probe0(20 downto 5) <= video_o_data;
--probe0(21)          <= RST;
--probe0(22)          <= sel_color_tp;
--probe0(23)          <= ;
----------------------------------------------

--probe0(0) <= ENABLE_NUC1ptCalib;
--probe0(1) <= NUC1pt_done_offset;
--probe0(2) <= APPLY_NUC1ptCalib;
--probe0(3) <= DMA_NUC1PT_MUX;
--probe0(4) <= ENABLE_NUC_D;
--probe0(5) <= Start_NUC1ptCalib;
--probe0(8 downto 6)  <= VIDEO_NUC1PT_FSM_Temp;
--probe0(9)  <= start_gain_calc   ;      
--probe0(10) <= done_gain_calc      ;    
--probe0(11) <= Start_GAINCalib_POS_EDGE;
--probe0(12) <= Start_GAINCalib_D      ; 
--probe0(13) <= Start_GAINCalib        ; 
--probe0(14) <=select_gain_addr_d;
--probe0(15) <=select_gain_addr;
--probe0(16) <=gain_enable;
--probe0(17) <=gain_enable_d;
--probe0(18)<= SNSR_FPGA_LINEVALID ;
--probe0(19)<= SNSR_FPGA_FRAMEVALID ; 
--probe0(20)<= VIDEO_O_V_TE;
--probe0(21)<= VIDEO_O_H_TE;
--probe0(127 downto 22)<= (others =>'0');


--probe0(0) <= VIDEO_I_NUC_V;
--probe0(1) <= VIDEO_I_NUC_H;
--probe0(2) <= VIDEO_I_NUC_DAV;
--probe0(3) <= VIDEO_I_NUC_EOI;
--probe0(17 downto 4)<= VIDEO_I_NUC_DATA;
--probe0(18)<= VIDEO_O_NUC_V    ;
--probe0(19)<= VIDEO_O_NUC_H    ;
--probe0(20)<= VIDEO_O_NUC_EOI  ;
--probe0(21)<= VIDEO_O_NUC_DAV  ;
--probe0(35 downto 22)<= VIDEO_O_NUC_DATA ;
--probe0(36)<= VIDEO_O_NUC_BAD  ;
--probe0(37)<= VIDEO_O_ROW_V;    
--probe0(38)<= VIDEO_O_ROW_H;    
--probe0(39)<= VIDEO_O_ROW_DAV;  
--probe0(53 downto 40)<= VIDEO_O_ROW_DATA; 
--probe0(54)<= VIDEO_O_ROW_BAD  ;            
--probe0(55)<= VIDEO_O_ROW_EOI  ;   
--probe0(56)<= VIDEO_O_BADP_V   ; 
--probe0(57)<= VIDEO_O_BADP_H   ; 
--probe0(58)<= VIDEO_O_BADP_EOI ; 
--probe0(59)<= VIDEO_O_BADP_DAV ; 
--probe0(73 downto 60)<= VIDEO_O_BADP_DATA;   
--probe0(74)<= VIDEO_O_V_P     ;
--probe0(75)<= VIDEO_O_H_P    ;
--probe0(76)<= VIDEO_O_DAV_P  ;
--probe0(90 downto 77)<= VIDEO_O_DATA_P ;
--probe0(91)<= VIDEO_O_EOI_P   ;
--probe0(92)<= VIDEO_I_FILT_V  ; 
--probe0(93)<= VIDEO_I_FILT_H   ;
--probe0(94)<= VIDEO_I_FILT_EOI ;
--probe0(95)<= VIDEO_I_FILT_DAV ;
--probe0(109 downto 96)<= VIDEO_I_FILT_DATA;
--probe0(110)<= SCALER_V  ; 
--probe0(111)<= SCALER_H  ; 
--probe0(112)<= SCALER_DAV;
--probe0(120 downto 113)<= SCALER_DATA ;
--probe0(121)<= SCALER_O_V   ;
--probe0(122)<= SCALER_O_H   ;
--probe0(123)<= SCALER_O_DAV ;
--probe0(131 downto 124)<= SCALER_O_DATA;
--probe0(132)<= SCALER_O_EOI   ;
--probe0(133)<= VIDEO_O_V_BC   ; 
--probe0(134)<= VIDEO_O_H_BC   ; 
--probe0(135)<= VIDEO_O_DAV_BC ;
--probe0(143 downto 136)<= VIDEO_O_DATA_BC;
--probe0(144)<= VIDEO_O_EOI_BC  ;
--probe0(145)<= VIDEO_I_V_SN    ;
--probe0(146)<= VIDEO_I_H_SN    ;
--probe0(147)<= VIDEO_I_DAV_SN  ;
--probe0(161 downto 148)<= VIDEO_I_DATA_SN ;
--probe0(162)<= VIDEO_I_EOI_SN      ;
--probe0(163)<= SNSR_FPGA_PIXEL_CLK ;
--probe0(164)<= SNSR_FPGA_LINEVALID  ;
--probe0(165)<= SNSR_FPGA_FRAMEVALID ;
----probe0(166)<= SNSR_FPGA_LINEVALID ;
--probe0(181 downto 166)<= SNSR_FPGA_DATA(15 downto 0);
--probe0(182)<= polarity         ;
--probe0(183)<= ENABLE_BADPIXREM ;
--probe0(184)<= ENABLE_SNUC      ;
--probe0(185)<= ENABLE_NUC_D     ;
--probe0(201 downto 186)<= offset_img_avg;
--probe0(255 downto 203)<= (others=>'0');

--i_TOII_TUVE_ila: TOII_TUVE_ila
--PORT MAP (
--  clk => CLK_100MHZ,
--  probe0 => probe0
--);


-------------------------------------

--probe0(127 downto 23) <= (others=>'0');
--probe0(0) <= ENABLE_UNITY_GAIN2;
--probe0(1) <= ENABLE_UNITY_GAIN_C;
--probe0(2) <= snapshot_ctrl_mux;
--probe0(3) <= snapshot_nuc_trigger;
--probe0(6 downto 4) <= snapshot_nuc_mode;
--probe0(9 downto 7) <= snapshot_nuc_channel;
--probe0(12 downto 10) <= std_logic_vector(to_unsigned(nuc1ptm2_fsm_t'POS(nuc1ptm2_fsm), 3));
--probe0(13) <= APPLY_NUC1ptCalib2;
--probe0(14) <= Start_NUC1ptCalib2;
--probe0(15) <= Start_NUC1ptCalib2_D;
--probe0(16) <= VIDEO_I_NUC_V;
--probe0(17) <= snapshot_done_c;
--probe0(18) <= OSD_START_NUC1PT2CALIB;
--probe0(19) <= snapshot_trigger_c;
--probe0(20) <= stop_dma_write2;
--probe0(21) <= stop_dma_write_c;
--probe0(22) <= DMA_WRITE_FREE;


--probe0(0)            <= video_o_frame_valid;
--probe0(1)            <= video_o_line_valid;
--probe0(2)            <= video_o_vsync;
--probe0(3)            <= video_o_hsync;
--probe0(4)            <= video_o_de;
--probe0(20 downto 5)  <= video_o_data;
--probe0(21)           <= SCALER_BIL_REQ_V;
--probe0(22)           <= SCALER_BIL_REQ_H;
--probe0(32 downto 23) <= SCALER_BIL_LINE_NO;
----probe0(31 downto 0)  <= DMA_R0_RDADDR_s;
----probe0(32)           <= SCALER_BIL_REQ_V;
--probe0(33)           <= SCALER_O_DAV;
--probe0(34)           <= SCALER_O_V;
--probe0(35)           <= SCALER_O_H;
--probe0(36)           <= SCALER_O_EOI;
--probe0(47 downto 37) <= std_logic_vector(line_ct);
--probe0(58 downto 48) <= std_logic_vector(pix_ct);
--probe0(59)           <= SCALER_RUN;
--probe0(60)           <= BT656_START;
--probe0(61)           <= SCALER_V;
--probe0(62)           <= SCALER_DAV;
--probe0(72 downto 63)           <= pix_cnt_out ;     
--probe0(82 downto 73)           <= line_cnt_out ;  
--probe0(85 downto 83)           <= std_logic_vector(to_unsigned(state'POS(fsm_scaler), 3));
--probe0(93 downto 86)           <= std_logic_vector(frame_cnt1);
--probe0(101 downto 94)          <= std_logic_vector(frame_cnt2);
--probe0(109 downto 102)         <= std_logic_vector(frame_cnt3);
--probe0(110)                    <= TICK1S;
--probe0(120 downto 111)         <= SCALER_LIN_NO;
--probe0(121)                    <= SCALER_REQ_V;
--probe0(122)                    <= SCALER_REQ_H;
--probe0(124 downto 123)         <= MEM_IMG_BUF_Temp;
--probe0(125)                    <= qspi_init_cmd_done;
--probe0(126)                    <= qspi_init_cmd_done_n;
--probe0(127)                    <= '0';
----probe0(127 downto 125)         <= (others=>'0');



--i_TOII_TUVE_ila: TOII_TUVE_ila
--PORT MAP (
--  clk => CLK,
--  probe0 => probe0
--);

-----------------------------------

end Behavioral;
