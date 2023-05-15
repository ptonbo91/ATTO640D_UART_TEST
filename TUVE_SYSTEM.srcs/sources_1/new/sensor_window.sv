
/*----------------------------------------------------------------
-- Copyright    : Tonbo Imaging
-- Contact      : info@tonboimaging.com
-- Project Name : Tonboimaging - Thermal Camera Project 
-- Block Name   : sensor_window
-- Description  : Temperature extraction encoded in video data
-- Author       : Aneesh M. U.
----------------------------------------------------------------*/
`timescale 1ns/1ps
//`define ENABLE_DEBUG_MSGS
//`define ILA_SENSOR_WINDOW

module sensor_window #(
	parameter 	BIT_WIDTH = 16,
			 	PIX_BITS = 10,
			 	LIN_BITS = 10,
			 	VIDEO_XSIZE = 640,
			 	VIDEO_YSIZE = 480
	) (
	(* mark_debug = "true" *)input clk,
	(* mark_debug = "true" *)input rst,
	    input                 blind_badpix_remove_en,
	    input [BIT_WIDTH-1:0] BAD_BLIND_PIX_LOW_TH,
	    input [BIT_WIDTH-1:0] BAD_BLIND_PIX_HIGH_TH,
	    input [BIT_WIDTH-1:0] dark_pix_th,
	    input [BIT_WIDTH-1:0] saturated_pix_th,

		output reg 		av_sensor_waitrequest,
		input 			av_sensor_write,
		input [31:0] 	av_sensor_writedata,
		input [3:0] 	av_sensor_address,
		input 			av_sensor_read,
		output reg 		av_sensor_readdatavalid,
		output reg [31:0] av_sensor_readdata,

		output reg [31:0] 	blind_pix_avg_frame,
		output reg 		 	blind_pix_avg_frame_valid,
		output reg [BIT_WIDTH-1:0] META1_AVG,
        output reg [BIT_WIDTH-1:0] META2_AVG,
        output reg [BIT_WIDTH-1:0] META3_AVG,
	
	(* mark_debug = "true" *)input video_i_v,
	(* mark_debug = "true" *)input video_i_h,
	(* mark_debug = "true" *)input video_i_dav,
	(* mark_debug = "true" *)input video_i_eoi,
	(* mark_debug = "true" *)input [BIT_WIDTH-1:0] video_i_data,
	
	//Ouptut data to other modules
	//After stripping temperature data from the frames
	(* mark_debug = "true" *)output reg video_o_v,
	(* mark_debug = "true" *)output reg video_o_h,
	(* mark_debug = "true" *)output reg video_o_dav,
	(* mark_debug = "true" *)output reg video_o_dav_with_temp,
	(* mark_debug = "true" *)output reg video_o_eoi,
	(* mark_debug = "true" *)output reg [BIT_WIDTH-1:0] video_o_data

);

//localparam [BIT_WIDTH-1:0] BAD_BLIND_PIX_LOW_TH  = 500,
//                           BAD_BLIND_PIX_HIGH_TH = 13000;

(* mark_debug = "true" *)reg [PIX_BITS-1:0] video_xcounti;
(* mark_debug = "true" *)reg [LIN_BITS-1:0] video_ycounti;


// assign video_xsize=VIDEO_XSIZE;
// assign video_ysize=VIDEO_YSIZE;

//video pixel counters 
always@(posedge clk, posedge rst) begin
	if(rst==1'b1) begin
		video_xcounti<=0;
		video_ycounti<=0;
	end
	else begin
		if (video_i_v == 1'b1 || video_i_h == 1'b1) begin
			video_xcounti<=0;
			if(video_i_v) video_ycounti <= 0;
			if(video_i_h) video_ycounti <= video_ycounti + 1;
		end
		if (video_i_dav==1'b1) begin
			video_xcounti<=video_xcounti+1;
		end
	end
end


// Averaging of various quantities
reg [LIN_BITS-1:0] exclude_top_rows;
reg [LIN_BITS-1:0] exclude_bottom_rows;
reg [PIX_BITS-1:0] exclude_left_columns;
reg [PIX_BITS-1:0] exclude_right_columns;

//reg [BIT_WIDTH-1:0] META1_AVG;
//reg [BIT_WIDTH-1:0] META2_AVG;
//reg [BIT_WIDTH-1:0] META3_AVG;

reg [31:0] META1_ACCUM;
reg [31:0] META2_ACCUM;
reg [31:0] META3_ACCUM;

reg [31:0] BLIND_PIXEL_ACCUM;
reg [31:0] BLIND_PIXEL_FRAME_ACCUM;

reg [BIT_WIDTH-1:0] BLIND_PIXEL_AVG_ROW;
reg [BIT_WIDTH-1:0] BLIND_PIXEL_AVG_FRAME;
reg blind_pixel_avg_row_valid;

reg [19:0] DARK_PIXEL_COUNT;
reg [19:0] DARK_PIXEL_COUNT_REG;

reg [19:0] SATURATED_PIXEL_COUNT;
reg [19:0] SATURATED_PIXEL_COUNT_REG;

reg [19:0] PIXEL_COUNT;
reg [19:0] PIXEL_COUNT_REG;

reg [33:0] PIXEL_ACCUM;

reg [BIT_WIDTH-1:0] IMG_AVG;

(* mark_debug = "true" *)reg start_div;
reg [33:0] divisor;
reg [33:0] dividend;
(* mark_debug = "true" *)wire done_div;
wire [33:0]quo;
wire [33:0]rmd;
reg [BIT_WIDTH-1:0] temp_video_i_data;

//(* mark_debug = "true" *)wire enable_column = (video_xcounti>=4 && video_xcounti<4+VIDEO_XSIZE)?1'b1:1'b0;
(* mark_debug = "true" *)wire enable_column = (video_xcounti == 0 || (video_xcounti>=4 && video_xcounti<4+VIDEO_XSIZE))?1'b1:1'b0; // to send META1 -temperature column (total 641)
(* mark_debug = "true" *)wire enable_row = (video_ycounti>exclude_top_rows && video_ycounti<=exclude_top_rows+VIDEO_YSIZE)?1'b1:1'b0;

`ifdef ENABLE_DEBUG_MSGS
initial begin
	forever begin
		@(posedge enable_row);
		@(posedge clk);
		@(posedge clk);
		$display("YCOUNT = %d",video_ycounti);
	end
end

`endif

function [31:0] multiply_by_const;
	// To divide by 480, we will first multiply by 2**16/480, and then right shift by 16 bits 2**16/480 ~137
	localparam [7:0] const_value=137;
	input [31:0] a;
	return a*const_value;
endfunction : multiply_by_const

always_ff @(posedge clk or posedge rst) begin : proc_window
	if(rst) begin
		exclude_top_rows 		<= 20;
		exclude_bottom_rows 	<= 19;
		exclude_left_columns 	<= 0;
		exclude_right_columns 	<= 0;
		META1_AVG 				<= 0;
		META2_AVG 				<= 0;
		META3_AVG 				<= 0;
		BLIND_PIXEL_AVG_ROW 	<= 0;
		BLIND_PIXEL_AVG_FRAME 	<= 0;
		META1_ACCUM  			<= 0;
		META2_ACCUM  			<= 0;
		META3_ACCUM 			<= 0;
		BLIND_PIXEL_ACCUM 		<= 0;
		BLIND_PIXEL_FRAME_ACCUM <= 0;
		DARK_PIXEL_COUNT 		<= 0;
		DARK_PIXEL_COUNT_REG 	<= 0;
		SATURATED_PIXEL_COUNT 	<= 0;
		SATURATED_PIXEL_COUNT_REG <=0;
		PIXEL_COUNT 			<= 0;
		PIXEL_COUNT_REG 		<= 0;
		PIXEL_ACCUM 			<= 0;
		IMG_AVG 				<= 0;
		dividend 				<= 0;
		divisor 				<= 0;
		blind_pixel_avg_row_valid <= 1'b0;
		start_div 				  <= 1'b0;
		blind_pix_avg_frame_valid 		<= 1'b0;
		blind_pix_avg_frame 		<= 0;
		temp_video_i_data           <= 'd8000;
	end else begin
		blind_pixel_avg_row_valid <= 1'b0;
		start_div 				  <= 1'b0;
		blind_pix_avg_frame_valid 		<= 1'b0;
		if(enable_row) begin 
			if(video_xcounti==0 && video_i_dav) begin
				META1_ACCUM <= META1_ACCUM + video_i_data;
			end
			else if(video_xcounti==1 && video_i_dav) begin 
				META2_ACCUM <= META2_ACCUM + video_i_data;
			end
			else if(video_xcounti==2 && video_i_dav) begin 
				META3_ACCUM <= META3_ACCUM + video_i_data;
			end
			else if(video_xcounti>=4 && video_xcounti<4+VIDEO_XSIZE && video_i_dav) begin
//				if(video_i_data<133) begin DARK_PIXEL_COUNT <= DARK_PIXEL_COUNT + 1; end
				if(video_i_data<dark_pix_th) begin DARK_PIXEL_COUNT <= DARK_PIXEL_COUNT + 1; end
//				else if(video_i_data>=2**BIT_WIDTH-1-133) begin SATURATED_PIXEL_COUNT <= SATURATED_PIXEL_COUNT +1; end
				else if(video_i_data>=saturated_pix_th) begin SATURATED_PIXEL_COUNT <= SATURATED_PIXEL_COUNT +1; end
				else begin PIXEL_ACCUM <= PIXEL_ACCUM + video_i_data; PIXEL_COUNT <= PIXEL_COUNT + 1; end
			end	
			else if(video_xcounti>=4+VIDEO_XSIZE+2 && video_xcounti<4+VIDEO_XSIZE+2+16 && video_i_dav) begin
//			else if(video_xcounti>=4+VIDEO_XSIZE+2 && video_xcounti<4+VIDEO_XSIZE+2+1 && video_i_dav) begin
//				BLIND_PIXEL_ACCUM <= BLIND_PIXEL_ACCUM + video_i_data;
				if(blind_badpix_remove_en)begin
				    if(video_i_data > BAD_BLIND_PIX_LOW_TH && video_i_data < BAD_BLIND_PIX_HIGH_TH)begin
                        temp_video_i_data <= video_i_data;
                        BLIND_PIXEL_ACCUM <= BLIND_PIXEL_ACCUM + video_i_data;
                    end 
                    else begin
				        BLIND_PIXEL_ACCUM <= BLIND_PIXEL_ACCUM + temp_video_i_data;
				    end  
				end      
				else begin
				   BLIND_PIXEL_ACCUM <= BLIND_PIXEL_ACCUM + video_i_data;
				end   
//				BLIND_PIXEL_ACCUM <=  video_i_data;
			end
			else if(video_xcounti==4+VIDEO_XSIZE+2+16+1 && video_i_dav) begin 
//				// BLIND_PIXEL_ROW_ACCUM <= BLIND_PIXEL_ROW_ACCUM + (BLIND_PIXEL_ACCUM >> 4);
				BLIND_PIXEL_AVG_ROW <= (BLIND_PIXEL_ACCUM >> 4);
				BLIND_PIXEL_ACCUM <= 0;
				BLIND_PIXEL_FRAME_ACCUM <= BLIND_PIXEL_FRAME_ACCUM + (BLIND_PIXEL_ACCUM >> 4);
				blind_pixel_avg_row_valid <= 1'b1;
			end
		end
		else begin
			if(video_ycounti==exclude_top_rows+VIDEO_YSIZE+1 && video_xcounti==0 && video_i_dav) begin
				META1_ACCUM <= multiply_by_const(META1_ACCUM);
			end
			else if(video_ycounti==exclude_top_rows+VIDEO_YSIZE+1 && video_xcounti==1 && video_i_dav) begin
				META2_ACCUM <= multiply_by_const(META2_ACCUM);
			end
			else if(video_ycounti==exclude_top_rows+VIDEO_YSIZE+1 && video_xcounti==2 && video_i_dav) begin
				META3_ACCUM <= multiply_by_const(META3_ACCUM);
			end
			else if(video_ycounti==exclude_top_rows+VIDEO_YSIZE+1 && video_xcounti==3 && video_i_dav) begin
				BLIND_PIXEL_FRAME_ACCUM <= multiply_by_const(BLIND_PIXEL_FRAME_ACCUM);
			end
			else if(video_ycounti==exclude_top_rows+VIDEO_YSIZE+1 && video_xcounti==4 && video_i_dav) begin
				META1_AVG 						<= META1_ACCUM >> 16;
				META2_AVG 						<= META2_ACCUM >> 16;
				META3_AVG 						<= META3_ACCUM >> 16;
				BLIND_PIXEL_AVG_FRAME 			<= BLIND_PIXEL_FRAME_ACCUM >> 16;
				META1_ACCUM 					<= 0;
				META2_ACCUM 					<= 0;
				META3_ACCUM 					<= 0;
				BLIND_PIXEL_FRAME_ACCUM  		<= 0;
				DARK_PIXEL_COUNT_REG 			<= DARK_PIXEL_COUNT;
				SATURATED_PIXEL_COUNT_REG 		<= SATURATED_PIXEL_COUNT;
				PIXEL_COUNT_REG 				<= PIXEL_COUNT;
				DARK_PIXEL_COUNT 				<= 0;
				SATURATED_PIXEL_COUNT 			<= 0;
				PIXEL_ACCUM 					<= 0;
				PIXEL_COUNT 					<= 0;
				dividend 						<= PIXEL_ACCUM;
				divisor 						<= PIXEL_COUNT;
				start_div 						<= 1'b1;
				blind_pix_avg_frame_valid 		<= 1'b1;
				blind_pix_avg_frame 			<= BLIND_PIXEL_FRAME_ACCUM >> 16;
			end
		end // else
		if(done_div) begin 
			IMG_AVG <= quo[BIT_WIDTH-1:0];
		end
	end
end

div	# (.W(34),
	   .CBIT(6))
DIVISION_Distribution_Value(
		.clk(clk), 
		.reset(rst), 
		.start(start_div),
		.dvsr(divisor), 
		.dvnd(dividend) ,
		.done_tick(done_div), 
		.quo(quo),
		.rmd(rmd) 
		);

(* mark_debug = "true" *)wire fifo_wr_en = enable_row && enable_column && video_i_dav;
wire [BIT_WIDTH-1:0] fifo_din  = video_i_data;
(* mark_debug = "true" *)wire wr_clk = clk;

(* mark_debug = "true" *)wire fifo_almost_empty;
(* mark_debug = "true" *)wire fifo_almost_full;
(* mark_debug = "true" *)wire fifo_data_valid;
(* mark_debug = "true" *)wire [BIT_WIDTH-1:0] fifo_dout;
(* mark_debug = "true" *)wire fifo_overflow;
(* mark_debug = "true" *)wire fifo_underflow;

(* mark_debug = "true" *)wire fifo_wr_ack;
(* mark_debug = "true" *)wire [5:0] fifo_wr_data_count;
(* mark_debug = "true" *)wire [5:0] fifo_rd_data_count;

(* mark_debug = "true" *)wire fifo_wr_rst_busy;
(* mark_debug = "true" *)wire fifo_rd_rst_busy;

(* mark_debug = "true" *)wire fifo_empty;
(* mark_debug = "true" *)wire fifo_full;

(* mark_debug = "true" *)reg fifo_read;

(* mark_debug = "true" *)wire fifo_rd_en = fifo_read;

xpm_fifo_sync #(
	.DOUT_RESET_VALUE("0"),    // String
	.ECC_MODE("no_ecc"),       // String
	.FIFO_MEMORY_TYPE("auto"), // String
	.FIFO_READ_LATENCY(1),     // DECIMAL
	.FIFO_WRITE_DEPTH(2**PIX_BITS),   // DECIMAL
	.FULL_RESET_VALUE(0),      // DECIMAL
	.PROG_EMPTY_THRESH(10),    // DECIMAL
	.PROG_FULL_THRESH(10),     // DECIMAL
	.RD_DATA_COUNT_WIDTH(6),   // DECIMAL
	.READ_DATA_WIDTH(BIT_WIDTH),      // DECIMAL
	.READ_MODE("std"),         // String
	.USE_ADV_FEATURES("1F0F"), // String
	.WAKEUP_TIME(0),           // DECIMAL
	.WRITE_DATA_WIDTH(BIT_WIDTH),     // DECIMAL
	.WR_DATA_COUNT_WIDTH(6)    // DECIMAL
)
xpm_fifo_async_inst (
	.almost_empty(fifo_almost_empty),   
	.almost_full(fifo_almost_full),     
	.data_valid(fifo_data_valid),       
	.dbiterr(),             
	.dout(fifo_dout), 
	.empty(fifo_empty),                 
	.full(fifo_full),                   
	.overflow(fifo_overflow),          
	.prog_empty(),       
	.prog_full(),        
	.rd_data_count(fifo_rd_data_count),
	.rd_rst_busy(fifo_rd_rst_busy),  
	.sbiterr(),            
	.underflow(fifo_underflow),         
	.wr_ack(fifo_wr_ack),               
	.wr_data_count(fifo_wr_data_count), 
	.wr_rst_busy(fifo_wr_rst_busy),     
	.din(fifo_din),                     
	.injectdbiterr(1'b0), 
	.injectsbiterr(1'b0),       
	.rd_en(fifo_rd_en),                 
	.rst(rst),                     
	.sleep(1'b0),                 
	.wr_clk(wr_clk),               
	.wr_en(fifo_wr_en)                  
);

localparam 	s_idle = 'd0,
			s_send_v = 'd1,
			s_send_h = 'd2,
			s_send_data = 'd3,
			s_send_eoi = 'd4,
			s_wait_fifo_empty = 'd5,
			s_wait_fifo = 'd6;


(* mark_debug = "true" *)reg [4:0] video_out_fsm;

(* mark_debug = "true" *)reg [PIX_BITS-1:0] xcount;
(* mark_debug = "true" *)reg [LIN_BITS-1:0] ycount;

reg signed [BIT_WIDTH:0] blind_pix_sum;

//wire signed [BIT_WIDTH+1:0] video_data = $signed({2'd0,fifo_dout}) + blind_pix_sum ;
wire signed [BIT_WIDTH+1:0] video_data = (xcount == 1) ? $signed({2'd0,fifo_dout}) :$signed({2'd0,fifo_dout}) + blind_pix_sum ; // To send META1 - Temperature data
//(* mark_debug = "true" *)wire video_dav = fifo_data_valid;
(* mark_debug = "true" *)wire video_dav = (xcount == 1) ? 1'b0 : fifo_data_valid; //(for 640)
(* mark_debug = "true" *)wire video_dav_with_temp = fifo_data_valid;              // for (641)

always_ff @(posedge clk) begin : proc_video_data
	video_o_dav <= video_dav;
	video_o_dav_with_temp <= video_dav_with_temp;
	if(video_data<0) begin	
		video_o_data <= 0;
	end else if(video_data>2**BIT_WIDTH -1) begin
		video_o_data <= 2**BIT_WIDTH -1;
	end else begin
		video_o_data <= video_data;
	end
end


(* mark_debug = "true" *)reg [7:0] wait_count;


reg signed [BIT_WIDTH:0] TARGET_VIDEO = 'd8192;
(* mark_debug = "true" *)reg blind_pix_sub_en;
(* mark_debug = "true" *)reg blind_pix_sub_en_reg;

always_ff @(posedge clk or posedge rst) begin : proc_video_out_fsm
	if(rst) begin
		video_out_fsm <= s_idle;
		video_o_v 	<= 1'b0;
		video_o_h 	<= 1'b0;
		video_o_eoi <= 1'b0;
		fifo_read 	<= 1'b0;

		xcount 		<= 0;
		ycount 		<= 0;
		wait_count 	<= 0;
		blind_pix_sub_en_reg <= 0;
	end else begin
		video_o_v <= 1'b0;
		video_o_h <= 1'b0;
		video_o_eoi <= 1'b0;
		fifo_read <= 1'b0;
		case(video_out_fsm)
			s_idle :begin
				// wait for blind pixel avg to be available
				if(video_i_v) blind_pix_sub_en_reg <= blind_pix_sub_en;
				if(blind_pixel_avg_row_valid) begin
					if(blind_pix_sub_en_reg) begin
						blind_pix_sum <= TARGET_VIDEO - $signed({1'b0,BLIND_PIXEL_AVG_ROW});
					end else begin
						blind_pix_sum <= 0;
					end
					xcount <= 0;
					ycount <= 0;
					video_out_fsm <= s_send_v;
				end 
			end
			
			s_send_v: begin 
				video_o_v <= 1'b1;
				video_out_fsm <= s_send_h;
			end

			s_send_h: begin 
				video_o_h <= 1'b1;
				video_out_fsm <= s_send_data;
			end

			s_send_data: begin 
//				if(xcount==VIDEO_XSIZE) begin
				if(xcount==VIDEO_XSIZE + 1) begin // to add temperature meta data with video data (1+640)
					if(ycount==VIDEO_YSIZE-1) begin
						wait_count	<= 4; 
						video_out_fsm <= s_send_eoi;	
					end 
					else begin 
						video_out_fsm <= s_wait_fifo;
					end
				end
				else if((!fifo_almost_empty && !fifo_empty && fifo_read==1'b0) || (fifo_almost_empty && !fifo_empty && fifo_read==1'b0)) begin
					fifo_read <= 1'b1;
					xcount <= xcount + 1;
				end
			end

			s_send_eoi: begin 
				ycount <= 0;
				xcount <= 0;
				if(wait_count==0) begin
					video_o_eoi <= 1'b1;
					video_out_fsm <= s_idle;
				end else begin 
					wait_count <= wait_count - 1;
				end
			end

			s_wait_fifo_empty: begin 
				if(fifo_empty) begin
					video_out_fsm <= s_wait_fifo;
				end
			end

			s_wait_fifo: begin
				if(blind_pixel_avg_row_valid) begin
					if(blind_pix_sub_en_reg) begin
						blind_pix_sum <= TARGET_VIDEO - $signed({1'b0,BLIND_PIXEL_AVG_ROW});
					end else begin
						blind_pix_sum <= 0;
					end
					xcount <= 0;
					ycount <= ycount + 1;
					video_out_fsm <= s_send_h;
				end
			end
		endcase // video_out_fsm
	end
end


always_ff @(posedge clk or posedge rst) begin : proc_sensor_param
	if(rst) begin
		av_sensor_waitrequest 		<= 0;
		av_sensor_readdatavalid 	<= 0;
		av_sensor_readdata 			<= 0;
		blind_pix_sub_en			<= 1;
	end else begin

		av_sensor_waitrequest 		<= 0;
		av_sensor_readdatavalid 	<= 0;

		if(av_sensor_write) begin 
			case (av_sensor_address)
			 	4'd0: begin blind_pix_sub_en 		<= av_sensor_writedata[0]; 			end
				default : /* default */;
			endcase
		end
		else if(av_sensor_read) begin 
			av_sensor_readdatavalid <= 1'b1;
			case (av_sensor_address)
				4'd0: begin av_sensor_readdata <= {31'd0, blind_pix_sub_en}; 				end
				4'd1: begin av_sensor_readdata <= {18'd0, META1_AVG}; 						end
				4'd2: begin av_sensor_readdata <= {18'd0, META2_AVG}; 						end
				4'd3: begin av_sensor_readdata <= {18'd0, META3_AVG}; 						end
				4'd4: begin av_sensor_readdata <= {18'd0, BLIND_PIXEL_AVG_FRAME}; 			end
				4'd5: begin av_sensor_readdata <= {18'd0, BLIND_PIXEL_AVG_ROW}; 			end
				4'd6: begin av_sensor_readdata <= DARK_PIXEL_COUNT_REG; 					end
				4'd7: begin av_sensor_readdata <= SATURATED_PIXEL_COUNT_REG; 				end
				4'd8: begin av_sensor_readdata <= PIXEL_COUNT_REG; 							end
				4'd9: begin av_sensor_readdata <= IMG_AVG; 									end
				default: begin av_sensor_readdata <= 32'hDEAD_BEEF; 						end
			endcase
		end
	end
end

`ifdef ILA_SENSOR_WINDOW

wire [127:0] probe0;
TOII_TUVE_ila ila_sensor_winndow(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {5'd0,
blind_badpix_remove_en,
temp_video_i_data,
video_i_data,
rst,
wait_count,
video_out_fsm,
BLIND_PIXEL_ACCUM,
//xcount,
//ycount,
video_i_v,  
video_i_h,  
video_i_dav,
video_i_eoi,
video_o_v,  
video_o_h,  
video_o_dav,
video_o_eoi,
video_xcounti,
video_ycounti,
enable_column,
enable_row,
blind_pixel_avg_row_valid,
blind_pix_avg_frame_valid,
fifo_empty,
fifo_full,
fifo_read,
fifo_wr_en,
fifo_almost_empty,
fifo_almost_full,
fifo_data_valid,
fifo_overflow,
fifo_underflow,
fifo_wr_ack,
//fifo_wr_data_count,
//fifo_rd_data_count,
fifo_wr_rst_busy,
fifo_rd_rst_busy,
blind_pix_sub_en,
blind_pix_sub_en_reg,
start_div,
done_div
};

`endif

endmodule 