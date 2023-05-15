library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity debouncer is
	generic (
			FREQ : positive:=27e6;
			SETTLE_TIME: time:= 20 ms;
--			MIN_TIME_GAP_PRESS_RELEASE : unsigned(11 downto 0);
			PULLUP: std_logic:='0'
		);
	port (
			clk     : in std_logic;
			rst     : in std_logic;
			tick1ms : in std_logic;
			tick1s                         : in  std_logic;
			MIN_TIME_GAP_PRESS_RELEASE     : in std_logic_vector(11 downto 0);
			max_release_wait_time          : in std_logic_vector(11 downto 0);
			max_gpio_o_2_3_long_press_time : in std_logic_vector(15 downto 0);
			max_gpio_o_1_2_long_press_time : in std_logic_vector(15 downto 0);
			max_gpio_o_1_3_long_press_time : in std_logic_vector(15 downto 0);
			long_press_step_size           : in std_logic_vector(11 downto 0);

			gpio_i_1: in std_logic;
			gpio_i_2: in std_logic;
			gpio_i_3: in std_logic;
			gpio_i_4: in std_logic;
			gpio_i_5: in std_logic;

		-- Pulse Outputs
			gpio_o_1_pulse: out std_logic;             -- short press pulse signal gpio1
			gpio_o_2_pulse: out std_logic;             -- short press pulse signal gpio2
			gpio_o_3_pulse: out std_logic;             -- short press pulse signal gpio3
			gpio_o_4_pulse: out std_logic;             -- short press pulse signal gpio4
			gpio_o_5_pulse: out std_logic;             -- short press pulse signal gpio5

 
            gpio_o_1_long_press_pulse :  buffer std_logic;   --long press pulse signal gpio1
            gpio_o_2_long_press_pulse :  buffer std_logic;   --long press pulse signal gpio2
            gpio_o_3_long_press_pulse :  buffer std_logic;   --long press pulse signal gpio3
            gpio_o_4_long_press_pulse :  buffer std_logic;   --long press pulse signal gpio4
            gpio_o_5_long_press_pulse :  buffer std_logic;   --long press pulse signal gpio5

            gpio_o_1_long_press_level :  out std_logic;    -- long press level signal gpio1
            gpio_o_2_long_press_level :  out std_logic;    -- long press level signal gpio2
            gpio_o_3_long_press_level :  out std_logic;    -- long press level signal gpio3
            gpio_o_4_long_press_level :  out std_logic;    -- long press level signal gpio4
            gpio_o_5_long_press_level :  out std_logic;    -- long press level signal gpio5
 
            
            gpio_o_1_2_long_press_pulse : buffer std_logic;      -- long press pulse signal  gpio1 and gpio2
            gpio_o_1_3_long_press_pulse : buffer std_logic;      -- long press pulse signal  gpio1 and gpio3
            gpio_o_2_3_long_press_pulse : buffer std_logic       -- long press pulse signal  gpio2 and gpio3

		);

end entity debouncer;

architecture RTL of debouncer is

	signal gpio_1_d1 : std_logic:= '0';
	signal gpio_1_d2 : std_logic:= '0';
	signal gpio_2_d1 : std_logic:= '0';
	signal gpio_2_d2 : std_logic:= '0';
	signal gpio_3_d1 : std_logic:= '0';
	signal gpio_3_d2 : std_logic:= '0';
	signal gpio_4_d1 : std_logic:= '0';
	signal gpio_4_d2 : std_logic:= '0';
	signal gpio_5_d1 : std_logic:= '0';
	signal gpio_5_d2 : std_logic:= '0';

	signal press_gpio_1_d3: std_logic:= '0';
	signal press_gpio_1_d4: std_logic:= '0';
	signal press_gpio_2_d3: std_logic:= '0';
	signal press_gpio_2_d4: std_logic:= '0';	
	signal press_gpio_3_d3: std_logic:= '0';
	signal press_gpio_3_d4: std_logic:= '0';
	signal press_gpio_4_d3: std_logic:= '0';
	signal press_gpio_4_d4: std_logic:= '0';
	signal press_gpio_5_d3: std_logic:= '0';
	signal press_gpio_5_d4: std_logic:= '0';


	signal release_gpio_1_d3 : std_logic:= '1';
	signal release_gpio_1_d4 : std_logic:= '1';
	signal release_gpio_2_d3 : std_logic:= '1';
	signal release_gpio_2_d4 : std_logic:= '1';	
	signal release_gpio_3_d3 : std_logic:= '1';
	signal release_gpio_3_d4 : std_logic:= '1';
	signal release_gpio_4_d3 : std_logic:= '1';
	signal release_gpio_4_d4 : std_logic:= '1';
	signal release_gpio_5_d3 : std_logic:= '1';
	signal release_gpio_5_d4 : std_logic:= '1';

    signal press_pulse_gpio_1   : std_logic:= '0';
    signal press_pulse_gpio_2   : std_logic:= '0';
    signal press_pulse_gpio_3   : std_logic:= '0';
    signal press_pulse_gpio_4   : std_logic:= '0';
    signal press_pulse_gpio_5   : std_logic:= '0';

    signal release_pulse_gpio_1 : std_logic:= '0';
    signal release_pulse_gpio_2 : std_logic:= '0';
    signal release_pulse_gpio_3 : std_logic:= '0';
    signal release_pulse_gpio_4 : std_logic:= '0';
    signal release_pulse_gpio_5 : std_logic:= '0';

	constant settle_time_in_clocks : positive := integer(real(FREQ) * SETTLE_TIME / 1 sec);
	signal press_timer_1 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	signal press_timer_2 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	signal press_timer_3 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	signal press_timer_4 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	signal press_timer_5 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;

	signal release_timer_1 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	signal release_timer_2 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	signal release_timer_3 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	signal release_timer_4 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	signal release_timer_5 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;



    type out_pulse_gen_gpio_1_st_t is (s_idle,s_wait_press,s_wait_release);
    signal out_pulse_gen_gpio_1_st   : out_pulse_gen_gpio_1_st_t;

    type out_pulse_gen_gpio_2_st_t is (s_idle,s_wait_press,s_wait_release,s_wait_gpio_2_3_release,s_wait_gpio_2_1_release);
    signal out_pulse_gen_gpio_2_st   : out_pulse_gen_gpio_2_st_t;
    
    type out_pulse_gen_gpio_3_st_t is (s_idle,s_wait_press,s_wait_release,s_wait_gpio_3_1_release);
    signal out_pulse_gen_gpio_3_st   : out_pulse_gen_gpio_3_st_t;

    type out_pulse_gen_gpio_4_st_t is (s_idle,s_wait_press,s_wait_release);
    signal out_pulse_gen_gpio_4_st   : out_pulse_gen_gpio_4_st_t;        

    type out_pulse_gen_gpio_5_st_t is (s_idle,s_wait_press,s_wait_release);
    signal out_pulse_gen_gpio_5_st   : out_pulse_gen_gpio_5_st_t;
    
    	
	signal long_press_timer     : unsigned(3 downto 0);
	signal release_wait_timer_1 : unsigned(11 downto 0);
	signal release_wait_timer_2 : unsigned(11 downto 0);
	signal release_wait_timer_3 : unsigned(11 downto 0);
	signal release_wait_timer_4 : unsigned(11 downto 0);
	signal release_wait_timer_5 : unsigned(11 downto 0);
	
	signal long_press_release_wait_time_1 : unsigned(11 downto 0);
	signal long_press_release_wait_time_2 : unsigned(11 downto 0);
	signal long_press_release_wait_time_3 : unsigned(11 downto 0);
	signal long_press_release_wait_time_4 : unsigned(11 downto 0);
	signal long_press_release_wait_time_5 : unsigned(11 downto 0);


    signal gpio_o_2_3_long_press_timer :  unsigned(15 downto 0);  
    signal gpio_o_1_2_long_press_timer :  unsigned(15 downto 0); 
    signal gpio_o_1_3_long_press_timer :  unsigned(15 downto 0);
    
    signal gpio_1_long_press_detect : std_logic;
    signal gpio_2_long_press_detect : std_logic; 
    signal gpio_3_long_press_detect : std_logic; 
    signal gpio_4_long_press_detect : std_logic; 
    signal gpio_5_long_press_detect : std_logic;  

begin
    gpio_o_1_long_press_level <= gpio_1_long_press_detect;
    gpio_o_2_long_press_level <= gpio_2_long_press_detect;
    gpio_o_3_long_press_level <= gpio_3_long_press_detect;
    gpio_o_4_long_press_level <= gpio_4_long_press_detect;
    gpio_o_5_long_press_level <= gpio_5_long_press_detect;


	-- Use a two stage syncronizer
	sync : process (rst, clk)
	begin
	  if (rst= '1') then
	    gpio_1_d1 <= '0';
	    gpio_1_d2 <= '0';
	    gpio_2_d1 <= '0';
	    gpio_2_d2 <= '0';
	    gpio_3_d1 <= '0';
	    gpio_3_d2 <= '0';
	    gpio_4_d1 <= '0';
	    gpio_4_d2 <= '0';
	    gpio_5_d1 <= '0';
	    gpio_5_d2 <= '0';

	  elsif (rising_edge(clk)) then

	  	gpio_1_d1 <= gpio_I_1;
	    gpio_1_d2 <= gpio_1_d1;
	    gpio_2_d1 <= gpio_I_2;
	    gpio_2_d2 <= gpio_2_d1;
	    gpio_3_d1 <= gpio_I_3;
	    gpio_3_d2 <= gpio_3_d1;
	    gpio_4_d1 <= gpio_I_4;
	    gpio_4_d2 <= gpio_4_d1;
	    gpio_5_d1 <= gpio_I_5;
	    gpio_5_d2 <= gpio_5_d1;
	
	  end if;
	end process sync;

-- Use a press_timer to check for debouncing and mitigate them
	counter_proc : process (rst, clk)
	begin
	  if (rst = '1') then
	    press_timer_1     <= settle_time_in_clocks-1;
	    press_timer_2     <= settle_time_in_clocks-1;
	    press_timer_3     <= settle_time_in_clocks-1;
	    press_timer_4     <= settle_time_in_clocks-1;
	    press_timer_5     <= settle_time_in_clocks-1;
	    release_timer_1   <= settle_time_in_clocks-1;
	    release_timer_2   <= settle_time_in_clocks-1;
	    release_timer_3   <= settle_time_in_clocks-1;
	    release_timer_4   <= settle_time_in_clocks-1;
	    release_timer_5   <= settle_time_in_clocks-1;
	    press_gpio_1_d3   <= '0';
	    press_gpio_2_d3   <= '0';
	    press_gpio_3_d3   <= '0';
	    press_gpio_4_d3   <= '0';
	    press_gpio_5_d3   <= '0';
	    release_gpio_1_d3 <= '1';
	    release_gpio_2_d3 <= '1';
	    release_gpio_3_d3 <= '1';
	    release_gpio_4_d3 <= '1';
	    release_gpio_5_d3 <= '1';

	  elsif (rising_edge(clk)) then
		if(gpio_1_d2='1') then
			press_timer_1 <= settle_time_in_clocks-1;
			press_gpio_1_d3 <= '0';
		elsif (press_timer_1=0) then
			press_gpio_1_d3 <= '1';
		else
			press_timer_1 <= press_timer_1 -1;
		end if;

		if(gpio_2_d2='1') then
			press_timer_2 <= settle_time_in_clocks-1;
			press_gpio_2_d3 <= '0';
		elsif (press_timer_2=0) then
			press_gpio_2_d3 <= '1';
		else
			press_timer_2 <= press_timer_2 -1;
		end if;

		if(gpio_3_d2='1') then
			press_timer_3 <= settle_time_in_clocks-1;
			press_gpio_3_d3 <= '0';
		elsif (press_timer_3=0) then
			press_gpio_3_d3 <= '1';
		else
			press_timer_3 <= press_timer_3 -1;
		end if;

		if(gpio_4_d2='1') then
			press_timer_4 <= settle_time_in_clocks-1;
			press_gpio_4_d3 <= '0';
		elsif (press_timer_4=0) then
			press_gpio_4_d3 <= '1';
		else
			press_timer_4 <= press_timer_4 -1;
		end if;

		if(gpio_5_d2='1') then
			press_timer_5 <= settle_time_in_clocks-1;
			press_gpio_5_d3 <= '0';
		elsif (press_timer_5=0) then
			press_gpio_5_d3 <= '1';
		else
			press_timer_5 <= press_timer_5 -1;
		end if;


		if(gpio_1_d2='0') then
			if(release_timer_1=0)then
	         release_gpio_1_d3 <= '0';
	        else
			 release_timer_1 <= release_timer_1 -1;
			end if;
		else
			release_gpio_1_d3 <= '1';
			release_timer_1   <= settle_time_in_clocks-1;
		end if;

		if(gpio_2_d2='0') then
			if(release_timer_2=0)then
	         release_gpio_2_d3 <= '0';
	        else
			 release_timer_2 <= release_timer_2 -1;
			end if;
		else
			release_gpio_2_d3 <= '1';
			release_timer_2   <= settle_time_in_clocks-1;
		end if;

		if(gpio_3_d2='0') then
			if(release_timer_3=0)then
	         release_gpio_3_d3 <= '0';
	        else
			 release_timer_3 <= release_timer_3 -1;
			end if;
		else
			release_gpio_3_d3 <= '1';
			release_timer_3   <= settle_time_in_clocks-1;
		end if;

		if(gpio_4_d2='0') then
			if(release_timer_4=0)then
	         release_gpio_4_d3 <= '0';
	        else
			 release_timer_4 <= release_timer_4 -1;
			end if;
		else
			release_gpio_4_d3 <= '1';
			release_timer_4   <= settle_time_in_clocks-1;
		end if;		

		if(gpio_5_d2='0') then
			if(release_timer_5=0)then
	         release_gpio_5_d3 <= '0';
	        else
			 release_timer_5 <= release_timer_5 -1;
			end if;
		else
			release_gpio_5_d3 <= '1';
			release_timer_5   <= settle_time_in_clocks-1;
		end if;

--		if(gpio_1_d2='0') then
--			release_timer_1 <= settle_time_in_clocks-1;
--			release_gpio_1_d3 <= '0';
--		elsif (release_timer_1=0) then
--			release_gpio_1_d3 <= '1';
--		else
--			release_timer_1 <= release_timer_1 -1;
--		end if;
		

--		if(gpio_2_d2='0') then
--			release_timer_2 <= settle_time_in_clocks-1;
--			release_gpio_2_d3 <= '0';
--		elsif (release_timer_2=0) then
--			release_gpio_2_d3 <= '1';
--		else
--			release_timer_2 <= release_timer_2 -1;
--		end if;

--		if(gpio_3_d2='0') then
--			release_timer_3 <= settle_time_in_clocks-1;
--			release_gpio_3_d3 <= '0';
--		elsif (release_timer_3=0) then
--			release_gpio_3_d3 <= '1';
--		else
--		    release_timer_3 <= release_timer_3 -1;
--		end if;

--		if(gpio_4_d2='0') then
--			release_timer_4 <= settle_time_in_clocks-1;
--			release_gpio_4_d3 <= '0';
--		elsif (release_timer_4=0) then
--			release_gpio_4_d3 <= '1';
--		else
--			release_timer_4 <= release_timer_4 -1;
--		end if;

--		if(gpio_5_d2='0') then
--			release_timer_5 <= settle_time_in_clocks-1;
--			release_gpio_5_d3 <= '0';
--		elsif (release_timer_5=0) then
--			release_gpio_5_d3 <= '1';
--		else
--			release_timer_5 <= release_timer_5 -1;
--		end if;

			
	  end if;
	  
	end process counter_proc;

-- Generate pulse signals from the debounced gpios
	pulse_gen : process (rst, clk)
	begin
	  if (rst = '1') then
		press_gpio_1_d4   <= '0';
		press_gpio_2_d4   <= '0';
		press_gpio_3_d4   <= '0';
		press_gpio_4_d4   <= '0';
		press_gpio_5_d4   <= '0';
	    release_gpio_1_d4 <= '1';
		release_gpio_2_d4 <= '1';
		release_gpio_3_d4 <= '1';
		release_gpio_4_d4 <= '1';
		release_gpio_5_d4 <= '1';
	  elsif (rising_edge(clk)) then
		press_gpio_1_d4   <= press_gpio_1_d3;
		press_gpio_2_d4   <= press_gpio_2_d3;
		press_gpio_3_d4   <= press_gpio_3_d3;
		press_gpio_4_d4   <= press_gpio_4_d3;
		press_gpio_5_d4   <= press_gpio_5_d3;
		release_gpio_5_d4 <= release_gpio_5_d3;
		release_gpio_1_d4 <= release_gpio_1_d3;
		release_gpio_2_d4 <= release_gpio_2_d3;
		release_gpio_3_d4 <= release_gpio_3_d3;
		release_gpio_4_d4 <= release_gpio_4_d3;
		release_gpio_5_d4 <= release_gpio_5_d3;

	  end if;
	end process pulse_gen;

	press_pulse_gpio_1   <= press_gpio_1_d3 and not press_gpio_1_d4;
	press_pulse_gpio_2   <= press_gpio_2_d3 and not press_gpio_2_d4;
	press_pulse_gpio_3   <= press_gpio_3_d3 and not press_gpio_3_d4;
	press_pulse_gpio_4   <= press_gpio_4_d3 and not press_gpio_4_d4;
	press_pulse_gpio_5   <= press_gpio_5_d3 and not press_gpio_5_d4;

	release_pulse_gpio_1 <= release_gpio_1_d3 and not release_gpio_1_d4;
	release_pulse_gpio_2 <= release_gpio_2_d3 and not release_gpio_2_d4;
	release_pulse_gpio_3 <= release_gpio_3_d3 and not release_gpio_3_d4;
	release_pulse_gpio_4 <= release_gpio_4_d3 and not release_gpio_4_d4;
	release_pulse_gpio_5 <= release_gpio_5_d3 and not release_gpio_5_d4;


-- Generate output pulse signals from the press and release action
	output_pulse_gen : process (rst, clk)
	begin
	  if (rst = '1') then
        out_pulse_gen_gpio_1_st <= s_idle;
        out_pulse_gen_gpio_2_st <= s_idle;
        out_pulse_gen_gpio_3_st <= s_idle;
        out_pulse_gen_gpio_4_st <= s_idle;
        out_pulse_gen_gpio_5_st <= s_idle;
        gpio_o_1_pulse          <= '0';
        gpio_o_2_pulse          <= '0';
        gpio_o_3_pulse          <= '0';
        gpio_o_4_pulse          <= '0';
        gpio_o_5_pulse          <= '0';
        gpio_o_1_long_press_pulse <= '0';
        gpio_o_2_long_press_pulse <= '0';
        gpio_o_3_long_press_pulse <= '0';
        gpio_o_4_long_press_pulse <= '0';
        gpio_o_5_long_press_pulse <= '0';
        release_wait_timer_1    <= x"000";
        release_wait_timer_2    <= x"000";
        release_wait_timer_3    <= x"000";
        release_wait_timer_4    <= x"000";
        release_wait_timer_5    <= x"000";
        gpio_o_2_3_long_press_pulse    <= '0';
        gpio_o_2_3_long_press_timer    <= x"0000";
        gpio_o_1_2_long_press_pulse    <= '0';
        gpio_o_1_2_long_press_timer    <= x"0000";
        gpio_o_1_3_long_press_pulse    <= '0';
        gpio_o_1_3_long_press_timer    <= x"0000"; 
        long_press_release_wait_time_1 <= (others=>'0');--unsigned(max_release_wait_time);
        long_press_release_wait_time_2 <= (others=>'0');--unsigned(max_release_wait_time);
        long_press_release_wait_time_3 <= (others=>'0');--unsigned(max_release_wait_time);
        long_press_release_wait_time_4 <= (others=>'0');--unsigned(max_release_wait_time);
        long_press_release_wait_time_5 <= (others=>'0');--unsigned(max_release_wait_time);
        gpio_1_long_press_detect       <= '0';
        gpio_2_long_press_detect       <= '0';
        gpio_3_long_press_detect       <= '0';
        gpio_4_long_press_detect       <= '0';
        gpio_5_long_press_detect       <= '0'; 
                
	  elsif (rising_edge(clk)) then  
          gpio_o_1_pulse        <= '0';
          gpio_o_2_pulse        <= '0';
          gpio_o_3_pulse        <= '0';
          gpio_o_4_pulse        <= '0';
          gpio_o_5_pulse        <= '0';
          gpio_o_1_long_press_pulse    <= '0';
          gpio_o_2_long_press_pulse    <= '0';
          gpio_o_3_long_press_pulse    <= '0';
          gpio_o_4_long_press_pulse    <= '0';
          gpio_o_5_long_press_pulse    <= '0';
          gpio_o_2_3_long_press_pulse  <= '0';
          gpio_o_1_2_long_press_pulse  <= '0';
          gpio_o_1_3_long_press_pulse  <= '0';
          
          case out_pulse_gen_gpio_1_st is
           
           when s_idle =>
              out_pulse_gen_gpio_1_st <= s_wait_press;
              
         --  when s_wait_press =>
         --   if(press_gpio_2_d3 = '1' and  press_gpio_1_d3 = '1')then
         --     out_pulse_gen_gpio_1_st <= s_idle;
         --     gpio_o_1_pulse          <= '0'; 
         --   elsif(press_gpio_3_d3 = '1' and  press_gpio_1_d3 = '1')then  
 		      --out_pulse_gen_gpio_1_st <= s_idle;
         --     gpio_o_1_pulse          <= '0';            
         --   elsif(press_pulse_gpio_1 = '1')then
         --     out_pulse_gen_gpio_1_st <= s_idle;
         --     gpio_o_1_pulse          <= '1';
         --   else
         --     out_pulse_gen_gpio_1_st <= s_wait_press;
         --   end if;
--            long_press_release_wait_time_1 <= unsigned(max_release_wait_time);

          when s_wait_press =>
--            if(press_gpio_2_d3 = '1' and  press_gpio_1_d3 = '1')then
--              out_pulse_gen_gpio_1_st <= s_idle;
--              gpio_o_1_pulse          <= '0'; 
--            elsif(press_gpio_3_d3 = '1' and  press_gpio_1_d3 = '1')then  
-- 		      out_pulse_gen_gpio_1_st <= s_idle;
--              gpio_o_1_pulse          <= '0';            
--            elsif(press_pulse_gpio_1 = '1')then
--              out_pulse_gen_gpio_1_st <= s_wait_release;
--            else
--              out_pulse_gen_gpio_1_st <= s_wait_press;
--            end if;
--            long_press_release_wait_time_1 <= unsigned(max_release_wait_time);
         
            if(press_pulse_gpio_1 = '1')then
              out_pulse_gen_gpio_1_st <= s_wait_release;
            else
              out_pulse_gen_gpio_1_st <= s_wait_press;
            end if;
            long_press_release_wait_time_1 <= unsigned(max_release_wait_time); 
              
           when s_wait_release =>
            if(press_gpio_2_d3 = '1' and  press_gpio_1_d3 = '1')then
              out_pulse_gen_gpio_1_st <= s_idle;
              gpio_o_1_pulse          <= '0'; 
              release_wait_timer_1    <= x"000";
            elsif(press_gpio_3_d3 = '1' and  press_gpio_1_d3 = '1')then  
 		      out_pulse_gen_gpio_1_st <= s_idle;
              gpio_o_1_pulse          <= '0';   
              release_wait_timer_1    <= x"000";
            elsif(release_pulse_gpio_1 = '1')then
              out_pulse_gen_gpio_1_st <= s_idle;
              if(gpio_1_long_press_detect = '1')then
                gpio_o_1_pulse           <= '0';
                gpio_1_long_press_detect <= '0';
              else
                gpio_o_1_pulse          <= '1';
              end if;
              release_wait_timer_1    <= x"000";   
             else
              out_pulse_gen_gpio_1_st <= s_wait_release;
              if(release_wait_timer_1 >= long_press_release_wait_time_1)then
                 release_wait_timer_1 <= x"000";
--                 gpio_o_1_pulse       <= '1';  
                 gpio_o_1_long_press_pulse <= '1';
                 gpio_1_long_press_detect  <= '1';
                 if(long_press_release_wait_time_1 >= unsigned(MIN_TIME_GAP_PRESS_RELEASE) + unsigned(long_press_step_size))then
                    long_press_release_wait_time_1 <= long_press_release_wait_time_1 - unsigned(long_press_step_size);
                 else
                    long_press_release_wait_time_1 <= unsigned(MIN_TIME_GAP_PRESS_RELEASE);
                 end if;                    
              else
                 if(tick1ms = '1')then
                     release_wait_timer_1 <= release_wait_timer_1 + 1;
                 end if;             
              end if;
             end if;
          end case;

          case out_pulse_gen_gpio_2_st is
           
           when s_idle =>
              out_pulse_gen_gpio_2_st <= s_wait_press;
              
           when s_wait_press =>
            if(press_pulse_gpio_2 = '1')then
              out_pulse_gen_gpio_2_st <= s_wait_release;
            else
              out_pulse_gen_gpio_2_st <= s_wait_press;
            end if;
            long_press_release_wait_time_2 <= unsigned(max_release_wait_time);
              
           when s_wait_release =>
             if(press_gpio_2_d3 = '1' and  press_gpio_1_d3 = '1')then
              out_pulse_gen_gpio_2_st <= s_wait_gpio_2_1_release;
              gpio_o_2_pulse          <= '0';              
              release_wait_timer_2    <= x"000";             
             elsif(press_gpio_2_d3 = '1' and  press_gpio_3_d3 = '1')then
              out_pulse_gen_gpio_2_st <= s_wait_gpio_2_3_release;
              gpio_o_2_pulse         <= '0';              
              release_wait_timer_2    <= x"000";
             elsif(release_pulse_gpio_2 = '1')then
              out_pulse_gen_gpio_2_st <= s_idle;
              if(gpio_2_long_press_detect = '1')then
                gpio_o_2_pulse           <= '0';
                gpio_2_long_press_detect <= '0';
              else
                gpio_o_2_pulse          <= '1';
              end if;
              release_wait_timer_2    <= x"000";   
             else
              out_pulse_gen_gpio_2_st <= s_wait_release;
              if(release_wait_timer_2 >= long_press_release_wait_time_2)then
                 release_wait_timer_2 <= x"000";
                 gpio_o_2_pulse           <= '1';
                 gpio_o_2_long_press_pulse<= '1';
                 gpio_2_long_press_detect <= '1';
                 if(long_press_release_wait_time_2 >= unsigned(MIN_TIME_GAP_PRESS_RELEASE) + unsigned(long_press_step_size))then
                    long_press_release_wait_time_2 <= long_press_release_wait_time_2 - unsigned(long_press_step_size);
                 else
                    long_press_release_wait_time_2 <= unsigned(MIN_TIME_GAP_PRESS_RELEASE);
                 end if;   
              else
                 if(tick1ms = '1')then
                     release_wait_timer_2 <= release_wait_timer_2 + 1;
                 end if;             
              end if;
             end if;

           when s_wait_gpio_2_3_release =>
             gpio_o_2_pulse   <= '0';
             release_wait_timer_2 <= x"000";  
             if(press_gpio_2_d3 = '1' and  press_gpio_3_d3 = '1')then
              if(gpio_o_2_3_long_press_timer >= unsigned(max_gpio_o_2_3_long_press_time))then 
	              gpio_o_2_3_long_press_pulse <= '1';
	              out_pulse_gen_gpio_2_st <= s_idle;
	              gpio_o_2_3_long_press_timer     <= x"0000";
              else
                  if(tick1ms = '1')then
                  	gpio_o_2_3_long_press_timer <= gpio_o_2_3_long_press_timer + 1;
                  end if;	
              end if;             
             else
              gpio_o_2_3_long_press_pulse <= '0';
              out_pulse_gen_gpio_2_st     <= s_idle;
              gpio_o_2_3_long_press_timer <= x"0000";
             end if;

           when s_wait_gpio_2_1_release =>
             gpio_o_2_pulse  <= '0';
             release_wait_timer_2 <= x"000";  
             if(press_gpio_2_d3 = '1' and  press_gpio_1_d3 = '1')then
              if(gpio_o_1_2_long_press_timer >= unsigned(max_gpio_o_1_2_long_press_time))then 
	              gpio_o_1_2_long_press_pulse<= '1';
	              out_pulse_gen_gpio_2_st    <= s_idle;
	              gpio_o_1_2_long_press_timer<= x"0000";
              else
                  if(tick1ms = '1')then
                  	gpio_o_1_2_long_press_timer <= gpio_o_1_2_long_press_timer + 1;
                  end if;	
              end if;             
             else
              gpio_o_1_2_long_press_pulse <= '0';
              out_pulse_gen_gpio_2_st     <= s_idle;
              gpio_o_1_2_long_press_timer <= x"0000";
             end if;

          end case;

          case out_pulse_gen_gpio_3_st is
           
           when s_idle =>
              out_pulse_gen_gpio_3_st <= s_wait_press;
              
           when s_wait_press =>
            if(press_pulse_gpio_3 = '1')then
              out_pulse_gen_gpio_3_st <= s_wait_release;
            else
              out_pulse_gen_gpio_3_st <= s_wait_press;
            end if;
            long_press_release_wait_time_3 <= unsigned(max_release_wait_time);
              
           when s_wait_release =>
             if(press_gpio_2_d3 = '1' and  press_gpio_3_d3 = '1')then
              out_pulse_gen_gpio_3_st <= s_idle;
              gpio_o_3_pulse         <= '0';
              release_wait_timer_3    <= x"000";
             elsif(press_gpio_1_d3 = '1' and  press_gpio_3_d3 = '1')then
              out_pulse_gen_gpio_3_st <= s_wait_gpio_3_1_release;
              gpio_o_3_pulse          <= '0';              
              release_wait_timer_3    <= x"000";              
             elsif(release_pulse_gpio_3 = '1')then
              out_pulse_gen_gpio_3_st <= s_idle;
              if(gpio_3_long_press_detect = '1')then
                gpio_o_3_pulse           <= '0';
                gpio_3_long_press_detect <= '0';
              else
                gpio_o_3_pulse          <= '1';
              end if;
              release_wait_timer_3    <= x"000";   
             else
              out_pulse_gen_gpio_3_st <= s_wait_release;
              if(release_wait_timer_3 >= long_press_release_wait_time_3)then
                 release_wait_timer_3 <= x"000";
                 gpio_o_3_pulse           <= '1';
                 gpio_o_3_long_press_pulse<= '1';
                 gpio_3_long_press_detect <= '1';
                 if(long_press_release_wait_time_3 >= unsigned(MIN_TIME_GAP_PRESS_RELEASE) + unsigned(long_press_step_size))then
                    long_press_release_wait_time_3 <= long_press_release_wait_time_3 - unsigned(long_press_step_size);
                 else
                    long_press_release_wait_time_3 <= unsigned(MIN_TIME_GAP_PRESS_RELEASE);
                 end if;  
              else
                 if(tick1ms = '1')then
                     release_wait_timer_3 <= release_wait_timer_3 + 1;
                 end if;             
              end if;
             end if;

          when s_wait_gpio_3_1_release =>
             gpio_o_3_pulse <= '0';
             release_wait_timer_3 <= x"000";  
             if(press_gpio_3_d3 = '1' and  press_gpio_1_d3 = '1')then
              if(gpio_o_1_3_long_press_timer >= unsigned(max_gpio_o_1_3_long_press_time))then 
	              gpio_o_1_3_long_press_pulse <= '1';
	              out_pulse_gen_gpio_3_st     <= s_idle;
	              gpio_o_1_3_long_press_timer <= x"0000";
              else
                  if(tick1ms = '1')then
                  	gpio_o_1_3_long_press_timer <= gpio_o_1_3_long_press_timer + 1;
                  end if;	
              end if;             
             else
              gpio_o_1_3_long_press_pulse <= '0';
              out_pulse_gen_gpio_3_st     <= s_idle;
              gpio_o_1_3_long_press_timer <= x"0000";
             end if;             
          end case;



          case out_pulse_gen_gpio_4_st is
           
           when s_idle =>
              out_pulse_gen_gpio_4_st <= s_wait_press;
              
           when s_wait_press =>
            if(press_pulse_gpio_4 = '1')then
              out_pulse_gen_gpio_4_st <= s_wait_release;
            else
              out_pulse_gen_gpio_4_st <= s_wait_press;
            end if;
            long_press_release_wait_time_4 <= unsigned(max_release_wait_time);
              
           when s_wait_release =>
             if(release_pulse_gpio_4 = '1')then
              out_pulse_gen_gpio_4_st <= s_idle;
              if(gpio_4_long_press_detect = '1')then
                gpio_o_4_pulse           <= '0';
                gpio_4_long_press_detect <= '0';
              else
                gpio_o_4_pulse          <= '1';
              end if;
              release_wait_timer_4    <= x"000";   
             else
              out_pulse_gen_gpio_4_st <= s_wait_release;
              if(release_wait_timer_4 >= long_press_release_wait_time_4)then
                 release_wait_timer_4     <= x"000";
                 gpio_o_4_pulse           <= '1';
                 gpio_o_4_long_press_pulse<= '1';
                 gpio_4_long_press_detect <= '1';
                 if(long_press_release_wait_time_4 >= unsigned(MIN_TIME_GAP_PRESS_RELEASE) + unsigned(long_press_step_size))then
                    long_press_release_wait_time_4 <= long_press_release_wait_time_4 - unsigned(long_press_step_size);
                 else
                    long_press_release_wait_time_4 <= unsigned(MIN_TIME_GAP_PRESS_RELEASE);
                 end if;  
              else
                 if(tick1ms = '1')then
                     release_wait_timer_4 <= release_wait_timer_4 + 1;
                 end if;             
              end if;
             end if;
             
          end case;

          case out_pulse_gen_gpio_5_st is
           
           when s_idle =>
              out_pulse_gen_gpio_5_st <= s_wait_press;
              
           when s_wait_press =>
            if(press_pulse_gpio_5 = '1')then
              out_pulse_gen_gpio_5_st <= s_wait_release;
            else
              out_pulse_gen_gpio_5_st <= s_wait_press;
            end if;
            long_press_release_wait_time_5 <= unsigned(max_release_wait_time);
              
           when s_wait_release =>
             if(release_pulse_gpio_5 = '1')then
              out_pulse_gen_gpio_5_st <= s_idle;
              if(gpio_5_long_press_detect = '1')then
                gpio_o_5_pulse           <= '0';
                gpio_5_long_press_detect <= '0';
              else
                gpio_o_5_pulse          <= '1';
              end if;
              release_wait_timer_5    <= x"000";   
             else
              out_pulse_gen_gpio_5_st <= s_wait_release;
              if(release_wait_timer_5 >= long_press_release_wait_time_5)then
                 release_wait_timer_5     <= x"000";
                 gpio_o_5_pulse           <= '1';
                 gpio_o_5_long_press_pulse<= '1';  
                 gpio_5_long_press_detect <= '1';
                 if(long_press_release_wait_time_5 >= unsigned(MIN_TIME_GAP_PRESS_RELEASE)+ unsigned(long_press_step_size))then
                    long_press_release_wait_time_5 <= long_press_release_wait_time_5 - unsigned(long_press_step_size);
                 else
                    long_press_release_wait_time_5 <= unsigned(MIN_TIME_GAP_PRESS_RELEASE);
                 end if;  
              else
                 if(tick1ms = '1')then
                     release_wait_timer_5 <= release_wait_timer_5 + 1;
                 end if;             
              end if;
             end if;
             
          end case;

	  end if;
	end process output_pulse_gen;


--	long_press_gen : process (rst, clk)
--	begin
--	  if (rst = '1') then
--        long_press_timer <= (others=>'0');
--        ADVANCE_MENU_TRIG_IN <= '0';
--	  elsif (rising_edge(clk)) then
--	   ADVANCE_MENU_TRIG_IN <= '0';
--	   if(press_gpio_4_d4='1' and press_gpio_5_d4 ='1')then
--	       if(tick1s = '1')then
--	           long_press_timer <= long_press_timer + 1;
--	       end if;
--	   else
--	       long_press_timer <= (others=>'0');       
--       end if;
       
--       if(long_press_timer >= 3)then
--        ADVANCE_MENU_TRIG_IN <= '1';
--       end if;
       
       
--	  end if;
--	end process long_press_gen;
        


end RTL;



--library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--entity debouncer is
--	generic (
--			FREQ : positive:=27e6;
--			SETTLE_TIME: time:= 20 ms;
--			PULLUP: std_logic:='0'
--		);
--	port (
--			clk     : in std_logic;
--			rst     : in std_logic;
--			TICK1S  : in  std_logic;

--			gpio_I_1: in std_logic;
--			gpio_I_2: in std_logic;
--			gpio_I_3: in std_logic;
--			gpio_I_4: in std_logic;
--			gpio_I_5: in std_logic;

--		-- Pulse Outputs
--			gpio_O_1: out std_logic;
--			gpio_O_2: out std_logic;
--			gpio_O_3: out std_logic;
--			gpio_O_4: out std_logic;
--			gpio_O_5: out std_logic;

--		    ADVANCE_MENU_TRIG_IN : out std_logic
--		);

--end entity debouncer;

--architecture RTL of debouncer is

--	signal gpio_1_d1 : std_logic:= '0';
--	signal gpio_1_d2 : std_logic:= '0';
--	signal gpio_1_d3 : std_logic:= '0';
--	signal gpio_1_d4 : std_logic:= '0';
--	signal gpio_2_d1 : std_logic:= '0';
--	signal gpio_2_d2 : std_logic:= '0';
--	signal gpio_2_d3 : std_logic:= '0';
--	signal gpio_2_d4 : std_logic:= '0';
--	signal gpio_3_d1 : std_logic:= '0';
--	signal gpio_3_d2 : std_logic:= '0';
--	signal gpio_3_d3 : std_logic:= '0';
--	signal gpio_3_d4 : std_logic:= '0';
--	signal gpio_4_d1 : std_logic:= '0';
--	signal gpio_4_d2 : std_logic:= '0';
--	signal gpio_4_d3 : std_logic:= '0';
--	signal gpio_4_d4 : std_logic:= '0';
--	signal gpio_5_d1 : std_logic:= '0';
--	signal gpio_5_d2 : std_logic:= '0';
--	signal gpio_5_d3 : std_logic:= '0';
--	signal gpio_5_d4 : std_logic:= '0';

--	constant settle_time_in_clocks : positive := integer(real(FREQ) * SETTLE_TIME / 1 sec);
--	signal press_timer_1 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal press_timer_2 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal press_timer_3 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal press_timer_4 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal press_timer_5 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	
--	signal long_press_timer : unsigned(3 downto 0);

--begin

--	-- Use a two stage syncronizer
--	sync : process (rst, clk)
--	begin
--	  if (rst= '1') then
--	    gpio_1_d1 <= '0';
--	    gpio_1_d2 <= '0';
--	    gpio_2_d1 <= '0';
--	    gpio_2_d2 <= '0';
--	    gpio_3_d1 <= '0';
--	    gpio_3_d2 <= '0';
--	    gpio_4_d1 <= '0';
--	    gpio_4_d2 <= '0';
--	    gpio_5_d1 <= '0';
--	    gpio_5_d2 <= '0';

--	  elsif (rising_edge(clk)) then

--	  	gpio_1_d1 <= gpio_I_1;
--	    gpio_1_d2 <= gpio_1_d1;
--	    gpio_2_d1 <= gpio_I_2;
--	    gpio_2_d2 <= gpio_2_d1;
--	    gpio_3_d1 <= gpio_I_3;
--	    gpio_3_d2 <= gpio_3_d1;
--	    gpio_4_d1 <= gpio_I_4;
--	    gpio_4_d2 <= gpio_4_d1;
--	    gpio_5_d1 <= gpio_I_5;
--	    gpio_5_d2 <= gpio_5_d1;
	
--	  end if;
--	end process sync;

---- Use a press_timer to check for debouncing and mitigate them
--	counter_proc : process (rst, clk)
--	begin
--	  if (rst = '1') then
--	    press_timer_1 <= settle_time_in_clocks-1;
--	    press_timer_2 <= settle_time_in_clocks-1;
--	    press_timer_3 <= settle_time_in_clocks-1;
--	    press_timer_4 <= settle_time_in_clocks-1;
--	    press_timer_5 <= settle_time_in_clocks-1;

--	    gpio_1_d3 <= '0';
--	    gpio_2_d3 <= '0';
--	    gpio_3_d3 <= '0';
--	    gpio_4_d3 <= '0';
--	    gpio_5_d3 <= '0';
--	  elsif (rising_edge(clk)) then
--		if(gpio_1_d2='1') then
--			press_timer_1 <= settle_time_in_clocks-1;
--			gpio_1_d3 <= '0';
--		elsif (press_timer_1=0) then
--			gpio_1_d3 <= '1';
--		else
--			press_timer_1 <= press_timer_1 -1;
--		end if;

--		if(gpio_2_d2='1') then
--			press_timer_2 <= settle_time_in_clocks-1;
--			gpio_2_d3 <= '0';
--		elsif (press_timer_2=0) then
--			gpio_2_d3 <= '1';
--		else
--			press_timer_2 <= press_timer_2 -1;
--		end if;

--		if(gpio_3_d2='1') then
--			press_timer_3 <= settle_time_in_clocks-1;
--			gpio_3_d3 <= '0';
--		elsif (press_timer_3=0) then
--			gpio_3_d3 <= '1';
--		else
--			press_timer_3 <= press_timer_3 -1;
--		end if;

--		if(gpio_4_d2='1') then
--			press_timer_4 <= settle_time_in_clocks-1;
--			gpio_4_d3 <= '0';
--		elsif (press_timer_4=0) then
--			gpio_4_d3 <= '1';
--		else
--			press_timer_4 <= press_timer_4 -1;
--		end if;

--		if(gpio_5_d2='1') then
--			press_timer_5 <= settle_time_in_clocks-1;
--			gpio_5_d3 <= '0';
--		elsif (press_timer_5=0) then
--			gpio_5_d3 <= '1';
--		else
--			press_timer_5 <= press_timer_5 -1;
--		end if;
			
--	  end if;
--	end process counter_proc;

---- Generate pulse signals from the debounced gpios
--	pulse_gen : process (rst, clk)
--	begin
--	  if (rst = '1') then
--		gpio_1_d4 <= '0';
--		gpio_2_d4 <= '0';
--		gpio_3_d4 <= '0';
--		gpio_4_d4 <= '0';
--		gpio_5_d4 <= '0';
--	  elsif (rising_edge(clk)) then
--		gpio_1_d4 <= gpio_1_d3;
--		gpio_2_d4 <= gpio_2_d3;
--		gpio_3_d4 <= gpio_3_d3;
--		gpio_4_d4 <= gpio_4_d3;
--		gpio_5_d4 <= gpio_5_d3;
--	  end if;
--	end process pulse_gen;

--	gpio_O_1 <= gpio_1_d3 and not gpio_1_d4;
--	gpio_O_2 <= gpio_2_d3 and not gpio_2_d4;
--	gpio_O_3 <= gpio_3_d3 and not gpio_3_d4;
--	gpio_O_4 <= gpio_4_d3 and not gpio_4_d4;
--	gpio_O_5 <= gpio_5_d3 and not gpio_5_d4;


--	long_press_gen : process (rst, clk)
--	begin
--	  if (rst = '1') then
--        long_press_press_timer <= (others=>'0');
--        ADVANCE_MENU_TRIG_IN <= '0';
--	  elsif (rising_edge(clk)) then
--	   ADVANCE_MENU_TRIG_IN <= '0';
--	   if(gpio_4_d4='1' and gpio_5_d4 ='1')then
--	       if(TICK1S = '1')then
--	           long_press_timer <= long_press_timer + 1;
--	       end if;
--	   else
--	       long_press_timer <= (others=>'0');       
--       end if;
       
--       if(long_press_timer >= 4)then
--        ADVANCE_MENU_TRIG_IN <= '1';
--       else
       
--       end if;
       
       
--	  end if;
--	end process long_press_gen;
        


--end RTL;



--library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--entity debouncer is
--	generic (
--			FREQ : positive:=27e6;
--			SETTLE_TIME: time:= 20 ms;
--			PULLUP: std_logic:='0'
--		);
--	port (
--			clk     : in std_logic;
--			rst     : in std_logic;
--			tick1ms : in std_logic;
--			tick1s  : in  std_logic;
--			max_release_wait_time : in std_logic_vector(11 downto 0);

--			gpio_i_1: in std_logic;
--			gpio_i_2: in std_logic;
--			gpio_i_3: in std_logic;
--			gpio_i_4: in std_logic;
--			gpio_i_5: in std_logic;

--		-- Pulse Outputs
--			gpio_o_1_pulse: out std_logic;
--			gpio_o_2_pulse: out std_logic;
--			gpio_o_3_pulse: out std_logic;
--			gpio_o_4_pulse: out std_logic;
--			gpio_o_5_pulse: out std_logic;

--		    ADVANCE_MENU_TRIG_IN : out std_logic
--		);

--end entity debouncer;

--architecture RTL of debouncer is

--	signal gpio_1_d1 : std_logic:= '0';
--	signal gpio_1_d2 : std_logic:= '0';
--	signal gpio_2_d1 : std_logic:= '0';
--	signal gpio_2_d2 : std_logic:= '0';
--	signal gpio_3_d1 : std_logic:= '0';
--	signal gpio_3_d2 : std_logic:= '0';
--	signal gpio_4_d1 : std_logic:= '0';
--	signal gpio_4_d2 : std_logic:= '0';
--	signal gpio_5_d1 : std_logic:= '0';
--	signal gpio_5_d2 : std_logic:= '0';

--	signal press_gpio_1_d3: std_logic:= '0';
--	signal press_gpio_1_d4: std_logic:= '0';
--	signal press_gpio_2_d3: std_logic:= '0';
--	signal press_gpio_2_d4: std_logic:= '0';	
--	signal press_gpio_3_d3: std_logic:= '0';
--	signal press_gpio_3_d4: std_logic:= '0';
--	signal press_gpio_4_d3: std_logic:= '0';
--	signal press_gpio_4_d4: std_logic:= '0';
--	signal press_gpio_5_d3: std_logic:= '0';
--	signal press_gpio_5_d4: std_logic:= '0';


--	signal release_gpio_1_d3 : std_logic:= '0';
--	signal release_gpio_1_d4 : std_logic:= '0';
--	signal release_gpio_2_d3 : std_logic:= '0';
--	signal release_gpio_2_d4 : std_logic:= '0';	
--	signal release_gpio_3_d3 : std_logic:= '0';
--	signal release_gpio_3_d4 : std_logic:= '0';
--	signal release_gpio_4_d3 : std_logic:= '0';
--	signal release_gpio_4_d4 : std_logic:= '0';
--	signal release_gpio_5_d3 : std_logic:= '0';
--	signal release_gpio_5_d4 : std_logic:= '0';

--    signal press_pulse_gpio_1   : std_logic:= '0';
--    signal press_pulse_gpio_2   : std_logic:= '0';
--    signal press_pulse_gpio_3   : std_logic:= '0';
--    signal press_pulse_gpio_4   : std_logic:= '0';
--    signal press_pulse_gpio_5   : std_logic:= '0';

--    signal release_pulse_gpio_1 : std_logic:= '0';
--    signal release_pulse_gpio_2 : std_logic:= '0';
--    signal release_pulse_gpio_3 : std_logic:= '0';
--    signal release_pulse_gpio_4 : std_logic:= '0';
--    signal release_pulse_gpio_5 : std_logic:= '0';

--    signal gpio_o_1 : std_logic:= '0';
--    signal gpio_o_2 : std_logic:= '0';
--    signal gpio_o_3 : std_logic:= '0';
--    signal gpio_o_4 : std_logic:= '0';
--    signal gpio_o_5 : std_logic:= '0';


--	constant settle_time_in_clocks : positive := integer(real(FREQ) * SETTLE_TIME / 1 sec);
--	signal press_timer_1 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal press_timer_2 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal press_timer_3 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal press_timer_4 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal press_timer_5 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;

--	signal release_timer_1 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal release_timer_2 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal release_timer_3 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal release_timer_4 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
--	signal release_timer_5 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;



--    type out_pulse_gen_gpio_1_st_t is (s_idle,s_wait_press,s_wait_release);
--    signal out_pulse_gen_gpio_1_st   : out_pulse_gen_gpio_1_st_t;

--    type out_pulse_gen_gpio_2_st_t is (s_idle,s_wait_press,s_wait_release);
--    signal out_pulse_gen_gpio_2_st   : out_pulse_gen_gpio_2_st_t;
    
--    type out_pulse_gen_gpio_3_st_t is (s_idle,s_wait_press,s_wait_release);
--    signal out_pulse_gen_gpio_3_st   : out_pulse_gen_gpio_3_st_t;

--    type out_pulse_gen_gpio_4_st_t is (s_idle,s_wait_press,s_wait_release);
--    signal out_pulse_gen_gpio_4_st   : out_pulse_gen_gpio_4_st_t;        

--    type out_pulse_gen_gpio_5_st_t is (s_idle,s_wait_press,s_wait_release);
--    signal out_pulse_gen_gpio_5_st   : out_pulse_gen_gpio_5_st_t;
    
    	
--	signal long_press_timer     : unsigned(3 downto 0);
--	signal release_wait_timer_1 : unsigned(11 downto 0);
--	signal release_wait_timer_2 : unsigned(11 downto 0);
--	signal release_wait_timer_3 : unsigned(11 downto 0);
--	signal release_wait_timer_4 : unsigned(11 downto 0);
--	signal release_wait_timer_5 : unsigned(11 downto 0);

--begin

--gpio_o_1_pulse <= gpio_o_1;
--gpio_o_2_pulse <= gpio_o_2;
--gpio_o_3_pulse <= gpio_o_3;
--gpio_o_4_pulse <= gpio_o_4;
--gpio_o_5_pulse <= gpio_o_5;


--	-- Use a two stage syncronizer
--	sync : process (rst, clk)
--	begin
--	  if (rst= '1') then
--	    gpio_1_d1 <= '0';
--	    gpio_1_d2 <= '0';
--	    gpio_2_d1 <= '0';
--	    gpio_2_d2 <= '0';
--	    gpio_3_d1 <= '0';
--	    gpio_3_d2 <= '0';
--	    gpio_4_d1 <= '0';
--	    gpio_4_d2 <= '0';
--	    gpio_5_d1 <= '0';
--	    gpio_5_d2 <= '0';

--	  elsif (rising_edge(clk)) then

--	  	gpio_1_d1 <= gpio_I_1;
--	    gpio_1_d2 <= gpio_1_d1;
--	    gpio_2_d1 <= gpio_I_2;
--	    gpio_2_d2 <= gpio_2_d1;
--	    gpio_3_d1 <= gpio_I_3;
--	    gpio_3_d2 <= gpio_3_d1;
--	    gpio_4_d1 <= gpio_I_4;
--	    gpio_4_d2 <= gpio_4_d1;
--	    gpio_5_d1 <= gpio_I_5;
--	    gpio_5_d2 <= gpio_5_d1;
	
--	  end if;
--	end process sync;

---- Use a press_timer to check for debouncing and mitigate them
--	counter_proc : process (rst, clk)
--	begin
--	  if (rst = '1') then
--	    press_timer_1     <= settle_time_in_clocks-1;
--	    press_timer_2     <= settle_time_in_clocks-1;
--	    press_timer_3     <= settle_time_in_clocks-1;
--	    press_timer_4     <= settle_time_in_clocks-1;
--	    press_timer_5     <= settle_time_in_clocks-1;
--	    release_timer_1   <= settle_time_in_clocks-1;
--	    release_timer_2   <= settle_time_in_clocks-1;
--	    release_timer_3   <= settle_time_in_clocks-1;
--	    release_timer_4   <= settle_time_in_clocks-1;
--	    release_timer_5   <= settle_time_in_clocks-1;
--	    press_gpio_1_d3   <= '0';
--	    press_gpio_2_d3   <= '0';
--	    press_gpio_3_d3   <= '0';
--	    press_gpio_4_d3   <= '0';
--	    press_gpio_5_d3   <= '0';
--	    release_gpio_1_d3 <= '0';
--	    release_gpio_2_d3 <= '0';
--	    release_gpio_3_d3 <= '0';
--	    release_gpio_4_d3 <= '0';
--	    release_gpio_5_d3 <= '0';

--	  elsif (rising_edge(clk)) then
--		if(gpio_1_d2='1') then
--			press_timer_1 <= settle_time_in_clocks-1;
--			press_gpio_1_d3 <= '0';
--		elsif (press_timer_1=0) then
--			press_gpio_1_d3 <= '1';
--		else
--			press_timer_1 <= press_timer_1 -1;
--		end if;

--		if(gpio_2_d2='1') then
--			press_timer_2 <= settle_time_in_clocks-1;
--			press_gpio_2_d3 <= '0';
--		elsif (press_timer_2=0) then
--			press_gpio_2_d3 <= '1';
--		else
--			press_timer_2 <= press_timer_2 -1;
--		end if;

--		if(gpio_3_d2='1') then
--			press_timer_3 <= settle_time_in_clocks-1;
--			press_gpio_3_d3 <= '0';
--		elsif (press_timer_3=0) then
--			press_gpio_3_d3 <= '1';
--		else
--			press_timer_3 <= press_timer_3 -1;
--		end if;

--		if(gpio_4_d2='1') then
--			press_timer_4 <= settle_time_in_clocks-1;
--			press_gpio_4_d3 <= '0';
--		elsif (press_timer_4=0) then
--			press_gpio_4_d3 <= '1';
--		else
--			press_timer_4 <= press_timer_4 -1;
--		end if;

--		if(gpio_5_d2='1') then
--			press_timer_5 <= settle_time_in_clocks-1;
--			press_gpio_5_d3 <= '0';
--		elsif (press_timer_5=0) then
--			press_gpio_5_d3 <= '1';
--		else
--			press_timer_5 <= press_timer_5 -1;
--		end if;

--		if(gpio_1_d2='0') then
--			release_timer_1 <= settle_time_in_clocks-1;
--			release_gpio_1_d3 <= '0';
--		elsif (release_timer_1=0) then
--			release_gpio_1_d3 <= '1';
--		else
--			release_timer_1 <= release_timer_1 -1;
--		end if;

--		if(gpio_2_d2='0') then
--			release_timer_2 <= settle_time_in_clocks-1;
--			release_gpio_2_d3 <= '0';
--		elsif (release_timer_2=0) then
--			release_gpio_2_d3 <= '1';
--		else
--			release_timer_2 <= release_timer_2 -1;
--		end if;

--		if(gpio_3_d2='0') then
--			release_timer_3 <= settle_time_in_clocks-1;
--			release_gpio_3_d3 <= '0';
--		elsif (release_timer_3=0) then
--			release_gpio_3_d3 <= '1';
--		else
--		    release_timer_3 <= release_timer_3 -1;
--		end if;

--		if(gpio_4_d2='0') then
--			release_timer_4 <= settle_time_in_clocks-1;
--			release_gpio_4_d3 <= '0';
--		elsif (release_timer_4=0) then
--			release_gpio_4_d3 <= '1';
--		else
--			release_timer_4 <= release_timer_4 -1;
--		end if;

--		if(gpio_5_d2='0') then
--			release_timer_5 <= settle_time_in_clocks-1;
--			release_gpio_5_d3 <= '0';
--		elsif (release_timer_5=0) then
--			release_gpio_5_d3 <= '1';
--		else
--			release_timer_5 <= release_timer_5 -1;
--		end if;

			
--	  end if;
	  
--	end process counter_proc;

---- Generate pulse signals from the debounced gpios
--	pulse_gen : process (rst, clk)
--	begin
--	  if (rst = '1') then
--		press_gpio_1_d4   <= '0';
--		press_gpio_2_d4   <= '0';
--		press_gpio_3_d4   <= '0';
--		press_gpio_4_d4   <= '0';
--		press_gpio_5_d4   <= '0';
--	    release_gpio_1_d4 <= '0';
--		release_gpio_2_d4 <= '0';
--		release_gpio_3_d4 <= '0';
--		release_gpio_4_d4 <= '0';
--		release_gpio_5_d4 <= '0';
--	  elsif (rising_edge(clk)) then
--		press_gpio_1_d4   <= press_gpio_1_d3;
--		press_gpio_2_d4   <= press_gpio_2_d3;
--		press_gpio_3_d4   <= press_gpio_3_d3;
--		press_gpio_4_d4   <= press_gpio_4_d3;
--		press_gpio_5_d4   <= press_gpio_5_d3;
--		release_gpio_5_d4 <= release_gpio_5_d3;
--		release_gpio_1_d4 <= release_gpio_1_d3;
--		release_gpio_2_d4 <= release_gpio_2_d3;
--		release_gpio_3_d4 <= release_gpio_3_d3;
--		release_gpio_4_d4 <= release_gpio_4_d3;
--		release_gpio_5_d4 <= release_gpio_5_d3;

--	  end if;
--	end process pulse_gen;

--	press_pulse_gpio_1   <= press_gpio_1_d3 and not press_gpio_1_d4;
--	press_pulse_gpio_2   <= press_gpio_2_d3 and not press_gpio_2_d4;
--	press_pulse_gpio_3   <= press_gpio_3_d3 and not press_gpio_3_d4;
--	press_pulse_gpio_4   <= press_gpio_4_d3 and not press_gpio_4_d4;
--	press_pulse_gpio_5   <= press_gpio_5_d3 and not press_gpio_5_d4;

--	release_pulse_gpio_1 <= release_gpio_1_d3 and not release_gpio_1_d4;
--	release_pulse_gpio_2 <= release_gpio_2_d3 and not release_gpio_2_d4;
--	release_pulse_gpio_3 <= release_gpio_3_d3 and not release_gpio_3_d4;
--	release_pulse_gpio_4 <= release_gpio_4_d3 and not release_gpio_4_d4;
--	release_pulse_gpio_5 <= release_gpio_5_d3 and not release_gpio_5_d4;


---- Generate output pulse signals from the press and release action
--	output_pulse_gen : process (rst, clk)
--	begin
--	  if (rst = '1') then
--        out_pulse_gen_gpio_1_st <= s_idle;
--        out_pulse_gen_gpio_2_st <= s_idle;
--        out_pulse_gen_gpio_3_st <= s_idle;
--        out_pulse_gen_gpio_4_st <= s_idle;
--        out_pulse_gen_gpio_5_st <= s_idle;
--        gpio_o_1                <= '0';
--        gpio_o_2                <= '0';
--        gpio_o_3                <= '0';
--        gpio_o_4                <= '0';
--        gpio_o_5                <= '0';
--        release_wait_timer_1    <= x"000";
--        release_wait_timer_2    <= x"000";
--        release_wait_timer_3    <= x"000";
--        release_wait_timer_4    <= x"000";
--        release_wait_timer_5    <= x"000";
        
--	  elsif (rising_edge(clk)) then  
--          gpio_o_1  <= '0';
--          gpio_o_2  <= '0';
--          gpio_o_3  <= '0';
--          gpio_o_4  <= '0';
--          gpio_o_5  <= '0';
          
--          case out_pulse_gen_gpio_1_st is
           
--           when s_idle =>
--              out_pulse_gen_gpio_1_st <= s_wait_press;
              
--           when s_wait_press =>
--            if(press_pulse_gpio_1 = '1')then
--              out_pulse_gen_gpio_1_st <= s_wait_release;
--            else
--              out_pulse_gen_gpio_1_st <= s_wait_press;
--            end if;
              
--           when s_wait_release =>
--             if(release_pulse_gpio_1 = '1')then
--              out_pulse_gen_gpio_1_st <= s_idle;
--              gpio_o_1                <= '1';
--              release_wait_timer_1    <= x"000";   
--             else
--              out_pulse_gen_gpio_1_st <= s_wait_release;
--              if(release_wait_timer_1 = unsigned(max_release_wait_time))then
--                 release_wait_timer_1 <= x"000";
--                 gpio_o_1             <= '1';
--              else
--                 if(tick1ms = '1')then
--                     release_wait_timer_1 <= release_wait_timer_1 + 1;
--                 end if;             
--              end if;
--             end if;

--          end case;

--          case out_pulse_gen_gpio_2_st is
           
--           when s_idle =>
--              out_pulse_gen_gpio_2_st <= s_wait_press;
              
--           when s_wait_press =>
--            if(press_pulse_gpio_2 = '1')then
--              out_pulse_gen_gpio_2_st <= s_wait_release;
--            else
--              out_pulse_gen_gpio_2_st <= s_wait_press;
--            end if;
              
--           when s_wait_release =>
--             if(release_pulse_gpio_2 = '1')then
--              out_pulse_gen_gpio_2_st <= s_idle;
--              gpio_o_2                <= '1';
--              release_wait_timer_2    <= x"000";   
--             else
--              out_pulse_gen_gpio_2_st <= s_wait_release;
--              if(release_wait_timer_2 = unsigned(max_release_wait_time))then
--                 release_wait_timer_2 <= x"000";
--                 gpio_o_2             <= '1';
--              else
--                 if(tick1ms = '1')then
--                     release_wait_timer_2 <= release_wait_timer_2 + 1;
--                 end if;             
--              end if;
--             end if;
             
--          end case;

--          case out_pulse_gen_gpio_3_st is
           
--           when s_idle =>
--              out_pulse_gen_gpio_3_st <= s_wait_press;
              
--           when s_wait_press =>
--            if(press_pulse_gpio_3 = '1')then
--              out_pulse_gen_gpio_3_st <= s_wait_release;
--            else
--              out_pulse_gen_gpio_3_st <= s_wait_press;
--            end if;
              
--           when s_wait_release =>
--             if(release_pulse_gpio_3 = '1')then
--              out_pulse_gen_gpio_3_st <= s_idle;
--              gpio_o_3                <= '1';
--              release_wait_timer_3    <= x"000";   
--             else
--              out_pulse_gen_gpio_3_st <= s_wait_release;
--              if(release_wait_timer_3 = unsigned(max_release_wait_time))then
--                 release_wait_timer_3 <= x"000";
--                 gpio_o_3             <= '1';
--              else
--                 if(tick1ms = '1')then
--                     release_wait_timer_3 <= release_wait_timer_3 + 1;
--                 end if;             
--              end if;
--             end if;
             
--          end case;

--          case out_pulse_gen_gpio_4_st is
           
--           when s_idle =>
--              out_pulse_gen_gpio_4_st <= s_wait_press;
              
--           when s_wait_press =>
--            if(press_pulse_gpio_4 = '1')then
--              out_pulse_gen_gpio_4_st <= s_wait_release;
--            else
--              out_pulse_gen_gpio_4_st <= s_wait_press;
--            end if;
              
--           when s_wait_release =>
--             if(release_pulse_gpio_4 = '1')then
--              out_pulse_gen_gpio_4_st <= s_idle;
--              gpio_o_4                <= '1';
--              release_wait_timer_4    <= x"000";   
--             else
--              out_pulse_gen_gpio_4_st <= s_wait_release;
--              if(release_wait_timer_4 = unsigned(max_release_wait_time))then
--                 release_wait_timer_4 <= x"000";
--                 gpio_o_4             <= '1';
--              else
--                 if(tick1ms = '1')then
--                     release_wait_timer_4 <= release_wait_timer_4 + 1;
--                 end if;             
--              end if;
--             end if;
             
--          end case;

--          case out_pulse_gen_gpio_5_st is
           
--           when s_idle =>
--              out_pulse_gen_gpio_5_st <= s_wait_press;
              
--           when s_wait_press =>
--            if(press_pulse_gpio_5 = '1')then
--              out_pulse_gen_gpio_5_st <= s_wait_release;
--            else
--              out_pulse_gen_gpio_5_st <= s_wait_press;
--            end if;
              
--           when s_wait_release =>
--             if(release_pulse_gpio_5 = '1')then
--              out_pulse_gen_gpio_5_st <= s_idle;
--              gpio_o_5                <= '1';
--              release_wait_timer_5    <= x"000";   
--             else
--              out_pulse_gen_gpio_5_st <= s_wait_release;
--              if(release_wait_timer_5 = unsigned(max_release_wait_time))then
--                 release_wait_timer_5 <= x"000";
--                 gpio_o_5             <= '1';
--              else
--                 if(tick1ms = '1')then
--                     release_wait_timer_5 <= release_wait_timer_5 + 1;
--                 end if;             
--              end if;
--             end if;
             
--          end case;

--	  end if;
--	end process output_pulse_gen;


--	long_press_gen : process (rst, clk)
--	begin
--	  if (rst = '1') then
--        long_press_timer <= (others=>'0');
--        ADVANCE_MENU_TRIG_IN <= '0';
--	  elsif (rising_edge(clk)) then
--	   ADVANCE_MENU_TRIG_IN <= '0';
--	   if(press_gpio_4_d4='1' and press_gpio_5_d4 ='1')then
--	       if(tick1s = '1')then
--	           long_press_timer <= long_press_timer + 1;
--	       end if;
--	   else
--	       long_press_timer <= (others=>'0');       
--       end if;
       
--       if(long_press_timer >= 3)then
--        ADVANCE_MENU_TRIG_IN <= '1';
--       end if;
       
       
--	  end if;
--	end process long_press_gen;
        


--end RTL;



----library IEEE;
----use IEEE.std_logic_1164.all;
----use IEEE.numeric_std.all;
----entity debouncer is
----	generic (
----			FREQ : positive:=27e6;
----			SETTLE_TIME: time:= 20 ms;
----			PULLUP: std_logic:='0'
----		);
----	port (
----			clk     : in std_logic;
----			rst     : in std_logic;
----			TICK1S  : in  std_logic;

----			gpio_I_1: in std_logic;
----			gpio_I_2: in std_logic;
----			gpio_I_3: in std_logic;
----			gpio_I_4: in std_logic;
----			gpio_I_5: in std_logic;

----		-- Pulse Outputs
----			gpio_O_1: out std_logic;
----			gpio_O_2: out std_logic;
----			gpio_O_3: out std_logic;
----			gpio_O_4: out std_logic;
----			gpio_O_5: out std_logic;

----		    ADVANCE_MENU_TRIG_IN : out std_logic
----		);

----end entity debouncer;

----architecture RTL of debouncer is

----	signal gpio_1_d1 : std_logic:= '0';
----	signal gpio_1_d2 : std_logic:= '0';
----	signal gpio_1_d3 : std_logic:= '0';
----	signal gpio_1_d4 : std_logic:= '0';
----	signal gpio_2_d1 : std_logic:= '0';
----	signal gpio_2_d2 : std_logic:= '0';
----	signal gpio_2_d3 : std_logic:= '0';
----	signal gpio_2_d4 : std_logic:= '0';
----	signal gpio_3_d1 : std_logic:= '0';
----	signal gpio_3_d2 : std_logic:= '0';
----	signal gpio_3_d3 : std_logic:= '0';
----	signal gpio_3_d4 : std_logic:= '0';
----	signal gpio_4_d1 : std_logic:= '0';
----	signal gpio_4_d2 : std_logic:= '0';
----	signal gpio_4_d3 : std_logic:= '0';
----	signal gpio_4_d4 : std_logic:= '0';
----	signal gpio_5_d1 : std_logic:= '0';
----	signal gpio_5_d2 : std_logic:= '0';
----	signal gpio_5_d3 : std_logic:= '0';
----	signal gpio_5_d4 : std_logic:= '0';

----	constant settle_time_in_clocks : positive := integer(real(FREQ) * SETTLE_TIME / 1 sec);
----	signal press_timer_1 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
----	signal press_timer_2 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
----	signal press_timer_3 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
----	signal press_timer_4 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
----	signal press_timer_5 : natural range settle_time_in_clocks-1 downto 0 := settle_time_in_clocks-1;
	
----	signal long_press_timer : unsigned(3 downto 0);

----begin

----	-- Use a two stage syncronizer
----	sync : process (rst, clk)
----	begin
----	  if (rst= '1') then
----	    gpio_1_d1 <= '0';
----	    gpio_1_d2 <= '0';
----	    gpio_2_d1 <= '0';
----	    gpio_2_d2 <= '0';
----	    gpio_3_d1 <= '0';
----	    gpio_3_d2 <= '0';
----	    gpio_4_d1 <= '0';
----	    gpio_4_d2 <= '0';
----	    gpio_5_d1 <= '0';
----	    gpio_5_d2 <= '0';

----	  elsif (rising_edge(clk)) then

----	  	gpio_1_d1 <= gpio_I_1;
----	    gpio_1_d2 <= gpio_1_d1;
----	    gpio_2_d1 <= gpio_I_2;
----	    gpio_2_d2 <= gpio_2_d1;
----	    gpio_3_d1 <= gpio_I_3;
----	    gpio_3_d2 <= gpio_3_d1;
----	    gpio_4_d1 <= gpio_I_4;
----	    gpio_4_d2 <= gpio_4_d1;
----	    gpio_5_d1 <= gpio_I_5;
----	    gpio_5_d2 <= gpio_5_d1;
	
----	  end if;
----	end process sync;

------ Use a press_timer to check for debouncing and mitigate them
----	counter_proc : process (rst, clk)
----	begin
----	  if (rst = '1') then
----	    press_timer_1 <= settle_time_in_clocks-1;
----	    press_timer_2 <= settle_time_in_clocks-1;
----	    press_timer_3 <= settle_time_in_clocks-1;
----	    press_timer_4 <= settle_time_in_clocks-1;
----	    press_timer_5 <= settle_time_in_clocks-1;

----	    gpio_1_d3 <= '0';
----	    gpio_2_d3 <= '0';
----	    gpio_3_d3 <= '0';
----	    gpio_4_d3 <= '0';
----	    gpio_5_d3 <= '0';
----	  elsif (rising_edge(clk)) then
----		if(gpio_1_d2='1') then
----			press_timer_1 <= settle_time_in_clocks-1;
----			gpio_1_d3 <= '0';
----		elsif (press_timer_1=0) then
----			gpio_1_d3 <= '1';
----		else
----			press_timer_1 <= press_timer_1 -1;
----		end if;

----		if(gpio_2_d2='1') then
----			press_timer_2 <= settle_time_in_clocks-1;
----			gpio_2_d3 <= '0';
----		elsif (press_timer_2=0) then
----			gpio_2_d3 <= '1';
----		else
----			press_timer_2 <= press_timer_2 -1;
----		end if;

----		if(gpio_3_d2='1') then
----			press_timer_3 <= settle_time_in_clocks-1;
----			gpio_3_d3 <= '0';
----		elsif (press_timer_3=0) then
----			gpio_3_d3 <= '1';
----		else
----			press_timer_3 <= press_timer_3 -1;
----		end if;

----		if(gpio_4_d2='1') then
----			press_timer_4 <= settle_time_in_clocks-1;
----			gpio_4_d3 <= '0';
----		elsif (press_timer_4=0) then
----			gpio_4_d3 <= '1';
----		else
----			press_timer_4 <= press_timer_4 -1;
----		end if;

----		if(gpio_5_d2='1') then
----			press_timer_5 <= settle_time_in_clocks-1;
----			gpio_5_d3 <= '0';
----		elsif (press_timer_5=0) then
----			gpio_5_d3 <= '1';
----		else
----			press_timer_5 <= press_timer_5 -1;
----		end if;
			
----	  end if;
----	end process counter_proc;

------ Generate pulse signals from the debounced gpios
----	pulse_gen : process (rst, clk)
----	begin
----	  if (rst = '1') then
----		gpio_1_d4 <= '0';
----		gpio_2_d4 <= '0';
----		gpio_3_d4 <= '0';
----		gpio_4_d4 <= '0';
----		gpio_5_d4 <= '0';
----	  elsif (rising_edge(clk)) then
----		gpio_1_d4 <= gpio_1_d3;
----		gpio_2_d4 <= gpio_2_d3;
----		gpio_3_d4 <= gpio_3_d3;
----		gpio_4_d4 <= gpio_4_d3;
----		gpio_5_d4 <= gpio_5_d3;
----	  end if;
----	end process pulse_gen;

----	gpio_O_1 <= gpio_1_d3 and not gpio_1_d4;
----	gpio_O_2 <= gpio_2_d3 and not gpio_2_d4;
----	gpio_O_3 <= gpio_3_d3 and not gpio_3_d4;
----	gpio_O_4 <= gpio_4_d3 and not gpio_4_d4;
----	gpio_O_5 <= gpio_5_d3 and not gpio_5_d4;


----	long_press_gen : process (rst, clk)
----	begin
----	  if (rst = '1') then
----        long_press_press_timer <= (others=>'0');
----        ADVANCE_MENU_TRIG_IN <= '0';
----	  elsif (rising_edge(clk)) then
----	   ADVANCE_MENU_TRIG_IN <= '0';
----	   if(gpio_4_d4='1' and gpio_5_d4 ='1')then
----	       if(TICK1S = '1')then
----	           long_press_timer <= long_press_timer + 1;
----	       end if;
----	   else
----	       long_press_timer <= (others=>'0');       
----       end if;
       
----       if(long_press_timer >= 4)then
----        ADVANCE_MENU_TRIG_IN <= '1';
----       else
       
----       end if;
       
       
----	  end if;
----	end process long_press_gen;
        


----end RTL;