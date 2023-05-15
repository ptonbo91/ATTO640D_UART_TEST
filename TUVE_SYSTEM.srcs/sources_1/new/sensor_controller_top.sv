`timescale 1ns/1ps
module sensor_controller_top
	#(
	parameter 	PIX_BITS 				= 10,
				LIN_BITS 				= 10,
				BIT_WIDTH               = 14,
				SENSOR_TOTAL_XSIZE 		= 780,
				SENSOR_TOTAL_YSIZE 		= 525,
				SENSOR_XSIZE 			= 664,
				SENSOR_YSIZE 			= 520
		)
	(
	input clk, 										// Same as pixclk to be given to the sensor
	input rst,
   
	output reg sensor_pixclk,

	// Data to the sensor
	input mclk,
	input rst_m,
	input area_switch_done,
    input low_to_high_temp_area_switch,
    input high_to_low_temp_area_switch,	
    input [15:0] lo_to_hi_area_global_offset_force_val,
    input [15:0] hi_to_lo_area_global_offset_force_val,
    input blind_badpix_remove_en,
    input [BIT_WIDTH-1:0] BAD_BLIND_PIX_LOW_TH,
    input [BIT_WIDTH-1:0] BAD_BLIND_PIX_HIGH_TH,
	input [BIT_WIDTH-1:0] dark_pix_th,
	input [BIT_WIDTH-1:0] saturated_pix_th,
	input [31:0] addr_coarse_offset,
	output reg [1:0] sensor_cmd,
	output reg [3:0] sensor_data,

	// Data from sensor
	input sensor_ssclk,
	input [0:0] sensor_framing,
	input [6:0] sensor_video_data,

	// Avalon slave bus to update the sensor parameters
	// also to set addresses etc
	output  		av_sensor_waitrequest,
	input 			av_sensor_write,
	input [31:0] 	av_sensor_writedata,
	input [5:0] 	av_sensor_address,
	input 			av_sensor_read,
	output  		av_sensor_readdatavalid,
	output reg [31:0] 	av_sensor_readdata,


	// Avalon master bus to read the sensor parameters
	// and coarse offset data from memory
	
	input 				av_coarse_waitrequest,
	output 				av_coarse_read,
	output [31:0] 		av_coarse_address,
	output [5:0] 		av_coarse_size,
	input 				av_coarse_readdatavalid,
	input [31:0]		av_coarse_readdata,	

	// Data for debug capture
	output raw_video_v,
	output raw_video_h,
	output raw_video_eoi,
	output raw_video_dav,
	output [15:0] raw_video_data,
	output [PIX_BITS-1:0] raw_video_xsize,
	output [LIN_BITS-1:0] raw_video_ysize,
    output [BIT_WIDTH-1:0] meta1_avg,
    output [BIT_WIDTH-1:0] meta2_avg,
    output [BIT_WIDTH-1:0] meta3_avg,
    
	// Data to the pipeline
	output reg video_o_v,
	output reg video_o_h,
	output reg video_o_dav,
	output reg video_o_dav_with_temp, // with temperature data
	output reg [13:0] video_o_data,
	output reg video_o_eoi,
	output [PIX_BITS-1:0]video_o_xsize,
	output [LIN_BITS-1:0]video_o_ysize,
	output [PIX_BITS-1:0]video_o_xsize_with_temp,
	output [LIN_BITS-1:0]video_o_ysize_with_temp,
	output [3:0] temp_sense_offset
	);


wire [3:0] sensor_cmd_s;
wire [7:0] sensor_data_s;

wire [1:0] sensor_framing_s;
wire [13:0] sensor_video_data_s;

wire video_i_v;
wire video_i_h;
wire video_i_dav;
wire [13:0] video_i_data;
wire video_i_eoi;
wire [PIX_BITS-1:0]video_i_xsize;
wire [LIN_BITS-1:0]video_i_ysize;

wire rst_ssclk;

wire  		av_sensor1_waitrequest;
wire		av_sensor1_write;
wire [31:0] av_sensor1_writedata;
wire [3:0] 	av_sensor1_address;
wire		av_sensor1_read;
wire  		av_sensor1_readdatavalid;
reg [31:0] av_sensor1_readdata;

wire  		av_sensor2_waitrequest;
wire		av_sensor2_write;
wire [31:0] av_sensor2_writedata;
wire [3:0] 	av_sensor2_address;
wire		av_sensor2_read;
wire  		av_sensor2_readdatavalid;
reg [31:0] av_sensor2_readdata;

wire  		av_sensor3_waitrequest;
wire		av_sensor3_write;
wire [31:0] av_sensor3_writedata;
wire [3:0] 	av_sensor3_address;
wire		av_sensor3_read;
wire  		av_sensor3_readdatavalid;
reg [31:0] av_sensor3_readdata;

wire blind_pix_avg_frame_valid;
wire [31:0] blind_pix_avg_frame;
// wire av_coarse_read;
// wire [10:0] av_coarse_address;
// wire [8:0] av_coarse_readdata;
// wire av_coarse_readdatavalid;
// wire av_coarse_waitrequest;

assign av_sensor_waitrequest = av_sensor1_waitrequest || av_sensor2_waitrequest || av_sensor3_waitrequest;
assign av_sensor_readdatavalid = av_sensor1_readdatavalid || av_sensor2_readdatavalid || av_sensor3_readdatavalid;

always_comb begin : proc_av_readdata
	if(av_sensor1_readdatavalid) begin
		av_sensor_readdata = av_sensor1_readdata;
	end else if(av_sensor2_readdatavalid) begin
		av_sensor_readdata = av_sensor2_readdata;
	end else if(av_sensor3_readdatavalid) begin
		av_sensor_readdata = av_sensor3_readdata;
	end else
		av_sensor_readdata = 0;
end

assign av_sensor1_address = av_sensor_address[3:0];
assign av_sensor2_address = av_sensor_address[3:0];
assign av_sensor3_address = av_sensor_address[3:0];

assign av_sensor1_writedata = av_sensor_writedata;
assign av_sensor2_writedata = av_sensor_writedata;
assign av_sensor3_writedata = av_sensor_writedata;

// lower address writes to sensor controller and upper address writes to sensor windowing
assign av_sensor1_write = av_sensor_write && (~av_sensor_address[5] && ~av_sensor_address[4]);
assign av_sensor2_write = av_sensor_write && (~av_sensor_address[5] && av_sensor_address[4]);
assign av_sensor3_write = av_sensor_write && (av_sensor_address[5] && ~av_sensor_address[4]);
// similarly for reads
assign av_sensor1_read = av_sensor_read && (~av_sensor_address[5] && ~av_sensor_address[4]);
assign av_sensor2_read = av_sensor_read && (~av_sensor_address[5] && av_sensor_address[4]);
assign av_sensor3_read = av_sensor_read && (av_sensor_address[5] && ~av_sensor_address[4]);


sensor_controller 
#(
	.SENSOR_XSIZE(SENSOR_XSIZE),
	.SENSOR_YSIZE(SENSOR_YSIZE)
) dut
(
	.clk(clk),
	.rst(rst),
	.mclk(mclk),
	.rst_m(rst_m),
	.area_switch_done(area_switch_done),
    .low_to_high_temp_area_switch(low_to_high_temp_area_switch),
    .high_to_low_temp_area_switch(high_to_low_temp_area_switch),
    .lo_to_hi_area_global_offset_force_val(lo_to_hi_area_global_offset_force_val),
    .hi_to_lo_area_global_offset_force_val(hi_to_lo_area_global_offset_force_val),    	
	.addr_coarse_offset(addr_coarse_offset),
	.sensor_cmd(sensor_cmd_s),
	.sensor_data(sensor_data_s),
	.sensor_ssclk(sensor_ssclk),
	.sensor_ssclk_rst(rst_ssclk),
	.sensor_framing(sensor_framing_s),
	.sensor_video_data(sensor_video_data_s),

	.av_sensor_waitrequest(av_sensor1_waitrequest),
	.av_sensor_write(av_sensor1_write),
	.av_sensor_writedata(av_sensor1_writedata),
	.av_sensor_address(av_sensor1_address),
	.av_sensor_read(av_sensor1_read),
	.av_sensor_readdatavalid(av_sensor1_readdatavalid),
	.av_sensor_readdata(av_sensor1_readdata),

	.av_coarse_read(av_coarse_read),
	.av_coarse_address(av_coarse_address),
	.av_coarse_size(av_coarse_size),
	.av_coarse_readdata(av_coarse_readdata),
	.av_coarse_readdatavalid(av_coarse_readdatavalid),
	.av_coarse_waitrequest(av_coarse_waitrequest),

	.blind_pix_avg_frame_valid(blind_pix_avg_frame_valid),
	.blind_pix_avg_frame(blind_pix_avg_frame),

	.video_o_v(video_i_v),
	.video_o_h(video_i_h),
	.video_o_dav(video_i_dav),
	.video_o_data(video_i_data),
	.video_o_eoi(video_i_eoi),
	.video_o_xsize(video_i_xsize),
	.video_o_ysize(video_i_ysize),
	.temp_sense_offset(temp_sense_offset)
	);


assign raw_video_v = video_i_v;
assign raw_video_h = video_i_h;
assign raw_video_eoi = video_i_eoi;
assign raw_video_dav = video_i_dav;
assign raw_video_data = video_i_data;
assign raw_video_xsize = video_i_xsize;
assign raw_video_ysize = video_i_ysize;


sensor_window 
#(	.BIT_WIDTH(14),
	.PIX_BITS(10),
	.LIN_BITS(10),
	.VIDEO_XSIZE(640),
	.VIDEO_YSIZE(480)
	)
sensor_window_inst(
	.clk(clk),
	.rst(rst),
	.blind_badpix_remove_en(blind_badpix_remove_en),
	.BAD_BLIND_PIX_LOW_TH(BAD_BLIND_PIX_LOW_TH),
	.BAD_BLIND_PIX_HIGH_TH(BAD_BLIND_PIX_HIGH_TH),
    .dark_pix_th(dark_pix_th),
    .saturated_pix_th(saturated_pix_th),
	.av_sensor_waitrequest(av_sensor2_waitrequest),
	.av_sensor_write(av_sensor2_write),
	.av_sensor_writedata(av_sensor2_writedata),
	.av_sensor_address(av_sensor2_address),
	.av_sensor_read(av_sensor2_read),
	.av_sensor_readdatavalid(av_sensor2_readdatavalid),
	.av_sensor_readdata(av_sensor2_readdata),

	.blind_pix_avg_frame_valid(blind_pix_avg_frame_valid),
	.blind_pix_avg_frame(blind_pix_avg_frame),
	.META1_AVG(meta1_avg),     
    .META2_AVG(meta2_avg),
    .META3_AVG(meta3_avg),

	.video_i_v(video_i_v),
	.video_i_h(video_i_h),
	.video_i_dav(video_i_dav),
	.video_i_eoi(video_i_eoi),
	.video_i_data(video_i_data),
	.video_o_v(video_o_v),
	.video_o_h(video_o_h),
	.video_o_dav(video_o_dav),
	.video_o_dav_with_temp(video_o_dav_with_temp),
	.video_o_eoi(video_o_eoi),
 	.video_o_data(video_o_data)
	);


// coarse_offset_cal 
// #(	.BIT_WIDTH(14),
// 	.PIX_BITS(10),
// 	.LIN_BITS(10),
// 	.VIDEO_XSIZE(640),
// 	.VIDEO_YSIZE(480)
// 	)
// coarse_offset_cal_inst(
// 	.clk(clk),
// 	.rst(rst),

// 	.av_sensor_waitrequest(av_sensor3_waitrequest),
// 	.av_sensor_write(av_sensor3_write),
// 	.av_sensor_writedata(av_sensor3_writedata),
// 	.av_sensor_address(av_sensor3_address),
// 	.av_sensor_read(av_sensor3_read),
// 	.av_sensor_readdatavalid(av_sensor3_readdatavalid),
// 	.av_sensor_readdata(av_sensor3_readdata),

// 	.av_coarse_read(av_coarse_read),
// 	.av_coarse_address(av_coarse_address),
//  	.av_coarse_readdata(av_coarse_readdata),
//  	.av_coarse_readdatavalid(av_coarse_readdatavalid),
//  	.av_coarse_waitrequest(av_coarse_waitrequest),

// 	.video_i_v(video_o_v),
// 	.video_i_h(video_o_h),
// 	.video_i_dav(video_o_dav),
// 	.video_i_eoi(video_o_eoi),
// 	.video_i_data(video_o_data)
// 	);



assign video_o_xsize = 640;//video_i_xsize;
assign video_o_ysize = 480;//video_i_ysize;
assign video_o_xsize_with_temp = 641;//video_i_xsize;
assign video_o_ysize_with_temp = 480;//video_i_ysize;
////////////////////////////////////////////////////////////////////////////////
/*
	Conversion to and from DDR registers 
*/

////////////////////////////////////////////////////////////////////////////////
/*
	Sensor pixclk
*/
ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_sensor_pixclk (
      .Q(sensor_pixclk),   // 1-bit DDR output
      .C(mclk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(1'b0), // 1-bit data input (positive edge)
      .D2(1'b1), // 1-bit data input (negative edge)
      .R(rst_m),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

////////////////////////////////////////////////////////////////////////////////
/*
	Sensor command output registers
*/
genvar ji;
generate
	for (ji=0;ji<2;ji=ji+1) begin
		/* code */
		ODDR #(
	      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	      .SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC" 
	   	) ODDR_sensor_cmd_x_xp1 (
	      .Q(sensor_cmd[ji]),   // 1-bit DDR output
	      .C(mclk),   // 1-bit clock input
	      .CE(1'b1), // 1-bit clock enable input
	      .D1(sensor_cmd_s[2*ji+1]), // 1-bit data input (positive edge)
	      .D2(sensor_cmd_s[2*ji]), // 1-bit data input (negative edge)
	      .R(rst_m),   // 1-bit reset
	      .S(1'b0)    // 1-bit set
	   	);
	end
endgenerate

////////////////////////////////////////////////////////////////////////////////
/*
	Sensor data output registers
*/
genvar ki;
generate
	for(ki=0;ki<4;ki=ki+1) begin 
		ODDR #(
	      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	      .SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC" 
	   ) ODDR_sensor_data_x_xp1 (
	      .Q(sensor_data[ki]),   // 1-bit DDR output
	      .C(mclk),   // 1-bit clock input
	      .CE(1'b1), // 1-bit clock enable input
	      .D1(sensor_data_s[2*ki+1]), // 1-bit data input (positive edge)
	      .D2(sensor_data_s[2*ki]), // 1-bit data input (negative edge)
	      .R(rst_m),   // 1-bit reset
	      .S(1'b0)    // 1-bit set
	   );
	end
endgenerate


//////////////////////////////////////////////////////////////////////////////////////////
/*
	Sensor input framing
*/
// Use async rst with SSCLK
xpm_cdc_async_rst #(
      .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
   )
   xpm_cdc_async_rst_inst (
      .dest_arst(rst_ssclk),
      .dest_clk(sensor_ssclk),   // 1-bit input: Destination clock.
      .src_arst(rst)    // 1-bit input: Source asynchronous reset signal.
   );

IDDR #(
  	.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                  //    or "SAME_EDGE_PIPELINED" 
  	.INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
  	.INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
  	.SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) IDDR_framing (
  	.Q1(sensor_framing_s[1]), // 1-bit output for positive edge of clock
  	.Q2(sensor_framing_s[0]), // 1-bit output for negative edge of clock
  	.C(sensor_ssclk),   // 1-bit clock input
  	.CE(1'b1), // 1-bit clock enable input
  	.D(sensor_framing[0]),   // 1-bit DDR data input
  	.R(rst_ssclk),   // 1-bit reset
  	.S(1'b0)    // 1-bit set
);


//////////////////////////////////////////////////////////////////////////////////////////
/*
	Sensor input video data
*/

genvar gi;

generate
	for(gi=0;gi<7;gi=gi+1) begin 
		IDDR #(
		  	.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
		                                  //    or "SAME_EDGE_PIPELINED" 
		  	.INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
		  	.INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
		  	.SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC" 
		) IDDR_video_data_x_sp1 (
		  	.Q1(sensor_video_data_s[2*gi+1]), // 1-bit output for positive edge of clock
		  	.Q2(sensor_video_data_s[2*gi]), // 1-bit output for negative edge of clock
		  	.C(sensor_ssclk),   // 1-bit clock input
		  	.CE(1'b1), // 1-bit clock enable input
		  	.D(sensor_video_data[gi]),   // 1-bit DDR data input
		  	.R(rst_ssclk),   // 1-bit reset
		  	.S(1'b0)    // 1-bit set
		);
	end
endgenerate

//////////////////////////////////////////////////////////////////////////////////////////
endmodule // sensor_controller_top