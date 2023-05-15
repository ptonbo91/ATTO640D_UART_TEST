library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------------
entity new_HIST_EQUALIZATION_MinMax is
generic (
	bitdepth : integer := 14;
	bit_width: integer := 13;
	VIDEO_XSIZE : positive := 640;
	VIDEO_YSIZE : positive := 512
);
port (
	CLK              : in  std_logic;                                     --  Clock
	RST              : in  std_logic;                                     --  Reset

	VIDEO_I_V        : in std_logic;
	VIDEO_I_H        : in std_logic;
	VIDEO_I_EOI      : in std_logic;
	VIDEO_I_DAV      : in std_logic;
	VIDEO_I_DATA     : in std_logic_vector(bit_width downto 0);
--	VIDEO_I_XCNT     : in std_logic_vector(9 downto 0);
--	VIDEO_I_YCNT     : in std_logic_vector(9 downto 0);
--	VIDEO_I_XSIZE    : in std_logic_vector(9 downto 0);
--	VIDEO_I_YSIZE    : in std_logic_vector(9 downto 0);


	VIDEO_O_V        : out std_logic;
	VIDEO_O_H        : out std_logic;
	VIDEO_O_EOI      : out std_logic;
	VIDEO_O_DAV      : out std_logic;
	VIDEO_O_DATA     : out std_logic_vector(7 downto 0);
--	VIDEO_O_XCNT     : out std_logic_vector(9 downto 0);
--	VIDEO_O_YCNT     : out std_logic_vector(9 downto 0);
--	VIDEO_O_XSIZE    : out std_logic_vector(9 downto 0);
--	VIDEO_O_YSIZE    : out std_logic_vector(9 downto 0);
	CNTRL_IPP 		 : in std_logic_vector(23 downto 0);
	CNTRL_MAX_GAIN   : in std_logic_vector(23 downto 0);
	CNTRL_MIN        : in std_logic_vector(23 downto 0);
	CNTRL_MAX        : in std_logic_vector(23 downto 0);
	CNTRL_HISTORY    : in std_logic_vector(23 downto 0);
	prev_lowVal_out  : out std_logic_vector(bitdepth-1 downto 0);
	prev_highVal_out  : out std_logic_vector(bitdepth-1 downto 0)
);
end new_HIST_EQUALIZATION_MinMax;
-------------------------------

architecture RTL of new_HIST_EQUALIZATION_MinMax is


--COMPONENT ila_0

--PORT (
--	clk : IN STD_LOGIC;



--	probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
--);
--END COMPONENT;

--COMPONENT TOII_TUVE_ila

--PORT (
--	clk : IN STD_LOGIC;



--	probe0 : IN STD_LOGIC_VECTOR(480 DOWNTO 0)
--);
--END COMPONENT  ;

component new_hist_mem is 
generic ( 
      VIDEO_I_DATA_WIDTH   :positive := 14;
      HIST_BIN_WIDTH       :positive := 19;
      NUMBER_OF_IN_PIXELS  :positive := 308160
);
port (
    VIDEO_I_PCLK     : in std_logic;
    VIDEO_I_VSYNC    : in std_logic;
    VIDEO_I_HSYNC    : in std_logic;
    VIDEO_I_EOI      : in std_logic;
    VIDEO_I_DAV      : in std_logic;
    VIDEO_I_DATA     : in std_logic_vector(bit_width downto 0);
    RESET            : in std_logic;
    HISTEQ_B_RDREQ   : in std_logic;
    HISTEQ_B_RDDATA  : out std_logic_vector(18 downto 0);
    HISTEQ_B_ADDR    : in std_logic_vector(bit_width downto 0);
    HISTEQ_A_WRREQ   : in std_logic;
    HISTEQ_A_WRDATA  : in std_logic_vector(18 downto 0);
    HISTEQ_A_ADDR    : in std_logic_vector(bit_width downto 0)
 );
end component;



----------------------------
-- Video Interface Control Signals
signal VIDEO_I_DAV_D1	: std_logic;
signal VIDEO_I_DAV_D2	: std_logic;
signal VIDEO_I_DAV_D3	: std_logic;
signal VIDEO_XCNT		: std_logic_vector(9 downto 0);
signal VIDEO_YCNT		: std_logic_vector(9 downto 0);
signal VIDEO_I_EOI_TEMP	: std_logic;
signal VIDEO_I_EOI_TEMP_2 : std_logic;
signal VIDEO_I_EOI_TEMP_3 : std_logic;
signal VIDEO_I_H_TEMP	: std_logic;
signal VIDEO_I_H_TEMP_2	: std_logic;
signal VIDEO_I_V_TEMP	: std_logic;
signal VIDEO_I_V_TEMP_2	: std_logic;

-- Histogram Creation Memory Signals

signal Hist_Gen_Done			: std_logic;
signal EQUAL_INPUT				: std_logic;
signal EQUAL_INPUT_CONTINUOUS	: std_logic;
signal EQUAL_INPUT_D1			: std_logic;
signal EQUAL_INPUT_CONTINUOUS_D1: std_logic;

signal TEMP_ADDR		: std_logic_vector(bitdepth-1 downto 0);


signal HIST_WRREQ	: std_logic;
signal HIST_RDREQ	: std_logic;
signal COUNT			: std_logic_vector(bitdepth downto 0);
signal ACCUM			: unsigned(31 downto 0);
signal ACCUM_TEMP		: unsigned (31 downto 0);
signal HIST_RDADDR	: std_logic_vector(bitdepth-1 downto 0);
signal HIST_WRADDR	: std_logic_vector(bitdepth-1 downto 0);
signal HIST_DIN		: std_logic_vector(18 downto 0);
signal HIST_DOUT	: std_logic_vector(18 downto 0);

-- Contrast-Stretch Multiplication Factor Generation Signals and Registers
signal Div_EN		: std_logic;
signal Dividend		: std_logic_vector (62 downto 0);
signal Divisor		: std_logic_vector (31 downto 0);
signal Quotient_Out	: std_logic_vector (31 downto 0);
signal MulX			: std_logic_vector (31 downto 0);
signal MulX_D       : std_logic_vector (31 downto 0);
signal Done_Div		: std_logic;

signal data_out			: std_logic_vector (7 downto 0);
signal ok_high, ok_low	: std_logic;
signal lowVal, highVal	: unsigned (bitdepth-1 downto 0);		-- Stores the COUNT, i.e., the HIST_ADDR where 1% and 99% of the no. of pixels are reached in the ACCUM register.
signal lowVal_d, highVal_d	: unsigned (bitdepth-1 downto 0);	
signal firstPixel		: unsigned (18 downto 0) := to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE/1000,19);
signal lastPixel		: unsigned (18 downto 0) := to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE*99/1000,19);
signal prev_lowVal		: unsigned (bitdepth-1 downto 0); 
signal prev_highVal 	: unsigned (bitdepth-1 downto 0);
signal DIFF_PIX_HL		: std_logic_vector (bitdepth-1 downto 0);
signal DIFF_PIX_HL_D    : std_logic_vector (bitdepth-1 downto 0);
signal DIFF_PIX_LOW 	: std_logic_vector (bitdepth-1 downto 0);
signal TEMP_PIXEL_OUT	: std_logic_vector (31+bitdepth downto 0);

type state_m is (S_HIST_GEN, S_LIMIT_DEFINITION_1, S_LIMIT_DEFINITION_2, S_LIMIT_DEFINITION_3, S_REST);
signal state: state_m;

type HL_state is (IDLE,DIFF_CALC_LOW_PER,DIFF_CALC_LOW,DIFF_CALC_HIGH_PER,DIFF_CALC_HIGH,DIFF_CORR,DIV_OUT);
signal Diff_Simple : HL_state;

signal LValCorrected			: std_logic;
signal HValCorrected			: std_logic;
signal diff_highVal_direction	: std_logic;
signal diff_lowVal_direction	: std_logic;
signal CorrHighVal				: unsigned (bitdepth-1 downto 0);
signal CorrLowVal				: unsigned (bitdepth-1 downto 0);
signal Diff_HighVal				: unsigned (bitdepth-1 downto 0);
signal Diff_LowVal				: unsigned (bitdepth-1 downto 0);
signal Diff_LowVal_per			: unsigned (bitdepth-1 downto 0);
signal Diff_HighVal_per			: unsigned (bitdepth-1 downto 0);
signal first					: std_logic;

signal FrameCounter : std_logic_vector (2 downto 0); -- Count and ignore the first four frames.

signal min_per       : unsigned(6 downto 0);                                 -- should accomodate values 0-100
signal max_per       : unsigned(6 downto 0);                                 -- should accomodate values 0-100
--signal NUM_PIX_BY100 : unsigned(17 downto 0) := to_unsigned(209715, 18);     -- (512*640)/100 in 12.6 format
signal NUM_PIX_BY100 : unsigned(17 downto 0) := to_unsigned(VIDEO_XSIZE*VIDEO_YSIZE*64/1000, 18);     -- (512*640)/100 in 12.6 format

signal history_by100 : unsigned(17 downto 0);

signal GAIN : std_logic_vector(MulX'range);
signal MAX_GAIN: std_logic_vector(MulX'range);

signal BRIGHTNESS: unsigned(bitdepth-1 downto 0);
signal TEMP_BRIGHTNESS: unsigned(31+bitdepth downto 0);
signal TEMP_PIXEL_OUT2: signed(TEMP_PIXEL_OUT'length downto 0);

signal IPP: std_logic_vector(8+bitdepth-1 downto 0);

signal probe0 :std_logic_vector (480 downto 0); 
--signal probe1 :std_logic_vector (127 downto 0);

signal wait_frame: std_logic;

--ATTRIBUTE MARK_DEBUG : string;
--ATTRIBUTE MARK_DEBUG of  DIFF_PIX_HL   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  DIFF_PIX_HL_D : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_V     : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_H     : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_DAV   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_EOI   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  lowVal_d      : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  highVal_d     : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  ACCUM         : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  ACCUM_TEMP    : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  count         : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  MulX_D        : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  IPP             : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  TEMP_PIXEL_OUT2 : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  TEMP_PIXEL_OUT  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_DAV_D2  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_DAV_D1  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  GAIN            : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  DIFF_PIX_LOW    : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  BRIGHTNESS      : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  TEMP_BRIGHTNESS : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  lowVal          : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  highval         : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  prev_lowVal     : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  prev_highVal    : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  data_out        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of  CorrLowVal      : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  CorrHighVal     : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  Diff_LowVal_per : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  Diff_HighVal_per: SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  diff_lowVal_direction : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  ok_high : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  ok_low : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  LValCorrected : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  Diff_Simple   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  first  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  state  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  FrameCounter : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  EQUAL_INPUT   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  EQUAL_INPUT_CONTINUOUS   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_DAV_D1   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  VIDEO_I_DAV_D2   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  first   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  Hist_Gen_Done   : SIGNAL IS "TRUE";

--ATTRIBUTE MARK_DEBUG of  HIST_RDREQ  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  HIST_DOUT   : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  HIST_RDADDR : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  HIST_WRREQ  : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  HIST_DIN    : SIGNAL IS "TRUE";
--ATTRIBUTE MARK_DEBUG of  HIST_WRADDR : SIGNAL IS "TRUE";

--ATTRIBUTE MARK_DEBUG of  wait_frame : SIGNAL IS "TRUE";




begin
prev_lowVal_out <= std_logic_vector(prev_lowVal);
prev_highVal_out <= std_logic_vector(prev_highVal);
	--VIDEO_O_DATA <= "000000" & data_out;
	VIDEO_O_DATA <= data_out;
--	VIDEO_O_XCNT <= VIDEO_XCNT;
--	VIDEO_O_YCNT <= VIDEO_YCNT;
--	VIDEO_O_XSIZE <= VIDEO_I_XSIZE;
--	VIDEO_O_YSIZE <= VIDEO_I_YSIZE;
  
	process(CLK,RST) begin
		if(RST = '1') then
			data_out <= (others => '0');
		elsif(rising_edge(CLK)) then
			if(MulX_D = std_logic_vector(to_unsigned(0,MulX_D'length))) then
				data_out <= TEMP_ADDR(bitdepth-1 downto bitdepth-8);  -- To directly pass outputs through, during the Calculation Frame Period (wrong outputs on purpose)
			elsif (TEMP_PIXEL_OUT2 < to_signed(0,bitdepth)) then
				data_out <= x"00";
			elsif (unsigned(TEMP_PIXEL_OUT2(TEMP_PIXEL_OUT2'length-1 downto bitdepth)) > to_unsigned(255,bitdepth)) then
				data_out <= x"FF";
			else
				data_out <= std_logic_vector(TEMP_PIXEL_OUT2(bitdepth+7 downto bitdepth));
			end if;
		end if;
	end process;

	Divisor		<= STD_LOGIC_VECTOR(resize(UNSIGNED(DIFF_PIX_HL),32));
	Dividend	<= STD_LOGIC_VECTOR(to_unsigned(0,63-8-bitdepth)) & x"FF" & STD_LOGIC_VECTOR(to_unsigned(0,bitdepth));
	
	Divider_Out:entity WORK.Divider_Generic_NRA
	GENERIC MAP(
		DivisorSize => 2*bitdepth		-- Assuming bit_width is always larger than bitdepth-1, because if not, divider WILL fail.
	)
	PORT MAP(
		RST			=> RST,
		CLK			=> CLK,
		Div_EN		=> Div_EN,
		Dividend	=> Dividend,						-- Dividend was supposed to be 255
		Divisor		=> Divisor,							-- Divisor was supposed to be highVal-lowVal
		Quotient	=> Quotient_Out,					-- But Quotient would be a value between 0 and 1
		Done		=> Done_Div							-- Thus, Dividend is 255 * 2^bitdepth
	);

	Quotient_Process: process(CLK,RST)
	begin
		if(RST = '1') then
			MulX <= (others => '0');
		elsif(rising_edge(CLK)) then
			if(Done_Div = '1') then
				MulX <= Quotient_Out;
			end if;
		end if;
	end process;

	TEMP_BRIGHTNESS <= (unsigned(GAIN)*unsigned(BRIGHTNESS));

	Contrast_Stretching_Process: process (RST,CLK)
	begin
		if RST = '1' then
			DIFF_PIX_LOW	<= (others => '0');
			TEMP_PIXEL_OUT	<= (others => '0');
			MulX_D          <= (others => '0');
			DIFF_PIX_HL_D   <= (others => '0');
			lowVal_d        <= (others => '0');
			highVal_d       <= (others => '1');
			BRIGHTNESS 	    <= (others => '0');
			MAX_GAIN 		<= std_logic_vector(to_unsigned(10000, MAX_GAIN'length));
			IPP 			<= std_logic_vector(to_unsigned(50, IPP'length));
		elsif rising_edge (CLK) then
		    if VIDEO_I_V = '1' then
		      MulX_D <= MulX;
		      DIFF_PIX_HL_D   <= DIFF_PIX_HL;
		      highVal_d <= highVal;
		      lowVal_d  <= lowVal;
		      BRIGHTNESS <= (shift_right(unsigned(lowVal),1)+shift_right(unsigned(highVal),1));
		      MAX_GAIN <= x"00" &CNTRL_MAX_GAIN;
		      IPP <= CNTRL_IPP(7 downto 0) & (bitdepth-1 downto 0 =>'0');
		      if(unsigned(MulX)>unsigned(MAX_GAIN)) then
		      	GAIN <= MAX_GAIN;
		      else
		      	GAIN <= MulX;
		      end if;
		    else 
		      MulX_D <= MulX_D;
		      DIFF_PIX_HL_D <= DIFF_PIX_HL_D;
		      lowVal_d <= lowVal_d;
		      highVal_d <= highVal_d;
		    end if;
		    
			if VIDEO_I_DAV = '1' then
				--if(unsigned(VIDEO_I_DATA(bit_width downto bit_width-bitdepth+1)) >= unsigned(highVal_d)) then
				--	DIFF_PIX_LOW <= DIFF_PIX_HL_D;
				--elsif(unsigned(VIDEO_I_DATA(bit_width downto bit_width-bitdepth+1)) <= unsigned(lowVal_d)) then
				--	DIFF_PIX_LOW <= (others => '0');
				--else
					DIFF_PIX_LOW <= std_logic_vector(unsigned(VIDEO_I_DATA(bit_width downto bit_width-bitdepth+1)));-- - unsigned(lowVal_d));
				--end if;
			end if;
			
			if VIDEO_I_DAV_D1 = '1' then
				TEMP_PIXEL_OUT <= std_logic_vector(unsigned(GAIN)*unsigned(DIFF_PIX_LOW));
			end if;
			if VIDEO_I_DAV_D2 = '1' then
				TEMP_PIXEL_OUT2 <= resize(signed('0' & IPP), TEMP_PIXEL_OUT2'length)+signed('0' & TEMP_PIXEL_OUT) - signed('0' & TEMP_BRIGHTNESS);
			end if;
		end if;
	end process;
	
	Hist_Gen_Process: process (CLK,RST)
	begin
		if RST = '1' then
			TEMP_ADDR		<= (others => '0');
			VIDEO_I_DAV_D1	<= '0';
			VIDEO_I_DAV_D2	<= '0';
			VIDEO_I_DAV_D3	<= '0';
			VIDEO_O_DAV		<= '0';

			VIDEO_I_V_TEMP	<= '0';
			VIDEO_O_V		<= '0';
  
			VIDEO_I_H_TEMP	<= '0';
			VIDEO_O_H		<= '0';
  
			VIDEO_I_EOI_TEMP <= '0';
			VIDEO_I_EOI_TEMP_2 <= '0'; -- Added a stage here.
			VIDEO_I_EOI_TEMP_3 <= '0';
			VIDEO_O_EOI		<= '0';
			
			VIDEO_XCNT		<= (others => '0');
			VIDEO_YCNT		<= (others => '0');

			min_per			<= (others => '0');
			max_per			<= (others => '0');
			history_by100	<= (others => '0');

			EQUAL_INPUT		<= '0';
			EQUAL_INPUT_CONTINUOUS		<= '0';
			EQUAL_INPUT_D1	<= '0';
			EQUAL_INPUT_CONTINUOUS_D1	<= '0';

			firstPixel		<= (others => '0');
			lastPixel		<= (others => '0');

			Hist_Gen_Done	<= '0';
			wait_frame      <= '0';


		elsif rising_edge(CLK) then
			

			
			VIDEO_I_DAV_D1 <= VIDEO_I_DAV;
			VIDEO_I_DAV_D2 <= VIDEO_I_DAV_D1;
			VIDEO_I_DAV_D3 <= VIDEO_I_DAV_D2;
			VIDEO_O_DAV <= VIDEO_I_DAV_D3;

			VIDEO_I_V_TEMP <= VIDEO_I_V;
			VIDEO_O_V<=VIDEO_I_V_TEMP;
  
			VIDEO_I_H_TEMP<=VIDEO_I_H;
			VIDEO_O_H <= VIDEO_I_H_TEMP;
  
			VIDEO_I_EOI_TEMP <= VIDEO_I_EOI;
			VIDEO_I_EOI_TEMP_2 <= VIDEO_I_EOI_TEMP; -- Added a stage here.
			VIDEO_I_EOI_TEMP_3 <= VIDEO_I_EOI_TEMP_2;
			VIDEO_O_EOI <= VIDEO_I_EOI_TEMP_3;
			Hist_Gen_Done	<= '0';
			if VIDEO_I_V = '1' then
			    wait_frame <= '1';
			    if wait_frame = '1'then
			     Hist_Gen_Done   <= '1';
			    end if;
			    firstPixel		<= resize(shift_right(NUM_PIX_BY100*min_per,6),firstPixel'length); --NUM_PIX_BY100 has 6 decimal bits
                lastPixel       <= resize(shift_right(NUM_PIX_BY100*max_per,6),lastPixel'length);  --NUM_PIX_BY100 has 6 decimal bits
				VIDEO_XCNT		<= (others => '0');
				VIDEO_YCNT		<= (others => '1');
				min_per			<= unsigned(CNTRL_MIN(min_per'length-1 downto 0));			--Value gets registered only at the beginning of frame
				max_per 		<= unsigned(CNTRL_MAX(max_per'length-1 downto 0));			--Value gets registered only at the beginning of frame
				history_by100	<= unsigned(CNTRL_HISTORY(6 downto 0))*to_unsigned(655,11);	--(2^16)/100 = 655. Will multiply with diff and then shift right by 16.
			end if;

			if VIDEO_I_H = '1' then
				VIDEO_XCNT		<= (others => '0');
				VIDEO_YCNT		<= STD_LOGIC_VECTOR(UNSIGNED(VIDEO_YCNT)+1);
			end if;
			
			if VIDEO_I_DAV = '1' then
				VIDEO_XCNT		<= STD_LOGIC_VECTOR(UNSIGNED(VIDEO_XCNT)+1);
			end if;
		end if;
	end process;

	Limit_Def_Process: process(RST,CLK)
	begin
		if RST = '1' then

			HIST_DIN	<= (others => '0');
			HIST_RDADDR	<= (others => '0');
			HIST_WRADDR	<= (others => '0');
			HIST_WRREQ	<= '0';
			HIST_RDREQ	<= '0';

			state			<= S_HIST_GEN;
			COUNT			<= (others => '0');
			ACCUM			<= (others => '0');
			ACCUM_TEMP		<= (others => '0');

			ok_low			<= '0';
			ok_high			<= '0';
			prev_lowVal		<= (others => '0');
			prev_highVal	<= (others => '1');
			lowVal			<= (others => '0');
			highVal			<= (others => '1');
			diff_highVal_direction		<= '0';
			diff_lowVal_direction		<= '0';
			first 			<= '1';
			FrameCounter	<= (others => '0');

		elsif rising_edge(CLK) then

			first <= not FrameCounter(2);
			HIST_WRREQ <= '0';
			HIST_RDREQ <= '0';

			--if VIDEO_I_V = '1' then
			--	state <= S_HIST_GEN;
			--end if;

			case state is
			when S_HIST_GEN =>
			-- Take each pixel as it comes and add it to Histogram
				COUNT		<= (others => '0');
				ACCUM		<= (others => '0');
				ACCUM_TEMP	<= (others => '0');
				if Hist_Gen_Done = '1' then
					state		<= S_LIMIT_DEFINITION_1;
				end if;
			-- End of Histogram Generation State

			when S_LIMIT_DEFINITION_1 =>
			-- Go through whole Histogram searching for limit points, Part 1
				HIST_RDADDR	<= COUNT(HIST_RDADDR'length-1 downto 0);
				HIST_RDREQ	<= '1';
				state 		<= S_LIMIT_DEFINITION_2;
				ACCUM 		<= ACCUM_TEMP;
			-- End of Histogram Read State 1

			when S_LIMIT_DEFINITION_2 =>
			-- Wait for it.
				state 		<= S_LIMIT_DEFINITION_3;

			when S_LIMIT_DEFINITION_3 =>
			-------------------------------------------------------------------------
			-- By using the History parameter, we attempt to limit the rate of
			-- change of Min and Max thresholds to some percentage of the difference
			-- between the old and the new values. The Min and Max thresholds in
			-- terms of percentages of the Frame Histogram are given as inputs to the
			-- HIST_EQUALIZATION_MinMax module.
			-- Note:- Always change History to 100% before changing the Min/Max
			-- Threshold percentage values.
			-------------------------------------------------------------------------
				HIST_DIN	<= (others => '0');
				ACCUM_TEMP	<= UNSIGNED(HIST_DOUT) + ACCUM;
				if (ok_low = '0' and (ACCUM > firstPixel)) then
					if (first = '1') then
						prev_lowVal		<= unsigned(COUNT(lowVal'length-1 downto 0)) - 1;
					else
						prev_lowVal		<= lowVal;
					end if;
					lowVal <= unsigned(COUNT(lowVal'length-1 downto 0)) - 1;
					if (unsigned(COUNT(lowVal'length-1 downto 0)) > lowVal) then
						diff_lowVal_direction <= '0';
					else
						diff_lowVal_direction <= '1';
					end if;
					ok_low <= '1';
				
				elsif (ok_high = '0' and (ACCUM > lastPixel)) then
					if first = '1' then
						prev_highVal <= unsigned(COUNT(highVal'length-1 downto 0)) - 1;
					else
						prev_highVal <= highVal;
					end if;
					highVal <= unsigned(COUNT(highVal'length-1 downto 0)) - 1;
					if (unsigned(COUNT(highVal'length-1 downto 0)) > highVal) then
						diff_highVal_direction <= '0';
					else
						diff_highVal_direction <= '1';
					end if;
					ok_high <= '1';
				end if;

				COUNT <= std_logic_vector(unsigned(COUNT)+1);
				if unsigned(COUNT) < to_unsigned(2**(bitdepth)-1, COUNT'length) then
					state <= S_LIMIT_DEFINITION_1;
				else
					COUNT <= (others=>'0');
					state <= S_REST;
				end if;

			when S_REST =>
				if ok_high = '0' then
					prev_highVal			<= highVal;
					highVal					<= (others => '1');
					diff_highVal_direction	<= '0';
					ok_high 				<= '1';
				end if;

				HIST_DIN		<= (others => '0');
				HIST_RDREQ		<= '0';
				if unsigned(COUNT) < to_unsigned(2**(bitdepth), COUNT'length) then
					HIST_WRADDR	<= COUNT(HIST_WRADDR'length-1 downto 0);
					COUNT			<= std_logic_vector(unsigned(COUNT)+1);
					HIST_WRREQ	<= '1';
					state			<= S_REST;
				else
					COUNT			<= (others=>'0');
					HIST_WRREQ   	<= '0';
					state			<= S_HIST_GEN;
					lowVal			<= CorrLowVal;
					highVal			<= CorrHighVal;
					ok_low			<= '0';
					ok_high			<= '0';
					if first = '1' then
						FrameCounter <= STD_LOGIC_VECTOR(UNSIGNED(FrameCounter) + 1);
					end if;
				end if;
			when others =>
				state <= S_HIST_GEN;
			end case;
			
		end if;
	end process;

	Pre_Division_Calculations: process(RST,CLK)
	begin
		if RST = '1' then
			CorrHighVal <= (others => '0');
			CorrLowVal <= (others => '0');
			-- CorrDiffPix_HL <= (others => '0');
			DIFF_PIX_HL <= (others => '0');
			Diff_LowVal <= (others => '0');
			Diff_HighVal <= (others => '0');
			Diff_Simple <= IDLE;
			LValCorrected <= '0';
			HValCorrected <= '0';
			Div_EN <= '0';
			Diff_LowVal_per <= (others => '0');
			Diff_HighVal_per <= (others => '0');
		elsif rising_edge(CLK) then
		
			case Diff_Simple is
			when IDLE =>
				if(ok_low = '1') then
					if(diff_lowVal_direction = '0') then
						Diff_LowVal <= unsigned(lowVal) - unsigned(prev_lowVal);
					else
						Diff_LowVal <= unsigned(prev_lowVal) - unsigned(lowVal);
					end if;
					Diff_Simple <= DIFF_CALC_LOW_PER;
					LValCorrected <= '0';
					HValCorrected <= '0';
				end if;

			when DIFF_CALC_LOW_PER =>
				Diff_LowVal_per <= resize(shift_right((unsigned(Diff_LowVal)*history_by100),16),Diff_LowVal_per'length);
				Diff_Simple <= DIFF_CALC_LOW;

			when DIFF_CALC_LOW =>
				if(LValCorrected = '0') then
					if(diff_lowVal_direction = '0') then
						CorrLowVal <= unsigned(prev_lowVal) + Diff_LowVal_per; -- The %age amount of change to be taken is user defined
					else
						CorrLowVal <= unsigned(prev_lowVal) - Diff_LowVal_per; -- The %age amount of change to be taken is user defined
					end if;
					LValCorrected <= '1';
				end if;
				if(ok_high = '1') then
					if(diff_highVal_direction = '0') then
						Diff_HighVal <= unsigned(highVal) - unsigned(prev_highVal);
					else
						Diff_HighVal <= unsigned(prev_highVal) - unsigned(highVal);
					end if;
					Diff_Simple <= DIFF_CALC_HIGH_PER;
				end if;

			when DIFF_CALC_HIGH_PER =>
				Diff_HighVal_per <= resize(shift_right((unsigned(Diff_HighVal)*history_by100),16),Diff_HighVal_per'length);
				Diff_Simple <= DIFF_CALC_HIGH;

			when DIFF_CALC_HIGH =>
				if(HValCorrected = '0') then
					if (diff_highVal_direction = '0') then
						CorrHighVal <= unsigned(prev_highVal) + Diff_HighVal_per; -- The %age amount of change to be taken is user defined
					else
						CorrHighVal <= unsigned(prev_highVal) - Diff_HighVal_per; -- The %age amount of change to be taken is user defined
					end if;
					HValCorrected <= '1';
					Diff_Simple <= DIFF_CORR;
				end if;

			when DIFF_CORR =>
				DIFF_PIX_HL <= STD_LOGIC_VECTOR(unsigned(CorrHighVal) - unsigned(CorrLowVal));
				Div_EN <= '1';
				Diff_Simple <= DIV_OUT;

			when DIV_OUT =>
				Div_EN <= '0';
				if ok_low = '0' then
					Diff_Simple <= IDLE;
				end if;

			when others =>
				Diff_Simple <= IDLE;
			end case;
		end if;
	end process;



--probe0(0) <= VIDEO_I_V    ;
--probe0(1) <= VIDEO_I_H    ;
--probe0(2) <= VIDEO_I_DAV  ;
--probe0(3) <= VIDEO_I_EOI  ;
--probe0(4)  <= EQUAL_INPUT;
--probe0(5)  <= EQUAL_INPUT_CONTINUOUS;
--probe0(6)  <= HIST_WRREQ;
--probe0(20 downto 7)   <= HIST_WRADDR;
--probe0(34 downto 21)  <= HIST_RDADDR;
----probe0(66 downto 35)<=  std_logic_vector(ACCUM);
--probe0(53 downto 35)  <= HIST_DIN;
--probe0(72 downto 54)  <= HIST_DOUT;
----probe0(91 downto 73)  <= TEMP_DIN;
--probe0(87 downto 73)  <= std_logic_vector(count);
--probe0(88)  <= HIST_RDREQ;
--probe0(89)  <= VIDEO_I_DAV_D1;
--probe0(90)  <= Hist_Gen_Done;
--probe0(91)  <= first;
--probe0(92)  <= wait_frame;
--probe0(95 downto 93)  <= (others=>'0');
--probe0(127 downto 96) <= std_logic_vector(ACCUM_TEMP);


--probe0(0) <= VIDEO_I_V    ;
--probe0(1) <= VIDEO_I_H    ;
--probe0(2) <= VIDEO_I_DAV  ;
--probe0(3) <= VIDEO_I_EOI  ;
--probe0(17 downto 4)   <= std_logic_vector(highVal_d);
--probe0(31 downto 18)  <= DIFF_PIX_LOW;--DIFF_PIX_HL_D;
--probe0(45 downto 32)  <= std_logic_vector(lowVal_d);
--probe0(60 downto 46)  <= std_logic_vector(count) ;
--probe0(63 downto 61)  <= (others=>'0');
--probe0(95 downto 64)  <= std_logic_vector(MulX_D);
--probe0(127 downto 96) <= GAIN;--std_logic_vector(ACCUM);


--i_ila_HIST_EQUAL: ila_0
--PORT MAP (
--	clk => CLK,
--	probe0 => probe0
--);


--probe1(0) <= VIDEO_I_V    ;
--probe1(1) <= VIDEO_I_H    ;
--probe1(2) <= VIDEO_I_DAV_D1  ;
--probe1(3) <= VIDEO_I_EOI  ;
--probe1(4) <= VIDEO_I_DAV_D2;
--probe1(51 downto 5)   <= std_logic_vector(TEMP_PIXEL_OUT2);
--probe1(97 downto 52)  <= TEMP_PIXEL_OUT;
--probe1(111 downto 98) <= IPP;
--probe1(127 downto 112)  <= (others=>'0');

--probe0(0) <= VIDEO_I_V    ;
--probe0(1) <= VIDEO_I_H    ;
--probe0(2) <= VIDEO_I_DAV_D1  ;
--probe0(3) <= VIDEO_I_EOI  ;
--probe0(4) <= VIDEO_I_DAV_D2;
--probe0(51 downto 5)   <= std_logic_vector(TEMP_PIXEL_OUT2);
--probe0(97 downto 52)  <= TEMP_PIXEL_OUT;
--probe0(98) <= VIDEO_I_DAV;
--probe0(111 downto 99)  <= (others=>'0');
--probe0(125 downto 112)  <=std_logic_Vector(BRIGHTNESS);
--probe0(171 downto 126)  <=std_logic_Vector(TEMP_BRIGHTNESS);
--probe0(185 downto 172)   <= std_logic_vector(highVal_d);
--probe0(199 downto 186)  <= DIFF_PIX_LOW;--DIFF_PIX_HL_D;
--probe0(213 downto 200)  <= std_logic_vector(lowVal_d);
--probe0(228 downto 214)  <= std_logic_vector(count) ;
----probe0(63 downto 61)  <= (others=>'0');
--probe0(260 downto 229)  <= std_logic_vector(MulX_D);
--probe0(292 downto 261) <= GAIN;--std_logic_vector(ACCUM);
--probe0(306 downto 293)  <= std_logic_vector(lowVal);
--probe0(320 downto 307)  <= std_logic_vector(highval);
--probe0(334 downto 321)  <= std_logic_vector(prev_lowVal);
--probe0(348 downto 335)  <= std_logic_vector(prev_highVal);
--probe0(356 downto 349)  <= std_logic_vector(data_out);
--probe0(362 downto 357)  <= (others=>'0');
--probe0(376 downto 363)  <= std_logic_vector(DIFF_PIX_HL);
--probe0(390 downto 377)  <= std_logic_vector(CorrHighVal);
--probe0(404 downto 391)  <= std_logic_vector(CorrLowVal);
--probe0(418 downto 405)  <= std_logic_vector(Diff_LowVal_per);
--probe0(432 downto 419)  <= std_logic_vector(Diff_HighVal_per);
--probe0(433)             <= diff_lowVal_direction;
--probe0(434)             <= ok_high;
--probe0(435)             <= ok_low;
--probe0(436)             <= LValCorrected;
--probe0(441 downto 437)  <= std_logic_vector(to_unsigned(HL_state'POS(Diff_Simple), 5));  
--probe0(442)             <= first;
--probe0(447 downto 443)  <= std_logic_vector(to_unsigned(state_m'POS(state), 5));  
--probe0(450 downto 448)  <= FrameCounter;
--probe0(472 downto 451)  <=IPP;
--probe0(480 downto 473)  <= (others=>'0');



--i_ila_HIST_EQUAL_1: TOII_TUVE_ila
--PORT MAP (
--	clk => CLK,
--	probe0 => probe0
--);



i_new_hist_mem : new_hist_mem
generic map( VIDEO_I_DATA_WIDTH  => 14,
             HIST_BIN_WIDTH      => 19,
             NUMBER_OF_IN_PIXELS => (VIDEO_XSIZE * VIDEO_YSIZE)
)
port map(
VIDEO_I_PCLK   => CLK ,
VIDEO_I_VSYNC  => VIDEO_I_V,
VIDEO_I_HSYNC  => VIDEO_I_H,
VIDEO_I_EOI    => VIDEO_I_EOI,
VIDEO_I_DAV    => VIDEO_I_DAV ,
VIDEO_I_DATA   => VIDEO_I_DATA,
RESET          => RST,
HISTEQ_B_RDREQ  => HIST_RDREQ,
HISTEQ_B_RDDATA => HIST_DOUT,
HISTEQ_B_ADDR   => HIST_RDADDR,
HISTEQ_A_WRREQ  => HIST_WRREQ,
HISTEQ_A_WRDATA => HIST_DIN,
HISTEQ_A_ADDR   => HIST_WRADDR
 );





end RTL;






