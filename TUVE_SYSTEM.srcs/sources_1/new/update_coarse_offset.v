// `define  ILA_COARSE_OFFSET_UPDATE
module update_coarse_offset 
#(	parameter SENSOR_XSIZE = 664,
	parameter SENSOR_YSIZE = 519,
	parameter CO_XSIZE = 660,
	parameter CO_YSIZE = 500
	)
	(
	input clk,    // Clock
	input rst,  // Asynchronous reset active high
    
    input [15:0]target_value_threshold, 
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
	We will implement the coarse offset calculation in this section
	Coarse offset is calculated by looking at the image snapshot 
	and then changing the coarse offset value till the video is somewhat
	centered to around 8192.

	In the datasheet the first step to calculate the coarse offset is to
	find the gain of the coarse offset map. Here in this implementation
	we will assume that the gain is a constant 1024, and adjust all the
	detectors accordingly.

	The algorihtm is simple.
	We first take a snapshot of the image.
	Then pixel by pixel we will caluculate the quantity
		delta = pix - 8192
		delta = delta >> 10 // Divide by 1024

	And then add this delta back to the original coarse offset map
		coarse_offset_update = coarse_offset + delta

	A rough pseudocode would be as follows.

	void update_coarse_offset(uint16_t pix, uint8_t coarse_offset, uint16_t video_xsize, uint16_t video_ysize){
		
		uint16_t N=16; // We perform chunks of calculation at a time and store back the results

		uint16_t pix_buff[N];
		uint16_t coarse_offset_buff[N];

		int16_t delta;

		for(int i=0; i<video_xsize*video_ysize/N;i++){
			for(int k=0;k<N;k++){
				// get pixel and coarse offset map
				pix_buff[k] = pix[i*N+k];
				coarse_offset_buff[k] = coarse_offset[i*N+k];
				
				// Find delta
				delta = pix_buff[k] - 8192;
				// In RTL other division factors such as 
				// 600, 800, 1000, 1200, 1400 can be configured
				// Here the factor is 1024
				delta = delta >> 10;

				// Also RTL contains a 'fine' correction mode
				// In which the delta changes only by 1, if the
				// diff is greater than 1000. 
				
				// Add delta to the coarse offset map
				if(delta>=0){
					coarse_offset_buff[k] = coarse_offset_buff[k] + delta;
				} else{
					coarse_offset_buff[k] = coarse_offset_buff[k] - delta;
				}

				// store back the coarse offset map
				coarse_offset[i*N+k] = coarse_offset_buff[k];

			}
		}
	}

*/

reg trigger;
reg done_frame;
// reg [15:0] video_xsize;
// reg [15:0] video_ysize;
reg [31:0] pix_addr;
reg [31:0] coarse_offset_addr;

reg [15:0] wait_count;
reg [15:0] wait_count_set;

reg [5:0] burst_size;
reg [15:0] start_line_count;
reg [3:0] co_calc_mode;

reg [7:0] coarse_offset_dc;

assign avl_waitrequest = 0;
always @(posedge clk or posedge rst) begin : proc_slave_logic
	if(rst) begin
		trigger <= 0;
		avl_readdatavalid <= 1'b0;
		pix_addr <= 32'h021AA000;
		coarse_offset_addr <= 32'h006CC000;
		wait_count_set <= 10;
		burst_size <= 16;
		// video_ysize <= 500;
		// video_xsize <= 660;
		start_line_count <= 9;
		co_calc_mode <= 0;
		coarse_offset_dc <= 8'hb4;
	end else begin
		avl_readdatavalid <= 1'b0;
		trigger <= 0;
		if(avl_write) begin 
			case(avl_address)
				4'd0: begin trigger <= avl_writedata[0]; 					end
				4'd1: begin pix_addr <= avl_writedata[31:0]; 				end
				4'd2: begin	coarse_offset_addr <= avl_writedata[31:0]; 		end
				4'd3: begin wait_count_set <= avl_writedata[15:0]; 			end
				4'd4: begin burst_size <= avl_writedata[5:0]; 				end
				4'd5: begin start_line_count <= avl_writedata[15:0]; 		end 
				4'd6: begin co_calc_mode <= avl_writedata[3:0]; 			end
				4'd7: begin coarse_offset_dc <= avl_writedata[7:0]; 		end
				default:// do nothing
				;
			endcase // avl_address
		end else if(avl_read) begin 
			avl_readdatavalid <= 1'b1;
			case(avl_address)
				4'd0: begin avl_readdata <= {31'd0, done_frame};		end
				4'd1: begin avl_readdata <= pix_addr;  					end
				4'd2: begin avl_readdata <= coarse_offset_addr;  		end
				4'd3: begin avl_readdata <= {16'd0, wait_count_set}; 	end	
				4'd4: begin avl_readdata <= {26'd0, burst_size}; 	 	end			
				4'd5: begin avl_readdata <= {16'd0, start_line_count}; 	end
				4'd6: begin avl_readdata <= {28'd0, co_calc_mode}; 		end
				4'd7: begin avl_readdata <= {24'd0, coarse_offset_dc}; 	end
				default:// do nothing
				;
			endcase
		end
	end
end


(* mark_debug = "true" *)wire avm_ready = av_ready;
reg avm_read ;
(* mark_debug = "true" *)reg avm_write ;
(* mark_debug = "true" *)reg avm_wrburst ;
(* mark_debug = "true" *)reg [5:0] avm_size;
(* mark_debug = "true" *)reg [31:0] avm_address ;
reg [31:0] avm_writedata;

assign av_size = avm_size;
assign av_read = avm_read;
assign av_writedata = avm_writedata;
assign av_wrburst = avm_wrburst;
assign av_address = avm_address;
assign av_write = avm_write;
assign av_wrbe = 4'hf;

wire avm_readdatavalid = av_rddatavalid;
wire [31:0] avm_readdata  = av_readdata;


reg [31:0] pix_batch_offset;
reg [31:0] co_batch_offset;


(* mark_debug = "true" *)reg [15:0] pix_buff [0:15];
(* mark_debug = "true" *)reg [7:0] coarse_offset_buff [0:15];
reg pix_buff_sel, coarse_offset_buff_sel;
(* mark_debug = "true" *)reg [7:0] c_addr;

(* mark_debug = "true" *)reg [4:0] master_fsm;
reg [4:0] master_fsm_cb;

(* mark_debug = "true" *)reg signed [15:0] delta;
(* mark_debug = "true" *)reg signed [15:0] coarse_offset_update;
(* mark_debug = "true" *)reg signed [15:0] delta_update;
(* mark_debug = "true" *)reg signed [21:0] delta_mult;

reg [15:0] line_counter;
(* mark_debug = "true" *)reg [15:0] pix_counter;
(* mark_debug = "true" *)reg [5:0] burst_size_i;

localparam s_idle = 'd0,
			s_manage_frame = 'd1,
			s_fetch_pix = 'd2,
			s_fetch_coarse_offset = 'd3,
			s_calc_coarse_offset = 'd4,
			s_calc_coarse_offset1 = 'd5,
			s_calc_coarse_offset2 = 'd6,
			s_calc_coarse_offset3 = 'd7,
			s_calc_coarse_offset4 = 'd8,
			s_fetch_mem1 = 'd9,
			s_fetch_mem2 = 'd10,
			s_store_mem1 = 'd11,
			s_store_mem2 = 'd12,
			s_wait = 'd13,
			s_line_manage = 'd14,
			s_calc_coarse_offset2_1 = 'd15,
			s_fill_co = 'd16,
			s_store_co_dc = 'd17,
			s_calc_coarse_offset2_21 = 'd18,
			s_calc_coarse_offset2_22 = 'd19;


always @(posedge clk or posedge rst) begin : proc_fsm
	if(rst) begin
		avm_read <= 0;
		avm_write <= 0;
		avm_wrburst <= 0;
		avm_address <= 0;
		avm_writedata <= 0;
		c_addr <= 0;
		{pix_buff_sel , coarse_offset_buff_sel} <= 3'b0;
		master_fsm <= s_idle;
		master_fsm_cb <= s_idle;
		delta <= 0;
		coarse_offset_update <= 0;
		delta_update <= 0;
		done_frame <= 1'b0;
		pix_batch_offset <= 0;
		co_batch_offset <= 0;
		wait_count <= 0;
		avm_size <= 0;
		line_counter <= 0;
		pix_counter <= 0;
		burst_size_i <= 0;
	end else begin
		case(master_fsm)
			s_idle: begin 
				if(trigger) begin
					done_frame <= 0;
					pix_batch_offset <= 0;
					co_batch_offset <= 0;
					line_counter <= 0;
					c_addr <= 0;
					if(co_calc_mode==0) begin
						master_fsm <= s_fill_co;
					end else begin
						master_fsm <= s_line_manage;
					end
				end
			end

			// Fill up the coarse offset buffer with constant value
			// then store it in the SDRAM
			s_fill_co: begin 
				coarse_offset_buff[c_addr] <= coarse_offset_dc;
				c_addr <= c_addr + 1;
				if(c_addr==burst_size-1) begin
					c_addr <= 0;
					master_fsm <= s_line_manage;
				end
			end

			s_line_manage: begin
				//The raw image dimension is 664*519, we need to start fetching from 10th line, with a 4 pixel offset
				pix_batch_offset <= (((start_line_count+line_counter)*(SENSOR_XSIZE)) << 1) + 4*2; 
				co_batch_offset <= line_counter*CO_XSIZE;
				burst_size_i <= burst_size;
				pix_counter <= CO_XSIZE;
				if(co_calc_mode==0) begin
					master_fsm <= s_store_co_dc;
				end else begin
					master_fsm <= s_fetch_pix;
				end
			end

			s_store_co_dc: begin
				avm_address <= coarse_offset_addr + (co_batch_offset); 
				c_addr <= 0;
				master_fsm <= s_store_mem1;
			end

			s_fetch_pix: begin // fetch image snapshot
				avm_address <= pix_addr + (pix_batch_offset);
				master_fsm <= s_fetch_mem1;
				master_fsm_cb <= s_fetch_coarse_offset;
				pix_buff_sel <= 1'b1;
			end

			s_fetch_coarse_offset: begin // fetch  table
				avm_address <= coarse_offset_addr + (co_batch_offset);
				master_fsm <= s_fetch_mem1;
				master_fsm_cb <= s_calc_coarse_offset;
				coarse_offset_buff_sel <= 1'b1;
			end

			s_calc_coarse_offset: begin 
				master_fsm <= s_calc_coarse_offset1;
				c_addr <= 0;
			end

			s_calc_coarse_offset1: begin 
				delta <= pix_buff[c_addr] - 8192;
				if(co_calc_mode==1) begin 					// Fine correction mode
					master_fsm <= s_calc_coarse_offset2_1;
				end else if(co_calc_mode==2) begin 			// Normal correction mode , div = 1024
					master_fsm <= s_calc_coarse_offset2;
				end else begin 								/// Other correction modes, div = [600, 800, 1000, 1200, 1400]
					master_fsm <= s_calc_coarse_offset2_21;
				end
			end

			s_calc_coarse_offset2: begin 
				// if(delta[15]) begin
				// 	delta_update <= (0-delta) >> 10;
				// end else begin
				// 	delta_update <= (delta) >> 10;
				// end
				delta_update <= (delta) >>> 10;
				master_fsm <= s_calc_coarse_offset3;
			end

			s_calc_coarse_offset2_1: begin
//				if($signed(delta)>1000) begin
//					delta_update <= 1;
//				end else if ($signed(delta)<-1000) begin
//					delta_update <= -1;
//				end else begin
//					delta_update <=0;
//				end
                if($signed(delta)>$signed(target_value_threshold)) begin
                    delta_update = 1;
                end else if ($signed(delta)<-$signed(target_value_threshold)) begin
                    delta_update = -1;
                end else begin
                    delta_update =0;
                end
				master_fsm <= s_calc_coarse_offset3;
			end

			s_calc_coarse_offset2_21: begin
				if(co_calc_mode==3) begin 					// div by 600, 2**15/600 ~= 54, similarly for 800, 1000, 1200, 1400 
					delta_mult <= (delta * 54);
				end else if(co_calc_mode==4) begin
					delta_mult <= (delta * 41);
				end else if(co_calc_mode==5) begin
					delta_mult <= (delta * 33) ;
				end else if(co_calc_mode==6) begin
					delta_mult <= (delta * 27) ;
				end else if(co_calc_mode==7) begin
					delta_mult <= (delta * 23) ;
				end else begin
					delta_mult <= (delta * 33) ;
				end
				master_fsm <= s_calc_coarse_offset2_22;
			end

			s_calc_coarse_offset2_22: begin
				delta_update <= delta_mult >>> 15;
				master_fsm <= s_calc_coarse_offset3;
			end

			s_calc_coarse_offset3: begin
				// if(delta[15]) begin // Negative value then subtract else add
				// 	coarse_offset_update <= {8'd0, coarse_offset_buff[c_addr]} - {{8{delta_update[7]}}, delta_update};
				// end else begin 
				// 	coarse_offset_update <= {8'd0, coarse_offset_buff[c_addr]} + {{8{delta_update[7]}}, delta_update};
				// end
				coarse_offset_update <= {8'd0, coarse_offset_buff[c_addr]} + delta_update;
				master_fsm <= s_calc_coarse_offset4;
			end

			s_calc_coarse_offset4: begin // clip results 
				if($signed(coarse_offset_update)<0) begin
					coarse_offset_buff[c_addr] <= 0;
				end else if($signed(coarse_offset_update)>255) begin
					coarse_offset_buff[c_addr] <= 255;
				end else begin
					coarse_offset_buff[c_addr] <= coarse_offset_update[7:0];
				end
				if(c_addr==burst_size_i-1) begin
					avm_address <= coarse_offset_addr + (co_batch_offset); 
					c_addr <= 0;
					master_fsm <= s_store_mem1;
				end else begin
					c_addr <= c_addr + 1;
					master_fsm <= s_calc_coarse_offset1;
				end
			end

			// 			Call back routines for fetching and storing from off chip SDRAM

			s_fetch_mem1: begin // fetch data from random address in memory
				avm_read <= 1'b1;
				if(pix_buff_sel) begin
					avm_size <= burst_size_i>>1;
				end else if(coarse_offset_buff_sel) begin 
					avm_size <= burst_size_i>>2;
				end
				c_addr <= 0;
				master_fsm <= s_fetch_mem2;
			end
			s_fetch_mem2: begin 
				if(avm_ready) begin  // read accepted
					avm_read <= 1'b0;
				end
				if(avm_readdatavalid) begin 
					if(pix_buff_sel) begin 
						// Pixel values are stored in 16bit locations
						{pix_buff[c_addr+1],pix_buff[c_addr]} <= avm_readdata;  
						c_addr <= c_addr + 2;
						if(c_addr==burst_size_i-2) begin 
							c_addr <= 0;
							{pix_buff_sel, coarse_offset_buff_sel} <= 2'b0;   
							master_fsm <= master_fsm_cb;
						end
					end else if(coarse_offset_buff_sel) begin 
						// coarse offsets are stored in 8bit locations
						{coarse_offset_buff[c_addr+3],coarse_offset_buff[c_addr+2], coarse_offset_buff[c_addr+1], coarse_offset_buff[c_addr]} <= avm_readdata;
						c_addr <= c_addr + 4;
						if(c_addr==burst_size_i-4) begin 
							c_addr <= 0;
							{pix_buff_sel, coarse_offset_buff_sel} <= 2'b0;
							master_fsm <= master_fsm_cb;
						end
					end
				end
			end
			s_store_mem1:  begin // store data to random address in memory
				avm_writedata <= {coarse_offset_buff[3],coarse_offset_buff[2], coarse_offset_buff[1], coarse_offset_buff[0]};
				avm_size <= burst_size_i >> 2; // Divide by 4 because, we will store coarse offset map as uint8
				avm_write <= 1'b1;
				avm_wrburst <= 1'b1;
				c_addr <= 4;
				master_fsm <= s_store_mem2;
			end
			s_store_mem2: begin
				if(avm_ready) begin 
					avm_wrburst <= 1'b0;
				end
				if(avm_ready) begin 
					avm_writedata <= {coarse_offset_buff[c_addr+3],coarse_offset_buff[c_addr+2], coarse_offset_buff[c_addr+1], coarse_offset_buff[c_addr]};
					c_addr <= c_addr+4;
					if(c_addr==burst_size_i) begin 
						c_addr <= 0;
						avm_write <= 1'b0;
						master_fsm <= s_manage_frame;
						pix_counter <= pix_counter - burst_size_i;
						pix_batch_offset <= pix_batch_offset + 2*burst_size_i;
						co_batch_offset <= co_batch_offset + burst_size_i;
					end
				end
			end
			// 			Manage frame data
			s_manage_frame: begin
				if(pix_counter==0) begin
					if(line_counter==CO_YSIZE-1) begin
						master_fsm_cb <= s_idle;
					end else begin	
						line_counter <= line_counter + 1;
						master_fsm_cb <= s_line_manage;
					end
				end else begin
					if(pix_counter  < burst_size_i) begin
						burst_size_i <= pix_counter;
						// pix_counter <= 0;
						// pix_batch_offset <= pix_batch_offset + 2*pix_counter;
						// co_batch_offset <= co_batch_offset + pix_counter;
					end else begin
						// pix_batch_offset <= pix_batch_offset + 2*burst_size_i;
						// co_batch_offset <= co_batch_offset + burst_size_i;
						// pix_counter <= pix_counter - burst_size_i;	
						burst_size_i <= burst_size;
					end
					if(co_calc_mode==0) begin
						master_fsm_cb <= s_store_co_dc;
					end else begin
						master_fsm_cb <= s_fetch_pix;
					end
				end
				wait_count <= wait_count_set;
				master_fsm <= s_wait;
			end

			s_wait: begin 
				if(wait_count==0) begin 
					master_fsm <= master_fsm_cb;
				end else begin 
					wait_count <= wait_count -1;
				end
			end
		endcase // master_fsm
	end
end


`ifdef ILA_COARSE_OFFSET_UPDATE

wire [127:0] probe0;
TOII_TUVE_ila ila_offset(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {4'd0, master_fsm, c_addr, delta, delta_update, coarse_offset_update, pix_counter, burst_size_i, avm_write, avm_ready, avm_wrburst,avm_address, avm_size
                 }; // 5+8+16*3+16+6+3+32+6


`endif
endmodule : update_coarse_offset