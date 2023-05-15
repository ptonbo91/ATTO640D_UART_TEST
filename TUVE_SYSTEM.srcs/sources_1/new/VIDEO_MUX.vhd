
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

---------------------
entity VIDEO_MUX is
generic(
		bit_width:positive:=13
	);
port(
		-- Clock and Reset
	    CLK           : in  std_logic;                     -- Module Clock 
	    RST           : in  std_logic;                     -- Module Reset (asynch'ed active high)
	    --Channel Select
	    Channel_Select: in  std_logic_vector(2 downto 0);
	    --Channel 1
	    VIDEO_I_V_1     : in std_logic;                     -- Video Output   Vertical Synchro  
	    VIDEO_I_H_1     : in std_logic;                     -- Video Output Horizontal Synchro
	    VIDEO_I_EOI_1   : in std_logic;  
	    VIDEO_I_DAV_1   : in std_logic;                     -- Video Output Data Valid
	    VIDEO_I_DATA_1  : in std_logic_vector(bit_width downto 0); -- Video Output Data 
	    VIDEO_I_XSIZE_1 : in std_logic_vector( 9 downto 0); -- Video X Size   
	    VIDEO_I_YSIZE_1 : in std_logic_vector( 9 downto 0); -- Video Y Size  
	    --VIDEO_I_XCNT_1  : in std_logic_vector( 9 downto 0); -- Video X Pixel Counter (1st pixel = 0)   
	    --VIDEO_I_YCNT_1  : in std_logic_vector( 9 downto 0); -- Video Y Line  Counter (1st line  = 0)
		--Channel 2
		VIDEO_I_V_2     : in std_logic;                     -- Video Output   Vertical Synchro  
	    VIDEO_I_H_2     : in std_logic;                     -- Video Output Horizontal Synchro
	    VIDEO_I_EOI_2   : in std_logic;  
	    VIDEO_I_DAV_2   : in std_logic;                     -- Video Output Data Valid
	    VIDEO_I_DATA_2  : in std_logic_vector(bit_width downto 0); -- Video Output Data 
	    VIDEO_I_XSIZE_2 : in std_logic_vector( 9 downto 0); -- Video X Size   
	    VIDEO_I_YSIZE_2 : in std_logic_vector( 9 downto 0); -- Video Y Size  
	    --VIDEO_I_XCNT_2  : in std_logic_vector( 9 downto 0); -- Video X Pixel Counter (1st pixel = 0)   
	    --VIDEO_I_YCNT_2  : in std_logic_vector( 9 downto 0); -- Video Y Line  Counter (1st line  = 0)
		--Channel 3
		VIDEO_I_V_3     : in std_logic;                     -- Video Output   Vertical Synchro  
	    VIDEO_I_H_3     : in std_logic;                     -- Video Output Horizontal Synchro
	    VIDEO_I_EOI_3   : in std_logic;  
	    VIDEO_I_DAV_3   : in std_logic;                     -- Video Output Data Valid
	    VIDEO_I_DATA_3  : in std_logic_vector(bit_width downto 0); -- Video Output Data 
	    VIDEO_I_XSIZE_3 : in std_logic_vector( 9 downto 0); -- Video X Size   
	    VIDEO_I_YSIZE_3 : in std_logic_vector( 9 downto 0); -- Video Y Size  
	    --VIDEO_I_XCNT_3  : in std_logic_vector( 9 downto 0); -- Video X Pixel Counter (1st pixel = 0)   
	    --VIDEO_I_YCNT_3  : in std_logic_vector( 9 downto 0); -- Video Y Line  Counter (1st line  = 0)
		--Channel 4
		VIDEO_I_V_4     : in std_logic;                     -- Video Output   Vertical Synchro  
	    VIDEO_I_H_4     : in std_logic;                     -- Video Output Horizontal Synchro
	    VIDEO_I_EOI_4   : in std_logic;  
	    VIDEO_I_DAV_4   : in std_logic;                     -- Video Output Data Valid
	    VIDEO_I_DATA_4  : in std_logic_vector(bit_width downto 0); -- Video Output Data 
	    VIDEO_I_XSIZE_4 : in std_logic_vector( 9 downto 0); -- Video X Size   
	    VIDEO_I_YSIZE_4 : in std_logic_vector( 9 downto 0); -- Video Y Size  
	    --VIDEO_I_XCNT_4  : in std_logic_vector( 9 downto 0); -- Video X Pixel Counter (1st pixel = 0)   
	    --VIDEO_I_YCNT_4  : in std_logic_vector( 9 downto 0); -- Video Y Line  Counter (1st line  = 0)
	    --Channel 5
		VIDEO_I_V_5     : in std_logic;                     -- Video Output   Vertical Synchro  
	    VIDEO_I_H_5     : in std_logic;                     -- Video Output Horizontal Synchro
	    VIDEO_I_EOI_5   : in std_logic;  
	    VIDEO_I_DAV_5   : in std_logic;                     -- Video Output Data Valid
	    VIDEO_I_DATA_5  : in std_logic_vector(bit_width downto 0); -- Video Output Data 
	    VIDEO_I_XSIZE_5 : in std_logic_vector( 9 downto 0); -- Video X Size   
	    VIDEO_I_YSIZE_5 : in std_logic_vector( 9 downto 0); -- Video Y Size  
	    --VIDEO_I_XCNT_5  : in std_logic_vector( 9 downto 0); -- Video X Pixel Counter (1st pixel = 0)   
	    --VIDEO_I_YCNT_5  : in std_logic_vector( 9 downto 0); -- Video Y Line  Counter (1st line  = 0)
	    --Channel 6
		VIDEO_I_V_6     : in std_logic;                     -- Video Output   Vertical Synchro  
	    VIDEO_I_H_6     : in std_logic;                     -- Video Output Horizontal Synchro
	    VIDEO_I_EOI_6   : in std_logic;  
	    VIDEO_I_DAV_6   : in std_logic;                     -- Video Output Data Valid
	    VIDEO_I_DATA_6  : in std_logic_vector(bit_width downto 0); -- Video Output Data 
	    VIDEO_I_XSIZE_6 : in std_logic_vector( 9 downto 0); -- Video X Size   
	    VIDEO_I_YSIZE_6 : in std_logic_vector( 9 downto 0); -- Video Y Size  
	    --VIDEO_I_XCNT_6  : in std_logic_vector( 9 downto 0); -- Video X Pixel Counter (1st pixel = 0)   
	    --VIDEO_I_YCNT_6  : in std_logic_vector( 9 downto 0); -- Video Y Line  Counter (1st line  = 0)

	    --Output Channel
	    VIDEO_O_V     : out std_logic;                     -- Video Output   Vertical Synchro  
	    VIDEO_O_H     : out std_logic;                     -- Video Output Horizontal Synchro
	    VIDEO_O_EOI   : out std_logic;  
	    VIDEO_O_DAV   : out std_logic;                     -- Video Output Data Valid
	    VIDEO_O_DATA  : out std_logic_vector(bit_width downto 0); -- Video Output Data 
	    VIDEO_O_XSIZE : out std_logic_vector( 9 downto 0); -- Video X Size   
	    VIDEO_O_YSIZE : out std_logic_vector( 9 downto 0) -- Video Y Size  
	    --VIDEO_O_XCNT  : out std_logic_vector( 9 downto 0); -- Video X Pixel Counter (1st pixel = 0)   
	    --VIDEO_O_YCNT  : out std_logic_vector( 9 downto 0) -- Video Y Line  Counter (1st line  = 0)  
	);
end entity;

architecture RTL of VIDEO_MUX is

signal VIDEO_O_EOIi:std_logic;
signal mux_cntrl: std_logic_vector(Channel_Select'range);
signal mux_cntrl1: std_logic_vector(Channel_Select'range);

signal frame_blank: std_logic_vector(0 to 7);

begin

mux_process:process(CLK,RST)
begin
	if RST='1' then
		VIDEO_O_DAV<='0';
		VIDEO_O_V<='0';
		VIDEO_O_H<='0';
		VIDEO_O_EOI<='0';
		VIDEO_O_DATA<=(others=>'0');
		VIDEO_O_XSIZE<=(others=>'0');
		VIDEO_O_YSIZE<=(others=>'0');
		--VIDEO_O_XCNT<=(others=>'0');
		--VIDEO_O_YCNT<=(others=>'0');
		VIDEO_O_EOIi<='0';
		mux_cntrl<=(others=>'1');
		frame_blank <= (others=>'0');
		mux_cntrl1 <= (others=>'0');

	elsif rising_edge(CLK) then

		if(VIDEO_I_EOI_1='1') then
			frame_blank(0)<='1';
		elsif (VIDEO_I_V_1='1') then
			frame_blank(0)<='0';
		end if;
		if(VIDEO_I_EOI_2='1') then
			frame_blank(1)<='1';
		elsif (VIDEO_I_V_2='1') then
			frame_blank(1)<='0';
		end if;
		if(VIDEO_I_EOI_3='1') then
			frame_blank(2)<='1';
		elsif (VIDEO_I_V_3='1') then
			frame_blank(2)<='0';
		end if;
		if(VIDEO_I_EOI_4='1') then
			frame_blank(3)<='1';
		elsif (VIDEO_I_V_4='1') then
			frame_blank(3)<='0';
		end if;
		if(VIDEO_I_EOI_5='1') then
			frame_blank(4)<='1';
		elsif (VIDEO_I_V_5='1') then
			frame_blank(4)<='0';
		end if;
		if(VIDEO_I_EOI_6='1') then
			frame_blank(5)<='1';
		elsif (VIDEO_I_V_6='1') then
			frame_blank(5)<='0';
		end if;


		if VIDEO_O_EOIi='1' then
			mux_cntrl1<=Channel_Select;
		end if;

		if(mux_cntrl1/=mux_cntrl) then
			case(mux_cntrl1) is
				when "000" =>  if (frame_blank(0)='1') then
								mux_cntrl <= mux_cntrl1;
							   else
							   	mux_cntrl <= "111";
							   end if;

				when "001" =>  if (frame_blank(1)='1') then
								mux_cntrl <= mux_cntrl1;
							   else
							   	mux_cntrl <= "111";
							   end if;

				when "010" =>  if (frame_blank(2)='1') then
								mux_cntrl <= mux_cntrl1;
							   else
							   	mux_cntrl <= "111";
							   end if;

				when "011" =>  if (frame_blank(3)='1') then
								mux_cntrl <= mux_cntrl1;
							   else
							   	mux_cntrl <= "111";
							   end if;

				when "100" =>  if (frame_blank(4)='1') then
								mux_cntrl <= mux_cntrl1;
							   else
							   	mux_cntrl <= "111";
							   end if;

				when "101" =>  if (frame_blank(5)='1') then
								mux_cntrl <= mux_cntrl1;
							   else
							   	mux_cntrl <= "111";
							   end if;

				when others => if(frame_blank(0)='1') then
								mux_cntrl <= mux_cntrl1;
							   else
							   	mux_cntrl <= "111";
							   end if;
			end case;
		end if;
		case( mux_cntrl ) is
		
			when "000" => 
				VIDEO_O_DAV<=VIDEO_I_DAV_1;
				VIDEO_O_V<=VIDEO_I_V_1;
				VIDEO_O_H<=VIDEO_I_H_1;
				VIDEO_O_EOI<=VIDEO_I_EOI_1;
				VIDEO_O_DATA<=VIDEO_I_DATA_1;
				VIDEO_O_XSIZE<=VIDEO_I_XSIZE_1;
				VIDEO_O_YSIZE<=VIDEO_I_YSIZE_1;
				--VIDEO_O_XCNT<=VIDEO_I_XCNT_1;
				--VIDEO_O_YCNT<=VIDEO_I_YCNT_1;
				VIDEO_O_EOIi<=VIDEO_I_EOI_1;

			when "001" =>
				VIDEO_O_DAV<=VIDEO_I_DAV_2;
				VIDEO_O_V<=VIDEO_I_V_2;
				VIDEO_O_H<=VIDEO_I_H_2;
				VIDEO_O_EOI<=VIDEO_I_EOI_2;
				VIDEO_O_DATA<= VIDEO_I_DATA_2;
				VIDEO_O_XSIZE<=VIDEO_I_XSIZE_2;
				VIDEO_O_YSIZE<=VIDEO_I_YSIZE_2;
				--VIDEO_O_XCNT<=VIDEO_I_XCNT_2;
				--VIDEO_O_YCNT<=VIDEO_I_YCNT_2;
				VIDEO_O_EOIi<=VIDEO_I_EOI_2;

			when "010" =>
				VIDEO_O_DAV<=VIDEO_I_DAV_3;
				VIDEO_O_V<=VIDEO_I_V_3;
				VIDEO_O_H<=VIDEO_I_H_3;
				VIDEO_O_EOI<=VIDEO_I_EOI_3;
				VIDEO_O_DATA<=VIDEO_I_DATA_3;
				VIDEO_O_XSIZE<=VIDEO_I_XSIZE_3;
				VIDEO_O_YSIZE<=VIDEO_I_YSIZE_3;
				--VIDEO_O_XCNT<=VIDEO_I_XCNT_3;
				--VIDEO_O_YCNT<=VIDEO_I_YCNT_3;
				VIDEO_O_EOIi<=VIDEO_I_EOI_3;

			when "011" =>
				VIDEO_O_DAV<=VIDEO_I_DAV_4;
				VIDEO_O_V<=VIDEO_I_V_4;
				VIDEO_O_H<=VIDEO_I_H_4;
				VIDEO_O_EOI<=VIDEO_I_EOI_4;
				VIDEO_O_DATA<= VIDEO_I_DATA_4;
				VIDEO_O_XSIZE<=VIDEO_I_XSIZE_4;
				VIDEO_O_YSIZE<=VIDEO_I_YSIZE_4;
				--VIDEO_O_XCNT<=VIDEO_I_XCNT_4;
				--VIDEO_O_YCNT<=VIDEO_I_YCNT_4;
				VIDEO_O_EOIi<=VIDEO_I_EOI_4;

			when "100" =>
				VIDEO_O_DAV<=VIDEO_I_DAV_5;
				VIDEO_O_V<=VIDEO_I_V_5;
				VIDEO_O_H<=VIDEO_I_H_5;
				VIDEO_O_EOI<=VIDEO_I_EOI_5;
				VIDEO_O_DATA<=VIDEO_I_DATA_5;
				VIDEO_O_XSIZE<=VIDEO_I_XSIZE_5;
				VIDEO_O_YSIZE<=VIDEO_I_YSIZE_5;
				--VIDEO_O_XCNT<=VIDEO_I_XCNT_5;
				--VIDEO_O_YCNT<=VIDEO_I_YCNT_5;
				VIDEO_O_EOIi<=VIDEO_I_EOI_5;

			when "101" =>
				VIDEO_O_DAV<=VIDEO_I_DAV_6;
				VIDEO_O_V<=VIDEO_I_V_6;
				VIDEO_O_H<=VIDEO_I_H_6;
				VIDEO_O_EOI<=VIDEO_I_EOI_6;
				VIDEO_O_DATA<=VIDEO_I_DATA_6;
				VIDEO_O_XSIZE<=VIDEO_I_XSIZE_6;
				VIDEO_O_YSIZE<=VIDEO_I_YSIZE_6;
				--VIDEO_O_XCNT<=VIDEO_I_XCNT_6;
				--VIDEO_O_YCNT<=VIDEO_I_YCNT_6;
				VIDEO_O_EOIi<=VIDEO_I_EOI_6;

			when "111" =>
				VIDEO_O_DAV<='0';
				VIDEO_O_V<='0';
				VIDEO_O_H<='0';
				VIDEO_O_EOI<='0';
				VIDEO_O_DATA<=(others=>'0');
				VIDEO_O_XSIZE<=(others=>'0');
				VIDEO_O_YSIZE<=(others=>'0');
				--VIDEO_O_EOIi<=VIDEO_I_EOI_6;

			when others =>
				VIDEO_O_DAV<=VIDEO_I_DAV_1;
				VIDEO_O_V<=VIDEO_I_V_1;
				VIDEO_O_H<=VIDEO_I_H_1;
				VIDEO_O_EOI<=  VIDEO_I_EOI_1;
				VIDEO_O_DATA<= VIDEO_I_DATA_1;
				VIDEO_O_XSIZE<=VIDEO_I_XSIZE_1;
				VIDEO_O_YSIZE<=VIDEO_I_YSIZE_1;
				--VIDEO_O_XCNT<=VIDEO_I_XCNT_1;
				--VIDEO_O_YCNT<=VIDEO_I_YCNT_1;
				VIDEO_O_EOIi<=VIDEO_I_EOI_1;

		end case ;
	end if;
end process mux_process;
end RTL;