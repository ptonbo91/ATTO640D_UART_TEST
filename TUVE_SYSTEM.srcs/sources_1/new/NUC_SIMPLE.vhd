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
------------------------------------------------------------------------------

-- Base address for the NUC tables are in THERMAL_CAM_PACK.vhd FILE 

  --use WORK.THERMAL_CAM_PACK.all;
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
----------------------------
entity NUC_SIMPLE is
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

    ---- Controlling NUC block
    AVL_WAITREQUEST: out std_logic;
    AVL_WRREQ     : in std_logic;
    AVL_RDREQ     : in std_logic;
    AVL_ADDR      : in std_logic_vector(3 downto 0);
    AVL_WRDATA    : in std_logic_vector(31 downto 0);
    AVL_RDDAV     : out std_logic;
    AVL_RDDATA    : out std_logic_vector(31 downto 0);

    -- Video Input
    VIDEO_I_V     : in  std_logic;                      -- Video Input   Vertical Synchro
    VIDEO_I_H     : in  std_logic;                      -- Video Input Horizontal Synchro
    VIDEO_I_EOI   : in  std_logic;                      -- Video Input End Of Image
    VIDEO_I_DAV   : in  std_logic;                      -- Video Input Data Valid
    VIDEO_I_DATA  : in  std_logic_vector(bit_width downto 0);  -- Video Input Data

    -- DMA Master Read Interface to Memory Controller
    DMA1_RDREADY   : in  std_logic;                      -- DMA Ready Request
    DMA1_RDREQ     : out std_logic;                      -- DMA Read Request
    DMA1_RDSIZE    : out std_logic_vector(DMA_SIZE_BITS-1 downto 0);  -- DMA Request Size
    DMA1_RDADDR    : out std_logic_vector(31 downto 0);  -- DMA Master Address
    DMA1_RDDAV     : in  std_logic;                      -- DMA Read Data Valid
    DMA1_RDDATA    : in  std_logic_vector(31 downto 0);  -- DMA Read Data

    -- DMA Master Read Interface to Memory Controller
    DMA2_RDREADY   : in  std_logic;                      -- DMA Ready Request
    DMA2_RDREQ     : out std_logic;                      -- DMA Read Request
    DMA2_RDSIZE    : out std_logic_vector(DMA_SIZE_BITS-1 downto 0);  -- DMA Request Size
    DMA2_RDADDR    : out std_logic_vector(31 downto 0);  -- DMA Master Address
    DMA2_RDDAV     : in  std_logic;                      -- DMA Read Data Valid
    DMA2_RDDATA    : in  std_logic_vector(31 downto 0);  -- DMA Read Data


    -- Video Output
    VIDEO_O_V     : out std_logic;                      -- Video Output   Vertical Synchro
    VIDEO_O_H     : out std_logic;                      -- Video Output Horizontal Synchro
    VIDEO_O_EOI   : out std_logic;                      -- Video Output End Of Image
    VIDEO_O_DAV   : out std_logic;                      -- Video Output Data Valid
    VIDEO_O_DATA  : buffer std_logic_vector(bit_width downto 0);  -- Video Output Data
    VIDEO_O_BAD   : out std_logic                      -- Video Output Bad Pixel

  );

-------------------------------
end entity NUC_SIMPLE;
-------------------------------

-------------------------------------------
architecture RTL of NUC_SIMPLE is
-------------------------------------------
COMPONENT TOII_TUVE_ila

PORT (
    clk : IN STD_LOGIC;
    probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

  signal nuc_probe: std_logic_vector(127 downto 0);

  signal ENABLE_NUC    : std_logic;
  signal ENABLE_BADPIX : std_logic;
  signal ZFORCE_BADPIX : std_logic;
  signal ENABLE_UNITY_GAIN  : std_logic;

  signal DMA_ADDR_BASE_GAIN : std_logic_vector(31 downto 0);
  signal DMA_ADDR_BASE_OFFSET: std_logic_vector(31 downto 0);

  signal DMA_ADDR_BASE_GAIN_REG : std_logic_vector(31 downto 0);
  signal DMA_ADDR_BASE_OFFSET_REG: std_logic_vector(31 downto 0);

  type DMA_RDFSM_t is ( s_IDLE, s_WAIT_FOR_H,
                        s_GET_GAIN_OFFSET_START_ADDR, s_GET_GAIN_OFFSET_MATRIX, 
                        s_NEXT_LINE, s_GET_LINE_PARAM );

  signal DMA_RDFSM      : DMA_RDFSM_t;
  signal DMA_RDGOTO     : DMA_RDFSM_t;
  

  signal DMA_ADDR_LIN   : unsigned(LIN_BITS-1 downto 0);    -- lines max
  
  signal DMA1_ADDR_PIX   : unsigned(PIX_BITS+1 downto 0);    -- pixels max * 2 (Because 32bits per pixel required)
  signal DMA1_ADDR_PICT  : unsigned(DMA_ADDR_LIN'length+DMA1_ADDR_PIX'length-1 downto 0); --temporary signal
  signal DMA1_ADDR_BASE  : unsigned(DMA1_RDADDR'range);       -- Base address signal
  
  signal DMA2_ADDR_PIX   : unsigned(PIX_BITS+1 downto 0);    -- pixels max * 2 (Because 32bits per pixel required)
  signal DMA2_ADDR_PICT  : unsigned(DMA_ADDR_LIN'length+DMA2_ADDR_PIX'length-1 downto 0); --temporary signal
  signal DMA2_ADDR_BASE  : unsigned(DMA2_RDADDR'range);       -- Base address signal


  signal DMA_ADDR_START : unsigned(DMA_ADDR_LIN'length+DMA1_ADDR_PIX'length-1 downto 0); 
       

  signal DMA_RDEND      : unsigned(DMA1_ADDR_PIX'range);     -- End address signal

  -- RAM Write FSM    
--  type RAM_WRFSM_t is ( s_IDLE, s_NEW_LINE, s_STORE_GAIN_MATRIX, s_STORE_OFFM1_MATRIX,s_STORE_OFFM2_MATRIX );
  type RAM_WRFSM_t is ( s_IDLE, s_NEW_LINE, s_STORE_GAIN_OFFSET_MATRIX);
  signal RAM_WRFSM : RAM_WRFSM_t;
  signal RAM_WRST  : std_logic;
  signal RAM_WRSEL : std_logic;

  -- Both Gain and OffsetMatrix have same size (to store two lines)  
  constant RAMS_ADDR_WIDTH : positive := PIX_BITS+1; -- 1 line, +1 for Double Buffer
  signal RAM_RDSEL : std_logic;
  signal RAM_RDCNT : unsigned(RAMS_ADDR_WIDTH-2 downto 0);

  -- Gain Data Size in bits : 15bits, 3.12 format
  constant GAIN_DATA_SIZE : positive := 15;

  constant DMA_DATA_WIDTH: positive:= 32;
  
  -- Gain Matrix RAM Signals
  constant GAIN_DATA_WIDTH : positive := GAIN_DATA_SIZE + 1; -- +1 because we also store the bad pixel information (1bit) here 
  signal GAIN_WRREQ  : std_logic;
  signal GAIN_WRCNT  : unsigned(RAMS_ADDR_WIDTH-2-1 downto 0);  
  signal GAIN_WRADDR : std_logic_vector(RAMS_ADDR_WIDTH-1-1 downto 0); -- This is because we are using mixed port ram. Thus write 
                                                                       -- address is 2bits less than RD address
  signal GAIN_WRDATA : std_logic_vector(DMA_DATA_WIDTH-1 downto 0);        -- Write data port is same width as FIFO port size.
  signal GAIN_RDADDR : std_logic_vector(RAMS_ADDR_WIDTH-1 downto 0);
  signal GAIN_RDDATA : std_logic_vector(GAIN_DATA_WIDTH-1 downto 0);
  signal GAIN_RDDATA_D : std_logic_vector(GAIN_DATA_WIDTH-1 downto 0);
  -- Offset Matrix RAM Signals
  constant OFFM_DATA_WIDTH : positive := 16;
  signal OFFM1_WRREQ  : std_logic;
  signal OFFM1_WRCNT  : unsigned(RAMS_ADDR_WIDTH-2-1 downto 0);
  signal OFFM1_WRADDR : std_logic_vector(RAMS_ADDR_WIDTH-1-1 downto 0); -- This is because we are using mixed port ram. Thus write 
                                                                       -- address is 1bit less than RD address
  signal OFFM1_WRDATA   : std_logic_vector(DMA_DATA_WIDTH-1 downto 0);        -- Write data port is same width as FIFO port size.
  signal OFFM1_RDADDR   : std_logic_vector(RAMS_ADDR_WIDTH-1 downto 0);
  signal OFFM1_RDDATA   : std_logic_vector(OFFM_DATA_WIDTH-1 downto 0);

  signal offset_1 : signed(31 downto 0);
  

  -- Video Output Signals
  signal ENABLE_NUC_l : std_logic;
  signal ENABLE_UNITY_GAIN_l: std_logic;
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

  
  -- Pipeline Signals
  signal VIDEO_I_DATAd : std_logic_vector(VIDEO_I_DATA'range);
  signal VIDEO_I_DATAd1 : std_logic_vector(VIDEO_I_DATA'range);
  signal VIDEO_I_DATAd2 : std_logic_vector(VIDEO_I_DATA'range);
  signal VIDEO_I_DATAd3 : std_logic_vector(VIDEO_I_DATA'range);
  
  signal VIDEO_I_XCNT  :  std_logic_vector(PIX_BITS-1 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
  signal VIDEO_I_YCNT  :  std_logic_vector(LIN_BITS-1 downto 0);  -- Video Y Line  Counter (1st line  = 0)

 
 
 --- OFFSET CALCULATION --------------------------------------------------------
 
  
  signal OFFIMG1_AVG  : std_logic_vector(15 downto 0);
  --signal OFFIMG2_AVG  : std_logic_vector(15 downto 0);
  
  signal update_offimg_avg : std_logic;
  
  signal VIDEO_I_V_D : std_logic;
  
  signal update_device_id_reg_en_d : std_logic;
  
  signal GAIN_LINE_RD_DONE        : std_logic;
  signal OFFSET_IMG1_LINE_RD_DONE : std_logic;

  signal GAIN_LINE_WR_DONE        : std_logic;
  signal OFFSET_IMG1_LINE_WR_DONE : std_logic;

------------------------------------------------------------------------------------  
  ATTRIBUTE MARK_DEBUG : string;
  ATTRIBUTE MARK_DEBUG of  OFFM1_WRCNT: SIGNAL IS "TRUE";
  ATTRIBUTE MARK_DEBUG of  GAIN_WRCNT: SIGNAL IS "TRUE";
  ATTRIBUTE MARK_DEBUG of  GAIN_WRREQ: SIGNAL IS "TRUE";
  ATTRIBUTE MARK_DEBUG of  DMA1_ADDR_PIX: SIGNAL IS "TRUE";
  ATTRIBUTE MARK_DEBUG of  DMA2_ADDR_PIX: SIGNAL IS "TRUE";


ATTRIBUTE MARK_DEBUG of VIDEO_I_V              : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_I_H              : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_I_DAV            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_I_EOI            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of DMA1_RDREADY            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of DMA1_RDDAV              : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of OFFM1_WRREQ            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of ENABLE_NUC             : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of offimg_start_div       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of ENABLE_NUC_l           : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of VIDEO_I_DAVd2          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_I_DAVd1          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_I_DAVd           : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_O_DAVi           : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of offimg1_done_tick      : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of offimg2_done_tick      : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of OFFIMG2_AVG            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of OFFIMG1_AVG            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_O_RES            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of OFFM1_RDDATA           : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_O_YCNTi          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_O_XCNTi          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of GAIN_RDDATA            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_I_DATA           : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of VIDEO_O_FSM            : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of DMA_RDFSM              : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of DMA_ADDR_START         : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of DMA1_RDDATA             : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of DMA1_ADDR_PICT          : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of DMA1_ADDR_BASE          : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of DMA_ADDR_BASE_GAIN     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of DMA_ADDR_LIN           : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of DMA2_RDREADY                : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA2_RDDAV                  : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of GAIN_LINE_RD_DONE           : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of OFFSET_IMG1_LINE_RD_DONE    : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of GAIN_LINE_WR_DONE           : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of OFFSET_IMG1_LINE_WR_DONE    : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of RAM_WRSEL                   : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of RAM_WRFSM                   : SIGNAL IS "TRUE"; 


ATTRIBUTE MARK_DEBUG of VIDEO_O_DATA : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of offset_1     : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of VIDEO_O_TEMP : SIGNAL IS "TRUE"; 




--------
begin
--------

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

process(CLK, RST) begin
  if RST='1' then
    AVL_RDDAV <= '0';
    ENABLE_NUC <= '0';
    ENABLE_BADPIX <= '0';
    ZFORCE_BADPIX <= '0';
    ENABLE_UNITY_GAIN <= '0';
    DMA_ADDR_BASE_GAIN <= (others=>'0');
    DMA_ADDR_BASE_OFFSET <= (others=>'0');
  elsif (rising_edge(CLK)) then
    AVL_RDDAV <= '0';
    if(AVL_WRREQ='1')then
      case(AVL_ADDR) is
        when x"0" => ENABLE_NUC <= AVL_WRDATA(0);
        when x"1" => ENABLE_BADPIX <= AVL_WRDATA(0);
                     ZFORCE_BADPIX <= AVL_WRDATA(1);
        when x"2" => ENABLE_UNITY_GAIN <= AVL_WRDATA(0);
        when x"3" => DMA_ADDR_BASE_GAIN <= AVL_WRDATA;
        when x"4" => DMA_ADDR_BASE_OFFSET <= AVL_WRDATA;
        when others =>
          null;
      end case;
    elsif(AVL_RDREQ='1') then
      AVL_RDDAV <= '1';
      AVL_RDDATA <= (others=>'0');
      case(AVL_ADDR) is
        when x"0" => AVL_RDDATA(0) <= ENABLE_NUC;
        when x"1" => AVL_RDDATA(0) <= ENABLE_BADPIX;
                     AVL_RDDATA(1) <= ZFORCE_BADPIX;
        when x"2" => AVL_RDDATA(0) <= ENABLE_UNITY_GAIN;
        when x"3" => AVL_RDDATA <= DMA_ADDR_BASE_GAIN;
        when x"4" => AVL_RDDATA <= DMA_ADDR_BASE_OFFSET;
        when others =>
          AVL_RDDATA <= x"DEAD_BEEF";
      end case;
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
      RAM_WRST        <= '0';
      DMA1_RDREQ      <= '0';
      DMA_RDEND       <= (others => '0');
      DMA_ADDR_LIN    <= (others => '0');
      DMA_ADDR_START  <= (others => '0');
      DMA1_ADDR_PIX   <= (others => '0');
      DMA1_ADDR_PICT  <= (others => '0');
      DMA1_ADDR_BASE  <= (others => '0');
      DMA2_ADDR_PIX   <= (others => '0');
      DMA2_ADDR_PICT  <= (others => '0');
      DMA2_ADDR_BASE  <= (others => '0');
      DMA_RDFSM       <= s_IDLE;
      DMA_ADDR_BASE_GAIN_REG <= (others=>'0');
      DMA_ADDR_BASE_OFFSET_REG <= (others=>'0');
      VIDEO_I_V_D <= '0';
      GAIN_LINE_RD_DONE        <= '0';
      OFFSET_IMG1_LINE_RD_DONE <= '0';
    elsif rising_edge(CLK) then


      RAM_WRST      <= '0';
      VIDEO_I_V_D      <= VIDEO_I_V;  
      
      case DMA_RDFSM is

        -- Wait for New Frame Flag to arrive here
        when s_IDLE =>
            DMA1_RDREQ    <= '0';
            DMA1_ADDR_PIX <= (others => '0');
            DMA2_RDREQ    <= '0';
            DMA2_ADDR_PIX <= (others => '0');
            DMA_ADDR_LIN <= to_unsigned(1,DMA_ADDR_LIN'length);
            
            -- New Frame is arriving !
            if VIDEO_I_V = '1' and (ENABLE_NUC = '1' or ENABLE_BADPIX = '1') then
              DMA_RDFSM  <= s_WAIT_FOR_H;
              DMA_ADDR_BASE_GAIN_REG <= DMA_ADDR_BASE_GAIN;
              DMA_ADDR_BASE_OFFSET_REG <= DMA_ADDR_BASE_OFFSET;
            end if;

        when s_WAIT_FOR_H =>
            if VIDEO_I_H = '1' then
              DMA_RDFSM <= s_GET_GAIN_OFFSET_START_ADDR;
            end if;      
        -- Computing here the Next line Start Address (VIDEO_O_XSIZi  )
        when s_GET_GAIN_OFFSET_START_ADDR =>
            DMA_ADDR_START <= DMA_ADDR_LIN * to_unsigned(to_integer(VIDEO_O_XSIZi)*2, DMA1_ADDR_PIX'length); -- 2 bytes of data . Therefore Xsize*2 bytes.
            DMA_RDFSM      <= s_GET_GAIN_OFFSET_MATRIX;

        -- Read Gain Matrix and Offset Img values here
        when s_GET_GAIN_OFFSET_MATRIX =>
            RAM_WRST      <= '1';  -- Will start the RAM_WRFSM !
            
            DMA1_ADDR_BASE <= unsigned(DMA_ADDR_BASE_GAIN_REG); -- GAIN BASE ADDRESS
            DMA1_ADDR_PICT <= DMA_ADDR_START;  -- start address
            DMA1_RDREQ     <= '1';  -- initiate the Read in Memory

            DMA2_ADDR_BASE <= unsigned(DMA_ADDR_BASE_OFFSET_REG); -- NUC 1-PT OFFSET IMG1 BASE ADDRESS
            DMA2_ADDR_PICT <= DMA_ADDR_START;  -- start address
            DMA2_RDREQ     <= '1';  -- initiate the Read in Memory
                
             
            DMA_RDFSM     <= s_GET_LINE_PARAM;
            DMA_RDEND     <= to_unsigned(to_integer(VIDEO_O_XSIZi)*2, DMA_RDEND'length);  -- 2 bytes of data per pixel is needed. Therefore Xsize*2 bytes.
            DMA_RDGOTO    <= s_NEXT_LINE;
            
            GAIN_LINE_RD_DONE        <= '0';
            OFFSET_IMG1_LINE_RD_DONE <= '0';
            
            
        -- Wait for next line
        when s_NEXT_LINE =>  
            if VIDEO_I_H = '1' then   -- Next line
              DMA1_ADDR_PIX <= (others => '0');
              DMA2_ADDR_PIX <= (others => '0');
              if (unsigned(DMA_ADDR_LIN)=(unsigned(VIDEO_O_YSIZi)-1)) then
                DMA_ADDR_LIN<= to_unsigned(0,DMA_ADDR_LIN'length);
              else
                DMA_ADDR_LIN <= DMA_ADDR_LIN + 1;
              end if;
              DMA_RDFSM    <= s_GET_GAIN_OFFSET_START_ADDR;
            end if;                

        -- Common Routine : Make Read requests from DDR3/SRAM memory for "a Line of Parameters"
        when s_GET_LINE_PARAM =>
            if(GAIN_LINE_RD_DONE = '0')then
                if DMA1_RDREADY = '1' then -- Read Accepted
                  DMA1_ADDR_PICT <= DMA1_ADDR_PICT + RD_SIZE*4;   --*8 because 8 bytes are read at once(64 bit data bus)
                  if DMA1_ADDR_PIX + RD_SIZE*4 = DMA_RDEND then  -- End of Reading this line
                    DMA1_RDREQ    <= '0';  ---**************** DMA_RDREQ    <= '0';
                    DMA1_ADDR_PIX <= (others => '0');
                    GAIN_LINE_RD_DONE <= '1';
                  else
                    DMA1_ADDR_PIX <= DMA1_ADDR_PIX  + RD_SIZE*4;  --*8 because 8 bytes are read at once(64 bit data bus)
                    DMA1_RDREQ <= '1';
                    DMA_RDFSM    <= s_GET_LINE_PARAM;
                  end if;
                else
                  DMA1_ADDR_PICT<= DMA1_ADDR_PICT;
                  DMA1_RDREQ <= '1';
                  DMA_RDFSM    <= s_GET_LINE_PARAM;
                end if;
            end if;
            if(OFFSET_IMG1_LINE_RD_DONE = '0')then
                if DMA2_RDREADY = '1' then -- Read Accepted
                  DMA2_ADDR_PICT <= DMA2_ADDR_PICT + RD_SIZE*4;   --*8 because 8 bytes are read at once(64 bit data bus)
                  if DMA2_ADDR_PIX + RD_SIZE*4 = DMA_RDEND then  -- End of Reading this line
                    DMA2_RDREQ    <= '0';  ---**************** DMA_RDREQ    <= '0';
                    DMA2_ADDR_PIX <= (others => '0');
                    OFFSET_IMG1_LINE_RD_DONE <= '1';
                  else
                    DMA2_ADDR_PIX <= DMA2_ADDR_PIX  + RD_SIZE*4;  --*8 because 8 bytes are read at once(64 bit data bus)
                    DMA2_RDREQ <= '1';
                    DMA_RDFSM    <= s_GET_LINE_PARAM;
                  end if;
                else
                  DMA2_ADDR_PICT<= DMA2_ADDR_PICT;
                  DMA2_RDREQ <= '1';
                  DMA_RDFSM    <= s_GET_LINE_PARAM;
                end if;
            end if;
            
            if(GAIN_LINE_RD_DONE='1' and OFFSET_IMG1_LINE_RD_DONE='1')then
                DMA_RDFSM    <= DMA_RDGOTO;
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
  DMA1_RDADDR <= std_logic_vector(DMA1_ADDR_BASE + DMA1_ADDR_PICT);   
  DMA1_RDSIZE <= std_logic_vector(to_unsigned(RD_SIZE, DMA1_RDSIZE'length));

  DMA2_RDADDR <= std_logic_vector(DMA2_ADDR_BASE + DMA2_ADDR_PICT);   
  DMA2_RDSIZE <= std_logic_vector(to_unsigned(RD_SIZE, DMA2_RDSIZE'length));
                   
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
      GAIN_WRREQ  <= '0';  
      GAIN_WRCNT  <= (others => '0');  
           
      OFFM1_WRREQ  <= '0';  
      OFFM1_WRCNT  <= (others => '0');  

      RAM_WRSEL   <= '0';
      RAM_WRFSM   <= s_IDLE;
      GAIN_LINE_WR_DONE        <= '0';
      OFFSET_IMG1_LINE_WR_DONE <= '0';
    elsif rising_edge(CLK) then

      GAIN_WRREQ  <= '0'; 
      OFFM1_WRREQ <= '0';

      case RAM_WRFSM is

        -- Wait for the New Frame Start 
        when s_IDLE =>
            if VIDEO_I_V = '1' and (ENABLE_NUC = '1' or ENABLE_BADPIX = '1') then
              RAM_WRSEL <= '0';  -- so that the 1st line is stored in buffer 0  
              RAM_WRFSM <= s_NEW_LINE;
              GAIN_LINE_WR_DONE        <= '0';
              OFFSET_IMG1_LINE_WR_DONE <= '0';
              
            end if;

        -- Wait for the Start Flag, or End Of Image
        when s_NEW_LINE =>
            if RAM_WRST = '1' then
              GAIN_WRCNT <= (others => '0');  
              OFFM1_WRCNT <= (others => '0');  
              RAM_WRSEL  <= not RAM_WRSEL;  
--              RAM_WRFSM  <= s_STORE_GAIN_MATRIX;
              RAM_WRFSM  <= s_STORE_GAIN_OFFSET_MATRIX;
              GAIN_LINE_WR_DONE        <= '0';
              OFFSET_IMG1_LINE_WR_DONE <= '0';
              
              
            end if;

        -- Store the Gain Matrix in RAM
        -- Extracting 64bits word from FIFO = 4 16bits Gain (+ bad pixel) Values
        when s_STORE_GAIN_OFFSET_MATRIX =>
            if(GAIN_LINE_WR_DONE = '0')then
                if DMA1_RDDAV='1'then 
                    GAIN_WRCNT  <= GAIN_WRCNT + 1;  
                    GAIN_WRADDR <= RAM_WRSEL & std_logic_vector(GAIN_WRCNT);
                    GAIN_WRDATA <= DMA1_RDDATA;
                    GAIN_WRREQ  <= '1';  
                    if (GAIN_WRCNT = VIDEO_O_XSIZi/2-1)then
                        GAIN_LINE_WR_DONE <= '1';
                    end if;
                end if;
            end if;
 
            if(OFFSET_IMG1_LINE_WR_DONE = '0')then
                if DMA2_RDDAV='1'then 
                    OFFM1_WRCNT  <= OFFM1_WRCNT + 1;   
                    OFFM1_WRADDR <= RAM_WRSEL & std_logic_vector(OFFM1_WRCNT);
                    OFFM1_WRDATA <= DMA2_RDDATA;
                    OFFM1_WRREQ  <= '1';
                    if (OFFM1_WRCNT = VIDEO_O_XSIZi/2-1)then
                        OFFSET_IMG1_LINE_WR_DONE <= '1';
                    end if;
                end if;
             end if;
        
            if(GAIN_LINE_WR_DONE = '1' and OFFSET_IMG1_LINE_WR_DONE = '1')then
                RAM_WRFSM <= s_NEW_LINE;
            end if;              
      end case;

      -- Clear FSM on End Of Image
--      if VIDEO_I_EOI = '1' then 
--        RAM_WRFSM <= s_IDLE;
--      end if;
            if VIDEO_I_V = '1' and (ENABLE_NUC = '1' or ENABLE_BADPIX = '1') then
              RAM_WRSEL <= '0';  -- so that the 1st line is stored in buffer 0  
              RAM_WRFSM <= s_NEW_LINE;
              GAIN_LINE_WR_DONE        <= '0';
              OFFSET_IMG1_LINE_WR_DONE <= '0';
              
            end if;            
    end if;
  end process RAM_WR_process;

    ---- Double Line Buffer for Gain Matrix

  GAIN_MATRIX_DBLINE : entity WORK.SPRAM_GENERIC_DC_MIXED
    generic map (
      RD_ADDR_WIDTH => RAMS_ADDR_WIDTH,  -- RAM Address Width
      WR_ADDR_WIDTH => RAMS_ADDR_WIDTH-1, -- since read data port is 4 times smaller
      RD_DATA_WIDTH => GAIN_DATA_WIDTH,  -- RAM Data Width
      WR_DATA_WIDTH => DMA_DATA_WIDTH,
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

--  GAIN_WRADDR <= RAM_WRSEL & std_logic_vector(GAIN_WRCNT);
  GAIN_RDADDR <= RAM_RDSEL & std_logic_vector(RAM_RDCNT);


  OFFSET_MATRIX1_DBLINE : entity WORK.SPRAM_GENERIC_DC_MIXED
    generic map (
      RD_ADDR_WIDTH => RAMS_ADDR_WIDTH,  -- RAM Address Width
      WR_ADDR_WIDTH => RAMS_ADDR_WIDTH-1, -- since read data port is 2 times smaller
      RD_DATA_WIDTH => OFFM_DATA_WIDTH,  -- RAM Data Width
      WR_DATA_WIDTH => DMA_DATA_WIDTH,
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

--  OFFM1_WRADDR <= RAM_WRSEL & std_logic_vector(OFFM1_WRCNT);
  OFFM1_RDADDR <= RAM_RDSEL & std_logic_vector(RAM_RDCNT);


  -- -------------------------------------------------------
  --  Computing NUC algo on the fly !
  -- -------------------------------------------------------
  -- This process reads the already prepared Gain / Offset Matrix values
  -- from internal ram buffers, and perform on the fly : 
  -- NUC(I,j) = (Input Image(I,j) * Gain Matrix(I,j)) - Offset Matrix (I,j)
  -- It also outputs the Bad Pixel information on the VIDEO_O_BAD output
  VIDEO_out_process : process(CLK, RST)
    variable vVIDEO_DATA : signed(VIDEO_O_TEMP'length + 5 downto 0);
    variable wavg_OFFM_RDDATA : signed(OFFM_DATA_WIDTH-1 downto 0);
    variable mult_OFFM1_RDDATA : signed((2*OFFM_DATA_WIDTH) downto 0);
    variable mult_OFFM_RDDATA_ADD : signed((2*OFFM_DATA_WIDTH)+1 downto 0);
--    variable offset_1 : std_logic_vector(31 downto 0);
--    variable offset_2 : std_logic_vector(31 downto 0);

  begin
    if RST = '1' then
      ENABLE_NUC_l  <= '0';
      ENABLE_UNITY_GAIN_l <= '0';
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
      
      VIDEO_I_DATAd  <= (others=>'0');
      VIDEO_I_DATAd1 <= (others=>'0');
      VIDEO_I_DATAd2 <= (others=>'0');
      VIDEO_I_DATAd3 <= (others=>'0');
      
--      offimg_start_div <= '0';
      
--      OFFIMG1_SUM      <= (others=>'0');
      OFFIMG1_AVG      <= (others=>'0');
--      offimg1_dvnd     <= (others=>'0');
      
--      OFFIMG2_SUM      <= (others=>'0');
      --OFFIMG2_AVG      <= (others=>'0'); 
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
                ENABLE_UNITY_GAIN_l <= ENABLE_UNITY_GAIN;
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
        -- NUC(I,j) = (Input Image(I,j) * Gain Matrix(I,j)) - Offset Matrix (I,j)
        -- Otherwise, just output the bad pixel information
        when s_COMPUTE_LINE =>
            -- Data Processing : step 1

            -- Memory reading takes 2 clk cycles. Thus it is necessary to delay the capturing by at least 1 clk cycle.
            -- This delay has been added to accomodate for pixel clock of 40MHz on a system clock of 108MHz

            if VIDEO_I_DAV ='1' then
              VIDEO_I_DAVd <='1';
              GAIN_RDADDRd <= GAIN_RDADDR;
              OFFM1_RDADDRd <= OFFM1_RDADDR;
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
              
              if(update_offimg_avg = '1')then
                update_offimg_avg <= '0';
                OFFIMG1_AVG       <= "00" & OFFM1_RDDATA(13 downto 0);
              end if;  

              if(ENABLE_UNITY_GAIN_l='1') then
                offset_1       <= (signed("0000" & unsigned(OFFIMG1_AVG(15 downto 0)) & "000000000000") - to_signed(2**12, 16)*signed(OFFM1_RDDATA(15 downto 0)));
              else 
                offset_1       <= (signed("0000" & unsigned(OFFIMG1_AVG(15 downto 0)) & "000000000000") - signed(GAIN_RDDATA(15 downto 0))*signed(OFFM1_RDDATA(15 downto 0)));
              end if;
              GAIN_RDDATA_D  <= GAIN_RDDATA;

            end if;
            
            if VIDEO_I_DAVd3 = '1' then  -- New Input Pixel
              VIDEO_O_NEW  <= ENABLE_NUC_l;     -- for the NUC pipeline
              VIDEO_O_BADi <= GAIN_RDDATA_D(15);  -- get the Bad Pixel information
              -- Compute : Input Image(I,j) * Gain Matrix(I,j) as an unsigned
              if(ENABLE_UNITY_GAIN_l='1') then
                VIDEO_O_TEMP <= to_unsigned(2**12, 15) * unsigned(VIDEO_I_DATAd3); 
              else 
                VIDEO_O_TEMP <= unsigned(GAIN_RDDATA_D(14 downto 0)) * unsigned(VIDEO_I_DATAd3);
              end if;
              -- Load the Offset Matrix, in signed result  
            
                VIDEO_O_RES  <= resize(signed(offset_1(27 downto 12)), VIDEO_O_RES'length);  -- add 3bits because format 4.3
              
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
              -- Compute (Input Image(I,j) * Gain Matrix(I,j) ) - Offset Matrix (I,j),
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
 
-- nuc_probe(0)  <= offset_matrix_rd_done;
-- nuc_probe(0)  <= VIDEO_I_V;
-- nuc_probe(1)  <= VIDEO_I_H;
-- nuc_probe(2)  <= VIDEO_I_DAV;
-- nuc_probe(3)  <= VIDEO_I_EOI;
-- nuc_probe(4)  <= ENABLE_NUC;
-- nuc_probe(5)  <= OFFM1_WRREQ;
-- nuc_probe(9 downto 6)  <= (others=>'0');
-- nuc_probe(10) <= VIDEO_O_DAVi;
-- nuc_probe(11) <= VIDEO_I_DAVd;        
-- nuc_probe(25 downto 12) <= VIDEO_O_DATA;
-- nuc_probe(26) <= VIDEO_I_DAVd1;  
-- nuc_probe(42 downto 27) <= OFFM1_RDDATA;
-- nuc_probe(46 downto 43) <= std_logic_vector(to_unsigned(VIDEO_O_FSM_t'POS(VIDEO_O_FSM), 4));
---- nuc_probe(48)           <= VIDEO_I_DAVd2;--temperature_data_len ;--OFFM1_WRADDR; 
-- nuc_probe(60 downto 47) <= VIDEO_I_DATA;--OFFIMG1_AVG;
-- nuc_probe(66 downto 61) <="000000";
---- nuc_probe(78 downto 63)  <= std_logic_Vector(offset_1(15 downto 0));
--nuc_probe(75 downto 67)  <=  std_logic_Vector(OFFM1_WRCNT);
-- nuc_probe(107 downto 76) <= OFFM1_WRDATA;--std_logic_Vector(VIDEO_O_TEMP);
-- nuc_probe(117 downto 108)<= std_logic_Vector(VIDEO_O_XCNTi);
-- nuc_probe(127 downto 118)<= std_logic_Vector(VIDEO_O_YCNTi);

 
-- i_nuc: TOII_TUVE_ila
--  PORT MAP (
--      clk => CLK,
--      probe0 => nuc_probe
--  );

-----------------------------
end architecture RTL;
-----------------------------