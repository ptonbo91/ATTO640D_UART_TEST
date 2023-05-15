library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- synthesis translate_off
use STD.textio.all;
use IEEE.std_logic_textio.all;
use IEEE.math_real.all;
-- synthesis translate_on

package THERMAL_CAM_PACK is
	
	-- -----------------------------
	--  Design Clocks Constants
	-- -----------------------------
	constant EXT_FREQ	: positive := 27e6;
	constant SYS_FREQ	: positive := 66e6;--7425e4;--66e6;--66e6;--54e6;
	constant SPI_FREQ	: positive := 1e6;
	constant LPC_FREQ	: positive := 108e5;
    constant I2C_FREQ   : positive := 100_000;
    constant SDRAM_FREQ : positive := 99e6;--108e6;--99e6;--100e6;
	-- Corresponding Periods
	constant EXT_PER : time := 1 sec / EXT_FREQ;
	constant SYS_PER : time := 1 sec / SYS_FREQ;
	constant SPI_PER : time := 1 sec / SPI_FREQ;
	constant LPC_PER : time := 1 sec / LPC_FREQ;

	-- Watchdog Timer Value on Registers Access : if not in IDLE in this time,
	-- then we assume there was an error on a Register Access,
	-- the REGS_MASTER FSM goes back to s_IDLE, and TIMEOUT_ERR bit is raised
	-- (to be checked in FPGA_STATUS register)
	-- Beware not to put a too low number !!! (DO NOT CHANGE UNLESS you are sure)
	constant TIMEOUT_VAL : positive := 3000; -- in ms  
	subtype BASE_RANGE is integer range 15 downto 12;
	-- ------------------------------------------
	--	Command IDs for Uncooled Comm Module
--	-- ------------------------------------------
--	constant SEND_I2C			: STD_LOGIC_VECTOR (7 downto 0) := x"00";
--	constant SEND_SPI			: STD_LOGIC_VECTOR (7 downto 0) := x"01";
--	constant INTERNAL			: STD_LOGIC_VECTOR (7 downto 0) := x"02";
--	constant I2C_READ			: STD_LOGIC_VECTOR (7 downto 0) := x"03";
--	constant SPI_READ			: STD_LOGIC_VECTOR (7 downto 0) := x"04";
--	constant WRITE_TO_FLASH_1	: STD_LOGIC_VECTOR (7 downto 0) := x"05";
--	constant WRITE_TO_FLASH_2	: STD_LOGIC_VECTOR (7 downto 0) := x"06";
--	constant READ_FROM_FLASH	: STD_LOGIC_VECTOR (7 downto 0) := x"07";
	--constant READ_FROM_FLASH_2	: STD_LOGIC_VECTOR (7 downto 0) := x"08";
--	constant ERASE_FROM_FLASH	: STD_LOGIC_VECTOR (7 downto 0) := x"08";
--	constant WRITE_TO_SRAM_1	: STD_LOGIC_VECTOR (7 downto 0) := x"09";
--	constant WRITE_TO_SRAM_2	: STD_LOGIC_VECTOR (7 downto 0) := x"0A";
--	constant READ_FROM_SRAM		: STD_LOGIC_VECTOR (7 downto 0) := x"0B";
	
	-- ------------------------------------------
	--	Response IDs for Uncooled Comm Module
	-- ------------------------------------------
--	constant INT_REPLY_ADDR		: STD_LOGIC_VECTOR (7 downto 0) := x"E2";
--	constant I2C_REPLY_ADDR		: STD_LOGIC_VECTOR (7 downto 0) := x"E3";
--	constant FLASH_REPLY_ADDR	: STD_LOGIC_VECTOR (7 downto 0) := x"E7";
--	constant SRAM_REPLY_ADDR	: STD_LOGIC_VECTOR (7 downto 0) := x"EB";

	-- -----------------------------------------------
	--  FLASH Command IDs
	-- -----------------------------------------------
--	constant FLASH_READ_CMD		: STD_LOGIC_VECTOR (3 downto 0) := x"1";
--	constant FLASH_ERASE_CMD	: STD_LOGIC_VECTOR (3 downto 0) := x"2";
--	constant FLASH_PROGR_CMD	: STD_LOGIC_VECTOR (3 downto 0) := x"4";
--	constant FLASH_RESET_CMD	: STD_LOGIC_VECTOR (3 downto 0) := x"8";

	--	----------------------------------------------------------------------------------------------------------------------
	--	|   FLASH_CMD	|	ADDR_23_16	|	ADDR_15_8	|	ADDR_7_0	||	BLANK	|	BLANK	|	BLANK	|	DataByte	|
	--	----------------------------------------------------------------------------------------------------------------------
	--	|	8 bits		|	8 bits		|	18 bits		|	8 bits		||	8 bits	|	8 bits	|	8 bits	|	8 bits		|
	--	----------------------------------------------------------------------------------------------------------------------

	-- ------------------------------------------
	--	Internal Register Command IDs
	-- ------------------------------------------
    constant SET_PAL_NTSC_MODE          : STD_LOGIC_VECTOR (7 downto 0) := x"01";
    constant GET_PAL_NTSC_MODE          : STD_LOGIC_VECTOR (7 downto 0) := x"01";
    constant SET_IMAGE_WIDTH_FULL       : STD_LOGIC_VECTOR (7 downto 0) := x"02";  
    constant GET_IMAGE_WIDTH_FULL       : STD_LOGIC_VECTOR (7 downto 0) := x"02"; 
    constant SET_TEMP_PIXELS_LEFT_RIGHT : STD_LOGIC_VECTOR (7 downto 0) := x"03";
    constant GET_TEMP_PIXELS_LEFT_RIGHT : STD_LOGIC_VECTOR (7 downto 0) := x"03";   
    constant SET_EXCLUDE_LEFT_RIGHT     : STD_LOGIC_VECTOR (7 downto 0) := x"04"; 
    constant GET_EXCLUDE_LEFT_RIGHT     : STD_LOGIC_VECTOR (7 downto 0) := x"04";   
    constant SET_PRODUCT_SEL            : STD_LOGIC_VECTOR (7 downto 0) := x"05"; 
    constant GET_PRODUCT_SEL            : STD_LOGIC_VECTOR (7 downto 0) := x"05";

    constant SET_OLED_ANALOG_VIDEO_OUT_SEL : STD_LOGIC_VECTOR (7 downto 0) := x"06"; 
    constant GET_OLED_ANALOG_VIDEO_OUT_SEL : STD_LOGIC_VECTOR (7 downto 0) := x"06";
    
    constant SET_LASER_EN               : STD_LOGIC_VECTOR (7 downto 0) := x"07"; 
    constant GET_LASER_EN               : STD_LOGIC_VECTOR (7 downto 0) := x"07";
        
    constant GET_SNAPSHOT_COUNTER       : STD_LOGIC_VECTOR (7 downto 0) := x"08";
    constant SET_SNAPSHOT_BURST_MODE_CAPTURE_SIZE : STD_LOGIC_VECTOR (7 downto 0) := x"09"; 
    constant GET_SNAPSHOT_BURST_MODE_CAPTURE_SIZE : STD_LOGIC_VECTOR (7 downto 0) := x"09";
    
    constant SET_TEMP_RANGE_UPDATE_TIMEOUT : STD_LOGIC_VECTOR (7 downto 0) := x"0A";
    constant GET_TEMP_RANGE_UPDATE_TIMEOUT : STD_LOGIC_VECTOR (7 downto 0) := x"0A";

    constant SET_MIPI_VIDEO_OUT_SEL     : STD_LOGIC_VECTOR (7 downto 0) := x"0B";
    constant GET_MIPI_VIDEO_OUT_SEL     : STD_LOGIC_VECTOR (7 downto 0) := x"0B";
        
    constant SET_DARK_PIX_TH             : STD_LOGIC_VECTOR (7 downto 0) := x"0C";
    constant GET_DARK_PIX_TH             : STD_LOGIC_VECTOR (7 downto 0) := x"0C";
    constant SET_SATURATED_PIX_TH        : STD_LOGIC_VECTOR (7 downto 0) := x"0D";
    constant GET_SATURATED_PIX_TH        : STD_LOGIC_VECTOR (7 downto 0) := x"0D";
    
    constant SET_I2C_DELAY_REG        : STD_LOGIC_VECTOR (7 downto 0) := x"0E";
    constant GET_I2C_DELAY_REG        : STD_LOGIC_VECTOR (7 downto 0) := x"0E";   
--    constant SET_MODULE_EN_DIS        : STD_LOGIC_VECTOR (7 downto 0) := x"0F";
--    constant GET_MODULE_EN_DIS        : STD_LOGIC_VECTOR (7 downto 0) := x"0F";

    constant SET_SIGHT_MODE           : STD_LOGIC_VECTOR (7 downto 0) := x"0F";
    constant GET_SIGHT_MODE           : STD_LOGIC_VECTOR (7 downto 0) := x"0F";

    constant SET_FPGA_VERSION         : STD_LOGIC_VECTOR (7 downto 0) := x"10";
    constant GET_FPGA_VERSION         : STD_LOGIC_VECTOR (7 downto 0) := x"10";
--  constant SET_PAL_NTSC_MODE        : STD_LOGIC_VECTOR (7 downto 0) := x"11";
--  constant GET_PAL_NTSC_MODE        : STD_LOGIC_VECTOR (7 downto 0) := x"11";
            
    constant SET_VIDEO_CTRL              : STD_LOGIC_VECTOR (7 downto 0) := x"20";
    constant GET_VIDEO_CTRL              : STD_LOGIC_VECTOR (7 downto 0) := x"20";
    constant SET_OLED_GAMMA_TABLE_SEL    : STD_LOGIC_VECTOR (7 downto 0) := x"21";
    constant GET_OLED_GAMMA_TABLE_SEL    : STD_LOGIC_VECTOR (7 downto 0) := x"21";
    constant SET_OLED_POS_V              : STD_LOGIC_VECTOR (7 downto 0) := x"22";
    constant GET_OLED_POS_V              : STD_LOGIC_VECTOR (7 downto 0) := x"22";
    constant SET_OLED_POS_H              : STD_LOGIC_VECTOR (7 downto 0) := x"23";
    constant GET_OLED_POS_H              : STD_LOGIC_VECTOR (7 downto 0) := x"23";  
    constant SET_OLED_BRIGHTNESS         : STD_LOGIC_VECTOR (7 downto 0) := x"24";
    constant GET_OLED_BRIGHTNESS         : STD_LOGIC_VECTOR (7 downto 0) := x"24";  
    constant SET_OLED_CONTRAST           : STD_LOGIC_VECTOR (7 downto 0) := x"25";
    constant GET_OLED_CONTRAST           : STD_LOGIC_VECTOR (7 downto 0) := x"25";  
    constant SET_OLED_IDRF               : STD_LOGIC_VECTOR (7 downto 0) := x"26"; 
    constant GET_OLED_IDRF               : STD_LOGIC_VECTOR (7 downto 0) := x"26";
    constant SET_OLED_DIMCTL             : STD_LOGIC_VECTOR (7 downto 0) := x"27";      
    constant GET_OLED_DIMCTL             : STD_LOGIC_VECTOR (7 downto 0) := x"27";
--    constant SET_MAX_VGN_SETTLE_TIME     : STD_LOGIC_VECTOR (7 downto 0) := x"28";
--    constant GET_MAX_VGN_SETTLE_TIME     : STD_LOGIC_VECTOR (7 downto 0) := x"28";
    constant SET_OLED_CATHODE_VOLTAGE    : STD_LOGIC_VECTOR (7 downto 0) := x"28";
    constant GET_OLED_CATHODE_VOLTAGE    : STD_LOGIC_VECTOR (7 downto 0) := x"28";
    constant SET_MAX_OLED_VGN_RD_PERIOD  : STD_LOGIC_VECTOR (7 downto 0) := x"29";
    constant GET_MAX_OLED_VGN_RD_PERIOD  : STD_LOGIC_VECTOR (7 downto 0) := x"29";   
    constant SET_MAX_BAT_PARAM_RD_PERIOD : STD_LOGIC_VECTOR (7 downto 0) := x"2A";
    constant GET_MAX_BAT_PARAM_RD_PERIOD : STD_LOGIC_VECTOR (7 downto 0) := x"2A";
    
  
    
--  constant GET_TEMP_AVG_LINE        : STD_LOGIC_VECTOR (7 downto 0) := x"31";
    constant SET_TEMPERATURE_OFFSET   : STD_LOGIC_VECTOR (7 downto 0) := x"40";
    constant GET_TEMPERATURE_OFFSET   : STD_LOGIC_VECTOR (7 downto 0) := x"40";
    constant GET_TEMP_AVG_FRAME       : STD_LOGIC_VECTOR (7 downto 0) := x"41";
--  constant SET_VIDEO_CHANNEL_SEL    : STD_LOGIC_VECTOR (7 downto 0) := x"51";
--  constant GET_VIDEO_CHANNEL_SEL    : STD_LOGIC_VECTOR (7 downto 0) := x"51";
--  constant SET_CAPTURE              : STD_LOGIC_VECTOR (7 downto 0) := x"23";
--  constant GET_CAPTURE              : STD_LOGIC_VECTOR (7 downto 0) := x"23";
--  constant SET_CLIP_THRESHOLD       : STD_LOGIC_VECTOR (7 downto 0) := x"71";
--  constant GET_CLIP_THRESHOLD       : STD_LOGIC_VECTOR (7 downto 0) := x"71";
    constant SET_OFFSET_TBALE_FORCE      : STD_LOGIC_VECTOR (7 downto 0) := x"12";
    constant GET_OFFSET_TBALE_FORCE      : STD_LOGIC_VECTOR (7 downto 0) := x"12";
    constant SET_THRESHOLD_SOBL          : STD_LOGIC_VECTOR (7 downto 0) := x"13";
    constant GET_THRESHOLD_SOBL          : STD_LOGIC_VECTOR (7 downto 0) := x"13";
--    constant SET_ALPHA                   : STD_LOGIC_VECTOR (7 downto 0) := x"14";
--    constant GET_ALPHA                   : STD_LOGIC_VECTOR (7 downto 0) := x"14";
    constant SET_RETICLE_COLOR_SEL       : STD_LOGIC_VECTOR (7 downto 0) := x"14";
    constant GET_RETICLE_COLOR_SEL       : STD_LOGIC_VECTOR (7 downto 0) := x"14";
    constant GET_RETICLE_COLOR1          : STD_LOGIC_VECTOR (7 downto 0) := x"15";
    constant SET_RETICLE_COLOR1          : STD_LOGIC_VECTOR (7 downto 0) := x"15";
    constant GET_RETICLE_COLOR2          : STD_LOGIC_VECTOR (7 downto 0) := x"16";
    constant SET_RETICLE_COLOR2          : STD_LOGIC_VECTOR (7 downto 0) := x"16";
    constant GET_RETICLE_POS_X           : STD_LOGIC_VECTOR (7 downto 0) := x"17";
    constant SET_RETICLE_POS_X           : STD_LOGIC_VECTOR (7 downto 0) := x"17";
    constant GET_RETICLE_POS_Y           : STD_LOGIC_VECTOR (7 downto 0) := x"18";
    constant SET_RETICLE_POS_Y           : STD_LOGIC_VECTOR (7 downto 0) := x"18"; 
    constant SET_PRESET_SEL              : STD_LOGIC_VECTOR (7 downto 0) := x"19";
    constant GET_PRESET_SEL              : STD_LOGIC_VECTOR (7 downto 0) := x"19";  
    constant SET_PRESET_P1_POS           : STD_LOGIC_VECTOR (7 downto 0) := x"1A";
    constant GET_PRESET_P1_POS           : STD_LOGIC_VECTOR (7 downto 0) := x"1A";
    constant SET_PRESET_P2_POS           : STD_LOGIC_VECTOR (7 downto 0) := x"1B";
    constant GET_PRESET_P2_POS           : STD_LOGIC_VECTOR (7 downto 0) := x"1B";   
    constant SET_PRESET_P3_POS           : STD_LOGIC_VECTOR (7 downto 0) := x"1C";
    constant GET_PRESET_P3_POS           : STD_LOGIC_VECTOR (7 downto 0) := x"1C";
    constant SET_PRESET_P4_POS           : STD_LOGIC_VECTOR (7 downto 0) := x"1D";
    constant GET_PRESET_P4_POS           : STD_LOGIC_VECTOR (7 downto 0) := x"1D";       
    constant SET_ENABLE_PRESET_INFO_DISP : STD_LOGIC_VECTOR (7 downto 0) := x"1E";
    constant GET_ENABLE_PRESET_INFO_DISP : STD_LOGIC_VECTOR (7 downto 0) := x"1E";
 
    constant SET_PRESET_INFO_DISP_POS_X  : STD_LOGIC_VECTOR (7 downto 0) := x"7B";
    constant GET_PRESET_INFO_DISP_POS_X  : STD_LOGIC_VECTOR (7 downto 0) := x"7B";   
    constant SET_PRESET_INFO_DISP_POS_Y  : STD_LOGIC_VECTOR (7 downto 0) := x"7C";
    constant GET_PRESET_INFO_DISP_POS_Y  : STD_LOGIC_VECTOR (7 downto 0) := x"7C";
 
    constant SET_BAD_BLIND_PIX_LOW_TH   : STD_LOGIC_VECTOR (7 downto 0) := x"7D";
    constant GET_BAD_BLIND_PIX_LOW_TH   : STD_LOGIC_VECTOR (7 downto 0) := x"7D";   
    constant SET_BAD_BLIND_PIX_HIGH_TH  : STD_LOGIC_VECTOR (7 downto 0) := x"7E";
    constant GET_BAD_BLIND_PIX_HIGH_TH  : STD_LOGIC_VECTOR (7 downto 0) := x"7E";

    constant SET_BLADE_MODE              : STD_LOGIC_VECTOR (7 downto 0) := x"80";
    constant GET_BLADE_MODE              : STD_LOGIC_VECTOR (7 downto 0) := x"80";
    constant SET_NUC_MODE                : STD_LOGIC_VECTOR (7 downto 0) := x"81";
    constant GET_NUC_MODE                : STD_LOGIC_VECTOR (7 downto 0) := x"81";
                 
    constant GET_LOGO_COLOR1             : STD_LOGIC_VECTOR (7 downto 0) := x"82";
    constant SET_LOGO_COLOR1             : STD_LOGIC_VECTOR (7 downto 0) := x"82";
    constant GET_LOGO_COLOR2             : STD_LOGIC_VECTOR (7 downto 0) := x"83";
    constant SET_LOGO_COLOR2             : STD_LOGIC_VECTOR (7 downto 0) := x"83";
    constant GET_LOGO_POS_X              : STD_LOGIC_VECTOR (7 downto 0) := x"84";
    constant SET_LOGO_POS_X              : STD_LOGIC_VECTOR (7 downto 0) := x"84";
    constant GET_LOGO_POS_Y              : STD_LOGIC_VECTOR (7 downto 0) := x"85";
    constant SET_LOGO_POS_Y              : STD_LOGIC_VECTOR (7 downto 0) := x"85";
    constant GET_ZOOM_MODE               : STD_LOGIC_VECTOR (7 downto 0) := x"86";
    constant SET_ZOOM_MODE               : STD_LOGIC_VECTOR (7 downto 0) := x"86";
    
--    constant GET_IMG_SHIFT_POS_X      : STD_LOGIC_VECTOR (7 downto 0) := x"37";
--    constant GET_IMG_SHIFT_POS_Y      : STD_LOGIC_VECTOR (7 downto 0) := x"38";
--    constant GET_PIX_POS              : STD_LOGIC_VECTOR (7 downto 0) := x"39";
--    constant SET_PIX_POS              : STD_LOGIC_VECTOR (7 downto 0) := x"39";
    constant SET_OLED_IMG_FLIP        : STD_LOGIC_VECTOR (7 downto 0) := x"42";
    constant GET_OLED_IMG_FLIP        : STD_LOGIC_VECTOR (7 downto 0) := x"42";
    constant SET_IMG_FLIP             : STD_LOGIC_VECTOR (7 downto 0) := x"43";
    constant GET_IMG_FLIP             : STD_LOGIC_VECTOR (7 downto 0) := x"43";
--    constant SET_IMG_FLIP_V          : STD_LOGIC_VECTOR (7 downto 0) := x"43";
--    constant GET_IMG_FLIP_V          : STD_LOGIC_VECTOR (7 downto 0) := x"43";

    constant SET_ROI_X_OFFSET         : STD_LOGIC_VECTOR (7 downto 0) := x"44";
    constant GET_ROI_X_OFFSET         : STD_LOGIC_VECTOR (7 downto 0) := x"44";     
    constant SET_ROI_Y_OFFSET         : STD_LOGIC_VECTOR (7 downto 0) := x"45"; 
    constant GET_ROI_Y_OFFSET         : STD_LOGIC_VECTOR (7 downto 0) := x"45";   
    constant SET_ROI_X_SIZE           : STD_LOGIC_VECTOR (7 downto 0) := x"46";
    constant GET_ROI_X_SIZE           : STD_LOGIC_VECTOR (7 downto 0) := x"46";     
    constant SET_ROI_Y_SIZE           : STD_LOGIC_VECTOR (7 downto 0) := x"47";
    constant GET_ROI_Y_SIZE           : STD_LOGIC_VECTOR (7 downto 0) := x"47";   
    constant SET_AGC_MAX_GAIN         : STD_LOGIC_VECTOR (7 downto 0) := x"48"; 
    constant GET_AGC_MAX_GAIN         : STD_LOGIC_VECTOR (7 downto 0) := x"48"; 
    constant SET_ROI_MODE             : STD_LOGIC_VECTOR (7 downto 0) := x"49";
    constant GET_ROI_MODE             : STD_LOGIC_VECTOR (7 downto 0) := x"49";

    constant SET_GYRO_DATA_UPDATE_TIMEOUT : STD_LOGIC_VECTOR (7 downto 0) := x"4A"; 
    constant GET_GYRO_DATA_UPDATE_TIMEOUT : STD_LOGIC_VECTOR (7 downto 0) := x"4A";     
    constant SET_GYRO_DATA_DISP_EN        : STD_LOGIC_VECTOR (7 downto 0) := x"4B"; 
    constant GET_GYRO_DATA_DISP_EN        : STD_LOGIC_VECTOR (7 downto 0) := x"4B"; 
    constant GET_YAW                      : STD_LOGIC_VECTOR (7 downto 0) := x"4C";
    constant GET_PITCH                    : STD_LOGIC_VECTOR (7 downto 0) := x"4D";
    constant GET_ROLL                     : STD_LOGIC_VECTOR (7 downto 0) := x"4E";
    
    constant SET_YAW_OFFSET               : STD_LOGIC_VECTOR (7 downto 0)  := x"5C"; 
    constant GET_YAW_OFFSET               : STD_LOGIC_VECTOR (7 downto 0)  := x"5C";
    constant SET_PITCH_OFFSET             : STD_LOGIC_VECTOR (7 downto 0)  := x"5D"; 
    constant GET_PITCH_OFFSET             : STD_LOGIC_VECTOR (7 downto 0)  := x"5D";
        
    constant SET_NUC_TIME_GAP           : STD_LOGIC_VECTOR (7 downto 0) := x"90";
    constant GET_NUC_TIME_GAP           : STD_LOGIC_VECTOR (7 downto 0) := x"90";
    constant SET_NUC1PT_CTRL            : STD_LOGIC_VECTOR (7 downto 0) := x"91";
    constant GET_NUC1PT_CTRL            : STD_LOGIC_VECTOR (7 downto 0) := x"91";
    constant SET_NUC1PT_CAPTURE_FRAMES  : STD_LOGIC_VECTOR (7 downto 0) := x"92"; 
    constant GET_NUC1PT_CAPTURE_FRAMES  : STD_LOGIC_VECTOR (7 downto 0) := x"92";   
    
    constant GET_OFFSET_TABLE_AVG       : STD_LOGIC_VECTOR (7 downto 0) := x"93";
    constant GET_GAIN_TABLE_SEL         : STD_LOGIC_VECTOR (7 downto 0) := x"94";
    constant SET_GAIN_TABLE_SEL         : STD_LOGIC_VECTOR (7 downto 0) := x"94";
    constant SET_GAIN_IMG_STORE_ADDR    : STD_LOGIC_VECTOR (7 downto 0) := x"95";
    constant GET_GAIN_IMG_STORE_ADDR    : STD_LOGIC_VECTOR (7 downto 0) := x"95";
    constant SET_GAIN_CALC_CTRL         : STD_LOGIC_VECTOR (7 downto 0) := x"96";
    constant GET_GAIN_CALC_CTRL         : STD_LOGIC_VECTOR (7 downto 0) := x"96"; 
    constant SET_TEMP_RANGE             : STD_LOGIC_VECTOR (7 downto 0) := x"97";          
    constant GET_TEMP_RANGE             : STD_LOGIC_VECTOR (7 downto 0) := x"97";
  
--    constant SET_IMG_SHIFT_LEFT         : STD_LOGIC_VECTOR (7 downto 0) := x"77";
--    constant GET_IMG_SHIFT_LEFT         : STD_LOGIC_VECTOR (7 downto 0) := x"77";
--    constant SET_IMG_SHIFT_RIGHT        : STD_LOGIC_VECTOR (7 downto 0) := x"78";
--    constant GET_IMG_SHIFT_RIGHT        : STD_LOGIC_VECTOR (7 downto 0) := x"78";
--    constant SET_IMG_SHIFT_UP           : STD_LOGIC_VECTOR (7 downto 0) := x"79";
--    constant GET_IMG_SHIFT_UP           : STD_LOGIC_VECTOR (7 downto 0) := x"79";
--    constant SET_IMG_SHIFT_DOWN         : STD_LOGIC_VECTOR (7 downto 0) := x"7A";
--    constant GET_IMG_SHIFT_DOWN         : STD_LOGIC_VECTOR (7 downto 0) := x"7A";

    constant SET_IMG_SHIFT_VERT           : STD_LOGIC_VECTOR (7 downto 0) := x"79";
    constant GET_IMG_SHIFT_VERT           : STD_LOGIC_VECTOR (7 downto 0) := x"79";
    constant SET_IMG_UP_SHIFT_VERT        : STD_LOGIC_VECTOR (7 downto 0) := x"7A";
    constant GET_IMG_UP_SHIFT_VERT        : STD_LOGIC_VECTOR (7 downto 0) := x"7A";
    
    constant SET_IMG_CROP_LEFT          : STD_LOGIC_VECTOR (7 downto 0) := x"89";
    constant GET_IMG_CROP_LEFT          : STD_LOGIC_VECTOR (7 downto 0) := x"89";
    constant SET_IMG_CROP_RIGHT         : STD_LOGIC_VECTOR (7 downto 0) := x"8A";
    constant GET_IMG_CROP_RIGHT         : STD_LOGIC_VECTOR (7 downto 0) := x"8A";
    constant SET_IMG_CROP_TOP           : STD_LOGIC_VECTOR (7 downto 0) := x"8B";
    constant GET_IMG_CROP_TOP           : STD_LOGIC_VECTOR (7 downto 0) := x"8B";
    constant SET_IMG_CROP_BOTTOM        : STD_LOGIC_VECTOR (7 downto 0) := x"8C";
    constant GET_IMG_CROP_BOTTOM        : STD_LOGIC_VECTOR (7 downto 0) := x"8C";
    
    constant SET_FIT_TO_SCREEN_EN       : STD_LOGIC_VECTOR (7 downto 0) := x"8D";
    constant GET_FIT_TO_SCREEN_EN       : STD_LOGIC_VECTOR (7 downto 0) := x"8D";
    
    constant SET_CO_TRIGGER_CALC : STD_LOGIC_VECTOR (7 downto 0) := x"98";
    constant GET_CO_TRIGGER_STATUS_CALC : STD_LOGIC_VECTOR (7 downto 0) := x"98";
    constant SET_CO_PIX_ADDR: STD_LOGIC_VECTOR (7 downto 0) := x"99";
    constant GET_CO_PIX_ADDR: STD_LOGIC_VECTOR (7 downto 0) := x"99";
    constant SET_CO_CO_ADDR: STD_LOGIC_VECTOR (7 downto 0) := x"9A";
    constant GET_CO_CO_ADDR: STD_LOGIC_VECTOR (7 downto 0) := x"9A";
    constant SET_CO_MODE: std_logic_vector(7 downto 0):= x"9B";
    constant SET_CO_CALC_MODE: std_logic_vector(7 downto 0):= x"9C";
    constant GET_CO_CALC_MODE: std_logic_vector(7 downto 0):= x"9C";
    constant SET_CO_DC: std_logic_vector(7 downto 0):=x"9D";
    constant GET_CO_DC: std_logic_vector(7 downto 0):=x"9D";
    --constant EN_PERFORM_IMG_AVG: std_logic_vector(7 downto 0):=x"A0";

    constant SET_AUTO_SHUTTER_TIMEOUT  : STD_LOGIC_VECTOR (7 downto 0) := x"9E";
    constant GET_AUTO_SHUTTER_TIMEOUT  : STD_LOGIC_VECTOR (7 downto 0) := x"9E"; 
    
    constant SET_FRAME_COUNTER_NUC1PT_DELAY  : STD_LOGIC_VECTOR (7 downto 0) := x"9F";
    constant GET_FRAME_COUNTER_NUC1PT_DELAY  : STD_LOGIC_VECTOR (7 downto 0) := x"9F"; 
  
    constant SET_EDGE_LEVEL             : STD_LOGIC_VECTOR (7 downto 0) := x"4F";
    constant GET_EDGE_LEVEL             : STD_LOGIC_VECTOR (7 downto 0) := x"4F"; 
    constant SET_EDGE_FILTER_EN         : STD_LOGIC_VECTOR (7 downto 0) := x"50";
    constant GET_EDGE_FILTER_EN         : STD_LOGIC_VECTOR (7 downto 0) := x"50"; 
    constant SET_AGC_MODE               : STD_LOGIC_VECTOR (7 downto 0) := x"51";  
    constant GET_AGC_MODE               : STD_LOGIC_VECTOR (7 downto 0) := x"51";       
    constant SET_POLARITY               : STD_LOGIC_VECTOR (7 downto 0) := x"52";  
    constant GET_POLARITY               : STD_LOGIC_VECTOR (7 downto 0) := x"52"; 
    
    constant SET_TEST_PATTERN_EN        : STD_LOGIC_VECTOR (7 downto 0) := x"53"; 
    constant GET_TEST_PATTERN_EN        : STD_LOGIC_VECTOR (7 downto 0) := x"53"; 
    constant SET_NUC_EN                 : STD_LOGIC_VECTOR (7 downto 0) := x"54"; 
    constant GET_NUC_EN                 : STD_LOGIC_VECTOR (7 downto 0) := x"54"; 
    constant SET_SOFTNUC_EN             : STD_LOGIC_VECTOR (7 downto 0) := x"55"; 
    constant GET_SOFTNUC_EN             : STD_LOGIC_VECTOR (7 downto 0) := x"55"; 
    constant SET_RETICLE_EN             : STD_LOGIC_VECTOR (7 downto 0) := x"56";  
    constant GET_RETICLE_EN             : STD_LOGIC_VECTOR (7 downto 0) := x"56";
    constant SET_COLOR_PALETTE_EN       : STD_LOGIC_VECTOR (7 downto 0) := x"57";
    constant GET_COLOR_PALETTE_EN       : STD_LOGIC_VECTOR (7 downto 0) := x"57";  
    constant SET_COLOR_PALETTE_MODE     : STD_LOGIC_VECTOR (7 downto 0) := x"58";
    constant GET_COLOR_PALETTE_MODE     : STD_LOGIC_VECTOR (7 downto 0) := x"58";  
    constant SET_LOGO_EN                : STD_LOGIC_VECTOR (7 downto 0) := x"59";
    constant GET_LOGO_EN                : STD_LOGIC_VECTOR (7 downto 0) := x"59";  
    constant SET_BADPIXREM_EN           : STD_LOGIC_VECTOR (7 downto 0) := x"60"; 
    constant GET_BADPIXREM_EN           : STD_LOGIC_VECTOR (7 downto 0) := x"60"; 
--    constant SET_AV_KERN_ADDR_DATA_SFILT: STD_LOGIC_VECTOR (7 downto 0) := x"61";    
--    constant GET_AV_KERN_ADDR_DATA_SFILT: STD_LOGIC_VECTOR (7 downto 0) := x"61";    
    constant SET_SHARPNESS              : STD_LOGIC_VECTOR (7 downto 0) := x"61";    
    constant GET_SHARPNESS              : STD_LOGIC_VECTOR (7 downto 0) := x"61";
    constant SET_SHARPNENING_FILTER_EN  : STD_LOGIC_VECTOR (7 downto 0) := x"62";
    constant GET_SHARPNENING_FILTER_EN  : STD_LOGIC_VECTOR (7 downto 0) := x"62";  
    constant SET_BRIGHT_CONTRAST_EN     : STD_LOGIC_VECTOR (7 downto 0) := x"63";
    constant GET_BRIGHT_CONTRAST_EN     : STD_LOGIC_VECTOR (7 downto 0) := x"63";  
    constant SET_SMOOTH_FILTER_EN       : STD_LOGIC_VECTOR (7 downto 0) := x"64";
    constant GET_SMOOTH_FILTER_EN       : STD_LOGIC_VECTOR (7 downto 0) := x"64";  
    constant SET_ZOOM_EN                : STD_LOGIC_VECTOR (7 downto 0) := x"65";
    constant GET_ZOOM_EN                : STD_LOGIC_VECTOR (7 downto 0) := x"65";
    constant SET_RETICLE_TYPE           : STD_LOGIC_VECTOR (7 downto 0) := x"66";
    constant GET_RETICLE_TYPE           : STD_LOGIC_VECTOR (7 downto 0) := x"66";
    constant SET_CP_MIN_MAX_VAL         : STD_LOGIC_VECTOR (7 downto 0) := x"67";
    constant GET_CP_MIN_MAX_VAL         : STD_LOGIC_VECTOR (7 downto 0) := x"67";
    constant SET_BPC_TH                 : STD_LOGIC_VECTOR (7 downto 0) := x"68";
    constant GET_BPC_TH                 : STD_LOGIC_VECTOR (7 downto 0) := x"68";
    
    constant GET_IMG_MIN                : STD_LOGIC_VECTOR (7 downto 0) := x"69";
    constant GET_IMG_MAX                : STD_LOGIC_VECTOR (7 downto 0) := x"70";
    constant GET_IMG_AVG                : STD_LOGIC_VECTOR (7 downto 0) := x"71";
    
    constant GET_CUR_OFF_TABLE          : STD_LOGIC_VECTOR (7 downto 0) := x"72"; 
    constant GET_CUR_GAIN_TABLE         : STD_LOGIC_VECTOR (7 downto 0) := x"73";
    constant GET_CUR_TEMP_AREA          : STD_LOGIC_VECTOR (7 downto 0) := x"74";
    
    constant SET_RETICLE_POS_CENTER     : STD_LOGIC_VECTOR (7 downto 0) := x"75";
    constant SET_RETICLE_SEL            : STD_LOGIC_VECTOR (7 downto 0) := x"76";
    constant GET_RETICLE_SEL            : STD_LOGIC_VECTOR (7 downto 0) := x"76";
    
    constant SET_IMG_MIN_LIMIT          : STD_LOGIC_VECTOR (7 downto 0) := x"87";  
    constant GET_IMG_MIN_LIMIT          : STD_LOGIC_VECTOR (7 downto 0) := x"87";
    constant SET_IMG_MAX_LIMIT          : STD_LOGIC_VECTOR (7 downto 0) := x"88";
    constant GET_IMG_MAX_LIMIT          : STD_LOGIC_VECTOR (7 downto 0) := x"88";
    
    constant SET_CNTRL_MIN_DPHE         : STD_LOGIC_VECTOR (7 downto 0) := x"A0";
    constant GET_CNTRL_MIN_DPHE         : STD_LOGIC_VECTOR (7 downto 0) := x"A0";
    constant SET_CNTRL_MAX_DPHE         : STD_LOGIC_VECTOR (7 downto 0) := x"A1";
    constant GET_CNTRL_MAX_DPHE         : STD_LOGIC_VECTOR (7 downto 0) := x"A1";
    constant SET_CNTRL_HIST1_DPHE       : STD_LOGIC_VECTOR (7 downto 0) := x"A2";
    constant GET_CNTRL_HIST1_DPHE       : STD_LOGIC_VECTOR (7 downto 0) := x"A2";
    constant SET_CNTRL_HIST2_DPHE       : STD_LOGIC_VECTOR (7 downto 0) := x"A3";
    constant GET_CNTRL_HIST2_DPHE       : STD_LOGIC_VECTOR (7 downto 0) := x"A3";
    constant SET_CNTRL_CLIP_DPHE        : STD_LOGIC_VECTOR (7 downto 0) := x"A4";
    constant GET_CNTRL_CLIP_DPHE        : STD_LOGIC_VECTOR (7 downto 0) := x"A4";
    constant SET_MAX_LIMITER_DPHE       : STD_LOGIC_VECTOR (7 downto 0) := x"A5";
    constant GET_MAX_LIMITER_DPHE       : STD_LOGIC_VECTOR (7 downto 0) := x"A5";
    constant SET_MUL_MAX_LIMITER_DPHE   : STD_LOGIC_VECTOR (7 downto 0) := x"3A";
    constant GET_MUL_MAX_LIMITER_DPHE   : STD_LOGIC_VECTOR (7 downto 0) := x"3A";

    constant SET_CNTRL_MIN_HISTEQ     : STD_LOGIC_VECTOR (7 downto 0) := x"A6"; 
    constant GET_CNTRL_MIN_HISTEQ     : STD_LOGIC_VECTOR (7 downto 0) := x"A6";   
    constant SET_CNTRL_MAX_HISTEQ     : STD_LOGIC_VECTOR (7 downto 0) := x"A7";
    constant GET_CNTRL_MAX_HISTEQ     : STD_LOGIC_VECTOR (7 downto 0) := x"A7";
    constant SET_CNTRL_HISTORY_HISTEQ : STD_LOGIC_VECTOR (7 downto 0) := x"A8";
    constant GET_CNTRL_HISTORY_HISTEQ : STD_LOGIC_VECTOR (7 downto 0) := x"A8";
    constant SET_CNTRL_MAX_GAIN       : STD_LOGIC_VECTOR (7 downto 0) := x"A9";
    constant GET_CNTRL_MAX_GAIN       : STD_LOGIC_VECTOR (7 downto 0) := x"A9";
    constant SET_CNTRL_IPP            : STD_LOGIC_VECTOR (7 downto 0) := x"AA";
    constant GET_CNTRL_IPP            : STD_LOGIC_VECTOR (7 downto 0) := x"AA";
    
    constant SET_BH_OFFSET            : STD_LOGIC_VECTOR (7 downto 0) := x"AB";
    constant GET_BH_OFFSET            : STD_LOGIC_VECTOR (7 downto 0) := x"AB";  

    constant GET_X_ACCEL              : STD_LOGIC_VECTOR (7 downto 0) := x"AC";
    constant GET_Y_ACCEL              : STD_LOGIC_VECTOR (7 downto 0) := x"AD";
    constant GET_Z_ACCEL              : STD_LOGIC_VECTOR (7 downto 0) := x"AE";
    
--    constant ADDR_CNTRL_MIN_HISTEQ     : STD_LOGIC_VECTOR (7 downto 0) := x"C0";    
--    constant ADDR_CNTRL_MAX_HISTEQ     : STD_LOGIC_VECTOR (7 downto 0) := x"C4";
--    constant ADDR_CNTRL_HISTORY_HISTEQ : STD_LOGIC_VECTOR (7 downto 0) := x"C8";
    
    constant SET_BRIGHTNESS        : STD_LOGIC_VECTOR (7 downto 0) := x"D0"; 
    constant GET_BRIGHTNESS        : STD_LOGIC_VECTOR (7 downto 0) := x"D0";
    constant SET_BRIGHTNESS_OFFSET : STD_LOGIC_VECTOR (7 downto 0) := x"D1";
    constant GET_BRIGHTNESS_OFFSET : STD_LOGIC_VECTOR (7 downto 0) := x"D1";  
    constant SET_CONTRAST_OFFSET   : STD_LOGIC_VECTOR (7 downto 0) := x"D2";
    constant GET_CONTRAST_OFFSET   : STD_LOGIC_VECTOR (7 downto 0) := x"D2";
    constant SET_CONTRAST          : STD_LOGIC_VECTOR (7 downto 0) := x"D4";
    constant GET_CONTRAST          : STD_LOGIC_VECTOR (7 downto 0) := x"D4";
    
    constant SET_CONSTANT_CB_CR    : STD_LOGIC_VECTOR (7 downto 0) := x"D3";
    constant GET_CONSTANT_CB_CR    : STD_LOGIC_VECTOR (7 downto 0) := x"D3";

    constant SET_OLED_OSD_POS_X_LY1 : STD_LOGIC_VECTOR (7 downto 0) := x"B0";
    constant GET_OLED_OSD_POS_X_LY1 : STD_LOGIC_VECTOR (7 downto 0) := x"B0";   
    constant SET_OLED_OSD_POS_Y_LY1 : STD_LOGIC_VECTOR (7 downto 0) := x"B1";
    constant GET_OLED_OSD_POS_Y_LY1 : STD_LOGIC_VECTOR (7 downto 0) := x"B1";
    constant SET_BPR_OSD_POS_X_LY1  : STD_LOGIC_VECTOR (7 downto 0) := x"B2";
    constant GET_BPR_OSD_POS_X_LY1  : STD_LOGIC_VECTOR (7 downto 0) := x"B2";   
    constant SET_BPR_OSD_POS_Y_LY1  : STD_LOGIC_VECTOR (7 downto 0) := x"B3";
    constant GET_BPR_OSD_POS_Y_LY1  : STD_LOGIC_VECTOR (7 downto 0) := x"B3";

    constant SET_IMG_Y_OFFSET  : STD_LOGIC_VECTOR (7 downto 0) := x"B4";
    constant GET_IMG_Y_OFFSET  : STD_LOGIC_VECTOR (7 downto 0) := x"B4";

    constant SET_GYRO_DATA_DISP_POS_X_LY1  : STD_LOGIC_VECTOR (7 downto 0) := x"B5";
    constant GET_GYRO_DATA_DISP_POS_X_LY1  : STD_LOGIC_VECTOR (7 downto 0) := x"B5";
    constant SET_GYRO_DATA_DISP_POS_Y_LY1  : STD_LOGIC_VECTOR (7 downto 0) := x"B6";
    constant GET_GYRO_DATA_DISP_POS_Y_LY1  : STD_LOGIC_VECTOR (7 downto 0) := x"B6";

    constant SET_GYRO_DATA_DISP_POS_X_LY2  : STD_LOGIC_VECTOR (7 downto 0) := x"B7";
    constant GET_GYRO_DATA_DISP_POS_X_LY2  : STD_LOGIC_VECTOR (7 downto 0) := x"B7";
    constant SET_GYRO_DATA_DISP_POS_Y_LY2  : STD_LOGIC_VECTOR (7 downto 0) := x"B8";
    constant GET_GYRO_DATA_DISP_POS_Y_LY2  : STD_LOGIC_VECTOR (7 downto 0) := x"B8";
        
    constant SET_OSD_EN              : STD_LOGIC_VECTOR (7 downto 0) := x"B9";
    constant GET_OSD_EN              : STD_LOGIC_VECTOR (7 downto 0) := x"B9";
    constant SET_OSD_TIMEOUT         : STD_LOGIC_VECTOR (7 downto 0) := x"BA";   
    constant GET_OSD_TIMEOUT         : STD_LOGIC_VECTOR (7 downto 0) := x"BA";
    constant SET_CURSOR_COLOR_INFO   : STD_LOGIC_VECTOR (7 downto 0) := x"BB";
    constant GET_CURSOR_COLOR_INFO   : STD_LOGIC_VECTOR (7 downto 0) := x"BB";
    constant SET_OSD_COLOR_INFO      : STD_LOGIC_VECTOR (7 downto 0) := x"BC";
    constant GET_OSD_COLOR_INFO      : STD_LOGIC_VECTOR (7 downto 0) := x"BC";
    constant SET_OSD_CH_COLOR_INFO1  : STD_LOGIC_VECTOR (7 downto 0) := x"BD"; 
    constant GET_OSD_CH_COLOR_INFO1  : STD_LOGIC_VECTOR (7 downto 0) := x"BD";  
    constant SET_OSD_CH_COLOR_INFO2  : STD_LOGIC_VECTOR (7 downto 0) := x"BE"; 
    constant GET_OSD_CH_COLOR_INFO2  : STD_LOGIC_VECTOR (7 downto 0) := x"BE";     
    constant SET_OSD_MODE            : STD_LOGIC_VECTOR (7 downto 0) := x"BF";
    constant GET_OSD_MODE            : STD_LOGIC_VECTOR (7 downto 0) := x"BF";    
    constant SET_OSD_POS_X_LY1_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C0"; 
    constant GET_OSD_POS_X_LY1_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C0";
    constant SET_OSD_POS_Y_LY1_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C1"; 
    constant GET_OSD_POS_Y_LY1_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C1";
    constant SET_OSD_POS_X_LY2_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C2"; 
    constant GET_OSD_POS_X_LY2_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C2"; 
    constant SET_OSD_POS_Y_LY2_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C3"; 
    constant GET_OSD_POS_Y_LY2_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C3";
    constant SET_OSD_POS_X_LY3_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C4"; 
    constant GET_OSD_POS_X_LY3_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C4"; 
    constant SET_OSD_POS_Y_LY3_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C5"; 
    constant GET_OSD_POS_Y_LY3_MODE1 : STD_LOGIC_VECTOR (7 downto 0) := x"C5";
    constant SET_OSD_POS_X_LY1_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"C6";
    constant GET_OSD_POS_X_LY1_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"C6";
    constant SET_OSD_POS_Y_LY1_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"C7";
    constant GET_OSD_POS_Y_LY1_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"C7";
    constant SET_OSD_POS_X_LY2_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"C8";
    constant GET_OSD_POS_X_LY2_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"C8";
    constant SET_OSD_POS_Y_LY2_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"C9";
    constant GET_OSD_POS_Y_LY2_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"C9";
    constant SET_OSD_POS_X_LY3_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"CA";
    constant GET_OSD_POS_X_LY3_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"CA";
    constant SET_OSD_POS_Y_LY3_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"CB";
    constant GET_OSD_POS_Y_LY3_MODE2 : STD_LOGIC_VECTOR (7 downto 0) := x"CB";   
    
    constant SET_TEMPERATURE_THRESHOLD                 : STD_LOGIC_VECTOR (7 downto 0) := x"CC";
    constant GET_TEMPERATURE_THRESHOLD                 : STD_LOGIC_VECTOR (7 downto 0) := x"CC";
    constant SET_LO_TO_HI_AREA_GLOBAL_OFFSET_FORCE_VAL : STD_LOGIC_VECTOR (7 downto 0) := x"CD";
    constant GET_LO_TO_HI_AREA_GLOBAL_OFFSET_FORCE_VAL : STD_LOGIC_VECTOR (7 downto 0) := x"CD"; 
    constant SET_HI_TO_LO_AREA_GLOBAL_OFFSET_FORCE_VAL : STD_LOGIC_VECTOR (7 downto 0) := x"CE"; 
    constant GET_HI_TO_LO_AREA_GLOBAL_OFFSET_FORCE_VAL : STD_LOGIC_VECTOR (7 downto 0) := x"CE";
    
    constant SET_ENABLE_SN_INFO_DISP      : STD_LOGIC_VECTOR (7 downto 0) := x"D7"; 
    constant GET_ENABLE_SN_INFO_DISP      : STD_LOGIC_VECTOR (7 downto 0) := x"D7";         
    constant SET_ENABLE_INFO_DISP         : STD_LOGIC_VECTOR (7 downto 0) := x"D8"; 
    constant GET_ENABLE_INFO_DISP         : STD_LOGIC_VECTOR (7 downto 0) := x"D8"; 
    constant SET_INFO_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0) := x"D9"; 
    constant GET_INFO_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0) := x"D9";
    constant SET_INFO_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0) := x"DA"; 
    constant GET_INFO_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0) := x"DA";
    constant SET_INFO_DISP_COLOR_INFO     : STD_LOGIC_VECTOR (7 downto 0) := x"DB"; 
    constant GET_INFO_DISP_COLOR_INFO     : STD_LOGIC_VECTOR (7 downto 0) := x"DB";  
    constant SET_INFO_DISP_CH_COLOR_INFO1 : STD_LOGIC_VECTOR (7 downto 0) := x"DC";
    constant GET_INFO_DISP_CH_COLOR_INFO1 : STD_LOGIC_VECTOR (7 downto 0) := x"DC"; 
    constant SET_INFO_DISP_CH_COLOR_INFO2 : STD_LOGIC_VECTOR (7 downto 0) := x"DD";
    constant GET_INFO_DISP_CH_COLOR_INFO2 : STD_LOGIC_VECTOR (7 downto 0) := x"DD";
    constant SET_SN_INFO_DISP_POS_X       : STD_LOGIC_VECTOR (7 downto 0) := x"DE"; 
    constant GET_SN_INFO_DISP_POS_X       : STD_LOGIC_VECTOR (7 downto 0) := x"DE";
    constant SET_SN_INFO_DISP_POS_Y       : STD_LOGIC_VECTOR (7 downto 0) := x"DF"; 
    constant GET_SN_INFO_DISP_POS_Y       : STD_LOGIC_VECTOR (7 downto 0) := x"DF";

    
    constant SET_ENABLE_BATTERY_DISP         : STD_LOGIC_VECTOR (7 downto 0) := x"E0"; 
    constant GET_ENABLE_BATTERY_DISP         : STD_LOGIC_VECTOR (7 downto 0) := x"E0"; 
--    constant SET_BATTERY_PERCENTAGE          : STD_LOGIC_VECTOR (7 downto 0) := x"E1"; 
--    constant GET_BATTERY_PERCENTAGE          : STD_LOGIC_VECTOR (7 downto 0) := x"E1"; 
    constant SET_BATTERY_DISP_TG_WAIT_FRAMES : STD_LOGIC_VECTOR (7 downto 0) := x"E1";  
    constant GET_BATTERY_DISP_TG_WAIT_FRAMES : STD_LOGIC_VECTOR (7 downto 0) := x"E1";   
    constant SET_BATTERY_PIX_MAP             : STD_LOGIC_VECTOR (7 downto 0) := x"E2"; 
    constant GET_BATTERY_PIX_MAP             : STD_LOGIC_VECTOR (7 downto 0) := x"E2"; 
    constant SET_BATTERY_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0) := x"E3"; 
    constant GET_BATTERY_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0) := x"E3";
    constant SET_BATTERY_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0) := x"E4"; 
    constant GET_BATTERY_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0) := x"E4";
    constant SET_BATTERY_DISP_REQ_XSIZE      : STD_LOGIC_VECTOR (7 downto 0) := x"E5"; 
    constant GET_BATTERY_DISP_REQ_XSIZE      : STD_LOGIC_VECTOR (7 downto 0) := x"E5";
    constant SET_BATTERY_DISP_REQ_YSIZE      : STD_LOGIC_VECTOR (7 downto 0) := x"E6"; 
    constant GET_BATTERY_DISP_REQ_YSIZE      : STD_LOGIC_VECTOR (7 downto 0) := x"E6";
    constant SET_BATTERY_DISP_COLOR_INFO     : STD_LOGIC_VECTOR (7 downto 0) := x"E7"; 
    constant GET_BATTERY_DISP_COLOR_INFO     : STD_LOGIC_VECTOR (7 downto 0) := x"E7";  
    constant SET_BATTERY_DISP_CH_COLOR_INFO1 : STD_LOGIC_VECTOR (7 downto 0) := x"E8";
    constant GET_BATTERY_DISP_CH_COLOR_INFO1 : STD_LOGIC_VECTOR (7 downto 0) := x"E8"; 
    constant SET_BATTERY_DISP_CH_COLOR_INFO2 : STD_LOGIC_VECTOR (7 downto 0) := x"E9";
    constant GET_BATTERY_DISP_CH_COLOR_INFO2 : STD_LOGIC_VECTOR (7 downto 0) := x"E9";
    constant SET_BATTERY_DISP_X_OFFSET       : STD_LOGIC_VECTOR (7 downto 0) := x"EA";
    constant GET_BATTERY_DISP_X_OFFSET       : STD_LOGIC_VECTOR (7 downto 0) := x"EA";
    constant SET_BATTERY_DISP_Y_OFFSET       : STD_LOGIC_VECTOR (7 downto 0) := x"EB";
    constant GET_BATTERY_DISP_Y_OFFSET       : STD_LOGIC_VECTOR (7 downto 0) := x"EB";
    constant SET_BATTERY_CHARGING_START      : STD_LOGIC_VECTOR (7 downto 0) := x"EC";
    constant GET_BATTERY_CHARGING_START      : STD_LOGIC_VECTOR (7 downto 0) := x"EC";
    constant SET_BATTERY_CHARGE_INC          : STD_LOGIC_VECTOR (7 downto 0) := x"ED";
    constant GET_BATTERY_CHARGE_INC          : STD_LOGIC_VECTOR (7 downto 0) := x"ED";

    constant SET_TARGET_VALUE_THRESHOLD      : STD_LOGIC_VECTOR (7 downto 0) := x"EE";
    constant GET_TARGET_VALUE_THRESHOLD      : STD_LOGIC_VECTOR (7 downto 0) := x"EE";
    
    constant SET_ENABLE_BAT_PER_DISP         : STD_LOGIC_VECTOR (7 downto 0) := x"F0"; 
    constant GET_ENABLE_BAT_PER_DISP         : STD_LOGIC_VECTOR (7 downto 0) := x"F0"; 
    constant SET_BAT_PER_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0) := x"F1"; 
    constant GET_BAT_PER_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0) := x"F1";
    constant SET_BAT_PER_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0) := x"F2"; 
    constant GET_BAT_PER_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0) := x"F2";
    constant SET_BAT_PER_DISP_REQ_XSIZE      : STD_LOGIC_VECTOR (7 downto 0) := x"F3"; 
    constant GET_BAT_PER_DISP_REQ_XSIZE      : STD_LOGIC_VECTOR (7 downto 0) := x"F3";
    constant SET_BAT_PER_DISP_REQ_YSIZE      : STD_LOGIC_VECTOR (7 downto 0) := x"F4"; 
    constant GET_BAT_PER_DISP_REQ_YSIZE      : STD_LOGIC_VECTOR (7 downto 0) := x"F4";
    constant SET_BAT_PER_DISP_COLOR_INFO     : STD_LOGIC_VECTOR (7 downto 0) := x"F5"; 
    constant GET_BAT_PER_DISP_COLOR_INFO     : STD_LOGIC_VECTOR (7 downto 0) := x"F5";  
    constant SET_BAT_PER_DISP_CH_COLOR_INFO1 : STD_LOGIC_VECTOR (7 downto 0) := x"F6";
    constant GET_BAT_PER_DISP_CH_COLOR_INFO1 : STD_LOGIC_VECTOR (7 downto 0) := x"F6"; 
    constant SET_BAT_PER_DISP_CH_COLOR_INFO2 : STD_LOGIC_VECTOR (7 downto 0) := x"F7";
    constant GET_BAT_PER_DISP_CH_COLOR_INFO2 : STD_LOGIC_VECTOR (7 downto 0) := x"F7";

    constant SET_ENABLE_BAT_CHG_SYMBOL       : STD_LOGIC_VECTOR (7 downto 0) := x"F8"; 
    constant GET_ENABLE_BAT_CHG_SYMBOL       : STD_LOGIC_VECTOR (7 downto 0) := x"F8"; 
    constant SET_BAT_CHG_SYMBOL_POS_OFFSET   : STD_LOGIC_VECTOR (7 downto 0) := x"F9"; 
    constant GET_BAT_CHG_SYMBOL_POS_OFFSET   : STD_LOGIC_VECTOR (7 downto 0) := x"F9";

    constant SET_BAT_PER_CONV_REG1           : STD_LOGIC_VECTOR (7 downto 0) := x"FA";
    constant GET_BAT_PER_CONV_REG1           : STD_LOGIC_VECTOR (7 downto 0) := x"FA"; 
    constant SET_BAT_PER_CONV_REG2           : STD_LOGIC_VECTOR (7 downto 0) := x"FB";
    constant GET_BAT_PER_CONV_REG2           : STD_LOGIC_VECTOR (7 downto 0) := x"FB";
    constant SET_BAT_PER_CONV_REG3           : STD_LOGIC_VECTOR (7 downto 0) := x"FC";
    constant GET_BAT_PER_CONV_REG3           : STD_LOGIC_VECTOR (7 downto 0) := x"FC";
    constant SET_BAT_PER_CONV_REG4           : STD_LOGIC_VECTOR (7 downto 0) := x"FD";
    constant GET_BAT_PER_CONV_REG4           : STD_LOGIC_VECTOR (7 downto 0) := x"FD";     
    constant SET_BAT_PER_CONV_REG5           : STD_LOGIC_VECTOR (7 downto 0) := x"FE";
    constant GET_BAT_PER_CONV_REG5           : STD_LOGIC_VECTOR (7 downto 0) := x"FE";
    constant SET_BAT_PER_CONV_REG6           : STD_LOGIC_VECTOR (7 downto 0) := x"FF";
    constant GET_BAT_PER_CONV_REG6           : STD_LOGIC_VECTOR (7 downto 0) := x"FF";

     
    constant SET_ENABLE_B_BAR_DISP        : STD_LOGIC_VECTOR (7 downto 0)   := x"5A"; 
    constant GET_ENABLE_B_BAR_DISP        : STD_LOGIC_VECTOR (7 downto 0)   := x"5A"; 
    constant SET_B_BAR_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0)  := x"5B"; 
    constant GET_B_BAR_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0)  := x"5B";
--    constant SET_B_BAR_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0)  := x"5C"; 
--    constant GET_B_BAR_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0)  := x"5C";
--    constant SET_B_BAR_DISP_REQ_XSIZE      : STD_LOGIC_VECTOR (7 downto 0)  := x"5D"; 
--    constant GET_B_BAR_DISP_REQ_XSIZE      : STD_LOGIC_VECTOR (7 downto 0)  := x"5D";
    constant SET_B_BAR_DISP_REQ_YSIZE      : STD_LOGIC_VECTOR (7 downto 0)  := x"5E"; 
    constant GET_B_BAR_DISP_REQ_YSIZE      : STD_LOGIC_VECTOR (7 downto 0)  := x"5E";
    constant SET_CB_BAR_DISP_COLOR_INFO    : STD_LOGIC_VECTOR (7 downto 0)  := x"5F";
    constant GET_CB_BAR_DISP_COLOR_INFO    : STD_LOGIC_VECTOR (7 downto 0)  := x"5F";
    constant SET_ENABLE_C_BAR_DISP         : STD_LOGIC_VECTOR (7 downto 0)  := x"6A"; 
    constant GET_ENABLE_C_BAR_DISP         : STD_LOGIC_VECTOR (7 downto 0)  := x"6A"; 
    constant SET_C_BAR_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0)  := x"6B"; 
    constant GET_C_BAR_DISP_POS_X          : STD_LOGIC_VECTOR (7 downto 0)  := x"6B";
    constant SET_C_BAR_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0)  := x"6C"; 
    constant GET_C_BAR_DISP_POS_Y          : STD_LOGIC_VECTOR (7 downto 0)  := x"6C";
    constant SET_C_BAR_DISP_REQ_XSIZE      : STD_LOGIC_VECTOR (7 downto 0)  := x"6D"; 
    constant GET_C_BAR_DISP_REQ_XSIZE      : STD_LOGIC_VECTOR (7 downto 0)  := x"6D";
--    constant SET_C_BAR_DISP_REQ_YSIZE      : STD_LOGIC_VECTOR (7 downto 0)  := x"6E"; 
--    constant GET_C_BAR_DISP_REQ_YSIZE      : STD_LOGIC_VECTOR (7 downto 0)  := x"6E";

    constant SET_WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE      : STD_LOGIC_VECTOR (7 downto 0)  := x"6E"; 
    constant GET_WAIT_NO_OF_FRAMES_TO_START_SDRAM_WRITE      : STD_LOGIC_VECTOR (7 downto 0)  := x"6E";

    constant SET_B_BAR_DISP_Y_OFFSET       : STD_LOGIC_VECTOR (7 downto 0)  := x"6F"; 
    constant GET_B_BAR_DISP_Y_OFFSET       : STD_LOGIC_VECTOR (7 downto 0)  := x"6F"; 
--    constant SET_C_BAR_DISP_X_OFFSET       : STD_LOGIC_VECTOR (7 downto 0)  := x"7F"; 
--    constant GET_C_BAR_DISP_X_OFFSET       : STD_LOGIC_VECTOR (7 downto 0)  := x"7F";  
    constant SET_GYRO_CALIB_START          : STD_LOGIC_VECTOR (7 downto 0)  := x"7F"; 
    constant GET_GYRO_CALIB_STATUS         : STD_LOGIC_VECTOR (7 downto 0)  := x"7F";  
    
    constant SET_CONTRAST_MODE_INFO_DISP_POS_X : STD_LOGIC_VECTOR (7 downto 0)  := x"8E";
    constant GET_CONTRAST_MODE_INFO_DISP_POS_X : STD_LOGIC_VECTOR (7 downto 0)  := x"8E";
    constant SET_CONTRAST_MODE_INFO_DISP_POS_Y : STD_LOGIC_VECTOR (7 downto 0)  := x"8F";
    constant GET_CONTRAST_MODE_INFO_DISP_POS_Y : STD_LOGIC_VECTOR (7 downto 0)  := x"8F";

    constant SET_MIN_TIME_GAP_PRESS_RELEASE     : STD_LOGIC_VECTOR (7 downto 0) := x"2B";
    constant GET_MIN_TIME_GAP_PRESS_RELEASE     : STD_LOGIC_VECTOR (7 downto 0) := x"2B";
    constant SET_BPR_DISP_EN_TIME_GAP           : STD_LOGIC_VECTOR (7 downto 0) := x"2C";
    constant GET_BPR_DISP_EN_TIME_GAP           : STD_LOGIC_VECTOR (7 downto 0) := x"2C";    
    constant SET_MAX_AGC_MODE_INFO_DISP_TIME    : STD_LOGIC_VECTOR (7 downto 0) := x"2D";
    constant GET_MAX_AGC_MODE_INFO_DISP_TIME    : STD_LOGIC_VECTOR (7 downto 0) := x"2D";
    constant SET_OLED_DISP_EN_TIME_GAP          : STD_LOGIC_VECTOR (7 downto 0) := x"2E";
    constant GET_OLED_DISP_EN_TIME_GAP          : STD_LOGIC_VECTOR (7 downto 0) := x"2E";
    constant SET_MAX_PRESET_SAVE_OK_DISP_FRAMES : STD_LOGIC_VECTOR (7 downto 0) := x"2F";  
    constant GET_MAX_PRESET_SAVE_OK_DISP_FRAMES : STD_LOGIC_VECTOR (7 downto 0) := x"2F";
    constant SET_MAX_RELEASE_WAIT_TIME          : STD_LOGIC_VECTOR (7 downto 0) := x"30";
    constant GET_MAX_RELEASE_WAIT_TIME          : STD_LOGIC_VECTOR (7 downto 0) := x"30";    
    constant SET_MAX_UP_DOWN_PRESS_TIME         : STD_LOGIC_VECTOR (7 downto 0) := x"31";
    constant GET_MAX_UP_DOWN_PRESS_TIME         : STD_LOGIC_VECTOR (7 downto 0) := x"31";
    constant SET_MAX_MENU_DOWN_PRESS_TIME       : STD_LOGIC_VECTOR (7 downto 0) := x"32";
    constant GET_MAX_MENU_DOWN_PRESS_TIME       : STD_LOGIC_VECTOR (7 downto 0) := x"32";
    constant SET_LONG_PRESS_STEP_SIZE           : STD_LOGIC_VECTOR (7 downto 0) := x"33";
    constant GET_LONG_PRESS_STEP_SIZE           : STD_LOGIC_VECTOR (7 downto 0) := x"33";

    constant SET_MENU_SEL_UP                 : STD_LOGIC_VECTOR (7 downto 0) := x"34";
    constant GET_MENU_SEL_UP                 : STD_LOGIC_VECTOR (7 downto 0) := x"34";
    constant SET_MENU_SEL_DN                 : STD_LOGIC_VECTOR (7 downto 0) := x"35";
    constant GET_MENU_SEL_DN                 : STD_LOGIC_VECTOR (7 downto 0) := x"35";
    constant SET_MENU_SEL_LEFT               : STD_LOGIC_VECTOR (7 downto 0) := x"36";
    constant GET_MENU_SEL_LEFT               : STD_LOGIC_VECTOR (7 downto 0) := x"36";
    constant SET_MENU_SEL_RIGHT              : STD_LOGIC_VECTOR (7 downto 0) := x"37";
    constant GET_MENU_SEL_RIGHT              : STD_LOGIC_VECTOR (7 downto 0) := x"37";  
    constant SET_MENU_SEL_CENTER             : STD_LOGIC_VECTOR (7 downto 0) := x"38";   
    constant GET_MENU_SEL_CENTER             : STD_LOGIC_VECTOR (7 downto 0) := x"38";         
    
--    constant RESTART_SENSOR_CMD  : STD_LOGIC_VECTOR (7 downto 0) := x"CF";
    constant SET_FIRING_DISTANCE               : STD_LOGIC_VECTOR (7 downto 0) := x"3B";
    constant GET_FIRING_DISTANCE                : STD_LOGIC_VECTOR (7 downto 0) := x"3B";
    constant SET_FIRING_MODE                    : STD_LOGIC_VECTOR (7 downto 0) := x"3C";
    constant GET_FIRING_MODE                    : STD_LOGIC_VECTOR (7 downto 0) := x"3C";
    constant SET_RETICLE_COLOR_TH               : STD_LOGIC_VECTOR (7 downto 0) := x"3D";
    constant GET_RETICLE_COLOR_TH               : STD_LOGIC_VECTOR (7 downto 0) := x"3D";
    constant SET_COLOR_SEL_WINDOW_XSIZE         : STD_LOGIC_VECTOR (7 downto 0) := x"3E";
    constant GET_COLOR_SEL_WINDOW_XSIZE         : STD_LOGIC_VECTOR (7 downto 0) := x"3E";  
    constant SET_COLOR_SEL_WINDOW_YSIZE         : STD_LOGIC_VECTOR (7 downto 0) := x"3F";   
    constant GET_COLOR_SEL_WINDOW_YSIZE         : STD_LOGIC_VECTOR (7 downto 0) := x"3F";     
    
    
    
    constant SET_UPDATE_DEVICE_ID_REG1 : STD_LOGIC_VECTOR (7 downto 0) :=x"D5";
    constant GET_UPDATE_DEVICE_ID_REG1 : STD_LOGIC_VECTOR (7 downto 0) :=x"D5";
    constant SET_UPDATE_DEVICE_ID_REG2 : STD_LOGIC_VECTOR (7 downto 0) :=x"D6";
    constant GET_UPDATE_DEVICE_ID_REG2 : STD_LOGIC_VECTOR (7 downto 0) :=x"D6";
    
    constant RESTART_SENSOR_CMD  : STD_LOGIC_VECTOR (7 downto 0) := x"CF";
    
    constant SET_UPDATE_DEVICE_ID_REG : STD_LOGIC_VECTOR (7 downto 0) :=x"D5";
    constant GET_UPDATE_DEVICE_ID_REG : STD_LOGIC_VECTOR (7 downto 0) :=x"D5";
    constant GET_DEVICE_ID            : STD_LOGIC_VECTOR (7 downto 0) :=x"D6";

    constant SET_SNAPSHOT_TOTAL_FRAMES: STD_LOGIC_VECTOR(7 downto 0) := x"E0";
    constant GET_SNAPSHOT_TOTAL_FRAMES: STD_LOGIC_VECTOR(7 downto 0) := x"E0";
	-- ------------------------------------------
	--	UART Communication Protocol Constants
	-- ------------------------------------------
	constant REPLY_ACK			: STD_LOGIC_VECTOR (7 downto 0) := x"01";
	constant REPLY_NACK			: STD_LOGIC_VECTOR (7 downto 0) := x"F0";
	constant REPLY_BAD_ADDR		: STD_LOGIC_VECTOR (7 downto 0) := x"F1";
	constant REPLY_BAD_REG_ADDR	: STD_LOGIC_VECTOR (7 downto 0) := x"F2";
	constant REPLY_INCOMPLETE	: STD_LOGIC_VECTOR (7 downto 0) := x"F3";
	constant REPLY_FLASH_WLE	: STD_LOGIC_VECTOR (7 downto 0) := x"F7";
	constant REPLY_SRAM_WLE		: STD_LOGIC_VECTOR (7 downto 0) := x"FC";
	constant REPLY_SRAM_ALE		: STD_LOGIC_VECTOR (7 downto 0) := x"FB";

	-- ------------------------------------------
	--	REGS MASTER Base Addresses
	-- ------------------------------------------
	constant BASE_PARAM : std_logic_vector(3 downto 0) := x"2";  -- Parameters Accesses
	constant BASE_FLASH : std_logic_vector(3 downto 0) := x"4";  -- Flash Accesses

	-- ----------------------------------
	--  Temperature Monitoring Interval
	-- ----------------------------------
	constant TEMP_REQ_PERIOD : positive := 10;  -- in ms

	-- ----------------------------------
	--  FLASH LPC Constants
	-- ----------------------------------

	-- FLASH Base Address where DMA Descriptors are stored
	constant FLASH_DMA_DESCR_BASE : unsigned(27 downto 00) := x"0000000";

	-- -----------------------------------------------
	--  FLASH Registers Addresses (matching BASE_FLASH)
	-- -----------------------------------------------
	constant ADDR_LPC_CTRL : std_logic_vector(3 downto 0) := x"0";
	constant ADDR_LPC_ADDR : std_logic_vector(3 downto 0) := x"1";

	constant ADDR_VIDEO_BUF0 : STD_LOGIC_VECTOR (31 downto 0) := x"00000000" ;
    constant ADDR_VIDEO_BUF1 : STD_LOGIC_VECTOR (31 downto 0) := x"0004B000";--x"0001B000" ;
    constant ADDR_VIDEO_BUF2 : STD_LOGIC_VECTOR (31 downto 0) := x"00096000";--x"00036000" ;
    
    
    constant ADDR_GAINM_START  : unsigned(31 downto 0) := x"000F0000";
    constant ADDR_GAINM_OFFSET : unsigned(31 downto 0) := x"00096000";
   
    --constant ADDR_GAIN_BADPIX_A : std_logic_vector(31 downto 0):=   x"000F0000";
    constant ADDR_GAIN_BADPIX_A : std_logic_vector(31 downto 0):=  std_logic_vector(ADDR_GAINM_START);
    constant ADDR_GAIN_BADPIX_B : std_logic_vector(31 downto 0):=  std_logic_vector(unsigned(ADDR_GAIN_BADPIX_A) + ADDR_GAINM_OFFSET);
    constant ADDR_GAIN_BADPIX_C : std_logic_vector(31 downto 0):=  std_logic_vector(unsigned(ADDR_GAIN_BADPIX_B) + ADDR_GAINM_OFFSET);
    constant ADDR_GAIN_BADPIX_D : std_logic_vector(31 downto 0):=  std_logic_vector(unsigned(ADDR_GAIN_BADPIX_C) + ADDR_GAINM_OFFSET);  
    constant ADDR_GAIN_BADPIX_E : std_logic_vector(31 downto 0):=  std_logic_vector(unsigned(ADDR_GAIN_BADPIX_D) + ADDR_GAINM_OFFSET); 
    constant ADDR_GAIN_BADPIX_F : std_logic_vector(31 downto 0):=  std_logic_vector(unsigned(ADDR_GAIN_BADPIX_E) + ADDR_GAINM_OFFSET); 
    constant ADDR_GAIN_BADPIX_G : std_logic_vector(31 downto 0):=  std_logic_vector(unsigned(ADDR_GAIN_BADPIX_F) + ADDR_GAINM_OFFSET);                          
    constant ADDR_IMG_COLD      : std_logic_vector(31 downto 0):= std_logic_vector(unsigned(ADDR_GAIN_BADPIX_G) + ADDR_GAINM_OFFSET);--x"033EA000";--x"00F0_0000"; 
    constant ADDR_IMG_HOT       : std_logic_vector(31 downto 0):= std_logic_vector(unsigned(ADDR_IMG_COLD) + ADDR_GAINM_OFFSET);--x"03516000";--x"00F0_0000"; 
    constant ADDR_GAIN          : std_logic_vector(31 downto 0):= std_logic_vector(unsigned(ADDR_IMG_HOT) + ADDR_GAINM_OFFSET);--x"03642000";--x"00F0_0000"; 
    
    constant ADDR_COARSE_OFFSET_START   : unsigned(31 downto 0) := x"006CC000";
    constant ADDR_COARSE_OFFSET_OFFSET  : unsigned(31 downto 0) := x"00052800";
    
    constant ADDR_COARSE_OFFSET_0 :  std_logic_vector(31 downto 0):=   std_logic_vector(ADDR_COARSE_OFFSET_START);
    constant ADDR_COARSE_OFFSET_1  : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_COARSE_OFFSET_0) + ADDR_COARSE_OFFSET_OFFSET);
    constant ADDR_COARSE_OFFSET_2  : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_COARSE_OFFSET_1) + ADDR_COARSE_OFFSET_OFFSET);    
    constant ADDR_COARSE_OFFSET_3  : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_COARSE_OFFSET_2) + ADDR_COARSE_OFFSET_OFFSET);    
    constant ADDR_COARSE_OFFSET_4  : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_COARSE_OFFSET_3) + ADDR_COARSE_OFFSET_OFFSET);
    constant ADDR_COARSE_OFFSET_5  : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_COARSE_OFFSET_4) + ADDR_COARSE_OFFSET_OFFSET);
    constant ADDR_COARSE_OFFSET_6  : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_COARSE_OFFSET_5) + ADDR_COARSE_OFFSET_OFFSET);    

    
    constant ADDR_OFFM_COEFF_START     : unsigned(31 downto 0) := x"0090D800";--x"0050A000";--x"00348000";--x"000E0000";
    constant ADDR_OFFM_COEFF_OFFSET    : unsigned(31 downto 0) := x"0012C000";--x"00096000";
    constant ADDR_OFFM_OFFSET          : unsigned(31 downto 0) := x"00096000";--x"00096000";

    constant ADDR_OFFM_PING            : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_START));
    constant ADDR_OFFM_PONG            : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_START)     + ADDR_OFFM_OFFSET);   
    constant ADDR_OFFM_COEFF_C1_TEMP_0 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_START)     + ADDR_OFFM_COEFF_OFFSET); 
    constant ADDR_OFFM_COEFF_C2_TEMP_0 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C1_TEMP_0) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C3_TEMP_0 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C2_TEMP_0) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C1_TEMP_1 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C3_TEMP_0) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C2_TEMP_1 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C1_TEMP_1) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C3_TEMP_1 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C2_TEMP_1) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C1_TEMP_2 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C3_TEMP_1) + ADDR_OFFM_COEFF_OFFSET); 
    constant ADDR_OFFM_COEFF_C2_TEMP_2 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C1_TEMP_2) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C3_TEMP_2 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C2_TEMP_2) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C1_TEMP_3 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C3_TEMP_2) + ADDR_OFFM_COEFF_OFFSET); 
    constant ADDR_OFFM_COEFF_C2_TEMP_3 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C1_TEMP_3) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C3_TEMP_3 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C2_TEMP_3) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C1_TEMP_4 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C3_TEMP_3) + ADDR_OFFM_COEFF_OFFSET); 
    constant ADDR_OFFM_COEFF_C2_TEMP_4 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C1_TEMP_4) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C3_TEMP_4 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C2_TEMP_4) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C1_TEMP_5 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C3_TEMP_4) + ADDR_OFFM_COEFF_OFFSET); 
    constant ADDR_OFFM_COEFF_C2_TEMP_5 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C1_TEMP_5) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C3_TEMP_5 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C2_TEMP_5) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C1_TEMP_6 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C3_TEMP_5) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C2_TEMP_6 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C1_TEMP_6) + ADDR_OFFM_COEFF_OFFSET);
    constant ADDR_OFFM_COEFF_C3_TEMP_6 : std_logic_vector(31 downto 0):=   std_logic_vector(unsigned(ADDR_OFFM_COEFF_C2_TEMP_6) + ADDR_OFFM_COEFF_OFFSET);
    	
	constant ADDR_OFFM_NUC1PT  : std_logic_vector (31 downto 0):= x"03D00000";
	--constant ADDR_RETICLE_INFO : std_logic_vector (31 downto 0):= x"03516000";--x"03354000";--x"00F0_0000"; 
    constant ADDR_OFFM_NUC1PTM2  : std_logic_vector (31 downto 0):= x"03D96000";

    constant ADDR_SNAPSHOT_BASE      : std_logic_vector (31 downto 0):= x"021AA000";
    constant ADDR_SNAPSHOT_OFFSET_1  : std_logic_vector (31 downto 0):= x"000aa000";
    constant ADDR_SNAPSHOT_OFFSET_2  : std_logic_vector (31 downto 0):= x"00055000";
	constant SNAPSHOT_BLANK_IMG_ADDR : std_logic_vector (31 downto 0):= x"036ea000";
--	constant RETICLE_W : std_logic_vector (9 downto 0):= "0010100000"; -- 160 
--    constant RETICLE_H : std_logic_vector (9 downto 0):= "0001111000";

	constant RETICLE_W : integer:= 640;
    constant RETICLE_H : integer:= 480;
    
	constant LOGO_W : integer:= 40;
    constant LOGO_H : integer:= 40;
	
--	constant ADDR_RETICLE_INFO_0 : std_logic_vector (31 downto 0):= x"03516000";
--	constant ADDR_RETICLE_INFO_1 : std_logic_vector (31 downto 0):= x"03528C00";
--	constant ADDR_RETICLE_INFO_2 : std_logic_vector (31 downto 0):= x"0353B800";
--	constant ADDR_RETICLE_INFO_3 : std_logic_vector (31 downto 0):= x"0354E400";
--	constant ADDR_RETICLE_INFO_4 : std_logic_vector (31 downto 0):= x"03561000"; --  NEXT ADDR 0x3573C00
	
--	constant ADDR_IMG_COLD     : std_logic_vector (31 downto 0):= x"033EA000";--x"00F0_0000"; 
--	constant ADDR_IMG_HOT      : std_logic_vector (31 downto 0):= x"03516000";--x"00F0_0000"; 
--	constant ADDR_GAIN         : std_logic_vector (31 downto 0):= x"03642000";--x"00F0_0000"; 
	
	constant QSPI_ADDR_IMG_COLD     : std_logic_vector (31 downto 0):= x"00a6a000";--x"03700000";x"00F0_0000"; 
	constant QSPI_ADDR_IMG_HOT      : std_logic_vector (31 downto 0):= x"00b00000"; --x"03796000";--x"00F0_0000";
	
--	constant LOW_TEMP_SENSOR_INIT_GFID_ADDR   :std_logic_vector (5 downto 0):= "000011";
--	constant LOW_TEMP_SENSOR_INIT_GSK_ADDR  :std_logic_vector (5 downto 0):= "000100";
--	constant HIGH_TEMP_SENSOR_INIT_GFID_ADDR  :std_logic_vector (5 downto 0):= "000101";
--	constant HIGH_TEMP_SENSOR_INIT_GSK_ADDR :std_logic_vector (5 downto 0):= "000110";

--    constant LOW_TEMP_SENSOR_INIT_GFID_ADDR       : std_logic_vector (5 downto 0):= "000011";
--	constant LOW_TEMP_SENSOR_INIT_GSK_ADDR        : std_logic_vector (5 downto 0):= "000100";
--	constant LOW_TEMP_SENSOR_INIT_INT_TIME_ADDR   : std_logic_vector (5 downto 0):= "000101";
--	constant LOW_TEMP_SENSOR_INIT_GAIN_ADDR       : std_logic_vector (5 downto 0):= "000110";
--	constant HIGH_TEMP_SENSOR_INIT_GFID_ADDR      : std_logic_vector (5 downto 0):= "000111";
--	constant HIGH_TEMP_SENSOR_INIT_GSK_ADDR       : std_logic_vector (5 downto 0):= "001000";
--	constant HIGH_TEMP_SENSOR_INIT_INT_TIME_ADDR  : std_logic_vector (5 downto 0):= "001001";
--    constant HIGH_TEMP_SENSOR_INIT_GAIN_ADDR      : std_logic_vector (5 downto 0):= "001010";

    constant TEMP_RANGE0_SENSOR_INIT_GFID_ADDR       : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(3,6));    
	constant TEMP_RANGE0_SENSOR_INIT_GSK_ADDR        : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(4,6));     
	constant TEMP_RANGE0_SENSOR_INIT_INT_TIME_ADDR   : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(5,6));      
	constant TEMP_RANGE0_SENSOR_INIT_GAIN_ADDR       : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(6,6));    
	
	constant TEMP_RANGE1_SENSOR_INIT_GFID_ADDR       : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(7,6));       
    constant TEMP_RANGE1_SENSOR_INIT_GSK_ADDR        : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(8,6));       
    constant TEMP_RANGE1_SENSOR_INIT_INT_TIME_ADDR   : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(9,6));         
    constant TEMP_RANGE1_SENSOR_INIT_GAIN_ADDR       : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(10,6));    
    
    constant TEMP_RANGE2_SENSOR_INIT_GFID_ADDR       : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(11,6));
    constant TEMP_RANGE2_SENSOR_INIT_GSK_ADDR        : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(12,6));
    constant TEMP_RANGE2_SENSOR_INIT_INT_TIME_ADDR   : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(13,6));
    constant TEMP_RANGE2_SENSOR_INIT_GAIN_ADDR       : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(14,6));
    
	constant TEMP_RANGE3_SENSOR_INIT_GFID_ADDR       : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(15,6)); 
	constant TEMP_RANGE3_SENSOR_INIT_GSK_ADDR        : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(16,6));  
	constant TEMP_RANGE3_SENSOR_INIT_INT_TIME_ADDR   : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(17,6)); 
    constant TEMP_RANGE3_SENSOR_INIT_GAIN_ADDR       : std_logic_vector (5 downto 0):= std_logic_vector(to_unsigned(18,6)); 
	
	
--	constant ADDR_OFFM_TEMP_20  : std_logic_vector(31 downto 0):=   x"00186000";
--    constant ADDR_OFFM_TEMP_22 : std_logic_vector(31 downto 0):=   x"0021C000";
--    constant ADDR_OFFM_TEMP_23 : std_logic_vector(31 downto 0):=   x"002B2000";
--    constant ADDR_OFFM_TEMP_24 : std_logic_vector(31 downto 0):=   x"00348000";
--    constant ADDR_OFFM_TEMP_25 : std_logic_vector(31 downto 0):=   x"003DE000";
--    constant ADDR_OFFM_TEMP_26 : std_logic_vector(31 downto 0):=   x"00474000";
--    constant ADDR_OFFM_TEMP_27 : std_logic_vector(31 downto 0):=   x"0050A000";
--    constant ADDR_OFFM_TEMP_28 : std_logic_vector(31 downto 0):=   x"005A0000";
--    constant ADDR_OFFM_TEMP_29 : std_logic_vector(31 downto 0):=   x"00636000";
--    constant ADDR_OFFM_TEMP_30 : std_logic_vector(31 downto 0):=   x"006CC000";
--    constant ADDR_OFFM_TEMP_31 : std_logic_vector(31 downto 0):=   x"00762000";
--    constant ADDR_OFFM_TEMP_32 : std_logic_vector(31 downto 0):=   x"007F8000";
--    constant ADDR_OFFM_TEMP_33 : std_logic_vector(31 downto 0):=   x"0088E000";
--    constant ADDR_OFFM_TEMP_34 : std_logic_vector(31 downto 0):=   x"00924000";
--    constant ADDR_OFFM_TEMP_35 : std_logic_vector(31 downto 0):=   x"009BA000";
--    constant ADDR_OFFM_TEMP_36 : std_logic_vector(31 downto 0):=   x"00A50000";
--    constant ADDR_OFFM_TEMP_37 : std_logic_vector(31 downto 0):=   x"00AE6000";
--    constant ADDR_OFFM_TEMP_38 : std_logic_vector(31 downto 0):=   x"00B7C000";
--    constant ADDR_OFFM_TEMP_39 : std_logic_vector(31 downto 0):=   x"00C12000";
--    constant ADDR_OFFM_TEMP_40 : std_logic_vector(31 downto 0):=   x"00CA8000";
--    constant ADDR_OFFM_TEMP_42 : std_logic_vector(31 downto 0):=   x"00D3E000";
--    constant ADDR_OFFM_TEMP_44 : std_logic_vector(31 downto 0):=   x"00DD4000";
--    constant ADDR_OFFM_TEMP_46 : std_logic_vector(31 downto 0):=   x"00E6A000";
--    constant ADDR_OFFM_TEMP_48 : std_logic_vector(31 downto 0):=   x"00F00000";

   
	-- -----------------------------------------------
	--  SRAM DMA Generic inputs
	-- -----------------------------------------------
--	constant DMA_ADDR_BITS : positive := 20;
--	constant DMA_SIZE_BITS : positive := 5;
--	constant DMA_DATA_BITS : positive := 16;  
	
	-- -----------------------------------------------
	--  SRAM Address Limits
	-- -----------------------------------------------
	constant SRAM_ADDR_MAX	: STD_LOGIC_VECTOR (19 downto 0) := (others => '1');

	-- -----------------------------------------------
	--  SPI Init Values
	-- -----------------------------------------------
	constant CLKDIV_0_QVGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"4021";
	constant CLKDIV_1_QVGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"4020";
	constant INT_TIME_QVGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"1168";
	constant GSK_VAL_QVGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"2715";
	constant GFID_VAL_QVGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"3AD8";

	constant CLKDIV_0_VGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"4001";
	constant CLKDIV_1_VGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"4001";
	constant INT_TIME_VGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"4001";
	constant GSK_VAL_VGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"29D0";
	constant GFID_VAL_VGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"3300";

	constant CLKDIV_0_XGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"4100";
	constant CLKDIV_1_XGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"4100";
	constant INT_TIME_XGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"1132";
	constant GSK_VAL_XGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"2226";
	constant GFID_VAL_XGA		: STD_LOGIC_VECTOR (31 downto 0) := x"0000" & x"3DAC";
	
	constant ADDR_FILTER	        : STD_LOGIC_VECTOR (31 downto 0) := x"000000" & x"20" ;
	constant ADDR_CLIP_THRESHOLD	: STD_LOGIC_VECTOR (31 downto 0) := x"000000" & x"24" ;
    
--function temp_range_gen(
--    temperature : in std_logic_vector (15 downto 0))
--return unsigned;    

end package THERMAL_CAM_PACK;


package body THERMAL_CAM_PACK is

--    function temp_range_gen(
--    temperature : in std_logic_vector(15 downto 0))
--    return unsigned is
--    variable vtemp: unsigned(5 downto 0);
--    begin
        
--        if(unsigned(temperature)>=to_unsigned(11536, temperature'length)) then
--            vtemp := "000000";
--        elsif(unsigned(temperature)<to_unsigned(11536, temperature'length) and unsigned(temperature)>=to_unsigned(11504, temperature'length)) then
--            vtemp := "000001";
--        elsif(unsigned(temperature)<to_unsigned(11504, temperature'length) and unsigned(temperature)>=to_unsigned(11472, temperature'length)) then
--            vtemp := "000010";  
--        elsif(unsigned(temperature)<to_unsigned(11472, temperature'length) and unsigned(temperature)>=to_unsigned(11424, temperature'length)) then
--            vtemp := "000011"; 
--        elsif(unsigned(temperature)<to_unsigned(11424, temperature'length) and unsigned(temperature)>=to_unsigned(11376, temperature'length)) then
--            vtemp := "000100"; 
--        elsif(unsigned(temperature)<to_unsigned(11376, temperature'length) and unsigned(temperature)>=to_unsigned(11360, temperature'length)) then
--            vtemp := "000101";
--        elsif(unsigned(temperature)<to_unsigned(11360, temperature'length) and unsigned(temperature)>=to_unsigned(11328, temperature'length)) then
--            vtemp := "000110"; 
--        elsif(unsigned(temperature)<to_unsigned(11328, temperature'length) and unsigned(temperature)>=to_unsigned(11296, temperature'length)) then
--            vtemp := "000111"; 
--        elsif(unsigned(temperature)<to_unsigned(11296, temperature'length) and unsigned(temperature)>=to_unsigned(11280, temperature'length)) then
--            vtemp := "001000";
--        elsif(unsigned(temperature)<to_unsigned(11280, temperature'length) and unsigned(temperature)>=to_unsigned(11264, temperature'length)) then
--            vtemp := "001001"; 
--        elsif(unsigned(temperature)<to_unsigned(11264, temperature'length) and unsigned(temperature)>=to_unsigned(11248, temperature'length)) then
--            vtemp := "001010"; 
--        elsif(unsigned(temperature)<to_unsigned(11248, temperature'length) and unsigned(temperature)>=to_unsigned(11200, temperature'length)) then
--            vtemp := "001011";  
--        elsif(unsigned(temperature)<to_unsigned(11200, temperature'length) and unsigned(temperature)>=to_unsigned(11168, temperature'length)) then
--            vtemp := "001100"; 
--        elsif(unsigned(temperature)<to_unsigned(11168, temperature'length) and unsigned(temperature)>=to_unsigned(11136, temperature'length)) then
--            vtemp := "001101";
--        elsif(unsigned(temperature)<to_unsigned(11136, temperature'length) and unsigned(temperature)>=to_unsigned(11104, temperature'length)) then
--            vtemp := "001110";             
--        elsif(unsigned(temperature)<to_unsigned(11104, temperature'length) and unsigned(temperature)>=to_unsigned(11072, temperature'length)) then
--            vtemp := "001111";
--        elsif(unsigned(temperature)<to_unsigned(11072, temperature'length) and unsigned(temperature)>=to_unsigned(11040, temperature'length)) then
--            vtemp := "010000";                           
--        elsif(unsigned(temperature)<to_unsigned(11040, temperature'length) and unsigned(temperature)>=to_unsigned(11008, temperature'length)) then
--            vtemp := "010001"; 
--        elsif(unsigned(temperature)<to_unsigned(11008, temperature'length) and unsigned(temperature)>=to_unsigned(10992, temperature'length)) then
--            vtemp := "010010";   
--        elsif(unsigned(temperature)<to_unsigned(10992, temperature'length) and unsigned(temperature)>=to_unsigned(10981, temperature'length)) then
--            vtemp := "010011"; 
--        elsif(unsigned(temperature)<to_unsigned(10981, temperature'length) and unsigned(temperature)>=to_unsigned(10944, temperature'length)) then
--            vtemp := "010100";    
--        elsif(unsigned(temperature)<to_unsigned(10944, temperature'length) and unsigned(temperature)>=to_unsigned(10912, temperature'length)) then
--            vtemp := "010101";    
--        elsif(unsigned(temperature)<to_unsigned(10912, temperature'length) and unsigned(temperature)>=to_unsigned(10880, temperature'length)) then
--            vtemp := "010110";    
--        elsif(unsigned(temperature)<to_unsigned(10880, temperature'length) and unsigned(temperature)>=to_unsigned(10816, temperature'length)) then
--            vtemp := "010111";    
--        else                  
--            vtemp := "010111";                       
--        end if;
--        return unsigned(vtemp);
--    end function temp_range_gen;
    
end package body THERMAL_CAM_PACK;