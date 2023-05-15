--		This Divider Module is generic and can be used for dividing any input Dividend
-- with a Divisor of half its bit-length. It is iterative, not pipelined, which
-- means that the Non-Restoring Division Algorithm takes only one input in
-- <DivisorSize> clock cycles, and gives the output at the end of those cycles.
--		A hard limit upon the function of this module has been placed at a 32b Divisor
-- and a 63b Dividend, because if you plan to divide by a 32b Divisor, you are
-- using the wrong algorithm, and there is probably an IP better suited to this
-- purpose.
--		At your own risk, and patience, increase the size of the Count signal to the
-- log_base_2(DivisorSize) if it is more than 32b long, and change the relevant comparators
-- and assignments in the COUNTER process.
--		Design was made iterative due to lack of severe throughput constraints upon
-- division that takes place in the HIST_EQUALIZATION module. If any such constraints
-- do exist, use a pipelined version of the same, which will use much more hardware,
-- and will probably be limited to a constant size. Also, you'll have to write that
-- code yourself. Good luck.
-- Implemented Non Restoring Divider Concept from http://stackoverflow.com/questions/12133810/non-restoring-division-algorithm

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Divider_Generic_NRA is
	GENERIC(
		DivisorSize	: positive := 9		-- No. of bits 
	);
	PORT(
		RST			: in std_logic;
		CLK			: in std_logic;
		Div_EN		: in std_logic;
		Dividend	: in std_logic_vector (62 downto 0);
		Divisor		: in std_logic_vector (31 downto 0);
		Quotient	: out std_logic_vector (31 downto 0);
		Done		: out std_logic
	);
end entity Divider_Generic_NRA;

architecture RTL_Iterative of Divider_Generic_NRA is

signal I, I2	: std_logic_vector (31 downto 0);
signal A		: std_logic_vector (31 downto 0);
signal Q		: std_logic_vector (31 downto 0);
signal Count	: std_logic_vector (4 downto 0);	-- Max Size = 31, but if you want to do 32b division,
signal Run		: std_logic;						-- don't.
signal Done_Sig : std_logic;
signal Y		: std_logic_vector (31 downto 0);

begin
	
	COUNTER: process(RST,CLK)
	begin
		if(RST = '1') then
			Count <= (others => '0');
			Done_Sig <= '0';
			Run <= '0';
		elsif(rising_edge(CLK)) then
			if(Div_EN = '1' and Run = '0') then
				Count <= "00001";
				Run <= '1';
				Done_Sig <= '0';
			elsif(unsigned(Count) = to_unsigned(DivisorSize,5)) then
				Count <= (others => '0');
				Done_Sig <= '1';
				Run <= '0';
			elsif(unsigned(Count) > to_unsigned(0,5)) then
				Count <= std_logic_vector(unsigned(Count)+1);
				Done_Sig <= '0';
			else
				Done_Sig <= '0';
			end if;
		end if;
	end process COUNTER;
	
	Done <= Done_Sig;
	I(DivisorSize-1 downto 0) <= std_logic_vector(signed(A(DivisorSize-2 downto 0) & Q(DivisorSize-1)) - signed(Y(DivisorSize-1 downto 0)));
	I2(DivisorSize-1 downto 0) <= std_logic_vector(signed(A(DivisorSize-2 downto 0) & Q(DivisorSize-1)) + signed(Y(DivisorSize-1 downto 0)));
	
	DIVISION: process(CLK,RST)
	begin
		if(RST = '1') then
			A <= (others => '0');
			Q <= (others => '0');
		elsif(rising_edge(CLK)) then
			if(Div_EN = '1' and Run = '0') then
				Y <= Divisor;
				A (DivisorSize-1 downto 0) <= '0' & Dividend((DivisorSize*2)-2 downto DivisorSize);
				Q (DivisorSize-1 downto 0) <= Dividend (DivisorSize-1 downto 0);
			elsif(Run = '1') then
				if(A(DivisorSize-1) = '0') then
					A(DivisorSize-1 downto 0) <= I(DivisorSize-1 downto 0);
					Q(DivisorSize-1 downto 0) <= Q(DivisorSize-2 downto 0) & not(I(DivisorSize-1));
				else
					A(DivisorSize-1 downto 0) <= I2(DivisorSize-1 downto 0);
					Q(DivisorSize-1 downto 0) <= Q(DivisorSize-2 downto 0) & not(I2(DivisorSize-1));
				end if;
			elsif(Done_Sig = '1') then
				Y <= (others => '0');
				A <= (others => '0');
				Q <= (others => '0');
			end if;
		end if;
	end process DIVISION;
	
	Quotient <= Q;
	
end RTL_Iterative;