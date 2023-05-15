library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rgb2ycbcr is
generic(
	bit_width : integer := 23;						   -- Actually (bit_width - 1)
	VIDEO_XSIZE :integer := 640;
	VIDEO_YSIZE :integer := 512
	);

port(
	CLK			  : in std_logic;
	RST			  : in std_logic;

	--Enable
	--ENABLE 	  	  : in std_logic;	

	--Input from Bad Pixel Removal block
	VIDEO_I_V     : in  std_logic;                      -- Video Input Vertical Synchro
	VIDEO_I_H     : in  std_logic;                      -- Video Input Horizontal Synchro
	VIDEO_I_EOI   : in  std_logic;                      -- Video Input End Of Image
	VIDEO_I_DAV   : in  std_logic;                      -- Video Input Data Valid
	VIDEO_I_DATA  : in  std_logic_vector(bit_width downto 0);  -- Video Input Data
	VIDEO_I_XSIZE : in  std_logic_vector( 10 downto 0);  -- Video X Size
	VIDEO_I_YSIZE : in  std_logic_vector( 9 downto 0);  -- Video Y Size
	--VIDEO_I_XCNT  : in  std_logic_vector( 9 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
	--VIDEO_I_YCNT  : in  std_logic_vector( 9 downto 0);  -- Video Y Line  Counter (1st line  = 0)


	-- Output to AGC block
	VIDEO_O_V     : out std_logic;                      -- Video Output Vertical Synchro
	VIDEO_O_H     : out std_logic;                      -- Video Output Horizontal Synchro
	VIDEO_O_EOI   : out std_logic;                      -- Video Output End Of Image
	VIDEO_O_DAV   : out std_logic;                      -- Video Output Data Valid
	VIDEO_O_DATA  : out std_logic_vector( bit_width downto 0);  -- Video Output Data
	VIDEO_O_XSIZE : out std_logic_vector( 10 downto 0);  -- Video X Size
	VIDEO_O_YSIZE : out std_logic_vector( 9 downto 0)  -- Video Y Size
	--VIDEO_O_XCNT  : out std_logic_vector( 9 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
	--VIDEO_O_YCNT  : out std_logic_vector( 9 downto 0)   -- Video Y Line  Counter (1st line  = 0)

	);
end rgb2ycbcr;

architecture behave of rgb2ycbcr is

-- Equation for conversion
-- Y	= t11*R + t12*G + t13*B - Offset1
-- Cb	= t21*R + t22*G + t23*B - Offset2
-- Cr	= t31*R + t32*G + t33*B - Offset3

-- Fixed Point Format: signed 4.12 in 2's complement
-- T =
--	0.2568 (0000 0100 0001 1100)	0.5041 (0000 1000 0001 0001)	0.0979 (0000 0001 1001 0001)
--	-0.1482(1111 1101 1010 0001)	-0.2910(1111 1011 0101 1000)	0.4392 (0000 0111 0000 0111)
--	0.4392 (0000 0111 0000 0111)	-0.3678(1111 1010 0001 1101)	-0.0714(1111 1110 1101 1100)

-- Fixed Point Format: signed 13.12 in 2's complement
-- Offset =
--	16	(0 0000 0001 0000 0000 0000 0000)
--	128	(0 0000 1000 0000 0000 0000 0000)
--	128	(0 0000 1000 0000 0000 0000 0000)

-- Pipeline Diagram for Y Channel (Similar Diagrams for Cb and Cr Channels)
--     t11    r      t12    g      t13    b
--       \   /		   \   /		 \   /								- Stage 1
--         * t11r		 *	t12g 	   * t13b      offset1							     fixed-point(13.12)
--          \			/ 				\              /				- Stage 2
--				  +       s11                  +          s12							 fixed-point(14.12)
--                 \                          /							- Stage 3
--                               + Y  													 fixed-point(15.12)
--       						 |										- Stage 4

constant t11: signed(15 downto 0):= "0000010000011100";
constant t21: signed(15 downto 0):= "1111110110100001";
constant t31: signed(15 downto 0):= "0000011100000111";

constant t12: signed(15 downto 0):= "0000100000010001";
constant t22: signed(15 downto 0):= "1111101101011000";
constant t32: signed(15 downto 0):= "1111101000011101";

constant t13: signed(15 downto 0):= "0000000110010001";
constant t23: signed(15 downto 0):= "0000011100000111";
constant t33: signed(15 downto 0):= "1111111011011100";

constant offset1 : signed(24 downto 0):= "0000000010000000000000000";
constant offset2 : signed(24 downto 0):= "0000010000000000000000000";
constant offset3 : signed(24 downto 0):= "0000010000000000000000000";

signal r: signed(8 downto 0);
signal g: signed(8 downto 0);
signal b: signed(8 downto 0);

-- use 3 stage pipeline for computation
-- stage 1 signals all multiplications
signal t11r, t12g, t13b, t21r, t22g, t23b, t31r, t32g, t33b : signed(24 downto 0); -- (4.12)*(9)=(13.12)
-- stage 2 signals all addition/subtractions
signal s11, s12, s21, s22, s31, s32: signed(25 downto 0); -- (13.12)+(13.12)=(14.12) 
-- stage 3 signals remaining addtion/subtractions
signal Y, Cb, Cr: signed(26 downto 0); -- (14.12)+(14.12)=(15.12)

signal VIDEO_O_Vi,		VIDEO_O_Vii,		VIDEO_O_Viii:		std_logic;
signal VIDEO_O_Hi,		VIDEO_O_Hii,		VIDEO_O_Hiii:		std_logic;
signal VIDEO_O_EOIi,	VIDEO_O_EOIii,		VIDEO_O_EOIiii:		std_logic;
signal VIDEO_O_DAVi,	VIDEO_O_DAVii,		VIDEO_O_DAViii:		std_logic;
signal VIDEO_O_XSIZEi,	VIDEO_O_XSIZEii,	VIDEO_O_XSIZEiii:	std_logic_vector(VIDEO_I_XSIZE'range);
signal VIDEO_O_YSIZEi,	VIDEO_O_YSIZEii,	VIDEO_O_YSIZEiii:	std_logic_vector(VIDEO_I_YSIZE'range);
--signal VIDEO_O_XCNTi,	VIDEO_O_XCNTii,		VIDEO_O_XCNTiii:	std_logic_vector(VIDEO_I_XCNT'range);
--signal VIDEO_O_YCNTi,	VIDEO_O_YCNTii, 	VIDEO_O_YCNTiii:	std_logic_vector(VIDEO_I_YCNT'range);

begin 

r <= signed('0'& VIDEO_I_DATA(23 downto 16));
g <= signed('0'& VIDEO_I_DATA(15 downto 8));
b <= signed('0'& VIDEO_I_DATA(7 downto 0));

process(CLK, RST)
begin
	if RST='1' then
		t11r <= (others=>'0');
		t12g <= (others=>'0');
		t13b <= (others=>'0');
		t21r <= (others=>'0');
		t22g <= (others=>'0');
		t23b <= (others=>'0');
		t31r <= (others=>'0');
		t32g <= (others=>'0');
		t33b <= (others=>'0');

		s11 <= (others => '0');
		s12 <= (others => '0');
		s21 <= (others => '0');
		s22 <= (others => '0');
		s31 <= (others => '0');
		s32 <= (others => '0');

		Y <= (others =>'0');
		Cb <= (others =>'0');
		Cr <= (others =>'0');

		VIDEO_O_V <= '0';
		VIDEO_O_H <= '0';
		VIDEO_O_EOI <= '0';
		VIDEO_O_DAV <= '0';
		VIDEO_O_DATA <= (others =>'0');
		VIDEO_O_XSIZE <= (others =>'0');
		VIDEO_O_YSIZE <= (others =>'0');
		--VIDEO_O_XCNT <= (others =>'0');
		--VIDEO_O_YCNT <= (others =>'0');

		VIDEO_O_Vi <= '0';
		VIDEO_O_Hi <= '0';
		VIDEO_O_EOIi <= '0';
		VIDEO_O_DAVi <= '0';
		VIDEO_O_XSIZEi <= (others =>'0');
		VIDEO_O_YSIZEi <= (others =>'0');
		--VIDEO_O_XCNTi <= (others =>'0');
		--VIDEO_O_YCNTi <= (others =>'0');

		VIDEO_O_Vii <= '0';
		VIDEO_O_Hii <= '0';
		VIDEO_O_EOIii <= '0';
		VIDEO_O_DAVii <= '0';
		VIDEO_O_XSIZEii <= (others =>'0');
		VIDEO_O_YSIZEii <= (others =>'0');
		--VIDEO_O_XCNTii <= (others =>'0');
		--VIDEO_O_YCNTii <= (others =>'0');

		VIDEO_O_Viii <= '0';
		VIDEO_O_Hiii <= '0';
		VIDEO_O_EOIiii <= '0';
		VIDEO_O_DAViii <= '0';
		VIDEO_O_XSIZEiii <= (others =>'0');
		VIDEO_O_YSIZEiii <= (others =>'0');
		--VIDEO_O_XCNTiii <= (others =>'0');
		--VIDEO_O_YCNTiii <= (others =>'0');

	elsif rising_edge(CLK) then
-- 		Pipeline Registers
		VIDEO_O_V <= VIDEO_O_Viii;
		VIDEO_O_H <= VIDEO_O_Hiii;
		VIDEO_O_EOI <= VIDEO_O_EOIiii;
		VIDEO_O_DAV <= VIDEO_O_DAViii;
		VIDEO_O_XSIZE <= VIDEO_O_XSIZEiii;
		VIDEO_O_YSIZE <= VIDEO_O_YSIZEiii;
		--VIDEO_O_XCNT <= VIDEO_O_XCNTiii;
		--VIDEO_O_YCNT <= VIDEO_O_YCNTiii;

		VIDEO_O_Viii <= VIDEO_O_Vii;
		VIDEO_O_Hiii <= VIDEO_O_Hii;
		VIDEO_O_EOIiii <= VIDEO_O_EOIii;
		VIDEO_O_DAViii <= VIDEO_O_DAVii;
		VIDEO_O_XSIZEiii <= VIDEO_O_XSIZEii;
		VIDEO_O_YSIZEiii <= VIDEO_O_YSIZEii;
		--VIDEO_O_XCNTiii <= VIDEO_O_XCNTii;
		--VIDEO_O_YCNTiii <= VIDEO_O_YCNTii;

		VIDEO_O_Vii <= VIDEO_O_Vi;
		VIDEO_O_Hii <= VIDEO_O_Hi;
		VIDEO_O_EOIii <= VIDEO_O_EOIi;
		VIDEO_O_DAVii <= VIDEO_O_DAVi;
		VIDEO_O_XSIZEii <= VIDEO_O_XSIZEi;
		VIDEO_O_YSIZEii <= VIDEO_O_YSIZEi;
		--VIDEO_O_XCNTii <= VIDEO_O_XCNTi;
		--VIDEO_O_YCNTii <= VIDEO_O_YCNTi;

		VIDEO_O_Vi <= VIDEO_I_V;
		VIDEO_O_Hi <= VIDEO_I_H;
		VIDEO_O_EOIi <= VIDEO_I_EOI;
		VIDEO_O_DAVi <= VIDEO_I_DAV;
		VIDEO_O_XSIZEi <= VIDEO_I_XSIZE;
		VIDEO_O_YSIZEi <= VIDEO_I_YSIZE;
		--VIDEO_O_XCNTi <= VIDEO_I_XCNT;
		--VIDEO_O_YCNTi <= VIDEO_I_YCNT;
		
		-- Data Pipeline
		-- Stage 1
		t11r<=t11*r;
		t12g<=t12*g;
		t13b<=t13*b;

		t21r<=t21*r;
		t22g<=t22*g;
		t23b<=t23*b;

		t31r<=t31*r;
		t32g<=t32*g;
		t33b<=t33*b;
		
		--  Stage 2
		s11 <= resize(t11r + t12g,s11'length);
		s12 <= resize(t13b + offset1, s12'length);

		s21 <= resize(t21r + t22g, s21'length);
		s22 <= resize(t23b + offset2, s22'length);

		s31 <= resize(t31r + t32g, s31'length);
		s32 <= resize(t33b + offset3, s32'length);
		
		-- Stage 3
		Y	<= resize(s11 + s12, Y'length);
		Cb	<= resize(s21 + s22, Cb'length);
		Cr	<= resize(s31 + s32, Cr'length);
		
		-- Stage 4
		if (Cr(Cr'high downto 12)> 240) then
			VIDEO_O_DATA(15 downto 8) <= std_logic_vector(to_unsigned(240,8));
		elsif (Cr(Cr'high downto 12)< 16) then
			VIDEO_O_DATA(15 downto 8) <= std_logic_vector(to_unsigned(16,8));
		else
			VIDEO_O_DATA(15 downto 8) <= std_logic_vector(Cr(19 downto 12));
		end if;

		if (Cb(Cb'high downto 12)> 240) then
			VIDEO_O_DATA(7 downto 0) <= std_logic_vector(to_unsigned(240,8));
		elsif (Cb(Cb'high downto 12)< 16) then
			VIDEO_O_DATA(7 downto 0) <= std_logic_vector(to_unsigned(16,8));
		else
			VIDEO_O_DATA(7 downto 0) <= std_logic_vector(Cb(19 downto 12));
		end if;

		if (Y(Y'high downto 12)> 235) then
			VIDEO_O_DATA(23 downto 16) <= std_logic_vector(to_unsigned(235,8));
		elsif (Y(Y'high downto 12)< 16) then
			VIDEO_O_DATA(23 downto 16) <= std_logic_vector(to_unsigned(16,8));
		else
			VIDEO_O_DATA(23 downto 16) <= std_logic_vector(Y(19 downto 12));
		end if;
		
	end if;
end process;

end behave;