   
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
   

----------------------------------
entity MEMORY_TO_SCALER is
----------------------------------
  generic (
    ADDR_BUF0 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 0
    ADDR_BUF1 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 1
    ADDR_BUF2 : unsigned(31 downto 0);       -- Base Address for Frame Buffer Image 2
    SNAPSHOT_IMG_ADDR_BASE : unsigned(31 downto 0);
    SNAPSHOT_IMG_ADDR_OFFSET: unsigned(31 downto 0);
    SNAPSHOT_BLANK_IMG_ADDR : unsigned(31 downto 0);
    PIX_BITS  : positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS  : positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image  
    DMA_SIZE_BITS: positive:=5;
    RD_SIZE   : positive range 1 to 16 := 4  -- Read Burst Size for Memory Read Requests
  );
  port (
    -- Clock and Reset
    CLK             : in  std_logic;                              -- Module Clock
    RST             : in  std_logic;                              -- Module Reset (Asynchronous active high)
    En_Pattern      : in  std_logic;                              -- For constant data out
    -- Memory Image Info                                
    --MEM_IMG_SOI   : in  std_logic;                              -- Memory Image Picture Start 
    GALLERY_ENABLE     : in std_logic;                          -- Enable GALLERY TO DISPLAY SNAPSHOT
    GALLERY_IMG_NUMBER : in std_logic_vector(7 downto 0);               -- SNAPSHOT IMAGE COUNTER
    IMG_VALID      : in std_logic_vector(63 downto 0);
    SNAPSHOT_COUNTER : in std_logic_Vector(7 downto 0);
    
    MEM_IMG_BUF     : in  std_logic_vector( 1 downto 0);          -- Memory Image Picture Buffer
    MEM_IMG_XSIZE   : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture X Size (max 1023)
    MEM_IMG_YSIZE   : in  std_logic_vector( 9 downto 0);          -- Memory Image Picture Y Size (max 1023)
    -- DMA Master Read Interface to Memory Controller
    DMA_RDREADY     : in  std_logic;                              -- DMA Ready Request
    DMA_RDREQ       : out std_logic;                              -- DMA Read Request
    DMA_RDSIZE      : out std_logic_vector(DMA_SIZE_BITS-1 downto 0);          -- DMA Request Size
    DMA_RDADDR      : out std_logic_vector(31 downto 0);          -- DMA Master Address
    DMA_RDDAV       : in  std_logic;                              -- DMA Read Data Valid
    DMA_RDDATA      : in  std_logic_vector(31 downto 0);          -- DMA Read Data
    -- YCrCb output Flux to Scaler Module               -
    IMG_SHIFT_VERT  : in  std_logic_vector(LIN_BITS-1 downto 0);
    SCALER_RUN      : out std_logic;                              -- Scaler Run
    SCALER_REQ_V    : in  std_logic;                              -- Scaler New Frame Request
    SCALER_REQ_H    : in  std_logic;                              -- Scaler New Line Request
    SCALER_LIN_NO   : in  std_logic_vector(LIN_BITS-1 downto 0);  -- Scaler asking memory_to_scaler to send this particular line
    SCALER_PIX_OFF  : in  std_logic_vector(PIX_BITS-1 downto 0);  -- Scaler asking memory_to_scaler to start sending data from a particular pixel in the line
    SCALER_REQ_XSIZE: in std_logic_vector(PIX_BITS-1 downto 0);   -- Width of image required by scaler
    SCALER_REQ_YSIZE: in std_logic_vector(LIN_BITS-1 downto 0);   -- Height of image required by scaler
    SCALER_V        : out std_logic;                              -- Scaler New Frame
    SCALER_H        : out std_logic;
    SCALER_DAV      : out std_logic;                              -- Scaler New Data
    SCALER_DATA     : out std_logic_vector(7 downto 0);          -- Scaler Data (Y on MSBs, Cb/Cr on LSBs)
    SCALER_EOI      : out std_logic;
    SCALER_XSIZE    : out std_logic_vector( 10 downto 0);          -- Scaler X Size
    SCALER_YSIZE    : out std_logic_vector( 9 downto 0);          -- Scaler Y Size
    SCALER_XCNT     : out std_logic_vector( 10 downto 0);          -- Scaler Pix  Number (start with 0)
    SCALER_YCNT     : out std_logic_vector( 9 downto 0);          -- Scaler Line Number (start with 0)
    SCALER_FIFO_EMP : out std_logic
--    DMA_ADDR_IMG_OUT   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
----------------------------------
end entity MEMORY_TO_SCALER;
----------------------------------


------------------------------------------
architecture RTL of MEMORY_TO_SCALER is
------------------------------------------
  signal En_Pattern_d : std_logic;
  type DMA_RDFSM_t is ( s_IDLE, s_WAIT_H, s_GET_ADDR, s_READ );
  signal DMA_RDFSM : DMA_RDFSM_t;
  signal DMA_ADDR_PIX  : unsigned(PIX_BITS+1 downto 0);  -- PIX_BITS for a line, 
  --signal DMA_ADDR_LIN  : unsigned(LIN_BITS-1 downto 0);  -- 9bits for 511 lines
  signal DMA_ADDR_PICT : unsigned(LIN_BITS+DMA_ADDR_PIX'length downto 0);
  signal DMA_ADDR_IMG  : unsigned(MEM_IMG_BUF'range);
  signal DMA_ADDR_BASE : unsigned(DMA_RDADDR'range);
  signal RUN        : std_logic;
  signal ADDR_SEL   : std_logic;
  signal ADDR_Hr    : unsigned(MEM_IMG_BUF'range);

  -- FIFO Signals
  constant FIFO_DEPTH : positive := 11;--10;  -- 2**FIFO_DEPTH words in the FIFO
  constant FIFO_WSIZE : positive := DMA_RDDATA'length;  
  signal FIFO_CLR     : std_logic;
  signal FIFO_WR      : std_logic;
  signal FIFO_IN      : std_logic_vector(FIFO_WSIZE-1 downto 0);
  signal FIFO_FUL     : std_logic;
  signal FIFO_NB      : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal FIFO_EMP     : std_logic;
  signal FIFO_RD      : std_logic;
  signal FIFO_OUT     : std_logic_vector(FIFO_WSIZE-1 downto 0);

  signal SCALER_XCNTi : unsigned(SCALER_XCNT'range);
  signal SCALER_YCNTi : unsigned(SCALER_YCNT'range);
  signal SCALER_DAVi  : std_logic;
  signal SCALER_SEL   : std_logic_vector(1 downto 0);
  Signal SNAPSHOT_IMG_ADDR : unsigned(31 downto 0);


--------
begin
--------
--DMA_ADDR_IMG_OUT <= STD_LOGIC_VECTOR (DMA_ADDR_IMG);
  -- ---------------------------------
  --  DMA Master Read Process
  -- ---------------------------------
  process(CLK, RST)
    variable vDMA_ADDR_IMG : unsigned(DMA_ADDR_IMG'range);
  begin
    if RST = '1' then
      RUN           <= '0';
      ADDR_SEL      <= '0';
      ADDR_Hr       <= (others => '0');
      DMA_RDREQ     <= '0';
      DMA_ADDR_PIX  <= (others => '0');
      --DMA_ADDR_LIN  <= (others => '0');
      DMA_ADDR_PICT <= (others => '0');
      DMA_ADDR_IMG  <= (others => '0');
      DMA_RDFSM     <= s_IDLE;
      SNAPSHOT_IMG_ADDR <= (others => '0');

    elsif rising_edge(CLK) then

      -- DMA WRITE module starts writing at buffer 0
      -- Wait that at least 1 valid frame has been written in memory before starting
      if unsigned(MEM_IMG_BUF) > 1 then
--      if unsigned(MEM_IMG_BUF) = 0 then
        RUN <= '1';  -- internal run
      end if;

      case DMA_RDFSM is         

        -- Wait for New Frame Flag to arrive here
        -- (see Synchronous Clear below this FSM)
        when s_IDLE =>
            DMA_ADDR_PIX <= (others => '0');
            --DMA_ADDR_LIN <= (others => '0');
            -- Compute the Buffer where to Read the new image
            -- Compute corresponding SRAM Base Address
            if GALLERY_ENABLE = '0' then
                if ADDR_SEL = '0' then
                  if unsigned(MEM_IMG_BUF) = 0 then
                    vDMA_ADDR_IMG := to_unsigned(2, vDMA_ADDR_IMG'length);
                  else
                    vDMA_ADDR_IMG := unsigned(MEM_IMG_BUF) - 1;
                  end if;
                  DMA_ADDR_IMG <= vDMA_ADDR_IMG;
                  -- Remember starting Address for next half frame (weave 30Hz)
                  ADDR_Hr      <= vDMA_ADDR_IMG;
                else
                  DMA_ADDR_IMG <= ADDR_Hr;
                end if;
             else
                 DMA_ADDR_IMG <= to_unsigned(3, vDMA_ADDR_IMG'length);
             end if;   
--             if(IMG_VALID(to_integer(unsigned(GALLERY_IMG_NUMBER) -1)) = '1')then
             if(GALLERY_IMG_NUMBER <= SNAPSHOT_COUNTER)then             
                SNAPSHOT_IMG_ADDR <= resize(SNAPSHOT_IMG_ADDR_BASE+ ((unsigned(GALLERY_IMG_NUMBER)-1)* SNAPSHOT_IMG_ADDR_OFFSET),SNAPSHOT_IMG_ADDR'length); 
             else
                SNAPSHOT_IMG_ADDR <= SNAPSHOT_BLANK_IMG_ADDR;
             end if;
             DMA_RDFSM <= s_WAIT_H;

        -- Waiting for Scaler Request    
        when s_WAIT_H =>
            if SCALER_REQ_H = '1' then
              -- Compute next line start address : (Xsize/2) * Line_Counter
              DMA_ADDR_PICT <= unsigned("000" & MEM_IMG_XSIZE(9 downto 0))*unsigned(SCALER_LIN_NO) + resize(unsigned(SCALER_PIX_OFF), DMA_ADDR_PICT'length);
              DMA_RDFSM <= s_GET_ADDR;
            end if;

        -- Do Read at Computed Address    
        when s_GET_ADDR =>
            DMA_RDREQ <= '1' and not En_Pattern_d;  -- initiate the read
            DMA_RDFSM <= s_READ;

        -- Make Read requests from SRAM memory
        when s_READ =>
           
            if DMA_RDREADY = '1' then -- Read Accepted
              DMA_ADDR_PICT <= DMA_ADDR_PICT + RD_SIZE*4;
              if DMA_ADDR_PIX+RD_SIZE*4 >= unsigned(SCALER_REQ_XSIZE(PIX_BITS-1 downto 0)) then -- End of Reading this line              
                DMA_RDREQ    <= '0';
                DMA_ADDR_PIX <= (others => '0');
                --DMA_ADDR_LIN <= DMA_ADDR_LIN + 1; -- will read next line
                DMA_RDFSM    <= s_WAIT_H;
              else
                DMA_RDFSM <= s_READ;
                DMA_RDREQ <= '1' and not En_Pattern_d;
                DMA_ADDR_PIX  <= DMA_ADDR_PIX  + RD_SIZE*4;
                end if;
            else
              DMA_RDREQ <= '1' and not En_Pattern_d;
              DMA_ADDR_PICT<=DMA_ADDR_PICT;
              DMA_RDFSM <= s_READ;
            end if;

        end case;

      -- Base Address Computation for Frame Buffers
      case to_integer(DMA_ADDR_IMG) is
        when 0 => DMA_ADDR_BASE <= ADDR_BUF0;
        when 1 => DMA_ADDR_BASE <= ADDR_BUF1;
        when 2 => DMA_ADDR_BASE <= ADDR_BUF2;
        when 3 => DMA_ADDR_BASE <= SNAPSHOT_IMG_ADDR;
        when others => null;
      end case;      
      
      if En_Pattern ='1' then
        En_Pattern_d <= '1';
      end if;
      
      -- Reset FSM on new frame request
      if SCALER_REQ_V = '1' and RUN = '1' then
        --ADDR_SEL  <= not ADDR_SEL;  -- to decide which next half frame to read
        DMA_RDFSM <= s_IDLE;
        if En_Pattern = '0' and En_Pattern_d= '1' then
            En_Pattern_d <= '0';
        end if;
      end if;

    end if;
  end process;


  -- -----------------------
  --  DMA Write Outputs
  -- -----------------------
  DMA_RDADDR <= std_logic_vector(DMA_ADDR_BASE + DMA_ADDR_PICT) ;
  DMA_RDSIZE <= std_logic_vector(to_unsigned(RD_SIZE, DMA_RDSIZE'length));


 
  FIFO_WR  <= DMA_RDDAV;
  FIFO_IN  <= DMA_RDDATA;
  FIFO_CLR <= SCALER_REQ_V;

  -- FIFO to store data 
  i_DMA_RDFIFO : entity WORK.FIFO_GENERIC_SC
    generic map (
      FIFO_DEPTH => FIFO_DEPTH,
      FIFO_WIDTH => FIFO_WSIZE,
      SHOW_AHEAD => true      ,
      USE_EAB    => true
    )
    port map (
      CLK    => CLK     ,
      RST    => RST     ,
      CLR    => FIFO_CLR,
      WRREQ  => FIFO_WR ,
      WRDATA => FIFO_IN ,
      FULL   => FIFO_FUL,
      USEDW  => FIFO_NB ,
      EMPTY  => FIFO_EMP,
      RDREQ  => FIFO_RD ,
      RDDATA => FIFO_OUT
    ); 
      
  
  assert not ( FIFO_FUL = '1' and FIFO_WR = '1' )
    report "[MEMORY_TO_SCALER] WRITE in FIFO Full !!!" severity failure;

  --FIFO_RD <= not FIFO_EMP and SCALER_SEL;

  -- -----------------------------
  --  Scaler Image Outputs
  -- -----------------------------
  process(CLK, RST)
  begin
    if RST = '1' then
      SCALER_V     <= '0';
      SCALER_SEL   <= (others => '0');
      SCALER_DAVi  <= '0';
    FIFO_RD   <= '0';
      SCALER_DATA  <= (others => '0');
      SCALER_XCNTi <= (others => '0');
      SCALER_YCNTi <= (others => '0');
      SCALER_H    <= '0';
      SCALER_EOI <= '0';
    elsif rising_edge(CLK) then
     FIFO_RD <= '0';
      SCALER_V <= '0'; 
      SCALER_H <= '0';
      SCALER_EOI <= '0';
      if SCALER_REQ_V = '1' then
        SCALER_V     <= '1'; 
        SCALER_YCNTi <= (others => '1'); -- first line will be number 0
        
      end if;

      if SCALER_REQ_H = '1' then
        SCALER_H <= '1';
        
      end if;
      
      -- Output Pixels
      SCALER_DAVi  <= '0';
      
     if En_Pattern_d = '1' then
         if(SCALER_XCNTi < (unsigned(SCALER_REQ_XSIZE) -1)) then
               SCALER_DAVi  <= '1';
               SCALER_DATA <= x"80";
         else
               SCALER_DAVi  <= '0';
               SCALER_DATA <= x"00";      
         end if;
   -- if FIFO_EMP = '0' and FIFO_RD = '0' then 
     elsif FIFO_EMP = '0' and SCALER_SEL = "00" and FIFO_RD = '0' then
    
    --if SCALER_SEL = "00" then
      SCALER_SEL  <= "01";
      SCALER_DAVi <= '1';
      if En_Pattern = '1' then
        SCALER_DATA <= x"80";  
      else
--        if(SCALER_YCNTi <= unsigned(IMG_SHIFT_VERT))then 
        if(unsigned(SCALER_LIN_NO) < unsigned(IMG_SHIFT_VERT))then 
            SCALER_DATA <=  x"10"; 
        else 
            SCALER_DATA <= FIFO_OUT(7 downto 0); 
        end if;
--        SCALER_DATA <= FIFO_OUT(7 downto 0); -- Y only, Cr/Cb always 0's
      end if;
    elsif SCALER_SEL = "01" then
      SCALER_SEL  <= "10";
      SCALER_DAVi <= '1';
      --FIFO_RD <= '1';
      if En_Pattern = '1' then
        SCALER_DATA <= x"80";  
      else
--        if(SCALER_YCNTi <= unsigned(IMG_SHIFT_VERT))then
        if(unsigned(SCALER_LIN_NO) < unsigned(IMG_SHIFT_VERT))then
            SCALER_DATA <=  x"10"; 
        else 
            SCALER_DATA <= FIFO_OUT(15 downto 8); 
        end if;
--        SCALER_DATA <= FIFO_OUT(15 downto 8) ;
      end if;
    elsif SCALER_SEL = "10" then
      SCALER_SEL  <= "11";
      SCALER_DAVi <= '1';
      if En_Pattern = '1' then
        SCALER_DATA <= x"80";  
      else
--        if(SCALER_YCNTi <= unsigned(IMG_SHIFT_VERT))then
        if(unsigned(SCALER_LIN_NO) < unsigned(IMG_SHIFT_VERT))then
            SCALER_DATA <=  x"10"; 
        else 
            SCALER_DATA <= FIFO_OUT(23 downto 16); 
        end if;
--        SCALER_DATA <= FIFO_OUT(23 downto 16) ;
      end if;
    elsif SCALER_SEL = "11" then
      SCALER_SEL  <= "00";
      SCALER_DAVi <= '1';
      FIFO_RD <= '1';
      if En_Pattern = '1' then
        SCALER_DATA <= x"80";  
      else
--        if(SCALER_YCNTi <= unsigned(IMG_SHIFT_VERT))then
      if(unsigned(SCALER_LIN_NO) < unsigned(IMG_SHIFT_VERT))then
            SCALER_DATA <=  x"10"; 
        else 
            SCALER_DATA <= FIFO_OUT(31 downto 24); 
        end if;
--        SCALER_DATA <= FIFO_OUT(31 downto 24) ;
      end if;
    end if;
  --end if;
      
      -- Source Pixels Counter
      if SCALER_REQ_H = '1' then
        SCALER_SEL   <= "00";
        SCALER_YCNTi <= SCALER_YCNTi + 1;  
        SCALER_XCNTi <= (others => '0');
      elsif SCALER_DAVi = '1' then
        SCALER_XCNTi <= SCALER_XCNTi + 1;
      end if;
      
      if((SCALER_YCNTi = unsigned(SCALER_REQ_YSIZE)-1 )and(SCALER_XCNTi = unsigned(SCALER_REQ_XSIZE)))then
        SCALER_EOI <= '1';
      end if;
      
    end if;
  end process;

  SCALER_RUN   <= RUN;
  SCALER_DAV   <= SCALER_DAVi;
  SCALER_XSIZE <= '0' &MEM_IMG_XSIZE;
  SCALER_YSIZE <= MEM_IMG_YSIZE;
  SCALER_XCNT  <= std_logic_vector(SCALER_XCNTi);
  SCALER_YCNT  <= std_logic_vector(SCALER_YCNTi);
  SCALER_FIFO_EMP <= FIFO_EMP;

--------------------------
end architecture RTL;
--------------------------
