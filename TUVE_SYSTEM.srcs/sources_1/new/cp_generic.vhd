library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cp_generic is
    port (
        clk	 	: in std_logic;
        palette : in std_logic_vector(4 downto 0);
        addr 	: in std_logic_vector(7 downto 0);
        r_dout 	: out std_logic_vector(7 downto 0);
        g_dout 	: out std_logic_vector(7 downto 0);
        b_dout	: out std_logic_vector(7 downto 0)
    );
end entity cp_generic;

architecture rom of cp_generic is

signal cr0,cr1,cg0,cg1,cb0,cb1: signed(18 downto 0);
signal cr1_d,cg1_d,cb1_d: signed(27 downto 0);
signal cr0_x, cg0_x, cb0_x: signed(27 downto 0);
signal cr0_x_cr1, cg0_x_cg1, cb0_x_cb1: signed(28 downto 0);
signal addr_d: std_logic_vector(7 downto 0);

signal probe0 :std_logic_vector(127 downto 0);

--COMPONENT ila_0

--PORT (
--	clk : IN STD_LOGIC;



--	probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
--);
--END COMPONENT;



--ATTRIBUTE MARK_DEBUG : string;
--ATTRIBUTE MARK_DEBUG of  cg0         : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  cg1_d       : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  cg1         : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  cg0_x       : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  cg0_x_cg1   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  addr_d      : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  addr        : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  palette     : SIGNAL IS "TRUE";

begin
-- piecewise linear interpolation for color palette generation
-- Equation c0*x+c1;

process(clk)
begin
	if rising_edge(clk) then

		addr_d <= addr;

		cr1_d <= resize(cr1, cr1_d'length) ;
		cg1_d <= resize(cg1, cg1_d'length) ;
		cb1_d <= resize(cb1, cb1_d'length) ;

		cr0_x <= signed('0' & addr_d)*cr0;
		cg0_x <= signed('0' & addr_d)*cg0;
		cb0_x <= signed('0' & addr_d)*cb0;

--		cr0_x_cr1 <= resize(cr0_x,cr0_x_cr1'length) + resize(cr1_d,cr0_x_cr1'length);
--		cg0_x_cg1 <= resize(cg0_x,cr0_x_cr1'length) + resize(cg1_d,cr0_x_cr1'length);
--		cb0_x_cb1 <= resize(cb0_x,cr0_x_cr1'length) + resize(cb1_d,cr0_x_cr1'length);
		
	    cr0_x_cr1 <= resize(cr0_x + cr1_d,cr0_x_cr1'length);
        cg0_x_cg1 <= resize(cg0_x + cg1_d,cg0_x_cg1'length);
        cb0_x_cb1 <= resize(cb0_x + cb1_d,cb0_x_cb1'length);
		

		if(cr0_x_cr1(cr0_x_cr1'length-1)='1') then
			r_dout <= std_logic_vector(to_unsigned(0,r_dout'length));
		elsif(cr0_x_cr1(cr0_x_cr1'length-1 downto 8)>255) then
			r_dout <= std_logic_vector(to_unsigned(255,r_dout'length));
		else
			r_dout <= std_logic_vector( cr0_x_cr1(15 downto 8) );
		end if;

		if(cg0_x_cg1(cg0_x_cg1'length-1)='1') then
			g_dout <= std_logic_vector(to_unsigned(0,g_dout'length));
		elsif(cg0_x_cg1(cg0_x_cg1'length-1 downto 8)>255) then
			g_dout <= std_logic_vector(to_unsigned(255,g_dout'length));
		else
			g_dout <= std_logic_vector( cg0_x_cg1(15 downto 8) );
		end if;

		if(cb0_x_cb1(cb0_x_cb1'length-1)='1') then
			b_dout <= std_logic_vector(to_unsigned(0,b_dout'length));
		elsif(cb0_x_cb1(cb0_x_cb1'length-1 downto 8)>255) then
			b_dout <= std_logic_vector(to_unsigned(255,b_dout'length));
		else
			b_dout <= std_logic_vector( cb0_x_cb1(15 downto 8) );
		end if;

		if (unsigned(addr)<32) then
			case(to_integer(unsigned(palette(3 downto 0)))) is
		        when 0 =>
		                cr0<=to_signed(512, cr0'length); cr1<=to_signed(0, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(0, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(32256, cb1'length);
		        when 1 =>
		                cr0<=to_signed(524, cr0'length); cr1<=to_signed(-39, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(0, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(0, cb1'length);
		        when 2 =>
		                cr0<=to_signed(494, cr0'length); cr1<=to_signed(4308, cr1'length);
		                cg0<=to_signed(-37, cg0'length); cg1<=to_signed(1681, cg1'length);
		                cb0<=to_signed(209, cb0'length); cb1<=to_signed(35009, cb1'length);
		        when 3 =>
		                cr0<=to_signed(235, cr0'length); cr1<=to_signed(-886, cr1'length);
		                cg0<=to_signed(148, cg0'length); cg1<=to_signed(-388, cg1'length);
		                cb0<=to_signed(546, cb0'length); cb1<=to_signed(96, cb1'length);
		        when 4 =>
		                cr0<=to_signed(264, cr0'length); cr1<=to_signed(-1100, cr1'length);
		                cg0<=to_signed(117, cg0'length); cg1<=to_signed(-231, cg1'length);
		                cb0<=to_signed(580, cb0'length); cb1<=to_signed(52, cb1'length);
		        when 5 =>
		                cr0<=to_signed(27, cr0'length); cr1<=to_signed(17756, cr1'length);
		                cg0<=to_signed(353, cg0'length); cg1<=to_signed(297, cg1'length);
		                cb0<=to_signed(322, cb0'length); cb1<=to_signed(21834, cb1'length);
		        when 6 =>
		                cr0<=to_signed(22, cr0'length); cr1<=to_signed(-4, cr1'length);
		                cg0<=to_signed(128, cg0'length); cg1<=to_signed(14394, cg1'length);
		                cb0<=to_signed(119, cb0'length); cb1<=to_signed(14829, cb1'length);
		        when others =>
		                cr0<=to_signed(512, cr0'length); cr1<=to_signed(0, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(0, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(32256, cb1'length);
		    end case;
		elsif (unsigned(addr)<64) then
			case(to_integer(unsigned(palette(3 downto 0)))) is
		        when 0 =>
		                cr0<=to_signed(502, cr0'length); cr1<=to_signed(314, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(0, cg1'length);
		                cb0<=to_signed(12, cb0'length); cb1<=to_signed(31858, cb1'length);
		        when 1 =>
		                cr0<=to_signed(522, cr0'length); cr1<=to_signed(-58, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(0, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(0, cb1'length);
		        when 2 =>
		                cr0<=to_signed(401, cr0'length); cr1<=to_signed(6780, cr1'length);
		                cg0<=to_signed(-5, cg0'length); cg1<=to_signed(373, cg1'length);
		                cb0<=to_signed(57, cb0'length); cb1<=to_signed(39894, cb1'length);
		        when 3 =>
		                cr0<=to_signed(424, cr0'length); cr1<=to_signed(-6571, cr1'length);
		                cg0<=to_signed(-13, cg0'length); cg1<=to_signed(4714, cg1'length);
		                cb0<=to_signed(448, cb0'length); cb1<=to_signed(4936, cb1'length);
		        when 4 =>
		                cr0<=to_signed(438, cr0'length); cr1<=to_signed(-5606, cr1'length);
		                cg0<=to_signed(22, cg0'length); cg1<=to_signed(1693, cg1'length);
		                cb0<=to_signed(282, cb0'length); cb1<=to_signed(11503, cb1'length);
		        when 5 =>
		                cr0<=to_signed(-101, cr0'length); cr1<=to_signed(21590, cr1'length);
		                cg0<=to_signed(303, cg0'length); cg1<=to_signed(1771, cg1'length);
		                cb0<=to_signed(128, cb0'length); cb1<=to_signed(27875, cb1'length);
		        when 6 =>
		                cr0<=to_signed(21, cr0'length); cr1<=to_signed(43, cr1'length);
		                cg0<=to_signed(122, cg0'length); cg1<=to_signed(14611, cg1'length);
		                cb0<=to_signed(119, cb0'length); cb1<=to_signed(14868, cb1'length);
		        when others =>
		                cr0<=to_signed(502, cr0'length); cr1<=to_signed(314, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(0, cg1'length);
		                cb0<=to_signed(12, cb0'length); cb1<=to_signed(31858, cb1'length);
	        end case;
		elsif (unsigned(addr)<96) then
			case(to_integer(unsigned(palette(3 downto 0)))) is
		        when 0 =>
		                cr0<=to_signed(522, cr0'length); cr1<=to_signed(-956, cr1'length);
		                cg0<=to_signed(516, cg0'length); cg1<=to_signed(-32930, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(32512, cb1'length);
		        when 1 =>
		                cr0<=to_signed(502, cr0'length); cr1<=to_signed(1212, cr1'length);
		                cg0<=to_signed(516, cg0'length); cg1<=to_signed(-32930, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(0, cb1'length);
		        when 2 =>
		                cr0<=to_signed(350, cr0'length); cr1<=to_signed(10054, cr1'length);
		                cg0<=to_signed(267, cg0'length); cg1<=to_signed(-16922, cg1'length);
		                cb0<=to_signed(-149, cb0'length); cb1<=to_signed(52985, cb1'length);
		        when 3 =>
		                cr0<=to_signed(400, cr0'length); cr1<=to_signed(-4963, cr1'length);
		                cg0<=to_signed(160, cg0'length); cg1<=to_signed(-5700, cg1'length);
		                cb0<=to_signed(44, cb0'length); cb1<=to_signed(29227, cb1'length);
		        when 4 =>
		                cr0<=to_signed(407, cr0'length); cr1<=to_signed(-3776, cr1'length);
		                cg0<=to_signed(148, cg0'length); cg1<=to_signed(-5519, cg1'length);
		                cb0<=to_signed(-26, cb0'length); cb1<=to_signed(29981, cb1'length);
		        when 5 =>
		                cr0<=to_signed(-116, cr0'length); cr1<=to_signed(22249, cr1'length);
		                cg0<=to_signed(262, cg0'length); cg1<=to_signed(4292, cg1'length);
		                cb0<=to_signed(24, cb0'length); cb1<=to_signed(34245, cb1'length);
		        when 6 =>
		                cr0<=to_signed(126, cr0'length); cr1<=to_signed(-6645, cr1'length);
		                cg0<=to_signed(174, cg0'length); cg1<=to_signed(11355, cg1'length);
		                cb0<=to_signed(178, cb0'length); cb1<=to_signed(11149, cb1'length);
		        when others =>
		                cr0<=to_signed(522, cr0'length); cr1<=to_signed(-956, cr1'length);
		                cg0<=to_signed(516, cg0'length); cg1<=to_signed(-32930, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(32512, cb1'length);
	        end case;
		elsif (unsigned(addr)<128) then
			case(to_integer(unsigned(palette(3 downto 0)))) is
		        when 0 =>
		                cr0<=to_signed(512, cr0'length); cr1<=to_signed(0, cr1'length);
		                cg0<=to_signed(512, cg0'length); cg1<=to_signed(-32653, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(32512, cb1'length);
		        when 1 =>
		                cr0<=to_signed(500, cr0'length); cr1<=to_signed(1462, cr1'length);
		                cg0<=to_signed(512, cg0'length); cg1<=to_signed(-32653, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(0, cb1'length);
		        when 2 =>
		                cr0<=to_signed(272, cr0'length); cr1<=to_signed(17542, cr1'length);
		                cg0<=to_signed(290, cg0'length); cg1<=to_signed(-18928, cg1'length);
		                cb0<=to_signed(-240, cb0'length); cb1<=to_signed(61334, cb1'length);
		        when 3 =>
		                cr0<=to_signed(417, cr0'length); cr1<=to_signed(-6577, cr1'length);
		                cg0<=to_signed(135, cg0'length); cg1<=to_signed(-3387, cg1'length);
		                cb0<=to_signed(-62, cb0'length); cb1<=to_signed(39280, cb1'length);
		        when 4 =>
		                cr0<=to_signed(399, cr0'length); cr1<=to_signed(-2917, cr1'length);
		                cg0<=to_signed(162, cg0'length); cg1<=to_signed(-6953, cg1'length);
		                cb0<=to_signed(-171, cb0'length); cb1<=to_signed(43858, cb1'length);
		        when 5 =>
		                cr0<=to_signed(-95, cr0'length); cr1<=to_signed(20330, cr1'length);
		                cg0<=to_signed(244, cg0'length); cg1<=to_signed(5814, cg1'length);
		                cb0<=to_signed(-8, cb0'length); cb1<=to_signed(37212, cb1'length);
		        when 6 =>
		                cr0<=to_signed(125, cr0'length); cr1<=to_signed(-6636, cr1'length);
		                cg0<=to_signed(175, cg0'length); cg1<=to_signed(11294, cg1'length);
		                cb0<=to_signed(179, cb0'length); cb1<=to_signed(11064, cb1'length);
		        when others =>
		                cr0<=to_signed(512, cr0'length); cr1<=to_signed(0, cr1'length);
		                cg0<=to_signed(512, cg0'length); cg1<=to_signed(-32653, cg1'length);
		                cb0<=to_signed(0, cb0'length); cb1<=to_signed(32512, cb1'length);
	        end case;
		elsif (unsigned(addr)<160) then
			case(to_integer(unsigned(palette(3 downto 0)))) is
		        when 0 =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(517, cg0'length); cg1<=to_signed(-33190, cg1'length);
		                cb0<=to_signed(-10, cb0'length); cb1<=to_signed(33722, cb1'length);
		        when 1 =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(517, cg0'length); cg1<=to_signed(-33190, cg1'length);
		                cb0<=to_signed(512, cb0'length); cb1<=to_signed(-65280, cb1'length);
		        when 2 =>
		                cr0<=to_signed(212, cr0'length); cr1<=to_signed(25170, cr1'length);
		                cg0<=to_signed(297, cg0'length); cg1<=to_signed(-19892, cg1'length);
		                cb0<=to_signed(-226, cb0'length); cb1<=to_signed(59559, cb1'length);
		        when 3 =>
		                cr0<=to_signed(392, cr0'length); cr1<=to_signed(-3119, cr1'length);
		                cg0<=to_signed(205, cg0'length); cg1<=to_signed(-12642, cg1'length);
		                cb0<=to_signed(-182, cb0'length); cb1<=to_signed(54491, cb1'length);
		        when 4 =>
		                cr0<=to_signed(326, cr0'length); cr1<=to_signed(6670, cr1'length);
		                cg0<=to_signed(279, cg0'length); cg1<=to_signed(-22037, cg1'length);
		                cb0<=to_signed(-279, cb0'length); cb1<=to_signed(57367, cb1'length);
		        when 5 =>
		                cr0<=to_signed(49, cr0'length); cr1<=to_signed(1263, cr1'length);
		                cg0<=to_signed(241, cg0'length); cg1<=to_signed(6226, cg1'length);
		                cb0<=to_signed(-96, cb0'length); cb1<=to_signed(48441, cb1'length);
		        when 6 =>
		                cr0<=to_signed(256, cr0'length); cr1<=to_signed(-23296, cr1'length);
		                cg0<=to_signed(256, cg0'length); cg1<=to_signed(1024, cg1'length);
		                cb0<=to_signed(248, cb0'length); cb1<=to_signed(2258, cb1'length);
		        when others =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(517, cg0'length); cg1<=to_signed(-33190, cg1'length);
		                cb0<=to_signed(-10, cb0'length); cb1<=to_signed(33722, cb1'length);
	        end case;
		elsif (unsigned(addr)<192) then
			case(to_integer(unsigned(palette(3 downto 0)))) is
		        when 0 =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(510, cg0'length); cg1<=to_signed(-32248, cg1'length);
		                cb0<=to_signed(-12, cb0'length); cb1<=to_signed(34186, cb1'length);
		        when 1 =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(510, cg0'length); cg1<=to_signed(-32248, cg1'length);
		                cb0<=to_signed(522, cb0'length); cb1<=to_signed(-66801, cb1'length);
		        when 2 =>
		                cr0<=to_signed(149, cr0'length); cr1<=to_signed(35286, cr1'length);
		                cg0<=to_signed(328, cg0'length); cg1<=to_signed(-24807, cg1'length);
		                cb0<=to_signed(-222, cb0'length); cb1<=to_signed(58916, cb1'length);
		        when 3 =>
		                cr0<=to_signed(170, cr0'length); cr1<=to_signed(32557, cr1'length);
		                cg0<=to_signed(448, cg0'length); cg1<=to_signed(-51294, cg1'length);
		                cb0<=to_signed(-19, cb0'length); cb1<=to_signed(27408, cb1'length);
		        when 4 =>
		                cr0<=to_signed(178, cr0'length); cr1<=to_signed(30309, cr1'length);
		                cg0<=to_signed(420, cg0'length); cg1<=to_signed(-44451, cg1'length);
		                cb0<=to_signed(-331, cb0'length); cb1<=to_signed(65541, cb1'length);
		        when 5 =>
		                cr0<=to_signed(432, cr0'length); cr1<=to_signed(-59762, cr1'length);
		                cg0<=to_signed(217, cg0'length); cg1<=to_signed(9969, cg1'length);
		                cb0<=to_signed(-241, cb0'length); cb1<=to_signed(71652, cb1'length);
		        when 6 =>
		                cr0<=to_signed(256, cr0'length); cr1<=to_signed(-23296, cr1'length);
		                cg0<=to_signed(251, cg0'length); cg1<=to_signed(1914, cg1'length);
		                cb0<=to_signed(255, cb0'length); cb1<=to_signed(1271, cb1'length);
		        when others =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(510, cg0'length); cg1<=to_signed(-32248, cg1'length);
		                cb0<=to_signed(-12, cb0'length); cb1<=to_signed(34186, cb1'length);
	        end case;
		elsif (unsigned(addr)<224) then
			case(to_integer(unsigned(palette(3 downto 0)))) is
		        when 0 =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(65280, cg1'length);
		                cb0<=to_signed(281, cb0'length); cb1<=to_signed(-21628, cb1'length);
		        when 1 =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(65280, cg1'length);
		                cb0<=to_signed(502, cb0'length); cb1<=to_signed(-62962, cb1'length);
		        when 2 =>
		                cr0<=to_signed(44, cr0'length); cr1<=to_signed(55605, cr1'length);
		                cg0<=to_signed(380, cg0'length); cg1<=to_signed(-34901, cg1'length);
		                cb0<=to_signed(-203, cb0'length); cb1<=to_signed(55270, cb1'length);
		        when 3 =>
		                cr0<=to_signed(23, cr0'length); cr1<=to_signed(60300, cr1'length);
		                cg0<=to_signed(479, cg0'length); cg1<=to_signed(-57035, cg1'length);
		                cb0<=to_signed(310, cb0'length); cb1<=to_signed(-35086, cb1'length);
		        when 4 =>
		                cr0<=to_signed(-6, cr0'length); cr1<=to_signed(65503, cr1'length);
		                cg0<=to_signed(493, cg0'length); cg1<=to_signed(-58294, cg1'length);
		                cb0<=to_signed(372, cb0'length); cb1<=to_signed(-72110, cb1'length);
		        when 5 =>
		                cr0<=to_signed(635, cr0'length); cr1<=to_signed(-98140, cr1'length);
		                cg0<=to_signed(156, cg0'length); cg1<=to_signed(21742, cg1'length);
		                cb0<=to_signed(-398, cb0'length); cb1<=to_signed(101654, cb1'length);
		        when 6 =>
		                cr0<=to_signed(620, cr0'length); cr1<=to_signed(-92804, cr1'length);
		                cg0<=to_signed(244, cg0'length); cg1<=to_signed(3109, cg1'length);
		                cb0<=to_signed(244, cb0'length); cb1<=to_signed(3109, cb1'length);
		        when others =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(65280, cg1'length);
		                cb0<=to_signed(281, cb0'length); cb1<=to_signed(-21628, cb1'length);
	        end case;
		else
			case(to_integer(unsigned(palette(3 downto 0)))) is
		        when 0 =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(65280, cg1'length);
		                cb0<=to_signed(280, cb0'length); cb1<=to_signed(-21568, cb1'length);
		        when 1 =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(65280, cg1'length);
		                cb0<=to_signed(512, cb0'length); cb1<=to_signed(-65280, cb1'length);
		        when 2 =>
		                cr0<=to_signed(-117, cr0'length); cr1<=to_signed(91623, cr1'length);
		                cg0<=to_signed(432, cg0'length); cg1<=to_signed(-46361, cg1'length);
		                cb0<=to_signed(-2, cb0'length); cb1<=to_signed(9982, cb1'length);
		        when 3 =>
		                cr0<=to_signed(-24, cr0'length); cr1<=to_signed(70553, cr1'length);
		                cg0<=to_signed(468, cg0'length); cg1<=to_signed(-54525, cg1'length);
		                cb0<=to_signed(456, cb0'length); cb1<=to_signed(-67408, cb1'length);
		        when 4 =>
		                cr0<=to_signed(1, cr0'length); cr1<=to_signed(62617, cr1'length);
		                cg0<=to_signed(431, cg0'length); cg1<=to_signed(-43836, cg1'length);
		                cb0<=to_signed(957, cb0'length); cb1<=to_signed(-202366, cb1'length);
		        when 5 =>
		                cr0<=to_signed(669, cr0'length); cr1<=to_signed(-105470, cr1'length);
		                cg0<=to_signed(88, cg0'length); cg1<=to_signed(36967, cg1'length);
		                cb0<=to_signed(-124, cb0'length); cb1<=to_signed(37792, cb1'length);
		        when 6 =>
		                cr0<=to_signed(620, cr0'length); cr1<=to_signed(-92874, cr1'length);
		                cg0<=to_signed(240, cg0'length); cg1<=to_signed(3939, cg1'length);
		                cb0<=to_signed(240, cb0'length); cb1<=to_signed(3939, cb1'length);
		        when others =>
		                cr0<=to_signed(0, cr0'length); cr1<=to_signed(65280, cr1'length);
		                cg0<=to_signed(0, cg0'length); cg1<=to_signed(65280, cg1'length);
		                cb0<=to_signed(280, cb0'length); cb1<=to_signed(-21568, cb1'length);
	        end case;
		end if;
	end if;
end process;

--probe0(18 downto 0)  <= std_logic_vector(cg0)  ;
--probe0(46 downto 19) <= std_logic_vector(cg1_d);
--probe0(74 downto 47) <= std_logic_vector(cg0_x)        ;
--probe0(103 downto 75) <= std_logic_vector(cg0_x_cg1)  ;
--probe0(111 downto 104) <= addr_d     ;
--probe0(115 downto 112) <= palette    ;
--probe0(116) <= clk; 
--probe0(127 downto 117) <= (others=>'0');

--i_ila_cp: ila_0
--PORT MAP (
--	clk => clk,
--	probe0 => probe0
--);


end rom;