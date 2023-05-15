`timescale 1ns / 1ps
//`define ILA_DEBUG_QSPI_MEM_CONTROLLER
`include "qspi_defs.vh"

`define STATE_IDLE   0
`define STATE_RDID   1
`define STATE_WAIT 2
`define STATE_WREN 3
`define STATE_BE 4
`define STATE_POLL_RFSR 5
`define STATE_PP 6
`define STATE_SE_4KB 7
`define STATE_WRVECR 8
`define STATE_RDVECR 9
`define STATE_RDSR 10
`define STATE_MIORDID 11

`define STATE_READ_DATA 12 
`define STATE_WRDIS 13
`define STATE_WREXADDR 14
`define STATE_RDEXADDR 15
`define STATE_EN4BYTE  16  
`define STATE_DIS4BYTE 17
`define STATE_RFSR     18
`define STATE_SE_32KB  19
`define STATE_SE_64KB  20
`define STATE_RESET_ENABLE 21
`define STATE_RESET_MEMORY 22
`define STATE_RECV 23
`define STATE_POWER_LOSS_RECV 24
`define STATE_INTERFACE_RESC 25
`define STATE_RD_FIFO_RQ 26  
`define STATE_RD_FIFO_WAIT 27 
`define STATE_RD_FIFO_DONE 28    
 

module qspi_mem_controller(
        input             clk,
        input             reset,
        input             clk_27mhz,
        input             reset_27mhz,
        input             qspi_init_done, 
        input             trigger,
        input             quad,
        input      [7:0]  cmd,
        input      [31:0] address,
        input      [7:0]  data_send, 
        input      [8:0]  rd_size,
        output reg [7:0]  readout,
        output reg        readout_valid,
        output reg        busy,
        output reg        error,
        inout       [3:0] DQio,
        output            S,
        input       [7:0] RD_FIFO_DATA, 
        output            RD_FIFO_RQ
         
          
    );
    
reg         spi_trigger;
wire        spi_busy;
wire [7:0]  data_out_byte;
//wire        data_out_byte_valid;
reg         QSPI_RD_FIFO_RQ;
reg         QSPI_RD_FIFO_RQ_D;
wire        QSPI_RD_FIFO_Empty;
wire        QSPI_RD_FIFO_ALMOST_Empty;
reg  [39:0] data_in;
reg  [8:0]  data_in_count;
reg  [8:0]  data_out_count;
reg  [35:0] delay_counter;
reg  [7:0]  qspi_cmd;
reg  [5:0]  state;
reg  [5:0]  nextstate;
wire [7:0]  test_data_out_byte;
wire        test_data_out_byte_valid;
reg  [7:0]  rfsr_reg_read_data;
reg  [8:0]  rd_rq_cnt;
reg  [8:0]  rd_cnt;


spi_cmd sc(.qspi_clk(clk_27mhz),.fpga_clk(clk), .reset_27mhz(reset_27mhz), .trigger_src(spi_trigger), .busy_dest(spi_busy), .quad_src(quad),.qspi_init_done_src(qspi_init_done),
    .data_in_count_src(data_in_count), .data_out_count_src(data_out_count), .data_in_src(data_in),.qspi_cmd_src(qspi_cmd),
    .DQio(DQio[3:0]), .S(S),.data_out_byte_dest(data_out_byte),//.data_out_byte_valid_dest(data_out_byte_valid),
    .QSPI_RD_FIFO_RQ(QSPI_RD_FIFO_RQ),
    .QSPI_RD_FIFO_Empty(QSPI_RD_FIFO_Empty), 
    .QSPI_RD_FIFO_ALMOST_Empty(QSPI_RD_FIFO_ALMOST_Empty),
    .RD_FIFO_DATA(RD_FIFO_DATA),.RD_FIFO_RQ(RD_FIFO_RQ),.test_data_out_byte_valid(test_data_out_byte_valid),.test_data_out_byte(test_data_out_byte)
    );

 
always @(posedge clk) begin
    if(reset) begin
        state <= `STATE_WAIT;
        nextstate <= `STATE_IDLE;
        spi_trigger <= 0;
        busy <= 1;
        error <= 0;
        readout <= 0;
        readout_valid <= 1'b0;
        rfsr_reg_read_data <= 0;
        QSPI_RD_FIFO_RQ_D<= 1'b0;
        rd_rq_cnt  <= 0;
        rd_cnt     <= 0;
    end
    else begin
        QSPI_RD_FIFO_RQ_D <= QSPI_RD_FIFO_RQ;
        case(state)
            `STATE_IDLE: begin
                readout_valid <= 1'b0;
                readout       <= 8'd0;
                if(trigger) begin
                    busy <= 1;
                    error <= 0;
                    case(cmd)
                        `CMD_RDID:
                            state <= `STATE_RDID;
                        `CMD_MIORDID:
                            state <= `STATE_MIORDID;
                        `CMD_WREN:
                            state <= `STATE_WREN;
                        `CMD_BE:
                            state <= `STATE_BE;
                        `CMD_SE_4KB:
                            state <= `STATE_SE_4KB;
                        `CMD_SE_32KB:
                            state <= `STATE_SE_32KB;
                        `CMD_SE_64KB:
                            state <= `STATE_SE_64KB;    
                        `CMD_PP:
                            state <= `STATE_PP;
                        `CMD_WRVECR:
                            state <= `STATE_WRVECR;
                        `CMD_RDVECR:
                            state <= `STATE_RDVECR;
                        `CMD_RDSR:
                            state <= `STATE_RDSR;
                        `CMD_READ:
                            state <= `STATE_READ_DATA; 
                        `CMD_WRDIS:
                            state <= `STATE_WRDIS; 
                        `CMD_WREXADDR:
                            state <= `STATE_WREXADDR;       
                        `CMD_RDEXADDR:
                            state <= `STATE_RDEXADDR; 
                        `CMD_EN4BYTE:
                                state <= `STATE_EN4BYTE;                                 
                        `CMD_DIS4BYTE:
                                state <= `STATE_DIS4BYTE;
                        `CMD_RFSR:
                                state <= `STATE_RFSR;                                 
                        `CMD_RESET_ENABLE:
                            state <= `STATE_RESET_ENABLE;                                                                                     
                        `CMD_RESET_MEMORY:
                            state <= `STATE_RESET_MEMORY; 
                        `CMD_RECOVERY:
                            state <= `STATE_RECV;    
                        `CMD_POWER_LOSS_RECOVERY:
                            state <= `STATE_POWER_LOSS_RECV ;  
                        `CMD_INTERFACE_RESCUE:
                            state <= `STATE_INTERFACE_RESC ;                              
                            
                        default: begin
//                            $display("ERROR: unknown command!");
//                            $display(cmd);
//                            $stop;
                        end
                    endcase
                end else
                    busy <= 0;
            end
        
            `STATE_RDID: begin
               if (quad == 1) begin
                    state <= `STATE_IDLE;
               end
               else begin
                    data_in <= `CMD_RDID;
                    qspi_cmd <= `CMD_RDID;
                    data_in_count <= 1;
                    data_out_count <= rd_size;
                    spi_trigger <= 1;
                    state <= `STATE_WAIT;
                    nextstate <= `STATE_IDLE;
              end                
             end
            `STATE_MIORDID: begin
                if (quad == 1) begin
                    data_in <= `CMD_MIORDID;
                    qspi_cmd <= `CMD_MIORDID;
                    data_in_count <= 1;
                    data_out_count <= rd_size;
                    spi_trigger <= 1;
                    state <= `STATE_WAIT;
                    nextstate <= `STATE_IDLE;
                end 
                else begin
                    state <= `STATE_IDLE;
                end   

            end                

            `STATE_RDSR: begin
                data_in <= `CMD_RDSR;
                qspi_cmd <= `CMD_RDSR;
                data_in_count <= 1;
                data_out_count <= rd_size;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end 
           `STATE_RFSR: begin
                data_in <= `CMD_RFSR;
                qspi_cmd <= `CMD_RFSR;
                data_in_count <= 1;
                data_out_count <= rd_size;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end               

            `STATE_WRVECR: begin
                data_in <= {`CMD_WRVECR, data_send[7:0]};
                qspi_cmd <= `CMD_WRVECR;
                data_in_count <= 2;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;               
            end

            `STATE_RDVECR: begin
                data_in <= `CMD_RDVECR;
                qspi_cmd <=`CMD_RDVECR ;
                data_in_count <= 1;
                data_out_count <= rd_size;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end

            `STATE_WREN: begin
                data_in <= `CMD_WREN;
                qspi_cmd <= `CMD_WREN;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end

            `STATE_RESET_ENABLE: begin
                data_in <= `CMD_RESET_ENABLE;
                qspi_cmd <= `CMD_RESET_ENABLE;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end

            `STATE_RESET_MEMORY: begin
                data_in <= `CMD_RESET_MEMORY;
                qspi_cmd <= `CMD_RESET_MEMORY;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end

            `STATE_RECV : begin
                data_in <= `CMD_RECOVERY;
                qspi_cmd <= `CMD_RECOVERY;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end            

            `STATE_POWER_LOSS_RECV : begin
                data_in <= `CMD_POWER_LOSS_RECOVERY;
                qspi_cmd <= `CMD_POWER_LOSS_RECOVERY;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end 
            
            `STATE_INTERFACE_RESC : begin
                data_in <= `CMD_INTERFACE_RESCUE;
                qspi_cmd <= `CMD_INTERFACE_RESCUE;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end 




            `STATE_BE: begin
                data_in <= `CMD_BE;
                qspi_cmd <= `CMD_BE ;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_POLL_RFSR;
                delay_counter <= `tBEmax*`input_freq;
            end

            `STATE_POLL_RFSR: begin
                readout_valid <= 1'b0;
                readout       <= 8'd0;
                if (delay_counter == 0) begin // max delay timeout
                    state <= `STATE_IDLE;
                    error <= 1;
                end else begin
//                    if (readout[7] == 1) begin // operation finished successfully
                    if(rfsr_reg_read_data[7]==1)begin
                        state <= `STATE_IDLE;
                    end else begin // go on polling
                        data_in <= `CMD_RFSR;
                        qspi_cmd <= `CMD_RFSR;
                        data_in_count <= 1;
                        data_out_count <= 1;
                        spi_trigger <= 1;
                        delay_counter <= delay_counter - 1;
                        state <= `STATE_WAIT;
                        nextstate <= `STATE_POLL_RFSR;
                    end
                end
            end                

            `STATE_WAIT: begin
//                spi_trigger <= 0;
//                if(data_out_byte_valid)begin
//                    readout       <= data_out_byte;
//                    rfsr_reg_read_data <= data_out_byte;
//                    readout_valid <= 1'b1;
//                end
//                else begin
//                    readout       <= 8'd0;
//                    readout_valid <= 1'b0;
//                end
                if(spi_busy)begin
                    spi_trigger <= 0;
//                    state <= `STATE_RD_FIFO_RQ;
                end 
                if (!spi_trigger && !spi_busy) begin
                    if(rd_rq_cnt==data_out_count)begin
                        state     <= nextstate;
                        rd_rq_cnt <= 0;
                        rd_cnt    <= 0;
                    end
                    else begin
                        state <= `STATE_RD_FIFO_RQ;
                    end                     
                end                                 
            end
            `STATE_RD_FIFO_RQ: begin
                if(rd_rq_cnt!=data_out_count)begin
                    QSPI_RD_FIFO_RQ <= 1'b1;
                    rd_rq_cnt          <= rd_rq_cnt + 1;
                end
                else begin
                    QSPI_RD_FIFO_RQ <= 1'b0;
                end
                if(QSPI_RD_FIFO_RQ_D == 1'b1)begin
                    readout            <= data_out_byte;
                    rfsr_reg_read_data <= data_out_byte;
                    readout_valid      <= 1'b1;
                    rd_cnt             <= rd_cnt +1;
                end
                else begin
                    readout       <= 8'd0;
                    readout_valid <= 1'b0;
                end              
                if (rd_cnt == data_out_count) begin
                    state  <= nextstate;
                    rd_rq_cnt <= 0;
                    rd_cnt <= 0;
                end
             end            
//            `STATE_RD_FIFO_RQ: begin
//                if(QSPI_RD_FIFO_Empty==1'b0 & (rd_cnt!=data_out_count))begin
//                    QSPI_RD_FIFO_RQ <= 1'b1;
//                    rd_cnt          <= rd_cnt + 1;
//                end
//                else begin
//                    QSPI_RD_FIFO_RQ <= 1'b0;
//                end
//                if(QSPI_RD_FIFO_RQ_D == 1'b1)begin
//                    readout            <= data_out_byte;
//                    rfsr_reg_read_data <= data_out_byte;
//                    readout_valid      <= 1'b1;
//                end
//                else begin
//                    readout       <= 8'd0;
//                    readout_valid <= 1'b0;
//                end              
//                if (!spi_trigger && !spi_busy && (rd_cnt_dd==data_out_count)) begin
//                    state  <= nextstate;
//                    rd_cnt <= 0;
//                end
//             end
//            `STATE_RD_FIFO_WAIT: begin
            
//            end 
//            `STATE_RD_FIFO_DONE: begin
            
//            end    
            `STATE_EN4BYTE: begin
                data_in <= `CMD_EN4BYTE;
                qspi_cmd <= `CMD_EN4BYTE;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end
            `STATE_DIS4BYTE: begin
                data_in <= `CMD_DIS4BYTE;
                qspi_cmd <= `CMD_DIS4BYTE;
                data_in_count <= 1;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end                
            
            `STATE_WREXADDR: begin
                data_in <= {`CMD_WREXADDR, data_send[7:0]};
                qspi_cmd <= `CMD_WREXADDR;
                data_in_count <= 2;
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;  
            end
            `STATE_RDEXADDR: begin
                data_in <= `CMD_RDEXADDR;
                qspi_cmd <=`CMD_RDEXADDR ;
                data_in_count <= 1;
                data_out_count <= rd_size;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_IDLE;
            end
            
            `STATE_PP: begin
                data_in <= {`CMD_PP,address};
                qspi_cmd <= `CMD_PP;
                data_in_count <= 261; // 256 bytes for data + 1 for command + 4 for address
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_POLL_RFSR;               
                delay_counter <= `tPPmax*`input_freq;
           end

            `STATE_SE_4KB: begin
                data_in <= {`CMD_SE_4KB,address};
                qspi_cmd <= `CMD_SE_4KB;
                data_in_count <= 5; // 1 byte command + 4 bytes address
                data_out_count <= 0;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_POLL_RFSR;               
                delay_counter <= `tSEmax*`input_freq;
           end
           `STATE_SE_32KB: begin
               data_in <= {`CMD_SE_32KB,address};
               qspi_cmd <= `CMD_SE_32KB;
               data_in_count <= 5; // 1 byte command + 4 bytes address
               data_out_count <= 0;
               spi_trigger <= 1;
               state <= `STATE_WAIT;
               nextstate <= `STATE_POLL_RFSR;               
               delay_counter <= `tSEmax*`input_freq;
           end
           `STATE_SE_64KB: begin
               data_in <= {`CMD_SE_64KB,address};
               qspi_cmd <= `CMD_SE_64KB;
               data_in_count <= 5; // 1 byte command + 4 bytes address
               data_out_count <= 0;
               spi_trigger <= 1;
               state <= `STATE_WAIT;
               nextstate <= `STATE_POLL_RFSR;               
               delay_counter <= `tSEmax*`input_freq;
           end
           `STATE_READ_DATA: begin     
                data_in <= {`CMD_READ,address};
                qspi_cmd <= `CMD_READ ;
                data_in_count <= 5;
                data_out_count <= rd_size;
                spi_trigger <= 1;
                state <= `STATE_WAIT;
                nextstate <= `STATE_POLL_RFSR;               
                delay_counter <= `tSEmax*`input_freq;
           end      
           
           `STATE_WRDIS: begin
               data_in <= `CMD_WRDIS;
               qspi_cmd <= `CMD_WRDIS;
               data_in_count <= 1;
               data_out_count <= 0;
               spi_trigger <= 1;
               state <= `STATE_WAIT;
               nextstate <= `STATE_IDLE;
           end
            
        endcase
     end   
end
    

`ifdef ILA_DEBUG_QSPI_MEM_CONTROLLER    
wire [200:0] probe0;
TOII_TUVE_ila ila_inst6(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {69'd0,
                 rd_cnt,
                 rd_rq_cnt,
                 QSPI_RD_FIFO_ALMOST_Empty,  
                 cmd,
                 QSPI_RD_FIFO_ALMOST_Empty,
                 test_data_out_byte_valid,
                 test_data_out_byte,
                 data_out_byte,
                 state,
                 nextstate,
//                 data_out_byte_valid,
                 spi_busy,
                 readout_valid,
                 readout,
                 spi_trigger,
                 quad,
                 qspi_cmd,
                 data_in,
                 QSPI_RD_FIFO_ALMOST_Empty,
                 data_out_count,
                 trigger,
                 busy,
                 QSPI_RD_FIFO_RQ,
                 QSPI_RD_FIFO_Empty,
                 QSPI_RD_FIFO_RQ_D                 
                      };  
 
`endif   

    
endmodule
