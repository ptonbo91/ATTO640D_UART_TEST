----------------------------------------------------------------------------
--code for brightness and contrast control
--this is a very simple code which anyone should be able to write
--brightness and contrast control is implemented using the line equation
--  y=c(x-128)+128+b
--where y is the output pixel (range 0-255)
--      x is the input pixel (range 0-255)
--      c is the contrast control parameter (0-127)
--      b is the brightness parameter (-255 to 255)

--output pixels are to be clipped to range 0-255

--author : Pratik
----------------------------------------------------------------------------


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

----------------------------
entity BRIGHTNESS_CONTRAST is
  generic (
  bit_width: positive:= 13;
  VIDEO_XSIZE : positive := 640;
  VIDEO_YSIZE : positive := 512
  );
  port (
    CLK              : in  std_logic;                                     --  Clock
    RST              : in  std_logic;                                     --  Reset

    ENABLE           : in  std_logic;

    CTRL_BRIGHT      : in std_logic_vector(7 downto 0);
    CTRL_CONTRAST    : in std_logic_vector(7 downto 0);

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
end BRIGHTNESS_CONTRAST;
-------------------------------

architecture behave of BRIGHTNESS_CONTRAST is


COMPONENT ila_0

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

signal probe0 : STD_LOGIC_VECTOR(127 DOWNTO 0);

signal VIDEO_DATA: signed(bit_width+1 downto 0);
signal VIDEO_DATA_CONTRAST:signed(bit_width+1+32 downto 0);
signal VIDEO_DATA_BRIGHTNESS : signed(31 downto 0);
signal VIDEO_DATA_OUT: signed(bit_width+33 downto 0);
signal BRIGHTNESS:signed(31 downto 0);
signal CONTRAST: unsigned(31 downto 0);

signal BRIGHTNESS_TEMP:signed(31 downto 0);
signal CONTRAST_TEMP: unsigned(31 downto 0);

signal VIDEO_O_EOIi,  VIDEO_O_EOIii    :   std_logic;
signal VIDEO_O_DAVi,  VIDEO_O_DAVii    :   std_logic;

signal start_div : std_logic;
signal dvsr      : std_logic_vector(31 downto 0);
signal dvnd      : std_logic_vector(31 downto 0);
signal done_tick : STD_LOGIC;
signal quo       : STD_LOGIC_VECTOR(31 downto 0);
signal rmd       : STD_LOGIC_VECTOR(31 downto 0);

constant BRIGHTNESS_MULT  : positive := ((2**(bit_width+16))-1)/50;    -- brightness range -127 to +127,  user input 0 to 100  
                                                       -- 0   means brightness = -127  
                                                       -- 50  means brightness = 0
                                                       -- 100 means brightness = +127
                                                       -- dvsr = 50
constant CONTRAST_DVSR : positive := 50;  -- contrast range 0.00 to 2  , user input 0 to 100
                                          -- 0   means contrast = 0   (0/50)
                                          -- 50  means contrast = 1   (50/50)
                                          -- 100 means contrast = 2   (100/50)


ATTRIBUTE MARK_DEBUG : string;
ATTRIBUTE MARK_DEBUG of  BRIGHTNESS_TEMP  : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  CONTRAST_TEMP    : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  done_tick    : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  dvnd    : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  start_div   : SIGNAL IS "TRUE";


ATTRIBUTE MARK_DEBUG of VIDEO_I_V   : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of VIDEO_I_H   : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of VIDEO_I_EOI : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of VIDEO_I_DAV : SIGNAL IS "TRUE";   

begin




-- 9 bits of video data (make it signed)
VIDEO_DATA<=signed('0' & VIDEO_I_DATA);

--latch the control signals only at the starting of the video
process(CLK, RST)
variable BRIGHTNESS_MULT_OUT : signed(63 downto 0);
begin
  if RST='1' then
    BRIGHTNESS <= to_signed(0,BRIGHTNESS'length);
    CONTRAST <= to_unsigned(2**16, CONTRAST'length);
    BRIGHTNESS_TEMP <= to_signed(0,BRIGHTNESS'length);
    CONTRAST_TEMP <= to_unsigned(2**16, CONTRAST'length);
    dvnd <= (others=>'0');
    dvsr <= (others=>'0');
    start_div <= '0';
  elsif rising_edge(CLK) then
  -- At the start of frame decide brightness and contrast only if enabled
    if VIDEO_I_V='1' and ENABLE='1' then  
        start_div <= '1';
        dvsr  <= STD_LOGIC_VECTOR(to_unsigned(CONTRAST_DVSR,dvsr'length));
        if unsigned(CTRL_CONTRAST) >= 100 then
            dvnd <= STD_LOGIC_VECTOR(to_unsigned(100,16)) & x"0000";
        else
            dvnd  <= x"00"& CTRL_CONTRAST & x"0000" ;
        end if;
        
        
        if unsigned(CTRL_BRIGHT)>= 100 then
            BRIGHTNESS_TEMP <= to_signed(127,BRIGHTNESS'length);
        elsif unsigned(CTRL_BRIGHT)= 0 then
            BRIGHTNESS_TEMP <= to_signed(-127,BRIGHTNESS'length);
        else
            BRIGHTNESS_MULT_OUT := signed((unsigned(x"000000"&CTRL_BRIGHT) - 50)*BRIGHTNESS_MULT);
            BRIGHTNESS_TEMP <= signed(BRIGHTNESS_MULT_OUT(47 downto 16));
        end if;
        
        CONTRAST   <= CONTRAST_TEMP;
        BRIGHTNESS <= BRIGHTNESS_TEMP;
    elsif VIDEO_I_V='1' and ENABLE='0' then
        BRIGHTNESS <= to_signed(0,BRIGHTNESS'length);
        CONTRAST <= to_unsigned(2**16, CONTRAST'length);
    else
        start_div <= '0';
    end if;
    
    if(done_tick = '1') then
        CONTRAST_TEMP <= unsigned(quo);
    else
        CONTRAST_TEMP <= CONTRAST_TEMP;
    end if;
     
  end if;
end process;

process(CLK, RST)
begin
  if RST='1' then
    VIDEO_DATA_OUT<=(others=>'0');
    VIDEO_DATA_CONTRAST<=(others=>'0');
    VIDEO_DATA_BRIGHTNESS<= (others=>'0');
    VIDEO_O_DATA <=(others=>'0');
    VIDEO_O_DAV <= '0';
    VIDEO_O_DAVi <= '0';
    VIDEO_O_DAVii <= '0';
    VIDEO_O_EOI<='0';
    VIDEO_O_EOIi<='0';
    VIDEO_O_EOIii<='0';
--    VIDEO_O_XSIZE <= (others =>'0');
--    VIDEO_O_YSIZE <= (others =>'0');

    VIDEO_O_V <='0';
    VIDEO_O_H<='0';
    
  elsif rising_edge(CLK) then

    VIDEO_O_V <= VIDEO_I_V;
    VIDEO_O_H <= VIDEO_I_H;
--    VIDEO_O_XSIZE <= VIDEO_I_XSIZE;
--    VIDEO_O_YSIZE <= VIDEO_I_YSIZE;
    
    VIDEO_O_DAVi <= VIDEO_I_DAV;
    VIDEO_O_DAVii <= VIDEO_O_DAVi;
    VIDEO_O_DAV <= VIDEO_O_DAVii;

    VIDEO_O_EOIi <= VIDEO_I_EOI;
    VIDEO_O_EOIii <= VIDEO_O_EOIi;
    VIDEO_O_EOI <= VIDEO_O_EOIii;

    VIDEO_DATA_CONTRAST<=signed(unsigned(VIDEO_DATA) - to_unsigned((2**(bit_width)),VIDEO_DATA'length))*signed(CONTRAST);
    VIDEO_DATA_BRIGHTNESS <= signed(signed(BRIGHTNESS(16 downto 0)) + to_signed((2**(bit_width)),BRIGHTNESS'length));
    VIDEO_DATA_OUT<=signed(VIDEO_DATA_CONTRAST)+signed((VIDEO_DATA_BRIGHTNESS(16 downto 0) & x"0000"));
    if signed(VIDEO_DATA_OUT(VIDEO_DATA_OUT'length-1 downto 16))>(2**(bit_width+1)-1) then
      VIDEO_O_DATA <= std_logic_vector(to_unsigned((2**(bit_width+1)-1), VIDEO_O_DATA'length));
    elsif signed(VIDEO_DATA_OUT(VIDEO_DATA_OUT'length-1 downto 16))<0 then
      VIDEO_O_DATA <= std_logic_vector(to_unsigned(0, VIDEO_O_DATA'length));
    else
      VIDEO_O_DATA <= std_logic_vector(VIDEO_DATA_OUT(bit_width+16 downto 16));
    end if;
  end if ;
end process;


 i_nuc_div : entity WORK.div
 generic map(
  W    => 32,
  CBIT => 6
  )
 port map(

  clk  => CLK,
  reset => RST,
  start => start_div ,
  dvsr =>  dvsr, 
  dvnd => dvnd,
  done_tick => done_tick,
  quo => quo, 
  rmd => rmd
  );
  
--  probe0(0) <= VIDEO_I_V    ;
--  probe0(1) <= VIDEO_I_H    ;
--  probe0(2) <= VIDEO_I_DAV  ;
--  probe0(3) <= VIDEO_I_EOI  ;
--  probe0(35 downto 4)   <= std_logic_vector(BRIGHTNESS_TEMP) ;
--  probe0(67 downto 36)  <= std_logic_vector(CONTRAST_TEMP);
--  probe0(99 downto 68)  <= std_logic_vector(dvnd);
--  probe0(100)  <= start_div;
--  probe0(101)  <= done_tick;
--  probe0(127 downto 102)  <= (others=>'0');

  
--  i_ila_BRIGHT_CONTRAST: ila_0
--  PORT MAP (
--      clk => CLK,
--      probe0 => probe0
--  );

end behave;
------------------------------------------------------------------------------
----code for brightness and contrast control
----this is a very simple code which anyone should be able to write
----brightness and contrast control is implemented using the line equation
----  y=mx+c
----where y is the output pixel
----      x is the input pixel (range 0-255)
----      m is the contrast control parameter (0-2^3)
----      c is the brightness parameter (-255 to 255)

----output pixels are to be clipped to range 0-255

----2 stage pipeline implemetation 1)m*x 2) m*x+c

----author : Aneesh M U
------------------------------------------------------------------------------


--library IEEE;
--  use IEEE.std_logic_1164.all;
--  use IEEE.numeric_std.all;

------------------------------
--entity BRIGHTNESS_CONTRAST is
--  generic (
--  bit_width: positive:= 13;
--  VIDEO_XSIZE : positive := 640;
--  VIDEO_YSIZE : positive := 512
--  );
--  port (
--    CLK              : in  std_logic;                                     --  Clock
--    RST              : in  std_logic;                                     --  Reset

--    ENABLE           : in  std_logic;

--    CTRL_BRIGHT      : in std_logic_vector(31 downto 0);
--    CTRL_CONTRAST    : in std_logic_vector(31 downto 0);

--    VIDEO_I_V        : in std_logic;
--    VIDEO_I_H        : in std_logic;
--    VIDEO_I_EOI      : in std_logic;
--    VIDEO_I_DAV      : in std_logic;
--    VIDEO_I_DATA     : in std_logic_vector(bit_width downto 0);
--    VIDEO_I_XSIZE    : in std_logic_vector(9 downto 0);
--    VIDEO_I_YSIZE    : in std_logic_vector(9 downto 0);

--    VIDEO_O_V        : out std_logic;
--    VIDEO_O_H        : out std_logic;
--    VIDEO_O_EOI      : out std_logic;
--    VIDEO_O_DAV      : out std_logic;
--    VIDEO_O_DATA     : out std_logic_vector(bit_width downto 0);
--    VIDEO_O_XSIZE    : out std_logic_vector(9 downto 0);
--    VIDEO_O_YSIZE    : out std_logic_vector(9 downto 0)
--  );
--end BRIGHTNESS_CONTRAST;
---------------------------------

--architecture behave of BRIGHTNESS_CONTRAST is


--COMPONENT ila_0

--PORT (
--	clk : IN STD_LOGIC;



--	probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
--);
--END COMPONENT;

--signal probe0 : STD_LOGIC_VECTOR(127 DOWNTO 0);

--signal VIDEO_DATA: signed(bit_width+1 downto 0);
--signal VIDEO_DATA_CONTRAST:signed(bit_width+1+32 downto 0);
--signal VIDEO_DATA_OUT: signed(bit_width+33 downto 0);
--signal BRIGHTNESS:signed(31 downto 0);
--signal CONTRAST: unsigned(31 downto 0);

--signal BRIGHTNESS_TEMP:signed(31 downto 0);
--signal CONTRAST_TEMP: unsigned(31 downto 0);

--signal VIDEO_O_EOIi,  VIDEO_O_EOIii    :   std_logic;
--signal VIDEO_O_DAVi,  VIDEO_O_DAVii    :   std_logic;

--signal start_div : std_logic;
--signal dvsr      : std_logic_vector(31 downto 0);
--signal dvnd      : std_logic_vector(31 downto 0);
--signal done_tick : STD_LOGIC;
--signal quo       : STD_LOGIC_VECTOR(31 downto 0);
--signal rmd       : STD_LOGIC_VECTOR(31 downto 0);

--constant BRIGHTNESS_MULT  : positive := ((2**(bit_width+1))-1)/50;    -- brightness range -255 to +255,  user input 0 to 100  
--                                                       -- 0   means brightness = -255  
--                                                       -- 50  means brightness = 0
--                                                       -- 100 means brightness = +255
--                                                       -- dvsr = 50
--constant CONTRAST_DVSR : positive := 50;  -- contrast range 0.00 to 2.00  , user input 0 to 100
--                                          -- 0   means contrast = 0   (0/50)
--                                          -- 50  means contrast = 1   (50/50)
--                                          -- 100 means contrast = 2   (100/50)


--ATTRIBUTE MARK_DEBUG : string;
--ATTRIBUTE MARK_DEBUG of  BRIGHTNESS_TEMP  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  CONTRAST_TEMP    : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  done_tick    : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  dvnd    : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  start_div   : SIGNAL IS "TRUE";


--ATTRIBUTE MARK_DEBUG of VIDEO_I_V   : SIGNAL IS "TRUE";   
--ATTRIBUTE MARK_DEBUG of VIDEO_I_H   : SIGNAL IS "TRUE";   
--ATTRIBUTE MARK_DEBUG of VIDEO_I_EOI : SIGNAL IS "TRUE";   
--ATTRIBUTE MARK_DEBUG of VIDEO_I_DAV : SIGNAL IS "TRUE";   

--begin




---- 9 bits of video data (make it signed)
--VIDEO_DATA<=signed('0' & VIDEO_I_DATA);

----latch the control signals only at the starting of the video
--process(CLK, RST)
--variable BRIGHTNESS_MULT_OUT : signed(63 downto 0);
--begin
--  if RST='1' then
--    BRIGHTNESS <= to_signed(0,BRIGHTNESS'length);
--    CONTRAST <= to_unsigned(2**16, CONTRAST'length);
--    BRIGHTNESS_TEMP <= to_signed(0,BRIGHTNESS'length);
--    CONTRAST_TEMP <= to_unsigned(2**16, CONTRAST'length);
--    dvnd <= (others=>'0');
--    dvsr <= (others=>'0');
--    start_div <= '0';
--  elsif rising_edge(CLK) then
--  -- At the start of frame decide brightness and contrast only if enabled
--    if VIDEO_I_V='1' and ENABLE='1' then  
--        start_div <= '1';
--        dvsr  <= STD_LOGIC_VECTOR(to_unsigned(CONTRAST_DVSR,dvsr'length));
--        if unsigned(CTRL_CONTRAST) >= 100 then
--            dvnd <= STD_LOGIC_VECTOR(to_unsigned(100,16)) & x"0000";
--        else
--            dvnd  <= CTRL_CONTRAST(15 downto 0) & x"0000" ;
--        end if;
        
        
--        if unsigned(CTRL_BRIGHT)>= 100 then
--            BRIGHTNESS_TEMP <= to_signed(255,BRIGHTNESS'length);
--        elsif unsigned(CTRL_BRIGHT)= 0 then
--            BRIGHTNESS_TEMP <= to_signed(-255,BRIGHTNESS'length);
--        else
--            BRIGHTNESS_MULT_OUT := signed((unsigned(CTRL_BRIGHT) - 50)*BRIGHTNESS_MULT);
--            BRIGHTNESS_TEMP <= signed(BRIGHTNESS_MULT_OUT(31 downto 0));
--        end if;
        
--        CONTRAST   <= CONTRAST_TEMP;
--        BRIGHTNESS <= BRIGHTNESS_TEMP;
--    elsif VIDEO_I_V='1' and ENABLE='0' then
--        BRIGHTNESS <= to_signed(0,BRIGHTNESS'length);
--        CONTRAST <= to_unsigned(2**16, CONTRAST'length);
--    else
--        start_div <= '0';
--    end if;
    
--    if(done_tick = '1') then
--        CONTRAST_TEMP <= unsigned(quo);
--    else
--        CONTRAST_TEMP <= CONTRAST_TEMP;
--    end if;
     
--  end if;
--end process;

--process(CLK, RST)
--begin
--  if RST='1' then
--    VIDEO_DATA_OUT<=(others=>'0');
--    VIDEO_DATA_CONTRAST<=(others=>'0');
--    VIDEO_O_DATA <=(others=>'0');
--    VIDEO_O_DAV <= '0';
--    VIDEO_O_DAVi <= '0';
--    VIDEO_O_DAVii <= '0';
--    VIDEO_O_EOI<='0';
--    VIDEO_O_EOIi<='0';
--    VIDEO_O_EOIii<='0';
--    VIDEO_O_XSIZE <= (others =>'0');
--    VIDEO_O_YSIZE <= (others =>'0');

--    VIDEO_O_V <='0';
--    VIDEO_O_H<='0';
    
--  elsif rising_edge(CLK) then

--    VIDEO_O_V <= VIDEO_I_V;
--    VIDEO_O_H <= VIDEO_I_H;
--    VIDEO_O_XSIZE <= VIDEO_I_XSIZE;
--    VIDEO_O_YSIZE <= VIDEO_I_YSIZE;
    
--    VIDEO_O_DAVi <= VIDEO_I_DAV;
--    VIDEO_O_DAVii <= VIDEO_O_DAVi;
--    VIDEO_O_DAV <= VIDEO_O_DAVii;

--    VIDEO_O_EOIi <= VIDEO_I_EOI;
--    VIDEO_O_EOIii <= VIDEO_O_EOIi;
--    VIDEO_O_EOI <= VIDEO_O_EOIii;

--    VIDEO_DATA_CONTRAST<=signed(VIDEO_DATA)*signed(CONTRAST);
--    VIDEO_DATA_OUT<=signed(VIDEO_DATA_CONTRAST)+signed(BRIGHTNESS(16 downto 0) & x"0000");
--    if signed(VIDEO_DATA_OUT(VIDEO_DATA_OUT'length-1 downto 16))>(2**(bit_width+1)-1) then
--      VIDEO_O_DATA <= std_logic_vector(to_unsigned((2**(bit_width+1)-1), VIDEO_O_DATA'length));
--    elsif signed(VIDEO_DATA_OUT(VIDEO_DATA_OUT'length-1 downto 16))<0 then
--      VIDEO_O_DATA <= std_logic_vector(to_unsigned(0, VIDEO_O_DATA'length));
--    else
--      VIDEO_O_DATA <= std_logic_vector(VIDEO_DATA_OUT(bit_width+16 downto 16));
--    end if;
--  end if ;
--end process;


-- i_nuc_div : entity WORK.div
-- generic map(
--  W    => 32,
--  CBIT => 6
--  )
-- port map(

--  clk  => CLK,
--  reset => RST,
--  start => start_div ,
--  dvsr =>  dvsr, 
--  dvnd => dvnd,
--  done_tick => done_tick,
--  quo => quo, 
--  rmd => rmd
--  );
  
----  probe0(0) <= VIDEO_I_V    ;
----  probe0(1) <= VIDEO_I_H    ;
----  probe0(2) <= VIDEO_I_DAV  ;
----  probe0(3) <= VIDEO_I_EOI  ;
----  probe0(35 downto 4)   <= std_logic_vector(BRIGHTNESS_TEMP) ;
----  probe0(67 downto 36)  <= std_logic_vector(CONTRAST_TEMP);
----  probe0(99 downto 68)  <= std_logic_vector(dvnd);
----  probe0(100)  <= start_div;
----  probe0(101)  <= done_tick;
----  probe0(127 downto 102)  <= (others=>'0');

  
----  i_ila_BRIGHT_CONTRAST: ila_0
----  PORT MAP (
----      clk => CLK,
----      probe0 => probe0
----  );

--end behave;