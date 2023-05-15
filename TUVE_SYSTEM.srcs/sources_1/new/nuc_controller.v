//`define  ILA_OFFSET_POLY
module nuc_controller
	#(parameter VIDEO_XSIZE = 640,
			VIDEO_YSIZE = 480,
			bit_width = 13,
			SIZE_BITS = 7)
	(
	input clk,    // Clock
	input rst,  // Asynchronous reset active high

	(* mark_debug = "true" *)input en_nuc,
	input en_nuc_1pt,
	input en_unity_gain,
	input en_nuc_1pt_mode2,
	input       force_temp_range_en,
    input [2:0] force_temp_range,
    input tick1s,
    input [15:0] temp_range_update_timeout,
    input [15:0] auto_shutter_timeout,
    input        sensor_power_on_init_done,
    input [15:0] temperature_threshold,
	// Master AVALON interface for fetching and storing tables
	(* mark_debug = "true" *)input av_ready,
	(* mark_debug = "true" *)output av_read,
	(* mark_debug = "true" *)output av_write,
	(* mark_debug = "true" *)output av_wrburst,
	(* mark_debug = "true" *)output [5:0] av_size,
	(* mark_debug = "true" *)output [31:0] av_address,
	(* mark_debug = "true" *)output [31:0] av_writedata,
	(* mark_debug = "true" *)output [3:0] av_wrbe,
	(* mark_debug = "true" *)input av_rddatavalid,
	(* mark_debug = "true" *)input [31:0] av_readdata,


	// Master AVALON interface for reading gain tables
	input 	dma1_rdready ,
	output 	dma1_rdreq   ,
	output 	[SIZE_BITS-1:0] dma1_rdsize  ,
	output 	[31:0] dma1_rdaddr  ,
	input 	dma1_rddav   ,
	input 	[31:0] dma1_rddata  ,
	// Master AVALON interface for reading offset tables
	input 	dma2_rdready ,
	output 	dma2_rdreq   ,
	output 	[SIZE_BITS-1:0] dma2_rdsize  ,
	output 	[31:0] dma2_rdaddr  ,
	input 	dma2_rddav   ,
	input 	[31:0] dma2_rddata  ,

 	(* mark_debug = "true" *)input video_i_v    ,
 	(* mark_debug = "true" *)input video_i_h    ,
 	(* mark_debug = "true" *)input video_i_eoi  ,
 	(* mark_debug = "true" *)input video_i_dav  ,
 	input [bit_width:0]video_i_data ,

	output video_o_v    ,
	output video_o_h    ,
	output video_o_eoi  ,
	output video_o_dav  ,
	output [bit_width:0]video_o_data ,
	output video_o_bad  ,
    
    input             update_gallery_img_valid_reg_en      ,
    input      [71:0] update_gallery_img_valid_reg         ,
    input      [7:0]  temperature_write_data               ,
    input             temperature_write_data_valid         ,
    output reg [15:0] temperature_rd_data                  ,
    output reg        temperature_rd_data_valid            ,
    input             temperature_rd_rq                    ,
    input [7:0]       temperature_wr_addr                  ,
    input             temperature_wr_rq                    ,
    input [15:0]      STORE_TEMP_AVG_FRAME                 ,
    
    output reg [31:0] ADDR_COARSE_OFFSET,
    output reg        update_sensor_param,
    output reg [5:0]  new_sensor_param_start_addr,
    output reg [2:0]  CUR_TEMP_AREA,
    input      [3:0]  temp_sense_offset,
    (* mark_debug = "true" *)output take_snapshot_reg,
    (* mark_debug = "true" *)output reg area_switch_done,
    (* mark_debug = "true" *)output reg low_to_high_temp_area_switch,
    (* mark_debug = "true" *)output reg high_to_low_temp_area_switch,
    input        [1:0] MUX_NUC_MODE,
    input        [1:0] MUX_BLADE_MODE,
    output reg    toggle_gpio,
    output reg    calc_done,
    output reg    calc_busy,
	input  [15:0] temp_data

	);


`include "TOII_TUVE_HEADER.vh"
`define TEMP_AREA_0 3'h0
`define TEMP_AREA_1 3'h1
`define TEMP_AREA_2 3'h2
`define TEMP_AREA_3 3'h3
`define TEMP_AREA_4 3'h4
`define TEMP_AREA_5 3'h5
`define TEMP_AREA_6 3'h6
reg take_snapshot;
(* mark_debug = "true" *)reg [2:0] PREVIOUS_TEMP_AREA;
(* mark_debug = "true" *)reg [15:0] previous_temperature;
(* mark_debug = "true" *)reg signed [15:0] temperature_diff_pos;
(* mark_debug = "true" *)reg signed [15:0] temperature_diff_neg;
(* mark_debug = "true" *) reg update_sensor_param_level ;
(* mark_debug = "true" *) reg update_coarse_offset_level;
(* mark_debug = "true" *)reg [15 :0]frame_cnt_btwn_area_change_and_snsr_update;
(* mark_debug = "true" *)reg [31 :0] LATCH_ADDR_COARSE_OFFSET;
wire avl1_waitrequest;
reg avl1_write;
reg avl1_read;
reg [3:0] avl1_address;
wire [31:0] avl1_readdata;
wire avl1_readdatavalid;
reg [31:0] avl1_writedata;

wire avl2_waitrequest;
reg avl2_write;
reg avl2_read;
reg [3:0] avl2_address;
wire [31:0] avl2_readdata;
wire avl2_readdatavalid;
reg [31:0] avl2_writedata;

reg        update_gallery_img_valid_reg_en_d;
reg        update_gallery_img_valid_reg_en_dd;
reg        update_gallery_img_valid_reg_en_ddd;
reg        update_gallery_img_valid_reg_en_dddd;
reg [15:0] TEMPERATURE_MEM [0:127];
reg [7:0]  TEMPERATURE_MEM_WR_ADDR;
reg [7:0]  TEMPERATURE_MEM_RD_ADDR;
reg [15:0] temperature_write_data_temp;
reg        temperature_mem_write_en;
reg [15:0] time_cnt;
reg [15:0] time_cnt_auto_shutter;
reg        latch_auto_shutter_en;
reg        temp_range_update_en;
reg        power_on_temp_range_update_en;
reg        switch_temp_offset_area;

assign take_snapshot_reg = take_snapshot && (!power_on_temp_range_update_en);

always @ (posedge clk or posedge rst) begin
  if (rst) begin
      TEMPERATURE_MEM_WR_ADDR     <= 0;
      temperature_write_data_temp <= 0;
      temperature_mem_write_en    <= 1'b0;
      TEMPERATURE_MEM_RD_ADDR     <= 0 ;
      update_gallery_img_valid_reg_en_d    <= 1'b0;
      update_gallery_img_valid_reg_en_dd   <= 1'b0; 
      update_gallery_img_valid_reg_en_ddd  <= 1'b0;  
      update_gallery_img_valid_reg_en_dddd <= 1'b0;
  end    
  else begin
      update_gallery_img_valid_reg_en_d    <= update_gallery_img_valid_reg_en;
      update_gallery_img_valid_reg_en_dd   <= update_gallery_img_valid_reg_en_d;
      update_gallery_img_valid_reg_en_ddd  <= update_gallery_img_valid_reg_en_dd;
      update_gallery_img_valid_reg_en_dddd <= update_gallery_img_valid_reg_en_ddd;
      if(temperature_write_data_valid == 1'b1) begin
          temperature_write_data_temp <= {temperature_write_data,temperature_write_data_temp[15:8]};
          temperature_mem_write_en    <= !temperature_mem_write_en;
          if(temperature_mem_write_en == 1'b1)begin
              TEMPERATURE_MEM[TEMPERATURE_MEM_WR_ADDR] <= {temperature_write_data,temperature_write_data_temp[15:8]};
              TEMPERATURE_MEM_WR_ADDR <= TEMPERATURE_MEM_WR_ADDR + 1;
          end
          else begin 
              TEMPERATURE_MEM_WR_ADDR <= TEMPERATURE_MEM_WR_ADDR;
          end   
          temperature_rd_data_valid <= 1'b0;
      end      
      else if(temperature_rd_rq == 1'b1)begin
           temperature_rd_data       <= TEMPERATURE_MEM[TEMPERATURE_MEM_RD_ADDR];
           temperature_rd_data_valid <= 1'b1;
           TEMPERATURE_MEM_RD_ADDR   <= TEMPERATURE_MEM_RD_ADDR + 1;
      end
      else if(temperature_wr_rq == 1'b1)begin
            TEMPERATURE_MEM[temperature_wr_addr]<=  STORE_TEMP_AVG_FRAME;           
            temperature_rd_data_valid <= 1'b0;
      end      
      else if(update_gallery_img_valid_reg_en == 1'b1)begin
            TEMPERATURE_MEM[123]<=  {update_gallery_img_valid_reg[7:0],8'd0};                  
      end
      else if(update_gallery_img_valid_reg_en_d == 1'b1)begin
            TEMPERATURE_MEM[124]<=  update_gallery_img_valid_reg[23:8]; 
      end
      else if(update_gallery_img_valid_reg_en_dd == 1'b1)begin
            TEMPERATURE_MEM[125]<=  update_gallery_img_valid_reg[39:24]; 
      end
      else if(update_gallery_img_valid_reg_en_ddd == 1'b1)begin
            TEMPERATURE_MEM[126]<=  update_gallery_img_valid_reg[55:40]; 
      end
      else if(update_gallery_img_valid_reg_en_dddd == 1'b1)begin
            TEMPERATURE_MEM[127]<=  update_gallery_img_valid_reg[71:56]; 
      end      
      else begin      
            temperature_rd_data_valid <= 1'b0;
      end
   end   
end 



// Polynomial Block instantiation
offset_poly offset_poly_inst(
	.clk(clk),    // Clock
	.rst(rst),  // Asynchronous reset active high
	.en_nuc_1pt_mode2(en_nuc_1pt_mode2),

	// Master AVALON interface for fetching and storing tables
	.av_ready(av_ready),
	.av_read(av_read),
	.av_write(av_write),
	.av_wrburst(av_wrburst),
	.av_size(av_size),
	.av_address(av_address),
	.av_writedata(av_writedata),
	.av_wrbe(),
	.av_rddatavalid(av_rddatavalid),
	.av_readdata(av_readdata),

	// Avalon slave interface for control of the module
	.avl_waitrequest(avl1_waitrequest),
	.avl_write(avl1_write),
	.avl_writedata(avl1_writedata),
	.avl_address(avl1_address),
	.avl_read(avl1_read),
	.avl_readdatavalid(avl1_readdatavalid),
	.avl_readdata(avl1_readdata)
	
);

//  NUC module instantiation
NUC_SIMPLE #(
 	.bit_width(bit_width),
    .PIX_BITS(10),
    .LIN_BITS(10),
    .VIDEO_YSIZE(VIDEO_YSIZE),
    .VIDEO_XSIZE(VIDEO_XSIZE),
    .DMA_SIZE_BITS(SIZE_BITS),
    .RD_SIZE(32)
   ) nuc_simple_inst (
   	.CLK(clk), 
	.RST(rst),

	.AVL_WAITREQUEST(avl2_waitrequest),
	.AVL_WRREQ(avl2_write) ,
	.AVL_RDREQ(avl2_read) ,
	.AVL_ADDR(avl2_address) ,
	.AVL_WRDATA(avl2_writedata),
	.AVL_RDDAV(avl2_readdatavalid) ,
	.AVL_RDDATA(avl2_readdata),

	.VIDEO_I_V(video_i_v),   
	.VIDEO_I_H(video_i_h),   
	.VIDEO_I_EOI(video_i_eoi), 
	.VIDEO_I_DAV(video_i_dav), 
	.VIDEO_I_DATA(video_i_data),

	.DMA1_RDREADY(dma1_rdready), 
	.DMA1_RDREQ(dma1_rdreq),   
	.DMA1_RDSIZE(dma1_rdsize),  
	.DMA1_RDADDR(dma1_rdaddr),  
	.DMA1_RDDAV(dma1_rddav),   
	.DMA1_RDDATA(dma1_rddata),  

	.DMA2_RDREADY(dma2_rdready),
	.DMA2_RDREQ(dma2_rdreq),
	.DMA2_RDSIZE(dma2_rdsize),
	.DMA2_RDADDR(dma2_rdaddr),
	.DMA2_RDDAV(dma2_rddav),
	.DMA2_RDDATA(dma2_rddata),

	.VIDEO_O_V(video_o_v),   
	.VIDEO_O_H(video_o_h),   
	.VIDEO_O_EOI(video_o_eoi), 
	.VIDEO_O_DAV(video_o_dav), 
	.VIDEO_O_DATA(video_o_data),
	.VIDEO_O_BAD(video_o_bad)
   );

// Controller FSM
// We will start calculation of offset at the starting of a frame
// Meanwhile, we will set height, width , burst size, wait count etc.
// Also, we will set the addresses of C1, C2, C3 and OFFSET matrices based
// on temperature 

(* mark_debug = "true" *)reg [4:0] control_fsm;
(* mark_debug = "true" *)reg [4:0] control_fsm_cb;

reg start_offset_calc;
//reg calc_done;
//reg calc_busy;

reg [15:0] temp_data_reg;
reg [15:0] temp_data_reg1;

reg [4:0] temp_region = 0;

// We will store different addresses of c1,c2,c3 for different temperature regions
reg [31:0] c1_address[0:15];
reg [31:0] c2_address[0:15];
reg [31:0] c3_address[0:15];

// We will store the offsets in ping pong frame buffer
wire [31:0] off_address[0:1];
wire [31:0] off_address_1pt; // 1pt NUC offset address

wire [31:0] img_corr_addr;

wire [31:0] gain_address;

reg [31:0] ADDR_OFFM_COEFF_C1;
reg [31:0] ADDR_OFFM_COEFF_C2;
reg [31:0] ADDR_OFFM_COEFF_C3;
reg [31:0] ADDR_GAINM;
reg [2:0]  temp_range;
reg sel_temp_range0_flag;
reg sel_temp_range1_flag;
reg sel_temp_range2_flag;
reg sel_temp_range3_flag;
reg sel_temp_range4_flag;
reg sel_temp_range5_flag;
reg sel_temp_range6_flag;
reg range0_flag;
reg range1_flag;
reg range2_flag;
reg range3_flag;
reg range4_flag;
reg range5_flag;
reg range6_flag;




assign off_address[0] 	= ADDR_OFFM_PING;
assign off_address[1] 	= ADDR_OFFM_PONG;
assign off_address_1pt 	= ADDR_OFFM_NUC1PT;
//assign gain_address 	= ADDR_GAINM_START;
assign gain_address     = ADDR_GAINM;

assign img_corr_addr    = ADDR_OFFM_NUC1PTM2;



(* mark_debug = "true" *)reg frame_buffer_num;

(* mark_debug = "true" *)reg [7:0] number_frames_elapsed;



localparam s_idle = 'd0,
			s_set_param = 'd1,
			s_set_video_size = 'd2,
			s_set_temp_data = 'd3,
			s_set_c1_addr = 'd4,
			s_set_c2_addr = 'd5,
			s_set_c3_addr = 'd6,
			s_set_off_addr = 'd7,
			s_send_trigger = 'd8,
			s_wait_done = 'd9,
			s_wait_done_check = 'd10,
			s_set_img_corr_addr = 'd11;

// control fsm for offset_polynomial module
always @(posedge clk or posedge rst) begin : proc_control_fsm
	if(rst) begin
		control_fsm <= s_idle;
		control_fsm_cb <= s_idle;
//		temp_data_reg <= 0;
		number_frames_elapsed <= 0;
		calc_done 	<= 1'b1;
		calc_busy 	<= 1'b0;

		avl1_address <= 0;
		avl1_writedata <= 0;
		avl1_write <= 0;
		avl1_read <= 0;

	end else begin
		case (control_fsm)
			s_idle: begin 
				if(start_offset_calc) begin 
					calc_done <= 1'b0;
					calc_busy <= 1'b1;
					number_frames_elapsed <= 0;
//					temp_data_reg <= temp_data;
					control_fsm <= s_set_param;
				end
			end
			s_set_param: begin 
				control_fsm <= s_set_video_size;
			end
			s_set_video_size: begin 
				avl1_address <= 8;
				avl1_writedata <= ((VIDEO_YSIZE & 16'hFFFF) << 16) | (VIDEO_XSIZE & 16'hFFFF);
				avl1_write <= 1'b1;

				control_fsm <= s_set_temp_data;
			end
			s_set_temp_data: begin 
				if(!avl1_waitrequest) begin 
					avl1_address <= 5;
					avl1_writedata <= temp_data_reg;
					avl1_write <= 1'b1;
					control_fsm <= s_set_c1_addr;	
				end
			end
			s_set_c1_addr: begin 
				if(!avl1_waitrequest) begin 
					avl1_address <= 1;
					// avl1_writedata <= c1_address[temp_region];
//					avl1_writedata <= ADDR_OFFM_COEFF_C1_TEMP_1;//ADDR_C1_MAT;
                    avl1_writedata <= ADDR_OFFM_COEFF_C1;
					avl1_write <= 1'b1;
					control_fsm <= s_set_c2_addr;
				end
			end
			s_set_c2_addr: begin
				if(!avl1_waitrequest) begin 
					avl1_address <= 2;
					// avl1_writedata <= c2_address[temp_region];
//					avl1_writedata <= ADDR_OFFM_COEFF_C2_TEMP_1;//ADDR_C2_MAT;
                    avl1_writedata <= ADDR_OFFM_COEFF_C2;
					avl1_write <= 1'b1;
					control_fsm <= s_set_c3_addr;
				end
			end
			s_set_c3_addr: begin 
				if(!avl1_waitrequest) begin 
					avl1_address <= 3;
					// avl1_writedata <= c3_address[temp_region];
//					avl1_writedata <= ADDR_OFFM_COEFF_C3_TEMP_1;//ADDR_C3_MAT;
					avl1_writedata <= ADDR_OFFM_COEFF_C3;
					avl1_write <= 1'b1;
					control_fsm <= s_set_img_corr_addr;
				end
			end

			s_set_img_corr_addr: begin
				if(!avl1_waitrequest) begin 
					avl1_address <= 9;
					avl1_writedata <= img_corr_addr;
					avl1_write <= 1'b1;
					control_fsm <= s_set_off_addr;
				end
			end
			s_set_off_addr: begin 
				if(!avl1_waitrequest) begin 
					avl1_address <= 4;
					if(frame_buffer_num) begin 
						avl1_writedata <= off_address[1];
					end
					else begin 
						avl1_writedata <= off_address[0];
					end
					
					// avl1_writedata <= 32'h00c12000;
					avl1_write <= 1'b1;
					control_fsm <= s_send_trigger;
				end
			end
			s_send_trigger: begin 
				if(!avl1_waitrequest) begin 
					avl1_address <= 0;
					avl1_writedata <= {en_nuc_1pt_mode2, 1'b1};
					avl1_write <= 1'b1;
					control_fsm <= s_wait_done;
				end
			end
			s_wait_done: begin 
				if(!avl1_waitrequest) begin 
					avl1_write <= 0;
				end
				if(video_i_eoi) begin 
					avl1_address <= 0;
					avl1_read <= 1'b1;
					control_fsm <= s_wait_done_check;
				end
			end
			s_wait_done_check: begin 
				if(!avl1_waitrequest) begin 
					avl1_read <= 1'b0;
				end
				if(avl1_readdatavalid) begin  						// check if the offset calculation is done
					if(avl1_readdata[0]==1) begin
						// frame_buffer_num <= ~frame_buffer_num; 
						calc_done <= 1'b1;
						calc_busy <= 1'b0;
						control_fsm <= s_idle;
					end
					else begin 
						number_frames_elapsed <= number_frames_elapsed + 1;
						control_fsm <= s_wait_done;
					end
				end
			end
		
			default : /* default */control_fsm <= s_idle;
		endcase
		
	end
end

reg [3:0] nuc_control_fsm;
localparam 	s_nuc_idle = 'd0,
			s_nuc_set_offset_addr = 'd1,
			s_nuc_set_gain_addr = 'd2,
			s_nuc_unity_gain = 'd3,
			s_nuc_wait_done = 'd4;


// control fsm for nuc module
always @(posedge clk or posedge rst) begin : proc_nuc_control
	if(rst) begin
		nuc_control_fsm <= s_nuc_idle;
		start_offset_calc <= 0;
		frame_buffer_num <= 0;
		avl2_write <= 1'b0;
		avl2_writedata <= 0;
		avl2_address <= 0;
		avl2_read <= 1'b0;
		temp_data_reg  <= 0;
		temp_data_reg1 <= 0;
        temp_range     <= `TEMP_AREA_3;//3'b011;
        update_sensor_param <= 1'b0;
        update_sensor_param_level <= 1'b0;
        update_coarse_offset_level<= 1'b0;
        take_snapshot <= 1'b0;
        frame_cnt_btwn_area_change_and_snsr_update <= 16'd0;
        new_sensor_param_start_addr <= temp_range2_sensor_init_gfid_addr;//temp_range4_sensor_init_dbias_addr;
        ADDR_COARSE_OFFSET          <= ADDR_COARSE_OFFSET_3;
        LATCH_ADDR_COARSE_OFFSET    <= ADDR_COARSE_OFFSET_3;
        sel_temp_range0_flag <= 1'b0;
        sel_temp_range1_flag <= 1'b0;
        sel_temp_range2_flag <= 1'b0;
        sel_temp_range3_flag <= 1'b0;
        sel_temp_range4_flag <= 1'b0;
        sel_temp_range5_flag <= 1'b0;
        sel_temp_range6_flag <= 1'b0;
        range0_flag        <= 1'b0;
        range1_flag        <= 1'b0;
        range2_flag        <= 1'b0;
        range3_flag        <= 1'b0;
        range4_flag        <= 1'b0;
        range5_flag        <= 1'b0;
        range6_flag        <= 1'b0;
        CUR_TEMP_AREA      <= `TEMP_AREA_3;
        PREVIOUS_TEMP_AREA <= `TEMP_AREA_3;
        time_cnt           <= 0;
        time_cnt_auto_shutter <= 0;
        latch_auto_shutter_en <= 1'b0;
        temp_range_update_en <= 1'b0;
        power_on_temp_range_update_en <= 1'b1;
        switch_temp_offset_area <= 1'b0;
        area_switch_done <= 1'b0;
        low_to_high_temp_area_switch <= 1'b0;
        high_to_low_temp_area_switch <= 1'b0;
        
	end else begin
	    if(tick1s)begin
	       if(time_cnt >= temp_range_update_timeout)begin
	           time_cnt <= 0;
	           temp_range_update_en <= 1'b1;
	           power_on_temp_range_update_en <= 1'b0;
	       end
	       else begin
	           time_cnt <= time_cnt + 1;
//	           temp_range_update_en <= 1'b0;
	       end
	    end
	    else begin
//	       temp_range_update_en <= 1'b0;
	       time_cnt <= time_cnt;
	    end
	    if(tick1s && (latch_auto_shutter_en==1'b0))begin
	       if(time_cnt_auto_shutter >= auto_shutter_timeout)begin
	           time_cnt_auto_shutter <= 0;
	           latch_auto_shutter_en <= 1'b1;
	       end
	       else begin
	           time_cnt_auto_shutter <= time_cnt_auto_shutter + 1;
	       end	       
	    end

	  
    
	    update_sensor_param<= 1'b0;
	    take_snapshot <= 1'b0;
	    low_to_high_temp_area_switch <= 1'b0;
	    high_to_low_temp_area_switch <= 1'b0;
		case(nuc_control_fsm)
			s_nuc_idle: begin
			    temp_data_reg1     <= temp_data;
//		        if(temp_data > temp)begin
                if(temp_range_update_en || (power_on_temp_range_update_en && sensor_power_on_init_done))begin
//                if(temp_range_update_en)begin
                   temp_range_update_en <= 1'b0;
//                   if(temp_sense_offset == 4'hB)begin
                     if(switch_temp_offset_area == 0)begin
                        if(temp_data>= TEMPERATURE_MEM[6])begin 
                            temp_range <= `TEMP_AREA_6;//3'b110;
                        end    
                        else if(temp_data>= TEMPERATURE_MEM[5])begin
                            temp_range <= `TEMP_AREA_5;//3'b101;
                        end
                        else if(temp_data>= TEMPERATURE_MEM[4])begin
                            temp_range <= `TEMP_AREA_4;//3'b100;
                        end
                        else if(temp_data>= TEMPERATURE_MEM[3])begin
                            temp_range <= `TEMP_AREA_3;//3'b011;
                        end
                        else if(temp_data>= TEMPERATURE_MEM[2])begin
                            temp_range <= `TEMP_AREA_2;//3'b010;
                        end
                        else begin
                            switch_temp_offset_area <= 1;  
                            temp_range <= `TEMP_AREA_1; 
                        end
                    end    
//                    else if(temp_sense_offset == 4'h5)begin   
                    else if(switch_temp_offset_area == 1)begin
                        if(temp_data<= TEMPERATURE_MEM[0])begin
                            temp_range <= `TEMP_AREA_0;//3'b000;
                        end
                        else if(temp_data<= TEMPERATURE_MEM[1])begin   
                            temp_range <= `TEMP_AREA_1;//3'b001;
                        end
                        else begin 
                            switch_temp_offset_area <= 0; 
                            temp_range <= `TEMP_AREA_2;
                        end
                    end    
                 end   
		        temperature_diff_pos <= previous_temperature - temp_data;
		        temperature_diff_neg <= temp_data - previous_temperature;
//		        if(!calc_busy && calc_done && update_sensor_param_level)begin
//		          update_sensor_param         <= 1'b1;
//		          update_sensor_param_level   <= 1'b0;
//		        end

//                if(!calc_busy && calc_done && update_sensor_param_level)begin
//                      update_sensor_param         <= 1'b1;
//                      update_sensor_param_level   <= 1'b0;
//                      update_coarse_offset_level  <= 1'b1;
//                      ADDR_COARSE_OFFSET          <= LATCH_ADDR_COARSE_OFFSET;
//                      frame_cnt_btwn_area_change_and_snsr_update <= 0;
//                end			        
				if(video_i_eoi) begin 
				    if(update_sensor_param_level)begin
				        frame_cnt_btwn_area_change_and_snsr_update <= frame_cnt_btwn_area_change_and_snsr_update +1;
				    end
				    else begin
				        frame_cnt_btwn_area_change_and_snsr_update <= 0;
				    end
				    
		            if((!calc_busy && calc_done))begin
		              if(update_sensor_param_level && (MUX_NUC_MODE == 2'b01 || MUX_NUC_MODE == 2'b10) && (MUX_BLADE_MODE !=2'b00))begin
				        toggle_gpio          <= !toggle_gpio;
				        previous_temperature <= temp_data;
                      end
                      else if (latch_auto_shutter_en==1'b1 && (MUX_NUC_MODE == 2'b01 || MUX_NUC_MODE == 2'b10)&& (MUX_BLADE_MODE ==2'b10))begin
                        toggle_gpio          <= !toggle_gpio;
                        latch_auto_shutter_en<= 1'b0;
                        previous_temperature <= temp_data;
                      end
                      else if((MUX_NUC_MODE == 2'b01 || MUX_NUC_MODE == 2'b10)&& (MUX_BLADE_MODE ==2'b01))begin 
                          if(temperature_diff_pos[15]==0) begin 							// Check if its a positive or negative number
                              if(temperature_diff_pos > temperature_threshold) begin
                                toggle_gpio          <= !toggle_gpio;
                                previous_temperature <= temp_data;
                              end
                          end else begin
                              if(temperature_diff_neg > temperature_threshold) begin
                                toggle_gpio          <= !toggle_gpio;
                                previous_temperature <= temp_data;
                              end
                           end
                      end    
                    end  
                    

				    
//                    if(!calc_busy && calc_done && update_coarse_offset_level)begin
                    if(!calc_busy && calc_done && update_sensor_param_level)begin
                      update_sensor_param         <= 1'b1;
                      update_sensor_param_level   <= 1'b0;
//                      update_coarse_offset_level  <= 1'b0;
                      ADDR_COARSE_OFFSET          <= LATCH_ADDR_COARSE_OFFSET;
//                      frame_cnt_btwn_area_change_and_snsr_update <= 0;
                      take_snapshot <= 1'b1;
                      if (power_on_temp_range_update_en ==1'b0)begin
                          area_switch_done <= 1'b1;
                      end
                      PREVIOUS_TEMP_AREA <= CUR_TEMP_AREA;
                      if(CUR_TEMP_AREA > PREVIOUS_TEMP_AREA)begin
                        low_to_high_temp_area_switch <= 1'b1;
                        high_to_low_temp_area_switch <= 1'b0; 
                      end
                      else if(CUR_TEMP_AREA < PREVIOUS_TEMP_AREA)begin 
                        low_to_high_temp_area_switch <= 1'b0;
                        high_to_low_temp_area_switch <= 1'b1; 
                      end
                     
                    end				
				    temp_data_reg   <= temp_data_reg1;
					nuc_control_fsm <= s_nuc_set_offset_addr;
					avl2_address <= 0;
					avl2_write <= 1'b1;
					avl2_writedata <= en_nuc;
					if(!calc_busy && calc_done && en_nuc) begin
						frame_buffer_num <= ~frame_buffer_num;
					end
					// Trigger the offset polynomial calculation only when nuc is enabled and calculations 
					// of the previous iteration are done
					start_offset_calc <= !calc_busy && calc_done && en_nuc;
//					start_offset_calc <= 1'b0;
					if(force_temp_range_en == 1'b1)begin	
					   range0_flag        <= 1'b0;
                       range1_flag        <= 1'b0;
                       range2_flag        <= 1'b0;
                       range3_flag        <= 1'b0;
                       range4_flag        <= 1'b0;
                       range5_flag        <= 1'b0;
                       range6_flag        <= 1'b0;		
					   if(force_temp_range == `TEMP_AREA_6 && sel_temp_range6_flag == 1'b0)begin
					        sel_temp_range0_flag <= 1'b0;  
					        sel_temp_range1_flag <= 1'b0;  
					        sel_temp_range2_flag <= 1'b0;  
					        sel_temp_range3_flag <= 1'b0;  
					        sel_temp_range4_flag <= 1'b0;  
					        sel_temp_range5_flag <= 1'b0;  
					        sel_temp_range6_flag <= 1'b1;
//					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_G;
					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_6;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_3;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_3;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_3;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range3_sensor_init_gfid_addr;//temp_range6_sensor_init_dbias_addr;
					        CUR_TEMP_AREA        <= `TEMP_AREA_6;
					   end
					   else if(force_temp_range == `TEMP_AREA_5 && sel_temp_range5_flag == 1'b0)begin
					        sel_temp_range0_flag <= 1'b0;  
					        sel_temp_range1_flag <= 1'b0;  
					        sel_temp_range2_flag <= 1'b0;  
					        sel_temp_range3_flag <= 1'b0;  
					        sel_temp_range4_flag <= 1'b0;  
					        sel_temp_range5_flag <= 1'b1;  
					        sel_temp_range6_flag <= 1'b0;
//					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_F;
					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_5;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_3;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_3;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_3;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range3_sensor_init_gfid_addr;//temp_range5_sensor_init_dbias_addr;					   
					        CUR_TEMP_AREA        <= `TEMP_AREA_5; 
					   end
					   else if(force_temp_range == `TEMP_AREA_4 && sel_temp_range4_flag == 1'b0)begin
					        sel_temp_range0_flag <= 1'b0;  
					        sel_temp_range1_flag <= 1'b0;  
					        sel_temp_range2_flag <= 1'b0;  
					        sel_temp_range3_flag <= 1'b0;  
					        sel_temp_range4_flag <= 1'b1;  
					        sel_temp_range5_flag <= 1'b0;  
					        sel_temp_range6_flag <= 1'b0;
//					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_E;
					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_4;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_3;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_3;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_3;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range3_sensor_init_gfid_addr;//temp_range4_sensor_init_dbias_addr;					   
					        CUR_TEMP_AREA        <= `TEMP_AREA_4;
					   end
					   else if(force_temp_range == `TEMP_AREA_3 && sel_temp_range3_flag == 1'b0)begin
					        sel_temp_range0_flag <= 1'b0;  
					        sel_temp_range1_flag <= 1'b0;  
					        sel_temp_range2_flag <= 1'b0;  
					        sel_temp_range3_flag <= 1'b1;  
					        sel_temp_range4_flag <= 1'b0;  
					        sel_temp_range5_flag <= 1'b0;  
					        sel_temp_range6_flag <= 1'b0;
//					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_D;
                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_3;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_3;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_3;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range3_sensor_init_gfid_addr;//temp_range3_sensor_init_dbias_addr;					   
					        CUR_TEMP_AREA        <= `TEMP_AREA_3;
					   end
					   else if(force_temp_range == `TEMP_AREA_2 && sel_temp_range2_flag == 1'b0)begin
					        sel_temp_range0_flag <= 1'b0;  
					        sel_temp_range1_flag <= 1'b0;  
					        sel_temp_range2_flag <= 1'b1;  
					        sel_temp_range3_flag <= 1'b0;  
					        sel_temp_range4_flag <= 1'b0;  
					        sel_temp_range5_flag <= 1'b0;  
					        sel_temp_range6_flag <= 1'b0;
//					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_C;
					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;					        
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_2;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_2;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_2;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_2;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_2;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range2_sensor_init_gfid_addr;//temp_range2_sensor_init_dbias_addr;					   
					        CUR_TEMP_AREA        <= `TEMP_AREA_2;
					   end
					   else if(force_temp_range == `TEMP_AREA_1 && sel_temp_range1_flag == 1'b0)begin
					        sel_temp_range0_flag <= 1'b0;  
					        sel_temp_range1_flag <= 1'b1;  
					        sel_temp_range2_flag <= 1'b0;  
					        sel_temp_range3_flag <= 1'b0;  
					        sel_temp_range4_flag <= 1'b0;  
					        sel_temp_range5_flag <= 1'b0;  
					        sel_temp_range6_flag <= 1'b0;
//					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_B;
					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_1;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_1;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_1;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_1;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_1;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range1_sensor_init_gfid_addr;//temp_range1_sensor_init_dbias_addr;					   
					        CUR_TEMP_AREA        <= `TEMP_AREA_1;
					   end
					   else if(force_temp_range == `TEMP_AREA_0&& sel_temp_range0_flag == 1'b0)begin
					        sel_temp_range0_flag <= 1'b1;  
					        sel_temp_range1_flag <= 1'b0;  
					        sel_temp_range2_flag <= 1'b0;  
					        sel_temp_range3_flag <= 1'b0;  
					        sel_temp_range4_flag <= 1'b0;  
					        sel_temp_range5_flag <= 1'b0;  
					        sel_temp_range6_flag <= 1'b0;
					        ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_0;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_0;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_0;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_0;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_0;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range0_sensor_init_gfid_addr;//temp_range0_sensor_init_dbias_addr;					   
					        CUR_TEMP_AREA        <= `TEMP_AREA_0;
					   end
					
					end
					else if(!calc_busy && calc_done)begin
				        sel_temp_range0_flag <= 1'b0;  
					    sel_temp_range1_flag <= 1'b0;  
					    sel_temp_range2_flag <= 1'b0;  
					    sel_temp_range3_flag <= 1'b0;  
					    sel_temp_range4_flag <= 1'b0;  
					    sel_temp_range5_flag <= 1'b0;  
					    sel_temp_range6_flag <= 1'b0;
					
                        if(temp_range == `TEMP_AREA_6 && range6_flag == 1'b0)begin
                            range0_flag        <= 1'b0;
                            range1_flag        <= 1'b0;
                            range2_flag        <= 1'b0;
                            range3_flag        <= 1'b0;
                            range4_flag        <= 1'b0;
                            range5_flag        <= 1'b0;
                            range6_flag        <= 1'b1;
//                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_G;
                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_6;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_3;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_3;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_3;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range3_sensor_init_gfid_addr;//temp_range6_sensor_init_dbias_addr; 
                            CUR_TEMP_AREA        <= `TEMP_AREA_6;
//                            take_snapshot <= 1'b1;
                        end
                        else if(temp_range == `TEMP_AREA_5 && range5_flag == 1'b0)begin
                            range0_flag        <= 1'b0;
                            range1_flag        <= 1'b0;
                            range2_flag        <= 1'b0;
                            range3_flag        <= 1'b0;
                            range4_flag        <= 1'b0;
                            range5_flag        <= 1'b1;
                            range6_flag        <= 1'b0;                        
//                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_F;
                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_5;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_3;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_3;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_3; 
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range3_sensor_init_gfid_addr;//temp_range5_sensor_init_dbias_addr; 
                            CUR_TEMP_AREA        <= `TEMP_AREA_5;
//                            take_snapshot <= 1'b1;
                        end
                        else if(temp_range == `TEMP_AREA_4 && range4_flag == 1'b0)begin
                            range0_flag        <= 1'b0;
                            range1_flag        <= 1'b0;
                            range2_flag        <= 1'b0;
                            range3_flag        <= 1'b0;
                            range4_flag        <= 1'b1;
                            range5_flag        <= 1'b0;
                            range6_flag        <= 1'b0;                         
//                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_E;
                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_4;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_3;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_3;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_3; 
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range3_sensor_init_gfid_addr;//temp_range4_sensor_init_dbias_addr; 
                            CUR_TEMP_AREA        <= `TEMP_AREA_4;
//                            take_snapshot <= 1'b1;
                        end				    	
                        else if(temp_range == `TEMP_AREA_3 && range3_flag == 1'b0)begin
                            range0_flag        <= 1'b0;
                            range1_flag        <= 1'b0;
                            range2_flag        <= 1'b0;
                            range3_flag        <= 1'b1;
                            range4_flag        <= 1'b0;
                            range5_flag        <= 1'b0;
                            range6_flag        <= 1'b0;                         
//                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_D;
                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_3;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_3;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_3;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_3;  
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range3_sensor_init_gfid_addr;//temp_range3_sensor_init_dbias_addr; 
                            CUR_TEMP_AREA        <= `TEMP_AREA_3;
//                            take_snapshot <= 1'b1;
                        end					   
                        else if(temp_range == `TEMP_AREA_2 && range2_flag == 1'b0)begin
                            range0_flag        <= 1'b0;
                            range1_flag        <= 1'b0;
                            range2_flag        <= 1'b1;
                            range3_flag        <= 1'b0;
                            range4_flag        <= 1'b0;
                            range5_flag        <= 1'b0;
                            range6_flag        <= 1'b0;                        
//                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_C;
                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_2;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_2;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_2;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_2;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_2; 
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range2_sensor_init_gfid_addr;//temp_range2_sensor_init_dbias_addr;
                            CUR_TEMP_AREA        <= `TEMP_AREA_2; 
//                            take_snapshot <= 1'b1;
                        end				
                        else if(temp_range == `TEMP_AREA_1 && range1_flag == 1'b0)begin
                            range0_flag        <= 1'b0;
                            range1_flag        <= 1'b1;
                            range2_flag        <= 1'b0;
                            range3_flag        <= 1'b0;
                            range4_flag        <= 1'b0;
                            range5_flag        <= 1'b0;
                            range6_flag        <= 1'b0;                        
//                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_B;
                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_1;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_1;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_1;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_1;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_1; 
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range1_sensor_init_gfid_addr;//temp_range1_sensor_init_dbias_addr; 
                            CUR_TEMP_AREA        <= `TEMP_AREA_1;
//                            take_snapshot <= 1'b1;
                        end	
                        else if(temp_range == `TEMP_AREA_0 && range0_flag == 1'b0)begin
                            range0_flag        <= 1'b1;
                            range1_flag        <= 1'b0;
                            range2_flag        <= 1'b0;
                            range3_flag        <= 1'b0;
                            range4_flag        <= 1'b0;
                            range5_flag        <= 1'b0;
                            range6_flag        <= 1'b0;                        
                            ADDR_GAINM         <= ADDR_GAIN_BADPIX_A;
//                            ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_0;
                            LATCH_ADDR_COARSE_OFFSET <= ADDR_COARSE_OFFSET_0;
                            ADDR_OFFM_COEFF_C1 <= ADDR_OFFM_COEFF_C1_TEMP_0;
                            ADDR_OFFM_COEFF_C2 <= ADDR_OFFM_COEFF_C2_TEMP_0;
                            ADDR_OFFM_COEFF_C3 <= ADDR_OFFM_COEFF_C3_TEMP_0;
//                            update_sensor_param         <= 1'b1;
                            update_sensor_param_level   <= 1'b1;
                            new_sensor_param_start_addr <= temp_range0_sensor_init_gfid_addr;//temp_range0_sensor_init_dbias_addr; 
                            CUR_TEMP_AREA        <= `TEMP_AREA_0;
//                            take_snapshot <= 1'b1;
                        end					    
				   end
				end
				
			end
			s_nuc_set_offset_addr: begin 
				if(!avl2_waitrequest) begin 
					start_offset_calc <=0;
					nuc_control_fsm <= s_nuc_set_gain_addr;
					avl2_address <= 4;
					if(en_nuc_1pt) begin
						avl2_writedata <= off_address_1pt;
					end else begin
						// if(start_offset_calc) begin
							if(frame_buffer_num) begin
								avl2_writedata <= off_address[0];	
							end
							else begin 
								avl2_writedata <= off_address[1];	
							end
						// end
					end
					avl2_write 	<= 1'b1;
				end
			end
			s_nuc_set_gain_addr: begin 
				if(!avl2_waitrequest) begin 
					avl2_address <= 3;
					avl2_writedata <= gain_address;
					avl2_write 	<= 1'b1;
					nuc_control_fsm <= s_nuc_unity_gain;
				end
			end
			s_nuc_unity_gain: begin 
				if(!avl2_waitrequest) begin 
					avl2_address <= 2;
					avl2_writedata <= en_unity_gain;
					avl2_write <= 1'b1;
					nuc_control_fsm <= s_nuc_wait_done;
				end
			end
			s_nuc_wait_done: begin 
				if(!avl2_waitrequest) begin 
					nuc_control_fsm <= s_nuc_idle;
				end
			end

			default: nuc_control_fsm <= s_nuc_idle;
		endcase
	end
end

`ifdef ILA_OFFSET_POLY

wire [127:0] probe0;
TOII_TUVE_ila ila_offset(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {12'd0,
//                 ADDR_GAINM ,        
//                 ADDR_COARSE_OFFSET,
//                 ADDR_OFFM_COEFF_C1,
//                 ADDR_OFFM_COEFF_C2,
//                 ADDR_OFFM_COEFF_C3,
                 range0_flag,
                 range1_flag,
                 range2_flag,
                 range3_flag,
                 range4_flag,
                 range5_flag,
                 range6_flag,
                 sel_temp_range0_flag,
                 sel_temp_range1_flag,
                 sel_temp_range2_flag,
                 sel_temp_range3_flag,
                 sel_temp_range4_flag,
                 sel_temp_range5_flag,
                 sel_temp_range6_flag,
                 CUR_TEMP_AREA,update_sensor_param,force_temp_range,force_temp_range_en,en_unity_gain,en_nuc_1pt, temp_range,number_frames_elapsed, control_fsm, frame_buffer_num, en_nuc, av_ready, av_address, av_read, av_wrburst, av_write, av_size, av_rddatavalid, video_i_v,
				 start_offset_calc, nuc_control_fsm, calc_busy, calc_done,
				 update_sensor_param_level,
				 video_i_v,
				 video_i_h,
				 video_i_eoi,
				 video_i_dav,
				 frame_cnt_btwn_area_change_and_snsr_update,
				 update_coarse_offset_level,
				 video_o_v,
				 video_o_eoi,
				 video_o_h,
				 video_o_dav,
				 area_switch_done,
				 low_to_high_temp_area_switch,
				 high_to_low_temp_area_switch,
				 PREVIOUS_TEMP_AREA};


`endif


endmodule : nuc_controller