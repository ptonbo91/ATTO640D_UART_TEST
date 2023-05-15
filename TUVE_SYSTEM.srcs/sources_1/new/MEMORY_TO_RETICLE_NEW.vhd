
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

Library xpm;
  use xpm.vcomponents.all; 

----------------------------------
entity MEMORY_TO_RETICLE_NEW is
----------------------------------
  generic (
    PIX_BITS  : positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS  : positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image 
    RETICLE_INIT_MEMORY_WR_SIZE : positive;
    VIDEO_X_OFFSET_PAL  : integer := 38;
    VIDEO_Y_OFFSET_PAL  : integer := 48; 
    VIDEO_X_OFFSET_OLED : integer := 160;
    VIDEO_Y_OFFSET_OLED : integer := 120
  );
  port (
    -- Clock and Reset
    CLK                        : in  std_logic;                              -- Module Clock
    RST                        : in  std_logic;                              -- Module Reset (Asynchronous active high)
    video_start                : in  std_logic;  
    sel_oled_analog_video_out  : in  std_logic;
    RETICLE_COLOR_SEL          : in  std_logic_vector(2 downto 0);        
    RETICLE_COLOR_TH           : in  std_logic_vector(15 downto 0);
    COLOR_SEL_WINDOW_XSIZE     : in  std_logic_vector(9 downto 0);    
    COLOR_SEL_WINDOW_YSIZE     : in  std_logic_vector(LIN_BITS-1 downto 0);    
    qspi_reticle_transfer_done : in std_logic;
    qspi_reticle_transfer_rq_ack: in std_logic;
    qspi_reticle_transfer_rq   : out std_logic;
    reticle_sel                : out std_logic_Vector(6 downto 0);
    RETICLE_OFFSET_RD_REQ      : in  std_logic;
    RETICLE_OFFSET_RD_ADDR     : in  std_logic_vector(3 downto 0);
    RETICLE_OFFSET_RD_DATA     : out std_logic_vector(31 downto 0);
    RETICLE_OFFSET_WR_EN_IN    : in  std_logic_vector(0 downto 0);           -- Block ram write enable (Reticle offset write data)
    RETICLE_OFFSET_WR_DATA_IN  : in  std_logic_Vector(31 downto 0);          -- Block ram write data (Reticle offset write data) 
    RETICLE_WR_EN_IN           : in  std_logic_vector(0 downto 0);           -- Block ram write enable (Reticle write data)
    RETICLE_WR_DATA_IN         : in  std_logic_Vector(31 downto 0);          -- Block ram write data (Reticle write data) 
    RETICLE_EN                 : in  std_logic;                              -- Enable reticle
    RETICLE_TYPE               : in  std_logic_vector(6 downto 0);           -- SELSECT RETICLE TYPE
--    RETICLE_COLOR_INFO1        : in  std_logic_vector( 23 downto 0);     -- RETICLE COLOR1
--    RETICLE_COLOR_INFO2        : in  std_logic_vector( 23 downto 0);     -- RETICLE COLOR2
    RETICLE_COLOR_INFO1        : in  std_logic_vector(7 downto 0);     -- RETICLE COLOR1
    RETICLE_COLOR_INFO2        : in  std_logic_vector(7 downto 0);     -- RETICLE COLOR2
    RETICLE_POS_X              : in  std_logic_vector(PIX_BITS-1 downto 0);  -- RETICLE POSITION X
    RETICLE_POS_Y              : in  std_logic_vector(LIN_BITS-1 downto 0);  -- RETICLE POSITION Y
    MEM_IMG_XSIZE              : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture X Size (max 1023)
    MEM_IMG_YSIZE              : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture Y Size (max 1023)
    
    RETICLE_REQ_V              : in  std_logic;                              -- Scaler New Frame Request
    RETICLE_REQ_H              : in  std_logic;                              -- Scaler New Line Request
    RETICLE_FIELD              : in  std_logic;                              -- FIELD
    RETICLE_REQ_XSIZE          : in std_logic_vector(PIX_BITS-1 downto 0);   -- Width of image required by scaler
    RETICLE_REQ_YSIZE          : in std_logic_vector(LIN_BITS-1 downto 0);   -- Height of image required by scaler
    
    VIDEO_IN_V                 : in std_logic;                              -- Scaler New Frame
    VIDEO_IN_H                 : in std_logic;
    VIDEO_IN_DAV               : in std_logic;                              -- Scaler New Data
--    VIDEO_IN_DATA              : in std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    VIDEO_IN_DATA              : in std_logic_vector(7 downto 0);
    VIDEO_IN_EOI               : in std_logic;
    VIDEO_IN_XSIZE             : in std_logic_vector(PIX_BITS-1 downto 0);  -- Width of output image
    VIDEO_IN_YSIZE             : in std_logic_vector(LIN_BITS-1 downto 0);  -- Height of output image

    RETICLE_V                  : out std_logic;                              -- Scaler New Frame
    RETICLE_H                  : out std_logic;
    RETICLE_DAV                : out std_logic;                              -- Scaler New Data
--    RETICLE_DATA               : out std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    RETICLE_DATA               : out std_logic_vector(7 downto 0);
    RETICLE_EOI                : out std_logic;
    RETICLE_POS_X_OUT          : out std_logic_vector(PIX_BITS-1 downto 0);
    RETICLE_POS_Y_OUT          : out std_logic_vector(LIN_BITS-1 downto 0)
  );
----------------------------------
end entity MEMORY_TO_RETICLE_NEW;
----------------------------------


------------------------------------------
architecture RTL of MEMORY_TO_RETICLE_NEW is
------------------------------------------

--COMPONENT ila_0

--PORT (
--  clk : IN STD_LOGIC;



--  probe0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0)
--);
--END COMPONENT;


--COMPONENT bpr_reticle
--  PORT (
--    clka : IN STD_LOGIC;
--    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--  );
--END COMPONENT;

COMPONENT bpr_reticle
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;



COMPONENT TOII_TUVE_ila

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

  
  signal RETICLE_OFFSET_RD_DATA_TEMP : std_logic_Vector(31 downto 0);
  signal probe0 : std_logic_vector(127 downto 0);
  
  type RETICLE_RDFSM_t is ( s_IDLE, s_WAIT_H );
  signal RETICLE_RDFSM    : RETICLE_RDFSM_t;
  signal RETICLE_DAVi     : std_logic;
  signal RETICLE_V_D      : std_logic;  
  signal RETICLE_H_D      : std_logic; 
  signal RETICLE_EOI_D    : std_logic;
  signal FIFO_RD1_CNT     : unsigned(PIX_BITS-1 downto 0);
  signal FIFO_RD1_CNT_D   : unsigned(PIX_BITS-1 downto 0);
  signal first_time_rd_rq : std_logic;
  signal RETICLE_EN_D     : std_logic;
--  signal Reticle_cnt1 : unsigned(9 downto 0);
--  signal Reticle_cnt2 : unsigned(9 downto 0);
  
  signal LATCH_RETICLE_POS_X       : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_RETICLE_POS_Y       : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_RETICLE_COLOR_INFO1 : std_logic_vector( 23 downto 0);
--  signal LATCH_RETICLE_COLOR_INFO2 : std_logic_vector( 23 downto 0);
  signal LATCH_RETICLE_COLOR_INFO1 : std_logic_vector(7 downto 0);
  signal LATCH_RETICLE_COLOR_INFO2 : std_logic_vector(7 downto 0);
    
  signal line_cnt           : unsigned(LIN_BITS-1 downto 0);
  signal pix_cnt            : unsigned(PIX_BITS-1 downto 0);
  signal pix_cnt_d          : unsigned(PIX_BITS-1 downto 0);
  signal RD_RETICLE_LIN_NO  : unsigned(LIN_BITS-1 downto 0);
  signal RETICLE_ADD_DONE   : std_logic; 
  signal RETICLE_POS_Y_TEMP : std_logic_Vector(LIN_BITS-1 downto 0); 
  signal RETICLE_POS_Y_D    : std_logic_Vector(LIN_BITS-1 downto 0); 
    
  signal RETICLE_XSIZE_OFFSET_R : std_logic_vector(PIX_BITS-1 downto 0);
  signal RETICLE_XSIZE_OFFSET_L : std_logic_vector(PIX_BITS-1 downto 0);
  signal RETICLE_YSIZE_OFFSET   : std_logic_vector(LIN_BITS-1 downto 0);
  signal RETICLE_PIX_OFFSET     : std_logic_vector(3 downto 0);
  signal RETICLE_PIX_OFFSET_D   : std_logic_vector(3 downto 0);
  signal RETICLE_RD_DONE        : std_logic;
  signal RETICLE_YSIZE_OFFSET_D : std_logic_vector(LIN_BITS-1 downto 0); 
  signal RETICLE_POS_Y_TEMP_D   : std_logic_vector(LIN_BITS-1 downto 0); 
  signal out_line_cnt           : unsigned(LIN_BITS-1 downto 0);

--  signal VIDEO_IN_DATA_DD : std_logic_vector(23 downto 0);
--  signal VIDEO_IN_DATA_D  : std_logic_vector(23 downto 0);
  signal VIDEO_IN_DATA_DD : std_logic_vector(7 downto 0);
  signal VIDEO_IN_DATA_D  : std_logic_vector(7 downto 0);
  signal VIDEO_IN_DAV_DD  : std_logic;
  signal VIDEO_IN_DAV_D   : std_logic;
  
  signal reticle_rd_addr        : std_logic_vector(14 downto 0);
  signal reticle_wr_addr        : std_logic_vector(14 downto 0);
  signal reticle_wr_addr_temp   : unsigned(14 downto 0);
  signal reticle_rd_addr_temp   : std_logic_vector(14 downto 0);
  signal reticle_rd_addr_base   : unsigned(19 downto 0);
  signal reticle_rd_data        : std_logic_vector(31 downto 0);
  signal reticle_addr           : std_logic_vector(14 downto 0);
  
  signal reticle_wr_en          : std_logic_vector(0 downto 0);
  signal reticle_wr_data        : std_logic_vector(31 downto 0);
  signal RETICLE_TYPE_D         : std_logic_vector(6 downto 0);
  signal qspi_reticle_change_rq : std_logic;
  signal qspi_reticle_change_en : std_logic;
  
  type reticle_transfer_st_t is (s_reticle_IDLE,s_reticle_transfer,s_reticle_req_wait);
  signal reticle_transfer_st   : reticle_transfer_st_t;
  signal rd_wr_sel             : std_logic; 
  signal LATCH_RETICLE_COLOR_SEL : std_logic_vector(2 downto 0);
   
  signal pix_sum   : unsigned (31 downto 0);
  signal pix_avg   : unsigned (7 downto 0);

  signal change_reticle_color : std_logic;

  signal start_div : std_logic;
  signal dvsr      : std_logic_vector(31 downto 0);
  signal dvnd      : std_logic_vector(31 downto 0);
  signal done_tick : STD_LOGIC;
  signal quo       : STD_LOGIC_VECTOR(31 downto 0);
  signal rmd       : STD_LOGIC_VECTOR(31 downto 0);  


  signal reticle_offset_wr_addr        : std_logic_vector(3 downto 0);
  signal reticle_offset_wr_addr_temp   : unsigned(4 downto 0);
  signal reticle_offset_wr_data        : std_logic_vector(31 downto 0);

  type reticle_offset_transfer_st_t is (s_reticle_offset_IDLE,s_reticle_offset_transfer,s_reticle_offset_transfer_done);
  signal reticle_offset_transfer_st   : reticle_offset_transfer_st_t;
  signal reticle_offset_wr_req        : std_logic_vector(0 downto 0); 
  
  signal reticle_offset_rd_req_init   : std_logic; 
  signal reticle_offset_rd_req_or     : std_logic; 

  signal VIDEO_X_OFFSET : unsigned(PIX_BITS-1 downto 0);
  signal VIDEO_Y_OFFSET : unsigned(LIN_BITS-1 downto 0);  

  ATTRIBUTE KEEP : string;
--  ATTRIBUTE KEEP of done_tick             : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of change_reticle_color  : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of VIDEO_IN_H            : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of VIDEO_IN_V            : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of VIDEO_IN_DAV          : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of out_line_cnt          : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of VIDEO_IN_EOI          : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of RETICLE_EOI_D         : SIGNAL IS "TRUE"; 
--  ATTRIBUTE KEEP of VIDEO_IN_DAV_D        : SIGNAL IS "TRUE"; 
--  ATTRIBUTE KEEP of VIDEO_IN_DAV_DD       : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of pix_sum               : SIGNAL IS "TRUE"; 
--  ATTRIBUTE KEEP of RETICLE_EN            : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of start_div             : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of RETICLE_EN_D          : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of RETICLE_REQ_V         : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of RETICLE_REQ_H         : SIGNAL IS "TRUE"; 
--  ATTRIBUTE KEEP of pix_avg               : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of quo                   : SIGNAL IS "TRUE"; 
--  ATTRIBUTE KEEP of dvsr                  : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of RETICLE_POS_Y         : SIGNAL IS "TRUE"; 
--  ATTRIBUTE KEEP of RETICLE_POS_X         : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of pix_cnt_d             : SIGNAL IS "TRUE"; 
  
ATTRIBUTE KEEP of RETICLE_OFFSET_WR_EN_IN      : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of RETICLE_OFFSET_RD_ADDR       : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of RETICLE_OFFSET_RD_REQ        : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of RETICLE_OFFSET_WR_DATA_IN    : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of reticle_offset_wr_addr       : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of reticle_offset_wr_addr_temp  : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of reticle_offset_wr_data       : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of reticle_offset_wr_req        : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of reticle_offset_transfer_st   : SIGNAL IS "TRUE"; 
ATTRIBUTE KEEP of RETICLE_OFFSET_RD_DATA_TEMP  : SIGNAL IS "TRUE"; 
  

--  ATTRIBUTE KEEP of  line_cnt: SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  in_line_cnt: SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  out_line_cnt: SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  pix_cnt: SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  pix_cnt_d: SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_XSIZE_OFFSET_L_D   : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_XSIZE_OFFSET_R_D   : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  LATCH_RETICLE_POS_X_D      : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  LATCH_RETICLE_POS_Y_D      : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  RETICLE_YSIZE_OFFSET_D     : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  RETICLE_POS_Y_TEMP_D       : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  RETICLE_XSIZE_OFFSET_L     : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  RETICLE_XSIZE_OFFSET_R     : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  LATCH_RETICLE_POS_X        : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  LATCH_RETICLE_POS_Y        : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  RETICLE_YSIZE_OFFSET       : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  RETICLE_POS_Y_TEMP         : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  RD_RETICLE_LIN_NO          : SIGNAL IS "TRUE";  
--  ATTRIBUTE KEEP of  RETICLE_POS_X              : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  RETICLE_POS_Y              : SIGNAL IS "TRUE";
  
--ATTRIBUTE KEEP of qspi_reticle_change_en    : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of FIFO_RD1_CNT              : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_POS_Y             : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_PIX_OFFSET        : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of qspi_reticle_change_rq    : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_EN                : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_RD_DONE           : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_REQ_V             : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_PIX_OFFSET_D      : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of LATCH_RETICLE_POS_Y       : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_FIELD             : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of first_time_rd_rq          : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_TYPE              : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_TYPE_D            : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RD_RETICLE_LIN_NO         : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_REQ_H             : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of line_cnt                  : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_DAVi              : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of VIDEO_IN_H                : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of VIDEO_IN_V                : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of VIDEO_IN_DAV              : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_YSIZE_OFFSET      : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of VIDEO_IN_EOI              : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_EOI_D             : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of VIDEO_IN_DAV_D            : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of VIDEO_IN_DAV_DD           : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of reticle_rd_addr_base      : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of out_line_cnt              : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_ADD_DONE          : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_RDFSM             : SIGNAL IS "TRUE"; 
  

--------
begin


--DMA_RDFSM_check <=  "000" when DMA_RDFSM = s_IDLE else
--                    "001" when DMA_RDFSM = s_WAIT_H else
--                    "010" when DMA_RDFSM = s_GET_ADDR else
--                    "011" when DMA_RDFSM = s_READ else
--                    "111";
  
RETICLE_OFFSET_RD_DATA <= RETICLE_OFFSET_RD_DATA_TEMP;  
  process(CLK, RST)
  begin
    if RST = '1' then
      RETICLE_RDFSM             <= s_IDLE;
      LATCH_RETICLE_COLOR_INFO1 <= x"EB";--x"EB8080";
      LATCH_RETICLE_COLOR_INFO2 <= x"10";--x"108080";
      LATCH_RETICLE_POS_X       <= (others => '0');
      LATCH_RETICLE_POS_Y       <= (others => '0');
      line_cnt                  <= (others => '0');
      RD_RETICLE_LIN_NO         <= (others => '0');
      RETICLE_POS_Y_TEMP        <= (others => '0');
      RETICLE_YSIZE_OFFSET      <= (others => '0');
      RETICLE_XSIZE_OFFSET_R    <= (others =>'0');
      RETICLE_XSIZE_OFFSET_L    <= (others =>'0');
      RETICLE_POS_Y_D           <= (others => '0');
      RETICLE_RD_DONE           <= '0';
      RETICLE_POS_X_OUT         <= std_logic_vector(to_unsigned(357,RETICLE_POS_X'length));
      RETICLE_POS_Y_OUT         <= std_logic_vector(to_unsigned(285,RETICLE_POS_Y'length));
      reticle_rd_addr_base      <= (others => '0');
      RETICLE_EN_D              <= '0';
      RETICLE_TYPE_D            <= (others => '0');
      reticle_sel               <= (others => '0');      
      qspi_reticle_change_en    <= '0';
      LATCH_RETICLE_COLOR_SEL   <= std_logic_vector(to_unsigned(0,LATCH_RETICLE_COLOR_SEL'length));
      
--      RETICLE_PIX_OFFSET_L <= (others =>'0');

    elsif rising_edge(CLK) then

      qspi_reticle_change_en <= '0';
       
      case RETICLE_RDFSM is         

        when s_IDLE =>  
            line_cnt <= (others => '0');
            if RETICLE_EN_D ='1' then
             RETICLE_RDFSM <= s_WAIT_H;
            end if; 
            
        when s_WAIT_H =>
            if RETICLE_REQ_H = '1' then
              line_cnt <= line_cnt + 1;
              if (line_cnt >= unsigned(LATCH_RETICLE_POS_Y(LIN_BITS-1 downto 0))) and  (line_cnt < (unsigned(MEM_IMG_YSIZE(LIN_BITS-1 downto  0)) + unsigned(LATCH_RETICLE_POS_Y(LIN_BITS-1 downto 0)) - unsigned(RETICLE_YSIZE_OFFSET))) then
                RD_RETICLE_LIN_NO    <= RD_RETICLE_LIN_NO + 1;
                reticle_rd_addr_base <= (unsigned(MEM_IMG_XSIZE(9 downto 0)))*RD_RETICLE_LIN_NO +  unsigned("00" &RETICLE_XSIZE_OFFSET_L(PIX_BITS-1 downto 4));
              end if;  
              RETICLE_RDFSM <= s_WAIT_H;
            end if;
        end case;


      if RETICLE_REQ_V = '1' then
        RETICLE_RDFSM <= s_IDLE; 
        if(RETICLE_FIELD = '0')then                        
             RETICLE_TYPE_D <= RETICLE_TYPE;
             if(RETICLE_TYPE_D/= RETICLE_TYPE) then
                reticle_sel            <= RETICLE_TYPE;
                RETICLE_EN_D           <= '0';
                qspi_reticle_change_en <= '1';
                
             else
                RETICLE_EN_D           <= RETICLE_EN;
             end if;                                               
             LATCH_RETICLE_COLOR_SEL   <= RETICLE_COLOR_SEL;
             LATCH_RETICLE_COLOR_INFO1 <= RETICLE_COLOR_INFO1;
             LATCH_RETICLE_COLOR_INFO2 <= RETICLE_COLOR_INFO2;
             RETICLE_POS_Y_D           <= RETICLE_POS_Y;
             
            if(unsigned(RETICLE_POS_X) < (unsigned(VIDEO_IN_XSIZE) - unsigned(RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1))))then
              if(unsigned(RETICLE_POS_X) <  unsigned(RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1))) then
                LATCH_RETICLE_POS_X    <= std_logic_vector(to_unsigned(0,LATCH_RETICLE_POS_X'length));
                RETICLE_XSIZE_OFFSET_L <= std_logic_vector((unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1)) - unsigned(RETICLE_POS_X))- to_unsigned(1,RETICLE_XSIZE_OFFSET_L'length));
              else
                LATCH_RETICLE_POS_X    <= std_logic_vector((unsigned(RETICLE_POS_X) - unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1))) + to_unsigned(1,LATCH_RETICLE_POS_X'length));
                RETICLE_XSIZE_OFFSET_L <= (others=>'0');
              end if;   
              RETICLE_XSIZE_OFFSET_R <= (others=>'0');
              RETICLE_POS_X_OUT      <= RETICLE_POS_X;
            else 
               if(unsigned(RETICLE_POS_X) < unsigned(VIDEO_IN_XSIZE)) then
                LATCH_RETICLE_POS_X    <= std_logic_vector((unsigned(RETICLE_POS_X) - unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1))) + to_unsigned(1,LATCH_RETICLE_POS_X'length));
                RETICLE_XSIZE_OFFSET_R <= std_logic_vector((unsigned(RETICLE_POS_X) + unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1)) + to_unsigned(1,RETICLE_XSIZE_OFFSET_R'length)) -unsigned(VIDEO_IN_XSIZE));
                RETICLE_POS_X_OUT      <= RETICLE_POS_X;
               else
                LATCH_RETICLE_POS_X    <= std_logic_vector(unsigned(VIDEO_IN_XSIZE) - unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1)));-- - to_unsigned(1,LATCH_RETICLE_POS_X'length));
                RETICLE_XSIZE_OFFSET_R <= std_logic_vector(unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1)));
                RETICLE_POS_X_OUT      <= std_logic_vector(unsigned(VIDEO_IN_XSIZE) - to_unsigned(1,RETICLE_POS_X_OUT'length));
               end if; 
               RETICLE_XSIZE_OFFSET_L  <= (others=>'0'); 
            end if;


            if(unsigned(RETICLE_POS_Y)< (unsigned(VIDEO_IN_YSIZE) - unsigned(RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1))))then  
                if(unsigned(RETICLE_POS_Y)<unsigned(RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)))then
                     RETICLE_YSIZE_OFFSET  <= std_logic_vector(unsigned('0'&RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)) - unsigned(RETICLE_POS_Y(LIN_BITS-1 downto 0))- to_unsigned(1,RETICLE_YSIZE_OFFSET'length));
                     RD_RETICLE_LIN_NO     <= (unsigned('0' &RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)) - to_unsigned(1,RD_RETICLE_LIN_NO'length)) - unsigned( RETICLE_POS_Y) ;  
                     RETICLE_POS_Y_TEMP    <= std_logic_vector(to_unsigned(0,LATCH_RETICLE_POS_Y'length));
                     LATCH_RETICLE_POS_Y   <= std_logic_vector(to_unsigned(0,LATCH_RETICLE_POS_Y'length));                     
                else    
                    LATCH_RETICLE_POS_Y <= std_logic_vector(unsigned(RETICLE_POS_Y) - unsigned('0' &RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1))+ to_unsigned(1,LATCH_RETICLE_POS_Y'length));
                    RD_RETICLE_LIN_NO   <= to_unsigned(0,RD_RETICLE_LIN_NO'length);
                    RETICLE_YSIZE_OFFSET <= (others=>'0');
                    RETICLE_POS_Y_TEMP   <= std_logic_vector(unsigned(RETICLE_POS_Y) - unsigned('0' &RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)) + to_unsigned(1,LATCH_RETICLE_POS_Y'length));
                end if;  
                RETICLE_POS_Y_OUT        <= RETICLE_POS_Y;  
                
            else
                if(RETICLE_POS_Y < VIDEO_IN_YSIZE)then
                    LATCH_RETICLE_POS_Y  <= std_logic_vector(unsigned(RETICLE_POS_Y) - unsigned('0' & RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1))+ to_unsigned(1,LATCH_RETICLE_POS_Y'length));
                    RD_RETICLE_LIN_NO    <= to_unsigned(0,RD_RETICLE_LIN_NO'length);
                    RETICLE_YSIZE_OFFSET <= std_logic_vector(unsigned(RETICLE_POS_Y(LIN_BITS-1 downto 0)) -  (unsigned(VIDEO_IN_YSIZE(LIN_BITS-1 downto 0)) - unsigned('0'& RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1))) + to_unsigned(1,LATCH_RETICLE_POS_Y'length));    -- NEW ADD                  
                    RETICLE_POS_Y_OUT   <= RETICLE_POS_Y;  
                else
                    LATCH_RETICLE_POS_Y  <= std_logic_vector(unsigned(VIDEO_IN_YSIZE) - unsigned('0'&RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)));
                    RD_RETICLE_LIN_NO    <= to_unsigned(0,RD_RETICLE_LIN_NO'length);
                    RETICLE_YSIZE_OFFSET <= std_logic_vector(unsigned('0' & RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)));-- - to_unsigned(1,RETICLE_YSIZE_OFFSET'length));
                    RETICLE_POS_Y_OUT    <= std_logic_vector(unsigned(VIDEO_IN_YSIZE) - to_unsigned(1,RETICLE_POS_Y_OUT'length));  
                end if;    

            end if;  
          
       else
           RETICLE_EN_D              <= RETICLE_EN_D;
           LATCH_RETICLE_COLOR_SEL   <= LATCH_RETICLE_COLOR_SEL;
           LATCH_RETICLE_COLOR_INFO1 <= LATCH_RETICLE_COLOR_INFO1;
           LATCH_RETICLE_COLOR_INFO2 <= LATCH_RETICLE_COLOR_INFO2;
           LATCH_RETICLE_POS_X       <= LATCH_RETICLE_POS_X;  
           RETICLE_XSIZE_OFFSET_R    <= RETICLE_XSIZE_OFFSET_R;
           RETICLE_XSIZE_OFFSET_L    <= RETICLE_XSIZE_OFFSET_L;    
--           LATCH_RETICLE_POS_Y       <= RETICLE_POS_Y_TEMP; 
       end if;    
     end if;

   end if;
 end process;



 process(CLK, RST)
   begin
     if RST = '1' then
        reticle_wr_addr        <= (others=>'0');
        reticle_wr_addr_temp   <= (others=>'0');
        reticle_wr_data        <= (others=>'0');
        reticle_wr_en          <= "0";
        rd_wr_sel              <= '0';
        qspi_reticle_change_rq <= '0';
        qspi_reticle_transfer_rq <= '0';
        reticle_transfer_st    <= s_reticle_idle;
        reticle_offset_transfer_st    <= s_reticle_offset_idle;
        reticle_offset_wr_addr        <= (others=>'0');
        reticle_offset_wr_addr_temp   <= (others=>'0');
        reticle_offset_wr_data        <= (others=>'0');
        reticle_offset_wr_req         <= "0";   
        reticle_offset_rd_req_init    <= '0';    
     elsif rising_edge(CLK) then

        if(qspi_reticle_change_en = '1')then
            qspi_reticle_change_rq <= '1';  
        end if; 

        case reticle_transfer_st is
        
            when s_reticle_idle =>
                reticle_transfer_st  <= s_reticle_transfer;
                reticle_wr_en        <= "0";
                reticle_wr_addr_temp <= (others=>'0');
                rd_wr_sel            <= '0';
                
            when s_reticle_transfer =>
                    if(qspi_reticle_transfer_rq_ack = '1')then
                        qspi_reticle_transfer_rq <= '0';
                    end if;
                    rd_wr_sel <= '0';
--                    if(reticle_wr_addr_temp = 1200)then
                    if(reticle_wr_addr_temp =to_unsigned(RETICLE_INIT_MEMORY_WR_SIZE,reticle_wr_addr_temp'length))then
                        reticle_wr_en        <= "0";
                        reticle_wr_addr_temp <= (others=>'0');
                        reticle_transfer_st  <= s_reticle_req_wait;
                    else
                        reticle_transfer_st  <= s_reticle_transfer;
                        if(RETICLE_WR_EN_IN = "1")then
                            reticle_wr_data      <= RETICLE_WR_DATA_IN;
                            reticle_wr_en        <= "1";
                            reticle_wr_addr      <= std_logic_Vector(reticle_wr_addr_temp);
                            reticle_wr_addr_temp <= reticle_wr_addr_temp +1; 
                        else
                            reticle_wr_en        <= "0";
                        end if;    
                    end if;

             when s_reticle_req_wait =>
                    rd_wr_sel            <= '1';
                    reticle_wr_en        <= "0";
                    reticle_wr_addr_temp <= (others=>'0');              
                    if(qspi_reticle_change_rq='1' and qspi_reticle_transfer_done='1')then
                        reticle_transfer_st      <= s_reticle_transfer;
                        qspi_reticle_transfer_rq <= '1';
                        qspi_reticle_change_rq   <= '0';
                    else
                        reticle_transfer_st  <= s_reticle_req_wait;
                    end if; 
        end case;     

        case reticle_offset_transfer_st is
        
            when s_reticle_offset_idle =>
                reticle_offset_transfer_st  <= s_reticle_offset_transfer;
                reticle_offset_wr_req       <="0";
                reticle_offset_wr_addr_temp <= (others=>'0');
                reticle_offset_rd_req_init  <= '0';
                
            when s_reticle_offset_transfer =>
                    if(reticle_offset_wr_addr_temp =to_unsigned(16,reticle_offset_wr_addr_temp'length))then
                        reticle_offset_wr_req       <= "0";
--                        reticle_offset_wr_addr_temp <= (others=>'0');
                        reticle_offset_transfer_st  <= s_reticle_offset_transfer_done;
                        reticle_offset_rd_req_init  <= '1';
                    else
                        reticle_offset_transfer_st  <= s_reticle_offset_transfer;
                        if(RETICLE_OFFSET_WR_EN_IN = "1")then
                            reticle_offset_wr_data      <= RETICLE_OFFSET_WR_DATA_IN;
                            reticle_offset_wr_req       <= "1";
                            reticle_offset_wr_addr      <= std_logic_Vector(reticle_offset_wr_addr_temp(3 downto 0));
                            reticle_offset_wr_addr_temp <= reticle_offset_wr_addr_temp +1; 
                        else
                            reticle_offset_wr_req         <= "0";
                        end if;    
                    end if;

             when s_reticle_offset_transfer_done =>
                    reticle_offset_wr_req       <= "0";
                    reticle_offset_wr_addr_temp <= (others=>'0');              
                    reticle_offset_transfer_st  <= s_reticle_offset_transfer_done;
                    reticle_offset_rd_req_init  <= '0';
                                
            end case;   

     end if;
 end process;

reticle_addr <=  reticle_wr_addr when  rd_wr_sel = '0' else reticle_rd_addr;
 
i_bpr_reticle : bpr_reticle
  PORT MAP (
    clka  => CLK,
    wea   => reticle_wr_en,
    addra => reticle_addr,
    dina  => reticle_wr_data,
    douta => reticle_rd_data
  );
 
 reticle_offset_rd_req_or <= reticle_offset_rd_req_init or RETICLE_OFFSET_RD_REQ;

  reticle_offset_data : xpm_memory_sdpram
   generic map (
      ADDR_WIDTH_A => 4,               -- DECIMAL
      ADDR_WIDTH_B => 4,               -- DECIMAL
      AUTO_SLEEP_TIME => 0,            -- DECIMAL
      BYTE_WRITE_WIDTH_A => 32,        -- DECIMAL
      CASCADE_HEIGHT => 0,             -- DECIMAL
      CLOCKING_MODE => "common_clock", -- String
      ECC_MODE => "no_ecc",            -- String
      MEMORY_INIT_FILE => "none",      -- String
      MEMORY_INIT_PARAM => "0",        -- String
      MEMORY_OPTIMIZATION => "true",   -- String
      MEMORY_PRIMITIVE => "auto",      -- String
      MEMORY_SIZE => 512,             -- DECIMAL
      MESSAGE_CONTROL => 0,            -- DECIMAL
      READ_DATA_WIDTH_B => 32,         -- DECIMAL
      READ_LATENCY_B => 1,             -- DECIMAL
      READ_RESET_VALUE_B => "0",       -- String
      RST_MODE_A => "SYNC",            -- String
      RST_MODE_B => "SYNC",            -- String
      SIM_ASSERT_CHK => 0,             -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_EMBEDDED_CONSTRAINT => 0,    -- DECIMAL
      USE_MEM_INIT => 1,               -- DECIMAL
      WAKEUP_TIME => "disable_sleep",  -- String
      WRITE_DATA_WIDTH_A => 32,        -- DECIMAL
      WRITE_MODE_B => "no_change"      -- String
   )
   port map (
      dbiterrb => open,             -- 1-bit output: Status signal to indicate double bit error occurrence
                                        -- on the data output of port B.

      doutb    => RETICLE_OFFSET_RD_DATA_TEMP,                   -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
      sbiterrb => open,             -- 1-bit output: Status signal to indicate single bit error occurrence
                                        -- on the data output of port B.

      addra => reticle_offset_wr_addr,                   -- ADDR_WIDTH_A-bit input: Address for port A write operations.
      addrb => RETICLE_OFFSET_RD_ADDR,                   -- ADDR_WIDTH_B-bit input: Address for port B read operations.
      clka  => CLK,                     -- 1-bit input: Clock signal for port A. Also clocks port B when
                                        -- parameter CLOCKING_MODE is "common_clock".

      clkb  => CLK,                     -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                        -- "independent_clock". Unused when parameter CLOCKING_MODE is
                                        -- "common_clock".

      dina => reticle_offset_wr_data,                     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      ena  => reticle_offset_wr_req(0),                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                        -- cycles when write operations are initiated. Pipelined internally.

      enb  => reticle_offset_rd_req_or,--RETICLE_OFFSET_RD_REQ,                       -- 1-bit input: Memory enable signal for port B. Must be high on clock
                                        -- cycles when read operations are initiated. Pipelined internally.

      injectdbiterra => '0', -- 1-bit input: Controls double bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      injectsbiterra => '0', -- 1-bit input: Controls single bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      regceb => '0',                 -- 1-bit input: Clock Enable for the last register stage on the output
                                        -- data path.

      rstb => RST,                     -- 1-bit input: Reset signal for the final port B output register
                                        -- stage. Synchronously resets output port doutb to the value specified
                                        -- by parameter READ_RESET_VALUE_B.

      sleep => '0',                   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
      wea   => reticle_offset_wr_req                       -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                        -- for port A input data port dina. 1 bit wide when word-wide writes
                                        -- are used. In byte-wide write configurations, each bit controls the
                                        -- writing one byte of dina to address addra. For example, to
                                        -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                        -- is 32, wea would be 4'b0010.

   ); 

 
      
 process(CLK, RST)
   begin
     if RST = '1' then
       RETICLE_V            <= '0';
       RETICLE_V_D          <= '0';
       RETICLE_DAVi         <= '0';
       RETICLE_DATA         <= (others => '0');
       RETICLE_H            <= '0';
       RETICLE_H_D          <= '0';
       RETICLE_EOI          <= '0';
       RETICLE_EOI_D        <= '0';
       first_time_rd_rq     <= '1'; 
       FIFO_RD1_CNT         <= (others => '0'); 
       FIFO_RD1_CNT_D       <= (others => '0'); 
       pix_cnt              <= (others => '0');
       pix_cnt_d            <= (others => '0');
       RETICLE_ADD_DONE     <= '0';
       RETICLE_PIX_OFFSET   <= (others => '0');
       RETICLE_PIX_OFFSET_D <= (others => '0');
       out_line_cnt         <= (others => '0');
       VIDEO_IN_DATA_DD     <= (others => '0');
       VIDEO_IN_DATA_D      <= (others => '0');
       VIDEO_IN_DAV_DD      <= '0';
       VIDEO_IN_DAV_D       <= '0';
       reticle_rd_addr      <= (others => '0');
       reticle_rd_addr_temp <= (others => '0');
       pix_sum              <= (others => '0');
       pix_avg              <= (others => '0');
       start_div            <= '0';
       dvsr                 <= (others => '0');
       dvnd                 <= (others => '0');
       change_reticle_color <= '0';
       VIDEO_X_OFFSET <= to_unsigned(VIDEO_X_OFFSET_OLED,PIX_BITS);
       VIDEO_Y_OFFSET <= to_unsigned(VIDEO_Y_OFFSET_OLED,LIN_BITS);
     elsif rising_edge(CLK) then
     
     if(sel_oled_analog_video_out='1')then
      VIDEO_X_OFFSET <= to_unsigned(VIDEO_X_OFFSET_PAL,PIX_BITS);
      VIDEO_Y_OFFSET <= to_unsigned(VIDEO_Y_OFFSET_PAL,LIN_BITS);
     else
      VIDEO_X_OFFSET <= to_unsigned(VIDEO_X_OFFSET_OLED,PIX_BITS);
      VIDEO_Y_OFFSET <= to_unsigned(VIDEO_Y_OFFSET_OLED,LIN_BITS);     
     end if;
     
     start_div       <= '0';
     
     if(done_tick='1')then
      pix_avg <= unsigned(quo(7 downto 0));
     end if;
     
     
     if RETICLE_EN_D ='1' then
           RETICLE_V      <= RETICLE_V_D;
           RETICLE_H      <= RETICLE_H_D;
           RETICLE_V_D    <= '0'; 
           RETICLE_H_D    <= '0';
           RETICLE_EOI_D  <= VIDEO_IN_EOI;
           RETICLE_EOI    <= RETICLE_EOI_D;
           RETICLE_DAVi   <= '0';
           FIFO_RD1_CNT_D <= FIFO_RD1_CNT;
           pix_cnt_d      <= pix_cnt;
           RETICLE_PIX_OFFSET_D <= RETICLE_PIX_OFFSET;
           VIDEO_IN_DAV_D <= VIDEO_IN_DAV;
           VIDEO_IN_DAV_DD <= VIDEO_IN_DAV_D;
           
           VIDEO_IN_DATA_D <= VIDEO_IN_DATA;
           VIDEO_IN_DATA_DD <= VIDEO_IN_DATA_D;
           

           
           if VIDEO_IN_V = '1' then
             RETICLE_V_D     <= '1'; 
             out_line_cnt    <= (others => '0');
             start_div       <= '1';
             dvnd            <= std_logic_vector(pix_sum);
             dvsr            <= std_logic_vector(resize(unsigned(COLOR_SEL_WINDOW_XSIZE) * unsigned(COLOR_SEL_WINDOW_YSIZE),dvnd'length));
             pix_sum         <= (others => '0');  
             if(pix_avg <= unsigned(RETICLE_COLOR_TH(7 downto 0)))then
              change_reticle_color <= '0'; 
             elsif(pix_avg >= unsigned(RETICLE_COLOR_TH(15 downto 8)))then
              change_reticle_color <= '1'; 
             else
              change_reticle_color <= change_reticle_color; 
             end if;                  
           end if;
     
           if VIDEO_IN_H = '1' then
             RETICLE_H_D <= '1';  
             first_time_rd_rq <= '1'; 
             FIFO_RD1_CNT <=(others => '0');   
             pix_cnt   <= (others => '0');
             RETICLE_ADD_DONE <= '0';
             out_line_cnt     <= out_line_cnt   +1;
             reticle_rd_addr_temp  <= std_logic_vector(reticle_rd_addr_base(14 downto 0));
                        
             RETICLE_PIX_OFFSET <= RETICLE_XSIZE_OFFSET_L(3 downto 0);
             
           end if;
          
          
 
          if ((out_line_cnt-1) >= unsigned(LATCH_RETICLE_POS_Y(LIN_BITS-1 downto 0))) and  ((out_line_cnt-1) < (unsigned(RETICLE_REQ_YSIZE(LIN_BITS-1 downto  0)) + unsigned(LATCH_RETICLE_POS_Y(LIN_BITS-1 downto 0)) - unsigned(RETICLE_YSIZE_OFFSET))) then                         
           if(VIDEO_IN_DAV = '1')then

                pix_cnt      <= pix_cnt + 1;

                if((pix_cnt>= unsigned(LATCH_RETICLE_POS_X)) and (pix_cnt < (((unsigned(RETICLE_REQ_XSIZE)-to_unsigned(15,pix_cnt'length)) + unsigned(LATCH_RETICLE_POS_X))- unsigned(RETICLE_XSIZE_OFFSET_L))))then
                    if FIFO_RD1_CNT = (to_unsigned(15,FIFO_RD1_CNT'length) - unsigned(RETICLE_PIX_OFFSET)) or first_time_rd_rq = '1'  then
                             reticle_rd_addr <= reticle_rd_addr_temp;
                             reticle_rd_addr_temp <= std_logic_vector(unsigned(reticle_rd_addr_temp) + 1);
                             FIFO_RD1_CNT <= (others => '0');
                             first_time_rd_rq <= '0';   

                             if((FIFO_RD1_CNT = (to_unsigned(15,FIFO_RD1_CNT'length) - unsigned(RETICLE_PIX_OFFSET)))and first_time_rd_rq = '0')then
                         
                                 RETICLE_PIX_OFFSET <= (others=>'0');
                             else 
                                 RETICLE_PIX_OFFSET <=  RETICLE_PIX_OFFSET;
                             end if; 

                    else  
                     FIFO_RD1_CNT  <= FIFO_RD1_CNT + 1;    
   
                    end if;  
                    if(pix_cnt = ((((unsigned(RETICLE_REQ_XSIZE))-to_unsigned(16,pix_cnt'length)) + unsigned(LATCH_RETICLE_POS_X))- unsigned(RETICLE_XSIZE_OFFSET_L))) then
                     RETICLE_ADD_DONE <= '1';
                    end if;                 
                else
                    if(RETICLE_ADD_DONE = '1')then
                         if FIFO_RD1_CNT = to_unsigned(15,FIFO_RD1_CNT'length) then
                             FIFO_RD1_CNT  <= to_unsigned(15,FIFO_RD1_CNT'length);
                         else
                             FIFO_RD1_CNT  <= FIFO_RD1_CNT+ 1;
                         end if;    
                         
                    end if;        
                
                end if;
           end if;
           
          
           if VIDEO_IN_DAV_DD = '1'then
                if(((pix_cnt_d-1)>= (unsigned(LATCH_RETICLE_POS_X))) and ((pix_cnt_d-1) < ((unsigned(RETICLE_REQ_XSIZE) + unsigned(LATCH_RETICLE_POS_X)) - (unsigned(RETICLE_XSIZE_OFFSET_R) +unsigned(RETICLE_XSIZE_OFFSET_L)))))then
                     RETICLE_DAVi <= '1';  
 
                     if(reticle_rd_data((2*(to_integer(FIFO_RD1_CNT_D)+to_integer(unsigned(RETICLE_PIX_OFFSET_D)))) + 1)='1')then
                          
                          if(reticle_rd_data((2*(to_integer(FIFO_RD1_CNT_D) + to_integer(unsigned(RETICLE_PIX_OFFSET_D))))) = '1')then
                             if(unsigned(LATCH_RETICLE_COLOR_SEL) >= 5)then
                                 if(change_reticle_color = '1')then   
                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2; --LATCH_RETICLE_COLOR_INFO2(23 downto 0);
                                 else   
                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1;  --LATCH_RETICLE_COLOR_INFO1(23 downto 0);
                                 end if;  
                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 4)then
                                RETICLE_DATA <= x"B4";--x"B48080"; 
                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 3)then
                                RETICLE_DATA <= x"80";--x"808080";     
                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 2)then
                                RETICLE_DATA <= x"50";--x"508080";                                
                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 1)then
                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2;     --LATCH_RETICLE_COLOR_INFO2(23 downto 0);
                             else
                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1; --LATCH_RETICLE_COLOR_INFO1(23 downto 0);   
                             end if;
                                  
 --                            Reticle_cnt1 <= Reticle_cnt1 + 1;
                          else
                             if(unsigned(LATCH_RETICLE_COLOR_SEL) >= 5)then
                                 if(change_reticle_color = '1')then   
                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1;--LATCH_RETICLE_COLOR_INFO1(23 downto 0);
                                 else   
                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2;--LATCH_RETICLE_COLOR_INFO2(23 downto 0);
                                 end if;  
                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 4)then
                                RETICLE_DATA <= x"50";--x"508080"; 
                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 3)then
                                RETICLE_DATA <= x"10";--x"108080";    
                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 2)then
                                RETICLE_DATA <= x"B4";--x"B48080";                                
                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 1)then
                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1;--LATCH_RETICLE_COLOR_INFO1(23 downto 0);
                             else
                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2;--LATCH_RETICLE_COLOR_INFO2(23 downto 0);
                             end if;                          
--                             if(unsigned(LATCH_RETICLE_COLOR_SEL) >= 2)then
--                                 if(change_reticle_color = '1')then
--                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1(23 downto 0);
--                                 else   
--                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2(23 downto 0);
--                                 end if; 
--                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 1)then
--                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1(23 downto 0);
--                             else
--                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2(23 downto 0);
--                             end if;   
--                             RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2(23 downto 0);
 --                            Reticle_cnt2 <= Reticle_cnt2 + 1;
                          end if;   
                     else 
                         RETICLE_DATA <= VIDEO_IN_DATA_DD;
                     end if;

--                     if(unsigned(RETICLE_POS_Y) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1)))then
--                        if (unsigned(RETICLE_POS_X) < to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))then
--                          if (((pix_cnt_d-1) >= to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) >= to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)) and ((out_line_cnt-1) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum; 
--                          end if;
--                        else
--                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))) and (((out_line_cnt-1) >= to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)) and ((out_line_cnt-1) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum;
--                          end if;
--                        end if;
--                     else
--                        if (unsigned(RETICLE_POS_X) < to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))then
--                          if (((pix_cnt_d-1) >= to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum;
--                          end if;
--                        else
--                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" &COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" &COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum; 
--                          end if;
--                        end if;                     
--                     end if;      
                     if(unsigned(RETICLE_POS_Y) >= unsigned(VIDEO_IN_YSIZE) - (VIDEO_Y_OFFSET + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))then
                        if (unsigned(RETICLE_POS_X) >= unsigned(VIDEO_IN_XSIZE) -(VIDEO_X_OFFSET + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1))))then
                          if (((pix_cnt_d-1) >= unsigned(VIDEO_IN_XSIZE) -(VIDEO_X_OFFSET + unsigned(COLOR_SEL_WINDOW_XSIZE))) and ((pix_cnt_d-1) < unsigned(VIDEO_IN_XSIZE) - VIDEO_X_OFFSET)) and (((out_line_cnt-1) >= unsigned(VIDEO_IN_YSIZE) - (VIDEO_Y_OFFSET + unsigned(COLOR_SEL_WINDOW_YSIZE))) and ((out_line_cnt-1) < unsigned(VIDEO_IN_YSIZE) - VIDEO_Y_OFFSET)) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum; 
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum;
                          end if;
                        elsif (unsigned(RETICLE_POS_X) < VIDEO_X_OFFSET + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1)))then
                          if (((pix_cnt_d-1) >= VIDEO_X_OFFSET and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) >= unsigned(VIDEO_IN_YSIZE) - (VIDEO_Y_OFFSET + unsigned(COLOR_SEL_WINDOW_YSIZE))) and ((out_line_cnt-1) < unsigned(VIDEO_IN_YSIZE) - VIDEO_Y_OFFSET))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum;
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum; 
                          end if;
                        else
                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1)))) and (((out_line_cnt-1) >= unsigned(VIDEO_IN_YSIZE) - (VIDEO_Y_OFFSET + unsigned(COLOR_SEL_WINDOW_YSIZE))) and ((out_line_cnt-1) < unsigned(VIDEO_IN_YSIZE) -VIDEO_Y_OFFSET))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum;
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum;
                          end if;
                        end if;
                     elsif(unsigned(RETICLE_POS_Y) < VIDEO_Y_OFFSET + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1)))then
                        if (unsigned(RETICLE_POS_X) >= unsigned(VIDEO_IN_XSIZE) -(VIDEO_X_OFFSET + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1))))then
                          if (((pix_cnt_d-1) >= unsigned(VIDEO_IN_XSIZE) -(VIDEO_X_OFFSET + unsigned(COLOR_SEL_WINDOW_XSIZE)) and ((pix_cnt_d-1) < unsigned(VIDEO_IN_XSIZE) - VIDEO_X_OFFSET)) and (((out_line_cnt-1) >= VIDEO_Y_OFFSET) and ((out_line_cnt-1) < VIDEO_Y_OFFSET + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum; 
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum; 
                          end if;
                        elsif (unsigned(RETICLE_POS_X) < VIDEO_X_OFFSET + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1)))then
                          if (((pix_cnt_d-1) >= VIDEO_X_OFFSET and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) >= VIDEO_Y_OFFSET) and ((out_line_cnt-1) < VIDEO_Y_OFFSET + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum; 
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum;  
                          end if;
                        else
                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1)))) and (((out_line_cnt-1) >= VIDEO_Y_OFFSET) and ((out_line_cnt-1) < VIDEO_Y_OFFSET + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum;
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum;
                          end if;
                        end if;
                     else
                        if (unsigned(RETICLE_POS_X) >= unsigned(VIDEO_IN_XSIZE) -(VIDEO_X_OFFSET + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1))))then
                          if (((pix_cnt_d-1) >= unsigned(VIDEO_IN_XSIZE) -(VIDEO_X_OFFSET + unsigned(COLOR_SEL_WINDOW_XSIZE)) and ((pix_cnt_d-1) < unsigned(VIDEO_IN_XSIZE) - VIDEO_X_OFFSET)) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum;
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum; 
                          end if;                     
                        elsif (unsigned(RETICLE_POS_X) < VIDEO_X_OFFSET + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1)))then
                          if (((pix_cnt_d-1) >= VIDEO_X_OFFSET and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum;
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum;
                          end if;
                        else
                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(9 downto 1)))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" &COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" &COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(23 downto 16)) + pix_sum; 
                            pix_sum <= unsigned(VIDEO_IN_DATA_DD) + pix_sum; 
                          end if;
                        end if;                     
                     end if;      

               else
                     RETICLE_DAVi <= '1';         
                     RETICLE_DATA <= VIDEO_IN_DATA_DD;
               end if; 
           end if; 
             
          else
             if(VIDEO_IN_DAV_DD = '1')then
                   RETICLE_DAVi <= '1';    
                   RETICLE_DATA <=VIDEO_IN_DATA_DD;
             end if;       
              
          end if;
     
     else
         RETICLE_V    <=  VIDEO_IN_V; 
         RETICLE_H    <=  VIDEO_IN_H ;
         RETICLE_DAVi <=  VIDEO_IN_DAV;
         RETICLE_DATA <=  VIDEO_IN_DATA;
         RETICLE_EOI  <=  VIDEO_IN_EOI;
         
         RETICLE_H_D <= '0';  
         RETICLE_V_D <= '0';
         RETICLE_EOI_D    <= '0';

         first_time_rd_rq <= '1'; 
         FIFO_RD1_CNT   <= (others=>'0');
         FIFO_RD1_CNT_D <= (others=>'0');
 
     end if;  
       
    end if;
     
   end process;

  RETICLE_DAV   <= RETICLE_DAVi;


  i_div : entity WORK.div
 generic map(
  W    => 32,
  CBIT => 6
  )
 port map(

  clk   => CLK,
  reset => RST,
  start => start_div ,
  dvsr  => dvsr, 
  dvnd  => dvnd,
  done_tick => done_tick,
  quo => quo, 
  rmd => rmd
  ); 



--probe0(0)<= RETICLE_DAVi;
--probe0(1)<= '0';
--probe0(2)<= VIDEO_IN_H;
--probe0(3)<= VIDEO_IN_V;
--probe0(4)<= VIDEO_IN_DAV;
--probe0(14 downto 5)<=RETICLE_YSIZE_OFFSET;--(others=> '0');--FIFO_NB1(9 downto 0);
----probe0(16 downto 11)<= std_logic_vector(DMA_ADDR_PIX_check);
--probe0(15)<= VIDEO_IN_EOI;
--probe0(16)<= RETICLE_EOI_D;
--probe0(17)<= VIDEO_IN_DAV_D;--FIFO_RD1;
--probe0(18)<= VIDEO_IN_DAV_DD;--FIFO_WR1;
----probe0(20 downto 19)<=  (others=> '0');
----probe0(20 downto 13)<= VIDEO_IN_DATA_D;
----probe0(30 downto 21 ) <= std_logic_vector(RETICLE_YCNTi);
--probe0(34 downto 19)<= std_logic_Vector(reticle_rd_addr_base(15 downto 0));--(others=> '0');   --std_logic_vector(to_unsigned(count,10));--FIFO_OUT;
--probe0(44 downto 35)<= std_logic_vector(out_line_cnt);
--probe0(50 downto 45)<=  std_logic_vector(FIFO_RD1_CNT(5 downto 0));
----probe0(50 downto 46)<= (others=> '0'); --FIFO_NB(5 downto 0);
----probe0(55 downto 53)<= SCALER_SEL;
--probe0(51)<= RETICLE_EN;
--probe0(52)<= '0';
--probe0(53)<= RETICLE_EN_D;
--probe0(54)<= qspi_reticle_change_en;
--probe0(55)<= '0';--FIFO_WR;
--probe0(65 downto 56)<= RETICLE_POS_Y;--(others=> '0');--LATCH_RETICLE_POS_X_D;
----probe0(77 downto 68)<=LATCH_RETICLE_POS_Y;
--probe0(69 downto 66)<=RETICLE_PIX_OFFSET;
--probe0(70)<= qspi_reticle_change_rq;
--probe0(71)<= RETICLE_EN;
--probe0(72)<= RETICLE_RD_DONE;
--probe0(73)<= RETICLE_REQ_V;--FIFO_CLR;
--probe0(77 downto 74)<= RETICLE_PIX_OFFSET_D;
--probe0(87 downto 78)<=LATCH_RETICLE_POS_Y;--RETICLE_POS_X;
--probe0(88)<= RETICLE_FIELD;
--probe0(89)<=first_time_rd_rq;
----probe0(89 downto 58)<= std_logic_vector(to_unsigned(FIFO_RD1_CNT,32));--FIFO_IN;
----probe0(90) <= '0';--DMA_RDREADY;
----probe0(91) <= '0';--DMA_RDDAV; 
--probe0(91 downto 90) <=std_logic_vector(to_unsigned(RETICLE_RDFSM_t'POS(RETICLE_RDFSM), 2));--std_logic_vector(to_unsigned(DMA_RDFSM_t'POS(DMA_RDFSM), 2)); --DMA_RDFSM_check; 
----probe0(104 downto 95)<= LATCH_RETICLE_POS_Y;--(others=> '0');--std_logic_vector(RETICLE_XSIZE_OFFSET_L_D);
----probe0(114 downto 105)<= std_logic_Vector(pix_cnt);
--probe0(98 downto 92)<= RETICLE_TYPE;
--probe0(105 downto 99)<= RETICLE_TYPE_D;
--probe0(115 downto 106)<= std_logic_vector(RD_RETICLE_LIN_NO);--(others=> '0');--RETICLE_DATA;
----probe0(114 downto 105)<= std_logic_Vector(Reticle_cnt1);--std_logic_Vector(RETICLE_YCNTi);
----probe0(115)<= RETICLE_REQ_V;

--probe0(116)<= RETICLE_REQ_H;
--probe0(126 downto 117)<=std_logic_Vector(line_cnt);
----probe0(126 downto 117)<=std_logic_Vector(Reticle_cnt2);
----probe0(122 downto 117)<= FIFO_NB;--RETICLE_LIN_NO;
----probe0(123)<= RETICLE_EN;
----probe0(126 downto 124 )<= (others=> '0');
--probe0(127)<= RETICLE_ADD_DONE;--FIFO_CLR;



----probe0(127)<= '0';
----probe0(159 downto 128)<= reticle_rd_data;
----probe0(165 downto 160)<= std_logic_Vector(FIFO_RD1_CNT_D(5 downto 0));
----probe0(166)<= FIFO_RD1_D;
------probe0(190 downto 167)<=FIFO_OUT1;
------probe0(176 downto 167)<= RETICLE_XSIZE_OFFSET_L;
------probe0(186 downto 177)<= RETICLE_XSIZE_OFFSET_R;
------probe0(190 downto 187)<= MEM_IMG_XSIZE(3 downto 0);--(others=>'0');

----probe0(190 downto 167)<= VIDEO_IN_DATA_DD;
----probe0(200 downto 191)<=std_logic_Vector(pix_cnt_d);
------probe0(255 downto 201)<= (others=>'0');
----probe0(210 downto 201)<= std_logic_vector(RD_RETICLE_LIN_NO);
----probe0(220 downto 211)<= LATCH_RETICLE_POS_X;--LATCH_RETICLE_POS_Y_D;
------probe0(221)<= DMA_RDREQ_D;
----probe0(221)<= RETICLE_EN;
----probe0(232 downto 222)<= std_logic_Vector(reticle_rd_addr);
------probe0(220 downto 211)<= std_logic_Vector(Reticle_cnt2);--RETICLE_YSIZE_OFFSET;
------probe0(230 downto 221)<= std_logic_Vector(Reticle_cnt1);--VIDEO_IN_YSIZE;
----probe0(243 downto 233)<=reticle_rd_addr_temp;--;MEM_IMG_XSIZE;--(others=> '0');--std_logic_vector(RETICLE_XSIZE_OFFSET_R_D);
------probe0(241)<=RETICLE_RD_DONE;
----probe0(253 downto 244)<= RETICLE_POS_Y_D;--VIDEO_IN_DATA(13 downto 1);
----probe0(255 downto 254)<= (others=>'0');
  

--probe0(0) <= done_tick;
--probe0(1) <= change_reticle_color;
--probe0(2) <= VIDEO_IN_H;
--probe0(3) <= VIDEO_IN_V;
--probe0(4) <= VIDEO_IN_DAV;
--probe0(14 downto 5)<= std_logic_vector(out_line_cnt);
--probe0(15) <= VIDEO_IN_EOI;
--probe0(16) <= RETICLE_EOI_D;
--probe0(17) <= VIDEO_IN_DAV_D;--FIFO_RD1;
--probe0(18) <= VIDEO_IN_DAV_DD;--FIFO_WR1; 
--probe0(50 downto 19)<=  std_logic_vector(pix_sum);
--probe0(51)<= RETICLE_EN;
--probe0(52)<= start_div;
--probe0(53)<= RETICLE_EN_D;
--probe0(54)<= RETICLE_REQ_V;--FIFO_CLR;
--probe0(55)<= RETICLE_REQ_H;
--probe0(63 downto 56) <= std_logic_vector(pix_avg);
--probe0(95 downto 64) <= quo;
--probe0(105 downto 96) <= RETICLE_POS_Y;
--probe0(115 downto 106) <= RETICLE_POS_X;
--probe0(125 downto 116) <= std_logic_vector(pix_cnt_d);
----probe0(103 downto 94) <= LATCH_RETICLE_POS_X;
----probe0(113 downto 104) <= LATCH_RETICLE_POS_Y;
----probe0(121 downto 114) <= VIDEO_IN_DATA_DD(23 downto 16);
--probe0(126) <= VIDEO_IN_H;
--probe0(127) <= VIDEO_IN_V;
----probe0(127 downto 126) <= (others=>'0');
----probe0(127 downto 96)<= dvsr;



--probe0(0) <= VIDEO_IN_H;
--probe0(1) <= VIDEO_IN_V;
--probe0(2) <= VIDEO_IN_DAV;
--probe0(3 downto 3)   <= RETICLE_OFFSET_WR_EN_IN;--RETICLE_EN;
--probe0(4)            <= RETICLE_OFFSET_RD_REQ;--start_div;
--probe0(8 downto  5)  <= RETICLE_OFFSET_RD_ADDR;
--probe0(40 downto 9)  <= RETICLE_OFFSET_RD_DATA_TEMP;
--probe0(72 downto 41) <= RETICLE_OFFSET_WR_DATA_IN;
--probe0(74 downto 73) <= std_logic_vector(to_unsigned(reticle_offset_transfer_st_t'POS(reticle_offset_transfer_st), 2));
--probe0(78 downto 75) <= reticle_offset_wr_addr;
--probe0(83 downto 79) <= std_logic_Vector(reticle_offset_wr_addr_temp);
--probe0(84 downto 84) <= reticle_offset_wr_req;
--probe0(116 downto 85)<= reticle_offset_wr_data;
--probe0(127 downto 117) <= (others=>'0');

--i_TOII_TUVE_ila: TOII_TUVE_ila
--PORT MAP (
--  clk => CLK,
--  probe0 => probe0
--);

--------------------------
end architecture RTL;
--------------------------





--library IEEE;
--  use IEEE.std_logic_1164.all;
--  use IEEE.numeric_std.all;

--Library xpm;
--  use xpm.vcomponents.all; 

------------------------------------
--entity MEMORY_TO_RETICLE_NEW is
------------------------------------
--  generic (
--    PIX_BITS  : positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
--    LIN_BITS  : positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image 
--    RETICLE_INIT_MEMORY_WR_SIZE : positive;
--    VIDEO_X_OFFSET : positive := 38;
--    VIDEO_Y_OFFSET : positive := 48 
--  );
--  port (
--    -- Clock and Reset
--    CLK                        : in  std_logic;                              -- Module Clock
--    RST                        : in  std_logic;                              -- Module Reset (Asynchronous active high)
--    video_start                : in  std_logic;  
--    RETICLE_COLOR_SEL          : in  std_logic_vector(1 downto 0);        
--    RETICLE_COLOR_TH           : in  std_logic_vector(15 downto 0);
--    COLOR_SEL_WINDOW_XSIZE     : in  std_logic_vector(PIX_BITS-1 downto 0);    
--    COLOR_SEL_WINDOW_YSIZE     : in  std_logic_vector(LIN_BITS-1 downto 0);    
--    qspi_reticle_transfer_done : in std_logic;
--    qspi_reticle_transfer_rq_ack: in std_logic;
--    qspi_reticle_transfer_rq   : out std_logic;
--    reticle_sel                : out std_logic_Vector(6 downto 0);
--    RETICLE_OFFSET_RD_REQ      : in  std_logic;
--    RETICLE_OFFSET_RD_ADDR     : in  std_logic_vector(3 downto 0);
--    RETICLE_OFFSET_RD_DATA     : out std_logic_vector(31 downto 0);
--    RETICLE_OFFSET_WR_EN_IN    : in  std_logic_vector(0 downto 0);           -- Block ram write enable (Reticle offset write data)
--    RETICLE_OFFSET_WR_DATA_IN  : in  std_logic_Vector(31 downto 0);          -- Block ram write data (Reticle offset write data) 
--    RETICLE_WR_EN_IN           : in  std_logic_vector(0 downto 0);           -- Block ram write enable (Reticle write data)
--    RETICLE_WR_DATA_IN         : in  std_logic_Vector(31 downto 0);          -- Block ram write data (Reticle write data) 
--    RETICLE_EN                 : in  std_logic;                              -- Enable reticle
--    RETICLE_TYPE               : in  std_logic_vector(6 downto 0);           -- SELSECT RETICLE TYPE
--    RETICLE_COLOR_INFO1        : in  std_logic_vector( 7 downto 0);     -- RETICLE COLOR1
--    RETICLE_COLOR_INFO2        : in  std_logic_vector( 7 downto 0);     -- RETICLE COLOR2
--    RETICLE_POS_X              : in  std_logic_vector(PIX_BITS-1 downto 0);  -- RETICLE POSITION X
--    RETICLE_POS_Y              : in  std_logic_vector(LIN_BITS-1 downto 0);  -- RETICLE POSITION Y
--    MEM_IMG_XSIZE              : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture X Size (max 1023)
--    MEM_IMG_YSIZE              : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture Y Size (max 1023)
    
--    RETICLE_REQ_V              : in  std_logic;                              -- Scaler New Frame Request
--    RETICLE_REQ_H              : in  std_logic;                              -- Scaler New Line Request
--    RETICLE_FIELD              : in  std_logic;                              -- FIELD
--    RETICLE_REQ_XSIZE          : in std_logic_vector(PIX_BITS-1 downto 0);   -- Width of image required by scaler
--    RETICLE_REQ_YSIZE          : in std_logic_vector(LIN_BITS-1 downto 0);   -- Height of image required by scaler
    
--    VIDEO_IN_V                 : in std_logic;                              -- Scaler New Frame
--    VIDEO_IN_H                 : in std_logic;
--    VIDEO_IN_DAV               : in std_logic;                              -- Scaler New Data
--    VIDEO_IN_DATA              : in std_logic_vector(7 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
--    VIDEO_IN_EOI               : in std_logic;
--    VIDEO_IN_XSIZE             : in std_logic_vector(PIX_BITS-1 downto 0);  -- Width of output image
--    VIDEO_IN_YSIZE             : in std_logic_vector(LIN_BITS-1 downto 0);  -- Height of output image

--    RETICLE_V                  : out std_logic;                              -- Scaler New Frame
--    RETICLE_H                  : out std_logic;
--    RETICLE_DAV                : out std_logic;                              -- Scaler New Data
--    RETICLE_DATA               : out std_logic_vector(7 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
--    RETICLE_EOI                : out std_logic;
--    RETICLE_POS_X_OUT          : out std_logic_vector(PIX_BITS-1 downto 0);
--    RETICLE_POS_Y_OUT          : out std_logic_vector(LIN_BITS-1 downto 0)
--  );
------------------------------------
--end entity MEMORY_TO_RETICLE_NEW;
------------------------------------


--------------------------------------------
--architecture RTL of MEMORY_TO_RETICLE_NEW is
--------------------------------------------

----COMPONENT ila_0

----PORT (
----  clk : IN STD_LOGIC;



----  probe0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0)
----);
----END COMPONENT;


----COMPONENT bpr_reticle
----  PORT (
----    clka : IN STD_LOGIC;
----    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
----    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
----  );
----END COMPONENT;

--COMPONENT bpr_reticle
--  PORT (
--    clka : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--  );
--END COMPONENT;



--COMPONENT TOII_TUVE_ila

--PORT (
--  clk : IN STD_LOGIC;



--  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
--);
--END COMPONENT;

  
--  signal RETICLE_OFFSET_RD_DATA_TEMP : std_logic_Vector(31 downto 0);
--  signal probe0 : std_logic_vector(127 downto 0);
  
--  type RETICLE_RDFSM_t is ( s_IDLE, s_WAIT_H );
--  signal RETICLE_RDFSM    : RETICLE_RDFSM_t;
--  signal RETICLE_DAVi     : std_logic;
--  signal RETICLE_V_D      : std_logic;  
--  signal RETICLE_H_D      : std_logic; 
--  signal RETICLE_EOI_D    : std_logic;
--  signal FIFO_RD1_CNT     : unsigned(PIX_BITS-1 downto 0);
--  signal FIFO_RD1_CNT_D   : unsigned(PIX_BITS-1 downto 0);
--  signal first_time_rd_rq : std_logic;
--  signal RETICLE_EN_D     : std_logic;
----  signal Reticle_cnt1 : unsigned(9 downto 0);
----  signal Reticle_cnt2 : unsigned(9 downto 0);
  
--  signal LATCH_RETICLE_POS_X       : std_logic_vector(PIX_BITS-1 downto 0);
--  signal LATCH_RETICLE_POS_Y       : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_RETICLE_COLOR_INFO1 : std_logic_vector( 7 downto 0);
--  signal LATCH_RETICLE_COLOR_INFO2 : std_logic_vector( 7 downto 0);
  
--  signal line_cnt           : unsigned(LIN_BITS-1 downto 0);
--  signal pix_cnt            : unsigned(PIX_BITS-1 downto 0);
--  signal pix_cnt_d          : unsigned(PIX_BITS-1 downto 0);
--  signal RD_RETICLE_LIN_NO  : unsigned(LIN_BITS-1 downto 0);
--  signal RETICLE_ADD_DONE   : std_logic; 
--  signal RETICLE_POS_Y_TEMP : std_logic_Vector(LIN_BITS-1 downto 0); 
--  signal RETICLE_POS_Y_D    : std_logic_Vector(LIN_BITS-1 downto 0); 
    
--  signal RETICLE_XSIZE_OFFSET_R : std_logic_vector(PIX_BITS-1 downto 0);
--  signal RETICLE_XSIZE_OFFSET_L : std_logic_vector(PIX_BITS-1 downto 0);
--  signal RETICLE_YSIZE_OFFSET   : std_logic_vector(LIN_BITS-1 downto 0);
--  signal RETICLE_PIX_OFFSET     : std_logic_vector(3 downto 0);
--  signal RETICLE_PIX_OFFSET_D   : std_logic_vector(3 downto 0);
--  signal RETICLE_RD_DONE        : std_logic;
--  signal RETICLE_YSIZE_OFFSET_D : std_logic_vector(LIN_BITS-1 downto 0); 
--  signal RETICLE_POS_Y_TEMP_D   : std_logic_vector(LIN_BITS-1 downto 0); 
--  signal out_line_cnt           : unsigned(LIN_BITS-1 downto 0);

--  signal VIDEO_IN_DATA_DD : std_logic_vector(7 downto 0);
--  signal VIDEO_IN_DATA_D  : std_logic_vector(7 downto 0);
--  signal VIDEO_IN_DAV_DD  : std_logic;
--  signal VIDEO_IN_DAV_D   : std_logic;
  
--  signal reticle_rd_addr        : std_logic_vector(14 downto 0);
--  signal reticle_wr_addr        : std_logic_vector(14 downto 0);
--  signal reticle_wr_addr_temp   : unsigned(14 downto 0);
--  signal reticle_rd_addr_temp   : std_logic_vector(14 downto 0);
--  signal reticle_rd_addr_base   : unsigned(19 downto 0);
--  signal reticle_rd_data        : std_logic_vector(31 downto 0);
--  signal reticle_addr           : std_logic_vector(14 downto 0);
  
--  signal reticle_wr_en          : std_logic_vector(0 downto 0);
--  signal reticle_wr_data        : std_logic_vector(31 downto 0);
--  signal RETICLE_TYPE_D         : std_logic_vector(6 downto 0);
--  signal qspi_reticle_change_rq : std_logic;
--  signal qspi_reticle_change_en : std_logic;
  
--  type reticle_transfer_st_t is (s_reticle_IDLE,s_reticle_transfer,s_reticle_req_wait);
--  signal reticle_transfer_st   : reticle_transfer_st_t;
--  signal rd_wr_sel             : std_logic; 
--  signal LATCH_RETICLE_COLOR_SEL : std_logic_vector(1 downto 0);
   
--  signal pix_sum   : unsigned (31 downto 0);
--  signal pix_avg   : unsigned (7 downto 0);

--  signal change_reticle_color : std_logic;

--  signal start_div : std_logic;
--  signal dvsr      : std_logic_vector(31 downto 0);
--  signal dvnd      : std_logic_vector(31 downto 0);
--  signal done_tick : STD_LOGIC;
--  signal quo       : STD_LOGIC_VECTOR(31 downto 0);
--  signal rmd       : STD_LOGIC_VECTOR(31 downto 0);  


--  signal reticle_offset_wr_addr        : std_logic_vector(3 downto 0);
--  signal reticle_offset_wr_addr_temp   : unsigned(4 downto 0);
--  signal reticle_offset_wr_data        : std_logic_vector(31 downto 0);

--  type reticle_offset_transfer_st_t is (s_reticle_offset_IDLE,s_reticle_offset_transfer,s_reticle_offset_transfer_done);
--  signal reticle_offset_transfer_st   : reticle_offset_transfer_st_t;
--  signal reticle_offset_wr_req        : std_logic_vector(0 downto 0); 
  
--  signal reticle_offset_rd_req_init   : std_logic; 
--  signal reticle_offset_rd_req_or     : std_logic; 

--  ATTRIBUTE KEEP : string;
----  ATTRIBUTE KEEP of done_tick             : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of change_reticle_color  : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of VIDEO_IN_H            : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of VIDEO_IN_V            : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of VIDEO_IN_DAV          : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of out_line_cnt          : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of VIDEO_IN_EOI          : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of RETICLE_EOI_D         : SIGNAL IS "TRUE"; 
----  ATTRIBUTE KEEP of VIDEO_IN_DAV_D        : SIGNAL IS "TRUE"; 
----  ATTRIBUTE KEEP of VIDEO_IN_DAV_DD       : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of pix_sum               : SIGNAL IS "TRUE"; 
----  ATTRIBUTE KEEP of RETICLE_EN            : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of start_div             : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of RETICLE_EN_D          : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of RETICLE_REQ_V         : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of RETICLE_REQ_H         : SIGNAL IS "TRUE"; 
----  ATTRIBUTE KEEP of pix_avg               : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of quo                   : SIGNAL IS "TRUE"; 
----  ATTRIBUTE KEEP of dvsr                  : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of RETICLE_POS_Y         : SIGNAL IS "TRUE"; 
----  ATTRIBUTE KEEP of RETICLE_POS_X         : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of pix_cnt_d             : SIGNAL IS "TRUE"; 
  
--ATTRIBUTE KEEP of RETICLE_OFFSET_WR_EN_IN      : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_OFFSET_RD_ADDR       : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_OFFSET_RD_REQ        : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_OFFSET_WR_DATA_IN    : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of reticle_offset_wr_addr       : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of reticle_offset_wr_addr_temp  : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of reticle_offset_wr_data       : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of reticle_offset_wr_req        : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of reticle_offset_transfer_st   : SIGNAL IS "TRUE"; 
--ATTRIBUTE KEEP of RETICLE_OFFSET_RD_DATA_TEMP  : SIGNAL IS "TRUE"; 
  

----  ATTRIBUTE KEEP of  line_cnt: SIGNAL IS "TRUE";
------  ATTRIBUTE KEEP of  in_line_cnt: SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  out_line_cnt: SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  pix_cnt: SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  pix_cnt_d: SIGNAL IS "TRUE";
------  ATTRIBUTE KEEP of  RETICLE_XSIZE_OFFSET_L_D   : SIGNAL IS "TRUE";
------  ATTRIBUTE KEEP of  RETICLE_XSIZE_OFFSET_R_D   : SIGNAL IS "TRUE";
------  ATTRIBUTE KEEP of  LATCH_RETICLE_POS_X_D      : SIGNAL IS "TRUE";
------  ATTRIBUTE KEEP of  LATCH_RETICLE_POS_Y_D      : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_YSIZE_OFFSET_D     : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_POS_Y_TEMP_D       : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_XSIZE_OFFSET_L     : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_XSIZE_OFFSET_R     : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  LATCH_RETICLE_POS_X        : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  LATCH_RETICLE_POS_Y        : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_YSIZE_OFFSET       : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_POS_Y_TEMP         : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RD_RETICLE_LIN_NO          : SIGNAL IS "TRUE";  
----  ATTRIBUTE KEEP of  RETICLE_POS_X              : SIGNAL IS "TRUE";
----  ATTRIBUTE KEEP of  RETICLE_POS_Y              : SIGNAL IS "TRUE";
  
----ATTRIBUTE KEEP of qspi_reticle_change_en    : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of FIFO_RD1_CNT              : SIGNAL IS "TRUE"; 
------ATTRIBUTE KEEP of RETICLE_POS_Y             : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_PIX_OFFSET        : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of qspi_reticle_change_rq    : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_EN                : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_RD_DONE           : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_REQ_V             : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_PIX_OFFSET_D      : SIGNAL IS "TRUE"; 
------ATTRIBUTE KEEP of LATCH_RETICLE_POS_Y       : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_FIELD             : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of first_time_rd_rq          : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_TYPE              : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_TYPE_D            : SIGNAL IS "TRUE"; 
------ATTRIBUTE KEEP of RD_RETICLE_LIN_NO         : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_REQ_H             : SIGNAL IS "TRUE"; 
------ATTRIBUTE KEEP of line_cnt                  : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_DAVi              : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of VIDEO_IN_H                : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of VIDEO_IN_V                : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of VIDEO_IN_DAV              : SIGNAL IS "TRUE"; 
------ATTRIBUTE KEEP of RETICLE_YSIZE_OFFSET      : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of VIDEO_IN_EOI              : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_EOI_D             : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of VIDEO_IN_DAV_D            : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of VIDEO_IN_DAV_DD           : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of reticle_rd_addr_base      : SIGNAL IS "TRUE"; 
------ATTRIBUTE KEEP of out_line_cnt              : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_ADD_DONE          : SIGNAL IS "TRUE"; 
----ATTRIBUTE KEEP of RETICLE_RDFSM             : SIGNAL IS "TRUE"; 
  

----------
--begin


----DMA_RDFSM_check <=  "000" when DMA_RDFSM = s_IDLE else
----                    "001" when DMA_RDFSM = s_WAIT_H else
----                    "010" when DMA_RDFSM = s_GET_ADDR else
----                    "011" when DMA_RDFSM = s_READ else
----                    "111";
  
--RETICLE_OFFSET_RD_DATA <= RETICLE_OFFSET_RD_DATA_TEMP;  
--  process(CLK, RST)
--  begin
--    if RST = '1' then
--      RETICLE_RDFSM             <= s_IDLE;
--      LATCH_RETICLE_COLOR_INFO1 <= x"EB";
--      LATCH_RETICLE_COLOR_INFO2 <= x"10";
--      LATCH_RETICLE_POS_X       <= (others => '0');
--      LATCH_RETICLE_POS_Y       <= (others => '0');
--      line_cnt                  <= (others => '0');
--      RD_RETICLE_LIN_NO         <= (others => '0');
--      RETICLE_POS_Y_TEMP        <= (others => '0');
--      RETICLE_YSIZE_OFFSET      <= (others => '0');
--      RETICLE_XSIZE_OFFSET_R    <= (others =>'0');
--      RETICLE_XSIZE_OFFSET_L    <= (others =>'0');
--      RETICLE_POS_Y_D           <= (others => '0');
--      RETICLE_RD_DONE           <= '0';
--      RETICLE_POS_X_OUT         <= std_logic_vector(to_unsigned(357,RETICLE_POS_X'length));
--      RETICLE_POS_Y_OUT         <= std_logic_vector(to_unsigned(285,RETICLE_POS_Y'length));
--      reticle_rd_addr_base      <= (others => '0');
--      RETICLE_EN_D              <= '0';
--      RETICLE_TYPE_D            <= (others => '0');
--      reticle_sel               <= (others => '0');      
--      qspi_reticle_change_en    <= '0';
--      LATCH_RETICLE_COLOR_SEL   <= std_logic_vector(to_unsigned(0,LATCH_RETICLE_COLOR_SEL'length));
      
----      RETICLE_PIX_OFFSET_L <= (others =>'0');

--    elsif rising_edge(CLK) then

--      qspi_reticle_change_en <= '0';
       
--      case RETICLE_RDFSM is         

--        when s_IDLE =>  
--            line_cnt <= (others => '0');
--            if RETICLE_EN_D ='1' then
--             RETICLE_RDFSM <= s_WAIT_H;
--            end if; 
            
--        when s_WAIT_H =>
--            if RETICLE_REQ_H = '1' then
--              line_cnt <= line_cnt + 1;
--              if (line_cnt >= unsigned(LATCH_RETICLE_POS_Y(LIN_BITS-1 downto 0))) and  (line_cnt < (unsigned(MEM_IMG_YSIZE(LIN_BITS-1 downto  0)) + unsigned(LATCH_RETICLE_POS_Y(LIN_BITS-1 downto 0)) - unsigned(RETICLE_YSIZE_OFFSET))) then
--                RD_RETICLE_LIN_NO    <= RD_RETICLE_LIN_NO + 1;
--                reticle_rd_addr_base <= (unsigned(MEM_IMG_XSIZE(PIX_BITS-1 downto 0)))*RD_RETICLE_LIN_NO +  unsigned("000" &RETICLE_XSIZE_OFFSET_L(PIX_BITS-1 downto 4));
--              end if;  
--              RETICLE_RDFSM <= s_WAIT_H;
--            end if;
--        end case;


--      if RETICLE_REQ_V = '1' then
--        RETICLE_RDFSM <= s_IDLE; 
--        if(RETICLE_FIELD = '0')then                        
--             RETICLE_TYPE_D <= RETICLE_TYPE;
--             if(RETICLE_TYPE_D/= RETICLE_TYPE) then
--                reticle_sel            <= RETICLE_TYPE;
--                RETICLE_EN_D           <= '0';
--                qspi_reticle_change_en <= '1';
                
--             else
--                RETICLE_EN_D           <= RETICLE_EN;
--             end if;                                               
--             LATCH_RETICLE_COLOR_SEL   <= RETICLE_COLOR_SEL;
--             LATCH_RETICLE_COLOR_INFO1 <= RETICLE_COLOR_INFO1;
--             LATCH_RETICLE_COLOR_INFO2 <= RETICLE_COLOR_INFO2;
--             RETICLE_POS_Y_D           <= RETICLE_POS_Y;
             
--            if(unsigned(RETICLE_POS_X) < (unsigned(VIDEO_IN_XSIZE) - unsigned(RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1))))then
--              if(unsigned(RETICLE_POS_X) <  unsigned(RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1))) then
--                LATCH_RETICLE_POS_X    <= std_logic_vector(to_unsigned(0,LATCH_RETICLE_POS_X'length));
--                RETICLE_XSIZE_OFFSET_L <= std_logic_vector((unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1)) - unsigned(RETICLE_POS_X))- to_unsigned(1,RETICLE_XSIZE_OFFSET_L'length));
--              else
--                LATCH_RETICLE_POS_X    <= std_logic_vector((unsigned(RETICLE_POS_X) - unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1))) + to_unsigned(1,LATCH_RETICLE_POS_X'length));
--                RETICLE_XSIZE_OFFSET_L <= (others=>'0');
--              end if;   
--              RETICLE_XSIZE_OFFSET_R <= (others=>'0');
--              RETICLE_POS_X_OUT      <= RETICLE_POS_X;
--            else 
--               if(unsigned(RETICLE_POS_X) < unsigned(VIDEO_IN_XSIZE)) then
--                LATCH_RETICLE_POS_X    <= std_logic_vector((unsigned(RETICLE_POS_X) - unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1))) + to_unsigned(1,LATCH_RETICLE_POS_X'length));
--                RETICLE_XSIZE_OFFSET_R <= std_logic_vector((unsigned(RETICLE_POS_X) + unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1)) + to_unsigned(1,RETICLE_XSIZE_OFFSET_R'length)) -unsigned(VIDEO_IN_XSIZE));
--                RETICLE_POS_X_OUT      <= RETICLE_POS_X;
--               else
--                LATCH_RETICLE_POS_X    <= std_logic_vector(unsigned(VIDEO_IN_XSIZE) - unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1)));-- - to_unsigned(1,LATCH_RETICLE_POS_X'length));
--                RETICLE_XSIZE_OFFSET_R <= std_logic_vector(unsigned('0' & RETICLE_REQ_XSIZE(PIX_BITS-1 downto 1)));
--                RETICLE_POS_X_OUT      <= std_logic_vector(unsigned(VIDEO_IN_XSIZE) - to_unsigned(1,RETICLE_POS_X_OUT'length));
--               end if; 
--               RETICLE_XSIZE_OFFSET_L  <= (others=>'0'); 
--            end if;


--            if(unsigned(RETICLE_POS_Y)< (unsigned(VIDEO_IN_YSIZE) - unsigned(RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1))))then  
--                if(unsigned(RETICLE_POS_Y)<unsigned(RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)))then
--                     RETICLE_YSIZE_OFFSET  <= std_logic_vector(unsigned('0'&RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)) - unsigned(RETICLE_POS_Y(LIN_BITS-1 downto 0))- to_unsigned(1,RETICLE_YSIZE_OFFSET'length));
--                     RD_RETICLE_LIN_NO     <= (unsigned('0' &RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)) - to_unsigned(1,RD_RETICLE_LIN_NO'length)) - unsigned( RETICLE_POS_Y) ;  
--                     RETICLE_POS_Y_TEMP    <= std_logic_vector(to_unsigned(0,LATCH_RETICLE_POS_Y'length));
--                     LATCH_RETICLE_POS_Y   <= std_logic_vector(to_unsigned(0,LATCH_RETICLE_POS_Y'length));                     
--                else    
--                    LATCH_RETICLE_POS_Y <= std_logic_vector(unsigned(RETICLE_POS_Y) - unsigned('0' &RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1))+ to_unsigned(1,LATCH_RETICLE_POS_Y'length));
--                    RD_RETICLE_LIN_NO   <= to_unsigned(0,RD_RETICLE_LIN_NO'length);
--                    RETICLE_YSIZE_OFFSET <= (others=>'0');
--                    RETICLE_POS_Y_TEMP   <= std_logic_vector(unsigned(RETICLE_POS_Y) - unsigned('0' &RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)) + to_unsigned(1,LATCH_RETICLE_POS_Y'length));
--                end if;  
--                RETICLE_POS_Y_OUT        <= RETICLE_POS_Y;  
                
--            else
--                if(RETICLE_POS_Y < VIDEO_IN_YSIZE)then
--                    LATCH_RETICLE_POS_Y  <= std_logic_vector(unsigned(RETICLE_POS_Y) - unsigned('0' & RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1))+ to_unsigned(1,LATCH_RETICLE_POS_Y'length));
--                    RD_RETICLE_LIN_NO    <= to_unsigned(0,RD_RETICLE_LIN_NO'length);
--                    RETICLE_YSIZE_OFFSET <= std_logic_vector(unsigned(RETICLE_POS_Y(LIN_BITS-1 downto 0)) -  (unsigned(VIDEO_IN_YSIZE(LIN_BITS-1 downto 0)) - unsigned('0'& RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1))) + to_unsigned(1,LATCH_RETICLE_POS_Y'length));    -- NEW ADD                  
--                    RETICLE_POS_Y_OUT   <= RETICLE_POS_Y;  
--                else
--                    LATCH_RETICLE_POS_Y  <= std_logic_vector(unsigned(VIDEO_IN_YSIZE) - unsigned('0'&RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)));
--                    RD_RETICLE_LIN_NO    <= to_unsigned(0,RD_RETICLE_LIN_NO'length);
--                    RETICLE_YSIZE_OFFSET <= std_logic_vector(unsigned('0' & RETICLE_REQ_YSIZE(LIN_BITS-1 downto 1)));-- - to_unsigned(1,RETICLE_YSIZE_OFFSET'length));
--                    RETICLE_POS_Y_OUT    <= std_logic_vector(unsigned(VIDEO_IN_YSIZE) - to_unsigned(1,RETICLE_POS_Y_OUT'length));  
--                end if;    

--            end if;  
          
--       else
--           RETICLE_EN_D              <= RETICLE_EN_D;
--           LATCH_RETICLE_COLOR_SEL   <= LATCH_RETICLE_COLOR_SEL;
--           LATCH_RETICLE_COLOR_INFO1 <= LATCH_RETICLE_COLOR_INFO1;
--           LATCH_RETICLE_COLOR_INFO2 <= LATCH_RETICLE_COLOR_INFO2;
--           LATCH_RETICLE_POS_X       <= LATCH_RETICLE_POS_X;  
--           RETICLE_XSIZE_OFFSET_R    <= RETICLE_XSIZE_OFFSET_R;
--           RETICLE_XSIZE_OFFSET_L    <= RETICLE_XSIZE_OFFSET_L;    
----           LATCH_RETICLE_POS_Y       <= RETICLE_POS_Y_TEMP; 
--       end if;    
--     end if;

--   end if;
-- end process;



-- process(CLK, RST)
--   begin
--     if RST = '1' then
--        reticle_wr_addr        <= (others=>'0');
--        reticle_wr_addr_temp   <= (others=>'0');
--        reticle_wr_data        <= (others=>'0');
--        reticle_wr_en          <= "0";
--        rd_wr_sel              <= '0';
--        qspi_reticle_change_rq <= '0';
--        qspi_reticle_transfer_rq <= '0';
--        reticle_transfer_st    <= s_reticle_idle;
--        reticle_offset_transfer_st    <= s_reticle_offset_idle;
--        reticle_offset_wr_addr        <= (others=>'0');
--        reticle_offset_wr_addr_temp   <= (others=>'0');
--        reticle_offset_wr_data        <= (others=>'0');
--        reticle_offset_wr_req         <= "0";   
--        reticle_offset_rd_req_init    <= '0';    
--     elsif rising_edge(CLK) then

--        if(qspi_reticle_change_en = '1')then
--            qspi_reticle_change_rq <= '1';  
--        end if; 

--        case reticle_transfer_st is
        
--            when s_reticle_idle =>
--                reticle_transfer_st  <= s_reticle_transfer;
--                reticle_wr_en        <= "0";
--                reticle_wr_addr_temp <= (others=>'0');
--                rd_wr_sel            <= '0';
                
--            when s_reticle_transfer =>
--                    if(qspi_reticle_transfer_rq_ack = '1')then
--                        qspi_reticle_transfer_rq <= '0';
--                    end if;
--                    rd_wr_sel <= '0';
----                    if(reticle_wr_addr_temp = 1200)then
--                    if(reticle_wr_addr_temp =to_unsigned(RETICLE_INIT_MEMORY_WR_SIZE,reticle_wr_addr_temp'length))then
--                        reticle_wr_en        <= "0";
--                        reticle_wr_addr_temp <= (others=>'0');
--                        reticle_transfer_st  <= s_reticle_req_wait;
--                    else
--                        reticle_transfer_st  <= s_reticle_transfer;
--                        if(RETICLE_WR_EN_IN = "1")then
--                            reticle_wr_data      <= RETICLE_WR_DATA_IN;
--                            reticle_wr_en        <= "1";
--                            reticle_wr_addr      <= std_logic_Vector(reticle_wr_addr_temp);
--                            reticle_wr_addr_temp <= reticle_wr_addr_temp +1; 
--                        else
--                            reticle_wr_en        <= "0";
--                        end if;    
--                    end if;

--             when s_reticle_req_wait =>
--                    rd_wr_sel            <= '1';
--                    reticle_wr_en        <= "0";
--                    reticle_wr_addr_temp <= (others=>'0');              
--                    if(qspi_reticle_change_rq='1' and qspi_reticle_transfer_done='1')then
--                        reticle_transfer_st      <= s_reticle_transfer;
--                        qspi_reticle_transfer_rq <= '1';
--                        qspi_reticle_change_rq   <= '0';
--                    else
--                        reticle_transfer_st  <= s_reticle_req_wait;
--                    end if; 
--        end case;     

--        case reticle_offset_transfer_st is
        
--            when s_reticle_offset_idle =>
--                reticle_offset_transfer_st  <= s_reticle_offset_transfer;
--                reticle_offset_wr_req       <="0";
--                reticle_offset_wr_addr_temp <= (others=>'0');
--                reticle_offset_rd_req_init  <= '0';
                
--            when s_reticle_offset_transfer =>
--                    if(reticle_offset_wr_addr_temp =to_unsigned(16,reticle_offset_wr_addr_temp'length))then
--                        reticle_offset_wr_req       <= "0";
----                        reticle_offset_wr_addr_temp <= (others=>'0');
--                        reticle_offset_transfer_st  <= s_reticle_offset_transfer_done;
--                        reticle_offset_rd_req_init  <= '1';
--                    else
--                        reticle_offset_transfer_st  <= s_reticle_offset_transfer;
--                        if(RETICLE_OFFSET_WR_EN_IN = "1")then
--                            reticle_offset_wr_data      <= RETICLE_OFFSET_WR_DATA_IN;
--                            reticle_offset_wr_req       <= "1";
--                            reticle_offset_wr_addr      <= std_logic_Vector(reticle_offset_wr_addr_temp(3 downto 0));
--                            reticle_offset_wr_addr_temp <= reticle_offset_wr_addr_temp +1; 
--                        else
--                            reticle_offset_wr_req         <= "0";
--                        end if;    
--                    end if;

--             when s_reticle_offset_transfer_done =>
--                    reticle_offset_wr_req       <= "0";
--                    reticle_offset_wr_addr_temp <= (others=>'0');              
--                    reticle_offset_transfer_st  <= s_reticle_offset_transfer_done;
--                    reticle_offset_rd_req_init  <= '0';
                                
--            end case;   

--     end if;
-- end process;

--reticle_addr <=  reticle_wr_addr when  rd_wr_sel = '0' else reticle_rd_addr;
 
--i_bpr_reticle : bpr_reticle
--  PORT MAP (
--    clka  => CLK,
--    wea   => reticle_wr_en,
--    addra => reticle_addr,
--    dina  => reticle_wr_data,
--    douta => reticle_rd_data
--  );
 
-- reticle_offset_rd_req_or <= reticle_offset_rd_req_init or RETICLE_OFFSET_RD_REQ;

--  reticle_offset_data : xpm_memory_sdpram
--   generic map (
--      ADDR_WIDTH_A => 4,               -- DECIMAL
--      ADDR_WIDTH_B => 4,               -- DECIMAL
--      AUTO_SLEEP_TIME => 0,            -- DECIMAL
--      BYTE_WRITE_WIDTH_A => 32,        -- DECIMAL
--      CASCADE_HEIGHT => 0,             -- DECIMAL
--      CLOCKING_MODE => "common_clock", -- String
--      ECC_MODE => "no_ecc",            -- String
--      MEMORY_INIT_FILE => "none",      -- String
--      MEMORY_INIT_PARAM => "0",        -- String
--      MEMORY_OPTIMIZATION => "true",   -- String
--      MEMORY_PRIMITIVE => "auto",      -- String
--      MEMORY_SIZE => 512,             -- DECIMAL
--      MESSAGE_CONTROL => 0,            -- DECIMAL
--      READ_DATA_WIDTH_B => 32,         -- DECIMAL
--      READ_LATENCY_B => 1,             -- DECIMAL
--      READ_RESET_VALUE_B => "0",       -- String
--      RST_MODE_A => "SYNC",            -- String
--      RST_MODE_B => "SYNC",            -- String
--      SIM_ASSERT_CHK => 0,             -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
--      USE_EMBEDDED_CONSTRAINT => 0,    -- DECIMAL
--      USE_MEM_INIT => 1,               -- DECIMAL
--      WAKEUP_TIME => "disable_sleep",  -- String
--      WRITE_DATA_WIDTH_A => 32,        -- DECIMAL
--      WRITE_MODE_B => "no_change"      -- String
--   )
--   port map (
--      dbiterrb => open,             -- 1-bit output: Status signal to indicate double bit error occurrence
--                                        -- on the data output of port B.

--      doutb    => RETICLE_OFFSET_RD_DATA_TEMP,                   -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
--      sbiterrb => open,             -- 1-bit output: Status signal to indicate single bit error occurrence
--                                        -- on the data output of port B.

--      addra => reticle_offset_wr_addr,                   -- ADDR_WIDTH_A-bit input: Address for port A write operations.
--      addrb => RETICLE_OFFSET_RD_ADDR,                   -- ADDR_WIDTH_B-bit input: Address for port B read operations.
--      clka  => CLK,                     -- 1-bit input: Clock signal for port A. Also clocks port B when
--                                        -- parameter CLOCKING_MODE is "common_clock".

--      clkb  => CLK,                     -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
--                                        -- "independent_clock". Unused when parameter CLOCKING_MODE is
--                                        -- "common_clock".

--      dina => reticle_offset_wr_data,                     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
--      ena  => reticle_offset_wr_req(0),                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
--                                        -- cycles when write operations are initiated. Pipelined internally.

--      enb  => reticle_offset_rd_req_or,--RETICLE_OFFSET_RD_REQ,                       -- 1-bit input: Memory enable signal for port B. Must be high on clock
--                                        -- cycles when read operations are initiated. Pipelined internally.

--      injectdbiterra => '0', -- 1-bit input: Controls double bit error injection on input data when
--                                        -- ECC enabled (Error injection capability is not available in
--                                        -- "decode_only" mode).

--      injectsbiterra => '0', -- 1-bit input: Controls single bit error injection on input data when
--                                        -- ECC enabled (Error injection capability is not available in
--                                        -- "decode_only" mode).

--      regceb => '0',                 -- 1-bit input: Clock Enable for the last register stage on the output
--                                        -- data path.

--      rstb => RST,                     -- 1-bit input: Reset signal for the final port B output register
--                                        -- stage. Synchronously resets output port doutb to the value specified
--                                        -- by parameter READ_RESET_VALUE_B.

--      sleep => '0',                   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
--      wea   => reticle_offset_wr_req                       -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
--                                        -- for port A input data port dina. 1 bit wide when word-wide writes
--                                        -- are used. In byte-wide write configurations, each bit controls the
--                                        -- writing one byte of dina to address addra. For example, to
--                                        -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
--                                        -- is 32, wea would be 4'b0010.

--   ); 

 
      
-- process(CLK, RST)
--   begin
--     if RST = '1' then
--       RETICLE_V            <= '0';
--       RETICLE_V_D          <= '0';
--       RETICLE_DAVi         <= '0';
--       RETICLE_DATA         <= (others => '0');
--       RETICLE_H            <= '0';
--       RETICLE_H_D          <= '0';
--       RETICLE_EOI          <= '0';
--       RETICLE_EOI_D        <= '0';
--       first_time_rd_rq     <= '1'; 
--       FIFO_RD1_CNT         <= (others => '0'); 
--       FIFO_RD1_CNT_D       <= (others => '0'); 
--       pix_cnt              <= (others => '0');
--       pix_cnt_d            <= (others => '0');
--       RETICLE_ADD_DONE     <= '0';
--       RETICLE_PIX_OFFSET   <= (others => '0');
--       RETICLE_PIX_OFFSET_D <= (others => '0');
--       out_line_cnt         <= (others => '0');
--       VIDEO_IN_DATA_DD     <= (others => '0');
--       VIDEO_IN_DATA_D      <= (others => '0');
--       VIDEO_IN_DAV_DD      <= '0';
--       VIDEO_IN_DAV_D       <= '0';
--       reticle_rd_addr      <= (others => '0');
--       reticle_rd_addr_temp <= (others => '0');
--       pix_sum              <= (others => '0');
--       pix_avg              <= (others => '0');
--       start_div            <= '0';
--       dvsr                 <= (others => '0');
--       dvnd                 <= (others => '0');
--       change_reticle_color <= '0';

--     elsif rising_edge(CLK) then
     
--     start_div       <= '0';
     
--     if(done_tick='1')then
--      pix_avg <= unsigned(quo(7 downto 0));
--     end if;
     
     
--     if RETICLE_EN_D ='1' then
--           RETICLE_V      <= RETICLE_V_D;
--           RETICLE_H      <= RETICLE_H_D;
--           RETICLE_V_D    <= '0'; 
--           RETICLE_H_D    <= '0';
--           RETICLE_EOI_D  <= VIDEO_IN_EOI;
--           RETICLE_EOI    <= RETICLE_EOI_D;
--           RETICLE_DAVi   <= '0';
--           FIFO_RD1_CNT_D <= FIFO_RD1_CNT;
--           pix_cnt_d      <= pix_cnt;
--           RETICLE_PIX_OFFSET_D <= RETICLE_PIX_OFFSET;
--           VIDEO_IN_DAV_D <= VIDEO_IN_DAV;
--           VIDEO_IN_DAV_DD <= VIDEO_IN_DAV_D;
           
--           VIDEO_IN_DATA_D <= VIDEO_IN_DATA;
--           VIDEO_IN_DATA_DD <= VIDEO_IN_DATA_D;
           

           
--           if VIDEO_IN_V = '1' then
--             RETICLE_V_D     <= '1'; 
--             out_line_cnt    <= (others => '0');
--             start_div       <= '1';
--             dvnd            <= std_logic_vector(pix_sum);
--             dvsr            <= std_logic_vector(resize(unsigned(COLOR_SEL_WINDOW_XSIZE) * unsigned(COLOR_SEL_WINDOW_YSIZE),dvnd'length));
--             pix_sum         <= (others => '0');  
--             if(pix_avg <= unsigned(RETICLE_COLOR_TH(7 downto 0)))then
--              change_reticle_color <= '0'; 
--             elsif(pix_avg >= unsigned(RETICLE_COLOR_TH(15 downto 8)))then
--              change_reticle_color <= '1'; 
--             else
--              change_reticle_color <= change_reticle_color; 
--             end if;                  
--           end if;
     
--           if VIDEO_IN_H = '1' then
--             RETICLE_H_D <= '1';  
--             first_time_rd_rq <= '1'; 
--             FIFO_RD1_CNT <=(others => '0');   
--             pix_cnt   <= (others => '0');
--             RETICLE_ADD_DONE <= '0';
--             out_line_cnt     <= out_line_cnt   +1;
--             reticle_rd_addr_temp  <= std_logic_vector(reticle_rd_addr_base(14 downto 0));
                        
--             RETICLE_PIX_OFFSET <= RETICLE_XSIZE_OFFSET_L(3 downto 0);
             
--           end if;
          
          
 
--          if ((out_line_cnt-1) >= unsigned(LATCH_RETICLE_POS_Y(LIN_BITS-1 downto 0))) and  ((out_line_cnt-1) < (unsigned(RETICLE_REQ_YSIZE(LIN_BITS-1 downto  0)) + unsigned(LATCH_RETICLE_POS_Y(LIN_BITS-1 downto 0)) - unsigned(RETICLE_YSIZE_OFFSET))) then                         
--           if(VIDEO_IN_DAV = '1')then

--                pix_cnt      <= pix_cnt + 1;

--                if((pix_cnt>= unsigned(LATCH_RETICLE_POS_X)) and (pix_cnt < (((unsigned(RETICLE_REQ_XSIZE)-to_unsigned(15,pix_cnt'length)) + unsigned(LATCH_RETICLE_POS_X))- unsigned(RETICLE_XSIZE_OFFSET_L))))then
--                    if FIFO_RD1_CNT = (to_unsigned(15,FIFO_RD1_CNT'length) - unsigned(RETICLE_PIX_OFFSET)) or first_time_rd_rq = '1'  then
--                             reticle_rd_addr <= reticle_rd_addr_temp;
--                             reticle_rd_addr_temp <= std_logic_vector(unsigned(reticle_rd_addr_temp) + 1);
--                             FIFO_RD1_CNT <= (others => '0');
--                             first_time_rd_rq <= '0';   

--                             if((FIFO_RD1_CNT = (to_unsigned(15,FIFO_RD1_CNT'length) - unsigned(RETICLE_PIX_OFFSET)))and first_time_rd_rq = '0')then
                         
--                                 RETICLE_PIX_OFFSET <= (others=>'0');
--                             else 
--                                 RETICLE_PIX_OFFSET <=  RETICLE_PIX_OFFSET;
--                             end if; 

--                    else  
--                     FIFO_RD1_CNT  <= FIFO_RD1_CNT + 1;    
   
--                    end if;  
--                    if(pix_cnt = ((((unsigned(RETICLE_REQ_XSIZE))-to_unsigned(16,pix_cnt'length)) + unsigned(LATCH_RETICLE_POS_X))- unsigned(RETICLE_XSIZE_OFFSET_L))) then
--                     RETICLE_ADD_DONE <= '1';
--                    end if;                 
--                else
--                    if(RETICLE_ADD_DONE = '1')then
--                         if FIFO_RD1_CNT = to_unsigned(15,FIFO_RD1_CNT'length) then
--                             FIFO_RD1_CNT  <= to_unsigned(15,FIFO_RD1_CNT'length);
--                         else
--                             FIFO_RD1_CNT  <= FIFO_RD1_CNT+ 1;
--                         end if;    
                         
--                    end if;        
                
--                end if;
--           end if;
           
          
--           if VIDEO_IN_DAV_DD = '1'then
--                if(((pix_cnt_d-1)>= (unsigned(LATCH_RETICLE_POS_X))) and ((pix_cnt_d-1) < ((unsigned(RETICLE_REQ_XSIZE) + unsigned(LATCH_RETICLE_POS_X)) - (unsigned(RETICLE_XSIZE_OFFSET_R) +unsigned(RETICLE_XSIZE_OFFSET_L)))))then
--                     RETICLE_DAVi <= '1';  
 
--                     if(reticle_rd_data((2*(to_integer(FIFO_RD1_CNT_D)+to_integer(unsigned(RETICLE_PIX_OFFSET_D)))) + 1)='1')then
                          
--                          if(reticle_rd_data((2*(to_integer(FIFO_RD1_CNT_D) + to_integer(unsigned(RETICLE_PIX_OFFSET_D))))) = '1')then
--                             if(unsigned(LATCH_RETICLE_COLOR_SEL) >= 2)then
--                                 if(change_reticle_color = '1')then   
--                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2(7 downto 0);
--                                 else   
--                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1(7 downto 0);
--                                 end if;  
--                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 1)then
--                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2(7 downto 0);
--                             else
--                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1(7 downto 0);
--                             end if;
                                  
-- --                            Reticle_cnt1 <= Reticle_cnt1 + 1;
--                          else
--                             if(unsigned(LATCH_RETICLE_COLOR_SEL) >= 2)then
--                                 if(change_reticle_color = '1')then
--                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1(7 downto 0);
--                                 else   
--                                    RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2(7 downto 0);
--                                 end if; 
--                             elsif(unsigned(LATCH_RETICLE_COLOR_SEL) = 1)then
--                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO1(7 downto 0);
--                             else
--                                RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2(7 downto 0);
--                             end if;   
----                             RETICLE_DATA <= LATCH_RETICLE_COLOR_INFO2(7 downto 0);
-- --                            Reticle_cnt2 <= Reticle_cnt2 + 1;
--                          end if;   
--                     else 
--                         RETICLE_DATA <= VIDEO_IN_DATA_DD;
--                     end if;

----                     if(unsigned(RETICLE_POS_Y) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1)))then
----                        if (unsigned(RETICLE_POS_X) < to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))then
----                          if (((pix_cnt_d-1) >= to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) >= to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)) and ((out_line_cnt-1) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
----                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum; 
----                          end if;
----                        else
----                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))) and (((out_line_cnt-1) >= to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)) and ((out_line_cnt-1) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
----                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum;
----                          end if;
----                        end if;
----                     else
----                        if (unsigned(RETICLE_POS_X) < to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))then
----                          if (((pix_cnt_d-1) >= to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
----                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum;
----                          end if;
----                        else
----                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" &COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" &COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
----                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum; 
----                          end if;
----                        end if;                     
----                     end if;      
--                     if(unsigned(RETICLE_POS_Y) >= unsigned(VIDEO_IN_YSIZE) - (to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))then
--                        if (unsigned(RETICLE_POS_X) >= unsigned(VIDEO_IN_XSIZE) -(to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))))then
--                          if (((pix_cnt_d-1) >= unsigned(VIDEO_IN_XSIZE) -(to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and ((pix_cnt_d-1) < unsigned(VIDEO_IN_XSIZE) - to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length))) and (((out_line_cnt-1) >= unsigned(VIDEO_IN_YSIZE) - (to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE))) and ((out_line_cnt-1) < unsigned(VIDEO_IN_YSIZE) - to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum; 
--                          end if;
--                        elsif (unsigned(RETICLE_POS_X) < to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))then
--                          if (((pix_cnt_d-1) >= to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) >= unsigned(VIDEO_IN_YSIZE) - (to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE))) and ((out_line_cnt-1) < unsigned(VIDEO_IN_YSIZE) - to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum; 
--                          end if;
--                        else
--                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))) and (((out_line_cnt-1) >= unsigned(VIDEO_IN_YSIZE) - (to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE))) and ((out_line_cnt-1) < unsigned(VIDEO_IN_YSIZE) - to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum;
--                          end if;
--                        end if;
--                     elsif(unsigned(RETICLE_POS_Y) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1)))then
--                        if (unsigned(RETICLE_POS_X) >= unsigned(VIDEO_IN_XSIZE) -(to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))))then
--                          if (((pix_cnt_d-1) >= unsigned(VIDEO_IN_XSIZE) -(to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned(COLOR_SEL_WINDOW_XSIZE)) and ((pix_cnt_d-1) < unsigned(VIDEO_IN_XSIZE) - to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length))) and (((out_line_cnt-1) >= to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)) and ((out_line_cnt-1) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum; 
--                          end if;
--                        elsif (unsigned(RETICLE_POS_X) < to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))then
--                          if (((pix_cnt_d-1) >= to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) >= to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)) and ((out_line_cnt-1) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum; 
--                          end if;
--                        else
--                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))) and (((out_line_cnt-1) >= to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length)) and ((out_line_cnt-1) < to_unsigned(VIDEO_Y_OFFSET,RETICLE_POS_Y'length) + unsigned(COLOR_SEL_WINDOW_YSIZE)))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum;
--                          end if;
--                        end if;
--                     else
--                        if (unsigned(RETICLE_POS_X) >= unsigned(VIDEO_IN_XSIZE) -(to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))))then
--                          if (((pix_cnt_d-1) >= unsigned(VIDEO_IN_XSIZE) -(to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned(COLOR_SEL_WINDOW_XSIZE)) and ((pix_cnt_d-1) < unsigned(VIDEO_IN_XSIZE) - to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum; 
--                          end if;                     
--                        elsif (unsigned(RETICLE_POS_X) < to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))then
--                          if (((pix_cnt_d-1) >= to_unsigned(VIDEO_X_OFFSET,RETICLE_POS_X'length) and ((pix_cnt_d-1) < unsigned(RETICLE_POS_X) + unsigned(COLOR_SEL_WINDOW_XSIZE))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" & COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum;
--                          end if;
--                        else
--                          if ((((pix_cnt_d-1) > unsigned(RETICLE_POS_X) - unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1))) and ((pix_cnt_d-1) <= unsigned(RETICLE_POS_X) + unsigned("0" & COLOR_SEL_WINDOW_XSIZE(PIX_BITS-1 downto 1)))) and (((out_line_cnt-1) > unsigned(RETICLE_POS_Y)- unsigned("0" &COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))) and ((out_line_cnt-1) <= unsigned(RETICLE_POS_Y) + unsigned("0" &COLOR_SEL_WINDOW_YSIZE(LIN_BITS-1 downto 1))))) then
--                            pix_sum <= unsigned(VIDEO_IN_DATA_DD(7 downto 0)) + pix_sum; 
--                          end if;
--                        end if;                     
--                     end if;      

--               else
--                     RETICLE_DAVi <= '1';         
--                     RETICLE_DATA <= VIDEO_IN_DATA_DD;
--               end if; 
--           end if; 
             
--          else
--             if(VIDEO_IN_DAV_DD = '1')then
--                   RETICLE_DAVi <= '1';    
--                   RETICLE_DATA <=VIDEO_IN_DATA_DD;
--             end if;       
              
--          end if;
     
--     else
--         RETICLE_V    <=  VIDEO_IN_V; 
--         RETICLE_H    <=  VIDEO_IN_H ;
--         RETICLE_DAVi <=  VIDEO_IN_DAV;
--         RETICLE_DATA <=  VIDEO_IN_DATA;
--         RETICLE_EOI  <=  VIDEO_IN_EOI;
         
--         RETICLE_H_D <= '0';  
--         RETICLE_V_D <= '0';
--         RETICLE_EOI_D    <= '0';

--         first_time_rd_rq <= '1'; 
--         FIFO_RD1_CNT   <= (others=>'0');
--         FIFO_RD1_CNT_D <= (others=>'0');
 
--     end if;  
       
--    end if;
     
--   end process;

--  RETICLE_DAV   <= RETICLE_DAVi;


--  i_div : entity WORK.div
-- generic map(
--  W    => 32,
--  CBIT => 6
--  )
-- port map(

--  clk   => CLK,
--  reset => RST,
--  start => start_div ,
--  dvsr  => dvsr, 
--  dvnd  => dvnd,
--  done_tick => done_tick,
--  quo => quo, 
--  rmd => rmd
--  ); 



----probe0(0)<= RETICLE_DAVi;
----probe0(1)<= '0';
----probe0(2)<= VIDEO_IN_H;
----probe0(3)<= VIDEO_IN_V;
----probe0(4)<= VIDEO_IN_DAV;
----probe0(14 downto 5)<=RETICLE_YSIZE_OFFSET;--(others=> '0');--FIFO_NB1(9 downto 0);
------probe0(16 downto 11)<= std_logic_vector(DMA_ADDR_PIX_check);
----probe0(15)<= VIDEO_IN_EOI;
----probe0(16)<= RETICLE_EOI_D;
----probe0(17)<= VIDEO_IN_DAV_D;--FIFO_RD1;
----probe0(18)<= VIDEO_IN_DAV_DD;--FIFO_WR1;
------probe0(20 downto 19)<=  (others=> '0');
------probe0(20 downto 13)<= VIDEO_IN_DATA_D;
------probe0(30 downto 21 ) <= std_logic_vector(RETICLE_YCNTi);
----probe0(34 downto 19)<= std_logic_Vector(reticle_rd_addr_base(15 downto 0));--(others=> '0');   --std_logic_vector(to_unsigned(count,10));--FIFO_OUT;
----probe0(44 downto 35)<= std_logic_vector(out_line_cnt);
----probe0(50 downto 45)<=  std_logic_vector(FIFO_RD1_CNT(5 downto 0));
------probe0(50 downto 46)<= (others=> '0'); --FIFO_NB(5 downto 0);
------probe0(55 downto 53)<= SCALER_SEL;
----probe0(51)<= RETICLE_EN;
----probe0(52)<= '0';
----probe0(53)<= RETICLE_EN_D;
----probe0(54)<= qspi_reticle_change_en;
----probe0(55)<= '0';--FIFO_WR;
----probe0(65 downto 56)<= RETICLE_POS_Y;--(others=> '0');--LATCH_RETICLE_POS_X_D;
------probe0(77 downto 68)<=LATCH_RETICLE_POS_Y;
----probe0(69 downto 66)<=RETICLE_PIX_OFFSET;
----probe0(70)<= qspi_reticle_change_rq;
----probe0(71)<= RETICLE_EN;
----probe0(72)<= RETICLE_RD_DONE;
----probe0(73)<= RETICLE_REQ_V;--FIFO_CLR;
----probe0(77 downto 74)<= RETICLE_PIX_OFFSET_D;
----probe0(87 downto 78)<=LATCH_RETICLE_POS_Y;--RETICLE_POS_X;
----probe0(88)<= RETICLE_FIELD;
----probe0(89)<=first_time_rd_rq;
------probe0(89 downto 58)<= std_logic_vector(to_unsigned(FIFO_RD1_CNT,32));--FIFO_IN;
------probe0(90) <= '0';--DMA_RDREADY;
------probe0(91) <= '0';--DMA_RDDAV; 
----probe0(91 downto 90) <=std_logic_vector(to_unsigned(RETICLE_RDFSM_t'POS(RETICLE_RDFSM), 2));--std_logic_vector(to_unsigned(DMA_RDFSM_t'POS(DMA_RDFSM), 2)); --DMA_RDFSM_check; 
------probe0(104 downto 95)<= LATCH_RETICLE_POS_Y;--(others=> '0');--std_logic_vector(RETICLE_XSIZE_OFFSET_L_D);
------probe0(114 downto 105)<= std_logic_Vector(pix_cnt);
----probe0(98 downto 92)<= RETICLE_TYPE;
----probe0(105 downto 99)<= RETICLE_TYPE_D;
----probe0(115 downto 106)<= std_logic_vector(RD_RETICLE_LIN_NO);--(others=> '0');--RETICLE_DATA;
------probe0(114 downto 105)<= std_logic_Vector(Reticle_cnt1);--std_logic_Vector(RETICLE_YCNTi);
------probe0(115)<= RETICLE_REQ_V;

----probe0(116)<= RETICLE_REQ_H;
----probe0(126 downto 117)<=std_logic_Vector(line_cnt);
------probe0(126 downto 117)<=std_logic_Vector(Reticle_cnt2);
------probe0(122 downto 117)<= FIFO_NB;--RETICLE_LIN_NO;
------probe0(123)<= RETICLE_EN;
------probe0(126 downto 124 )<= (others=> '0');
----probe0(127)<= RETICLE_ADD_DONE;--FIFO_CLR;



------probe0(127)<= '0';
------probe0(159 downto 128)<= reticle_rd_data;
------probe0(165 downto 160)<= std_logic_Vector(FIFO_RD1_CNT_D(5 downto 0));
------probe0(166)<= FIFO_RD1_D;
--------probe0(190 downto 167)<=FIFO_OUT1;
--------probe0(176 downto 167)<= RETICLE_XSIZE_OFFSET_L;
--------probe0(186 downto 177)<= RETICLE_XSIZE_OFFSET_R;
--------probe0(190 downto 187)<= MEM_IMG_XSIZE(3 downto 0);--(others=>'0');

------probe0(190 downto 167)<= VIDEO_IN_DATA_DD;
------probe0(200 downto 191)<=std_logic_Vector(pix_cnt_d);
--------probe0(255 downto 201)<= (others=>'0');
------probe0(210 downto 201)<= std_logic_vector(RD_RETICLE_LIN_NO);
------probe0(220 downto 211)<= LATCH_RETICLE_POS_X;--LATCH_RETICLE_POS_Y_D;
--------probe0(221)<= DMA_RDREQ_D;
------probe0(221)<= RETICLE_EN;
------probe0(232 downto 222)<= std_logic_Vector(reticle_rd_addr);
--------probe0(220 downto 211)<= std_logic_Vector(Reticle_cnt2);--RETICLE_YSIZE_OFFSET;
--------probe0(230 downto 221)<= std_logic_Vector(Reticle_cnt1);--VIDEO_IN_YSIZE;
------probe0(243 downto 233)<=reticle_rd_addr_temp;--;MEM_IMG_XSIZE;--(others=> '0');--std_logic_vector(RETICLE_XSIZE_OFFSET_R_D);
--------probe0(241)<=RETICLE_RD_DONE;
------probe0(253 downto 244)<= RETICLE_POS_Y_D;--VIDEO_IN_DATA(13 downto 1);
------probe0(255 downto 254)<= (others=>'0');
  

----probe0(0) <= done_tick;
----probe0(1) <= change_reticle_color;
----probe0(2) <= VIDEO_IN_H;
----probe0(3) <= VIDEO_IN_V;
----probe0(4) <= VIDEO_IN_DAV;
----probe0(14 downto 5)<= std_logic_vector(out_line_cnt);
----probe0(15) <= VIDEO_IN_EOI;
----probe0(16) <= RETICLE_EOI_D;
----probe0(17) <= VIDEO_IN_DAV_D;--FIFO_RD1;
----probe0(18) <= VIDEO_IN_DAV_DD;--FIFO_WR1; 
----probe0(50 downto 19)<=  std_logic_vector(pix_sum);
----probe0(51)<= RETICLE_EN;
----probe0(52)<= start_div;
----probe0(53)<= RETICLE_EN_D;
----probe0(54)<= RETICLE_REQ_V;--FIFO_CLR;
----probe0(55)<= RETICLE_REQ_H;
----probe0(63 downto 56) <= std_logic_vector(pix_avg);
----probe0(95 downto 64) <= quo;
----probe0(105 downto 96) <= RETICLE_POS_Y;
----probe0(115 downto 106) <= RETICLE_POS_X;
----probe0(125 downto 116) <= std_logic_vector(pix_cnt_d);
------probe0(103 downto 94) <= LATCH_RETICLE_POS_X;
------probe0(113 downto 104) <= LATCH_RETICLE_POS_Y;
------probe0(121 downto 114) <= VIDEO_IN_DATA_DD(7 downto 0);
----probe0(126) <= VIDEO_IN_H;
----probe0(127) <= VIDEO_IN_V;
------probe0(127 downto 126) <= (others=>'0');
------probe0(127 downto 96)<= dvsr;



----probe0(0) <= VIDEO_IN_H;
----probe0(1) <= VIDEO_IN_V;
----probe0(2) <= VIDEO_IN_DAV;
----probe0(3 downto 3)   <= RETICLE_OFFSET_WR_EN_IN;--RETICLE_EN;
----probe0(4)            <= RETICLE_OFFSET_RD_REQ;--start_div;
----probe0(8 downto  5)  <= RETICLE_OFFSET_RD_ADDR;
----probe0(40 downto 9)  <= RETICLE_OFFSET_RD_DATA_TEMP;
----probe0(72 downto 41) <= RETICLE_OFFSET_WR_DATA_IN;
----probe0(74 downto 73) <= std_logic_vector(to_unsigned(reticle_offset_transfer_st_t'POS(reticle_offset_transfer_st), 2));
----probe0(78 downto 75) <= reticle_offset_wr_addr;
----probe0(83 downto 79) <= std_logic_Vector(reticle_offset_wr_addr_temp);
----probe0(84 downto 84) <= reticle_offset_wr_req;
----probe0(116 downto 85)<= reticle_offset_wr_data;
----probe0(127 downto 117) <= (others=>'0');

----i_TOII_TUVE_ila: TOII_TUVE_ila
----PORT MAP (
----  clk => CLK,
----  probe0 => probe0
----);

----------------------------
--end architecture RTL;
----------------------------




