`timescale 1ns/1ps

module global_offset_control (
	input clk,    // Clock
	input rst,  // Asynchronous reset active high

	input low_to_high_temp_area_switch,
	input high_to_low_temp_area_switch,
    
    input [15:0] lo_to_hi_area_global_offset_force_val,
    input [15:0] hi_to_lo_area_global_offset_force_val,
     	
	input [15:0] global_offset_forced,
	input force_global_offset,

	input lock_global_offset,

	input blind_pix_avg_frame_valid,
	input [31:0] blind_pix_avg_frame,

	output reg [15:0] global_offset,
	output reg global_offset_valid
	
);

/*
Difference between lock_global_offset and force_global_offset.
lock_global_offset will lock the current global offset calculated by the algorithm
whereas force_global_offset will force the global_offset_forced (given by the user)
to the output. The lock_global_offset takes precedence over force_global_offset.
*/

reg [15:0] global_offset_init = 16'hA600;

reg [3:0] go_fsm;
localparam 	go_idle = 'd0,
			go_check_diff = 'd1,
			go_send_global_offset = 'd2;

reg signed [15:0] diff_blind_pix_target = 16'd8192 - blind_pix_avg_frame[15:0];
reg signed [15:0] diff_blind_pix_target_neg = blind_pix_avg_frame[15:0] - 16'd8192;

reg [15:0] global_offset_change;

reg [15:0] global_offset_forced_reg;

reg low_to_high_temp_area_switch_latch;
reg high_to_low_temp_area_switch_latch;

always_ff @(posedge clk) begin : proc_regoster_difference
	if(blind_pix_avg_frame_valid) begin			
		diff_blind_pix_target <= 16'd8192 - blind_pix_avg_frame[15:0];
		diff_blind_pix_target_neg <= blind_pix_avg_frame[15:0] - 16'd8192;
	end
	if(force_global_offset) begin
		global_offset_forced_reg <= global_offset_forced;
	end
end


// Let us assume that the gain of global offset register varies with temperature
// Further let us assume the gain of global offset register is 32 (datasheet gives a nominal value of 30)
// This gain is used only approximately upto a point when the difference between target blind average 
// vs actual is greater than 500. Once it reaches below 500, we will no longer consider the gain and 
// keep iterating with small changes.

// Maximum difference between target and actual blind pixel value is +8192 or -8192 (Since, video pixels are 14 bits)
// Which corresponds to a global offset change of +256 or -256 (8192/32)
// (Thus we can define certain values of global_offset_change which can be standardized and applied)
// For difference greater than 3000 we will assume global_offset_change  = diff/32
// For differences less than 3000, we will define 3 regions where the global offset will vary slowly (see below)


always_ff @(posedge clk or posedge rst) begin : proc_global_offset_control
	if(rst) begin
		global_offset <= global_offset_init;
		global_offset_valid <= 1'b0;
		go_fsm <= go_idle;
		global_offset_change <= 0;
		low_to_high_temp_area_switch_latch <= 1'b0;
		high_to_low_temp_area_switch_latch <= 1'b0;
	end else begin
		global_offset_valid <= 1'b0;
		
		if(low_to_high_temp_area_switch)begin
		  low_to_high_temp_area_switch_latch <= 1'b1;
		end
        
        if(high_to_low_temp_area_switch)begin
		  high_to_low_temp_area_switch_latch <= 1'b1;
		end
		
		case(go_fsm)
			go_idle: begin
				if(blind_pix_avg_frame_valid && !lock_global_offset) begin
					go_fsm <= go_check_diff;
				end
				else if(low_to_high_temp_area_switch_latch == 1'b1 || high_to_low_temp_area_switch_latch == 1'b1)begin
				    go_fsm <= go_send_global_offset;
				end				
			end
			go_check_diff: begin
				go_fsm <= go_send_global_offset;
				if(diff_blind_pix_target[15]==0) begin 							// Check if its a positive or negative number
					if(diff_blind_pix_target < 50) begin
						global_offset_change <= 0;
					end else if(diff_blind_pix_target > 3000) begin
						global_offset_change <= diff_blind_pix_target >> 5;
					end else if(diff_blind_pix_target > 2000) begin
						global_offset_change <= 20;
					end else if(diff_blind_pix_target > 1000) begin
						global_offset_change <= 12;
					end else if(diff_blind_pix_target > 500) begin
						global_offset_change <= 7;
					end else if(diff_blind_pix_target > 200) begin
						global_offset_change <= 4;
					end else begin
						global_offset_change <= 1;
					end
				end else begin
					if(diff_blind_pix_target_neg < 50) begin
						global_offset_change <= 0;
					end else if(diff_blind_pix_target_neg > 3000) begin
						global_offset_change <= diff_blind_pix_target_neg >> 5;
					end else if(diff_blind_pix_target_neg > 2000) begin
						global_offset_change <= 20;
					end else if(diff_blind_pix_target_neg > 1000) begin
						global_offset_change <= 12;
					end else if(diff_blind_pix_target_neg > 500) begin
						global_offset_change <= 7;
					end else if(diff_blind_pix_target_neg > 200) begin
						global_offset_change <= 4;
					end else begin
						global_offset_change <= 1;
					end
				end
			end

			go_send_global_offset: begin
				global_offset_valid <= 1'b1;
				if(force_global_offset) begin
					global_offset <= global_offset_forced_reg;
				end 
				else if(low_to_high_temp_area_switch_latch == 1'b1)begin
				    low_to_high_temp_area_switch_latch<= 1'b0;
//				    global_offset <= 16'd41660;
				    global_offset <= lo_to_hi_area_global_offset_force_val;
				end
		        else if(high_to_low_temp_area_switch_latch == 1'b1)begin
				    high_to_low_temp_area_switch_latch<= 1'b0;
//				    global_offset <= 16'd47050;
				    global_offset <= hi_to_lo_area_global_offset_force_val;
				end
				else if(diff_blind_pix_target[15]==0) begin
					global_offset <= global_offset - global_offset_change;
				end else begin
					global_offset <= global_offset + global_offset_change;
				end
				go_fsm <= go_idle;
			end
		endcase
	end
end

endmodule