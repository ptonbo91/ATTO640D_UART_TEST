// `define  ILA_COARSE_OFFSET_UPDATE_GPIO
module 	coarse_map_update_gpio
	#(parameter C_C = 2,
	  parameter C_F = 2)
	(
	input	clk,
	input 	rst,

	input trigger_co,
	output busy_co,
	output done_co,

	input tick_1ms,

	input snap_done,
	output snap_trigger,
	output [2:0] snap_mode,
	output [2:0] snap_channel,
	output  [7:0] snap_image_numbers,

	output [31:0] av_fpga_address,
	output av_fpga_read,
	input [31:0] av_fpga_readdata,
	input av_fpga_readdatavalid,
	output av_fpga_write,
	output [31:0] av_fpga_writedata,
	input av_fpga_waitrequest,


	output av_sensor_write,
	output [31:0] av_sensor_writedata,
	output [31:0] av_sensor_address


	);

`include "TOII_TUVE_HEADER.vh"


/* Implement the following python serial command code into various bus transactions


def enable_co_correction(mode='div1024', slot=1):
    
    #Mode definition
    
    mode_dict = {'fine':1,
                 'div1024':2,
                 'div600':3, 
                 'div800':4, 
                 'div1000':5, 
                 'div1200':6, 
                 'div1400':7
                 }
    
    if(mode not in mode_dict):
        print('Illegal Mode value:',mode)
        print('Mode needs to be one of the following')
        print('[\'fine\', \'div1024\', \'div600\', \'div800\', \'div1000\', \'div1200\', \'div1400\']')
        return
        
    co_address_base = 0x006CC000
    co_address_offset = 0x00052800
    co_address = co_address_base+(slot-1)*co_address_offset
    
    cmd_gen.set_CO_addr(co_address)
    
    cmd_gen.disable_nuc()
    # cmd_gen.disable_blind_pix_subtraction()
    cmd_gen.lock_global_offset()
    cmd_gen.take_snapshot(channel=0, mode=12, number_frames=1)
    cmd_gen.switch_CO_bus_mode(1)
    cmd_gen.set_CO_mode(mode_dict[mode])
    cmd_gen.trigger_wait_CO_calc()
    cmd_gen.switch_CO_bus_mode(0)
    cmd_gen.enable_blind_pix_subtraction()
    cmd_gen.auto_global_offset()
*/


`define SET_BLIND_PIX_SUB 8'h10
`define GLOBAL_OFFSET_ADDR 8'd00

`define SET_NUC_EN 8'h54
`define GET_CUR_TEMP_AREA 8'h74
`define SET_CO_TRIGGER_CALC 8'h98
`define GET_CO_TRIGGER_STATUS_CALC 8'h98
`define SET_CO_PIX_ADDR 8'h99
`define GET_CO_PIX_ADDR 8'h99
`define SET_CO_CO_ADDR 8'h9A
`define GET_CO_CO_ADDR 8'h9A
`define SET_CO_MODE 8'h9B
`define SET_CO_CALC_MODE 8'h9C
`define GET_CO_CALC_MODE 8'h9C
`define SET_CO_DC 8'h9D
`define GET_CO_DC 8'h9D
`define SET_NUC1PT_CTRL 8'h91


// `define WAIT_2_SEC  'd132000000 // 2 secs counter with 66 MHz needs 132000000 clock cycles, and can be represented with 27 bits
`define WAIT_2_SEC  2000
`define WAIT_200_MSEC 200

(* mark_debug = "true" *)reg [4:0] fsm;
(* mark_debug = "true" *)reg [4:0] fsm_cb;

localparam s_idle = 'd0,
		s_set_co_address = 'd1,
		s_disable_nuc = 'd2,
		s_lock_global_offset = 'd3,
		s_take_snap = 'd4,
		s_switch_co_bus_mode_1 = 'd5,
		s_set_co_mode = 'd6,
		s_trigger_co_calc = 'd7,
		s_switch_co_bus_mode_0 = 'd8,
		s_enable_blind_pix_sub = 'd9,
		s_disable_blind_pix_sub = 'd10,
		s_auto_global_offset = 'd11,
		s_fpga_bus_wtxn1 = 'd12,
		s_fpga_bus_wtxn2 = 'd13,
		s_fpga_bus_rtxn1 = 'd14,
		s_fpga_bus_rtxn2 = 'd15,
		s_sensor_wtxn1 = 'd16,
		s_sensor_wtxn2 = 'd17,
		s_take_snap_done = 'd18,
		s_end_calc = 'd19,
		s_enable_nuc = 'd20,
		s_wait = 'd21,
		s_manage = 'd22,
		s_get_cur_area = 'd23,
		s_trigger_co_calc_done = 'd24,
		s_auto_global_offset_done = 'd25,
		s_perform_nuc1pt_1 = 'd26,
		s_perform_nuc1pt_2 = 'd27,
		s_perform_nuc1pt_3 = 'd28
		;

// reg [27:0] wait_count;
reg [15:0] wait_count;

(* mark_debug = "true" *)reg [31:0] address;
(* mark_debug = "true" *)reg [31:0] data;

(* mark_debug = "true" *)reg [3:0] co_mode;

(* mark_debug = "true" *)reg [2:0] count;


(* mark_debug = "true" *)wire snap_done_r;
(* mark_debug = "true" *)reg snap_trigger_r;
reg [2:0] snap_mode_r;
reg [2:0] snap_channel_r;
reg  [7:0] snap_image_numbers_r;

reg [31:0] av_fpga_address_r;
reg av_fpga_read_r;
wire [31:0] av_fpga_readdata_r;
wire av_fpga_readdatavalid_r;
reg av_fpga_write_r;
reg [31:0] av_fpga_writedata_r;
wire av_fpga_waitrequest_r;


reg av_sensor_write_r;
reg [31:0] av_sensor_writedata_r;
reg [31:0] av_sensor_address_r;

assign av_sensor_write  	= av_sensor_write_r;
assign av_sensor_writedata 	= av_sensor_writedata_r;
assign av_sensor_address 	= av_sensor_address_r;

assign av_fpga_address				= av_fpga_address_r;
assign av_fpga_read 				= av_fpga_read_r;
assign av_fpga_readdata_r 			= av_fpga_readdata;
assign av_fpga_readdatavalid_r 		= av_fpga_readdatavalid;
assign av_fpga_write 				= av_fpga_write_r;
assign av_fpga_writedata 			= av_fpga_writedata_r;
assign av_fpga_waitrequest_r 		= av_fpga_waitrequest;

assign snap_done_r 			= snap_done;
assign snap_trigger 		= snap_trigger_r;
assign snap_mode 			= snap_mode_r;
assign snap_channel 		= snap_channel_r;
assign snap_image_numbers 	= snap_image_numbers_r;

(* mark_debug = "true" *)reg busy_co_r;
(* mark_debug = "true" *)reg done_co_r;


always @(posedge clk, posedge rst) begin : proc_fsm
	if(rst) begin
		fsm <= s_idle;
		fsm_cb <= s_idle;
		count <= 0;
		address <= 0;
		data	<= 0;
		wait_count <= 0;

		av_sensor_write_r <= 0;
		av_sensor_writedata_r <= 0;
		av_sensor_address_r <= 0;

		av_fpga_address_r 	<= 0;
		av_fpga_read_r 		<= 0;
		av_fpga_write_r 	<= 0;
		av_fpga_writedata_r <= 0;

		snap_trigger_r 		<= 0;
		snap_mode_r 		<= 0;
		snap_channel_r 		<= 0;
		snap_image_numbers_r<= 0;

		busy_co_r <= 0;
		done_co_r <= 0;

	end else begin
		case (fsm)
			s_idle : begin
				done_co_r <= 1'b0;
				busy_co_r <= 1'b0;
				if(trigger_co) begin
					fsm <= s_get_cur_area;
					busy_co_r <= 1'b1;
				end
			end

			s_get_cur_area: begin
				address <= `GET_CUR_TEMP_AREA;
				fsm <= s_fpga_bus_rtxn1;
				fsm_cb <= s_set_co_address;
			end

			s_set_co_address: begin
				address <= `SET_CO_CO_ADDR;
				data <= ADDR_COARSE_OFFSET_START + data*ADDR_COARSE_OFFSET_OFFSET;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_disable_nuc;
			end

			s_disable_nuc: begin
				address <= `SET_NUC_EN;
				data <= 0;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_manage;
			end

			s_enable_nuc: begin
				address <= `SET_NUC_EN;
				data <= 3;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_idle;
				done_co_r <= 1'b1;
			end

			s_perform_nuc1pt_1: begin
				address <= `SET_NUC1PT_CTRL;
				data <= 1;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_perform_nuc1pt_2;
			end

			s_perform_nuc1pt_2: begin
				address <= `SET_NUC1PT_CTRL;
				data <= 0;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_perform_nuc1pt_3;
			end

			s_perform_nuc1pt_3: begin
				address <= `SET_NUC1PT_CTRL;
				data <= 2;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_enable_nuc;
			end

			s_manage: begin
				if(count==C_C+C_F) begin	
					fsm <= s_perform_nuc1pt_1;
					count <= 0;
				end else begin
					if(count<C_C) begin
						co_mode <= 2;
					end else begin
						co_mode <= 1;
					end
					count <= count + 1;
					fsm <= s_disable_blind_pix_sub;
			 	end
			end

			s_disable_blind_pix_sub: begin
				address <= `SET_BLIND_PIX_SUB;
				data <= 0;
				fsm <= s_sensor_wtxn1;
				fsm_cb <= s_lock_global_offset;
			end

			s_lock_global_offset: begin
				address <= `GLOBAL_OFFSET_ADDR;
				data <= 'd1;
				fsm <= s_sensor_wtxn1;
				fsm_cb <= s_take_snap;
			end


			s_take_snap: begin
				snap_channel_r <= 0;
				snap_mode_r <= 4;
				snap_image_numbers_r <= 1;
				snap_trigger_r <= 1'b1;
				fsm <= s_take_snap_done;
			end

			s_take_snap_done: begin
				snap_trigger_r <= 1'b0;
				if(snap_done_r) begin
					fsm <= s_switch_co_bus_mode_1;
				end
			end

			s_switch_co_bus_mode_1: begin
				address <= `SET_CO_MODE;
				data <= 'd1;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_set_co_mode;
			end

			s_set_co_mode: begin
				address <= `SET_CO_CALC_MODE;
				data <= co_mode;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_trigger_co_calc;
			end

			s_trigger_co_calc: begin
				address <= `SET_CO_TRIGGER_CALC;
				data <= 'd1;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_trigger_co_calc_done;
			end

			s_trigger_co_calc_done: begin
				wait_count <= `WAIT_2_SEC;
				fsm <= s_wait;
				fsm_cb <= s_switch_co_bus_mode_0;
			end

			s_switch_co_bus_mode_0: begin
				address <= `SET_CO_MODE;
				data <= 'd1;
				fsm <= s_fpga_bus_wtxn1;
				fsm_cb <= s_enable_blind_pix_sub;
			end

			s_enable_blind_pix_sub: begin
				address <= `SET_BLIND_PIX_SUB;
				data <= 'd1;
				fsm <= s_sensor_wtxn1;
				fsm_cb <= s_auto_global_offset;
			end

			s_auto_global_offset: begin
				address <= `GLOBAL_OFFSET_ADDR;
				data <= 0;
				fsm <= s_sensor_wtxn1;
				fsm_cb <= s_auto_global_offset_done;
			end

			// Wait for the video frames to stabilize
			s_auto_global_offset_done: begin
				wait_count <= `WAIT_200_MSEC;
				fsm <= s_wait;
				fsm_cb <= s_manage;
			end


			s_fpga_bus_wtxn1: begin
				av_fpga_write_r <= 1'b1;
				av_fpga_writedata_r <= data;
				av_fpga_address_r <= address;
				fsm <= s_fpga_bus_wtxn2;
			end

			s_fpga_bus_wtxn2: begin
				if(!av_fpga_waitrequest_r) begin
					av_fpga_write_r <= 1'b0;
					fsm <= fsm_cb;
				end
			end

			s_fpga_bus_rtxn1: begin
				av_fpga_read_r <= 1'b1;
				av_fpga_address_r <= address;
				fsm <= s_fpga_bus_rtxn2;
			end

			s_fpga_bus_rtxn2: begin
				if(!av_fpga_waitrequest_r) begin
					av_fpga_read_r <= 1'b0;
				end
				if(av_fpga_readdatavalid_r) begin
					data <= av_fpga_readdata_r;
					fsm <= fsm_cb;
				end
			end

			s_sensor_wtxn1: begin
				av_sensor_write_r <= 1'b1;
				av_sensor_address_r <= address;
				av_sensor_writedata_r <= data;
				fsm <= s_sensor_wtxn2;
			end

			s_sensor_wtxn2: begin
				av_sensor_write_r <= 1'b0;
				fsm <= fsm_cb;
			end

			s_wait: begin
				// Wait for 1s counter
				if(wait_count==0) begin
					fsm <= fsm_cb;
				end else begin
					if(tick_1ms) begin
						wait_count <= wait_count - 1;
					end
				end
			end
		
			default : /* default */ fsm <= s_idle;
		endcase
	end
end


assign busy_co = busy_co_r;
assign done_co = done_co_r;

`ifdef ILA_COARSE_OFFSET_UPDATE_GPIO

wire [127:0] probe0;
TOII_TUVE_ila ila_offset(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {42'd0,trigger_co, busy_co_r, done_co_r, address, data, count, co_mode, snap_trigger_r, snap_done_r, fsm, fsm_cb};
				//3+2*32+3+4+2+5*2
`endif

endmodule : coarse_map_update_gpio