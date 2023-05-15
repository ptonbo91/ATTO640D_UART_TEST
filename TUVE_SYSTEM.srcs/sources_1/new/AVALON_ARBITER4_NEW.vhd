-- THIS CODE Is CONFIDENTIAL AND CANNOT BE block
----------------------------------------------------------------
-- Copyright     : ALSE - http://alse-fr.com
-- Contact       : info@alse-fr.com
-- Block Name    : AVALON_ARBITER4
-- Description   : Arbiter between four Avalon-MM Masters
-- Auteur        : E.LAURENDEAU
-- Date          : June 2012
-- Version       : 2012.06
----------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

Library xpm;
use xpm.vcomponents.all;         
-------------------------------
entity AVALON_ARBITER4_NEW is
-------------------------------
  generic (
     ADDR_WIDTH  : positive := 22;
     DATA_WIDTH  : positive := 32;
     BURST_WIDTH  : positive :=  5
  );
  port (
    
    SEL_OLED_ANALOG_VIDEO_OUT : in std_logic;
    -- Avalon-MM Master 0 - Write Only
    DMA_W0_CLK     : in std_logic;
    DMA_W0_RST     : in std_logic;
    DMA_W0_READY   : out std_logic;                                    -- DMA_W0 Ready
    DMA_W0_WRITE   : in  std_logic;                                    -- DMA_W0 Write   Request
    DMA_W0_WRBURST : in  std_logic;                                    -- DMA_W0 Write   Request Start of Burst
    DMA_W0_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_W0 Address Request
    DMA_W0_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_W0 Size    Request
    DMA_W0_WRDATA  : in  std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_W0 Write Data
    --DMA_W0_ADDR_DEC: in  std_logic;                                    -- DMA_W0 ADDR DECREMENT
    DMA_W0_WRBE    : in  std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA_W0 Write Byte Enable
    -- Avalon-MM Master 1 - Write Only
    DMA_W1_CLK     : in std_logic;
    DMA_W1_RST     : in std_logic;
    DMA_W1_READY   : out std_logic;                                    -- DMA_W1 Ready
    DMA_W1_WRITE   : in  std_logic;                                    -- DMA_W1 Write   Request
    DMA_W1_WRBURST : in  std_logic;                                    -- DMA_W1 Write   Request Start of Burst
    DMA_W1_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_W1 Address Request
    DMA_W1_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_W1 Size    Request
    DMA_W1_WRDATA  : in  std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_W1 Write Data
    DMA_W1_WRBE    : in  std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA_W1 Write Byte Enable
    -- Avalon-MM Master 2 - Write Only
    DMA_W2_CLK     : in std_logic;
    DMA_W2_RST     : in std_logic;
    DMA_W2_READY   : out std_logic;                                    -- DMA_W2 Ready
    DMA_W2_WRITE   : in  std_logic;                                    -- DMA_W2 Write   Request
    DMA_W2_WRBURST : in  std_logic;                                    -- DMA_W2 Write   Request Start of Burst
    DMA_W2_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_W2 Address Request
    DMA_W2_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_W2 Size    Request
    DMA_W2_WRDATA  : in  std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_W2 Write Data
    DMA_W2_WRBE    : in  std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA_W2 Write Byte Enable

    -- Avalon-MM Master 0 - Read Only
    DMA_R0_CLK     : in std_logic;
    DMA_R0_RST     : in std_logic;
    DMA_R0_READY   : out std_logic;                                    -- DMA_R0 Ready
    DMA_R0_READ    : in  std_logic;                                    -- DMA_R0 Read    Request
    DMA_R0_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_R0 Address Request
    DMA_R0_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_R0 Size    Request
    DMA_R0_RDDAV   : out std_logic;                                    -- DMA_R0 Read Data Valid
    DMA_R0_RDDATA  : out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_R0 Read Data
    -- Avalon-MM Master 1 - Read Only
    DMA_R1_CLK     : in std_logic;
    DMA_R1_RST     : in std_logic;
    DMA_R1_READY   : out std_logic;                                    -- DMA_R1 Ready
    DMA_R1_READ    : in  std_logic;                                    -- DMA_R1 Read    Request
    DMA_R1_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_R1 Address Request
    DMA_R1_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_R1 Size    Request
    DMA_R1_RDDAV   : out std_logic;                                    -- DMA_R1 Read Data Valid
    DMA_R1_RDDATA  : out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_R1 Read Data
    -- Avalon-MM Master 2 - Read Only
    DMA_R2_CLK     : in std_logic;
    DMA_R2_RST     : in std_logic;
    DMA_R2_READY   : out std_logic;                                    -- DMA_R2 Ready
    DMA_R2_READ    : in  std_logic;                                    -- DMA_R2 Read    Request
    DMA_R2_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_R2 Address Request
    DMA_R2_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_R2 Size    Request
    DMA_R2_RDDAV   : out std_logic;                                    -- DMA_R2 Read Data Valid
    DMA_R2_RDDATA  : out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_R2 Read Data
    -- Avalon-MM Master 3 - Read Only
    DMA_R3_CLK     : in std_logic;
    DMA_R3_RST     : in std_logic;
    DMA_R3_READY   : out std_logic;                                    -- DMA_R2 Ready
    DMA_R3_READ    : in  std_logic;                                    -- DMA_R2 Read    Request
    DMA_R3_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_R2 Address Request
    DMA_R3_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_R2 Size    Request
    DMA_R3_RDDAV   : out std_logic;                                    -- DMA_R2 Read Data Valid
    DMA_R3_RDDATA  : out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_R2 Read Data


    -- Avalon-MM Master 4 - Read Only
    DMA_R4_CLK     : in std_logic;
    DMA_R4_RST     : in std_logic;
    DMA_R4_READY   : out std_logic;                                    -- DMA_R1 Ready
    DMA_R4_READ    : in  std_logic;                                    -- DMA_R1 Read    Request
    DMA_R4_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_R1 Address Request
    DMA_R4_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_R1 Size    Request
    DMA_R4_RDDAV   : out std_logic;                                    -- DMA_R1 Read Data Valid
    DMA_R4_RDDATA  : out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_R1 Read Data



    -- Avalon-MM Master 5 - Read Only
    DMA_R5_CLK     : in std_logic;
    DMA_R5_RST     : in std_logic;
    DMA_R5_READY   : out std_logic;                                    -- DMA_R1 Ready
    DMA_R5_READ    : in  std_logic;                                    -- DMA_R1 Read    Request
    DMA_R5_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_R1 Address Request
    DMA_R5_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_R1 Size    Request
    DMA_R5_RDDAV   : out std_logic;                                    -- DMA_R1 Read Data Valid
    DMA_R5_RDDATA  : out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_R1 Read Data

    -- Avalon-MM Master 6 - Read and Write, (Lowest priority channel)
    DMA_RW6_CLK     : in std_logic;
    DMA_RW6_RST     : in std_logic;
    DMA_RW6_READY   : out std_logic;                                    -- DMA_R1 Ready
    DMA_RW6_READ    : in  std_logic;                                    -- DMA_R1 Read    Request
    DMA_RW6_WRITE   : in  std_logic;
    DMA_RW6_WRBURST : in  std_logic;
    DMA_RW6_WRDATA  : in std_logic_vector(DATA_WIDTH-1 downto 0);      
    DMA_RW6_WRBE    : in  std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA_W2 Write Byte Enable
    DMA_RW6_ADDR    : in  std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA_R1 Address Request
    DMA_RW6_SIZE    : in  std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA_R1 Size    Request
    DMA_RW6_RDDAV   : out std_logic;                                    -- DMA_R1 Read Data Valid
    DMA_RW6_RDDATA  : out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA_R1 Read Data


    -- Avalon-MM Arbiter Output
    DMA_CLK    : in std_logic;
    DMA_RST    : in std_logic;
    DMA_WRITE    : out std_logic;                                    -- DMA  Write   Request
    DMA_WRBURST  : out std_logic;                                    -- DMA  Write   Request Start of Burst
    DMA_READ     : out std_logic;                                    -- DMA  Read    Request
    DMA_ADDR     : out std_logic_vector( ADDR_WIDTH  -1 downto 0);   -- DMA  Address Request
    DMA_SIZE     : out std_logic_vector(BURST_WIDTH  -1 downto 0);   -- DMA  Size    Request
    DMA_WRDATA   : out std_logic_vector( DATA_WIDTH  -1 downto 0);   -- DMA  Write Data
    --DMA_ADDR_DEC : out std_logic;                                    -- DMA  ADDR DECREMENT
    DMA_WRBE     : out std_logic_vector( DATA_WIDTH/8-1 downto 0);   -- DMA  Write Byte Enable
    DMA_READY    : in  std_logic;                                    -- DMA  Ready
    DMA_RDDAV    : in  std_logic;                                    -- DMA  Read Data Valid
    DMA_RDDATA   : in  std_logic_vector( DATA_WIDTH  -1 downto 0)    -- DMA  Read Data
  );
-------------------------------
end entity AVALON_ARBITER4_NEW;
-------------------------------


-----------------------------------------
architecture RTL of AVALON_ARBITER4_NEW is
-----------------------------------------

COMPONENT TOII_TUVE_ila

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

signal probe0 : std_logic_vector(127 downto 0);
  --type   ARBITER_FSM_t is (s_DMA_W0, s_DMA_W1, s_DMA_W2, s_DMA_R0, s_DMA_R1, s_DMA_R2,s_DMA_R3);
  --signal ARBITER_FSM   : ARBITER_FSM_t;
  --

  ----------------------------------------------------------------
--The following function calculates ceil(log2(x))
function ceil_log2(input:positive) return integer is
  variable temp,log:integer;
  begin
    temp:=input;
      log:=0;
      while (temp /= 0) loop
        temp:=temp/2;
        log:=log+1;
      end loop;
   return log;
end function ceil_log2;
------------------------------------------------------------------

  signal DMA_W0_READY_i  : std_logic;
  signal DMA_W1_READY_i  : std_logic;
  signal DMA_W2_READY_i  : std_logic;

  signal DMA_R0_READY_i  : std_logic;
  signal DMA_R1_READY_i  : std_logic;
  signal DMA_R2_READY_i  : std_logic;
  signal DMA_R3_READY_i  : std_logic;
  signal DMA_R4_READY_i  : std_logic;
  signal DMA_R5_READY_i  : std_logic;

  signal DMA_RW6_READY_i : std_logic;
  --

  constant DMA_WR_FIFO_DEPTH: positive:= BURST_WIDTH;
  constant DMA_WR_FIFO_WIDTH: positive:= DATA_WIDTH;

  constant DMA_WR_FIFO_CMD_DEPTH: positive:=4;
  constant DMA_WR_FIFO_CMD_WIDTH: positive:= (DMA_W0_ADDR'length + DMA_W0_SIZE'length + DMA_W0_WRBE'length);

  signal DMA_W0_FIFO_RD_CMD: std_logic;
  signal DMA_W0_FIFO_ADDR: std_logic_vector(DMA_W0_ADDR'range);
  signal DMA_W0_EMPTY_RD_CMD: std_logic;
  signal DMA_W0_FIFO_CNT_CMD: std_logic_vector(DMA_WR_FIFO_CMD_DEPTH downto 0);
  signal DMA_W0_FIFO_SIZE: std_logic_vector(DMA_W0_SIZE'range);
  signal DMA_W0_FIFO_WRBE: std_logic_vector(DMA_W0_WRBE'range);

  signal DMA_W0_FIFO_CMD_WR: std_logic;
  signal DMA_W0_FIFO_CMD_IN: std_logic_vector(DMA_W0_ADDR'length+DMA_W0_SIZE'length+DMA_W0_WRBE'length -1 downto 0);
  signal DMA_W0_FIFO_CMD_OUT: std_logic_vector(DMA_W0_FIFO_CMD_IN'range);


  signal DMA_W0_FIFO_RD: std_logic;
  signal DMA_W0_FIFO_OUT: std_logic_vector(DMA_WR_FIFO_WIDTH-1 downto 0);
  signal DMA_W0_EMPTY_RD: std_logic;
  signal DMA_W0_FIFO_CNT: std_logic_vector(DMA_WR_FIFO_DEPTH downto 0);


  signal DMA_W1_FIFO_RD_CMD: std_logic;
  signal DMA_W1_FIFO_ADDR: std_logic_vector(DMA_W1_ADDR'range);
  signal DMA_W1_EMPTY_RD_CMD: std_logic;
  signal DMA_W1_FIFO_CNT_CMD: std_logic_vector(DMA_WR_FIFO_CMD_DEPTH downto 0);
  signal DMA_W1_FIFO_SIZE: std_logic_vector(DMA_W1_SIZE'range);
  signal DMA_W1_FIFO_WRBE: std_logic_vector(DMA_W1_WRBE'range);

  signal DMA_W1_FIFO_CMD_WR: std_logic;
  signal DMA_W1_FIFO_CMD_IN: std_logic_vector(DMA_W1_ADDR'length+DMA_W1_SIZE'length+DMA_W1_WRBE'length -1 downto 0);
  signal DMA_W1_FIFO_CMD_OUT: std_logic_vector(DMA_W1_FIFO_CMD_IN'range);

  signal DMA_W1_FIFO_RD: std_logic;
  signal DMA_W1_FIFO_OUT: std_logic_vector(DMA_WR_FIFO_WIDTH-1 downto 0);
  signal DMA_W1_EMPTY_RD: std_logic;
  signal DMA_W1_FIFO_CNT: std_logic_vector(DMA_WR_FIFO_DEPTH downto 0);


  signal DMA_W2_FIFO_RD_CMD: std_logic;
  signal DMA_W2_FIFO_ADDR: std_logic_vector(DMA_W2_ADDR'range);
  signal DMA_W2_EMPTY_RD_CMD: std_logic;
  signal DMA_W2_FIFO_CNT_CMD: std_logic_vector(DMA_WR_FIFO_CMD_DEPTH downto 0);
  signal DMA_W2_FIFO_SIZE: std_logic_vector(DMA_W2_SIZE'range);
  signal DMA_W2_FIFO_WRBE: std_logic_vector(DMA_W2_WRBE'range);

  signal DMA_W2_FIFO_CMD_WR: std_logic;
  signal DMA_W2_FIFO_CMD_IN: std_logic_vector(DMA_W2_ADDR'length+DMA_W2_SIZE'length+DMA_W2_WRBE'length -1 downto 0);
  signal DMA_W2_FIFO_CMD_OUT: std_logic_vector(DMA_W2_FIFO_CMD_IN'range);

  signal DMA_W2_FIFO_RD: std_logic;
  signal DMA_W2_FIFO_OUT: std_logic_vector(DMA_WR_FIFO_WIDTH-1 downto 0);
  signal DMA_W2_EMPTY_RD: std_logic;
  signal DMA_W2_FIFO_CNT: std_logic_vector(DMA_WR_FIFO_DEPTH downto 0);

  signal DMA_RW6_WRFIFO_RD: std_logic;
  signal DMA_RW6_WRFIFO_OUT: std_logic_vector(DMA_WR_FIFO_WIDTH-1 downto 0);
  signal DMA_RW6_WREMPTY_RD: std_logic;
  signal DMA_RW6_WRFIFO_CNT: std_logic_vector(DMA_WR_FIFO_DEPTH downto 0);

  signal DMA_W0_TRNSCN: std_logic_vector(1 downto 0);
  signal DMA_W1_TRNSCN: std_logic_vector(1 downto 0);
  signal DMA_W2_TRNSCN: std_logic_vector(1 downto 0);

  signal DMA_W0_TRNSCN_M: std_logic_vector(DMA_W0_TRNSCN'range);
  signal DMA_W1_TRNSCN_M: std_logic_vector(DMA_W1_TRNSCN'range);
  signal DMA_W2_TRNSCN_M: std_logic_vector(DMA_W2_TRNSCN'range);

  signal DMA_W0_FIFO_WR : std_logic;
  signal DMA_W1_FIFO_WR : std_logic;
  signal DMA_W2_FIFO_WR : std_logic;

  signal DMA_RW6_WRFIFO_WR: std_logic;



  constant DMA_RD_FIFO_CMD_DEPTH: positive:=4;
  constant DMA_RD_FIFO_CMD_WIDTH: positive:= (DMA_R0_ADDR'length + DMA_R0_SIZE'length);

  signal DMA_R0_FIFO_RD_CMD: std_logic;
  signal DMA_R1_FIFO_RD_CMD: std_logic;
  signal DMA_R2_FIFO_RD_CMD: std_logic;
  signal DMA_R3_FIFO_RD_CMD: std_logic;
  signal DMA_R4_FIFO_RD_CMD: std_logic;
  signal DMA_R5_FIFO_RD_CMD: std_logic;

  signal DMA_RW6_FIFO_RD_CMD: std_logic;

  signal DMA_R0_EMPTY_RD_CMD: std_logic;
  signal DMA_R1_EMPTY_RD_CMD: std_logic;
  signal DMA_R2_EMPTY_RD_CMD: std_logic;
  signal DMA_R3_EMPTY_RD_CMD: std_logic;
  signal DMA_R4_EMPTY_RD_CMD: std_logic;
  signal DMA_R5_EMPTY_RD_CMD: std_logic;

  signal DMA_RW6_EMPTY_RD_CMD: std_logic;

  signal DMA_R0_FIFO_ADDR: std_logic_vector(DMA_R0_ADDR'range);
  signal DMA_R1_FIFO_ADDR: std_logic_vector(DMA_R1_ADDR'range);
  signal DMA_R2_FIFO_ADDR: std_logic_vector(DMA_R2_ADDR'range);
  signal DMA_R3_FIFO_ADDR: std_logic_vector(DMA_R3_ADDR'range);
  signal DMA_R4_FIFO_ADDR: std_logic_vector(DMA_R4_ADDR'range);
  signal DMA_R5_FIFO_ADDR: std_logic_vector(DMA_R5_ADDR'range);

  --signal DMA_RW6_FIFO_ADDR: std_logic_vector(DMA_RW6_ADDR'range);

  signal DMA_R0_FIFO_SIZE: std_logic_vector(DMA_R0_SIZE'range);
  signal DMA_R1_FIFO_SIZE: std_logic_vector(DMA_R1_SIZE'range);
  signal DMA_R2_FIFO_SIZE: std_logic_vector(DMA_R2_SIZE'range);
  signal DMA_R3_FIFO_SIZE: std_logic_vector(DMA_R3_SIZE'range);
  signal DMA_R4_FIFO_SIZE: std_logic_vector(DMA_R4_SIZE'range);
  signal DMA_R5_FIFO_SIZE: std_logic_vector(DMA_R5_SIZE'range);

  signal DMA_RW6_RDFIFO_SIZE: std_logic_vector(DMA_RW6_SIZE'range);

  signal DMA_R0_FIFO_CNT_CMD: std_logic_vector(DMA_RD_FIFO_CMD_DEPTH downto 0);
  signal DMA_R1_FIFO_CNT_CMD: std_logic_vector(DMA_RD_FIFO_CMD_DEPTH downto 0);
  signal DMA_R2_FIFO_CNT_CMD: std_logic_vector(DMA_RD_FIFO_CMD_DEPTH downto 0);
  signal DMA_R3_FIFO_CNT_CMD: std_logic_vector(DMA_RD_FIFO_CMD_DEPTH downto 0);
  signal DMA_R4_FIFO_CNT_CMD: std_logic_vector(DMA_RD_FIFO_CMD_DEPTH downto 0);
  signal DMA_R5_FIFO_CNT_CMD: std_logic_vector(DMA_RD_FIFO_CMD_DEPTH downto 0);

  signal DMA_RW6_FIFO_CNT_CMD: std_logic_vector(DMA_RD_FIFO_CMD_DEPTH downto 0);
  
  constant RD_MAX_REQ: positive:= 2;
  constant REQ_WIDTH: positive:= ceil_log2(RD_MAX_REQ);
  
  constant DMA_RD_FIFO_DEPTH: positive:=BURST_WIDTH+REQ_WIDTH;
  constant DMA_RD_FIFO_WIDTH: positive:= DATA_WIDTH;

  signal DMA_R0_EN : std_logic;
  signal DMA_R1_EN : std_logic;
  signal DMA_R2_EN : std_logic;
  signal DMA_R3_EN : std_logic;
  signal DMA_R4_EN : std_logic;
  signal DMA_R5_EN : std_logic;

  signal DMA_RW6_EN : std_logic;

  signal DMA_R0_FIFO_RD: std_logic;    
  signal DMA_R1_FIFO_RD: std_logic;
  signal DMA_R2_FIFO_RD: std_logic;
  signal DMA_R3_FIFO_RD: std_logic;
  signal DMA_R4_FIFO_RD: std_logic;
  signal DMA_R5_FIFO_RD: std_logic;

  signal DMA_RW6_RDFIFO_RD: std_logic;

  signal DMA_R0_FIFO_OUT: std_logic_vector(DMA_RD_FIFO_WIDTH-1 downto 0);
  signal DMA_R1_FIFO_OUT: std_logic_vector(DMA_RD_FIFO_WIDTH-1 downto 0);
  signal DMA_R2_FIFO_OUT: std_logic_vector(DMA_RD_FIFO_WIDTH-1 downto 0);
  signal DMA_R3_FIFO_OUT: std_logic_vector(DMA_RD_FIFO_WIDTH-1 downto 0);
  signal DMA_R4_FIFO_OUT: std_logic_vector(DMA_RD_FIFO_WIDTH-1 downto 0);
  signal DMA_R5_FIFO_OUT: std_logic_vector(DMA_RD_FIFO_WIDTH-1 downto 0);

  signal DMA_RW6_RDFIFO_OUT: std_logic_vector(DMA_RD_FIFO_WIDTH-1 downto 0);

  signal DMA_R0_EMPTY_RD: std_logic;
  signal DMA_R1_EMPTY_RD: std_logic;
  signal DMA_R2_EMPTY_RD: std_logic;
  signal DMA_R3_EMPTY_RD: std_logic;
  signal DMA_R4_EMPTY_RD: std_logic;
  signal DMA_R5_EMPTY_RD: std_logic;

  signal DMA_RW6_RDEMPTY_RD: std_logic;

  signal DMA_R0_FIFO_CNT_WR: std_logic_vector(DMA_RD_FIFO_DEPTH downto 0);

  signal DMA_R0_FIFO_CNT: std_logic_vector(DMA_RD_FIFO_DEPTH downto 0);
  signal DMA_R1_FIFO_CNT: std_logic_vector(DMA_RD_FIFO_DEPTH downto 0);
  signal DMA_R2_FIFO_CNT: std_logic_vector(DMA_RD_FIFO_DEPTH downto 0);
  signal DMA_R3_FIFO_CNT: std_logic_vector(DMA_RD_FIFO_DEPTH downto 0);
  signal DMA_R4_FIFO_CNT: std_logic_vector(DMA_RD_FIFO_DEPTH downto 0);
  signal DMA_R5_FIFO_CNT: std_logic_vector(DMA_RD_FIFO_DEPTH downto 0);

  signal DMA_RW6_RDFIFO_CNT: std_logic_vector(DMA_RD_FIFO_DEPTH downto 0);

  signal DMA_R0_SIZEi: unsigned(DMA_R0_SIZE'length+REQ_WIDTH-1 downto 0);
  signal DMA_R1_SIZEi: unsigned(DMA_R1_SIZE'length+REQ_WIDTH-1 downto 0);
  signal DMA_R2_SIZEi: unsigned(DMA_R2_SIZE'length+REQ_WIDTH-1 downto 0);
  signal DMA_R3_SIZEi: unsigned(DMA_R3_SIZE'length+REQ_WIDTH-1 downto 0);
  signal DMA_R4_SIZEi: unsigned(DMA_R3_SIZE'length+REQ_WIDTH-1 downto 0);
  signal DMA_R5_SIZEi: unsigned(DMA_R3_SIZE'length+REQ_WIDTH-1 downto 0);

  signal DMA_RW6_SIZEi: unsigned(DMA_RW6_SIZE'length-1 downto 0);

  signal DMA_R0_REQ: unsigned(REQ_WIDTH-1 downto 0);
  signal DMA_R1_REQ: unsigned(REQ_WIDTH-1 downto 0);
  signal DMA_R2_REQ: unsigned(REQ_WIDTH-1 downto 0);
  signal DMA_R3_REQ: unsigned(REQ_WIDTH-1 downto 0);
  signal DMA_R4_REQ: unsigned(REQ_WIDTH-1 downto 0);
  signal DMA_R5_REQ: unsigned(REQ_WIDTH-1 downto 0);

  signal DMA_R0_DONE: std_logic;
  signal DMA_R1_DONE: std_logic;
  signal DMA_R2_DONE: std_logic;
  signal DMA_R3_DONE: std_logic;
  signal DMA_R4_DONE: std_logic;
  signal DMA_R5_DONE: std_logic;

  signal DMA_RW6_DONE: std_logic;

  signal DMA_R0_TRNSCN: std_logic_vector(1 downto 0);
  signal DMA_R1_TRNSCN: std_logic_vector(1 downto 0);
  signal DMA_R2_TRNSCN: std_logic_vector(1 downto 0);
  signal DMA_R3_TRNSCN: std_logic_vector(1 downto 0);
  signal DMA_R4_TRNSCN: std_logic_vector(1 downto 0);
  signal DMA_R5_TRNSCN: std_logic_vector(1 downto 0);

  signal DMA_RW6_TRNSCN: std_logic_vector(1 downto 0);


  signal DMA_R0_TRNSCN_M: std_logic_vector(DMA_R0_TRNSCN'range);
  signal DMA_R1_TRNSCN_M: std_logic_vector(DMA_R1_TRNSCN'range);
  signal DMA_R2_TRNSCN_M: std_logic_vector(DMA_R2_TRNSCN'range);
  signal DMA_R3_TRNSCN_M: std_logic_vector(DMA_R3_TRNSCN'range);
  signal DMA_R4_TRNSCN_M: std_logic_vector(DMA_R4_TRNSCN'range);
  signal DMA_R5_TRNSCN_M: std_logic_vector(DMA_R5_TRNSCN'range);

  signal DMA_RW6_TRNSCN_M: std_logic_vector(DMA_RW6_TRNSCN'range);

  signal DMA_R0_FIFO_WR: std_logic;
  signal DMA_R1_FIFO_WR: std_logic;
  signal DMA_R2_FIFO_WR: std_logic;
  signal DMA_R3_FIFO_WR: std_logic;
  signal DMA_R4_FIFO_WR: std_logic;
  signal DMA_R5_FIFO_WR: std_logic;

  signal DMA_RW6_RDFIFO_WR: std_logic;

  signal DMA_R0_FIFO_CMD_WR: std_logic;
  signal DMA_R0_FIFO_CMD_IN: std_logic_vector(DMA_R0_ADDR'length+DMA_R0_SIZE'length-1 downto 0);
  signal DMA_R0_FIFO_CMD_OUT: std_logic_vector(DMA_R0_FIFO_CMD_IN'range);

  signal DMA_R1_FIFO_CMD_WR: std_logic;
  signal DMA_R1_FIFO_CMD_IN: std_logic_vector(DMA_R1_ADDR'length+DMA_R1_SIZE'length-1 downto 0);
  signal DMA_R1_FIFO_CMD_OUT: std_logic_vector(DMA_R1_FIFO_CMD_IN'range);

  signal DMA_R2_FIFO_CMD_WR: std_logic;
  signal DMA_R2_FIFO_CMD_IN: std_logic_vector(DMA_R2_ADDR'length+DMA_R2_SIZE'length-1 downto 0);
  signal DMA_R2_FIFO_CMD_OUT: std_logic_vector(DMA_R2_FIFO_CMD_IN'range);

  signal DMA_R3_FIFO_CMD_WR: std_logic;
  signal DMA_R3_FIFO_CMD_IN: std_logic_vector(DMA_R3_ADDR'length+DMA_R3_SIZE'length-1 downto 0);
  signal DMA_R3_FIFO_CMD_OUT: std_logic_vector(DMA_R3_FIFO_CMD_IN'range);

  signal DMA_R4_FIFO_CMD_WR: std_logic;
  signal DMA_R4_FIFO_CMD_IN: std_logic_vector(DMA_R4_ADDR'length+DMA_R4_SIZE'length-1 downto 0);
  signal DMA_R4_FIFO_CMD_OUT: std_logic_vector(DMA_R4_FIFO_CMD_IN'range);

  signal DMA_R5_FIFO_CMD_WR: std_logic;
  signal DMA_R5_FIFO_CMD_IN: std_logic_vector(DMA_R5_ADDR'length+DMA_R5_SIZE'length-1 downto 0);
  signal DMA_R5_FIFO_CMD_OUT: std_logic_vector(DMA_R5_FIFO_CMD_IN'range);
  
  signal BURST_COUNT: unsigned(DMA_SIZE'range);



  signal DMA_RW6_FIFO_ADDR: std_logic_vector(DMA_RW6_ADDR'range);
  
--  signal DMA_RW6_FIFO_CNT_CMD: std_logic_vector(DMA_WR_FIFO_CMD_DEPTH downto 0);
  signal DMA_RW6_FIFO_SIZE: std_logic_vector(DMA_RW6_SIZE'range);
  signal DMA_RW6_FIFO_WRBE: std_logic_vector(DMA_RW6_WRBE'range);

  signal DMA_RW6_FIFO_WRnRD: std_logic;
  signal DMA_RW6_FIFO_CMD_WR: std_logic;
  signal DMA_RW6_FIFO_CMD_IN: std_logic_vector(DMA_RW6_ADDR'length+DMA_RW6_SIZE'length+DMA_RW6_WRBE'length+1-1 downto 0);
  signal DMA_RW6_FIFO_CMD_OUT: std_logic_vector(DMA_RW6_FIFO_CMD_IN'range);

  type DMA_STATE_t is (W0_START, W0_ST0, W0_ST1, W0_ST2, W0_WAIT, W0_DONE, 
                       W1_START, W1_ST0, W1_ST1, W1_ST2, W1_WAIT, W1_DONE,
                       W2_START, W2_ST0, W2_ST1, W2_ST2, W2_WAIT, W2_DONE,
                       R0_START, R0_ST0, R0_ST1, R0_ST2, R0_DONE, 
                       R1_START, R1_ST0, R1_ST1, R1_ST2, R1_DONE,
                       R2_START, R2_ST0, R2_ST1, R2_ST2, R2_DONE,
                       R3_START, R3_ST0, R3_ST1, R3_ST2, R3_DONE,
                       R4_START, R4_ST0, R4_ST1, R4_ST2, R4_DONE,
                       R5_START, R5_ST0, R5_ST1, R5_ST2, R5_DONE,
                       RW6_START, RW6_ST0,RW6_ST1, RW6_ST2, RW6_ST3,
                       RW6_ST4, RW6_ST5, RW6_ST6, RW6_WAIT );

  signal DMA_STATE : DMA_STATE_t;
  

  type DMA_R0_ST_t is (R0_S0, R0_S1, R0_S2);
  signal DMA_R0_ST : DMA_R0_ST_t;

  type DMA_R1_ST_t is (R1_S0, R1_S1, R1_S2);
  signal DMA_R1_ST : DMA_R1_ST_t;
  
  type DMA_R2_ST_t is (R2_S0, R2_S1, R2_S2);
  signal DMA_R2_ST : DMA_R2_ST_t;

  type DMA_R3_ST_t is (R3_S0, R3_S1, R3_S2);
  signal DMA_R3_ST : DMA_R3_ST_t;

  type DMA_R4_ST_t is (R4_S0, R4_S1, R4_S2);
  signal DMA_R4_ST : DMA_R4_ST_t;

  type DMA_R5_ST_t is (R5_S0, R5_S1, R5_S2);
  signal DMA_R5_ST : DMA_R5_ST_t;

  type RW6_READY_FSM_t is (RW6_R_IDLE, RW6_R_S1, RW6_R_S2, RW6_R_S3, RW6_R_S4);
  signal RW6_READY_FSM : RW6_READY_FSM_t;

signal DMA_WRITE_temp : std_logic;
signal DMA_WRBURST_TEMP : std_logic;


type W0_READY_FSM_t is (W0_R_IDLE, W0_R_S1, W0_R_S2);
signal W0_READY_FSM: W0_READY_FSM_t;

type W1_READY_FSM_t is (W1_R_IDLE, W1_R_S1, W1_R_S2);
signal W1_READY_FSM: W1_READY_FSM_t;

type W2_READY_FSM_t is (W2_R_IDLE, W2_R_S1, W2_R_S2);
signal W2_READY_FSM: W2_READY_FSM_t;

--signal DMA_W0_EMPTY_RD_CMD_S : std_logic;
signal DMA_W0_EMPTY_RD_S     : std_logic;
--signal DMA_W1_EMPTY_RD_CMD_S : std_logic;
signal DMA_W1_EMPTY_RD_S     : std_logic;
--signal DMA_W2_EMPTY_RD_CMD_S : std_logic;
signal DMA_W2_EMPTY_RD_S     : std_logic;

signal DMA_W0_EMPTY_RD_M     : std_logic;
signal DMA_W1_EMPTY_RD_M     : std_logic;
signal DMA_W2_EMPTY_RD_M     : std_logic;

signal DMA_RW6_EMPTY_RD_M     : std_logic;

ATTRIBUTE FSM_ENCODING : string;
ATTRIBUTE SAFE_IMPLEMENTATION : string;
attribute FSM_ENCODING        of W0_READY_FSM : signal is "sequential";
attribute SAFE_IMPLEMENTATION of W0_READY_FSM : signal is "yes";
attribute FSM_ENCODING        of W1_READY_FSM : signal is "sequential";
attribute SAFE_IMPLEMENTATION of W1_READY_FSM : signal is "yes";
attribute FSM_ENCODING        of W2_READY_FSM : signal is "sequential";
attribute SAFE_IMPLEMENTATION of W2_READY_FSM : signal is "yes";
attribute FSM_ENCODING        of DMA_R0_ST : signal is "sequential";
attribute SAFE_IMPLEMENTATION of DMA_R0_ST : signal is "yes";
attribute FSM_ENCODING        of DMA_R1_ST : signal is "sequential";
attribute SAFE_IMPLEMENTATION of DMA_R1_ST : signal is "yes";
attribute FSM_ENCODING        of DMA_R2_ST : signal is "sequential";
attribute SAFE_IMPLEMENTATION of DMA_R2_ST : signal is "yes";
attribute FSM_ENCODING        of DMA_R3_ST : signal is "sequential";
attribute SAFE_IMPLEMENTATION of DMA_R3_ST : signal is "yes";
attribute FSM_ENCODING        of DMA_R4_ST : signal is "sequential";
attribute SAFE_IMPLEMENTATION of DMA_R4_ST : signal is "yes";
attribute FSM_ENCODING        of DMA_R5_ST : signal is "sequential";
attribute SAFE_IMPLEMENTATION of DMA_R5_ST : signal is "yes";
attribute FSM_ENCODING        of DMA_STATE : signal is "sequential";
attribute SAFE_IMPLEMENTATION of DMA_STATE : signal is "yes";



ATTRIBUTE MARK_DEBUG : string;
ATTRIBUTE MARK_DEBUG of  DMA_WRITE_temp   : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  DMA_WRBURST_TEMP   : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  DMA_W0_READY_i     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_WRITE       : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_WRBURST     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_FIFO_RD_CMD : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_FIFO_CMD_WR : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_EMPTY_RD_CMD: SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_FIFO_WR     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_FIFO_RD     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_EMPTY_RD    : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W0_TRNSCN_M       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  DMA_W0_FIFO_CNT       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  DMA_W0_FIFO_CNT_CMD   : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  DMA_READY             : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  DMA_STATE             : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  BURST_COUNT           : SIGNAL IS "TRUE";

ATTRIBUTE MARK_DEBUG of  DMA_W2_READY_i     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_WRITE       : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_WRBURST     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_FIFO_RD_CMD : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_FIFO_CMD_WR : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_EMPTY_RD_CMD: SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_FIFO_WR     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_FIFO_RD     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_EMPTY_RD    : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_W2_TRNSCN_M       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  DMA_W2_FIFO_CNT       : SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of  DMA_W2_FIFO_CNT_CMD   : SIGNAL IS "TRUE";

ATTRIBUTE MARK_DEBUG of  DMA_R0_READY_i     : SIGNAL IS "TRUE";  
ATTRIBUTE MARK_DEBUG of  DMA_R0_READ       : SIGNAL IS "TRUE";  


--ATTRIBUTE MARK_DEBUG of DMA_R0_READY_i   : SIGNAL IS "TRUE";   
--ATTRIBUTE MARK_DEBUG of DMA_R0_READ      : SIGNAL IS "TRUE";   
--ATTRIBUTE MARK_DEBUG of DMA_W2_READY_i   : SIGNAL IS "TRUE";   
--ATTRIBUTE MARK_DEBUG of DMA_W2_WRITE     : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R1_READY_i   : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R1_READ      : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R2_READY_i   : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R2_READ      : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R3_READY_i   : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R3_READ      : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R4_READY_i   : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R4_READ      : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R5_READY_i   : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R5_READ      : SIGNAL IS "TRUE";   
ATTRIBUTE MARK_DEBUG of DMA_R4_RST       : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R4_CLK       : SIGNAL IS "TRUE"; 

ATTRIBUTE MARK_DEBUG of DMA_R0_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R1_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R2_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R3_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R4_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R5_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_W0_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_W1_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_W2_TRNSCN          : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R0_TRNSCN_M        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R1_TRNSCN_M        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R2_TRNSCN_M        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R3_TRNSCN_M        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R4_TRNSCN_M        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R5_TRNSCN_M        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of DMA_W0_TRNSCN_M        : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_W1_TRNSCN_M        : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of DMA_W2_TRNSCN_M        : SIGNAL IS "TRUE"; 

ATTRIBUTE MARK_DEBUG of DMA_R0_ST : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R1_ST : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R2_ST : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R3_ST : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R4_ST : SIGNAL IS "TRUE"; 
ATTRIBUTE MARK_DEBUG of DMA_R5_ST : SIGNAL IS "TRUE"; 
--ATTRIBUTE MARK_DEBUG of DMA_STATE : SIGNAL IS "TRUE"; 

-------
begin
-------
  DMA_WRBURST  <= DMA_WRBURST_TEMP;
  DMA_WRITE    <= DMA_WRITE_temp;
  DMA_W0_READY <= DMA_W0_READY_i;
  DMA_W1_READY <= DMA_W1_READY_i;
  DMA_W2_READY <= DMA_W2_READY_i;

  DMA_R0_READY <= DMA_R0_READY_i;
  DMA_R1_READY <= DMA_R1_READY_i;
  DMA_R2_READY <= DMA_R2_READY_i;
  DMA_R3_READY <= DMA_R3_READY_i;
  DMA_R4_READY <= DMA_R4_READY_i;
  DMA_R5_READY <= DMA_R5_READY_i;


  DMA_RW6_READY <= DMA_RW6_READY_i;

-- Manage WRITE READY signals

-- Manage WRITE READY signals

  --DMA_W0_READY_i <= '0' when (DMA_W0_TRNSCN = "10" or DMA_W0_TRNSCN = "11")  else '1';

  process(DMA_W0_CLK, DMA_W0_RST)
  begin
    if DMA_W0_RST='1' then
      W0_READY_FSM <= W0_R_IDLE;
      DMA_W0_TRNSCN <= "00";
      --DMA_W0_READY_i <= '1';
      DMA_W0_READY_i <= '0';
    elsif rising_edge(DMA_W0_CLK) then
      case W0_READY_FSM is
        when W0_R_IDLE =>
          DMA_W0_TRNSCN <= "00";
          DMA_W0_READY_i <= '1';
          --if(DMA_W0_WRBURST='1' and DMA_W0_WRITE='1' and DMA_W0_READY_i='1') then
          if(DMA_W0_WRBURST='1' and DMA_W0_WRITE='1' and DMA_W0_READY_i='1') then
            --DMA_W0_READY_i <= '1';
            DMA_W0_TRNSCN <= "01";
            W0_READY_FSM <= W0_R_S1;
          end if;

        when W0_R_S1 =>
         if(DMA_W0_WRITE='0') then
            DMA_W0_READY_i <= '0';
            if(DMA_W0_EMPTY_RD_M ='0')then
              DMA_W0_TRNSCN <= "10";
              W0_READY_FSM <= W0_R_S2;
            end if;
          end if;

        when W0_R_S2 =>
--          if(DMA_W0_EMPTY_RD_CMD_S='1' and DMA_W0_EMPTY_RD_S = '1') then
          if(DMA_W0_EMPTY_RD_M ='1')then
            DMA_W0_TRNSCN <= "11";
            W0_READY_FSM <= W0_R_IDLE;
          end if;

        end case;
    end if;
  end process;



  xpm_cdc_gray_inst_W0: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_W0_CLK,
    src_in_bin => DMA_W0_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_W0_TRNSCN_M
  );


DMA_W0_EMPTY_RD_M <= DMA_W0_EMPTY_RD_CMD and DMA_W0_EMPTY_RD;

-- Manage WRITE READY signals
  --DMA_W1_READY_i <= '0' when (DMA_W1_TRNSCN = "10" or DMA_W1_TRNSCN = "11")  else '1';
  process(DMA_W1_CLK, DMA_W1_RST)
  begin
    if DMA_W1_RST='1' then
      W1_READY_FSM <= W1_R_IDLE;
      DMA_W1_TRNSCN <= "00";
      --DMA_W1_READY_i <= '1';
      DMA_W1_READY_i <= '0';
    elsif rising_edge(DMA_W1_CLK) then
      case W1_READY_FSM is
        when W1_R_IDLE =>
          DMA_W1_TRNSCN <= "00";
          DMA_W1_READY_i <= '1';
          --if(DMA_W1_WRBURST='1' and DMA_W1_WRITE='1' and DMA_W1_READY_i='1') then
          if(DMA_W1_WRBURST='1' and DMA_W1_WRITE='1' and DMA_W1_READY_i='1') then
            --DMA_W1_READY_i <= '1';
            DMA_W1_TRNSCN <= "01";
            W1_READY_FSM <= W1_R_S1;
          end if;

        when W1_R_S1 =>
          if(DMA_W1_WRITE='0') then
            DMA_W1_READY_i <= '0';
            if(DMA_W1_EMPTY_RD_M ='0')then
              DMA_W1_TRNSCN <= "10";
              W1_READY_FSM <= W1_R_S2;
            end if;
          end if;

        when W1_R_S2 =>
--          if(DMA_W1_EMPTY_RD_CMD_S='1' and DMA_W1_EMPTY_RD_S = '1') then
          if(DMA_W1_EMPTY_RD_M ='1')then
            DMA_W1_TRNSCN <= "11";
            W1_READY_FSM <= W1_R_IDLE;
          end if;

        end case;
    end if;
  end process;


  xpm_cdc_gray_inst_W1: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_W1_CLK,
    src_in_bin => DMA_W1_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_W1_TRNSCN_M
  );
DMA_W1_EMPTY_RD_M <= DMA_W1_EMPTY_RD_CMD and DMA_W1_EMPTY_RD;

  -- Manage WRITE READY signals
  --DMA_W2_READY_i <= '0' when (DMA_W2_TRNSCN = "10" or DMA_W2_TRNSCN = "11")  else '1';
  process(DMA_W2_CLK, DMA_W2_RST)
  begin
    if DMA_W2_RST='1' then
      W2_READY_FSM <= W2_R_IDLE;
      DMA_W2_TRNSCN <= "00";
      --DMA_W2_READY_i <= '1';
      DMA_W2_READY_i <= '0';
    elsif rising_edge(DMA_W2_CLK) then
      case W2_READY_FSM is
        when W2_R_IDLE =>
          DMA_W2_TRNSCN <= "00";
          DMA_W2_READY_i <= '1';
          --if(DMA_W2_WRBURST='1' and DMA_W2_WRITE='1' and DMA_W2_READY_i='1') then
          if(DMA_W2_WRBURST='1' and DMA_W2_WRITE='1' and DMA_W2_READY_i='1') then
            --DMA_W2_READY_i <= '1';
            DMA_W2_TRNSCN <= "01";
            W2_READY_FSM <= W2_R_S1;
          end if;

        when W2_R_S1 =>
          if(DMA_W2_WRITE='0') then
            DMA_W2_READY_i <= '0';
            if(DMA_W2_EMPTY_RD_M ='0')then
              DMA_W2_TRNSCN <= "10";
              W2_READY_FSM <= W2_R_S2;
            end if;
          end if;

        when W2_R_S2 =>
--          if(DMA_W2_EMPTY_RD_CMD_S='1' and DMA_W2_EMPTY_RD_S = '1') then
          if(DMA_W2_EMPTY_RD_M ='1')then
            DMA_W2_TRNSCN <= "11";
            W2_READY_FSM <= W2_R_IDLE;
          end if;
        end case;
    end if;
  end process;


  xpm_cdc_gray_inst_W2: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_W2_CLK,
    src_in_bin => DMA_W2_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_W2_TRNSCN_M
  );

  DMA_W2_EMPTY_RD_M <= DMA_W2_EMPTY_RD_CMD and DMA_W2_EMPTY_RD;
 
  DMA_W0_FIFO_CMD_WR <= DMA_W0_WRITE and DMA_W0_WRBURST and DMA_W0_READY_i;
  DMA_W0_FIFO_CMD_IN <= DMA_W0_ADDR & DMA_W0_SIZE & DMA_W0_WRBE;
  DMA_W0_FIFO_WRBE <= DMA_W0_FIFO_CMD_OUT(DMA_W0_WRBE'length-1 downto 0);
  DMA_W0_FIFO_SIZE <= DMA_W0_FIFO_CMD_OUT(DMA_W0_WRBE'length+DMA_W0_SIZE'length-1 downto DMA_W0_WRBE'length);
  DMA_W0_FIFO_ADDR <= DMA_W0_FIFO_CMD_OUT(DMA_W0_FIFO_CMD_OUT'length-1 downto DMA_W0_WRBE'length+DMA_W0_SIZE'length);

  --i_DMA_W0_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_WR_FIFO_CMD_DEPTH         ,
  --  FIFO_WIDTH  => DMA_WR_FIFO_CMD_WIDTH         ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_W0_CLK ,
  --  RST_WR      => DMA_W0_RST ,
  --  CLR_WR      =>  '0',
  --  WRREQ       =>  DMA_W0_FIFO_CMD_WR ,
  --  WRDATA      =>  DMA_W0_FIFO_CMD_IN ,
  --  CLK_RD      =>  DMA_CLK           ,
  --  RST_RD      =>  DMA_RST           ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_W0_FIFO_RD_CMD,
  --  RDDATA      =>  DMA_W0_FIFO_CMD_OUT,
  --  EMPTY_RD    =>  DMA_W0_EMPTY_RD_CMD ,
  --  FIFO_CNT_RD =>  DMA_W0_FIFO_CNT_CMD          
  --  );

  --DMA_W0_FIFO_WR <= DMA_W0_WRITE and DMA_W0_READY_i; 

  --i_DMA_W0_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_WR_FIFO_DEPTH        ,
  --  FIFO_WIDTH  => DMA_WR_FIFO_WIDTH        ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_W0_CLK ,
  --  RST_WR      => DMA_W0_RST ,
  --  CLR_WR      =>  '0',
  --  WRREQ       =>  DMA_W0_FIFO_WR,
  --  WRDATA      =>  DMA_W0_WRDATA     ,
  --  CLK_RD      =>  DMA_CLK           ,
  --  RST_RD      =>  DMA_RST           ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_W0_FIFO_RD    ,
  --  RDDATA      =>  DMA_W0_FIFO_OUT   ,
  --  EMPTY_RD    =>  DMA_W0_EMPTY_RD   ,
  --  FIFO_CNT_RD =>  DMA_W0_FIFO_CNT          
  --  );

    i_DMA_W0_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_WR_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_WR_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_WR_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_WR_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_WR_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_W0_FIFO_CMD_OUT,
      empty => DMA_W0_EMPTY_RD_CMD,
      rd_data_count => DMA_W0_FIFO_CNT_CMD,
      din => DMA_W0_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_W0_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_W0_CLK,
      wr_en => DMA_W0_FIFO_CMD_WR 
   );

  DMA_W0_FIFO_WR <= DMA_W0_WRITE and DMA_W0_READY_i; 

  i_DMA_W0_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_WR_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_WR_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_WR_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_WR_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_WR_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_W0_FIFO_OUT,
      empty => DMA_W0_EMPTY_RD,
      rd_data_count => DMA_W0_FIFO_CNT,
      din => DMA_W0_WRDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_W0_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_W0_CLK,
      wr_en => DMA_W0_FIFO_WR 
   );


  DMA_W1_FIFO_CMD_WR <= DMA_W1_WRITE and DMA_W1_WRBURST and DMA_W1_READY_i;
  DMA_W1_FIFO_CMD_IN <= DMA_W1_ADDR & DMA_W1_SIZE & DMA_W1_WRBE;
  DMA_W1_FIFO_WRBE <= DMA_W1_FIFO_CMD_OUT(DMA_W1_WRBE'length-1 downto 0);
  DMA_W1_FIFO_SIZE <= DMA_W1_FIFO_CMD_OUT(DMA_W1_WRBE'length+DMA_W1_SIZE'length-1 downto DMA_W1_WRBE'length);
  DMA_W1_FIFO_ADDR <= DMA_W1_FIFO_CMD_OUT(DMA_W1_FIFO_CMD_OUT'length-1 downto DMA_W1_WRBE'length+DMA_W1_SIZE'length);


--i_DMA_W1_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
--   generic map (
--    FIFO_DEPTH  => DMA_WR_FIFO_CMD_DEPTH         ,
--    FIFO_WIDTH  => DMA_WR_FIFO_CMD_WIDTH         ,
--    RAM_STYLE   => "block"
--    )    
--    port map (
--    CLK_WR      => DMA_W1_CLK ,
--    RST_WR      => DMA_W1_RST ,
--    CLR_WR      =>  '0',
--    WRREQ       =>  DMA_W1_FIFO_CMD_WR ,
--    WRDATA      =>  DMA_W1_FIFO_CMD_IN,
--    CLK_RD      =>  DMA_CLK           ,
--    RST_RD      =>  DMA_RST           ,
--    CLR_RD      =>  '0'               ,
--    RDREQ       =>  DMA_W1_FIFO_RD_CMD,
--    RDDATA      =>  DMA_W1_FIFO_CMD_OUT,
--    EMPTY_RD    =>  DMA_W1_EMPTY_RD_CMD ,
--    FIFO_CNT_RD =>  DMA_W1_FIFO_CNT_CMD          
--    );

--  DMA_W1_FIFO_WR <= DMA_W1_WRITE and DMA_W1_READY_i; 

--  i_DMA_W1_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
--   generic map (
--    FIFO_DEPTH  => DMA_WR_FIFO_DEPTH        ,
--    FIFO_WIDTH  => DMA_WR_FIFO_WIDTH        ,
--    RAM_STYLE   => "block"
--    )    
--    port map (
--    CLK_WR      => DMA_W1_CLK ,
--    RST_WR      => DMA_W1_RST ,
--    CLR_WR      =>  '0',
--    WRREQ       =>  DMA_W1_FIFO_WR    ,
--    WRDATA      =>  DMA_W1_WRDATA     ,
--    CLK_RD      =>  DMA_CLK           ,
--    RST_RD      =>  DMA_RST           ,
--    CLR_RD      =>  '0'               ,
--    RDREQ       =>  DMA_W1_FIFO_RD    ,
--    RDDATA      =>  DMA_W1_FIFO_OUT   ,
--    EMPTY_RD    =>  DMA_W1_EMPTY_RD   ,
--    FIFO_CNT_RD =>  DMA_W1_FIFO_CNT          
--    );

    i_DMA_W1_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_WR_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_WR_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_WR_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_WR_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_WR_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_W1_FIFO_CMD_OUT,
      empty => DMA_W1_EMPTY_RD_CMD,
      rd_data_count => DMA_W1_FIFO_CNT_CMD,
      din => DMA_W1_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_W1_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_W1_CLK,
      wr_en => DMA_W1_FIFO_CMD_WR 
   );

  DMA_W1_FIFO_WR <= DMA_W1_WRITE and DMA_W1_READY_i; 

  i_DMA_W1_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_WR_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_WR_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_WR_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_WR_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_WR_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_W1_FIFO_OUT,
      empty => DMA_W1_EMPTY_RD,
      rd_data_count => DMA_W1_FIFO_CNT,
      din => DMA_W1_WRDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_W1_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_W1_CLK,
      wr_en => DMA_W1_FIFO_WR 
   );

  DMA_W2_FIFO_CMD_WR <= DMA_W2_WRITE and DMA_W2_WRBURST and DMA_W2_READY_i;
  DMA_W2_FIFO_CMD_IN <= DMA_W2_ADDR & DMA_W2_SIZE & DMA_W2_WRBE;
  DMA_W2_FIFO_WRBE <= DMA_W2_FIFO_CMD_OUT(DMA_W2_WRBE'length-1 downto 0);
  DMA_W2_FIFO_SIZE <= DMA_W2_FIFO_CMD_OUT(DMA_W2_WRBE'length+DMA_W2_SIZE'length-1 downto DMA_W2_WRBE'length);
  DMA_W2_FIFO_ADDR <= DMA_W2_FIFO_CMD_OUT(DMA_W2_FIFO_CMD_OUT'length-1 downto DMA_W2_WRBE'length+DMA_W2_SIZE'length);

  --i_DMA_W2_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_WR_FIFO_CMD_DEPTH         ,
  --  FIFO_WIDTH  => DMA_WR_FIFO_CMD_WIDTH         ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_W2_CLK ,
  --  RST_WR      => DMA_W2_RST ,
  --  CLR_WR      =>  '0',
  --  WRREQ       =>  DMA_W2_FIFO_CMD_WR,
  --  WRDATA      =>  DMA_W2_FIFO_CMD_IN,
  --  CLK_RD      =>  DMA_CLK           ,
  --  RST_RD      =>  DMA_RST           ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_W2_FIFO_RD_CMD,
  --  RDDATA      =>  DMA_W2_FIFO_CMD_OUT,
  --  EMPTY_RD    =>  DMA_W2_EMPTY_RD_CMD ,
  --  FIFO_CNT_RD =>  DMA_W2_FIFO_CNT_CMD          
  --  );

  --DMA_W2_FIFO_WR <= DMA_W2_WRITE and DMA_W2_READY_i; 

  --i_DMA_W2_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_WR_FIFO_DEPTH        ,
  --  FIFO_WIDTH  => DMA_WR_FIFO_WIDTH        ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_W2_CLK ,
  --  RST_WR      => DMA_W2_RST ,
  --  CLR_WR      =>  '0',
  --  WRREQ       =>  DMA_W2_FIFO_WR    ,
  --  WRDATA      =>  DMA_W2_WRDATA     ,
  --  CLK_RD      =>  DMA_CLK           ,
  --  RST_RD      =>  DMA_RST           ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_W2_FIFO_RD    ,
  --  RDDATA      =>  DMA_W2_FIFO_OUT   ,
  --  EMPTY_RD    =>  DMA_W2_EMPTY_RD   ,
  --  FIFO_CNT_RD =>  DMA_W2_FIFO_CNT          
  --  );
    i_DMA_W2_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_WR_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_WR_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_WR_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_WR_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_WR_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_W2_FIFO_CMD_OUT,
      empty => DMA_W2_EMPTY_RD_CMD,
      rd_data_count => DMA_W2_FIFO_CNT_CMD,
      din => DMA_W2_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_W2_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_W2_CLK,
      wr_en => DMA_W2_FIFO_CMD_WR 
   );

  DMA_W2_FIFO_WR <= DMA_W2_WRITE and DMA_W2_READY_i; 

  i_DMA_W2_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_WR_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_WR_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_WR_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_WR_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_WR_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_W2_FIFO_OUT,
      empty => DMA_W2_EMPTY_RD,
      rd_data_count => DMA_W2_FIFO_CNT,
      din => DMA_W2_WRDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_W2_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_W2_CLK,
      wr_en => DMA_W2_FIFO_WR 
   );


  DMA_WRDATA <= DMA_W0_FIFO_OUT when (DMA_STATE=W0_ST1 or DMA_STATE=W0_ST2) else
                DMA_W1_FIFO_OUT when (DMA_STATE=W1_ST1 or DMA_STATE=W1_ST2) else
                DMA_W2_FIFO_OUT when (DMA_STATE=W2_ST1 or DMA_STATE=W2_ST2) else
                DMA_RW6_WRFIFO_OUT when (DMA_STATE=RW6_ST3 or DMA_STATE=RW6_ST4) else
                x"0000_0000";
  
  READ_DC_FIFO_PROCESS: process(DMA_CLK, DMA_RST)
  begin
    if DMA_RST='1' then 
      DMA_STATE <= W0_DONE;
      DMA_READ <= '0';
      DMA_WRITE_temp <= '0';
      DMA_ADDR <= (others=>'0');
      DMA_WRBE <= (others=>'1');
      DMA_WRBURST_temp <= '0';
      --DMA_WRDATA <= (others=>'0');
      DMA_SIZE <= (others=>'0');
      DMA_W0_FIFO_RD_CMD <= '0';
      DMA_W0_FIFO_RD <= '0';
      DMA_W1_FIFO_RD_CMD <= '0';
      DMA_W1_FIFO_RD <= '0';
      DMA_W2_FIFO_RD_CMD <= '0';
      DMA_W2_FIFO_RD <= '0';

      DMA_RW6_WRFIFO_RD <= '0';

      DMA_R0_EN <= '0';
      DMA_R1_EN <= '0';
      DMA_R2_EN <= '0';
      DMA_R3_EN <= '0';
      DMA_R4_EN <= '0';
      DMA_R5_EN <= '0';

      DMA_RW6_EN <= '0';

      DMA_R0_FIFO_RD_CMD <= '0';
      DMA_R1_FIFO_RD_CMD <= '0';
      DMA_R2_FIFO_RD_CMD <= '0';
      DMA_R3_FIFO_RD_CMD <= '0';
      DMA_R4_FIFO_RD_CMD <= '0';
      DMA_R5_FIFO_RD_CMD <= '0';

      DMA_RW6_FIFO_RD_CMD <= '0';

      BURST_COUNT <= (others=>'0');


    elsif rising_edge(DMA_CLK) then
      DMA_W0_FIFO_RD_CMD <= '0';
      DMA_W0_FIFO_RD <= '0';
      DMA_W1_FIFO_RD_CMD <= '0';
      DMA_W1_FIFO_RD <= '0';
      DMA_W2_FIFO_RD_CMD <= '0';
      DMA_W2_FIFO_RD <= '0';

      DMA_RW6_WRFIFO_RD <= '0';

      DMA_R0_FIFO_RD_CMD <= '0';
      DMA_R1_FIFO_RD_CMD <= '0';
      DMA_R2_FIFO_RD_CMD <= '0';
      DMA_R3_FIFO_RD_CMD <= '0';
      DMA_R4_FIFO_RD_CMD <= '0';
      DMA_R5_FIFO_RD_CMD <= '0';

      DMA_RW6_FIFO_RD_CMD <= '0';

      case DMA_STATE is

        when W0_DONE=>
          if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then
            if(DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then
              DMA_STATE <= R0_START;
            elsif (DMA_R1_TRNSCN_M="10") then
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then  
              DMA_STATE <= R4_START;
            elsif (DMA_R5_TRNSCN_M="10") then  
              DMA_STATE <= R5_START;
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;          
          else        
            if(DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R1_TRNSCN_M="10") then
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then  
              DMA_STATE <= R4_START;
            elsif (DMA_R5_TRNSCN_M="10") then  
              DMA_STATE <= R5_START;
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_R0_TRNSCN_M="10") then
              DMA_STATE <= R0_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
          end if;
        when W1_DONE=>
          if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then   
            if (DMA_W2_TRNSCN_M="10") then 
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then
              DMA_STATE <= R0_START;
            elsif (DMA_R1_TRNSCN_M="10") then
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then  
              DMA_STATE <= R4_START;
            elsif (DMA_R5_TRNSCN_M="10") then  
              DMA_STATE <= R5_START;
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;        
          else     
            if (DMA_W2_TRNSCN_M="10") then 
              DMA_STATE <= W2_START;
            elsif (DMA_R1_TRNSCN_M="10") then
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then  
              DMA_STATE <= R4_START;
            elsif (DMA_R5_TRNSCN_M="10") then  
              DMA_STATE <= R5_START;
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_R0_TRNSCN_M="10") then
              DMA_STATE <= R0_START;            
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
          end if;  

        when W2_DONE=>
          if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then 
            if (DMA_R0_TRNSCN_M="10") then
              DMA_STATE <= R0_START;
            elsif (DMA_R1_TRNSCN_M="10") then
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;          
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START;          
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
          else
            if (DMA_R1_TRNSCN_M="10") then
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;          
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START;          
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then
              DMA_STATE <= R0_START;            
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
              
          end if;      

        when R0_DONE=>
          if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then 
            if (DMA_R1_TRNSCN_M="10") then
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;          
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START;                      
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then
              DMA_STATE <= R0_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
          else
            if (DMA_R1_TRNSCN_M="10") then
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;          
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START;                      
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then
              DMA_STATE <= R0_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
          end if;  

          when R1_DONE=>
            if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then 
              if (DMA_R2_TRNSCN_M="10") then
                DMA_STATE <= R2_START;
              elsif (DMA_R3_TRNSCN_M="10") then  
                DMA_STATE <= R3_START;
              elsif (DMA_R4_TRNSCN_M="10") then 
                DMA_STATE <= R4_START;          
              elsif (DMA_R5_TRNSCN_M="10") then 
                DMA_STATE <= R5_START;          
              elsif (DMA_W0_TRNSCN_M="10") then
                DMA_STATE <= W0_START;
              elsif (DMA_W1_TRNSCN_M="10") then
                DMA_STATE <= W1_START;
              elsif (DMA_W2_TRNSCN_M="10") then
                DMA_STATE <= W2_START;
              elsif (DMA_R0_TRNSCN_M="10") then  
                DMA_STATE <= R0_START;
              elsif (DMA_R1_TRNSCN_M="10") then
                DMA_STATE <= R1_START;
              elsif (DMA_RW6_TRNSCN_M="10") then
                DMA_STATE <= RW6_START;
              end if;          
            else
              if (DMA_R2_TRNSCN_M="10") then
                DMA_STATE <= R2_START;
              elsif (DMA_R3_TRNSCN_M="10") then  
                DMA_STATE <= R3_START;
              elsif (DMA_R4_TRNSCN_M="10") then 
                DMA_STATE <= R4_START;          
              elsif (DMA_R5_TRNSCN_M="10") then 
                DMA_STATE <= R5_START;          
              elsif (DMA_W0_TRNSCN_M="10") then
                DMA_STATE <= W0_START;
              elsif (DMA_W1_TRNSCN_M="10") then
                DMA_STATE <= W1_START;
              elsif (DMA_W2_TRNSCN_M="10") then
                DMA_STATE <= W2_START;
              elsif (DMA_R1_TRNSCN_M="10") then
                DMA_STATE <= R1_START;
              elsif (DMA_R0_TRNSCN_M="10") then  
                DMA_STATE <= R0_START;
              elsif (DMA_RW6_TRNSCN_M="10") then
                DMA_STATE <= RW6_START;
              end if;
            end if;

        when R2_DONE=>
          if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then 
            if (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;          
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START;          
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then  
              DMA_STATE <= R0_START;
            elsif (DMA_R1_TRNSCN_M="10") then  
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;        
          else
            if (DMA_R3_TRNSCN_M="10") then  
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;          
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START;          
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R1_TRNSCN_M="10") then  
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then
              DMA_STATE <= R2_START;
            elsif (DMA_R0_TRNSCN_M="10") then  
              DMA_STATE <= R0_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
          end if;

        when R3_DONE=>
          if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then 
            if (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;          
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START; 
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then  
              DMA_STATE <= R0_START;
            elsif (DMA_R1_TRNSCN_M="10") then  
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then  
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then
              DMA_STATE <= R3_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
          else
            if (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;          
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START; 
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R1_TRNSCN_M="10") then  
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then  
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then
              DMA_STATE <= R3_START;
            elsif (DMA_R0_TRNSCN_M="10") then  
              DMA_STATE <= R0_START;            
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;
            end if;
              
          end if;      

        when R4_DONE=>
          if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then 
            if (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START; 
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then  
              DMA_STATE <= R0_START;
            elsif (DMA_R1_TRNSCN_M="10") then  
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then  
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;          
            end if;
          else
            if (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START; 
            elsif (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R1_TRNSCN_M="10") then  
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then  
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;
            elsif (DMA_R0_TRNSCN_M="10") then  
              DMA_STATE <= R0_START;            
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;          
            end if;

          end if;
        when R5_DONE=>
          if(SEL_OLED_ANALOG_VIDEO_OUT ='1')then 
            if (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R0_TRNSCN_M="10") then  
              DMA_STATE <= R0_START;
            elsif (DMA_R1_TRNSCN_M="10") then  
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then  
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;    
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START;
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;         
            end if;
          else
            if (DMA_W0_TRNSCN_M="10") then
              DMA_STATE <= W0_START;
            elsif (DMA_W1_TRNSCN_M="10") then
              DMA_STATE <= W1_START;
            elsif (DMA_W2_TRNSCN_M="10") then
              DMA_STATE <= W2_START;
            elsif (DMA_R1_TRNSCN_M="10") then  
              DMA_STATE <= R1_START;
            elsif (DMA_R2_TRNSCN_M="10") then  
              DMA_STATE <= R2_START;
            elsif (DMA_R3_TRNSCN_M="10") then
              DMA_STATE <= R3_START;
            elsif (DMA_R4_TRNSCN_M="10") then 
              DMA_STATE <= R4_START;    
            elsif (DMA_R5_TRNSCN_M="10") then 
              DMA_STATE <= R5_START;
            elsif (DMA_R0_TRNSCN_M="10") then  
              DMA_STATE <= R0_START;            
            elsif (DMA_RW6_TRNSCN_M="10") then
              DMA_STATE <= RW6_START;         
            end if;
          end if;

        when W0_START =>
          DMA_W0_FIFO_RD_CMD <= '1';
          DMA_STATE <= W0_ST0;

        when W0_ST0 =>
          DMA_W0_FIFO_RD <= '1';
          DMA_STATE <= W0_ST1;

        when W0_ST1 =>
          DMA_WRITE_temp <= '1';
          DMA_WRBURST_temp <= '1';
          DMA_ADDR <= DMA_W0_FIFO_ADDR;
          BURST_COUNT <= unsigned(DMA_W0_FIFO_SIZE)-1;
          DMA_SIZE <= DMA_W0_FIFO_SIZE;
          DMA_WRBE <= DMA_W0_FIFO_WRBE;
          --DMA_WRDATA <= DMA_W0_FIFO_OUT;
          if(DMA_READY='1' and unsigned(DMA_W0_FIFO_SIZE)/=1) then 
            DMA_W0_FIFO_RD <= '1';
          end if;
          DMA_STATE <= W0_ST2;

        when  W0_ST2 =>
          --DMA_WRDATA <= DMA_W0_FIFO_OUT;
          if(DMA_READY='1') then
            DMA_WRBURST_temp <='0';
          end if;
          if(DMA_READY='1' and BURST_COUNT/=0) then
            if(BURST_COUNT=1) then
              DMA_W0_FIFO_RD <= '0';
            else 
              DMA_W0_FIFO_RD <= '1';
            end if;
            BURST_COUNT <= BURST_COUNT -1;
          end if;
          if(BURST_COUNT =0) then
            DMA_WRITE_temp <= '0';
            DMA_STATE <= W0_WAIT;
          end if;

        when W0_WAIT =>
--          if(DMA_W0_TRNSCN_M="00") then
          if(DMA_W0_TRNSCN_M="00" or DMA_W0_TRNSCN_M="01") then
              DMA_STATE <= W0_DONE;
          end if;

        when W1_START =>
          DMA_W1_FIFO_RD_CMD <= '1';
          DMA_STATE <=W1_ST0;

        when W1_ST0 =>
          DMA_W1_FIFO_RD <= '1';
          DMA_STATE <= W1_ST1;

        when W1_ST1 =>
          DMA_WRITE_temp <= '1';
          DMA_WRBURST_temp <= '1';
          DMA_ADDR <= DMA_W1_FIFO_ADDR;
          BURST_COUNT <= unsigned(DMA_W1_FIFO_SIZE)-1;
          DMA_SIZE <= DMA_W1_FIFO_SIZE;
          DMA_WRBE <= DMA_W1_FIFO_WRBE;
          --DMA_WRDATA <= DMA_W1_FIFO_OUT;
          if(DMA_READY='1' and unsigned(DMA_W1_FIFO_SIZE)/=1) then 
            DMA_W1_FIFO_RD <= '1';
          end if;
          DMA_STATE <= W1_ST2;

        when  W1_ST2 =>
          --DMA_WRDATA <= DMA_W1_FIFO_OUT;
          if(DMA_READY='1') then
            DMA_WRBURST_temp <='0';
          end if;
          if(DMA_READY='1' and BURST_COUNT/=0) then
            if(BURST_COUNT=1) then
              DMA_W1_FIFO_RD <= '0';
            else 
              DMA_W1_FIFO_RD <= '1';
            end if;
            BURST_COUNT <= BURST_COUNT -1;
          end if;
          if(BURST_COUNT =0) then
            DMA_WRITE_temp <= '0';
            DMA_STATE <= W1_WAIT;
          end if;

        when W1_WAIT =>
--          if(DMA_W1_TRNSCN_M="00") then
          if(DMA_W1_TRNSCN_M="00" or DMA_W1_TRNSCN_M="01") then
              DMA_STATE <= W1_DONE;
          end if;

        when W2_START =>
          DMA_W2_FIFO_RD_CMD <= '1';
          DMA_STATE <= W2_ST0;


        when W2_ST0 =>
          DMA_W2_FIFO_RD <= '1';
          DMA_STATE <= W2_ST1;

        when W2_ST1 =>
          DMA_WRITE_temp <= '1';
          DMA_WRBURST_temp <= '1';
          DMA_ADDR <= DMA_W2_FIFO_ADDR;
          BURST_COUNT <= unsigned(DMA_W2_FIFO_SIZE)-1;
          DMA_SIZE <= DMA_W2_FIFO_SIZE;
          DMA_WRBE <= DMA_W2_FIFO_WRBE;
          --DMA_WRDATA <= DMA_W2_FIFO_OUT;
          if(DMA_READY='1' and unsigned(DMA_W2_FIFO_SIZE)/=1) then 
            DMA_W2_FIFO_RD <= '1';
          end if;
          DMA_STATE <= W2_ST2;

        when  W2_ST2 =>
          --DMA_WRDATA <= DMA_W2_FIFO_OUT;
          if(DMA_READY='1') then
            DMA_WRBURST_temp <='0';
          end if;
          if(DMA_READY='1' and BURST_COUNT/=0) then
            if(BURST_COUNT=1) then
              DMA_W2_FIFO_RD <= '0';
            else 
              DMA_W2_FIFO_RD <= '1';
            end if;
            BURST_COUNT <= BURST_COUNT -1;
          end if;
          if(BURST_COUNT =0) then
            DMA_WRITE_temp <= '0';
            DMA_STATE <= W2_WAIT;
          end if;

        when W2_WAIT =>
          if(DMA_W2_TRNSCN_M="00" or DMA_W2_TRNSCN_M="01") then
--          if(DMA_W2_TRNSCN_M="00") then
              DMA_STATE <= W2_DONE;
          end if;

        when R0_START =>
          DMA_R0_EN <= '1';
          DMA_R0_FIFO_RD_CMD <= '1';
          DMA_STATE <= R0_ST0;

        when R0_ST0 =>
          DMA_STATE <= R0_ST1;

        when  R0_ST1 =>
          DMA_READ <='1';
          DMA_ADDR <= DMA_R0_FIFO_ADDR;
          DMA_SIZE <= DMA_R0_FIFO_SIZE;
          DMA_STATE <= R0_ST2;

        when  R0_ST2 =>
          if(DMA_READY='1') then
            DMA_READ <= '0';
          end if;
          if(DMA_R0_EMPTY_RD_CMD/='1' and DMA_READY='1') then
            DMA_STATE <= R0_START;
          elsif(DMA_R0_TRNSCN_M="11") then
            DMA_R0_EN <= '0';
            DMA_STATE <= R0_DONE;
          end if;

        when R1_START =>
          DMA_R1_EN <= '1';
          DMA_R1_FIFO_RD_CMD <= '1';
          DMA_STATE <= R1_ST0;

        when R1_ST0 =>
          DMA_STATE <= R1_ST1;

        when  R1_ST1 =>
          DMA_READ <='1';
          DMA_ADDR <= DMA_R1_FIFO_ADDR;
          DMA_SIZE <= DMA_R1_FIFO_SIZE;
          DMA_STATE <= R1_ST2;

        when  R1_ST2 =>
          if(DMA_READY='1') then
            DMA_READ <= '0';
          end if;
          if(DMA_R1_EMPTY_RD_CMD/='1' and DMA_READY='1') then
            DMA_STATE <= R1_START;
          elsif(DMA_R1_TRNSCN_M="11") then
            DMA_R1_EN <= '0';
            DMA_STATE <= R1_DONE;
          end if;

        when R2_START =>
          DMA_R2_EN <= '1';
          DMA_R2_FIFO_RD_CMD <= '1';
          DMA_STATE <= R2_ST0;

        when R2_ST0 =>
          DMA_STATE <= R2_ST1;

        when  R2_ST1 =>
          DMA_READ <='1';
          DMA_ADDR <= DMA_R2_FIFO_ADDR;
          DMA_SIZE <= DMA_R2_FIFO_SIZE;
          DMA_STATE <= R2_ST2;

        when  R2_ST2 =>
          if(DMA_READY='1') then
            DMA_READ <= '0';
          end if;
          if(DMA_R2_EMPTY_RD_CMD/='1' and DMA_READY='1') then
            DMA_STATE <= R2_START;
          elsif(DMA_R2_TRNSCN_M="11") then
            DMA_R2_EN <= '0';
            DMA_STATE <= R2_DONE;
          end if;

        when R3_START =>
          DMA_R3_EN <= '1';
          DMA_R3_FIFO_RD_CMD <= '1';
          DMA_STATE <= R3_ST0;

        when R3_ST0 =>
          DMA_STATE <= R3_ST1;

        when  R3_ST1 =>
          DMA_READ <='1';
          DMA_ADDR <= DMA_R3_FIFO_ADDR;
          DMA_SIZE <= DMA_R3_FIFO_SIZE;
          DMA_STATE <= R3_ST2;

        when  R3_ST2 =>
          if(DMA_READY='1') then
            DMA_READ <= '0';
          end if;
          if(DMA_R3_EMPTY_RD_CMD/='1' and DMA_READY='1') then
            DMA_STATE <= R3_START;
          elsif(DMA_R3_TRNSCN_M="11") then
            DMA_R3_EN <= '0';
            DMA_STATE <= R3_DONE;
          end if;
        
        when R4_START =>
            DMA_R4_EN <= '1';
            DMA_R4_FIFO_RD_CMD <= '1';
            DMA_STATE <= R4_ST0;
  
        when R4_ST0 =>
            DMA_STATE <= R4_ST1;
  
        when R4_ST1 =>
            DMA_READ <='1';
            DMA_ADDR <= DMA_R4_FIFO_ADDR;
            DMA_SIZE <= DMA_R4_FIFO_SIZE;
            DMA_STATE <= R4_ST2;
  
        when R4_ST2 =>
            if(DMA_READY='1') then
              DMA_READ <= '0';
            end if;
            if(DMA_R4_EMPTY_RD_CMD/='1' and DMA_READY='1') then
              DMA_STATE <= R4_START;
            elsif(DMA_R4_TRNSCN_M="11") then
              DMA_R4_EN <= '0';
              DMA_STATE <= R4_DONE;
            end if;  
          
        when R5_START =>
            DMA_R5_EN <= '1';
            DMA_R5_FIFO_RD_CMD <= '1';
            DMA_STATE <= R5_ST0;
  
        when R5_ST0 =>
            DMA_STATE <= R5_ST1;
  
        when R5_ST1 =>
            DMA_READ <='1';
            DMA_ADDR <= DMA_R5_FIFO_ADDR;
            DMA_SIZE <= DMA_R5_FIFO_SIZE;
            DMA_STATE <= R5_ST2;
  
        when R5_ST2 =>
            if(DMA_READY='1') then
              DMA_READ <= '0';
            end if;
            if(DMA_R5_EMPTY_RD_CMD/='1' and DMA_READY='1') then
              DMA_STATE <= R5_START;
            elsif(DMA_R5_TRNSCN_M="11") then
              DMA_R5_EN <= '0';
              DMA_STATE <= R5_DONE;
            end if;            
        
        when RW6_START => 
          DMA_RW6_FIFO_RD_CMD <= '1';
          DMA_STATE <= RW6_ST0;

        when RW6_ST0 =>
          DMA_STATE <= RW6_ST1;

        when RW6_ST1=>
          if(DMA_RW6_FIFO_WRnRD='1') then
            DMA_STATE <= RW6_ST2;
          else
            DMA_RW6_EN <= '1';
            DMA_STATE <= RW6_ST5;
          end if;

        when RW6_ST2 =>
          DMA_RW6_WRFIFO_RD <= '1';
          DMA_STATE <= RW6_ST3;

        when RW6_ST3 =>
          DMA_WRITE_temp <= '1';
          DMA_WRBURST_temp <= '1';
          DMA_ADDR <= DMA_RW6_FIFO_ADDR;
          BURST_COUNT <= unsigned(DMA_RW6_FIFO_SIZE)-1;
          DMA_SIZE <= DMA_RW6_FIFO_SIZE;
          DMA_WRBE <= DMA_RW6_FIFO_WRBE;
          --DMA_WRDATA <= DMA_W0_FIFO_OUT;
          if(DMA_READY='1' and unsigned(DMA_RW6_FIFO_SIZE)/=1) then 
            DMA_RW6_WRFIFO_RD <= '1';
          end if;
          DMA_STATE <= RW6_ST4;

        when  RW6_ST4 =>
          --DMA_WRDATA <= DMA_W0_FIFO_OUT;
          if(DMA_READY='1') then
            DMA_WRBURST_temp <='0';
          end if;
          if(DMA_READY='1' and BURST_COUNT/=0) then
            if(BURST_COUNT=1) then
              DMA_RW6_WRFIFO_RD <= '0';
            else 
              DMA_RW6_WRFIFO_RD <= '1';
            end if;
            BURST_COUNT <= BURST_COUNT -1;
          end if;
          if(BURST_COUNT =0) then
            DMA_WRITE_temp <= '0';
            DMA_STATE <= RW6_WAIT;
          end if;

        when RW6_WAIT =>
--          if(DMA_W0_TRNSCN_M="00") then
          if(DMA_RW6_TRNSCN_M="00" or DMA_RW6_TRNSCN_M="01") then
              DMA_STATE <= R0_DONE;
          end if;

        when RW6_ST5 =>
            DMA_READ <='1';
            DMA_ADDR <= DMA_RW6_FIFO_ADDR;
            DMA_SIZE <= DMA_RW6_FIFO_SIZE;
            DMA_STATE <= RW6_ST6;
  
        when RW6_ST6 =>
            if(DMA_READY='1') then
              DMA_READ <= '0';
            end if;
            if(DMA_RW6_TRNSCN_M="11") then
              DMA_RW6_EN <= '0';
              DMA_STATE <= W0_DONE;
            end if;            

      
      end case;
    end if;
  end process;


  DMA_R0_FIFO_CMD_WR <= DMA_R0_READ and DMA_R0_READY_i;
  DMA_R0_FIFO_CMD_IN <= DMA_R0_ADDR & DMA_R0_SIZE;
  DMA_R0_FIFO_SIZE <= DMA_R0_FIFO_CMD_OUT(DMA_R0_SIZE'length-1 downto 0);
  DMA_R0_FIFO_ADDR <= DMA_R0_FIFO_CMD_OUT(DMA_R0_FIFO_CMD_OUT'length-1 downto DMA_R0_SIZE'length);

--i_DMA_R0_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
--   generic map (
--    FIFO_DEPTH  => DMA_RD_FIFO_CMD_DEPTH         ,
--    FIFO_WIDTH  => DMA_RD_FIFO_CMD_WIDTH         ,
--    RAM_STYLE   => "block"
--    )    
--    port map (
--    CLK_WR      => DMA_R0_CLK ,
--    RST_WR      => DMA_R0_RST ,
--    CLR_WR      =>  '0',
--    WRREQ       =>  DMA_R0_FIFO_CMD_WR,
--    WRDATA      =>  DMA_R0_FIFO_CMD_IN,
--    CLK_RD      =>  DMA_CLK           ,
--    RST_RD      =>  DMA_RST           ,
--    CLR_RD      =>  '0'               ,
--    RDREQ       =>  DMA_R0_FIFO_RD_CMD,
--    RDDATA      =>  DMA_R0_FIFO_CMD_OUT,
--    EMPTY_RD    =>  DMA_R0_EMPTY_RD_CMD ,
--    FIFO_CNT_RD =>  DMA_R0_FIFO_CNT_CMD
--    );

  i_DMA_R0_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R0_FIFO_CMD_OUT,
      empty => DMA_R0_EMPTY_RD_CMD,
      rd_data_count => DMA_R0_FIFO_CNT_CMD,
      din => DMA_R0_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_R0_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_R0_CLK,
      wr_en => DMA_R0_FIFO_CMD_WR 
   );

    DMA_R0_FIFO_WR <= DMA_RDDAV and DMA_R0_EN;

  --i_DMA_R0_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_DEPTH        ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_WIDTH        ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_CLK ,
  --  RST_WR      => DMA_RST ,
  --  CLR_WR      =>  '0'    ,
  --  WRREQ       =>  DMA_R0_FIFO_WR,
  --  WRDATA      =>  DMA_RDDATA     ,
  --  CLK_RD      =>  DMA_R0_CLK     ,
  --  RST_RD      =>  DMA_R0_RST     ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R0_FIFO_RD    ,
  --  RDDATA      =>  DMA_R0_FIFO_OUT   ,
  --  EMPTY_RD    =>  DMA_R0_EMPTY_RD   ,
  --  FIFO_CNT_RD =>  DMA_R0_FIFO_CNT          
  --  );
  i_DMA_R0_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R0_FIFO_OUT,
      empty => DMA_R0_EMPTY_RD,
      wr_data_count => DMA_R0_FIFO_CNT_WR,
      rd_data_count => DMA_R0_FIFO_CNT,
      din => DMA_RDDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_R0_CLK,
      rd_en => DMA_R0_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_CLK,
      wr_en => DMA_R0_FIFO_WR 
   );

    DMA_R0_RDDATA <= DMA_R0_FIFO_OUT;

    DMA_R0_READY_i <= '1' when DMA_R0_ST = R0_S0 else '0';

     process(DMA_R0_CLK, DMA_R0_RST)
    begin
      if(DMA_R0_RST='1') then
        DMA_R0_SIZEi <= (others=>'0');
        DMA_R0_ST <= R0_S0;
        DMA_R0_DONE <= '0';
        DMA_R0_FIFO_RD<='0';
        --DMA_R0_READY_i <= '1';
        DMA_R0_RDDAV <= '0';
        --DMA_R0_RDDATA <= (others =>'0');
        DMA_R0_TRNSCN <= "00";
        DMA_R0_REQ <= (others=>'0');
      elsif rising_edge(DMA_R0_CLK) then

        DMA_R0_RDDAV <= DMA_R0_FIFO_RD;
        --DMA_R0_RDDATA <= DMA_R0_FIFO_OUT;
        case DMA_R0_ST is
          when R0_S0 =>
            --if DMA_R0_READ='1' and DMA_R0_READY_i='1' then 
            if DMA_R0_READ='1' then 
              DMA_R0_TRNSCN <= "01";
              DMA_R0_SIZEi <= DMA_R0_SIZEi + unsigned(DMA_R0_SIZE);
              --DMA_R0_ST <= R0_S1;
              --DMA_R0_READY_i <= '0';
              DMA_R0_REQ <= DMA_R0_REQ + 1;
            end if;
            --if (DMA_R0_READ='0' and DMA_R0_READY_i='1' and DMA_R0_REQ>0) or (DMA_R0_REQ=RD_MAX_REQ-1) then
            if (DMA_R0_READ='0' and DMA_R0_REQ>0) or (DMA_R0_REQ=RD_MAX_REQ-1) then
              DMA_R0_REQ <= (others=>'0');
              DMA_R0_TRNSCN <= "10";
              DMA_R0_ST <= R0_S1;
              --DMA_R0_READY_i <= '0';
            end if;

          when R0_S1 =>
            if(DMA_R0_EMPTY_RD/='1' and unsigned(DMA_R0_FIFO_CNT)=(DMA_R0_SIZEi)) then
              DMA_R0_TRNSCN <= "11";
              DMA_R0_DONE <= '1';
              DMA_R0_FIFO_RD <='1';
              DMA_R0_SIZEi <= (DMA_R0_SIZEi -1);
              DMA_R0_ST <= R0_S2;
            end if;

          when R0_S2 =>
            if(DMA_R0_FIFO_RD='1' and (DMA_R0_SIZEi)=0) then
              DMA_R0_TRNSCN <= "00";
              DMA_R0_FIFO_RD <='0';
              DMA_R0_DONE <= '0';
              --DMA_R0_READY_i <= '1';
              DMA_R0_ST <= R0_S0;
            else
              DMA_R0_SIZEi <= (DMA_R0_SIZEi -1);
            end if;
        end case;
      end if;
    end process;

  xpm_cdc_gray_inst_R0: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_R0_CLK,
    src_in_bin => DMA_R0_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_R0_TRNSCN_M
  );


  DMA_R1_FIFO_CMD_WR <= DMA_R1_READ and DMA_R1_READY_i;
  DMA_R1_FIFO_CMD_IN <= DMA_R1_ADDR & DMA_R1_SIZE;
  DMA_R1_FIFO_SIZE <= DMA_R1_FIFO_CMD_OUT(DMA_R1_SIZE'length-1 downto 0);
  DMA_R1_FIFO_ADDR <= DMA_R1_FIFO_CMD_OUT(DMA_R1_FIFO_CMD_OUT'length-1 downto DMA_R1_SIZE'length);

  --i_DMA_R1_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_CMD_DEPTH         ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_CMD_WIDTH         ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_R1_CLK ,
  --  RST_WR      => DMA_R1_RST ,
  --  CLR_WR      =>  '0',
  --  WRREQ       =>  DMA_R1_FIFO_CMD_WR,
  --  WRDATA      =>  DMA_R1_FIFO_CMD_IN,
  --  CLK_RD      =>  DMA_CLK           ,
  --  RST_RD      =>  DMA_RST           ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R1_FIFO_RD_CMD,
  --  RDDATA      =>  DMA_R1_FIFO_CMD_OUT,
  --  EMPTY_RD    =>  DMA_R1_EMPTY_RD_CMD ,
  --  FIFO_CNT_RD =>  DMA_R1_FIFO_CNT_CMD
  --  );

  i_DMA_R1_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R1_FIFO_CMD_OUT,
      empty => DMA_R1_EMPTY_RD_CMD,
      rd_data_count => DMA_R1_FIFO_CNT_CMD,
      din => DMA_R1_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_R1_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_R1_CLK,
      wr_en => DMA_R1_FIFO_CMD_WR 
   );

  DMA_R1_FIFO_WR <= DMA_RDDAV and DMA_R1_EN;

  --i_DMA_R1_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_DEPTH        ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_WIDTH        ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_CLK ,
  --  RST_WR      => DMA_RST ,
  --  CLR_WR      =>  '0'    ,
  --  WRREQ       =>  DMA_R1_FIFO_WR ,
  --  WRDATA      =>  DMA_RDDATA     ,
  --  CLK_RD      =>  DMA_R1_CLK     ,
  --  RST_RD      =>  DMA_R1_RST     ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R1_FIFO_RD    ,
  --  RDDATA      =>  DMA_R1_FIFO_OUT   ,
  --  EMPTY_RD    =>  DMA_R1_EMPTY_RD   ,
  --  FIFO_CNT_RD =>  DMA_R1_FIFO_CNT          
  --  );

  i_DMA_R1_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R1_FIFO_OUT,
      empty => DMA_R1_EMPTY_RD,
      rd_data_count => DMA_R1_FIFO_CNT,
      din => DMA_RDDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_R1_CLK,
      rd_en => DMA_R1_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_CLK,
      wr_en => DMA_R1_FIFO_WR 
   );

    DMA_R1_RDDATA <= DMA_R1_FIFO_OUT;


    DMA_R1_READY_i <= '1' when DMA_R1_ST=R1_S0 else '0';

    process(DMA_R1_CLK, DMA_R1_RST)
    begin
      if(DMA_R1_RST='1') then
        DMA_R1_SIZEi <= (others=>'0');
        DMA_R1_ST <= R1_S0;
        DMA_R1_DONE <= '0';
        DMA_R1_FIFO_RD <='0';
        --DMA_R1_READY_i <= '1';
        DMA_R1_RDDAV <= '0';
        --DMA_R1_RDDATA <= (others =>'0');
        DMA_R1_TRNSCN <= "00";
        DMA_R1_REQ <= (others=>'0');
      elsif rising_edge(DMA_R1_CLK) then

        DMA_R1_RDDAV <= DMA_R1_FIFO_RD;
        --DMA_R1_RDDATA <= DMA_R1_FIFO_OUT;
        case DMA_R1_ST is
          when R1_S0 =>
            --if DMA_R1_READ='1' and DMA_R1_READY_i='1' then 
            if DMA_R1_READ='1' then 
              DMA_R1_TRNSCN <= "01";
              DMA_R1_SIZEi <= DMA_R1_SIZEi + unsigned(DMA_R1_SIZE);
              --DMA_R1_ST <= R1_S1;
              --DMA_R1_READY_i <= '0';
              DMA_R1_REQ <= DMA_R1_REQ + 1;
            end if;
            --if (DMA_R1_READ='0' and DMA_R1_READY_i='1' and DMA_R1_REQ>0) or (DMA_R1_REQ=RD_MAX_REQ-1) then
            if (DMA_R1_READ='0' and DMA_R1_REQ>0) or (DMA_R1_REQ=RD_MAX_REQ-1) then
              DMA_R1_REQ <= (others=>'0');
              DMA_R1_TRNSCN <= "10";
              DMA_R1_ST <= R1_S1;
              --DMA_R1_READY_i <= '0';
            end if;

          when R1_S1 =>
            if(DMA_R1_EMPTY_RD/='1' and unsigned(DMA_R1_FIFO_CNT)=(DMA_R1_SIZEi)) then
              DMA_R1_TRNSCN <= "11";
              DMA_R1_DONE <= '1';
              DMA_R1_FIFO_RD <='1';
              DMA_R1_SIZEi <= (DMA_R1_SIZEi -1);
              DMA_R1_ST <= R1_S2;
            end if;

          when R1_S2 =>
            if(DMA_R1_FIFO_RD='1' and (DMA_R1_SIZEi)=0) then
              DMA_R1_TRNSCN <= "00";
              DMA_R1_FIFO_RD <='0';
              DMA_R1_DONE <= '0';
              --DMA_R1_READY_i <= '1';
              DMA_R1_ST <= R1_S0;
            else
              DMA_R1_SIZEi <= (DMA_R1_SIZEi -1);
            end if;
        end case;
      end if;
    end process;


  xpm_cdc_gray_inst_R1: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_R1_CLK,
    src_in_bin => DMA_R1_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_R1_TRNSCN_M
  );

  DMA_R2_FIFO_CMD_WR <= DMA_R2_READ and DMA_R2_READY_i;
  DMA_R2_FIFO_CMD_IN <= DMA_R2_ADDR & DMA_R2_SIZE;
  DMA_R2_FIFO_SIZE <= DMA_R2_FIFO_CMD_OUT(DMA_R2_SIZE'length-1 downto 0);
  DMA_R2_FIFO_ADDR <= DMA_R2_FIFO_CMD_OUT(DMA_R2_FIFO_CMD_OUT'length-1 downto DMA_R2_SIZE'length);


--i_DMA_R2_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
--   generic map (
--    FIFO_DEPTH  => DMA_RD_FIFO_CMD_DEPTH         ,
--    FIFO_WIDTH  => DMA_RD_FIFO_CMD_WIDTH         ,
--    RAM_STYLE   => "block"
--    )    
--    port map (
--    CLK_WR      => DMA_R2_CLK ,
--    RST_WR      => DMA_R2_RST ,
--    CLR_WR      =>  '0',
--    WRREQ       =>  DMA_R2_FIFO_CMD_WR,
--    WRDATA      =>  DMA_R2_FIFO_CMD_IN,
--    CLK_RD      =>  DMA_CLK           ,
--    RST_RD      =>  DMA_RST           ,
--    CLR_RD      =>  '0'               ,
--    RDREQ       =>  DMA_R2_FIFO_RD_CMD,
--    RDDATA      =>  DMA_R2_FIFO_CMD_OUT,
--    EMPTY_RD    =>  DMA_R2_EMPTY_RD_CMD ,
--    FIFO_CNT_RD =>  DMA_R2_FIFO_CNT_CMD
--    );

  i_DMA_R2_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R2_FIFO_CMD_OUT,
      empty => DMA_R2_EMPTY_RD_CMD,
      rd_data_count => DMA_R2_FIFO_CNT_CMD,
      din => DMA_R2_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_R2_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_R2_CLK,
      wr_en => DMA_R2_FIFO_CMD_WR 
   );

  DMA_R2_FIFO_WR <= DMA_RDDAV and DMA_R2_EN;

  --i_DMA_R2_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_DEPTH          ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_WIDTH          ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_CLK ,
  --  RST_WR      => DMA_RST ,
  --  CLR_WR      =>  '0'    ,
  --  WRREQ       =>  DMA_R2_FIFO_WR ,
  --  WRDATA      =>  DMA_RDDATA     ,
  --  CLK_RD      =>  DMA_R2_CLK     ,
  --  RST_RD      =>  DMA_R2_RST     ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R2_FIFO_RD    ,
  --  RDDATA      =>  DMA_R2_FIFO_OUT   ,
  --  EMPTY_RD    =>  DMA_R2_EMPTY_RD   ,
  --  FIFO_CNT_RD =>  DMA_R2_FIFO_CNT          
  --  );

       i_DMA_R2_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R2_FIFO_OUT,
      empty => DMA_R2_EMPTY_RD,
      rd_data_count => DMA_R2_FIFO_CNT,
      din => DMA_RDDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_R2_CLK,
      rd_en => DMA_R2_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_CLK,
      wr_en => DMA_R2_FIFO_WR 
   );

    DMA_R2_RDDATA <= DMA_R2_FIFO_OUT;

    DMA_R2_READY_i <= '1' when DMA_R2_ST = R2_S0 else '0';

    process(DMA_R2_CLK, DMA_R2_RST)
    begin
      if(DMA_R2_RST='1') then
        DMA_R2_SIZEi <= (others=>'0');
        DMA_R2_ST <= R2_S0;
        DMA_R2_DONE <= '0';
        DMA_R2_FIFO_RD <='0';
        --DMA_R2_READY_i <= '1';
        DMA_R2_RDDAV <= '0';
        --DMA_R2_RDDATA <= (others =>'0');
        DMA_R2_TRNSCN <= "00";
        DMA_R2_REQ <= (others=>'0');
      elsif rising_edge(DMA_R2_CLK) then

        DMA_R2_RDDAV <= DMA_R2_FIFO_RD;
        --DMA_R2_RDDATA <= DMA_R2_FIFO_OUT;
        case DMA_R2_ST is
          when R2_S0 =>
            --if DMA_R2_READ='1' and DMA_R2_READY_i='1' then 
            if DMA_R2_READ='1' then 
              DMA_R2_TRNSCN <= "01";
              DMA_R2_SIZEi <= DMA_R2_SIZEi+ unsigned(DMA_R2_SIZE);
              --DMA_R2_ST <= R2_S1;
              --DMA_R2_READY_i <= '0';
              DMA_R2_REQ <= DMA_R2_REQ + 1;
            end if;
            --if (DMA_R2_READ='0' and DMA_R2_READY_i='1' and DMA_R2_REQ>0) or (DMA_R2_REQ=RD_MAX_REQ-1) then
            if (DMA_R2_READ='0' and DMA_R2_REQ>0) or (DMA_R2_REQ=RD_MAX_REQ-1) then
              DMA_R2_REQ <= (others=>'0');
              DMA_R2_TRNSCN <= "10";
              DMA_R2_ST <= R2_S1;
              --DMA_R2_READY_i <= '0';
            end if;

          when R2_S1 =>
            if(DMA_R2_EMPTY_RD/='1' and unsigned(DMA_R2_FIFO_CNT)=(DMA_R2_SIZEi)) then
              DMA_R2_TRNSCN <= "11";
              DMA_R2_DONE <= '1';
              DMA_R2_FIFO_RD <='1';
              DMA_R2_SIZEi <= (DMA_R2_SIZEi -1);
              DMA_R2_ST <= R2_S2;
            end if;

          when R2_S2 =>
            if(DMA_R2_FIFO_RD='1' and (DMA_R2_SIZEi)=0) then
              DMA_R2_TRNSCN <= "00";
              DMA_R2_FIFO_RD <='0';
              DMA_R2_DONE <= '0';
              --DMA_R2_READY_i <= '1';
              DMA_R2_ST <= R2_S0;
            else
              DMA_R2_SIZEi <= (DMA_R2_SIZEi -1);
            end if;
        end case;
      end if;
    end process;


  xpm_cdc_gray_inst_R2: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_R2_CLK,
    src_in_bin => DMA_R2_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_R2_TRNSCN_M
  );



  DMA_R3_FIFO_CMD_WR <= DMA_R3_READ and DMA_R3_READY_i;
  DMA_R3_FIFO_CMD_IN <= DMA_R3_ADDR & DMA_R3_SIZE;
  DMA_R3_FIFO_SIZE <= DMA_R3_FIFO_CMD_OUT(DMA_R3_SIZE'length-1 downto 0);
  DMA_R3_FIFO_ADDR <= DMA_R3_FIFO_CMD_OUT(DMA_R3_FIFO_CMD_OUT'length-1 downto DMA_R3_SIZE'length);
  
--i_DMA_R3_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
--   generic map (
--    FIFO_DEPTH  => DMA_RD_FIFO_CMD_DEPTH         ,
--    FIFO_WIDTH  => DMA_RD_FIFO_CMD_WIDTH         ,
--    RAM_STYLE   => "block"
--    )    
--    port map (
--    CLK_WR      => DMA_R3_CLK ,
--    RST_WR      => DMA_R3_RST ,
--    CLR_WR      =>  '0',
--    WRREQ       =>  DMA_R3_FIFO_CMD_WR,
--    WRDATA      =>  DMA_R3_FIFO_CMD_IN,
--    CLK_RD      =>  DMA_CLK           ,
--    RST_RD      =>  DMA_RST           ,
--    CLR_RD      =>  '0'               ,
--    RDREQ       =>  DMA_R3_FIFO_RD_CMD,
--    RDDATA      =>  DMA_R3_FIFO_CMD_OUT,
--    EMPTY_RD    =>  DMA_R3_EMPTY_RD_CMD ,
--    FIFO_CNT_RD =>  DMA_R3_FIFO_CNT_CMD
--    );

   i_DMA_R3_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R3_FIFO_CMD_OUT,
      empty => DMA_R3_EMPTY_RD_CMD,
      rd_data_count => DMA_R3_FIFO_CNT_CMD,
      din => DMA_R3_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_R3_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_R3_CLK,
      wr_en => DMA_R3_FIFO_CMD_WR 
   );

  DMA_R3_FIFO_WR <= DMA_RDDAV and DMA_R3_EN;

  --i_DMA_R3_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_DEPTH          ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_WIDTH          ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_CLK ,
  --  RST_WR      => DMA_RST ,
  --  CLR_WR      =>  '0'    ,
  --  WRREQ       =>  DMA_R3_FIFO_WR ,
  --  WRDATA      =>  DMA_RDDATA     ,
  --  CLK_RD      =>  DMA_R3_CLK     ,
  --  RST_RD      =>  DMA_R3_RST     ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R3_FIFO_RD    ,
  --  RDDATA      =>  DMA_R3_FIFO_OUT   ,
  --  EMPTY_RD    =>  DMA_R3_EMPTY_RD   ,
  --  FIFO_CNT_RD =>  DMA_R3_FIFO_CNT          
  --  );
       i_DMA_R3_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R3_FIFO_OUT,
      empty => DMA_R3_EMPTY_RD,
      rd_data_count => DMA_R3_FIFO_CNT,
      din => DMA_RDDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_R3_CLK,
      rd_en => DMA_R3_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_CLK,
      wr_en => DMA_R3_FIFO_WR 
   );

    DMA_R3_RDDATA <= DMA_R3_FIFO_OUT;

    DMA_R3_READY_i <= '1' when DMA_R3_ST = R3_S0 else '0';

    process(DMA_R3_CLK, DMA_R3_RST)
    begin
      if(DMA_R3_RST='1') then
        DMA_R3_SIZEi <= (others=>'0');
        DMA_R3_ST <= R3_S0;
        DMA_R3_DONE <= '0';
        DMA_R3_FIFO_RD <='0';
        --DMA_R3_READY_i <= '1';
        DMA_R3_RDDAV <= '0';
        --DMA_R3_RDDATA <= (others =>'0');
        DMA_R3_TRNSCN <= "00";
        DMA_R3_REQ <= (others=>'0');
      elsif rising_edge(DMA_R3_CLK) then

        DMA_R3_RDDAV <= DMA_R3_FIFO_RD;
        --DMA_R3_RDDATA <= DMA_R3_FIFO_OUT;
        case DMA_R3_ST is
          when R3_S0 =>
            --if DMA_R3_READ='1' and DMA_R3_READY_i='1' then 
            if DMA_R3_READ='1' then 
              DMA_R3_TRNSCN <= "01";
              DMA_R3_SIZEi <= DMA_R3_SIZEi + unsigned(DMA_R3_SIZE);
              --DMA_R3_ST <= R3_S1;
              --DMA_R3_READY_i <= '0';
              DMA_R3_REQ <= DMA_R3_REQ + 1;
            end if;
            --if (DMA_R3_READ='0' and DMA_R3_READY_i='1' and DMA_R3_REQ>0) or (DMA_R3_REQ=RD_MAX_REQ-1) then
            if (DMA_R3_READ='0' and DMA_R3_REQ>0) or (DMA_R3_REQ=RD_MAX_REQ-1) then
              DMA_R3_REQ <= (others=>'0');
              DMA_R3_TRNSCN <= "10";
              DMA_R3_ST <= R3_S1;
              --DMA_R3_READY_i <= '0';
            end if;

          when R3_S1 =>
            if(DMA_R3_EMPTY_RD/='1' and unsigned(DMA_R3_FIFO_CNT)=(DMA_R3_SIZEi)) then
              DMA_R3_TRNSCN <= "11";
              DMA_R3_DONE <= '1';
              DMA_R3_FIFO_RD <='1';
              DMA_R3_SIZEi <= (DMA_R3_SIZEi -1);
              DMA_R3_ST <= R3_S2;
            end if;

          when R3_S2 =>
            if(DMA_R3_FIFO_RD='1' and (DMA_R3_SIZEi)=0) then
              DMA_R3_TRNSCN <= "00";
              DMA_R3_FIFO_RD <='0';
              DMA_R3_DONE <= '0';
              --DMA_R3_READY_i <= '1';
              DMA_R3_ST <= R3_S0;
            else
              DMA_R3_SIZEi <= (DMA_R3_SIZEi -1);
            end if;
        end case;
      end if;
    end process;

xpm_cdc_gray_inst_R3: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_R3_CLK,
    src_in_bin => DMA_R3_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_R3_TRNSCN_M
  );


  DMA_R4_FIFO_CMD_WR <= DMA_R4_READ and DMA_R4_READY_i;
  DMA_R4_FIFO_CMD_IN <= DMA_R4_ADDR & DMA_R4_SIZE;
  DMA_R4_FIFO_SIZE <= DMA_R4_FIFO_CMD_OUT(DMA_R4_SIZE'length-1 downto 0);
  DMA_R4_FIFO_ADDR <= DMA_R4_FIFO_CMD_OUT(DMA_R4_FIFO_CMD_OUT'length-1 downto DMA_R4_SIZE'length);

  --i_DMA_R4_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_CMD_DEPTH         ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_CMD_WIDTH         ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_R4_CLK ,
  --  RST_WR      => DMA_R4_RST ,
  --  CLR_WR      =>  '0',
  --  WRREQ       =>  DMA_R4_FIFO_CMD_WR,
  --  WRDATA      =>  DMA_R4_FIFO_CMD_IN,
  --  CLK_RD      =>  DMA_CLK           ,
  --  RST_RD      =>  DMA_RST           ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R4_FIFO_RD_CMD,
  --  RDDATA      =>  DMA_R4_FIFO_CMD_OUT,
  --  EMPTY_RD    =>  DMA_R4_EMPTY_RD_CMD ,
  --  FIFO_CNT_RD =>  DMA_R4_FIFO_CNT_CMD
  --  );

  i_DMA_R4_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R4_FIFO_CMD_OUT,
      empty => DMA_R4_EMPTY_RD_CMD,
      rd_data_count => DMA_R4_FIFO_CNT_CMD,
      din => DMA_R4_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_R4_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_R4_CLK,
      wr_en => DMA_R4_FIFO_CMD_WR 
   );

  DMA_R4_FIFO_WR <= DMA_RDDAV and DMA_R4_EN;

  --i_DMA_R4_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_DEPTH        ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_WIDTH        ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_CLK ,
  --  RST_WR      => DMA_RST ,
  --  CLR_WR      =>  '0'    ,
  --  WRREQ       =>  DMA_R4_FIFO_WR ,
  --  WRDATA      =>  DMA_RDDATA     ,
  --  CLK_RD      =>  DMA_R4_CLK     ,
  --  RST_RD      =>  DMA_R4_RST     ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R4_FIFO_RD    ,
  --  RDDATA      =>  DMA_R4_FIFO_OUT   ,
  --  EMPTY_RD    =>  DMA_R4_EMPTY_RD   ,
  --  FIFO_CNT_RD =>  DMA_R4_FIFO_CNT          
  --  );
       i_DMA_R4_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R4_FIFO_OUT,
      empty => DMA_R4_EMPTY_RD,
      rd_data_count => DMA_R4_FIFO_CNT,
      din => DMA_RDDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_R4_CLK,
      rd_en => DMA_R4_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_CLK,
      wr_en => DMA_R4_FIFO_WR 
   );

    DMA_R4_RDDATA <= DMA_R4_FIFO_OUT;

    DMA_R4_READY_i <= '1' when DMA_R4_ST = R4_S0 else '0';

    process(DMA_R4_CLK, DMA_R4_RST)
    begin
      if(DMA_R4_RST='1') then
        DMA_R4_SIZEi <= (others=>'0');
        DMA_R4_ST <= R4_S0;
        DMA_R4_DONE <= '0';
        DMA_R4_FIFO_RD <='0';
        --DMA_R4_READY_i <= '1';
        DMA_R4_RDDAV <= '0';
        --DMA_R1_RDDATA <= (others =>'0');
        DMA_R4_TRNSCN <= "00";
        DMA_R4_REQ <= (others=>'0');
      elsif rising_edge(DMA_R4_CLK) then

        DMA_R4_RDDAV <= DMA_R4_FIFO_RD;
        --DMA_R1_RDDATA <= DMA_R1_FIFO_OUT;
        case DMA_R4_ST is
          when R4_S0 =>
            --if DMA_R4_READ='1' and DMA_R4_READY_i='1' then 
            if DMA_R4_READ='1' then 
              DMA_R4_TRNSCN <= "01";
              DMA_R4_SIZEi <= DMA_R4_SIZEi + unsigned(DMA_R4_SIZE);
              --DMA_R1_ST <= R1_S1;
              --DMA_R1_READY_i <= '0';
              DMA_R4_REQ <= DMA_R4_REQ + 1;
            end if;
            --if (DMA_R4_READ='0' and DMA_R4_READY_i='1' and DMA_R4_REQ>0) or (DMA_R4_REQ=RD_MAX_REQ-1) then
            if (DMA_R4_READ='0' and DMA_R4_REQ>0) or (DMA_R4_REQ=RD_MAX_REQ-1) then
              DMA_R4_REQ <= (others=>'0');
              DMA_R4_TRNSCN <= "10";
              DMA_R4_ST <= R4_S1;
              --DMA_R4_READY_i <= '0';
            end if;

          when R4_S1 =>
            if(DMA_R4_EMPTY_RD/='1' and unsigned(DMA_R4_FIFO_CNT)=(DMA_R4_SIZEi)) then
              DMA_R4_TRNSCN <= "11";
              DMA_R4_DONE <= '1';
              DMA_R4_FIFO_RD <='1';
              DMA_R4_SIZEi <= (DMA_R4_SIZEi -1);
              DMA_R4_ST <= R4_S2;
            end if;

          when R4_S2 =>
            if(DMA_R4_FIFO_RD='1' and (DMA_R4_SIZEi)=0) then
              DMA_R4_TRNSCN <= "00";
              DMA_R4_FIFO_RD <='0';
              DMA_R4_DONE <= '0';
              --DMA_R4_READY_i <= '1';
              DMA_R4_ST <= R4_S0;
            else
              DMA_R4_SIZEi <= (DMA_R4_SIZEi -1);
            end if;
        end case;
      end if;
    end process;


xpm_cdc_gray_inst_R4: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_R4_CLK,
    src_in_bin => DMA_R4_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_R4_TRNSCN_M
  );

  DMA_R5_FIFO_CMD_WR <= DMA_R5_READ and DMA_R5_READY_i;
  DMA_R5_FIFO_CMD_IN <= DMA_R5_ADDR & DMA_R5_SIZE;
  DMA_R5_FIFO_SIZE <= DMA_R5_FIFO_CMD_OUT(DMA_R5_SIZE'length-1 downto 0);
  DMA_R5_FIFO_ADDR <= DMA_R5_FIFO_CMD_OUT(DMA_R5_FIFO_CMD_OUT'length-1 downto DMA_R5_SIZE'length);

  --i_DMA_R5_DCFIFO_CMD: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_CMD_DEPTH         ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_CMD_WIDTH         ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_R5_CLK ,
  --  RST_WR      => DMA_R5_RST ,
  --  CLR_WR      =>  '0',
  --  WRREQ       =>  DMA_R5_FIFO_CMD_WR,
  --  WRDATA      =>  DMA_R5_FIFO_CMD_IN,
  --  CLK_RD      =>  DMA_CLK           ,
  --  RST_RD      =>  DMA_RST           ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R5_FIFO_RD_CMD,
  --  RDDATA      =>  DMA_R5_FIFO_CMD_OUT,
  --  EMPTY_RD    =>  DMA_R5_EMPTY_RD_CMD ,
  --  FIFO_CNT_RD =>  DMA_R5_FIFO_CNT_CMD
  --  );
    i_DMA_R5_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_CMD_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R5_FIFO_CMD_OUT,
      empty => DMA_R5_EMPTY_RD_CMD,
      rd_data_count => DMA_R5_FIFO_CNT_CMD,
      din => DMA_R5_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_R5_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_R5_CLK,
      wr_en => DMA_R5_FIFO_CMD_WR 
   );

  DMA_R5_FIFO_WR <= DMA_RDDAV and DMA_R5_EN;

  --i_DMA_R5_DCFIFO_DATA: entity WORK.FIFO_DUAL_CLK
  -- generic map (
  --  FIFO_DEPTH  => DMA_RD_FIFO_DEPTH        ,
  --  FIFO_WIDTH  => DMA_RD_FIFO_WIDTH        ,
  --  RAM_STYLE   => "block"
  --  )    
  --  port map (
  --  CLK_WR      => DMA_CLK ,
  --  RST_WR      => DMA_RST ,
  --  CLR_WR      =>  '0'    ,
  --  WRREQ       =>  DMA_R5_FIFO_WR ,
  --  WRDATA      =>  DMA_RDDATA     ,
  --  CLK_RD      =>  DMA_R5_CLK     ,
  --  RST_RD      =>  DMA_R5_RST     ,
  --  CLR_RD      =>  '0'               ,
  --  RDREQ       =>  DMA_R5_FIFO_RD    ,
  --  RDDATA      =>  DMA_R5_FIFO_OUT   ,
  --  EMPTY_RD    =>  DMA_R5_EMPTY_RD   ,
  --  FIFO_CNT_RD =>  DMA_R5_FIFO_CNT          
  --  );

     i_DMA_R5_DCFIFO_DATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_R5_FIFO_OUT,
      empty => DMA_R5_EMPTY_RD,
      rd_data_count => DMA_R5_FIFO_CNT,
      din => DMA_RDDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_R5_CLK,
      rd_en => DMA_R5_FIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_CLK,
      wr_en => DMA_R5_FIFO_WR 
   );

    DMA_R5_RDDATA <= DMA_R5_FIFO_OUT;

    DMA_R5_READY_i <= '1' when DMA_R5_ST = R5_S0 else '0';

    process(DMA_R5_CLK, DMA_R5_RST)
    begin
      if(DMA_R5_RST='1') then
        DMA_R5_SIZEi <= (others=>'0');
        DMA_R5_ST <= R5_S0;
        DMA_R5_DONE <= '0';
        DMA_R5_FIFO_RD <='0';
        --DMA_R5_READY_i <= '1';
        DMA_R5_RDDAV <= '0';
        --DMA_R1_RDDATA <= (others =>'0');
        DMA_R5_TRNSCN <= "00";
        DMA_R5_REQ <= (others=>'0');
      elsif rising_edge(DMA_R5_CLK) then

        DMA_R5_RDDAV <= DMA_R5_FIFO_RD;
        --DMA_R1_RDDATA <= DMA_R1_FIFO_OUT;
        case DMA_R5_ST is
          when R5_S0 =>
            --if DMA_R5_READ='1' and DMA_R5_READY_i='1' then 
            if DMA_R5_READ='1' then 
              DMA_R5_TRNSCN <= "01";
              DMA_R5_SIZEi <= DMA_R5_SIZEi + unsigned(DMA_R5_SIZE);
              --DMA_R1_ST <= R1_S1;
              --DMA_R1_READY_i <= '0';
              DMA_R5_REQ <= DMA_R5_REQ + 1;
            end if;
            --if (DMA_R5_READ='0' and DMA_R5_READY_i='1' and DMA_R5_REQ>0) or (DMA_R5_REQ=RD_MAX_REQ-1) then
            if (DMA_R5_READ='0' and DMA_R5_REQ>0) or (DMA_R5_REQ=RD_MAX_REQ-1) then
              DMA_R5_REQ <= (others=>'0');
              DMA_R5_TRNSCN <= "10";
              DMA_R5_ST <= R5_S1;
              --DMA_R5_READY_i <= '0';
            end if;

          when R5_S1 =>
            if(DMA_R5_EMPTY_RD/='1' and unsigned(DMA_R5_FIFO_CNT)=(DMA_R5_SIZEi)) then
              DMA_R5_TRNSCN <= "11";
              DMA_R5_DONE <= '1';
              DMA_R5_FIFO_RD <='1';
              DMA_R5_SIZEi <= (DMA_R5_SIZEi -1);
              DMA_R5_ST <= R5_S2;
            end if;

          when R5_S2 =>
            if(DMA_R5_FIFO_RD='1' and (DMA_R5_SIZEi)=0) then
              DMA_R5_TRNSCN <= "00";
              DMA_R5_FIFO_RD <='0';
              DMA_R5_DONE <= '0';
              --DMA_R5_READY_i <= '1';
              DMA_R5_ST <= R5_S0;
            else
              DMA_R5_SIZEi <= (DMA_R5_SIZEi -1);
            end if;
        end case;
      end if;
    end process;

xpm_cdc_gray_inst_R5: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_R5_CLK,
    src_in_bin => DMA_R5_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_R5_TRNSCN_M
  );


  process(DMA_RW6_CLK, DMA_RW6_RST)
  begin
    if DMA_RW6_RST='1' then
      RW6_READY_FSM <= RW6_R_IDLE;
      DMA_RW6_TRNSCN <= "00";
      DMA_RW6_READY_i <= '0';
      DMA_RW6_SIZEi <= (others=>'0');
      DMA_RW6_DONE <= '0';
      DMA_RW6_RDFIFO_RD <='0';
      DMA_RW6_RDDAV <= '0';
    elsif rising_edge(DMA_RW6_CLK) then

      DMA_RW6_RDDAV <= DMA_RW6_RDFIFO_RD;

      case RW6_READY_FSM is
        when RW6_R_IDLE =>
          DMA_RW6_TRNSCN <= "00";
          DMA_RW6_READY_i <= '1';
          --if(DMA_W0_WRBURST='1' and DMA_W0_WRITE='1' and DMA_W0_READY_i='1') then
          if(DMA_RW6_WRBURST='1' and DMA_RW6_WRITE='1' and DMA_RW6_READY_i='1') then
            --DMA_W0_READY_i <= '1';
            DMA_RW6_TRNSCN <= "01";
            RW6_READY_FSM <= RW6_R_S1;
          elsif (DMA_RW6_READ='1' and DMA_RW6_READY_i='1') then
            DMA_RW6_READY_i <= '0';
            DMA_RW6_TRNSCN <= "01";
            DMA_RW6_SIZEi <= unsigned(DMA_RW6_SIZE);
            RW6_READY_FSM <= RW6_R_S3;
          end if;


        when RW6_R_S1 =>
         if(DMA_RW6_WRITE='0') then
            DMA_RW6_READY_i <= '0';
            if(DMA_RW6_EMPTY_RD_M ='0')then
              DMA_RW6_TRNSCN <= "10";
              RW6_READY_FSM <= RW6_R_S2;
            end if;
          end if;

        when RW6_R_S2 =>
--          if(DMA_W0_EMPTY_RD_CMD_S='1' and DMA_W0_EMPTY_RD_S = '1') then
          if(DMA_RW6_EMPTY_RD_M ='1')then
            DMA_RW6_TRNSCN <= "11";
            RW6_READY_FSM <= RW6_R_IDLE;
          end if;


        when RW6_R_S3 =>
            DMA_RW6_TRNSCN <= "10";
            if(DMA_RW6_RDEMPTY_RD/='1' and unsigned(DMA_RW6_RDFIFO_CNT)=(DMA_RW6_SIZEi)) then
              DMA_RW6_TRNSCN <= "11";
              DMA_RW6_DONE <= '1';
              DMA_RW6_RDFIFO_RD <='1';
              DMA_RW6_SIZEi <= (DMA_RW6_SIZEi -1);
              RW6_READY_FSM <= RW6_R_S4;
            end if;

          when RW6_R_S4 =>
            if(DMA_RW6_RDFIFO_RD='1' and (DMA_RW6_SIZEi)=0) then
              DMA_RW6_TRNSCN <= "00";
              DMA_RW6_RDFIFO_RD <='0';
              DMA_RW6_DONE <= '0';
              --DMA_R5_READY_i <= '1';
              RW6_READY_FSM <= RW6_R_IDLE;
            else
              DMA_RW6_SIZEi <= (DMA_RW6_SIZEi -1);
            end if;

        end case;
    end if;
  end process;


xpm_cdc_gray_inst_RW6: xpm_cdc_gray
  generic map(
    DEST_SYNC_FF => 4,
    WIDTH     => 2
  )
  port map(
    src_clk => DMA_RW6_CLK,
    src_in_bin => DMA_RW6_TRNSCN,
    dest_clk => DMA_CLK,
    dest_out_bin => DMA_RW6_TRNSCN_M
  );

  DMA_RW6_EMPTY_RD_M <= DMA_RW6_EMPTY_RD_CMD and DMA_RW6_WREMPTY_RD;
 
  DMA_RW6_FIFO_CMD_WR <= ((DMA_RW6_WRITE and DMA_RW6_WRBURST) or DMA_RW6_READ) and DMA_RW6_READY_i;
  DMA_RW6_FIFO_CMD_IN <= DMA_RW6_WRITE & DMA_RW6_ADDR & DMA_RW6_SIZE & DMA_RW6_WRBE;
  DMA_RW6_FIFO_WRnRD <= DMA_RW6_FIFO_CMD_OUT(DMA_RW6_FIFO_CMD_OUT'length-1); 
  DMA_RW6_FIFO_WRBE <= DMA_RW6_FIFO_CMD_OUT(DMA_RW6_WRBE'length-1 downto 0);
  DMA_RW6_FIFO_SIZE <= DMA_RW6_FIFO_CMD_OUT(DMA_RW6_WRBE'length+DMA_RW6_SIZE'length-1 downto DMA_RW6_WRBE'length);
  DMA_RW6_FIFO_ADDR <= DMA_RW6_FIFO_CMD_OUT(DMA_RW6_FIFO_CMD_OUT'length-2 downto DMA_RW6_WRBE'length+DMA_RW6_SIZE'length);


  i_DMA_RW6_DCFIFO_CMD : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_WR_FIFO_CMD_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_WR_FIFO_CMD_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_WR_FIFO_CMD_WIDTH+1,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_WR_FIFO_CMD_WIDTH+1,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_WR_FIFO_CMD_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_RW6_FIFO_CMD_OUT,
      empty => DMA_RW6_EMPTY_RD_CMD,
      rd_data_count => DMA_RW6_FIFO_CNT_CMD,
      din => DMA_RW6_FIFO_CMD_IN,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_RW6_FIFO_RD_CMD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_RW6_CLK,
      wr_en => DMA_RW6_FIFO_CMD_WR 
   );

  DMA_RW6_WRFIFO_WR <= DMA_RW6_WRITE and DMA_RW6_READY_i; 

  i_DMA_RW6_DCFIFO_WRDATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_WR_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_WR_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_WR_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_WR_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_WR_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_RW6_WRFIFO_OUT,
      empty => DMA_RW6_WREMPTY_RD,
      rd_data_count => DMA_RW6_WRFIFO_CNT,
      din => DMA_RW6_WRDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_CLK,
      rd_en => DMA_RW6_WRFIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_RW6_CLK,
      wr_en => DMA_RW6_WRFIFO_WR 
   );

DMA_RW6_RDFIFO_WR <= DMA_RDDAV and DMA_RW6_EN;

i_DMA_RW6_DCFIFO_RDDATA : xpm_fifo_async
   generic map (
      CDC_SYNC_STAGES => 2,       -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 2**(DMA_RD_FIFO_DEPTH),   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1,   -- DECIMAL
      READ_DATA_WIDTH => DMA_RD_FIFO_WIDTH,      -- DECIMAL
      READ_MODE => "std",         -- String
      RELATED_CLOCKS => 0,        -- DECIMAL
      USE_ADV_FEATURES => "0707", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => DMA_RD_FIFO_WIDTH,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => DMA_RD_FIFO_DEPTH+1    -- DECIMAL
   )
   port map (
      dout => DMA_RW6_RDFIFO_OUT,
      empty => DMA_RW6_RDEMPTY_RD,
      rd_data_count => DMA_RW6_RDFIFO_CNT,
      din => DMA_RDDATA,
      injectdbiterr => '0', 
      injectsbiterr => '0', 
      rd_clk => DMA_RW6_CLK,
      rd_en => DMA_RW6_RDFIFO_RD,
      rst => DMA_RST,
      sleep => '0',
      wr_clk => DMA_CLK,
      wr_en => DMA_RW6_RDFIFO_WR 
   );

    DMA_RW6_RDDATA <= DMA_RW6_RDFIFO_OUT;
    
--probe0(0)<= DMA_W0_READY_i;
--probe0(1)<= DMA_W0_WRITE;
--probe0(2)<= DMA_W0_WRBURST;
--probe0(3)<= DMA_W0_FIFO_RD_CMD;
--probe0(4)<= DMA_W0_FIFO_CMD_WR;
--probe0(5)<= DMA_W0_EMPTY_RD_CMD;
--probe0(6)<= DMA_W0_FIFO_WR;
--probe0(7)<= DMA_W0_FIFO_RD;
--probe0(8)<= DMA_W0_EMPTY_RD;
--probe0(10 downto 9)<= DMA_W0_TRNSCN_M;
--probe0(16 downto 11)<= std_logic_vector(to_unsigned(DMA_STATE_t'POS(DMA_STATE), 6));
--probe0(17)<= DMA_READY;
--probe0(18)<= DMA_WRITE_temp;
--probe0(19)<= DMA_WRBURST_temp;
--probe0(25 downto 20)<= std_logic_vector(BURST_COUNT);
--probe0(32 downto 26)<= std_logic_vector(DMA_W0_FIFO_CNT);
----probe0(33 downto 32)<= std_logic_vector(DMA_W0_FIFO_CNT_CMD);
--probe0(33) <= '0';
----probe0(32)<= DMA_W2_READY_i;
----probe0(33)<= DMA_W2_WRITE;
--probe0(34)<= DMA_W2_WRBURST;
--probe0(35)<= DMA_W2_FIFO_RD_CMD;
--probe0(36)<= DMA_W2_FIFO_CMD_WR;
--probe0(37)<= DMA_W2_EMPTY_RD_CMD;
--probe0(38)<= DMA_W2_FIFO_WR;
--probe0(39)<= DMA_W2_FIFO_RD;
--probe0(40)<= DMA_W2_EMPTY_RD;
--probe0(42 downto 41)<= DMA_W2_TRNSCN_M;
--probe0(49 downto 43)<= std_logic_vector(DMA_W2_FIFO_CNT);
----probe0(50 downto 49)<= std_logic_vector(DMA_W2_FIFO_CNT_CMD);
--probe0(50) <= '0';
--probe0(51) <= DMA_R0_READY_i;
--probe0(52) <= DMA_R0_READ;
--probe0(53) <= DMA_W2_READY_i;
--probe0(54) <= DMA_W2_WRITE;
--probe0(55) <= DMA_R1_READY_i;
--probe0(56) <= DMA_R1_READ;
--probe0(57) <= DMA_R2_READY_i;
--probe0(58) <= DMA_R2_READ;
--probe0(59) <= DMA_R3_READY_i;
--probe0(60) <= DMA_R3_READ;
--probe0(61) <= DMA_R4_READY_i;
--probe0(62) <= DMA_R4_READ;
--probe0(63) <= DMA_R5_READY_i;
--probe0(64) <= DMA_R5_READ;
--probe0(65) <= DMA_R4_CLK;
--probe0(66) <= DMA_R4_RST;
--probe0(68 downto 67) <= std_logic_vector(to_unsigned(DMA_R0_ST_t'POS(DMA_R0_ST), 2));
--probe0(70 downto 69) <= std_logic_vector(to_unsigned(DMA_R1_ST_t'POS(DMA_R1_ST), 2));
--probe0(72 downto 71) <= std_logic_vector(to_unsigned(DMA_R2_ST_t'POS(DMA_R2_ST), 2));
--probe0(74 downto 73) <= std_logic_vector(to_unsigned(DMA_R3_ST_t'POS(DMA_R3_ST), 2));
--probe0(76 downto 75) <= std_logic_vector(to_unsigned(DMA_R4_ST_t'POS(DMA_R4_ST), 2));
--probe0(78 downto 77) <= std_logic_vector(to_unsigned(DMA_R5_ST_t'POS(DMA_R5_ST), 2));
--probe0(82 downto 79) <= std_logic_vector(to_unsigned(DMA_STATE_t'POS(DMA_STATE), 4));
--probe0(84 downto 83)   <= DMA_R0_TRNSCN;
--probe0(86 downto 85)   <= DMA_R1_TRNSCN;
--probe0(88 downto 87)   <= DMA_R2_TRNSCN;
--probe0(90 downto 89)   <= DMA_R3_TRNSCN;
--probe0(92 downto 91)   <= DMA_R4_TRNSCN;
--probe0(94 downto 93)   <= DMA_R5_TRNSCN;
--probe0(96 downto 95)   <= DMA_W0_TRNSCN;
--probe0(98 downto 97)   <= DMA_W1_TRNSCN;
--probe0(100 downto 99)  <= DMA_W2_TRNSCN;
--probe0(102 downto 101) <= DMA_R0_TRNSCN_M;
--probe0(104 downto 103) <= DMA_R1_TRNSCN_M;
--probe0(106 downto 105) <= DMA_R2_TRNSCN_M;
--probe0(108 downto 107) <= DMA_R3_TRNSCN_M;
--probe0(110 downto 109) <= DMA_R4_TRNSCN_M;
--probe0(112 downto 111) <= DMA_R5_TRNSCN_M;
--probe0(114 downto 113) <= DMA_W0_TRNSCN_M;
--probe0(116 downto 115) <= DMA_W1_TRNSCN_M;
--probe0(118 downto 117) <= DMA_W2_TRNSCN_M;


--probe0(127 downto 119)<= (others=>'0');

    
--    i_NUC1pt_ila: TOII_TUVE_ila
--    PORT MAP (
--        clk => DMA_CLK,
--        probe0 => probe0
--    );    
    
------------------------
end architecture RTL;
------------------------