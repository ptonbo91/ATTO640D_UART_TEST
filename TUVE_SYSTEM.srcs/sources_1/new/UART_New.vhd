-- UART.vhd
-- -----------------------------------------------------------------------
--   Synthesizable UART - Dynamically Parametrizable Version - VHDL Model
--   (c) ALSE - cannot be used without the prior written consent of ALSE
-- -----------------------------------------------------------------------
--  Version  : 2011.08
--  Date     : Aug 2011
--  Author   : Bert CUZEAU
--  Contact  : info@alse-fr.com
--  Web      : http://www.alse-fr.com
-- ---------------------------------------------------------------
--  FUNCTION :
--    Asynchronous RS232 Transceiver with internal Baud rate generator.
--    This model is synthesizable to any technology. No internal Fifo.
--
--    Can use any Xtal but verify that :
--       Fxtal / max(Baudrate) is accurate enough
--    For very high speeds, it is recommended to use specific
--    Xtal frequencies like 18.432 MHz, etc...
--    Transmit & Receive occur with identical format.
--
--    ----------------
--   | Baud |  Rate   |
--   |------|---------|
--   |   0  |  Baud1  |  115200 by default
--   |   1  |  Baud2  |  19.200 by default
--    ----------------
--
--
--  Generics / Default values :
--  -------------------------
--    Fxtal  = Main Clock frequency in Hertz
--    Format : "00"= 6 bits, "01"=7bits, "10"=8 bits  ("11" is also 8 bits)
--    Parity = '0' if no parity wanted
--    Even   = '1' means even, '0' means Odd, ignored if not parity
--    Baud1  = Baud rate # 1
--    Baud2  = Baud rate # 2
--
--   Typical Area :  (depends on division factor)
--     ~ 100 LCs (Flex 10k)
--     ~ 45 CLB slices (Spartan 2)
--     ~ 115 LUTs (Virtex 2 pro)
--   You can use almost any VHDL synthesis tool
--   like LeonardoSpectrum, Synplify, XST (ISE), QuartusII, etc...
--
--   Design notes :
--
--   1. Baud rate divisor constants are computed automatically
--      with the Fxtal Generic value.
--
--   2. Format options (Use of Parity & Even/Odd format)
--      are dynamic choices in this version
--
--   3. Invalid characters do not generate an RxRDY.
--     this can be modified easily in RxOVF State.
--
--   4. The Tx & Rx State Machines are resync'd Mealy type, and
--     they could be encoded as binary (one-hot isn't very useful).
--
--   Modifications :
--     Added internal resync FlipFlop on Rx & RTS.
--     you don't have to resynchronize them externally.
--
--  v2011.08 :
--   * fixed the ClrDiv sIDLE glitch bug
--     ClrDiv is now removed & replaced by a IDLE_Rx Check
--
--  v5.1 :
--   * fixed rx which was read in RxOVF state
--
--  v4.1 :
--   * fixed a bug in the parity calculation
--   * removed RegDin (smaller by 8 x FlipFlops)
--
--   Open Issues :
--     The sampling could be more sophisticated, and we could have more
--     frame checking done, and framing errors handling could be enhanced.
--     In fact, we assume that there will be no error...
--     which is often the case : this UART has flawlessly exchanged
--     millions of bytes. Moreover, sensitive data should always be
--     checked within a data exchange protocol (CRC, checksum,...).
--
-- ---------------------------------------------------------------

-- July 2012 : special version for Schlumberger Recorder
--  => Three possible baudrates

-- Sai Parthasarathy
-- September 2015 : Added functionality - Mark Space Parity, where
--					first data byte has parity bit '1', and all the
--					rest of the data bytes in a message have the
--					parity bit set to '0'.
--					Mark Space Parity is completely independent and
--					separate in concept and implementation from the
--					regular parity in UART communication.
-- Sai Parthasarathy
-- January 2017 : Moved Mark Space Parity into PORT inputs.

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-- ----------------------------------------------
    Entity UART_New is
-- ----------------------------------------------
-- Notes :
--   Nb of Stop bits = 1 (always)

  Generic (
    Fxtal     :     integer  := 216E6;  -- in Hertz
		Baud1     	:		positive := 4800;
		Baud2     	:		positive := 9600;
		Baud3     	:		positive := 19200;
		Baud4     	:		positive := 38400;
		Baud5     	:		positive := 57600;
		Baud6     	:		positive := 115200;
		Baud7     	:		positive := 921600
  );
  Port (  CLK       : in  std_logic;  -- System Clock at Fqxtal
          RST       : in  std_logic;  -- Asynchronous Reset active high

          Din       : in  std_logic_vector (7 downto 0);
          FirstByte : in  std_logic;  -- For First Byte of data FirstByte (1), else FirstByte (0)
          LD        : in  std_logic;  -- Load, must be pulsed high
          Rx        : in  std_logic;

		      MSParity	: in  std_logic := '0'; -- Mark Space Parity Enable (1) / Disable (0)
          Baud      : in  std_logic_vector(2 downto 0);        -- Baud Rate Select Baud1 (0) / Baud2 (1)
          Parity    : in  std_logic := '1'; -- No Parity (0) / Parity (1)
          Even      : in  std_logic := '1'; -- Odd (0) / Even (1)
          Format    : in std_logic_vector (1 downto 0) := "10"; -- 6 bits (00) / 7b (01) / 8b (10)
          Status    : out std_logic_vector(2 downto 0);         -- RS232 Status (2=RxERR, 1=TxEn, 2=RxEn)

          Dout      : out std_logic_vector(7 downto 0);
          Tx        : out std_logic;
          TxBusy    : out std_logic;  -- '1' when Busy sending
          RxErr     : out std_logic;
          RxRDY     : out std_logic   -- '1' when Data available
       );
end UART_New;


-- ---------------------------------------------------------------
    Architecture RTL of UART_New is
-- ---------------------------------------------------------------
function myMin ( i, j : integer) return integer is
begin
  if i <= j then return i; else return j; end if;
end function;

constant Debug : integer := 1;
constant MaxFactor		:	positive := Fxtal / MyMin(Baud6,Baud2);

constant Divisor1		:	positive := (Fxtal / Baud1) / 2;
constant Divisor2		:	positive := (Fxtal / Baud2) / 2;
constant Divisor3		:	positive := (Fxtal / Baud3) / 2;
constant Divisor4		:	positive := (Fxtal / Baud4) / 2;
constant Divisor5		:	positive := (Fxtal / Baud5) / 2;
constant Divisor6		:	positive := (Fxtal / Baud6) / 2;
constant Divisor7		:	positive := (Fxtal / Baud7) / 2;

Type TxFSM_State is (Idle_Tx, Load_Tx, Shift_Tx, Parity_Tx, Stop_Tx  );
signal TxFSM : TxFSM_State;

Type RxFSM_State is (Idle_Rx, Start_Rx, Shift_Rx, Edge_Rx, MS_Parity_Rx,
                     Parity_Rx, Parity_2, Stop_Rx, RxOVF );
signal RxFSM : RxFSM_State;

signal Tx_Reg : std_logic_vector (8 downto 0);
signal Rx_Reg : std_logic_vector (7 downto 0);
signal Tx_First : std_logic;

signal RxDivisor: integer range 0 to MaxFactor/2; -- Rx division factor
signal TxDivisor: integer range 0 to MaxFactor;   -- Tx division factor

signal RxDiv : integer range 0 to MaxFactor/2;
signal TxDiv : integer range 0 to MaxFactor;

signal TopTx : std_logic;
signal TopRx : std_logic;

signal TxBitCnt : integer range 0 to 15;

signal RxBitCnt : integer range 0 to 15;
signal RxRDYi   : std_logic;
signal Rx_Par   : std_logic; -- Receive parity built
signal Tx_Par   : std_logic; -- Transmit parity built
signal RxErri   : std_logic;

signal Rx_r     : std_logic;  -- resync FlipFlop for Rx input

signal LocDin   : std_logic_vector (7 downto 0); -- for multiple data length
signal iFormat : integer range 0 to 2;

--------
begin
--------

-- Outputs
RxErr <= RxErri; 

-- fill unused upper bits with 1's :
LocDin <= "11" & Din(5 downto 0) when Format = "00" -- 6 bits
    else  '1'  & Din(6 downto 0) when Format = "01" -- 7 bits
    else         Din;              -- Format = "10" (or 11) 8 bits

-- make sure we have only 3 choices (0, 1, 2) :
iFormat <= 0 when Format = "00"      -- 6 bits
     else  1 when Format = "01"      -- 7 bits
     else  2;  -- Format = "10" (or 11) 8 bits

-- -----------------------------------
--  Status Generation
-- -----------------------------------
-- RxErr
Status(2) <= RxErri;
-- TxEn
Status(1) <= '1' When (TxFSM /= Idle_Tx) Else '0';
-- RxEn
Status(0) <= '1' When (RxFSM /= Idle_Rx) Else '0';


-- -----------------------------------
--  Rx input resynchronization
-- -----------------------------------
Rx_Input_Resync: process (RST, CLK)
begin
  if RST='1' then
    Rx_r  <= '1';  -- avoid false start bit at powerup
  elsif rising_edge(CLK) then
    Rx_r <= Rx;
  end if;
end process;

-- --------------------------
--  Baud Rate conversion
-- --------------------------
-- Note that constants are (actual_divisor - 1)
-- You can easily add more BaudRates by extending the "case" instruction...
Baud_Rate_Conv: process (RST, CLK)
begin
  if RST='1' then
    RxDivisor <= 0;
    TxDivisor <= 0;
  elsif rising_edge(CLK) then
    case Baud is
      when "000" =>    RxDivisor <= Divisor1 - 1;
                     TxDivisor <= (2 * Divisor1) - 1;
      when "001" =>    RxDivisor <= Divisor2 - 1;
                     TxDivisor <= (2  * Divisor2) - 1;
      when "010" =>    RxDivisor <= Divisor3 - 1;
                     TxDivisor <= (2 * Divisor3) - 1;
      when "011" =>    RxDivisor <= Divisor4 - 1;
                     TxDivisor <= (2  * Divisor4) - 1;
      when "100" =>    RxDivisor <= Divisor5 - 1;
                     TxDivisor <= (2 * Divisor5) - 1;
      when "101" =>    RxDivisor <= Divisor6 - 1;
                     TxDivisor <= (2  * Divisor6) - 1;
      when "110" =>    RxDivisor <= Divisor7 - 1;
                     TxDivisor <= (2 * Divisor7) - 1;
      when others => RxDivisor <= 1;   -- n.u.
                     TxDivisor <= 1;
    end case;
  end if;
end process;

-- ------------------------------
--  Rx Clock Generation
-- ------------------------------
-- Periodicity : bit time / 2

Rx_CLK_Gen: process (RST, CLK)
begin
  if RST='1' then
    RxDiv <= 0 ;
    TopRx <= '0';
  elsif rising_edge(CLK) then
    TopRx <= '0';
    if RxFSM = Idle_Rx and Rx_r = '0' then
      RxDiv <= 1;
    elsif RxDiv >= RxDivisor then
      RxDiv <= 0;
      TopRx <= '1';
    else
      RxDiv <=  RxDiv + 1;
    end if;
  end if;
end process;


-- --------------------------
--  Tx Clock Generation
-- --------------------------
-- Periodicity : bit time

Tx_CLK_Gen: process (RST, CLK)
begin
  if RST='1' then
    TxDiv <=  0 ;
    TopTx <= '0';
  elsif rising_edge(CLK) then
    TopTx <= '0';
    if TxDiv = TxDivisor then
      TxDiv <= 0;
      TopTx <= '1';
    else
      TxDiv <=  TxDiv + 1;
    end if;
  end if;
end process;


-- --------------------------
--  TRANSMIT State Machine
-- --------------------------

TX <= Tx_Reg(0); -- LSB first

Tx_FSM: process (RST, CLK)
begin
  if RST='1' then
    Tx_Reg   <= (others => '1'); -- Line=1 when no Xmit
    TxFSM    <= Idle_Tx;
    TxBitCnt <= 0;
    TxBusy   <= '0';
    Tx_Par   <= '0';
	Tx_First <= '0';

  elsif rising_edge(CLK) then

    TxBusy <= '1';  -- Except when explicitly '0'

    case TxFSM is

      when Idle_Tx =>
          if LD='1' then
            Tx_Reg <= LocDin & '1';  -- Latch input data immediately.
			Tx_First <= FirstByte;
            TxBusy <= '1';
            TxFSM <= Load_Tx;
          else
            TxBusy <= '0';
          end if;

      when Load_Tx =>
          if TopTx='1' then
            TxFSM  <= Shift_Tx;
            Tx_Reg(0) <= '0';  -- Start bit
            TxBitCnt <= 7 + iFormat; -- (Nbits+2) = Start + Data + Parity
            Tx_Par <= not Even; -- in case we need it.
          end if;

      when Shift_Tx =>
          if TopTx='1' then     -- Shift Right with a '1'
            TxBitCnt <= TxBitCnt - 1;
            Tx_Par <= Tx_Par xor Tx_Reg(1);
            Tx_Reg <= '1' & Tx_Reg (8 downto 1);
            if TxBitCnt=1 then
			  if MSParity = '1' then
			    Tx_Reg(0) <= Tx_First;
				TxFSM <= Parity_Tx;
              elsif Parity = '0' then
                TxFSM <= Stop_Tx;
              else
                Tx_Reg(0) <= Tx_Par; -- Send the parity
                TxFSM <= Parity_Tx;
              end if;
            end if;
          end if;

      when Parity_Tx =>       -- during Parity bit
          if TopTx='1' then
            Tx_Reg(0) <= '1'; -- replace parity with Stop bit
            TxFSM <= Stop_Tx;
          end if;

      when Stop_Tx =>         -- during Stop bit
          if TopTx='1' then
            TxFSM <= Idle_Tx;
          end if;

      when others =>
          TxFSM <= Idle_Tx;

    end case;
  end if;
end process;


-- ------------------------
--  RECEIVE State Machine
-- ------------------------

Rx_FSM: process (RST, CLK)

begin
  if RST='1' then
    Rx_Reg   <= (others => '0');
    Dout     <= (others => '0');
    RxBitCnt <= 0;
    RxFSM    <= Idle_Rx;
    RxRdy    <= '0';
    RxRdyi   <= '0';
    RxErri   <= '0';
    Rx_Par   <= '0';

  elsif rising_edge(CLK) then

    --
    RxRDY  <= '0';
    if RxRdyi='1' and TopRx = '1' then  -- Clear error bit when a word has been received...
      RxErri <= '0';
      RxRDY  <= not RxErri;
      RxRdyi <= '0';
    end if;

    --
    case RxFSM is

      when Idle_Rx =>      -- Wait until start bit occurs
          RxBitCnt <= 6 + iFormat; -- (Nbits+1) -1
          Rx_Par <= not Even;
          if Rx_r='0' then
            RxFSM  <= Start_Rx;
          end if;

      when Start_Rx =>  -- Wait on first data bit
          if TopRx = '1' then
            if Rx_r='1' then -- Start bit error
              RxFSM <= RxOVF;
              assert (debug < 1) report "Start bit error." severity warning;
            else
              RxFSM <= Edge_Rx;
            end if;
          end if;

      when Edge_Rx =>   -- should be near Rx edge
          if TopRx = '1' then
            RxFSM <= Shift_Rx;
            if RxBitCnt = 0 then
			  if MSParity = '1' then
				RxFSM <= MS_Parity_Rx;
              elsif Parity='1' then
                RxFSM <= Parity_Rx;
              else
                RxFSM <= Stop_Rx;
              end if;
            else
              RxFSM <= Shift_Rx;
            end if;
          end if;

      when Shift_Rx =>  -- Sample data !
          if TopRx = '1' then
            RxBitCnt <= RxBitCnt - 1;
            -- shift right from position 6, 7 or 8 according to Format
            case iFormat is
              when 0 => Rx_Reg <= "00" & Rx_r & Rx_Reg (5 downto 1); -- 6 bits
              when 1 => Rx_Reg <=  '0' & Rx_r & Rx_Reg (6 downto 1); -- 7 bits
              when others =>  Rx_Reg  <= Rx_r & Rx_Reg (7 downto 1); -- "00" & "11"
            end case;
            Rx_Par <= Rx_Par xor Rx_r;
            RxFSM <= Edge_Rx;
          end if;
	  
	  when MS_Parity_Rx =>
		  if TopRx = '1' then
			RxFSM <= Parity_2;
		  end if;
	  
      when Parity_Rx => -- Sample the parity
          if TopRx = '1' then
            if (Rx_Par = Rx_r) then
              RxFSM <= Parity_2;
            else
              RxFSM <= RxOVF;
            end if;
          end if;

      when Parity_2 =>  -- second half Bit period wait
          if TopRx = '1' then
            RxFSM <= Stop_Rx;
          end if;

      when Stop_Rx =>   -- here during Middle of Stop bit
          if TopRx = '1' then

            -- Make Dout, fill in unused bits with 0's
            case iFormat is
              when 0      => Dout <= "00" & Rx_reg(5 downto 0); -- 6 LS bits
              when 1      => Dout <= '0'  & Rx_reg(6 downto 0); -- 7 LS bits
              when others => Dout <= Rx_reg; -- all the eight bits
            end case;

            --
            if Rx_r='1' then
            ---- synthesis translate_off
            --report "[UART] Character received in FPGA is : "
            --    & "'" & character'val(to_integer(unsigned(Rx_Reg))) & "'"
            --    severity note;
            ---- synthesis translate_on
              RxRdyi <= '1'; 
              RxFSM  <= Idle_Rx;
            else
              -- synthesis translate_off
              assert (debug < 1) report "[UART] Stop bit Error. " severity Error;
              -- synthesis translate_on
              RxErri  <= '1';
              RxFSM   <= RxOVF;
            end if;
          end if;


      -- ERROR HANDLING COULD BE IMPROVED :
      -- Here, we could try to re-synchronize !
      when RxOVF =>     -- Overflow / Error : should we RxRDY ?
          RxRdyi <= '0'; -- or '1' : to be defined by the project
          RxErri <= '1';
          if Rx_r='1' then  -- return to idle as soon as Rx goes inactive
            assert false report "[UART] Error in character received. " severity warning;
            RxFSM <= Idle_Rx;
          end if;

      when others => -- in case it would be encoded as safe + binary...
            RxFSM <= Idle_Rx;

    end case;
  end if;
end process;

end RTL;
