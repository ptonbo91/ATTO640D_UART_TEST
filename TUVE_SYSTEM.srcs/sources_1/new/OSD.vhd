library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
   

----------------------------------
entity OSD is
----------------------------------
  generic ( 

    PIX_BITS          : positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS          : positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image  
    CH_ROM_ADDR_WIDTH : positive;
    CH_ROM_DATA_WIDTH : positive;
    CH_PER_BYTE       : positive
  );
  port (
    -- Clock and Reset
    CLK                  : in  std_logic;                              -- Module Clock
    RST                  : in  std_logic;                              -- Module Reset (Asynchronous active high)
    tick1ms              : in  std_logic;
    burst_capture_size   : in  std_logic_vector(7 downto 0);
    snapshot_save_done   : in std_logic;
    snapshot_delete_done : in std_logic;
    gyro_calib_done      : in std_logic;
    OSD_TIMEOUT          : in  std_logic_vector(15 downto 0); 
--    OSD_EN               : in  std_logic;                              -- Enable OSD
--    OSD_EN_OUT           : out std_logic;

--    OSD_COLOR_INFO1      : in  std_logic_vector( 23 downto 0);     -- OSD COLOR1
--    CH_COLOR_INFO1       : in  std_logic_vector( 23 downto 0);     -- OSD COLOR2
--    CH_COLOR_INFO2       : in  std_logic_vector( 23 downto 0);     -- OSD COLOR2
--    CURSOR_COLOR_INFO    : in  std_logic_vector( 23 downto 0); 
    OSD_COLOR_INFO1      : in  std_logic_vector( 7 downto 0);     -- OSD COLOR1
    CH_COLOR_INFO1       : in  std_logic_vector( 7 downto 0);     -- OSD COLOR2
    CH_COLOR_INFO2       : in  std_logic_vector( 7 downto 0);     -- OSD COLOR2
    CURSOR_COLOR_INFO    : in  std_logic_vector( 7 downto 0); 
    OSD_POS_X_LY1        : in  std_logic_vector(PIX_BITS-1 downto 0);  -- OSD POSITION X
    OSD_POS_Y_LY1        : in  std_logic_vector(LIN_BITS-1 downto 0);  -- OSD POSITION Y
    OSD_POS_X_LY2        : in  std_logic_vector(PIX_BITS-1 downto 0);  -- OSD POSITION X
    OSD_POS_Y_LY2        : in  std_logic_vector(LIN_BITS-1 downto 0);  -- OSD POSITION Y
    OSD_POS_X_LY3        : in  std_logic_vector(PIX_BITS-1 downto 0);  -- OSD POSITION X
    OSD_POS_Y_LY3        : in  std_logic_vector(LIN_BITS-1 downto 0);  -- OSD POSITION Y
    MENU_SEL_CENTER      : in  std_logic;
    MENU_SEL_UP          : in  std_logic; 
    MENU_SEL_DN          : in  std_logic;
--    ADVANCE_MENU_TRIG_IN : in  std_logic;
--    main_menu_sel        : in  std_logic;
--    advance_menu_trig    : in  std_logic;
    
    CH_IMG_WIDTH_IN         : in  std_logic_vector( 10 downto 0);          -- Memory Image Picture X Size (max 1023)
    CH_IMG_HEIGHT_IN        : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture Y Size (max 1023)

    OSD_REQ_V            : in  std_logic;                              -- Scaler New Frame Request
    OSD_REQ_H            : in  std_logic;                              -- Scaler New Line Request
    OSD_FIELD            : in  std_logic;                              -- FIELD
    OSD_REQ_XSIZE_LY1    : in  std_logic_vector(PIX_BITS-1 downto 0);  --MENU LAYER1 WIDTH 
    OSD_REQ_YSIZE_LY1    : in  std_logic_vector(LIN_BITS-1 downto 0);  --MENU LAYER1 HEIGHT 
    OSD_REQ_XSIZE_LY2    : in  std_logic_vector(PIX_BITS-1 downto 0);  --MENU LAYER2 WIDTH 
    OSD_REQ_YSIZE_LY2    : in  std_logic_vector(LIN_BITS-1 downto 0);  --MENU LAYER2 HEIGHT
    OSD_REQ_XSIZE_LY3    : in  std_logic_vector(PIX_BITS-1 downto 0);  --MENU LAYER3 WIDTH 
    OSD_REQ_YSIZE_LY3    : in  std_logic_vector(LIN_BITS-1 downto 0);  --MENU LAYER3 HEIGHT
    
    VIDEO_IN_V           : in  std_logic;                              -- Scaler New Frame
    VIDEO_IN_H           : in  std_logic;
    VIDEO_IN_DAV         : in  std_logic;                              -- Scaler New Data
--    VIDEO_IN_DATA        : in  std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    VIDEO_IN_DATA        : in  std_logic_vector(7 downto 0);
    VIDEO_IN_EOI         : in  std_logic;
    VIDEO_IN_XSIZE       : in  std_logic_vector(PIX_BITS-1 downto 0);  -- Width of output image
    VIDEO_IN_YSIZE       : in  std_logic_vector(LIN_BITS-1 downto 0);  -- Height of output image
    
    OSD_V                : out std_logic;                              -- Scaler New Frame
    OSD_H                : out std_logic;
    OSD_DAV              : out std_logic;                              -- Scaler New Data
--    OSD_DATA             : out std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    OSD_DATA             : out std_logic_vector(7 downto 0);
    OSD_EOI              : out std_logic;
    OSD_POS_X_OUT        : out std_logic_vector(PIX_BITS-1 downto 0);
    OSD_POS_Y_OUT        : out std_logic_vector(LIN_BITS-1 downto 0);
    CURSOR_POS_OUT       : out std_logic_Vector(7 downto 0);
    CMD_START_NUC1ptCalib           : in std_logic;
    CMD_START_NUC1ptCalib_VALID     : in std_logic; 
    CMD_AGC_MODE_SEL                : in std_logic_Vector(1 downto 0); 
    CMD_AGC_MODE_SEL_VALID          : in std_logic;              
    CMD_BRIGHTNESS                  : in std_logic_vector(7 downto 0);  
    CMD_BRIGHTNESS_VALID            : in std_logic;           
    CMD_CONTRAST                    : in std_logic_vector(7 downto 0);               
    CMD_CONTRAST_VALID              : in std_logic; 
    CMD_DZOOM                       : in std_logic_Vector(2 downto 0);
    CMD_DZOOM_VALID                 : in std_logic;
    CMD_RETICLE_COLOR               : in std_logic_vector(2 downto 0);                
    CMD_RETICLE_COLOR_VALID         : in std_logic; 
    CMD_RETICLE_TYPE_SEL            : in std_logic_vector(3 downto 0);                
    CMD_RETICLE_TYPE_SEL_VALID      : in std_logic; 
--    CMD_RETICLE_POS_X               : in std_logic_vector(PIX_BITS-1 downto 0);       
--    CMD_RETICLE_POS_X_VALID         : in std_logic; 
--    CMD_RETICLE_POS_Y               : in std_logic_vector(LIN_BITS-1 downto 0);       
--    CMD_RETICLE_POS_Y_VALID         : in std_logic; 
    CMD_RETICLE_POS_YX              : in std_logic_vector(23 downto 0);       
    CMD_RETICLE_POS_YX_VALID        : in std_logic; 
    CMD_DISPLAY_LUX                 : in std_logic_vector(7 downto 0);
    CMD_DISPLAY_LUX_VALID           : in std_logic;
    CMD_DISPLAY_GAIN                : in std_logic_vector(7 downto 0);
    CMD_DISPLAY_GAIN_VALID          : in std_logic;
    CMD_DISPLAY_VERT                : in std_logic_vector(9 downto 0);
    CMD_DISPLAY_VERT_VALID          : in std_logic;
    CMD_DISPLAY_HORZ                : in std_logic_vector(8 downto 0);
    CMD_DISPLAY_HORZ_VALID          : in std_logic;
    
    CMD_POLARITY                    : in std_logic_vector(1 downto 0);                                   
    CMD_POLARITY_VALID              : in std_logic;                                  
    CMD_SNUC_EN                     : in std_logic;                                    
    CMD_SNUC_EN_VALID               : in std_logic;
    CMD_SHARPNESS                   : in std_logic_vector(3 downto 0);
    CMD_SHARPNESS_VALID             : in std_logic;
    CMD_CP_TYPE_SEL                 : in std_logic_vector(4 downto 0); 
    CMD_CP_TYPE_SEL_VALID           : in std_logic; 
    CMD_LOGO_EN                     : in std_logic;                                    
    CMD_LOGO_EN_VALID               : in std_logic; 
    CMD_SMOOTHING_EN                : in std_logic;
    CMD_SMOOTHING_EN_VALID          : in std_logic;
    CMD_EDGE_EN                     : in std_logic;
    CMD_EDGE_EN_VALID               : in std_logic;
    CMD_GALLERY_IMG_VALID           : in std_logic_vector(71 downto 0);
    CMD_GALLERY_IMG_VALID_EN        : in std_logic;
    CMD_LASER_EN                    : in std_logic;
    CMD_LASER_EN_VALID              : in std_logic;   
    CMD_GYRO_DATA_DISP_EN           : in std_logic;
    CMD_GYRO_DATA_DISP_EN_VALID     : in std_logic;
    CMD_FIRING_MODE                 : in std_logic;
    CMD_FIRING_MODE_VALID           : in std_logic;    
--    CMD_FIT_TO_SCREEN_EN            : in std_logic;
--    CMD_FIT_TO_SCREEN_EN_VALID      : in std_logic;
    CMD_DISPLAY_MODE                : in std_logic;
    CMD_DISPLAY_MODE_VALID          : in std_logic;

    CMD_SIGHT_MODE                  : in std_logic_vector(1 downto 0);
    CMD_SIGHT_MODE_VALID            : in std_logic;
        
    CMD_MAX_LIMITER_DPHE            : in std_logic_vector(7 downto 0);
    CMD_MAX_LIMITER_DPHE_VALID      : in std_logic; 
    CMD_MUL_MAX_LIMITER_DPHE        : in std_logic_vector(7 downto 0);
    CMD_MUL_MAX_LIMITER_DPHE_VALID  : in std_logic; 
    CMD_CNTRL_MAX_GAIN              : in std_logic_vector(7 downto 0);
    CMD_CNTRL_MAX_GAIN_VALID        : in std_logic;
    CMD_CNTRL_IPP                   : in std_logic_vector(7 downto 0);
    CMD_CNTRL_IPP_VALID             : in std_logic;
    CMD_NUC_MODE                    : in std_logic_vector(1 downto 0);
    CMD_NUC_MODE_VALID              : in std_logic;
    CMD_BLADE_MODE                  : in std_logic_vector(1 downto 0);
    CMD_BLADE_MODE_VALID            : in std_logic;
        
    OSD_START_NUC1PTCALIB           : out std_logic;  
    OSD_COARSE_OFFSET_CALIB_START   : out std_logic;
    OSD_DZOOM                       : out std_logic_Vector(2 downto 0);
    OSD_DZOOM_VALID                 : out std_logic;
    OSD_AGC_MODE_SEL                : out std_logic_vector(1 downto 0);
    OSD_AGC_MODE_SEL_VALID          : out std_logic;
    OSD_SNAPSHOT_COUNTER            : out std_logic_vector(7 downto 0);
    OSD_SNAPSHOT_COUNTER_VALID      : out std_logic;
    OSD_BRIGHTNESS                  : out std_logic_vector(7 downto 0);
    OSD_BRIGHTNESS_VALID            : out std_logic;
    OSD_CONTRAST                    : out std_logic_vector(7 downto 0);
    OSD_CONTRAST_VALID              : out std_logic;
    OSD_RETICLE_COLOR               : out std_logic_vector(2 downto 0);
    OSD_RETICLE_COLOR_VALID         : out std_logic;    
    OSD_RETICLE_TYPE_SEL            : out std_logic_vector(3 downto 0);
    OSD_RETICLE_TYPE_SEL_VALID      : out std_logic;
    OSD_RETICLE_POS_YX              : out std_logic_vector(23 downto 0);
    OSD_RETICLE_POS_YX_VALID        : out std_logic;    
--    OSD_RETICLE_POS_X               : out std_logic_vector(PIX_BITS-1 downto 0);
--    OSD_RETICLE_POS_X_VALID         : out std_logic;
--    OSD_RETICLE_POS_Y               : out std_logic_vector(LIN_BITS-1 downto 0);
--    OSD_RETICLE_POS_Y_VALID         : out std_logic;
    OSD_DISPLAY_LUX                 : out std_logic_vector(7 downto 0);
    OSD_DISPLAY_LUX_VALID           : out std_logic;
    OSD_DISPLAY_GAIN                : out std_logic_vector(7 downto 0);
    OSD_DISPLAY_GAIN_VALID          : out std_logic;
    OSD_DISPLAY_VERT                : out std_logic_vector(9 downto 0);
    OSD_DISPLAY_VERT_VALID          : out std_logic;
    OSD_DISPLAY_HORZ                : out std_logic_vector(8 downto 0);
    OSD_DISPLAY_HORZ_VALID          : out std_logic;
    OSD_SNUC_EN                     : out std_logic;
    OSD_SNUC_EN_VALID               : out std_logic;
    OSD_SMOOTHING_EN                : out std_logic;
    OSD_SMOOTHING_EN_VALID          : out std_logic;
    OSD_SHARPNESS                   : out std_logic_vector(3 downto 0);
    OSD_SHARPNESS_VALID             : out std_logic;    
    OSD_POLARITY                    : out std_logic_vector(1 downto 0);
    OSD_POLARITY_VALID              : out std_logic;
    OSD_EDGE_EN                     : out std_logic;
    OSD_EDGE_EN_VALID               : out std_logic;
    OSD_CP_TYPE_SEL                 : out std_logic_vector(4 downto 0);  
    OSD_CP_TYPE_SEL_VALID           : out std_logic;
    OSD_MARK_BP                     : out std_logic;
    OSD_MARK_BP_VALID               : out std_logic;
    OSD_UNMARK_BP                   : out std_logic; 
    OSD_UNMARK_BP_VALID             : out std_logic;
    OSD_SAVE_BP                     : out std_logic;
    OSD_LOAD_USER_SETTINGS          : out std_logic;
    OSD_LOAD_FACTORY_SETTINGS       : out std_logic;
    OSD_SAVE_USER_SETTINGS          : out std_logic;
    OSD_SINGLE_SNAPSHOT             : out std_logic;
    OSD_BURST_SNAPSHOT              : out std_logic;
    OSD_GALLERY_ENABLE              : out std_logic;                          -- Enable GALLERY TO DISPLAY SNAP
    OSD_GALLERY_IMG_NUMBER          : out std_logic_vector(7 downto 0);               -- SNAPSHOT IMAGE COUNTER
    OSD_GALLERY_IMG_VALID           : out std_logic_vector(71 downto 0);
    OSD_GALLERY_IMG_VALID_EN        : out std_logic;
    OSD_SNAPSHOT_DELETE_EN          : out std_logic;
    OSD_LASER_EN                    : out std_logic;
    OSD_LASER_EN_VALID              : out std_logic;
    OSD_GYRO_DATA_DISP_EN           : out std_logic;
    OSD_GYRO_DATA_DISP_EN_VALID     : out std_logic;     
    OSD_GYRO_CALIB_EN               : out std_logic;
    OSD_GYRO_CALIB_EN_VALID         : out std_logic; 
    OSD_STANDBY_EN                  : out std_logic;
    OSD_STANDBY_EN_VALID            : out std_logic;
    OSD_POWER_OFF_EN                : out std_logic;  
    OSD_LOAD_GALLERY                : out std_logic;    
    OSD_DISTANCE_SEL                : out std_logic_vector(3 downto 0);  
    OSD_DISTANCE_SEL_VALID          : out std_logic;   
    OSD_FIRING_MODE                 : out std_logic;
    OSD_FIRING_MODE_VALID           : out std_logic; 
--    OSD_FIT_TO_SCREEN_EN            : out std_logic;
--    OSD_FIT_TO_SCREEN_EN_VALID      : out std_logic;
    OSD_DISPLAY_MODE                : out std_logic;
    OSD_DISPLAY_MODE_VALID          : out std_logic;    

    OSD_SIGHT_MODE                  : out std_logic_vector(1 downto 0);
    OSD_SIGHT_MODE_VALID            : out std_logic;

--    OSD_MAX_LIMITER_DPHE            : out std_logic_vector(23 downto 0);
    OSD_MAX_LIMITER_DPHE            : out std_logic_vector(7 downto 0);
    OSD_MAX_LIMITER_DPHE_VALID      : out std_logic; 
    OSD_MUL_MAX_LIMITER_DPHE        : out std_logic_vector(7 downto 0);
    OSD_MUL_MAX_LIMITER_DPHE_VALID  : out std_logic; 
--    OSD_CNTRL_MAX_GAIN              : out std_logic_vector(23 downto 0);
    OSD_CNTRL_MAX_GAIN              : out std_logic_vector(7 downto 0);
    OSD_CNTRL_MAX_GAIN_VALID        : out std_logic;
--    OSD_CNTRL_IPP                   : out std_logic_vector(23 downto 0);
    OSD_CNTRL_IPP                   : out std_logic_vector(7 downto 0);
    OSD_CNTRL_IPP_VALID             : out std_logic;
    OSD_NUC_MODE                    : out std_logic_vector(1 downto 0);
    OSD_NUC_MODE_VALID              : out std_logic;
    OSD_BLADE_MODE                  : out std_logic_vector(1 downto 0);
    OSD_BLADE_MODE_VALID            : out std_logic;
    RETICLE_OFFSET_V                : in  unsigned(8 downto 0);
    RETICLE_OFFSET_H                : in  unsigned(8 downto 0);
    FIRING_DISTANCE                 : in  unsigned(9 downto 0);
    OSD_EN_OUT                      : out std_logic 
  );
----------------------------------
end entity OSD;
----------------------------------

------------------------------------------
architecture RTL of OSD is
------------------------------------------

COMPONENT ila_0

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

component CH_ROM is
   generic(
          ADDR_WIDTH: positive:=6;
          DATA_WIDTH: positive:=8
    );
   port(
   clk   : in std_logic;
   addr  : in std_logic_vector(CH_ROM_ADDR_WIDTH -1 downto 0);
   data  : out std_logic_vector(CH_ROM_DATA_WIDTH-1 downto 0)
);
end component;

component BINARY_TO_BCD is
generic(
    DATA_IN_WIDTH : positive := 10;
    DATA_OUT_WIDTH: positive := 12
);
port(
    CLK                  : in std_logic; 
    RST                  : in std_logic; 
    BIN_DATA_IN          : in std_logic_Vector (9 downto 0);
    BIN_DATA_IN_VALID    : in std_logic;
    BCD_DATA_OUT         : out std_logic_vector(11 downto 0);
    BCD_DATA_OUT_VALID   : out std_logic
   );                    
end component;

  constant SHUTDOWN_TIMEOUT        : unsigned(15 downto 0) := x"0BB8"; -- 3000 ms / 3 seconds
  constant GALLERY_DISP_TIMEOUT    : unsigned(15 downto 0) := x"1770"; -- 6000 ms / 5 seconds
  constant PAGE1_NUMBER_OF_OPTION  : unsigned(7 downto 0)  := x"0A"; 
  constant PAGE2_NUMBER_OF_OPTION  : unsigned(7 downto 0)  := x"0B";--x"0E";--x"0D";--x"0A";--x"09"; --x"0B"; 
  constant PIX_BETWEEN_CH_CLM      : unsigned(7 downto 0)  := x"01";
  constant PIX_BETWEEN_CH_ROW      : unsigned(7 downto 0)  := x"02";
 
  constant PAGE1_CALIBRATION_POS         : unsigned(7 downto 0)  := x"00";
  constant PAGE1_BRIGHTNESS_POS          : unsigned(7 downto 0)  := x"01";
  constant PAGE1_GAIN_POS                : unsigned(7 downto 0)  := x"02";
  constant PAGE1_DZOOM_POS               : unsigned(7 downto 0)  := x"03";
  constant PAGE1_AGC_POS                 : unsigned(7 downto 0)  := x"04";
  constant PAGE1_LASER_POS               : unsigned(7 downto 0)  := x"05";
  constant PAGE1_DISPLAY_POS             : unsigned(7 downto 0)  := x"06";
  constant PAGE1_RETICLE_POS             : unsigned(7 downto 0)  := x"07";
  constant PAGE1_ADVANCE_MENU_POS        : unsigned(7 downto 0)  := x"08";
  constant PAGE1_SHUTDOWN_POS            : unsigned(7 downto 0)  := x"09";
  

  constant PAGE2_IMG_ENHANCE_POS         : unsigned(7 downto 0)  := x"00";
  --constant PAGE2_DISPLAY_MODE_POS        : unsigned(7 downto 0)  := x"01";
  constant PAGE2_SIGHT_CONFIG_POS        : unsigned(7 downto 0)  := x"01";
  constant PAGE2_AGC_ADVANCE_POS         : unsigned(7 downto 0)  := x"02";
  constant PAGE2_NUC_ADVANCE_POS         : unsigned(7 downto 0)  := x"03";
  constant PAGE2_GALLERY_POS             : unsigned(7 downto 0)  := x"04";
  constant PAGE2_BIT_POS                 : unsigned(7 downto 0)  := x"05";
  constant PAGE2_COMPASS_POS             : unsigned(7 downto 0)  := x"06";
  constant PAGE2_BPR_POS                 : unsigned(7 downto 0)  := x"07";
  constant PAGE2_SNAPSHOT_POS            : unsigned(7 downto 0)  := x"08";
  constant PAGE2_SETTINGS_POS            : unsigned(7 downto 0)  := x"09";
  constant PAGE2_STANDBY_POS             : unsigned(7 downto 0)  := x"0A";
--  constant PAGE2_FIRING_POS              : unsigned(7 downto 0)  := x"0B";
  
  
  constant CALIBRATION_POS         : unsigned(7 downto 0)  := x"00";
  constant BRIGHTNESS_POS          : unsigned(7 downto 0)  := x"01";
  constant GAIN_POS                : unsigned(7 downto 0)  := x"02";
  constant DZOOM_POS               : unsigned(7 downto 0)  := x"03";
  constant AGC_POS                 : unsigned(7 downto 0)  := x"04";
  constant LASER_POS               : unsigned(7 downto 0)  := x"05";
  constant DISPLAY_POS             : unsigned(7 downto 0)  := x"06";
  constant RETICLE_POS             : unsigned(7 downto 0)  := x"07";
  constant ADVANCE_MENU_POS        : unsigned(7 downto 0)  := x"08";
  constant SHUTDOWN_POS            : unsigned(7 downto 0)  := x"09";
  constant IMG_ENHANCE_POS         : unsigned(7 downto 0)  := x"0A";
  --constant DISPLAY_MODE_POS        : unsigned(7 downto 0)  := x"0B";
  constant SIGHT_CONFIG_POS        : unsigned(7 downto 0)  := x"0B";
  constant AGC_ADVANCE_POS         : unsigned(7 downto 0)  := x"0C";
  constant NUC_ADVANCE_POS         : unsigned(7 downto 0)  := x"0D";
  constant GALLERY_POS             : unsigned(7 downto 0)  := x"0E";
  constant BIT_POS                 : unsigned(7 downto 0)  := x"0F";
  constant COMPASS_POS             : unsigned(7 downto 0)  := x"10";
  constant BPR_POS                 : unsigned(7 downto 0)  := x"11";
  constant SNAPSHOT_POS            : unsigned(7 downto 0)  := x"12";
  constant SETTINGS_POS            : unsigned(7 downto 0)  := x"13";
  constant STANDBY_POS             : unsigned(7 downto 0)  := x"14";
--  constant FIRING_POS              : unsigned(7 downto 0)  := x"15";
  
  constant POLARITY_KEY_POS        : unsigned(7 downto 0)  := x"16";
  constant DZOOM_KEY_POS           : unsigned(7 downto 0)  := x"17";
--  constant GAIN_KEY_POS            : unsigned(7 downto 0)  := x"13";

---- OPTION = TOTAL SELCTABLE OPTION -1 
  constant POLARITY_OPTION         : unsigned(7 downto 0)  := x"00";
  constant CALIBRATION_OPTION      : unsigned(7 downto 0)  := x"00";  
  constant BRIGHTNESS_OPTION       : unsigned(7 downto 0)  := x"00";  
  constant GAIN_OPTION             : unsigned(7 downto 0)  := x"00"; 
  constant DZOOM_OPTION            : unsigned(7 downto 0)  := x"00";  
  constant AGC_OPTION              : unsigned(7 downto 0)  := x"00";  
  constant LASER_OPTION            : unsigned(7 downto 0)  := x"00";
  constant DISPLAY_OPTION          : unsigned(7 downto 0)  := x"04";
  constant RETICLE_OPTION          : unsigned(7 downto 0)  := x"04";
  constant ADVANCE_MENU_OPTION     : unsigned(7 downto 0)  := x"00"; 
  constant SHUTDOWN_OPTION         : unsigned(7 downto 0)  := x"00";  
  constant IMG_ENHANCE_OPTION      : unsigned(7 downto 0)  := x"03"; 
  --constant DISPLAY_MODE_OPTION     : unsigned(7 downto 0)  := x"00"; 
  constant SIGHT_CONFIG_OPTION     : unsigned(7 downto 0)  := x"02";
  constant AGC_ADVANCE_OPTION      : unsigned(7 downto 0)  := x"04";
  constant NUC_ADVANCE_OPTION      : unsigned(7 downto 0)  := x"01";
  constant GALLERY_OPTION          : unsigned(7 downto 0)  := x"03";
  constant BIT_OPTION              : unsigned(7 downto 0)  := x"01"; 
  constant COMPASS_OPTION          : unsigned(7 downto 0)  := x"02";   
  constant BPR_OPTION              : unsigned(7 downto 0)  := x"04";
  constant SNAPSHOT_OPTION         : unsigned(7 downto 0)  := x"00";
  constant SETTINGS_OPTION         : unsigned(7 downto 0)  := x"03";
  constant STANDBY_OPTION          : unsigned(7 downto 0)  := x"00";
  constant FIRING_OPTION           : unsigned(7 downto 0)  := x"02";
  
  constant MAX_SNAPSHOT            : unsigned(7 downto 0)  := x"40";  
  constant MAX_GALLERY_IMG_NUMBER  : unsigned(7 downto 0)  := x"40";
  constant CH_IMG_WIDTH            : unsigned(9 downto 0)  := "00" &x"10";--"00" &x"08";
  constant CH_IMG_HEIGHT           : unsigned(9 downto 0)  := "00" &x"20";--"00" &x"10";
  
  constant OLED_POS_V_MAX_OFFSET   :unsigned(9 downto 0)  := to_unsigned(255,10);
  constant OLED_POS_H_MAX_OFFSET   :unsigned(8 downto 0)  := to_unsigned(336,9);--x"FF";--x"80";--x"68";
  
  signal probe0 : std_logic_vector(127 downto 0);
  type   CH_ROM_RDFSM_t is ( s_IDLE, s_WAIT_H,s_GET_CH_ADDR_LY1,s_GET_CH_ADDR_LY2,s_GET_CH_ADDR_LY3,s_GET_ADDR, s_READ ); --s_GET_CH_ADDR,
  signal CH_ROM_RDFSM     : CH_ROM_RDFSM_t;
  signal CH_ROM_ADDR_PIX  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);  -- PIX_BITS for a line, 
  signal CH_ROM_ADDR_PICT : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);

  signal CH_ROM_ADDR_BASE : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal CH_ROM_ADDR_BASE_TEMP : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal RUN        : std_logic;
  signal ADDR_SEL   : std_logic;

  constant FIFO_DEPTH : positive := CH_ROM_ADDR_WIDTH;--10;  -- 2**FIFO_DEPTH words in the FIFO
  constant FIFO_WSIZE : positive := CH_ROM_DATA_WIDTH;  

  signal FIFO_CLR_OSD     : std_logic;
  signal FIFO_WR_OSD      : std_logic;
  signal FIFO_IN_OSD      : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_FUL_OSD     : std_logic;
  signal FIFO_NB_OSD      : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal FIFO_EMP_OSD     : std_logic;
  signal FIFO_RD_OSD      : std_logic;
  signal FIFO_OUT_OSD     : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_OUT_OSD_REV : std_logic_vector(FIFO_WSIZE-1 downto 0);

  constant FIFO_DEPTH1 : positive := 11;--10;  -- 2**FIFO_DEPTH words in the FIFO
--  constant FIFO_WSIZE1 : positive := 24;  
  constant FIFO_WSIZE1 : positive := 8;  
  
  signal FIFO_CLR1     : std_logic;
  signal FIFO_WR1      : std_logic;
  signal FIFO_IN1      : std_logic_vector(FIFO_WSIZE1-1 downto 0);
  signal FIFO_FUL1     : std_logic;
  signal FIFO_NB1      : std_logic_vector(FIFO_DEPTH1-1 downto 0);
  signal FIFO_EMP1     : std_logic;
  signal FIFO_RD1      : std_logic;
  signal FIFO_OUT1     : std_logic_vector(FIFO_WSIZE1-1 downto 0);
  
  signal OSD_DAVi      : std_logic;

  signal OSD_V_D    : std_logic;  
  signal OSD_H_D    : std_logic; 
  signal OSD_DAV_D  : std_logic;
  signal OSD_EOI_D  : std_logic;
  

  signal count             : integer := 0;
  signal FIFO_RD1_CNT      : integer := 0;
  signal FIFO_RD1_CNT_D    : integer := 0;
  signal FIFO_RD_OSD_D : std_logic;
  signal FIFO_RD1_D        : std_logic;
  signal first_time_rd_rq  : std_logic;
  signal OSD_EN_D          : std_logic;
  
  
--  signal LATCH_OSD_REQ_XSIZE    : std_logic_vector(PIX_BITS-1 downto 0);
--  signal LATCH_OSD_REQ_YSIZE    : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_POS_X_OSD        : std_logic_vector(PIX_BITS-1 downto 0);
--  signal LATCH_POS_Y_OSD        : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_OSD_COLOR_INFO1  : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO1   : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO2   : std_logic_vector( 23 downto 0);
--  signal LATCH_CURSOR_COLOR_INFO: std_logic_vector( 23 downto 0);

  signal OSD_REQ_XSIZE          : std_logic_vector(PIX_BITS-1 downto 0);
  signal OSD_REQ_YSIZE          : std_logic_vector(LIN_BITS-1 downto 0);
  signal POS_X_OSD              : std_logic_vector(PIX_BITS-1 downto 0);
  signal POS_Y_OSD              : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_OSD_COLOR_INFO1  : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO1   : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO2   : std_logic_vector( 23 downto 0);
--  signal LATCH_CURSOR_COLOR_INFO: std_logic_vector( 23 downto 0);
  signal LATCH_OSD_COLOR_INFO1  : std_logic_vector(7 downto 0);
  signal LATCH_CH_COLOR_INFO1   : std_logic_vector(7 downto 0);
  signal LATCH_CH_COLOR_INFO2   : std_logic_vector(7 downto 0);
  signal LATCH_CURSOR_COLOR_INFO: std_logic_vector(7 downto 0);
  
  signal LATCH_OSD_POS_X_LY1      : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_OSD_POS_Y_LY1      : std_logic_vector(LIN_BITS-1 downto 0);
  signal LATCH_OSD_POS_X_LY2      : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_OSD_POS_Y_LY2      : std_logic_vector(LIN_BITS-1 downto 0);
  signal LATCH_OSD_POS_X_LY3      : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_OSD_POS_Y_LY3      : std_logic_vector(LIN_BITS-1 downto 0);
  signal LATCH_OSD_REQ_XSIZE_LY1  : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_OSD_REQ_XSIZE_LY2  : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_OSD_REQ_XSIZE_LY3  : std_logic_vector(PIX_BITS-1 downto 0);

  
  signal line_cnt        : unsigned(LIN_BITS-1 downto 0);
  signal pix_cnt         : unsigned(PIX_BITS-1 downto 0);
  signal pix_cnt_d       : unsigned(PIX_BITS-1 downto 0);
  signal RD_OSD_LIN_NO   : unsigned(LIN_BITS-1 downto 0);
  signal OSD_ADD_DONE    : std_logic; 
  signal OSD_POS_Y_TEMP  : std_logic_Vector(LIN_BITS-1 downto 0); 
  signal OSD_POS_Y_D     : std_logic_Vector(LIN_BITS-1 downto 0);  
  signal OSD_POS_X1      : std_logic_vector(PIX_BITS-1 downto 0);  -- OSD POSITION X
  signal OSD_POS_Y1      : std_logic_vector(LIN_BITS-1 downto 0);  -- OSD POSITION Y
  signal OSD_LINE_CNT    : unsigned(LIN_BITS-1 downto 0);
  signal OSD_RD_DONE     : std_logic;
  signal flag            : std_logic;
  
  signal POS_Y_CH     : unsigned(LIN_BITS-1 downto 0);
  signal POS_X_CH     : unsigned(PIX_BITS-1 downto 0);
  signal POS_X_CH_D   : unsigned(PIX_BITS-1 downto 0);
  signal POS_X_CH_DD  : unsigned(PIX_BITS-1 downto 0);

--  signal LATCH_POS_Y_CH_LY2     : unsigned(LIN_BITS-1 downto 0);
--  signal POS_X_CH_LY2     : unsigned(PIX_BITS-1 downto 0);


--  signal LATCH_POS_Y_CH_1     : unsigned(LIN_BITS-1 downto 0);
--  signal POS_X_CH_1     : unsigned(PIX_BITS-1 downto 0);
   
--  signal LATCH_POS_Y_CH_1_LY2 : unsigned(LIN_BITS-1 downto 0);
--  signal POS_X_CH_1_LY2 : unsigned(PIX_BITS-1 downto 0);
  
--  signal LATCH_POS_Y_CH_1_LY3 : unsigned(LIN_BITS-1 downto 0);
--  signal POS_X_CH_1_LY3 : unsigned(PIX_BITS-1 downto 0);

  signal POS_Y_CH_1_LY1     : unsigned(LIN_BITS-1 downto 0);
  signal POS_X_CH_1_LY1     : unsigned(PIX_BITS-1 downto 0);
   
  signal POS_Y_CH_1_LY2 : unsigned(LIN_BITS-1 downto 0);
  signal POS_X_CH_1_LY2 : unsigned(PIX_BITS-1 downto 0);
  
  signal POS_Y_CH_1_LY3 : unsigned(LIN_BITS-1 downto 0);
  signal POS_X_CH_1_LY3 : unsigned(PIX_BITS-1 downto 0);
  
  
  signal CH_CNT    : unsigned(7 downto 0);
  signal SEL_CH_WR_FIFO : std_logic_vector(7 downto 0);
   
  signal DMA_RDDAV_D : std_logic;
  
  signal CH_CNT_FIFO_RD   : unsigned(7 downto 0);
  signal CH_CNT_FIFO_RD_D : unsigned(7 downto 0);
  signal CURSOR_SEL_CNT   : unsigned(7 downto 0);


  signal ADDR_CH_1   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_2   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_3   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_4   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_5   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_6   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_7   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_8   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_9   : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_10  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_11  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_12  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_13  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_14  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_15  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_16  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_17  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_18  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);  
  signal ADDR_CH_19  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_20  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_21  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_22  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_23  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_24  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_25  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_26  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_27  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_28  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_29  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_30  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_31  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_32  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_33  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);  
  signal ADDR_CH_34  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_35  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_36  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_37  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_38  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_39  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_40  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  
  signal CH_ADDR_OFFSET       : unsigned(5 downto 0); 
  signal CURSOR_POS           : unsigned(7 downto 0 );
--  signal LATCH_CURSOR_POS     : unsigned(7 downto 0);
  signal CURSOR_POS_LY2       : unsigned(7 downto 0 );
--  signal LATCH_CURSOR_POS_LY2 : unsigned(7 downto 0);
  
  
  
  signal CH_ROM_DATA : std_logic_vector(CH_ROM_DATA_WIDTH-1 downto 0);
  signal CH_ROM_ADDR : std_logic_vector(CH_ROM_ADDR_WIDTH-1 downto 0); 
 
  signal INTERNAL_LINE_CNT :  unsigned(LIN_BITS-1 downto 0);
  signal CH_LIN_CNT_RD     : unsigned(7 downto 0);
  signal CH_ADD_CNT        : unsigned(7 downto 0);
  signal OSD_REQ_V_D       : std_logic ;
  signal OSD_REQ_V_DD      : std_logic ;
  signal OSD_REQ_V_DDD      : std_logic ;
  signal lin_block_cnt     : unsigned(7 downto 0);
  signal lin_block_cnt_dd  : unsigned(7 downto 0);
  signal lin_block_cnt_d   : unsigned(7 downto 0);
  signal clm_block_cnt     : unsigned(7 downto 0);
  signal add_cursor        : std_logic;
  signal add_cursor_d      : std_logic;
--  signal page_cnt          : unsigned(1 downto 0);
--  signal latch_page_cnt    : unsigned(1 downto 0);
  signal advance_menu_sel  : std_logic;
  signal main_menu_sel     : std_logic;
  signal LATCH_ADVANCE_MENU_TRIG : std_logic;
  signal ADVANCE_MENU_TRIG : std_logic;
  signal ADVANCE_MENU_TRIG_IN : std_logic;
--  signal latch_main_menu_sel    : std_logic;
  signal hot_key_menu_sel       : std_logic;
  signal latch_hot_key_menu_sel : std_logic;

--  signal latch_ly1_sel : std_logic;
--  signal latch_ly2_sel : std_logic;
--  signal latch_ly3_sel : std_logic;   
  signal ly1_sel : std_logic;
  signal ly2_sel : std_logic;
  signal ly3_sel : std_logic;
  
  signal ly2_option_cnt  : unsigned(7 downto 0);
  signal menu_option_cnt : unsigned(7 downto 0);
  signal BIN_DATA          : std_logic_vector(9 downto 0);   
  signal BIN_DATA_VALID    : std_logic;
  signal BCD_DATA          : std_logic_vector(11 downto 0);
  signal BCD_DATA_VALID    : std_logic;
  signal BCD_DATA_D        : std_logic_vector(11 downto 0);

  signal BCD_DATA_RETICLE_OFFSET_H       : std_logic_vector(11 downto 0);
  signal BCD_DATA_RETICLE_OFFSET_H_VALID : std_logic;
  signal BCD_DATA_RETICLE_OFFSET_H_D     : std_logic_vector(11 downto 0);
  signal RETICLE_OFFSET_H_1              : unsigned(9 downto 0);
   
  signal CALIB_MODE                  : unsigned(0 downto 0); 
  signal CALIB_MODE_VALID            : std_logic;
  signal BRIGHTNESS                  : unsigned(7 downto 0);
  signal BRIGHTNESS_VALID            : std_logic;
  signal DZOOM                       : unsigned(2 downto 0);
  signal DZOOM_VALID                 : std_logic;
  signal AGC_MODE                    : unsigned(1 downto 0);
  signal AGC_MODE_VALID              : std_logic;
  signal snapshot_sel                : std_logic_vector(1 downto 0);
  signal SINGLE_SNAPSHOT             : std_logic;
  signal BURST_SNAPSHOT              : std_logic;
  signal SNAPSHOT_COUNTER            : unsigned(7 downto 0);
  signal SNAPSHOT_COUNTER_VALID      : std_logic;
  signal SNAPSHOT_DELETE_EN          : std_logic;
  signal GALLERY_FULL                : std_logic;
  signal GALLERY_FULL_DISP_OFF       : std_logic;
  signal GALLERY_FULL_DISP_EN        : std_logic;




  signal RETICLE_COLOR               : unsigned(2 downto 0);
  signal RETICLE_COLOR_VALID         : std_logic;
  signal RETICLE_TYPE_HIST           : unsigned(3 downto 0);   
  signal RETICLE_TYPE                : unsigned(3 downto 0);
  signal RETICLE_TYPE_VALID          : std_logic;
  signal RETICLE_HORZ                : unsigned(PIX_BITS-1 downto 0); 
--  signal RETICLE_HORZ_VALID          : std_logic;
  signal RETICLE_VERT                : unsigned(LIN_BITS-1 downto 0);
--  signal RETICLE_VERT_VALID          : std_logic;
  signal RETICLE_VERT_HORZ_VALID     : std_logic;
  signal RETICLE_VERT_HORZ_VALID_D   : std_logic;
     
  signal DISPLAY_LUX                 : unsigned(7 downto 0);
  signal DISPLAY_LUX_VALID           : std_logic;
  signal DISPLAY_GAIN                : unsigned(7 downto 0);
  signal DISPLAY_GAIN_VALID          : std_logic;
  signal DISPLAY_HORZ                : unsigned(8 downto 0);
  signal DISPLAY_HORZ_VALID          : std_logic;
  signal DISPLAY_VERT                : unsigned(9 downto 0);
  signal DISPLAY_VERT_VALID          : std_logic;
   
  signal SOFTNUC                     : unsigned(0 downto 0);
  signal SOFTNUC_VALID               : std_logic;
     
  signal SMOOTHING                   : unsigned(0 downto 0); 
  signal SMOOTHING_HIST              : unsigned(0 downto 0);
  signal SMOOTHING_VALID             : std_logic;
  signal SMOOTHING_VALID_D           : std_logic;
  signal SMOOTHING_VALID_DD          : std_logic;

  signal SHARPNESS                  : unsigned(3 downto 0); 
  signal SHARPNESS_VALID            : std_logic;

  signal PALETTE_TYPE                : unsigned(3 downto 0);
  signal PALETTE_TYPE_VALID          : std_logic;
  
  signal MARK_BP                     : unsigned(0 downto 0);  
  signal MARK_BP_VALID               : std_logic;  
  signal MARK_BP_UPDATE              : std_logic;  
  signal UNMARK_BP                   : unsigned(0 downto 0); 
  signal UNMARK_BP_VALID             : std_logic;  
  signal SAVE_BP                     : std_logic;   
  signal LOAD_USER_SETTINGS          : std_logic;  
  signal LOAD_FACTORY_SETTINGS       : std_logic;
  signal SAVE_USER_SETTINGS          : std_logic;  

  signal CONTRAST                    : unsigned(7 downto 0);
  signal CONTRAST_VALID              : std_logic;   

  signal POLARITY                    : unsigned(2 downto 0);
  signal POLARITY_VALID              : std_logic;
  signal EDGE_EN_VALID              : std_logic;
  
  signal GAIN                        : unsigned(7 downto 0);
  signal GAIN_VALID                  : std_logic;                   
 
  signal ly3_val_init_done           : std_logic;
  signal polarity_en                 : std_logic;
--  signal gain_en                     : std_logic;
  signal dzoom_en                    : std_logic;
  
  signal MAX_LIMITER_DPHE       : unsigned(7 downto 0);
  signal MUL_MAX_LIMITER_DPHE   : unsigned(7 downto 0);
  signal CNTRL_MAX_GAIN         : unsigned(7 downto 0);
  signal CNTRL_IPP              : unsigned(7 downto 0);
  signal MAX_LIMITER_DPHE_VALID : std_logic;
  signal MUL_MAX_LIMITER_DPHE_VALID : std_logic;
  signal CNTRL_MAX_GAIN_VALID   : std_logic;
  signal CNTRL_IPP_VALID        : std_logic;  
  signal NUC_MODE               : unsigned(1 downto 0);
  signal BLADE_MODE             : unsigned(1 downto 0);
  signal NUC_MODE_VALID         : std_logic;
  signal BLADE_MODE_VALID       : std_logic;

  
  signal START_NUC1PTCALIB : std_logic;
  signal OSD_EN : std_logic;
    
--  signal DATA_IN_CNT : unsigned(PIX_BITS-1 downto 0);

--  signal VIDEO_IN_DATA_D    :std_logic_vector(23 downto 0);
--  signal VIDEO_IN_DATA_DD   :std_logic_vector(23 downto 0);
--  signal VIDEO_IN_DATA_DDD  :std_logic_vector(23 downto 0);
--  signal VIDEO_IN_DATA_DDDD :std_logic_vector(23 downto 0);

  signal VIDEO_IN_DATA_D    :std_logic_vector(7 downto 0);
  signal VIDEO_IN_DATA_DD   :std_logic_vector(7 downto 0);
  signal VIDEO_IN_DATA_DDD  :std_logic_vector(7 downto 0);
  signal VIDEO_IN_DATA_DDDD :std_logic_vector(7 downto 0);
    
  signal OSD_REQ_H_D    : std_logic;
  signal OSD_REQ_H_DD   : std_logic;  
  signal OSD_REQ_H_DDD  : std_logic;
  signal OSD_REQ_H_DDDD : std_logic;  

  signal VIDEO_IN_V_D    : std_logic;
  signal VIDEO_IN_V_DD   : std_logic;  
  signal VIDEO_IN_V_DDD  : std_logic;
  signal VIDEO_IN_V_DDDD : std_logic;  

  signal VIDEO_IN_H_D    : std_logic;
  signal VIDEO_IN_H_DD   : std_logic;  
  signal VIDEO_IN_H_DDD  : std_logic;
  signal VIDEO_IN_H_DDDD : std_logic;   

  signal VIDEO_IN_DAV_D    : std_logic;
  signal VIDEO_IN_DAV_DD   : std_logic;  
  signal VIDEO_IN_DAV_DDD  : std_logic;
  signal VIDEO_IN_DAV_DDDD : std_logic;
  
  signal VIDEO_IN_EOI_D     : std_logic;
  signal VIDEO_IN_EOI_DD    : std_logic;  
  signal VIDEO_IN_EOI_DDD   : std_logic;
  signal VIDEO_IN_EOI_DDDD  : std_logic;
   
  
  signal MENU_SEL_CENTER_TRIG  : std_logic; 
  signal MENU_SEL_UP_TRIG      : std_logic; 
  signal MENU_SEL_DN_TRIG      : std_logic; 

  signal LATCH_MENU_SEL_CENTER : std_logic; 
  signal LATCH_MENU_SEL_UP     : std_logic; 
  signal LATCH_MENU_SEL_DN     : std_logic; 
  
  signal OSD_EN_DD : std_logic;
  signal menu_timeout_cnt       : unsigned(15 downto 0);
  signal latch_menu_timeout_cnt : unsigned(15 downto 0);
  signal menu_timeout_cnt_start : std_logic; 
  signal snapshot_save_done_latch   : std_logic;
  signal snapshot_save_done_trig    : std_logic;
  signal snapshot_delete_done_latch : std_logic;
  signal snapshot_delete_done_trig  : std_logic;
  signal gyro_calib_done_latch : std_logic;
  signal gyro_calib_done_trig  : std_logic;
      
  signal GALLERY_ENABLE              : std_logic;                   
  signal GALLERY_IMG_NUMBER          : unsigned(7 downto 0);
  signal GALLERY_IMG_NUMBER_VALID    : std_logic;
  signal GALLERY_IMG_VALID           : std_logic_vector(63 downto 0);
  signal GALLERY_IMG_VALID_EN        : std_logic;
  signal LOAD_GALLERY                : std_logic;
  signal LOAD_GALLERY_DONE           : std_logic;
  signal coarse_offset_calib_start           : std_logic;
--  signal   en_OSD_pix_offset : std_logic;
  signal LASER_EN       : unsigned(0 downto 0);
  signal LASER_EN_VALID : std_logic;

  signal GYRO_DATA_DISP_EN       : unsigned(0 downto 0);
  signal GYRO_DATA_DISP_EN_VALID : std_logic;

  signal GYRO_CALIB_EN       : std_logic;
  signal GYRO_CALIB_EN_VALID : std_logic;

  signal STANDBY_EN        : unsigned(0 downto 0);
  signal STANDBY_EN_VALID  : std_logic;
  
  signal SHUTDOWN_EN       : std_logic;
  signal SHUTDOWN_EN_D     : std_logic;
  signal SHUTDOWN_EN_VALID : std_logic;
  signal SHUTDOWN_PROCESS_DONE : std_logic;
  signal shutdown_timeout_cnt : unsigned(15 downto 0);
  signal gallery_full_disp_timeout_cnt : unsigned(15 downto 0);
  signal param_update : std_logic;

  signal FIRING_MODE          : unsigned(0 downto 0); 
  signal FIRING_MODE_VALID    : std_logic;   
  signal DISTANCE_SEL         : unsigned(3 downto 0); 
  signal DISTANCE_SEL_VALID   : std_logic; 
  signal DISTANCE_SEL_VALID_D : std_logic; 
  signal DISTANCE_SEL_VALID_DD: std_logic;
--  signal RETICLE_OFFSET       : unsigned(3 downto 0); 
  signal RETICLE_OFFSET_VALID : std_logic; 

--  signal FIT_TO_SCREEN_EN       : unsigned(0 downto 0); 
--  signal FIT_TO_SCREEN_EN_VALID : std_logic; 

  signal DISPLAY_MODE       : unsigned(0 downto 0); 
  signal DISPLAY_MODE_VALID : std_logic; 

  signal SIGHT_MODE       : unsigned(1 downto 0); 
  signal SIGHT_MODE_VALID : std_logic; 

  ATTRIBUTE MARK_DEBUG : string;
--  ATTRIBUTE MARK_DEBUG of  DMA_RDFSM_check: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  VIDEO_IN_DATA_D: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  VIDEO_IN_DATA_DD: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OSD_DAVi: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_OUT_OSD: SIGNAL IS "TRUE";
--  --ATTRIBUTE MARK_DEBUG of  FIFO_OUT_D: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_RD_OSD: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_WR_OSD: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_CLR_OSD: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_RD_OSD_1: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_WR_OSD_1: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  FIFO_CLR_OSD_1: SIGNAL IS "TRUE";  
----  ATTRIBUTE MARK_DEBUG of  OSD_XCNTi: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  OSD_YCNTi: SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  DMA_ADDR_PIX_check: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  count: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_RD1_CNT : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_RD1_CNT_D : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_NB_OSD : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  FIFO_NB1 : SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  OSD_cnt1 : SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  OSD_cnt2 : SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OSD_FIELD: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OSD_EN: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OSD_EN_D: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  line_cnt: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OSD_ADD_DONE: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  LATCH_POS_X_OSD: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  LATCH_POS_Y_OSD: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OSD_POS_X: SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of  OSD_POS_Y: SIGNAL IS "TRUE"; 
  
----  ATTRIBUTE MARK_DEBUG of  OSD_XSIZE_OFFSET_L : SIGNAL IS "TRUE"; 
----  ATTRIBUTE MARK_DEBUG of  OSD_PIX_OFFSET : SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of  OSD_XSIZE_OFFSET_R : SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of OSD_PIX_OFFSET_D : SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of flag :SIGNAL IS "TRUE";

--  ATTRIBUTE MARK_DEBUG of FIFO_RD1_D       :SIGNAL IS "TRUE"; 
--  ATTRIBUTE MARK_DEBUG of FIFO_OUT1        :SIGNAL IS "TRUE"; 
--  ATTRIBUTE MARK_DEBUG of pix_cnt_d        :SIGNAL IS "TRUE"; 
  
--  ATTRIBUTE MARK_DEBUG of RD_OSD_LIN_NO    :SIGNAL IS "TRUE";
----  ATTRIBUTE MARK_DEBUG of OSD_YSIZE_OFFSET :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of VIDEO_IN_YSIZE       :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of DMA_ADDR_PICT        :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of DMA_ADDR_PIX         :SIGNAL IS "TRUE";
  
--  ATTRIBUTE MARK_DEBUG of FIFO_EMP_OSD  :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of FIFO_EMP1 :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of OSD_RD_DONE :SIGNAL IS "TRUE";
  
--  ATTRIBUTE MARK_DEBUG of LATCH_POS_Y_CH :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of POS_X_CH :SIGNAL IS "TRUE";
  
--  ATTRIBUTE MARK_DEBUG of LATCH_POS_Y_CH_1 :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of POS_X_CH_1 :SIGNAL IS "TRUE";
  
--  ATTRIBUTE MARK_DEBUG of CH_CNT         :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of SEL_CH_WR_FIFO :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of DMA_RDDAV_D    :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of DMA_RDDATA     :SIGNAL IS "TRUE";
  
----  ATTRIBUTE MARK_DEBUG of DMA_ADDR_PICT :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of DMA_ADDR_BASE :SIGNAL IS "TRUE"; 
--  ATTRIBUTE MARK_DEBUG of CLK :SIGNAL IS "TRUE"; 
--  ATTRIBUTE MARK_DEBUG of FIFO_IN_OSD_1 :SIGNAL IS "TRUE"; 
--  ATTRIBUTE MARK_DEBUG of CH_CNT_FIFO_RD  :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of CH_CNT_FIFO_RD_D :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of CURSOR_SEL_CNT   :SIGNAL IS "TRUE";
--  ATTRIBUTE MARK_DEBUG of CURSOR_POS       :SIGNAL IS "TRUE";
  
--  ATTRIBUTE MARK_DEBUG of  en_OSD_pix_offset : SIGNAL IS "TRUE";

 ATTRIBUTE MARK_DEBUG of OSD_DAVi         :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of FIFO_EMP_OSD     :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of FIFO_NB1         :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of VIDEO_IN_H       :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of VIDEO_IN_V       :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of VIDEO_IN_DAV     :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of OSD_REQ_V        :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of OSD_REQ_H        :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of OSD_FIELD        :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of VIDEO_IN_EOI     :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of OSD_EOI_D        :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of FIFO_RD1         :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of FIFO_WR1         :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of OSD_EN           :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of OSD_EN_D         :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of FIFO_RD_OSD      :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of FIFO_WR_OSD      :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of count            :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of pix_cnt          :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of line_cnt         :SIGNAL IS "TRUE";
-- ATTRIBUTE MARK_DEBUG of POS_X_CH_D :SIGNAL IS "TRUE";    
 ATTRIBUTE MARK_DEBUG of pix_cnt_d        :SIGNAL IS "TRUE";
 ATTRIBUTE MARK_DEBUG of lin_block_cnt_dd :SIGNAL IS "TRUE";     
 ATTRIBUTE MARK_DEBUG of lin_block_cnt_d  :SIGNAL IS "TRUE";     
 ATTRIBUTE MARK_DEBUG of lin_block_cnt    :SIGNAL IS "TRUE";     
 ATTRIBUTE MARK_DEBUG of clm_block_cnt    :SIGNAL IS "TRUE";   
-- ATTRIBUTE MARK_DEBUG of POS_X_CH_DD:SIGNAL IS "TRUE";   
-- ATTRIBUTE MARK_DEBUG of POS_X_CH   :SIGNAL IS "TRUE";   


--------
begin
--------
--DMA_RDFSM_check <=  "000" when DMA_RDFSM = s_IDLE else
--                    "001" when DMA_RDFSM = s_WAIT_H else
----                    "010" when DMA_RDFSM = s_GET_CH_ADDR else
--                    "011" when DMA_RDFSM = s_GET_ADDR else
--                    "100" when DMA_RDFSM = s_READ else
--                    "111";
OSD_EN_OUT                      <= OSD_EN;
--OSD_START_NUC1PTCALIB           <= '0'when (CALIB_MODE="0")else '1';--START_NUC1PTCALIB;     
OSD_START_NUC1PTCALIB           <= CALIB_MODE_VALID;      
OSD_COARSE_OFFSET_CALIB_START   <= coarse_offset_calib_start;
OSD_DZOOM                       <= std_logic_vector(DZOOM);
OSD_DZOOM_VALID                 <= DZOOM_VALID;
OSD_AGC_MODE_SEL                <= std_logic_vector(AGC_MODE);
OSD_AGC_MODE_SEL_VALID          <= AGC_MODE_VALID;
OSD_SNAPSHOT_COUNTER            <= std_logic_Vector(SNAPSHOT_COUNTER);
OSD_SNAPSHOT_COUNTER_VALID      <= SNAPSHOT_COUNTER_VALID;
OSD_BRIGHTNESS                  <= std_logic_vector(BRIGHTNESS);
OSD_BRIGHTNESS_VALID            <= BRIGHTNESS_VALID;
OSD_CONTRAST                    <= std_logic_vector(GAIN);
OSD_CONTRAST_VALID              <= GAIN_VALID;
--OSD_RETICLE_COLOR               <= '1'when (RETICLE_COLOR="1")else '0'; 
OSD_RETICLE_COLOR               <= std_logic_vector(RETICLE_COLOR);
OSD_RETICLE_COLOR_VALID         <= RETICLE_COLOR_VALID;
OSD_RETICLE_TYPE_SEL            <= std_logic_vector(RETICLE_TYPE); 
OSD_RETICLE_TYPE_SEL_VALID      <= RETICLE_TYPE_VALID;
OSD_RETICLE_POS_YX              <= "00" &std_logic_vector(RETICLE_VERT) & "0" & std_logic_vector(RETICLE_HORZ);
OSD_RETICLE_POS_YX_VALID        <= RETICLE_VERT_HORZ_VALID_D;
--OSD_RETICLE_POS_X               <= std_logic_vector(RETICLE_HORZ);
--OSD_RETICLE_POS_X_VALID         <= RETICLE_HORZ_VALID;
--OSD_RETICLE_POS_Y               <= std_logic_vector(RETICLE_VERT);
--OSD_RETICLE_POS_Y_VALID         <= RETICLE_VERT_VALID;

OSD_DISPLAY_LUX                 <= std_logic_vector(DISPLAY_LUX);
OSD_DISPLAY_LUX_VALID           <= DISPLAY_LUX_VALID;
OSD_DISPLAY_GAIN                <= std_logic_vector(DISPLAY_GAIN);
OSD_DISPLAY_GAIN_VALID          <= DISPLAY_GAIN_VALID;
OSD_DISPLAY_VERT                <= std_logic_vector(DISPLAY_VERT);
OSD_DISPLAY_VERT_VALID          <= DISPLAY_VERT_VALID;
OSD_DISPLAY_HORZ                <= std_logic_vector(DISPLAY_HORZ);
OSD_DISPLAY_HORZ_VALID          <= DISPLAY_HORZ_VALID;

OSD_SNUC_EN                     <= '1' when (SOFTNUC = "1") else '0';
OSD_SNUC_EN_VALID               <= SOFTNUC_VALID;
OSD_SMOOTHING_EN                <= '1' when (SMOOTHING = "1") else '0';
OSD_SMOOTHING_EN_VALID          <= SMOOTHING_VALID_DD when (POLARITY = "000" or POLARITY = "001" or POLARITY = "010" ) else '0';
OSD_SHARPNESS                   <= std_logic_Vector(SHARPNESS);
OSD_SHARPNESS_VALID             <= SHARPNESS_VALID;
OSD_CP_TYPE_SEL                 <= '0' &std_logic_vector(PALETTE_TYPE);
OSD_CP_TYPE_SEL_VALID           <= PALETTE_TYPE_VALID;
--OSD_POLARITY                    <= '1' when (POLARITY = "01" or POLARITY = "11") else '0';
OSD_POLARITY                    <= "01" when (POLARITY = "001" or POLARITY = "100") else "00" when (POLARITY = "000" or POLARITY = "011") else "10";
OSD_POLARITY_VALID              <= POLARITY_VALID;
OSD_EDGE_EN                     <= '1' when (POLARITY = "011" or POLARITY = "100") else '0';
OSD_EDGE_EN_VALID               <= EDGE_EN_VALID;
OSD_MARK_BP                     <= '1' when (MARK_BP = "1") else '0';        
OSD_MARK_BP_VALID               <= MARK_BP_UPDATE;          
OSD_UNMARK_BP                   <= '1' when (MARK_BP = "0") else '0';          
OSD_UNMARK_BP_VALID             <= MARK_BP_UPDATE;          
OSD_SAVE_BP                     <= SAVE_BP;                
OSD_LOAD_USER_SETTINGS          <= LOAD_USER_SETTINGS;       
OSD_LOAD_FACTORY_SETTINGS       <= LOAD_FACTORY_SETTINGS;
OSD_SAVE_USER_SETTINGS          <= SAVE_USER_SETTINGS  or (((SHUTDOWN_EN and (not SHUTDOWN_EN_D)) or (not OSD_EN)) and param_update);   --SHUTDOWN_EN_VALID 
OSD_SINGLE_SNAPSHOT             <= SINGLE_SNAPSHOT;
OSD_BURST_SNAPSHOT              <= BURST_SNAPSHOT;  
OSD_GALLERY_ENABLE              <= GALLERY_ENABLE;
OSD_GALLERY_IMG_NUMBER          <= std_logic_vector(GALLERY_IMG_NUMBER);
OSD_GALLERY_IMG_VALID           <= GALLERY_IMG_VALID & std_logic_vector(SNAPSHOT_COUNTER);
OSD_GALLERY_IMG_VALID_EN        <= GALLERY_IMG_VALID_EN;
OSD_SNAPSHOT_DELETE_EN          <= SNAPSHOT_DELETE_EN;
OSD_LASER_EN                    <= '1' when (LASER_EN = "1") else '0';
OSD_LASER_EN_VALID              <= LASER_EN_VALID;     
OSD_GYRO_DATA_DISP_EN           <= '1' when (GYRO_DATA_DISP_EN = "1") else '0';
OSD_GYRO_DATA_DISP_EN_VALID     <= GYRO_DATA_DISP_EN_VALID;
OSD_GYRO_CALIB_EN               <= GYRO_CALIB_EN;
OSD_GYRO_CALIB_EN_VALID         <= GYRO_CALIB_EN_VALID;
OSD_STANDBY_EN                  <= '1' when (STANDBY_EN = "1") else '0';
OSD_STANDBY_EN_VALID            <= STANDBY_EN_VALID;  
OSD_POWER_OFF_EN                <= '1' when (SHUTDOWN_EN = '1' and SHUTDOWN_PROCESS_DONE = '1') else '0';
OSD_LOAD_GALLERY                <= LOAD_GALLERY and (not(LOAD_GALLERY_DONE));  
OSD_DISTANCE_SEL                <= std_logic_vector(DISTANCE_SEL);
OSD_DISTANCE_SEL_VALID          <= DISTANCE_SEL_VALID;
OSD_FIRING_MODE                 <= '1' when FIRING_MODE = "1" else '0';
OSD_FIRING_MODE_VALID           <= FIRING_MODE_VALID;
--OSD_FIT_TO_SCREEN_EN            <= '1' when FIT_TO_SCREEN_EN = "1" else '0'; 
--OSD_FIT_TO_SCREEN_EN_VALID      <= FIT_TO_SCREEN_EN_VALID;
OSD_DISPLAY_MODE                <= '1' when DISPLAY_MODE  = "1" else '0'; 
OSD_DISPLAY_MODE_VALID          <= DISPLAY_MODE_VALID;

OSD_SIGHT_MODE                  <= std_logic_vector(SIGHT_MODE); 
OSD_SIGHT_MODE_VALID            <= SIGHT_MODE_VALID;

--OSD_MAX_LIMITER_DPHE            <= std_logic_vector(MAX_LIMITER_DPHE*to_unsigned(50,16));
OSD_MAX_LIMITER_DPHE            <= std_logic_vector(MAX_LIMITER_DPHE);
OSD_MAX_LIMITER_DPHE_VALID      <= MAX_LIMITER_DPHE_VALID;
OSD_MUL_MAX_LIMITER_DPHE        <= std_logic_vector(MUL_MAX_LIMITER_DPHE);
OSD_MUL_MAX_LIMITER_DPHE_VALID  <= MUL_MAX_LIMITER_DPHE_VALID;
--OSD_CNTRL_MAX_GAIN              <= std_logic_vector(CNTRL_MAX_GAIN*to_unsigned(640,16));
OSD_CNTRL_MAX_GAIN              <= std_logic_vector(CNTRL_MAX_GAIN);
OSD_CNTRL_MAX_GAIN_VALID        <= CNTRL_MAX_GAIN_VALID;
--OSD_CNTRL_IPP                   <= std_logic_vector(CNTRL_IPP*to_unsigned(2,16));
OSD_CNTRL_IPP                   <= std_logic_vector(CNTRL_IPP);
OSD_CNTRL_IPP_VALID             <= CNTRL_IPP_VALID;
OSD_NUC_MODE                    <= std_logic_vector(NUC_MODE);
OSD_NUC_MODE_VALID              <= NUC_MODE_VALID;
OSD_BLADE_MODE                  <= std_logic_vector(BLADE_MODE);
OSD_BLADE_MODE_VALID            <= BLADE_MODE_VALID;

CH_ADDR_OFFSET    <= unsigned(CH_IMG_HEIGHT(5 downto 0));
CURSOR_POS_OUT    <= std_logic_Vector(CURSOR_POS);

  -- ---------------------------------
  --  DMA Master Read Process
  -- ---------------------------------
  process(CLK, RST)
  begin
    if RST = '1' then
      RUN                     <= '0';
      ADDR_SEL                <= '1';
      CH_ROM_ADDR_PICT        <= (others => '0');
      CH_ROM_RDFSM            <= s_IDLE;
      LATCH_OSD_COLOR_INFO1   <= x"50";--x"508080";
      LATCH_CH_COLOR_INFO1    <= x"EB";--x"EB8080";
      LATCH_CH_COLOR_INFO2    <= x"10";--x"108080";
      LATCH_CURSOR_COLOR_INFO <= x"EB";--x"EB8080";
--      LATCH_POS_X_OSD         <= (others => '0');
--      LATCH_POS_Y_OSD         <= (others => '0');
--      POS_X_CH_1        <= (others => '0');
--      LATCH_POS_Y_CH_1        <= (others => '0');
--      POS_X_CH_1_LY2    <= (others => '0');
--      LATCH_POS_Y_CH_1_LY2    <= (others => '0');
--      POS_X_CH_1_LY3    <= (others => '0');
--      LATCH_POS_Y_CH_1_LY3    <= (others => '0');
--      POS_X_CH                <= (others => '0');
--      POS_Y_CH                <= (others => '0');
      LATCH_OSD_POS_X_LY1     <= (others => '0');
      LATCH_OSD_POS_X_LY2     <= (others => '0');
      LATCH_OSD_POS_X_LY3     <= (others => '0');
      LATCH_OSD_POS_Y_LY1     <= (others => '0');
      LATCH_OSD_POS_Y_LY2     <= (others => '0');
      LATCH_OSD_POS_Y_LY3     <= (others => '0');
      LATCH_OSD_REQ_XSIZE_LY1 <= (others => '0');
      LATCH_OSD_REQ_XSIZE_LY2 <= (others => '0');
      LATCH_OSD_REQ_XSIZE_LY3 <= (others => '0');
      POS_X_OSD               <= (others => '0');
      POS_Y_OSD               <= (others => '0');
      OSD_REQ_XSIZE           <= (others => '0');
      POS_X_CH_1_LY1          <= (others => '0');
      POS_Y_CH_1_LY1          <= (others => '0');
      POS_X_CH_1_LY2          <= (others => '0');
      POS_Y_CH_1_LY2          <= (others => '0');
      POS_X_CH_1_LY3          <= (others => '0');
      POS_Y_CH_1_LY3          <= (others => '0');
      line_cnt                <= (others => '0');
      RD_OSD_LIN_NO           <= (others => '0');
      OSD_POS_Y_TEMP          <= (others => '0');
      OSD_POS_Y_D             <= (others => '0');
      OSD_RD_DONE             <= '0';
      OSD_POS_X_OUT           <= std_logic_vector(to_unsigned(6,OSD_POS_X_OUT'length));
      OSD_POS_Y_OUT           <= std_logic_vector(to_unsigned(16,OSD_POS_Y_OUT 'length));
      CH_CNT                  <= (others => '0');
      SEL_CH_WR_FIFO          <= (others => '0');
      DMA_RDDAV_D             <= '0';
--      LATCH_CURSOR_POS        <= x"00";
--      LATCH_MENU_SEL_UP       <= '0';
--      LATCH_MENU_SEL_DN       <= '0';
      ADDR_CH_1               <= resize(12*CH_IMG_HEIGHT,CH_ROM_ADDR_WIDTH);
      ADDR_CH_2               <= resize(1*CH_IMG_HEIGHT,CH_ROM_ADDR_WIDTH);    
      ADDR_CH_3               <= (others => '0');
      ADDR_CH_4               <= (others => '0');
      ADDR_CH_5               <= (others => '0');
      ADDR_CH_6               <= resize(13*CH_IMG_HEIGHT,CH_ROM_ADDR_WIDTH);
      ADDR_CH_7               <= resize(1*CH_IMG_HEIGHT,CH_ROM_ADDR_WIDTH);
      ADDR_CH_8               <= (others => '0');
      ADDR_CH_9               <= (others => '0');
      ADDR_CH_10              <= (others => '0');
      ADDR_CH_11              <= resize(14*CH_IMG_HEIGHT,CH_ROM_ADDR_WIDTH);
      ADDR_CH_12              <= resize(1*CH_IMG_HEIGHT,CH_ROM_ADDR_WIDTH);
      ADDR_CH_13              <= (others => '0');
      ADDR_CH_14              <= (others => '0');
      ADDR_CH_15              <= (others => '0');
      ADDR_CH_16              <= (others => '0');
      ADDR_CH_17              <= (others => '0');
      ADDR_CH_18              <= (others => '0');
      ADDR_CH_19              <= (others => '0');
      ADDR_CH_20              <= (others => '0');
      ADDR_CH_21              <= (others => '0');
      ADDR_CH_22              <= (others => '0');
      ADDR_CH_23              <= (others => '0');
      ADDR_CH_24              <= (others => '0');
      CURSOR_POS              <= x"00";
      CURSOR_POS_LY2          <= x"00";
--      OSD_EN_OUT              <= '0';
      INTERNAL_LINE_CNT       <= (others=>'0');
      CH_ADD_CNT              <= (others=>'0');
--      page_cnt                <= (others=>'0');
--      latch_page_cnt          <= (others=>'0');
      main_menu_sel           <= '0';
--      latch_main_menu_sel     <= '0';
      advance_menu_sel        <= '0';
      ADVANCE_MENU_TRIG       <= '0';
      ADVANCE_MENU_TRIG_IN    <= '0';
      LATCH_ADVANCE_MENU_TRIG <= '0';
      hot_key_menu_sel        <= '0';
      latch_hot_key_menu_sel  <= '0';
--      latch_ly1_sel           <= '0';
--      latch_ly2_sel           <= '0';
--      latch_ly3_sel           <= '0';
      ly1_sel                 <= '0';
      ly2_sel                 <= '0';
      ly3_sel                 <= '0';
      ly2_option_cnt          <= (others => '0');
      menu_option_cnt         <= (others => '0');
      CALIB_MODE          <= to_unsigned(  0,CALIB_MODE'length);
      BRIGHTNESS          <= to_unsigned(  6,BRIGHTNESS'length);
      DZOOM               <= to_unsigned(  0,DZOOM'length);
      AGC_MODE            <= to_unsigned(  1,AGC_MODE'length);
      RETICLE_COLOR       <= to_unsigned(  0,RETICLE_COLOR'length);
      RETICLE_TYPE        <= to_unsigned(  0,RETICLE_TYPE'length);
      RETICLE_VERT        <= to_unsigned(239,RETICLE_VERT'length);
      RETICLE_HORZ        <= to_unsigned(319,RETICLE_HORZ'length);
      DISPLAY_LUX         <= to_unsigned(50,DISPLAY_LUX'length);
      DISPLAY_GAIN        <= to_unsigned(50,DISPLAY_GAIN'length);
      DISPLAY_VERT        <= to_unsigned( 12,DISPLAY_VERT'length);
      DISPLAY_HORZ        <= to_unsigned( 11,DISPLAY_HORZ'length);
      SOFTNUC             <= to_unsigned(  0,SOFTNUC'length);
      SMOOTHING           <= to_unsigned(  0,SMOOTHING'length);
      SMOOTHING_HIST      <= to_unsigned(  0,SMOOTHING_HIST'length);
      SHARPNESS           <= to_unsigned(  0,SHARPNESS'length);
      PALETTE_TYPE        <= to_unsigned(  0,PALETTE_TYPE'length);
      MARK_BP             <= to_unsigned(  0,MARK_BP'length);
      POLARITY            <= to_unsigned(  0,POLARITY'length);
      GAIN                <= to_unsigned(  6,GAIN'length);
      CALIB_MODE_VALID    <= '0';
      BRIGHTNESS_VALID    <= '0';
      DZOOM_VALID         <= '0';
      AGC_MODE_VALID      <= '0';
      SNAPSHOT_COUNTER_VALID <= '0';
      GALLERY_IMG_NUMBER_VALID <= '0';
      LOAD_GALLERY        <= '0'; 
      LOAD_GALLERY_DONE   <= '0'; 
      RETICLE_COLOR_VALID <= '0';
      RETICLE_TYPE_VALID  <= '0';
      RETICLE_VERT_HORZ_VALID  <= '0';
      RETICLE_VERT_HORZ_VALID_D<= '0';    
--      RETICLE_VERT_VALID  <= '0';
--      RETICLE_HORZ_VALID  <= '0';
      DISPLAY_LUX_VALID   <= '0';
      DISPLAY_GAIN_VALID  <= '0';
      DISPLAY_VERT_VALID  <= '0';
      DISPLAY_HORZ_VALID  <= '0';
      SOFTNUC_VALID       <= '0';
      SMOOTHING_VALID     <= '0';
      SMOOTHING_VALID_D   <= '0';
      SMOOTHING_VALID_DD  <= '0';
      SHARPNESS_VALID     <= '0';
      PALETTE_TYPE_VALID  <= '0';
      MARK_BP_VALID       <= '0';
      MARK_BP_UPDATE      <= '0';
      POLARITY_VALID      <= '0';
      EDGE_EN_VALID       <= '0';
      GAIN_VALID          <= '0';
      ly3_val_init_done   <= '0';
      BCD_DATA_D          <= (others=>'0');
      polarity_en         <= '0';
--      gain_en             <= '0';
      dzoom_en            <= '0';
      START_NUC1PTCALIB      <= '0';
      SAVE_USER_SETTINGS     <= '0';
      LOAD_FACTORY_SETTINGS  <= '0';
      LOAD_USER_SETTINGS     <= '0';
      SAVE_BP                <= '0';
      snapshot_sel           <= (others=>'0');
      SINGLE_SNAPSHOT        <= '0';
      BURST_SNAPSHOT         <= '0';  
      SNAPSHOT_DELETE_EN     <= '0';
      SNAPSHOT_COUNTER       <= x"00";--x"01";  
      GALLERY_FULL           <= '0';  
      GALLERY_FULL_DISP_OFF  <= '0';
      GALLERY_FULL_DISP_EN   <= '0';
      RETICLE_TYPE_HIST      <= (others=>'0');
      menu_timeout_cnt_start <= '0';
      menu_timeout_cnt       <= (others=>'0');
      latch_menu_timeout_cnt <= (others=>'0');
      OSD_EN_D               <= '0';
      OSD_EN_DD              <= '0'; 
      param_update           <= '0';               
      OSD_REQ_H_D            <= '0';
      OSD_REQ_H_DD           <= '0';
      OSD_REQ_H_DDD          <= '0';
      OSD_REQ_H_DDDD         <= '0';
      LATCH_MENU_SEL_CENTER  <= '0';
      LATCH_MENU_SEL_UP      <= '0';
      LATCH_MENU_SEL_DN      <= '0';
      snapshot_save_done_latch   <= '0';
      snapshot_save_done_trig    <= '0';
      snapshot_delete_done_latch <= '0';
      snapshot_delete_done_trig  <= '0';
      gyro_calib_done_latch      <= '0';
      gyro_calib_done_trig       <= '0';
      GALLERY_ENABLE      <= '0';
      GALLERY_IMG_NUMBER <= x"01";
      GALLERY_IMG_VALID    <= (others=>'0');
      GALLERY_IMG_VALID_EN <= '0';
      coarse_offset_calib_start <= '0';
      LASER_EN <=(others=>'0');
      LASER_EN_VALID <= '0';
      GYRO_DATA_DISP_EN       <= (others=>'0');
      GYRO_DATA_DISP_EN_VALID <= '0';
      GYRO_CALIB_EN       <= '0';
      GYRO_CALIB_EN_VALID <= '0';
      STANDBY_EN <=(others=>'0');
      STANDBY_EN_VALID <= '0';
      SHUTDOWN_EN <= '0';
      SHUTDOWN_EN_D <= '0';
      SHUTDOWN_EN_VALID <= '0';
      SHUTDOWN_PROCESS_DONE <= '0';
      shutdown_timeout_cnt <=  (others=>'0');
      gallery_full_disp_timeout_cnt <= (others=>'0');
      RETICLE_OFFSET_VALID<= '0';
      FIRING_MODE_VALID   <= '0';
      DISTANCE_SEL_VALID  <= '0';
      DISTANCE_SEL_VALID_D <= '0';
      DISTANCE_SEL_VALID_DD<= '0';
--      FIT_TO_SCREEN_EN_VALID <= '0';
      DISPLAY_MODE_VALID <= '0';    
      SIGHT_MODE_VALID   <= '0';
      FIRING_MODE  <= (others=>'0');
      DISTANCE_SEL <= (others=>'0');
--      FIT_TO_SCREEN_EN <= (others=>'0');
      DISPLAY_MODE <= (others=>'0');
      SIGHT_MODE   <= (others=>'0');
      MAX_LIMITER_DPHE      <= (others=>'0');
      MUL_MAX_LIMITER_DPHE  <= (others=>'0');
      CNTRL_MAX_GAIN        <= (others=>'0');
      CNTRL_IPP             <= (others=>'0');
      MAX_LIMITER_DPHE_VALID<= '0';
      MUL_MAX_LIMITER_DPHE_VALID<= '0';
      CNTRL_MAX_GAIN_VALID  <= '0';
      CNTRL_IPP_VALID       <= '0';
      NUC_MODE              <= (others=>'0');
      BLADE_MODE            <= (others=>'0');
      NUC_MODE_VALID        <= '0';
      BLADE_MODE_VALID      <= '0';      
--      RETICLE_OFFSET <= (others=>'1');
    elsif rising_edge(CLK) then   
      NUC_MODE_VALID         <= '0';  
      BLADE_MODE_VALID       <= '0';  
      MAX_LIMITER_DPHE_VALID <= '0';
      MUL_MAX_LIMITER_DPHE_VALID<= '0'; 
      CNTRL_MAX_GAIN_VALID   <= '0'; 
      CNTRL_IPP_VALID        <= '0'; 
      SHUTDOWN_EN_D <= SHUTDOWN_EN;   
      GALLERY_FULL_DISP_OFF<= '0';
      ADVANCE_MENU_TRIG_IN <= '0';
      SHUTDOWN_EN_VALID    <= '0';
      STANDBY_EN_VALID     <= '0';
      GYRO_DATA_DISP_EN_VALID <= '0';
      GYRO_CALIB_EN_VALID <= '0';
      GYRO_CALIB_EN       <= '0';
      LASER_EN_VALID       <= '0';
      coarse_offset_calib_start <= '0';
      GALLERY_IMG_VALID_EN <= '0';
      CALIB_MODE_VALID    <= '0';
      BRIGHTNESS_VALID    <= '0';
      DZOOM_VALID         <= '0';
      AGC_MODE_VALID      <= '0';
      RETICLE_OFFSET_VALID<= '0';
      FIRING_MODE_VALID   <= '0';
      DISTANCE_SEL_VALID  <= '0';
      DISTANCE_SEL_VALID_D <= DISTANCE_SEL_VALID;
      DISTANCE_SEL_VALID_DD<= DISTANCE_SEL_VALID_D;
--      FIT_TO_SCREEN_EN_VALID <= '0';
      DISPLAY_MODE_VALID     <= '0';
      SIGHT_MODE_VALID       <= '0';
      SNAPSHOT_COUNTER_VALID <= '0';
      GALLERY_IMG_NUMBER_VALID <= '0';
      LOAD_GALLERY        <= '0';  
      RETICLE_COLOR_VALID <= '0';
      RETICLE_TYPE_VALID  <= '0';
      RETICLE_VERT_HORZ_VALID   <= '0';
      RETICLE_VERT_HORZ_VALID_D <= RETICLE_VERT_HORZ_VALID;
--      RETICLE_VERT_VALID  <= '0';
--      RETICLE_HORZ_VALID  <= '0';
      DISPLAY_LUX_VALID   <= '0';
      DISPLAY_GAIN_VALID  <= '0';
      DISPLAY_VERT_VALID  <= '0';
      DISPLAY_HORZ_VALID  <= '0';
      SOFTNUC_VALID       <= '0';
      SMOOTHING_VALID     <= '0';
      SMOOTHING_VALID_D   <= SMOOTHING_VALID;
      SMOOTHING_VALID_DD  <= SMOOTHING_VALID_D;
      SHARPNESS_VALID     <= '0';
      PALETTE_TYPE_VALID  <= '0';
      MARK_BP_VALID       <= '0';
      MARK_BP_UPDATE      <= '0';
      POLARITY_VALID      <= '0'; 
      EDGE_EN_VALID       <= POLARITY_VALID;
      GAIN_VALID          <= '0'; 
      FIFO_WR_OSD <= '0';      

      OSD_EN_D            <= OSD_EN;
      OSD_EN_DD           <= OSD_EN_D;
      --OSD_EN_DD           <= '0';

      OSD_REQ_H_D             <= OSD_REQ_H;    
      OSD_REQ_H_DD            <= OSD_REQ_H_D;   
      OSD_REQ_H_DDD           <= OSD_REQ_H_DD;   
      OSD_REQ_H_DDDD          <= OSD_REQ_H_DDD;
      snapshot_save_done_latch   <= '0'; 
      snapshot_delete_done_latch <= '0';
      gyro_calib_done_latch      <= '0';
      LATCH_MENU_SEL_CENTER   <= '0';
      LATCH_MENU_SEL_UP       <= '0';
      LATCH_MENU_SEL_DN       <= '0';
      LATCH_ADVANCE_MENU_TRIG <= '0';
      
     if(LOAD_GALLERY = '1') then
        LOAD_GALLERY_DONE <= '1';
     end if;

      case CH_ROM_RDFSM is         

        when s_IDLE =>
            CH_ROM_ADDR_PIX <= (others => '0');
            line_cnt        <= (others => '0');        
            if OSD_EN_DD ='1' then
             CH_ROM_RDFSM   <= s_WAIT_H;
            end if; 

        when s_WAIT_H =>
            if OSD_REQ_H_DDDD = '1' then
              line_cnt     <= line_cnt + 1;
              OSD_RD_DONE  <= '0';         
              if(ly1_sel = '1')then
                  if (line_cnt >= (POS_Y_CH(LIN_BITS-1 downto 0)) and  (line_cnt < (unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0))+ POS_Y_CH(LIN_BITS-1 downto 0)))) then
                      CH_ROM_RDFSM      <= s_GET_CH_ADDR_LY1;
                      INTERNAL_LINE_CNT <= INTERNAL_LINE_CNT +1;
                  else
                      CH_ROM_RDFSM      <= s_WAIT_H;
                      INTERNAL_LINE_CNT <= (others=>'0');
                  end if;    
              elsif(ly2_sel = '1') then  
                  if (line_cnt >= (POS_Y_CH(LIN_BITS-1 downto 0)) and  (line_cnt < (unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0))+ POS_Y_CH(LIN_BITS-1 downto 0)))) then
                      CH_ROM_RDFSM      <= s_GET_CH_ADDR_LY2;
                      INTERNAL_LINE_CNT <= INTERNAL_LINE_CNT +1;
                  else
                      CH_ROM_RDFSM      <= s_WAIT_H;
                      INTERNAL_LINE_CNT <= (others=>'0');
                  end if;  
              elsif(ly3_sel = '1') then  
                  if (line_cnt >= (POS_Y_CH(LIN_BITS-1 downto 0)) and  (line_cnt < (unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0))+ POS_Y_CH(LIN_BITS-1 downto 0)))) then
                      CH_ROM_RDFSM      <= s_GET_CH_ADDR_LY3;
                      INTERNAL_LINE_CNT <= INTERNAL_LINE_CNT +1;
                  else
                      CH_ROM_RDFSM      <= s_WAIT_H;
                      INTERNAL_LINE_CNT <= (others=>'0');
                  end if;  
              else
                  CH_ROM_RDFSM      <= s_WAIT_H;
                  INTERNAL_LINE_CNT <= (others=>'0');                   
              end if;
              
              
                                        
            end if;


        when s_GET_CH_ADDR_LY1 =>
            if(CH_CNT = 0)then 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_1 + CH_ROM_ADDR_PICT);
                    CH_CNT       <= CH_CNT + 1;
                    CH_ROM_RDFSM <= s_GET_ADDR;
            elsif(CH_CNT = 1)then                                                                                                                                                 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_2 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                                              
            elsif(CH_CNT = 2)then                                                                                                                                          
                    CH_ROM_ADDR  <=std_logic_Vector(ADDR_CH_3 + CH_ROM_ADDR_PICT);                                                                
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                
            elsif(CH_CNT = 3)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_4 + CH_ROM_ADDR_PICT);                                                            
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                          
            elsif(CH_CNT = 4)then                                                                                                                                          
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_5 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                         
            elsif(CH_CNT = 5)then                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_6 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                              
            elsif(CH_CNT = 6)then                                                                                                                                             
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_7 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                 
            elsif(CH_CNT = 7)then                                                                                                                                       
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_8 + CH_ROM_ADDR_PICT);                                                          
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                  
            elsif(CH_CNT = 8)then                                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_9 + CH_ROM_ADDR_PICT);                                                                 
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                     
            elsif(CH_CNT = 9)then                                                                                                                                                 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_10 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                              
            elsif(CH_CNT = 10)then                                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_11 + CH_ROM_ADDR_PICT);                                                               
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                    
            elsif(CH_CNT = 11)then                                                                                                                                             
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_12 + CH_ROM_ADDR_PICT);                                                                
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                        
            elsif(CH_CNT = 12)then                                                                                                                                                   
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_13 + CH_ROM_ADDR_PICT);                                                                   
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                          
            elsif(CH_CNT = 13)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_14 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                     
            elsif(CH_CNT = 13)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_14 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 13)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_14 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                    
            else
                    CH_ROM_RDFSM      <= s_WAIT_H;
                    CH_CNT        <= (others=>'0');
                    OSD_RD_DONE   <= '1';   
                    
--                    if(INTERNAL_LINE_CNT= 8 or INTERNAL_LINE_CNT = 16 or INTERNAL_LINE_CNT= 24 or INTERNAL_LINE_CNT= 32 or INTERNAL_LINE_CNT= 40 or INTERNAL_LINE_CNT= 48 or INTERNAL_LINE_CNT= 56 or INTERNAL_LINE_CNT= 64 or INTERNAL_LINE_CNT= 72)then
                    if(INTERNAL_LINE_CNT= unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0)) ) then
                      CH_ADD_CNT <= CH_ADD_CNT + 1;
                      INTERNAL_LINE_CNT <= (others=>'0');
                      CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
                      --if(OSD_FIELD = '0')then
                      --  CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
                      --else
                      --  CH_ROM_ADDR_PICT  <= to_unsigned(1,CH_ROM_ADDR_PICT'length); 
                      --end if;  
                    else
                      CH_ROM_ADDR_PICT  <= CH_ROM_ADDR_PICT + 1;
                    end if;
            end if;                 

        when s_GET_CH_ADDR_LY2 =>
            if(CH_CNT = 0)then 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_1 + CH_ROM_ADDR_PICT);
                    CH_CNT       <= CH_CNT + 1;
                    CH_ROM_RDFSM <= s_GET_ADDR;
            elsif(CH_CNT = 1)then                                                                                                                                                 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_2 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                                              
            elsif(CH_CNT = 2)then                                                                                                                                          
                    CH_ROM_ADDR  <=std_logic_Vector(ADDR_CH_3 + CH_ROM_ADDR_PICT);                                                                
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                
            elsif(CH_CNT = 3)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_4 + CH_ROM_ADDR_PICT);                                                            
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                          
            elsif(CH_CNT = 4)then                                                                                                                                          
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_5 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                         
            elsif(CH_CNT = 5)then                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_6 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                              
            elsif(CH_CNT = 6)then                                                                                                                                             
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_7 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                 
            elsif(CH_CNT = 7)then                                                                                                                                       
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_8 + CH_ROM_ADDR_PICT);                                                          
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                  
            elsif(CH_CNT = 8)then                                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_9 + CH_ROM_ADDR_PICT);                                                                 
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                     
            elsif(CH_CNT = 9)then                                                                                                                                                 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_10 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                              
            elsif(CH_CNT = 10)then                                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_11 + CH_ROM_ADDR_PICT);                                                               
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                    
            elsif(CH_CNT = 11)then                                                                                                                                             
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_12 + CH_ROM_ADDR_PICT);                                                                
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                        
            elsif(CH_CNT = 12)then                                                                                                                                                   
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_13 + CH_ROM_ADDR_PICT);                                                                   
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                          
            elsif(CH_CNT = 13)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_14 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                     
            elsif(CH_CNT = 14)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_15 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 15)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_16 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 16)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_17 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                       
            elsif(CH_CNT = 17)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_18 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 18)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_19 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 19)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_20 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 20)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_21 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 21)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_22 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                       
            elsif(CH_CNT = 22)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_23 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 23)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_24 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR; 
            elsif(CH_CNT = 24)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_25 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 25)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_26 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 26)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_27 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                       
            elsif(CH_CNT = 27)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_28 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 28)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_29 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;
            elsif(CH_CNT = 29)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_30 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 30)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_31 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 31)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_32 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                       
            elsif(CH_CNT = 32)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_33 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 33)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_34 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 34)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_35 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 35)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_36 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 36)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_37 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                       
            elsif(CH_CNT = 37)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_38 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 38)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_39 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR; 
            elsif(CH_CNT = 39)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_40 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                    
            else
                    CH_ROM_RDFSM      <= s_WAIT_H;
                    CH_CNT        <= (others=>'0');
                    OSD_RD_DONE   <= '1';   
                    
--                    if(INTERNAL_LINE_CNT= 8 or INTERNAL_LINE_CNT = 16 or INTERNAL_LINE_CNT= 24 or INTERNAL_LINE_CNT= 32 or INTERNAL_LINE_CNT= 40 or INTERNAL_LINE_CNT= 48 or INTERNAL_LINE_CNT= 56 or INTERNAL_LINE_CNT= 64 or INTERNAL_LINE_CNT= 72)then
--                    if(INTERNAL_LINE_CNT= 8 ) then
                    if(INTERNAL_LINE_CNT = unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0)))then
                      CH_ADD_CNT        <= CH_ADD_CNT + 1;
                      INTERNAL_LINE_CNT <= (others=>'0');
                      CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
                      --if(OSD_FIELD = '0')then
                      --  CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
                      --else
                      --  CH_ROM_ADDR_PICT  <= to_unsigned(1,CH_ROM_ADDR_PICT'length); 
                      --end if;  
                    else
                      CH_ROM_ADDR_PICT  <= CH_ROM_ADDR_PICT + 1;
                    end if;
            end if;                 

        when s_GET_CH_ADDR_LY3 =>
            if(CH_CNT = 0)then 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_1 + CH_ROM_ADDR_PICT);
                    CH_CNT       <= CH_CNT + 1;
                    CH_ROM_RDFSM <= s_GET_ADDR;
            elsif(CH_CNT = 1)then                                                                                                                                                 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_2 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                                              
            elsif(CH_CNT = 2)then                                                                                                                                          
                    CH_ROM_ADDR  <=std_logic_Vector(ADDR_CH_3 + CH_ROM_ADDR_PICT);                                                                
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                
            elsif(CH_CNT = 3)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_4 + CH_ROM_ADDR_PICT);                                                            
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                          
            elsif(CH_CNT = 4)then                                                                                                                                          
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_5 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                         
            elsif(CH_CNT = 5)then                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_6 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                              
            elsif(CH_CNT = 6)then                                                                                                                                             
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_7 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                 
            elsif(CH_CNT = 7)then                                                                                                                                       
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_8 + CH_ROM_ADDR_PICT);                                                          
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                  
            elsif(CH_CNT = 8)then                                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_9 + CH_ROM_ADDR_PICT);                                                                 
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                     
            elsif(CH_CNT = 9)then                                                                                                                                                 
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_10 + CH_ROM_ADDR_PICT);                                                              
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                              
            elsif(CH_CNT = 10)then                                                                                                                                               
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_11 + CH_ROM_ADDR_PICT);                                                               
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                    
            elsif(CH_CNT = 11)then                                                                                                                                             
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_12 + CH_ROM_ADDR_PICT);                                                                
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                                                                                                        
            elsif(CH_CNT = 12)then                                                                                                                                                   
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_13 + CH_ROM_ADDR_PICT);                                                                   
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                                                          
            elsif(CH_CNT = 13)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_14 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                     
            elsif(CH_CNT = 14)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_15 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;  
            elsif(CH_CNT = 15)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_16 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                                                                                    
            elsif(CH_CNT = 16)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_17 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;                                        
            else
                    CH_ROM_RDFSM      <= s_WAIT_H;
                    CH_CNT        <= (others=>'0');
                    OSD_RD_DONE   <= '1';   
                    
--                    if(INTERNAL_LINE_CNT= 8 or INTERNAL_LINE_CNT = 16 or INTERNAL_LINE_CNT= 24 or INTERNAL_LINE_CNT= 32 or INTERNAL_LINE_CNT= 40 or INTERNAL_LINE_CNT= 48 or INTERNAL_LINE_CNT= 56 or INTERNAL_LINE_CNT= 64 or INTERNAL_LINE_CNT= 72)then
                    if(INTERNAL_LINE_CNT= unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0))) then
                      CH_ADD_CNT <= CH_ADD_CNT + 1;
                      INTERNAL_LINE_CNT <= (others=>'0');
                      CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
                      --if(OSD_FIELD = '0')then
                      --  CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
                      --else
                      --  CH_ROM_ADDR_PICT  <= to_unsigned(1,CH_ROM_ADDR_PICT'length); 
                      --end if;  
                    else
                      CH_ROM_ADDR_PICT  <= CH_ROM_ADDR_PICT + 1;
                    end if;
            end if;    


        -- Do Read at Computed Address    
        when s_GET_ADDR =>
            CH_ROM_RDFSM <= s_READ;           

        -- WRITE CH DATA TO FIFO
        when s_READ =>
            FIFO_IN_OSD  <= CH_ROM_DATA;
            FIFO_WR_OSD  <= '1';
            if(ly1_sel = '1')then
                CH_ROM_RDFSM <= s_GET_CH_ADDR_LY1;
            elsif(ly2_sel = '1')then
                CH_ROM_RDFSM <= s_GET_CH_ADDR_LY2;
            elsif(ly3_sel = '1')then
                CH_ROM_RDFSM <= s_GET_CH_ADDR_LY3;
            end if;
 
        end case;
                
         
     if(advance_menu_sel = '1')then    
        if(CURSOR_POS = PAGE2_IMG_ENHANCE_POS)then
            ly2_option_cnt  <= IMG_ENHANCE_OPTION;
            menu_option_cnt <= IMG_ENHANCE_POS;          
        --elsif(CURSOR_POS = PAGE2_DISPLAY_MODE_POS)then
        --    ly2_option_cnt  <= DISPLAY_MODE_OPTION;
        --    menu_option_cnt <= DISPLAY_MODE_POS; 
        elsif(CURSOR_POS = PAGE2_SIGHT_CONFIG_POS)then
            ly2_option_cnt  <= SIGHT_CONFIG_OPTION;
            menu_option_cnt <= SIGHT_CONFIG_POS; 
        elsif(CURSOR_POS = PAGE2_AGC_ADVANCE_POS)then
            ly2_option_cnt  <= AGC_ADVANCE_OPTION;
            menu_option_cnt <= AGC_ADVANCE_POS; 
        elsif(CURSOR_POS = PAGE2_NUC_ADVANCE_POS)then
            ly2_option_cnt  <= NUC_ADVANCE_OPTION;
            menu_option_cnt <= NUC_ADVANCE_POS;
        elsif(CURSOR_POS = PAGE2_GALLERY_POS)then
            ly2_option_cnt  <= GALLERY_OPTION;
            menu_option_cnt <= GALLERY_POS;       
        elsif(CURSOR_POS = PAGE2_BIT_POS)then
            ly2_option_cnt  <= BIT_OPTION;
            menu_option_cnt <= BIT_POS;                     
        elsif(CURSOR_POS = PAGE2_COMPASS_POS)then
            ly2_option_cnt  <= COMPASS_OPTION;
            menu_option_cnt <= COMPASS_POS;            
        elsif(CURSOR_POS = PAGE2_BPR_POS)then
            ly2_option_cnt  <= BPR_OPTION;
            menu_option_cnt <= BPR_POS;
        elsif(CURSOR_POS = PAGE2_SNAPSHOT_POS)then
            ly2_option_cnt  <= SNAPSHOT_OPTION;
            menu_option_cnt <= SNAPSHOT_POS;             
        elsif(CURSOR_POS = PAGE2_SETTINGS_POS)then
            ly2_option_cnt  <= SETTINGS_OPTION;
            menu_option_cnt <= SETTINGS_POS;                                 
        elsif(CURSOR_POS = PAGE2_STANDBY_POS)then
            ly2_option_cnt  <= STANDBY_OPTION;
            menu_option_cnt <= STANDBY_POS; 
--        elsif(CURSOR_POS = PAGE2_FIRING_POS)then
--            ly2_option_cnt  <= FIRING_OPTION;
--            menu_option_cnt <= FIRING_POS; 
        else
            ly2_option_cnt  <= IMG_ENHANCE_OPTION;
            menu_option_cnt <= IMG_ENHANCE_POS;
        end if;           
     elsif(main_menu_sel = '1')then   
        if(CURSOR_POS = PAGE1_CALIBRATION_POS)then
            ly2_option_cnt  <= CALIBRATION_OPTION;
            menu_option_cnt <= CALIBRATION_POS;
        elsif(CURSOR_POS = PAGE1_BRIGHTNESS_POS)then
            ly2_option_cnt  <= BRIGHTNESS_OPTION;
            menu_option_cnt <= BRIGHTNESS_POS;    
        elsif(CURSOR_POS = PAGE1_GAIN_POS)then
            ly2_option_cnt  <= GAIN_OPTION;
            menu_option_cnt <= GAIN_POS;
        elsif(CURSOR_POS = PAGE1_DZOOM_POS)then
            ly2_option_cnt  <= DZOOM_OPTION;
            menu_option_cnt <= DZOOM_POS;
        elsif(CURSOR_POS = PAGE1_AGC_POS)then
            ly2_option_cnt  <= AGC_OPTION;
            menu_option_cnt <= AGC_POS;
        elsif(CURSOR_POS = PAGE1_LASER_POS)then
            ly2_option_cnt  <= LASER_OPTION;
            menu_option_cnt <= LASER_POS;  
        elsif(CURSOR_POS = PAGE1_DISPLAY_POS)then
            ly2_option_cnt  <= DISPLAY_OPTION;
            menu_option_cnt <= DISPLAY_POS;                 
        elsif(CURSOR_POS = PAGE1_RETICLE_POS)then
            ly2_option_cnt  <= RETICLE_OPTION;
            menu_option_cnt <= RETICLE_POS;                 
        elsif(CURSOR_POS = PAGE1_ADVANCE_MENU_POS)then
            ly2_option_cnt  <= ADVANCE_MENU_OPTION;
            menu_option_cnt <= ADVANCE_MENU_POS;
        elsif(CURSOR_POS = PAGE1_SHUTDOWN_POS)then
            ly2_option_cnt  <= SHUTDOWN_OPTION;
            menu_option_cnt <= SHUTDOWN_POS;          
--        elsif(CURSOR_POS = 4)then
--            ly2_option_cnt  <= x"00";
--            menu_option_cnt <= x"04";
--        elsif(CURSOR_POS = 5)then
--            ly2_option_cnt  <= x"00";
--            menu_option_cnt <= x"09";            
--        elsif(CURSOR_POS = 6)then
--            ly2_option_cnt <= x"04";
--            menu_option_cnt <= x"0A";
--        elsif(CURSOR_POS = 7)then
--            ly2_option_cnt <= x"03";
--            menu_option_cnt <= x"0B";           
        else
            ly2_option_cnt  <= CALIBRATION_OPTION;
            menu_option_cnt <= CALIBRATION_POS;
        end if;
     elsif(hot_key_menu_sel = '1')then   
        if(polarity_en = '1')then  
            ly2_option_cnt  <= POLARITY_OPTION;
            menu_option_cnt <= POLARITY_KEY_POS;     
--        elsif(gain_en = '1')then
        elsif(dzoom_en = '1')then
--            ly2_option_cnt  <= GAIN_OPTION;
--            menu_option_cnt <= GAIN_KEY_POS;   
            ly2_option_cnt  <= DZOOM_OPTION;
            menu_option_cnt <= DZOOM_KEY_POS; 
        end if;
     end if;
      
     START_NUC1PTCALIB     <= '0';  
     SAVE_USER_SETTINGS    <= '0'; 
     LOAD_FACTORY_SETTINGS <= '0'; 
     LOAD_USER_SETTINGS    <= '0'; 
     SAVE_BP               <= '0'; 
     SINGLE_SNAPSHOT       <= '0';
     BURST_SNAPSHOT        <= '0';
     SNAPSHOT_DELETE_EN    <= '0';

     if(SHUTDOWN_EN = '1')then
        if(tick1mS  = '1')then
            shutdown_timeout_cnt <= shutdown_timeout_cnt + 1;
        end if;        
     end if;  
     if(shutdown_timeout_cnt = SHUTDOWN_TIMEOUT )then
        SHUTDOWN_PROCESS_DONE <= '1';
     end if;
     
     if(GALLERY_FULL_DISP_EN = '1')then
        if(gallery_full_disp_timeout_cnt >= GALLERY_DISP_TIMEOUT)then
            GALLERY_FULL_DISP_OFF <= '1';
            GALLERY_FULL_DISP_EN  <= '0';
            gallery_full_disp_timeout_cnt <= (others=>'0');
        else    
            if(tick1mS  = '1')then
                gallery_full_disp_timeout_cnt <= gallery_full_disp_timeout_cnt + 1;
            end if; 
         end if;    
     else
          gallery_full_disp_timeout_cnt <= (others=>'0');
     end if;
--     if(ly1_sel = '1')then
     if(ly1_sel = '1')then
        if(LATCH_MENU_SEL_CENTER ='1' or LATCH_MENU_SEL_UP = '1' or LATCH_MENU_SEL_DN = '1')then
            menu_timeout_cnt_start <= '0';
        else
            menu_timeout_cnt_start <= '1';
        end if;
     elsif(ly3_sel = '1' and (menu_option_cnt = CALIBRATION_POS))then 
            menu_timeout_cnt_start <= '1';
     else
        menu_timeout_cnt_start <= '0';
     end if;

     if(menu_timeout_cnt_start ='1' and OSD_EN = '1')then
        if(tick1mS  = '1')then
            menu_timeout_cnt <= menu_timeout_cnt + 1;
        end if;
     else
        menu_timeout_cnt <= x"0000";
     end if;

     if(latch_menu_timeout_cnt >= unsigned(OSD_TIMEOUT) and (ly1_sel = '1' or  (ly3_sel = '1' and menu_option_cnt = CALIBRATION_POS))) then
        OSD_EN           <= '0'; 
        main_menu_sel    <= '0';  
        advance_menu_sel <= '0';  
        ly3_val_init_done<= '0';
        if((ly3_sel = '1' and menu_option_cnt = CALIBRATION_POS))then
            ly3_sel <= '0';
        end if;
     elsif(LATCH_MENU_SEL_CENTER = '1' and OSD_EN = '0')then
        OSD_EN        <= '1';
        main_menu_sel <= '1'; 
     elsif(LATCH_ADVANCE_MENU_TRIG = '1'and OSD_EN = '0')then
        OSD_EN           <= '1';
        advance_menu_sel <= '1';  
     elsif((LATCH_MENU_SEL_CENTER = '1' and OSD_EN = '1') or (snapshot_save_done_latch = '1' and menu_option_cnt = SNAPSHOT_POS and ly3_sel ='1') or (snapshot_delete_done_latch = '1' and menu_option_cnt = GALLERY_POS and ly3_sel ='1') or (gyro_calib_done_latch = '1' and menu_option_cnt = COMPASS_POS and ly3_sel ='1'))then
--        gain_en          <= '0';
        dzoom_en         <= '0';
        polarity_en      <= '0'; 
        hot_key_menu_sel <= '0';  
        if((main_menu_sel = '1' or advance_menu_sel = '1') and ly1_sel = '1')then
--            if(menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = COMPASS_POS or menu_option_cnt = GALLERY_POS or menu_option_cnt = BPR_POS or menu_option_cnt = SNAPSHOT_POS or menu_option_cnt = SETTINGS_POS  )then
--            if(menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = GALLERY_POS or menu_option_cnt = BIT_POS or menu_option_cnt = BPR_POS or menu_option_cnt = SNAPSHOT_POS or menu_option_cnt = SETTINGS_POS or menu_option_cnt = FIRING_POS )then
--            if(menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = GALLERY_POS or menu_option_cnt = BIT_POS or menu_option_cnt = BPR_POS  or menu_option_cnt = SETTINGS_POS or menu_option_cnt = FIRING_POS )then
            if(menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = SIGHT_CONFIG_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = GALLERY_POS or menu_option_cnt = BIT_POS or menu_option_cnt = COMPASS_POS or menu_option_cnt = BPR_POS  or menu_option_cnt = SETTINGS_POS  )then
                ly2_sel <= '1';
                ly1_sel <= '0'; 
                ly3_sel <= '0';
                
--                if(menu_option_cnt = SNAPSHOT_POS)then
--                    SNAPSHOT_COUNTER_VALID<= '1';
--                end if;    
 
--                if(menu_option_cnt = FIRING_POS)then
--                    RETICLE_OFFSET_VALID<= '1';
--                end if;                  
                if(menu_option_cnt = GALLERY_POS)then
                    GALLERY_ENABLE <= '1';
                    GALLERY_IMG_NUMBER_VALID <= '1';
                    LOAD_GALLERY <= '1';
                    
                end if; 
                
                if(menu_option_cnt = BPR_POS)then
                    RETICLE_TYPE_VALID <= '1';
                    RETICLE_TYPE       <= to_unsigned(6,RETICLE_TYPE'length);       
                    RETICLE_TYPE_HIST  <= RETICLE_TYPE;         
                end if;  
                 
--            elsif(menu_option_cnt = CALIBRATION_POS)then
--                ly2_sel <= '0';
--                ly1_sel <= '0'; 
--                ly3_sel <= '0';
--                START_NUC1PTCALIB <= '1';
            else
                ly2_sel <= '0';
                ly1_sel <= '0'; 
                if(menu_option_cnt = ADVANCE_MENU_POS or menu_option_cnt = STANDBY_POS)then 
                 ly3_sel           <= '0';
                else
                 ly3_sel           <= '1'; 
                end if; 
                
--                if(menu_option_cnt = SNAPSHOT_POS)then
--                    SNAPSHOT_COUNTER_VALID<= '1';
--                end if;  
                
                if(menu_option_cnt = SNAPSHOT_POS)then
--                     GALLERY_IMG_VALID             <= GALLERY_IMG_VALID or std_logic_vector(rotate_left(resize(unsigned'(x"0000_0000_0000_0001"),GALLERY_IMG_VALID'length), to_integer(SNAPSHOT_COUNTER-1)));
--                     GALLERY_IMG_VALID(to_integer(SNAPSHOT_COUNTER-1)) <= '1';
--                     GALLERY_IMG_VALID(to_integer(SNAPSHOT_COUNTER)) <= '1';  
                     if(SNAPSHOT_COUNTER >= MAX_SNAPSHOT)then
                        SINGLE_SNAPSHOT       <= '0'; 
                        GALLERY_FULL          <= '1';
                        GALLERY_FULL_DISP_EN  <= '1';
                        snapshot_sel          <= "10";
                     else
                        SINGLE_SNAPSHOT       <= '1';
                        snapshot_sel          <= "00";
                        GALLERY_FULL           <= '0';  
                        SNAPSHOT_COUNTER      <= SNAPSHOT_COUNTER + 1;
                         
--                        GALLERY_IMG_VALID(to_integer(SNAPSHOT_COUNTER)) <= '1'; 
                     end if;   
                     GALLERY_IMG_VALID_EN <= '1';
                     SNAPSHOT_COUNTER_VALID <= '1';
--                elsif(menu_option_cnt = SNAPSHOT_POS and CURSOR_POS_LY2 = x"01")then
--                     BURST_SNAPSHOT         <= '1';    
--                     snapshot_sel           <= '1'; 
--                     GALLERY_IMG_VALID      <= (others=>'1');
--                     GALLERY_IMG_VALID_EN   <= '1';
--                     SNAPSHOT_COUNTER       <= MAX_SNAPSHOT;
--                     SNAPSHOT_COUNTER_VALID <= '1';
--                  end if;
--                elsif(menu_option_cnt = SNAPSHOT_POS and CURSOR_POS_LY2 = x"01")then
--                     if(SNAPSHOT_COUNTER > MAX_SNAPSHOT -unsigned(burst_capture_size))then
--                      BURST_SNAPSHOT         <= '0';    
--                      snapshot_sel           <= "10"; 
--                      GALLERY_FULL           <= '1';
--                      GALLERY_FULL_DISP_EN   <= '1';
--                     else
--                      BURST_SNAPSHOT         <= '1';    
--                      snapshot_sel           <= "01"; 
--                      GALLERY_FULL           <= '0'; 
--                      SNAPSHOT_COUNTER       <= SNAPSHOT_COUNTER + unsigned(burst_capture_size);
----                      GALLERY_IMG_VALID(to_integer(SNAPSHOT_COUNTER)) <= '1'; 
--                     end if; 
--                     GALLERY_IMG_VALID_EN <= '1';
--                     SNAPSHOT_COUNTER_VALID <= '1';
                       
                  end if;
                
                if(menu_option_cnt = STANDBY_POS)then         
                 STANDBY_EN_VALID <= '1';
                 STANDBY_EN  <=  to_unsigned(1,STANDBY_EN'length);
                end if;
                 
                if(menu_option_cnt = ADVANCE_MENU_POS or menu_option_cnt = STANDBY_POS)then
                 OSD_EN            <= '0';
                 main_menu_sel     <= '0';
                 advance_menu_sel  <= '0';
                end if; 

                if(menu_option_cnt = ADVANCE_MENU_POS)then
                 ADVANCE_MENU_TRIG_IN <= '1';
                end if;     
                
                if(menu_option_cnt = SHUTDOWN_POS)then 
                 SHUTDOWN_EN       <= '1';            
                 SHUTDOWN_EN_VALID <= '1';
                end if; 
                
                if(menu_option_cnt = CALIBRATION_POS)then
                 CALIB_MODE_VALID  <= '1';
                end if;
                                           
            end if;  
            CURSOR_POS_LY2 <= x"00";      
        elsif(ly2_sel = '1')then
--            if(((menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = COMPASS_POS or menu_option_cnt = BPR_POS or menu_option_cnt = SNAPSHOT_POS)and CURSOR_POS_LY2 = ly2_option_cnt) or (menu_option_cnt = SETTINGS_POS)or(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 /= x"02") or (menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"03"))then
--            if(((menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = BIT_POS or menu_option_cnt = BPR_POS or menu_option_cnt = SNAPSHOT_POS or menu_option_cnt = FIRING_POS)and CURSOR_POS_LY2 = ly2_option_cnt) or (menu_option_cnt = SETTINGS_POS)or(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 /= x"02") or (menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"03") or (menu_option_cnt = NUC_ADVANCE_POS and CURSOR_POS_LY2 = x"02"))then
--            if(((menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = BIT_POS or menu_option_cnt = BPR_POS or menu_option_cnt = SNAPSHOT_POS or menu_option_cnt = FIRING_POS)and CURSOR_POS_LY2 = ly2_option_cnt) or (menu_option_cnt = SETTINGS_POS)or(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 /= x"02") or (menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"03"))then
--            if(((menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = BIT_POS or menu_option_cnt = BPR_POS or menu_option_cnt = FIRING_POS)and CURSOR_POS_LY2 = ly2_option_cnt) or (menu_option_cnt = SETTINGS_POS)or(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 /= x"02") or (menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"03"))then
            if(((menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or  menu_option_cnt = SIGHT_CONFIG_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = BIT_POS or menu_option_cnt = COMPASS_POS or menu_option_cnt = BPR_POS)and CURSOR_POS_LY2 = ly2_option_cnt) or (menu_option_cnt = SETTINGS_POS)or(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 /= x"02") or (menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"03"))then
                ly1_sel <= '0';
--                ly2_sel <= '0';
                ly3_sel <= '0';
                if(menu_option_cnt = GALLERY_POS and (CURSOR_POS_LY2 = x"00" or CURSOR_POS_LY2 = x"01"))then
                    ly2_sel <= '1';
                else
                    ly2_sel <= '0';
                    CURSOR_POS_LY2  <= x"00";
                end if;    
                
--                if(menu_option_cnt = NUC_ADVANCE_POS and CURSOR_POS_LY2 = x"02")then
--                    if(NUC_MODE="10" and BLADE_MODE = "00")then
--                        coarse_offset_calib_start <= '1';  
--                    end if;                             
--                end if;    
                
                if(menu_option_cnt = BPR_POS and  (CURSOR_POS_LY2 = x"04" or CURSOR_POS_LY2 = x"03"))then
                     RETICLE_TYPE_VALID <= '1';
                     RETICLE_TYPE       <= RETICLE_TYPE_HIST;    
                end if; 
                if(menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"03")then
                     SAVE_BP            <= '1';              
                elsif(menu_option_cnt = SETTINGS_POS and CURSOR_POS_LY2 = x"00")then     
                     LOAD_USER_SETTINGS    <= '1';                     
                elsif(menu_option_cnt = SETTINGS_POS and CURSOR_POS_LY2 = x"01")then     
                     LOAD_FACTORY_SETTINGS <= '1'; 
                elsif(menu_option_cnt = SETTINGS_POS and CURSOR_POS_LY2 = x"02")then     
                     SAVE_USER_SETTINGS    <= '1'; 
                end if;
                
                if(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 = x"00")then
                    if (unsigned(GALLERY_IMG_NUMBER) = x"01")then
                        GALLERY_IMG_NUMBER <= MAX_GALLERY_IMG_NUMBER;
                    else
                        GALLERY_IMG_NUMBER <= GALLERY_IMG_NUMBER -1;
                    end if;
                    GALLERY_IMG_NUMBER_VALID <= '1';
                    
                elsif(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 = x"01")then
                    if (unsigned(GALLERY_IMG_NUMBER) >=  MAX_GALLERY_IMG_NUMBER)then
                        GALLERY_IMG_NUMBER <= x"01";
                    else
                        GALLERY_IMG_NUMBER <= GALLERY_IMG_NUMBER +1;
                    end if;
                    GALLERY_IMG_NUMBER_VALID <= '1';
                elsif(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 = x"03") then    
                    GALLERY_ENABLE <= '0';
                end if;
                         
            else
                ly1_sel <= '0';
                ly2_sel <= '0';
                ly3_sel <= '1';
--                if(menu_option_cnt = SNAPSHOT_POS and CURSOR_POS_LY2 = x"00")then
----                     GALLERY_IMG_VALID             <= GALLERY_IMG_VALID or std_logic_vector(rotate_left(resize(unsigned'(x"0000_0000_0000_0001"),GALLERY_IMG_VALID'length), to_integer(SNAPSHOT_COUNTER-1)));
----                     GALLERY_IMG_VALID(to_integer(SNAPSHOT_COUNTER-1)) <= '1';
----                     GALLERY_IMG_VALID(to_integer(SNAPSHOT_COUNTER)) <= '1';  
                    
--                     if(SNAPSHOT_COUNTER >= MAX_SNAPSHOT)then
--                        SINGLE_SNAPSHOT       <= '0'; 
--                        GALLERY_FULL          <= '1';
--                        GALLERY_FULL_DISP_EN  <= '1';
--                        snapshot_sel          <= "10";
--                     else
--                        SINGLE_SNAPSHOT       <= '1';
--                        snapshot_sel          <= "00";
--                        GALLERY_FULL           <= '0';  
--                        SNAPSHOT_COUNTER      <= SNAPSHOT_COUNTER + 1;
                         
----                        GALLERY_IMG_VALID(to_integer(SNAPSHOT_COUNTER)) <= '1'; 
--                     end if;   
--                     GALLERY_IMG_VALID_EN <= '1';
--                     SNAPSHOT_COUNTER_VALID <= '1';
----                elsif(menu_option_cnt = SNAPSHOT_POS and CURSOR_POS_LY2 = x"01")then
----                     BURST_SNAPSHOT         <= '1';    
----                     snapshot_sel           <= '1'; 
----                     GALLERY_IMG_VALID      <= (others=>'1');
----                     GALLERY_IMG_VALID_EN   <= '1';
----                     SNAPSHOT_COUNTER       <= MAX_SNAPSHOT;
----                     SNAPSHOT_COUNTER_VALID <= '1';
----                  end if;
--                elsif(menu_option_cnt = SNAPSHOT_POS and CURSOR_POS_LY2 = x"01")then
--                     if(SNAPSHOT_COUNTER > MAX_SNAPSHOT -unsigned(burst_capture_size))then
--                      BURST_SNAPSHOT         <= '0';    
--                      snapshot_sel           <= "10"; 
--                      GALLERY_FULL           <= '1';
--                      GALLERY_FULL_DISP_EN   <= '1';
--                     else
--                      BURST_SNAPSHOT         <= '1';    
--                      snapshot_sel           <= "01"; 
--                      GALLERY_FULL           <= '0'; 
--                      SNAPSHOT_COUNTER       <= SNAPSHOT_COUNTER + unsigned(burst_capture_size);
----                      GALLERY_IMG_VALID(to_integer(SNAPSHOT_COUNTER)) <= '1'; 
--                     end if; 
--                     GALLERY_IMG_VALID_EN <= '1';
--                     SNAPSHOT_COUNTER_VALID <= '1';
                       
--                  end if;

--                elsif(menu_option_cnt = SNAPSHOT_POS and CURSOR_POS_LY2 = x"02")then 
--                     SNAPSHOT_COUNTER_VALID <= '1';
--                end if; 
                
                if(menu_option_cnt = GALLERY_POS and CURSOR_POS_LY2 = x"02")then 
                     SNAPSHOT_DELETE_EN      <= '1';
--                     GALLERY_IMG_VALID             <= GALLERY_IMG_VALID and std_logic_vector(rotate_left (resize(unsigned'(x"FFFF_FFFF_FFFF_FFFE"),GALLERY_IMG_VALID'length), to_integer(GALLERY_IMG_NUMBER -1)));
--                     GALLERY_IMG_VALID(to_integer(GALLERY_IMG_NUMBER-1)) <= '0';  -- delete single image
--                     GALLERY_IMG_VALID      <= (others=>'0');                     
--                     GALLERY_IMG_VALID_EN   <= '1';  
                     SNAPSHOT_COUNTER         <=  (others=>'0');  
                     SNAPSHOT_COUNTER_VALID   <= '1';
                     GALLERY_IMG_VALID_EN     <= '1';
                     GALLERY_IMG_NUMBER       <= x"01";  
                     GALLERY_IMG_NUMBER_VALID <= '1';     
                     GALLERY_FULL             <= '0'; 
                end if;
                if(menu_option_cnt = COMPASS_POS and CURSOR_POS_LY2 = x"01")then     
                    GYRO_CALIB_EN_VALID <= '1';
                    GYRO_CALIB_EN       <= '1';             
                end if;                  
            end if;                   
        elsif(ly3_sel = '1')then
            ly1_sel           <= '0';
            
--            if(menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = COMPASS_POS or menu_option_cnt = BPR_POS or menu_option_cnt = SETTINGS_POS or (menu_option_cnt = SNAPSHOT_POS and (CURSOR_POS_LY2 =x"02")))then
--            if(menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = BIT_POS or menu_option_cnt = BPR_POS or menu_option_cnt = SETTINGS_POS or menu_option_cnt = FIRING_POS or (menu_option_cnt = SNAPSHOT_POS and (CURSOR_POS_LY2 =x"02")))then
            if(menu_option_cnt = RETICLE_POS or menu_option_cnt = DISPLAY_POS or menu_option_cnt = IMG_ENHANCE_POS or menu_option_cnt = SIGHT_CONFIG_POS or menu_option_cnt = AGC_ADVANCE_POS or menu_option_cnt = NUC_ADVANCE_POS or menu_option_cnt = BIT_POS  or menu_option_cnt = BPR_POS or menu_option_cnt = SETTINGS_POS or (menu_option_cnt = SNAPSHOT_POS and (CURSOR_POS_LY2 =x"02")) or (menu_option_cnt = COMPASS_POS and (CURSOR_POS_LY2 =x"00")))then
                ly2_sel           <= '1';
            elsif(menu_option_cnt = GALLERY_POS) then
                if(snapshot_delete_done_latch = '1')then
                 ly2_sel           <= '1';
                else
                 ly2_sel           <= '0';
                end if; 
            elsif((menu_option_cnt = COMPASS_POS and (CURSOR_POS_LY2 =x"01")))then    
                if(gyro_calib_done_latch = '1')then
                 ly2_sel           <= '1';
                else
                 ly2_sel           <= '0';
                end if;            
            else
                ly2_sel           <= '0';
                CURSOR_POS_LY2    <= x"00";
            end if;
            
--            if(menu_option_cnt = FIRING_POS)then
--                 RETICLE_OFFSET_VALID<= '1';
--            end if; 
            
            if(menu_option_cnt = GALLERY_POS)then
                if(snapshot_delete_done_latch = '1')then
                 ly3_sel           <= '0';
                else
                 ly3_sel           <= '1';
                end if;             
--            elsif(menu_option_cnt = SNAPSHOT_POS and (CURSOR_POS_LY2 /= x"02")  )then
            elsif(menu_option_cnt = SNAPSHOT_POS )then
                if(snapshot_save_done_latch = '1')then
                 ly3_sel           <= '0';
                else
                 ly3_sel           <= '1';
                end if; 
            elsif((menu_option_cnt = COMPASS_POS and (CURSOR_POS_LY2 =x"01")))then    
                if(gyro_calib_done_latch = '1')then
                 ly3_sel           <= '0';
                else
                 ly3_sel           <= '1';
                end if;      
            elsif(menu_option_cnt = SHUTDOWN_POS )then
                ly3_sel           <= '1';
            else
                ly3_sel           <= '0';
            end if;
            
            if(hot_key_menu_sel= '1')then
                OSD_EN            <= '0';
            end if;

--            if(menu_option_cnt = CALIBRATION_POS)then
--                CALIB_MODE_VALID  <= '1';
--            end if;
            
            ly3_val_init_done <= '0';
--            if(menu_option_cnt = BPR_POS)then
--                RETICLE_TYPE_VALID <= '1';
--                RETICLE_TYPE       <= to_unsigned(1,RETICLE_TYPE'length);
--            end if;       
        end if;     
--     elsif((MENU_SEL_UP = '1' and OSD_EN_D = '1') and latch_ly2_Sel = '0')then
     elsif((LATCH_MENU_SEL_UP = '1' and OSD_EN = '1') and ly1_Sel = '1')then 
        if(CURSOR_POS = x"00")then
            if((main_menu_sel = '1') )then
                CURSOR_POS <= PAGE1_NUMBER_OF_OPTION -1;
            elsif((advance_menu_sel = '1'))then
                CURSOR_POS <= PAGE2_NUMBER_OF_OPTION -1;
            end if;
        else 
            CURSOR_POS <= CURSOR_POS - 1;
        end if;        
--     elsif((MENU_SEL_DN = '1' and OSD_EN_D = '1' ) and latch_ly2_Sel = '0')then
     elsif((LATCH_MENU_SEL_DN = '1' and OSD_EN = '1' ) and ly1_Sel = '1')then
        if((CURSOR_POS = PAGE1_NUMBER_OF_OPTION -1) and (main_menu_sel ='1'))then
            CURSOR_POS <= x"00";
        elsif((CURSOR_POS = PAGE2_NUMBER_OF_OPTION -1) and (advance_menu_sel = '1'))then
            CURSOR_POS <= x"00";
        else
            CURSOR_POS <= CURSOR_POS + 1;
        end if;   
     elsif((LATCH_MENU_SEL_UP = '1' and OSD_EN = '1') and ly2_Sel = '1')then 
        if((CURSOR_POS_LY2 = ly2_option_cnt))then
            CURSOR_POS_LY2 <= x"00";
        else
            CURSOR_POS_LY2 <= CURSOR_POS_LY2 + 1;
        end if;   
               
--     elsif((MENU_SEL_DN = '1' and OSD_EN_D = '1' ) and latch_ly2_Sel = '0')then
     elsif((LATCH_MENU_SEL_DN = '1' and OSD_EN = '1' ) and ly2_Sel = '1')then
        if(CURSOR_POS_LY2 = x"00")then
            CURSOR_POS_LY2 <= ly2_option_cnt;
        else 
            CURSOR_POS_LY2 <= CURSOR_POS_LY2 - 1;
        end if;   
        
     elsif((main_menu_sel = '1' or advance_menu_sel = '1') and ly2_sel = '0' and ly3_sel = '0')then 
        ly1_sel <= '1';    
        ly2_sel <= '0';
        ly3_sel <= '0';
     elsif(hot_key_menu_sel = '1')then
        ly3_sel <= '1';  
     elsif(LATCH_MENU_SEL_UP = '1' and OSD_EN = '0')then
--        ly3_sel          <= '1'; 
        ly1_sel          <= '0';
        ly2_sel          <= '0';
--        gain_en          <= '1'; 
        dzoom_en         <= '1';
        hot_key_menu_sel <= '1'; 
        OSD_EN           <= '1';   
     elsif(LATCH_MENU_SEL_DN = '1' and OSD_EN = '0')then
--        ly3_sel          <= '1'; 
        ly1_sel          <= '0';
        ly2_sel          <= '0';
        polarity_en      <= '1';
        hot_key_menu_sel <= '1'; 
        OSD_EN           <= '1';
     elsif(OSD_EN = '0')then
          CURSOR_POS      <= x"00";
          ly1_sel         <= '0';   
--          ly2_sel         <= '0'; 
--          ly3_sel         <= '0'; 
          CURSOR_POS_LY2  <= x"00";
--          page_cnt        <= "00";
          param_update      <= '0';
     end if;

     if((LATCH_MENU_SEL_UP = '1' and OSD_EN = '1') and ly3_Sel = '1')then 
        --if(menu_option_cnt = CALIBRATION_POS)then
        --  if(CALIB_MODE >= to_unsigned(1,CALIB_MODE'length))then
        --    CALIB_MODE <= to_unsigned(0,CALIB_MODE'length);
        --  else
        --    CALIB_MODE <= CALIB_MODE +1;
        --  end if;
        --  CALIB_MODE_VALID <= '1';
        param_update <= '1';
        if(menu_option_cnt = BRIGHTNESS_POS)then
          BRIGHTNESS_VALID <= '1';
          if(BRIGHTNESS >= to_unsigned(10,BRIGHTNESS'length))then
            BRIGHTNESS <= to_unsigned(0,BRIGHTNESS'length);
          else
            BRIGHTNESS <= BRIGHTNESS +1;
          end if;
        elsif(menu_option_cnt = DZOOM_POS or menu_option_cnt = DZOOM_KEY_POS)then
          DZOOM_VALID <= '1';
          if(SIGHT_MODE = "01" and CMD_DISPLAY_MODE = '0')then
              DZOOM <= DZOOM;
          else
              if(DZOOM >= to_unsigned(2,DZOOM'length))then
                DZOOM <= to_unsigned(0,DZOOM'length);
              else  
                DZOOM <= DZOOM +1;
              end if;  
          end if;
        elsif(menu_option_cnt = AGC_POS)then
          AGC_MODE_VALID <= '1';
          if(AGC_MODE >= to_unsigned(2,AGC_MODE'length))then
            AGC_MODE <= to_unsigned(0,AGC_MODE'length);
          else
            AGC_MODE <= AGC_MODE +1;
          end if;     
        elsif(menu_option_cnt = LASER_POS)then 
          LASER_EN_VALID <= '1';
          if(LASER_EN >= to_unsigned(1,LASER_EN'length))then 
            LASER_EN <= to_unsigned(0,LASER_EN'length);
          else
            LASER_EN <= to_unsigned(1,LASER_EN'length);
          end if;                   
        elsif(menu_option_cnt = DISPLAY_POS)then
          
          if(CURSOR_POS_LY2 =x"0" )then
            DISPLAY_LUX_VALID <= '1';
--            if(DISPLAY_LUX >= to_unsigned(127,DISPLAY_LUX'length))then
            if(DISPLAY_LUX >= to_unsigned(100,DISPLAY_LUX'length))then
              DISPLAY_LUX <= to_unsigned(0,DISPLAY_LUX'length);
            else  
              DISPLAY_LUX  <= DISPLAY_LUX  + 1; 
            end if;  
          elsif(CURSOR_POS_LY2 =x"1" )then  
            DISPLAY_GAIN_VALID <= '1';
--            if(DISPLAY_GAIN >= to_unsigned(7,DISPLAY_GAIN'length))then 
            if(DISPLAY_GAIN >= to_unsigned(100,DISPLAY_GAIN'length))then 
              DISPLAY_GAIN <= to_unsigned(0,DISPLAY_GAIN'length);
            else
              DISPLAY_GAIN <= DISPLAY_GAIN + 1;
            end if;

          elsif(CURSOR_POS_LY2 =x"2" )then
            DISPLAY_VERT_VALID <= '1';
--            if(DISPLAY_VERT >= to_unsigned(12,DISPLAY_VERT'length))then
            if(DISPLAY_VERT >= OLED_POS_V_MAX_OFFSET)then
              DISPLAY_VERT <= to_unsigned(0,DISPLAY_VERT'length);
            else
              DISPLAY_VERT <= DISPLAY_VERT + 1;
            end if;
          elsif(CURSOR_POS_LY2 =x"3" )then 
            DISPLAY_HORZ_VALID <= '1'; 
--            if(DISPLAY_HORZ >= to_unsigned(12,DISPLAY_HORZ'length))then
            if(DISPLAY_HORZ >= OLED_POS_H_MAX_OFFSET)then
              DISPLAY_HORZ <= to_unsigned(0,DISPLAY_HORZ'length);
            else  
              DISPLAY_HORZ <= DISPLAY_HORZ + 1;
            end if;
          end if;  
        elsif(menu_option_cnt = RETICLE_POS)then
          if(CURSOR_POS_LY2 =x"0")then
            RETICLE_COLOR_VALID <= '1';
            if(RETICLE_COLOR >= to_unsigned(5,RETICLE_COLOR'length))then
              RETICLE_COLOR <= to_unsigned(0,RETICLE_COLOR'length);
            else
              RETICLE_COLOR <= RETICLE_COLOR + 1;
            end if;          
          elsif(CURSOR_POS_LY2 =x"1" )then
            RETICLE_TYPE_VALID <= '1';
            if(RETICLE_TYPE >= to_unsigned(6,RETICLE_TYPE'length))then
              RETICLE_TYPE <= to_unsigned(0,RETICLE_TYPE'length);
            else
              RETICLE_TYPE <= RETICLE_TYPE + 1;
            end if;
          elsif(CURSOR_POS_LY2 =x"2" )then   
--            RETICLE_VERT_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1'; 
            if(RETICLE_VERT >= to_unsigned(479,RETICLE_VERT'length))then        
              RETICLE_VERT <= to_unsigned(0,RETICLE_VERT'length);
            else  
              RETICLE_VERT <= RETICLE_VERT + 1;
            end if;
          elsif(CURSOR_POS_LY2 =x"3" )then 
--            RETICLE_HORZ_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
            if(RETICLE_HORZ >= to_unsigned(639,RETICLE_HORZ'length))then
              RETICLE_HORZ <= to_unsigned(0,RETICLE_HORZ'length);
            else          
              RETICLE_HORZ <= RETICLE_HORZ + 1;
            end if;
          end if;    

        --elsif(menu_option_cnt = PALETTE_POS)then 
        --  PALETTE_TYPE_VALID <= '1';
        --  if(PALETTE_TYPE >= to_unsigned(6,PALETTE_TYPE'length))then
        --    PALETTE_TYPE <= to_unsigned(0,PALETTE_TYPE'length);
        --  else
        --    PALETTE_TYPE <= PALETTE_TYPE +1;
        --  end if;          
        elsif(menu_option_cnt = IMG_ENHANCE_POS)then
          if(CURSOR_POS_LY2 =x"0" and (POLARITY /= "011" and POLARITY /= "100"))then 
            SMOOTHING_VALID <= '1';
            if(SMOOTHING >= to_unsigned(1,SMOOTHING'length))then
              SMOOTHING <= to_unsigned(0,SMOOTHING'length);
              SMOOTHING_HIST <=to_unsigned(0,SMOOTHING_HIST'length);
            else 
              SMOOTHING <= to_unsigned(1,SMOOTHING'length);
              SMOOTHING_HIST <= to_unsigned(1,SMOOTHING_HIST'length); 
            end if;
          elsif(CURSOR_POS_LY2 =x"1")then
            SHARPNESS_VALID <= '1';
            if(SHARPNESS >= to_unsigned(8,SHARPNESS'length))then
              SHARPNESS  <= to_unsigned(0,SHARPNESS'length);
            else
              SHARPNESS  <= SHARPNESS + 1;
            end if; 
          elsif(CURSOR_POS_LY2 =x"2")then
            SOFTNUC_VALID <= '1';
            if(SOFTNUC >= to_unsigned(1,SOFTNUC'length))then
              SOFTNUC <= to_unsigned(0,SOFTNUC'length);
            else
              SOFTNUC  <= SOFTNUC +1;
            end if;             
          end if;
        --elsif(menu_option_cnt = DISPLAY_MODE_POS)then 
        --  DISPLAY_MODE_VALID <= '1';
        --  if(DISPLAY_MODE >= to_unsigned(1,DISPLAY_MODE'length))then 
        --    DISPLAY_MODE <= to_unsigned(0,DISPLAY_MODE'length);
        --  else
        --    DISPLAY_MODE <= to_unsigned(1,DISPLAY_MODE'length);
        --  end if;   

        elsif(menu_option_cnt = SIGHT_CONFIG_POS)then 
            if(CURSOR_POS_LY2 =x"0")then
              DISPLAY_MODE_VALID <= '1';
              if(DISPLAY_MODE >= to_unsigned(1,DISPLAY_MODE'length))then 
                DISPLAY_MODE <= to_unsigned(0,DISPLAY_MODE'length);
              else
                DISPLAY_MODE <= to_unsigned(1,DISPLAY_MODE'length);
              end if;  
            elsif(CURSOR_POS_LY2 =x"1")then 
              SIGHT_MODE_VALID <= '1';
              if(SIGHT_MODE >= to_unsigned(2,SIGHT_MODE'length))then 
                SIGHT_MODE <= to_unsigned(0,SIGHT_MODE'length);
              else
                SIGHT_MODE <= SIGHT_MODE + 1;
              end if;              
            end if;                  
        --elsif(menu_option_cnt = FIT_TO_SCREEN_POS)then 
        --  FIT_TO_SCREEN_EN_VALID <= '1';
        --  if(FIT_TO_SCREEN_EN >= to_unsigned(1,FIT_TO_SCREEN_EN'length))then 
        --    FIT_TO_SCREEN_EN <= to_unsigned(0,FIT_TO_SCREEN_EN'length);
        --  else
        --    FIT_TO_SCREEN_EN <= to_unsigned(1,FIT_TO_SCREEN_EN'length);
        --  end if;  
        elsif(menu_option_cnt = AGC_ADVANCE_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
            MAX_LIMITER_DPHE_VALID    <= '1';
            if(MAX_LIMITER_DPHE >= to_unsigned(100,MAX_LIMITER_DPHE'length))then        
              MAX_LIMITER_DPHE <= to_unsigned(0,MAX_LIMITER_DPHE'length);
            else  
              MAX_LIMITER_DPHE <= MAX_LIMITER_DPHE + 1;
            end if;
          elsif(CURSOR_POS_LY2 = x"1")then
            CNTRL_MAX_GAIN_VALID    <= '1';
            if(CNTRL_MAX_GAIN >= to_unsigned(100,CNTRL_MAX_GAIN'length))then        
              CNTRL_MAX_GAIN <= to_unsigned(0,CNTRL_MAX_GAIN'length);
            else  
              CNTRL_MAX_GAIN <= CNTRL_MAX_GAIN + 1;
            end if;
          elsif(CURSOR_POS_LY2 = x"2")then
            CNTRL_IPP_VALID    <= '1';
            if(CNTRL_IPP >= to_unsigned(100,CNTRL_IPP'length))then        
              CNTRL_IPP <= to_unsigned(0,CNTRL_IPP'length);
            else  
              CNTRL_IPP <= CNTRL_IPP + 1;
            end if;           
          elsif(CURSOR_POS_LY2 = x"3")then
            MUL_MAX_LIMITER_DPHE_VALID <= '1';
            if(MUL_MAX_LIMITER_DPHE >= to_unsigned(5,MUL_MAX_LIMITER_DPHE'length))then        
              MUL_MAX_LIMITER_DPHE <= to_unsigned(0,MUL_MAX_LIMITER_DPHE'length);
            else  
              MUL_MAX_LIMITER_DPHE <= MUL_MAX_LIMITER_DPHE + 1;
            end if;
          end if;             
        elsif(menu_option_cnt = NUC_ADVANCE_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
            NUC_MODE_VALID    <= '1';
            if(NUC_MODE >= to_unsigned(2,NUC_MODE'length))then        
              NUC_MODE <= to_unsigned(0,NUC_MODE'length);
            else  
              NUC_MODE <= NUC_MODE + 1;
            end if;
--          elsif(CURSOR_POS_LY2 = x"1")then
--            BLADE_MODE_VALID    <= '1';
--            if(BLADE_MODE >= to_unsigned(3,BLADE_MODE'length))then        
--              BLADE_MODE <= to_unsigned(0,BLADE_MODE'length);
--            else  
--              BLADE_MODE <= BLADE_MODE + 1;
--            end if;           
          end if;   
        elsif(menu_option_cnt = COMPASS_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
            GYRO_DATA_DISP_EN_VALID <= '1';
            if(GYRO_DATA_DISP_EN >= to_unsigned(1,GYRO_DATA_DISP_EN'length))then 
              GYRO_DATA_DISP_EN <= to_unsigned(0,GYRO_DATA_DISP_EN'length);
            else
              GYRO_DATA_DISP_EN <= to_unsigned(1,GYRO_DATA_DISP_EN'length);
            end if; 
--          elsif(CURSOR_POS_LY2 = x"1")then 
--            GYRO_CALIB_EN_VALID <= '1';
--            GYRO_CALIB_EN       <= '1';                
          end if;               
        elsif(menu_option_cnt = BPR_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
--            RETICLE_VERT_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
            if(RETICLE_VERT >= to_unsigned(479,RETICLE_VERT'length))then        
              RETICLE_VERT <= to_unsigned(0,RETICLE_VERT'length);
            else  
              RETICLE_VERT <= RETICLE_VERT + 1;
            end if;
          elsif(CURSOR_POS_LY2 = x"1")then
--            RETICLE_HORZ_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
            if(RETICLE_HORZ >= to_unsigned(639,RETICLE_HORZ'length))then        
              RETICLE_HORZ <= to_unsigned(0,RETICLE_HORZ'length);
            else  
              RETICLE_HORZ <= RETICLE_HORZ + 1;
            end if;
          elsif(CURSOR_POS_LY2 = x"2")then
            MARK_BP_VALID  <= '1';
            MARK_BP_UPDATE <= '1';
            if(MARK_BP >= to_unsigned(1,MARK_BP'length))then
              MARK_BP <= to_unsigned(0,MARK_BP'length);
            else
              MARK_BP <= MARK_BP + 1;
            end if;
          end if;  
    
--        elsif(menu_option_cnt = FIRING_POS)then
--          if(CURSOR_POS_LY2 =x"0")then
--            FIRING_MODE_VALID <= '1';
--            if(FIRING_MODE >= to_unsigned(1,FIRING_MODE'length))then
--              FIRING_MODE <= to_unsigned(0,FIRING_MODE'length);
--            else
--              FIRING_MODE <= FIRING_MODE + 1;
--            end if;          
--          elsif(CURSOR_POS_LY2 =x"1" )then
--            DISTANCE_SEL_VALID <= '1';
--            if(DISTANCE_SEL >= to_unsigned(15,RETICLE_TYPE'length))then
--              DISTANCE_SEL <= to_unsigned(0,RETICLE_TYPE'length);
--            else
--              DISTANCE_SEL <= DISTANCE_SEL + 1;
--            end if;
--          end if;                    
        elsif(menu_option_cnt = POLARITY_KEY_POS)then
          POLARITY_VALID  <= '1';
          SMOOTHING_VALID <= '1';
          if(POLARITY >= to_unsigned(4,POLARITY'length))then
            POLARITY  <= to_unsigned(0,POLARITY'length);
          else
            POLARITY  <= POLARITY +1; 
          end if;
          if(POLARITY = "010")then
            SMOOTHING <= "1"; 
          elsif(POLARITY = "100")then
            SMOOTHING <= SMOOTHING_HIST;  
          end if;   
--        elsif(menu_option_cnt = GAIN_KEY_POS or menu_option_cnt = GAIN_POS)then
        elsif(menu_option_cnt = GAIN_POS)then
          GAIN_VALID <= '1';
          if(GAIN >= to_unsigned(10,GAIN'length))then
            GAIN  <= to_unsigned(0,GAIN'length);
          else
            GAIN  <= GAIN +1; 
          end if;     
        end if;           
     elsif((LATCH_MENU_SEL_DN = '1' and OSD_EN = '1') and ly3_Sel = '1')then 
        param_update <= '1';  
        --if(menu_option_cnt = CALIBRATION_POS)then
          --if(CALIB_MODE = to_unsigned(0,CALIB_MODE'length))then
          --  CALIB_MODE <= to_unsigned(1,CALIB_MODE'length);
          --else
          --  CALIB_MODE <= CALIB_MODE -1;
          --end if;
          --CALIB_MODE_VALID <= '1';         
        if(menu_option_cnt = BRIGHTNESS_POS)then
          BRIGHTNESS_VALID <= '1';
          if(BRIGHTNESS = to_unsigned(0,BRIGHTNESS'length))then
            BRIGHTNESS <= to_unsigned(10,BRIGHTNESS'length);
          else
            BRIGHTNESS <= BRIGHTNESS -1;
          end if;
        elsif(menu_option_cnt = DZOOM_POS or menu_option_cnt = DZOOM_KEY_POS)then
          DZOOM_VALID <= '1';
          if(SIGHT_MODE = "01" and CMD_DISPLAY_MODE = '0')then
              DZOOM <= DZOOM;
          else          
              if(DZOOM = to_unsigned(0,DZOOM'length))then
                DZOOM <= to_unsigned(2,DZOOM'length);
              else  
                DZOOM <= DZOOM -1;
              end if;  
          end if;
        elsif(menu_option_cnt = AGC_POS)then
          AGC_MODE_VALID <= '1';
          if(AGC_MODE = to_unsigned(0,AGC_MODE'length))then
            AGC_MODE <= to_unsigned(2,AGC_MODE'length);
          else
            AGC_MODE <= AGC_MODE -1;
          end if;           
        elsif(menu_option_cnt = LASER_POS)then 
          LASER_EN_VALID <= '1';
          if(LASER_EN = to_unsigned(0,LASER_EN'length))then 
            LASER_EN <= to_unsigned(1,LASER_EN'length);
          else
            LASER_EN <= to_unsigned(0,LASER_EN'length);
          end if;  
        elsif(menu_option_cnt = DISPLAY_POS)then
          if(CURSOR_POS_LY2 =x"0" )then
            DISPLAY_LUX_VALID <= '1';
            if(DISPLAY_LUX = to_unsigned(0,DISPLAY_LUX'length))then
--              DISPLAY_LUX <= to_unsigned(127,DISPLAY_LUX'length);
              DISPLAY_LUX <= to_unsigned(100,DISPLAY_LUX'length);
            else  
              DISPLAY_LUX  <= DISPLAY_LUX  - 1; 
            end if;  
          elsif(CURSOR_POS_LY2 =x"1" )then  
            DISPLAY_GAIN_VALID <= '1';
            if(DISPLAY_GAIN = to_unsigned(0,DISPLAY_GAIN'length))then 
--              DISPLAY_GAIN <= to_unsigned(7,DISPLAY_GAIN'length);
              DISPLAY_GAIN <= to_unsigned(100,DISPLAY_GAIN'length);
            else
              DISPLAY_GAIN <= DISPLAY_GAIN - 1;
            end if;

          elsif(CURSOR_POS_LY2 =x"2" )then
            DISPLAY_VERT_VALID <= '1';
            if(DISPLAY_VERT = to_unsigned(0,DISPLAY_VERT'length))then
--              DISPLAY_VERT <= to_unsigned(12,DISPLAY_VERT'length);
              DISPLAY_VERT <= OLED_POS_V_MAX_OFFSET;
            else
              DISPLAY_VERT <= DISPLAY_VERT - 1;
            end if;
          elsif(CURSOR_POS_LY2 =x"3" )then  
            DISPLAY_HORZ_VALID <= '1';
            if(DISPLAY_HORZ = to_unsigned(0,DISPLAY_HORZ'length))then
--              DISPLAY_HORZ <= to_unsigned(12,DISPLAY_HORZ'length);
              DISPLAY_HORZ <= OLED_POS_H_MAX_OFFSET;
            else  
              DISPLAY_HORZ <= DISPLAY_HORZ - 1;
            end if;
          end if;  
        elsif(menu_option_cnt = RETICLE_POS)then
          if(CURSOR_POS_LY2 =x"0" )then
            RETICLE_COLOR_VALID <= '1';
            if(RETICLE_COLOR = to_unsigned(0,RETICLE_COLOR'length))then
              RETICLE_COLOR <= to_unsigned(5,RETICLE_COLOR'length);
            else
              RETICLE_COLOR <= RETICLE_COLOR - 1;
            end if;
          elsif(CURSOR_POS_LY2 =x"1" )then
            RETICLE_TYPE_VALID <= '1';
            if(RETICLE_TYPE = to_unsigned(0,RETICLE_TYPE'length))then
              RETICLE_TYPE <= to_unsigned(6,RETICLE_TYPE'length);
            else
              RETICLE_TYPE <= RETICLE_TYPE - 1;
            end if;
          elsif(CURSOR_POS_LY2 =x"2" )then   
--            RETICLE_VERT_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
            if(RETICLE_VERT = to_unsigned(0,RETICLE_VERT'length))then        
              RETICLE_VERT <= to_unsigned(479,RETICLE_VERT'length);
            else  
              RETICLE_VERT <= RETICLE_VERT - 1;
            end if;
          elsif(CURSOR_POS_LY2 =x"3" )then 
--            RETICLE_HORZ_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
            if(RETICLE_HORZ = to_unsigned(0,RETICLE_HORZ'length))then
              RETICLE_HORZ <= to_unsigned(639,RETICLE_HORZ'length);
            else          
              RETICLE_HORZ <= RETICLE_HORZ - 1;
            end if;
          end if;             
        elsif(menu_option_cnt = IMG_ENHANCE_POS)then
          if(CURSOR_POS_LY2 =x"0"  and (POLARITY /= "011" and POLARITY /= "100"))then
            SMOOTHING_VALID <= '1';
            if(SMOOTHING = to_unsigned(0,SMOOTHING'length))then
              SMOOTHING <= to_unsigned(1,SMOOTHING'length);
              SMOOTHING_HIST <= to_unsigned(1,SMOOTHING_HIST'length);
            else 
              SMOOTHING <= to_unsigned(0,SMOOTHING'length);
              SMOOTHING_HIST <= to_unsigned(0,SMOOTHING_HIST'length);
            end if;
          elsif(CURSOR_POS_LY2 =x"1" )then
            SHARPNESS_VALID <= '1';
            if(SHARPNESS = to_unsigned(0,SHARPNESS'length))then
              SHARPNESS  <= to_unsigned(8,SHARPNESS'length);
            else
              SHARPNESS  <= SHARPNESS - 1;
            end if; 
          elsif(CURSOR_POS_LY2 =x"2" )then
            SOFTNUC_VALID <= '1';
            if(SOFTNUC = to_unsigned(0,SOFTNUC'length))then
              SOFTNUC <= to_unsigned(1,SOFTNUC'length);
            else
              SOFTNUC  <= SOFTNUC -1;
            end if;   
          end if;
        --elsif(menu_option_cnt = DISPLAY_MODE_POS)then 
        --  DISPLAY_MODE_VALID <= '1';
        --  if(DISPLAY_MODE = to_unsigned(0,DISPLAY_MODE'length))then 
        --    DISPLAY_MODE <= to_unsigned(1,DISPLAY_MODE'length);
        --  else
        --    DISPLAY_MODE <= to_unsigned(0,DISPLAY_MODE'length);
        --  end if;   

        elsif(menu_option_cnt = SIGHT_CONFIG_POS)then 
            if(CURSOR_POS_LY2 =x"0")then
              DISPLAY_MODE_VALID <= '1';
              if(DISPLAY_MODE = to_unsigned(0,DISPLAY_MODE'length))then 
                DISPLAY_MODE <= to_unsigned(1,DISPLAY_MODE'length);
              else
                DISPLAY_MODE <= to_unsigned(0,DISPLAY_MODE'length);
              end if;  
            elsif(CURSOR_POS_LY2 =x"1")then 
              SIGHT_MODE_VALID <= '1';
              if(SIGHT_MODE = to_unsigned(0,SIGHT_MODE'length))then 
                SIGHT_MODE <= to_unsigned(2,SIGHT_MODE'length);
              else
                SIGHT_MODE <= SIGHT_MODE - 1;
              end if;              
            end if; 

        --elsif(menu_option_cnt = FIT_TO_SCREEN_POS)then 
        --  FIT_TO_SCREEN_EN_VALID <= '1';
        --  if(FIT_TO_SCREEN_EN = to_unsigned(0,FIT_TO_SCREEN_EN'length))then 
        --    FIT_TO_SCREEN_EN <= to_unsigned(1,FIT_TO_SCREEN_EN'length);
        --  else
        --    FIT_TO_SCREEN_EN <= to_unsigned(0,FIT_TO_SCREEN_EN'length);
        --  end if;   
        elsif(menu_option_cnt = AGC_ADVANCE_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
            MAX_LIMITER_DPHE_VALID    <= '1';
            if(MAX_LIMITER_DPHE = to_unsigned(0,MAX_LIMITER_DPHE'length))then        
              MAX_LIMITER_DPHE <= to_unsigned(100,MAX_LIMITER_DPHE'length);
            else  
              MAX_LIMITER_DPHE <= MAX_LIMITER_DPHE - 1;
            end if;
          elsif(CURSOR_POS_LY2 = x"1")then
            CNTRL_MAX_GAIN_VALID    <= '1';
            if(CNTRL_MAX_GAIN = to_unsigned(0,CNTRL_MAX_GAIN'length))then        
              CNTRL_MAX_GAIN <= to_unsigned(100,CNTRL_MAX_GAIN'length);
            else  
              CNTRL_MAX_GAIN <= CNTRL_MAX_GAIN - 1;
            end if;
          elsif(CURSOR_POS_LY2 = x"2")then
            CNTRL_IPP_VALID    <= '1';
            if(CNTRL_IPP = to_unsigned(0,CNTRL_IPP'length))then        
              CNTRL_IPP <= to_unsigned(100,CNTRL_IPP'length);
            else  
              CNTRL_IPP <= CNTRL_IPP - 1;
            end if;           
          elsif(CURSOR_POS_LY2 = x"3")then
            MUL_MAX_LIMITER_DPHE_VALID <= '1';
            if(MUL_MAX_LIMITER_DPHE = to_unsigned(0,MUL_MAX_LIMITER_DPHE'length))then        
              MUL_MAX_LIMITER_DPHE <= to_unsigned(5,MUL_MAX_LIMITER_DPHE'length);
            else  
              MUL_MAX_LIMITER_DPHE <= MUL_MAX_LIMITER_DPHE - 1;
            end if;
          end if;  
        elsif(menu_option_cnt = NUC_ADVANCE_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
            NUC_MODE_VALID    <= '1';
            if(NUC_MODE = to_unsigned(0,NUC_MODE'length))then        
              NUC_MODE <= to_unsigned(2,NUC_MODE'length);
            else  
              NUC_MODE <= NUC_MODE - 1;
            end if;
--          elsif(CURSOR_POS_LY2 = x"1")then
--            BLADE_MODE_VALID    <= '1';
--            if(BLADE_MODE = to_unsigned(0,BLADE_MODE'length))then        
--              BLADE_MODE <= to_unsigned(3,BLADE_MODE'length);
--            else  
--              BLADE_MODE <= BLADE_MODE - 1;
--            end if;             
          end if;                   
        --elsif(menu_option_cnt = PALETTE_POS)then 
        --  PALETTE_TYPE_VALID <= '1';
        --  if(PALETTE_TYPE = to_unsigned(0,PALETTE_TYPE'length))then
        --    PALETTE_TYPE <= to_unsigned(6,PALETTE_TYPE'length);
        --  else
        --    PALETTE_TYPE <= PALETTE_TYPE -1;
        --  end if;
        elsif(menu_option_cnt = COMPASS_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
            GYRO_DATA_DISP_EN_VALID <= '1';
            if(GYRO_DATA_DISP_EN = to_unsigned(0,GYRO_DATA_DISP_EN'length))then 
              GYRO_DATA_DISP_EN <= to_unsigned(1,GYRO_DATA_DISP_EN'length);
            else
              GYRO_DATA_DISP_EN <= to_unsigned(0,GYRO_DATA_DISP_EN'length);
            end if;  
--          elsif(CURSOR_POS_LY2 = x"1")then 
--            GYRO_CALIB_EN_VALID <= '1';
--            GYRO_CALIB_EN       <= '1';                
          end if;                          
        elsif(menu_option_cnt = BPR_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
--            RETICLE_VERT_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
            if(RETICLE_VERT = to_unsigned(0,RETICLE_VERT'length))then        
              RETICLE_VERT <= to_unsigned(479,RETICLE_VERT'length);
            else  
              RETICLE_VERT <= RETICLE_VERT - 1;
            end if;
          elsif(CURSOR_POS_LY2 = x"1")then
--            RETICLE_HORZ_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
            if(RETICLE_HORZ = to_unsigned(0,RETICLE_HORZ'length))then        
              RETICLE_HORZ <= to_unsigned(639,RETICLE_HORZ'length);
            else  
              RETICLE_HORZ <= RETICLE_HORZ - 1;
            end if;
          elsif(CURSOR_POS_LY2 = x"2")then
            MARK_BP_VALID <= '1';
            MARK_BP_UPDATE <= '1';
            if(MARK_BP = to_unsigned(0,MARK_BP'length))then
              MARK_BP <= to_unsigned(1,MARK_BP'length);
            else
             MARK_BP <= MARK_BP - 1;
            end if;
          end if;

--        elsif(menu_option_cnt = SNAPSHOT_POS and CURSOR_POS_LY2 = x"02")then 
--          if(SNAPSHOT_COUNTER = x"01")then
--             SNAPSHOT_COUNTER      <= MAX_SNAPSHOT;
--          else
--             SNAPSHOT_COUNTER      <= SNAPSHOT_COUNTER - 1;
--          end if;   
--          SNAPSHOT_COUNTER_VALID <= '1'; 
 
--        elsif(menu_option_cnt = STANDBY_POS)then 
--          STANDBY_EN_VALID <= '1';
--          if(STANDBY_EN = to_unsigned(0,STANDBY_EN'length))then 
--            STANDBY_EN <= to_unsigned(1,STANDBY_EN'length);
--          else
--            STANDBY_EN <= to_unsigned(0,STANDBY_EN'length);
--          end if;     
--        elsif(menu_option_cnt = FIRING_POS)then
--          if(CURSOR_POS_LY2 =x"0")then
--            FIRING_MODE_VALID <= '1';
--            if(FIRING_MODE = to_unsigned(0,FIRING_MODE'length))then
--              FIRING_MODE <= to_unsigned(1,FIRING_MODE'length);
--            else
--              FIRING_MODE <= FIRING_MODE - 1;
--            end if;          
--          elsif(CURSOR_POS_LY2 =x"1" )then
--            DISTANCE_SEL_VALID <= '1';
--            if(DISTANCE_SEL = to_unsigned(0,RETICLE_TYPE'length))then
--              DISTANCE_SEL <= to_unsigned(15,RETICLE_TYPE'length);
--            else
--              DISTANCE_SEL <= DISTANCE_SEL - 1;
--            end if;
--          end if;                  
        elsif(menu_option_cnt = POLARITY_KEY_POS)then
          POLARITY_VALID  <= '1';
          SMOOTHING_VALID <= '1';
          if(POLARITY = to_unsigned(0,POLARITY'length))then
            POLARITY  <= to_unsigned(4,POLARITY'length);
          else
            POLARITY  <= POLARITY -1; 
          end if;     
          if(POLARITY = "000")then
            SMOOTHING <= "1";
          elsif(POLARITY = "011")then
            SMOOTHING <= SMOOTHING_HIST;
          end if;         
--        elsif(menu_option_cnt = GAIN_KEY_POS or menu_option_cnt = GAIN_POS)then
        elsif(menu_option_cnt = GAIN_POS)then
          GAIN_VALID <= '1';
          if(GAIN = to_unsigned(0,GAIN'length))then
            GAIN  <= to_unsigned(10,GAIN'length);
          else
            GAIN  <= GAIN -1; 
          end if;     
        end if;  
     elsif(ly3_sel = '1' and ly3_val_init_done ='0')then
        ly3_val_init_done <= '1';
        --if(menu_option_cnt = CALIBRATION_POS)then
        --    CALIB_MODE_VALID <= '1';
        if(menu_option_cnt = BRIGHTNESS_POS)then
          BRIGHTNESS_VALID <= '1';                  
        
        elsif(menu_option_cnt = DZOOM_POS or menu_option_cnt = DZOOM_KEY_POS)then
          DZOOM_VALID <= '1';
        
        elsif(menu_option_cnt = AGC_POS)then
          AGC_MODE_VALID <= '1';
 
        elsif(menu_option_cnt = LASER_POS)then
          LASER_EN_VALID <= '1';   
        
        elsif(menu_option_cnt = DISPLAY_POS)then  
          if(CURSOR_POS_LY2 =x"0" )then
            DISPLAY_LUX_VALID <= '1';
          elsif(CURSOR_POS_LY2 =x"1" )then  
            DISPLAY_GAIN_VALID <= '1';
          elsif(CURSOR_POS_LY2 =x"2" )then
            DISPLAY_VERT_VALID <= '1';
          elsif(CURSOR_POS_LY2 =x"3" )then 
            DISPLAY_HORZ_VALID <= '1'; 
          end if;  

        elsif(menu_option_cnt = RETICLE_POS)then
          if(CURSOR_POS_LY2 =x"0" )then
            RETICLE_COLOR_VALID <= '1';
          elsif(CURSOR_POS_LY2 =x"1" )then
            RETICLE_TYPE_VALID <= '1';
          elsif(CURSOR_POS_LY2 =x"2" )then   
--            RETICLE_VERT_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
          elsif(CURSOR_POS_LY2 =x"3" )then 
--            RETICLE_HORZ_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
          end if;              

        elsif(menu_option_cnt = IMG_ENHANCE_POS)then
          if(CURSOR_POS_LY2 =x"0")then        
            SMOOTHING_VALID <= '1';
          elsif(CURSOR_POS_LY2 =x"1")then
            SHARPNESS_VALID <= '1';
          elsif(CURSOR_POS_LY2 =x"2")then         
            SOFTNUC_VALID <= '1';
          end if;
        --elsif(menu_option_cnt = DISPLAY_MODE_POS)then
        --  DISPLAY_MODE_VALID <= '1';          
        elsif(menu_option_cnt = SIGHT_CONFIG_POS)then
          if(CURSOR_POS_LY2 =x"0")then              
            DISPLAY_MODE_VALID <= '1';   
          elsif(CURSOR_POS_LY2 =x"1")then       
            SIGHT_MODE_VALID <= '1';   
          end if;      
        --elsif(menu_option_cnt = FIT_TO_SCREEN_POS)then
          --FIT_TO_SCREEN_EN_VALID <= '1';
        elsif(menu_option_cnt = AGC_ADVANCE_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
            MAX_LIMITER_DPHE_VALID    <= '1';
          elsif(CURSOR_POS_LY2 = x"1")then
            CNTRL_MAX_GAIN_VALID <= '1';
          elsif(CURSOR_POS_LY2 = x"2")then
            CNTRL_IPP_VALID <= '1';
          elsif(CURSOR_POS_LY2 = x"3")then
            MUL_MAX_LIMITER_DPHE_VALID <= '1';            
          end if;  
        elsif(menu_option_cnt = NUC_ADVANCE_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
            NUC_MODE_VALID    <= '1';
--          elsif(CURSOR_POS_LY2 = x"1")then
--            BLADE_MODE_VALID    <= '1';
          end if; 
        --elsif(menu_option_cnt = PALETTE_POS)then 
        --  PALETTE_TYPE_VALID <= '1';

        elsif(menu_option_cnt = COMPASS_POS)then
          if(CURSOR_POS_LY2 = x"0")then
            GYRO_DATA_DISP_EN_VALID <= '1';   
          end if;
        elsif(menu_option_cnt = BPR_POS)then 
          if(CURSOR_POS_LY2 = x"0")then
--            RETICLE_VERT_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
          elsif(CURSOR_POS_LY2 = x"1")then
--            RETICLE_HORZ_VALID <= '1';
            RETICLE_VERT_HORZ_VALID    <= '1';
          elsif(CURSOR_POS_LY2 = x"2")then
            MARK_BP_VALID <= '1';
          end if;  
       
--        elsif(menu_option_cnt = STANDBY_POS)then
--          STANDBY_EN_VALID <= '1';                         
--        elsif(menu_option_cnt = FIRING_POS)then
--          if(CURSOR_POS_LY2 =x"0" )then
--            FIRING_MODE_VALID <= '1';
--          elsif(CURSOR_POS_LY2 =x"1" )then
--            DISTANCE_SEL_VALID <= '1';
--          end if;  
        elsif(menu_option_cnt = POLARITY_KEY_POS)then
          POLARITY_VALID <= '1';        
--        elsif(menu_option_cnt = GAIN_KEY_POS or menu_option_cnt = GAIN_POS)then
        elsif(menu_option_cnt = GAIN_POS)then
          GAIN_VALID <= '1';  
        end if;             
     else
        --if(CMD_START_NUC1ptCalib_VALID = '1')then
        --    if(CMD_START_NUC1ptCalib = '1')then
        --        CALIB_MODE <= "1";
        --    else 
        --        CALIB_MODE <= "0";
        --    end if;  
        --    CALIB_MODE_VALID <= '1';  
        --end if;
        if(CMD_BRIGHTNESS_VALID = '1')then 
            if(unsigned(CMD_BRIGHTNESS) <= to_unsigned(10,BRIGHTNESS'length))then
                BRIGHTNESS <= unsigned(CMD_BRIGHTNESS);
            else
                BRIGHTNESS <= to_unsigned(10,BRIGHTNESS'length);
            end if;    
            BRIGHTNESS_VALID <= '1';
        end if;

        if(CMD_CONTRAST_VALID = '1')then 
            if(unsigned(CMD_CONTRAST) <= to_unsigned(10,CONTRAST'length))then
                GAIN <= unsigned(CMD_CONTRAST);
            else
                GAIN <= to_unsigned(10,GAIN'length);
            end if;
            GAIN_VALID <= '1'; 
        end if;

        if(CMD_DZOOM_VALID = '1')then
            if(unsigned(CMD_DZOOM) <= to_unsigned(2,DZOOM'length))then
                DZOOM <= unsigned(CMD_DZOOM);
            else
                DZOOM <= to_unsigned(2,DZOOM'length);
            end if;            
--            DZOOM       <= unsigned(CMD_DZOOM);
            DZOOM_VALID <= '1';
        end if;
        if(CMD_AGC_MODE_SEL_VALID = '1')then 
            if(unsigned(CMD_AGC_MODE_SEL) <= to_unsigned(2,AGC_MODE'length))then
                AGC_MODE <= unsigned(CMD_AGC_MODE_SEL);
            else
                AGC_MODE <= to_unsigned(2,AGC_MODE'length);
            end if;              
--            AGC_MODE       <= unsigned(CMD_AGC_MODE_SEL);
            AGC_MODE_VALID <= '1';
        end if;
        if(CMD_LASER_EN_VALID = '1')then 
            if(CMD_LASER_EN = '1')then
               LASER_EN       <= "1";
            else
               LASER_EN       <= "0";
            end if;
            LASER_EN_VALID <= '1';
        end if; 


        if(CMD_DISPLAY_HORZ_VALID = '1')then 
            DISPLAY_HORZ       <= unsigned(CMD_DISPLAY_HORZ);
            DISPLAY_HORZ_VALID <= '1';
        end if;
        if(CMD_DISPLAY_VERT_VALID = '1')then 
            DISPLAY_VERT       <= unsigned(CMD_DISPLAY_VERT);
            DISPLAY_VERT_VALID <= '1';
        end if;
        if(CMD_DISPLAY_LUX_VALID = '1')then 
            if(unsigned(CMD_DISPLAY_LUX) > to_unsigned(100,CMD_DISPLAY_LUX'length))then
               DISPLAY_LUX <= to_unsigned(100,DISPLAY_LUX'length); 
            else
               DISPLAY_LUX <= unsigned(CMD_DISPLAY_LUX);
            end if;
            
            DISPLAY_LUX_VALID <= '1';
        end if;
        if(CMD_DISPLAY_GAIN_VALID = '1')then 
            if(unsigned(CMD_DISPLAY_GAIN) > to_unsigned(100,CMD_DISPLAY_GAIN'length))then
               DISPLAY_GAIN <= to_unsigned(100,DISPLAY_GAIN'length); 
            else
               DISPLAY_GAIN <= unsigned(CMD_DISPLAY_GAIN);
            end if;
            DISPLAY_GAIN_VALID <= '1';
        end if;


        if(CMD_RETICLE_COLOR_VALID = '1')then 
--            if(CMD_RETICLE_COLOR = '1')then
--               RETICLE_COLOR <= "1"; 
--            else
--               RETICLE_COLOR <= "0";
--            end if; 
            if(unsigned(CMD_RETICLE_COLOR) <= to_unsigned(5,CMD_RETICLE_COLOR'length) )then
               RETICLE_COLOR <= unsigned(CMD_RETICLE_COLOR); 
            else
               RETICLE_COLOR <= to_unsigned(5,RETICLE_COLOR'length);
            end if; 

            RETICLE_COLOR_VALID <= '1';
        end if;
        
        if(CMD_RETICLE_TYPE_SEL_VALID = '1')then 
            if(unsigned(CMD_RETICLE_TYPE_SEL) > to_unsigned(6,RETICLE_TYPE'length))then
               RETICLE_TYPE <= to_unsigned(6,RETICLE_TYPE'length); 
            else
               RETICLE_TYPE <= unsigned(CMD_RETICLE_TYPE_SEL);
            end if; 
            RETICLE_TYPE_VALID <= '1';
        end if;
        if(CMD_RETICLE_POS_YX_VALID = '1')then 
            if(unsigned(CMD_RETICLE_POS_YX(10 downto 0)) > to_unsigned(639,RETICLE_HORZ'length))then
                RETICLE_HORZ <= to_unsigned(639,RETICLE_HORZ'length);
            else
                RETICLE_HORZ <= unsigned(CMD_RETICLE_POS_YX(10 downto 0));
            end if;
            if(unsigned(CMD_RETICLE_POS_YX(21 downto 12)) > to_unsigned(479,RETICLE_VERT'length))then
                RETICLE_VERT <= to_unsigned(479,RETICLE_VERT'length);
            else
                RETICLE_VERT <= unsigned(CMD_RETICLE_POS_YX(21 downto 12));
            end if;    
            RETICLE_VERT_HORZ_VALID <= '1';
        end if;
--        if(CMD_RETICLE_POS_X_VALID = '1')then 
--            RETICLE_HORZ       <= unsigned(CMD_RETICLE_POS_X);
--            RETICLE_HORZ_VALID <= '1';
--        end if;
--        if(CMD_RETICLE_POS_Y_VALID = '1')then 
--            RETICLE_VERT <= unsigned(CMD_RETICLE_POS_Y);
--            RETICLE_VERT_VALID <= '1';
--        end if;

        if(CMD_SNUC_EN_VALID = '1')then 
            if(CMD_SNUC_EN = '1')then
                SOFTNUC <= "1";
            else
                SOFTNUC <= "0";
            end if;
            SOFTNUC_VALID <= '1';
        end if;         
        --if(CMD_CP_TYPE_SEL_VALID = '1')then 
        --    PALETTE_TYPE       <= unsigned(CMD_CP_TYPE_SEL(3 downto 0));
        --    PALETTE_TYPE_VALID <= '1';
        --end if;  

        if(CMD_SHARPNESS_VALID = '1')then 
            if(unsigned(CMD_SHARPNESS) <= to_unsigned(8,SHARPNESS'length))then
                SHARPNESS       <= unsigned(CMD_SHARPNESS);
            else
                SHARPNESS <= to_unsigned(8,SHARPNESS'length);
            end if;           
            SHARPNESS_VALID <= '1';
        end if;  

        if(CMD_SMOOTHING_EN_VALID = '1' and (POLARITY /= "011" and POLARITY /="100"))then
            if(CMD_SMOOTHING_EN = '1')then
                SMOOTHING <= "1";
                SMOOTHING_HIST <= "1";
            else
                SMOOTHING <= "0";
                SMOOTHING_HIST <= "0";
            end if;
            SMOOTHING_VALID <= '1';
        end if;  
                                                    
        if(CMD_EDGE_EN_VALID = '1' or CMD_POLARITY_VALID = '1')then 
            if(CMD_EDGE_EN = '1' and CMD_POLARITY = "00")then
                POLARITY       <= "011";
                SMOOTHING      <= "1";
            elsif(CMD_EDGE_EN = '1' and CMD_POLARITY = "01")then
                POLARITY       <= "100";
                SMOOTHING      <= "1";
            elsif(CMD_POLARITY = "01")then    
                POLARITY  <= "001";
                SMOOTHING <= SMOOTHING_HIST;
            elsif(CMD_POLARITY = "00")then
                POLARITY  <= "000";  
                SMOOTHING <= SMOOTHING_HIST;  
            else
                POLARITY  <= "010";  
                SMOOTHING <= SMOOTHING_HIST;              
            end if;
            POLARITY_VALID  <= '1';
            SMOOTHING_VALID <= '1'; 
        end if;

        if(CMD_DISPLAY_MODE_VALID = '1')then 
            if(CMD_DISPLAY_MODE = '1')then
               DISPLAY_MODE       <= "1";
            else
               DISPLAY_MODE       <= "0";
            end if;
            DISPLAY_MODE_VALID <= '1';
        end if; 

        if(CMD_SIGHT_MODE_VALID = '1')then 
            if(unsigned(CMD_SIGHT_MODE) <= to_unsigned(2,SIGHT_MODE'length))then
                SIGHT_MODE <= unsigned(CMD_SIGHT_MODE);
            else
                SIGHT_MODE <= to_unsigned(2,SIGHT_MODE'length);
            end if;
            SIGHT_MODE_VALID <= '1';
        end if; 

        if(CMD_GALLERY_IMG_VALID_EN = '1')then
            GALLERY_IMG_VALID      <= CMD_GALLERY_IMG_VALID(71 downto 8);
            SNAPSHOT_COUNTER       <= unsigned(CMD_GALLERY_IMG_VALID(7 downto 0)); 
            SNAPSHOT_COUNTER_VALID <= '1';
            GALLERY_IMG_VALID_EN   <= '1';  
        end if;

        if(CMD_GYRO_DATA_DISP_EN_VALID = '1')then 
            if(CMD_GYRO_DATA_DISP_EN = '1')then
               GYRO_DATA_DISP_EN <= "1";
            else
               GYRO_DATA_DISP_EN <= "0";
            end if;
            GYRO_DATA_DISP_EN_VALID <= '1';
        end if; 
               
        if(((CURSOR_POS_LY2 = x"02") and menu_option_cnt = BPR_POS))then
            MARK_BP <= MARK_BP; 
        else
            MARK_BP <= "0"; 
        end if;    

        --if(CMD_FIT_TO_SCREEN_EN_VALID = '1')then 
        --    if(CMD_FIT_TO_SCREEN_EN = '1')then
        --       FIT_TO_SCREEN_EN       <= "1";
        --    else
        --       FIT_TO_SCREEN_EN       <= "0";
        --    end if;
        --    FIT_TO_SCREEN_EN_VALID <= '1';
        --end if; 
                
        
--        if(CMD_FIRING_MODE_VALID = '1')then 
--            if(CMD_FIRING_MODE = '1')then
--               FIRING_MODE <= "1";
--            else
--               FIRING_MODE <= "0";
--            end if;
--            FIRING_MODE_VALID <= '1';
--        end if;   
        
        if(CMD_MAX_LIMITER_DPHE_VALID = '1')then 
            if(unsigned(CMD_MAX_LIMITER_DPHE) > to_unsigned(100,MAX_LIMITER_DPHE'length))then
               MAX_LIMITER_DPHE <= to_unsigned(100,MAX_LIMITER_DPHE'length); 
            else
               MAX_LIMITER_DPHE <= unsigned(CMD_MAX_LIMITER_DPHE);
            end if;
            MAX_LIMITER_DPHE_VALID <= '1';
        end if;               

        if(CMD_MUL_MAX_LIMITER_DPHE_VALID = '1')then 
            if(unsigned(CMD_MUL_MAX_LIMITER_DPHE) > to_unsigned(5,MUL_MAX_LIMITER_DPHE'length))then
               MUL_MAX_LIMITER_DPHE <= to_unsigned(5,MUL_MAX_LIMITER_DPHE'length); 
            else
               MUL_MAX_LIMITER_DPHE <= unsigned(CMD_MUL_MAX_LIMITER_DPHE);
            end if;
            MUL_MAX_LIMITER_DPHE_VALID <= '1';
        end if; 

        if(CMD_CNTRL_MAX_GAIN_VALID = '1')then 
            if(unsigned(CMD_CNTRL_MAX_GAIN) > to_unsigned(100,CNTRL_MAX_GAIN'length))then
               CNTRL_MAX_GAIN <= to_unsigned(100,CNTRL_MAX_GAIN'length); 
            else
               CNTRL_MAX_GAIN <= unsigned(CMD_CNTRL_MAX_GAIN);
            end if;
            CNTRL_MAX_GAIN_VALID <= '1';
        end if;  

        if(CMD_CNTRL_IPP_VALID = '1')then 
            if(unsigned(CMD_CNTRL_IPP) > to_unsigned(100,CNTRL_IPP'length))then
               CNTRL_IPP <= to_unsigned(100,CNTRL_IPP'length); 
            else
               CNTRL_IPP <= unsigned(CMD_CNTRL_IPP);
            end if;
            CNTRL_IPP_VALID <= '1';
        end if;

        if(CMD_NUC_MODE_VALID = '1')then 
            if(unsigned(CMD_NUC_MODE) > to_unsigned(2,NUC_MODE'length))then
               NUC_MODE <= to_unsigned(2,NUC_MODE'length); 
            else
               NUC_MODE <= unsigned(CMD_NUC_MODE);
            end if;
--            NUC_MODE_VALID <= '1';
        end if;

        if(CMD_BLADE_MODE_VALID = '1')then 
            BLADE_MODE <= unsigned(CMD_BLADE_MODE);
            BLADE_MODE_VALID <= '1';
        end if;

--        if(CMD_STANDBY_EN_VALID = '1')then 
--            STANDBY_EN       <= unsigned(CMD_STANDBY_EN);
--            STANDBY_EN_VALID <= '1';
--        end if; 

     end if;  
                            
     if(BCD_DATA_VALID = '1')then
        BCD_DATA_D <= BCD_DATA; 
     else
        BCD_DATA_D <= BCD_DATA_D; 
     end if;              

     if(BCD_DATA_RETICLE_OFFSET_H_VALID = '1')then
        BCD_DATA_RETICLE_OFFSET_H_D <= BCD_DATA_RETICLE_OFFSET_H; 
     else
        BCD_DATA_RETICLE_OFFSET_H_D <= BCD_DATA_RETICLE_OFFSET_H_D; 
     end if; 
               
     
     if(ly3_Sel = '1')then       
          if(hot_key_menu_sel = '1' and polarity_en = '1')then
--            if(BCD_DATA_D = x"000")then              
--                ADDR_CH_14 <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                ADDR_CH_15 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_16 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_17 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
--            elsif(BCD_DATA_D = x"001")then              
--                ADDR_CH_14 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                ADDR_CH_15 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--            elsif(BCD_DATA_D = x"002")then              
--                ADDR_CH_14 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_15 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_16 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_17 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--            end if;
              ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
              ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
              ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
              ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
          elsif(menu_option_cnt = DZOOM_POS or menu_option_cnt = DZOOM_KEY_POS)then 
--         if(BCD_DATA_VALID = '1')then
            if(SIGHT_MODE = "01" and CMD_DISPLAY_MODE = '0')then
                ADDR_CH_14 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                ADDR_CH_15 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
            elsif(BCD_DATA_D = x"000")then              
                ADDR_CH_14 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                ADDR_CH_15 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
--            elsif(BCD_DATA_D = x"001")then              
--                ADDR_CH_14 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_15 <= resize( 4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_16 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--            elsif(BCD_DATA_D = x"002")then              
--                ADDR_CH_14 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_15 <= resize( 6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_16 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            elsif(BCD_DATA_D = x"001")then  
                ADDR_CH_14 <= resize( 4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                ADDR_CH_15 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);             
            elsif(BCD_DATA_D = x"002")then              
                ADDR_CH_14 <= resize( 6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_15 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
            end if;                  
          else 
--         if(BCD_DATA_VALID = '1')then
            if(BCD_DATA_D(7 downto 4)= x"0" and BCD_DATA_D(11 downto 8) = x"0")then
                if(BCD_DATA_D(3 downto 0) = x"0")then              
                    ADDR_CH_14 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"1")then 
                    ADDR_CH_14 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(3 downto 0) = x"2")then
                    ADDR_CH_14 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"3")then 
                    ADDR_CH_14 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(3 downto 0) = x"4")then
                    ADDR_CH_14 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"5")then
                    ADDR_CH_14 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"6")then
                    ADDR_CH_14 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"7")then
                    ADDR_CH_14 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"8")then
                    ADDR_CH_14 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"9")then 
                    ADDR_CH_14 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                else
                    ADDR_CH_14 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                end if;        
                ADDR_CH_15 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_16 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            elsif (BCD_DATA_D(11 downto 8) = x"0")then
                if(BCD_DATA_D(3 downto 0) = x"0")then              
                    ADDR_CH_15 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"1")then 
                    ADDR_CH_15 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(3 downto 0) = x"2")then
                    ADDR_CH_15 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"3")then 
                    ADDR_CH_15 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(3 downto 0) = x"4")then
                    ADDR_CH_15 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(3 downto 0) = x"5")then
                    ADDR_CH_15 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"6")then
                    ADDR_CH_15 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"7")then
                    ADDR_CH_15 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"8")then
                    ADDR_CH_15 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"9")then 
                    ADDR_CH_15 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                else
                    ADDR_CH_15 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                end if;
    
                if(BCD_DATA_D(7 downto 4) = x"0")then
                    ADDR_CH_14 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
                elsif(BCD_DATA_D(7 downto 4) = x"1")then 
                    ADDR_CH_14 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"2")then
                    ADDR_CH_14 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"3")then 
                    ADDR_CH_14 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"4")then
                    ADDR_CH_14 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"5")then
                    ADDR_CH_14 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                elsif(BCD_DATA_D(7 downto 4) = x"6")then
                    ADDR_CH_14 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"7")then
                    ADDR_CH_14 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"8")then
                    ADDR_CH_14 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"9")then 
                    ADDR_CH_14 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                else
                    ADDR_CH_14 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                end if;         
                ADDR_CH_16 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
            else
                if(BCD_DATA_D(3 downto 0) = x"0")then              
                    ADDR_CH_16 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"1")then 
                    ADDR_CH_16 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(3 downto 0) = x"2")then
                    ADDR_CH_16 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"3")then 
                    ADDR_CH_16 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(3 downto 0) = x"4")then
                    ADDR_CH_16 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(3 downto 0) = x"5")then
                    ADDR_CH_16 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(3 downto 0) = x"6")then
                    ADDR_CH_16 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                elsif(BCD_DATA_D(3 downto 0) = x"7")then
                    ADDR_CH_16 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                elsif(BCD_DATA_D(3 downto 0) = x"8")then
                    ADDR_CH_16 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                elsif(BCD_DATA_D(3 downto 0) = x"9")then 
                    ADDR_CH_16 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                else
                    ADDR_CH_16 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                end if;
          
                if(BCD_DATA_D(7 downto 4) = x"1")then 
                    ADDR_CH_15 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(7 downto 4) = x"2")then
                    ADDR_CH_15 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(7 downto 4) = x"3")then 
                    ADDR_CH_15 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(7 downto 4) = x"4")then
                    ADDR_CH_15 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"5")then
                    ADDR_CH_15 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"6")then
                    ADDR_CH_15 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(7 downto 4) = x"7")then
                    ADDR_CH_15 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(7 downto 4) = x"8")then
                    ADDR_CH_15 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(7 downto 4) = x"9")then 
                    ADDR_CH_15 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                else
                    ADDR_CH_15 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                end if;
                
                if(BCD_DATA_D(11 downto 8)= x"1")then 
                    ADDR_CH_14 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(11 downto 8) = x"2")then
                    ADDR_CH_14 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                elsif(BCD_DATA_D(11 downto 8) = x"3")then 
                    ADDR_CH_14 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(11 downto 8) = x"4")then
                    ADDR_CH_14 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                elsif(BCD_DATA_D(11 downto 8) = x"5")then
                    ADDR_CH_14 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(11 downto 8) = x"6")then
                    ADDR_CH_14 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(11 downto 8) = x"7")then
                    ADDR_CH_14 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(BCD_DATA_D(11 downto 8) = x"8")then
                    ADDR_CH_14 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(BCD_DATA_D(11 downto 8) = x"9")then 
                    ADDR_CH_14 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                else
                    ADDR_CH_14 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                end if;                          
            end if;    
--         end if;
         ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         end if;        
         if(hot_key_menu_sel = '1')then
            if(polarity_en= '1')then
               if(BCD_DATA_D = x"000")then 
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               elsif(BCD_DATA_D = x"001")then  
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(22*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               elsif(BCD_DATA_D = x"002")then  
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                    
               elsif(BCD_DATA_D = x"003")then  
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               elsif(BCD_DATA_D = x"004")then  
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(22*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               end if;                               

--               ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_2  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--               ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_4  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_5  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_7  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_8  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_9  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--               ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
--            elsif(gain_en = '1')then
            elsif(dzoom_en = '1')then
               ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_2  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--               ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_5  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--               ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_2  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_3  <= resize(37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_4  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_5  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_6  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
               ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
               ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
               ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                            
            end if;
         
         elsif(main_menu_sel = '1')then
    --         if(CH_ADD_CNT = 4 or CH_ADD_CNT = 5 or CH_ADD_CNT = 6 or CH_ADD_CNT = 7)then  -- BLANK
    --               ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    --               ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     
             if(CURSOR_POS= PAGE1_SHUTDOWN_POS)then -- SHUTTING DOWN
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             elsif(CURSOR_POS= PAGE1_ADVANCE_MENU_POS)then -- ADVANCE MENU
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CURSOR_POS = PAGE1_RETICLE_POS)then -- RETICLE
                if(CURSOR_POS_LY2 = x"00")then
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
----                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
----                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                    if(RETICLE_COLOR="000")then                    
                       ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_7  <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_8  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_9  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_10 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_11 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                       ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
                       ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                      
                    elsif(RETICLE_COLOR ="001")then                   
                       ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_7  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_8  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_10 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_11 <= resize(22*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                       ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
                       ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                      
                    elsif(RETICLE_COLOR ="010")then                    
                       ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_7  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_8  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_10 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_12 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                       ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
                       ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                    elsif(RETICLE_COLOR ="011")then
                       ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_7  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_8  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_10 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_12 <= resize( 4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                       ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
                       ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                           
                    elsif(RETICLE_COLOR ="100")then
                       ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_7  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_8  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_10 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_12 <= resize( 5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                       ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
                       ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
                    else               
                       ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                       ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_8  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_9  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_10 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                       ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
                       ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                      
                    end if;   
                elsif(CURSOR_POS_LY2 = x"01")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                elsif(CURSOR_POS_LY2 = x"02")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                
                elsif(CURSOR_POS_LY2 = x"03")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                
                else
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                end if;    

             elsif(CURSOR_POS = PAGE1_DISPLAY_POS)then  -- DISPLAY
                if(CURSOR_POS_LY2 = x"00")then -- LUX -- BRT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(CURSOR_POS_LY2 = x"01")then   -- GAIN -- CONT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(CURSOR_POS_LY2 = x"02")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                elsif(CURSOR_POS_LY2 = x"03")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                else
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                end if;    

             elsif(CURSOR_POS = PAGE1_LASER_POS)then --LASER
                   if(LASER_EN = 1)then
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   else
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   end if;

             elsif(CURSOR_POS= PAGE1_AGC_POS)then -- AGC
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);      
                   
             elsif(CURSOR_POS = PAGE1_DZOOM_POS)then -- DZOOM
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
             elsif(CURSOR_POS = PAGE1_GAIN_POS)then  -- GAIN --- CONTRAST
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);              
             elsif(CURSOR_POS = PAGE1_BRIGHTNESS_POS)then  -- BRIGHTNESS
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                         
             
             elsif(CURSOR_POS = PAGE1_CALIBRATION_POS)then   -- CALIBRATING
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   --ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
             end if;
         elsif(advance_menu_sel = '1')then          
--             if(CURSOR_POS = PAGE2_FIRING_POS)then -- FIRING
--                if(CURSOR_POS_LY2 = x"00")then  -- MODE
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
----                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
----                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
--                elsif(CURSOR_POS_LY2 = x"01")then -- DISTANCE
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_6  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
----                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                else
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
----                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
--                end if;     
             if(CURSOR_POS = PAGE2_STANDBY_POS)then -- STANDBY
                  if (STANDBY_EN = "1")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                  else
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                   
                  end if;
             elsif(CURSOR_POS = PAGE2_SETTINGS_POS)then -- SETTINGS
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             elsif(CURSOR_POS= PAGE2_SNAPSHOT_POS)then -- SNAPSHOT  
--                if(CURSOR_POS_LY2 = x"02")then
--                   ADDR_CH_1  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);               
--                else
                  if(snapshot_sel = "00" or snapshot_sel = "01")then
                   ADDR_CH_1  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_11 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   if(snapshot_sel = "01")then
                    ADDR_CH_13 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                    ADDR_CH_14 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                    ADDR_CH_15 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                    ADDR_CH_16 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                    ADDR_CH_17 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   else
                    ADDR_CH_13 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   end if;
                  else
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_2  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_10 <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_13 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                                  
                  end if; 
--                end if;       

                                                                       
             elsif(CURSOR_POS = PAGE2_BPR_POS)then --BPR
                if(CURSOR_POS_LY2 = x"00")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(CURSOR_POS_LY2 = x"01")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                elsif(CURSOR_POS_LY2 = x"02")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(22*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                elsif(CURSOR_POS_LY2 = x"03")then
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                else 
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                end if;    

             elsif(CURSOR_POS = PAGE2_COMPASS_POS)then --COMPASS
               if(CURSOR_POS_LY2 = x"00")then -- CONTROL
                   if(GYRO_DATA_DISP_EN = 1)then
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   else
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   end if;                 

                elsif(CURSOR_POS_LY2 = x"01")then -- START CALIB
                     ADDR_CH_1  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                     ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize( 5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                     ADDR_CH_15 <= resize( 8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     
--               elsif(CURSOR_POS_LY2 = x"02")then  -- LOCATION
--                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_2  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_5  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_6  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_7  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_8  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_9  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--  --                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--  --                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--  --                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--  --                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
                else  -- EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
                end if;              

             elsif(CURSOR_POS = PAGE2_BIT_POS)then -- BIT POSITION
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  


             elsif(CURSOR_POS = PAGE2_GALLERY_POS)then -- GALLERY
--               if(CURSOR_POS_LY2 = x"02")then
                   ADDR_CH_1  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                    
--                else
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                    
--                end if;        

             elsif(CURSOR_POS = PAGE2_NUC_ADVANCE_POS)then --NUC ADVANCE
                if(CURSOR_POS_LY2 = x"00")then    -- NUC MODE
                   if(NUC_MODE = "10")then  --- Manual
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   elsif(NUC_MODE = "01")then -- SEMI-SHUTTER
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   else  -- SHUTTERLESS
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_14 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   end if;           
--                elsif(CURSOR_POS_LY2 = x"01")then      -- BLADE MODE
--                   if(BLADE_MODE = "11")then  --- MANUAL
--                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_6  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_8  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_9  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_10 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   elsif(BLADE_MODE = "10")then -- TIME
--                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_7  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_8  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_9  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_10 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   elsif(BLADE_MODE = "01")then -- TEMPERATURE
--                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_6  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_7  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_8  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_9  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_10 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_11 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_12 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_13 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_14 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   else -- DISABLE  
--                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_6  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_7  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_8  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_10 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_12 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                     ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                                      
--                   end if;                           
--                elsif(CURSOR_POS_LY2 = x"03")then  -- BIT
--                   ADDR_CH_1  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_12 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
                else                                                      -- EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                end if; 

             elsif(CURSOR_POS = PAGE2_AGC_ADVANCE_POS)then --AGC ADVANCE
                if(CURSOR_POS_LY2 = x"00")then    -- MAX LIMITER DPHE  -- AGC0 GAIN
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                
                elsif(CURSOR_POS_LY2 = x"01")then  -- CNTRL MAX GAIN (Linear Hist / CS) -- AGC1 GAIN
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                elsif(CURSOR_POS_LY2 = x"02")then   -- CNTRL IPP (Linear Hist / Contrast Stretch) -- AGC1 OFFSET
                   ADDR_CH_1  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                elsif(CURSOR_POS_LY2 = x"03")then      -- DPHAE PARAM2  -- AGC-2 GAIN
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                else                                                      -- EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
                end if;    

             --elsif(CURSOR_POS = PAGE2_DISPLAY_MODE_POS)then -- DISPLAY MODE: INTERNAL DISPLAY / EXTERNAL DISPLAY
             --      if(DISPLAY_MODE = 1)then 
             --        ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_9  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_11 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_12 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_13 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_14 <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_15 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_16 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_17 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
             --      else
             --        ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_2  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_3  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_9  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_11 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_12 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_13 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_14 <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_15 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_16 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --        ADDR_CH_17 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      end if;           
             elsif(CURSOR_POS = PAGE2_SIGHT_CONFIG_POS)then  -- SIGHT CONFIG
                   if(CURSOR_POS_LY2 = x"00")then -- DISPLAY MODE: INTERNAL DISPLAY / EXTERNAL DISPLAY
                       if(DISPLAY_MODE = 1)then 
                         ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_9  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_11 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_12 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_13 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_14 <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_15 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_16 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_17 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                       else
                         ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_2  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_3  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_9  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_11 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_12 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_13 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_14 <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_15 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_16 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_17 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       end if;  
                    elsif(CURSOR_POS_LY2 = x"01")then -- SIGHT MODE : -Stand-alone / Clip-on  /Helmet 
                       if(SIGHT_MODE = 2)then -- HELMET
                         ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_6  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_7  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_8  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_9  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_10 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_11 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                       elsif(SIGHT_MODE = 1)then --Clip-on
                         ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_6  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_7  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_8  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_9  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_10 <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_11 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_12 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       else                      -- Stand-alone
                         ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_6  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_8  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_9  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_10 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_12 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_13 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_14 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                         ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                       end if;                      
                    end if;

            elsif(CURSOR_POS = PAGE2_IMG_ENHANCE_POS)then --IMG ENHANCEMENT
               if(CURSOR_POS_LY2 = x"00")then -- SMOOTHING
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                  

                elsif(CURSOR_POS_LY2 = x"01")then -- SHARPNESS
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
  --                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     
               elsif(CURSOR_POS_LY2 = x"02")then  -- SOFTNUC
                     ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_4  <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_6  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_7  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_8  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                     ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
  --                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
                else  -- EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
                end if;

            end if;
        end if;   
                                     
     elsif(ly2_sel = '1')then
         if(main_menu_sel = '1')then
             if(CURSOR_POS = PAGE1_SHUTDOWN_POS)then -- SHUTDOWN
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_19 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
             elsif(CURSOR_POS = PAGE1_ADVANCE_MENU_POS)then -- ADV MENU
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_18 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_27 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  

             elsif(CURSOR_POS = PAGE1_RETICLE_POS)then  -- RETICLE
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_5  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_6  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_12 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
                   ADDR_CH_22 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize(37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_36 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CURSOR_POS = PAGE1_DISPLAY_POS)then  -- DISPLAY
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     
 
             elsif(CURSOR_POS = PAGE1_LASER_POS)then -- LASER
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_2  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   

             elsif(CURSOR_POS = PAGE1_AGC_POS)then -- AGC
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_17 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
    
             elsif(CURSOR_POS = PAGE1_DZOOM_POS)then -- DZOOM
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize(37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       

             elsif(CURSOR_POS = PAGE1_GAIN_POS)then  -- GAIN
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_15 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
             
             elsif(CURSOR_POS = PAGE1_BRIGHTNESS_POS)then  -- BRIGHTNESS
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                         
             
             elsif(CURSOR_POS = PAGE1_CALIBRATION_POS) then  -- CALIBRATION
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                  
             end if;
         elsif(advance_menu_sel = '1')then
--             if(CURSOR_POS = PAGE2_FIRING_POS)then  -- FIRING
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_3  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_4  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_5  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_10 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_15 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_16 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
--                   ADDR_CH_19 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_20 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_21 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_22 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_25 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_26 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   if(RETICLE_OFFSET_H(8) = '1')then
--                    ADDR_CH_28  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   else
--                    ADDR_CH_28  <= resize(38*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   end if;                                       
--                   if(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4)= x"0" and BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"0")then
--                      if(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"0")then              
--                          ADDR_CH_29 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"1")then 
--                          ADDR_CH_29 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"2")then
--                          ADDR_CH_29 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"3")then 
--                          ADDR_CH_29 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"4")then
--                          ADDR_CH_29 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"5")then
--                          ADDR_CH_29 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"6")then
--                          ADDR_CH_29 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"7")then
--                          ADDR_CH_29 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"8")then
--                          ADDR_CH_29 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"9")then 
--                          ADDR_CH_29 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      else
--                          ADDR_CH_29 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      end if;        
--                      ADDR_CH_30 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      ADDR_CH_31 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   elsif (BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"0")then
--                      if(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"0")then              
--                          ADDR_CH_30 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"1")then 
--                          ADDR_CH_30 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"2")then
--                          ADDR_CH_30 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"3")then 
--                          ADDR_CH_30 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"4")then
--                          ADDR_CH_30 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"5")then
--                          ADDR_CH_30 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"6")then
--                          ADDR_CH_30 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"7")then
--                          ADDR_CH_30 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"8")then
--                          ADDR_CH_30 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"9")then 
--                          ADDR_CH_30 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      else
--                          ADDR_CH_30 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      end if;
          
--                      if(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"0")then
--                          ADDR_CH_29 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"1")then 
--                          ADDR_CH_29 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"2")then
--                          ADDR_CH_29 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"3")then 
--                          ADDR_CH_29 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"4")then
--                          ADDR_CH_29 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"5")then
--                          ADDR_CH_29 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"6")then
--                          ADDR_CH_29 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"7")then
--                          ADDR_CH_29 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"8")then
--                          ADDR_CH_29 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"9")then 
--                          ADDR_CH_29 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      else
--                          ADDR_CH_29 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      end if;         
--                      ADDR_CH_31 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
--                   else
--                      if(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"0")then              
--                          ADDR_CH_31 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"1")then 
--                          ADDR_CH_31 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"2")then
--                          ADDR_CH_31 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"3")then 
--                          ADDR_CH_31 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"4")then
--                          ADDR_CH_31 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"5")then
--                          ADDR_CH_31 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"6")then
--                          ADDR_CH_31 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"7")then
--                          ADDR_CH_31 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"8")then
--                          ADDR_CH_31 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(3 downto 0) = x"9")then 
--                          ADDR_CH_31 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      else
--                          ADDR_CH_31 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      end if;
                
--                      if(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"1")then 
--                          ADDR_CH_30 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"2")then
--                          ADDR_CH_30 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"3")then 
--                          ADDR_CH_30 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"4")then
--                          ADDR_CH_30 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"5")then
--                          ADDR_CH_30 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"6")then
--                          ADDR_CH_30 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"7")then
--                          ADDR_CH_30 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"8")then
--                          ADDR_CH_30 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(7 downto 4) = x"9")then 
--                          ADDR_CH_30 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      else
--                          ADDR_CH_30 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      end if;
                      
--                      if(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8)= x"1")then 
--                          ADDR_CH_29 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"2")then
--                          ADDR_CH_29 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"3")then 
--                          ADDR_CH_29 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"4")then
--                          ADDR_CH_29 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"5")then
--                          ADDR_CH_29 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"6")then
--                          ADDR_CH_29 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"7")then
--                          ADDR_CH_29 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"8")then
--                          ADDR_CH_29 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_RETICLE_OFFSET_H_D(11 downto 8) = x"9")then 
--                          ADDR_CH_29 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      else
--                          ADDR_CH_29 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      end if;                          
--                   end if;                       
--                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_33 <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   ADDR_CH_34 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   if(RETICLE_OFFSET_V(8) = '1')then
--                    ADDR_CH_36  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   else
--                    ADDR_CH_36  <= resize(38*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   end if;                    
----                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
----                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   if(BCD_DATA_D(7 downto 4)= x"0" and BCD_DATA_D(11 downto 8) = x"0")then
--                      if(BCD_DATA_D(3 downto 0) = x"0")then              
--                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"1")then 
--                          ADDR_CH_37 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(3 downto 0) = x"2")then
--                          ADDR_CH_37 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"3")then 
--                          ADDR_CH_37 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(3 downto 0) = x"4")then
--                          ADDR_CH_37 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"5")then
--                          ADDR_CH_37 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"6")then
--                          ADDR_CH_37 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"7")then
--                          ADDR_CH_37 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"8")then
--                          ADDR_CH_37 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"9")then 
--                          ADDR_CH_37 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      else
--                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      end if;        
--                      ADDR_CH_38 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      ADDR_CH_39 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                   elsif (BCD_DATA_D(11 downto 8) = x"0")then
--                      if(BCD_DATA_D(3 downto 0) = x"0")then              
--                          ADDR_CH_38 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"1")then 
--                          ADDR_CH_38 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(3 downto 0) = x"2")then
--                          ADDR_CH_38 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"3")then 
--                          ADDR_CH_38 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(3 downto 0) = x"4")then
--                          ADDR_CH_38 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(3 downto 0) = x"5")then
--                          ADDR_CH_38 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"6")then
--                          ADDR_CH_38 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"7")then
--                          ADDR_CH_38 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"8")then
--                          ADDR_CH_38 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"9")then 
--                          ADDR_CH_38 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      else
--                          ADDR_CH_38 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      end if;
          
--                      if(BCD_DATA_D(7 downto 4) = x"0")then
--                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
--                      elsif(BCD_DATA_D(7 downto 4) = x"1")then 
--                          ADDR_CH_37 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"2")then
--                          ADDR_CH_37 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"3")then 
--                          ADDR_CH_37 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"4")then
--                          ADDR_CH_37 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"5")then
--                          ADDR_CH_37 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_D(7 downto 4) = x"6")then
--                          ADDR_CH_37 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"7")then
--                          ADDR_CH_37 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"8")then
--                          ADDR_CH_37 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"9")then 
--                          ADDR_CH_37 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      else
--                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      end if;         
--                      ADDR_CH_39 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
--                   else
--                      if(BCD_DATA_D(3 downto 0) = x"0")then              
--                          ADDR_CH_39 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"1")then 
--                          ADDR_CH_39 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(3 downto 0) = x"2")then
--                          ADDR_CH_39 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"3")then 
--                          ADDR_CH_39 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(3 downto 0) = x"4")then
--                          ADDR_CH_39 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(3 downto 0) = x"5")then
--                          ADDR_CH_39 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(3 downto 0) = x"6")then
--                          ADDR_CH_39 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_D(3 downto 0) = x"7")then
--                          ADDR_CH_39 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_D(3 downto 0) = x"8")then
--                          ADDR_CH_39 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_D(3 downto 0) = x"9")then 
--                          ADDR_CH_39 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      else
--                          ADDR_CH_39 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      end if;
                
--                      if(BCD_DATA_D(7 downto 4) = x"1")then 
--                          ADDR_CH_38 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(7 downto 4) = x"2")then
--                          ADDR_CH_38 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(7 downto 4) = x"3")then 
--                          ADDR_CH_38 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(7 downto 4) = x"4")then
--                          ADDR_CH_38 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"5")then
--                          ADDR_CH_38 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"6")then
--                          ADDR_CH_38 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(7 downto 4) = x"7")then
--                          ADDR_CH_38 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(7 downto 4) = x"8")then
--                          ADDR_CH_38 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(7 downto 4) = x"9")then 
--                          ADDR_CH_38 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      else
--                          ADDR_CH_38 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      end if;
                      
--                      if(BCD_DATA_D(11 downto 8)= x"1")then 
--                          ADDR_CH_37 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(11 downto 8) = x"2")then
--                          ADDR_CH_37 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_D(11 downto 8) = x"3")then 
--                          ADDR_CH_37 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(11 downto 8) = x"4")then
--                          ADDR_CH_37 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                      elsif(BCD_DATA_D(11 downto 8) = x"5")then
--                          ADDR_CH_37 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(11 downto 8) = x"6")then
--                          ADDR_CH_37 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(11 downto 8) = x"7")then
--                          ADDR_CH_37 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      elsif(BCD_DATA_D(11 downto 8) = x"8")then
--                          ADDR_CH_37 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                      elsif(BCD_DATA_D(11 downto 8) = x"9")then 
--                          ADDR_CH_37 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      else
--                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--                      end if;                          
--                   end if;    
--                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                      
                   
             if(CURSOR_POS = PAGE2_STANDBY_POS)then -- STANDBY
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
             elsif(CURSOR_POS = PAGE2_SETTINGS_POS)then -- SETTINGS
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_17 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_26 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                       

             elsif(CURSOR_POS = PAGE2_SNAPSHOT_POS)then -- SNAPSHOT SINGLE, BURST, EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_5  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_6  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_7  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_8  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_9  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
                   ADDR_CH_21 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_22 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_23 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_24 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_35 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_37 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);

             elsif(CURSOR_POS = PAGE2_BPR_POS)then --BPR
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize(37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_19 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_20 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_21 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_22 <= resize(22*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_27 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_28 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_29 <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                    

             elsif(CURSOR_POS = PAGE2_COMPASS_POS)then -- CONTROL , START CALIB , LOCATION, EXIT
                   --ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_3  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_4  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_5  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_6  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_7  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_8  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_9  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_10 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_11 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   --ADDR_CH_12 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_13 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_14 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_15 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_16 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_17 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_18 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_19 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_20 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_21 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_22 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                     
                   --ADDR_CH_23 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_24 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_25 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_26 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_27 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_28 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_29 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_30 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_31 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
                   --ADDR_CH_32 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_33 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   --ADDR_CH_34 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_35 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_36 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_37 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_38 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   --ADDR_CH_39 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   --ADDR_CH_40 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);             
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_5  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_17 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                     
                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_33 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CURSOR_POS = PAGE2_BIT_POS)then -- STATUS EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                     
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             elsif(CURSOR_POS = PAGE2_GALLERY_POS)then -- GALLERY
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_2  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_14 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_20 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_28 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_33 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   if(BCD_DATA_D(7 downto 4)= x"0" and BCD_DATA_D(11 downto 8) = x"0")then
                      if(BCD_DATA_D(3 downto 0) = x"0")then              
                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"1")then 
                          ADDR_CH_37 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(3 downto 0) = x"2")then
                          ADDR_CH_37 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"3")then 
                          ADDR_CH_37 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(3 downto 0) = x"4")then
                          ADDR_CH_37 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"5")then
                          ADDR_CH_37 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"6")then
                          ADDR_CH_37 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"7")then
                          ADDR_CH_37 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"8")then
                          ADDR_CH_37 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"9")then 
                          ADDR_CH_37 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      else
                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      end if;        
                      ADDR_CH_38 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      ADDR_CH_39 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   elsif (BCD_DATA_D(11 downto 8) = x"0")then
                      if(BCD_DATA_D(3 downto 0) = x"0")then              
                          ADDR_CH_38 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"1")then 
                          ADDR_CH_38 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(3 downto 0) = x"2")then
                          ADDR_CH_38 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"3")then 
                          ADDR_CH_38 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(3 downto 0) = x"4")then
                          ADDR_CH_38 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(3 downto 0) = x"5")then
                          ADDR_CH_38 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"6")then
                          ADDR_CH_38 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"7")then
                          ADDR_CH_38 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"8")then
                          ADDR_CH_38 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"9")then 
                          ADDR_CH_38 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      else
                          ADDR_CH_38 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      end if;
          
                      if(BCD_DATA_D(7 downto 4) = x"0")then
                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
                      elsif(BCD_DATA_D(7 downto 4) = x"1")then 
                          ADDR_CH_37 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"2")then
                          ADDR_CH_37 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"3")then 
                          ADDR_CH_37 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"4")then
                          ADDR_CH_37 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"5")then
                          ADDR_CH_37 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                      elsif(BCD_DATA_D(7 downto 4) = x"6")then
                          ADDR_CH_37 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"7")then
                          ADDR_CH_37 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"8")then
                          ADDR_CH_37 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"9")then 
                          ADDR_CH_37 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      else
                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      end if;         
                      ADDR_CH_39 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
                   else
                      if(BCD_DATA_D(3 downto 0) = x"0")then              
                          ADDR_CH_39 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"1")then 
                          ADDR_CH_39 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(3 downto 0) = x"2")then
                          ADDR_CH_39 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"3")then 
                          ADDR_CH_39 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(3 downto 0) = x"4")then
                          ADDR_CH_39 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(3 downto 0) = x"5")then
                          ADDR_CH_39 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(3 downto 0) = x"6")then
                          ADDR_CH_39 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                      elsif(BCD_DATA_D(3 downto 0) = x"7")then
                          ADDR_CH_39 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                      elsif(BCD_DATA_D(3 downto 0) = x"8")then
                          ADDR_CH_39 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                      elsif(BCD_DATA_D(3 downto 0) = x"9")then 
                          ADDR_CH_39 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      else
                          ADDR_CH_39 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                      end if;
                
                      if(BCD_DATA_D(7 downto 4) = x"1")then 
                          ADDR_CH_38 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(7 downto 4) = x"2")then
                          ADDR_CH_38 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(7 downto 4) = x"3")then 
                          ADDR_CH_38 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(7 downto 4) = x"4")then
                          ADDR_CH_38 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"5")then
                          ADDR_CH_38 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"6")then
                          ADDR_CH_38 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(7 downto 4) = x"7")then
                          ADDR_CH_38 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(7 downto 4) = x"8")then
                          ADDR_CH_38 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(7 downto 4) = x"9")then 
                          ADDR_CH_38 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      else
                          ADDR_CH_38 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      end if;
                      
                      if(BCD_DATA_D(11 downto 8)= x"1")then 
                          ADDR_CH_37 <= resize(3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(11 downto 8) = x"2")then
                          ADDR_CH_37 <= resize(4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                      elsif(BCD_DATA_D(11 downto 8) = x"3")then 
                          ADDR_CH_37 <= resize(5*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(11 downto 8) = x"4")then
                          ADDR_CH_37 <= resize(6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                      elsif(BCD_DATA_D(11 downto 8) = x"5")then
                          ADDR_CH_37 <= resize(7*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(11 downto 8) = x"6")then
                          ADDR_CH_37 <= resize(8*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(11 downto 8) = x"7")then
                          ADDR_CH_37 <= resize(9*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      elsif(BCD_DATA_D(11 downto 8) = x"8")then
                          ADDR_CH_37 <= resize(10*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                      elsif(BCD_DATA_D(11 downto 8) = x"9")then 
                          ADDR_CH_37 <= resize(11*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      else
                          ADDR_CH_37 <= resize(2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                      end if;                          
                   end if;                       
--                   ADDR_CH_37 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_38 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  

             elsif(CURSOR_POS = PAGE2_NUC_ADVANCE_POS)then -- MODE , BLADE , ADV-CALIB, BIT, EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_13 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_14 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                     
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);              
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_19 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_20 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_21 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_22 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_23 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                     
--                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
--                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_36 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_37 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_38 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_39 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_12 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_13 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_14 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_18 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_19 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_20 <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_21 <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_22 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_23 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                     
--                   ADDR_CH_24 <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_25 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_26 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_30 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_31 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_32 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
--                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_36 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_37 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_38 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--                   ADDR_CH_39 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
             elsif(CURSOR_POS = PAGE2_AGC_ADVANCE_POS)then --AGC ADVANCE
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 2*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_11 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_12 <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_13 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_14 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_15 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_16 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_18 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_19 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_20 <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                   
                   ADDR_CH_28 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize( 4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize(39*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_31 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                                     
                   ADDR_CH_36 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
             --elsif(CURSOR_POS = PAGE2_DISPLAY_MODE_POS)then -- DISPLAY MODE
             --      ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
             --      ADDR_CH_2  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_3  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_5  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_6  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_8  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_9  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_11 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
             --      ADDR_CH_12 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_13 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_14 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
             --      ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_22 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_23 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
             --      ADDR_CH_26 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_27 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_28 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_29 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_35 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_36 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_37 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   

             elsif(CURSOR_POS = PAGE2_SIGHT_CONFIG_POS)then -- SIGHT CONFIG : DISPLAY MODE/ SIGHT MODE /EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_16 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_24 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

    
             elsif(CURSOR_POS = PAGE2_IMG_ENHANCE_POS)then -- SMOOTHING , SHARPNESS , SOFTNUC, EXIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_15 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_16 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_17 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_18 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_19 <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_20 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_21 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_22 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_23 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                     
                   ADDR_CH_24 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_25 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_26 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_27 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_28 <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_29 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_30 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_31 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_32 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);          
                   ADDR_CH_33 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_34 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_35 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_36 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_37 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_38 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_39 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_40 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                     
             end if;
         end if;    

     else
         if(main_menu_sel = '1')then
             if(CH_ADD_CNT = PAGE1_SHUTDOWN_POS)then -- SHUTDOWN
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CH_ADD_CNT = PAGE1_ADVANCE_MENU_POS)then -- ADVANCE MENU
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CH_ADD_CNT = PAGE1_RETICLE_POS)then  -- RETICLE
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       

             elsif(CH_ADD_CNT = PAGE1_DISPLAY_POS)then  -- DISPLAY
                   ADDR_CH_1  <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    
             elsif(CH_ADD_CNT = PAGE1_LASER_POS)then -- LASER
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);


             elsif(CH_ADD_CNT = PAGE1_AGC_POS)then -- AGC
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    
             elsif(CH_ADD_CNT = PAGE1_DZOOM_POS)then -- DZOOM
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize( 15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize( 37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize( 26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CH_ADD_CNT = PAGE1_GAIN_POS)then  -- GAIN -- CONTRAST
                   ADDR_CH_1  <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CH_ADD_CNT = PAGE1_BRIGHTNESS_POS)then  -- BRIGHTNESS
                   ADDR_CH_1  <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             
             elsif(CH_ADD_CNT = PAGE1_CALIBRATION_POS)then  -- NUC CALIB --1PT --CALIBRATION
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             end if;   
         elsif(advance_menu_sel= '1')then 
--             if(CH_ADD_CNT = PAGE2_FIRING_POS)then  -- FIRING
--                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_2  <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_3  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_5  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_6  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_7  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);              
             if(CH_ADD_CNT = PAGE2_STANDBY_POS)then --STANDBY
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                  

             elsif(CH_ADD_CNT = PAGE2_SETTINGS_POS)then -- SETTINGS
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CH_ADD_CNT = PAGE2_SNAPSHOT_POS)then -- SNAPSHOT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);

             elsif(CH_ADD_CNT = PAGE2_BPR_POS)then --BPR
                   ADDR_CH_1  <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CH_ADD_CNT = PAGE2_COMPASS_POS)then --COMPASS
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                   

             elsif(CH_ADD_CNT = PAGE2_BIT_POS)then --BIT
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                   


             elsif(CH_ADD_CNT = PAGE2_GALLERY_POS)then --GALLERY
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_3  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 


             elsif(CH_ADD_CNT = PAGE2_NUC_ADVANCE_POS)then --NUC ADVACNE
                   ADDR_CH_1  <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(32*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             elsif(CH_ADD_CNT = PAGE2_AGC_ADVANCE_POS)then --AGC ADVACNE
                   ADDR_CH_1  <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
                   ADDR_CH_12 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   
             --elsif(CH_ADD_CNT = PAGE2_DISPLAY_MODE_POS)then -- DISPLAY MODE
             --      ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_2  <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_3  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_4  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_5  <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_6  <= resize(23*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_7  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_8  <= resize(36*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_9  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_10 <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_11 <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_12 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_13 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             --      ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);

             elsif(CH_ADD_CNT = PAGE2_SIGHT_CONFIG_POS)then -- SIGHT CONFIG
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(17*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);

             elsif(CH_ADD_CNT = PAGE2_IMG_ENHANCE_POS)then --IMG_ENHANCE
                   ADDR_CH_1  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_2  <= resize(20*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_3  <= resize(24*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_4  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_5  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_6  <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_7  <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_8  <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_9  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_10 <= resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_11 <= resize(14*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_12 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                   ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 

             end if;
         end if;
       end if;                     
--     end if;

     if(ly3_sel = '1')then
      POS_X_OSD      <= LATCH_OSD_POS_X_LY3;
      POS_Y_OSD      <= LATCH_OSD_POS_Y_LY3;
      POS_Y_CH_1_LY3 <= (unsigned(LATCH_OSD_POS_Y_LY3)) ;  
      POS_X_CH_1_LY3 <= (unsigned(LATCH_OSD_POS_X_LY3) + to_unsigned(4,POS_X_CH_1_LY3'length));  
      OSD_REQ_XSIZE  <= LATCH_OSD_REQ_XSIZE_LY3;                           
     elsif(ly2_sel = '1')then
      POS_X_OSD      <= LATCH_OSD_POS_X_LY2;
      POS_Y_OSD      <= LATCH_OSD_POS_Y_LY2;
      POS_Y_CH_1_LY2 <= (unsigned(LATCH_OSD_POS_Y_LY2)) ;  
      POS_X_CH_1_LY2 <= (unsigned(LATCH_OSD_POS_X_LY2) + to_unsigned(4,POS_X_CH_1_LY2'length));  
      OSD_REQ_XSIZE  <= LATCH_OSD_REQ_XSIZE_LY2;       
     else
      POS_X_OSD      <= LATCH_OSD_POS_X_LY1;
      POS_Y_OSD      <= LATCH_OSD_POS_Y_LY1;
      POS_Y_CH_1_LY1 <= (unsigned(LATCH_OSD_POS_Y_LY1)) ;
      POS_X_CH_1_LY1 <= (unsigned(LATCH_OSD_POS_X_LY1) + to_unsigned(4,POS_X_CH_1_LY1'length)); 
      OSD_REQ_XSIZE  <= LATCH_OSD_REQ_XSIZE_LY1; 
     end if; 


     if OSD_REQ_V = '1' then
        CH_ROM_RDFSM <= s_IDLE; 
        CH_ADD_CNT   <= (others=>'0');
        if(OSD_FIELD = '0')then                                                                       
--           OSD_EN_D <= OSD_EN;
           latch_menu_timeout_cnt  <= menu_timeout_cnt; 
           if(STANDBY_EN = "0")then
               LATCH_MENU_SEL_CENTER   <= MENU_SEL_CENTER_TRIG ;
               LATCH_MENU_SEL_UP       <= MENU_SEL_UP_TRIG;
               LATCH_MENU_SEL_DN       <= MENU_SEL_DN_TRIG; 
           else
               LATCH_MENU_SEL_CENTER   <= '0';
               LATCH_MENU_SEL_UP       <= '0';
               LATCH_MENU_SEL_DN       <= '0';
           end if;    
           
           if(STANDBY_EN = "1")then
             if(MENU_SEL_CENTER_TRIG = '1' or  MENU_SEL_UP_TRIG = '1' or  MENU_SEL_DN_TRIG = '1')then
                STANDBY_EN <= to_unsigned(0,STANDBY_EN'length);
                STANDBY_EN_VALID <= '1';
             end if;           
           end if;    
           gyro_calib_done_latch      <= gyro_calib_done_trig;
           LATCH_ADVANCE_MENU_TRIG    <= ADVANCE_MENU_TRIG;
           snapshot_save_done_latch   <= snapshot_save_done_trig;
           snapshot_delete_done_latch <= snapshot_delete_done_trig;

           if(gyro_calib_done = '1')then
            gyro_calib_done_trig <= '1';
           else
            gyro_calib_done_trig <= '0';
           end if;

           if(snapshot_save_done = '1' or GALLERY_FULL_DISP_OFF = '1')then
            snapshot_save_done_trig <= '1';
           else
            snapshot_save_done_trig <= '0';
           end if;
           
           if(snapshot_delete_done = '1')then
            snapshot_delete_done_trig <= '1';
           else
            snapshot_delete_done_trig <= '0';
           end if;
           
           if(MENU_SEL_CENTER = '1')then
            MENU_SEL_CENTER_TRIG    <= '1';
           else
            MENU_SEL_CENTER_TRIG    <= '0';
           end if;
           if(MENU_SEL_UP = '1')then
            MENU_SEL_UP_TRIG        <= '1';
           else
            MENU_SEL_UP_TRIG        <= '0';
           end if;
           if(MENU_SEL_DN = '1')then
            MENU_SEL_DN_TRIG      <= '1';
           else
            MENU_SEL_DN_TRIG      <= '0';
           end if;
           if(ADVANCE_MENU_TRIG_IN= '1')then
            ADVANCE_MENU_TRIG      <= '1';
           else
            ADVANCE_MENU_TRIG      <= '0';
           end if;

           LATCH_OSD_POS_X_LY1     <= OSD_POS_X_LY1;
           LATCH_OSD_POS_Y_LY1     <= OSD_POS_Y_LY1;
           LATCH_OSD_POS_X_LY2     <= OSD_POS_X_LY2;
           LATCH_OSD_POS_Y_LY2     <= OSD_POS_Y_LY2;
           LATCH_OSD_POS_X_LY3     <= OSD_POS_X_LY3;
           LATCH_OSD_POS_Y_LY3     <= OSD_POS_Y_LY3;
           LATCH_OSD_REQ_XSIZE_LY1 <= OSD_REQ_XSIZE_LY1;
           LATCH_OSD_REQ_XSIZE_LY2 <= OSD_REQ_XSIZE_LY2;
           LATCH_OSD_REQ_XSIZE_LY3 <= OSD_REQ_XSIZE_LY3;
           LATCH_OSD_COLOR_INFO1   <= OSD_COLOR_INFO1;
           LATCH_CH_COLOR_INFO1    <= CH_COLOR_INFO1;
           LATCH_CH_COLOR_INFO2    <= CH_COLOR_INFO2;
           LATCH_CURSOR_COLOR_INFO <= CURSOR_COLOR_INFO;    
           CH_ROM_ADDR_PICT        <= to_unsigned(0,CH_ROM_ADDR_PICT'length);  
           RD_OSD_LIN_NO           <= to_unsigned(0,RD_OSD_LIN_NO'length);  
--           latch_main_menu_sel     <= main_menu_sel;
           latch_hot_key_menu_sel  <= hot_key_menu_sel;
           latch_menu_timeout_cnt <=  menu_timeout_cnt;
--           latch_page_cnt          <= page_cnt;
        else
--           OSD_EN_D               <= OSD_EN_D;
           LATCH_OSD_POS_X_LY1     <= LATCH_OSD_POS_X_LY1;
           LATCH_OSD_POS_Y_LY1     <= LATCH_OSD_POS_Y_LY1;
           LATCH_OSD_POS_X_LY2     <= LATCH_OSD_POS_X_LY2;
           LATCH_OSD_POS_Y_LY2     <= LATCH_OSD_POS_Y_LY2;
           LATCH_OSD_POS_X_LY3     <= LATCH_OSD_POS_X_LY3;
           LATCH_OSD_POS_Y_LY3     <= LATCH_OSD_POS_Y_LY3;
           LATCH_OSD_REQ_XSIZE_LY1 <= LATCH_OSD_REQ_XSIZE_LY1;
           LATCH_OSD_REQ_XSIZE_LY2 <= LATCH_OSD_REQ_XSIZE_LY2;
           LATCH_OSD_REQ_XSIZE_LY3 <= LATCH_OSD_REQ_XSIZE_LY3;
           LATCH_OSD_COLOR_INFO1   <= LATCH_OSD_COLOR_INFO1;
           LATCH_CH_COLOR_INFO1    <= LATCH_CH_COLOR_INFO1;
           LATCH_CH_COLOR_INFO2    <= LATCH_CH_COLOR_INFO2;
           LATCH_CURSOR_COLOR_INFO <= LATCH_CURSOR_COLOR_INFO;
           RD_OSD_LIN_NO           <= to_unsigned(0,RD_OSD_LIN_NO'length);
           CH_ROM_ADDR_PICT        <= to_unsigned(0,CH_ROM_ADDR_PICT'length);
--           latch_main_menu_sel     <= latch_main_menu_sel;
--           latch_page_cnt         <= latch_page_cnt;

           if(gyro_calib_done = '1')then
            gyro_calib_done_trig <= '1';
           end if;
           if(snapshot_save_done = '1' or GALLERY_FULL_DISP_OFF = '1')then
            snapshot_save_done_trig <= '1';
           end if;
           if(snapshot_delete_done = '1')then
            snapshot_delete_done_trig <= '1';
           end if;
           if(MENU_SEL_CENTER = '1')then
            MENU_SEL_CENTER_TRIG <= '1';
           end if;
           if(MENU_SEL_UP = '1')then
            MENU_SEL_UP_TRIG     <= '1';
           end if;
           if(MENU_SEL_DN = '1')then
            MENU_SEL_DN_TRIG     <= '1';
           end if;   
           
           if(ADVANCE_MENU_TRIG_IN ='1')then
            ADVANCE_MENU_TRIG <= '1';
           end if;
           
                  
       end if;
      else   
          if(gyro_calib_done = '1')then
           gyro_calib_done_trig <= '1';
          end if;
          if(snapshot_save_done = '1' or GALLERY_FULL_DISP_OFF = '1')then
           snapshot_save_done_trig <= '1';
          end if;
          if(snapshot_delete_done = '1')then
           snapshot_delete_done_trig <= '1';
          end if;
          if(MENU_SEL_CENTER = '1')then
           MENU_SEL_CENTER_TRIG <= '1'; 
          end if;
          if(MENU_SEL_UP = '1')then
           MENU_SEL_UP_TRIG <= '1'; 
          end if;      
          if(MENU_SEL_DN = '1')then
           MENU_SEL_DN_TRIG <= '1'; 
          end if;   
          if(ADVANCE_MENU_TRIG_IN ='1')then
            ADVANCE_MENU_TRIG <= '1';
          end if;
          
       end if;
   end if;
 end process;


 FIFO_CLR_OSD   <= OSD_REQ_V or OSD_REQ_H_DDDD;

 i_OSD_CH_RDFIFO : entity WORK.FIFO_GENERIC_SC
  generic map (
    FIFO_DEPTH => FIFO_DEPTH,
    FIFO_WIDTH => FIFO_WSIZE,
    SHOW_AHEAD => false      ,
    USE_EAB    => true
  )
  port map (
    CLK    => CLK     ,
    RST    => RST     ,
    CLR    => FIFO_CLR_OSD,
    WRREQ  => FIFO_WR_OSD ,
    WRDATA => FIFO_IN_OSD ,
    FULL   => FIFO_FUL_OSD,
    USEDW  => FIFO_NB_OSD ,
    EMPTY  => FIFO_EMP_OSD,
    RDREQ  => FIFO_RD_OSD ,
    RDDATA => FIFO_OUT_OSD_REV
  ); 
   
gen:    
    for i in 0 to 15 generate
           FIFO_OUT_OSD(i) <=FIFO_OUT_OSD_REV(15-i); 
    end generate;
     
      
  FIFO_WR1  <= VIDEO_IN_DAV;
  FIFO_IN1  <= VIDEO_IN_DATA;
  FIFO_CLR1 <= VIDEO_IN_V;   
    
    
    
  i_OSD_RDFIFO : entity WORK.FIFO_GENERIC_SC
    generic map (
      FIFO_DEPTH => FIFO_DEPTH1,
      FIFO_WIDTH => FIFO_WSIZE1,
      SHOW_AHEAD => false      ,
      USE_EAB    => true
    )
    port map (
      CLK    => CLK     ,
      RST    => RST     ,
      CLR    => FIFO_CLR1,
      WRREQ  => FIFO_WR1 ,
      WRDATA => FIFO_IN1 ,
      FULL   => FIFO_FUL1,
      USEDW  => FIFO_NB1 ,
      EMPTY  => FIFO_EMP1,
      RDREQ  => FIFO_RD1 ,
      RDDATA => FIFO_OUT1
    ); 
        
  
  assert not ( FIFO_FUL_OSD = '1' and FIFO_WR_OSD = '1' )
    report "[MEMORY_TO_SCALER] WRITE in FIFO Full !!!" severity failure;

  process(CLK, RST)
  begin
    if RST = '1' then
      OSD_V             <= '0';
      OSD_V_D           <= '0';
      OSD_DAVi          <= '0';
      FIFO_RD_OSD   <= '0';
      FIFO_RD1          <= '0';
      OSD_DATA          <= (others => '0');
      OSD_H             <= '0';
      OSD_H_D           <= '0';
      OSD_EOI           <= '0';
      OSD_EOI_D         <= '0';
      first_time_rd_rq  <= '1'; 
      FIFO_RD1_CNT      <= 0; 
      FIFO_RD1_CNT_D    <= 0; 
      count             <= 0;
      pix_cnt_d         <= (others => '0');
      OSD_ADD_DONE      <= '0';
      flag              <= '0';
      CH_CNT_FIFO_RD    <= (others=>'0');
      CH_CNT_FIFO_RD_D  <= (others=>'0');
      OSD_LINE_CNT      <= (others=>'0'); 
--      POS_X_CH_D  <= (others=>'0'); 
--      POS_X_CH_DD <= (others=>'0');      
      CH_LIN_CNT_RD     <= (others=>'0');  
      OSD_REQ_V_D       <=  '0';    
      lin_block_cnt     <= (others=>'0'); 
      lin_block_cnt_d   <= (others=>'0'); 
      lin_block_cnt_dd  <= (others=>'0'); 
      add_cursor        <= '0';
      add_cursor_d      <= '0';
      VIDEO_IN_V_D      <= '0';
      VIDEO_IN_V_DD     <= '0';
      VIDEO_IN_V_DDD    <= '0';
      VIDEO_IN_V_DDDD   <= '0';
      VIDEO_IN_H_D      <= '0';
      VIDEO_IN_H_DD     <= '0';
      VIDEO_IN_H_DDD    <= '0';
      VIDEO_IN_H_DDDD   <= '0';  
      OSD_REQ_V_D       <= '0';
      OSD_REQ_V_DD      <= '0';
      OSD_REQ_V_DDD     <= '0';    
      POS_X_CH         <= (others => '0');
      POS_Y_CH          <= (others => '0');
      VIDEO_IN_DATA_D   <= (others => '0'); 
      VIDEO_IN_DATA_DD  <= (others => '0'); 
      VIDEO_IN_DATA_DDD <= (others => '0'); 
      VIDEO_IN_DATA_DDDD<= (others => '0');   
      VIDEO_IN_DAV_D    <= '0'; 
      VIDEO_IN_DAV_DD   <= '0'; 
      VIDEO_IN_DAV_DDD  <= '0'; 
      VIDEO_IN_DAV_DDDD <= '0'; 
      VIDEO_IN_EOI_D    <= '0'; 
      VIDEO_IN_EOI_DD   <= '0'; 
      VIDEO_IN_EOI_DDD  <= '0'; 
      VIDEO_IN_EOI_DDDD <= '0';             
    elsif rising_edge(CLK) then

--      LATCH_POS_Y_CH      <= LATCH_POS_Y_CH_1;
      CH_CNT_FIFO_RD_D <= CH_CNT_FIFO_RD;
      OSD_REQ_V_D      <= OSD_REQ_V;
      OSD_REQ_V_DD     <= OSD_REQ_V_D;
      OSD_REQ_V_DDD    <= OSD_REQ_V_DD;
      VIDEO_IN_V_D     <= VIDEO_IN_V;
      VIDEO_IN_V_DD    <= VIDEO_IN_V_D;
      VIDEO_IN_V_DDD   <= VIDEO_IN_V_DD;
      VIDEO_IN_V_DDDD  <= VIDEO_IN_V_DDD;
      VIDEO_IN_H_D     <= VIDEO_IN_H;
      VIDEO_IN_H_DD    <= VIDEO_IN_H_D;
      VIDEO_IN_H_DDD   <= VIDEO_IN_H_DD;
      VIDEO_IN_H_DDDD  <= VIDEO_IN_H_DDD;
      VIDEO_IN_DAV_D    <= VIDEO_IN_DAV;      
      VIDEO_IN_DAV_DD   <= VIDEO_IN_DAV_D;
      VIDEO_IN_DAV_DDD  <= VIDEO_IN_DAV_DD;
      VIDEO_IN_DAV_DDDD <= VIDEO_IN_DAV_DDD;
      VIDEO_IN_DATA_D   <= VIDEO_IN_DATA;
      VIDEO_IN_DATA_DD  <= VIDEO_IN_DATA_D  ;
      VIDEO_IN_DATA_DDD <= VIDEO_IN_DATA_DD ;
      VIDEO_IN_DATA_DDDD<= VIDEO_IN_DATA_DDD;
      VIDEO_IN_EOI_D    <= VIDEO_IN_EOI   ; 
      VIDEO_IN_EOI_DD   <= VIDEO_IN_EOI_D ;
      VIDEO_IN_EOI_DDD  <= VIDEO_IN_EOI_DD;
      VIDEO_IN_EOI_DDDD <= VIDEO_IN_EOI_DDD;      
      
      add_cursor_d     <= add_cursor;
      if(ly3_sel = '1')then
        add_cursor <= '0';        
      elsif(ly2_sel = '1')then
--        if(menu_option_cnt = FIRING_POS)then
--            if(CURSOR_POS_LY2 = x"00")then
--                if(CH_CNT_FIFO_RD>= x"01" and CH_CNT_FIFO_RD <= x"06")then
--                    add_cursor <= '1';
--                else
--                    add_cursor <= '0';
--                end if;        
--            elsif(CURSOR_POS_LY2 = x"01")then
--                if(CH_CNT_FIFO_RD>= x"07" and CH_CNT_FIFO_RD <= x"10")then
--                    add_cursor <= '1';
--                else
--                    add_cursor <= '0';
--                end if;        
--            elsif(CURSOR_POS_LY2 = x"02")then
--                if(CH_CNT_FIFO_RD>= x"11" and CH_CNT_FIFO_RD <= x"16")then
--                    add_cursor <= '1';
--                else
--                    add_cursor <= '0';
--                end if;
--            end if;      
        if(menu_option_cnt = SNAPSHOT_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"01" and CH_CNT_FIFO_RD <= x"0A")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"11" and CH_CNT_FIFO_RD <= x"19")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
--            elsif(CURSOR_POS_LY2 = x"02")then
--                if(CH_CNT_FIFO_RD>= x"18" and CH_CNT_FIFO_RD <= x"1F")then
--                    add_cursor <= '1';
--                else
--                    add_cursor <= '0';
--                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"20" and CH_CNT_FIFO_RD <= x"28")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;  
            end if;  
        elsif(menu_option_cnt = BIT_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"06" and CH_CNT_FIFO_RD <= x"11")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"18" and CH_CNT_FIFO_RD <= x"21")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 

            end if;  

        elsif(menu_option_cnt = NUC_ADVANCE_POS)then
            if(CURSOR_POS_LY2 = x"00")then
--                if(CH_CNT_FIFO_RD>= x"01" and CH_CNT_FIFO_RD <= x"06")then
                if(CH_CNT_FIFO_RD>= x"09" and CH_CNT_FIFO_RD <= x"0E")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
--            elsif(CURSOR_POS_LY2 = x"01")then
--                if(CH_CNT_FIFO_RD>= x"11" and CH_CNT_FIFO_RD <= x"17")then
--                    add_cursor <= '1';
--                else
--                    add_cursor <= '0';
--                end if; 
--            elsif(CURSOR_POS_LY2 = x"02")then
--                if(CH_CNT_FIFO_RD>= x"10" and CH_CNT_FIFO_RD <= x"1A")then
--                    add_cursor <= '1';
--                else
--                    add_cursor <= '0';
--                end if; 
--            elsif(CURSOR_POS_LY2 = x"03")then
--                if(CH_CNT_FIFO_RD>= x"1C" and CH_CNT_FIFO_RD <= x"20")then
--                    add_cursor <= '1';
--                else
--                    add_cursor <= '0';
--                end if; 
            elsif(CURSOR_POS_LY2 = x"01")then
--                if(CH_CNT_FIFO_RD>= x"22" and CH_CNT_FIFO_RD <= x"27")then
                if(CH_CNT_FIFO_RD>= x"17" and CH_CNT_FIFO_RD <= x"1C")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;  
            end if;                                   
        elsif(menu_option_cnt = AGC_ADVANCE_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"00" and CH_CNT_FIFO_RD <= x"08")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"08" and CH_CNT_FIFO_RD <= x"10")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"10" and CH_CNT_FIFO_RD <= x"1A")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"03")then
                if(CH_CNT_FIFO_RD>= x"1A" and CH_CNT_FIFO_RD <= x"22")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            elsif(CURSOR_POS_LY2 = x"04")then
                if(CH_CNT_FIFO_RD>= x"22" and CH_CNT_FIFO_RD <= x"27")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            end if;       
        elsif(menu_option_cnt = IMG_ENHANCE_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"02" and CH_CNT_FIFO_RD <= x"0C")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"0D" and CH_CNT_FIFO_RD <= x"17")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"18" and CH_CNT_FIFO_RD <= x"20")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"03")then
                if(CH_CNT_FIFO_RD>= x"21" and CH_CNT_FIFO_RD <= x"26")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;  
            end if;      
        elsif(menu_option_cnt = SIGHT_CONFIG_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"02" and CH_CNT_FIFO_RD <= x"0F")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"12" and CH_CNT_FIFO_RD <= x"1D")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"20" and CH_CNT_FIFO_RD <= x"25")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            end if;                              
        elsif(menu_option_cnt = COMPASS_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"03" and CH_CNT_FIFO_RD <= x"0B")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"0F" and CH_CNT_FIFO_RD <= x"1B")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"1F" and CH_CNT_FIFO_RD <= x"24")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;  
            end if; 
        elsif(menu_option_cnt = RETICLE_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"02" and CH_CNT_FIFO_RD <= x"08")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"0a" and CH_CNT_FIFO_RD <= x"0f")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"12" and CH_CNT_FIFO_RD <= x"17")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"03")then
                if(CH_CNT_FIFO_RD>= x"1a" and CH_CNT_FIFO_RD <= x"1f")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"04")then
                if(CH_CNT_FIFO_RD>= x"22" and CH_CNT_FIFO_RD <= x"27")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            end if;
        elsif(menu_option_cnt = DISPLAY_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"02" and CH_CNT_FIFO_RD <= x"06")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"09" and CH_CNT_FIFO_RD <= x"0e")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"11" and CH_CNT_FIFO_RD <= x"16")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"03")then
                if(CH_CNT_FIFO_RD>= x"19" and CH_CNT_FIFO_RD <= x"1e")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            elsif(CURSOR_POS_LY2 = x"04")then
                if(CH_CNT_FIFO_RD>= x"21" and CH_CNT_FIFO_RD <= x"26")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            end if;
        elsif(menu_option_cnt = BPR_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"01" and CH_CNT_FIFO_RD <= x"06")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"09" and CH_CNT_FIFO_RD <= x"0e")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"11" and CH_CNT_FIFO_RD <= x"16")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"03")then
                if(CH_CNT_FIFO_RD>= x"19" and CH_CNT_FIFO_RD <= x"1e")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            elsif(CURSOR_POS_LY2 = x"04")then
                if(CH_CNT_FIFO_RD>= x"21" and CH_CNT_FIFO_RD <= x"26")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            end if;     
        elsif(menu_option_cnt = SETTINGS_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"01" and CH_CNT_FIFO_RD <= x"0B")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"0D" and CH_CNT_FIFO_RD <= x"1a")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"1b" and CH_CNT_FIFO_RD <= x"20")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"03")then
                if(CH_CNT_FIFO_RD>= x"21" and CH_CNT_FIFO_RD <= x"26")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            end if;               
        elsif(menu_option_cnt = GALLERY_POS)then
            if(CURSOR_POS_LY2 = x"00")then
                if(CH_CNT_FIFO_RD>= x"00" and CH_CNT_FIFO_RD <= x"09")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;        
            elsif(CURSOR_POS_LY2 = x"01")then
                if(CH_CNT_FIFO_RD>= x"0B" and CH_CNT_FIFO_RD <= x"10")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if; 
            elsif(CURSOR_POS_LY2 = x"02")then
                if(CH_CNT_FIFO_RD>= x"11" and CH_CNT_FIFO_RD <= x"18")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            elsif(CURSOR_POS_LY2 = x"03")then
                if(CH_CNT_FIFO_RD>= x"19" and CH_CNT_FIFO_RD <= x"1E")then
                    add_cursor <= '1';
                else
                    add_cursor <= '0';
                end if;
            end if;    
        end if;                                     
      else   
          if(CURSOR_POS = clm_block_cnt)then 
             add_cursor <= '1';          
          else
            add_cursor <= '0';
          end if;            
--          if(CURSOR_POS = x"00" )then 
--            if(clm_block_cnt = x"00")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if;                 
--          elsif(CURSOR_POS = x"01")then
--            if(clm_block_cnt = x"01")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if;   
                
--          elsif(CURSOR_POS = x"02")then
--            if(clm_block_cnt = x"02")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if;  
--          elsif(CURSOR_POS = x"03")then 
--            if(clm_block_cnt = x"03" )then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if;  
--          elsif(CURSOR_POS = x"04")then
--            if(clm_block_cnt = x"04" )then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if;        
--          elsif(CURSOR_POS = x"05")then 
--            if(clm_block_cnt = x"05")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if;        
--          elsif(CURSOR_POS = x"06")then 
--            if(clm_block_cnt = x"06")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if;  
--          elsif(CURSOR_POS = x"07")then 
--            if(clm_block_cnt = x"07")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if; 
--           elsif(CURSOR_POS = x"08")then 
--            if(clm_block_cnt = x"08")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if; 
--           elsif(CURSOR_POS = x"09")then 
--            if(clm_block_cnt = x"09")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if; 
--           elsif(CURSOR_POS = x"0A")then 
--            if(clm_block_cnt = x"0A")then
--                add_cursor <= '1';          
--            else
--                add_cursor <= '0';
--            end if;  
--           else
--            add_cursor <= '0';
--           end if;           
      end if;
      if(OSD_REQ_V_DDD = '1') then
          if(ly3_sel = '1')then
            POS_Y_CH <= POS_Y_CH_1_LY3; 
          elsif(ly2_sel = '1')then
            POS_Y_CH <= POS_Y_CH_1_LY2; 
          else
            POS_Y_CH <= POS_Y_CH_1_LY1;
          end if;
          CH_LIN_CNT_RD  <= (others=>'0');
      end if; 
  
      
      if OSD_EN_DD ='1' then
            OSD_V              <= OSD_V_D;
            OSD_H              <= OSD_H_D;
            FIFO_RD_OSD        <= '0';
            FIFO_RD1           <= '0';
            OSD_V_D            <= '0'; 
            OSD_H_D            <= '0';
            OSD_EOI_D          <= VIDEO_IN_EOI;
            OSD_EOI            <= OSD_EOI_D;
            OSD_DAVi           <= '0';
            FIFO_RD1_D         <= FIFO_RD1;
            FIFO_RD_OSD_D      <= FIFO_RD_OSD ;
            FIFO_RD1_CNT_D     <= FIFO_RD1_CNT;
            pix_cnt_d          <= pix_cnt;
            POS_X_CH_D         <= POS_X_CH;
            POS_X_CH_DD        <= POS_X_CH_D;
            lin_block_cnt_d    <= lin_block_cnt;         
            lin_block_cnt_dd   <= lin_block_cnt_d;   
                       
            if VIDEO_IN_V_DDDD = '1' then
              OSD_V_D        <= '1'; 
              CH_CNT_FIFO_RD <= (others=>'0');
              OSD_LINE_CNT   <= (others=>'0');
              lin_block_cnt <= (others=>'0');
              clm_block_cnt <= (others=>'0');
            end if;
      
            if VIDEO_IN_H_DDDD = '1' then
              OSD_H_D          <= '1';  
              first_time_rd_rq <= '1'; 
              FIFO_RD1_CNT     <= 0;   
              pix_cnt          <= (others => '0');
              count            <= 0;
              OSD_ADD_DONE     <= '0';
              CH_CNT_FIFO_RD   <= (others=>'0');
              OSD_ADD_DONE     <= '0';
              lin_block_cnt <= (others=>'0');
              if(ly3_sel = '1')then
                POS_X_CH   <= POS_X_CH_1_LY3;              
              elsif(ly2_sel = '1')then
                POS_X_CH   <= POS_X_CH_1_LY2;
              else
                POS_X_CH   <= POS_X_CH_1_LY1;
              end if;
--              if ((line_cnt-1) = (to_unsigned(8,LIN_BITS) + unsigned(LATCH_POS_Y_CH(LIN_BITS-1 downto 1))))then
              if ((line_cnt-1) = (unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0)) + unsigned(POS_Y_CH(LIN_BITS-1 downto 0))))then
                         CH_LIN_CNT_RD   <=  CH_LIN_CNT_RD + 1 ; 
                         clm_block_cnt   <=  clm_block_cnt +1;
                         if(ly3_sel = '1')then
                            POS_Y_CH  <= POS_Y_CH_1_LY3;
                         elsif(ly2_sel = '1')then
                            POS_Y_CH  <= POS_Y_CH_1_LY2;
                         elsif(main_menu_sel= '1')then                  
                             if(CH_LIN_CNT_RD = x"00")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+1*unsigned(CH_IMG_HEIGHT)+1*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"01")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+2*unsigned(CH_IMG_HEIGHT)+2*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"02")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+3*unsigned(CH_IMG_HEIGHT)+3*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"03")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+4*unsigned(CH_IMG_HEIGHT)+4*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);    
                             elsif(CH_LIN_CNT_RD = x"04")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+5*unsigned(CH_IMG_HEIGHT)+5*PIX_BETWEEN_CH_ROW),POS_Y_CH'length); 
                             elsif(CH_LIN_CNT_RD = x"05")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+6*unsigned(CH_IMG_HEIGHT)+6*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                     
                             elsif(CH_LIN_CNT_RD = x"06")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+7*unsigned(CH_IMG_HEIGHT)+7*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                  
                             elsif(CH_LIN_CNT_RD = x"07")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+8*unsigned(CH_IMG_HEIGHT)+8*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                  
                             elsif(CH_LIN_CNT_RD = x"08")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+9*unsigned(CH_IMG_HEIGHT)+9*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                  
                             end if;                                                            
--                             elsif(CH_LIN_CNT_RD = x"03")then
--                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+4*unsigned(CH_IMG_HEIGHT)+4*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
--                             elsif(CH_LIN_CNT_RD = x"04")then
--                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+5**unsigned(CH_IMG_HEIGHT)+5*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
--                             elsif(CH_LIN_CNT_RD = x"05")then
--                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+6*unsigned(CH_IMG_HEIGHT)+16*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
--                             elsif(CH_LIN_CNT_RD = x"06")then
--                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+7**unsigned(CH_IMG_HEIGHT)+7*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
--                             end if; 
                         elsif(advance_menu_sel= '1')then  
                             if(CH_LIN_CNT_RD = x"00")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+1*unsigned(CH_IMG_HEIGHT)+1*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"01")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+2*unsigned(CH_IMG_HEIGHT)+2*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"02")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+3*unsigned(CH_IMG_HEIGHT)+3*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"03")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+4*unsigned(CH_IMG_HEIGHT)+4*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"04")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+5*unsigned(CH_IMG_HEIGHT)+5*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"05")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+6*unsigned(CH_IMG_HEIGHT)+6*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"06")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+7*unsigned(CH_IMG_HEIGHT)+7*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"07")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+8*unsigned(CH_IMG_HEIGHT)+8*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                          
                             elsif(CH_LIN_CNT_RD = x"08")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+9*unsigned(CH_IMG_HEIGHT)+9*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);
                             elsif(CH_LIN_CNT_RD = x"09")then
                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+10*unsigned(CH_IMG_HEIGHT)+10*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                   
--                             elsif(CH_LIN_CNT_RD = x"0A")then
--                                 POS_Y_CH  <= resize((POS_Y_CH_1_LY1+11*unsigned(CH_IMG_HEIGHT)+11*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                 
                             --elsif(CH_LIN_CNT_RD = x"0B")then
                             --    POS_Y_CH  <= resize((POS_Y_CH_1_LY1+12*unsigned(CH_IMG_HEIGHT)+12*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                 
                             --elsif(CH_LIN_CNT_RD = x"0C")then
                             --    POS_Y_CH  <= resize((POS_Y_CH_1_LY1+13*unsigned(CH_IMG_HEIGHT)+13*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                 
                             --elsif(CH_LIN_CNT_RD = x"0D")then
                             --    POS_Y_CH  <= resize((POS_Y_CH_1_LY1+14*unsigned(CH_IMG_HEIGHT)+14*PIX_BETWEEN_CH_ROW),POS_Y_CH'length);                                 
                             end if; 
                         end if;                       
                end if;
              
                           
            end if;
           

  
--           if ((line_cnt-1) >= unsigned(LATCH_POS_Y_CH(LIN_BITS-1 downto 1))) and  ((line_cnt-1) < (to_unsigned(8,line_cnt'length) + unsigned(LATCH_POS_Y_CH(LIN_BITS-1 downto 1)))) then                     
           if ((line_cnt-1) >= unsigned(POS_Y_CH(LIN_BITS-1 downto 0))) and  ((line_cnt-1) < (unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0)) + unsigned(POS_Y_CH(LIN_BITS-1 downto 0)))) then                           
--            if((((OSD_RD_DONE = '1') and (unsigned(FIFO_NB1) >= to_unsigned(8,FIFO_NB1'length)))) or (count>= (unsigned(VIDEO_IN_XSIZE))-8))then        
            if((((OSD_RD_DONE = '1') and (unsigned(FIFO_NB1) >= unsigned(CH_IMG_WIDTH)))) or (count>= (unsigned(VIDEO_IN_XSIZE))-unsigned(CH_IMG_WIDTH)))then 
                 count      <= count + 1;
                 FIFO_RD1   <= '1';
                 pix_cnt    <= pix_cnt + 1;
                 if((pix_cnt = unsigned(POS_X_CH)))then
                   FIFO_RD_OSD      <= '1';
                   OSD_ADD_DONE     <= '1';
                   FIFO_RD1_CNT     <= 0;
                 elsif(OSD_ADD_DONE = '1')then
                   if FIFO_RD1_CNT = (unsigned(CH_IMG_WIDTH) -1) then
                       OSD_ADD_DONE <= '0';
                       FIFO_RD1_CNT <= 0;
                   else
                       FIFO_RD1_CNT <= FIFO_RD1_CNT+ 1;
                   end if;                       
                 end if;  
                              
                 if((pix_cnt) = (unsigned(CH_IMG_WIDTH)- 1 + unsigned(POS_X_CH)))then
                     CH_CNT_FIFO_RD   <=  CH_CNT_FIFO_RD + 1 ; 
                     if(ly3_sel ='1')then
                         if(CH_CNT_FIFO_RD = x"00")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+1*PIX_BETWEEN_CH_CLM+1*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                             lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"01")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+2*PIX_BETWEEN_CH_CLM+2*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"02")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+3*PIX_BETWEEN_CH_CLM+3*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                             lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"03")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+4*PIX_BETWEEN_CH_CLM+4*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"04")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+5*PIX_BETWEEN_CH_CLM+5*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"05")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+6*PIX_BETWEEN_CH_CLM+6*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"06")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+7*PIX_BETWEEN_CH_CLM+7*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"07")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+8*PIX_BETWEEN_CH_CLM+8*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"08")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+9*PIX_BETWEEN_CH_CLM+9*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"09")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+10*PIX_BETWEEN_CH_CLM+10*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"0A")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+11*PIX_BETWEEN_CH_CLM+11*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"0B")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+12*PIX_BETWEEN_CH_CLM+12*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"0C")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+13*PIX_BETWEEN_CH_CLM+13*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"0D")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+14*PIX_BETWEEN_CH_CLM+14*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"0E")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+15*PIX_BETWEEN_CH_CLM+15*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"0F")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+16*PIX_BETWEEN_CH_CLM+16*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"10")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY3+17*PIX_BETWEEN_CH_CLM+16*unsigned(CH_IMG_WIDTH)),POS_X_CH'length); 
                         end if;   
                     
                     elsif(ly2_sel ='1')then
                          if(CH_CNT_FIFO_RD = x"00")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+1*PIX_BETWEEN_CH_CLM+1*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                             lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"01")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+2*PIX_BETWEEN_CH_CLM+2*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"02")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+3*PIX_BETWEEN_CH_CLM+3*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                             lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"03")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+4*PIX_BETWEEN_CH_CLM+4*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"04")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+5*PIX_BETWEEN_CH_CLM+5*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"05")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+6*PIX_BETWEEN_CH_CLM+6*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"06")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+7*PIX_BETWEEN_CH_CLM+7*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"07")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+8*PIX_BETWEEN_CH_CLM+8*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"08")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+9*PIX_BETWEEN_CH_CLM+9*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"09")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+10*PIX_BETWEEN_CH_CLM+10*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"0A")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+11*PIX_BETWEEN_CH_CLM+11*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"0B")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+12*PIX_BETWEEN_CH_CLM+12*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"0C")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+13*PIX_BETWEEN_CH_CLM+13*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"0D")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+14*PIX_BETWEEN_CH_CLM+14*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"0E")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+15*PIX_BETWEEN_CH_CLM+15*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"0F")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+16*PIX_BETWEEN_CH_CLM+16*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"10")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+17*PIX_BETWEEN_CH_CLM+17*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"11")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+18*PIX_BETWEEN_CH_CLM+18*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"12")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+19*PIX_BETWEEN_CH_CLM+19*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"13")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+20*PIX_BETWEEN_CH_CLM+20*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"14")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+21*PIX_BETWEEN_CH_CLM+21*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"15")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+22*PIX_BETWEEN_CH_CLM+22*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"16")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+23*PIX_BETWEEN_CH_CLM+23*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"17")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+24*PIX_BETWEEN_CH_CLM+24*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"18")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+25*PIX_BETWEEN_CH_CLM+25*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"19")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+26*PIX_BETWEEN_CH_CLM+26*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"1A")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+27*PIX_BETWEEN_CH_CLM+27*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"1B")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+28*PIX_BETWEEN_CH_CLM+28*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"1C")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+29*PIX_BETWEEN_CH_CLM+29*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"1D")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+30*PIX_BETWEEN_CH_CLM+30*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"1E")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+31*PIX_BETWEEN_CH_CLM+31*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"1F")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+32*PIX_BETWEEN_CH_CLM+32*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"20")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+33*PIX_BETWEEN_CH_CLM+33*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"21")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+34*PIX_BETWEEN_CH_CLM+34*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"22")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+35*PIX_BETWEEN_CH_CLM+35*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"23")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+36*PIX_BETWEEN_CH_CLM+36*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"24")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+37*PIX_BETWEEN_CH_CLM+37*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"25")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+38*PIX_BETWEEN_CH_CLM+38*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"26")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+39*PIX_BETWEEN_CH_CLM+39*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"27")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY2+40*PIX_BETWEEN_CH_CLM+40*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);      
                         end if;                   

                     else
                         if(CH_CNT_FIFO_RD = x"00")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+1*PIX_BETWEEN_CH_CLM+1*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                             lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"01")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+2*PIX_BETWEEN_CH_CLM+2*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"02")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+3*PIX_BETWEEN_CH_CLM+3*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                             lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"03")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+4*PIX_BETWEEN_CH_CLM+4*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"04")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+5*PIX_BETWEEN_CH_CLM+5*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"05")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+6*PIX_BETWEEN_CH_CLM+6*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"06")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+7*PIX_BETWEEN_CH_CLM+7*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"07")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+8*PIX_BETWEEN_CH_CLM+8*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"08")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+9*PIX_BETWEEN_CH_CLM+9*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"09")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+10*PIX_BETWEEN_CH_CLM+10*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"0A")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+11*PIX_BETWEEN_CH_CLM+11*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                         elsif(CH_CNT_FIFO_RD = x"0B")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+12*PIX_BETWEEN_CH_CLM+12*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1;
                         elsif(CH_CNT_FIFO_RD = x"0C")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+13*PIX_BETWEEN_CH_CLM+13*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         elsif(CH_CNT_FIFO_RD = x"0D")then
                             POS_X_CH  <= resize((POS_X_CH_1_LY1+14*PIX_BETWEEN_CH_CLM+14*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                         end if;    
    --                     elsif(CH_CNT_FIFO_RD = x"0E")then
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+60*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    ----                         lin_block_cnt   <= lin_block_cnt +1;  
    --                     end if;                             
    --                     elsif(CH_CNT_FIFO_RD = x"0F")then
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+2*PIX_BETWEEN_CH_CLM+61*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
    --                     elsif(CH_CNT_FIFO_RD = x"10")then
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+4*PIX_BETWEEN_CH_CLM+62*unsigned(CH_IMG_WIDTH)),POS_X_CH'length); 
    --                     elsif(CH_CNT_FIFO_RD = x"11")then
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+72*unsigned(CH_IMG_WIDTH)),POS_X_CH'length); 
    --                         lin_block_cnt   <= lin_block_cnt +1;
    --                     elsif(CH_CNT_FIFO_RD = x"12")then
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+2*PIX_BETWEEN_CH_CLM+73*unsigned(CH_IMG_WIDTH)),POS_X_CH'length); 
    --                     elsif(CH_CNT_FIFO_RD = x"13")then
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+4*PIX_BETWEEN_CH_CLM+74*unsigned(CH_IMG_WIDTH)),POS_X_CH'length); 
    --                     elsif(CH_CNT_FIFO_RD = x"14")then
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+5*PIX_BETWEEN_CH_CLM+84*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                         lin_block_cnt   <= lin_block_cnt +1; 
    --                     elsif(CH_CNT_FIFO_RD = x"15")then
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+7*PIX_BETWEEN_CH_CLM+85*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);                                                                                                                              
    --                     else
    --                         POS_X_CH  <= resize((POS_X_CH_1_LY1+9*PIX_BETWEEN_CH_CLM+86*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
    --                     end if;   
                        end if;                    
                 end if; 
                    
                 if count = (unsigned(VIDEO_IN_XSIZE))-1 then
                  count <= 0; 
                 end if;  
            else
                  FIFO_RD1     <= '0';
                  FIFO_RD_OSD  <= '0';
            end if;
            
            
            
            if FIFO_RD1_D = '1'then
               OSD_DAVi <= '1';
               if(((pix_cnt_d-1)>= (unsigned(POS_X_OSD))) and ((pix_cnt_d-1) < ((unsigned(OSD_REQ_XSIZE) + unsigned(POS_X_OSD)))))then
--                   if(((pix_cnt_d-1)>= (unsigned(POS_X_CH_DD))) and ((pix_cnt_d-1) < ((to_unsigned(8,PIX_BITS) + unsigned(POS_X_CH_DD)))))then   
                   if(((pix_cnt_d-1)>= (unsigned(POS_X_CH_DD))) and ((pix_cnt_d-1) < ((unsigned(CH_IMG_WIDTH)+ unsigned(POS_X_CH_DD)))))then   
                      if(FIFO_OUT_OSD(((FIFO_RD1_CNT_D))) = '1')then                       
                            OSD_DATA <= LATCH_CH_COLOR_INFO1; 
                      else 
                        if(add_cursor_d = '1')then
                            OSD_DATA <= LATCH_CURSOR_COLOR_INFO;
                        else
                            OSD_DATA <= LATCH_OSD_COLOR_INFO1;
                        end if;     
                      end if;
                   else
                      if(add_cursor_d = '1')then
                        OSD_DATA <= LATCH_CURSOR_COLOR_INFO;
                      else
                        OSD_DATA <= LATCH_OSD_COLOR_INFO1;
                      end if;     
--                    if((((pix_cnt_d-1)>= (unsigned(POS_X_CH_DD-4))) and  ((pix_cnt_d-1)<= (unsigned(POS_X_CH_DD-1)))) or (((pix_cnt_d-1) >= ((to_unsigned(8,PIX_BITS) + unsigned(POS_X_CH_DD)))) and ((pix_cnt_d-1) <= ((to_unsigned(11,PIX_BITS) + unsigned(POS_X_CH_DD))))))then
--                        if(add_cursor_d = '1')then
--                            OSD_DATA <= LATCH_CURSOR_COLOR_INFO;
--                        else
--                            OSD_DATA <= LATCH_OSD_COLOR_INFO1;
--                        end if;                           
--                    else
--                       OSD_DATA <= FIFO_OUT1;
--                    end if;  
                   end if;
               else
--                  if(add_cursor_d = '1')then
--                    OSD_DATA <= LATCH_CURSOR_COLOR_INFO;
--                  else
--                    OSD_DATA <= LATCH_OSD_COLOR_INFO1;
--                  end if;  
               
                  OSD_DATA <= FIFO_OUT1;
               end if;     
            end if; 
              
          else
             FIFO_RD_OSD     <= '0';
--             if((unsigned(FIFO_NB1) >= to_unsigned(8,FIFO_NB1'length))) or (count>= (unsigned(VIDEO_IN_XSIZE))-8)then  
             if((unsigned(FIFO_NB1) >= to_unsigned(8,FIFO_NB1'length))) or (count>= (unsigned(VIDEO_IN_XSIZE))-unsigned(CH_IMG_WIDTH))then             
                   count     <= count + 1;
                   FIFO_RD1  <= '1';
                   pix_cnt   <= pix_cnt + 1;            
                   if count = (unsigned(VIDEO_IN_XSIZE))-1 then
                    count <= 0; 
                   end if;     
                   
              else
                    FIFO_RD1     <= '0';
                    
              end if;
            
              if FIFO_RD1_D = '1'then
                   OSD_DAVi <= '1';
                   OSD_DATA <= FIFO_OUT1;     
              end if;        
               
           end if;
      else
          OSD_V             <= VIDEO_IN_V_DDDD   ;--VIDEO_IN_V; 
          OSD_H             <= VIDEO_IN_H_DDDD   ;--VIDEO_IN_H ;
          OSD_DAVi          <= VIDEO_IN_DAV_DDDD ;--VIDEO_IN_DAV;
          OSD_DATA          <= VIDEO_IN_DATA_DDDD;--VIDEO_IN_DATA;
          OSD_EOI           <= VIDEO_IN_EOI_DDDD ;--VIDEO_IN_EOI;
          FIFO_RD_OSD       <= '0';
          FIFO_RD1          <= '0'; 
          OSD_H_D           <= '0';  
          OSD_V_D           <= '0';
          OSD_EOI_D         <= '0';
          first_time_rd_rq  <= '1'; 
          FIFO_RD1_CNT      <= 0; 
          count             <= 0;
          FIFO_RD1_D        <= '0';
          FIFO_RD_OSD_D     <= '0';
          FIFO_RD1_CNT_D    <= 0;
          CURSOR_SEL_CNT    <= x"02";
          OSD_LINE_CNT      <= (others=>'0');
  
      end if;  
      
   end if;
   
  end process;

OSD_DAV   <= OSD_DAVi;

i_CH_ROM :  CH_ROM
   generic map(
          ADDR_WIDTH => CH_ROM_ADDR_WIDTH,
          DATA_WIDTH => CH_ROM_DATA_WIDTH
    )
   port map(
   clk  => CLK,
   addr => CH_ROM_ADDR,
   data => CH_ROM_DATA
);

BIN_DATA         <= std_logic_vector(       "00"     & BRIGHTNESS  )     when( menu_option_cnt = BRIGHTNESS_POS)else  
                    --std_logic_vector(x"00"& "0"      & CALIB_MODE  )     when( menu_option_cnt = CALIBRATION_POS)else 
                    std_logic_vector(x"0" & "000"    & DZOOM       )     when( menu_option_cnt = DZOOM_POS or menu_option_cnt = DZOOM_KEY_POS )else  
                    std_logic_vector(x"0" & "0000"   & AGC_MODE    )     when( menu_option_cnt = AGC_POS)else  
--                    std_logic_vector("00"& RETICLE_OFFSET_V(7 downto 0)) when( menu_option_cnt = FIRING_POS and ly2_sel = '1')else
--                    std_logic_vector(x"00"& "0"      & FIRING_MODE )     when( menu_option_cnt = FIRING_POS and CURSOR_POS_LY2 =x"0" )else  
----                    std_logic_vector(x"0" & "00"     & DISTANCE_SEL)     when( menu_option_cnt = FIRING_POS and CURSOR_POS_LY2 =x"1" )else
--                    std_logic_vector(                  FIRING_DISTANCE)  when( menu_option_cnt = FIRING_POS and CURSOR_POS_LY2 =x"1" )else 
                    std_logic_Vector(       "00"     & SNAPSHOT_COUNTER) when( menu_option_cnt = SNAPSHOT_POS)else                     
                    std_logic_Vector(       "00"     & GALLERY_IMG_NUMBER) when( menu_option_cnt = GALLERY_POS)else   
                    std_logic_vector(x"0" & "000"    & RETICLE_COLOR)    when( menu_option_cnt = RETICLE_POS and CURSOR_POS_LY2 =x"0" )else  
                    std_logic_vector(x"0" & "00"     & RETICLE_TYPE)     when( menu_option_cnt = RETICLE_POS and CURSOR_POS_LY2 =x"1" )else
                    std_logic_vector(                  RETICLE_VERT)     when((menu_option_cnt = RETICLE_POS and CURSOR_POS_LY2 =x"2")or(menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"0"))else
                    std_logic_vector(                  RETICLE_HORZ(9 downto 0))     when((menu_option_cnt = RETICLE_POS and CURSOR_POS_LY2 =x"3")or(menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"1") )else
                    std_logic_vector(       "00"     & DISPLAY_LUX )     when( menu_option_cnt = DISPLAY_POS and CURSOR_POS_LY2 =x"0" )else
                    std_logic_vector(       "00"     & DISPLAY_GAIN)     when( menu_option_cnt = DISPLAY_POS and CURSOR_POS_LY2 =x"1" )else
                    std_logic_vector(                  DISPLAY_VERT)     when( menu_option_cnt = DISPLAY_POS and CURSOR_POS_LY2 =x"2" )else
                    std_logic_vector(       "0"      & DISPLAY_HORZ)     when( menu_option_cnt = DISPLAY_POS and CURSOR_POS_LY2 =x"3" )else
                    std_logic_vector(x"00" & "0"     & SMOOTHING   )     when( menu_option_cnt = IMG_ENHANCE_POS and CURSOR_POS_LY2 =x"0")else
                    std_logic_vector(x"0"  & "00"    & SHARPNESS   )     when( menu_option_cnt = IMG_ENHANCE_POS and CURSOR_POS_LY2 =x"1")else
                    std_logic_vector(x"00" & "0"     & SOFTNUC     )     when( menu_option_cnt = IMG_ENHANCE_POS and CURSOR_POS_LY2 =x"2" )else
                    std_logic_vector(        "00"    & MAX_LIMITER_DPHE) when( menu_option_cnt = AGC_ADVANCE_POS and CURSOR_POS_LY2 =x"0")else
                    std_logic_vector(        "00"    & CNTRL_MAX_GAIN)   when( menu_option_cnt = AGC_ADVANCE_POS and CURSOR_POS_LY2 =x"1")else
                    std_logic_vector(        "00"    & CNTRL_IPP)        when( menu_option_cnt = AGC_ADVANCE_POS and CURSOR_POS_LY2 =x"2")else
                    std_logic_vector(        "00"    & MUL_MAX_LIMITER_DPHE)when(  menu_option_cnt = AGC_ADVANCE_POS and CURSOR_POS_LY2 =x"3")else
                    --std_logic_vector(x"0"  & "00"    & PALETTE_TYPE)     when( menu_option_cnt = PALETTE_POS)else
                    std_logic_vector(x"00" & "0"     & MARK_BP     )     when( menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"2")else
                    std_logic_vector(x"0"  & "000"   & POLARITY    )     when( menu_option_cnt = POLARITY_KEY_POS)else
                    std_logic_vector(        "00"    & GAIN        )     when( menu_option_cnt = GAIN_POS);
--                    std_logic_vector(        "00"    & GAIN        )     when( menu_option_cnt = GAIN_KEY_POS or menu_option_cnt = GAIN_POS);
                    
                                      
BIN_DATA_VALID   <= BRIGHTNESS_VALID   when( menu_option_cnt = BRIGHTNESS_POS)else        
                    --CALIB_MODE_VALID   when( menu_option_cnt = CALIBRATION_POS)else                                   
                    DZOOM_VALID         when( menu_option_cnt = DZOOM_POS or menu_option_cnt = DZOOM_KEY_POS)else                                      
                    AGC_MODE_VALID      when( menu_option_cnt = AGC_POS)else    
--                    RETICLE_OFFSET_VALID when( menu_option_cnt = FIRING_POS and ly2_sel = '1')else
--                    FIRING_MODE_VALID    when( menu_option_cnt = FIRING_POS and CURSOR_POS_LY2 =x"0" )else  
----                    DISTANCE_SEL_VALID   when( menu_option_cnt = FIRING_POS and CURSOR_POS_LY2 =x"1" )else 
--                    DISTANCE_SEL_VALID_DD when( menu_option_cnt = FIRING_POS and CURSOR_POS_LY2 =x"1" )else 
                    SNAPSHOT_COUNTER_VALID when ( menu_option_cnt = SNAPSHOT_POS)else 
                    GALLERY_IMG_NUMBER_VALID when ( menu_option_cnt = GALLERY_POS)else                 
                    RETICLE_COLOR_VALID when( menu_option_cnt = RETICLE_POS and CURSOR_POS_LY2 =x"0" )else                                      
                    RETICLE_TYPE_VALID when( menu_option_cnt = RETICLE_POS and CURSOR_POS_LY2 =x"1" )else    
                    RETICLE_VERT_HORZ_VALID when((menu_option_cnt = RETICLE_POS and CURSOR_POS_LY2 =x"2")or(menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"0"))else    
                    RETICLE_VERT_HORZ_VALID when((menu_option_cnt = RETICLE_POS and CURSOR_POS_LY2 =x"3")or(menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"1"))else    
                    DISPLAY_LUX_VALID  when( menu_option_cnt = DISPLAY_POS and CURSOR_POS_LY2 =x"0" )else    
                    DISPLAY_GAIN_VALID when( menu_option_cnt = DISPLAY_POS and CURSOR_POS_LY2 =x"1" )else    
                    DISPLAY_VERT_VALID when( menu_option_cnt = DISPLAY_POS and CURSOR_POS_LY2 =x"2" )else    
                    DISPLAY_HORZ_VALID when( menu_option_cnt = DISPLAY_POS and CURSOR_POS_LY2 =x"3" )else                                      
                    SMOOTHING_VALID    when( menu_option_cnt = IMG_ENHANCE_POS and CURSOR_POS_LY2 =x"0")else                                 
                    SHARPNESS_VALID    when( menu_option_cnt = IMG_ENHANCE_POS and CURSOR_POS_LY2 =x"1")else  
                    SOFTNUC_VALID      when( menu_option_cnt = IMG_ENHANCE_POS and CURSOR_POS_LY2 =x"2")else  
                    MAX_LIMITER_DPHE_VALID  when( menu_option_cnt = AGC_ADVANCE_POS and CURSOR_POS_LY2 =x"0")else   
                    CNTRL_MAX_GAIN_VALID    when( menu_option_cnt = AGC_ADVANCE_POS and CURSOR_POS_LY2 =x"1")else  
                    CNTRL_IPP_VALID         when( menu_option_cnt = AGC_ADVANCE_POS and CURSOR_POS_LY2 =x"2")else                               
                    MUL_MAX_LIMITER_DPHE_VALID when( menu_option_cnt = AGC_ADVANCE_POS and CURSOR_POS_LY2 =x"3")else 
                    --PALETTE_TYPE_VALID when( menu_option_cnt = PALETTE_POS)else                                    
                    MARK_BP_VALID     when( menu_option_cnt = BPR_POS and CURSOR_POS_LY2 = x"2")else        
                    POLARITY_VALID     when( menu_option_cnt = POLARITY_KEY_POS)else
                    GAIN_VALID         when( menu_option_cnt = GAIN_POS);
--                    GAIN_VALID         when( menu_option_cnt = GAIN_KEY_POS or menu_option_cnt = GAIN_POS);

i_BINARY_TO_BCD : BINARY_TO_BCD
generic map(  DATA_IN_WIDTH  => 10,
              DATA_OUT_WIDTH => 12)
port map(
 CLK                => CLK,
 RST                => RST,
 BIN_DATA_IN        => BIN_DATA,
 BIN_DATA_IN_VALID  => BIN_DATA_VALID,
 BCD_DATA_OUT       => BCD_DATA,
 BCD_DATA_OUT_VALID => BCD_DATA_VALID
); 

RETICLE_OFFSET_H_1 <= "00" & RETICLE_OFFSET_H(7 downto 0) ;

i_BINARY_TO_BCD_RETICLE_OFFSET_H : BINARY_TO_BCD
generic map(  DATA_IN_WIDTH  => 10,
              DATA_OUT_WIDTH => 12)
port map(
 CLK                => CLK,
 RST                => RST,
 BIN_DATA_IN        => std_logic_vector(RETICLE_OFFSET_H_1),
 BIN_DATA_IN_VALID  => RETICLE_OFFSET_VALID,
 BCD_DATA_OUT       => BCD_DATA_RETICLE_OFFSET_H,
 BCD_DATA_OUT_VALID => BCD_DATA_RETICLE_OFFSET_H_VALID
); 


--probe0(0)<= OSD_DAVi;
--probe0(1)<= FIFO_EMP_OSD;
--probe0(2)<= VIDEO_IN_H;
--probe0(3)<= VIDEO_IN_V;
--probe0(4)<= VIDEO_IN_DAV;
--probe0(14 downto 5)<=FIFO_NB1;
----probe0(16 downto 11)<= std_logic_vector(DMA_ADDR_PIX_check);
--probe0(15)<= VIDEO_IN_EOI;
--probe0(16)<= OSD_EOI_D;
--probe0(17)<= FIFO_RD1;
--probe0(18)<= FIFO_WR1;
----probe0(20 downto 19)<=  (others=> '0');
----probe0(20 downto 13)<= VIDEO_IN_DATA_D;
----probe0(30 downto 21 ) <= std_logic_vector(OSD_YCNTi);
--probe0(28 downto 19)<= std_logic_vector(to_unsigned(count,10));--FIFO_OUT;
--probe0(38 downto 29)<= OSD_POS_Y;
--probe0(44 downto 39)<=  std_logic_vector(to_unsigned(FIFO_RD1_CNT,6));
--probe0(50 downto 45)<= "00000" &FIFO_NB_OSD;
--probe0(51)<= OSD_EN;
--probe0(52)<= OSD_FIELD;
--probe0(53)<= OSD_EN_D;
--probe0(54)<= FIFO_RD_OSD;
--probe0(55)<= FIFO_WR_OSD;
--probe0(65 downto 56)<=LATCH_POS_X_OSD;
----probe0(75 downto 56)<=std_logic_vector(DMA_ADDR_BASE(31 downto 12));
----probe0(66)<= flag;
--probe0(75 downto 66)<=std_logic_vector(LATCH_POS_Y_CH);
----probe0(69 downto 66)<=OSD_PIX_OFFSET;
--probe0(76)<= flag;
--probe0(77)<=FIFO_RD_OSD_1;
----probe0(77 downto 74)<= OSD_PIX_OFFSET_D;
--probe0(87 downto 78)<=std_logic_vector(RD_OSD_LIN_NO);--OSD_POS_X;
--probe0(88)<= OSD_FIELD;
--probe0(89)<=FIFO_WR_OSD_2;
----probe0(89 downto 58)<= std_logic_vector(to_unsigned(FIFO_RD1_CNT,32));--FIFO_IN;
--probe0(90) <= DMA_RDREADY;
--probe0(91) <= DMA_RDDAV;
--probe0(94 downto 92) <=DMA_RDFSM_check; 
----probe0(104 downto 95)<= std_logic_vector(OSD_XSIZE_OFFSET_L);
--probe0(104 downto 95)<= std_logic_vector(POS_X_CH);
--probe0(114 downto 105)<= std_logic_Vector(pix_cnt);
----probe0(114 downto 105)<= std_logic_Vector(OSD_cnt1);--std_logic_Vector(OSD_YCNTi);
--probe0(115)<= OSD_REQ_V;
--probe0(116)<= OSD_REQ_H;
--probe0(126 downto 117)<=std_logic_Vector(line_cnt);
----probe0(126 downto 117)<=std_logic_Vector(OSD_cnt2);
----probe0(122 downto 117)<= FIFO_NB;--OSD_LIN_NO;
----probe0(123)<= OSD_EN;
----probe0(126 downto 124 )<= (others=> '0');
--probe0(127)<= OSD_ADD_DONE;--FIFO_CLR;
----probe0(127)<= '0';
--probe0(159 downto 128)<=  FIFO_OUT_OSD;--FIFO_OUT_OSD;
--probe0(165 downto 160)<= std_logic_vector(to_unsigned(FIFO_RD1_CNT_D,6));
--probe0(166)<= FIFO_RD1_D;
--probe0(198 downto 167)<= DMA_RDDATA;
----probe0(200 downto 199) <= (others=>'0');
------probe0(200 downto 191)<=std_logic_Vector(pix_cnt_d);
------probe0(255 downto 201)<= (others=>'0');
----probe0(210 downto 201)<= std_logic_vector(RD_OSD_LIN_NO);
----probe0(220 downto 211)<= std_logic_vector(POS_X_CH);--std_logic_Vector(OSD_cnt2);--OSD_YSIZE_OFFSET;
----probe0(230 downto 221)<= std_logic_vector(LATCH_POS_Y_CH);--std_logic_Vector(OSD_cnt1);--VIDEO_IN_YSIZE;
----probe0(240 downto 231)<=std_logic_vector(OSD_XSIZE_OFFSET_R);
--probe0(206 downto 199) <= std_logic_vector(CURSOR_SEL_CNT);
--probe0(214 downto 207) <= std_logic_vector(CH_CNT_FIFO_RD);
--probe0(221 downto 215) <= (others=>'0');
----probe0(221 downto 199) <= std_logic_vector(DMA_ADDR_PICT);
--probe0(229 downto 222) <= std_logic_vector(CH_CNT_FIFO_RD_D);
--probe0(230)<= FIFO_RD_OSD_2;
--probe0(238 downto 231)<= SEL_CH_WR_FIFO;
--probe0(239)<= DMA_RDDAV_D;
----probe0(239)<= DMA_RDDAV_D;
--probe0(240)<= FIFO_WR_OSD_1;
----probe0(240 downto 239)<=(others=>'0');
--probe0(241)           <=OSD_RD_DONE;
--probe0(249 downto 242)<= std_logic_vector(CH_CNT);
--probe0(253 downto 250)<= LATCH_CURSOR_POS;
--probe0(255 downto 254)<= (others=>'0');

--probe0(0)<= OSD_DAVi;
--probe0(1)<= FIFO_EMP_OSD;
--probe0(2)<= VIDEO_IN_H;
--probe0(3)<= VIDEO_IN_V;
--probe0(4)<= VIDEO_IN_DAV;
--probe0(5)<= OSD_REQ_V;
--probe0(6)<= OSD_REQ_H;
--probe0(7)<= OSD_FIELD;
--probe0(17 downto 8)<=FIFO_NB1;
----probe0(16 downto 11)<= std_logic_vector(DMA_ADDR_PIX_check);
--probe0(18)<= VIDEO_IN_EOI;
--probe0(19)<= OSD_EOI_D;
--probe0(20)<= FIFO_RD1;
--probe0(21)<= FIFO_WR1;
--probe0(31 downto 22)<= std_logic_vector(to_unsigned(count,10));--FIFO_OUT;
--probe0(41 downto 32)<= std_logic_Vector(line_cnt);
--probe0(51 downto 42)<= std_logic_Vector(pix_cnt);
--probe0(52)<= OSD_EN;
--probe0(53)<= OSD_EN_D;
--probe0(54)<= FIFO_RD_OSD;
--probe0(55)<= FIFO_WR_OSD;
--probe0(65 downto 56)<=  std_logic_Vector(POS_X_CH_D);
--probe0(75 downto 66)<=  std_logic_Vector(pix_cnt_d);
--probe0(83 downto 76)<=  std_logic_Vector(lin_block_cnt_dd);
--probe0(91 downto 84)<=  std_logic_Vector(lin_block_cnt_d);
--probe0(99 downto 92)<=  std_logic_Vector(lin_block_cnt);
--probe0(107 downto 100)<=  std_logic_Vector(clm_block_cnt);
--probe0(117 downto 108)<=  std_logic_Vector(POS_X_CH_DD);
--probe0(127 downto 118)<=  std_logic_Vector(POS_X_CH);

--i_ila_OSD: ila_0
--PORT MAP (
--  clk => CLK,
--  probe0 => probe0
--);
--------------------------
end architecture RTL;
--------------------------