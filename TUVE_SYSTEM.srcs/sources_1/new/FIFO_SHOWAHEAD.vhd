-- ----------------------------------------------
--  ShowAhead wrapper for regular Fifos
-- ----------------------------------------------
--
-- 2012.07 : Updated by Guillaume JOLI
--  * Fixed for anticipated read
--
-- 2011.11 : Updated by Etienne Laurendeau
--  * Change the F_RdEn equation (test Empty in any case now)
--  * Add synchronous clear input (if present on Classic Fifo)
--  * Add "used" input/output for number of words in Fifo
--
-- 2011.09 : First Revision by Bertrand Cuzeau
-- This module is to be inserted on the Fifo Read port


Library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-- ----------------------------------------------
   Entity FIFO_SHOWAHEAD is
-- ----------------------------------------------
 port (
        Clock   : in  std_logic;
        Reset   : in  std_logic;

        -- Fifo
        F_Clear : in  std_logic;
        F_Empty : in  std_logic;
        F_Used  : in  std_logic_vector;
        F_RdEn  : out std_logic;

        -- World
        Empty   : out std_logic;
        Used    : out std_logic_vector;
        RdEn    : in  std_logic

      );
  End Entity;

-- ----------------------------------------------
    Architecture RTL Of FIFO_SHOWAHEAD Is
-- ----------------------------------------------

  Type State_t    Is (s_NoData, s_Data);
  Signal State    : state_t;

-----\
Begin
-----/

  --
  F_RdEn <= not F_Empty when (State = s_NoData)               -- Anticipate
                          or (State = s_Data and RdEN = '1')  -- We read but there is more data in the Fifo
            else '0';

  --
  process (Clock, Reset)
  begin
    if Reset = '1' then
      State <= s_NoData;
      Empty <= '1';

    elsif rising_edge(Clock) then

      case State is
-- s_NoData
        when s_NoData =>
          if (F_Empty = '0') then -- do an anticipated Read
           State <= s_Data;
           --
           If (RdEn = '1') Then
             Empty <= '0';
           End If;
          end if;
-- s_Data
        when s_Data =>
          Empty <= '0';
          if    (F_Empty = '1') and (RdEN = '1') then  -- This Read does empty our buffer
            Empty <= '1';
            State <= s_NoData;
          elsif (F_Empty = '0') and (RdEN = '1') then -- We still have Data coming from the pipe
          end if;

      end case;

      if (F_Clear = '1') then
        State <= s_NoData;
        Empty <= '1';
      end if;

    end if;
  end process;


  -- Number of Words in "our" Fifo
  Used <= std_logic_vector(unsigned(F_Used) + 1) when (State /= s_NoData) else F_Used;

End architecture RTL;
