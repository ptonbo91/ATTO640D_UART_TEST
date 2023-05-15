----------------------------------------------------------------
-- Copyright    : Tonbo Imaging Pvt. Ltd.
-- Block Name   : META_HARDEN
-- Description  : Module For Removing Meta Stability 
-- Author       : ARDRA SINGH
-- Version      : 2016.1
----------------------------------------------------------------
--
-- 2016.1       : Decreases the possibility of a signal entering a 
--                meta-stable state while crossing from one clock
--                domain to another 
--
----------------------------------------------------------------

Library IEEE;
Use IEEE.std_logic_1164.all;
Use IEEE.numeric_std.all;

-------------------------------
Entity META_HARDEN_VECTOR Is
-------------------------------
  Generic (
	 bit_width        : Positive := 1
  );
  Port (
     CLK_DST          : In  Std_Logic;
	 RST_DST          : In  Std_Logic;
	 SIGNAL_SRC       : In  Std_Logic_Vector(bit_width-1 downto 0);
	 SIGNAL_DST       : Out Std_Logic_Vector(bit_width-1 downto 0)
  );
-------------------------------
End Entity META_HARDEN_VECTOR;
-------------------------------


-------------------------------------------
Architecture RTL Of META_HARDEN_VECTOR Is
-------------------------------------------

  Signal SIGNAL_META : Std_Logic_Vector(bit_width-1 downto 0);

---------
begin
---------

  Process(RST_DST, CLK_DST)
  Begin
    If (RST_DST = '1') Then
      --
        SIGNAL_META <= (others => '0');
		SIGNAL_DST  <= (others => '0');
		
    ElsIf RISING_EDGE(CLK_DST) Then

		SIGNAL_META <= SIGNAL_SRC;
		SIGNAL_DST  <= SIGNAL_META;
	 
    End If;
  End Process;
  
------------------------
End Architecture RTL;
------------------------

