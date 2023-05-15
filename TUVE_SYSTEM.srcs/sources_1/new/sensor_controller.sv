`timescale 1ns/1ps
//`define SENSOR_COUNTER_DEBUG
//`define ILA_DEBUG
`include "TOII_TUVE_HEADER.vh"
module sensor_controller
	#(
	parameter 	PIX_BITS 				= 10,
				LIN_BITS 				= 10,
				SKIP_FRAMES             = 2, //50
				SENSOR_TOTAL_XSIZE 		= 780,
				SENSOR_TOTAL_YSIZE 		= 525,
				SENSOR_XSIZE 			= 664,
				SENSOR_YSIZE 			= 520,
				VIDEO_XSIZE 			= 640,
				VIDEO_YSIZE 			= 519
		)
	(
	input clk, 										// Same as pixclk to be given to the sensor
	input rst,

	// Data to the sensor
	input mclk,
	input rst_m,
	input area_switch_done,
	(* mark_debug = "true" *)input low_to_high_temp_area_switch,
	(* mark_debug = "true" *)input high_to_low_temp_area_switch,
	(* mark_debug = "true" *)input [15:0] lo_to_hi_area_global_offset_force_val,
	(* mark_debug = "true" *)input [15:0] hi_to_lo_area_global_offset_force_val,
	input [31:0] addr_coarse_offset,
	(* mark_debug = "true" *)output reg [3:0] sensor_cmd,
	(* mark_debug = "true" *)output reg [7:0] sensor_data,

	// Data from sensor
	input sensor_ssclk,
	input sensor_ssclk_rst,
	(* mark_debug = "true" *)input [1:0] sensor_framing,
	(* mark_debug = "true" *)input [13:0] sensor_video_data,

	// Avalon slave bus to update the sensor parameters
	// also to set addresses etc
	output reg 		av_sensor_waitrequest,
	input 			av_sensor_write,
	input [31:0] 	av_sensor_writedata,
	input [3:0] 	av_sensor_address,
	input 			av_sensor_read,
	output reg 		av_sensor_readdatavalid,
	output reg [31:0] av_sensor_readdata,


	// Avalon master bus to read the sensor parameters
	// and coarse offset data from memory
	// Avalon master bus to read coarse offset data from memory
	input 				av_coarse_waitrequest,
	output reg			av_coarse_read,
	output [31:0] 		av_coarse_address,
	output [5:0] 		av_coarse_size,
	input 				av_coarse_readdatavalid,
	input [31:0]		av_coarse_readdata,
    
	input 				blind_pix_avg_frame_valid,
	input [31:0] 		blind_pix_avg_frame,

	// Data to the pipeline
	(* mark_debug = "true" *)output reg video_o_v,
	(* mark_debug = "true" *)output reg video_o_h,
	(* mark_debug = "true" *)output reg video_o_dav,
	(* mark_debug = "true" *)output reg [13:0] video_o_data,
	(* mark_debug = "true" *)output reg video_o_eoi,
	output [PIX_BITS-1:0]video_o_xsize,
	output [LIN_BITS-1:0]video_o_ysize,
	output reg [3 :0]temp_sense_offset
	);


wire [3:0] sensor_cmd_s;
wire [7:0] sensor_data_s;

wire [11:0] sensor_cmd_data;

//////////////////////////////////////////////////////////////////////////
//Free running x and y counters for selecting the address LUT address
//for Athena640
(* mark_debug = "true" *)reg [PIX_BITS-1:0]	xcounter;
(* mark_debug = "true" *)reg [LIN_BITS-1:0]	ycounter;
always_ff @(posedge mclk or posedge rst_m) begin : proc_xycounter
	if(rst_m) begin
		xcounter <= 0;
		ycounter <= 0;
		frame_counter <= 0;
	end else begin
		xcounter <= xcounter+1;
		if(xcounter==SENSOR_TOTAL_XSIZE-1) begin 
			xcounter <= 0;
			ycounter <= ycounter + 1;
			if(ycounter==SENSOR_TOTAL_YSIZE-1) begin 
				ycounter <= 0;
				frame_counter <= frame_counter +1;
			end 
		end
	end
end
//////////////////////////////////////////////////////////////////////////

(* mark_debug = "true" *)wire line_1  	= (ycounter==0)?1'b1:1'b0;
(* mark_debug = "true" *)wire line_even 	= (ycounter[0]==1'b0)?1'b1:1'b0;
(* mark_debug = "true" *)wire line_odd 	= ~line_even;


//////////////////////////////////////////////////////////////////////////
// Delay lines for handling BRAM read latency of 2 cycles
reg line_1_d[0:1];
reg line_even_d[0:1];
reg line_odd_d[0:1];
reg [PIX_BITS-1:0] 	xcounter_d [0:1];

integer i;
always_ff @(posedge mclk or posedge rst_m) begin : proc_delay_line_signals
	if(rst_m) begin
		for(i=0;i<2;i=i+1) begin 
			line_1_d[i] 	<= 0;
			line_even_d[i] 	<= 0;
			line_odd_d[i] 	<= 0;
			xcounter_d[i] 	<= 0;	
		end
	end else begin
		{line_1_d[0], line_1_d[1]} 			<= {line_1, line_1_d[0]};
		{line_even_d[0], line_even_d[1]} 	<= {line_even, line_even_d[0]};
		{line_odd_d[0], line_odd_d[1]} 		<= {line_odd, line_odd_d[0]};
		xcounter_d[0] <= xcounter;
		xcounter_d[1] <= xcounter_d[0];
	end
end
//////////////////////////////////////////////////////////////////////////

// reg [3:0] coarse_offset_fsm;
// localparam sc_idle = 4'd0,
// 			sc_request_coarse_offset = 4'd1,
// 			sc_end = 4'd2;
//////////////////////////////////////////////////////////////////////////
// Write sensor registers 
(* mark_debug = "true" *)reg override_sensor_param;
(* mark_debug = "true" *)reg enable_coarse_offset;
(* mark_debug = "true" *)reg store_sensor_param;
(* mark_debug = "true" *)reg force_global_offset;
(* mark_debug = "true" *)reg lock_global_offset;
(* mark_debug = "true" *)reg [7 :0]detector_bias; 		
(* mark_debug = "true" *)reg [15:0]global_offset_forced; 		
(* mark_debug = "true" *)reg [15:0]global_offset; 		
//(* mark_debug = "true" *)reg [3 :0]temp_sense_offset; 	
(* mark_debug = "true" *)reg [7 :0]heating_compensation; 	
(* mark_debug = "true" *)reg hdir, vdir;
(* mark_debug = "true" *)reg [7:0]coarse_offset_dc;
reg [31:0] coarse_offset_base_addr;
reg [9:0] coarse_ycounter_start;
reg enable_heating_monitor;
(* mark_debug = "true" *) reg [8:0]frame_counter;
always_ff @(posedge clk or posedge rst) begin : proc_sensor_param
	if(rst) begin
		av_sensor_waitrequest 		<= 0;
		av_sensor_readdatavalid 	<= 0;
		av_sensor_readdata 			<= 0;
		override_sensor_param		<= 0;
		store_sensor_param 			<= 0;
		force_global_offset 		<= 0;
		lock_global_offset 			<= 0;
		// By default keep the same as what's given in BAE sensor datasheet
		detector_bias 				<= 8'h62;	
		global_offset_forced 		<= 16'hA600;
		temp_sense_offset 			<= 4'hB;
		heating_compensation 		<= 8'h32;
		hdir 						<= 1'b1;
		vdir 						<= 1'b0;
		coarse_offset_dc 			<= 8'hb4;
		enable_coarse_offset 		<= 1'b1;
		coarse_offset_base_addr 	<= ADDR_COARSE_OFFSET_3;//32'h2b2000;
		coarse_ycounter_start 		<= 12;
		enable_heating_monitor 		<= 0;
	end else begin
		coarse_offset_base_addr 	<= addr_coarse_offset; 
		av_sensor_waitrequest 		<= 0;
		av_sensor_readdatavalid 	<= 0;
		store_sensor_param 			<= 0;
		if(av_sensor_write) begin 
			case (av_sensor_address)
			 	// 4'd0: begin override_sensor_param 	<= av_sensor_writedata[0]; 		store_sensor_param <= av_sensor_writedata[1];	end
			 	4'd0: begin force_global_offset 	<= av_sensor_writedata[1]; 
			 				lock_global_offset 		<= av_sensor_writedata[0]; 														end
			 	4'd1: begin detector_bias 			<= av_sensor_writedata[7:0];													end
			 	4'd2: begin global_offset_forced 	<= av_sensor_writedata[15:0];													end
			 	4'd3: begin temp_sense_offset 		<= av_sensor_writedata[3:0];													end
			 	4'd4: begin heating_compensation 	<= av_sensor_writedata[7:0];													end
			 	4'd5: begin coarse_offset_dc 		<= av_sensor_writedata[7:0]; 													end
			 	4'd6: begin hdir  					<= av_sensor_writedata[0]; 		vdir 				<= av_sensor_writedata[1]; 	end
			 	4'd7: begin enable_coarse_offset 	<= av_sensor_writedata[0];														end
//			 	4'd8: begin coarse_offset_base_addr <= av_sensor_writedata; 														end
			 	4'd9: begin coarse_ycounter_start 	<= av_sensor_writedata[9:0]; 													end
			 	4'd11: begin enable_heating_monitor <= av_sensor_writedata[0]; 														end
				default : /* default */;
			endcase
		end
		else if(av_sensor_read) begin 
			av_sensor_readdatavalid <= 1'b1;
			case (av_sensor_address)
				// 4'd0: begin av_sensor_readdata <= {30'd0, store_sensor_param, override_sensor_param}; 	end
				4'd0: begin av_sensor_readdata <= {30'd0, force_global_offset, lock_global_offset}; 	end
				4'd1: begin av_sensor_readdata <= {24'd0, detector_bias}; 							  	end
				4'd2: begin av_sensor_readdata <= {16'd0, global_offset_forced};					  	end
				4'd3: begin av_sensor_readdata <= {28'd0, temp_sense_offset}; 						  	end
				4'd4: begin av_sensor_readdata <= {24'd0, heating_compensation}; 					  	end
				4'd5: begin av_sensor_readdata <= {24'd0, coarse_offset_dc}; 	 						end
				4'd6: begin av_sensor_readdata <= {30'd0, vdir, hdir}; 									end
				4'd7: begin av_sensor_readdata <= {31'd0, enable_coarse_offset}; 						end
				4'd8: begin av_sensor_readdata <= coarse_offset_base_addr; 								end
				4'd9: begin	av_sensor_readdata <= {22'd0, coarse_ycounter_start}; 						end
				4'd10: begin av_sensor_readdata <= {16'd0, global_offset};							  	end
				4'd11: begin av_sensor_readdata <= {31'd0, enable_heating_monitor}; 					end
				default: begin av_sensor_readdata <= 32'hDEAD_BEEF; 									end
			endcase
		end
	end
end

reg enable_heating_monitor_cdc;
xpm_cdc_single #(
  .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
  .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
  .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
)
xpm_cdc_2 (
  .dest_out(enable_heating_monitor_cdc), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                       // registered.

  .dest_clk(mclk), // 1-bit input: Clock signal for the destination clock domain.
  .src_clk(clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
  .src_in(enable_heating_monitor)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
);

reg enable_heating_monitor_reg;
reg override_sensor_param_reg;
always_ff @(posedge mclk or posedge rst_m) begin : proc_override_sensor_param
	if(rst_m) begin
		override_sensor_param_reg 	<= 0;
		enable_heating_monitor_reg  <= 0;
	end else begin
		// Sample override_sensor_param only at the end of current frame
		// (Or just before starting next frame)
		if(xcounter==SENSOR_TOTAL_XSIZE-1 && ycounter==SENSOR_TOTAL_YSIZE-1) begin
			override_sensor_param_reg <= override_sensor_param;
			enable_heating_monitor_reg <= enable_heating_monitor_cdc;
		end 
	end
end

////////////////////////////////////////////////////////////////////////// 
localparam 	s_idle_sp = 4'd0,
			s_store_param = 4'd1,
			s_store_detector_bias1 = 4'd2,
			s_store_detector_bias2 = 4'd3,
			s_store_global_offset1 = 4'd4,
			s_store_global_offset2 = 4'd5,
			s_store_global_offset3 = 4'd6,
			s_store_global_offset4 = 4'd7,
			s_store_temp_sense_offset = 4'd8,
			s_store_heating_comp1 = 4'd9,
			s_store_heating_comp2 = 4'd10,
			s_store_readout_dir = 4'd11;

(* mark_debug = "true" *)reg [3:0] sensor_param_fsm; 

reg store_sensor_param_reg;

reg wrreq_l1;
reg [PIX_BITS-1:0] wraddr_l1;
reg [11:0] wrdata_l1;

(* mark_debug = "true" *)reg line_1_reg1, line_1_reg2;

xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_0 (
      .dest_out(line_1_reg1), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(mclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(line_1)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

always_ff @(posedge clk) begin : proc_line_1_reg
	line_1_reg2 <= line_1_reg1;
end

(* mark_debug = "true" *) wire line_1_falling_edge = (line_1_reg1==0 && line_1_reg2==1)?1'b1:1'b0;

wire [15:0] global_offset_out;
wire global_offset_out_valid;

always_ff @(posedge clk or posedge rst) begin : proc_store_sensor_param
	if(rst) begin
		wrreq_l1 <= 0;
		wraddr_l1 <= 0;
		wrdata_l1 <= 0;
		store_sensor_param_reg <= 0;
		global_offset <= 16'hA600;
	end else begin
		wrreq_l1 <= 0;
		if(store_sensor_param && store_sensor_param_reg ==0) begin	
			store_sensor_param_reg <= 1'b1;
		end
		if(global_offset_out_valid) begin
			global_offset <= global_offset_out;
		end
		case(sensor_param_fsm)
			s_idle_sp : begin 
				// if(store_sensor_param_reg && !line_1 && ycounter<SENSOR_TOTAL_YSIZE-1) begin 
				if(line_1_falling_edge) begin
					sensor_param_fsm <= s_store_param;
					store_sensor_param_reg <= 1'b0;
				end
			end
			s_store_param: begin 
				sensor_param_fsm <= s_store_detector_bias1;
			end
			s_store_detector_bias1: begin 
				wraddr_l1 <= 10;
				wrdata_l1 <= {8'h42, detector_bias[7:4]};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_detector_bias2;
			end
			s_store_detector_bias2: begin 
				wraddr_l1 <= 11;
				wrdata_l1 <= {8'h43, detector_bias[3:0]};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_global_offset1;
			end
			s_store_global_offset1: begin 
				wraddr_l1 <= 38;
				wrdata_l1 <= {8'h50, global_offset[15:12]};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_global_offset2;
			end
			s_store_global_offset2: begin 
				wraddr_l1 <= 39;
				wrdata_l1 <= {8'h51, global_offset[11:8]};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_global_offset3;
			end
			s_store_global_offset3: begin 
				wraddr_l1 <= 40;
				wrdata_l1 <= {8'h52, global_offset[7:4]};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_global_offset4;
			end
			s_store_global_offset4: begin 
				wraddr_l1 <= 41;
				wrdata_l1 <= {8'h53, global_offset[3:0]};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_temp_sense_offset;
			end
			s_store_temp_sense_offset: begin 
				wraddr_l1 <= 54;
				wrdata_l1 <= {8'h4E, temp_sense_offset};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_heating_comp1;
			end
			s_store_heating_comp1: begin 
				wraddr_l1 <= 60;
				wrdata_l1 <= {8'h59, heating_compensation[7:4]};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_heating_comp2;
			end
			s_store_heating_comp2: begin 
				wraddr_l1 <= 61;
				wrdata_l1 <= {8'h5A, heating_compensation[3:0]};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_store_readout_dir;
			end
			s_store_readout_dir: begin 
				wraddr_l1 <= 7;
				wrdata_l1 <= {8'h31, hdir,vdir,2'b10};
				wrreq_l1 <= 1'b1;
				sensor_param_fsm <= s_idle_sp;
			end
		endcase // sensor_param_fsm
	end
end

////////////////////////////////////////////////////////////////////////// 
reg enable_coarse_offset_done;
/////////////////////////////////////////////////////////////////////////
/*
	Clock cycles 3,4,5,6 define vclk toggle
	Clock cycles 10,11,38,39,40,41,54,60,61 of 1st line define sensor 
	paramters
*/

reg [LIN_BITS-1:0] heating_monitor_linenumber;

reg [PIX_BITS-1:0] heating_monitor_columnnumber;

always_ff @(posedge mclk or posedge rst_m) begin : proc_override_lut
	if(rst_m) begin
		sensor_cmd 	<= 0;
		sensor_data <= 0;
		heating_monitor_columnnumber <= 0;
		heating_monitor_linenumber 	 <= 0;
	end else begin
		if(line_1_d[1]) begin  							// if 1st line
			// if(override_sensor_param_reg) begin 
			// 	case(xcounter_d[1])
			// 		// Override readout direction
			// 		//  7: {sensor_cmd, sensor_data} <= {8'h31, hdir,vdir,2'b10};
			// 		// // Override heating compensation values
			// 		// 10: {sensor_cmd, sensor_data} <= {8'h42, detector_bias[7:4]};
			// 		// 11: {sensor_cmd, sensor_data} <= {8'h43, detector_bias[3:0]};
			// 		// // Override global offset values
			// 		// 38: {sensor_cmd, sensor_data} <= {8'h50, global_offset[15:12]};
			// 		// 39: {sensor_cmd, sensor_data} <= {8'h51, global_offset[11:8]};
			// 		// 40: {sensor_cmd, sensor_data} <= {8'h52, global_offset[7:4]};
			// 		// 41: {sensor_cmd, sensor_data} <= {8'h53, global_offset[3:0]};
			// 		// // Override temperatur sensor offset values
			// 		// 54: {sensor_cmd, sensor_data} <= {8'h4E, temp_sense_offset};
			// 		// // Override heating compensation values
			// 		// 60: {sensor_cmd, sensor_data} <= {8'h59, heating_compensation[7:4]};
			// 		// 61: {sensor_cmd, sensor_data} <= {8'h5A, heating_compensation[3:0]};
			// 		// Default pass whatever is in 
			// 		default: {sensor_cmd, sensor_data} <= {sensor_cmd_s, sensor_data_s};
			// 	endcase // xcounter_d[1]
			// end	else begin 
				heating_monitor_columnnumber 	<= 9 + 15;
				heating_monitor_linenumber 		<= 9;
				{sensor_cmd, sensor_data} <= {sensor_cmd_s, sensor_data_s};
			// end
		end	else begin  								// if not 1st line
			// if(xcounter_d[1]>=15 && xcounter_d[1]<675) begin 
			// 	if(~enable_coarse_offset_done) begin
			// 		{sensor_cmd, sensor_data} <= {4'h0, coarse_offset_dc};
			// 	end	else begin 
			// 		{sensor_cmd, sensor_data} <= {sensor_cmd_s, sensor_data_s};
			// 	end 
			// end
			// else begin
				case(xcounter_d[1])
					2: 	if (line_even_d[1]) begin
							{sensor_cmd, sensor_data} <= 12'h100; 
						end
						else begin
							{sensor_cmd, sensor_data} <= 12'h104;
						end
					3:	if (line_even_d[1]) begin
							{sensor_cmd, sensor_data} <= 12'h100; 
						end
						else begin
							{sensor_cmd, sensor_data} <= 12'h104; 
						end
					4:	if (line_even_d[1]) begin
							{sensor_cmd, sensor_data} <= 12'h104; 
						end
						else begin
							{sensor_cmd, sensor_data} <= 12'h100; 
						end
					5:	if (line_even_d[1]) begin
							{sensor_cmd, sensor_data} <= 12'h104; 
						end
						else begin
							{sensor_cmd, sensor_data} <= 12'h100; 
						end
					6 : if(line_even_d[1]) begin
							{sensor_cmd, sensor_data} <= 12'h107; 
						end
						else begin 
							{sensor_cmd, sensor_data} <= 12'h103; 
						end
					default	: begin
						{sensor_cmd, sensor_data} <= {sensor_cmd_s, sensor_data_s};
						if(enable_heating_monitor_reg) begin 
							if(heating_monitor_linenumber<=9+315) begin
								if(xcounter_d[1]==heating_monitor_columnnumber && ycounter==heating_monitor_linenumber) begin 
									{sensor_cmd, sensor_data} <= 12'hD00; 
									heating_monitor_columnnumber <= heating_monitor_columnnumber + 2;
									heating_monitor_linenumber 	 <= heating_monitor_linenumber + 1;
								end
							end
						end
					end
				endcase
			// end
		end 
	end
end

wire [PIX_BITS-1:0]addrb_l1 = xcounter;
wire enb_l1 = line_1;
wire [11:0]doutb_l1;

wire ena_l1 = wrreq_l1;
wire [PIX_BITS-1:0]addra_l1 = wraddr_l1;
wire [11:0]dina_l1 = wrdata_l1;

xpm_memory_sdpram #(
      .ADDR_WIDTH_A(10),               // DECIMAL
      .ADDR_WIDTH_B(10),               // DECIMAL
      .AUTO_SLEEP_TIME(0),            // DECIMAL
      .BYTE_WRITE_WIDTH_A(12),        // DECIMAL
      .CLOCKING_MODE("independent_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .MEMORY_INIT_FILE("line_1.mem"),      // String
      .MEMORY_INIT_PARAM("0"),        // String
      .MEMORY_OPTIMIZATION("true"),   // String
      .MEMORY_PRIMITIVE("auto"),      // String
      .MEMORY_SIZE(780*12),             // DECIMAL
      .MESSAGE_CONTROL(0),            // DECIMAL
      .READ_DATA_WIDTH_B(12),         // DECIMAL
      .READ_LATENCY_B(2),             // DECIMAL
      .READ_RESET_VALUE_B("0"),       // String
      .RST_MODE_A("SYNC"),            // String
      .RST_MODE_B("SYNC"),            // String
      .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
      .USE_MEM_INIT(1),               // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String
      .WRITE_DATA_WIDTH_A(12),        // DECIMAL
      .WRITE_MODE_B("no_change")      // String
   )
xpm_memory_sdpram_line_1 (
      .dbiterrb(),
      .doutb(doutb_l1),
      .sbiterrb(),
      .addra(addra_l1),
      .addrb(addrb_l1),
      .clka(clk),
      .clkb(mclk),
      .dina(dina_l1),
      .ena(ena_l1),
      .enb(enb_l1),
      .injectdbiterra(1'b0),
      .injectsbiterra(1'b0),
      .regceb(1'b1),
      .rstb(rst_m),
      .sleep(1'b0),
      .wea(1'b1)
   );

/// Add coarse offset module here
coarse_offset_corr #(
	.VIDEO_XSIZE(660),
	.VIDEO_YSIZE(500)
	)

coarse_offset_corr_inst
      (
        	.clk(clk),
            .rst(rst),
			.enable_coarse_offset(enable_coarse_offset),
            .area_switch_done(area_switch_done), 
            .video_o_v(video_o_v),  
            .video_o_eoi(video_o_eoi),
            .video_o_h(video_o_h),  
            .video_o_dav(video_o_dav),   
            .av_coarse_waitrequest(av_coarse_waitrequest),
            .av_coarse_read(av_coarse_read),
            .av_coarse_address(av_coarse_address),
            .av_coarse_size(av_coarse_size),
            .av_coarse_readdatavalid(av_coarse_readdatavalid),
            .av_coarse_readdata(av_coarse_readdata),

			.base_address(coarse_offset_base_addr),
			.coarse_offset_dc(coarse_offset_dc),
			.coarse_ycounter_start(coarse_ycounter_start),

			.mclk(mclk),
			.rst_m(rst_m),
            .line_1(line_1),
            .line_even(line_even),
            .line_odd(line_odd),
            .line_even_d(line_even_d),

            .xcounter(xcounter),
            .ycounter(ycounter),

            .sensor_cmd_data(sensor_cmd_data)
        );

assign {sensor_cmd_s, sensor_data_s} = line_1_d[1]? doutb_l1:sensor_cmd_data;

(* mark_debug = "true" *) wire start_of_frame 	= sensor_framing[1] && sensor_framing[0];
(* mark_debug = "true" *) wire start_of_line  	= sensor_framing[1] && !sensor_framing[0];
(* mark_debug = "true" *) wire video_data_valid = !sensor_framing[1] && sensor_framing[0];

global_offset_control go_ctrl(
	.clk(clk),
	.rst(rst),  // Asynchronous reset active high

    .low_to_high_temp_area_switch(low_to_high_temp_area_switch),
    .high_to_low_temp_area_switch(high_to_low_temp_area_switch),
    .lo_to_hi_area_global_offset_force_val(lo_to_hi_area_global_offset_force_val),
    .hi_to_lo_area_global_offset_force_val(hi_to_lo_area_global_offset_force_val),
	.global_offset_forced(global_offset_forced),
	.force_global_offset(force_global_offset),

	.lock_global_offset(lock_global_offset),

	.blind_pix_avg_frame_valid(blind_pix_avg_frame_valid),
	.blind_pix_avg_frame(blind_pix_avg_frame),

	.global_offset(global_offset_out),
	.global_offset_valid(global_offset_out_valid)
	
);

//`ifdef SENSOR_COUNTER_DEBUG

(* mark_debug = "true" *)reg [10:0] sensor_xcount;
(* mark_debug = "true" *)reg [10:0] sensor_ycount;
//(* mark_debug = "true" *)reg [3:0] sensor_frame_count;
(* mark_debug = "true" *)reg [9:0] sensor_frame_count;
(* mark_debug = "true" *)reg start_fifo_en;
always_ff @(posedge sensor_ssclk or posedge sensor_ssclk_rst) begin : proc_sensor_count
	if(sensor_ssclk_rst) begin
		sensor_xcount <= 0;
		sensor_ycount <= 0;
		sensor_frame_count <= 0;
		start_fifo_en <= 0;
	end else begin
		if(start_of_frame) begin 
			sensor_xcount <= 0;
			sensor_ycount <= 0;
			if(sensor_frame_count <SKIP_FRAMES*2) begin
			 sensor_frame_count <= sensor_frame_count + 1;
			end
		end
		else if(start_of_line) begin 
			sensor_ycount <= sensor_ycount + 1;
			sensor_xcount <= 0;
		end
		else if(video_data_valid) begin 
			sensor_xcount <= sensor_xcount + 1;
		end
		if(start_fifo_en==1'b0) begin
		  // Wait for 2 frames, and at the end of the 2 frames to start enabling fifo
		  if(sensor_frame_count==SKIP_FRAMES*2 && sensor_xcount==SENSOR_XSIZE-2 && sensor_ycount==(SENSOR_YSIZE-1)*2 &&sensor_framing==2'b0) begin
		      start_fifo_en <= 1'b1;
		  end
		end
	end
end
//`endif


wire fifo_wr_en = (sensor_framing[1] || sensor_framing[0]) && start_fifo_en;
wire [15:0] fifo_din  = {sensor_framing,sensor_video_data};
wire wr_clk = sensor_ssclk;
wire wr_rst = sensor_ssclk_rst;

(* mark_debug = "true" *)(* mark_keep = "true" *)wire fifo_almost_empty;
wire fifo_almost_full;
(* mark_debug = "true" *)wire fifo_data_valid;
wire [15:0] fifo_dout;
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

xpm_fifo_async #(
	.CDC_SYNC_STAGES(3),       // DECIMAL
	.DOUT_RESET_VALUE("0"),    // String
	.ECC_MODE("no_ecc"),       // String
	.FIFO_MEMORY_TYPE("auto"), // String
	.FIFO_READ_LATENCY(1),     // DECIMAL
	.FIFO_WRITE_DEPTH(32),   // DECIMAL
	.FULL_RESET_VALUE(0),      // DECIMAL
	.PROG_EMPTY_THRESH(10),    // DECIMAL
	.PROG_FULL_THRESH(10),     // DECIMAL
	.RD_DATA_COUNT_WIDTH(6),   // DECIMAL
	.READ_DATA_WIDTH(16),      // DECIMAL
	.READ_MODE("std"),         // String
	.RELATED_CLOCKS(0),        // DECIMAL
	.USE_ADV_FEATURES("1f0f"), // String
	.WAKEUP_TIME(0),           // DECIMAL
	.WRITE_DATA_WIDTH(16),     // DECIMAL
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
	.rd_clk(clk),               
	.rd_en(fifo_rd_en),                 
	.rst(wr_rst),                     
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


assign video_o_data = fifo_dout[13:0];
assign video_o_dav = fifo_data_valid && (video_out_fsm!=s_idle);


wire ycounter_lt_6 = (ycounter < 6)? 1'b1:1'b0;
(* mark_debug = "true" *)reg ycounter_lt_6_cdc;
xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_1 (
      .dest_out(ycounter_lt_6_cdc), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(mclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(ycounter_lt_6)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

reg [7:0] wait_count;
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
	end else begin
		video_o_v <= 1'b0;
		video_o_h <= 1'b0;
		video_o_eoi <= 1'b0;
		fifo_read <= 1'b0;
		case(video_out_fsm)
			s_idle :begin
				// Flush all fifo contents before ycounter hits 6. 
				if(ycounter_lt_6_cdc) begin
					if(!fifo_empty) begin
						fifo_read <= 1'b1;
					end
				end 
				else begin 
					//  After ycounter becomes 6 the actual video starts
					if(!fifo_empty) begin
						video_out_fsm <= s_send_v;
						xcount <= 0;
						ycount <= 0;
					end
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
				if(xcount==SENSOR_XSIZE) begin
					if(ycount==SENSOR_YSIZE-1) begin
						wait_count	<= 4; 
						video_out_fsm <= s_send_eoi;	
					end 
					else begin 
						wait_count	<= 4; 
						video_out_fsm <= s_wait_fifo_empty;
					end
				end
				else if((!fifo_almost_empty && !fifo_empty) || (fifo_almost_empty && !fifo_empty && fifo_read==1'b0)) begin
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
				// if(wait_count==0) begin
					video_out_fsm <= s_wait_fifo;
				end
				// end else begin
				// 	wait_count <= wait_count - 1;
				// end
			end

			s_wait_fifo: begin
				if(~fifo_empty) begin 
					xcount <= 0;
					ycount <= ycount + 1;
					video_out_fsm <= s_send_h;
				end
			end
		endcase // video_out_fsm
		if(line_1_falling_edge) begin
			video_out_fsm <= s_idle;
		end
	end
end

assign video_o_xsize = SENSOR_XSIZE;
assign video_o_ysize = SENSOR_YSIZE;

`ifdef ILA_DEBUG

wire [127:0] probe0;
TOII_TUVE_ila ila_inst2(
    .CLK(clk),
    .PROBE0(probe0)
);
`ifdef SENSOR_COUNTER_DEBUG
assign probe0 = {5'd0,video_data_valid,start_of_frame,start_of_line, sensor_frame_count, start_fifo_en, ycounter_lt_6_cdc,line_1_reg1, line_1_reg2,override_sensor_param, detector_bias, temp_sense_offset, xcount, ycount, fifo_empty, fifo_read, 
fifo_wr_en, fifo_full, sensor_cmd, sensor_data, xcounter, sensor_framing, video_o_v, video_o_h, video_o_eoi, 
video_o_dav, video_out_fsm, sensor_xcount, sensor_ycount, line_1, line_even, line_odd, fifo_data_valid, ycounter};
`else 
assign probe0 = {3'd0, override_sensor_param, detector_bias, temp_sense_offset, global_offset, heating_compensation, fifo_empty, fifo_read, 
fifo_wr_en, fifo_full, sensor_cmd, sensor_data, sensor_video_data, sensor_framing, video_o_v, video_o_h, video_o_eoi, 
video_o_dav, video_out_fsm, xcounter, ycounter, line_1, line_even, line_odd, fifo_data_valid, video_o_data, sensor_param_fsm,
fifo_almost_empty,line_1_falling_edge,area_switch_done,low_to_high_temp_area_switch,high_to_low_temp_area_switch};
`endif
`endif
endmodule