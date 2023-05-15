library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
   

----------------------------------
entity ADD_LOGO is
----------------------------------
  generic (
    PIX_BITS  : positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS  : positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image  
    LOGO_INIT_MEMORY_WR_SIZE : positive
  );
  port (
    -- Clock and Reset
    CLK                        : in  std_logic;                              -- Module Clock
    RST                        : in  std_logic;                              -- Module Reset (Asynchronous active high)
--    video_start                : in std_logic;          
--    qspi_LOGO_transfer_done : in std_logic;
--    qspi_LOGO_transfer_rq   : out std_logic;
--    LOGO_sel                : out std_logic_Vector(3 downto 0);
    LOGO_WR_EN_IN           : in  std_logic_vector(0 downto 0);           -- Block ram write enable (LOGO write data)
    LOGO_WR_DATA_IN         : in  std_logic_Vector(31 downto 0);          -- Block ram write data (LOGO write data) 
    LOGO_EN                 : in  std_logic;                              -- Enable LOGO
--    LOGO_TYPE               : in  std_logic_vector(3 downto 0);           -- SELSECT LOGO TYPE
--    LOGO_COLOR_INFO1        : in  std_logic_vector(23 downto 0);     -- LOGO COLOR1
--    LOGO_COLOR_INFO2        : in  std_logic_vector(23 downto 0);     -- LOGO COLOR2
    LOGO_COLOR_INFO1        : in  std_logic_vector( 7 downto 0);     -- LOGO COLOR1
    LOGO_COLOR_INFO2        : in  std_logic_vector( 7 downto 0);     -- LOGO COLOR2
    LOGO_POS_X              : in  std_logic_vector(PIX_BITS-1 downto 0);  -- LOGO POSITION X
    LOGO_POS_Y              : in  std_logic_vector(LIN_BITS-1 downto 0);  -- LOGO POSITION Y
--    MEM_IMG_XSIZE              : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture X Size (max 1023)
--    MEM_IMG_YSIZE              : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture Y Size (max 1023)
    
    LOGO_REQ_V              : in  std_logic;                              -- Scaler New Frame Request
    LOGO_REQ_H              : in  std_logic;                              -- Scaler New Line Request
    LOGO_FIELD              : in  std_logic;                              -- FIELD
    LOGO_REQ_XSIZE          : in std_logic_vector(PIX_BITS-1 downto 0);   -- Width of image required by scaler
    LOGO_REQ_YSIZE          : in std_logic_vector(LIN_BITS-1 downto 0);   -- Height of image required by scaler
    
    VIDEO_IN_V                 : in std_logic;                              -- Scaler New Frame
    VIDEO_IN_H                 : in std_logic;
    VIDEO_IN_DAV               : in std_logic;                              -- Scaler New Data
--    VIDEO_IN_DATA              : in std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    VIDEO_IN_DATA              : in std_logic_vector(7 downto 0);           -- Scaler Data (Y)
    VIDEO_IN_EOI               : in std_logic;
    VIDEO_IN_XSIZE             : in std_logic_vector(PIX_BITS-1 downto 0);  -- Width of output image
    VIDEO_IN_YSIZE             : in std_logic_vector(LIN_BITS-1 downto 0);  -- Height of output image

    LOGO_V                  : out std_logic;                              -- Scaler New Frame
    LOGO_H                  : out std_logic;
    LOGO_DAV                : out std_logic;                              -- Scaler New Data
--    LOGO_DATA               : out std_logic_vector(23 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    LOGO_DATA               : out std_logic_vector(7 downto 0);            -- Scaler Data (Y )
    LOGO_EOI                : out std_logic;
    LOGO_POS_X_OUT          : out std_logic_vector(PIX_BITS-1 downto 0);
    LOGO_POS_Y_OUT          : out std_logic_vector(LIN_BITS-1 downto 0)
  );
----------------------------------
end entity ADD_LOGO;
----------------------------------


------------------------------------------
architecture RTL of ADD_LOGO is
------------------------------------------



--COMPONENT LOGO_INIT_MEMORY
--  PORT (
--    clka : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
--  );
--END COMPONENT;
COMPONENT LOGO_INIT_MEMORY
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END COMPONENT;


COMPONENT TOII_TUVE_ila

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0)
);
END COMPONENT;

  

  signal probe0 : std_logic_vector(255 downto 0);
  
  type LOGO_RDFSM_t is ( s_IDLE, s_WAIT_H );
  signal LOGO_RDFSM    : LOGO_RDFSM_t;
  signal LOGO_DAVi     : std_logic;
  signal LOGO_V_D      : std_logic;  
  signal LOGO_H_D      : std_logic; 
  signal LOGO_EOI_D    : std_logic;
  signal FIFO_RD1_CNT     : unsigned(PIX_BITS-1 downto 0);
  signal FIFO_RD1_CNT_D   : unsigned(PIX_BITS-1 downto 0);
  signal first_time_rd_rq : std_logic;
  signal LOGO_EN_D     : std_logic;
--  signal LOGO_cnt1 : unsigned(9 downto 0);
--  signal LOGO_cnt2 : unsigned(9 downto 0);
  
  signal LATCH_LOGO_POS_X       : std_logic_vector(PIX_BITS-1 downto 0);
  signal LATCH_LOGO_POS_Y       : std_logic_vector(LIN_BITS-1 downto 0);
--  signal LATCH_LOGO_COLOR_INFO1 : std_logic_vector( 23 downto 0);
--  signal LATCH_LOGO_COLOR_INFO2 : std_logic_vector( 23 downto 0);
  signal LATCH_LOGO_COLOR_INFO1 : std_logic_vector(7 downto 0);
  signal LATCH_LOGO_COLOR_INFO2 : std_logic_vector(7 downto 0);
  
  signal line_cnt           : unsigned(LIN_BITS-1 downto 0);
  signal pix_cnt            : unsigned(PIX_BITS-1 downto 0);
  signal pix_cnt_d          : unsigned(PIX_BITS-1 downto 0);
  signal RD_LOGO_LIN_NO  : unsigned(LIN_BITS-1 downto 0);
  signal LOGO_ADD_DONE   : std_logic; 
  signal LOGO_POS_Y_TEMP : std_logic_Vector(LIN_BITS-1 downto 0); 
  signal LOGO_POS_Y_D    : std_logic_Vector(LIN_BITS-1 downto 0); 
    
  signal LOGO_XSIZE_OFFSET_R : std_logic_vector(PIX_BITS-1 downto 0);
  signal LOGO_XSIZE_OFFSET_L : std_logic_vector(PIX_BITS-1 downto 0);
  signal LOGO_YSIZE_OFFSET   : std_logic_vector(LIN_BITS-1 downto 0);
  signal LOGO_PIX_OFFSET     : std_logic_vector(2 downto 0);
  signal LOGO_PIX_OFFSET_D   : std_logic_vector(2 downto 0);
  signal LOGO_RD_DONE        : std_logic;
  signal LOGO_YSIZE_OFFSET_D : std_logic_vector(LIN_BITS-1 downto 0); 
  signal LOGO_POS_Y_TEMP_D   : std_logic_vector(LIN_BITS-1 downto 0); 
  signal out_line_cnt           : unsigned(LIN_BITS-1 downto 0);

--  signal VIDEO_IN_DATA_DD : std_logic_vector(23 downto 0);
--  signal VIDEO_IN_DATA_D  : std_logic_vector(23 downto 0);
  signal VIDEO_IN_DATA_DD : std_logic_vector(7 downto 0);
  signal VIDEO_IN_DATA_D  : std_logic_vector(7 downto 0);
  signal VIDEO_IN_DAV_DD  : std_logic;
  signal VIDEO_IN_DAV_D   : std_logic;
  
  signal LOGO_rd_addr        : std_logic_vector(10 downto 0);
  signal LOGO_wr_addr        : std_logic_vector(7 downto 0);
  signal LOGO_wr_addr_temp   : unsigned(7 downto 0);
  signal LOGO_rd_addr_temp   : std_logic_vector(10 downto 0);
  signal LOGO_rd_addr_base   : unsigned(20 downto 0);
  signal LOGO_rd_data        : std_logic_vector(1 downto 0);
  signal LOGO_addr           : std_logic_vector(7 downto 0);
  
  signal LOGO_rd_en          : std_logic;
  signal LOGO_wr_en          : std_logic_vector(0 downto 0);
  signal LOGO_wr_data        : std_logic_vector(15 downto 0);
  signal LOGO_TYPE_D         : std_logic_vector(3 downto 0);
  signal qspi_LOGO_change_rq : std_logic;
  signal qspi_LOGO_change_en : std_logic;
  
  type LOGO_transfer_st_t is (s_LOGO_IDLE,s_LOGO_transfer,s_LOGO_transfer1,s_LOGO_req_wait);
  signal LOGO_transfer_st   : LOGO_transfer_st_t;
  signal rd_wr_sel          : std_logic; 
  
  signal LOGO_WR_DATA_IN_TEMP : std_logic_vector(15 downto 0); 
   
  ATTRIBUTE KEEP : string;
  ATTRIBUTE KEEP of  line_cnt: SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  in_line_cnt: SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  out_line_cnt: SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  pix_cnt: SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  pix_cnt_d: SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  LOGO_XSIZE_OFFSET_L_D   : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  LOGO_XSIZE_OFFSET_R_D   : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  LATCH_LOGO_POS_X_D      : SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  LATCH_LOGO_POS_Y_D      : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LOGO_YSIZE_OFFSET_D     : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LOGO_POS_Y_TEMP_D       : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LOGO_XSIZE_OFFSET_L     : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LOGO_XSIZE_OFFSET_R     : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LATCH_LOGO_POS_X        : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LATCH_LOGO_POS_Y        : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LOGO_YSIZE_OFFSET       : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LOGO_POS_Y_TEMP         : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  RD_LOGO_LIN_NO          : SIGNAL IS "TRUE";  
  ATTRIBUTE KEEP of  LOGO_POS_X              : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP of  LOGO_POS_Y              : SIGNAL IS "TRUE";

--------
begin


--DMA_RDFSM_check <=  "000" when DMA_RDFSM = s_IDLE else
--                    "001" when DMA_RDFSM = s_WAIT_H else
--                    "010" when DMA_RDFSM = s_GET_ADDR else
--                    "011" when DMA_RDFSM = s_READ else
--                    "111";
  
  
  process(CLK, RST)
  begin
    if RST = '1' then
      LOGO_RDFSM             <= s_IDLE;
      LATCH_LOGO_COLOR_INFO1 <= x"EB";--x"EB8080";
      LATCH_LOGO_COLOR_INFO2 <= x"52";--x"52F05A"; 
      LATCH_LOGO_POS_X       <= (others => '0');
      LATCH_LOGO_POS_Y       <= (others => '0');
      line_cnt               <= (others => '0');
      RD_LOGO_LIN_NO         <= (others => '0');
      LOGO_POS_Y_TEMP        <= (others => '0');
      LOGO_YSIZE_OFFSET      <= (others => '0');
      LOGO_XSIZE_OFFSET_R    <= (others =>'0');
      LOGO_XSIZE_OFFSET_L    <= (others =>'0');
      LOGO_POS_Y_D           <= (others => '0');
      LOGO_RD_DONE           <= '0';
      LOGO_POS_X_OUT         <= std_logic_vector(to_unsigned(45,LOGO_POS_X'length));
      LOGO_POS_Y_OUT         <= std_logic_vector(to_unsigned(551,LOGO_POS_Y'length));
      LOGO_rd_addr_base      <= (others => '0');
      LOGO_EN_D              <= '0';
      LOGO_TYPE_D            <= (others => '0');
--      LOGO_sel               <= (others => '0');      
      qspi_LOGO_change_en    <= '0';
      
--      LOGO_PIX_OFFSET_L <= (others =>'0');

    elsif rising_edge(CLK) then

      qspi_LOGO_change_en <= '0';
       
      case LOGO_RDFSM is         

        when s_IDLE =>  
            line_cnt <= (others => '0');
            if LOGO_EN_D ='1' then
             LOGO_RDFSM <= s_WAIT_H;
            end if; 
            
        when s_WAIT_H =>
            if LOGO_REQ_H = '1' then
              line_cnt <= line_cnt + 1;
              if(line_cnt >= unsigned(LATCH_LOGO_POS_Y(LIN_BITS-1 downto 0)) and  (line_cnt < (unsigned(LOGO_REQ_YSIZE(LIN_BITS-1 downto  0)) + unsigned(LATCH_LOGO_POS_Y(LIN_BITS-1 downto 0)) - unsigned(LOGO_YSIZE_OFFSET)))) then
                RD_LOGO_LIN_NO    <= RD_LOGO_LIN_NO + 1;
                LOGO_rd_addr_base <= (unsigned(LOGO_REQ_XSIZE(PIX_BITS-1 downto 0)))*RD_LOGO_LIN_NO +  unsigned("0" &LOGO_XSIZE_OFFSET_L(PIX_BITS-1 downto 0));
              end if;  
              LOGO_RDFSM <= s_WAIT_H;
            end if;
        end case;


      if LOGO_REQ_V = '1' then
        LOGO_RDFSM <= s_IDLE; 
        if(LOGO_FIELD = '0')then                        
--             LOGO_TYPE_D <= LOGO_TYPE;
--             if(LOGO_TYPE_D/= LOGO_TYPE) then
--                LOGO_sel            <= LOGO_TYPE;
--                LOGO_EN_D           <= '0';
--                qspi_LOGO_change_en <= '1';
                
--             else
--                LOGO_EN_D           <= LOGO_EN;
--             end if;                                               
             LOGO_EN_D           <= LOGO_EN;
             LATCH_LOGO_COLOR_INFO1 <= LOGO_COLOR_INFO1;
             LATCH_LOGO_COLOR_INFO2 <= LOGO_COLOR_INFO2;
             LOGO_POS_Y_D           <= LOGO_POS_Y;
             
            if(unsigned(LOGO_POS_X) < (unsigned(VIDEO_IN_XSIZE) - unsigned(LOGO_REQ_XSIZE(PIX_BITS-1 downto 1))))then
              if(unsigned(LOGO_POS_X) <  unsigned(LOGO_REQ_XSIZE(PIX_BITS-1 downto 1))) then
                LATCH_LOGO_POS_X    <= std_logic_vector(to_unsigned(0,LATCH_LOGO_POS_X'length));
                LOGO_XSIZE_OFFSET_L <= std_logic_vector((unsigned('0' & LOGO_REQ_XSIZE(PIX_BITS-1 downto 1)) - unsigned(LOGO_POS_X))- to_unsigned(1,LOGO_XSIZE_OFFSET_L'length));
              else
                LATCH_LOGO_POS_X    <= std_logic_vector((unsigned(LOGO_POS_X) - unsigned('0' & LOGO_REQ_XSIZE(PIX_BITS-1 downto 1))) + to_unsigned(1,LATCH_LOGO_POS_X'length));
                LOGO_XSIZE_OFFSET_L <= (others=>'0');
              end if;   
              LOGO_XSIZE_OFFSET_R <= (others=>'0');
              LOGO_POS_X_OUT      <= LOGO_POS_X;
            else 
               if(unsigned(LOGO_POS_X) < unsigned(VIDEO_IN_XSIZE)) then
                LATCH_LOGO_POS_X    <= std_logic_vector((unsigned(LOGO_POS_X) - unsigned('0' & LOGO_REQ_XSIZE(PIX_BITS-1 downto 1))) + to_unsigned(1,LATCH_LOGO_POS_X'length));
                LOGO_XSIZE_OFFSET_R <= std_logic_vector((unsigned(LOGO_POS_X) + unsigned('0' & LOGO_REQ_XSIZE(PIX_BITS-1 downto 1)) + to_unsigned(1,LOGO_XSIZE_OFFSET_R'length)) -unsigned(VIDEO_IN_XSIZE));
                LOGO_POS_X_OUT      <= LOGO_POS_X;
               else
                LATCH_LOGO_POS_X    <= std_logic_vector(unsigned(VIDEO_IN_XSIZE) - unsigned('0' & LOGO_REQ_XSIZE(PIX_BITS-1 downto 1)));-- - to_unsigned(1,LATCH_LOGO_POS_X'length));
                LOGO_XSIZE_OFFSET_R <= std_logic_vector(unsigned('0' & LOGO_REQ_XSIZE(PIX_BITS-1 downto 1)));
                LOGO_POS_X_OUT      <= std_logic_vector(unsigned(VIDEO_IN_XSIZE) - to_unsigned(1,LOGO_POS_X_OUT'length));
               end if; 
               LOGO_XSIZE_OFFSET_L  <= (others=>'0'); 
            end if;


            if(unsigned(LOGO_POS_Y)< (unsigned(VIDEO_IN_YSIZE) - unsigned(LOGO_REQ_YSIZE(LIN_BITS-1 downto 1))))then  
                if(unsigned(LOGO_POS_Y)<unsigned(LOGO_REQ_YSIZE(LIN_BITS-1 downto 1)))then
                     LOGO_YSIZE_OFFSET  <= std_logic_vector(unsigned("0" & LOGO_REQ_YSIZE(LIN_BITS-1 downto 1)) - unsigned(LOGO_POS_Y(LIN_BITS-1 downto 0))- to_unsigned(1,LOGO_YSIZE_OFFSET'length));
                     RD_LOGO_LIN_NO     <= ('0' &unsigned(LOGO_REQ_YSIZE(LIN_BITS-1 downto 1)) - to_unsigned(1,RD_LOGO_LIN_NO'length)) - unsigned( LOGO_POS_Y) ;  
                     LOGO_POS_Y_TEMP    <= std_logic_vector(to_unsigned(0,LATCH_LOGO_POS_Y'length));
                     LATCH_LOGO_POS_Y   <= std_logic_vector(to_unsigned(0,LATCH_LOGO_POS_Y'length));
                     
                else    
                     LATCH_LOGO_POS_Y <= std_logic_vector(unsigned(LOGO_POS_Y) - unsigned('0' &LOGO_REQ_YSIZE(LIN_BITS-1 downto 1))+ to_unsigned(1,LATCH_LOGO_POS_Y'length));
                     RD_LOGO_LIN_NO   <= to_unsigned(0,RD_LOGO_LIN_NO'length);
                     LOGO_YSIZE_OFFSET <= (others=>'0');
                     LOGO_POS_Y_TEMP   <= std_logic_vector(unsigned(LOGO_POS_Y) - unsigned('0' &LOGO_REQ_YSIZE(LIN_BITS-1 downto 1)) + to_unsigned(1,LATCH_LOGO_POS_Y'length));
                end if;  
                LOGO_POS_Y_OUT        <= LOGO_POS_Y;  
                
            else
                if(LOGO_POS_Y < VIDEO_IN_YSIZE)then
                    LATCH_LOGO_POS_Y  <= std_logic_vector(unsigned(LOGO_POS_Y) - unsigned('0' &LOGO_REQ_YSIZE(LIN_BITS-1 downto 1))+ to_unsigned(1,LATCH_LOGO_POS_Y'length));
                    RD_LOGO_LIN_NO    <= to_unsigned(0,RD_LOGO_LIN_NO'length);
                    LOGO_YSIZE_OFFSET <= std_logic_vector(unsigned(LOGO_POS_Y(LIN_BITS-1 downto 0)) -  (unsigned(VIDEO_IN_YSIZE(LIN_BITS-1 downto 0)) - unsigned('0' &LOGO_REQ_YSIZE(LIN_BITS-1 downto 1))) + to_unsigned(1,LATCH_LOGO_POS_Y'length));    -- NEW ADD                  
                    LOGO_POS_Y_OUT   <= LOGO_POS_Y;  
                else
                    LATCH_LOGO_POS_Y  <= std_logic_vector(unsigned(VIDEO_IN_YSIZE) - unsigned('0' &LOGO_REQ_YSIZE(LIN_BITS-1 downto 1)));
                    RD_LOGO_LIN_NO    <= to_unsigned(0,RD_LOGO_LIN_NO'length);
                    LOGO_YSIZE_OFFSET <= std_logic_vector(unsigned("0" & LOGO_REQ_YSIZE(LIN_BITS-1 downto 1)));-- - to_unsigned(1,LOGO_YSIZE_OFFSET'length));
                    LOGO_POS_Y_OUT    <= std_logic_vector(unsigned(VIDEO_IN_YSIZE) - to_unsigned(1,LOGO_POS_Y_OUT'length));  
                end if;    

            end if;  
          
       else
           LOGO_EN_D              <= LOGO_EN_D;
           LATCH_LOGO_COLOR_INFO1 <= LATCH_LOGO_COLOR_INFO1;
           LATCH_LOGO_COLOR_INFO2 <= LATCH_LOGO_COLOR_INFO2;
           LATCH_LOGO_POS_X       <= LATCH_LOGO_POS_X;  
           LOGO_XSIZE_OFFSET_R    <= LOGO_XSIZE_OFFSET_R;
           LOGO_XSIZE_OFFSET_L    <= LOGO_XSIZE_OFFSET_L;    
       end if;    
     end if;

   end if;
 end process;



 process(CLK, RST)
   begin
     if RST = '1' then
        LOGO_wr_addr        <= (others=>'0');
        LOGO_wr_addr_temp   <= (others=>'0');
        LOGO_wr_data        <= (others=>'0');
        LOGO_wr_en          <= "0";
        LOGO_rd_en          <= '0';
        rd_wr_sel           <= '0';
        qspi_LOGO_change_rq <= '0';
        LOGO_transfer_st    <= s_LOGO_idle;
     elsif rising_edge(CLK) then
--        qspi_LOGO_transfer_rq <= '0';

--        if(qspi_LOGO_change_en = '1')then
--            qspi_LOGO_change_rq <= '1';  
--        end if; 
        LOGO_wr_en        <= "0";
        case LOGO_transfer_st is
            
            when s_LOGO_idle =>
                LOGO_transfer_st  <= s_LOGO_transfer;
                LOGO_wr_en        <= "0";
                LOGO_wr_addr_temp <= (others=>'0');
                rd_wr_sel            <= '0';
                
            when s_LOGO_transfer =>
                    rd_wr_sel <= '0';
                    if(LOGO_wr_addr_temp = to_unsigned(LOGO_INIT_MEMORY_WR_SIZE,LOGO_wr_addr_temp'length))then
                        LOGO_wr_en        <= "0";
                        LOGO_wr_addr_temp <= (others=>'0');
                        LOGO_transfer_st  <= s_LOGO_req_wait;
                    else                    
                        if(LOGO_WR_EN_IN = "1")then
                            LOGO_WR_DATA_IN_TEMP <= LOGO_WR_DATA_IN(31 downto 16);
                            LOGO_wr_data         <= LOGO_WR_DATA_IN(15 downto 0);
                            LOGO_wr_en           <= "1";
                            LOGO_wr_addr         <= std_logic_Vector(LOGO_wr_addr_temp);
                            LOGO_wr_addr_temp    <= LOGO_wr_addr_temp +1; 
                            LOGO_transfer_st     <= s_LOGO_transfer1;
                        else
                            LOGO_wr_en        <= "0";
                        end if;    
                    end if;
             when s_LOGO_transfer1 =>
                            LOGO_wr_data         <= LOGO_WR_DATA_IN_TEMP(15 downto 0);
                            LOGO_wr_en           <= "1";
                            LOGO_wr_addr         <= std_logic_Vector(LOGO_wr_addr_temp);
                            LOGO_wr_addr_temp    <= LOGO_wr_addr_temp +1;
                            LOGO_transfer_st     <= s_LOGO_transfer;                           
            
             when s_LOGO_req_wait =>
                    rd_wr_sel         <= '1';
                    LOGO_rd_en        <= '1';
                    LOGO_wr_en        <= "0";
                    LOGO_wr_addr_temp <= (others=>'0');  
                    LOGO_transfer_st  <= s_LOGO_req_wait;            
--                    if(qspi_LOGO_change_rq='1' and qspi_LOGO_transfer_done='1')then
--                        LOGO_transfer_st      <= s_LOGO_transfer;
--                        qspi_LOGO_transfer_rq <= '1';
--                        qspi_LOGO_change_rq   <= '0';
--                    else
--                        LOGO_transfer_st  <= s_LOGO_req_wait;
--                    end if; 
        end case;     
     end if;
 end process;

--LOGO_addr <=  LOGO_wr_addr when  rd_wr_sel = '0' else LOGO_rd_addr;
--LOGO_addr <=  LOGO_rd_addr;
 
 
i_LOGO_INIT_MEMORY : LOGO_INIT_MEMORY
  PORT MAP (
    clka  => CLK,
    wea   => LOGO_wr_en,
    addra => LOGO_wr_addr,
    dina  => LOGO_wr_data,
    clkb  => CLK,
    enb   => LOGO_rd_en,
    addrb => LOGO_rd_addr,
    doutb => LOGO_rd_data
  ); 
 
--i_LOGO_INIT_MEMORY : LOGO_INIT_MEMORY
--  PORT MAP (
--    clka  => CLK,
--    wea   => LOGO_wr_en,
--    addra => LOGO_addr,
--    dina  => LOGO_wr_data,
--    douta => LOGO_rd_data
--  );



 
      
 process(CLK, RST)
   begin
     if RST = '1' then
       LOGO_V            <= '0';
       LOGO_V_D          <= '0';
       LOGO_DAVi         <= '0';
       LOGO_DATA         <= (others => '0');
       LOGO_H            <= '0';
       LOGO_H_D          <= '0';
       LOGO_EOI          <= '0';
       LOGO_EOI_D        <= '0';
       first_time_rd_rq     <= '1'; 
       FIFO_RD1_CNT         <= (others => '0'); 
       FIFO_RD1_CNT_D       <= (others => '0'); 
       pix_cnt              <= (others => '0');
       pix_cnt_d            <= (others => '0');
       LOGO_ADD_DONE     <= '0';
       LOGO_PIX_OFFSET   <= (others => '0');
       LOGO_PIX_OFFSET_D <= (others => '0');
       out_line_cnt         <= (others => '0');
       VIDEO_IN_DATA_DD     <= (others => '0');
       VIDEO_IN_DATA_D      <= (others => '0');
       VIDEO_IN_DAV_DD      <= '0';
       VIDEO_IN_DAV_D       <= '0';
       LOGO_rd_addr      <= (others => '0');
       LOGO_rd_addr_temp <= (others => '0');
     elsif rising_edge(CLK) then
     
     if LOGO_EN_D ='1' then
           LOGO_V      <= LOGO_V_D;
           LOGO_H      <= LOGO_H_D;
           LOGO_V_D    <= '0'; 
           LOGO_H_D    <= '0';
           LOGO_EOI_D  <= VIDEO_IN_EOI;
           LOGO_EOI    <= LOGO_EOI_D;
           LOGO_DAVi   <= '0';
           FIFO_RD1_CNT_D <= FIFO_RD1_CNT;
           pix_cnt_d      <= pix_cnt;
           LOGO_PIX_OFFSET_D <= LOGO_PIX_OFFSET;
           VIDEO_IN_DAV_D <= VIDEO_IN_DAV;
           VIDEO_IN_DAV_DD <= VIDEO_IN_DAV_D;
           
           VIDEO_IN_DATA_D <= VIDEO_IN_DATA;
           VIDEO_IN_DATA_DD <= VIDEO_IN_DATA_D;
           

           
           if VIDEO_IN_V = '1' then
             LOGO_V_D     <= '1'; 
             out_line_cnt    <= (others => '0');
           end if;
     
           if VIDEO_IN_H = '1' then
             LOGO_H_D <= '1';  
             first_time_rd_rq <= '1'; 
             FIFO_RD1_CNT <=(others => '0');   
             pix_cnt   <= (others => '0');
             LOGO_ADD_DONE <= '0';
             out_line_cnt     <= out_line_cnt   +1;
             LOGO_rd_addr_temp  <= std_logic_vector(LOGO_rd_addr_base(10 downto 0));
                        
             LOGO_PIX_OFFSET <= LOGO_XSIZE_OFFSET_L(2 downto 0);
             
           end if;
          
          
 
          if ((out_line_cnt-1) >= unsigned(LATCH_LOGO_POS_Y(LIN_BITS-1 downto 0))) and  ((out_line_cnt-1) < (unsigned(LOGO_REQ_YSIZE(LIN_BITS-1 downto  0)) + unsigned(LATCH_LOGO_POS_Y(LIN_BITS-1 downto 0)) - unsigned(LOGO_YSIZE_OFFSET))) then                         
           if(VIDEO_IN_DAV = '1')then
                pix_cnt  <= pix_cnt + 1;
                if((pix_cnt>= unsigned(LATCH_LOGO_POS_X)) and (pix_cnt < (((unsigned(LOGO_REQ_XSIZE)) + unsigned(LATCH_LOGO_POS_X))- unsigned(LOGO_XSIZE_OFFSET_L))))then
                    LOGO_rd_addr      <= LOGO_rd_addr_temp;
                    LOGO_rd_addr_temp <= std_logic_vector(unsigned(LOGO_rd_addr_temp) + 1);                
                end if;
                
           end if;
           
          
           if VIDEO_IN_DAV_DD = '1'then
                if(((pix_cnt_d-1)>= (unsigned(LATCH_LOGO_POS_X))) and ((pix_cnt_d-1) < ((unsigned(LOGO_REQ_XSIZE) + unsigned(LATCH_LOGO_POS_X)) - (unsigned(LOGO_XSIZE_OFFSET_R) +unsigned(LOGO_XSIZE_OFFSET_L)))))then
                     LOGO_DAVi <= '1';  
 
                     if(LOGO_rd_data(1)='1')then
                          
                          if(LOGO_rd_data(0) = '1')then
--                             LOGO_DATA <= LATCH_LOGO_COLOR_INFO1(23 downto 0);
                             LOGO_DATA <= LATCH_LOGO_COLOR_INFO1(7 downto 0);
 --                            LOGO_cnt1 <= LOGO_cnt1 + 1;
                          else
--                             LOGO_DATA <= LATCH_LOGO_COLOR_INFO2(23 downto 0);
                             LOGO_DATA <= LATCH_LOGO_COLOR_INFO2(7 downto 0);
 --                            LOGO_cnt2 <= LOGO_cnt2 + 1;
                          end if;   
                     else 
                         LOGO_DATA <= VIDEO_IN_DATA_DD;
                     end if;
               else
                     LOGO_DAVi <= '1';         
                     LOGO_DATA <= VIDEO_IN_DATA_DD;
               end if; 
           end if; 
             
          else
             if(VIDEO_IN_DAV_DD = '1')then
                   LOGO_DAVi <= '1';    
                   LOGO_DATA <=VIDEO_IN_DATA_DD;
             end if;       
              
          end if;
     
     else
         LOGO_V    <=  VIDEO_IN_V; 
         LOGO_H    <=  VIDEO_IN_H ;
         LOGO_DAVi <=  VIDEO_IN_DAV;
         LOGO_DATA <=  VIDEO_IN_DATA;
         LOGO_EOI  <=  VIDEO_IN_EOI;
         
         LOGO_H_D <= '0';  
         LOGO_V_D <= '0';
         LOGO_EOI_D    <= '0';

         first_time_rd_rq <= '1'; 
         FIFO_RD1_CNT   <= (others=>'0');
         FIFO_RD1_CNT_D <= (others=>'0');
 
     end if;  
       
    end if;
     
   end process;

  LOGO_DAV   <= LOGO_DAVi;



--------------------------
end architecture RTL;
--------------------------