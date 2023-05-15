--	Original Developers - Dexcel?
--	Modified by: Sai Parthasarathy
--	Change Log 13-01-2016
	--	Look up "Change Log Point 1"
	--	1.	I2C_Master previously set an internal signal, sda_int, which represented the
	--		sda INOUT port inside the FPGA, to 'Z'. This can potentially (and actually did)
	--		cause issues when the compiler is not smart enough to deal with it, since internal
	--		signals cannot be set to anything other than '0' and '1'. Therefore, made internal
	--		signal work with only '0' and '1', and reflected it as 'Z' only at assignment to
	--		INOUT port.

	--	Look up "Change Log Point 2"
	--	2.	Module previously did not completely conform to Avalon standards. Write_EN and
	--		Read_EN were expected to stay at '1' throughout the transaction process. Now it
	--		has been modified to comply with Avalon protocol, and Write_EN and Read_EN are
	--		registered into an "Int_Write_EN" and "Int_Read_EN".

	--	Look up "Change Log Point 3"
	--	3.	Module previously observed only whether Write_EN = '1' and Read_EN = '0', and
	--		assumed all other combinations of the two signals to be Read Requests. This is
	--		now modified to check whether Write_EN = '1' and Read_EN = '0', or
	--		if Write_EN = '0' and Read_EN = '1', and if neither are true, then FSM directly
	--		skips to stop communication. There is no error acknowledgement for when this happens, yet.
	--		Try not to give both Write_EN and Read_EN as '1' simultaneously.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY SENSOR_I2C_MASTER IS
  GENERIC(
    input_clk : INTEGER := 110_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 100_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
	reg_addr  : IN     STD_LOGIC_VECTOR(15 DOWNTO 0); --address of target register in slave
    read_en   : IN     STD_LOGIC;                    --'1' is read
	write_en  : IN     STD_LOGIC;                    --'1' is write
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
	read_valid: OUT    STD_LOGIC;
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC;
    reg_16_bit_en : in STD_LOGIC;
    state_o   : out STD_LOGIC_VECTOR(3 DOWNTO 0)
    );                   --serial clock output of i2c bus
END SENSOR_I2C_MASTER;

ARCHITECTURE logic OF SENSOR_I2C_MASTER IS
  CONSTANT divider  :  INTEGER := (input_clk/bus_clk)/4; --number of clocks in 1/4 cycle of scl
  TYPE machine IS(ready, start, command, slv_ack1, reg,slv_ack_reg, wr, rd, slv_ack2, mstr_ack, stop); --needed states
  SIGNAL  state		:  machine;                          --state machine
  TYPE read_phase IS (default,phase1,phase2);
  SIGNAL  temp      :read_phase;
  SIGNAL  ena_i     :  STD_LOGIC;  
  SIGNAL  data_clk  :  STD_LOGIC;                        --clock edges for sda
  SIGNAL  scl_clk   :  STD_LOGIC;                        --constantly running internal scl
  SIGNAL  scl_ena   :  STD_LOGIC := '0';                 --enables internal scl to output
  SIGNAL  sda_int   :  STD_LOGIC := '1';                 --internal sda
  SIGNAL  sda_ena_n :  STD_LOGIC;                        --enables internal sda to output
  SIGNAL  int_read_en	:  STD_LOGIC;									-- Change Log Point 2
  SIGNAL  int_write_en	:  STD_LOGIC;									-- Change Log Point 2
  SIGNAL  addr_r,addr_w   :  STD_LOGIC_VECTOR(7 DOWNTO 0);     --latched in address and read/write
  SIGNAL  data_tx   :  STD_LOGIC_VECTOR(7 DOWNTO 0);     --latched in data to write to slave
  SIGNAL  data_rx   :  STD_LOGIC_VECTOR(7 DOWNTO 0);     --data received from slave
  SIGNAL  bit_cnt   :  INTEGER RANGE 0 TO 7 := 7;        --tracks bit number in transaction
  SIGNAL  stretch   :  STD_LOGIC := '0';                 --identifies if slave is stretching scl
  SIGNAL reg_addr_temp : STD_LOGIC_VECTOR(15 DOWNTO 0); 
  SIGNAL reg_16_bit_en_latch : STD_LOGIC;  
BEGIN

state_o <=  "0000" when state=ready else
                "0001" when state=start else
                "0010" when state=command else
                "0011" when state=slv_ack1 else
                "0100" when state=reg else
                "0101" when state=slv_ack_reg else
                "0110" when state=wr else
                "0111" when state=rd else
                "1000" when state=slv_ack2 else
                "1001" when state=mstr_ack else
                "1010" when state=stop else
                "1111"
                ;
  --generate the timing for the bus clock (scl_clk) and the data clock (data_clk)
  PROCESS(clk, reset_n)
    VARIABLE count : INTEGER RANGE 0 TO divider*4; --timing for clock generation
  BEGIN
    IF(reset_n = '1') THEN               --reset asserted
      stretch <= '0';
      count := 0;
    ELSIF(clk'EVENT AND clk = '1') THEN
	--ena_i <= ena;
---\	
	--THE COUNT WILL STOP IF STRETCH = 0
---/	
      IF(count = divider*4-1) THEN       --end of timing cycle
        count := 0;                      --reset timer
      ELSIF(stretch = '0') THEN          --clock stretching from slave not detected
        count := count + 1;              --continue clock generation timing
      END IF;
---\	
	--IN THE 3rd cycle WE CAN STOP THE COUNTER and so STOP the DATA_CLK and SCL_CLK when SCL = 0
---/	  
      CASE count IS
        WHEN 0 TO divider-1 =>           --first 1/4 cycle of clocking
          scl_clk <= '0';
          data_clk <= '0';
        WHEN divider TO divider*2-1 =>   --second 1/4 cycle of clocking
          scl_clk <= '0';
          data_clk <= '1';
        WHEN divider*2 TO divider*3-1 => --third 1/4 cycle of clocking
          -- scl_clk <= 'Z';                --release scl
		  scl_clk <= '1'; 														-- Change Log Point 1
          IF(scl = '0') THEN             --detect if slave is stretching clock 
            stretch <= '1';				-- hold the scl_clk low
          ELSE
            stretch <= '0';
          END IF;
          data_clk <= '1';
        WHEN OTHERS =>                   --last 1/4 cycle of clocking
          -- scl_clk <= 'Z';
		  scl_clk <= '1'; 														-- Change Log Point 1 
          data_clk <= '0';
      END CASE;
    END IF;
  END PROCESS;

  --state machine and writing to sda during scl low (data_clk rising edge)
  PROCESS(data_clk, reset_n)
  BEGIN
    IF(reset_n = '1') THEN                  --reset asserted
      state 	<= ready;                       --return to initial state
      busy 		<= '1';                          --indicate not available
      scl_ena	<= '0';                       --sets scl high impedance
      sda_int 	<= '1';                       --sets sda high impedance
      bit_cnt 	<= 7;                         --restarts data bit counter
      data_rd 	<= "00000000";                --clear data read port
	  read_valid <= '0';
    ELSIF(data_clk'EVENT AND data_clk = '1') THEN
      CASE state IS
		--------------
        WHEN ready =>                       --idle state
		--------------
		  reg_addr_temp <= reg_addr(7 downto 0) & reg_addr(15 downto 8);
		  reg_16_bit_en_latch <= '0';
          temp 		 <= default;
		  read_valid <= '0';
		  int_read_en <= '0';												-- Change Log Point 2
		  int_write_en <= '0';												-- Change Log Point 2
		  IF(ena = '1') and ((read_en or write_en)='1') THEN                --transaction requested
            busy <= '1';                    --flag busy
            addr_r <= addr & '1';           --collect requested slave address and read
            addr_w <= addr & '0';
			data_tx <= data_wr;             --collect requested data to write
            state <= start;                 --go to start bit
			int_read_en <= read_en;											-- Change Log Point 2
			int_write_en <= write_en;										-- Change Log Point 2
          ELSE                              --remain idle
            busy <= '0';                    --unflag busy
            state <= ready;                 --remain idle

          END IF;
		  
		--------------- 
        WHEN start =>                       --start bit of transaction
		---------------
          busy <= '1';                      --resume busy if continuous mode
          scl_ena <= '1';                   --enable scl output
          sda_int <= addr_w(bit_cnt);      --set first address bit to bus
          state <= command;                 --go to command
          reg_16_bit_en_latch <= '0';
		  
        --------------- 
		WHEN command =>                     --address and command byte of transaction
		---------------
			busy <= '1';         
			IF(bit_cnt = 0) THEN              --command transmit finished
				sda_int <= '1';                 --release sda for slave acknowledge
				bit_cnt <= 7;                   --reset bit counter for "byte" states
				state <= slv_ack1;              --go to slave acknowledge (command)
			ELSE                              --next clock cycle of command state
				bit_cnt <= bit_cnt - 1;         --keep track of transaction bits
				if temp = default then
					sda_int <= addr_w(bit_cnt-1);  --write slave address + "write bit"
				elsif temp = phase2 then
					sda_int <= addr_r(bit_cnt-1);  --write slave address + "read bit" in 2nd phase of read
				end if;
				state <= command;               --continue with command
			END IF;
			
		----------------
        WHEN slv_ack1 =>                    --slave acknowledge bit (command)
		----------------
			if temp = default then
				busy <= '1';            
				sda_int <= reg_addr_temp(bit_cnt);    --write first bit of register address
				state <= reg;                    --go to register byte byte
			elsif temp =phase2 then
				busy <= '1';
				sda_int <= '1';						-- releasing SDA
				state <= rd;						-- to read from slave
			end if;
        --------------   
        WHEN reg =>                     --address and command byte of transaction
		--------------
			busy <= '1';
			IF(bit_cnt = 0) THEN              --command transmit finished
				sda_int <= '1';                 --release sda for slave acknowledge
				bit_cnt <= 7;                   --reset bit counter for "byte" states
				state <= slv_ack_reg;              --go to slave acknowledge (command)
			ELSE                              --next clock cycle of command state
				bit_cnt <= bit_cnt - 1;         --keep track of transaction bits
				sda_int <= reg_addr_temp(bit_cnt-1);  --write address/command bit to bus
				state <= reg;               --continue with command
			END IF;
			
		--------------------
        WHEN slv_ack_reg =>                    --slave acknowledge bit (register)
		--------------------
          	busy <= '1';
			
			
			IF(int_read_en = '0' AND int_write_en ='1') THEN         			--write command					-- Change Log Point 2
				
				if(reg_16_bit_en = '1' and reg_16_bit_en_latch = '0')then
				    sda_int <= reg_addr_temp(2*bit_cnt+1);  --write address/command bit to bus
				    reg_addr_temp <= x"00" & reg_addr_temp(15 downto 8);
				    state <= reg;                    	--go to write byte
				    reg_16_bit_en_latch <= '1';
				else
				    sda_int <= data_tx(bit_cnt);    	--write first bit of data
				    state <= wr;                    	--go to write byte
				    reg_16_bit_en_latch <= '0';
			    end if;
			ELSIF(int_read_en = '1' AND int_write_en = '0') THEN               	--read command					-- Change Log Point 3
				
		       if(reg_16_bit_en= '1' and reg_16_bit_en_latch = '0' )then
                sda_int <= reg_addr_temp(2*bit_cnt+1);  --write address/command bit to bus
                reg_addr_temp <= x"00" &reg_addr_temp(15 downto 8);
                state <= reg;                        --go to write byte
                reg_16_bit_en_latch <= '1';
               else
				sda_int <= '1';                		--
				state <= stop;						-- go to stop to end PHASE1
				temp <= phase1;
				reg_16_bit_en_latch <= '0';
			   end if;
			ELSE																								-- Change Log Point 3
				sda_int <= '1';
				scl_ena <= '0';
				state <= stop;
			END IF;
			
		--------------
        WHEN wr =>                          --write byte of transaction
		--------------
          busy <= '1';                      --resume busy if continuous mode
          IF(bit_cnt = 0) THEN              --write byte transmit finished
            sda_int <= '1';                 --release sda for slave acknowledge  --XXXXXXXXXXXXXXXXX===============XXXXXXXXXXXXXX
            bit_cnt <= 7;                   --reset bit counter for "byte" states
            state <= slv_ack2;              --go to slave acknowledge (write)
				ena_i <= '0';						-- ADDED SO THAT IT LATCHES ONLY 1 BYTE OF DATA
		  ELSE                              --next clock cycle of write state
            bit_cnt <= bit_cnt - 1;         --keep track of transaction bits
            sda_int <= data_tx(bit_cnt-1);  --write next bit to bus
            state <= wr;                    --continue writing
          END IF;
		-------------- 
        WHEN rd =>                          --read byte of transaction
		--------------
          busy <= '1';                      --resume busy if continuous mode
          IF(bit_cnt = 0) THEN              --read byte receive finished
         --   IF(ena = '1' AND rw = '1') THEN --continuing with another read
         --     sda_int <= '0';               --acknowledge the byte has been received
          --  ELSE                            --stopping or continuing with a write
            sda_int <= '1';               --send a no-acknowledge (before stop or repeated start)
          --  END IF;
            bit_cnt <= 7;                   --reset bit counter for "byte" states
            data_rd <= data_rx;             --output received data
            state <= mstr_ack;              --go to master acknowledge
			ena_i <= '0';					-- ADDED SO THAT IT LATCHES ONLY 1 BYTE OF DATA
		  ELSE                              --next clock cycle of read state
            bit_cnt <= bit_cnt - 1;         --keep track of transaction bits
            state <= rd;                    --continue reading
          END IF;
		----------------	  
        WHEN slv_ack2 =>                    --slave acknowledge bit (write)
		----------------
                        
            scl_ena <= '0';                 --disable scl
            state <= stop;                  --go to stop bit
			busy <= '1';
        
		----------------
        WHEN mstr_ack =>                    --master acknowledge bit after a read
		----------------

            scl_ena <= '0';                 --disable scl
            state <= stop;                  --go to stop bit
			busy <= '1';
			read_valid <= '1';
		  
		-------------- 
        WHEN stop =>                        -- stop bit of transaction
		--------------
			if temp = phase1 then            -- it means phase 1 of read is over
				state <= start;				-- START the second phase
				busy <= '1';
				temp <= phase2;				-- in second phase TEMP = phase2 
			else 
				state <= ready;
				busy <= '0';                      
			end if;
          
     
      END CASE; 
	  
    END IF;

    --reading from sda during scl high (falling edge of data_clk)
    IF(reset_n = '1') THEN               --reset asserted
      ack_error <= '0';
    ELSIF(data_clk'EVENT AND data_clk = '0') THEN
      CASE state IS
        WHEN start =>                    --starting new transaction
          ack_error <= '0';              --reset acknowledge error flag
        WHEN slv_ack1 =>                 --receiving slave acknowledge (command)
          ack_error <= sda OR ack_error; --set error output if no-acknowledge
		when slv_ack_reg =>
		  ack_error <= sda OR ack_error; --set error output if no-acknowledge
        WHEN rd =>                       --receiving slave data
			--sda_int <= '1';
          data_rx(bit_cnt) <= sda;       --receive current slave data bit
        WHEN slv_ack2 =>                 --receiving slave acknowledge (write)
          ack_error <= sda OR ack_error; --set error output if no-acknowledge
        WHEN OTHERS =>
          NULL;
      END CASE;
    END IF;
    
  END PROCESS;  

  --set sda output
  WITH state SELECT
    sda_ena_n <=   data_clk WHEN start, --generate start condition
              NOT data_clk WHEN stop,   --generate stop condition
              sda_int WHEN OTHERS;      --set to internal sda signal    
      
  --set scl and sda outputs
  
  -- scl <= scl_clk WHEN scl_ena = '1' ELSE 'Z';
  scl <= '0' WHEN (scl_clk = '0' and scl_ena = '1') ELSE 'Z';							-- Change Log Point 1
  sda <= '0' WHEN sda_ena_n = '0' ELSE 'Z';
----\
	  --scl_ena = '0' only when STATE = ACK and the next STATE = STOP so that the slave can send ACK set 
	  --sda_ena_n = '0' means sda = 0 WHEN
----/
END logic;