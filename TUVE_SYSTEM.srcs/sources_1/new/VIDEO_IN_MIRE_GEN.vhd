----------------------------------------------------------------
-- Copyright    : ALSE - http://alse-fr.com
-- Contact      : info@alse-fr.com
-- Project Name : Tonboimaging - Thermal Camera Project
-- Block Name   : VIDEO_IN_MIRE_GEN
-- Description  : Video In Pattern Generator 
-- Author       : E.LAURENDEAU
-- Date         : 30/12/2013
----------------------------------------------------------------


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-----------------------------
entity VIDEO_IN_MIRE_GEN is
-----------------------------
  generic (         
    REQ_XSIZE  : positive range 16 to 1023:=384; -- Required Output Horizontal Size 
    REQ_YSIZE  : positive range 16 to 1023:=288; -- Required Output   Vertical Size
    REQ_HBLANK : positive := 1250;          -- CLK cycles for Horizontal Blanking
    REQ_VBLANK : positive :=   50;          -- Lines for Vertical Blanking
    REQ_PIXCLK : integer  range  0 to 16:=16    -- CLK cycles between 2 VIDEO_O_DAV
  );
  port (
    CLK           : in  std_logic;                     -- Module Clock
    RST           : in  std_logic;                     -- Module Reset (Asynch Active High)
    TICK1S        : in std_logic;
    VIDEO_O_XSIZE : out std_logic_vector(9 downto 0);  -- Video X Size
    VIDEO_O_YSIZE : out std_logic_vector(9 downto 0);  -- Video Y Size
    VIDEO_O_V     : out std_logic;                     -- Video   Vertical Synchro
    VIDEO_O_H     : out std_logic;                     -- Video Horizontal Synchro
    VIDEO_O_EOI   : out std_logic;                     -- Video End of Image
    VIDEO_O_DAV   : out std_logic;                     -- Video Pixel Valid Flag
    VIDEO_O_DATA  : out std_logic_vector(7 downto 0);  -- Video Pixel Data
    VIDEO_O_XCNT  : out std_logic_vector(9 downto 0);  -- Video Pixel Counter (1st pix is 0)
    VIDEO_O_YCNT  : out std_logic_vector(9 downto 0)   -- Video  Line Counter (1st lin is 0)
  );
------------------------------
end entity VIDEO_IN_MIRE_GEN;
------------------------------


------------------------------------------
architecture RTL of VIDEO_IN_MIRE_GEN is
------------------------------------------

  constant V_ACTIV_SIZE : positive := REQ_YSIZE;
  constant V_BLANK_SIZE : positive := REQ_VBLANK;
  constant V_TOTAL_SIZE : positive := V_ACTIV_SIZE + V_BLANK_SIZE;
  constant V_SYNC_ST    : positive :=  20;
  constant V_ACTIV_ST   : positive :=  42;
  constant H_ACTIV_SIZE : positive := REQ_XSIZE;
  constant H_BLANK_SIZE : positive := REQ_HBLANK;
  constant H_TOTAL_SIZE : positive := H_ACTIV_SIZE + H_BLANK_SIZE;
  
  type VIDEO_FSM_t is ( s_IDLE, s_LINE_MNGT, s_HBLANK, s_SEND_LINE, s_WAIT_PIX );
  signal VIDEO_FSM     : VIDEO_FSM_t;
  signal VIDEO_ACTIV   : std_logic;
  signal VIDEO_VSYNCi  : std_logic;
  signal VIDEO_HSYNCi  : std_logic;
  signal VIDEO_EOIi    : std_logic;
  signal VIDEO_DAVi    : std_logic;
  signal VIDEO_DATAi   : unsigned(VIDEO_O_DATA'range);  
  signal VIDEO_CNT_PIX : unsigned(11 downto 00);  
  signal VIDEO_XCNTi   : unsigned(VIDEO_O_XCNT'range);
  signal VIDEO_YCNTi   : unsigned(VIDEO_O_YCNT'range); 
  signal VIDEO_WAITPIX : integer range 0 to REQ_PIXCLK;

  signal dcount: integer;
  signal flag : std_logic;
  signal init_data: unsigned(7 downto 0);
-------
begin
-------


  -- Main Process that generates the VSYNC, HSYNC and DAV signals
  -- with correct Horizontal and Vertical Blanking,
  -- regarding Required Resolution (REQ_XSIZE and REQ_YSIZE)
  VIDEO_GEN_process : process(CLK, RST)
    variable v_VIDEO_CNT_LIN : unsigned(11 downto 0);  -- up to 1920
  begin
   if RST = '1' then
     VIDEO_VSYNCi   <= '0';
     VIDEO_HSYNCi   <= '0';
   v_VIDEO_CNT_LIN  := (others => '0');
     VIDEO_CNT_PIX  <= (others => '0');
     VIDEO_ACTIV    <= '0';
     VIDEO_EOIi     <= '0';
     VIDEO_DAVi     <= '0';
     VIDEO_WAITPIX  <=  0 ;
     VIDEO_DATAi    <= (others => '0');
     VIDEO_XCNTi    <= (others => '0'); 
     VIDEO_YCNTi    <= (others => '0'); 
     VIDEO_FSM      <= s_IDLE;
     dcount <= 0;
     flag <= '1';
     init_data <= to_unsigned(98,init_data'length);
   elsif rising_edge(CLK) then

     VIDEO_VSYNCi   <= '0';
     VIDEO_HSYNCi   <= '0';
     VIDEO_DAVi     <= '0';
     VIDEO_EOIi     <= '0';

     if TICK1S='1' then
      dcount <= dcount +1;
     end if;

     -- Pixel Counter
     if VIDEO_DAVi = '1' then
       VIDEO_XCNTi <= VIDEO_XCNTi + 1;
       -- End of Image Detection
       if VIDEO_XCNTi = REQ_XSIZE-1 and 
          VIDEO_YCNTi = REQ_YSIZE-1 then
         VIDEO_EOIi <= '1';
       end if;
     end if;
     
     case VIDEO_FSM is

       when s_IDLE =>
           v_VIDEO_CNT_LIN := to_unsigned(V_TOTAL_SIZE-2, v_VIDEO_CNT_LIN'length);
           flag <= '1';
           VIDEO_FSM <= s_LINE_MNGT;

       when s_LINE_MNGT =>
           -- Lines Counter (cleared by code below)
           if v_VIDEO_CNT_LIN = V_TOTAL_SIZE then
             v_VIDEO_CNT_LIN := to_unsigned(1, v_VIDEO_CNT_LIN'length);
--             VIDEO_DATAi <= (others=>'0');
             if dcount >250 then
--              flag <= not flag;
              if(init_data >158)then
                init_data <= to_unsigned(98,init_data'length);
              else
                init_data <= init_data + 10;
              end if; 
              
              
              dcount <= 0;
             end if;
           else
             v_VIDEO_CNT_LIN := v_VIDEO_CNT_LIN + 1;
           end if;
           -- V sync flag generation
           if v_VIDEO_CNT_LIN = V_SYNC_ST then
             VIDEO_VSYNCi <= '1';
             VIDEO_YCNTi  <= (others => '1');
           end if;
           -- "ACTIVE lines" flag generation
           if v_VIDEO_CNT_LIN >= V_ACTIV_ST and v_VIDEO_CNT_LIN < V_ACTIV_ST+V_ACTIV_SIZE then
             VIDEO_ACTIV <= '1';
           else
             VIDEO_ACTIV <= '0';
           end if;
           -- Go send the Data
           VIDEO_CNT_PIX <= to_unsigned(H_BLANK_SIZE, VIDEO_CNT_PIX'length);
           VIDEO_FSM     <= s_HBLANK;

       when s_HBLANK =>
           if VIDEO_ACTIV = '1' and VIDEO_CNT_PIX = 10 then
             VIDEO_HSYNCi <= '1';
             VIDEO_YCNTi  <= VIDEO_YCNTi + 1;
           end if;
           if VIDEO_CNT_PIX = 0 then
             VIDEO_CNT_PIX <= to_unsigned(0, VIDEO_CNT_PIX'length);
--             VIDEO_DATAi   <= x"FF" + init_data;
             VIDEO_DATAi   <= init_data;
--             VIDEO_DATAi <= VIDEO_DATAi + 1;
             VIDEO_XCNTi   <= (others => '0');
             VIDEO_FSM     <= s_SEND_LINE;
           else
             VIDEO_CNT_PIX <= VIDEO_CNT_PIX - 1;
           end if;

       -- Send Active Pixels (or not) + End of Line
       when s_SEND_LINE =>
           VIDEO_CNT_PIX <= VIDEO_CNT_PIX + 1; -- Pixel Counter
           if VIDEO_CNT_PIX >= H_ACTIV_SIZE then
             VIDEO_DAVi <= '0';
             VIDEO_FSM <= s_LINE_MNGT;
           else
             VIDEO_DAVi  <= VIDEO_ACTIV;
             if(flag='1') then
                if(VIDEO_DATAi> 158)then
                 VIDEO_DATAi <= to_unsigned(98,VIDEO_DATAi'length);
                else
                 VIDEO_DATAi <= VIDEO_DATAi + 1;
                end if;
              
             else
               VIDEO_DATAi <= VIDEO_DATAi - 1;
             end if;
             if REQ_PIXCLK > 0 then
               VIDEO_WAITPIX <= REQ_PIXCLK-1;
               VIDEO_FSM     <= s_WAIT_PIX;
             end if;
           end if;

       -- Waiting some Clock cycles between two active pixels
       when s_WAIT_PIX =>
           if VIDEO_WAITPIX = 0 then
             VIDEO_FSM <= s_SEND_LINE;
           else
             VIDEO_WAITPIX <= VIDEO_WAITPIX - 1;
           end if;

     end case;

   end if;
  end process VIDEO_GEN_process;

  VIDEO_O_V     <= VIDEO_VSYNCi when rising_edge(CLK);
  VIDEO_O_H     <= VIDEO_HSYNCi when rising_edge(CLK);
  VIDEO_O_EOI   <= VIDEO_EOIi   when rising_edge(CLK);
  VIDEO_O_DAV   <= VIDEO_DAVi   when rising_edge(CLK);
  VIDEO_O_DATA  <= std_logic_vector(VIDEO_DATAi) when rising_edge(CLK);
  VIDEO_O_XSIZE <= std_logic_vector(to_unsigned(REQ_XSIZE, VIDEO_O_XSIZE'length));
  VIDEO_O_YSIZE <= std_logic_vector(to_unsigned(REQ_YSIZE, VIDEO_O_YSIZE'length));
  VIDEO_O_XCNT  <= std_logic_vector(VIDEO_XCNTi) when rising_edge(CLK);  
  VIDEO_O_YCNT  <= std_logic_vector(VIDEO_YCNTi) when rising_edge(CLK);

----------------------------
end architecture RTL;
----------------------------
