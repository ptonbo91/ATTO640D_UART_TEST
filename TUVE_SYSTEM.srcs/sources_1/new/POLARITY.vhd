----------------------------------------------------------------------------
--code for brightness and contrast control
--this is a very simple code which anyone should be able to write
--brightness and contrast control is implemented using the line equation
--  y=mx+c
--where y is the output pixel
--      x is the input pixel (range 0-255)
--      m is the contrast control parameter (0-2^3)
--      c is the brightness parameter (-255 to 255)

--output pixels are to be clipped to range 0-255

--2 stage pipeline implemetation 1)m*x 2) m*x+c

--author : Aneesh M U
----------------------------------------------------------------------------


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

----------------------------
entity POLARITY is
  generic (
  bit_width: positive:= 13;
  VIDEO_XSIZE : positive := 640;
  VIDEO_YSIZE : positive := 512
  );
  port (
    CLK              : in  std_logic;                                     --  Clock
    RST              : in  std_logic;                                     --  Reset

    POLARITY         : in  std_logic_vector(1 downto 0);
    BH_OFFSET        : in  std_logic_vector(bit_width downto 0);

    VIDEO_I_V        : in std_logic;
    VIDEO_I_H        : in std_logic;
    VIDEO_I_EOI      : in std_logic;
    VIDEO_I_DAV      : in std_logic;
    VIDEO_I_DATA     : in std_logic_vector(bit_width downto 0);
--    VIDEO_I_XSIZE    : in std_logic_vector(9 downto 0);
--    VIDEO_I_YSIZE    : in std_logic_vector(9 downto 0);

    VIDEO_O_V        : out std_logic;
    VIDEO_O_H        : out std_logic;
    VIDEO_O_EOI      : out std_logic;
    VIDEO_O_DAV      : out std_logic;
    VIDEO_O_DATA     : out std_logic_vector(bit_width downto 0)
--    VIDEO_O_XSIZE    : out std_logic_vector(9 downto 0);
--    VIDEO_O_YSIZE    : out std_logic_vector(9 downto 0)
  );
end POLARITY;
-------------------------------

architecture behave of POLARITY is

signal VIDEO_DATA: std_logic_vector(bit_width downto 0);

signal VIDEO_DATA_TEMP_l1: unsigned(bit_width+10 downto 0);
signal VIDEO_DATA_TEMP_l2: unsigned(bit_width+10 downto 0);
--signal VIDEO_DATA_CONTRAST:signed(bit_width+1+32 downto 0);
signal VIDEO_DATA_OUT: unsigned(bit_width+1 downto 0);
signal BRIGHTNESS:signed(31 downto 0);
signal CONTRAST: unsigned(31 downto 0);
signal VIDEO_O_EOIi,  VIDEO_O_EOIii    :   std_logic;
signal VIDEO_O_DAVi,  VIDEO_O_DAVii    :   std_logic;
signal POLARITY_D: std_logic_vector(POLARITY'range);
begin

-- 9 bits of video data (make it signed)
--VIDEO_DATA<=signed('0' & VIDEO_I_DATA);

--latch the control signals only at the starting of the video
process(CLK, RST)
begin
  if RST='1' then
    POLARITY_D <= (others=>'0');
  elsif rising_edge(CLK) then
  -- At the start of frame decide brightness and contrast only if enabled
    if VIDEO_I_V='1' then
      POLARITY_D <= POLARITY;
    end if;
  end if;
end process;

process(CLK, RST)
begin
  if RST='1' then
    VIDEO_DATA_OUT<=(others=>'0');
--    VIDEO_DATA_CONTRAST<=(others=>'0');
    VIDEO_O_DATA <=(others=>'0');
    VIDEO_O_DAV <= '0';
    VIDEO_O_DAVi <= '0';
    --VIDEO_O_DAVii <= '0';
    VIDEO_O_EOI<='0';
    VIDEO_O_EOIi<='0';
    VIDEO_O_EOIii<='0';
--    VIDEO_O_XSIZE <= (others=>'0');
--    VIDEO_O_YSIZE <= (others=>'0');

    VIDEO_O_V <='0';
    VIDEO_O_H<='0';
    
  elsif rising_edge(CLK) then

    VIDEO_O_V <= VIDEO_I_V;
    VIDEO_O_H <= VIDEO_I_H;
--    VIDEO_O_XSIZE <= VIDEO_I_XSIZE;
--    VIDEO_O_YSIZE <= VIDEO_I_YSIZE;

    VIDEO_O_DAVi <= VIDEO_I_DAV;
    --VIDEO_O_DAVii <= VIDEO_O_DAVi;
    VIDEO_O_DAV <= VIDEO_O_DAVi;

    VIDEO_O_EOIi <= VIDEO_I_EOI;
    VIDEO_O_EOIii <= VIDEO_O_EOIi;
    VIDEO_O_EOI <= VIDEO_O_EOIii;

    VIDEO_DATA <= VIDEO_I_DATA;

    VIDEO_DATA_TEMP_l1 <= to_unsigned(409, 10)*unsigned(VIDEO_I_DATA);
    VIDEO_DATA_TEMP_l2 <= to_unsigned(590, 10)*unsigned(VIDEO_I_DATA);
    if(unsigned(VIDEO_I_DATA)> (to_unsigned(2**(bit_width+1)-1, VIDEO_I_DATA'length)- unsigned(BH_OFFSET)))then
        VIDEO_DATA_OUT <= to_unsigned(0, VIDEO_DATA_OUT'length);
    else
        VIDEO_DATA_OUT <=(to_unsigned(2**(bit_width+1)-1, VIDEO_DATA_OUT'length) - (unsigned(VIDEO_I_DATA)+unsigned(BH_OFFSET)));
    end if;
    --if signed(VIDEO_DATA_OUT(VIDEO_DATA_OUT'length-1 downto 0))>(2**(bit_width+1)-1) then
    --  VIDEO_O_DATA <= std_logic_vector(to_unsigned((2**(bit_width+1)-1), VIDEO_O_DATA'length));
    --elsif signed(VIDEO_DATA_OUT(VIDEO_DATA_OUT'length-1 downto 0))<0 then
    --  VIDEO_O_DATA <= std_logic_vector(to_unsigned(0, VIDEO_O_DATA'length));
    --else
    if(POLARITY_D="01") then
        VIDEO_O_DATA <= std_logic_vector(VIDEO_DATA_OUT(bit_width downto 0));
    elsif(POLARITY_D="10") then
      if(unsigned(VIDEO_DATA)<50) then
        VIDEO_O_DATA <= std_logic_vector(resize(VIDEO_DATA_TEMP_l1(VIDEO_DATA_TEMP_l1'length-1 downto 8) + to_unsigned(16, VIDEO_O_DATA'length),VIDEO_O_DATA'length));
      elsif (unsigned(VIDEO_DATA)<120) then
        VIDEO_O_DATA <= std_logic_vector(to_unsigned(146, VIDEO_O_DATA'length) - unsigned(VIDEO_DATA));
      elsif (unsigned(VIDEO_DATA)<192) then
        VIDEO_O_DATA <= std_logic_vector(resize(VIDEO_DATA_TEMP_l2(VIDEO_DATA_TEMP_l2'length-1 downto 8) - to_unsigned(250, VIDEO_O_DATA'length), VIDEO_O_DATA'length)); 
      elsif (unsigned(VIDEO_DATA)<232) then
        VIDEO_O_DATA <= std_logic_vector(resize(to_unsigned(576,10) - unsigned(VIDEO_DATA & '0'), VIDEO_O_DATA'length));
      else
        VIDEO_O_DATA <= std_logic_vector(resize(unsigned(VIDEO_DATA & "0") - to_unsigned(336, 10), VIDEO_O_DATA'length));
      end if;
    else
      VIDEO_O_DATA <= VIDEO_DATA;
    end if;
  end if ;
end process;


end behave;