--------------------------------------------------------------------
-- Updated 29-07-2015
-- Corrected format errors in Cb Cr data selection.
-- Now works according to BT.656 standards
--------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Y444toY422 is
generic(
	bit_width : integer := 23		-- Actually (bit_width - 1)
--	VIDEO_XSIZE :integer := 640;
--	VIDEO_YSIZE :integer := 512
	);
port(
	CLK			  : in std_logic;
	RST			  : in std_logic;

	VIDEO_I_V     : in  std_logic;                      -- Video Input Vertical Synchro
	VIDEO_I_H     : in  std_logic;                      -- Video Input Horizontal Synchro
	VIDEO_I_EOI   : in  std_logic;                      -- Video Input End Of Image
	VIDEO_I_DAV   : in  std_logic;                      -- Video Input Data Valid
	VIDEO_I_DATA  : in  std_logic_vector(bit_width downto 0);  -- Video Input Data
--	VIDEO_I_XSIZE : in  std_logic_vector( 9 downto 0);  -- Video X Size
--	VIDEO_I_YSIZE : in  std_logic_vector( 9 downto 0);  -- Video Y Size
	--VIDEO_I_XCNT  : in  std_logic_vector( 9 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
	--VIDEO_I_YCNT  : in  std_logic_vector( 9 downto 0);  -- Video Y Line  Counter (1st line  = 0)

	VIDEO_O_V     : out std_logic;                      -- Video Output Vertical Synchro
	VIDEO_O_H     : out std_logic;                      -- Video Output Horizontal Synchro
	VIDEO_O_EOI   : out std_logic;                      -- Video Output End Of Image
	VIDEO_O_DAV   : out std_logic;                      -- Video Output Data Valid
	VIDEO_O_DATA  : out std_logic_vector( 15 downto 0)  -- Video Output Data
--	VIDEO_O_XSIZE : out std_logic_vector( 9 downto 0);  -- Video X Size
--	VIDEO_O_YSIZE : out std_logic_vector( 9 downto 0)  -- Video Y Size
	--VIDEO_O_XCNT  : out std_logic_vector( 9 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
	--VIDEO_O_YCNT  : out std_logic_vector( 9 downto 0)   -- Video Y Line  Counter (1st line  = 0)
	);
end Y444toY422;

architecture RTL of Y444toY422 is

signal NextPixel, PrevPixel : STD_LOGIC_VECTOR (15 downto 0);
signal CbCr_SEL : STD_LOGIC;

signal VIDEO_I_V_i, VIDEO_I_V_ii		: std_logic;                      -- Video Input Vertical Synchro
signal VIDEO_I_H_i, VIDEO_I_H_ii		: std_logic;                      -- Video Input Horizontal Synchro
signal VIDEO_I_EOI_i, VIDEO_I_EOI_ii	: std_logic;                      -- Video Input End Of Image
signal VIDEO_I_DAV_i, VIDEO_I_DAV_ii	: std_logic;                      -- Video Input Data Valid
signal VIDEO_I_DATA_i					: std_logic_vector(bit_width downto 0);  -- Video Input Data
--signal VIDEO_I_XSIZE_i, VIDEO_I_XSIZE_ii: std_logic_vector( 9 downto 0);  -- Video X Size
--signal VIDEO_I_YSIZE_i, VIDEO_I_YSIZE_ii: std_logic_vector( 9 downto 0);  -- Video Y Size
--signal VIDEO_I_XCNT_i, VIDEO_I_XCNT_ii	: std_logic_vector( 9 downto 0);  -- Video X Pixel Counter (1st pixel = 0)
--signal VIDEO_I_YCNT_i, VIDEO_I_YCNT_ii	: std_logic_vector( 9 downto 0);  -- Video Y Line  Counter (1st line  = 0)

signal Cr0 : std_logic_vector (7 downto 0);
--signal HFLIP : std_logic;

begin
	
	VIDEO_O_H <= VIDEO_I_H_ii;
	VIDEO_O_V <= VIDEO_I_V_ii;
	VIDEO_O_EOI <= VIDEO_I_EOI_ii;
	VIDEO_O_DAV <= VIDEO_I_DAV_ii;
	VIDEO_O_DATA <= NextPixel;
--	VIDEO_O_XSIZE <= VIDEO_I_XSIZE_ii;
--	VIDEO_O_YSIZE <= VIDEO_I_YSIZE_ii;
	--VIDEO_O_XCNT <= VIDEO_I_XCNT_ii;
	--VIDEO_O_YCNT <= VIDEO_I_YCNT_ii;

	process(RST,CLK)
	begin
		if RST = '1' then
			VIDEO_I_V_i		<= '0';
			VIDEO_I_H_i		<= '0';
			VIDEO_I_EOI_i	<= '0';
			VIDEO_I_DAV_i	<= '0';
			VIDEO_I_DATA_i	<= (others => '0');
--			VIDEO_I_XSIZE_i	<= (others => '0');
--			VIDEO_I_YSIZE_i	<= (others => '0');
			--VIDEO_I_XCNT_i	<= (others => '0');
			--VIDEO_I_YCNT_i	<= (others => '0');
			
			VIDEO_I_V_ii	<= '0';
			VIDEO_I_H_ii	<= '0';
			VIDEO_I_EOI_ii	<= '0';
			VIDEO_I_DAV_ii	<= '0';
			NextPixel		<= (others => '0');
--			VIDEO_I_XSIZE_ii<= (others => '0');
--			VIDEO_I_YSIZE_ii<= (others => '0');
			--VIDEO_I_XCNT_ii	<= (others => '0');
			--VIDEO_I_YCNT_ii	<= (others => '0');
			
			CbCr_SEL <= '0';
		elsif rising_edge(CLK) then
			VIDEO_I_V_i		<= VIDEO_I_V;
			VIDEO_I_H_i		<= VIDEO_I_H;
			VIDEO_I_EOI_i	<= VIDEO_I_EOI;
			VIDEO_I_DAV_i	<= VIDEO_I_DAV;
			VIDEO_I_DATA_i	<= VIDEO_I_DATA;
--			VIDEO_I_XSIZE_i	<= VIDEO_I_XSIZE;
--			VIDEO_I_YSIZE_i	<= VIDEO_I_YSIZE;
			--VIDEO_I_XCNT_i	<= VIDEO_I_XCNT;
			--VIDEO_I_YCNT_i	<= VIDEO_I_YCNT;
			if VIDEO_I_H_i = '1' then		-- Reset Cb/Cr Select signal at beginning of each line.
				CbCr_SEL <= '0';			-- Reset it to Cb at beginning of line.
			elsif VIDEO_I_DAV_i = '1' then	-- The value of CbCr_SEL arrived at here will be used
				CbCr_SEL <= not CbCr_SEL;	-- in the next clock cycle.
			end if;
			
			if VIDEO_I_DAV_i = '1' then
				if CbCr_SEL = '0' then	
					NextPixel <=  VIDEO_I_DATA_i(23 downto 16) & VIDEO_I_DATA_i(7 downto 0);
					Cr0		  <= VIDEO_I_DATA_i(15 downto 8);
				else					
					NextPixel <= VIDEO_I_DATA_i(23 downto 16) & Cr0  ;
				end if;
			end if;
			
			VIDEO_I_V_ii	<= VIDEO_I_V_i;
			VIDEO_I_H_ii	<= VIDEO_I_H_i;
			VIDEO_I_EOI_ii	<= VIDEO_I_EOI_i;
			VIDEO_I_DAV_ii	<= VIDEO_I_DAV_i;
--			VIDEO_I_XSIZE_ii<= VIDEO_I_XSIZE_i;
--			VIDEO_I_YSIZE_ii<= VIDEO_I_YSIZE_i;
			--VIDEO_I_XCNT_ii	<= VIDEO_I_XCNT_i;
			--VIDEO_I_YCNT_ii	<= VIDEO_I_YCNT_i;
			
		end if;
	end process;

end RTL;