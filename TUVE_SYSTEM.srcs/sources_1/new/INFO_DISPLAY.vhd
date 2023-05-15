library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
   

----------------------------------
entity INFO_DISPLAY is
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
    CLK                         : in  std_logic;                              -- Module Clock
    RST                         : in  std_logic;                              -- Module Reset (Asynchronous active high)
    INFO_DISP_EN                : in  std_logic;                              -- Enable INFO DISPLAY
    SN_INFO_DISP_EN             : in  std_logic;                              -- Enable Serial Number INFO DISPLAY
    PRDCT_NAME_WRITE_DATA_VALID : in  std_logic;
    PRDCT_NAME_WRITE_DATA       : in  std_logic_vector(7 downto 0);
--    INFO_DISP_COLOR_INFO        : in  std_logic_vector( 23 downto 0);     
--    CH_COLOR_INFO1              : in  std_logic_vector( 23 downto 0);     
--    CH_COLOR_INFO2              : in  std_logic_vector( 23 downto 0);     
    INFO_DISP_COLOR_INFO        : in  std_logic_vector(7 downto 0);     
    CH_COLOR_INFO1              : in  std_logic_vector(7 downto 0);     
    CH_COLOR_INFO2              : in  std_logic_vector(7 downto 0); 

    INFO_DISP_POS_X             : in  std_logic_vector(PIX_BITS-1 downto 0);  -- INFO DISPLAY POSITION X
    INFO_DISP_POS_Y             : in  std_logic_vector(LIN_BITS-1 downto 0);  -- INFO DISPLAY POSITION Y
 
    SN_INFO_DISP_POS_X          : in  std_logic_vector(PIX_BITS-1 downto 0);  -- SERIAL NUMBER INFO DISPLAY POSITION X
    SN_INFO_DISP_POS_Y          : in  std_logic_vector(LIN_BITS-1 downto 0);  -- SERIAL NUMBER INFO DISPLAY POSITION Y
    
    CH_IMG_WIDTH_IN                : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture X Size (max 1023)
    CH_IMG_HEIGHT_IN               : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture Y Size (max 1023)

    INFO_DISP_REQ_V             : in  std_logic;                              -- Scaler New Frame Request
    INFO_DISP_REQ_H             : in  std_logic;                              -- Scaler New Line Request
    INFO_DISP_FIELD             : in  std_logic;                              -- FIELD

    INFO_DISP_REQ_XSIZE1        : in  std_logic_vector(PIX_BITS-1 downto 0);  --MENU LAYER3 WIDTH 
    INFO_DISP_REQ_YSIZE1        : in  std_logic_vector(LIN_BITS-1 downto 0);  --MENU LAYER3 HEIGHT
    
    VIDEO_IN_V                  : in  std_logic;                              -- Scaler New Frame
    VIDEO_IN_H                  : in  std_logic;
    VIDEO_IN_DAV                : in  std_logic;                              -- Scaler New Data
--    VIDEO_IN_DATA               : in  std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    VIDEO_IN_DATA               : in  std_logic_vector(7 downto 0);
    VIDEO_IN_EOI                : in  std_logic;
    VIDEO_IN_XSIZE              : in  std_logic_vector(PIX_BITS-1 downto 0);  -- Width of output image
    VIDEO_IN_YSIZE              : in  std_logic_vector(LIN_BITS-1 downto 0);  -- Height of output image
    
    INFO_DISP_V                 : out std_logic;                              -- Scaler New Frame
    INFO_DISP_H                 : out std_logic;
    INFO_DISP_DAV               : out std_logic;                              -- Scaler New Data
--    INFO_DISP_DATA              : out std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    INFO_DISP_DATA              : out std_logic_vector(7 downto 0);
    INFO_DISP_EOI               : out std_logic;
    INFO_DISP_POS_X_OUT         : out std_logic_vector(PIX_BITS-1 downto 0);
    INFO_DISP_POS_Y_OUT         : out std_logic_vector(LIN_BITS-1 downto 0);
    
    DEVICE_ID                   : in std_logic_Vector(31 downto 0);
    MUX_DZOOM                   : in std_logic_Vector(2 downto 0);
    MUX_AGC_MODE_SEL            : in std_logic_vector(1 downto 0);
    MUX_BRIGHTNESS              : in std_logic_vector(7 downto 0);
    MUX_CONTRAST                : in std_logic_vector(7 downto 0);
    MUX_RETICLE_TYPE            : in std_logic_vector(3 downto 0);
    MUX_RETICLE_HORZ            : in std_logic_vector(PIX_BITS-1 downto 0);
    MUX_RETICLE_VERT            : in std_logic_vector(LIN_BITS-1 downto 0);
    MUX_POLARITY                : in std_logic_vector(1 downto 0);
    MUX_EDGE_EN                 : in std_logic
    
  );
----------------------------------
end entity INFO_DISPLAY;
----------------------------------

------------------------------------------
architecture RTL of INFO_DISPLAY is
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
    DATA_IN_WIDTH : positive ;
    DATA_OUT_WIDTH: positive 
);
port(
    CLK                  : in std_logic; 
    RST                  : in std_logic; 
    BIN_DATA_IN          : in std_logic_Vector (DATA_IN_WIDTH-1 downto 0);
    BIN_DATA_IN_VALID    : in std_logic;
    BCD_DATA_OUT         : out std_logic_vector(DATA_OUT_WIDTH-1 downto 0);
    BCD_DATA_OUT_VALID   : out std_logic
   );                    
end component;



  constant PIX_BETWEEN_CH_CLM      : unsigned(7 downto 0)  := x"01";
  constant PIX_BETWEEN_CH_ROW      : unsigned(7 downto 0)  := x"02"; 
  constant CH_IMG_WIDTH            : unsigned(9 downto 0)  := "00" &x"10";--"00" &x"08";
  constant CH_IMG_HEIGHT           : unsigned(9 downto 0)  := "00" &x"20";--"00" &x"10";

  signal probe0 : std_logic_vector(127 downto 0);
  type   CH_ROM_RDFSM_t is ( s_IDLE, s_WAIT_H,s_GET_CH_ADDR,s_GET_ADDR, s_READ ); --s_GET_CH_ADDR,
  signal CH_ROM_RDFSM     : CH_ROM_RDFSM_t;
  signal CH_ROM_ADDR_PIX  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);  -- PIX_BITS for a line, 
  signal CH_ROM_ADDR_PICT : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);

  signal CH_ROM_ADDR_BASE : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal CH_ROM_ADDR_BASE_TEMP : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);


  constant FIFO_DEPTH : positive := CH_ROM_ADDR_WIDTH;--10;  -- 2**FIFO_DEPTH words in the FIFO
  constant FIFO_WSIZE : positive := CH_ROM_DATA_WIDTH;  

  signal FIFO_CLR_INFO_DISP     : std_logic;
  signal FIFO_WR_INFO_DISP      : std_logic;
  signal FIFO_IN_INFO_DISP      : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_FUL_INFO_DISP     : std_logic;
  signal FIFO_NB_INFO_DISP      : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal FIFO_EMP_INFO_DISP     : std_logic;
  signal FIFO_RD_INFO_DISP      : std_logic;
  signal FIFO_OUT_INFO_DISP     : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_OUT_INFO_DISP_REV : std_logic_vector(FIFO_WSIZE-1 downto 0);

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
  
  signal INFO_DISP_DAVi      : std_logic;

  signal INFO_DISP_V_D    : std_logic;  
  signal INFO_DISP_H_D    : std_logic; 
  signal INFO_DISP_DAV_D  : std_logic;
  signal INFO_DISP_EOI_D  : std_logic;
  

  signal count             : integer := 0;
  signal FIFO_RD1_CNT      : integer := 0;
  signal FIFO_RD1_CNT_D    : integer := 0;
  signal FIFO_RD_INFO_DISP_D : std_logic;
  signal FIFO_RD1_D        : std_logic;
  signal first_time_rd_rq  : std_logic;
  signal INFO_DISP_EN_D          : std_logic;

  
--  signal LATCH_INFO_DISP_REQ_XSIZE    : std_logic_vector(PIX_BITS-1 downto 0);
--  signal LATCH_INFO_DISP_REQ_YSIZE    : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_POS_X_INFO_DISP        : std_logic_vector(PIX_BITS-1 downto 0);
--  signal LATCH_POS_Y_INFO_DISP        : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_INFO_DISP_COLOR_INFO1  : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO1   : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO2   : std_logic_vector( 23 downto 0);
--  signal LATCH_CURSOR_COLOR_INFO: std_logic_vector( 23 downto 0);

  signal INFO_DISP_REQ_XSIZE  : std_logic_vector(PIX_BITS-1 downto 0);
  signal INFO_DISP_REQ_YSIZE  : std_logic_vector(LIN_BITS-1 downto 0);
  signal POS_X_INFO_DISP                : std_logic_vector(PIX_BITS-1 downto 0);
  signal POS_Y_INFO_DISP                : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_INFO_DISP_COLOR_INFO     : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO1           : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO2           : std_logic_vector( 23 downto 0);
--  signal LATCH_CURSOR_COLOR_INFO        : std_logic_vector( 23 downto 0);
  signal LATCH_INFO_DISP_COLOR_INFO     : std_logic_vector(7 downto 0);
  signal LATCH_CH_COLOR_INFO1           : std_logic_vector(7 downto 0);
  signal LATCH_CH_COLOR_INFO2           : std_logic_vector(7 downto 0);
  signal LATCH_CURSOR_COLOR_INFO        : std_logic_vector(7 downto 0);

  signal LATCH_INFO_DISP_POS_X      : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_INFO_DISP_POS_Y      : std_logic_vector(LIN_BITS-1 downto 0);
  signal LATCH_INFO_DISP_REQ_XSIZE  : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_INFO_DISP_REQ_YSIZE  : std_logic_vector(LIN_BITS-1 downto 0);

  
  signal line_cnt        : unsigned(LIN_BITS-1 downto 0);
  signal pix_cnt         : unsigned(PIX_BITS-1 downto 0);
  signal pix_cnt_d       : unsigned(PIX_BITS-1 downto 0);
  signal RD_INFO_DISP_LIN_NO   : unsigned(LIN_BITS-1 downto 0);
  signal INFO_DISP_ADD_DONE    : std_logic; 
  signal INFO_DISP_POS_Y_TEMP  : std_logic_Vector(LIN_BITS-1 downto 0); 
  signal INFO_DISP_POS_Y_D     : std_logic_Vector(LIN_BITS-1 downto 0);  
  signal INFO_DISP_POS_X1      : std_logic_vector(PIX_BITS-1 downto 0);  -- INFO_DISP POSITION X
  signal INFO_DISP_POS_Y1      : std_logic_vector(LIN_BITS-1 downto 0);  -- INFO_DISP POSITION Y
  signal INFO_DISP_LINE_CNT    : unsigned(LIN_BITS-1 downto 0);
  signal INFO_DISP_RD_DONE     : std_logic;
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

  signal POS_Y_CH_1     : unsigned(LIN_BITS-1 downto 0);
  signal POS_X_CH_1     : unsigned(PIX_BITS-1 downto 0);
  
  
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
  signal ADDR_CH_41  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal ADDR_CH_42  : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0); 

  signal CH_ADDR_OFFSET       : unsigned(5 downto 0); 
--  signal LATCH_CURSOR_POS_LY2 : unsigned(7 downto 0);
  
  
  
  signal CH_ROM_DATA : std_logic_vector(CH_ROM_DATA_WIDTH-1 downto 0);
  signal CH_ROM_ADDR : std_logic_vector(CH_ROM_ADDR_WIDTH-1 downto 0); 
 
  signal INTERNAL_LINE_CNT :  unsigned(LIN_BITS-1 downto 0);
  signal CH_LIN_CNT_RD     : unsigned(7 downto 0);
  signal CH_ADD_CNT        : unsigned(7 downto 0);
  signal INFO_DISP_REQ_V_D       : std_logic ;
  signal INFO_DISP_REQ_V_DD      : std_logic ;
  signal INFO_DISP_REQ_V_DDD      : std_logic ;

  signal BIN_DATA          : std_logic_vector(9 downto 0);   
  signal BIN_DATA_VALID    : std_logic;
  signal BCD_DATA          : std_logic_vector(11 downto 0);
  signal BCD_DATA_VALID    : std_logic;
  signal BCD_DATA_D        : std_logic_vector(11 downto 0);

  signal DEVICE_ID_BCD_DATA          : std_logic_vector(39 downto 0);
  signal DEVICE_ID_BCD_DATA_D        : std_logic_vector(39 downto 0);
  signal DEVICE_ID_BCD_DATA_VALID    : std_logic;

  
--  signal DATA_IN_CNT : unsigned(PIX_BITS-1 downto 0);
    
  signal INFO_DISP_REQ_H_D    : std_logic;
  signal INFO_DISP_REQ_H_DD   : std_logic;  
  signal INFO_DISP_REQ_H_DDD  : std_logic;
  signal INFO_DISP_REQ_H_DDDD : std_logic;  

  signal VIDEO_IN_V_D    : std_logic;
  signal VIDEO_IN_V_DD   : std_logic;  
  signal VIDEO_IN_V_DDD  : std_logic;
  signal VIDEO_IN_V_DDDD : std_logic;  

  signal VIDEO_IN_H_D    : std_logic;
  signal VIDEO_IN_H_DD   : std_logic;  
  signal VIDEO_IN_H_DDD  : std_logic;
  signal VIDEO_IN_H_DDDD : std_logic;    
  
  signal BRIGHTNESS    : std_logic_vector(7 downto 0);
  signal CONTRAST      : std_logic_vector(7 downto 0);
  signal RETICLE_TYPE  : std_logic_vector(3 downto 0);
  signal RETICLE_HORZ  : std_logic_vector(PIX_BITS-1 downto 0);
  signal RETICLE_VERT  : std_logic_vector(LIN_BITS-1 downto 0);
  signal DZOOM         : std_logic_vector(2 downto 0);
  signal POLARITY      : std_logic_vector(2 downto 0);
  signal AGC           : std_logic_vector(1 downto 0);

  signal BCD_BRIGHTNESS    : std_logic_vector(11 downto 0);
  signal BCD_CONTRAST      : std_logic_vector(11 downto 0);
  signal BCD_RETICLE_TYPE  : std_logic_vector(11 downto 0);
  signal BCD_RETICLE_HORZ  : std_logic_vector(11 downto 0);
  signal BCD_RETICLE_VERT  : std_logic_vector(11 downto 0);
  signal BCD_DZOOM         : std_logic_vector(11 downto 0);
  signal BCD_AGC           : std_logic_vector(11 downto 0);

  type   bin_to_bcd_t is ( s_idle,s_brightness,s_brightness_wait,
                           s_contrast,s_contrast_wait,
                           s_reticle_type,s_reticle_type_wait,
                           s_reticle_horz,s_reticle_horz_wait,
                           s_reticle_vert,s_reticle_vert_wait,
                           s_dzoom,s_dzoom_wait,
                           s_agc,s_agc_wait); --s_GET_CH_ADDR,
  signal bin_to_bcd_fsm     : bin_to_bcd_t;
  
  signal SN_INFO_DISP_EN_D : std_logic;
  signal DEVICE_ID_D       : std_logic_vector(31 downto 0);
  signal DEVICE_ID_D_VALID : std_logic;

  type PRDCT_NAME_MEM_t is array (0 to 31) of std_logic_vector(7 downto 0);
  signal PRDCT_NAME_MEM     : PRDCT_NAME_MEM_t := (others => (others => '0'));
  
  signal PRDCT_NAME_MEM_WR_ADDR : unsigned (5 downto 0);  
  
--------
begin
--------
--DMA_RDFSM_check <=  "000" when DMA_RDFSM = s_IDLE else
--                    "001" when DMA_RDFSM = s_WAIT_H else
----                    "010" when DMA_RDFSM = s_GET_CH_ADDR else
--                    "011" when DMA_RDFSM = s_GET_ADDR else
--                    "100" when DMA_RDFSM = s_READ else
--                    "111";

CH_ADDR_OFFSET    <= unsigned(CH_IMG_HEIGHT(5 downto 0));

  -- ---------------------------------
  --  DMA Master Read Process
  -- ---------------------------------
  process(CLK, RST)
  begin
    if RST = '1' then
      CH_ROM_ADDR_PICT            <= (others => '0');
      CH_ROM_RDFSM                <= s_IDLE;
      LATCH_INFO_DISP_COLOR_INFO  <= x"50";--x"508080";
      LATCH_CH_COLOR_INFO1        <= x"EB";--x"EB8080";
      LATCH_CH_COLOR_INFO2        <= x"10";--x"108080";
      LATCH_CURSOR_COLOR_INFO     <= x"EB";--x"EB8080";

      LATCH_INFO_DISP_POS_X     <= (others => '0');
      LATCH_INFO_DISP_POS_X     <= (others => '0');
      LATCH_INFO_DISP_REQ_XSIZE <= (others => '0');
      LATCH_INFO_DISP_REQ_YSIZE <= (others => '0');
      POS_X_INFO_DISP           <= (others => '0');
      POS_Y_INFO_DISP           <= (others => '0');
      POS_X_CH_1                <= (others => '0');
      POS_Y_CH_1                <= (others => '0');
      RD_INFO_DISP_LIN_NO       <= (others => '0');
      INFO_DISP_POS_Y_TEMP      <= (others => '0');
      INFO_DISP_POS_Y_D         <= (others => '0');
      INFO_DISP_RD_DONE         <= '0';
      INFO_DISP_POS_X_OUT       <= std_logic_vector(to_unsigned(6,INFO_DISP_POS_X_OUT'length));
      INFO_DISP_POS_Y_OUT       <= std_logic_vector(to_unsigned(16,INFO_DISP_POS_Y_OUT 'length));
      CH_CNT                    <= (others => '0');
      SEL_CH_WR_FIFO            <= (others => '0');
      DMA_RDDAV_D               <= '0';

      ADDR_CH_1               <= (others => '0');
      ADDR_CH_2               <= (others => '0');  
      ADDR_CH_3               <= (others => '0');
      ADDR_CH_4               <= (others => '0');
      ADDR_CH_5               <= (others => '0');
      ADDR_CH_6               <= (others => '0');
      ADDR_CH_7               <= (others => '0');
      ADDR_CH_8               <= (others => '0');
      ADDR_CH_9               <= (others => '0');
      ADDR_CH_10              <= (others => '0');
      ADDR_CH_11              <= (others => '0');
      ADDR_CH_12              <= (others => '0');
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
      ADDR_CH_25              <= (others => '0');
      ADDR_CH_26              <= (others => '0');
      ADDR_CH_27              <= (others => '0');
      ADDR_CH_28              <= (others => '0');
      ADDR_CH_29              <= (others => '0');
      ADDR_CH_30              <= (others => '0');
      ADDR_CH_31              <= (others => '0');
      ADDR_CH_32              <= (others => '0');
      ADDR_CH_33              <= (others => '0');
      ADDR_CH_34              <= (others => '0');
      ADDR_CH_35              <= (others => '0');
      ADDR_CH_36              <= (others => '0');
      ADDR_CH_37              <= (others => '0');
      ADDR_CH_38              <= (others => '0');
      ADDR_CH_39              <= (others => '0');     
      ADDR_CH_40              <= (others => '0'); 
      ADDR_CH_41              <= (others => '0'); 
      ADDR_CH_42              <= (others => '0');        
--      INFO_DISP_EN_OUT              <= '0';
      INTERNAL_LINE_CNT       <= (others=>'0');
      CH_ADD_CNT              <= (others=>'0');

      INFO_DISP_EN_D               <= '0';              
      INFO_DISP_REQ_H_D            <= '0';
      INFO_DISP_REQ_H_DD           <= '0';
      INFO_DISP_REQ_H_DDD          <= '0';
      INFO_DISP_REQ_H_DDDD         <= '0';
      SN_INFO_DISP_EN_D            <= '0';
      DEVICE_ID_D                  <= (others=>'0');
      PRDCT_NAME_MEM_WR_ADDR       <= (others => '0');
    elsif rising_edge(CLK) then

      FIFO_WR_INFO_DISP <= '0';     
      DEVICE_ID_D_VALID <= '0'; 

      INFO_DISP_REQ_H_D             <= INFO_DISP_REQ_H;    
      INFO_DISP_REQ_H_DD            <= INFO_DISP_REQ_H_D;   
      INFO_DISP_REQ_H_DDD           <= INFO_DISP_REQ_H_DD;   
      INFO_DISP_REQ_H_DDDD          <= INFO_DISP_REQ_H_DDD; 

      case CH_ROM_RDFSM is         

        when s_IDLE =>
            CH_ROM_ADDR_PIX <= (others => '0');
            line_cnt        <= (others => '0');        
            if INFO_DISP_EN_D ='1' then
             CH_ROM_RDFSM   <= s_WAIT_H;
            end if; 

        when s_WAIT_H =>
            if INFO_DISP_REQ_H_DDDD = '1' then
              line_cnt     <= line_cnt + 1;
              INFO_DISP_RD_DONE  <= '0';         
              if (line_cnt >= (POS_Y_CH(LIN_BITS-1 downto 0)) and  (line_cnt < (unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0))+ POS_Y_CH(LIN_BITS-1 downto 0)))) then
                CH_ROM_RDFSM      <= s_GET_CH_ADDR;
                INTERNAL_LINE_CNT <= INTERNAL_LINE_CNT +1;
              else
                CH_ROM_RDFSM      <= s_WAIT_H;
                INTERNAL_LINE_CNT <= (others=>'0');
              end if;                      
            end if;

        when s_GET_CH_ADDR =>
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
            elsif(CH_CNT = 40)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_41 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;     
            elsif(CH_CNT = 41)then                                                                                                                                                    
                    CH_ROM_ADDR  <= std_logic_Vector(ADDR_CH_42 + CH_ROM_ADDR_PICT);                                                                  
                    CH_CNT       <= CH_CNT + 1;                                                                
                    CH_ROM_RDFSM <= s_GET_ADDR;   
            else
                    CH_ROM_RDFSM       <= s_WAIT_H;
                    CH_CNT             <= (others=>'0');
                    INFO_DISP_RD_DONE  <= '1';   
                    if(INTERNAL_LINE_CNT = unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0)))then
                      CH_ADD_CNT        <= CH_ADD_CNT + 1;
                      INTERNAL_LINE_CNT <= (others=>'0');
                      CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
                      --if(INFO_DISP_FIELD = '0')then
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
            FIFO_IN_INFO_DISP  <= CH_ROM_DATA;
            FIFO_WR_INFO_DISP  <= '1';
            CH_ROM_RDFSM       <= s_GET_CH_ADDR;
        end case;
        

      if(PRDCT_NAME_WRITE_DATA_VALID = '1') then
        PRDCT_NAME_MEM(to_integer(PRDCT_NAME_MEM_WR_ADDR)) <= PRDCT_NAME_WRITE_DATA ;
        PRDCT_NAME_MEM_WR_ADDR <= PRDCT_NAME_MEM_WR_ADDR + 1;
      end if;

    

                            
     if(BCD_DATA_VALID = '1')then
        BCD_DATA_D <= BCD_DATA; 
     else
        BCD_DATA_D <= BCD_DATA_D; 
     end if;              

     if(DEVICE_ID_BCD_DATA_VALID = '1')then
        DEVICE_ID_BCD_DATA_D <= DEVICE_ID_BCD_DATA; 
     else
        DEVICE_ID_BCD_DATA_D <= DEVICE_ID_BCD_DATA_D; 
     end if; 

     if(SN_INFO_DISP_EN_D = '1')then                  
         ADDR_CH_1  <= resize(unsigned(PRDCT_NAME_MEM(0))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_2  <= resize(unsigned(PRDCT_NAME_MEM(1))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_3  <= resize(unsigned(PRDCT_NAME_MEM(2))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_4  <= resize(unsigned(PRDCT_NAME_MEM(3))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_5  <= resize(unsigned(PRDCT_NAME_MEM(4))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_6  <= resize(unsigned(PRDCT_NAME_MEM(5))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_7  <= resize(unsigned(PRDCT_NAME_MEM(6))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_8  <= resize(unsigned(PRDCT_NAME_MEM(7))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(26*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_9  <= resize(unsigned(PRDCT_NAME_MEM(8))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_10 <= resize(unsigned(PRDCT_NAME_MEM(9))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_11 <= resize(unsigned(PRDCT_NAME_MEM(10))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_12 <= resize(unsigned(PRDCT_NAME_MEM(11))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(30*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_13 <= resize(unsigned(PRDCT_NAME_MEM(12))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize(25*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_14 <= resize(unsigned(PRDCT_NAME_MEM(13))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_15 <= resize(unsigned(PRDCT_NAME_MEM(14))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_16 <= resize(unsigned(PRDCT_NAME_MEM(15))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);     --resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_17 <= resize(unsigned(PRDCT_NAME_MEM(16))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_18 <= resize(unsigned(PRDCT_NAME_MEM(17))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_19 <= resize(unsigned(PRDCT_NAME_MEM(18))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_20 <= resize(unsigned(PRDCT_NAME_MEM(19))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_21 <= resize(unsigned(PRDCT_NAME_MEM(20))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_22 <= resize(unsigned(PRDCT_NAME_MEM(21))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_23 <= resize(unsigned(PRDCT_NAME_MEM(22))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_24 <= resize(unsigned(PRDCT_NAME_MEM(23))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_25 <= resize(unsigned(PRDCT_NAME_MEM(24))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_26 <= resize(unsigned(PRDCT_NAME_MEM(25))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_27 <= resize(unsigned(PRDCT_NAME_MEM(26))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_28 <= resize(unsigned(PRDCT_NAME_MEM(27))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_29 <= resize(unsigned(PRDCT_NAME_MEM(28))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_30 <= resize(unsigned(PRDCT_NAME_MEM(29))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_31 <= resize(unsigned(PRDCT_NAME_MEM(30))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_32 <= resize(unsigned(PRDCT_NAME_MEM(31))*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_33 <= resize((unsigned(DEVICE_ID_BCD_DATA_D(39 downto 36))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_34 <= resize((unsigned(DEVICE_ID_BCD_DATA_D(35 downto 32))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_35 <= resize((unsigned(DEVICE_ID_BCD_DATA_D(31 downto 28))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_36 <= resize((unsigned(DEVICE_ID_BCD_DATA_D(27 downto 24))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_37 <= resize((unsigned(DEVICE_ID_BCD_DATA_D(23 downto 20))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_38 <= resize((unsigned(DEVICE_ID_BCD_DATA_D(19 downto 16))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_39 <= resize((unsigned(DEVICE_ID_BCD_DATA_D(15 downto 12))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_40 <= resize((unsigned(DEVICE_ID_BCD_DATA_D(11 downto  8))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_41 <= resize((unsigned(DEVICE_ID_BCD_DATA_D( 7 downto  4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_42 <= resize((unsigned(DEVICE_ID_BCD_DATA_D( 3 downto  0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
    
     else
         ADDR_CH_1   <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                 
--         ADDR_CH_2  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
--         ADDR_CH_3  <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--         if(BCD_BRIGHTNESS(7 downto 4)= x"0" and BCD_BRIGHTNESS(11 downto 8) = x"0")then
--            ADDR_CH_4 <= resize((unsigned(BCD_BRIGHTNESS(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_5 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_6 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--         elsif (BCD_BRIGHTNESS(11 downto 8) = x"0")then
--            ADDR_CH_4 <= resize((unsigned(BCD_BRIGHTNESS(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_5 <= resize((unsigned(BCD_BRIGHTNESS(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_6 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
--         else
--            ADDR_CH_4 <= resize((unsigned(BCD_BRIGHTNESS(11 downto 8))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_5 <= resize((unsigned(BCD_BRIGHTNESS(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_6 <= resize((unsigned(BCD_BRIGHTNESS(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--         end if;    
--         ADDR_CH_7  <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         
--         ADDR_CH_8  <= resize(18*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--         ADDR_CH_9 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--         if(BCD_CONTRAST(7 downto 4)= x"0" and BCD_CONTRAST(11 downto 8) = x"0")then
--            ADDR_CH_10 <= resize((unsigned(BCD_CONTRAST(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_11 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_12 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--         elsif (BCD_CONTRAST(11 downto 8) = x"0")then
--            ADDR_CH_10 <= resize((unsigned(BCD_CONTRAST(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_11 <= resize((unsigned(BCD_CONTRAST(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
--            ADDR_CH_12 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
--         else
--            ADDR_CH_10 <= resize((unsigned(BCD_CONTRAST(11 downto 8))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_11 <= resize((unsigned(BCD_CONTRAST(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_12 <= resize((unsigned(BCD_CONTRAST(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--         end if;   
--         ADDR_CH_13 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);

--         ADDR_CH_14 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--         ADDR_CH_15 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--         if(BCD_RETICLE_TYPE(7 downto 4)= x"0" and BCD_RETICLE_TYPE(11 downto 8) = x"0")then
--            ADDR_CH_16 <= resize((unsigned(BCD_RETICLE_TYPE(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_17 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_18 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--         elsif (BCD_RETICLE_TYPE(11 downto 8) = x"0")then
--            ADDR_CH_16 <= resize((unsigned(BCD_RETICLE_TYPE(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_17 <= resize((unsigned(BCD_RETICLE_TYPE(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
--            ADDR_CH_18 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
--         else
--            ADDR_CH_16 <= resize((unsigned(BCD_RETICLE_TYPE(11 downto 8))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_17 <= resize((unsigned(BCD_RETICLE_TYPE(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--            ADDR_CH_18 <= resize((unsigned(BCD_RETICLE_TYPE(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
--         end if;  
----         ADDR_CH_19 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
    
         ADDR_CH_2 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_3 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         if(BCD_RETICLE_HORZ(7 downto 4)= x"0" and BCD_RETICLE_HORZ(11 downto 8) = x"0")then
            ADDR_CH_4 <= resize((unsigned(BCD_RETICLE_HORZ(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_5 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_6 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         elsif (BCD_RETICLE_HORZ(11 downto 8) = x"0")then
            ADDR_CH_4 <= resize((unsigned(BCD_RETICLE_HORZ(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_5 <= resize((unsigned(BCD_RETICLE_HORZ(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
            ADDR_CH_6 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
         else
            ADDR_CH_4 <= resize((unsigned(BCD_RETICLE_HORZ(11 downto 8))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_5 <= resize((unsigned(BCD_RETICLE_HORZ(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_6 <= resize((unsigned(BCD_RETICLE_HORZ(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         end if;  
         ADDR_CH_7 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_8 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
    
         ADDR_CH_9 <= resize(33*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_10 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         if(BCD_RETICLE_VERT(7 downto 4)= x"0" and BCD_RETICLE_VERT(11 downto 8) = x"0")then
            ADDR_CH_11 <= resize((unsigned(BCD_RETICLE_VERT(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_12 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_13 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         elsif (BCD_RETICLE_VERT(11 downto 8) = x"0")then
            ADDR_CH_11 <= resize((unsigned(BCD_RETICLE_VERT(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_12 <= resize((unsigned(BCD_RETICLE_VERT(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);       
            ADDR_CH_13 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
         else
            ADDR_CH_11 <= resize((unsigned(BCD_RETICLE_VERT(11 downto 8))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_12 <= resize((unsigned(BCD_RETICLE_VERT(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_13 <= resize((unsigned(BCD_RETICLE_VERT(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         end if;  
         ADDR_CH_14 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_15 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);    
    
         ADDR_CH_16 <= resize(37*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);      
         ADDR_CH_17 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         if(BCD_DZOOM(3 downto 0)= x"0")then
            ADDR_CH_18 <= resize( 3*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_19 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         elsif(BCD_DZOOM(3 downto 0)= x"1")then
            ADDR_CH_18 <= resize( 4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_19 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);      
         elsif(BCD_DZOOM(3 downto 0)= x"2")then
            ADDR_CH_18 <= resize( 6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_19 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);      
         elsif(BCD_DZOOM(3 downto 0)= x"3")then
            ADDR_CH_18 <= resize(29*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_19 <= resize( 4*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_20 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);      
         elsif(BCD_DZOOM(3 downto 0)= x"4")then
            ADDR_CH_18 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_19 <= resize( 6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_20 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         else
            ADDR_CH_18 <= resize( 6*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_19 <= resize(35*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_20 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);              
         end if;
         ADDR_CH_21 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
        
         ADDR_CH_22 <= resize(27*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         ADDR_CH_23 <= resize( 1*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         if(POLARITY= "000")then
            ADDR_CH_24 <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_25 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--            ADDR_CH_42 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         elsif(POLARITY= "001")then   
            ADDR_CH_24 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_25 <= resize(19*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--            ADDR_CH_42 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         elsif(POLARITY= "010")then 
            ADDR_CH_24 <= resize(31*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_25 <= resize(15*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--            ADDR_CH_42 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);             
         elsif(POLARITY= "011")then   
            ADDR_CH_24 <= resize(34*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_25 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--            ADDR_CH_42 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         elsif(POLARITY= "100")then   
            ADDR_CH_24 <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
            ADDR_CH_25 <= resize(16*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
--            ADDR_CH_42 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
         end if;
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
         ADDR_CH_41 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         ADDR_CH_42 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);                
     end if;
     POS_X_INFO_DISP      <= LATCH_INFO_DISP_POS_X;
     POS_Y_INFO_DISP      <= LATCH_INFO_DISP_POS_Y;
     POS_Y_CH_1           <= (unsigned(LATCH_INFO_DISP_POS_Y)) ;
     POS_X_CH_1           <= (unsigned(LATCH_INFO_DISP_POS_X) + to_unsigned(4,POS_X_CH_1'length)); 
     INFO_DISP_REQ_XSIZE  <= LATCH_INFO_DISP_REQ_XSIZE;
     INFO_DISP_REQ_YSIZE  <= LATCH_INFO_DISP_REQ_YSIZE; 



     if INFO_DISP_REQ_V = '1' then
        CH_ROM_RDFSM <= s_IDLE; 
        CH_ADD_CNT   <= (others=>'0');
        if(INFO_DISP_FIELD = '0')then           
           DEVICE_ID_D                <= DEVICE_ID;
           if(DEVICE_ID_D /= DEVICE_ID)then
            DEVICE_ID_D_VALID <= '1';
           end if;                                                            
           INFO_DISP_EN_D             <= INFO_DISP_EN or SN_INFO_DISP_EN;
           SN_INFO_DISP_EN_D          <= SN_INFO_DISP_EN;
           if(SN_INFO_DISP_EN = '1')then
            LATCH_INFO_DISP_POS_X      <= SN_INFO_DISP_POS_X;
            LATCH_INFO_DISP_POS_Y      <= SN_INFO_DISP_POS_Y;           
           else
            LATCH_INFO_DISP_POS_X      <= INFO_DISP_POS_X;
            LATCH_INFO_DISP_POS_Y      <= INFO_DISP_POS_Y;           
           end if;
--           LATCH_INFO_DISP_POS_X      <= INFO_DISP_POS_X;
--           LATCH_INFO_DISP_POS_Y      <= INFO_DISP_POS_Y;
           LATCH_INFO_DISP_REQ_XSIZE  <= INFO_DISP_REQ_XSIZE1;
           LATCH_INFO_DISP_REQ_YSIZE  <= INFO_DISP_REQ_YSIZE1;
           LATCH_INFO_DISP_COLOR_INFO <= INFO_DISP_COLOR_INFO;
           LATCH_CH_COLOR_INFO1       <= CH_COLOR_INFO1;
           LATCH_CH_COLOR_INFO2       <= CH_COLOR_INFO2;  
           CH_ROM_ADDR_PICT           <= to_unsigned(0,CH_ROM_ADDR_PICT'length);  
           RD_INFO_DISP_LIN_NO        <= to_unsigned(0,RD_INFO_DISP_LIN_NO'length);  
        else
           INFO_DISP_EN_D             <= INFO_DISP_EN_D;
           LATCH_INFO_DISP_POS_X      <= LATCH_INFO_DISP_POS_X;
           LATCH_INFO_DISP_POS_Y      <= LATCH_INFO_DISP_POS_Y;
           LATCH_INFO_DISP_REQ_XSIZE  <= LATCH_INFO_DISP_REQ_XSIZE;
           LATCH_INFO_DISP_REQ_YSIZE  <= LATCH_INFO_DISP_REQ_YSIZE;           
           LATCH_INFO_DISP_COLOR_INFO <= LATCH_INFO_DISP_COLOR_INFO;
           LATCH_CH_COLOR_INFO1       <= LATCH_CH_COLOR_INFO1;
           LATCH_CH_COLOR_INFO2       <= LATCH_CH_COLOR_INFO2;
           LATCH_CURSOR_COLOR_INFO    <= LATCH_CURSOR_COLOR_INFO;
           --RD_INFO_DISP_LIN_NO        <= to_unsigned(1,RD_INFO_DISP_LIN_NO'length);
           --CH_ROM_ADDR_PICT           <= to_unsigned(1,CH_ROM_ADDR_PICT'length);
           CH_ROM_ADDR_PICT           <= to_unsigned(0,CH_ROM_ADDR_PICT'length);  
           RD_INFO_DISP_LIN_NO        <= to_unsigned(0,RD_INFO_DISP_LIN_NO'length);  
          
        end if;
   end if;
  end if;
end process;


 FIFO_CLR_INFO_DISP   <= INFO_DISP_REQ_V or INFO_DISP_REQ_H_DDDD;

 i_INFO_DISP_CH_RDFIFO : entity WORK.FIFO_GENERIC_SC
  generic map (
    FIFO_DEPTH => FIFO_DEPTH,
    FIFO_WIDTH => FIFO_WSIZE,
    SHOW_AHEAD => false      ,
    USE_EAB    => true
  )
  port map (
    CLK    => CLK     ,
    RST    => RST     ,
    CLR    => FIFO_CLR_INFO_DISP,
    WRREQ  => FIFO_WR_INFO_DISP ,
    WRDATA => FIFO_IN_INFO_DISP ,
    FULL   => FIFO_FUL_INFO_DISP,
    USEDW  => FIFO_NB_INFO_DISP ,
    EMPTY  => FIFO_EMP_INFO_DISP,
    RDREQ  => FIFO_RD_INFO_DISP ,
    RDDATA => FIFO_OUT_INFO_DISP_REV
  ); 
   
gen:    
    for i in 0 to 15 generate
           FIFO_OUT_INFO_DISP(i) <=FIFO_OUT_INFO_DISP_REV(15-i); 
    end generate;
     
      
  FIFO_WR1  <= VIDEO_IN_DAV;
  FIFO_IN1  <= VIDEO_IN_DATA;
  FIFO_CLR1 <= VIDEO_IN_V;   
    
    
    
  i_INFO_DISP_RDFIFO : entity WORK.FIFO_GENERIC_SC
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
        
  
  assert not ( FIFO_FUL_INFO_DISP = '1' and FIFO_WR_INFO_DISP = '1' )
    report "[MEMORY_TO_SCALER] WRITE in FIFO Full !!!" severity failure;

  process(CLK, RST)
  begin
    if RST = '1' then
      INFO_DISP_V             <= '0';
      INFO_DISP_V_D           <= '0';
      INFO_DISP_DAVi          <= '0';
      FIFO_RD_INFO_DISP   <= '0';
      FIFO_RD1          <= '0';
      INFO_DISP_DATA          <= (others => '0');
      INFO_DISP_H             <= '0';
      INFO_DISP_H_D           <= '0';
      INFO_DISP_EOI           <= '0';
      INFO_DISP_EOI_D         <= '0';
      first_time_rd_rq  <= '1'; 
      FIFO_RD1_CNT      <= 0; 
      FIFO_RD1_CNT_D    <= 0; 
      count             <= 0;
      pix_cnt_d         <= (others => '0');
      INFO_DISP_ADD_DONE      <= '0';
      flag              <= '0';
      CH_CNT_FIFO_RD    <= (others=>'0');
      CH_CNT_FIFO_RD_D  <= (others=>'0');
      INFO_DISP_LINE_CNT      <= (others=>'0'); 
      POS_X_CH_D  <= (others=>'0'); 
      POS_X_CH_DD <= (others=>'0');      
      CH_LIN_CNT_RD     <= (others=>'0');  
      INFO_DISP_REQ_V_D       <=  '0';    
      VIDEO_IN_V_D      <= '0';
      VIDEO_IN_V_DD     <= '0';
      VIDEO_IN_V_DDD    <= '0';
      VIDEO_IN_V_DDDD   <= '0';
      VIDEO_IN_H_D      <= '0';
      VIDEO_IN_H_DD     <= '0';
      VIDEO_IN_H_DDD    <= '0';
      VIDEO_IN_H_DDDD   <= '0';  
      INFO_DISP_REQ_V_D       <= '0';
      INFO_DISP_REQ_V_DD      <= '0';
      INFO_DISP_REQ_V_DDD     <= '0';    
      POS_X_CH         <= (others => '0');
      POS_Y_CH          <= (others => '0');      
    elsif rising_edge(CLK) then

--      LATCH_POS_Y_CH      <= LATCH_POS_Y_CH_1;
      CH_CNT_FIFO_RD_D <= CH_CNT_FIFO_RD;
      INFO_DISP_REQ_V_D    <= INFO_DISP_REQ_V;
      INFO_DISP_REQ_V_DD   <= INFO_DISP_REQ_V_D;
      INFO_DISP_REQ_V_DDD  <= INFO_DISP_REQ_V_DD;
      VIDEO_IN_V_D     <= VIDEO_IN_V;
      VIDEO_IN_V_DD    <= VIDEO_IN_V_D;
      VIDEO_IN_V_DDD   <= VIDEO_IN_V_DD;
      VIDEO_IN_V_DDDD  <= VIDEO_IN_V_DDD;
      VIDEO_IN_H_D     <= VIDEO_IN_H;
      VIDEO_IN_H_DD    <= VIDEO_IN_H_D;
      VIDEO_IN_H_DDD   <= VIDEO_IN_H_DD;
      VIDEO_IN_H_DDDD  <= VIDEO_IN_H_DDD;

      if(INFO_DISP_REQ_V_DDD = '1') then
          POS_Y_CH <= POS_Y_CH_1;
          CH_LIN_CNT_RD  <= (others=>'0');
      end if; 
  
      
      if INFO_DISP_EN_D ='1' then
            INFO_DISP_V         <= INFO_DISP_V_D;
            INFO_DISP_H         <= INFO_DISP_H_D;
            FIFO_RD_INFO_DISP   <= '0';
            FIFO_RD1            <= '0';
            INFO_DISP_V_D       <= '0'; 
            INFO_DISP_H_D       <= '0';
            INFO_DISP_EOI_D     <= VIDEO_IN_EOI;
            INFO_DISP_EOI       <= INFO_DISP_EOI_D;
            INFO_DISP_DAVi      <= '0';
            FIFO_RD1_D          <= FIFO_RD1;
            FIFO_RD_INFO_DISP_D <= FIFO_RD_INFO_DISP ;
            FIFO_RD1_CNT_D      <= FIFO_RD1_CNT;
            pix_cnt_d           <= pix_cnt;
            POS_X_CH_D          <= POS_X_CH;
            POS_X_CH_DD         <= POS_X_CH_D;
                       
            if VIDEO_IN_V_DDDD = '1' then
              INFO_DISP_V_D        <= '1'; 
              CH_CNT_FIFO_RD <= (others=>'0');
              INFO_DISP_LINE_CNT   <= (others=>'0');
            end if;
      
            if VIDEO_IN_H_DDDD = '1' then
              INFO_DISP_H_D      <= '1';  
              first_time_rd_rq   <= '1'; 
              FIFO_RD1_CNT       <= 0;   
              pix_cnt            <= (others => '0');
              count              <= 0;
              INFO_DISP_ADD_DONE <= '0';
              CH_CNT_FIFO_RD     <= (others=>'0');
              POS_X_CH           <= POS_X_CH_1;                        
            end if;
           
           if ((line_cnt-1) >= unsigned(POS_Y_CH(LIN_BITS-1 downto 0))) and  ((line_cnt-1) < (unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0)) + unsigned(POS_Y_CH(LIN_BITS-1 downto 0)))) then 
            if((((INFO_DISP_RD_DONE = '1') and (unsigned(FIFO_NB1) >= unsigned(CH_IMG_WIDTH)))) or (count>= (unsigned(VIDEO_IN_XSIZE))-unsigned(CH_IMG_WIDTH)))then 
                 count      <= count + 1;
                 FIFO_RD1   <= '1';
                 pix_cnt    <= pix_cnt + 1;
                 if((pix_cnt = unsigned(POS_X_CH)))then
                   FIFO_RD_INFO_DISP      <= '1';
                   INFO_DISP_ADD_DONE     <= '1';
                   FIFO_RD1_CNT     <= 0;
                 elsif(INFO_DISP_ADD_DONE = '1')then
                   if FIFO_RD1_CNT = (unsigned(CH_IMG_WIDTH) -1) then
                       INFO_DISP_ADD_DONE <= '0';
                       FIFO_RD1_CNT <= 0;
                   else
                       FIFO_RD1_CNT <= FIFO_RD1_CNT+ 1;
                   end if;                       
                 end if;  
                              
                 if((pix_cnt) = (unsigned(CH_IMG_WIDTH)- 1 + unsigned(POS_X_CH)))then
                     CH_CNT_FIFO_RD   <=  CH_CNT_FIFO_RD + 1 ; 
                      if(CH_CNT_FIFO_RD = x"00")then
                           POS_X_CH  <= resize((POS_X_CH_1+1*PIX_BETWEEN_CH_CLM+1*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"01")then
                           POS_X_CH  <= resize((POS_X_CH_1+2*PIX_BETWEEN_CH_CLM+2*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"02")then
                           POS_X_CH  <= resize((POS_X_CH_1+3*PIX_BETWEEN_CH_CLM+3*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"03")then
                           POS_X_CH  <= resize((POS_X_CH_1+4*PIX_BETWEEN_CH_CLM+4*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"04")then
                           POS_X_CH  <= resize((POS_X_CH_1+5*PIX_BETWEEN_CH_CLM+5*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"05")then
                           POS_X_CH  <= resize((POS_X_CH_1+6*PIX_BETWEEN_CH_CLM+6*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"06")then
                           POS_X_CH  <= resize((POS_X_CH_1+7*PIX_BETWEEN_CH_CLM+7*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"07")then
                           POS_X_CH  <= resize((POS_X_CH_1+8*PIX_BETWEEN_CH_CLM+8*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"08")then
                           POS_X_CH  <= resize((POS_X_CH_1+9*PIX_BETWEEN_CH_CLM+9*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"09")then
                           POS_X_CH  <= resize((POS_X_CH_1+10*PIX_BETWEEN_CH_CLM+10*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"0A")then
                           POS_X_CH  <= resize((POS_X_CH_1+11*PIX_BETWEEN_CH_CLM+11*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"0B")then
                           POS_X_CH  <= resize((POS_X_CH_1+12*PIX_BETWEEN_CH_CLM+12*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       elsif(CH_CNT_FIFO_RD = x"0C")then
                           POS_X_CH  <= resize((POS_X_CH_1+13*PIX_BETWEEN_CH_CLM+13*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"0D")then
                           POS_X_CH  <= resize((POS_X_CH_1+14*PIX_BETWEEN_CH_CLM+14*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"0E")then
                           POS_X_CH  <= resize((POS_X_CH_1+15*PIX_BETWEEN_CH_CLM+15*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"0F")then
                           POS_X_CH  <= resize((POS_X_CH_1+16*PIX_BETWEEN_CH_CLM+16*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"10")then
                           POS_X_CH  <= resize((POS_X_CH_1+17*PIX_BETWEEN_CH_CLM+17*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"11")then
                           POS_X_CH  <= resize((POS_X_CH_1+18*PIX_BETWEEN_CH_CLM+18*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"12")then
                           POS_X_CH  <= resize((POS_X_CH_1+19*PIX_BETWEEN_CH_CLM+19*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"13")then
                           POS_X_CH  <= resize((POS_X_CH_1+20*PIX_BETWEEN_CH_CLM+20*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"14")then
                           POS_X_CH  <= resize((POS_X_CH_1+21*PIX_BETWEEN_CH_CLM+21*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"15")then
                           POS_X_CH  <= resize((POS_X_CH_1+22*PIX_BETWEEN_CH_CLM+22*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"16")then
                           POS_X_CH  <= resize((POS_X_CH_1+23*PIX_BETWEEN_CH_CLM+23*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"17")then
                           POS_X_CH  <= resize((POS_X_CH_1+24*PIX_BETWEEN_CH_CLM+24*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"18")then
                           POS_X_CH  <= resize((POS_X_CH_1+25*PIX_BETWEEN_CH_CLM+25*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"19")then
                           POS_X_CH  <= resize((POS_X_CH_1+26*PIX_BETWEEN_CH_CLM+26*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"1A")then
                           POS_X_CH  <= resize((POS_X_CH_1+27*PIX_BETWEEN_CH_CLM+27*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"1B")then
                           POS_X_CH  <= resize((POS_X_CH_1+28*PIX_BETWEEN_CH_CLM+28*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"1C")then
                           POS_X_CH  <= resize((POS_X_CH_1+29*PIX_BETWEEN_CH_CLM+29*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"1D")then
                           POS_X_CH  <= resize((POS_X_CH_1+30*PIX_BETWEEN_CH_CLM+30*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"1E")then
                           POS_X_CH  <= resize((POS_X_CH_1+31*PIX_BETWEEN_CH_CLM+31*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"1F")then
                           POS_X_CH  <= resize((POS_X_CH_1+32*PIX_BETWEEN_CH_CLM+32*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"20")then
                           POS_X_CH  <= resize((POS_X_CH_1+33*PIX_BETWEEN_CH_CLM+33*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"21")then
                           POS_X_CH  <= resize((POS_X_CH_1+34*PIX_BETWEEN_CH_CLM+34*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"22")then
                           POS_X_CH  <= resize((POS_X_CH_1+35*PIX_BETWEEN_CH_CLM+35*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"23")then
                           POS_X_CH  <= resize((POS_X_CH_1+36*PIX_BETWEEN_CH_CLM+36*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"24")then
                           POS_X_CH  <= resize((POS_X_CH_1+37*PIX_BETWEEN_CH_CLM+37*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"25")then
                           POS_X_CH  <= resize((POS_X_CH_1+38*PIX_BETWEEN_CH_CLM+38*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"26")then
                           POS_X_CH  <= resize((POS_X_CH_1+39*PIX_BETWEEN_CH_CLM+39*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);  
                       elsif(CH_CNT_FIFO_RD = x"27")then
                           POS_X_CH  <= resize((POS_X_CH_1+40*PIX_BETWEEN_CH_CLM+40*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);                                      
                       elsif(CH_CNT_FIFO_RD = x"28")then
                           POS_X_CH  <= resize((POS_X_CH_1+41*PIX_BETWEEN_CH_CLM+41*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);      
                       elsif(CH_CNT_FIFO_RD = x"29")then
                           POS_X_CH  <= resize((POS_X_CH_1+42*PIX_BETWEEN_CH_CLM+42*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);    
                       end if;    
                 end if; 
                    
                 if count = (unsigned(VIDEO_IN_XSIZE))-1 then
                  count <= 0; 
                 end if;  
            else
                  FIFO_RD1     <= '0';
                  FIFO_RD_INFO_DISP  <= '0';
            end if;
            
            
            
            if FIFO_RD1_D = '1'then
               INFO_DISP_DAVi <= '1';
               if(((pix_cnt_d-1)>= (unsigned(POS_X_INFO_DISP))) and ((pix_cnt_d-1) < ((unsigned(INFO_DISP_REQ_XSIZE) + unsigned(POS_X_INFO_DISP)))))then
                  if(((pix_cnt_d-1)>= (unsigned(POS_X_CH_DD))) and ((pix_cnt_d-1) < ((unsigned(CH_IMG_WIDTH)+ unsigned(POS_X_CH_DD)))))then   
                    if(FIFO_OUT_INFO_DISP(((FIFO_RD1_CNT_D))) = '1')then  
--                        if(MUX_POLARITY='0')then                     
--                            INFO_DISP_DATA <= LATCH_CH_COLOR_INFO1;
--                        else
--                            INFO_DISP_DATA <= LATCH_CH_COLOR_INFO2;
--                        end if;    
                        INFO_DISP_DATA <= LATCH_CH_COLOR_INFO1; 
                    else 
                        INFO_DISP_DATA <= FIFO_OUT1;
                    end if;
                  else
                    INFO_DISP_DATA <= FIFO_OUT1;
                  end if;
               else
                  INFO_DISP_DATA <= FIFO_OUT1;
               end if;     
            end if; 
              
          else
             FIFO_RD_INFO_DISP     <= '0';
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
                   INFO_DISP_DAVi <= '1';
                   INFO_DISP_DATA <= FIFO_OUT1;     
              end if;        
               
           end if;
      else
          INFO_DISP_V             <= VIDEO_IN_V; 
          INFO_DISP_H             <= VIDEO_IN_H ;
          INFO_DISP_DAVi          <= VIDEO_IN_DAV;
          INFO_DISP_DATA          <= VIDEO_IN_DATA;
          INFO_DISP_EOI           <= VIDEO_IN_EOI;
          FIFO_RD_INFO_DISP       <= '0';
          FIFO_RD1                <= '0'; 
          INFO_DISP_H_D           <= '0';  
          INFO_DISP_V_D           <= '0';
          INFO_DISP_EOI_D         <= '0';
          first_time_rd_rq        <= '1'; 
          FIFO_RD1_CNT            <= 0; 
          count                   <= 0;
          FIFO_RD1_D              <= '0';
          FIFO_RD_INFO_DISP_D     <= '0';
          FIFO_RD1_CNT_D          <= 0;
          CURSOR_SEL_CNT          <= x"02";
          INFO_DISP_LINE_CNT      <= (others=>'0');
  
      end if;  
      
   end if;
    
  end process;

INFO_DISP_DAV   <= INFO_DISP_DAVi;

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



process(CLK, RST)
  begin
    if RST = '1' then
        BRIGHTNESS   <= (others =>'0');
        CONTRAST     <= (others =>'0');
        RETICLE_TYPE <= (others =>'0');
        RETICLE_HORZ <= (others =>'0');
        RETICLE_VERT <= (others =>'0'); 
        DZOOM        <= (others =>'0');
        POLARITY     <= (others =>'0');
        AGC          <= (others =>'0');  
        BCD_BRIGHTNESS   <= (others =>'0');
        BCD_CONTRAST     <= (others =>'0');
        BCD_RETICLE_TYPE <= (others =>'0');
        BCD_RETICLE_HORZ <= (others =>'0');
        BCD_RETICLE_VERT <= (others =>'0');
        BCD_DZOOM        <= (others =>'0');
        BCD_AGC          <= (others =>'0');
        bin_to_bcd_fsm   <= s_idle;
        BIN_DATA         <= (others =>'0');
        BIN_DATA_VALID   <= '0';
    elsif rising_edge(CLK) then
         BIN_DATA_VALID <= '0';
        case bin_to_bcd_fsm is
        
         when s_idle => 
            BRIGHTNESS     <= MUX_BRIGHTNESS    ; 
            CONTRAST       <= MUX_CONTRAST      ; 
            RETICLE_TYPE   <= MUX_RETICLE_TYPE  ;
            RETICLE_HORZ   <= MUX_RETICLE_HORZ  ; 
            RETICLE_VERT   <= MUX_RETICLE_VERT  ; 
            DZOOM          <= MUX_DZOOM         ; 
            AGC            <= MUX_AGC_MODE_SEL  ;    
            if(INFO_DISP_REQ_V = '1' and INFO_DISP_FIELD = '0')then
                bin_to_bcd_fsm <= s_brightness;
--                POLARITY       <= '0' &MUX_EDGE_EN & MUX_POLARITY;      
                if(MUX_EDGE_EN = '1' and MUX_POLARITY = "00")then
                    POLARITY       <= "011";
                elsif(MUX_EDGE_EN = '1' and MUX_POLARITY = "01")then
                    POLARITY       <= "100";
                elsif(MUX_POLARITY = "01")then    
                    POLARITY  <= "001";
                elsif(MUX_POLARITY = "00")then
                    POLARITY  <= "000";  
                else
                    POLARITY  <= "010";            
                end if;
            else
                bin_to_bcd_fsm <= s_idle;       
                POLARITY       <= POLARITY;
            end if;
         
         when s_brightness =>
            BIN_DATA       <= "00" &BRIGHTNESS;  
            BIN_DATA_VALID <= '1';            
            bin_to_bcd_fsm <= s_brightness_wait; 
         when s_brightness_wait =>
            if(BCD_DATA_VALID = '1')then
                BCD_BRIGHTNESS <= BCD_DATA;
                bin_to_bcd_fsm <= s_contrast; 
            end if;
         when s_contrast     => 
            BIN_DATA       <= "00" &CONTRAST;  
            BIN_DATA_VALID <= '1';
            bin_to_bcd_fsm <= s_contrast_wait; 
         when s_contrast_wait     => 
            if(BCD_DATA_VALID = '1')then
                BCD_CONTRAST   <= BCD_DATA;
                bin_to_bcd_fsm <= s_reticle_type; 
            end if; 
         when s_reticle_type => 
            BIN_DATA       <= x"0"& "00" &RETICLE_TYPE;  
            BIN_DATA_VALID <= '1';
            bin_to_bcd_fsm <= s_reticle_type_wait;
         when s_reticle_type_wait => 
            if(BCD_DATA_VALID = '1')then
                BCD_RETICLE_TYPE <= BCD_DATA;
                bin_to_bcd_fsm   <= s_reticle_horz; 
            end if;              
         when s_reticle_horz => 
            BIN_DATA       <= RETICLE_HORZ(9 downto 0);  
            BIN_DATA_VALID <= '1';
            bin_to_bcd_fsm <= s_reticle_horz_wait;
         when s_reticle_horz_wait => 
            if(BCD_DATA_VALID = '1')then
                BCD_RETICLE_HORZ <= BCD_DATA;
                bin_to_bcd_fsm   <= s_reticle_vert; 
            end if;                     
         when s_reticle_vert => 
            BIN_DATA       <= RETICLE_VERT;  
            BIN_DATA_VALID <= '1';
            bin_to_bcd_fsm <= s_reticle_vert_wait;
         when s_reticle_vert_wait => 
            if(BCD_DATA_VALID = '1')then
                BCD_RETICLE_VERT <= BCD_DATA;
                bin_to_bcd_fsm   <= s_dzoom; 
            end if;                  
         when s_dzoom    =>
            BIN_DATA       <= X"0"&"000" & DZOOM;  
            BIN_DATA_VALID <= '1';     
            bin_to_bcd_fsm <= s_dzoom_wait;      
         when s_dzoom_wait    =>
            if(BCD_DATA_VALID = '1')then
                BCD_DZOOM      <= BCD_DATA;
                bin_to_bcd_fsm <= s_agc; 
            end if;    
         when s_agc          =>
            BIN_DATA       <= x"00" &AGC;  
            BIN_DATA_VALID <= '1'; 
            bin_to_bcd_fsm <= s_agc_wait;
         when s_agc_wait    =>
            if(BCD_DATA_VALID = '1')then
                BCD_AGC        <= BCD_DATA;
                bin_to_bcd_fsm <= s_idle; 
            end if;        
         
        end case;  
        
        
        
    end if;
end process;  



i_BINARY_TO_BCD_ARCP : BINARY_TO_BCD
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

i_BINARY_TO_BCD_SN : BINARY_TO_BCD
generic map(  DATA_IN_WIDTH  => 32,
              DATA_OUT_WIDTH => 40)
port map(
 CLK                => CLK,
 RST                => RST,
 BIN_DATA_IN        => DEVICE_ID_D,
 BIN_DATA_IN_VALID  => DEVICE_ID_D_VALID,
 BCD_DATA_OUT       => DEVICE_ID_BCD_DATA,
 BCD_DATA_OUT_VALID => DEVICE_ID_BCD_DATA_VALID
); 




--probe0(0)<= INFO_DISP_DAVi;
--probe0(1)<= FIFO_EMP_INFO_DISP;
--probe0(2)<= VIDEO_IN_H;
--probe0(3)<= VIDEO_IN_V;
--probe0(4)<= VIDEO_IN_DAV;
--probe0(14 downto 5)<=FIFO_NB1;
----probe0(16 downto 11)<= std_logic_vector(DMA_ADDR_PIX_check);
--probe0(15)<= VIDEO_IN_EOI;
--probe0(16)<= INFO_DISP_EOI_D;
--probe0(17)<= FIFO_RD1;
--probe0(18)<= FIFO_WR1;
----probe0(20 downto 19)<=  (others=> '0');
----probe0(20 downto 13)<= VIDEO_IN_DATA_D;
----probe0(30 downto 21 ) <= std_logic_vector(INFO_DISP_YCNTi);
--probe0(28 downto 19)<= std_logic_vector(to_unsigned(count,10));--FIFO_OUT;
--probe0(38 downto 29)<= INFO_DISP_POS_Y;
--probe0(44 downto 39)<=  std_logic_vector(to_unsigned(FIFO_RD1_CNT,6));
--probe0(50 downto 45)<= "00000" &FIFO_NB_INFO_DISP;
--probe0(51)<= INFO_DISP_EN;
--probe0(52)<= INFO_DISP_FIELD;
--probe0(53)<= INFO_DISP_EN_D;
--probe0(54)<= FIFO_RD_INFO_DISP;
--probe0(55)<= FIFO_WR_INFO_DISP;
--probe0(65 downto 56)<=LATCH_POS_X_INFO_DISP;
----probe0(75 downto 56)<=std_logic_vector(DMA_ADDR_BASE(31 downto 12));
----probe0(66)<= flag;
--probe0(75 downto 66)<=std_logic_vector(LATCH_POS_Y_CH);
----probe0(69 downto 66)<=INFO_DISP_PIX_OFFSET;
--probe0(76)<= flag;
--probe0(77)<=FIFO_RD_INFO_DISP_1;
----probe0(77 downto 74)<= INFO_DISP_PIX_OFFSET_D;
--probe0(87 downto 78)<=std_logic_vector(RD_INFO_DISP_LIN_NO);--INFO_DISP_POS_X;
--probe0(88)<= INFO_DISP_FIELD;
--probe0(89)<=FIFO_WR_INFO_DISP_2;
----probe0(89 downto 58)<= std_logic_vector(to_unsigned(FIFO_RD1_CNT,32));--FIFO_IN;
--probe0(90) <= DMA_RDREADY;
--probe0(91) <= DMA_RDDAV;
--probe0(94 downto 92) <=DMA_RDFSM_check; 
----probe0(104 downto 95)<= std_logic_vector(INFO_DISP_XSIZE_OFFSET_L);
--probe0(104 downto 95)<= std_logic_vector(POS_X_CH);
--probe0(114 downto 105)<= std_logic_Vector(pix_cnt);
----probe0(114 downto 105)<= std_logic_Vector(INFO_DISP_cnt1);--std_logic_Vector(INFO_DISP_YCNTi);
--probe0(115)<= INFO_DISP_REQ_V;
--probe0(116)<= INFO_DISP_REQ_H;
--probe0(126 downto 117)<=std_logic_Vector(line_cnt);
----probe0(126 downto 117)<=std_logic_Vector(INFO_DISP_cnt2);
----probe0(122 downto 117)<= FIFO_NB;--INFO_DISP_LIN_NO;
----probe0(123)<= INFO_DISP_EN;
----probe0(126 downto 124 )<= (others=> '0');
--probe0(127)<= INFO_DISP_ADD_DONE;--FIFO_CLR;
----probe0(127)<= '0';
--probe0(159 downto 128)<=  FIFO_OUT_INFO_DISP;--FIFO_OUT_INFO_DISP;
--probe0(165 downto 160)<= std_logic_vector(to_unsigned(FIFO_RD1_CNT_D,6));
--probe0(166)<= FIFO_RD1_D;
--probe0(198 downto 167)<= DMA_RDDATA;
----probe0(200 downto 199) <= (others=>'0');
------probe0(200 downto 191)<=std_logic_Vector(pix_cnt_d);
------probe0(255 downto 201)<= (others=>'0');
----probe0(210 downto 201)<= std_logic_vector(RD_INFO_DISP_LIN_NO);
----probe0(220 downto 211)<= std_logic_vector(POS_X_CH);--std_logic_Vector(INFO_DISP_cnt2);--INFO_DISP_YSIZE_OFFSET;
----probe0(230 downto 221)<= std_logic_vector(LATCH_POS_Y_CH);--std_logic_Vector(INFO_DISP_cnt1);--VIDEO_IN_YSIZE;
----probe0(240 downto 231)<=std_logic_vector(INFO_DISP_XSIZE_OFFSET_R);
--probe0(206 downto 199) <= std_logic_vector(CURSOR_SEL_CNT);
--probe0(214 downto 207) <= std_logic_vector(CH_CNT_FIFO_RD);
--probe0(221 downto 215) <= (others=>'0');
----probe0(221 downto 199) <= std_logic_vector(DMA_ADDR_PICT);
--probe0(229 downto 222) <= std_logic_vector(CH_CNT_FIFO_RD_D);
--probe0(230)<= FIFO_RD_INFO_DISP_2;
--probe0(238 downto 231)<= SEL_CH_WR_FIFO;
--probe0(239)<= DMA_RDDAV_D;
----probe0(239)<= DMA_RDDAV_D;
--probe0(240)<= FIFO_WR_INFO_DISP_1;
----probe0(240 downto 239)<=(others=>'0');
--probe0(241)           <=INFO_DISP_RD_DONE;
--probe0(249 downto 242)<= std_logic_vector(CH_CNT);
--probe0(253 downto 250)<= LATCH_CURSOR_POS;
--probe0(255 downto 254)<= (others=>'0');

--probe0(0)<= INFO_DISP_DAVi;
--probe0(1)<= FIFO_EMP_INFO_DISP;
--probe0(2)<= VIDEO_IN_H;
--probe0(3)<= VIDEO_IN_V;
--probe0(4)<= VIDEO_IN_DAV;
--probe0(5)<= INFO_DISP_REQ_V;
--probe0(6)<= INFO_DISP_REQ_H;
--probe0(7)<= INFO_DISP_FIELD;
--probe0(17 downto 8)<=FIFO_NB1;
----probe0(16 downto 11)<= std_logic_vector(DMA_ADDR_PIX_check);
--probe0(18)<= VIDEO_IN_EOI;
--probe0(19)<= INFO_DISP_EOI_D;
--probe0(20)<= FIFO_RD1;
--probe0(21)<= FIFO_WR1;
--probe0(31 downto 22)<= std_logic_vector(to_unsigned(count,10));--FIFO_OUT;
--probe0(41 downto 32)<= std_logic_Vector(line_cnt);
--probe0(51 downto 42)<= std_logic_Vector(pix_cnt);
--probe0(52)<= INFO_DISP_EN;
--probe0(53)<= INFO_DISP_EN_D;
--probe0(54)<= FIFO_RD_INFO_DISP;
--probe0(55)<= FIFO_WR_INFO_DISP;
--probe0(65 downto 56)<=  std_logic_Vector(POS_X_CH_D);
--probe0(75 downto 66)<=  std_logic_Vector(pix_cnt_d);
--probe0(83 downto 76)<=  std_logic_Vector(lin_block_cnt_dd);
--probe0(91 downto 84)<=  std_logic_Vector(lin_block_cnt_d);
--probe0(99 downto 92)<=  std_logic_Vector(lin_block_cnt);
--probe0(107 downto 100)<=  std_logic_Vector(clm_block_cnt);
--probe0(117 downto 108)<=  std_logic_Vector(POS_X_CH_DD);
--probe0(127 downto 118)<=  std_logic_Vector(POS_X_CH);

--i_ila_INFO_DISP: ila_0
--PORT MAP (
--  clk => CLK,
--  probe0 => probe0
--);
--------------------------
end architecture RTL;
--------------------------