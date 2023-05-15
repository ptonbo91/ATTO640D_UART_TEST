// `define ILA_NUC1pt_MODE2
module offset_poly (
	input clk,    // Clock
	input rst,  // Asynchronous reset active high
	input en_nuc_1pt_mode2,

	// Master AVALON interface for fetching and storing tables
	input av_ready,
	output av_read,
	output av_write,
	output av_wrburst,
	output [5:0] av_size,
	output [31:0] av_address,
	output [31:0] av_writedata,
	output [3:0] av_wrbe,
	input av_rddatavalid,
	input [31:0] av_readdata,

	// Avalon slave interface for control of the module
	output  			avl_waitrequest,
	input 				avl_write,
	input [31:0] 		avl_writedata,
	input [3:0] 		avl_address,
	input 				avl_read,
	output reg 			avl_readdatavalid,
	output reg [31:0] 	avl_readdata
	
);

/*
	We implement Offset = C1*T*T + C2*T + C3 here
	We will store C1, C2, C3 as single precision floating point (fp32) in memory. 
	T is an integer representing temperature of the sensor. We will use floating point
	addtion and multiplication for generating O, and finally convert back to integer
	Following is a rough C-style pseudo-code(not implemented as C function) for deriving the verilog code
	void offset_poly(float32_t *c1, float32_t *c2, float32_t *c3, uint16_t T, uint16_t *offset, uint16_t video_xsize, uint16_t video_ysize){
	
		uint16_t N=32; // We perform chunks of calculation at a time and store back the results
		float32_t T_fp32;
		float32_t T_sq;
		float offset_fp32;
		int16_t offset_int;
		float32_t c1_buf[32], c2_buf[32], c3_buf[32];
		uint16_t offset_buf[32];
		T_fp32 = (float32_t) T;
		T_sq = T_fp32*T_fp32;
		uint32_t num_valid_offset_pixels = 0;
		// Even though uint64_t is mentioned as the type here,
		// in verilog implementation we will reduce the bits
		// so as to simplify the divider implementation
		uint64_t offset_sum = 0;
	
		for(int i=0; i<video_xsize*video_ysize/N;i++){
			for(int k=0;k<N;k++){
				c1_buf[k] = c1[i*N+k];
				c2_buf[k] = c2[i*N+k];
				c3_buf[k] = c3[i*N+k];
				// This computation is split into multiple single step operation in code below
				offset_fp32 = c1_buf[k] * T_sq + c2_buf[k] * T_fp32 + c3_buf[k];
				
				offset_int = int16_t(offset_fp32);
				
				// Clip offset
				offset_int = (offset_int<0)?0:(offset_int>16383)16383:offset_int);
				offset_buf[k] = offset_int;
				offset[i*N+k] = offset_buf[k];
				// accumulate offset image for the frame
				// and replace the first pixel with the average value
				// This is specific to our NUC implementation
				// remove the outliers
				if(offset_int>300 && offset_int < 16000){
					offset_sum += offset_int;
					num_valid_offset_pixels += 1;
				}
			}	
		}
		offset_avg = uint16_t(offset_sum/num_valid_offset_pixels)
		offset[0] = offset_avg
	}
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Modification to the above calculation is required for a finer NUC1pt on top of shutterless calibration.
The above function will take another argument, which is the buffer of corrected image as shown below
void offset_poly(float32_t *c1, float32_t *c2, float32_t *c3, uint16_t *img_corr,  uint16_t T, uint16_t *offset, uint16_t video_xsize, uint16_t video_ysize){
and the offset correction equation will be changed as follows
	offset[i*N+k] = offset_buf[k] - (img_corr_buffer[k] - 8192);
img_corr is the buffered shutter image with correction applied using unity gain
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Control signals
(* mark_debug = "true" *)reg trigger;
reg done_frame;
reg [15:0] video_xsize;
reg [15:0] video_ysize;
reg [31:0] c1_addr;
reg [31:0] c2_addr;
reg [31:0] c3_addr;

(* mark_debug = "true" *)reg [31:0] img_corr_addr;

reg [31:0] offset_addr;

reg [15:0] temp_data;

reg [15:0] wait_count;
reg [15:0] wait_count_set;

reg [5:0] burst_size;

(* mark_debug = "true" *)reg en_1pt_mode;
reg en_1pt_mode_reg;
reg en_nuc_1pt_mode2_reg;

assign avl_waitrequest = 0;
always @(posedge clk or posedge rst) begin : proc_slave_logic
	if(rst) begin
		trigger <= 0;
		avl_readdatavalid <= 1'b0;
		c1_addr <= 32'h002A_0000;
		c2_addr <= 32'h002A_0000;
		c3_addr <= 32'h002A_0000;
		offset_addr <= 32'h002A_0000;
		img_corr_addr <= 32'h002A_0000;
		temp_data <= 0;
		wait_count_set <= 200;
		burst_size <= 16;
		video_ysize <= 480;
		video_xsize <= 640;
		en_1pt_mode <= 1'b0;
	end else begin
		avl_readdatavalid <= 1'b0;
		trigger <= 0;
		if(avl_write) begin 
			case(avl_address)
				4'd0: begin trigger <= avl_writedata[0]; 					
							en_1pt_mode <= avl_writedata[1];				end
				4'd1: begin c1_addr <= avl_writedata[31:0]; 				end
				4'd2: begin	c2_addr <= avl_writedata[31:0]; 				end
				4'd3: begin	c3_addr <= avl_writedata[31:0]; 				end
				4'd4: begin	offset_addr <= avl_writedata[31:0]; 			end
				4'd5: begin temp_data <= avl_writedata[15:0]; 				end
				4'd6: begin wait_count_set <= avl_writedata[15:0]; 			end
				4'd7: begin burst_size <= avl_writedata[5:0]; 				end
				4'd8: begin {video_ysize, video_xsize} <= avl_writedata;	end
				4'd9: begin	img_corr_addr <= avl_writedata[31:0]; 			end
				default: begin end
			endcase // avl_address
		end else if(avl_read) begin 
			avl_readdatavalid <= 1'b1;
			case(avl_address)
				4'd0: begin avl_readdata <= {30'd0, en_1pt_mode,done_frame};end
				4'd1: begin avl_readdata <= c1_addr;  						end
				4'd2: begin avl_readdata <= c2_addr;  						end
				4'd3: begin avl_readdata <= c3_addr;  						end
				4'd4: begin avl_readdata <= offset_addr;  					end	
				4'd5: begin avl_readdata <= {16'd0, temp_data}; 	 		end
				4'd6: begin avl_readdata <= {16'd0, wait_count_set}; 		end	
				4'd7: begin avl_readdata <= {26'd0, burst_size}; 	 		end			
				4'd8: begin avl_readdata <= {video_ysize, video_xsize}; 	end
				4'd9: begin avl_readdata <= img_corr_addr;					end
				default: begin avl_readdata <= 32'hdeadbeef;				end
			endcase
		end
	end
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// State machine to perform calculations and memory transactions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire avm_ready = av_ready;
(* mark_debug = "true" *)reg avm_read ;
(* mark_debug = "true" *)reg avm_write ;
reg avm_wrburst ;
reg [5:0] avm_size;
(* mark_debug = "true" *)reg [31:0] avm_address ;
(* mark_debug = "true" *)reg [31:0] avm_writedata;

assign av_size = avm_size;
assign av_read = avm_read;
assign av_writedata = avm_writedata;
assign av_wrburst = avm_wrburst;
assign av_address = avm_address;
assign av_write = avm_write;
assign av_wrbe = 4'hf;

wire avm_readdatavalid = av_rddatavalid;
(* mark_debug = "true" *)wire [31:0] avm_readdata  = av_readdata;

(* mark_debug = "true" *)reg [4:0] master_fsm;
(* mark_debug = "true" *)reg [4:0] master_fsm_cb;
localparam s_idle = 'd0,
			s_manage_frame = 'd1,
			s_fetch_C1 = 'd2,
			s_fetch_C2 = 'd3,
			s_fetch_C3 = 'd4,
			s_fetch_mem1 = 'd5,
			s_fetch_mem2 = 'd6,
			s_store_mem1 = 'd7,
			s_store_mem2 = 'd8,
			s_calc_offset = 'd9,
			s_calc_offset1 = 'd10,
			s_calc_offset2 = 'd11,
			s_calc_offset3 = 'd12,
			s_calc_offset4 = 'd13,
			s_calc_offset5 = 'd14,
			s_calc_offset6 = 'd15,
			s_wait		   = 'd16,
			s_int_to_fp32 = 'd17,
			s_add_fp32 = 'd18,
			s_add_fp32_2 = 'd19,
			s_mult_fp32 = 'd20,
			s_mult_fp32_2 = 'd21,
			s_fp32_to_int = 'd22,
			s_convert_temp_fp32 = 'd23,
			s_done_temp_fp32 = 'd24,
			s_sq_temp_data = 'd25,
			s_done_sq_temp_data = 'd26,
			s_clip_offset = 'd27,
			s_calc_offset_avg1 = 'd28,
			s_calc_offset_avg2 = 'd29,
			s_fetch_img_corr = 'd30;

reg [31:0] c1_mem [0:15];
reg [31:0] c2_mem [0:15];
reg [31:0] c3_mem [0:15];

reg [15:0] offset_mem[0:15];

reg [15:0] img_corr_buffer[0:15];

reg [7:0] c_addr;

reg c1_sel, c2_sel, c3_sel;
reg img_corr_sel;


reg [31:0] total_pixels;
reg [31:0] batch_offset;


// T in float
reg [31:0] temp_data_fp32;
// T*T in float
reg [31:0] temp_data_sq_fp32;
// C1*T*T in float
reg [31:0] c1_t_sq;

// We will tie all the output ready/ack signals to high, so that we can consume the output as
// soon as it is ready

// fp32 multiplier signals
reg mult_in1_valid;
wire mult_in1_ready;
reg mult_in2_valid;
wire mult_in2_ready;

wire mult_out_valid;
wire mult_out_ready = 1'b1;

reg [31:0] mult_in1;
reg [31:0] mult_in2;
wire [31:0] mult_out;

// fp32 adder signals

reg add_in1_valid;
wire add_in1_ready;
reg add_in2_valid;
wire add_in2_ready;

wire add_out_valid;
wire add_out_ready = 1'b1;

reg [31:0] add_in1;
reg [31:0] add_in2;
wire [31:0] add_out;

// int to fp32  and fp32 to int signals
reg int2fp32_in_valid;
wire int2fp32_in_ready;

wire int2fp32_out_valid;
wire int2fp32_out_ready = 1'b1;

reg [31:0] int2fp32_in;
wire [31:0] int2fp32_out;

reg fp322int_in_valid;
wire fp322int_in_ready;

wire fp322int_out_valid;
wire fp322int_out_ready = 1'b1;

reg [31:0] fp322int_in;
wire [31:0] fp322int_out;

// Offset int signal
reg [31:0] offset_int;

reg [36-1:0] offset_sum;
reg [31:0] num_valid_offset_pixels;
reg [31:0] first2_pixels;

reg div_start;
reg [36-1:0] div_dvsr;
reg [36-1:0] div_dvnd;
wire div_done;
wire [36-1:0] div_quo;


always @(posedge clk or posedge rst) begin : proc_master_fsm
	if(rst) begin
		avm_read <= 0;
		avm_write <= 0;
		avm_wrburst <= 0;
		avm_address <= 0;
		avm_writedata <= 0;
		c_addr <= 0;
		{c1_sel , c2_sel, c3_sel} <= 3'b0;
		img_corr_sel <= 1'b0;
		master_fsm <= s_idle;
		master_fsm_cb <= s_idle;
		total_pixels <= 0;
		batch_offset <= 0;
		done_frame <= 0;
		avm_size <= 16;

		temp_data_fp32 <= 0;
		temp_data_sq_fp32 <= 0;
		c1_t_sq <= 0;

		mult_in1 <= 0;
		mult_in2 <= 0;
		add_in1 <= 0;
		add_in2 <= 0;
		int2fp32_in <= 0;
		fp322int_in <= 0;
		int2fp32_in_valid <= 0;
		fp322int_in_valid <= 0;
		mult_in1_valid <= 0;
		mult_in2_valid <= 0;
		add_in1_valid <= 0;
		add_in2_valid <= 0;

		wait_count <= 0;
		offset_sum <= 0;
		num_valid_offset_pixels <= 0;
		en_1pt_mode_reg <= 0;
		en_nuc_1pt_mode2_reg <= 0;
	end else begin
		case(master_fsm)
			s_idle: begin 
//				if(trigger) begin // start offset calculation
				if(trigger || (en_nuc_1pt_mode2_reg != en_nuc_1pt_mode2))begin // start offset calculation
					en_nuc_1pt_mode2_reg <= en_nuc_1pt_mode2;
					num_valid_offset_pixels <= 0;
					offset_sum <= 0;
					done_frame <= 0;
					batch_offset <= 0;
					master_fsm <= s_convert_temp_fp32;
					total_pixels <= video_xsize* video_ysize;
					avm_size <= burst_size;
					en_1pt_mode_reg <= en_1pt_mode;
				end
			end

//			Convert temperature data to floating point and also calculate sqaure of it
			// T = float(T)
			s_convert_temp_fp32: begin 
				int2fp32_in <= {16'd0, temp_data};
				master_fsm <= s_int_to_fp32;
				master_fsm_cb <= s_done_temp_fp32;
			end

			s_done_temp_fp32: begin 
				if(int2fp32_out_valid) begin 
					temp_data_fp32 <= int2fp32_out;
					master_fsm <= s_sq_temp_data;
				end
			end

			// T*T
			s_sq_temp_data: begin 
				mult_in1 <= temp_data_fp32;
				mult_in2 <= temp_data_fp32;
				master_fsm <= s_mult_fp32;
				master_fsm_cb <= s_done_sq_temp_data;
			end

			s_done_sq_temp_data: begin 
				if(mult_out_valid) begin 
					temp_data_sq_fp32 <= mult_out;
					master_fsm <= s_fetch_C1;
				end
			end

			s_fetch_C1: begin // fetch C1 table
				avm_address <= c1_addr + batch_offset;
				master_fsm <= s_fetch_mem1;
				master_fsm_cb <= s_fetch_C2;
				c1_sel <= 1'b1;
			end

			s_fetch_C2: begin // fetch C2 table
				avm_address <= c2_addr + batch_offset;
				master_fsm <= s_fetch_mem1;
				master_fsm_cb <= s_fetch_C3;
				c2_sel <= 1'b1;
			end

			s_fetch_C3: begin // fetch C3 table
				avm_address <= c3_addr + batch_offset;
				master_fsm <= s_fetch_mem1;
//				if(en_1pt_mode_reg) begin
				if(en_nuc_1pt_mode2_reg)begin
					master_fsm_cb <= s_fetch_img_corr;
				end else begin	
					master_fsm_cb <= s_calc_offset;
				end
				c3_sel <= 1'b1;
			end

			s_fetch_img_corr: begin // fetch img_corr
				avm_address <= img_corr_addr + (batch_offset>>1);
				master_fsm <= s_fetch_mem1;
				master_fsm_cb <= s_calc_offset;
				img_corr_sel <= 1'b1;
			end

// 			Calculation Chain
// 			Can do operations serially as there is no need for realtime performance
			s_calc_offset: begin 
				master_fsm <= s_calc_offset1;
				c_addr <= 0;
			end

			// (T*T) x C1
			s_calc_offset1: begin 
				mult_in1 <= temp_data_sq_fp32;
				mult_in2 <= c1_mem[c_addr];
				master_fsm <= s_mult_fp32;
				master_fsm_cb <= s_calc_offset2;
			end

			// C2 x T
			s_calc_offset2: begin 
				if(mult_out_valid) begin
					c1_t_sq <= mult_out;
					mult_in1 <= temp_data_fp32;
					mult_in2 <= c2_mem[c_addr];
					master_fsm <= s_mult_fp32;
					master_fsm_cb <= s_calc_offset3;
				end
			end

			// C1*T*T + C2*T
			s_calc_offset3: begin 
				if(mult_out_valid) begin 
					add_in1 <= c1_t_sq;
					add_in2 <= mult_out;
					master_fsm <= s_add_fp32;
					master_fsm_cb <= s_calc_offset4;
				end
			end

			// (C1*T*T + C2*T) + C3
			s_calc_offset4: begin 
				if(add_out_valid) begin 
					add_in1 <= add_out;
					add_in2 <= c3_mem[c_addr];
					master_fsm <= s_add_fp32;
					master_fsm_cb <= s_calc_offset5;
				end
			end

			// O = (C1*T*T + C2*T) + C3
			s_calc_offset5: begin 
				if(add_out_valid) begin 
					fp322int_in <= add_out;
					master_fsm <= s_fp32_to_int;
					master_fsm_cb <= s_calc_offset6;
				end
			end

			// O = int(O)
			s_calc_offset6: begin 
				if(fp322int_out_valid) begin 
//					if(en_1pt_mode_reg) begin
					if(en_nuc_1pt_mode2_reg)begin
						offset_int <= $signed(fp322int_out) + $signed(img_corr_buffer[c_addr]) - 8192;
					end else begin
						offset_int <= fp322int_out;
					end
					master_fsm <= s_clip_offset;
				end
			end

			// O > 16383? 16383: (O<0?0: O)
			s_clip_offset: begin 
				if($signed(offset_int) < 0 ) begin 
					offset_mem[c_addr] <= 0;
				end else if($signed(offset_int)>16383) begin
					offset_mem[c_addr] <= 16383;
				end else begin 
					offset_mem[c_addr] <= offset_int[15:0];
				end

				if($signed(offset_int) > 300 && $signed(offset_int) < 16000) begin 
					offset_sum <= offset_sum + offset_int[15:0];
					num_valid_offset_pixels <= num_valid_offset_pixels +1;
				end

				if(c_addr==burst_size-1) begin 
					avm_address <= offset_addr + (batch_offset >> 1); // Divide by two because we are storing only 16 bits
					master_fsm <= s_store_mem1;
					c_addr <= 0;
				end else begin
					c_addr <= c_addr + 1;
					master_fsm <= s_calc_offset1;	
				end
			end

// 			end of calculation chain

// 			Call back routines for fetching and storing from off chip SDRAM

			s_fetch_mem1: begin // fetch data from random address in memory
				avm_read <= 1'b1;
				avm_size <= burst_size;
				c_addr <= 0;
				master_fsm <= s_fetch_mem2;
				if(img_corr_sel) begin
					avm_size <= burst_size >> 1;
				end 
			end
			s_fetch_mem2: begin 
				if(avm_ready) begin  // read accepted
					avm_read <= 1'b0;
				end
				if(avm_readdatavalid) begin 
					if(!img_corr_sel) begin
						if(c1_sel) begin 
							c1_mem[c_addr] <= avm_readdata;
						end else if(c2_sel) begin 
							c2_mem[c_addr] <= avm_readdata;
						end else if(c3_sel) begin 
							c3_mem[c_addr] <= avm_readdata;
						end
						c_addr <= c_addr + 1;
						if(c_addr==burst_size-1) begin 
							c_addr <= 0;
							{c1_sel , c2_sel, c3_sel} <= 3'b0;
							master_fsm <= master_fsm_cb;
						end
					end else begin
						img_corr_buffer[c_addr] <= avm_readdata[15:0];
						img_corr_buffer[c_addr+1] <= avm_readdata[15+16:0+16];
						c_addr <= c_addr + 2;
						if(c_addr==((burst_size)-2)) begin 
							c_addr <= 0;
							img_corr_sel <= 1'b0;
							master_fsm <= master_fsm_cb;
						end
					end
				end
			end
			s_store_mem1:  begin // store data to random address in memory
				avm_writedata <= {offset_mem[1], offset_mem[0]};
				avm_size <= burst_size >> 1; // Divide by 2 because, we will store offset matrix as uint16
				avm_write <= 1'b1;
				avm_wrburst <= 1'b1;
				c_addr <= 2;
				master_fsm <= s_store_mem2;
			end
			s_store_mem2: begin
				if(avm_ready) begin 
					avm_wrburst <= 1'b0;
				end
				if(avm_ready) begin 
					avm_writedata <= {offset_mem[c_addr+1], offset_mem[c_addr]};
					c_addr <= c_addr+2;
					if(c_addr==burst_size) begin 
						c_addr <= 0;
						avm_write <= 1'b0;
						master_fsm <= s_manage_frame;
					end
				end
			end

// 			Manage frame data
			s_manage_frame: begin
				if(total_pixels==burst_size) begin
					// done_frame <= 1'b1;
//					master_fsm <= s_calc_offset_avg1;
					if(en_nuc_1pt_mode2_reg != en_nuc_1pt_mode2)begin
					   master_fsm <= s_idle;
					end
					else begin
					   master_fsm <= s_calc_offset_avg1;
					end 
				end
				else begin 
					total_pixels <= total_pixels - burst_size; // decrement total pixels by burst size
					batch_offset <= batch_offset+4*burst_size; // increment memory address by 4*burst size (32 bit wide BUS)
					wait_count <= wait_count_set;
					master_fsm_cb <= s_fetch_C1;
			        if(en_nuc_1pt_mode2_reg != en_nuc_1pt_mode2)begin
					   master_fsm <= s_idle;
					end
					else begin
					   master_fsm <= s_wait;
					end 
//					master_fsm <= s_wait;

					// Store first two pixels, since we can do only a 32bit write to memory
					// and offset data is only 16 bits. Thus when we finish averaging the
					// offset, we can replace offset_mem[0] corresponding to the first pixel
					// and write it to memory
					if(batch_offset==0) begin 
						first2_pixels <= {offset_mem[1], offset_mem[0]};	
					end
				end
			end

			s_wait: begin 
				if(wait_count==0) begin 
					master_fsm <= master_fsm_cb;
				end else begin 
					wait_count <= wait_count -1;
				end
			end

// 			Calculate the offset image average
			s_calc_offset_avg1:begin 
				div_dvsr <= num_valid_offset_pixels;
				div_dvnd <= offset_sum;
				div_start <= 1'b1;
				master_fsm <= s_calc_offset_avg2;
			end

			s_calc_offset_avg2: begin 
				div_start <= 1'b0;
				if(div_done) begin 
					avm_address <= offset_addr;
					avm_writedata <= {first2_pixels[31:16], div_quo[15:0]};
					avm_size 	<= 1;
					avm_write 	<= 1'b1;
					avm_wrburst <= 1'b1;
				end
				if(avm_write && avm_ready) begin 
					avm_write 	<= 1'b0;
					avm_wrburst <= 1'b0;
					if(en_nuc_1pt_mode2_reg != en_nuc_1pt_mode2)begin
					   done_frame 	<= 1'b0; 	
					end
					else begin
                       done_frame 	<= 1'b1; 	// Finsished storing offset avg in the memory
                    end  					
//					done_frame 	<= 1'b1; 	// Finsished storing offset avg in the memory
					master_fsm 	<= s_idle;
				end
			end

// 			Procedure for floating point operations

			s_int_to_fp32: begin 
				int2fp32_in_valid <= 1'b1;
				if(int2fp32_in_valid && int2fp32_in_ready) begin
					int2fp32_in_valid <= 1'b0;
					master_fsm <= master_fsm_cb;
				end
			end

			s_add_fp32: begin 
				add_in1_valid <=1'b1;
				if(add_in1_ready && add_in1_valid) begin 
					add_in1_valid <=1'b0;
					master_fsm <= s_add_fp32_2;
				end
			end
			s_add_fp32_2: begin 
				add_in2_valid <=1'b1;
				if(add_in2_ready && add_in2_valid) begin 
					add_in2_valid <=1'b0;
					master_fsm <= master_fsm_cb;
				end
			end

			s_mult_fp32: begin 
				mult_in1_valid <= 1'b1;
				if(mult_in1_valid && mult_in1_ready) begin 
					mult_in1_valid <= 1'b0;
					master_fsm <= s_mult_fp32_2;
				end
			end
			s_mult_fp32_2: begin 
				mult_in2_valid <= 1'b1;
				if(mult_in2_valid && mult_in2_ready) begin 
					mult_in2_valid <= 1'b0;
					master_fsm <= master_fsm_cb;
				end
			end

			s_fp32_to_int: begin 
				fp322int_in_valid <= 1'b1;
				if(fp322int_in_valid && fp322int_in_ready) begin 
					fp322int_in_valid <= 1'b0;
					master_fsm <= master_fsm_cb;
				end
			end
		endcase
	end
end


 int_to_float int2fp32_inst(
        .input_a(int2fp32_in),
        .input_a_stb(int2fp32_in_valid),
        .output_z_ack(int2fp32_out_ready),
        .clk(clk),
        .rst(rst),
        .output_z(int2fp32_out),
        .output_z_stb(int2fp32_out_valid),
        .input_a_ack(int2fp32_in_ready));

 float_to_int fp322int_inst(
        .input_a(fp322int_in),
        .input_a_stb(fp322int_in_valid),
        .output_z_ack(fp322int_out_ready),
        .clk(clk),
        .rst(rst),
        .output_z(fp322int_out),
        .output_z_stb(fp322int_out_valid),
        .input_a_ack(fp322int_in_ready));

fp32_adder fp32_adder_inst(
        .input_a(add_in1),
        .input_b(add_in2),
        .input_a_stb(add_in1_valid),
        .input_b_stb(add_in2_valid),
        .output_z_ack(add_out_ready),
        .clk(clk),
        .rst(rst),
        .output_z(add_out),
        .output_z_stb(add_out_valid),
        .input_a_ack(add_in1_ready),
        .input_b_ack(add_in2_ready));

fp32_multiplier fp32_multiplier_inst(
        .input_a(mult_in1),
        .input_b(mult_in2),
        .input_a_stb(mult_in1_valid),
        .input_b_stb(mult_in2_valid),
        .output_z_ack(mult_out_ready),
        .clk(clk),
        .rst(rst),
        .output_z(mult_out),
        .output_z_stb(mult_out_valid),
        .input_a_ack(mult_in1_ready),
        .input_b_ack(mult_in2_ready));

div 	#(
  		.W(36),
  		.CBIT(6))
 div_int_inst(
  		.clk(clk),
  		.reset(rst),
  		.start(div_start),
  		.dvsr(div_dvsr), 
  		.dvnd(div_dvnd),
  		.done_tick(div_done),
  		.quo(div_quo), 
  		.rmd()); 


`ifdef ILA_NUC1pt_MODE2

wire [127:0] probe0;
TOII_TUVE_ila ila_offset(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {18'd0, avm_write, avm_read, avm_address, avm_readdata, master_fsm, master_fsm_cb, en_1pt_mode_reg, trigger, img_corr_addr}; //1+1+32+32+5+5+1+1+32

`endif

endmodule