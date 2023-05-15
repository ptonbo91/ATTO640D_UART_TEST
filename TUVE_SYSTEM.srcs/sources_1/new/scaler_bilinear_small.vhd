Library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity scaler_bilinear_small is
generic (   PIX_BITS            : positive := 10;                               -- 2**PIX_BITS = Maximum Number of pixels in an input line
            LIN_BITS            : positive := 10                               -- 2**LIN_BITS = Maximum Number of lines in an output image 
);
port (      CLK                 : in std_logic;       
            RST                 : in  std_logic;
            SRC_RUN             : in std_logic;                                 -- RUN signal sent by memory_to_scaler which indicates that there is at least one frame in memory
            SRC_REQ_V           : out std_logic;                                -- Ask memory_to_scaler to get ready for sending a frame 
            SRC_REQ_H           : out std_logic;                                -- Ask memory_to_scaler to send a line 
            SRC_DMA_ADDR_LIN    : out std_logic_vector(LIN_BITS-1 downto 0);    -- Ask memory_to_scaler to send this particular line
            SRC_DMA_ADDR_OFF    : out std_logic_vector(PIX_BITS-1 downto 0);    -- Ask memory_to_scaler to start sending data from a particular pixel in the line
            SRC_REQ_XSIZE       : out std_logic_vector(PIX_BITS-1 downto 0);    -- Width of image required from memory_to_scaler
            SRC_REQ_YSIZE       : out std_logic_vector(LIN_BITS-1 downto 0);    -- Height of image required from memory_to_scaler
            SRC_V               : in std_logic;                                 -- Start-of-frame signal from memory_to_scaler  
            SRC_DAV             : in std_logic;                                 -- Data-valid signal from memory_to_scaler
            SRC_DATA            : in std_logic_vector(7 downto 0);             -- Data signal from memory_to_scaler
            SRC_XSIZE           : in std_logic_vector(PIX_BITS-1 downto 0);     -- X-size signal from memory_to_scaler
            SRC_YSIZE           : in std_logic_vector(LIN_BITS-1 downto 0);     -- Y-size signal from memory_to_scaler
            SRC_XCNT            : in std_logic_vector(PIX_BITS-1 downto 0);     -- X-count signal from memory_to_scaler (starting from  0)
            SRC_YCNT            : in std_logic_vector(LIN_BITS-1 downto 0);     -- Y-count signal from memory_to_scaler (starting from 0)
            SRC_FIFO_EMP        : in std_logic;                                 -- Memory_to_scaler data FIFO is empty, scaler can send request for new line

            ZOOM_ENABLE         : in std_logic;                                 -- This signal has to be made high after all other settings 
            IN_X_SIZE           : in std_logic_vector(PIX_BITS-1 downto 0);     -- Input bits to be read from memory
            IN_Y_SIZE           : in std_logic_vector(LIN_BITS-1 downto 0);     -- Input lines to be read from memory
            IN_X_OFF            : in std_logic_vector(PIX_BITS-1 downto 0);     -- Leave these many pixels from the left for each line 
            IN_Y_OFF            : in std_logic_vector(LIN_BITS-1 downto 0);     -- Leave these many lines from the top  
            OUT_X_SIZE          : in std_logic_vector(10 downto 0);              -- Output number of bits per line from scaler 
            OUT_Y_SIZE          : in std_logic_vector(9 downto 0);              -- Output number of lines from scaler 

            BT656_REQ_V         : in std_logic;                                 -- Request from BT656 to start calculating first line
            BT656_REQ_H         : in std_logic;
            BT656_FIELD         : in std_logic;                                 
            BT656_LINE_NO       : in std_logic_vector(LIN_BITS-1 downto 0);
            BT656_REQ_XSIZE     : in std_logic_vector(PIX_BITS-1 downto 0); 
            BT656_REQ_YSIZE     : in std_logic_vector(LIN_BITS-1 downto 0);
            VIDEO_O_V           : out std_logic;
            VIDEO_O_H           : out std_logic;
            VIDEO_O_DAV         : out std_logic;
            VIDEO_O_DATA        : out std_logic_vector(7 downto 0);             -- Scaler Y output
            VIDEO_O_EOI         : out std_logic;
            VIDEO_O_XSIZE       : out std_logic_vector(PIX_BITS-1 downto 0);
            VIDEO_O_YSIZE       : out std_logic_vector(LIN_BITS-1 downto 0)
);
end entity;

architecture RTL of scaler_bilinear_small is

  ----------------------------
COMPONENT TOII_TUVE_ila

PORT (
  clk : IN STD_LOGIC;
  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;
----------------------------

  signal probe0: std_logic_vector(127 downto 0);

----------------------------------------------------------------
function ceil_log2(input:positive) return integer is
  variable temp,log:integer;
  begin
    temp:=input;
      log:=0;
      while (temp /= 0) loop
        temp:=temp/2;
        log:=log+1;
      end loop;
   return log;
end function ceil_log2;
----------------------------------------------------------------------------------------------------------------------
 -- Constants
  constant LIN_BITS_OUT            : positive := 10;                          ------  HD resolution = 1080 * 720 and 2**LIN_BITS_OUT = Maximum Number of lines in an output image
  constant PIX_BITS_OUT            : positive := 10;                          ------  HD resolution = 1080 * 720 and 2**PIX_BITS_OUT = Maximum Number of pixels in an input line
  constant DATA_WIDTH              : positive := 8;                          ------  incoming data is supposed to be YCbCr 4:2:2 format
  constant MULTIPLIER_WIDTH        : positive := 18;                          ------  DSP multiplier width 
  constant FRACTION_BITS           : positive := 16;                           ------  Number of decimal bits in the ratios: (Input_x_size / Output_x_size), (Input_y_size / Output_y_size) 
  constant W                       : positive := PIX_BITS+FRACTION_BITS;      ------  Width of division module signals 
  constant CBIT                    : integer  := ceil_log2(W);                ------  ceil(log2(W))

    -- Division 
  signal start                     : std_logic;
  signal dvsr                      : std_logic_vector(W-1 downto 0);
  signal dvnd                      : std_logic_vector(W-1 downto 0);
  signal done_tick                 : std_logic;
  signal quo                       : std_logic_vector(W-1 downto 0);
  signal rmd                       : std_logic_vector(W-1 downto 0);

  signal x_ratio                   : unsigned(FRACTION_BITS-1 downto 0);
  signal y_ratio                   : unsigned(FRACTION_BITS-1 downto 0);
  signal y_old                     : signed(LIN_BITS downto 0);
  signal x_full                    : unsigned(PIX_BITS+FRACTION_BITS-1 downto 0);
  signal y_full                    : unsigned(LIN_BITS+FRACTION_BITS-1 downto 0);
  signal x_int                     : unsigned(PIX_BITS-1 downto 0);
  signal y_int                     : unsigned(LIN_BITS-1 downto 0);
  signal x_diff                    : unsigned(FRACTION_BITS-1 downto 0);
  signal x_diff_1                  : unsigned(FRACTION_BITS downto 0);
  signal y_diff                    : unsigned(FRACTION_BITS-1 downto 0);
  signal y_diff_1                  : unsigned(FRACTION_BITS downto 0);

  signal XCNT                      : unsigned(PIX_BITS-1 downto 0);
  signal YCNT                      : unsigned(LIN_BITS-1 downto 0);

  signal IN_X_SIZE_REG            : std_logic_vector(IN_X_SIZE'range);
  signal IN_Y_SIZE_REG            : std_logic_vector(IN_Y_SIZE'range);
  signal IN_X_OFF_REG             : std_logic_vector(IN_X_OFF'range);
  signal IN_Y_OFF_REG             : std_logic_vector(IN_Y_OFF'range);
  signal OUT_X_SIZE_REG           : std_logic_vector(OUT_X_SIZE'range);
  signal OUT_Y_SIZE_REG           : std_logic_vector(OUT_Y_SIZE'range);


  signal line_ptr                  : std_logic_vector(0 to 1);
  signal stage : std_logic_vector(0 to 6);

  signal A, B, C, D                               : unsigned(DATA_WIDTH-1 downto 0);
  signal A_mul, B_mul, C_mul, D_mul               : unsigned(2*FRACTION_BITS+1 downto 0);
  signal A_mul_d1, B_mul_d1, C_mul_d1, D_mul_d1   : unsigned(2*FRACTION_BITS+1 downto 0);
  signal A_reg, B_reg, C_reg, D_reg               : unsigned(DATA_WIDTH-1 downto 0);
  signal A_res, B_res, C_res, D_res               : unsigned(DATA_WIDTH+2*FRACTION_BITS+1 downto 0);

  signal AB_res, CD_res                           : unsigned(DATA_WIDTH+2*FRACTION_BITS+1 downto 0);
  signal pixel_out                                : unsigned(DATA_WIDTH+2*FRACTION_BITS+1 downto 0);
  signal pixel_valid                              : std_logic;

  signal addr0_a, addr0_b, addr1_a, addr1_b : std_logic_vector(PIX_BITS-1 downto 0);
  signal rd_data0_a, rd_data0_b, rd_data1_a, rd_data1_b : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wr_data0, wr_data1 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wr_en0, wr_en1 : std_logic;

  signal wr_en : std_logic_vector(0 to 1);

  type FSM_t is (idle, calc_ratios, calc_y_ratio, calc_x_ratio, calc_y1, calc_y2, calc_pix, calc_pix1, fetch_line, fetch_1line, fetch_2lines, fetch_wait, wait_cyc, end_img, pass_through);
  signal state : FSM_t;
  signal state_temp : FSM_t;
  signal prev_state: FSM_t;

  signal BT656_REQ_H_LEVEL: std_logic;
  signal BT656_LINE_NO_REG : std_logic_vector(BT656_LINE_NO'range);

  signal wait_cnt : integer range 0 to 255;

  attribute mark_debug : string;
  attribute mark_debug of BT656_REQ_V : signal is "TRUE";
  attribute mark_debug of BT656_REQ_H : signal is "TRUE";
  attribute mark_debug of BT656_REQ_H_LEVEL : signal is "TRUE";
  attribute mark_debug of BT656_REQ_XSIZE : signal is "TRUE";
  attribute mark_debug of BT656_REQ_YSIZE : signal is "TRUE";
  attribute mark_debug of BT656_LINE_NO_REG : signal is "TRUE";
  attribute mark_debug of state : signal is "TRUE";
  --attribute mark_debug of BT656_REQ_V : signal is "TRUE";
  --attribute mark_debug of BT656_REQ_V : signal is "TRUE";


begin

  line_1 : entity WORK.DPRAM_GENERIC_DC
-------------------------------------
  Generic map(
    ADDR_WIDTH  =>     PIX_BITS,               -- RAM Address Width
    DATA_WIDTH  =>     DATA_WIDTH,             -- RAM Data Width
    RAM_STYLE   =>     "block",                 -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
    BYPASS_RW   =>     true,                   -- Returned Write Data when Read and Write at same address
    SIMPLE_DP   =>     false,                  -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
    SINGLE_CLK  =>     true,                   -- Advertise that A_CLK = B_CLK
    OUTPUT_REG  =>     false                   -- Output Registered if True
  )
  Port map(
    A_CLK       => CLK,
    A_ADDR      => addr0_a,
    A_WRREQ     => wr_en0,
    A_WRDATA    => wr_data0,
    A_RDREQ     => '1',
    A_RDDATA    => rd_data0_a,
    B_CLK       => CLK,
    B_ADDR      => addr0_b,
    B_WRREQ     => '0',
    B_WRDATA    => (others=>'0'),
    B_RDREQ     => '1',
    B_RDDATA    => rd_data0_b
  );

line_2 : entity WORK.DPRAM_GENERIC_DC
-------------------------------------
  Generic map(
    ADDR_WIDTH  =>     PIX_BITS,               -- RAM Address Width
    DATA_WIDTH  =>     DATA_WIDTH,             -- RAM Data Width
    RAM_STYLE   =>     "block",                 -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
    BYPASS_RW   =>     true,                   -- Returned Write Data when Read and Write at same address
    SIMPLE_DP   =>     false,                  -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
    SINGLE_CLK  =>     true,                   -- Advertise that A_CLK = B_CLK
    OUTPUT_REG  =>     false                   -- Output Registered if True
  )
  Port map(
    A_CLK       => CLK,
    A_ADDR      => addr1_a,
    A_WRREQ     => wr_en1,
    A_WRDATA    => wr_data1,
    A_RDREQ     => '1',
    A_RDDATA    => rd_data1_a,
    B_CLK       => CLK,
    B_ADDR      => addr1_b,
    B_WRREQ     => '0',
    B_WRDATA    => (others=>'0'),
    B_RDREQ     => '1',
    B_RDDATA    => rd_data1_b
  );

  inst_div : entity WORK.div
--------------------
  Generic map(
      W => W,
      CBIT => CBIT
  )
  Port map (
      clk => CLK,
      reset => RST,
      start => start,
      dvsr => dvsr,
      dvnd => dvnd,
      done_tick => done_tick,
      quo => quo,
      rmd => rmd
  );


  addr0_a <= std_logic_vector(x_int) when state = calc_pix else SRC_XCNT;
  addr0_b <= std_logic_vector(x_int+1);
  addr1_a <= std_logic_vector(x_int) when state = calc_pix else SRC_XCNT;
  addr1_b <= std_logic_vector(x_int+1);

  wr_data0 <= SRC_DATA;
  wr_data1 <= SRC_DATA;

  wr_en0 <= SRC_DAV and wr_en(0);
  wr_en1 <= SRC_DAV and wr_en(1);

  --x_ratio <= to_unsigned(256, x_ratio'length);
  --y_ratio <= to_unsigned(256, y_ratio'length);

  A <= unsigned(rd_data0_a) when line_ptr(0)='0' else
        unsigned(rd_data1_a);

  B <= unsigned(rd_data0_b) when line_ptr(0)='0' else
        unsigned(rd_data1_b);

  C <= unsigned(rd_data0_a) when line_ptr(0)='1' else
        unsigned(rd_data1_a);

  D <= unsigned(rd_data0_b) when line_ptr(0)='1' else
        unsigned(rd_data1_b);


  process(CLK, RST) 
    variable x_diff_v: unsigned(FRACTION_BITS downto 0);
    variable y_diff_v: unsigned(FRACTION_BITS downto 0);
  begin
    if(RST='1') then

      state <= idle;
      state_temp <= idle;
      stage <= (others=>'0');
      line_ptr <= "01";
      y_int <= (others=>'0');
      x_int <= (others=>'0');
      y_full <= (others=>'0');
      x_full <= (others=>'0');
      y_diff <= (others=>'0');
      x_diff <= (others=>'0');
      y_diff_1 <= (others=>'0');
      x_diff_1 <= (others=>'0');
      XCNT <= (others=>'1');
      YCNT <= (others=>'0');
      SRC_REQ_H <= '0';
      SRC_REQ_V <= '0';
      SRC_REQ_XSIZE <= (others=>'0');
      SRC_REQ_YSIZE <= (others=>'0');
      SRC_DMA_ADDR_OFF <= (others=>'0');
      SRC_DMA_ADDR_LIN <= (others=>'0');
      A_reg <= (others=>'0');
      B_reg <= (others=>'0');
      C_reg <= (others=>'0');
      D_reg <= (others=>'0');

      A_res <= (others=>'0');
      B_res <= (others=>'0');
      C_res <= (others=>'0');
      D_res <= (others=>'0');

      AB_res <= (others=>'0');
      CD_res <= (others=>'0');

      pixel_valid <= '0';
      pixel_out <= (others=>'0');

      VIDEO_O_V <= '0';
      VIDEO_O_H <= '0';
      VIDEO_O_EOI <= '0';
      VIDEO_O_DAV <= '0';
      wr_en <= (others => '0');
      BT656_REQ_H_LEVEL <= '0';
      prev_state <= pass_through;
      VIDEO_O_XSIZE <= (others=>'0');
      VIDEO_O_YSIZE <= (others=>'0');
      dvsr <= (others=>'0');
      dvnd <= (others=>'0');
      start <= '0';


    elsif (rising_edge(CLK)) then
      SRC_REQ_H <= '0';
      SRC_REQ_V <= '0';
      stage <= (others => '0');
      pixel_valid <= '0';
      VIDEO_O_V <= '0';
      VIDEO_O_H <= '0';
      VIDEO_O_EOI <= '0';
      VIDEO_O_DAV <= pixel_valid;
      VIDEO_O_DATA <= std_logic_vector(pixel_out(2*FRACTION_BITS+DATA_WIDTH-1 downto 2*FRACTION_BITS));
      if (BT656_REQ_H='1') then
        BT656_REQ_H_LEVEL <= '1';
        BT656_LINE_NO_REG <= BT656_LINE_NO;
      end if;

      case state is
        when idle =>
          y_old <= to_signed(-1, y_old'length);
          line_ptr <= "01";
          if (BT656_REQ_V='1') then
            SRC_REQ_V <='1';
            VIDEO_O_V <= '1';
            if (ZOOM_ENABLE='1' and BT656_FIELD='0' and IN_X_SIZE=OUT_X_SIZE and IN_Y_SIZE=OUT_Y_SIZE) then
              state <= pass_through;
              prev_state <= pass_through;
              SRC_REQ_XSIZE <= IN_X_SIZE;
              SRC_REQ_YSIZE <= IN_Y_SIZE;
              IN_X_SIZE_REG <= IN_X_SIZE;
              IN_Y_SIZE_REG <= IN_Y_SIZE;
              IN_X_OFF_REG  <= IN_X_OFF;
              IN_Y_OFF_REG  <= IN_Y_OFF;
              OUT_X_SIZE_REG <= OUT_X_SIZE;
              OUT_Y_SIZE_REG <= OUT_Y_SIZE;
              VIDEO_O_XSIZE <= IN_X_SIZE;
              VIDEO_O_YSIZE <= IN_Y_SIZE;
            elsif(ZOOM_ENABLE='1' and BT656_FIELD='0') then
              state <= calc_ratios;
              prev_state <= calc_y1;
              SRC_REQ_XSIZE <= IN_X_SIZE;
              SRC_REQ_YSIZE <= IN_Y_SIZE;
              IN_X_SIZE_REG <= IN_X_SIZE;
              IN_Y_SIZE_REG <= IN_Y_SIZE;
              IN_X_OFF_REG  <= IN_X_OFF;
              IN_Y_OFF_REG  <= IN_Y_OFF;
              OUT_X_SIZE_REG <= OUT_X_SIZE;
              OUT_Y_SIZE_REG <= OUT_Y_SIZE;
              VIDEO_O_XSIZE <= OUT_X_SIZE;
              VIDEO_O_YSIZE <= OUT_Y_SIZE;
            elsif(ZOOM_ENABLE='0' and BT656_FIELD='0') then
              state <= pass_through;
              prev_state <= pass_through;
              SRC_REQ_XSIZE <= IN_X_SIZE;
              SRC_REQ_YSIZE <= IN_Y_SIZE;
              IN_X_SIZE_REG <= IN_X_SIZE;
              IN_Y_SIZE_REG <= IN_Y_SIZE;
              IN_X_OFF_REG  <= IN_X_OFF;
              IN_Y_OFF_REG  <= IN_Y_OFF;
              OUT_X_SIZE_REG <= OUT_X_SIZE;
              OUT_Y_SIZE_REG <= OUT_Y_SIZE;
              VIDEO_O_XSIZE <= IN_X_SIZE;
              VIDEO_O_YSIZE <= IN_Y_SIZE;
            else
              state <= prev_state;
            end if;
          end if;

        when calc_ratios =>
          dvnd <= std_logic_vector(resize(unsigned(std_logic_vector(unsigned(IN_Y_SIZE_REG)-1) & std_logic_vector(to_unsigned(0, FRACTION_BITS))), dvnd'length));                          --10.8 format
          dvsr <= std_logic_vector(resize(unsigned(OUT_Y_SIZE_REG), dvsr'length));
          start <=  '1';
          state <= calc_y_ratio;

        when calc_y_ratio => 
          if done_tick = '1' then
            y_ratio <= resize(unsigned(quo), y_ratio'length);
            dvnd <= std_logic_vector(resize(unsigned(std_logic_vector(unsigned(IN_X_SIZE_REG)-1) & std_logic_vector(to_unsigned(0, FRACTION_BITS))), dvnd'length));  
            dvsr <= std_logic_vector(resize(unsigned(OUT_X_SIZE_REG), dvsr'length));
            start <=  '1';
            state <= calc_x_ratio;
          else
            start <= '0';
          end if;

        when calc_x_ratio => 
          if done_tick = '1' then
            x_ratio <= resize(unsigned(quo), x_ratio'length);
            state <= calc_y1;
          else
            start <= '0';
          end if; 

        when calc_y1 =>
          if (BT656_REQ_H_LEVEL='1') then
            BT656_REQ_H_LEVEL <= '0';
            y_full <= unsigned(BT656_LINE_NO_REG) * y_ratio;
            state <= calc_y2;
          end if;

        when calc_y2 =>
          y_int <= y_full(LIN_BITS+FRACTION_BITS-1 downto FRACTION_BITS);
          y_diff <= unsigned(y_full(FRACTION_BITS-1 downto 0));
          y_diff_v := (to_unsigned(2**FRACTION_BITS, FRACTION_BITS+1)-y_full(FRACTION_BITS-1 downto 0));
          --y_diff_1 <= y_diff_v(FRACTION_BITS-1 downto 0);
          y_diff_1 <= y_diff_v;
          state <= fetch_line;

        when fetch_line =>
          if(y_old/=to_signed(-1, y_old'length) and y_int = unsigned('0' & y_old) + 1) then
            line_ptr <= line_ptr(1) & line_ptr(0);
            state <= fetch_1line;
          elsif (y_old=to_signed(-1, y_old'length) or y_int >unsigned('0' & y_old) + 1) then
            line_ptr <= "01";
            state <= fetch_2lines;
          else
            state <= calc_pix1;
          end if;

        when fetch_1line =>
          SRC_REQ_H <='1';
          SRC_DMA_ADDR_LIN <= std_logic_vector(y_int +1 + unsigned(IN_Y_OFF_REG)) ;
          SRC_DMA_ADDR_OFF <= IN_X_OFF_REG;
          if(line_ptr(1)='0') then
            wr_en <= "10";
          else
            wr_en <= "01";
          end if;
          state <= fetch_wait;
          state_temp <= calc_pix1;

        when fetch_2lines =>
          SRC_REQ_H <= '1';
          SRC_DMA_ADDR_LIN <= std_logic_vector(y_int + unsigned(IN_Y_OFF_REG));
          SRC_DMA_ADDR_OFF <= IN_X_OFF_REG;
          if(line_ptr(0)='0') then
            wr_en <= "10";
          else
            wr_en <= "01";
          end if;
          --wr_en(line_ptr(0)) <= '1';
          --wr_en(line_ptr(1)) <= '0';
          state <= fetch_wait;
          state_temp <= fetch_1line;
          

        when fetch_wait =>
          if SRC_DAV='1' and unsigned(SRC_XCNT)=unsigned(IN_X_SIZE_REG)-1 then
            state <= state_temp;
          end if;

        when calc_pix1 =>
          VIDEO_O_H <= '1';
          state <= calc_pix;

        when calc_pix =>
        -- stage 0
          wr_en <= "00";
          y_old <= signed('0' & y_int);
          if XCNT/=unsigned(OUT_X_SIZE_REG)-1 then
            XCNT <= XCNT + 1;
            stage(0) <= '1';
          end if;
          
          -- stage 1          
          x_full <= XCNT * x_ratio;
          stage(1) <= stage(0);
          

        -- stage 2
          x_int <= x_full(PIX_BITS+FRACTION_BITS-1 downto FRACTION_BITS);
          x_diff <= x_full(FRACTION_BITS-1 downto 0);
          x_diff_v := (to_unsigned(2**FRACTION_BITS, FRACTION_BITS+1)- x_full(FRACTION_BITS-1 downto 0));
          --x_diff_1 <= x_diff_v(FRACTION_BITS-1 downto 0);
          x_diff_1 <= x_diff_v;
          stage(2) <= stage(1);

          -- stage 3
          A_mul_d1 <= x_diff_1 * y_diff_1;
          B_mul_d1 <= '0' & x_diff * y_diff_1;
          C_mul_d1 <= '0' & x_diff_1 * y_diff;
          D_mul_d1 <= "00" & x_diff * y_diff;
          stage(3) <= stage(2);

          -- stage 4

          A_reg <= A;
          B_reg <= B;
          C_reg <= C;
          D_reg <= D;
          A_mul <= A_mul_d1;
          B_mul <= B_mul_d1;
          C_mul <= C_mul_d1;
          D_mul <= D_mul_d1;
          
          stage(4) <= stage(3);

          -- stage 5

          A_res <= A_reg * A_mul;
          B_res <= B_reg * B_mul;
          C_res <= C_reg * C_mul;
          D_res <= D_reg * D_mul;
          stage(5) <= stage(4);

        -- stage 6
          AB_res <= A_res + B_res;
          CD_res <= C_res + D_res;
          stage(6) <= stage(5);

        -- stage 7
          pixel_valid <= stage(6);
          pixel_out <= AB_res + CD_res;

          if XCNT=unsigned(OUT_X_SIZE_REG)-1 and unsigned(stage)=0 and pixel_valid='0' then
            XCNT <= (others=>'1');
            if YCNT = unsigned(OUT_Y_SIZE_REG(OUT_Y_SIZE_REG'length-1 downto 0)) -1 then
              state <= end_img;
              YCNT <= to_unsigned(0, YCNT'length);
            else
              YCNT <= YCNT +1 ;
              state <= calc_y1;
            end if;
          end if;

        when end_img =>
          VIDEO_O_EOI <= '1';
          state_temp <= idle;
          wait_cnt <= 10;
          state <= wait_cyc;


        when wait_cyc =>
          if wait_cnt=0 then
            state <= state_temp;
          else
            wait_cnt <= wait_cnt - 1;
          end if;

        when pass_through =>
          if(BT656_REQ_H_LEVEL='1') then 
            BT656_REQ_H_LEVEL <='0';
            SRC_REQ_H <='1';
            VIDEO_O_H <='1';
            SRC_DMA_ADDR_LIN <= BT656_LINE_NO;
            SRC_DMA_ADDR_OFF <= (others => '0');
          end if;
          VIDEO_O_DATA <= SRC_DATA;
          VIDEO_O_DAV <= SRC_DAV;
          if(unsigned(SRC_XCNT)=unsigned(IN_X_SIZE_REG)-1 and unsigned(SRC_YCNT)=unsigned(IN_Y_SIZE_REG(IN_Y_SIZE_REG'length-1 downto 0)) -1 and SRC_DAV='1') then
            state <= end_img;
          end if;

      end case;
    end if;
  end process;


--i_ILA_SCALER: TOII_TUVE_ILA
--port map(
-- clk        => CLK,
-- probe0     => probe0
--);

--probe0 <= (127 downto 122 =>'0') &
--           std_logic_vector(y_ratio)  &
--           std_logic_vector(y_int)  &
--           std_logic_vector(y_diff)  &
--           std_logic_vector(y_diff_1)  &
--           std_logic_vector(y_full)  &
--           std_logic_vector(to_unsigned(FSM_t'POS(state), 4)) & BT656_REQ_V & BT656_REQ_H & BT656_REQ_H_LEVEL & BT656_REQ_XSIZE & BT656_REQ_YSIZE & BT656_LINE_NO_REG;

end RTL;