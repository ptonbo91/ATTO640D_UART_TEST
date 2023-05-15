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
Entity META_HARDEN Is
-------------------------------
  Port (
     CLK_DST          : In  Std_Logic;
	 RST_DST          : In  Std_Logic;
	 SIGNAL_SRC       : In  Std_Logic;
	 SIGNAL_DST       : Out Std_Logic
  );
-------------------------------
End Entity META_HARDEN;
-------------------------------


-------------------------------------------
Architecture RTL Of META_HARDEN Is
-------------------------------------------

  Signal SIGNAL_META : Std_Logic;

---------
begin
---------

  Process(RST_DST, CLK_DST)
  Begin
    If (RST_DST = '1') Then
      --
        SIGNAL_META <= '0';
		SIGNAL_DST  <= '0';
		
    ElsIf RISING_EDGE(CLK_DST) Then

		SIGNAL_META <= SIGNAL_SRC;
		SIGNAL_DST  <= SIGNAL_META;
	 
    End If;
  End Process;
  
------------------------
End Architecture RTL;
------------------------

