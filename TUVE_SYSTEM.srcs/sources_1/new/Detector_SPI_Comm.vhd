library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Detector_SPI_Comm is
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
	WriteData		:	in STD_LOGIC_VECTOR (31 downto 0);	-- writedata	- Avalon MM
	Write_EN		:	in STD_LOGIC;						-- write		- Avalon MM
	Read_EN			:	in STD_LOGIC;						-- read			- Avalon MM
	ADDRESS			:	in STD_LOGIC_VECTOR (7 downto 0);	-- address		- Avalon MM
	ReadData		:	out STD_LOGIC_VECTOR (31 downto 0);	-- readdata		- Avalon MM
	Wait_Req		:	out STD_LOGIC;						-- waitreq		- Avalon MM
	ReadDataValid	:	out STD_LOGIC;						-- readdatavalid- Avalon MM
	-----------------------------------------
	-- SPI Physical Interface
	SPI_SS_N	: out std_logic;		-- SPI Slave Select (active low!)
    SPI_SCLK	: out std_logic;		-- SPI Serial Clock
    SPI_MOSI	: out std_logic;		-- SPI Master Out Slave In (from FPGA to SPI)
    SPI_MISO	: in  std_logic			-- SPI Master In Slave Out (from SPI to FPGA)
);
end entity Detector_SPI_Comm;

architecture RTL of Detector_SPI_Comm is

-- Internal Avalon MM Addresses
constant AV_WR_ADDRESS		: STD_LOGIC_VECTOR(7 downto 0) := x"04";
constant AV_RD_ADDRESS		: STD_LOGIC_VECTOR(7 downto 0) := x"08";
constant AV_STATUS_ADDRESS	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
constant AV_CTRL_ADDRESS	: STD_LOGIC_VECTOR(7 downto 0) := x"0C";

-- MISO Related signals, to regulate and read only useful MISO information
signal MISO_TimeCounter : integer range -128 to 127 := -1;
signal MISO_Time		: signed (7 downto 0) := to_signed(-1,8);
signal MISO_Time_i		: signed (7 downto 0);

-- SPI Module Signals
signal SPI_WR_REQ		: STD_LOGIC;
signal SPI_WRDATA		: STD_LOGIC_VECTOR (Data_Size-1 downto 0);
--signal SPI_WR_DONE		: STD_LOGIC;
signal SPI_RD_REQ		: STD_LOGIC;
signal SPI_RDDATA		: STD_LOGIC_VECTOR (Data_Size-1 downto 0);		
signal SPI_MISO_EN		: STD_LOGIC;
signal SPI_MISO_Start	: STD_LOGIC;
signal Int_SS_N			: STD_LOGIC;
signal Int_SCLK			: STD_LOGIC;

signal SS_MOSI_Wait		: STD_LOGIC_VECTOR (7 downto 0);
signal SS_MOSI_Wait_i	: STD_LOGIC_VECTOR (7 downto 0);
signal Data_Length		: STD_LOGIC;
signal Data_Length_i	: STD_LOGIC;

signal Delayed_Int_SS_N			: STD_LOGIC;
signal Temp_Delayed_Int_SS_N	: STD_LOGIC;

-- TxFIFO signals
signal TxFIFO_CLR		: STD_LOGIC;
signal TxFIFO_WRREQ		: STD_LOGIC;
signal TxFIFO_WRDATA	: STD_LOGIC_VECTOR (Data_Size-1 downto 0);
signal TxFIFO_RDREQ		: STD_LOGIC;
signal TxFIFO_RDDATA	: STD_LOGIC_VECTOR (Data_Size-1 downto 0);
signal TxFIFO_Empty		: STD_LOGIC;
signal TxFIFO_Full		: STD_LOGIC;
signal TxBuffFilled		: STD_LOGIC_VECTOR (4 downto 0);
signal TxFIFO_AlmostFull: STD_LOGIC;

-- RxFIFO signals
signal RxFIFO_CLR		: STD_LOGIC;
signal RxFIFO_WRREQ		: STD_LOGIC;
signal RxFIFO_WRDATA	: STD_LOGIC_VECTOR (Data_Size-1 downto 0);
signal RxFIFO_RDREQ		: STD_LOGIC;
signal RxFIFO_RDDATA	: STD_LOGIC_VECTOR (Data_Size-1 downto 0);
signal RxFIFO_Empty		: STD_LOGIC;
signal RxFIFO_Full		: STD_LOGIC;
signal RxBuffFilled		: STD_LOGIC_VECTOR (4 downto 0);
signal RxFIFO_AlmostFull: STD_LOGIC;

signal Rx_Status_Reg	: STD_LOGIC_VECTOR (7 downto 0);
signal Tx_Status_Reg	: STD_LOGIC_VECTOR (7 downto 0);

type Read_FSM is (Idle, Waiting_0, Waiting_1, Receiving_Word_0, Receiving_Word_1, Done);
signal FSM_SPI_Read : Read_FSM;

type Write_FSM is (Waiting, Sending_Word);
signal FSM_SPI_Write : Write_FSM;

begin

	Wait_Req		<= TxFIFO_Full;
	Rx_Status_Reg	<= "0000" & RxFIFO_CLR & RxFIFO_Empty & RxFIFO_Full & RxFIFO_AlmostFull;
	Tx_Status_Reg	<= "0000" & TxFIFO_CLR & TxFIFO_Empty & TxFIFO_Full & TxFIFO_AlmostFull;

	AV_Read_Write: process(RST,CLK)
	begin
		if RST = '1' then
			TxFIFO_WRREQ	<= '0';
			RxFIFO_RDREQ	<= '0';
			TxFIFO_WRDATA	<= (others => '0');
			ReadData		<= (others => '0');
			RxFIFO_CLR		<= '0';
			TxFIFO_CLR		<= '0';
			ReadDataValid	<= '0';
			MISO_Time		<= (others => '1'); -- -1 by default for no data receive
			SS_MOSI_Wait	<= (others => '0'); -- 0 by default for no wait time
			Data_Length		<= '1';				-- '1' by default for 16b data
		elsif rising_edge(CLK) then
			TxFIFO_WRREQ	<= '0';
			RxFIFO_RDREQ	<= '0';
			RxFIFO_CLR		<= '0';
			TxFIFO_CLR		<= '0';
			ReadDataValid	<= '0';
			if Write_EN = '1' then
				case ADDRESS is
				when AV_WR_ADDRESS =>
					TxFIFO_WRDATA	<= WriteData(Data_Size-1 downto 0);
					TxFIFO_WRREQ	<= '1';									--	----------------------------------------------------------------------------------
				when AV_STATUS_ADDRESS =>									--	| -- 31 downto 24 -- | -- 23 downto 16 -- | -- 15 downto 8 -- | -- 7 downto 0 -- |
					RxFIFO_CLR	<= WriteData(19);							--	|	Rx_FIFO_Size	 |	  Rx_Status_Reg	  |	   Tx_FIFO_Size	  |	  Tx_Status_Reg	 |
					TxFIFO_CLR	<= WriteData(3);							--	----------------------------------------------------------------------------------

				-- Make AV_CTRL_ADDRESS function only when FIFO_Tx is empty
				when AV_CTRL_ADDRESS =>										--	----------------------------------------------------------------------------------
					MISO_Time		<= signed(WriteData(7 downto 0));		--	|			-- 31 downto 17 -- 			|16| -- 15 downto 8 -- | -- 7 downto 0 --|
					SS_MOSI_Wait	<= WriteData(15 downto 8);				--	|			XX..............XX 			|DL|	 MISO_Time	   |	MOSI_Wait	 |
					Data_Length		<= WriteData(16);						--	----------------------------------------------------------------------------------
				when others => null;
				end case;
			else
				TxFIFO_WRDATA	<= (others => '0');
				TxFIFO_WRREQ	<= '0';
				RxFIFO_CLR		<= '0';
				TxFIFO_CLR		<= '0';
			end if;

			if Read_EN = '1' then
				case ADDRESS is
				when AV_RD_ADDRESS =>
					ReadData		<= x"0000" & RxFIFO_RDDATA;
					ReadDataValid	<= '1';
					RxFIFO_RDREQ	<= '1';
				when AV_STATUS_ADDRESS =>
					ReadData		<= "000" & RxBuffFilled & Rx_Status_Reg & "000" & TxBuffFilled & Tx_Status_Reg;
					ReadDataValid	<= '1';
				when AV_CTRL_ADDRESS =>
					ReadData		<= x"000" & "000" & Data_Length & SS_MOSI_Wait & STD_LOGIC_VECTOR (MISO_Time);
					ReadDataValid	<= '1';
				when others => null;
				end case;
			else
				ReadDataValid	<= '0';
				RxFIFO_RDREQ	<= '0';
			end if;
		end if;
	end process;

	Set_SPI_Ctrl: process(RST,CLK)
	begin
		if RST = '1' then
			MISO_Time_i		<= (others => '0');
			SS_MOSI_Wait_i	<= (others => '0');
			Data_Length_i	<= '1';
		elsif rising_edge (CLK) then
			if TxFIFO_Empty = '1' and Int_SS_N = '1' then
				MISO_Time_i		<= MISO_Time;
				SS_MOSI_Wait_i	<= SS_MOSI_Wait;
				Data_Length_i	<= Data_Length;
			end if;
		end if;
	end process;

	SPI_Read_Write: process(RST,CLK)
	begin
		if RST = '1' then
			TxFIFO_RDREQ	<= '0';
			SPI_WR_REQ		<= '0';
			SPI_WRDATA		<= (others => '0');
			FSM_SPI_Write	<= Waiting;
			FSM_SPI_Read	<= Idle;
			SPI_MISO_EN		<= '0';
			SPI_MISO_Start	<= '0';
			MISO_TimeCounter	<= 0;
		elsif rising_edge (CLK) then
			
			TxFIFO_RDREQ	<= '0';
			SPI_WR_REQ		<= '0';
			
			case FSM_SPI_Write is
			
			when Waiting =>
				if Delayed_Int_SS_N = '1' and TxFIFO_Empty = '0' then
					SPI_WR_REQ		<= '1';
					SPI_WRDATA		<= TxFIFO_RDDATA;
					TxFIFO_RDREQ	<= '1';
					FSM_SPI_Write	<= Sending_Word;
				end if;

			when Sending_Word =>
				if Delayed_Int_SS_N = '0' then
					FSM_SPI_Write	<= Waiting;
				end if;

			end case;

			case FSM_SPI_Read is

			when Idle =>
				if Int_SS_N = '0' then
					FSM_SPI_Read	<= Waiting_0;
				end if;

			when Waiting_0 =>
				if MISO_Time_i = -1 then
					FSM_SPI_Read		<= Done;
					SPI_MISO_EN			<= '0';
				elsif MISO_Time_i = 0 then
					FSM_SPI_Read		<= Receiving_Word_0;
					SPI_MISO_EN			<= '1';
					SPI_MISO_Start		<= '1';
					MISO_TimeCounter	<= 0;
				elsif Int_SCLK = '1' then
					SPI_MISO_EN			<= '1';
					MISO_TimeCounter	<= MISO_TimeCounter + 1;
					FSM_SPI_Read		<= Waiting_1;
				end if;

			when Waiting_1 =>
				if Int_SCLK = '0' then
					if (to_signed(MISO_TimeCounter,MISO_Time'length) < MISO_Time_i) then
						FSM_SPI_Read		<= Waiting_0;
					else
						FSM_SPI_Read		<= Receiving_Word_0;
						SPI_MISO_Start		<= '1';
						MISO_TimeCounter	<= 0;
					end if;
				end if;

			when Receiving_Word_0 =>
				if Int_SCLK = '1' then
					MISO_TimeCounter		<= MISO_TimeCounter + 1;
					FSM_SPI_Read			<= Receiving_Word_1;
				end if;

			when Receiving_Word_1 =>
				if Int_SCLK = '0' then
					if MISO_TimeCounter = Data_Size then
						SPI_MISO_EN			<= '0';
						SPI_MISO_Start		<= '0';
						MISO_TimeCounter	<= 0;
						FSM_SPI_Read		<= Done;
					else
						FSM_SPI_Read		<= Receiving_Word_0;
					end if;
				end if;

			when Done =>
				if Delayed_Int_SS_N = '1' then
					FSM_SPI_Read	<= Idle;
				end if;

			end case;

		end if;
	end process;

	Waiting_Time_Int_SCLK_10: process(Int_SCLK, RST)
	variable SCLK_CNTR : integer range 0 to 10500 := 0;
	begin
		if RST = '1' then
			Delayed_Int_SS_N <= '1';
		elsif rising_edge (Int_SCLK) then
			--if SCLK_CNTR = 100 then
				--SCLK_CNTR := 0;
				--Delayed_Int_SS_N <= Temp_Delayed_Int_SS_N;
			--else
				--Temp_Delayed_Int_SS_N	<= Int_SS_N;
				--SCLK_CNTR 				:= SCLK_CNTR + 1;
			--end if;
			if Int_SS_N = '1' and Delayed_Int_SS_N = '0' then
				if SCLK_CNTR = 10500 then
					SCLK_CNTR 			:= 0;
					Delayed_Int_SS_N	<= '1';
				else
					SCLK_CNTR := SCLK_CNTR + 1;
				end if;
			elsif Int_SS_N = '0' and Delayed_Int_SS_N = '1' then
				Delayed_Int_SS_N	<= '0';
			end if;
		end if;
	end process;

	i_SPI: entity WORK.SPI_Master
	GENERIC MAP(
		CLK_Freq	=> CLK_Freq,
		SPI_Freq	=> SPI_Freq,
		Data_Size	=> Data_Size
	)
	PORT MAP(
		-----------------------------------------
		--	Device Clock and Asynchronous Reset
		RST			=> RST,
		CLK			=> CLK,
		-----------------------------------------
		--	Device FPGA Side I/O
		WR_REQ		=> SPI_WR_REQ,
		WRDATA		=> SPI_WRDATA,
		--WR_DONE		=> SPI_WR_DONE,
		RD_REQ		=> SPI_RD_REQ,
		RDDATA		=> SPI_RDDATA,
		Data_Length	=> Data_Length_i,
		MISO_EN		=> SPI_MISO_EN,
		MISO_Start	=> SPI_MISO_Start,
		SS_MOSI_Wait=> SS_MOSI_Wait_i,
		Int_SCLK	=> Int_SCLK,
		
		-- SPI Physical Interface
		SPI_SS_N	=> Int_SS_N,
	    SPI_SCLK	=> SPI_SCLK,
	    SPI_MOSI	=> SPI_MOSI,
	    SPI_MISO	=> SPI_MISO
	);

	SPI_SS_N	<= Int_SS_N;

	Tx_FIFO : entity WORK.FIFO_GENERIC_SC
	  Generic Map(
		FIFO_DEPTH		=> 5,				-- 2**FIFO_DEPTH = Number of Words in FIFO
		FIFO_WIDTH		=> Data_Size,		-- FIFO Words Number of Bits
		-- FIFO_WIDTH		=> 8,
		AEMPTY_LEVEL	=> 0,
		AFULL_LEVEL		=> 20,
		RAM_STYLE		=> "block",		-- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
		SHOW_AHEAD		=> True
	  )
	  Port Map(
		CLK			=> CLK,
		RST			=> RST,
		CLR			=> TxFIFO_CLR,
		WRREQ		=> TxFIFO_WRREQ,
		WRDATA		=> TxFIFO_WRDATA,
		RDREQ		=> TxFIFO_RDREQ,
		RDDATA		=> TxFIFO_RDDATA,
		EMPTY		=> TxFIFO_Empty,
		FULL		=> TxFIFO_Full,
		USEDW		=> TxBuffFilled,
		AFULL		=> TxFIFO_AlmostFull,
		AEMPTY		=> open
	  );
	
	RxFIFO_WRDATA	<= SPI_RDDATA;
	RxFIFO_WRREQ	<= SPI_RD_REQ;

	Rx_FIFO : entity WORK.FIFO_GENERIC_SC
	  Generic Map(
		FIFO_DEPTH		=> 5,				-- 2**FIFO_DEPTH = Number of Words in FIFO
		FIFO_WIDTH		=> Data_Size,		-- FIFO Words Number of Bits
		AEMPTY_LEVEL	=> 0,
		AFULL_LEVEL		=> 25,
		RAM_STYLE		=> "block",		-- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
		SHOW_AHEAD		=> True
	  )
	  Port Map(
		CLK			=> CLK,
		RST			=> RST,
		CLR			=> RxFIFO_CLR,
		WRREQ		=> RxFIFO_WRREQ,
		WRDATA		=> RxFIFO_WRDATA,
		RDREQ		=> RxFIFO_RDREQ,
		RDDATA		=> RxFIFO_RDDATA,
		EMPTY		=> RxFIFO_Empty,
		FULL		=> RxFIFO_Full,
		USEDW		=> RxBuffFilled,
		AFULL		=> RxFIFO_AlmostFull,
		AEMPTY		=> open
	  );

end RTL;