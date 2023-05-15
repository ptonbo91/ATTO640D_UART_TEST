`timescale 1ns / 1ps
//`define ILA_DEBUG_QSPI
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2018 22:20:09
// Design Name: 
// Module Name: Qspi_Rd_Wr_Controller_Module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "qspi_defs.vh"

module Qspi_Rd_Wr_Controller_Module(
    input             clk,
    input             reset,
    input             clk_27mhz,
    input             reset_27mhz,
    
//(* mark_debug = "true" *)    input             wait_done,
///*(* mark_debug = "true" *) */   input             restart_en,
///*(* mark_debug = "true" *) */   input             reset_en,
    //input             Start_QSPI_Module,
    input             STARTUPE2_clk_stop,
    input      [7:0]  cmd,
    input             input_valid,
    input      [31:0] address,
    input      [7:0]  data_in,
    input             input_data_valid ,  // Only for Page Write give data_valid input   
    input      [8:0]  rd_size,    
    input             trigger,
    output reg [7:0]  read_data_out,
    output reg        read_data_out_valid,
    output reg        busy,
    output reg        qspi_init_done,
    output reg        wr_enable_error,  
    output reg        wr_vecr_error,
    output reg        wr_disable_error,
    inout             FPGA_SPI_DQ0,
    inout             FPGA_SPI_DQ1,
    inout             FPGA_SPI_DQ2,
    inout             FPGA_SPI_DQ3,
    output            FPGA_SPI_CS   
    );



parameter [4:0] error_state                 = 5'd31,
                reset_memory_wait_state     = 5'd30,
                reset_memory_state          = 5'd29,
                reset_enable_wait_state     = 5'd28,
                reset_enable_state          = 5'd27,
                interface_rescue_wait_state = 5'd26,//power_loss_recovery_wait_state= 5'd26,
                interface_rescue_state      = 5'd25,//power_loss_recovery_state = 5'd25,
                recovery_wait_state         = 5'd24,
                recovery_state              = 5'd23;
                

(* mark_debug = "true" *)reg  [4:0]  state;
(* mark_debug = "true" *)reg  [4:0]  prev_state;
(* mark_debug = "true" *)reg  [31:0] qspi_address;
(* mark_debug = "true" *)reg  [7:0]  qspi_cmd;
(* mark_debug = "true" *)wire        qspi_busy;
(* mark_debug = "true" *)reg         qspi_trigger;
(* mark_debug = "true" *)wire [7:0]  readout;
(* mark_debug = "true" *)wire        readout_valid;
(* mark_debug = "true" *)reg  [7:0]  Status_reg_data;

//reg  read_data_valid;
(* mark_debug = "true" *)wire error;
(* mark_debug = "true" *)reg  quad;

(* mark_debug = "true" *)reg  [7:0] vecr_reg_data;
(* mark_debug = "true" *)wire [8:0] read_data_count;
(* mark_debug = "true" *)reg  [7:0] qspi_data_send;
(* mark_debug = "true" *)reg  [8:0] qspi_rd_size;

//////////////// Clock and EOS //////

(* mark_debug = "true" *)wire  EOS;
(* mark_debug = "true" *)wire  clk_27mhz_180;

/////////////////////// FIFO ////////////////

(* mark_debug = "true" *)reg WR_FIFO_CLR;
(* mark_debug = "true" *)wire [7:0] RD_FIFO_DATA;
(* mark_debug = "true" *)wire RD_FIFO_Empty;    
(* mark_debug = "true" *)wire RD_FIFO_Full;     
(* mark_debug = "true" *)wire [7:0]RDBuffFilled;     
(* mark_debug = "true" *)wire RD_FIFO_AlmostFull;
(* mark_debug = "true" *)wire RD_FIFO_RQ;      
(* mark_debug = "true" *)reg WR_wrreq_sig;      
(* mark_debug = "true" *)reg [7:0]WR_Data_Word; 
(* mark_debug = "true" *)reg [8:0]WR_Data_Cnt;

(* mark_debug = "true" *)reg [31:0]count;


/////////////////////////////////////////////




assign clk_27mhz_180 = !clk_27mhz;

STARTUPE2 #(
   .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
   .SIM_CCLK_FREQ(10.0)  // Set the Configuration Clock Frequency(ns) for simulation.
)
STARTUPE2_inst (
    .CFGCLK(),              // 1-bit output: Configuration main clock output
    .CFGMCLK(),             // 1-bit output: Configuration internal oscillator clock output
    .EOS(EOS),              // 1-bit output: Active high output signal indicating the End Of Startup.
    .PREQ(),                // 1-bit output: PROGRAM request to fabric output
    .CLK(1'b0),             // 1-bit input: User start-up clock input
    .GSR(1'b0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
    .GTS(1'b0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
    .KEYCLEARB(1'b0),       // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
    .PACK(1'b0),             // 1-bit input: PROGRAM acknowledge input
    .USRCCLKO(clk_27mhz_180 &(!STARTUPE2_clk_stop)),   // 1-bit input: User CCLK input
    .USRCCLKTS(1'b0), // 1-bit input: User CCLK 3-state enable input
    .USRDONEO(1'b1),   // 1-bit input: User DONE pin output control
    .USRDONETS(1'b1)  // 1-bit input: User DONE 3-state enable output
);
 
qspi_mem_controller mc(
    .clk(clk), 
    .reset(reset),
    .clk_27mhz(clk_27mhz), 
    .reset_27mhz(reset_27mhz),
    .S(FPGA_SPI_CS), 
    .DQio({FPGA_SPI_DQ3,FPGA_SPI_DQ2,FPGA_SPI_DQ1,FPGA_SPI_DQ0}),
    .trigger(qspi_trigger),
    .quad(quad),
    .cmd(qspi_cmd),
    .address(qspi_address),
    .data_send(qspi_data_send),
    .rd_size(qspi_rd_size),
    .readout(readout),
    .readout_valid(readout_valid),
    .busy(qspi_busy),
    .error(error),
    .RD_FIFO_DATA(RD_FIFO_DATA), 
    .RD_FIFO_RQ(RD_FIFO_RQ),
    .qspi_init_done(qspi_init_done)     
    
);




 
always @(posedge clk) begin
        if(reset) begin
            qspi_trigger <= 0;
            state <= 0;
            quad <= 0;
            qspi_cmd       <= 0;//`CMD_RDID;
            qspi_address   <= 0; 
            qspi_data_send <= 0;
            qspi_rd_size   <= 0;
//            read_data_valid <= 1'b0;
            busy    <= 1'b1;
            qspi_init_done <= 1'b0;
            wr_enable_error <= 1'b0;
            wr_vecr_error <= 1'b0;
            wr_disable_error <= 1'b0;
            WR_FIFO_CLR <= 1'b1;
            WR_Data_Cnt <= 0;
            prev_state <= 0;
            Status_reg_data <= 0;
            count      <= 0;
        end else begin
            case(state)
               0: begin
                  //if(EOS & Start_QSPI_Module)begin
//                  if(wait_done)begin
                      if(EOS)begin
                        if(!qspi_busy)begin
        //                        state <= state+1;
                            state    <= recovery_state;
                            prev_state <= state;
                            busy  <= 1'b1;
                            qspi_init_done <= 1'b0;
                            WR_FIFO_CLR    <= 1'b0;
                         end
                      end
//                  end
//                  else begin
//                    state    <= 0;
//                  end    
               end 

               recovery_state: begin
                   if (qspi_trigger)
                       qspi_trigger <= 0;
                   else if(!qspi_busy) begin 
                           qspi_trigger    <= 1;   
                           quad            <= 1;     // to send data on dq[0] and dq[3]
//                           state           <= state+1;
                           state           <= recovery_wait_state;
                           prev_state      <= state;   
                           qspi_cmd        <= `CMD_RECOVERY;
                           qspi_address    <= 0; 
                           qspi_data_send  <= 0;
                           qspi_rd_size    <= 0;       
                   end               
               end

              recovery_wait_state : begin
                qspi_trigger <= 0;
                state <=  interface_rescue_state;  // power_loss_recovery_state;
//                if(wait_done)begin
//                    state <=  interface_rescue_state;  // power_loss_recovery_state;
//                end
//                else begin
//                    state <= recovery_wait_state;
//                end     
              end 
 
//              power_loss_recovery_state: begin
//                   if (qspi_trigger)
//                       qspi_trigger <= 0;
//                   else if(!qspi_busy) begin 
//                           qspi_trigger    <= 1;   
//                           quad            <= 1;
////                           state           <= state+1;
//                           state           <= reset_state;
//                           prev_state <= state;   
//                           qspi_cmd        <=`CMD_POWER_LOSS_RECOVERY;
//                           qspi_address    <= 0; 
//                           qspi_data_send  <= 0;
//                           qspi_rd_size    <= 0;       
//                   end               
//               end

              interface_rescue_state: begin
                   if (qspi_trigger)
                       qspi_trigger <= 0;
                   else if(!qspi_busy) begin 
                           qspi_trigger    <= 1;   
                           quad            <= 1;   // to send data on dq[0] and dq[3]
//                           state           <= state+1;
                           state           <= interface_rescue_wait_state;
                           prev_state      <= state;   
                           qspi_cmd        <=`CMD_INTERFACE_RESCUE;
                           qspi_address    <= 0; 
                           qspi_data_send  <= 0;
                           qspi_rd_size    <= 0;       
                   end               
               end

              interface_rescue_wait_state : begin
                qspi_trigger <= 0;
                state <=  reset_enable_state;
//                if(reset_en)begin
//                    state <=  reset_enable_state;  
//                end
//                else begin
//                    state <= interface_rescue_wait_state;
//                end     
              end 
                
             reset_enable_state : begin
                   if (qspi_trigger)
                       qspi_trigger <= 0;
                   else if(!qspi_busy) begin 
                           qspi_trigger    <= 1;   
                           quad            <= 0;
//                           state           <= state+1;
                           state           <= reset_enable_wait_state;
                           prev_state      <= state;   
                           qspi_cmd        <= `CMD_RESET_ENABLE;
                           qspi_address    <= 0; 
                           qspi_data_send  <= 0;
                           qspi_rd_size    <= 0;       
                   end             
             end                   

             reset_enable_wait_state : begin
                qspi_trigger <= 0;
                state <=  reset_memory_state;
//                if(wait_done)begin
//                    state <=  reset_memory_state;  
//                end
//                else begin
//                    state <= reset_enable_wait_state;
//                end     
              end 

             reset_memory_state : begin
                   if (qspi_trigger)
                       qspi_trigger <= 0;
                   else if(!qspi_busy) begin 
                           qspi_trigger    <= 1;   
                           quad            <= 0;
//                           state           <= state+1;
                           state           <= reset_memory_wait_state;
                           prev_state      <= state;   
                           qspi_cmd        <= `CMD_RESET_MEMORY;
                           qspi_address    <= 0; 
                           qspi_data_send  <= 0;
                           qspi_rd_size    <= 0;       
                   end                
             end 
             
             reset_memory_wait_state: begin
                qspi_trigger <= 0;
                state        <=  1;
//                if(restart_en)begin
//                    state <=  1;  
//                end
//                else begin
//                    state <= reset_memory_wait_state;
//                end     
              end 
               
               1: begin
                   if (qspi_trigger)
                       qspi_trigger <= 0;
                   else if(!qspi_busy) begin 
                           qspi_trigger    <= 1;   
                           quad            <= 0;
                           state           <= state+1;
                           prev_state      <= state;   
                           qspi_cmd        <= `CMD_WREN;
                           qspi_address    <= 0; 
                           qspi_data_send  <= 0;
                           qspi_rd_size    <= 0;       
                   end
               end
   
              2: begin
                   if (qspi_trigger)
                       qspi_trigger <= 0;
                   else if(!qspi_busy) begin     
                       quad           <= 0;                   
                       qspi_trigger   <= 1;   
                       state          <= state+1;//5;   
                       prev_state     <= state;
                       qspi_cmd       <= `CMD_RDSR;//`CMD_RDID; 
                       qspi_address   <= 0; 
                       qspi_data_send <= 0;
                       qspi_rd_size   <= 1;
                       
                   end
              end  
              
             3: begin 
                   if (qspi_trigger)
                        qspi_trigger <= 0;
                   else if(qspi_busy) begin              
                       if(readout_valid)begin
                            Status_reg_data <= readout[7:0];
                            if(readout[1]==1'b1)begin
                                state           <= state + 1;
                                prev_state      <= state;
                                wr_enable_error <= 1'b0;               
                            end
                            else begin
                                wr_enable_error   <= 1'b1;
//                                state           <= error_state;
                                state           <= 2;
                                prev_state      <= state;
                                count           <= count +1;
                            end    
                       end                                    
                   end
               end             
             
              4: begin    
                   //enable quad IO    
                   if (qspi_trigger)
                       qspi_trigger <= 0;
                   else if(!qspi_busy) begin                    
                           qspi_cmd       <= `CMD_WRVECR;
                           qspi_address   <= 0; 
                           qspi_rd_size   <= 0;
                           qspi_data_send <= 8'b011_01_111;  //  8'b010_01_111 quad protocol, hold/accelerator disabled, default drive strength DDR
                           qspi_trigger   <= 1;   
                           state          <= state+1;  
                           prev_state     <= state;
                           quad           <= 0; 
                   end
                end
    
                5: begin
                    if (qspi_trigger)
                        qspi_trigger <= 0;
                    else if(!qspi_busy) begin               
                        quad           <= 1;
                        qspi_cmd       <=  `CMD_RDVECR;//`CMD_MIORDID;//`CMD_RDID;
                        qspi_address   <= 0; 
                        qspi_data_send <= 0;
                        qspi_rd_size   <= 1;
                        qspi_trigger   <= 1;   
                        state          <= state+1;   
                        prev_state     <= state;              
                    end
                end
                
                6: begin          
                   if (qspi_trigger)
                     qspi_trigger <= 0;
                   else if(qspi_busy) begin
                        if(readout_valid)begin
//                             Status_reg_data <= readout[7:0];
                             if(readout==8'h6f)begin
                                 state          <= state + 1;
                                 prev_state     <= state;
                                 wr_vecr_error  <= 1'b0;               
                             end
                             else begin
                                 wr_vecr_error   <= 1'b1;
                                 state           <= error_state;
                                 prev_state      <= state;
                             end    
                        end                                    
                    end 

                  end 
                
                7: begin
                    if (qspi_trigger)
                        qspi_trigger <= 0;
                    else if(!qspi_busy) begin                   
                            qspi_trigger   <= 1;   
                            state          <= state+1;  
                            prev_state     <= state; 
                            qspi_cmd       <= `CMD_RDSR;
                            qspi_address   <= 0; 
                            qspi_data_send <= 0;
                            qspi_rd_size   <= 1;     
                   end
                
                end  
                
               8: begin  
                    if (qspi_trigger)
                        qspi_trigger <= 0;
                    else if(qspi_busy) begin            
                          if(readout_valid)begin
                               Status_reg_data <= readout[7:0];
                               if(readout[1]==1'b1)begin
                                   state      <= state + 4;  
                                   prev_state <= state;            
                               end
                               else begin 
                                   state      <= state + 1;
                                   prev_state <= state;
                                   
                               end    
                          end                                    
                    end
                end
    
                9: begin
                    if (qspi_trigger)
                        qspi_trigger <= 0;
                    else if(!qspi_busy) begin                  
                            qspi_trigger   <= 1;   
                            state          <= state+1; 
                            prev_state     <= state;  
                            qspi_cmd       <= `CMD_WREN;
                            qspi_address   <= 0; 
                            qspi_data_send <= 0;
                            qspi_rd_size   <= 0;       
                   end
                
                end  
               10: begin
                    if (qspi_trigger)
                        qspi_trigger <= 0;
                    else if(!qspi_busy) begin                     
                        qspi_trigger   <= 1;   
                        state          <= state+1;   
                        prev_state     <= state;
                        qspi_cmd       <= `CMD_RDSR;//`CMD_RDSR;  
                        qspi_address   <= 0; 
                        qspi_data_send <= 0;
                        qspi_rd_size   <= 1;           
                   end
                
               end
               11: begin
                   if (qspi_trigger)
                        qspi_trigger <= 0;
                   else if(qspi_busy) begin
                       if(readout_valid)begin
                            Status_reg_data <= readout[7:0];
                            if(readout[1]==1'b1)begin
                                state           <= state + 1;
                                prev_state      <= state;
                                wr_enable_error <= 1'b0;               
                            end
                            else begin
                                wr_enable_error <= 1'b1;
                                state           <= error_state;
                                prev_state      <= state;
                            end     
                        end
                    end                                    
               end  
                       
               12: begin
                     if (qspi_trigger)
                         qspi_trigger <= 0;
                     else if(!qspi_busy) begin                    
                             qspi_trigger   <= 1;   
                             state          <= state+1; 
                             prev_state     <= state;  
                             qspi_cmd       <= `CMD_EN4BYTE ;
                             qspi_address   <= 0; 
                             qspi_data_send <= 0;
                             qspi_rd_size   <= 0;  
                     end
                end 
                
                13: begin
                      if (qspi_trigger)
                          qspi_trigger <= 0;
                      else if(!qspi_busy) begin                     
                          qspi_trigger   <= 1;   
                          state          <= state+1;   
                          prev_state     <= state;
                          qspi_cmd       <= `CMD_RFSR ;
                          qspi_address   <= 0; 
                          qspi_data_send <= 0;
                          qspi_rd_size   <= 1;
                     end
                  end 
                14:begin
                   if (qspi_trigger)
                     qspi_trigger <= 0;
                   else if(qspi_busy) begin
                        if(readout_valid)begin
                             Status_reg_data <= readout[7:0];
                             if(readout[0]==1'b1)begin
                                 state           <= state + 1;
                                 prev_state      <= state;
                                 wr_enable_error <= 1'b0;               
                             end
                             else begin
                                 wr_enable_error <= 1'b1;
                                 state           <= error_state;
                                 prev_state      <= state;
                             end     
                        end
                    end    
                end
                  
                15: begin
                      if (qspi_trigger)
                          qspi_trigger <= 0;
                      else if(!qspi_busy) begin                    
                              qspi_trigger   <= 1;   
                              state          <= state+1;  
                              prev_state     <= state; 
                              qspi_cmd       <= `CMD_WRDIS;
                              qspi_address   <= 0; 
                              qspi_data_send <= 0;
                              qspi_rd_size   <= 0;       
                     end 
                 end  
                16: begin
                      if (qspi_trigger)
                          qspi_trigger <= 0;
                      else if(!qspi_busy) begin                   
                          qspi_trigger   <= 1;   
                          state          <= state+1; 
                          prev_state     <= state;  
                          qspi_cmd       <= `CMD_RDSR;//`CMD_RDSR;   
                          qspi_address   <= 0; 
                          qspi_data_send <= 0;
                          qspi_rd_size   <= 1;          
                     end
              
                end  
              17: begin
                  if (qspi_trigger)
                    qspi_trigger <= 0;
                  else if(qspi_busy) begin
                     if(readout_valid)begin
                           Status_reg_data <= readout[7:0];
                           if(readout[1]==1'b0)begin
                               state            <= state + 1;
                               prev_state       <= state;
                               wr_disable_error <= 1'b0;               
                           end
                           else begin
                               wr_disable_error <= 1'b1;
                               state            <= error_state;
                               prev_state       <= state;
                           end     
                      end 
                   end
               end                                      

               18: begin
                    if(qspi_trigger)
                        qspi_trigger <= 0;
                    else if(!qspi_busy) begin
                                state           <= state+1;  
                                prev_state      <= state; 
                                qspi_init_done  <= 1'b1;
                                busy            <= 1'b0;   
                                Status_reg_data <= readout[7:0];    
                     end    
                end
                
                19: begin
                    WR_FIFO_CLR  <= 1'b0;  
                    if(trigger)begin
                        busy           <= 1'b1;        
                        if(input_valid)begin
                            if(cmd == `CMD_PP)begin
                                state          <= state+1;
                                prev_state     <= state;
                                qspi_cmd       <= cmd;
                                qspi_address   <= address; 
                                qspi_data_send <= data_in;
                                qspi_rd_size   <= rd_size;
                                qspi_trigger   <= 0;
                                WR_Data_Cnt    <= 0;
                            end else begin
                                qspi_trigger   <= 1;
                                qspi_cmd       <= cmd;
                                qspi_address   <= address; 
                                qspi_data_send <= data_in;
                                qspi_rd_size   <= rd_size; 
                                state          <= state+2; 
                                prev_state     <= state;
                            end 
                        end                                 
                    end      
                end

                20: begin
                   if(input_data_valid)begin
                        WR_Data_Word   <= data_in;
                        WR_wrreq_sig   <= 1'b1;
                        WR_Data_Cnt    <= WR_Data_Cnt + 1;
                        qspi_cmd       <= qspi_cmd;
                        qspi_address   <= qspi_address; 
                        qspi_data_send <= data_in;
                        qspi_rd_size   <= qspi_rd_size;
                   end
                   else begin
                        WR_wrreq_sig   <= 1'b0;
                   end 
                   if(WR_Data_Cnt == 256)begin
                    WR_Data_Word   <= 0;
                    WR_wrreq_sig   <= 1'b0;
                    qspi_trigger   <= 1;
                    state          <= state + 1;
                    prev_state     <= state;
                    WR_Data_Cnt    <= 0;    
                   end  
                    
                end   
                                                                                    
                21: begin  // Read Data
                        if (qspi_trigger)
                            qspi_trigger <= 0;    
                        else if(qspi_busy) begin
                            read_data_out       <= readout;
                            read_data_out_valid <= readout_valid; 
                                                             
                        end
                        else begin
                            state               <= state + 1;
                            prev_state          <= state;
                            read_data_out       <= 8'd0;
                            read_data_out_valid <= 1'b0;
                            busy                <= 1'b0;    
                        end
                end 
                

                                   
                22: begin
                    qspi_trigger <= 0;
//                    read_data_valid <= 1'b0;
                    state        <= 19;
                    prev_state   <= state;
                    busy         <= 1'b0;
                    WR_FIFO_CLR  <= 1'b1;
                end
                
                error_state : begin
                            state <= state;
                end
            endcase
        end
    end  
    
  
    
// FIFO_GENERIC_SC #
//    (
//            .FIFO_DEPTH (8),            //    -- 2**FIFO_DEPTH = Number of Words in FIFO
//            .FIFO_WIDTH (8),            //    -- FIFO Words Number of Bits
//            .AEMPTY_LEVEL(0),
//            .AFULL_LEVEL (20)
//          )
//          WR_DATA_FIFO(
//            .CLK        (clk),
//            .RST        (reset),
//            .CLR        (WR_FIFO_CLR),
//            .WRREQ      (WR_wrreq_sig),
//            .WRDATA     (WR_Data_Word),
//            .RDREQ      (RD_FIFO_RQ),
//            .RDDATA     (RD_FIFO_DATA),
//            .EMPTY      (RD_FIFO_Empty),
//            .FULL       (RD_FIFO_Full),
//            .USEDW      (RDBuffFilled),
//            .AFULL      (RD_FIFO_AlmostFull),
//            .AEMPTY        ()
//          );   


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
   xpm_fifo_async_inst_WR_DATA_FIFO (
      .almost_empty(),   // 1-bit output: Almost Empty : When asserted, this signal indicates that
                                     // only one more read can be performed before the FIFO goes to empty.

      .almost_full(),     // 1-bit output: Almost Full: When asserted, this signal indicates that
                                     // only one more write can be performed before the FIFO is full.

      .data_valid(),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                     // that valid data is available on the output bus (dout).

      .dbiterr(),             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
                                     // a double-bit error and data in the FIFO core is corrupted.

      .dout(RD_FIFO_DATA),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                     // when reading the FIFO.

      .empty(RD_FIFO_Empty),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
                                     // FIFO is empty. Read requests are ignored when the FIFO is empty,
                                     // initiating a read while empty is not destructive to the FIFO.

      .full(RD_FIFO_Full),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the
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

      .din(WR_Data_Word),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                     // writing the FIFO.

      .injectdbiterr(1'b0), // 1-bit input: Double Bit Error Injection: Injects a double bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .injectsbiterr(1'b0), // 1-bit input: Single Bit Error Injection: Injects a single bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .rd_clk(clk_27mhz),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
                                     // running clock.

      .rd_en(RD_FIFO_RQ),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                     // signal causes data (on dout) to be read from the FIFO. Must be held
                                     // active-low when rd_rst_busy is active high.

      .rst(reset),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                     // unstable at the time of applying reset, but reset must be released only
                                     // after the clock(s) is/are stable.

      .sleep(1'b0),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
                                     // block is in power saving mode.

      .wr_clk(clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                     // free running clock.

      .wr_en(WR_wrreq_sig)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                     // signal causes data (on din) to be written to the FIFO. Must be held
                                     // active-low when rst or wr_rst_busy is active high.

   );


`ifdef ILA_DEBUG_QSPI    
wire [127:0] probe0;
TOII_TUVE_ila ila_inst4(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {21'd0,
//                 wait_done,
                 clk_27mhz,
                 count,
                 WR_FIFO_CLR,
                 WR_Data_Word,
                 RD_FIFO_DATA,
                 RD_FIFO_Empty,
                 RD_FIFO_RQ,
                 WR_wrreq_sig,
                 cmd,
                 
                 data_in,
                 RD_FIFO_Full,
                 //reset_en,
                 //wait_done,
                 //restart_en,
                 prev_state,qspi_init_done,busy, EOS,state, error, wr_enable_error, input_data_valid,/*wr_disable_error,*/ /*wr_vecr_error,*/ qspi_trigger, qspi_busy, qspi_init_done, readout_valid, readout,WR_Data_Cnt/*Status_reg_data*/};//, readout_valid, Start_QSPI_Module};//,
                  // readout_valid_mc, readout_valid_mc_d, qspi_trigger_d, qspi_trigger_mc, busy, input_valid, trigger, RD_FIFO_RQ_MC, WR_wrreq_sig};// // Status_reg_data };    
 
`endif   
    
endmodule
