// `define ILA_SNAP
module snapshot 
#( parameter PIX_BITS = 10,
	LIN_BITS = 10,
	WR_SIZE = 16,
	DMA_SIZE_BITS=5
	)
	(
	input clk,    // Clock	
	input rst,  // Asynchronous reset active low

	(* mark_debug = "true" *)input start,
	(* mark_debug = "true" *)output busy,
	(* mark_debug = "true" *)output done,
	input [2:0] 		 channel,
	input [31:0] 		 base_addr,
	
	input 				 src_1_v,
	input 				 src_1_h,
	input 				 src_1_eoi,
	input 				 src_1_dav,
	input [16-1:0] 		 src_1_data,
	input [PIX_BITS-1:0] src_1_xsize,
	input [LIN_BITS-1:0] src_1_ysize,

	input 				 src_2_v,
	input 				 src_2_h,
	input 				 src_2_eoi,
	input 				 src_2_dav,
	input [16-1:0] 		 src_2_data,
	input [PIX_BITS-1:0] src_2_xsize,
	input [LIN_BITS-1:0] src_2_ysize,

	input 				 src_3_v,
	input 				 src_3_h,
	input 				 src_3_eoi,
	input 				 src_3_dav,
	input [08-1:0] 		 src_3_data,
	input [PIX_BITS-1:0] src_3_xsize,
	input [LIN_BITS-1:0] src_3_ysize,

    input 				 src_4_v,
	input 				 src_4_h,
	input 				 src_4_eoi,
	input 				 src_4_dav,
	input [16-1:0] 		 src_4_data,
	input [PIX_BITS-1:0] src_4_xsize,
	input [LIN_BITS-1:0] src_4_ysize,
	
	input  						dma_wrready,
	output 						dma_wrreq,  
	output 						dma_wrburst,
	output [DMA_SIZE_BITS-1:0]  dma_wrsize, 
	(* mark_debug = "true" *)output [31:0] 				dma_wraddr, 
	output [31:0] 				dma_wrdata, 
	output [3:0]  				dma_wrbe
);

localparam FIFO_DEPTH = 10;
localparam FIFO_WIDTH = 32;

reg [31:0] base_addr_d;

wire [DMA_SIZE_BITS-1:0] wrsize_max = WR_SIZE;

wire wr_clk = clk;
//wire rst = rst;
wire [FIFO_WIDTH-1:0] dout;
wire [FIFO_DEPTH:0] rd_data_count;
wire [FIFO_DEPTH:0] wr_data_count;

wire rd_rst_busy, wr_rst_busy;
(* mark_debug = "true" *)wire empty, full;

reg [FIFO_WIDTH-1:0] din;
(* mark_debug = "true" *)wire rd_en;

(* mark_debug = "true" *)reg wr_en;

reg [2:0] channel_d;
reg start_l;

assign busy = start_l;

(* mark_debug = "true" *)reg [3:0]fifo_fsm;

localparam s_idle = 'd0,
		   s_enable_channel = 'd1,
		   s_write_data = 'd2,
		   s_wait_fifo_empty = 'd3;

reg [3:0] bytes_per_pixel;

(* mark_debug = "true" *)reg 			 	src_v; 		
(* mark_debug = "true" *)reg 			 	src_h;
(* mark_debug = "true" *)reg 			 	src_eoi;
(* mark_debug = "true" *)reg 			 	src_dav;
reg [16-1:0] 	 	src_data;
reg [PIX_BITS-1:0] 	src_xsize;
reg [LIN_BITS-1:0]	src_ysize;

always @(*) begin : proc_mux_channels
	case(channel_d)
		0: begin 
			src_v 			= src_1_v; 		
			src_h 			= src_1_h;
			src_eoi 		= src_1_eoi;
			src_dav 		= src_1_dav;
			src_data 		= src_1_data;
			src_xsize 		= src_1_xsize;
			src_ysize 		= src_1_ysize;
			bytes_per_pixel = 2;
		end
		1: begin 
			src_v 			= src_2_v; 		
			src_h 			= src_2_h;
			src_eoi 		= src_2_eoi;
			src_dav 		= src_2_dav;
			src_data 		= src_2_data;
			src_xsize 		= src_2_xsize;
			src_ysize 		= src_2_ysize;
			bytes_per_pixel = 2;
		end
		2: begin 
			src_v 			= src_3_v; 		
			src_h 			= src_3_h;
			src_eoi 		= src_3_eoi;
			src_dav 		= src_3_dav;
			src_data 		= src_3_data;
			src_xsize 		= src_3_xsize;
			src_ysize 		= src_3_ysize;
			bytes_per_pixel = 1;
		end
		3: begin 
			src_v 			= src_4_v; 		
			src_h 			= src_4_h;
			src_eoi 		= src_4_eoi;
			src_dav 		= src_4_dav;
			src_data 		= src_4_data;
			src_xsize 		= src_4_xsize;
			src_ysize 		= src_4_ysize;
			bytes_per_pixel = 2;
		end		
		default: begin 
			src_v 			= src_1_v; 		
			src_h 			= src_1_h;
			src_eoi 		= src_1_eoi;
			src_dav 		= src_1_dav;
			src_data 		= src_1_data;
			src_xsize 		= src_1_xsize;
			src_ysize 		= src_1_ysize;
			bytes_per_pixel = 2;
		end
	endcase // channel_d
end

reg [3:0] fifo_select;
reg [PIX_BITS+LIN_BITS-1:0] total_pixels;
reg [PIX_BITS+LIN_BITS-1:0] pixels_left;
(* mark_debug = "true" *)reg done_reg;

// Control FIFO input
always @(posedge clk or posedge rst) begin : proc_fifo_input_ctrl
	if(rst) begin
		channel_d <= 0;
		start_l <= 0;
		fifo_fsm <= s_idle;
		din <= 0;
		fifo_select <= 0;
		total_pixels <= 0;
		done_reg <= 0;
		pixels_left <= 0;
	end else begin
		wr_en <= 1'b0;
		done_reg <= 0;

		case(fifo_fsm)
			s_idle: begin 
				fifo_select <= 0;
				if(start & wr_rst_busy==0 & rd_rst_busy==0) begin
					start_l <= 1'b1;
					channel_d <= channel;
					base_addr_d <= base_addr;
					fifo_fsm <= s_enable_channel;
				end
			end
			s_enable_channel: begin 
				if(src_v) begin 
					fifo_fsm <= s_write_data;
					total_pixels <= src_xsize * src_ysize;
					pixels_left <= src_xsize * src_ysize;
				end
			end
			s_write_data: begin 
				if(src_dav) begin 
					fifo_select <= fifo_select + 1;
					pixels_left <= pixels_left - 1;
					if(bytes_per_pixel==4) begin 
						din <= src_data;
						wr_en <= 1'b1;
					end
					else if(bytes_per_pixel==2) begin 
						case (fifo_select[0]) 
							0: begin 
								din[15:0] <= src_data;
							end
							1: begin 
								din[31:16] <= src_data;
								wr_en <= 1'b1;
							end
						endcase // fifo_select[0]
					end else begin 
						case (fifo_select[1:0])
							0: begin 
								din[7:0] <= src_data[7:0];
							end
							1: begin 
								din[15:8] <= src_data[7:0];
							end
							2:  begin 
								din[23:16] <= src_data[7:0];
							end
							3: begin 
								din[31:24] <= src_data[7:0];
								wr_en <= 1'b1;
							end
						endcase // fifo_select[1:0]
					end
					if(pixels_left==1) begin 
						fifo_fsm <= s_wait_fifo_empty;
					end
				end
			end
			s_wait_fifo_empty: begin 
				if(empty) begin 
					start_l <= 1'b0;
					done_reg <= 1'b1;
					fifo_fsm <= s_idle;
				end
			end
		endcase // fifo_fsm	
	end
end


assign done = done_reg;

xpm_fifo_sync #(
  .DOUT_RESET_VALUE("0"),    // String
  .ECC_MODE("no_ecc"),       // String
  .FIFO_MEMORY_TYPE("auto"), // String
  .FIFO_READ_LATENCY(0),     // DECIMAL
  .FIFO_WRITE_DEPTH(2**FIFO_DEPTH),   // DECIMAL
  .FULL_RESET_VALUE(0),      // DECIMAL
  .PROG_EMPTY_THRESH(10),    // DECIMAL
  .PROG_FULL_THRESH(10),     // DECIMAL
  .RD_DATA_COUNT_WIDTH(FIFO_DEPTH+1),   // DECIMAL
  .READ_DATA_WIDTH(FIFO_WIDTH),      // DECIMAL
  .READ_MODE("fwft"),         // String
  .USE_ADV_FEATURES("0707"), // String
  .WAKEUP_TIME(0),           // DECIMAL
  .WRITE_DATA_WIDTH(FIFO_WIDTH),     // DECIMAL
  .WR_DATA_COUNT_WIDTH(FIFO_DEPTH+1)    // DECIMAL
)
xpm_fifo_sync_inst (
   .almost_empty(),
   .almost_full(),
   .data_valid(),
   .dbiterr(),
  .dout(dout),
  .empty(empty),
  .full(full),
   .overflow(),
   .prog_empty(),
   .prog_full(),
  .rd_data_count(rd_data_count),
  .rd_rst_busy(rd_rst_busy),
   .sbiterr(),
   .underflow(),
   .wr_ack(),
  .wr_data_count(wr_data_count),
  .wr_rst_busy(wr_rst_busy),
  .din(din),
  .injectdbiterr(1'b0),
  .injectsbiterr(1'b0),
  .rd_en(rd_en),
  .rst(rst),
  .sleep(1'b0),
  .wr_clk(wr_clk),
  .wr_en(wr_en)
);

(* mark_debug = "true" *)wire wrready = dma_wrready;
(* mark_debug = "true" *)reg wrreq;
(* mark_debug = "true" *)reg wrburst;
wire [DMA_SIZE_BITS-1:0] wrsize; 
(* mark_debug = "true" *)reg [31:0] wraddr; 
wire [31:0] wrdata = dout; 
wire [3:0] wrbe = {4{1'b1}};

(* mark_debug = "true" *)reg [PIX_BITS+LIN_BITS-1:0] pixels_remaining;
(* mark_debug = "true" *)reg [3:0] pixels_per_beat;
(* mark_debug = "true" *)reg [DMA_SIZE_BITS-1:0] dma_cnt;
(* mark_debug = "true" *)reg [DMA_SIZE_BITS-1:0] wrsize_d; 

(* mark_debug = "true" *)reg [3:0] dma_fsm;
localparam s_start = 'd0,
			s_write1 = 'd1,
			s_write2 = 'd2,
			s_wait = 'd3;

reg [31:0] addr;

assign rd_en = (dma_fsm==s_write2)?(!empty && wrready):1'b0; 

(* mark_debug = "true" *)wire [FIFO_DEPTH:0] fifo_cnt = rd_data_count;

assign wrsize = wrsize_d;
always @(posedge clk or posedge rst) begin : proc_dma
	if(rst) begin
		dma_fsm <= s_start;
		dma_cnt <= 0;
		wrsize_d <= 0;
		pixels_per_beat <= 0;
		pixels_remaining <= 0;
		addr <= 0;
		wrreq <= 1'b0;
		wrburst <= 1'b0;
	end else begin
		case(dma_fsm)  
			s_start: begin 
				if(fifo_fsm==s_write_data) begin 
					dma_fsm <= s_write1;
					dma_cnt <= wrsize_max;
					wrsize_d <= wrsize_max;
					pixels_remaining <= total_pixels;
					addr <= 0;
					case(bytes_per_pixel) 
						1: pixels_per_beat <= 4;
						2: pixels_per_beat <= 2;
						3: pixels_per_beat <= 1;
						default: pixels_per_beat <= 4;
					endcase // bytes_per_pixel
				end
			end
			s_write1: begin // start burst writing
				wrburst <= 1'b0;
				if(empty==0 && fifo_cnt >= dma_cnt) begin 
					wrreq 	<= 1'b1;
					wrburst <= 1'b1;
					pixels_remaining <= pixels_remaining - dma_cnt*pixels_per_beat;
					dma_fsm <= s_write2;
				end
			end
			s_write2: begin 
				if(wrready) begin 
					wrburst <= 1'b0;
				end
				wrreq 	<= 1'b1;
				if(dma_cnt==1 && wrready) begin 
					addr <= addr + wrsize_d*4;
					dma_cnt <= wrsize_max;
					dma_fsm <= s_wait;
					wrreq <= 1'b0;
				end
				else if(rd_en) begin 
					dma_cnt <= dma_cnt - 1;
				end
			end
			s_wait: begin 
				if(pixels_remaining==0) begin 
						dma_fsm <= s_start;
				end else begin
					if(dma_cnt==0) begin 
						if(pixels_remaining < wrsize_d*pixels_per_beat) begin 
							case(bytes_per_pixel)
								1: begin 
									dma_cnt <= pixels_remaining >> 2;	
									wrsize_d <= pixels_remaining >> 2;	
								end 
								2: begin
									dma_cnt <= pixels_remaining >> 1;
									wrsize_d <= pixels_remaining >> 1;	
								end
								4: begin
									dma_cnt <= pixels_remaining;
									wrsize_d <= pixels_remaining;	
								end
								default: begin 
									dma_cnt <= pixels_remaining >> 2;
									wrsize_d <= pixels_remaining >> 2;
								end
							endcase // bytes_per_pixel
						end else begin 
							dma_cnt <= wrsize_max;
							wrsize_d <= wrsize_max;
						end
						dma_fsm <= s_write1;
					end else begin 
						dma_cnt <= dma_cnt - 1;
					end
				end
			end
		endcase // dma_fsm
	end
end


assign dma_wrreq = wrreq;
assign dma_wrdata = wrdata;
assign dma_wrsize = wrsize;
assign dma_wrbe = wrbe;
assign dma_wrburst = wrburst;
assign dma_wraddr = base_addr_d + addr;


`ifdef  ILA_SNAP

wire [127:0] probe0;
TOII_TUVE_ila ila_snap(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {25'd0, fifo_fsm, start, busy, dma_fsm, pixels_remaining, pixels_per_beat, bytes_per_pixel, wrsize_d, dma_cnt, empty, //51
			full, rd_en, done_reg, wr_en, src_v, src_h, src_dav, wrreq, wrready, dma_wraddr, fifo_cnt}; //52

`endif


endmodule