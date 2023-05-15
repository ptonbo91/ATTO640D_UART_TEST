`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2021 08:22:28 AM
// Design Name: 
// Module Name: bno_packet_rx
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


//`define BNO_ILA

module bno_packet_rx (
input             clk,
input             rst,
input             trigger,
input      [7:0]  av_uart_readdata,
input             av_uart_readdatavalid,
input             av_uart_waitrequest,
output reg [7:0]  av_uart_address,
output reg        av_uart_read,
output reg [15:0] yaw,
output reg [15:0] pitch,
output reg [15:0] roll,
output reg [15:0] x_accel,
output reg [15:0] y_accel,
output reg [15:0] z_accel,
output reg        crc_error,
output reg        bno_data_valid
);

localparam [7:0] BNO_HEADER_BYTE_0        = 8'hAA,
                 BNO_HEADER_BYTE_1        = 8'hAA;


localparam [2:0] r_idle                   = 3'd0,
                 r_data_decode            = 3'd1,
                 r_get_data               = 3'd2,
                 r_get_data2              = 3'd3;

reg [2:0] st;
reg       trigger_reg;
wire      trigger_pos_edge;
//reg       datavalid;
reg [7:0] data;
reg [7:0] checksum;
reg       read_done;
reg [7:0] recv_cnt;
//  reg [7:0] rsrvd [0:2];

reg [15:0] temp_yaw    ;    
reg [15:0] temp_pitch  ;  
reg [15:0] temp_roll   ;   
reg [15:0] temp_x_accel;
reg [15:0] temp_y_accel;
reg [15:0] temp_z_accel;

`ifdef  BNO_ILA
    reg [7:0] data_reg [0:39];
`endif    
reg [7:0] packet_seq_no; 

assign trigger_pos_edge = (trigger && (!trigger_reg));

always @(posedge clk or posedge rst) begin
	if (rst) begin
    	st              <= r_idle;
    	trigger_reg     <= 0;
//    	datavalid       <= 0;
    	data            <= 0;
    	recv_cnt        <= 0;
    	checksum        <= 0;
    	crc_error       <= 0;
    	av_uart_address <= 0;
    	av_uart_read    <= 0; 
    	read_done       <= 0;
    	yaw             <= 0;
    	pitch           <= 0;
    	roll            <= 0;
    	x_accel         <= 0;
    	y_accel         <= 0;
    	z_accel         <= 0;
        temp_yaw        <= 0;
        temp_pitch      <= 0;
        temp_roll       <= 0;
        temp_x_accel    <= 0;
        temp_y_accel    <= 0;
        temp_z_accel    <= 0;	
    	bno_data_valid  <= 0;
	end
	else begin
	    trigger_reg    <= trigger;
	    crc_error      <= 1'b0;
        bno_data_valid <= 1'b0;
        
        if(bno_data_valid == 1'b1 && crc_error == 1'b0)begin
            yaw     <= temp_yaw    ;
            pitch   <= temp_pitch  ;
            roll    <= temp_roll   ;
            x_accel <= temp_x_accel;
            y_accel <= temp_y_accel;
            z_accel <= temp_z_accel;  
        end         
        
        case (st)
             r_idle: begin
                if (trigger_pos_edge) begin
                    st <= r_get_data;
                end    
                else begin
                    st <= r_idle;
                end
            end    
            r_get_data: begin
                av_uart_address <= 4;
                av_uart_read    <= 1'b1;
                st              <= r_get_data2;
            end
            r_get_data2: begin
                av_uart_read <= (!read_done);
                if ((!av_uart_waitrequest)) begin
                    av_uart_read <= 1'b0;
                    read_done <= 1'b1;
                end
                if (av_uart_readdatavalid) begin
                    data      <= av_uart_readdata;
//                    datavalid <= 1'b1;
                    read_done <= 1'b0;
                    st        <= r_data_decode;
                end  
            end
            r_data_decode: begin
//                datavalid      <= 1'b0;
`ifdef  BNO_ILA                
                data_reg[0]     <= data;
                data_reg[1]     <= data_reg[0];
                data_reg[2]     <= data_reg[1];
                data_reg[3]     <= data_reg[2];
                data_reg[4]     <= data_reg[3];
                data_reg[5]     <= data_reg[4];
                data_reg[6]     <= data_reg[5];
                data_reg[7]     <= data_reg[6];
                data_reg[8]     <= data_reg[7];
                data_reg[9]     <= data_reg[8];
                data_reg[10]    <= data_reg[9];
                data_reg[11]    <= data_reg[10];
                data_reg[12]    <= data_reg[11];
                data_reg[13]    <= data_reg[12];
                data_reg[14]    <= data_reg[13];
                data_reg[15]    <= data_reg[14];
                data_reg[16]    <= data_reg[15];
                data_reg[17]    <= data_reg[16];
                data_reg[18]    <= data_reg[17];
                data_reg[19]    <= data_reg[18];
                data_reg[20]    <= data_reg[19];
                data_reg[21]    <= data_reg[20];
                data_reg[22]    <= data_reg[21];
                data_reg[23]    <= data_reg[22];
                data_reg[24]    <= data_reg[23];
                data_reg[25]    <= data_reg[24];
                data_reg[26]    <= data_reg[25];
                data_reg[27]    <= data_reg[26];
                data_reg[28]    <= data_reg[27];
                data_reg[29]    <= data_reg[28];
                data_reg[30]    <= data_reg[29];
                data_reg[31]    <= data_reg[30];
                data_reg[32]    <= data_reg[31];
                data_reg[33]    <= data_reg[32];
                data_reg[34]    <= data_reg[33];
                data_reg[35]    <= data_reg[34];
                data_reg[36]    <= data_reg[35];
                data_reg[37]    <= data_reg[36];
                data_reg[38]    <= data_reg[37];
                data_reg[39]    <= data_reg[38];
`endif                
//                if (((data == BNO_HEADER_BYTE_0) && datavalid && recv_cnt==0)) begin
                if (((data == BNO_HEADER_BYTE_0) && recv_cnt==0)) begin
                    recv_cnt <= recv_cnt + 1;
                    checksum <= 0;
                end
//                else if (((data == BNO_HEADER_BYTE_1) && datavalid && recv_cnt==1)) begin
                else if (((data == BNO_HEADER_BYTE_1) && recv_cnt==1)) begin
                    recv_cnt  <= recv_cnt + 1;
                    checksum  <= 0;
                end    
//                else if (((recv_cnt == 2) && datavalid)) begin
                else if(recv_cnt == 2) begin
                    packet_seq_no <= data;
                    checksum      <= checksum + data;
                    recv_cnt      <= recv_cnt + 1;
                end                
//                else if (((recv_cnt == 3) && datavalid)) begin
                else if(recv_cnt == 3) begin
                    temp_yaw <= {temp_yaw[15:8],data};
                    checksum <= checksum + data;
                    recv_cnt <= recv_cnt + 1;
                end
//                else if((recv_cnt == 4) && datavalid) begin  
                else if(recv_cnt == 4) begin  
                    temp_yaw <= {data,temp_yaw[7:0]};
                    checksum <= checksum + data;
                    recv_cnt <= recv_cnt + 1;
                end
//                else if (((recv_cnt == 5) && datavalid)) begin
                else if(recv_cnt == 5) begin
                    temp_pitch <= {temp_pitch[15:8],data};
                    checksum   <= checksum + data;
                    recv_cnt   <= recv_cnt + 1;
                end
//                else if (((recv_cnt == 6) && datavalid)) begin
                else if(recv_cnt == 6) begin
                    temp_pitch <= {data,temp_pitch[7:0]};
                    checksum   <= checksum + data;
                    recv_cnt   <= recv_cnt + 1;
                end
//                else if (((recv_cnt == 7) && datavalid)) begin
                else if(recv_cnt == 7) begin
                    temp_roll <= {temp_roll[15:8],data};
                    checksum  <= checksum + data;
                    recv_cnt  <= recv_cnt + 1;
                end
//                else if (((recv_cnt == 8) && datavalid)) begin
                else if(recv_cnt == 8) begin
                    temp_roll <= {data,temp_roll[7:0]};
                    checksum  <= checksum + data;
                    recv_cnt  <= recv_cnt + 1;
                end
//                else if (((recv_cnt == 9) && datavalid)) begin
                else if(recv_cnt == 9) begin
                    temp_x_accel <= {temp_x_accel[15:8],data};
                    checksum     <= checksum + data;
                    recv_cnt     <= recv_cnt + 1;
                end
//                else if (((recv_cnt == 10) && datavalid)) begin
                else if(recv_cnt == 10) begin
                    temp_x_accel <= {data,temp_x_accel[7:0]};
                    checksum     <= checksum + data;
                    recv_cnt     <= recv_cnt + 1;
                end                
//                else if (((recv_cnt == 11) && datavalid)) begin
                else if(recv_cnt == 11) begin
                    temp_y_accel <= {temp_y_accel[15:8],data};
                    checksum     <= checksum + data;
                    recv_cnt     <= recv_cnt + 1;
                end
//                else if (((recv_cnt == 12) && datavalid)) begin
                else if(recv_cnt == 12) begin
                    temp_y_accel <= {data,temp_y_accel[7:0]};
                    checksum     <= checksum + data;
                    recv_cnt     <= recv_cnt + 1;
                end 
//                else if (((recv_cnt == 13) && datavalid)) begin
                else if(recv_cnt == 13) begin
                    temp_z_accel <= {temp_z_accel[15:8],data};
                    checksum     <= checksum + data;
                    recv_cnt     <= recv_cnt + 1;
                end
//                else if (((recv_cnt == 14) && datavalid)) begin
                else if(recv_cnt == 14) begin
                    temp_z_accel <= {data,temp_z_accel[7:0]};
                    checksum     <= checksum + data;
                    recv_cnt     <= recv_cnt + 1;
                end               
//                else if (((recv_cnt == 15) && datavalid)) begin
                else if(recv_cnt == 15) begin
//                    rsrvd[0] <= data;
                    checksum <= checksum + data;
                    recv_cnt <= recv_cnt + 1;
                end  
//                else if (((recv_cnt == 16) && datavalid)) begin
                else if(recv_cnt == 16)  begin
//                    rsrvd[1]  <= data;
                    checksum <= checksum + data;
                    recv_cnt <= recv_cnt + 1;
                end  
//                else if (((recv_cnt == 17) && datavalid)) begin
                else if(recv_cnt == 17) begin
//                    rsrvd[3] <= data;
                    checksum <= checksum + data;
                    recv_cnt <= recv_cnt + 1;
                end                  
//                else if (((recv_cnt == 18) && datavalid)) begin
                else if(recv_cnt == 18) begin
                    if(checksum == data)begin
                    	crc_error      <= 1'b0;
                    end
                    else begin
                    	crc_error      <= 1'b1;	
                    end
                    bno_data_valid <= 1'b1;	
                    recv_cnt  <= 0;
                    checksum  <= 0;
                end 
                else begin
                    recv_cnt  <= 0;
                end
                if (trigger_pos_edge) begin
                    st <= r_get_data;
                end    
                else begin
                    st <= r_idle;
                end
            end            
	endcase	
	end
end

`ifdef  BNO_ILA

wire [447:0] probe0;
TOII_TUVE_ila ila_snap(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {4'd0,
                 av_uart_address,
                 bno_data_valid,
                 av_uart_readdatavalid,
                 av_uart_readdata,
                 av_uart_read,
                 av_uart_waitrequest,
                 av_uart_read,
                 read_done,
                 data,
//                 datavalid,
                 st,
                 yaw,
                 pitch,
                 roll,
                 x_accel,
                 // y_accel,
                 // z_accel,
                 crc_error,
                 checksum,
                 recv_cnt,
                 trigger_reg,
                 trigger_pos_edge,
                 packet_seq_no,
                 data_reg[0],
                 data_reg[1],
                 data_reg[2],
                 data_reg[3], 
                data_reg[4]  ,
                data_reg[5]  ,
                data_reg[6]  ,
                data_reg[7]  ,
                data_reg[8]  ,
                data_reg[9]  ,
                data_reg[10] ,
                data_reg[11] ,
                data_reg[12] ,
                data_reg[13] ,
                data_reg[14] ,
                data_reg[15] ,
                data_reg[16] ,
                data_reg[17] ,
                data_reg[18] ,
                data_reg[19] ,
                data_reg[20] ,
                data_reg[21] ,
                data_reg[22] ,
                data_reg[23] ,
                data_reg[24] ,
                data_reg[25] ,
                data_reg[26] ,
                data_reg[27] ,
                data_reg[28] ,
                data_reg[29] ,
                data_reg[30] ,
                data_reg[31] ,
                data_reg[32] ,
                data_reg[33] ,
                data_reg[34] ,
                data_reg[35] ,
                data_reg[36] ,
                data_reg[37] ,
                data_reg[38] ,
                data_reg[39]
                 };

`endif

endmodule
