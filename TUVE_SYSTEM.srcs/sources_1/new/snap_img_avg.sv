// `define ILA_SNAP_AVG
module snap_img_avg (
	input clk,    // Clock
	input rst,  // Asynchronous reset active high

	// Master AVALON interface for fetching and storing images
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

`include "TOII_TUVE_HEADER.vh"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Control signals
(* mark_debug = "true" *)reg trigger;
(* mark_debug = "true" *)reg done_frame;
reg [15:0] video_xsize;
reg [15:0] video_ysize;
reg [5:0] burst_size;


reg [5:0] img_frame_exponent; // imgs_to_average = 2**(img_frame_exponent)

assign avl_waitrequest = 0;
always @(posedge clk or posedge rst) begin : proc_slave_logic
	if(rst) begin
		trigger <= 0;
		avl_readdatavalid <= 1'b0;
		burst_size <= 16;
		video_ysize <= 519;
		video_xsize <= 664;
		img_frame_exponent <= 0;
	end else begin
		avl_readdatavalid <= 1'b0;
		trigger <= 0;
		if(avl_write) begin 
			case(avl_address)
				4'd0: begin trigger <= avl_writedata[0]; img_frame_exponent <= avl_writedata[16+5:16];	end
				4'd1: begin burst_size <= avl_writedata[5:0]; 		end
				4'd2: begin {video_ysize, video_xsize} <= avl_writedata;				end
				default: begin end
			endcase // avl_address
		end else if(avl_read) begin 
			avl_readdatavalid <= 1'b1;
			case(avl_address)
				4'd0: begin avl_readdata <= {10'd0 ,img_frame_exponent, 15'd0, done_frame};		end
				4'd1: begin avl_readdata <= {26'd0, burst_size}; 	 	end			
				4'd2: begin avl_readdata <= {video_ysize, video_xsize}; end
				default: begin avl_readdata <= 32'hdeadbeef; end
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

(* mark_debug = "true" *)reg [4:0] master_fsm;
(* mark_debug = "true" *)reg [4:0] master_fsm_cb;

localparam s_idle = 'd0,
		   s_manage_frame = 'd1,
		   s_fetch_mem1 = 'd2,
		   s_fetch_mem2 = 'd3,
		   s_store_mem1 = 'd4,
		   s_store_mem2 = 'd5,
		   s_manage_frame1 = 'd6,
		   s_manage_frame2 = 'd7,
		   s_clear_mem = 'd8,
		   s_add_batch_offset ='d9,
		   s_get_imgs = 'd10,
		   s_accumulate1 = 'd11,
		   s_accumulate2 = 'd12,
		   s_division = 'd13;


reg [15:0] img_buff_mem [0:31];
reg [31:0] img_avg_mem [0:31];

(* mark_debug = "true" *)reg [7:0] c_addr;
(* mark_debug = "true" *)reg [31:0] batch_offset;

(* mark_debug = "true" *)reg [7:0] img_count;

reg [31:0] img_address;
wire [31:0] img_avg_address = ADDR_OFFM_COEFF_START;


reg [7:0] total_frames_to_average;

always@(*) begin
	case(img_frame_exponent) 
		0: total_frames_to_average <= 1;
		1: total_frames_to_average <= 2;
		2: total_frames_to_average <= 4;
		3: total_frames_to_average <= 8;
		4: total_frames_to_average <= 16;
		5: total_frames_to_average <= 32;
		default: total_frames_to_average <= 1;
	endcase
end

`define DIV_BITS  5;

always @(posedge clk or posedge rst) begin : proc_master_fsm
	if(rst) begin
		avm_read <= 0;
		avm_write <= 0;
		avm_wrburst <= 0;
		avm_address <= 0;
		avm_writedata <= 0;
		c_addr <= 0;
		master_fsm <= s_idle;
		master_fsm_cb <= s_idle;
		batch_offset <= 0;
		done_frame <= 0;
		avm_size <= 16;
		img_count <= 0;

	end else begin
		case(master_fsm)
			s_idle: begin 
				if(trigger) begin // start offset calculation
					done_frame <= 0;
					batch_offset <= 0;
					img_count <= 0;
					c_addr <= 0;
					master_fsm <= s_clear_mem;
					avm_size <= burst_size;

					// if(img_frame_exponent==0) begin 
					// 	done_frame <= 1'b1;
					// 	master_fsm <= s_idle;
					// end
				end
			end

			s_clear_mem: begin
				if(c_addr == burst_size*2 -1) begin	
					c_addr <= 0;
					master_fsm <= s_get_imgs;	
				end else begin
					c_addr <= c_addr + 1;
				end
				img_avg_mem[c_addr] <= 0;
			end

			s_get_imgs: begin
				img_address <= ADDR_SNAPSHOT_BASE + img_count*ADDR_SNAPSHOT_OFFSET_1;
				master_fsm <= s_add_batch_offset;
			end

			s_add_batch_offset: begin
				avm_address <= img_address + batch_offset;
				c_addr <= 0;
				master_fsm <= s_fetch_mem1;
				master_fsm_cb <= s_accumulate1;
			end

			s_accumulate1: begin
				img_avg_mem[c_addr] <= img_avg_mem[c_addr] + img_buff_mem[c_addr];
				master_fsm <= s_accumulate2;
			end

			s_accumulate2: begin
				if(c_addr == burst_size*2 -1) begin
					c_addr <= 0;
					master_fsm <= s_manage_frame1;
				end else begin	
					c_addr <= c_addr + 1;
					master_fsm <= s_accumulate1;
				end
			end

			s_manage_frame1: begin	
				if(img_count == total_frames_to_average-1) begin
					img_count <= 0;
					avm_address <= img_avg_address + batch_offset;
					master_fsm <= s_division;
					c_addr <= 0;
				end else begin
					img_count <= img_count + 1;
					master_fsm <= s_get_imgs;
				end
			end

			s_manage_frame2: begin
				if(batch_offset==ADDR_SNAPSHOT_OFFSET_1-burst_size) begin
					batch_offset <= 0;
					done_frame <= 1'b1;
					master_fsm <= s_idle;
					// master_fsm <= s_manage_frame2;
					// if(img_count == TOTAL_FRAME_BUFFERS-1) begin
						
					// end else begin
					// 	master_fsm <= s_get_imgs;
					// end
				end else begin
					batch_offset <= batch_offset + burst_size;
					master_fsm <= s_clear_mem;
				end
			end


			s_division: begin
				if(c_addr==burst_size*2 -1 ) begin 
					c_addr <= 0;
					master_fsm <= s_store_mem1;
					master_fsm_cb <= s_manage_frame2;
				end else begin
					c_addr <= c_addr + 1;
				end 
				case(img_frame_exponent)
					0: img_avg_mem[c_addr] <= img_avg_mem[c_addr][15:0];
					1: img_avg_mem[c_addr] <= img_avg_mem[c_addr][15+1:0+1];
					2: img_avg_mem[c_addr] <= img_avg_mem[c_addr][15+2:0+2];
					3: img_avg_mem[c_addr] <= img_avg_mem[c_addr][15+3:0+3];
					4: img_avg_mem[c_addr] <= img_avg_mem[c_addr][15+4:0+4];
					5: img_avg_mem[c_addr] <= img_avg_mem[c_addr][15+5:0+5];
					default: img_avg_mem[c_addr] <= img_avg_mem[c_addr][15:0];
				endcase
			end

// 			Call back routines for fetching and storing from off chip SDRAM

			s_fetch_mem1: begin // fetch data from random address in memory
				avm_read <= 1'b1;
				avm_size <= burst_size;
				c_addr <= 0;
				master_fsm <= s_fetch_mem2;
			end
			s_fetch_mem2: begin 
				if(avm_ready) begin  // read accepted
					avm_read <= 1'b0;
				end
				if(avm_readdatavalid) begin 

					img_buff_mem[c_addr] <= avm_readdata[15:0];
					img_buff_mem[c_addr+1] <= avm_readdata[15+16:0+16];

					c_addr <= c_addr + 2;
					if(c_addr==burst_size*2-2) begin 
						c_addr <= 0;
						master_fsm <= master_fsm_cb;
					end
				end
			end
			s_store_mem1:  begin // store data to random address in memory
				// Divide by 32 (average of 32 raw images) so leave out the last 5 bits
				avm_writedata <= {img_avg_mem[1][15:0], img_avg_mem[0][15:0]};
				avm_size <= burst_size;
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
					// Divide by 32 (average of 32 raw images) so leave out the last 5 bits
					avm_writedata <= {img_avg_mem[c_addr+1][15:0], img_avg_mem[c_addr][15:0]};
					c_addr <= c_addr+2;
					if(c_addr==burst_size*2) begin 
						c_addr <= 0;
						avm_write <= 1'b0;
						master_fsm <= master_fsm_cb;
					end
				end
			end
		endcase
	end
end




`ifdef ILA_SNAP_AVG

wire [127:0] probe0;
TOII_TUVE_ila ila_offset(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {46'd0, avm_address, avm_write, avm_read, img_count, batch_offset[19:0], c_addr, done_frame, trigger, master_fsm, master_fsm_cb}; // 32+1+1+8+20+8+1+1+5+5

`endif

endmodule