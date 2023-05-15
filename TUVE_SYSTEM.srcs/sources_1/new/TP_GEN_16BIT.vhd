----------------------------------------------------------------
-- Copyright    : ALSE - http://alse-fr.com
-- Contact      : info@alse-fr.com
-- Project Name : Tonboimaging - Thermal Camera Project
-- Block Name   : TP_GEN_16BIT
-- Description  : Video In Pattern Generator 
-- Author       : E.LAURENDEAU
-- Date         : 30/12/2013
----------------------------------------------------------------


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-----------------------------
entity TP_GEN_16BIT is
-----------------------------
  generic (         
    REQ_XSIZE  : positive range 16 to 2095:=384; -- Required Output Horizontal Size 
    REQ_YSIZE  : positive range 16 to 2095:=288; -- Required Output   Vertical Size
    TVS        : positive := 2;   -- VSYNC PULSE WIDTH          : 2 HYNC PERIOD
    TAVS       : positive := 5;   -- TIME TO ACTIVE VIDEO START : 5 HYNC PERIOD
    TAV        : positive := 600; -- ACTIVE VIDEO               : 600 HYNC PERIOD
    TVIDL      : positive := 2;   -- FRAME  BLANKING            : 2 HYNC PERIOD
    THS        : positive := 8;   -- HSYNC PULSE WIDTH          : 8 SCLK
    TDES       : positive := 12;  -- TIME TO DATA ENABLE START  : 12 SCLK
    TLDATA     : positive := 800; -- TOTAL DATA                 : 800 SCLK
    THIDL      : positive := 12 ;  -- LINE OVERSCAN              : 12 SCLK
    PIX_BITS   : positive := 10;
    LIN_BITS   : positive := 10
  );
  port (
    clk           : in  std_logic;                     -- module clock
    rst           : in  std_logic;                     -- module reset (asynch active high)
    tick1ms       : in  std_logic;
    sel_color_tp  : in  std_logic; 
    video_i_v     : in  std_logic; 
    video_i_h     : in  std_logic; 
    video_i_dav   : in  std_logic; 
    video_i_data  : in  std_logic_vector(15 downto 0); 
    video_i_eoi   : in  std_logic; 
    video_i_xsize : in  std_logic_vector(PIX_BITS-1 downto 0);     
    video_i_ysize : in  std_logic_vector(LIN_BITS-1 downto 0);     
    pclk          : in std_logic;

    video_o_vsync       : buffer std_logic;                     -- video vsync
    video_o_hsync       : buffer std_logic;                     -- video hysnc
    video_o_frame_valid : buffer std_logic;  -- high during full frmae   
    video_o_line_valid  : buffer std_logic;  -- high during full line 

    video_o_de    : buffer std_logic;                     -- video data enable (data valid)
    video_o_data  : buffer std_logic_vector(15 downto 0);   -- video pixel data
    pix_cnt_out   : out std_logic_vector(PIX_BITS-1 downto 0);
    line_cnt_out  : out std_logic_Vector(LIN_BITS-1 downto 0);
    fifo_usedw    : out std_logic_Vector(14 downto 0)
  ); 
------------------------------
end entity TP_GEN_16BIT;
------------------------------


------------------------------------------
architecture RTL of TP_GEN_16BIT is
------------------------------------------

COMPONENT TOII_TUVE_ila

PORT (
    clk : IN STD_LOGIC;



    probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

 signal probe0: std_logic_vector(127 downto 0);

 constant FIFO_DEPTH : positive := 15;
-- constant FIFO_DEPTH : positive := 12;
 constant FIFO_WIDTH : positive := 16;

  constant V_TOTAL_SIZE : positive := TAVS+TAV+TVIDL;
  constant H_TOTAL_SIZE : positive := TDES + TLDATA + THIDL;
  
  type video_fsm_t is ( s_idle, s_wait_fifo,s_frame_gen, s_ths, s_tdes, s_tldata,s_thidl);
  signal video_fsm     : video_fsm_t;

-- RGB to YUV Formulas are
  -- Y =  0.299*R + 0.587*G + 0.114*B
  -- U = -0.169*R - 0.331*G + 0.500*B + 128
  -- V =  0.500*R - 0.419*G - 0.081*B + 128
  function RGB2YUV (
    R : in integer range 0 to 255;
    G : in integer range 0 to 255;
    B : in integer range 0 to 255 ) return std_logic_vector is
    variable RES_Y     : real;
    variable RES_U     : real;
    variable RES_V     : real;
    variable RES_Y_slv : std_logic_vector(7 downto 0);
    variable RES_U_slv : std_logic_vector(7 downto 0);
    variable RES_V_slv : std_logic_vector(7 downto 0);
  begin
    RES_Y :=  0.299*real(R) +0.587*real(G) +0.114*real(B);
    RES_U := -0.169*real(R) -0.331*real(G) +0.500*real(B) +128.0;
    RES_V :=  0.500*real(R) -0.419*real(G) -0.081*real(B) +128.0;
    if RES_Y > 254.0 then
      RES_Y := 254.0;
    elsif RES_Y < 1.0 then
      RES_Y := 1.0;
    end if;
    if RES_U > 254.0 then
      RES_U := 254.0;
    elsif RES_U < 1.0 then
      RES_U := 1.0;
    end if;
    if RES_V > 254.0 then
      RES_V := 254.0;
    elsif RES_V < 1.0 then
      RES_V := 1.0;
    end if;
    RES_Y_slv := std_logic_vector(to_unsigned(integer(RES_Y),8));
    RES_U_slv := std_logic_vector(to_unsigned(integer(RES_U),8));
    RES_V_slv := std_logic_vector(to_unsigned(integer(RES_V),8));
    return RES_V_slv & RES_U_slv & RES_Y_slv;
  end function RGB2YUV;

  -- YCbCr values (assuming gamma corrected RGB with 0-255 range)
  -- Y on 07:00, Cb on 15:08, Cr on 23:16
  constant WHITE   : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>255,B=>255);
  constant YELLOW  : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>255,B=>000);
  constant CYAN    : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>255,B=>255);
  constant GREEN   : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>255,B=>000);
  constant MAGENTA : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>000,B=>255);
  constant RED     : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>000,B=>000);
  constant BLUE    : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>000,B=>255);
  constant BLACK   : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>000,B=>000);
  
  constant H_STRIP_NB   : positive := 16;
  
  type COLOR_TAB_t is array (0 to H_STRIP_NB-1) of std_logic_vector(23 downto 00);
  constant COLOR_TAB_FULL : COLOR_TAB_t :=
    ( 00=>WHITE, 01=>YELLOW, 02=>CYAN , 03=>GREEN , 04=>MAGENTA, 05=>RED, 06=>BLUE , 07=>BLACK,
      08=>WHITE, 09=>YELLOW, 10=>CYAN , 11=>GREEN , 12=>MAGENTA, 13=>RED, 14=>BLUE , 15=>BLACK );


  signal line_cnt : unsigned(LIN_BITS-1 downto 0);
  signal pix_cnt  : unsigned(PIX_BITS-1 downto 0);
  signal tp_value : unsigned(7 downto 0);
  signal tp_start_value : unsigned(7 downto 0);
  signal temp_cnt : unsigned(7 downto 0);
  signal COLOR_IDX : integer range 0 to H_STRIP_NB-1;
  signal flag : std_logic;
  
  type video_in_fsm_t is ( sc_idle, sc_req_v, sc_req_h, sc_wait_dav, sc_wait_fifo,sc_wait);
  signal video_in_fsm     : video_in_fsm_t;

  signal vxcount : unsigned(PIX_BITS-1 downto 0);
  signal vycount : unsigned(LIN_BITS-1 downto 0);
  signal latch_video_i_xsize     : std_logic_vector(PIX_BITS-1 downto 0);
  signal latch_video_i_ysize     : std_logic_vector(LIN_BITS-1 downto 0);
  signal out_latch_video_i_xsize : std_logic_vector(PIX_BITS-1 downto 0);
  signal out_latch_video_i_ysize : std_logic_vector(LIN_BITS-1 downto 0);
  signal data_wr_en : std_logic;
 
--  signal fifo_usedw : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal fifo_cnt   : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal fifo_clr   : std_logic;
  signal fifo_clr_rd: std_logic;
  signal fifo_afull : std_logic;
  signal fifo_aempty: std_logic;
  signal fifo_full  : std_logic;
  signal fifo_empty : std_logic;
  signal fifo_wr    : std_logic;
  signal fifo_rd    : std_logic;
  signal fifo_in    : std_logic_vector(FIFO_WIDTH-1 downto 0);
  signal fifo_out   : std_logic_vector(FIFO_WIDTH-1 downto 0);
  
  signal start_rd   : std_logic;
  signal y_offset   : unsigned(LIN_BITS-1 downto 0);
  
ATTRIBUTE MARK_DEBUG : string;
ATTRIBUTE MARK_DEBUG of video_in_fsm     : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of video_fsm        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of video_i_data     : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_in          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_out         : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_cnt         : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of line_cnt         : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of pix_cnt          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of vxcount          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of vycount          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of data_wr_en       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of start_rd         : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_clr         : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_clr_rd      : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_afull       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_aempty      : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_full        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_empty       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_wr          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of fifo_rd          : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of video_i_v        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of video_i_h        : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of video_i_dav      : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of video_i_eoi      : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of video_o_vsync       : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of video_o_hsync       : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of video_o_frame_valid : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of video_o_line_valid  : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of video_o_de          : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of video_o_data        : SIGNAL IS "TRUE";     
ATTRIBUTE MARK_DEBUG of y_offset            : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of latch_video_i_xsize     : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of latch_video_i_ysize     : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of out_latch_video_i_xsize : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of out_latch_video_i_ysize : SIGNAL IS "TRUE";   


-------
begin
-------
line_cnt_out <= std_logic_vector(line_cnt);
pix_cnt_out  <= std_logic_vector(pix_cnt) ;

  video_in_process : process(clk, rst)begin
   if rst = '1' then
     video_in_fsm        <= sc_idle;
     vycount             <= (others=>'0');
     vxcount             <= (others=>'0');
     fifo_clr            <= '1';
     data_wr_en          <= '1';
     latch_video_i_xsize <= (others=>'0'); 
     latch_video_i_ysize <= (others=>'0');
     start_rd            <= '0';     

   elsif rising_edge(clk) then
    fifo_clr <= '0';
    case video_in_fsm is
      when sc_idle =>
        video_in_fsm <= sc_req_v;
      
      when sc_req_v => 
       if(video_i_v = '1')then
            video_in_fsm        <= sc_wait;
            data_wr_en          <= '1';
            latch_video_i_xsize <= video_i_xsize;
            latch_video_i_ysize <= video_i_ysize;   
        else 
            video_in_fsm <= sc_req_v;
        end if;    
      
      when sc_wait =>
        start_rd   <= '1';
        if(video_i_h = '1')then
        video_in_fsm <= sc_wait_dav;
        vycount      <= vycount + 1;
        else
        video_in_fsm <= sc_wait;
        end if;  

      when sc_wait_dav =>
        if(video_i_dav='1')then           
          if(vxcount = unsigned(latch_video_i_xsize)-1)then
            vxcount <= (others=>'0'); 
            if(vycount = unsigned(latch_video_i_ysize))then
                data_wr_en <= '0';
            end if;    
            video_in_fsm <= sc_wait_fifo;
          else
            vxcount      <= vxcount + 1;
            video_in_fsm <= sc_wait_dav;
          end if;
         end if;
         
      when sc_wait_fifo =>         
        if(vycount = unsigned(latch_video_i_ysize))then
            vycount      <= (others=>'0'); 
            video_in_fsm <= sc_idle; 
        else 
            video_in_fsm <= sc_wait_dav; 
            vycount  <= vycount + 1;
        end if; 
      
      when others =>
                  
    end case;
   end if;
 end process;  
 
  
 VIDEO_IN_FIFO_DUAL_CLK  :entity work.FIFO_DUAL_CLK
 GENERIC MAP(
    FIFO_DEPTH => FIFO_DEPTH,
    FIFO_WIDTH => FIFO_WIDTH
    ) 
  PORT MAP (
    CLK_WR      => clk,         
    RST_WR      => rst,         
    CLR_WR      => fifo_clr,         
    WRREQ       => fifo_wr,          
    WRDATA      => fifo_in,         
    CLK_RD      => pclk,         
    RST_RD      => rst,         
    CLR_RD      => fifo_clr_rd,         
    RDREQ       => fifo_rd,          
    RDDATA      => fifo_out,         
    EMPTY_RD    => fifo_empty,       
    FIFO_CNT_RD => fifo_cnt    
    );
meta_harden_inst1 : entity work.META_HARDEN 
PORT MAP(
    CLK_DST     => pclk,
    RST_DST     => rst ,
    SIGNAL_SRC  => fifo_clr,
    SIGNAL_DST  => fifo_clr_rd
    );
meta_harden_inst2 : entity work.META_HARDEN_VECTOR 
GENERIC MAP(
 bit_width => FIFO_DEPTH
 ) 
 PORT MAP(
    CLK_DST     =>  clk,
    RST_DST     =>  rst,
    SIGNAL_SRC  =>  fifo_cnt,
    SIGNAL_DST  =>  fifo_usedw
    );

fifo_wr <= video_i_dav and data_wr_en;
fifo_in <= video_i_data;
 
 

--  video_gen_process : process(clk, rst)
  video_gen_process : process(pclk, rst)
  variable COLOR   : std_logic_vector(23 downto 0);
  begin
   if rst = '1' then
     video_fsm       <= s_idle;
     video_o_vsync   <= '0';
     video_o_hsync   <= '0';
     video_o_de      <= '0';
     video_o_data    <= (others=>'0');
     line_cnt        <= (others=>'0');
     pix_cnt         <= (others=>'0');
     tp_value        <= x"10";
     tp_start_value  <= x"10";--(others=>'0');
     temp_cnt        <= x"ff";
     flag            <= '0';
     video_o_frame_valid <= '0';
     video_o_line_valid  <= '0';
--   elsif rising_edge(clk) then
   elsif rising_edge(pclk) then
    
    if(tick1ms = '1')then
        tp_start_value <= tp_start_value +12; 
    end if;    
        
        
    case video_fsm is
      when s_idle =>
          out_latch_video_i_xsize <= latch_video_i_xsize;
          out_latch_video_i_ysize <= latch_video_i_ysize;
          y_offset                <= to_unsigned(TAV,y_offset'length)- unsigned(latch_video_i_ysize);
          if(start_rd = '1')then
--            if((unsigned(fifo_cnt)>unsigned('0'&latch_video_i_xsize &'0')-1))then
--                video_fsm <= s_wait_fifo;
--            end if;
            video_fsm <= s_frame_gen;
          end if;
      when s_wait_fifo => 
        if((unsigned(fifo_cnt)>unsigned(out_latch_video_i_xsize)-1)) then
            video_fsm <= s_frame_gen;
        end if;  
          
      when s_frame_gen =>
          video_fsm     <= s_ths;
          pix_cnt       <= (others=>'0');
          video_o_hsync <= '1';

          if(line_cnt >= TVS)then        
            video_o_vsync  <= '0';
          else
            video_o_vsync  <= '1';
            tp_value       <= tp_start_value;
            temp_cnt       <= x"ff";
            flag           <= '0';
            COLOR_IDX      <= 0;
          end if; 
          if(line_cnt <= (TAVS +TAV))then
            video_o_frame_valid <= '1'; 
      
          else
            video_o_frame_valid <= '0';
          end if;  
          

      when s_ths =>
          if(pix_cnt = THS-1)then
            video_o_hsync <= '0';
            video_fsm     <= s_tdes;
          else
            video_o_hsync <= '1';
            video_fsm     <= s_ths;
          end if;  
          pix_cnt      <= pix_cnt + 1;

      when s_tdes =>
          if(pix_cnt = TDES-2)then
            video_fsm  <= s_tldata;
          else
            video_fsm  <= s_tdes;
          end if;  
          pix_cnt    <= pix_cnt + 1;
          if(pix_cnt = TDES-2 or pix_cnt = TDES-3)then
            if(line_cnt >= TAVS and line_cnt < (TAVS +TAV)-(y_offset))then
                fifo_rd               <= '1';
            end if;
          end if;
      when s_tldata=>
          if(pix_cnt = TDES +TLDATA-1)then
            video_fsm  <= s_thidl;
            video_o_de <= '0';
            video_o_line_valid <= '0';
            fifo_rd            <= '0';
          else
            video_fsm  <= s_tldata;
            if(line_cnt >= TAVS and line_cnt < (TAVS +TAV))then
              
              
              video_o_de   <= '1';
              video_o_line_valid <= '1';
              
--              if(line_cnt >= TAVS+12 and line_cnt < (TAVS +TAV)-12)then
--              if(line_cnt >= TAVS+ ('0'&y_offset(LIN_BITS-1 downto 1)) and line_cnt < (TAVS +TAV)-('0'&y_offset(LIN_BITS-1 downto 1)))then
              if(line_cnt >= TAVS and line_cnt < (TAVS +TAV)-(y_offset))then
--                  if((pix_cnt >= TDES-1+41-2) and (pix_cnt < TDES-1+757-2))then
--                  if((pix_cnt >= TDES-1) and (pix_cnt < TDES-1+800-2))then
                  if((pix_cnt >= TDES-1) and (pix_cnt < TDES-1+960-2))then
--                  if((pix_cnt >= TDES-1) and (pix_cnt < TDES-1+1280-2))then
--                  if((pix_cnt >= TDES-1) and (pix_cnt < TDES-1+720-2))then
                    fifo_rd               <= '1';
                  else
                    fifo_rd               <= '0';
                  end if;
                  
--                  if((pix_cnt >= TDES-1+41) and (pix_cnt < TDES-1+757))then  
--                  if(pix_cnt = TDES-1 or pix_cnt = TDES or pix_cnt = TDES+1 or pix_cnt = TDES+2)then
                  if(pix_cnt = TDES +TLDATA-2)then
                    video_o_data <= x"80"&X"10"; 
                  else                    
                    video_o_data <= fifo_out(7 downto 0) &fifo_out(15 downto 8);
                  end if;
--                  video_o_data <= fifo_out(7 downto 0) &fifo_out(15 downto 8);
               else
                fifo_rd            <= '0';
--                video_o_de         <= '1';
--                video_o_line_valid <= '1';
                video_o_data <= x"80"&X"10";
                
               end if;   
                            
              
--              flag         <= not flag;
--             COLOR := COLOR_TAB_FULL(COLOR_IDX);
--             if(temp_cnt= x"27")then
                
--                tp_value    <= tp_value + x"0c";
--                temp_cnt    <= x"00";
--                COLOR_IDX   <= COLOR_IDX + 1;
--             else
--                temp_cnt    <= temp_cnt + 1;
--             end if;
--             if(sel_color_tp= '1')then
--                if(flag = '0')then
--                    video_o_data <= COLOR(23 downto 16) &COLOR(7 downto 0);
--                else
--                    video_o_data <= COLOR(15 downto 8) &COLOR(7 downto 0);
--                end if;    
--             else
--                video_o_data <= x"80" & std_logic_vector(tp_value);
--             end if;   

            else
              video_o_de   <= '0';
              video_o_line_valid <= '0';
              video_o_data <= (others=>'0');  
            end if; 
          end if;
          pix_cnt <= pix_cnt + 1;

      when s_thidl =>
          if(pix_cnt = H_TOTAL_SIZE-2)then
--              video_fsm <= s_frame_gen;
              if(line_cnt = V_TOTAL_SIZE-1)then
                line_cnt <= (others=>'0');
                video_fsm <= s_idle;  
              else
                line_cnt      <= line_cnt + 1;
----                video_fsm <= s_frame_gen;  
--                video_fsm <= s_wait_fifo;
--                if(line_cnt >= TAVS+('0'&y_offset(LIN_BITS-1 downto 1))-1 and line_cnt < (TAVS +TAV-('0'&y_offset(LIN_BITS-1 downto 1))-1))then
                if(line_cnt >= TAVS-1 and line_cnt < (TAVS +TAV-(y_offset)-1))then
                    video_fsm <= s_wait_fifo;
                else
                    video_fsm <= s_frame_gen;
                end if;
              end if;
              if(line_cnt >= TAVS and line_cnt < (TAVS +TAV))then
                 tp_value       <= tp_start_value;
                 temp_cnt    <= x"FF";
                 flag            <= '0';
                 COLOR_IDX      <= 0;
              end if;   
          else
            video_fsm <= s_thidl;
          end if;
            pix_cnt  <= pix_cnt + 1;
    end case;

   end if;
  end process video_gen_process;


--probe0(9 downto 0)   <= std_logic_vector(line_cnt);
--probe0(20 downto 10) <= std_logic_vector(pix_cnt);
--probe0(31 downto 21) <= std_logic_vector(vxcount);
--probe0(41 downto 32) <= std_logic_vector(vycount);
--probe0(42) <= data_wr_en;
--probe0(43) <= start_rd;
--probe0(44) <= fifo_clr;
--probe0(45) <= fifo_clr_rd;
--probe0(46) <= fifo_afull;
--probe0(47) <= fifo_aempty;
--probe0(48) <= fifo_full ;
--probe0(49) <= fifo_empty ;
--probe0(50) <= fifo_wr ;
--probe0(51) <= fifo_rd ;
--probe0(52) <= video_i_v  ;
--probe0(53) <= video_i_h  ;
--probe0(54) <= video_i_dav ;
--probe0(55) <= video_i_eoi  ;
--probe0(71 downto 56)   <= video_o_data;--video_i_data;
--probe0(87 downto 72)   <= video_i_data;--fifo_in; 
--probe0(103 downto 88)  <= fifo_out;
--probe0(114 downto 104) <= (others=>'0');
--probe0(117 downto 115) <= std_logic_vector(to_unsigned(video_in_fsm_t'POS(video_in_fsm), 3));
--probe0(120 downto 118) <= std_logic_vector(to_unsigned(video_fsm_t'POS(video_fsm), 3));
--probe0(121)            <= video_o_vsync ;     
--probe0(122)            <= video_o_hsync;      
--probe0(123)            <= video_o_frame_valid;
--probe0(124)            <= video_o_line_valid; 
--probe0(125)            <= video_o_de;  
----probe0(135 downto 126) <= std_logic_vector(y_offset)      ;
----probe0(145 downto 136) <= latch_video_i_xsize      ;
----probe0(155 downto 146) <= latch_video_i_ysize      ;
----probe0(165 downto 156) <= out_latch_video_i_xsize  ;
----probe0(175 downto 166) <= out_latch_video_i_ysize  ;
--probe0(127 downto 126) <= (others=>'0');
----probe0(190 downto 176) <=fifo_cnt;
----probe0(200 downto 191) <= (others=>'0');


-- i_TP_GEN_16BIT: TOII_TUVE_ila
--  PORT MAP (
--      clk => CLK,
--      probe0 => probe0
--  );

----------------------------
end architecture RTL;
----------------------------

--------------------------------------------------------------------
------ Copyright    : ALSE - http://alse-fr.com
------ Contact      : info@alse-fr.com
------ Project Name : Tonboimaging - Thermal Camera Project
------ Block Name   : TP_GEN_16BIT
------ Description  : Video In Pattern Generator 
------ Author       : E.LAURENDEAU
------ Date         : 30/12/2013
--------------------------------------------------------------------


----library IEEE;
----  use IEEE.std_logic_1164.all;
----  use IEEE.numeric_std.all;

---------------------------------
----entity TP_GEN_16BIT is
---------------------------------
----  generic (         
----    REQ_XSIZE  : positive range 16 to 2095:=384;--positive range 16 to 1023:=384; -- Required Output Horizontal Size 
----    REQ_YSIZE  : positive range 16 to 1023:=288; -- Required Output   Vertical Size
----    TVS        : positive := 2;   -- VSYNC PULSE WIDTH          : 2 HYNC PERIOD
----    TAVS       : positive := 5;   -- TIME TO ACTIVE VIDEO START : 5 HYNC PERIOD
----    TAV        : positive := 600; -- ACTIVE VIDEO               : 600 HYNC PERIOD
----    TVIDL      : positive := 2;   -- FRAME  BLANKING            : 2 HYNC PERIOD
----    THS        : positive := 8;   -- HSYNC PULSE WIDTH          : 8 SCLK
----    TDES       : positive := 12;  -- TIME TO DATA ENABLE START  : 12 SCLK
----    TLDATA     : positive := 800; -- TOTAL DATA                 : 800 SCLK
----    THIDL      : positive := 12 ;  -- LINE OVERSCAN              : 12 SCLK
----    PIX_BITS   : positive := 10;
----    LIN_BITS   : positive := 10
----  );
----  port (
----    clk           : in  std_logic;                     -- module clock
----    rst           : in  std_logic;                     -- module reset (asynch active high)
----    tick1ms       : in  std_logic;
----    sel_color_tp  : in  std_logic; 
------    video_o_xsize : out std_logic_vector(PIX_BITS-1 downto 0);  -- video x size
------    video_o_ysize : out std_logic_vector(LIN_BITS-1 downto 0);  -- video y size
----    video_o_vsync : out std_logic;                     -- video vsync
----    video_o_hsync : out std_logic;                     -- video hysnc
----    video_o_frame_valid : out std_logic;  -- high during full frmae   
----    video_o_line_valid  : out std_logic;  -- high during full line 

----    video_o_de    : out std_logic;                     -- video data enable (data valid)
----    video_o_data  : out std_logic_vector(15 downto 0);   -- video pixel data
----    pix_cnt_out   : out std_logic_vector(PIX_BITS-1 downto 0);
----    line_cnt_out  : out std_logic_Vector(LIN_BITS-1 downto 0)
----  );
----------------------------------
----end entity TP_GEN_16BIT;
----------------------------------


----------------------------------------------
----architecture RTL of TP_GEN_16BIT is
----------------------------------------------

----  constant V_TOTAL_SIZE : positive := TAVS+TAV+TVIDL;
----  constant H_TOTAL_SIZE : positive := TDES + TLDATA + THIDL;
  
----  type video_fsm_t is ( s_idle, s_frame_gen, s_ths, s_tdes, s_tldata,s_thidl);
----  signal video_fsm     : video_fsm_t;

------ RGB to YUV Formulas are
----  -- Y =  0.299*R + 0.587*G + 0.114*B
----  -- U = -0.169*R - 0.331*G + 0.500*B + 128
----  -- V =  0.500*R - 0.419*G - 0.081*B + 128
----  function RGB2YUV (
----    R : in integer range 0 to 255;
----    G : in integer range 0 to 255;
----    B : in integer range 0 to 255 ) return std_logic_vector is
----    variable RES_Y     : real;
----    variable RES_U     : real;
----    variable RES_V     : real;
----    variable RES_Y_slv : std_logic_vector(7 downto 0);
----    variable RES_U_slv : std_logic_vector(7 downto 0);
----    variable RES_V_slv : std_logic_vector(7 downto 0);
----  begin
----    RES_Y :=  0.299*real(R) +0.587*real(G) +0.114*real(B);
----    RES_U := -0.169*real(R) -0.331*real(G) +0.500*real(B) +128.0;
----    RES_V :=  0.500*real(R) -0.419*real(G) -0.081*real(B) +128.0;
----    if RES_Y > 254.0 then
----      RES_Y := 254.0;
----    elsif RES_Y < 1.0 then
----      RES_Y := 1.0;
----    end if;
----    if RES_U > 254.0 then
----      RES_U := 254.0;
----    elsif RES_U < 1.0 then
----      RES_U := 1.0;
----    end if;
----    if RES_V > 254.0 then
----      RES_V := 254.0;
----    elsif RES_V < 1.0 then
----      RES_V := 1.0;
----    end if;
----    RES_Y_slv := std_logic_vector(to_unsigned(integer(RES_Y),8));
----    RES_U_slv := std_logic_vector(to_unsigned(integer(RES_U),8));
----    RES_V_slv := std_logic_vector(to_unsigned(integer(RES_V),8));
----    return RES_V_slv & RES_U_slv & RES_Y_slv;
----  end function RGB2YUV;

----  -- YCbCr values (assuming gamma corrected RGB with 0-255 range)
----  -- Y on 07:00, Cb on 15:08, Cr on 23:16
----  constant WHITE   : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>255,B=>255);
----  constant YELLOW  : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>255,B=>000);
----  constant CYAN    : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>255,B=>255);
----  constant GREEN   : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>255,B=>000);
----  constant MAGENTA : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>000,B=>255);
----  constant RED     : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>000,B=>000);
----  constant BLUE    : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>000,B=>255);
----  constant BLACK   : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>000,B=>000);
  
----  constant H_STRIP_NB   : positive := 16;
  
----  type COLOR_TAB_t is array (0 to H_STRIP_NB-1) of std_logic_vector(23 downto 00);
----  constant COLOR_TAB_FULL : COLOR_TAB_t :=
----    ( 00=>WHITE, 01=>YELLOW, 02=>CYAN , 03=>GREEN , 04=>MAGENTA, 05=>RED, 06=>BLUE , 07=>BLACK,
----      08=>WHITE, 09=>YELLOW, 10=>CYAN , 11=>GREEN , 12=>MAGENTA, 13=>RED, 14=>BLUE , 15=>BLACK );


----  signal line_cnt : unsigned(LIN_BITS-1 downto 0);
----  signal pix_cnt  : unsigned(PIX_BITS-1 downto 0);
----  signal tp_value : unsigned(7 downto 0);
----  signal tp_start_value : unsigned(7 downto 0);
----  signal temp_cnt : unsigned(7 downto 0);
----  signal COLOR_IDX : integer range 0 to H_STRIP_NB-1;
----  signal flag : std_logic;
-----------
----begin
-----------
----line_cnt_out <= std_logic_vector(line_cnt);
----pix_cnt_out  <= std_logic_vector(pix_cnt) ;
----  video_gen_process : process(clk, rst)
----  variable COLOR   : std_logic_vector(23 downto 0);
----  begin
----   if rst = '1' then
----     video_fsm       <= s_idle;
----     video_o_vsync   <= '0';
----     video_o_hsync   <= '0';
----     video_o_de      <= '0';
----     video_o_data    <= (others=>'0');
----     line_cnt        <= (others=>'0');
----     pix_cnt         <= (others=>'0');
----     tp_value        <= x"10";
----     tp_start_value  <= x"10";--(others=>'0');
----     temp_cnt        <= x"ff";
----     flag            <= '0';
----     video_o_frame_valid <= '0';
----     video_o_line_valid  <= '0';
----   elsif rising_edge(clk) then
    
----    if(tick1ms = '1')then
----        tp_start_value <= tp_start_value +1; 
----    end if;    
        
        
----    case video_fsm is
----      when s_idle =>
----          video_fsm <= s_frame_gen;
----      when s_frame_gen =>
----          video_fsm     <= s_ths;
----          pix_cnt       <= (others=>'0');
----          video_o_hsync <= '1';

----          if(line_cnt >= TVS)then        
----            video_o_vsync  <= '0';
----          else
----            video_o_vsync  <= '1';
----            tp_value       <= tp_start_value;
----            temp_cnt       <= x"ff";
----            flag           <= '0';
----            COLOR_IDX      <= 0;
----          end if; 
----          if(line_cnt <= (TAVS +TAV))then
----            video_o_frame_valid <= '1'; 
      
----          else
----            video_o_frame_valid <= '0';
----          end if;  
          

----      when s_ths =>
----          if(pix_cnt = THS-1)then
----            video_o_hsync <= '0';
----            video_fsm     <= s_tdes;
----          else
----            video_o_hsync <= '1';
----            video_fsm     <= s_ths;
----          end if;  
----          pix_cnt      <= pix_cnt + 1;

----      when s_tdes =>
----          if(pix_cnt = TDES-2)then
----            video_fsm  <= s_tldata;
----          else
----            video_fsm  <= s_tdes;
----          end if;  
----          pix_cnt    <= pix_cnt + 1;
----      when s_tldata=>
----          if(pix_cnt = TDES +TLDATA-1)then
----            video_fsm  <= s_thidl;
----            video_o_de <= '0';
----            video_o_line_valid <= '0';
----          else
----            video_fsm  <= s_tldata;
----            if(line_cnt >= TAVS and line_cnt < (TAVS +TAV))then
----              video_o_de   <= '1';
----              video_o_line_valid <= '1';
----              flag         <= not flag;
----             COLOR := COLOR_TAB_FULL(COLOR_IDX);
----             if(temp_cnt= x"27")then
                
----                tp_value    <= tp_value + x"0c";
----                temp_cnt    <= x"00";
----                if(COLOR_IDX=H_STRIP_NB-1)then
----                 COLOR_IDX   <= 0;
----                else
----                 COLOR_IDX   <= COLOR_IDX + 1;
----                end if;
----             else
----                temp_cnt    <= temp_cnt + 1;
----             end if;
----             if(sel_color_tp= '1')then
----                if(flag = '0')then
----                    video_o_data <= COLOR(23 downto 16) &COLOR(7 downto 0);
----                else
----                    video_o_data <= COLOR(15 downto 8) &COLOR(7 downto 0);
----                end if;    
----             else
----                video_o_data <= x"80" & std_logic_vector(tp_value);
----             end if;   

----            else
----              video_o_de   <= '0';
----              video_o_line_valid <= '0';
----              video_o_data <= (others=>'0');  
                          
----            end if; 
----          end if;
----          pix_cnt <= pix_cnt + 1;

----      when s_thidl =>
----          if(pix_cnt = H_TOTAL_SIZE-2)then
----            video_fsm <= s_frame_gen;
----              if(line_cnt = V_TOTAL_SIZE-1)then
----                line_cnt <= (others=>'0');
----              else
----                line_cnt      <= line_cnt + 1;
----              end if;
----              if(line_cnt >= TAVS and line_cnt < (TAVS +TAV))then
----                 tp_value       <= tp_start_value;
----                 temp_cnt    <= x"FF";
----                 flag            <= '0';
----                 COLOR_IDX      <= 0;
----              end if;   
----          else
----            video_fsm <= s_thidl;
----          end if;
----            pix_cnt  <= pix_cnt + 1;
----    end case;

----   end if;
----  end process video_gen_process;


--------------------------------
----end architecture RTL;
--------------------------------


------------------------------------------------------------------
---- Copyright    : ALSE - http://alse-fr.com
---- Contact      : info@alse-fr.com
---- Project Name : Tonboimaging - Thermal Camera Project
---- Block Name   : TP_GEN_16BIT
---- Description  : Video In Pattern Generator 
---- Author       : E.LAURENDEAU
---- Date         : 30/12/2013
------------------------------------------------------------------


--library IEEE;
--  use IEEE.std_logic_1164.all;
--  use IEEE.numeric_std.all;

-------------------------------
--entity TP_GEN_16BIT is
-------------------------------
--  generic (         
--    REQ_XSIZE  : positive range 16 to 2095:=384;--positive range 16 to 1023:=384; -- Required Output Horizontal Size 
--    REQ_YSIZE  : positive range 16 to 1023:=288; -- Required Output   Vertical Size
--    TVS        : positive := 2;   -- VSYNC PULSE WIDTH          : 2 HYNC PERIOD
--    TAVS       : positive := 5;   -- TIME TO ACTIVE VIDEO START : 5 HYNC PERIOD
--    TAV        : positive := 600; -- ACTIVE VIDEO               : 600 HYNC PERIOD
--    TVIDL      : positive := 2;   -- FRAME  BLANKING            : 2 HYNC PERIOD
--    THS        : positive := 8;   -- HSYNC PULSE WIDTH          : 8 SCLK
--    TDES       : positive := 12;  -- TIME TO DATA ENABLE START  : 12 SCLK
--    TLDATA     : positive := 800; -- TOTAL DATA                 : 800 SCLK
--    THIDL      : positive := 12 ;  -- LINE OVERSCAN              : 12 SCLK
--    PIX_BITS   : positive := 10;
--    LIN_BITS   : positive := 10
--  );
--  port (
--    clk           : in  std_logic;                     -- module clock
--    rst           : in  std_logic;                     -- module reset (asynch active high)
--    tick1ms       : in  std_logic;
--    sel_color_tp  : in  std_logic; 
----    video_o_xsize : out std_logic_vector(PIX_BITS-1 downto 0);  -- video x size
----    video_o_ysize : out std_logic_vector(LIN_BITS-1 downto 0);  -- video y size
--    video_o_vsync : out std_logic;                     -- video vsync
--    video_o_hsync : out std_logic;                     -- video hysnc
--    video_o_frame_valid : out std_logic;  -- high during full frmae   
--    video_o_line_valid  : out std_logic;  -- high during full line 

--    video_o_de    : out std_logic;                     -- video data enable (data valid)
--    video_o_data  : out std_logic_vector(15 downto 0);   -- video pixel data
--    pix_cnt_out   : out std_logic_vector(PIX_BITS-1 downto 0);
--    line_cnt_out  : out std_logic_Vector(LIN_BITS-1 downto 0)
--  );
--------------------------------
--end entity TP_GEN_16BIT;
--------------------------------


--------------------------------------------
--architecture RTL of TP_GEN_16BIT is
--------------------------------------------

--  constant V_TOTAL_SIZE : positive := TAVS+TAV+TVIDL;
--  constant H_TOTAL_SIZE : positive := TDES + TLDATA + THIDL;
  
--  type video_fsm_t is ( s_idle, s_frame_gen, s_ths, s_tdes, s_tldata,s_thidl);
--  signal video_fsm     : video_fsm_t;

---- RGB to YUV Formulas are
--  -- Y =  0.299*R + 0.587*G + 0.114*B
--  -- U = -0.169*R - 0.331*G + 0.500*B + 128
--  -- V =  0.500*R - 0.419*G - 0.081*B + 128
--  function RGB2YUV (
--    R : in integer range 0 to 255;
--    G : in integer range 0 to 255;
--    B : in integer range 0 to 255 ) return std_logic_vector is
--    variable RES_Y     : real;
--    variable RES_U     : real;
--    variable RES_V     : real;
--    variable RES_Y_slv : std_logic_vector(7 downto 0);
--    variable RES_U_slv : std_logic_vector(7 downto 0);
--    variable RES_V_slv : std_logic_vector(7 downto 0);
--  begin
--    RES_Y :=  0.299*real(R) +0.587*real(G) +0.114*real(B);
--    RES_U := -0.169*real(R) -0.331*real(G) +0.500*real(B) +128.0;
--    RES_V :=  0.500*real(R) -0.419*real(G) -0.081*real(B) +128.0;
--    if RES_Y > 254.0 then
--      RES_Y := 254.0;
--    elsif RES_Y < 1.0 then
--      RES_Y := 1.0;
--    end if;
--    if RES_U > 254.0 then
--      RES_U := 254.0;
--    elsif RES_U < 1.0 then
--      RES_U := 1.0;
--    end if;
--    if RES_V > 254.0 then
--      RES_V := 254.0;
--    elsif RES_V < 1.0 then
--      RES_V := 1.0;
--    end if;
--    RES_Y_slv := std_logic_vector(to_unsigned(integer(RES_Y),8));
--    RES_U_slv := std_logic_vector(to_unsigned(integer(RES_U),8));
--    RES_V_slv := std_logic_vector(to_unsigned(integer(RES_V),8));
--    return RES_V_slv & RES_U_slv & RES_Y_slv;
--  end function RGB2YUV;

--  -- YCbCr values (assuming gamma corrected RGB with 0-255 range)
--  -- Y on 07:00, Cb on 15:08, Cr on 23:16
--  constant WHITE   : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>255,B=>255);
--  constant YELLOW  : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>255,B=>000);
--  constant CYAN    : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>255,B=>255);
--  constant GREEN   : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>255,B=>000);
--  constant MAGENTA : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>000,B=>255);
--  constant RED     : std_logic_vector(23 downto 0):= RGB2YUV(R=>255,G=>000,B=>000);
--  constant BLUE    : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>000,B=>255);
--  constant BLACK   : std_logic_vector(23 downto 0):= RGB2YUV(R=>000,G=>000,B=>000);
  
--  constant H_STRIP_NB   : positive := 16;
  
--  type COLOR_TAB_t is array (0 to H_STRIP_NB-1) of std_logic_vector(23 downto 00);
--  constant COLOR_TAB_FULL : COLOR_TAB_t :=
--    ( 00=>WHITE, 01=>YELLOW, 02=>CYAN , 03=>GREEN , 04=>MAGENTA, 05=>RED, 06=>BLUE , 07=>BLACK,
--      08=>WHITE, 09=>YELLOW, 10=>CYAN , 11=>GREEN , 12=>MAGENTA, 13=>RED, 14=>BLUE , 15=>BLACK );


--  signal line_cnt : unsigned(LIN_BITS-1 downto 0);
--  signal pix_cnt  : unsigned(PIX_BITS-1 downto 0);
--  signal tp_value : unsigned(7 downto 0);
--  signal tp_start_value : unsigned(7 downto 0);
--  signal temp_cnt : unsigned(7 downto 0);
--  signal COLOR_IDX : integer range 0 to H_STRIP_NB-1;
--  signal flag : std_logic;
---------
--begin
---------
--line_cnt_out <= std_logic_vector(line_cnt);
--pix_cnt_out  <= std_logic_vector(pix_cnt) ;
--  video_gen_process : process(clk, rst)
--  variable COLOR   : std_logic_vector(23 downto 0);
--  begin
--   if rst = '1' then
--     video_fsm       <= s_idle;
--     video_o_vsync   <= '0';
--     video_o_hsync   <= '0';
--     video_o_de      <= '0';
--     video_o_data    <= (others=>'0');
--     line_cnt        <= (others=>'0');
--     pix_cnt         <= (others=>'0');
--     tp_value        <= x"10";
--     tp_start_value  <= x"10";--(others=>'0');
--     temp_cnt        <= x"ff";
--     flag            <= '0';
--     video_o_frame_valid <= '0';
--     video_o_line_valid  <= '0';
--   elsif rising_edge(clk) then
    
--    if(tick1ms = '1')then
--        tp_start_value <= tp_start_value +1; 
--    end if;    
        
        
--    case video_fsm is
--      when s_idle =>
--          video_fsm <= s_frame_gen;
--      when s_frame_gen =>
--          video_fsm     <= s_ths;
--          pix_cnt       <= (others=>'0');
--          video_o_hsync <= '1';

--          if(line_cnt >= TVS)then        
--            video_o_vsync  <= '0';
--          else
--            video_o_vsync  <= '1';
--            tp_value       <= tp_start_value;
--            temp_cnt       <= x"ff";
--            flag           <= '0';
--            COLOR_IDX      <= 0;
--          end if; 
--          if(line_cnt <= (TAVS +TAV))then
--            video_o_frame_valid <= '1'; 
      
--          else
--            video_o_frame_valid <= '0';
--          end if;  
          

--      when s_ths =>
--          if(pix_cnt = THS-1)then
--            video_o_hsync <= '0';
--            video_fsm     <= s_tdes;
--          else
--            video_o_hsync <= '1';
--            video_fsm     <= s_ths;
--          end if;  
--          pix_cnt      <= pix_cnt + 1;

--      when s_tdes =>
--          if(pix_cnt = TDES-2)then
--            video_fsm  <= s_tldata;
--          else
--            video_fsm  <= s_tdes;
--          end if;  
--          pix_cnt    <= pix_cnt + 1;
--      when s_tldata=>
--          if(pix_cnt = TDES +TLDATA-1)then
--            video_fsm  <= s_thidl;
--            video_o_de <= '0';
--            video_o_line_valid <= '0';
--          else
--            video_fsm  <= s_tldata;
--            if(line_cnt >= TAVS and line_cnt < (TAVS +TAV))then
--              video_o_de   <= '1';
--              video_o_line_valid <= '1';
--              flag         <= not flag;
--             COLOR := COLOR_TAB_FULL(COLOR_IDX);
--             if(temp_cnt= x"27")then
                
--                tp_value    <= tp_value + x"0c";
--                temp_cnt    <= x"00";
--                if(COLOR_IDX=H_STRIP_NB-1)then
--                 COLOR_IDX   <= 0;
--                else
--                 COLOR_IDX   <= COLOR_IDX + 1;
--                end if;
--             else
--                temp_cnt    <= temp_cnt + 1;
--             end if;
--             if(sel_color_tp= '1')then
--                if(flag = '0')then
--                    video_o_data <= COLOR(23 downto 16) &COLOR(7 downto 0);
--                else
--                    video_o_data <= COLOR(15 downto 8) &COLOR(7 downto 0);
--                end if;    
--             else
----                video_o_data <= x"80" & std_logic_vector(tp_value);
--                video_o_data <= x"80" & std_logic_vector(line_cnt(7 downto 0));
--             end if;   

--            else
--              video_o_de   <= '0';
--              video_o_line_valid <= '0';
--              video_o_data <= (others=>'0');  
                          
--            end if; 
--          end if;
--          pix_cnt <= pix_cnt + 1;

--      when s_thidl =>
--          if(pix_cnt = H_TOTAL_SIZE-2)then
--            video_fsm <= s_frame_gen;
--              if(line_cnt = V_TOTAL_SIZE-1)then
--                line_cnt <= (others=>'0');
--              else
--                line_cnt      <= line_cnt + 1;
--              end if;
--              if(line_cnt >= TAVS and line_cnt < (TAVS +TAV))then
--                 tp_value       <= tp_start_value;
--                 temp_cnt    <= x"FF";
--                 flag            <= '0';
--                 COLOR_IDX      <= 0;
--              end if;   
--          else
--            video_fsm <= s_thidl;
--          end if;
--            pix_cnt  <= pix_cnt + 1;
--    end case;

--   end if;
--  end process video_gen_process;


------------------------------
--end architecture RTL;
------------------------------
