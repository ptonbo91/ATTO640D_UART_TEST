
/*----------------------------------------------------------------
-- Copyright    : Tonbo Imaging
-- Contact      : info@tonboimaging.com
-- Project Name : Tonboimaging - Thermal Camera Project 
-- Block Name   : coarse_offset_cal
-- Description  : Calculate the coarse offset data to be sent to
-- 				  sensor
-- Author       : Aneesh M. U.
----------------------------------------------------------------*/
`timescale 1ns/1ps
// `define ILA_DEBUG
module coarse_offset_cal #(
	parameter 	BIT_WIDTH = 16,
			 	PIX_BITS = 10,
			 	LIN_BITS = 10,
			 	VIDEO_XSIZE = 640,
			 	VIDEO_YSIZE = 480
	) (
	(* mark_debug = "true" *)input clk,
	(* mark_debug = "true" *)input rst,

		output reg 		av_sensor_waitrequest,
		input 			av_sensor_write,
		input [31:0] 	av_sensor_writedata,
		input [3:0] 	av_sensor_address,
		input 			av_sensor_read,
		output reg 		av_sensor_readdatavalid,
		output reg [31:0] av_sensor_readdata,

		input av_coarse_read,
		input [10:0] av_coarse_address,
		output [8:0] av_coarse_readdata,
		output av_coarse_readdatavalid,
		output av_coarse_waitrequest,
	
	(* mark_debug = "true" *)input video_i_v,
	(* mark_debug = "true" *)input video_i_h,
	(* mark_debug = "true" *)input video_i_dav,
	(* mark_debug = "true" *)input video_i_eoi,
	(* mark_debug = "true" *)input [BIT_WIDTH-1:0] video_i_data

);

reg enable_fifo;
wire enable_fifo_line;
wire fifo_wr_en = enable_fifo && enable_fifo_line && video_i_dav;
wire [BIT_WIDTH-1:0] fifo_din  = video_i_data;
wire wr_clk = clk;

wire fifo_almost_empty;
wire fifo_almost_full;
(* mark_debug = "true" *)wire fifo_data_valid;
wire [BIT_WIDTH-1:0] fifo_dout;
wire fifo_overflow;
wire fifo_underflow;

wire fifo_wr_ack;
wire [5:0] fifo_wr_data_count;
wire [5:0] fifo_rd_data_count;

wire fifo_wr_rst_busy;
wire fifo_rd_rst_busy;

(* mark_debug = "true" *)wire fifo_empty;
(* mark_debug = "true" *)wire fifo_full;

(* mark_debug = "true" *)reg fifo_read;

wire fifo_rd_en = fifo_read;

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
	.USE_ADV_FEATURES("1707"), // String
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

reg [15:0] average_coarse_offset_gain;
reg [LIN_BITS-1:0] store_line_num;

reg [LIN_BITS-1:0] video_ycounter;
always_ff @(posedge clk or posedge rst) begin : proc_video_counter
	if(rst) begin
		video_ycounter <= 0;
	end else begin
		if(video_i_v) begin
			video_ycounter <= 0;
		end
		if(video_i_h) begin 
			video_ycounter <= video_ycounter + 1;
		end
	end
end

assign enable_fifo_line = (video_ycounter==store_line_num)?1'b1:1'b0;

reg [3:0] coarse_offset_fsm;
localparam s_idle = 4'd0,
			s_read_fifo = 4'd1,
			s_start_div = 4'd2,
			s_store_result = 4'd3;

reg start_coarse_offset_cal;
reg [7:0] coarse_offset_dc;
reg use_updated_coarse_offset;
reg use_flat_coarse_offset;
always_ff @(posedge clk or posedge rst) begin : proc_sensor_param
	if(rst) begin
		av_sensor_waitrequest 		<= 0;
		av_sensor_readdatavalid 	<= 0;
		av_sensor_readdata 			<= 0;
		average_coarse_offset_gain 	<= 1000;
		store_line_num 				<= 1;
		start_coarse_offset_cal  	<= 0;
		coarse_offset_dc 			<= 'hB4;
		use_updated_coarse_offset 	<= 0;
		use_flat_coarse_offset 		<= 0;
	end else begin
		start_coarse_offset_cal  	<= 0;
		av_sensor_waitrequest 		<= 0;
		av_sensor_readdatavalid 	<= 0;

		if(av_sensor_write) begin 
			case(av_sensor_address)
				4'd0: begin start_coarse_offset_cal <= 1'b1; 							end
				4'd1: begin	average_coarse_offset_gain <= av_sensor_writedata[15:0]; 	end
				4'd2: begin store_line_num <= av_sensor_writedata[LIN_BITS-1:0]; 	 	end
				4'd3: begin coarse_offset_dc <= av_sensor_writedata[7:0]; 				end
				4'd4: begin use_updated_coarse_offset <= av_sensor_writedata[0]; use_flat_coarse_offset <= av_sensor_writedata[1];		end
			endcase
		end
		else if(av_sensor_read) begin 
			av_sensor_readdatavalid <= 1'b1;
			case (av_sensor_address)
				4'd0: 	begin 
							if(coarse_offset_fsm!=s_idle)
								av_sensor_readdata <= 1;
							else
								av_sensor_readdata <= 0;
						end
				4'd1: begin av_sensor_readdata <= average_coarse_offset_gain; 										end
				4'd2: begin av_sensor_readdata <= store_line_num; 													end
				4'd3: begin av_sensor_readdata <= coarse_offset_dc; 												end
				4'd4: begin av_sensor_readdata <= {use_flat_coarse_offset, use_updated_coarse_offset}; 				end
				default: begin av_sensor_readdata <= 32'hDEAD_BEEF; 												end
			endcase
		end

	end
end 

reg start_coarse_offset_cal_reg;
always_ff @(posedge clk or posedge rst) begin : proc_enable_fifo
	if(rst) begin
		start_coarse_offset_cal_reg	<= 0;
		enable_fifo <= 0;
	end else begin
		if(start_coarse_offset_cal && start_coarse_offset_cal_reg==0) begin
			start_coarse_offset_cal_reg <= 1'b1;
		end
		if(start_coarse_offset_cal_reg && video_i_v) begin
			enable_fifo <= 1'b1;
		end
		if(enable_fifo && video_i_eoi) begin
			start_coarse_offset_cal_reg <= 1'b0;
			enable_fifo <= 1'b0;
		end
	end
end

reg [BIT_WIDTH-1:0] TARGET_VIDEO = 'd8192;
reg [PIX_BITS-1:0] xcounter;
reg [PIX_BITS-1:0]addr_d;
reg signed [8:0] data_d;
reg we_d;

reg start_div;
reg [15:0] divisor;
reg [15:0] dividend;
wire done_div;
wire [15:0]quo;
wire [15:0]rmd;

reg negative_div;

wire [PIX_BITS-1:0] addra = addr_d;
wire [7:0] dina = (data_d<0)?0:((data_d>255)?255:data_d);
wire [7:0] douta;
wire wea = we_d;
wire ena = 1'b1;

wire [PIX_BITS-1:0]addrb = av_coarse_address;
wire enb = av_coarse_read;
wire [7:0] dinb = 0;
wire [7:0]doutb;
wire web = 1'b0;


always_ff @(posedge clk or posedge rst) begin : proc_coarse_offset_cal
	if(rst) begin
		coarse_offset_fsm <= s_idle;
		fifo_read <= 1'b0;
		negative_div <= 1'b0;
		start_div <= 1'b0;
		xcounter <= 0;
		we_d <= 1'b0;
	end else begin
		start_div <= 1'b0;
		fifo_read <= 1'b0;
		we_d <= 1'b0;
		case(coarse_offset_fsm)
			s_idle: begin 
				if(start_coarse_offset_cal) begin 
					coarse_offset_fsm <= s_read_fifo;
					xcounter <= 0;
				end
			end
			s_read_fifo: begin 
				if(!fifo_empty) begin 
					fifo_read <= 1'b1;
					coarse_offset_fsm <= s_start_div;
				end
			end
			s_start_div: begin 
				if(fifo_data_valid) begin 
					if(fifo_dout > TARGET_VIDEO) begin dividend <= fifo_dout - TARGET_VIDEO; negative_div <= 1'b0; end
					else begin dividend <= TARGET_VIDEO - fifo_dout; negative_div <= 1'b1; end
					divisor <= average_coarse_offset_gain;
					start_div <= 1'b1;
					coarse_offset_fsm <= s_store_result;
					addr_d <= xcounter;
				end
			end
			s_store_result: begin 
				if(done_div) begin 
					xcounter <= xcounter + 1;
					if(xcounter==VIDEO_XSIZE-1) begin 
						xcounter <= 0;
						coarse_offset_fsm <= s_idle;
					end
					else begin 
						coarse_offset_fsm <= s_read_fifo;
					end
					addr_d <= xcounter;
					if(use_updated_coarse_offset) begin
						data_d <= (negative_div)?(douta - quo[7:0]):(douta + quo[7:0]);
					end else if(use_flat_coarse_offset) begin
						data_d <= coarse_offset_dc;
					end else begin	
						data_d <= (negative_div)?(coarse_offset_dc - quo[7:0]):(coarse_offset_dc + quo[7:0]);
					end
					we_d <= 1'b1; 
				end
			end
		endcase
	end
end

reg readdatavalid[0:1];

assign av_coarse_waitrequest = 0;
assign av_coarse_readdatavalid = readdatavalid[1]; 
assign av_coarse_readdata = doutb;


always_ff @(posedge clk) begin : proc_valid_delay
	readdatavalid <= {av_coarse_read, readdatavalid[0]};
end


xpm_memory_tdpram #(
      .ADDR_WIDTH_A(PIX_BITS),               // DECIMAL
      .ADDR_WIDTH_B(PIX_BITS),               // DECIMAL
      .AUTO_SLEEP_TIME(0),            // DECIMAL
      .MEMORY_SIZE(VIDEO_XSIZE*8),             // DECIMAL
      .MESSAGE_CONTROL(0),            // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String

      .BYTE_WRITE_WIDTH_A(8),        // DECIMAL
      .BYTE_WRITE_WIDTH_B(8),        // DECIMAL
      .CLOCKING_MODE("common_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .MEMORY_INIT_FILE("line_coarse.mem"),      // String
      .MEMORY_INIT_PARAM("0"),        // String
      .MEMORY_OPTIMIZATION("true"),   // String
      .MEMORY_PRIMITIVE("auto"),      // String
      .READ_DATA_WIDTH_A(8),         // DECIMAL
      .READ_DATA_WIDTH_B(8),         // DECIMAL
      .READ_LATENCY_A(2),             // DECIMAL
      .READ_LATENCY_B(2),             // DECIMAL
      .READ_RESET_VALUE_A("0"),       // String
      .READ_RESET_VALUE_B("0"),       // String
      .RST_MODE_A("SYNC"),            // String
      .RST_MODE_B("SYNC"),            // String
      .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
      .USE_MEM_INIT(1),               // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String
      .WRITE_DATA_WIDTH_A(8),        // DECIMAL
      .WRITE_DATA_WIDTH_B(8),        // DECIMAL
      .WRITE_MODE_A("no_change"),     // String
      .WRITE_MODE_B("no_change")      // String
   )
xpm_memory_tdpram_line_x (
      .dbiterrb(),
      .dbiterra(),
      .douta(douta),
      .doutb(doutb),
      .sbiterrb(),
      .sbiterra(),
      .addra(addra),
      .addrb(addrb),
      .clka(clk),
      .clkb(clk),
      .dina(dina),
      .dinb(dinb),
      .ena(ena),
      .enb(enb),
      .injectdbiterra(1'b0),
      .injectsbiterra(1'b0),
      .injectdbiterrb(1'b0),
      .injectsbiterrb(1'b0),
      .regcea(1'b1),
      .regceb(1'b1),
      .rsta(rst),
      .rstb(rst),
      .sleep(1'b0),
      .wea(wea),
      .web(web)
   );

div	# (.W(16),
	   .CBIT(5))
DIVISION_COARSE_OFFSET(
		.clk(clk), 
		.reset(rst), 
		.start(start_div),
		.dvsr(divisor), 
		.dvnd(dividend) ,
		.done_tick(done_div), 
		.quo(quo),
		.rmd(rmd) 
		);

endmodule // coarse_offset_cal