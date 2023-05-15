`timescale 1ns / 1ps
//`define ILA_DEBUG_SPI
`define STATE_IDLE 0
`define STATE_SEND 1
`define STATE_READ 2
`define STATE_RECOVERY 3
`define STATE_POWER_LOSS_RECOVERY 4
`define STATE_INTERFACE_RESCUE 5


`include "qspi_defs.vh"

module spi_cmd(
        input             qspi_clk,
        input             fpga_clk,
        input             reset_27mhz,
        input             trigger_src,
        input             qspi_init_done_src,  
        output            busy_dest,
        input      [8:0]  data_in_count_src,
        input      [8:0]  data_out_count_src,
        input      [39:0] data_in_src, // 1B cmd + 4B addr
        input      [7:0]  qspi_cmd_src,
        input             quad_src,       
        inout      [3:0]  DQio,   //SPI interface
        output reg        S ,
        output [7:0]  data_out_byte_dest,
        input         QSPI_RD_FIFO_RQ,
        output        QSPI_RD_FIFO_Empty,
        output        QSPI_RD_FIFO_ALMOST_Empty,
//        output        data_out_byte_valid_dest,
        output reg        RD_FIFO_RQ,
        input      [7:0]  RD_FIFO_DATA,
        output            test_data_out_byte_valid,
        output      [7:0] test_data_out_byte
         
    );
 
 
parameter [4:0] DUMMY_CYCLE_NUM =5'd10;
reg [3:0]   DQ = 4'b1111;
reg         rd_data_out_byte_done; 
reg [2:0]   state;      
reg [7:0]   data_out;
reg [11:0]  bit_cntr_wr;
reg [11:0]  bit_cntr_rd;
reg [11:0]  bit_cntr_rd_byte;
reg [4:0]   Dummy_Cycle_Count;
reg [39:0]  data_in_temp;
reg         temp_cnt;
reg [5:0]   bit_cntr_pp_wr;
reg oe;
reg [7:0] pulse_cnt;

reg [7:0]  data_out_byte;
reg        data_out_byte_valid;
reg        busy;

wire        trigger;
wire        qspi_init_done;                                  
//wire [8:0]  data_in_count;               
//wire [8:0]  data_out_count;              
//wire [39:0] data_in; // 1B cmd + 4B addr 
//wire [7:0]  qspi_cmd;                    
wire        quad;   
wire   QSPI_RD_FIFO_Full;                     

assign test_data_out_byte_valid = data_out_byte_valid;
assign test_data_out_byte       = data_out_byte;

   xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_single_inst_quad (
      .dest_out(quad), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(qspi_clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(fpga_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(quad_src)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );


   xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_single_inst_qspi_init_done (
      .dest_out(qspi_init_done), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(qspi_clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(fpga_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(qspi_init_done_src)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

//   xpm_cdc_gray #(
//      .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
//      .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//      .REG_OUTPUT(0),            // DECIMAL; 0=disable registered output, 1=enable registered output
//      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//      .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
//      .WIDTH(9)                  // DECIMAL; range: 2-32
//   )
//   xpm_cdc_gray_inst_data_in_count (
//      .dest_out_bin(data_in_count), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
//                                   // destination clock domain. This output is combinatorial unless REG_OUTPUT
//                                   // is set to 1.

//      .dest_clk(qspi_clk),         // 1-bit input: Destination clock.
//      .src_clk(fpga_clk),           // 1-bit input: Source clock.
//      .src_in_bin(data_in_count_src)      // WIDTH-bit input: Binary input bus that will be synchronized to the
//                                   // destination clock domain.
//   );

//   xpm_cdc_gray #(
//      .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
//      .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//      .REG_OUTPUT(0),            // DECIMAL; 0=disable registered output, 1=enable registered output
//      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//      .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
//      .WIDTH(9)                  // DECIMAL; range: 2-32
//   )
//   xpm_cdc_gray_inst_data_out_count (
//      .dest_out_bin(data_out_count), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
//                                   // destination clock domain. This output is combinatorial unless REG_OUTPUT
//                                   // is set to 1.

//      .dest_clk(qspi_clk),         // 1-bit input: Destination clock.
//      .src_clk(fpga_clk),           // 1-bit input: Source clock.
//      .src_in_bin(data_out_count_src)      // WIDTH-bit input: Binary input bus that will be synchronized to the
//                                   // destination clock domain.
//   );

//   xpm_cdc_gray #(
//      .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
//      .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//      .REG_OUTPUT(0),            // DECIMAL; 0=disable registered output, 1=enable registered output
//      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//      .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
//      .WIDTH(32)                  // DECIMAL; range: 2-32
//   )
//   xpm_cdc_gray_inst_data_in_32 (
//      .dest_out_bin(data_in[31:0]), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
//                                   // destination clock domain. This output is combinatorial unless REG_OUTPUT
//                                   // is set to 1.

//      .dest_clk(qspi_clk),         // 1-bit input: Destination clock.
//      .src_clk(fpga_clk),           // 1-bit input: Source clock.
//      .src_in_bin(data_in_src[31:0])      // WIDTH-bit input: Binary input bus that will be synchronized to the
//                                   // destination clock domain.
//   );

//   xpm_cdc_gray #(
//      .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
//      .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//      .REG_OUTPUT(0),            // DECIMAL; 0=disable registered output, 1=enable registered output
//      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//      .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
//      .WIDTH(8)                  // DECIMAL; range: 2-32
//   )
//   xpm_cdc_gray_inst_data_in_8 (
//      .dest_out_bin(data_in[39:32]), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
//                                   // destination clock domain. This output is combinatorial unless REG_OUTPUT
//                                   // is set to 1.

//      .dest_clk(qspi_clk),         // 1-bit input: Destination clock.
//      .src_clk(fpga_clk),           // 1-bit input: Source clock.
//      .src_in_bin(data_in_src[39:32])      // WIDTH-bit input: Binary input bus that will be synchronized to the
//                                   // destination clock domain.
//   );



//   xpm_cdc_gray #(
//      .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
//      .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//      .REG_OUTPUT(0),            // DECIMAL; 0=disable registered output, 1=enable registered output
//      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//      .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
//      .WIDTH(8)                  // DECIMAL; range: 2-32
//   )
//   xpm_cdc_gray_inst_qspi_cmd (
//      .dest_out_bin(qspi_cmd), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
//                                   // destination clock domain. This output is combinatorial unless REG_OUTPUT
//                                   // is set to 1.

//      .dest_clk(qspi_clk),         // 1-bit input: Destination clock.
//      .src_clk(fpga_clk),           // 1-bit input: Source clock.
//      .src_in_bin(qspi_cmd_src)      // WIDTH-bit input: Binary input bus that will be synchronized to the
//                                   // destination clock domain.
//   );


   xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_single_inst_trigger_in (
      .dest_out(trigger), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(qspi_clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(fpga_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(trigger_src)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );



   xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_single_inst_busy_out (
      .dest_out(busy_dest), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(fpga_clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(qspi_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(busy)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

//   xpm_cdc_gray #(
//      .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
//      .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//      .REG_OUTPUT(0),            // DECIMAL; 0=disable registered output, 1=enable registered output
//      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//      .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
//      .WIDTH(8)                  // DECIMAL; range: 2-32
//   )
//   xpm_cdc_gray_inst_data_out (
//      .dest_out_bin(data_out_byte_dest), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
//                                   // destination clock domain. This output is combinatorial unless REG_OUTPUT
//                                   // is set to 1.

//      .dest_clk(fpga_clk),         // 1-bit input: Destination clock.
//      .src_clk(qspi_clk),           // 1-bit input: Source clock.
//      .src_in_bin(data_out_byte)      // WIDTH-bit input: Binary input bus that will be synchronized to the
//                                   // destination clock domain.
//   );


//   xpm_cdc_pulse #(
//      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
//      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//      .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
//      .RST_USED(0),       // DECIMAL; 0=no reset, 1=implement reset
//      .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//   )
//   xpm_cdc_pulse_inst_data_out_valid (
//      .dest_pulse(data_out_byte_valid_dest), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
//                               // transfer is correctly initiated on src_pulse input. This output is
//                               // combinatorial unless REG_OUTPUT is set to 1.

//      .dest_clk(fpga_clk),     // 1-bit input: Destination clock.
//      .dest_rst(1'b0),     // 1-bit input: optional; required when RST_USED = 1
//      .src_clk(qspi_clk),       // 1-bit input: Source clock.
//      .src_pulse(data_out_byte_valid),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
//                               // destination clock domain. The minimum gap between each pulse transfer must be
//                               // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
//                               // between the falling edge of a src_pulse to the rising edge of the next
//                               // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
//                               // will generate a pulse the size of one dest_clk period in the destination
//                               // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
//                               // src_rst and/or dest_rst are asserted.
//      .src_rst(1'b0)        // 1-bit input: optional; required when RST_USED = 1
//   );




   xpm_fifo_async #(
      .CDC_SYNC_STAGES(2),       // DECIMAL
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(512),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),   // DECIMAL
      .READ_DATA_WIDTH(8),      // DECIMAL
      .READ_MODE("std"),         // String
      .RELATED_CLOCKS(0),        // DECIMAL
      .USE_ADV_FEATURES("0707"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(8),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
   )
   xpm_fifo_async_inst_QSPI_WR_DATA_FIFO (
      .almost_empty(QSPI_RD_FIFO_ALMOST_Empty),   // 1-bit output: Almost Empty : When asserted, this signal indicates that
                                     // only one more read can be performed before the FIFO goes to empty.

      .almost_full(),     // 1-bit output: Almost Full: When asserted, this signal indicates that
                                     // only one more write can be performed before the FIFO is full.

      .data_valid(),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                     // that valid data is available on the output bus (dout).

      .dbiterr(),             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
                                     // a double-bit error and data in the FIFO core is corrupted.

      .dout(data_out_byte_dest),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                     // when reading the FIFO.

      .empty(QSPI_RD_FIFO_Empty),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
                                     // FIFO is empty. Read requests are ignored when the FIFO is empty,
                                     // initiating a read while empty is not destructive to the FIFO.

      .full(QSPI_RD_FIFO_Full),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the
                                     // FIFO is full. Write requests are ignored when the FIFO is full,
                                     // initiating a write when the FIFO is full is not destructive to the
                                     // contents of the FIFO.

      .overflow(),           // 1-bit output: Overflow: This signal indicates that a write request
                                     // (wren) during the prior clock cycle was rejected, because the FIFO is
                                     // full. Overflowing the FIFO is not destructive to the contents of the
                                     // FIFO.

      .prog_empty(),       // 1-bit output: Programmable Empty: This signal is asserted when the
                                     // number of words in the FIFO is less than or equal to the programmable
                                     // empty threshold value. It is de-asserted when the number of words in
                                     // the FIFO exceeds the programmable empty threshold value.

      .prog_full(),         // 1-bit output: Programmable Full: This signal is asserted when the
                                     // number of words in the FIFO is greater than or equal to the
                                     // programmable full threshold value. It is de-asserted when the number of
                                     // words in the FIFO is less than the programmable full threshold value.

      .rd_data_count(), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
                                     // number of words read from the FIFO.

      .rd_rst_busy(),     // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
                                     // domain is currently in a reset state.

      .sbiterr(),             // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
                                     // and fixed a single-bit error.

      .underflow(),         // 1-bit output: Underflow: Indicates that the read request (rd_en) during
                                     // the previous clock cycle was rejected because the FIFO is empty. Under
                                     // flowing the FIFO is not destructive to the FIFO.

      .wr_ack(),               // 1-bit output: Write Acknowledge: This signal indicates that a write
                                     // request (wr_en) during the prior clock cycle is succeeded.

      .wr_data_count(), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates
                                     // the number of words written into the FIFO.

      .wr_rst_busy(),     // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
                                     // write domain is currently in a reset state.

      .din(data_out_byte),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                     // writing the FIFO.

      .injectdbiterr(1'b0), // 1-bit input: Double Bit Error Injection: Injects a double bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .injectsbiterr(1'b0), // 1-bit input: Single Bit Error Injection: Injects a single bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .rd_clk(fpga_clk),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
                                     // running clock.

      .rd_en(QSPI_RD_FIFO_RQ),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                     // signal causes data (on dout) to be read from the FIFO. Must be held
                                     // active-low when rd_rst_busy is active high.

      .rst(reset_27mhz),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                     // unstable at the time of applying reset, but reset must be released only
                                     // after the clock(s) is/are stable.

      .sleep(1'b0),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
                                     // block is in power saving mode.

      .wr_clk(qspi_clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                     // free running clock.

      .wr_en(data_out_byte_valid)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                     // signal causes data (on din) to be written to the FIFO. Must be held
                                     // active-low when rst or wr_rst_busy is active high.

   );



assign DQio[0] = oe?DQ[0]:1'bZ;
assign DQio[1] = oe?DQ[1]:1'bZ;
assign DQio[2] = oe?DQ[2]:1'bZ;
assign DQio[3] = quad?(oe?DQ[3]:1'bZ):1'b1; // has to be held 1 as 'hold'
//during single IO operation, but in quad mode behaves as other IOs
wire [2:0] width = quad?4:1;


always @(posedge qspi_clk) begin
    if(reset_27mhz) begin
        state <= `STATE_IDLE;
        oe <= 0;
        S <= 1;
        busy <= 1;
        Dummy_Cycle_Count <= 0;
        rd_data_out_byte_done <= 1'b0;
        temp_cnt  <= 0;
        bit_cntr_pp_wr <= 39;   
        pulse_cnt <= 0;
        RD_FIFO_RQ <= 1'b0;
    end else begin
        RD_FIFO_RQ <= 1'b0;
        case(state)
            `STATE_IDLE: begin
                            if(trigger && !busy) begin
//                                state<=`STATE_SEND;
                                if(qspi_cmd_src==`CMD_RECOVERY)begin
                                    state<=`STATE_RECOVERY;
                                end
                                else if(qspi_cmd_src==`CMD_POWER_LOSS_RECOVERY)begin
                                    state<=`STATE_POWER_LOSS_RECOVERY;
                                end
                                else if(qspi_cmd_src==`CMD_INTERFACE_RESCUE)begin
                                    state<=`STATE_INTERFACE_RESCUE;
                                end 
                                else begin
                                    state<=`STATE_SEND;
                                end
                                busy <= 1;
                                bit_cntr_wr <= data_in_count_src*8 - 1;    
                                bit_cntr_rd <= data_out_count_src*8;
                                rd_data_out_byte_done <= 1'b0;
                                bit_cntr_pp_wr <= 39;
                                temp_cnt       <= 0;
                                if(qspi_init_done & qspi_cmd_src==`CMD_PP)begin    
                                    data_in_temp <= data_in_src;
                                    RD_FIFO_RQ     <=  1'b1; 
                                end
                                
                             end else begin
                                S <= 1;
                                if(!trigger)begin
                                    busy <= 0;
                                end    
                                rd_data_out_byte_done <= 1'b1;
                                data_in_temp <= 0;
                             end 
             end
    
            `STATE_SEND: begin
                            S <= 0;
                            oe <= 1;
                            if(quad) begin
                                if(qspi_init_done & qspi_cmd_src==`CMD_PP)begin    
                                    DQ[0] <= data_in_temp[bit_cntr_pp_wr-3];
                                    DQ[1] <= data_in_temp[bit_cntr_pp_wr-2];
                                    DQ[2] <= data_in_temp[bit_cntr_pp_wr-1];
                                    DQ[3] <= data_in_temp[bit_cntr_pp_wr];
                                    if(temp_cnt == 1)begin
                                        bit_cntr_pp_wr <= 39;
                                        temp_cnt       <= 0;
                                        if(bit_cntr_wr>43)begin
                                            RD_FIFO_RQ     <=  1'b1;
                                        end
                                        else begin
                                            RD_FIFO_RQ     <=  1'b0;
                                        end    
//                                        RD_FIFO_RQ     <= 1'b0;
                                        data_in_temp   <= {data_in_temp[31:0],RD_FIFO_DATA};
                                    end else begin
                                        bit_cntr_pp_wr <=  bit_cntr_pp_wr -4;
                                        temp_cnt       <=  1;
//                                        RD_FIFO_RQ     <=  1'b1;   
                                        RD_FIFO_RQ     <= 1'b0;
                                    end
                                    
                                    
                                    
                                end
                                else begin
                                    DQ[0] <= data_in_src[bit_cntr_wr-3];
                                    DQ[1] <= data_in_src[bit_cntr_wr-2];
                                    DQ[2] <= data_in_src[bit_cntr_wr-1];
                                    DQ[3] <= data_in_src[bit_cntr_wr];
                                end
                                    
                            end else
                                 DQ[0] <= data_in_src[bit_cntr_wr];
                            
                            if(bit_cntr_wr>width-1) begin
                                bit_cntr_wr <= bit_cntr_wr - width;
                            end else begin
                                if(qspi_cmd_src== `CMD_READ)begin   //8'h0C
                                   if(Dummy_Cycle_Count== 1)begin
                                        oe <= 0;
                                   end
                                   if(Dummy_Cycle_Count == DUMMY_CYCLE_NUM)begin
                                       if(data_out_count_src>0) begin
                                           state <= `STATE_READ;
                                       end
                                       else begin
                                           state <= `STATE_IDLE;
//                                           busy  <= 0;
                                           rd_data_out_byte_done <= 1'b1;
                                       end 
                                        Dummy_Cycle_Count <= 0;                           
                                   end
                                   else begin
                                        Dummy_Cycle_Count <= Dummy_Cycle_Count + 1;
                                   end   
                                end
                                else begin
                                    if(data_out_count_src>0) begin
                                        state <= `STATE_READ;
                                    end
                                    else begin
                                        state <= `STATE_IDLE;
//                                        busy  <= 0;
                                        rd_data_out_byte_done <= 1'b1;
                                        
                                    end
                                end   
                            end 
            end
    
            `STATE_READ: begin
                            oe <= 0;
                            
                            if(bit_cntr_rd>width-1) begin
                                bit_cntr_rd <= bit_cntr_rd - width;
                            end else begin
                                S <= 1;
                                state <= `STATE_IDLE; 
                                rd_data_out_byte_done <= 1'b1;
                            end
//                            if(bit_cntr_rd == width) begin
//                                busy  <= 0;
//                            end 
            end

            `STATE_RECOVERY :begin
                oe <= 1; 
                if(pulse_cnt==0 || pulse_cnt==8 || pulse_cnt==18 || pulse_cnt==32 || pulse_cnt==50 || pulse_cnt==76)begin
                    S <= 0;              
                    DQ[0] <= 1'b1;
//                    DQ[1] <= 1'b1;
//                    DQ[2] <= 1'b1;
                    DQ[3] <= 1'b1;
                end
                else if(pulse_cnt==7 || pulse_cnt==17 || pulse_cnt==31 || pulse_cnt==49 || pulse_cnt==75 || pulse_cnt==109)begin
                    S <= 1;              
                    DQ[0] <= 1'b0;
//                    DQ[1] <= 1'b1;
//                    DQ[2] <= 1'b1;
                    DQ[3] <= 1'b0;                
                end        
                
                if(pulse_cnt==109)begin
                    state <= `STATE_IDLE; 
                    pulse_cnt <= 0;
//                    busy  <= 0;
                end
                else begin  
                    state <= `STATE_RECOVERY;
                    pulse_cnt <= pulse_cnt + 1;  
                end
            end

            `STATE_POWER_LOSS_RECOVERY :begin
                oe <= 1; 
                if(pulse_cnt==0)begin
                    S <= 0;              
                    DQ[0] <= 1'b1;
//                    DQ[1] <= 1'b1;
//                    DQ[2] <= 1'b1;
                    DQ[3] <= 1'b1;
                end
                else if(pulse_cnt==8)begin
                    S <= 1;              
                    DQ[0] <= 1'b0;
//                    DQ[1] <= 1'b0;
//                    DQ[2] <= 1'b0;
                    DQ[3] <= 1'b0;                
                end        
                
                if(pulse_cnt==8)begin
                    state <= `STATE_IDLE; 
                    pulse_cnt <= 0;
//                    busy  <= 0;
                end
                else begin  
                    state <= `STATE_POWER_LOSS_RECOVERY;
                    pulse_cnt <= pulse_cnt + 1;  
                end
            end 
 
            `STATE_INTERFACE_RESCUE :begin
                oe <= 1; 
                if(pulse_cnt==0)begin
                    S <= 0;              
                    DQ[0] <= 1'b1;
//                    DQ[1] <= 1'b1;
//                    DQ[2] <= 1'b1;
                    DQ[3] <= 1'b1;
                end
                else if(pulse_cnt==16)begin
                    S <= 1;              
                    DQ[0] <= 1'b0;
//                    DQ[1] <= 1'b0;
//                    DQ[2] <= 1'b0;
                    DQ[3] <= 1'b0;                
                end        
                
                if(pulse_cnt==16)begin
                    state <= `STATE_IDLE; 
                    pulse_cnt <= 0;
//                    busy  <= 0;
                end
                else begin  
                    state <= `STATE_INTERFACE_RESCUE;
                    pulse_cnt <= pulse_cnt + 1;  
                end
            end             
        endcase
    end
end 

always @(negedge qspi_clk) begin
    if(reset_27mhz)begin
        data_out             <= 0;
        bit_cntr_rd_byte     <= 0;
        data_out_byte        <= 0;
        data_out_byte_valid  <= 1'b0;
    end
    else begin
        if(rd_data_out_byte_done == 1'b1)begin  
            data_out            <= 0;
            bit_cntr_rd_byte    <= 0;
            data_out_byte       <= 0;
            data_out_byte_valid <= 1'b0;    
        end
        if(state==`STATE_READ) begin
            if(quad)begin
                data_out <= {data_out[3:0], DQio[3], DQio[2], DQio[1], DQio[0]};
            end
            else begin
                data_out <= {data_out[6:0], DQio[1]};
            end
            if(quad)begin
                if(bit_cntr_rd_byte == 2)begin
                    bit_cntr_rd_byte    <= 1;
                    data_out_byte       <= {data_out[3:0], DQio[3], DQio[2], DQio[1], DQio[0]}; 
                    data_out_byte_valid <= 1'b1;         
                end
                else begin
                    bit_cntr_rd_byte    <= bit_cntr_rd_byte + 1;
                    data_out_byte       <= 8'd0;
                    data_out_byte_valid <= 1'b0;
                end 
            end  
            else begin   
                if(bit_cntr_rd_byte == 8)begin
                        bit_cntr_rd_byte    <= 1;
                        data_out_byte       <= {data_out[6:0],DQio[1]};  
                        data_out_byte_valid <= 1'b1;        
                end
                else begin
                        bit_cntr_rd_byte    <= bit_cntr_rd_byte + 1;
                        data_out_byte       <= 8'd0;
                        data_out_byte_valid <= 1'b0;  
                end     
            end    
    end
end   
end


`ifdef ILA_DEBUG_SPI    
wire [200:0] probe0;
TOII_TUVE_ila ila_inst5(
    .CLK(qspi_clk),
    .PROBE0(probe0)
);

assign probe0 = {10'd0,
//                 data_in_count,
                 data_in_count_src,
                 data_out_byte_valid,
                 data_out_byte,
                 state,
                 quad,
                 quad_src,
//                 qspi_cmd,
                 qspi_cmd_src,
//                 data_in,
                 data_in_src,
//                 data_out_count,
                 data_out_count_src,
                 trigger,
                 trigger_src,
                 busy,
                 busy_dest,
                 data_out_byte_dest,
//                 data_out_byte_valid_dest,
                 qspi_init_done,
                 qspi_init_done_src,
                 bit_cntr_wr,
                 bit_cntr_rd,
                 rd_data_out_byte_done,
                 bit_cntr_rd_byte,
                 S,
                 oe,
                 data_out,
                 RD_FIFO_RQ,
                 RD_FIFO_DATA,
                 data_in_temp,
                 QSPI_RD_FIFO_Full        
                      };  
 
`endif   

endmodule
