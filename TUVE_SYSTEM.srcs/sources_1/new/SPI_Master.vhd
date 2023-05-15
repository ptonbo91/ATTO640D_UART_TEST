library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--	Capable of waiting for upto SCLK cycles between SS_N being set to '0' and SPI_SCLK starting.
--	Note:- SS_MOSI_Wait works as the amt. of wait time, i.e., if SS_MOSI_Wait = 1,
--			then THERE IS ONE EMPTY SCLK CYCLE BETWEEN SS_N'falling_edge and SCLK'rising_edge.
--			Thus, SS_MOSI_Wait is, in effect, an unsigned 8b value, which should be set to zero
--			when no space is wanted between SS_N and SPI_CLK.

entity SPI_Master is
GENERIC(
	CLK_Freq	: integer := 216e6;
	SPI_Freq	: integer := 1e6;
	Data_Size	: integer := 16
);
PORT(
	-----------------------------------------
	--	Device Clock and Asynchronous Reset
	RST		: in STD_LOGIC;
	CLK		: in STD_LOGIC;
	-----------------------------------------
	--	Device FPGA Side I/O
	WR_REQ		: in STD_LOGIC;
	WRDATA		: in STD_LOGIC_VECTOR (Data_Size-1 downto 0);
	RD_REQ		: out STD_LOGIC;
	RDDATA		: out STD_LOGIC_VECTOR (Data_Size-1 downto 0);
	Data_Length	: in STD_LOGIC;
	MISO_EN		: in STD_LOGIC;
	MISO_Start	: in STD_LOGIC;
	SS_MOSI_Wait: in STD_LOGIC_VECTOR (7 downto 0);	-- Amt of time between SS_N -ve edge and first SCLK positive edge
	Int_SCLK	: out STD_LOGIC;
	-----------------------------------------
	-- SPI Physical Interface
	SPI_SS_N	: out std_logic;		-- SPI Slave Select (active low!)
    SPI_SCLK	: out std_logic;		-- SPI Serial Clock
    SPI_MOSI	: out std_logic;		-- SPI Master Out Slave In (from FPGA to SPI)
    SPI_MISO	: in  std_logic			-- SPI Master In Slave Out (from SPI to FPGA)
);
end entity SPI_Master;

architecture RTL of SPI_Master is

constant SPI_SCLK_DIV : integer := (CLK_Freq/SPI_Freq)/2;

signal SCLK		: STD_LOGIC;
signal SCLK_EN	: STD_LOGIC;
signal SS_N		: STD_LOGIC;
signal Div		: integer;

type SPI_management is (state_Idle, state_Wait_SS_to_MOSI_0, state_Wait_SS_to_MOSI_1, state_Tx_Rx);
signal FSM_SPI	: SPI_management;

signal Data_Length_Val : unsigned (7 downto 0);

signal MISO_Data	: STD_LOGIC_VECTOR (Data_Size-1 downto 0);
signal Bit_CNTR_MISO: integer;

type SPI_Read is (Idle, Waiting, Data_Read, Done);
signal FSM_MISO		: SPI_Read;

signal MISO_Done	: STD_LOGIC;

signal MOSI_Data	: STD_LOGIC_VECTOR (Data_Size-1 downto 0);
signal Bit_CNTR_MOSI: unsigned (7 downto 0);

signal MOSI_Wait_CNTR	: unsigned (7 downto 0);

type SPI_Write is (Idle, Data_Write, Waiting, Done);
signal FSM_MOSI		: SPI_Write;

signal MOSI_Done	: STD_LOGIC;

begin

	-- -------------------------------------
	-- SPI SCLK generation
	-- -------------------------------------
	SCLK_GEN: process(RST,CLK)
	begin
		if RST = '1' then
			SCLK <= '0';
			Div <= 0;
		elsif rising_edge(CLK) then
			if Div >= SPI_SCLK_DIV then
				Div	<= 0;
				SCLK	<= not SCLK;
			else
				Div	<= Div + 1;
			end if;
		end if;
	end process;

	Int_SCLK <= SCLK;
	-- -------------------------------------
	-- -------------------------------------

	Data_Length_Val <=	to_unsigned(16,8) when Data_Length = '1' else
						to_unsigned(8,8);

	-- -------------------------------------
	-- SPI Slave Select and SCLK management
	-- -------------------------------------
	SS_SCLK: process (RST,CLK)
	begin
		if RST = '1' then
			FSM_SPI	<= state_Idle;
			SS_N	<= '1';
			SCLK_EN <= '0';
			
		elsif rising_edge(CLK) then
			
			case FSM_SPI is
			
			when state_Idle =>
				if WR_REQ = '1' then
					if SS_MOSI_Wait = x"00" then
						MOSI_Wait_CNTR	<= (others => '0');
						if SCLK = '1' then
							FSM_SPI		<= state_Wait_SS_to_MOSI_1;
						else
							FSM_SPI		<= state_Wait_SS_to_MOSI_0;
						end if;
						--FSM_SPI	<= state_Wait_SS_to_MOSI_0;
						--MOSI_Wait_CNTR	<= x"01";
					else
						FSM_SPI			<= state_Wait_SS_to_MOSI_0;
						MOSI_Wait_CNTR	<= unsigned(SS_MOSI_Wait);
					end if;
					SS_N	<= '0';
				end if;

			when state_Wait_SS_to_MOSI_0 =>
				if SCLK = '1' then
					--if MOSI_Wait_CNTR = 0 then
					--	MOSI_Wait_CNTR	<= (others => '0');
					--	FSM_SPI			<= state_Tx_Rx;
					--else
					if MOSI_Wait_CNTR /= 0 then
						MOSI_Wait_CNTR	<= MOSI_Wait_CNTR - 1;
					end if;
						FSM_SPI		<= state_Wait_SS_to_MOSI_1;
					--end if;
				end if;

			when state_Wait_SS_to_MOSI_1 =>
				if SCLK = '0' then
					if MOSI_Wait_CNTR = 0 then
						MOSI_Wait_CNTR	<= (others => '0');
						FSM_SPI			<= state_Tx_Rx;
					else
						FSM_SPI		<= state_Wait_SS_to_MOSI_0;
					end if;
				end if;
		
			when state_Tx_Rx =>
				if (MOSI_Done = '1' and MISO_EN = '0') or (MISO_Done = '1' and MOSI_Done = '1') then
					SCLK_EN <= '0';
					SS_N	<= '1';
					FSM_SPI	<= state_Idle;
				elsif MISO_EN = '1' and MOSI_Done = '1' and MISO_Start = '0' and MISO_Done = '0' then
					SCLK_EN	<= '0';
				else
					SCLK_EN	<= SCLK;
				end if;
			
			end case;
		
		end if;
	end process;
	SPI_SCLK	<= SCLK_EN;
	SPI_SS_N	<= SS_N;
	-- -------------------------------------
	-- -------------------------------------
	
	-- -------------------------------------
	-- SPI MOSI management
	-- -------------------------------------
	MOSI: process (RST,CLK)
	begin
		if RST = '1' then
			FSM_MOSI		<= Idle;
			Bit_CNTR_MOSI	<= (others => '0');
			MOSI_Data		<= (others => '0');
			SPI_MOSI		<= '0';
			--WR_DONE	<= '0';
		elsif rising_edge(CLK) then
			
			--WR_DONE	<= '0';
			MOSI_Done		<= '0';

			case FSM_MOSI is
			
			when Idle =>
				if WR_REQ = '1' then
					MOSI_Data		<= WRDATA;
				end if;
				if SS_N = '0' then
					FSM_MOSI		<= Data_Write;
				end if;
				
			when Data_Write =>	-- Write data at Negative Edge
				if SCLK_EN = '0' and Bit_CNTR_MOSI = Data_Length_Val then
					FSM_MOSI		<= Done;
					Bit_CNTR_MOSI	<= (others => '0');
					MOSI_Done		<= '1';
				elsif SCLK_EN = '0' then
					SPI_MOSI		<= MOSI_Data(MOSI_Data'length-1);
					MOSI_Data		<= MOSI_Data(MOSI_Data'length-2 downto 0) & '0';
					Bit_CNTR_MOSI	<= Bit_CNTR_MOSI + 1;
					FSM_MOSI		<= Waiting;
				end if;
			
			when Waiting =>		-- Make decisions at Positive Edge
				if SCLK_EN = '1' then
					FSM_MOSI		<= Data_Write;
					--WR_DONE			<= '1';
				end if;
			
			when Done =>
				if SS_N = '1' then
					FSM_MOSI		<= Idle;
				end if;
			
			end case;
		end if;
	end process;
	-- -------------------------------------
	-- -------------------------------------
	
	-- -------------------------------------
	-- SPI MISO management
	-- -------------------------------------
	MISO: process (RST,CLK)
	begin
		if RST = '1' then
			FSM_MISO		<= Idle;
			Bit_CNTR_MISO	<= 0;
			RDDATA			<= (others => '0');
			RD_REQ			<= '0';
			MISO_Data		<= (others => '0');
		elsif rising_edge(CLK) then
			
			RD_REQ			<= '0';
			MISO_Done		<= '0';
			
			case FSM_MISO is
			
			when Idle =>
				if SS_N = '0' and MISO_EN = '1' and MISO_Start = '1' then
					FSM_MISO	<= Waiting;
				end if;
			
			when Waiting =>		-- Read data at Positive Edge
				if SCLK_EN = '1' then
					FSM_MISO		<= Data_Read;
					MISO_Data		<= MISO_Data(MISO_Data'length-2 downto 0) & SPI_MISO;
					Bit_CNTR_MISO	<= Bit_CNTR_MISO + 1;
				end if;
				
			when Data_Read =>	-- Make decisions at Negative Edge
				if SCLK_EN = '0' and Bit_CNTR_MISO = Data_Length_Val then
					RDDATA			<= MISO_Data;
					RD_REQ			<= '1';
					FSM_MISO		<= Done;
					Bit_CNTR_MISO	<= 0;
					MISO_Done		<= '1';
				elsif SCLK_EN = '0' then
					FSM_MISO		<= Waiting;
				end if;
			
			when Done =>
				if SS_N = '1' then
					FSM_MISO		<= Idle;
				end if;
			
			end case;
		end if;
	end process;
	-- -------------------------------------
	-- -------------------------------------

end RTL;