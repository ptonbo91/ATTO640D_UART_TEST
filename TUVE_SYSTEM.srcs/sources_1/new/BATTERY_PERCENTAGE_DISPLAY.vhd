library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
   

----------------------------------
entity BATTERY_PERCENTAGE_DISPLAY is
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
    CLK                            : in  std_logic;                              -- Module Clock
    RST                            : in  std_logic;                              -- Module Reset (Asynchronous active high)
    BAT_PER_DISP_EN                : in  std_logic;                              -- Enable BATTERY PERCENTAGE DISPLAY
    bat_per_disp_toggle            : in  std_logic;
    BAT_CHG_SYMBOL_EN              : in  std_logic;
    BATTERY_CHARGING_START         : in  std_logic;
--    BAT_PER_DISP_COLOR_INFO        : in  std_logic_vector( 23 downto 0);     
--    CH_COLOR_INFO1                 : in  std_logic_vector( 23 downto 0);     
--    CH_COLOR_INFO2                 : in  std_logic_vector( 23 downto 0);     
    BAT_PER_DISP_COLOR_INFO        : in  std_logic_vector(7 downto 0);     
    CH_COLOR_INFO1                 : in  std_logic_vector(7 downto 0);     
    CH_COLOR_INFO2                 : in  std_logic_vector(7 downto 0);  
    BAT_PER_DISP_POS_X             : in  std_logic_vector(PIX_BITS-1 downto 0);  -- BATTREY PERCENTAGE POSITION X
    BAT_PER_DISP_POS_Y             : in  std_logic_vector(LIN_BITS-1 downto 0);  -- BATTREY PERCENTAGE POSITION Y 
    BAT_CHG_SYMBOL_POS_OFFSET      : in  std_logic_vector(PIX_BITS downto 0);    -- BATTREY CHARGING SYMBOL POSITION OFFSET AND LEFT/RIGHT LOCATION SELECTION    
    CH_IMG_WIDTH_IN                : in  std_logic_vector( 9 downto 0);          
    CH_IMG_HEIGHT_IN               : in  std_logic_vector( 9 downto 0);          

    BAT_PER_DISP_REQ_V             : in  std_logic;                              -- Scaler New Frame Request
    BAT_PER_DISP_REQ_H             : in  std_logic;                              -- Scaler New Line Request
    BAT_PER_DISP_FIELD             : in  std_logic;                              -- FIELD

    BAT_PER_DISP_REQ_XSIZE1        : in  std_logic_vector(PIX_BITS-1 downto 0);  
    BAT_PER_DISP_REQ_YSIZE1        : in  std_logic_vector(LIN_BITS-1 downto 0);  
    
    VIDEO_IN_V                     : in  std_logic;                              -- Scaler New Frame
    VIDEO_IN_H                     : in  std_logic;
    VIDEO_IN_DAV                   : in  std_logic;                              -- Scaler New Data
--    VIDEO_IN_DATA                  : in  std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    VIDEO_IN_DATA                  : in  std_logic_vector(7 downto 0);
    VIDEO_IN_EOI                   : in  std_logic;
    VIDEO_IN_XSIZE                 : in  std_logic_vector(PIX_BITS-1 downto 0);  -- Width of output image
    VIDEO_IN_YSIZE                 : in  std_logic_vector(LIN_BITS-1 downto 0);  -- Height of output image
    
    BAT_PER_DISP_V                 : out std_logic;                              
    BAT_PER_DISP_H                 : out std_logic;
    BAT_PER_DISP_DAV               : out std_logic;                              
--    BAT_PER_DISP_DATA              : out std_logic_vector(23 downto 0);   
    BAT_PER_DISP_DATA              : out std_logic_vector(7 downto 0);         
    BAT_PER_DISP_EOI               : out std_logic;
    POLARITY                       : in  std_logic;  
    BAT_PER                        : in  std_logic_Vector(7 downto 0)
    
  );
----------------------------------
end entity BATTERY_PERCENTAGE_DISPLAY;
----------------------------------

------------------------------------------
architecture RTL of BATTERY_PERCENTAGE_DISPLAY is
------------------------------------------

COMPONENT ila_0

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

component CH_ROM_SIZE_8 is
   generic(
          ADDR_WIDTH: positive;
          DATA_WIDTH: positive
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

  constant PIX_BETWEEN_CH_CLM          : unsigned(7 downto 0)  := x"00";
  constant CH_IMG_WIDTH            : unsigned(9 downto 0)  := "00" &x"10";--"00" &x"08";
  constant CH_IMG_HEIGHT           : unsigned(9 downto 0)  := "00" &x"10";--"00" &x"08";  
  
--  constant PIX_BETWEEN_CH_ROW          : unsigned(7 downto 0)  := x"02";   
  constant FIFO_DEPTH                  : positive := CH_ROM_ADDR_WIDTH;--10;  -- 2**FIFO_DEPTH words in the FIFO
  constant FIFO_WSIZE                  : positive := CH_ROM_DATA_WIDTH;
  constant FIFO_DEPTH1                 : positive := 11;--0;  -- 2**FIFO_DEPTH words in the FIFO
--  constant FIFO_WSIZE1                 : positive := 24;  
  constant FIFO_WSIZE1                 : positive := 8;    
--  signal probe0                        : std_logic_vector(127 downto 0);
  type   CH_ROM_RDFSM_t is ( s_IDLE, s_WAIT_H,s_GET_CH_ADDR,s_GET_ADDR, s_READ ); --s_GET_CH_ADDR,
  signal CH_ROM_RDFSM                  : CH_ROM_RDFSM_t;
  signal CH_ROM_ADDR_PIX               : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);  
  signal CH_ROM_ADDR_PICT              : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal CH_ROM_ADDR_BASE              : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal CH_ROM_ADDR_BASE_TEMP         : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal FIFO_CLR_BAT_PER_DISP         : std_logic;
  signal FIFO_WR_BAT_PER_DISP          : std_logic;
  signal FIFO_IN_BAT_PER_DISP          : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_FUL_BAT_PER_DISP         : std_logic;
  signal FIFO_NB_BAT_PER_DISP          : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal FIFO_EMP_BAT_PER_DISP         : std_logic;
  signal FIFO_RD_BAT_PER_DISP          : std_logic;
  signal FIFO_OUT_BAT_PER_DISP         : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_OUT_BAT_PER_DISP_REV     : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_CLR1                     : std_logic;
  signal FIFO_WR1                      : std_logic;
  signal FIFO_IN1                      : std_logic_vector(FIFO_WSIZE1-1 downto 0);
  signal FIFO_FUL1                     : std_logic;
  signal FIFO_NB1                      : std_logic_vector(FIFO_DEPTH1-1 downto 0);
  signal FIFO_EMP1                     : std_logic;
  signal FIFO_RD1                      : std_logic;
  signal FIFO_OUT1                     : std_logic_vector(FIFO_WSIZE1-1 downto 0);
  signal BAT_PER_DISP_DAVi             : std_logic;
  signal BAT_PER_DISP_V_D              : std_logic;  
  signal BAT_PER_DISP_H_D              : std_logic; 
  signal BAT_PER_DISP_DAV_D            : std_logic;
  signal BAT_PER_DISP_EOI_D            : std_logic;  
  signal count                         : integer := 0;
  signal FIFO_RD1_CNT                  : integer := 0;
  signal FIFO_RD1_CNT_D                : integer := 0;
  signal FIFO_RD_BAT_PER_DISP_D        : std_logic;
  signal FIFO_RD1_D                    : std_logic;
  signal first_time_rd_rq              : std_logic;
  signal BAT_PER_DISP_EN_D             : std_logic;
  signal BAT_CHG_SYMBOL_EN_D           : std_logic;
  signal BAT_PER_DISP_REQ_XSIZE        : std_logic_vector(PIX_BITS-1 downto 0);
  signal BAT_PER_DISP_REQ_YSIZE        : std_logic_vector(LIN_BITS-1 downto 0);
  signal POS_X_BAT_PER_DISP            : std_logic_vector(PIX_BITS-1 downto 0);
  signal POS_Y_BAT_PER_DISP            : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_BAT_PER_DISP_COLOR_INFO : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO1          : std_logic_vector( 23 downto 0);
--  signal LATCH_CH_COLOR_INFO2          : std_logic_vector( 23 downto 0);
--  signal LATCH_CURSOR_COLOR_INFO       : std_logic_vector( 23 downto 0);
  signal LATCH_BAT_PER_DISP_COLOR_INFO : std_logic_vector(7 downto 0);
  signal LATCH_CH_COLOR_INFO1          : std_logic_vector(7 downto 0);
  signal LATCH_CH_COLOR_INFO2          : std_logic_vector(7 downto 0);
  signal LATCH_CURSOR_COLOR_INFO       : std_logic_vector(7 downto 0);
  signal LATCH_BAT_PER_DISP_POS_X      : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_BAT_PER_DISP_POS_Y      : std_logic_vector(LIN_BITS-1 downto 0);
  signal LATCH_BAT_PER_DISP_REQ_XSIZE  : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_BAT_PER_DISP_REQ_YSIZE  : std_logic_vector(LIN_BITS-1 downto 0);
  signal line_cnt                      : unsigned(LIN_BITS-1 downto 0);
  signal pix_cnt                       : unsigned(PIX_BITS-1 downto 0);
  signal pix_cnt_d                     : unsigned(PIX_BITS-1 downto 0);
  signal RD_BAT_PER_DISP_LIN_NO        : unsigned(LIN_BITS-1 downto 0);
  signal BAT_PER_DISP_ADD_DONE         : std_logic; 
  signal BAT_PER_DISP_POS_Y_TEMP       : std_logic_Vector(LIN_BITS-1 downto 0); 
  signal BAT_PER_DISP_POS_Y_D          : std_logic_Vector(LIN_BITS-1 downto 0);  
  signal BAT_PER_DISP_POS_X1           : std_logic_vector(PIX_BITS-1 downto 0);  -- BAT_PER_DISP POSITION X
  signal BAT_PER_DISP_POS_Y1           : std_logic_vector(LIN_BITS-1 downto 0);  -- BAT_PER_DISP POSITION Y
  signal BAT_PER_DISP_LINE_CNT         : unsigned(LIN_BITS-1 downto 0);
  signal BAT_PER_DISP_RD_DONE          : std_logic;
  signal flag                          : std_logic; 
  signal POS_Y_CH                      : unsigned(LIN_BITS-1 downto 0);
  signal POS_X_CH                      : unsigned(PIX_BITS-1 downto 0);
  signal POS_X_CH_D                    : unsigned(PIX_BITS-1 downto 0);
  signal POS_X_CH_DD                   : unsigned(PIX_BITS-1 downto 0);
  signal POS_Y_CH_1                    : unsigned(LIN_BITS-1 downto 0);
  signal POS_X_CH_1                    : unsigned(PIX_BITS-1 downto 0);
  signal CH_CNT                        : unsigned(3 downto 0);
  signal SEL_CH_WR_FIFO                : std_logic_vector(7 downto 0);
  signal DMA_RDDAV_D                   : std_logic;
  signal CH_CNT_FIFO_RD                : unsigned(3 downto 0);
  signal CH_CNT_FIFO_RD_D              : unsigned(3 downto 0);
  signal ADDR_CH_1                     : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_2                     : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_3                     : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_4                     : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal ADDR_CH_5                     : unsigned(CH_ROM_ADDR_WIDTH-1 downto 0);
  signal CH_ADDR_OFFSET                : unsigned(5 downto 0);  
  signal CH_ROM_DATA                   : std_logic_vector(CH_ROM_DATA_WIDTH-1 downto 0);
  signal CH_ROM_ADDR                   : std_logic_vector(CH_ROM_ADDR_WIDTH-1 downto 0); 
  signal INTERNAL_LINE_CNT             : unsigned(LIN_BITS-1 downto 0);
  signal CH_LIN_CNT_RD                 : unsigned(7 downto 0);
  signal CH_ADD_CNT                    : unsigned(7 downto 0);
  signal BAT_PER_DISP_REQ_V_D          : std_logic ;
  signal BAT_PER_DISP_REQ_V_DD         : std_logic ;
  signal BAT_PER_DISP_REQ_V_DDD        : std_logic ;
  signal BIN_DATA                      : std_logic_vector(9 downto 0);   
  signal BIN_DATA_VALID                : std_logic;
  signal BCD_DATA                      : std_logic_vector(11 downto 0);
  signal BCD_DATA_VALID                : std_logic;
  signal BCD_DATA_D                    : std_logic_vector(11 downto 0);  
  signal BAT_PER_DISP_REQ_H_D          : std_logic;
  signal BAT_PER_DISP_REQ_H_DD         : std_logic;  
  signal BAT_PER_DISP_REQ_H_DDD        : std_logic;
  signal BAT_PER_DISP_REQ_H_DDDD       : std_logic;  
  signal VIDEO_IN_V_D                  : std_logic;
  signal VIDEO_IN_V_DD                 : std_logic;  
  signal VIDEO_IN_V_DDD                : std_logic;
  signal VIDEO_IN_V_DDDD               : std_logic;  
  signal VIDEO_IN_H_D                  : std_logic;
  signal VIDEO_IN_H_DD                 : std_logic;  
  signal VIDEO_IN_H_DDD                : std_logic;
  signal VIDEO_IN_H_DDDD               : std_logic;    
  signal BCD_BAT_PER                   : std_logic_vector(11 downto 0);
  type   bin_to_bcd_t is ( s_idle,s_bat_per,s_bat_per_wait); --s_GET_CH_ADDR,
  signal bin_to_bcd_fsm                : bin_to_bcd_t;
  signal BATTERY_CHARGING_START_D      : std_logic; 
  signal BAT_CHG_SYMBOL_POS_OFFSET_D   : std_logic_vector(PIX_BITS downto 0);



  
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
      CH_ROM_ADDR_PICT              <= (others => '0');
      CH_ROM_RDFSM                  <= s_IDLE;
      LATCH_BAT_PER_DISP_COLOR_INFO <= x"50";--x"508080";
      LATCH_CH_COLOR_INFO1          <= x"EB";--x"EB8080";
      LATCH_CH_COLOR_INFO2          <= x"10";--x"108080";
      LATCH_CURSOR_COLOR_INFO       <= x"EB";--x"EB8080";
      LATCH_BAT_PER_DISP_POS_X      <= (others => '0');
      LATCH_BAT_PER_DISP_POS_X      <= (others => '0');
      LATCH_BAT_PER_DISP_REQ_XSIZE  <= (others => '0');
      LATCH_BAT_PER_DISP_REQ_YSIZE  <= (others => '0');
      POS_X_BAT_PER_DISP            <= (others => '0');
      POS_Y_BAT_PER_DISP            <= (others => '0');
      POS_X_CH_1                    <= (others => '0');
      POS_Y_CH_1                    <= (others => '0');
      RD_BAT_PER_DISP_LIN_NO        <= (others => '0');
      BAT_PER_DISP_POS_Y_TEMP       <= (others => '0');
      BAT_PER_DISP_POS_Y_D          <= (others => '0');
      BAT_PER_DISP_RD_DONE          <= '0';
      CH_CNT                        <= (others => '0');
      SEL_CH_WR_FIFO                <= (others => '0');
      DMA_RDDAV_D                   <= '0';
      ADDR_CH_1                     <= (others => '0');
      ADDR_CH_2                     <= (others => '0');  
      ADDR_CH_3                     <= (others => '0');
      ADDR_CH_4                     <= (others => '0');
      ADDR_CH_5                     <= (others => '0');
      INTERNAL_LINE_CNT             <= (others=>'0');
      CH_ADD_CNT                    <= (others=>'0');
      BAT_PER_DISP_EN_D             <= '0';              
      BAT_PER_DISP_REQ_H_D          <= '0';
      BAT_PER_DISP_REQ_H_DD         <= '0';
      BAT_PER_DISP_REQ_H_DDD        <= '0';
      BAT_PER_DISP_REQ_H_DDDD       <= '0';
      BAT_CHG_SYMBOL_EN_D           <= '0';
      BATTERY_CHARGING_START_D      <= '0'; 
      BAT_CHG_SYMBOL_POS_OFFSET_D   <= (others=>'0');
    elsif rising_edge(CLK) then

      FIFO_WR_BAT_PER_DISP    <= '0';     

      BAT_PER_DISP_REQ_H_D    <= BAT_PER_DISP_REQ_H;    
      BAT_PER_DISP_REQ_H_DD   <= BAT_PER_DISP_REQ_H_D;   
      BAT_PER_DISP_REQ_H_DDD  <= BAT_PER_DISP_REQ_H_DD;   
      BAT_PER_DISP_REQ_H_DDDD <= BAT_PER_DISP_REQ_H_DDD; 

      case CH_ROM_RDFSM is         

        when s_IDLE =>
            CH_ROM_ADDR_PIX <= (others => '0');
            line_cnt        <= (others => '0');        
            if BAT_PER_DISP_EN_D ='1' or BAT_CHG_SYMBOL_EN_D = '1' then
             CH_ROM_RDFSM   <= s_WAIT_H;
            end if; 

        when s_WAIT_H =>
            if BAT_PER_DISP_REQ_H_DDDD = '1' then
              line_cnt     <= line_cnt + 1;
              BAT_PER_DISP_RD_DONE  <= '0';         
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
            else
                    CH_ROM_RDFSM          <= s_WAIT_H;
                    CH_CNT                <= (others=>'0');
                    BAT_PER_DISP_RD_DONE  <= '1';   
                    if(INTERNAL_LINE_CNT = unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0)))then
                      CH_ADD_CNT        <= CH_ADD_CNT + 1;
                      INTERNAL_LINE_CNT <= (others=>'0');
                      CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
--                      if(BAT_PER_DISP_FIELD = '0')then
--                        CH_ROM_ADDR_PICT  <= to_unsigned(0,CH_ROM_ADDR_PICT'length); 
--                      else
--                        CH_ROM_ADDR_PICT  <= to_unsigned(1,CH_ROM_ADDR_PICT'length); 
--                      end if;  
                    else
--                      CH_ROM_ADDR_PICT  <= CH_ROM_ADDR_PICT + 2;
                      CH_ROM_ADDR_PICT  <= CH_ROM_ADDR_PICT + 1;
                    end if;
            end if;                 
                

        -- Do Read at Computed Address    
        when s_GET_ADDR =>
            CH_ROM_RDFSM <= s_READ;           

        -- WRITE CH DATA TO FIFO
        when s_READ =>
            FIFO_IN_BAT_PER_DISP  <= CH_ROM_DATA;
            FIFO_WR_BAT_PER_DISP  <= '1';
            CH_ROM_RDFSM          <= s_GET_CH_ADDR;
        end case;
        

    

                            
     if(BCD_DATA_VALID = '1')then
        BCD_DATA_D <= BCD_DATA; 
     else
        BCD_DATA_D <= BCD_DATA_D; 
     end if;              

     if(BAT_PER_DISP_EN_D = '1' or BAT_CHG_SYMBOL_EN_D='1')then   
        if(BAT_CHG_SYMBOL_POS_OFFSET_D(PIX_BITS)='1')then
         if(BAT_PER_DISP_EN_D = '1')then
             if(BCD_BAT_PER(7 downto 4)= x"0" and BCD_BAT_PER(11 downto 8) = x"0")then
                ADDR_CH_2 <= resize((unsigned(BCD_BAT_PER(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_3 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_4 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_5 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
             elsif (BCD_BAT_PER(11 downto 8) = x"0")then
                ADDR_CH_2 <= resize((unsigned(BCD_BAT_PER(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_3 <= resize((unsigned(BCD_BAT_PER(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_4 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                ADDR_CH_5 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);  
             else
                ADDR_CH_2 <= resize((unsigned(BCD_BAT_PER(11 downto 8))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_3 <= resize((unsigned(BCD_BAT_PER(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_4 <= resize((unsigned(BCD_BAT_PER(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_5  <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);              
             end if;             
         else
            ADDR_CH_2 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_3 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_4 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_5 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         end if;
         if(BAT_CHG_SYMBOL_EN_D = '1' and BATTERY_CHARGING_START_D = '1')then          
            ADDR_CH_1  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);      
         else
            ADDR_CH_1  <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         end if;
             
        else
         if(BAT_PER_DISP_EN_D = '1')then                   
             if(BCD_BAT_PER(7 downto 4)= x"0" and BCD_BAT_PER(11 downto 8) = x"0")then
                ADDR_CH_1 <= resize((unsigned(BCD_BAT_PER(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_2 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_3 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_4 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
             elsif (BCD_BAT_PER(11 downto 8) = x"0")then
                ADDR_CH_1 <= resize((unsigned(BCD_BAT_PER(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_2 <= resize((unsigned(BCD_BAT_PER(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_3 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);   
                ADDR_CH_4 <= resize( 0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
             else
                ADDR_CH_1 <= resize((unsigned(BCD_BAT_PER(11 downto 8))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_2 <= resize((unsigned(BCD_BAT_PER(7 downto 4))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
                ADDR_CH_3 <= resize((unsigned(BCD_BAT_PER(3 downto 0))+2)*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH); 
                ADDR_CH_4 <= resize(12*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);             
             end if;
                
         else
            ADDR_CH_1 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_2 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_3 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
            ADDR_CH_4 <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);            
         end if; 
        
         if(BAT_CHG_SYMBOL_EN_D = '1' and BATTERY_CHARGING_START_D = '1')then          
            ADDR_CH_5  <= resize(13*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);      
         else
            ADDR_CH_5  <= resize(0*CH_ADDR_OFFSET,CH_ROM_ADDR_WIDTH);
         end if;
        end if; 
     end if;
     POS_X_BAT_PER_DISP      <= LATCH_BAT_PER_DISP_POS_X;
     POS_Y_BAT_PER_DISP      <= LATCH_BAT_PER_DISP_POS_Y;
     POS_Y_CH_1              <= (unsigned(LATCH_BAT_PER_DISP_POS_Y)) ;
     POS_X_CH_1              <= (unsigned(LATCH_BAT_PER_DISP_POS_X)) ; 
     BAT_PER_DISP_REQ_XSIZE  <= LATCH_BAT_PER_DISP_REQ_XSIZE;
     BAT_PER_DISP_REQ_YSIZE  <= LATCH_BAT_PER_DISP_REQ_YSIZE; 



     if BAT_PER_DISP_REQ_V = '1' then
        CH_ROM_RDFSM <= s_IDLE; 
        CH_ADD_CNT   <= (others=>'0');
        if(BAT_PER_DISP_FIELD = '0')then       
             if(BAT_PER_DISP_EN = '1')then
                BAT_PER_DISP_EN_D <='1' and not(bat_per_disp_toggle);
             else
                BAT_PER_DISP_EN_D         <= '0' ;
             end if;          
                                                     
--           BAT_PER_DISP_EN_D             <= BAT_PER_DISP_EN ;
           BAT_CHG_SYMBOL_EN_D           <= BAT_CHG_SYMBOL_EN;
           BATTERY_CHARGING_START_D      <= BATTERY_CHARGING_START;
           BAT_CHG_SYMBOL_POS_OFFSET_D   <= BAT_CHG_SYMBOL_POS_OFFSET;
           LATCH_BAT_PER_DISP_POS_X      <= BAT_PER_DISP_POS_X;
           LATCH_BAT_PER_DISP_POS_Y      <= BAT_PER_DISP_POS_Y;             
           LATCH_BAT_PER_DISP_REQ_XSIZE  <= BAT_PER_DISP_REQ_XSIZE1;
           LATCH_BAT_PER_DISP_REQ_YSIZE  <= BAT_PER_DISP_REQ_YSIZE1;
           LATCH_BAT_PER_DISP_COLOR_INFO <= BAT_PER_DISP_COLOR_INFO;
           LATCH_CH_COLOR_INFO1          <= CH_COLOR_INFO1;
           LATCH_CH_COLOR_INFO2          <= CH_COLOR_INFO2;  
           CH_ROM_ADDR_PICT              <= to_unsigned(0,CH_ROM_ADDR_PICT'length);  
           RD_BAT_PER_DISP_LIN_NO        <= to_unsigned(0,RD_BAT_PER_DISP_LIN_NO'length);  
        else
           BAT_PER_DISP_EN_D             <= BAT_PER_DISP_EN_D;
           BAT_CHG_SYMBOL_EN_D           <= BAT_CHG_SYMBOL_EN_D;
           BATTERY_CHARGING_START_D      <= BATTERY_CHARGING_START_D;
           BAT_CHG_SYMBOL_POS_OFFSET_D   <= BAT_CHG_SYMBOL_POS_OFFSET_D; 
           LATCH_BAT_PER_DISP_POS_X      <= LATCH_BAT_PER_DISP_POS_X;
           LATCH_BAT_PER_DISP_POS_Y      <= LATCH_BAT_PER_DISP_POS_Y;
           LATCH_BAT_PER_DISP_REQ_XSIZE  <= LATCH_BAT_PER_DISP_REQ_XSIZE;
           LATCH_BAT_PER_DISP_REQ_YSIZE  <= LATCH_BAT_PER_DISP_REQ_YSIZE;           
           LATCH_BAT_PER_DISP_COLOR_INFO <= LATCH_BAT_PER_DISP_COLOR_INFO;
           LATCH_CH_COLOR_INFO1          <= LATCH_CH_COLOR_INFO1;
           LATCH_CH_COLOR_INFO2          <= LATCH_CH_COLOR_INFO2;
           LATCH_CURSOR_COLOR_INFO       <= LATCH_CURSOR_COLOR_INFO;
           RD_BAT_PER_DISP_LIN_NO        <= to_unsigned(1,RD_BAT_PER_DISP_LIN_NO'length);
--           CH_ROM_ADDR_PICT              <= to_unsigned(1,CH_ROM_ADDR_PICT'length);     
           CH_ROM_ADDR_PICT              <= to_unsigned(0,CH_ROM_ADDR_PICT'length);     
        end if;
   end if;
  end if;
end process;


 FIFO_CLR_BAT_PER_DISP   <= BAT_PER_DISP_REQ_V or BAT_PER_DISP_REQ_H_DDDD;

 i_BAT_PER_DISP_CH_RDFIFO : entity WORK.FIFO_GENERIC_SC
  generic map (
    FIFO_DEPTH => FIFO_DEPTH,
    FIFO_WIDTH => FIFO_WSIZE,
    SHOW_AHEAD => false      ,
    USE_EAB    => true
  )
  port map (
    CLK    => CLK     ,
    RST    => RST     ,
    CLR    => FIFO_CLR_BAT_PER_DISP,
    WRREQ  => FIFO_WR_BAT_PER_DISP ,
    WRDATA => FIFO_IN_BAT_PER_DISP ,
    FULL   => FIFO_FUL_BAT_PER_DISP,
    USEDW  => FIFO_NB_BAT_PER_DISP ,
    EMPTY  => FIFO_EMP_BAT_PER_DISP,
    RDREQ  => FIFO_RD_BAT_PER_DISP ,
    RDDATA => FIFO_OUT_BAT_PER_DISP_REV
  ); 
   
gen:    
    for i in 0 to 15 generate
           FIFO_OUT_BAT_PER_DISP(i) <=FIFO_OUT_BAT_PER_DISP_REV(15-i); 
    end generate;
     
      
  FIFO_WR1  <= VIDEO_IN_DAV;
  FIFO_IN1  <= VIDEO_IN_DATA;
  FIFO_CLR1 <= VIDEO_IN_V;   
    
    
    
  i_BAT_PER_DISP_RDFIFO : entity WORK.FIFO_GENERIC_SC
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
        
  
  assert not ( FIFO_FUL_BAT_PER_DISP = '1' and FIFO_WR_BAT_PER_DISP = '1' )
    report "[MEMORY_TO_SCALER] WRITE in FIFO Full !!!" severity failure;

  process(CLK, RST)
  begin
    if RST = '1' then
      BAT_PER_DISP_V         <= '0';
      BAT_PER_DISP_V_D       <= '0';
      BAT_PER_DISP_DAVi      <= '0';
      FIFO_RD_BAT_PER_DISP   <= '0';
      FIFO_RD1               <= '0';
      BAT_PER_DISP_DATA      <= (others => '0');
      BAT_PER_DISP_H         <= '0';
      BAT_PER_DISP_H_D       <= '0';
      BAT_PER_DISP_EOI       <= '0';
      BAT_PER_DISP_EOI_D     <= '0';
      first_time_rd_rq       <= '1'; 
      FIFO_RD1_CNT           <= 0; 
      FIFO_RD1_CNT_D         <= 0; 
      count                  <= 0;
      pix_cnt_d              <= (others => '0');
      BAT_PER_DISP_ADD_DONE  <= '0';
      flag                   <= '0';
      CH_CNT_FIFO_RD         <= (others=>'0');
      CH_CNT_FIFO_RD_D       <= (others=>'0');
      BAT_PER_DISP_LINE_CNT  <= (others=>'0'); 
      POS_X_CH_D             <= (others=>'0'); 
      POS_X_CH_DD            <= (others=>'0');      
      CH_LIN_CNT_RD          <= (others=>'0');  
      BAT_PER_DISP_REQ_V_D   <=  '0';    
      VIDEO_IN_V_D           <= '0';
      VIDEO_IN_V_DD          <= '0';
      VIDEO_IN_V_DDD         <= '0';
      VIDEO_IN_V_DDDD        <= '0';
      VIDEO_IN_H_D           <= '0';
      VIDEO_IN_H_DD          <= '0';
      VIDEO_IN_H_DDD         <= '0';
      VIDEO_IN_H_DDDD        <= '0';  
      BAT_PER_DISP_REQ_V_D   <= '0';
      BAT_PER_DISP_REQ_V_DD  <= '0';
      BAT_PER_DISP_REQ_V_DDD <= '0';    
      POS_X_CH               <= (others => '0');
      POS_Y_CH               <= (others => '0');      
    elsif rising_edge(CLK) then

--      LATCH_POS_Y_CH      <= LATCH_POS_Y_CH_1;
      CH_CNT_FIFO_RD_D       <= CH_CNT_FIFO_RD;
      BAT_PER_DISP_REQ_V_D   <= BAT_PER_DISP_REQ_V;
      BAT_PER_DISP_REQ_V_DD  <= BAT_PER_DISP_REQ_V_D;
      BAT_PER_DISP_REQ_V_DDD <= BAT_PER_DISP_REQ_V_DD;
      VIDEO_IN_V_D           <= VIDEO_IN_V;
      VIDEO_IN_V_DD          <= VIDEO_IN_V_D;
      VIDEO_IN_V_DDD         <= VIDEO_IN_V_DD;
      VIDEO_IN_V_DDDD        <= VIDEO_IN_V_DDD;
      VIDEO_IN_H_D           <= VIDEO_IN_H;
      VIDEO_IN_H_DD          <= VIDEO_IN_H_D;
      VIDEO_IN_H_DDD         <= VIDEO_IN_H_DD;
      VIDEO_IN_H_DDDD        <= VIDEO_IN_H_DDD;

      if(BAT_PER_DISP_REQ_V_DDD = '1') then
          POS_Y_CH       <= POS_Y_CH_1;
          CH_LIN_CNT_RD  <= (others=>'0');
      end if; 
  
      
      if BAT_PER_DISP_EN_D ='1'or BAT_CHG_SYMBOL_EN_D = '1' then
            BAT_PER_DISP_V         <= BAT_PER_DISP_V_D;
            BAT_PER_DISP_H         <= BAT_PER_DISP_H_D;
            FIFO_RD_BAT_PER_DISP   <= '0';
            FIFO_RD1               <= '0';
            BAT_PER_DISP_V_D       <= '0'; 
            BAT_PER_DISP_H_D       <= '0';
            BAT_PER_DISP_EOI_D     <= VIDEO_IN_EOI;
            BAT_PER_DISP_EOI       <= BAT_PER_DISP_EOI_D;
            BAT_PER_DISP_DAVi      <= '0';
            FIFO_RD1_D             <= FIFO_RD1;
            FIFO_RD_BAT_PER_DISP_D <= FIFO_RD_BAT_PER_DISP ;
            FIFO_RD1_CNT_D         <= FIFO_RD1_CNT;
            pix_cnt_d              <= pix_cnt;
            POS_X_CH_D             <= POS_X_CH;
            POS_X_CH_DD            <= POS_X_CH_D;
                       
            if VIDEO_IN_V_DDDD = '1' then
              BAT_PER_DISP_V_D      <= '1'; 
              CH_CNT_FIFO_RD        <= (others=>'0');
              BAT_PER_DISP_LINE_CNT <= (others=>'0');
            end if;
      
            if VIDEO_IN_H_DDDD = '1' then
              BAT_PER_DISP_H_D      <= '1';  
              first_time_rd_rq      <= '1'; 
              FIFO_RD1_CNT          <= 0;   
              pix_cnt               <= (others => '0');
              count                 <= 0;
              BAT_PER_DISP_ADD_DONE <= '0';
              CH_CNT_FIFO_RD        <= (others=>'0');
              POS_X_CH              <= POS_X_CH_1;                        
            end if;
           
           if ((line_cnt-1) >= unsigned(POS_Y_CH(LIN_BITS-1 downto 0))) and  ((line_cnt-1) < (unsigned(CH_IMG_HEIGHT(LIN_BITS-1 downto 0)) + unsigned(POS_Y_CH(LIN_BITS-1 downto 0)))) then                           
            if((((BAT_PER_DISP_RD_DONE = '1') and (unsigned(FIFO_NB1) >= unsigned(CH_IMG_WIDTH)))) or (count>= (unsigned(VIDEO_IN_XSIZE))-unsigned(CH_IMG_WIDTH)))then 
                 count      <= count + 1;
                 FIFO_RD1   <= '1';
                 pix_cnt    <= pix_cnt + 1;
                 if((pix_cnt = unsigned(POS_X_CH)))then
                   FIFO_RD_BAT_PER_DISP  <= '1';
                   BAT_PER_DISP_ADD_DONE <= '1';
                   FIFO_RD1_CNT          <= 0;
                 elsif(BAT_PER_DISP_ADD_DONE = '1')then
                   if FIFO_RD1_CNT = (unsigned(CH_IMG_WIDTH) -1) then
                       BAT_PER_DISP_ADD_DONE <= '0';
                       FIFO_RD1_CNT          <= 0;
                   else
                       FIFO_RD1_CNT <= FIFO_RD1_CNT+ 1;
                   end if;                       
                 end if;  
                              
                 if((pix_cnt) = (unsigned(CH_IMG_WIDTH)- 1 + unsigned(POS_X_CH)))then
                     CH_CNT_FIFO_RD   <=  CH_CNT_FIFO_RD + 1 ; 
                       if(CH_CNT_FIFO_RD = x"00")then
                        if(BAT_CHG_SYMBOL_POS_OFFSET_D(PIX_BITS)='1')then
                           POS_X_CH  <= resize((POS_X_CH_1+1*PIX_BETWEEN_CH_CLM+unsigned(BAT_CHG_SYMBOL_POS_OFFSET_D(PIX_BITS-1 downto 0))+1*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                        else
                           POS_X_CH  <= resize((POS_X_CH_1+1*PIX_BETWEEN_CH_CLM+1*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                        end if;
                       elsif(CH_CNT_FIFO_RD = x"01")then
                        if(BAT_CHG_SYMBOL_POS_OFFSET_D(PIX_BITS)='1')then
                           POS_X_CH  <= resize((POS_X_CH_1+2*PIX_BETWEEN_CH_CLM+unsigned(BAT_CHG_SYMBOL_POS_OFFSET_D(PIX_BITS-1 downto 0))+2*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                        else
                           POS_X_CH  <= resize((POS_X_CH_1+2*PIX_BETWEEN_CH_CLM+2*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                        end if;
                       elsif(CH_CNT_FIFO_RD = x"02")then
                        if(BAT_CHG_SYMBOL_POS_OFFSET_D(PIX_BITS)='1')then
                           POS_X_CH  <= resize((POS_X_CH_1+3*PIX_BETWEEN_CH_CLM+unsigned(BAT_CHG_SYMBOL_POS_OFFSET_D(PIX_BITS-1 downto 0))+3*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                        else
                           POS_X_CH  <= resize((POS_X_CH_1+3*PIX_BETWEEN_CH_CLM+3*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                        end if;
                       elsif(CH_CNT_FIFO_RD = x"03")then                        
                           POS_X_CH  <= resize((POS_X_CH_1+4*PIX_BETWEEN_CH_CLM+unsigned(BAT_CHG_SYMBOL_POS_OFFSET_D(PIX_BITS-1 downto 0))+4*unsigned(CH_IMG_WIDTH)),POS_X_CH'length);
                       end if;
                 end if; 
                    
                 if count = (unsigned(VIDEO_IN_XSIZE))-1 then
                  count <= 0; 
                 end if;  
            else
                  FIFO_RD1     <= '0';
                  FIFO_RD_BAT_PER_DISP  <= '0';
            end if;
            
            
            
            if FIFO_RD1_D = '1'then
               BAT_PER_DISP_DAVi <= '1';
               if(((pix_cnt_d-1)>= (unsigned(POS_X_BAT_PER_DISP))) and ((pix_cnt_d-1) < ((unsigned(BAT_PER_DISP_REQ_XSIZE) + unsigned(POS_X_BAT_PER_DISP)))))then
                  if(((pix_cnt_d-1)>= (unsigned(POS_X_CH_DD))) and ((pix_cnt_d-1) < ((unsigned(CH_IMG_WIDTH)+ unsigned(POS_X_CH_DD)))))then   
                    if(FIFO_OUT_BAT_PER_DISP(((FIFO_RD1_CNT_D))) = '1')then  
--                        if(POLARITY='0')then                     
--                            BAT_PER_DISP_DATA <= LATCH_CH_COLOR_INFO1;
--                        else
--                            BAT_PER_DISP_DATA <= LATCH_CH_COLOR_INFO2;
--                        end if;  
                        BAT_PER_DISP_DATA <= LATCH_CH_COLOR_INFO1;   
                    else 
                        BAT_PER_DISP_DATA <= FIFO_OUT1;
                    end if;
                  else
                    BAT_PER_DISP_DATA <= FIFO_OUT1;
                  end if;
               else
                  BAT_PER_DISP_DATA <= FIFO_OUT1;
               end if;     
            end if; 
              
          else
             FIFO_RD_BAT_PER_DISP     <= '0';
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
                   BAT_PER_DISP_DAVi <= '1';
                   BAT_PER_DISP_DATA <= FIFO_OUT1;     
              end if;        
               
           end if;
      else
          BAT_PER_DISP_V         <= VIDEO_IN_V; 
          BAT_PER_DISP_H         <= VIDEO_IN_H ;
          BAT_PER_DISP_DAVi      <= VIDEO_IN_DAV;
          BAT_PER_DISP_DATA      <= VIDEO_IN_DATA;
          BAT_PER_DISP_EOI       <= VIDEO_IN_EOI;
          FIFO_RD_BAT_PER_DISP   <= '0';
          FIFO_RD1               <= '0'; 
          BAT_PER_DISP_H_D       <= '0';  
          BAT_PER_DISP_V_D       <= '0';
          BAT_PER_DISP_EOI_D     <= '0';
          first_time_rd_rq       <= '1'; 
          FIFO_RD1_CNT           <= 0; 
          count                  <= 0;
          FIFO_RD1_D             <= '0';
          FIFO_RD_BAT_PER_DISP_D <= '0';
          FIFO_RD1_CNT_D         <= 0;
          BAT_PER_DISP_LINE_CNT  <= (others=>'0');
  
      end if;  
      
   end if;
    
  end process;

BAT_PER_DISP_DAV   <= BAT_PER_DISP_DAVi;

i_CH_ROM_SIZE_8 :  CH_ROM_SIZE_8
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
        BCD_BAT_PER    <= (others =>'0');
        bin_to_bcd_fsm <= s_idle;
        BIN_DATA       <= (others =>'0');
        BIN_DATA_VALID <= '0';
    elsif rising_edge(CLK) then
        BIN_DATA_VALID   <= '0';
        case bin_to_bcd_fsm is        
         when s_idle => 
            if(BAT_PER_DISP_REQ_V = '1' and BAT_PER_DISP_FIELD = '0')then
                bin_to_bcd_fsm <= s_bat_per;    
            else
                bin_to_bcd_fsm <= s_idle;       
            end if;
         
         when s_bat_per =>
            BIN_DATA       <= "00" &BAT_PER;  
            BIN_DATA_VALID <= '1';            
            bin_to_bcd_fsm <= s_bat_per_wait; 
         when s_bat_per_wait =>
            if(BCD_DATA_VALID = '1')then
                BCD_BAT_PER    <= BCD_DATA;
                bin_to_bcd_fsm <= s_idle; 
            end if;            
        end case;  
 
    end if;
end process;  



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

--probe0(0)<= BAT_PER_DISP_DAVi;
--probe0(1)<= FIFO_EMP_BAT_PER_DISP;
--probe0(2)<= VIDEO_IN_H;
--probe0(3)<= VIDEO_IN_V;
--probe0(4)<= VIDEO_IN_DAV;
--probe0(5)<= BAT_PER_DISP_REQ_V;
--probe0(6)<= BAT_PER_DISP_REQ_H;
--probe0(7)<= BAT_PER_DISP_FIELD;
--probe0(17 downto 8)<=FIFO_NB1;
----probe0(16 downto 11)<= std_logic_vector(DMA_ADDR_PIX_check);
--probe0(18)<= VIDEO_IN_EOI;
--probe0(19)<= BAT_PER_DISP_EOI_D;
--probe0(20)<= FIFO_RD1;
--probe0(21)<= FIFO_WR1;
--probe0(31 downto 22)<= std_logic_vector(to_unsigned(count,10));--FIFO_OUT;
--probe0(41 downto 32)<= std_logic_Vector(line_cnt);
--probe0(51 downto 42)<= std_logic_Vector(pix_cnt);
--probe0(52)<= BAT_PER_DISP_EN;
--probe0(53)<= BAT_PER_DISP_EN_D;
--probe0(54)<= FIFO_RD_BAT_PER_DISP;
--probe0(55)<= FIFO_WR_BAT_PER_DISP;
--probe0(65 downto 56)<=  std_logic_Vector(POS_X_CH_D);
--probe0(75 downto 66)<=  std_logic_Vector(pix_cnt_d);
--probe0(83 downto 76)<=  std_logic_Vector(lin_block_cnt_dd);
--probe0(91 downto 84)<=  std_logic_Vector(lin_block_cnt_d);
--probe0(99 downto 92)<=  std_logic_Vector(lin_block_cnt);
--probe0(107 downto 100)<=  std_logic_Vector(clm_block_cnt);
--probe0(117 downto 108)<=  std_logic_Vector(POS_X_CH_DD);
--probe0(127 downto 118)<=  std_logic_Vector(POS_X_CH);

--i_ila_BAT_PER_DISP: ila_0
--PORT MAP (
--  clk => CLK,
--  probe0 => probe0
--);
--------------------------
end architecture RTL;
--------------------------