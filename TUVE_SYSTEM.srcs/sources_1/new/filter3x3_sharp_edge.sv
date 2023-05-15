`timescale 1ns/1ps
module filter3x3_sharp_edge
	#(
		parameter bitwidth = 14,
				  VIDEO_XSIZE = 640,
				  VIDEO_YSIZE = 480,
				  PIX_BITS = 10,
				  LIN_BITS = 9
		)
	(
	input clk,
	input rst,

	input av_wr,
   	input [7:0]av_addr,
   	input [15:0]av_data,
   	output av_busy,

	input video_i_v,	
	input video_i_h,	
	input video_i_eoi,	
	input video_i_dav,	
	input [bitwidth-1:0]video_i_data,

	output video_o_v,	
	output video_o_h,	
	output video_o_eoi,	
	output video_o_dav,	
	output [bitwidth-1:0]video_o_data
);


	filter3x3
#(
	.SHARP_EDGE(1),
	.bitwidth(bitwidth),
	.VIDEO_XSIZE(VIDEO_XSIZE),
	.VIDEO_YSIZE(VIDEO_YSIZE),
	.PIX_BITS(PIX_BITS),
	.LIN_BITS(LIN_BITS)	
	)
filter_inst_sharp_edge(
	.clk(clk),
	.rst(rst),
	.av_wr(av_wr),
	.av_addr(av_addr),
	.av_data(av_data),
 	.av_busy(av_busy),
	.video_i_v(video_i_v),	
	.video_i_h(video_i_h),	
	.video_i_eoi(video_i_eoi),	
	.video_i_dav(video_i_dav),	
	.video_i_data(video_i_data),
	.video_o_v(video_o_v),	
	.video_o_h(video_o_h),	
	.video_o_eoi(video_o_eoi),	
	.video_o_dav(video_o_dav),	
	.video_o_data(video_o_data)
);

endmodule // filter3x3_sharp_edge