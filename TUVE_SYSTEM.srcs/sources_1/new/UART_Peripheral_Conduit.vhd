--------------------------------------------------------------------------------------------
-- Copyright    : Tonbo Imaging
-- Project Name : Tonboimaging - Thermal Camera Project
-- Block Name   : UART_Peripheral_Conduit
-- Description  : Top Module to act as an intermediary between the HPS and a UART peripheral device.
-- Author       : Sai Parthasarathy M.
-- Date         : JUN 2015
-- Design Notes	: UART_Peripheral_Conduit is the module which acts as the Soft UART controller
--				  between the HPS outputs and a peripheral device, to send Control and Data,
--				  and receive whatever data may be sent back to the HPS.
--				  It also sends some control signals to the LTC2870 chip, which acts as the
--				  switch between sending and receiving data in RS232 format or RS485 format.
--				  Link to datasheet: http://cds.linear.com/docs/en/datasheet/28701fa.pdf
--				  The communication between the FPGA and the HPS takes place through a
--				  Memory Mapped I/O, which follows the Avalon MM "protocol", which involves the
--				  inputs and outputs in the "Input from HPS to FPGA" and "Output from FPGA to HPS"
--				  sections of the PORT of the entity.
--				  Module has been written to keep Rx and Tx separate, and thus be able to handle
--				  Full Duplex communication between the device and HPS through the UART.
--				  The data bytes received are stored in two FIFOs, Tx_FIFO and Rx_FIFO. These are
--				  buffers to keep the HPS from supplying data too fast to the UART, and to keep the
--				  UART from overwriting its own output data in case the HPS is stalled.
-- Patch 1.1:
--				  Mark Space Parity option is provided as a Generic input.
--				  Now also has CLR inputs to reset FIFOs if necessary.
--				  Can also detect Timeout from Serial Peripheral after 4 blank word time periods.
--				  Counters for UsedW in FIFO IP were unreliable, so separate counters were made.
--				  Default Baud rate is Baud1 = 115200. Default word format is 8-bit words.
-- Patch 1.2:
--				  Introduced interrupts, linked to RxRDY signal, i.e., whenever new data is received.
-- Patch 1.3:
--				  Introduced multiple baud rates, runtime changeable. Baud rates have an extra 
--				  control register at 0x0C.
-- Patch 1.4:
--				  Mark Space Parity option made runtime changeable.
--				  Increased FIFO size to 255 data bytes.
-- Patch 1.5:
--				  Discovered bug in interrupt generation. Since interrupt generation is linked to
--				  RxRDY, it is possible that a data byte is received while Kernel Module is in the
--				  ISR, and sets the interrupt flag to 0. When this happens, one or two bytes in the
--				  FPGA FIFO are ignored until more data is received. Introduced timer to activate
--				  interrupt if no read is performed in 10 ms after the current QueueSize becomes
--				  a non-zero value.
-- Version		: v201509
--------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Peripheral_Conduit is
	GENERIC (
		Fxtal     	:		integer  := 27e6;  -- in Hertz
		Baud1     	:		positive := 4800;
		Baud2     	:		positive := 9600;
		Baud3     	:		positive := 19200;
		Baud4     	:		positive := 38400;
		Baud5     	:		positive := 57600;
		Baud6     	:		positive := 115200;
		Baud7     	:		positive := 921600;		
		--BaudSel	  	:		STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
		WordFormat	:		STD_LOGIC_VECTOR (1 downto 0) := "10";
		RS_232_485	:		STD_LOGIC := '0';	-- '0' -> RS232, '1' -> RS485
		Parity		:		STD_LOGIC := '0';
		ModeParity	: 		STD_LOGIC := '0' 
		);
	PORT(
		-----------------------------------------
		--	Device Clock and Asynchronous Reset
		CLK					:	in STD_LOGIC;
		RST					:	in STD_LOGIC;
		-----------------------------------------
		--	UART Specifics
		-- BaudSel			:	in STD_LOGIC						:= '0';	-- Baud Rate Select Baud1 (0) / Baud2 (1)
		-- WordFormat		:	in STD_LOGIC_VECTOR (1 downto 0)	:= "10";-- 6 bits (00) / 7b (01) / 8b (10)
		-----------------------------------------
		--	Input from HPS to FPGA
		AVS_WriteData		:	in STD_LOGIC_VECTOR (31 downto 0);	-- writedata	- Avalon MM
		AVS_Write_EN		:	in STD_LOGIC;						-- write		- Avalon MM
		AVS_Read_EN			:	in STD_LOGIC;						-- read			- Avalon MM
		AVS_Address			:	in STD_LOGIC_VECTOR (7 downto 0);	-- AVS_Address		- Avalon MM
		-----------------------------------------
		--	Output from FPGA to HPS
		AVS_ReadData		:	out STD_LOGIC_VECTOR (31 downto 0);	-- readdata		- Avalon MM
		AVS_Wait_Req		:	out STD_LOGIC;						-- waitreq		- Avalon MM
		AVS_ReadDAV			:	out STD_LOGIC;						-- AVS_ReadDAV- Avalon MM
		-----------------------------------------
		--	Serial Input Data from Device to FPGA
		UART_Rx				:	in STD_LOGIC;
		-----------------------------------------
		--	Serial Output Data from FPGA to Device
		UART_Tx				:	out STD_LOGIC;
		Trigger_int_signal	: out STD_LOGIC;
		-----------------------------------------
		--	Signals from FPGA to LTC2870
		SEL_232_485			:	out STD_LOGIC						-- FPGA_GPIO_RS232/RS485 = FPGA_GPIO_TE485
		-----------------------------------------				-- Both signals are either 1 or 0 together
		);
end entity UART_Peripheral_Conduit;

architecture RTL of UART_Peripheral_Conduit is

function MyMin ( i, j : integer) return integer is
begin
  if i <= j then return i; else return j; end if;
end function;

-- Special UART Modes
signal MSParity			:	STD_LOGIC := '0';

-- All the AVS_Addresses for this module that you'll need to use
constant UART_STATUS	:	STD_LOGIC_VECTOR (7 downto 0) := x"00";
constant UART_DATA_RD	:	STD_LOGIC_VECTOR (7 downto 0) := x"04";
constant UART_DATA_WR	:	STD_LOGIC_VECTOR (7 downto 0) := x"08";
constant UART_BAUD_SEL  :   STD_LOGIC_VECTOR (7 downto 0) := x"0C";

-- All internal signals are from POV of UART_Peripheral_Conduit
signal Tx_Data_Word		:	STD_LOGIC_VECTOR (8 downto 0);
signal Tx_FIFO_Empty	:	STD_LOGIC;
signal Tx_FIFO_Full		:	STD_LOGIC;
signal Tx_FIFO2UART		:	STD_LOGIC_VECTOR (8 downto 0);
signal TxBuffFilled		:	STD_LOGIC_VECTOR (8 downto 0);
signal Tx_FIFO_AlmostFull	:	STD_LOGIC;
signal Tx_FIFO_QueueSize:	STD_LOGIC_VECTOR (7 downto 0);
signal Tx_FIFO_CLR		:	STD_LOGIC;

signal Rx_UART2FIFO			:	STD_LOGIC_VECTOR (7 downto 0);
signal Rx_FIFO_Empty		:	STD_LOGIC;
signal Rx_FIFO_Full			:	STD_LOGIC;
signal Rx_Data_Word			:	STD_LOGIC_VECTOR (7 downto 0);
signal Temp_Rx_Data_Word	:	STD_LOGIC_VECTOR (7 downto 0);
signal RxBuffFilled			:	STD_LOGIC_VECTOR (8 downto 0);
signal Rx_FIFO_AlmostFull	:	STD_LOGIC;
signal Rx_FIFO_QueueSize	:	STD_LOGIC_VECTOR (7 downto 0);
signal Rx_FIFO_CLR			:	STD_LOGIC;

signal Tx_Protocol_SEL	:	STD_LOGIC := '1';
signal Tx_Status_Reg	:	STD_LOGIC_VECTOR (7 downto 0);
signal Rx_Status_Reg	:	STD_LOGIC_VECTOR (7 downto 0);
signal ReadDAV_Sig		:	STD_LOGIC;
signal ReadDAV_Sig_i	:	STD_LOGIC;

signal Interrupt_Gen	:	STD_LOGIC;
signal count_irq		:	unsigned (27 downto 0);

--	UART Signals
signal LD				:	STD_LOGIC;
signal UART_Din			:	STD_LOGIC_VECTOR (7 downto 0);
signal FirstByte		:	STD_LOGIC;
signal RS232_STS		:	STD_LOGIC_VECTOR (2 downto 0);
signal TxBusy			:	STD_LOGIC;
signal RxRDY			:	STD_LOGIC;
signal IO_EN			:	STD_LOGIC;
signal Rx_AVS_Read_EN_sig	:	STD_LOGIC;
signal Tx_wrreq_sig		:	STD_LOGIC;
signal baud_sel_1       : std_logic_vector(2 downto 0) := "000";

constant Divisor1		:	positive := (Fxtal / Baud1) / 2;
constant Divisor2		:	positive := (Fxtal / Baud2) / 2;
constant Divisor3		:	positive := (Fxtal / Baud3) / 2;
constant Divisor4		:	positive := (Fxtal / Baud4) / 2;
constant Divisor5		:	positive := (Fxtal / Baud5) / 2;
constant Divisor6		:	positive := (Fxtal / Baud6) / 2;
constant Divisor7		:	positive := (Fxtal / Baud7) / 2;

constant MaxFactor		:	positive := Fxtal / MyMin(Baud6,Baud2);
signal TxDivisor		:	integer range 0 to MaxFactor;   -- Tx division factor
signal TxDiv			:	integer range 0 to MaxFactor;
signal TopTx			:	std_logic := '0';
signal Timeout_CNTR		:	STD_LOGIC_VECTOR (7 downto 0);
signal Timeout			:	STD_LOGIC;
signal Timeout_Mode		:	STD_LOGIC;

type interrupt_extension is (Idle, Counting_While_Extending, Waiting_Till_Next_Tick);
signal state_delay : interrupt_extension;

type interrupt_state is (Idle, Wait_After_Interrupt_Triggered, Wait_For_Counter_Idle);
signal state_IRQ_Gen: interrupt_state;

begin

	SEL_232_485			<= Tx_Protocol_SEL;
	AVS_Wait_Req		<= Tx_FIFO_Full;
	Rx_Status_Reg		<= "000" & Rx_FIFO_CLR & Rx_FIFO_Empty & Rx_FIFO_Full & Rx_FIFO_AlmostFull & Timeout;
	Tx_Status_Reg		<= "000" & Tx_FIFO_CLR & Tx_FIFO_Empty & Tx_FIFO_Full & Tx_FIFO_AlmostFull & Tx_Protocol_SEL;	-- if Tx_Protocol_SEL = '0', RS232 mode, and if '1', RS485.
	Rx_AVS_Read_EN_sig	<= ReadDAV_Sig and IO_EN;
	AVS_ReadDAV			<= ReadDAV_Sig_i;




	IRQ_Gen: process(CLK,RST)
	begin
		if(RST = '1') then
			Interrupt_Gen <= '0';
			state_IRQ_Gen <= idle;
		elsif rising_edge(CLK) then
			
			case state_IRQ_Gen is
			
			when Idle =>
				if Rx_FIFO_QueueSize /= x"00" then
					Interrupt_Gen <= '1';
				 	state_IRQ_Gen <= Wait_After_Interrupt_Triggered;
				end if;
			
			when Wait_After_Interrupt_Triggered =>
				Interrupt_Gen <= '0';
				if(state_delay = Counting_While_Extending) then
					state_IRQ_Gen <= Wait_For_Counter_Idle;
				end if;

			when Wait_For_Counter_Idle =>
				if (state_delay = Idle) then
					state_IRQ_Gen <= Idle;
				end if;

			when others =>
				Interrupt_Gen <= '0';
				state_IRQ_Gen <= Idle;

			end case;
		end if;
	end process;

	process(CLK,RST)
	begin
		if RST = '1' then
			Trigger_int_signal <= '0';
			count_irq <= (others => '0');
			state_delay <= idle;
		elsif rising_edge(CLK) then
			
			case state_delay is 
				
			when Idle =>
				if(Interrupt_Gen = '1') then
					count_irq <= (others => '0');
					Trigger_int_signal <= '1';
					state_delay <= Counting_While_Extending;
				else
					Trigger_int_signal <= '0';
				end if;

			when Counting_While_Extending =>
				if(count_irq = x"000006C") then		-- 180 ticks
					Trigger_int_signal <= '0';
					count_irq <= count_irq + 1;
					state_delay <= Waiting_Till_Next_Tick;
				else
					Trigger_int_signal <= '1';
					count_irq <= count_irq + 1;
				end if;

			when Waiting_Till_Next_Tick =>
--				if (count_irq = x"001A5E0") then	-- 180,000 ticks
                if (count_irq = x"001770") then	-- 6000 ticks
					count_irq <= (others => '0');
					state_delay <= Idle;
				else
					count_irq <= count_irq + 1;
				end if;
			
			when others => 
				Trigger_int_signal <= '0';
				count_irq <= (others => '0');
				state_delay <= Idle;
			end case;
		end if;
	end process;

	
	-- process(RST,CLK)
	-- begin
		-- elsif rising_edge (CLK) then
			-- if unsigned(TxBuffFilled) = to_unsigned(30,5) then
				-- AVS_Wait_Req = '1';
			-- end if;
			-- if Tx_FIFO_Empty = '1' then
				-- AVS_Wait_Req = '0';
			-- end if;
		-- end if;
	-- end process;
	
	-- --------------------------
	--  Baud Rate conversion
	-- --------------------------
	-- Note that constants are (actual_divisor - 1)
	-- You can easily add more BaudRates by extending the "case" instruction...
	process (RST, CLK)
	begin
		if RST='1' then
			TxDivisor <= 0;
		elsif rising_edge(CLK) then
			case baud_sel_1 is
				when "000" =>		TxDivisor <= (2 * Divisor1) - 1;
				when "001" =>		TxDivisor <= (2 * Divisor2) - 1;
				when "010" =>		TxDivisor <= (2 * Divisor3) - 1;
				when "011" =>		TxDivisor <= (2 * Divisor4) - 1;
				when "100" =>		TxDivisor <= (2 * Divisor5) - 1;
				when "101" =>		TxDivisor <= (2 * Divisor6) - 1;
				when "110" =>		TxDivisor <= (2 * Divisor7) - 1;
				when others =>	TxDivisor <= 0;
			end case;
		end if;
	end process;
	-----------------------------
	
	-- --------------------------
	--  Tx Clock Generation
	-- --------------------------
	-- Periodicity : bit time
	process (RST, CLK)
	begin
		if RST='1' then
			TxDiv <=  0 ;
			TopTx <= '0';                                   -----TopTx  : TX CLK
		elsif rising_edge(CLK) then
			
			if TxDiv = TxDivisor then
				TxDiv <= 0;
				TopTx <= '1';
			else
				TxDiv <=  TxDiv + 1;
				TopTx <= '0';
			end if;
		end if;
	end process;
	-----------------------------
	
	Timeout_Calc: process (RST, CLK)
	begin
		if RST = '1' then
			Timeout			<= '0';
			Timeout_Mode	<= '1';
			Timeout_CNTR	<= (others =>'0');
		elsif rising_edge (CLK) then
			if TopTx = '1' then
				Timeout_CNTR	<= STD_LOGIC_VECTOR(unsigned(Timeout_CNTR) + 1);
			end if;
			if RxRDY = '1' then
				Timeout_CNTR	<= (others => '0');
				Timeout_Mode	<= '0';
			end if;
			
			case WordFormat is
			when "00" =>
				if (unsigned(Timeout_CNTR) = to_unsigned(40,8) and Timeout_Mode = '0') then
					Timeout			<= '1';
					Timeout_Mode	<= '1';
				end if;
			when "01" =>
				if (unsigned(Timeout_CNTR) = to_unsigned(45,8) and Timeout_Mode = '0') then
					Timeout			<= '1';
					Timeout_Mode	<= '1';
				end if;
			when "10" =>
				if (unsigned(Timeout_CNTR) = to_unsigned(50,8) and Timeout_Mode = '0') then
					Timeout			<= '1';                        ------------------------- To be checked
					Timeout_Mode	<= '1';
				end if;
			when others =>
				Timeout				<= Timeout;
				Timeout_Mode		<= Timeout_Mode;
			end case;
			
			if Rx_AVS_Read_EN_sig = '1' then
				Timeout			<= '0';
				Timeout_Mode	<= '0';
			end if;
		end if;
	end process;
	
	process(CLK,RST)
	begin
		if RST = '1' then
			ReadDAV_Sig <= '0';
			ReadDAV_Sig_i <= '0';
		elsif rising_edge(CLK) then
			-- if (Rx_FIFO_Empty = '0') then
				ReadDAV_Sig <= AVS_Read_EN;
			-- else
				-- ReadDAV_Sig <= '0';
			-- end if;
			ReadDAV_Sig_i <= ReadDAV_Sig;
		end if;
	end process;
	
	Queue_Sizes: process(RST,CLK)
	begin
		if RST = '1' then
			Rx_FIFO_QueueSize <= (others => '0');
			Tx_FIFO_QueueSize <= (others => '0');
		elsif rising_edge (CLK) then
			if (Rx_FIFO_CLR = '1') then
				Rx_FIFO_QueueSize <= (others => '0');
			elsif (RxRDY = '1' and (unsigned(Rx_FIFO_QueueSize) <= to_unsigned(255,8))) then
				Rx_FIFO_QueueSize <= STD_LOGIC_VECTOR(unsigned(Rx_FIFO_QueueSize) + 1);
			elsif (Rx_AVS_Read_EN_sig = '1' and (unsigned(Rx_FIFO_QueueSize) > to_unsigned(0,8))) then
				Rx_FIFO_QueueSize <= STD_LOGIC_VECTOR(unsigned(Rx_FIFO_QueueSize) - 1);
			end if;
			
			if (Tx_FIFO_CLR = '1') then
				Tx_FIFO_QueueSize <= (others => '0');
			elsif (Tx_wrreq_sig = '1' and (unsigned(Tx_FIFO_QueueSize) <= to_unsigned(255,8))) then
				Tx_FIFO_QueueSize <= STD_LOGIC_VECTOR(unsigned(Tx_FIFO_QueueSize) + 1);
			elsif (LD = '1' and (unsigned(Tx_FIFO_QueueSize) > to_unsigned(0,8))) then
				Tx_FIFO_QueueSize <= STD_LOGIC_VECTOR(unsigned(Tx_FIFO_QueueSize) - 1);
			end if;
		end if;
	end process;
	
	IO_Process: process(RST,CLK)
	begin
		if(RST = '1') then
			Tx_Protocol_SEL <= RS_232_485;							-- Unless specifically set to '1', always set to use RS232 by default.
			Temp_Rx_Data_Word <= (others => '0');
			Tx_Data_Word <= (others => '0');
			Tx_wrreq_sig <= '0';
			IO_EN <= '0';
			Tx_FIFO_CLR		<= '0';
			Rx_FIFO_CLR		<= '0';
			baud_sel_1   <= (others => '0');
		elsif(rising_edge(CLK)) then
			Tx_wrreq_sig <= '0';
			-- IO_EN <= '0';
			Tx_FIFO_CLR		<= '0';
			Rx_FIFO_CLR		<= '0';
			if AVS_Read_EN = '1' then
				case AVS_Address is
				when UART_BAUD_SEL =>
					AVS_ReadData <= x"00000" & "000" & MSParity & x"0" & '0' & baud_sel_1;
				when UART_STATUS =>
					IO_EN <= '0';								-- '0' means module is receiving/sending Control Signals
					AVS_ReadData <= Rx_FIFO_QueueSize
									& Rx_Status_Reg
									& Tx_FIFO_QueueSize
									& Tx_Status_Reg;			-- If readreq is sent, then readdata is:
																-- Byte 3: No. of Rx_Bytes in waiting
																-- Byte 2: Rx Status Register
																-- Byte 1: No. of Tx_Bytes in waiting
																-- Byte 0: Tx Status Register
					-- AVS_ReadData <= x"000000" & Tx_Status_Reg;	-- If readreq is sent, then readdata is the status of the SEL_232_485
				when UART_DATA_RD =>
					IO_EN <= '1';								-- '1' means module is receiving/sending Data
					Tx_wrreq_sig <= '0';
					if Rx_FIFO_Empty = '0' then					-- Upon setting AVS_Read_EN to '1', check if Rx_FIFO is not empty, then pop a word out
						AVS_ReadData <= x"F00000" & Rx_Data_Word;
						Temp_Rx_Data_Word <= Rx_Data_Word;
					else												-- If Rx_FIFO is empty, then give the most recently popped word as the output.
						AVS_ReadData <= x"F00000" & Temp_Rx_Data_Word;	-- Of course, this should not happen, as Read Request should only be given
					end if;												-- when the HPS expects the Device to send data.
				when others =>
					IO_EN <= '0';										-- When the AVS_Address is anything else, disable HPS2FPGA/FPGA2HPS data
					Tx_wrreq_sig <= '0';								-- but keep the rest of the system running to push out all data in Tx_FIFO.
				end case;
			end if;
			if AVS_Write_EN = '1' then
				case AVS_Address is
				when UART_BAUD_SEL =>
					baud_sel_1	<= AVS_WriteData(2 downto 0);
					MSParity	<= AVS_WriteData(8);
				when UART_STATUS =>
					IO_EN <= '0';
					Tx_Protocol_SEL <= AVS_WriteData(0);		-- If writereq is sent, then SEL_232_285 is eventually written to supplied value.
					Tx_FIFO_CLR		<= AVS_WriteData(4);		-- Same bit position as RD of same bit in Tx_Status_Reg
					Rx_FIFO_CLR		<= AVS_WriteData(20);		-- Same bit position as RD of same bit in Rx_Status_Reg
				when UART_DATA_WR =>
					-- IO_EN <= '1';
					IO_EN <= '0';
					Tx_Data_Word <= AVS_WriteData (8 downto 0);
					Tx_wrreq_sig <= '1';
				when others =>
					IO_EN <= '0';
					Tx_wrreq_sig <= '0';
				end case;
			end if;	
		end if;
	end process;
	
	TxFIFO2UART_process: process(CLK,RST)
	begin
		if(RST = '1') then
			LD <= '0';
		elsif(rising_edge(CLK)) then
			if(Tx_FIFO_Empty = '0' and TxBusy = '0' and LD = '0') then	
				LD <= '1';					-- Our data is already in the register Tx_FIFO2UART.
			else							-- The LD is just an acknowledgement to the Tx_FIFO that
				LD <= '0';					-- its output, q, has been read.
			end if;
		end if;
	end process;

	Tx_FIFO : entity WORK.FIFO_GENERIC_SC
	  Generic Map(
		FIFO_DEPTH		=> 9,				-- 2**FIFO_DEPTH = Number of Words in FIFO
		FIFO_WIDTH		=> 9,				-- FIFO Words Number of Bits
		-- FIFO_WIDTH		=> 8,
		AEMPTY_LEVEL	=> 0,
		AFULL_LEVEL		=> 20,
		RAM_STYLE		=> "block",		-- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
		SHOW_AHEAD		=> True
	  )
	  Port Map(
		CLK			=> CLK,
		RST			=> RST,
		CLR			=> Tx_FIFO_CLR,
		WRREQ		=> Tx_wrreq_sig,
		WRDATA		=> Tx_Data_Word,
		RDREQ		=> LD,
		RDDATA		=> Tx_FIFO2UART,
		EMPTY		=> Tx_FIFO_Empty,
		FULL		=> Tx_FIFO_Full,
		USEDW		=> TxBuffFilled,
		AFULL		=> Tx_FIFO_AlmostFull,
		AEMPTY		=> open
	  );
	
	Rx_FIFO : entity WORK.FIFO_GENERIC_SC
	  Generic Map(
		FIFO_DEPTH		=> 9,				-- 2**FIFO_DEPTH = Number of Words in FIFO
		FIFO_WIDTH		=> 8,				-- FIFO Words Number of Bits
		AEMPTY_LEVEL	=> 0,
		AFULL_LEVEL		=> 25,
		RAM_STYLE		=> "block",		-- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
		SHOW_AHEAD		=> True
	  )
	  Port Map(
		CLK			=> CLK,
		RST			=> RST,
		CLR			=> Rx_FIFO_CLR,
		WRREQ		=> RxRDY,
		WRDATA		=> Rx_UART2FIFO,
		RDREQ		=> Rx_AVS_Read_EN_sig,	-- Rx_AVS_Read_EN_sig = AVS_Read_EN and IO_EN; 
		RDDATA		=> Rx_Data_Word,
		EMPTY		=> Rx_FIFO_Empty,
		FULL		=> Rx_FIFO_Full,
		USEDW		=> RxBuffFilled,
		AFULL		=> Rx_FIFO_AlmostFull,
		AEMPTY		=> open
	  );
	
	UART_Din	<= Tx_FIFO2UART (7 downto 0);
	FirstByte	<= Tx_FIFO2UART (8);
	
	i_UART : entity WORK.UART_New
      generic map (
        Fxtal		=> Fxtal				,
        Baud1		=> Baud1				,
        Baud2		=> Baud2				,
        Baud3		=> Baud3				,
        Baud4		=> Baud4				,
        Baud5		=> Baud5				,
        Baud6		=> Baud6				 

      ) port map (
		CLK			=> CLK					,
		RST			=> RST					,
		
		Din			=> UART_Din				,
		FirstByte	=> FirstByte			,
		LD			=> LD					,
		Rx			=> UART_Rx				,
		
		Baud		=> baud_sel_1			,	-- Baud Rate Select Baud1 (0) / Baud2 (1)
		Parity		=> Parity					,	-- No Parity (0) / Parity (1)
		MSParity	=> MSParity				,
		Even		=> ModeParity					,	-- Odd (0) / Even (1)
		Format		=> "10"					,	-- 6 bits (00) / 7b (01) / 8b (10)
		Status		=> RS232_STS			,
		
		Dout		=> Rx_UART2FIFO			,
		Tx			=> UART_Tx		,
		TxBusy		=> TxBusy				,
		RxErr		=> open					,	-- If everything is working as it is supposed to, then this signal should be useless.
		RxRDY		=> RxRDY					);	-- ^If it's not useless, then sorry.

end RTL;