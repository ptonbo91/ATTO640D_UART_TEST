----------------------------------------------------------------
-- Copyright    : Tonbo Imaging Pvt. Ltd.
-- Block Name   : FIFO_GENERIC_DC
-- Description  : Universal Dual Clock Fifo
-- Author       : ARDRA SINGH
-- Version      : 2016.1
----------------------------------------------------------------
--
-- 2016.1       : Original Release Based on ALSE's FIFO_GENERIC_SC
--
-- Notes        : VIDEO_CL_OUT_GENERIC can now operate at any frequency in CameraLink frequency 
--                range (20-85 MHz) given that it is greater that input pixel clock frequency. 
--                No restictions on gaps between two DAVs.
-- Take care    : If PIX_BITS is changed, you will need to modify the gray code conversion in 
--                FIFO_DUAL_CLK module according to the number of bits.
----------------------------------------------------------------

Library IEEE;
Use IEEE.std_logic_1164.all;
Use IEEE.numeric_std.all;

-------------------------------
Entity VIDEO_IN_GENERIC Is
-------------------------------
  Generic (
	 BIT_WIDTH      : Positive := 14;
--	 VIDEO_XSIZE    : Positive := 1024;
--	 VIDEO_YSIZE   	: Positive := 768;
	 PIX_BITS       : Positive := 11;
	 LIN_BITS       : Positive := 10		
  );
  Port (
    -- Clock and Reset
    CLK            : in  std_logic;                               -- System Clock 
    CLK_ila        : in  std_logic;   ----For ILA0 Clock 
    RST            : in  std_logic;                               -- System Reset (asynch'ed active high)
	
	VIDEO_XSIZE    : in  std_logic_vector(PIX_BITS-1 downto 0);
    VIDEO_YSIZE    : in  std_logic_vector(LIN_BITS-1 downto 0);
    
	-- Video Output (sync'ed on Input CameraLink Clock)           -- Frequency will be in the range 20-85 Mhz 
	main_clock     : in  std_logic;                               -- Main Clock
    detector_clock : in  std_logic;                               -- Data Valid  
    vsync          : in  std_logic;                               -- Frame Valid  
    hsync          : in  std_logic;                               -- Line Valid
    video_data     : in  std_logic_vector(BIT_WIDTH-1 downto 0);    -- Video Data
    -- Video Input (sync'ed on 108 MHz CLK)
    VIDEO_O_V      : out std_logic;                               -- Video Output   Vertical Synchro  
    VIDEO_O_H      : out std_logic;                               -- Video Output Horizontal Synchro
    VIDEO_O_DAV    : out std_logic;                               -- Video Output Data Valid
    VIDEO_O_DATA   : out std_logic_vector(BIT_WIDTH-1 downto 0);    -- Video Output Data 
    VIDEO_O_EOI    : out std_logic;
    
    ID : buffer std_logic_vector(3 downto 0)   --FSM Check
  );
-------------------------------
End Entity VIDEO_IN_GENERIC;
-------------------------------


-------------------------------------------
Architecture RTL Of VIDEO_IN_GENERIC Is
-------------------------------------------

------------------------------------------------
COMPONENT ila_0

PORT (
    clk : IN STD_LOGIC;
    probe0 : IN STD_LOGIC_VECTOR(127 downto 0)            --(255 DOWNTO 0)
);
END COMPONENT;
  -- Temperature Signals
  signal nuc_probe: std_logic_vector(127 downto 0);     --(255 DOWNTO 0);                        --(127 downto 0);
  
  ------------------------------------------------------
  Signal vsync_d              : Std_Logic;
  Signal vsync_r              : Std_Logic;
  Signal hsync_d              : Std_Logic;
  Signal detector_clock_d     : Std_Logic;
  Signal video_data_d         : Std_Logic_Vector(BIT_WIDTH-1 downto 0);
  Signal new_frame            : Std_Logic;
  Signal new_frame_d          : Std_Logic;
  Signal new_frame_start      : Std_Logic;

  Signal RST_CameraLink       : Std_Logic;
  Signal RDDATA               : Std_Logic_Vector(BIT_WIDTH-1 downto 0);
  Signal RDREQ                : Std_Logic;
  Signal WRREQ                : Std_Logic;
  Signal DATA_AVBL            : Std_Logic;
  Signal EMPTY_RD             : Std_Logic;
  Signal FIFO_CNT_RD          : Std_Logic_Vector(PIX_BITS-1 downto 0);
  Signal XCNT                 : Unsigned(PIX_BITS-1 downto 0);
  Signal XCNT_i               : Unsigned(PIX_BITS-1 downto 0);  
  Signal XCNT_ii              : Unsigned(PIX_BITS-1 downto 0);
  Signal YCNT                 : Unsigned(LIN_BITS-1 downto 0);
  Signal VIDEO_O_DATA_i       : Std_Logic_Vector(BIT_WIDTH-1 downto 0);
  Signal VIDEO_O_V_i          : Std_Logic;
  Signal VIDEO_O_H_i          : Std_Logic;
  Signal VIDEO_O_DAV_i        : Std_Logic;
  Signal VIDEO_O_EOI_i        : Std_Logic;
  Signal WAIT_CNT             : Unsigned(3 downto 0);
  
  
  --------------------------------------------------------
--    signal ID : std_logic_vector(3 downto 0) := "0000";
------------------------------------------------------------
    
  type VIDEO_FSM_t is (IDLE, GEN_V, WAIT_FOR_FIFO_CLEAR, GEN_H, GET_DATA, LOWER_H, LOWER_V, LINE_OVER);
  signal VIDEO_FSM            : VIDEO_FSM_t;


---------
begin
---------

  ---------------------------------------------------
  -- Fifo Write Management Logic
  ---------------------------------------------------
  Process(RST_CameraLink, main_clock)
  Begin
    If (RST_CameraLink = '1') Then
    	vsync_d <= '0';
    	hsync_d <= '0';
    	detector_clock_d <= '0';
    	video_data_d <= (others => '0');

    ElsIf RISING_EDGE(main_clock) Then
		vsync_d <= vsync;
    	hsync_d <= hsync;                           -- Delayed hsync used for writing as hsync and vsync rising at the same time can create problems
    	detector_clock_d <= detector_clock;         -- Delayed detector_clock used for writing as hsync and vsync rising at the same time can create problems
    	video_data_d <= video_data;                 -- Delayed video_data used for writing as hsync and vsync rising at the same time can create problems

	End If;  
  End Process;

  vsync_r <= vsync and not(vsync_d);
  new_frame_start <= new_frame and not(new_frame_d);

  ---------------------------------------------------
  -- Fifo Write Management Logic
  ---------------------------------------------------
  Process(RST, CLK)
  Begin
    If (RST = '1') Then

    	VIDEO_FSM        <= IDLE;
    	new_frame_d      <= '0';
    	VIDEO_O_V_i      <= '0';
		VIDEO_O_H_i      <= '0';
		VIDEO_O_DAV_i    <= '0';
		DATA_AVBL        <= '0';
		RDREQ            <= '0';
		XCNT             <= (others => '0');
		XCNT_i           <= (others => '0');
		XCNT_ii          <= (others => '0');
		YCNT             <= (others => '0');
		VIDEO_O_DATA_i   <= (others => '0');
		VIDEO_O_EOI_i    <= '0';

    ElsIf RISING_EDGE(CLK) Then
	  
		new_frame_d <= new_frame;
		VIDEO_O_V_i <= '0';
		VIDEO_O_H_i <= '0';
		VIDEO_O_DAV_i <= '0';
		DATA_AVBL <= RDREQ;
		XCNT_i <= XCNT;
		XCNT_ii <= XCNT_i;
		RDREQ <= '0';
		VIDEO_O_EOI_i <= '0';
     
	  	case VIDEO_FSM is

	  		when IDLE =>
	  		   ID <= "0001";
				if new_frame_start = '1' then
					VIDEO_O_V_i <= '0';
					VIDEO_O_H_i <= '0';
					VIDEO_O_DAV_i <= '0';
					XCNT <= (others => '0');
					VIDEO_FSM <= GEN_V;
				end if;

	       	when GEN_V =>
	       	   ID <= "0010";
	       		VIDEO_O_V_i <= '1';
	       		WAIT_CNT <= to_unsigned(8,WAIT_CNT'length);
	       		VIDEO_FSM <= WAIT_FOR_FIFO_CLEAR;

	       	when WAIT_FOR_FIFO_CLEAR =>
	       	   ID <= "0011";
	       		VIDEO_O_V_i <= '0';
	       		if WAIT_CNT > 0 then
	       			WAIT_CNT <= WAIT_CNT - 1;
	       		end if;
				if EMPTY_RD = '0' and WAIT_CNT = 0 then
					RDREQ <= '1';
					XCNT <= XCNT + 1;
					VIDEO_FSM <= GEN_H;
				end if;
				
			when GEN_H =>
			 ID <= "0100";
				VIDEO_O_H_i <= '1';
				if EMPTY_RD = '0' and ((RDREQ = '0' and unsigned(FIFO_CNT_RD) >= 1) or (RDREQ = '1' and unsigned(FIFO_CNT_RD) >= 2)) then
					RDREQ <= '1';
					XCNT <= XCNT + 1;
				end if;
				VIDEO_FSM <= GET_DATA;
				
			when GET_DATA =>
			 ID <= "0101";
				if DATA_AVBL = '1' then 
					VIDEO_O_DATA_i <= RDDATA;
					VIDEO_O_DAV_i <= '1';
					if XCNT_i = unsigned(VIDEO_XSIZE) then
						XCNT <= (others => '0');			
						if YCNT = unsigned(VIDEO_YSIZE)-1 then
							YCNT <= (others => '0');
							VIDEO_FSM <= LOWER_V;
						else 
							YCNT <= YCNT + 1;
							VIDEO_FSM <= LOWER_H;
						end if;
					end if;
				end if;
				if XCNT < unsigned(VIDEO_XSIZE) then
					if EMPTY_RD = '0' and ((RDREQ = '0' and unsigned(FIFO_CNT_RD) >= 1) or (RDREQ = '1' and unsigned(FIFO_CNT_RD) >= 2)) then
						RDREQ <= '1';
						XCNT <= XCNT + 1;
					end if;
				end if;

			when LOWER_V =>
			 ID <= "0110";
				VIDEO_O_EOI_i <= '1';
				VIDEO_FSM <= IDLE;

			when LOWER_H =>
			 ID <= "0111";
			 	VIDEO_FSM <= LINE_OVER;
				
			when LINE_OVER => 
			 ID <= "1000";
				if EMPTY_RD = '0' then
					RDREQ <= '1';
					XCNT <= XCNT + 1;
					VIDEO_FSM <= GEN_H;
				end if;	
       
		end case;    

		if new_frame_start = '1' then
			VIDEO_O_V_i <= '0';
			VIDEO_O_H_i <= '0';
			VIDEO_O_DAV_i <= '0';
			XCNT <= (others => '0');
			VIDEO_FSM <= GEN_V;
		end if;
    
	 End If;
  
  End Process;

  VIDEO_O_V      <= VIDEO_O_V_i;       
  VIDEO_O_H      <= VIDEO_O_H_i;       
  VIDEO_O_DAV    <= VIDEO_O_DAV_i;     
  VIDEO_O_DATA   <= VIDEO_O_DATA_i;         
  VIDEO_O_EOI    <= VIDEO_O_EOI_i;
  
  WRREQ <= hsync_d and detector_clock_d;

  -- ------------------------
  --  DUAL CLOCK FIFO INSTANTIATION
  -- ------------------------
  i_FIFO_DUAL_CLK : entity WORK.FIFO_DUAL_CLK
	 Generic map (
		FIFO_DEPTH  => PIX_BITS       ,
		FIFO_WIDTH  => BIT_WIDTH-1+1    ,
		RAM_STYLE   => "distributed"
	 )		
    Port map (
        CLK_WR      => main_clock     ,
		RST_WR      => RST_CameraLink ,
		CLR_WR      => vsync_r        ,
		WRREQ       => WRREQ          ,
		WRDATA      => video_data_d   ,
		CLK_RD      => CLK            ,
		RST_RD      => RST            ,
		CLR_RD      => new_frame_start,
		RDREQ       => RDREQ          ,
		RDDATA      => RDDATA         ,
		EMPTY_RD    => EMPTY_RD       ,
		FIFO_CNT_RD => FIFO_CNT_RD         
    );
	 
  -- ------------------------
  --  META_HARDEN INSTANTIATIONS
  -- ------------------------
  i_META_HARDEN_RST : entity WORK.META_HARDEN
    Port map (
        CLK_DST    => main_clock     ,
		RST_DST    => '0'            ,
		SIGNAL_SRC => RST            ,
		SIGNAL_DST => RST_CameraLink
    );

  i_META_HARDEN_V : entity WORK.META_HARDEN
    Port map (
        CLK_DST    => CLK         ,
		RST_DST    => RST         ,
		SIGNAL_SRC => vsync       ,
		SIGNAL_DST => new_frame
    );
-------------------------------------------


-- nuc_probe(255 downto 234) <= std_logic_vector(DMA_ADDR_START);
 
 nuc_probe(0)  <= vsync_d             ;
-- nuc_probe(1)  <= vsync_r             ;
-- nuc_probe(2)  <= vsync_f             ;
-- nuc_probe(3)  <= vsync_f_sync        ;

-- nuc_probe(1 downto 4)  <= ID;  

---- nuc_probe(4)  <= hsync_d             ;
-- nuc_probe(5)  <= detector_clock_d    ;
-- nuc_probe(19 downto 6)  <= std_logic_vector(video_data_d);
-- nuc_probe(20)  <= new_frame         ;  
-- nuc_probe(21)  <= new_frame_d       ;  
-- nuc_probe(22)  <= new_frame_start   ;                     
-- nuc_probe(23)  <= RST_CameraLink    ;  
-- nuc_probe(37 downto 24)  <= RDDATA  ;  
-- nuc_probe(38)  <= CLK  ;         --RDREQ             ;  
-- nuc_probe(39)  <= WRREQ             ;  
-- nuc_probe(40)  <= DATA_AVBL         ;  
-- nuc_probe(41)  <= EMPTY_RD          ;  
-- nuc_probe(51 downto 42)  <= FIFO_CNT_RD       ;  
-- nuc_probe(61 downto 52)  <= std_logic_vector(XCNT)              ;  
-- nuc_probe(71 downto 62)  <= std_logic_vector(XCNT_i)            ;           
-- nuc_probe(81 downto 72)  <= std_logic_vector(YCNT)              ;  
-- nuc_probe(95 downto 82)  <= VIDEO_O_DATA_i    ;  
-- nuc_probe(96)  <= VIDEO_O_V_i       ;  
-- nuc_probe(97)  <= VIDEO_O_H_i       ;  
-- nuc_probe(98)  <= VIDEO_O_DAV_i     ;  
-- nuc_probe(99)  <= VIDEO_O_EOI_i     ;  
-- nuc_probe(103 downto 100)  <= std_logic_vector(WAIT_CNT);                    
---- nuc_probe(104)  <= enable_fifo       ;  
-- nuc_probe(108 downto 105)  <= std_logic_vector(to_unsigned(VIDEO_FSM_t'POS(VIDEO_FSM), 4));
-- nuc_probe(109)<=   main_clock ;
-- nuc_probe(110)<=   vsync ;         
-- nuc_probe(111)<=   hsync ;         
-- nuc_probe(125 downto 112)<=   video_data;  
-- nuc_probe(126)<= RST;   
---- nuc_probe(127)<= video_start;  

-- i_video_in_generic: ila_0
--  PORT MAP (
--      clk => clk,
--      probe0 => nuc_probe
--  ); 
--------------------------

	 
------------------------
End Architecture RTL;
------------------------

