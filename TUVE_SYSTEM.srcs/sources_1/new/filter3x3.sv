`timescale 1ns/1ps

module filter3x3
	#(
		parameter SHARP_EDGE = 0, 
               bitwidth = 14,
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

	output reg video_o_v,	
	output reg video_o_h,	
	output reg video_o_eoi,	
	output     video_o_dav,	
	output     [bitwidth-1:0]video_o_data
);



// Address decode and control the modules
reg enable_filter;
reg enable_edge_filter;
reg enable_fixed_kernel;

reg signed [4:0] sharp_scale;

reg signed [bitwidth:0] threshold_value;

// reg signed [15:0] kernel_temp;
// reg [3:0] transfer_kernel;

assign av_busy = 1'b0;
always_ff @(posedge clk or posedge rst) begin : proc_decode_input
   if(rst) begin
      enable_filter <= 0;
      enable_edge_filter <= 0;
      enable_fixed_kernel <= 0;
      threshold_value <= 10;
      sharp_scale <= 2;
   end else begin
      if(av_wr) begin 
         case (av_addr)
            0  : begin 
                  enable_filter <= av_data[0];
                  enable_edge_filter <= av_data[1];
                  enable_fixed_kernel <= av_data[2];
               end
            1  : begin 
                  threshold_value <= av_data[bitwidth-1:0];
               end
            2  : begin 
                  sharp_scale <= av_data[3:0];
               end 

            // 3  : begin 
            //       transfer_kernel <= av_data[3:0];
            //    end
            // 4  : kernel_temp[0][0] <= av_data;
            // 5  : kernel_temp[0][1] <= av_data;
            // 6  : kernel_temp[0][2] <= av_data;
            // 7  : kernel_temp[1][0] <= av_data;
            // 8  : kernel_temp[1][1] <= av_data;
            // 9  : kernel_temp[1][2] <= av_data;
            // 10 : kernel_temp[2][0] <= av_data;
            // 11 : kernel_temp[2][1] <= av_data;
            // 12 : kernel_temp[2][2] <= av_data;

            default : /* default */;
         endcase
      end
   end
end


// Register these signals at the output
reg enable_edge_filter_reg;
reg enable_fixed_kernel_reg; 
reg enable_filter_reg;

reg fifo0_rd_force; 
reg fifo_rd_wr_enable;

reg [PIX_BITS-1:0] xcounter_in;
reg [LIN_BITS-1:0] ycounter_in;

wire fifo0_almost_empty;
wire fifo0_almost_full;
wire fifo0_data_valid;
wire fifo0_empty;
wire fifo0_full;
wire fifo0_overflow;
wire fifo0_underflow;
wire fifo0_prog_empty;
wire fifo0_prog_full;
wire fifo0_rd_rst_busy;
wire fifo0_wr_rst_busy;

wire [bitwidth-1:0] fifo0_dout;
wire [PIX_BITS:0] fifo0_rd_data_count;
wire [PIX_BITS:0] fifo0_wr_data_count;

reg fifo0_rd_en;
// wire fifo0_rd_en = fifo0_prog_full && fifo_rd_wr_enable; // | fifo0_rd_force;

wire fifo0_wr_en = video_i_dav && fifo_rd_wr_enable;

wire [bitwidth-1:0]fifo0_din = video_i_data;



always_ff @(posedge clk or posedge rst) begin : proc_fifo_rd_wr_enable
   if(rst) begin
      fifo_rd_wr_enable <= 1'b0;
   end else begin
      if(fifo0_wr_rst_busy==1'b0 && fifo0_rd_rst_busy==1'b0 && video_i_v==1'b1 && fifo_rd_wr_enable==1'b0) begin
         fifo_rd_wr_enable <= 1'b1;
      end
   end
end

xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(2**(PIX_BITS+1)),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(4),    // DECIMAL
      .PROG_FULL_THRESH(VIDEO_XSIZE),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(PIX_BITS+1),   // DECIMAL
      .READ_DATA_WIDTH(bitwidth),      // DECIMAL
      .READ_MODE("std"),         // String
      .USE_ADV_FEATURES("1707"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(bitwidth),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(PIX_BITS+1)    // DECIMAL
   )
   xpm_fifo_line_buffer0 (
      .almost_empty(fifo0_almost_empty),
      .almost_full(fifo0_almost_full),
      .data_valid(fifo0_data_valid),
      .dbiterr(),
      .dout(fifo0_dout),
      .empty(fifo0_empty),
      .full(fifo0_full),
      .overflow(fifo0_overflow),
      .prog_empty(fifo0_prog_empty),
      .prog_full(fifo0_prog_full),
      .rd_data_count(fifo0_rd_data_count),
      .rd_rst_busy(fifo0_rd_rst_busy),
      .sbiterr(),
      .underflow(fifo0_underflow),
      .wr_ack(),
      .wr_data_count(fifo0_wr_data_count),
      .wr_rst_busy(fifo0_wr_rst_busy),
      .din(fifo0_din),
      .injectdbiterr(1'b0),
      .injectsbiterr(1'b0),
      .rd_en(fifo0_rd_en),
      .rst(rst),
      .sleep(1'b0),
      .wr_clk(clk),
      .wr_en(fifo0_wr_en)
   );

wire fifo1_almost_empty;
wire fifo1_almost_full;
wire fifo1_data_valid;
wire fifo1_empty;
wire fifo1_full;
wire fifo1_overflow;
wire fifo1_underflow;
wire fifo1_prog_empty;
wire fifo1_prog_full;
wire fifo1_rd_rst_busy;
wire fifo1_wr_rst_busy;

wire [bitwidth-1:0] fifo1_dout;
wire [PIX_BITS:0] fifo1_rd_data_count;
wire [PIX_BITS:0] fifo1_wr_data_count;


reg fifo1_rd_en;
// wire fifo1_rd_en = fifo1_prog_full && fifo_rd_wr_enable; // | fifo0_rd_force;

wire fifo1_wr_en = fifo0_data_valid && fifo_rd_wr_enable;

wire [bitwidth-1:0]fifo1_din = fifo0_dout;


xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(2**PIX_BITS),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(4),    // DECIMAL
      .PROG_FULL_THRESH(VIDEO_XSIZE),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(PIX_BITS+1),   // DECIMAL
      .READ_DATA_WIDTH(bitwidth),      // DECIMAL
      .READ_MODE("std"),         // String
      .USE_ADV_FEATURES("1707"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(bitwidth),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(PIX_BITS+1)    // DECIMAL
   )
   xpm_fifo_line_buffer1 (
      .almost_empty(fifo1_almost_empty),
      .almost_full(fifo1_almost_full),
      .data_valid(fifo1_data_valid),
      .dbiterr(),
      .dout(fifo1_dout),
      .empty(fifo1_empty),
      .full(fifo1_full),
      .overflow(fifo1_overflow),
      .prog_empty(fifo1_prog_empty),
      .prog_full(fifo1_prog_full),
      .rd_data_count(fifo1_rd_data_count),
      .rd_rst_busy(fifo1_rd_rst_busy),
      .sbiterr(),
      .underflow(fifo1_underflow),
      .wr_ack(),
      .wr_data_count(fifo1_wr_data_count),
      .wr_rst_busy(fifo1_wr_rst_busy),
      .din(fifo1_din),
      .injectdbiterr(1'b0),
      .injectsbiterr(1'b0),
      .rd_en(fifo1_rd_en),
      .rst(rst),
      .sleep(1'b0),
      .wr_clk(clk),
      .wr_en(fifo1_wr_en)
   );

wire fifo2_almost_empty;
wire fifo2_almost_full;
wire fifo2_data_valid;
wire fifo2_empty;
wire fifo2_full;
wire fifo2_overflow;
wire fifo2_underflow;
wire fifo2_prog_empty;
wire fifo2_prog_full;
wire fifo2_rd_rst_busy;
wire fifo2_wr_rst_busy;

wire [bitwidth-1:0] fifo2_dout;
wire [PIX_BITS:0] fifo2_rd_data_count;
wire [PIX_BITS:0] fifo2_wr_data_count;


reg fifo2_rd_en;
// wire fifo1_rd_en = fifo1_prog_full && fifo_rd_wr_enable; // | fifo0_rd_force;

wire fifo2_wr_en = fifo1_data_valid && fifo_rd_wr_enable;

wire [bitwidth-1:0]fifo2_din = fifo1_dout;


xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(2**PIX_BITS),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(4),    // DECIMAL
      .PROG_FULL_THRESH(VIDEO_XSIZE),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(PIX_BITS+1),   // DECIMAL
      .READ_DATA_WIDTH(bitwidth),      // DECIMAL
      .READ_MODE("std"),         // String
      .USE_ADV_FEATURES("1707"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(bitwidth),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(PIX_BITS+1)    // DECIMAL
   )
   xpm_fifo_line_buffer2 (
      .almost_empty(fifo2_almost_empty),
      .almost_full(fifo2_almost_full),
      .data_valid(fifo2_data_valid),
      .dbiterr(),
      .dout(fifo2_dout),
      .empty(fifo2_empty),
      .full(fifo2_full),
      .overflow(fifo2_overflow),
      .prog_empty(fifo2_prog_empty),
      .prog_full(fifo2_prog_full),
      .rd_data_count(fifo2_rd_data_count),
      .rd_rst_busy(fifo2_rd_rst_busy),
      .sbiterr(),
      .underflow(fifo2_underflow),
      .wr_ack(),
      .wr_data_count(fifo2_wr_data_count),
      .wr_rst_busy(fifo2_wr_rst_busy),
      .din(fifo2_din),
      .injectdbiterr(1'b0),
      .injectsbiterr(1'b0),
      .rd_en(fifo2_rd_en),
      .rst(rst),
      .sleep(1'b0),
      .wr_clk(clk),
      .wr_en(fifo2_wr_en)
   );

   reg [4-1:0] fifo_rd_fsm;

   localparam s_idle = 4'd0,
               s_fill_fifo0 = 4'd1,
               s_fill_fifo1 = 4'd2,
               s_fill_up_window = 4'd3,
               s_push_out_pixels0 = 4'd4,
               s_push_out_pixels1 = 4'd5,
               s_push_out_pixels2 = 4'd6,
               s_push_out_pixels3 = 4'd7;


   reg [PIX_BITS-1:0] xcounter_fifo;
   reg [LIN_BITS-1:0] ycounter_fifo;
   reg start_read;

   reg start_read_f0;
   reg start_read_f1;
   reg start_read_f2;

   reg start_read_f0_level;
   reg start_read_f1_level;
   reg start_read_f2_level;

   reg [PIX_BITS-1:0] fifo0_count;
   reg [PIX_BITS-1:0] fifo1_count;
   reg [PIX_BITS-1:0] fifo2_count;

   always_ff @(posedge clk or posedge rst) begin : proc_read_fifos
      if(rst) begin
         fifo0_rd_en <= 1'b0;
         fifo1_rd_en <= 1'b0;
         fifo2_rd_en <= 1'b0;
         start_read <= 1'b0;
         xcounter_fifo <= 0;
         ycounter_fifo <= 0;

         start_read_f0 <= 1'b0;
         start_read_f1 <= 1'b0;
         start_read_f2 <= 1'b0;

         start_read_f0_level <= 1'b0;
         start_read_f1_level <= 1'b0;
         start_read_f2_level <= 1'b0;

         fifo0_count <= 0;
         fifo1_count <= 0;
         fifo2_count <= 0;

         fifo_rd_fsm <= s_idle;
      end else begin
         fifo0_rd_en <= 1'b0;
         fifo1_rd_en <= 1'b0;
         fifo2_rd_en <= 1'b0;

         start_read_f0 <= 1'b0;
         start_read_f1 <= 1'b0;
         start_read_f2 <= 1'b0;

         if(start_read_f0) begin
            start_read_f0_level <=1'b1;
            fifo0_count <= 0; 
         end   

         if(start_read_f0_level) begin
            fifo0_rd_en <= 1'b1;
            fifo0_count <= fifo0_count + 1;
            if(fifo0_count==VIDEO_XSIZE) begin
               fifo0_rd_en <= 1'b0;
               fifo0_count <= 0;
               start_read_f0_level <= 1'b0;
            end 
         end

         if(start_read_f1) begin
            start_read_f1_level <=1'b1;
            fifo1_count <= 0; 
         end

         if(start_read_f1_level) begin
            fifo1_rd_en <= 1'b1;
            fifo1_count <= fifo1_count + 1;
            if(fifo1_count==VIDEO_XSIZE) begin
               fifo1_rd_en <= 1'b0;
               fifo1_count <= 0;
               start_read_f1_level <= 1'b0;
            end 
         end

         if(start_read_f2) begin
            start_read_f2_level <=1'b1;
            fifo2_count <= 0; 
         end   

         if(start_read_f2_level) begin
            fifo2_rd_en <= 1'b1;
            fifo2_count <= fifo2_count + 1;
            if(fifo2_count==VIDEO_XSIZE) begin
               fifo2_rd_en <= 1'b0;
               fifo2_count <= 0;
               start_read_f2_level <= 1'b0;
            end 
         end

         case (fifo_rd_fsm)
            s_idle: begin
               // if(video_i_v) begin
               if(fifo0_prog_full && start_read_f0_level==0) begin 
                  start_read_f0 <= 1'b1;
                  ycounter_fifo <= 0;
                  fifo_rd_fsm <= s_fill_fifo0;
               end
            end
            s_fill_fifo0: begin 
               if(fifo0_prog_full && fifo1_prog_full && start_read_f0_level==0 && start_read_f1_level==0) begin
                  start_read_f0 <= 1'b1;
                  start_read_f1 <= 1'b1;
                  ycounter_fifo <= ycounter_fifo + 1;
                  fifo_rd_fsm <= s_fill_fifo1;
               end
            end
            s_fill_fifo1: begin
               if(fifo0_prog_full && fifo1_prog_full && fifo2_prog_full && start_read_f0_level==0 && start_read_f1_level==0 && start_read_f2_level==0) begin
                  start_read_f0 <= 1'b1;
                  start_read_f1 <= 1'b1;
                  start_read_f2 <= 1'b1;
                  ycounter_fifo <= ycounter_fifo + 1;
                  fifo_rd_fsm <= s_fill_up_window;
               end
            end
            s_fill_up_window: begin 
               if(start_read_f0_level==0 && start_read_f1_level==0 && start_read_f2_level==0) begin
                  if(ycounter_fifo<VIDEO_YSIZE-1) begin
                     fifo_rd_fsm <= s_fill_fifo1;
                  end else begin
                     fifo_rd_fsm <= s_push_out_pixels1;
                  end
               end
            end

            s_push_out_pixels0: begin
               if(start_read_f0_level==0 && start_read_f1_level==0 && start_read_f2_level==0) begin 
                  start_read_f0 <= 1'b1;
                  start_read_f1 <= 1'b1;
                  start_read_f2 <= 1'b1;
                  fifo_rd_fsm <= s_push_out_pixels1;
               end 
            end
            s_push_out_pixels1: begin
               if(start_read_f1_level==0 && start_read_f2_level==0) begin 
                  start_read_f1 <= 1'b1;
                  start_read_f2 <= 1'b1;
                  start_read <= 1'b0;
                  fifo_rd_fsm <= s_push_out_pixels2;
               end
               if(fifo0_prog_full && start_read==0 && start_read_f0_level==0) begin
                  start_read <= 1'b1;
                  start_read_f0 <= 1'b1;
                  ycounter_fifo <= 0;
               end 
            end
            s_push_out_pixels2: begin 
               if(start_read_f2==0 && start_read_f2_level==0) begin 
                  start_read_f2 <= 1'b1;
                  start_read <= 1'b0;
                  fifo_rd_fsm <= s_push_out_pixels3;
               end 
               if(fifo1_prog_full && fifo0_prog_full && start_read==0 && start_read_f0_level==0 && start_read_f1_level==0) begin
                  start_read <= 1'b1;
                  start_read_f0 <= 1'b1;
                  start_read_f1 <= 1'b1;
                  ycounter_fifo <= ycounter_fifo + 1;
               end 
               else if(fifo0_prog_full && start_read==0 && start_read_f0_level==0) begin
                  start_read <= 1'b1;
                  start_read_f0 <= 1'b1;
                  ycounter_fifo <= 0;
               end
            end
            s_push_out_pixels3: begin 
               // if(start_read_f2==0 && start_read_f2_level==0) begin
                  if(fifo1_prog_full && fifo0_prog_full && start_read_f0_level==0 && start_read_f1_level==0) begin
                     start_read_f0 <= 1'b1;
                     start_read_f1 <= 1'b1;
                     ycounter_fifo <= ycounter_fifo + 1;
                     fifo_rd_fsm <= s_fill_fifo1;
                  end 
                  else if(fifo0_prog_full && start_read_f0_level==0) begin
                     start_read_f0 <= 1'b1;
                     ycounter_fifo <= 0;
                     fifo_rd_fsm <= s_fill_fifo0;
                  end
                  else begin
                     fifo_rd_fsm <= s_idle;
                  end
               // end
            end
            default : /* default */;
         endcase
      end
   end

wire [bitwidth-1:0] video_data_lb0 = fifo0_dout;
wire [bitwidth-1:0] video_data_lb1 = fifo1_dout;
wire [bitwidth-1:0] video_data_lb2 = fifo2_dout;

wire video_lb0_dav = fifo0_data_valid;
wire video_lb1_dav = fifo1_data_valid;
wire video_lb2_dav = fifo2_data_valid;


always_ff @(posedge clk or posedge rst) begin : proc_counters
   if(rst) begin
      xcounter_in <= 0;
      ycounter_in <= 0;
   end else begin
      if(video_i_dav) begin 
         xcounter_in <= xcounter_in + 1;
         if(xcounter_in==VIDEO_XSIZE-1) begin 
            xcounter_in <= 0;
            ycounter_in <= ycounter_in+1;
            if(ycounter_in==VIDEO_YSIZE-1) begin 
               ycounter_in <= 0;
            end
         end
      end
   end
end

reg [bitwidth-1:0] img_window[0:2][0:2]; 

reg [PIX_BITS-1:0] xcounter_window;
reg [LIN_BITS-1:0] ycounter_window;

reg video_lb1_dav_d;
always_ff @(posedge clk) begin : proc_video_lb1_dav
   video_lb1_dav_d <= video_lb1_dav;
end

reg img_window_dav;

always_ff @(posedge clk or posedge rst) begin : proc_populate_window
   if(rst) begin
      ycounter_window <= 0;
      xcounter_window <= 0;

      img_window_dav <= 0;

      for(int i=0;i<3;i++) begin
         for(int j=0;j<3;j++) begin
            img_window[i][j] <= 0;
         end
      end

   end else begin
      img_window_dav <= video_lb1_dav_d;
      if(start_read_f1) begin
         ycounter_window <= ycounter_window +1;
         if(ycounter_window==VIDEO_YSIZE) begin
            ycounter_window <= 1;
         end
      end
      if(fifo1_data_valid) begin
         xcounter_window <= xcounter_window + 1;
         if(xcounter_window==VIDEO_XSIZE-1) begin
            xcounter_window <= 0;
         end // if(xcounter_window==VIDEO_XSIZE-1
      end
      if(video_lb1_dav) begin
         if(ycounter_window==1) begin
            if(xcounter_window==0) begin
               img_window[0][0] <= video_data_lb0;    img_window[0][1] <= video_data_lb0;    img_window[0][2] <= img_window[0][1]; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= video_data_lb1;    img_window[1][2] <= img_window[1][1]; 
               img_window[2][0] <= video_data_lb0;    img_window[2][1] <= video_data_lb0;    img_window[2][2] <= img_window[2][1]; 
            end else if(xcounter_window==1) begin
               img_window[0][0] <= video_data_lb0;    img_window[0][1] <= img_window[0][0];    img_window[0][2] <= video_data_lb0; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= img_window[1][0];    img_window[1][2] <= video_data_lb1; 
               img_window[2][0] <= video_data_lb0;    img_window[2][1] <= img_window[2][0];    img_window[2][2] <= video_data_lb0; 
            end else begin
               img_window[0][0] <= video_data_lb0;    img_window[0][1] <= img_window[0][0];    img_window[0][2] <= img_window[0][1]; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= img_window[1][0];    img_window[1][2] <= img_window[1][1]; 
               img_window[2][0] <= video_data_lb0;    img_window[2][1] <= img_window[2][0];    img_window[2][2] <= img_window[2][1]; 
            end
         end
         else if(ycounter_window==VIDEO_YSIZE) begin
            if(xcounter_window==0) begin
               img_window[0][0] <= video_data_lb2;    img_window[0][1] <= video_data_lb2;    img_window[0][2] <= img_window[0][1]; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= video_data_lb1;    img_window[1][2] <= img_window[1][1]; 
               img_window[2][0] <= video_data_lb2;    img_window[2][1] <= video_data_lb2;    img_window[2][2] <= img_window[2][1]; 
            end else if(xcounter_window==1) begin
               img_window[0][0] <= video_data_lb2;    img_window[0][1] <= img_window[0][0];    img_window[0][2] <= video_data_lb2; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= img_window[1][0];    img_window[1][2] <= video_data_lb1; 
               img_window[2][0] <= video_data_lb2;    img_window[2][1] <= img_window[2][0];    img_window[2][2] <= video_data_lb2; 
            end else begin
               img_window[0][0] <= video_data_lb2;    img_window[0][1] <= img_window[0][0];    img_window[0][2] <= img_window[0][1]; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= img_window[1][0];    img_window[1][2] <= img_window[1][1]; 
               img_window[2][0] <= video_data_lb2;    img_window[2][1] <= img_window[2][0];    img_window[2][2] <= img_window[2][1]; 
            end
         end
         else if(ycounter_window>1) begin
            if(xcounter_window==0) begin
               img_window[0][0] <= video_data_lb2;    img_window[0][1] <= video_data_lb2;    img_window[0][2] <= img_window[0][1]; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= video_data_lb1;    img_window[1][2] <= img_window[1][1]; 
               img_window[2][0] <= video_data_lb0;    img_window[2][1] <= video_data_lb0;    img_window[2][2] <= img_window[2][1]; 
            end else if(xcounter_window==1) begin
               img_window[0][0] <= video_data_lb2;    img_window[0][1] <= img_window[0][0];    img_window[0][2] <= video_data_lb2; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= img_window[1][0];    img_window[1][2] <= video_data_lb1; 
               img_window[2][0] <= video_data_lb0;    img_window[2][1] <= img_window[2][0];    img_window[2][2] <= video_data_lb0; 
            end else begin
               img_window[0][0] <= video_data_lb2;    img_window[0][1] <= img_window[0][0];    img_window[0][2] <= img_window[0][1]; 
               img_window[1][0] <= video_data_lb1;    img_window[1][1] <= img_window[1][0];    img_window[1][2] <= img_window[1][1]; 
               img_window[2][0] <= video_data_lb0;    img_window[2][1] <= img_window[2][0];    img_window[2][2] <= img_window[2][1]; 
            end
         end
      end else if(video_lb1_dav==0 && video_lb1_dav_d==1) begin
         img_window[0][0] <= img_window[0][1];    img_window[0][1] <= img_window[0][0];    img_window[0][2] <= img_window[0][1]; 
         img_window[1][0] <= img_window[1][1];    img_window[1][1] <= img_window[1][0];    img_window[1][2] <= img_window[1][1]; 
         img_window[2][0] <= img_window[2][1];    img_window[2][1] <= img_window[2][0];    img_window[2][2] <= img_window[2][1];  
      end
   end
end


wire [bitwidth-1:0] fifo_din ;
wire fifo_wr_en;

generate
   if(SHARP_EDGE>=1) begin


/*
   Sobel kernels are integers 
   Gx = [-1,0,1]  Gy = [-1,-2,-1]
        [-2,0,2]       [ 0, 0, 0] 
        [-1,0,1]       [ 1, 2, 1]

   Fixed Unsharp mask kernel

   K = [-2,-2,-2]
       [-2,16,-2]
       [-2,-2,-2]
   Finally divide by 16

   Adaptive Unsharp mask kernel (https://homepages.inf.ed.ac.uk/rbf/HIPR2/unsharp.htm)

   K1 = [ 0,0,0]  K2 = [-1,0,0]  K3 = [0,-2,0]  K4 = [ 0,0,-1] 
        [-2,2,0]       [ 0,1,0]       [0, 2,0]       [ 0,1, 0]
        [ 0,0,0]       [ 0,0,0]       [0, 0,0]       [ 0,0, 0]

   K5 = [0,0, 0]  K6 = [0,0, 0]  K7 = [0, 0,0]  K8 = [ 0,0,0]
        [0,2,-2]       [0,1, 0]       [0, 2,0]       [ 0,1,0]
        [0,0, 0]       [0,0,-1]       [0,-2,0]       [-1,0,0]
   Finally divide by 16

   For now, will will use K1 and K2 for Gx and Gy if sobel filter is enabled, or K1 for K for fixed unsharp kernel

*/

reg signed [bitwidth+8-1:0] Opwindow_K1[0:2][0:2];
reg signed [bitwidth+8-1:0] Opwindow_K2[0:2][0:2];
reg signed [bitwidth+8-1:0] Opwindow_K3[0:2][0:2];
reg signed [bitwidth+8-1:0] Opwindow_K4[0:2][0:2];
reg signed [bitwidth+8-1:0] Opwindow_K5[0:2][0:2];
reg signed [bitwidth+8-1:0] Opwindow_K6[0:2][0:2];
reg signed [bitwidth+8-1:0] Opwindow_K7[0:2][0:2];
reg signed [bitwidth+8-1:0] Opwindow_K8[0:2][0:2];

reg Opwindow_dav;


always_ff @(posedge clk) begin : proc_sobel_edge
   Opwindow_dav <= img_window_dav;
   if(enable_edge_filter_reg) begin
      Opwindow_K1[0][0] <= -img_window[0][0];            Opwindow_K1[0][1] <= -(img_window[0][1] << 1);     Opwindow_K1[0][2] <= -img_window[0][2];
      Opwindow_K1[1][0] <= 0;                            Opwindow_K1[1][1] <= 0;                            Opwindow_K1[1][2] <= 0;
      Opwindow_K1[2][0] <= img_window[2][0];             Opwindow_K1[2][1] <= (img_window[2][1] << 1);      Opwindow_K1[2][2] <= img_window[2][2];
   end else if(enable_fixed_kernel_reg) begin
      Opwindow_K1[0][0] <= -(img_window[0][0] << 1);          Opwindow_K1[0][1] <= -(img_window[0][1] << 1);          Opwindow_K1[0][2] <= -(img_window[0][2] << 1);
      Opwindow_K1[1][0] <= -(img_window[1][0] << 1);          Opwindow_K1[1][1] <=  (img_window[1][1] << 4);          Opwindow_K1[1][2] <= -(img_window[1][2] << 1);
      Opwindow_K1[2][0] <= -(img_window[2][0] << 1);          Opwindow_K1[2][1] <= -(img_window[2][1] << 1);          Opwindow_K1[2][2] <= -(img_window[2][2] << 1);
   end else begin 
      Opwindow_K1[0][0] <= 0;                            Opwindow_K1[0][1] <= 0;                            Opwindow_K1[0][2] <= 0;
      Opwindow_K1[1][0] <= -(img_window[1][0] << 1);     Opwindow_K1[1][1] <=  (img_window[1][1] << 1);     Opwindow_K1[1][2] <= 0;
      Opwindow_K1[2][0] <= 0;                            Opwindow_K1[2][1] <= 0;                            Opwindow_K1[2][2] <= 0;
   end
   if(enable_edge_filter_reg) begin 
      Opwindow_K2[0][0] <= -(img_window[0][0]);             Opwindow_K2[0][1] <= 0;                            Opwindow_K2[0][2] <= (img_window[0][2]);
      Opwindow_K2[1][0] <= -(img_window[1][0] << 1);        Opwindow_K2[1][1] <= 0;                            Opwindow_K2[1][2] <= (img_window[1][2] << 1);
      Opwindow_K2[2][0] <= -(img_window[2][0]);             Opwindow_K2[2][1] <= 0;                            Opwindow_K2[2][2] <= (img_window[2][2]);   
   end
   else if(enable_fixed_kernel_reg) begin 
      for(int i=0;i<3;i++) begin 
         for(int j=0;j<3;j++) begin 
            Opwindow_K2[i][j] <= 0;
         end
      end
   end
   else begin 
      Opwindow_K2[0][0] <= -(img_window[0][0]);          Opwindow_K2[0][1] <= 0;                            Opwindow_K2[0][2] <= 0;
      Opwindow_K2[1][0] <= 0;                            Opwindow_K2[1][1] <=  (img_window[1][1]);          Opwindow_K2[1][2] <= 0;
      Opwindow_K2[2][0] <= 0;                            Opwindow_K2[2][1] <= 0;                            Opwindow_K2[2][2] <= 0;
   end
   if(enable_edge_filter_reg || enable_fixed_kernel_reg) begin 
      for(int i=0;i<3;i++) begin 
         for(int j=0;j<3;j++) begin 
            Opwindow_K3[i][j] <= 0;
            Opwindow_K4[i][j] <= 0;
            Opwindow_K5[i][j] <= 0;
            Opwindow_K6[i][j] <= 0;
            Opwindow_K7[i][j] <= 0;
            Opwindow_K8[i][j] <= 0;
         end
      end
   end else begin

      Opwindow_K3[0][0] <= 0;                            Opwindow_K3[0][1] <= -(img_window[0][1] << 1);     Opwindow_K3[0][2] <= 0;
      Opwindow_K3[1][0] <= 0;                            Opwindow_K3[1][1] <=  (img_window[1][1] << 1);     Opwindow_K3[1][2] <= 0;
      Opwindow_K3[2][0] <= 0;                            Opwindow_K3[2][1] <= 0;                            Opwindow_K3[2][2] <= 0;

      Opwindow_K4[0][0] <= 0;                            Opwindow_K4[0][1] <= 0;                            Opwindow_K4[0][2] <= -(img_window[0][2]);
      Opwindow_K4[1][0] <= 0;                            Opwindow_K4[1][1] <=  (img_window[1][1]);          Opwindow_K4[1][2] <= 0;
      Opwindow_K4[2][0] <= 0;                            Opwindow_K4[2][1] <= 0;                            Opwindow_K4[2][2] <= 0;

      Opwindow_K5[0][0] <= 0;                            Opwindow_K5[0][1] <= 0;                            Opwindow_K5[0][2] <= 0;
      Opwindow_K5[1][0] <= 0;                            Opwindow_K5[1][1] <=  (img_window[1][1] << 1);     Opwindow_K5[1][2] <= -(img_window[1][2] << 1);
      Opwindow_K5[2][0] <= 0;                            Opwindow_K5[2][1] <= 0;                            Opwindow_K5[2][2] <= 0;

      Opwindow_K6[0][0] <= 0;                            Opwindow_K6[0][1] <= 0;                            Opwindow_K6[0][2] <= 0;
      Opwindow_K6[1][0] <= 0;                            Opwindow_K6[1][1] <=  (img_window[1][1]);          Opwindow_K6[1][2] <= 0;
      Opwindow_K6[2][0] <= 0;                            Opwindow_K6[2][1] <= 0;                            Opwindow_K6[2][2] <= -(img_window[2][2]);

      Opwindow_K7[0][0] <= 0;                            Opwindow_K7[0][1] <= 0;                            Opwindow_K7[0][2] <= 0;
      Opwindow_K7[1][0] <= 0;                            Opwindow_K7[1][1] <=  (img_window[1][1] << 1);     Opwindow_K7[1][2] <= 0;
      Opwindow_K7[2][0] <= 0;                            Opwindow_K7[2][1] <= -(img_window[2][1] << 1);     Opwindow_K7[2][2] <= 0;

      Opwindow_K8[0][0] <= 0;                            Opwindow_K8[0][1] <= 0;                            Opwindow_K8[0][2] <= 0;
      Opwindow_K8[1][0] <= 0;                            Opwindow_K8[1][1] <=  (img_window[1][1]);          Opwindow_K8[1][2] <= 0;
      Opwindow_K8[2][0] <= -(img_window[2][0]);          Opwindow_K8[2][1] <= 0;                            Opwindow_K8[2][2] <= 0;
   end
end


reg signed [bitwidth+8-1:0] partial_sum_K1_l0[0:4];
reg signed [bitwidth+8-1:0] partial_sum_K1_l1[0:2];
reg signed [bitwidth+8-1:0] partial_sum_K1_l2[0:1];
reg signed [bitwidth+12-1:0] window_sum_K1;

reg signed [bitwidth+8-1:0] partial_sum_K2_l0[0:4];
reg signed [bitwidth+8-1:0] partial_sum_K2_l1[0:2];
reg signed [bitwidth+8-1:0] partial_sum_K2_l2[0:1];
reg signed [bitwidth+12-1:0] window_sum_K2;

reg signed [bitwidth+8-1:0] partial_sum_K3_l0;
reg signed [bitwidth+8-1:0] partial_sum_K3_l1;
reg signed [bitwidth+8-1:0] partial_sum_K3_l2;
reg signed [bitwidth+12-1:0] window_sum_K3;

reg signed [bitwidth+8-1:0] partial_sum_K4_l0;
reg signed [bitwidth+8-1:0] partial_sum_K4_l1;
reg signed [bitwidth+8-1:0] partial_sum_K4_l2;
reg signed [bitwidth+12-1:0] window_sum_K4;

reg signed [bitwidth+8-1:0] partial_sum_K5_l0;
reg signed [bitwidth+8-1:0] partial_sum_K5_l1;
reg signed [bitwidth+8-1:0] partial_sum_K5_l2;
reg signed [bitwidth+12-1:0] window_sum_K5;

reg signed [bitwidth+8-1:0] partial_sum_K6_l0;
reg signed [bitwidth+8-1:0] partial_sum_K6_l1;
reg signed [bitwidth+8-1:0] partial_sum_K6_l2;
reg signed [bitwidth+12-1:0] window_sum_K6;

reg signed [bitwidth+8-1:0] partial_sum_K7_l0;
reg signed [bitwidth+8-1:0] partial_sum_K7_l1;
reg signed [bitwidth+8-1:0] partial_sum_K7_l2;
reg signed [bitwidth+12-1:0] window_sum_K7;

reg signed [bitwidth+8-1:0] partial_sum_K8_l0;
reg signed [bitwidth+8-1:0] partial_sum_K8_l1;
reg signed [bitwidth+8-1:0] partial_sum_K8_l2;
reg signed [bitwidth+12-1:0] window_sum_K8;

reg partial_sum_l0_dav;
reg partial_sum_l1_dav;
reg partial_sum_l2_dav;

reg window_sum_dav;
reg window_sum_T_dav;

reg signed [bitwidth+12-1:0] window_sum_T_K1;
reg signed [bitwidth+12-1:0] window_sum_T_K2;
reg signed [bitwidth+12-1:0] window_sum_T_K3;
reg signed [bitwidth+12-1:0] window_sum_T_K4;
reg signed [bitwidth+12-1:0] window_sum_T_K5;
reg signed [bitwidth+12-1:0] window_sum_T_K6;
reg signed [bitwidth+12-1:0] window_sum_T_K7;
reg signed [bitwidth+12-1:0] window_sum_T_K8;

reg signed [bitwidth+12-1:0] window_sum_unsigned_K1;
reg signed [bitwidth+12-1:0] window_sum_unsigned_K2;

reg signed [bitwidth+12-1:0] window_sum_edge_K1_K2;

reg signed [bitwidth+12-1:0] total_sum_p0[0:3];
reg signed [bitwidth+12-1:0] total_sum_p1[0:1];
reg signed [bitwidth+12-1:0] total_sum;

reg signed [bitwidth+12-1:0] total_sum_edge_p0;

reg total_sum_p0_dav;
reg total_sum_p1_dav;
reg total_sum_dav;

reg video_out_temp_dav;
reg signed [bitwidth+16-1:0]video_out_temp;

// Pipelined pass through of video input for sharpening
reg signed [bitwidth:0] video_data[0:10];
always_ff @(posedge clk) begin : proc_video_delay
   // if(img_window_dav)  begin 
      video_data[0] <= img_window[1][1];
      for(int k=0;k<10;k++) begin 
         video_data[k+1] <= video_data[k];
      end
   // end
end

// Addition pipeline for 3x3 multiplier output
always_ff @(posedge clk) begin : proc_addition_pipeline

   // Pipe stage 1
   partial_sum_l0_dav <= Opwindow_dav;
   partial_sum_K1_l0[0] <= Opwindow_K1[0][0] + Opwindow_K1[0][1];
   partial_sum_K1_l0[1] <= Opwindow_K1[0][2] + Opwindow_K1[1][0];
   partial_sum_K1_l0[2] <= Opwindow_K1[1][1] + Opwindow_K1[1][2];
   partial_sum_K1_l0[3] <= Opwindow_K1[2][0] + Opwindow_K1[2][1];
   partial_sum_K1_l0[4] <= Opwindow_K1[2][2];

   partial_sum_K2_l0[0] <= Opwindow_K2[0][0] + Opwindow_K2[0][1];
   partial_sum_K2_l0[1] <= Opwindow_K2[0][2] + Opwindow_K2[1][0];
   partial_sum_K2_l0[2] <= Opwindow_K2[1][1] + Opwindow_K2[1][2];
   partial_sum_K2_l0[3] <= Opwindow_K2[2][0] + Opwindow_K2[2][1];
   partial_sum_K2_l0[4] <= Opwindow_K2[2][2];

   partial_sum_K3_l0 <= Opwindow_K3[1][1] + Opwindow_K3[0][1];

   partial_sum_K4_l0 <= Opwindow_K4[1][1] + Opwindow_K4[0][2];

   partial_sum_K5_l0 <= Opwindow_K5[1][1] + Opwindow_K5[1][2];

   partial_sum_K6_l0 <= Opwindow_K6[1][1] + Opwindow_K6[2][2];

   partial_sum_K7_l0 <= Opwindow_K7[1][1] + Opwindow_K7[2][1];

   partial_sum_K8_l0 <= Opwindow_K8[1][1] + Opwindow_K8[2][0];

   // Pipe stage 2
   partial_sum_l1_dav <= partial_sum_l0_dav;
   partial_sum_K1_l1[0] <= partial_sum_K1_l0[0] + partial_sum_K1_l0[1];
   partial_sum_K1_l1[1] <= partial_sum_K1_l0[2] + partial_sum_K1_l0[3];
   partial_sum_K1_l1[2] <= partial_sum_K1_l0[4];

   partial_sum_K2_l1[0] <= partial_sum_K2_l0[0] + partial_sum_K2_l0[1];
   partial_sum_K2_l1[1] <= partial_sum_K2_l0[2] + partial_sum_K2_l0[3];
   partial_sum_K2_l1[2] <= partial_sum_K2_l0[4];

   partial_sum_K3_l1 <= partial_sum_K3_l0;
   partial_sum_K4_l1 <= partial_sum_K4_l0;
   partial_sum_K5_l1 <= partial_sum_K5_l0;
   partial_sum_K6_l1 <= partial_sum_K6_l0;
   partial_sum_K7_l1 <= partial_sum_K7_l0;
   partial_sum_K8_l1 <= partial_sum_K8_l0;

   // Pipe stage 3
   partial_sum_l2_dav <= partial_sum_l1_dav;
   partial_sum_K1_l2[0] <= partial_sum_K1_l1[0] + partial_sum_K1_l1[1];
   partial_sum_K1_l2[1] <= partial_sum_K1_l1[2];

   partial_sum_K2_l2[0] <= partial_sum_K2_l1[0] + partial_sum_K2_l1[1];
   partial_sum_K2_l2[1] <= partial_sum_K2_l1[2];

   partial_sum_K3_l2 <= partial_sum_K3_l1;
   partial_sum_K4_l2 <= partial_sum_K4_l1;
   partial_sum_K5_l2 <= partial_sum_K5_l1;
   partial_sum_K6_l2 <= partial_sum_K6_l1;
   partial_sum_K7_l2 <= partial_sum_K7_l1;
   partial_sum_K8_l2 <= partial_sum_K8_l1;


   // Pipe stage 4
   window_sum_dav <= partial_sum_l2_dav;
   window_sum_K1 <= partial_sum_K1_l2[0] + partial_sum_K1_l2[1];
   window_sum_K2 <= partial_sum_K2_l2[0] + partial_sum_K2_l2[1];
   window_sum_K3 <= partial_sum_K3_l2;
   window_sum_K4 <= partial_sum_K4_l2;
   window_sum_K5 <= partial_sum_K5_l2;
   window_sum_K6 <= partial_sum_K6_l2;
   window_sum_K7 <= partial_sum_K7_l2;
   window_sum_K8 <= partial_sum_K8_l2;

   // Pipe stage 5
   window_sum_T_dav <= window_sum_dav;  
   if (window_sum_K1 > threshold_value || window_sum_K1 <= -threshold_value) window_sum_T_K1 <= window_sum_K1; else window_sum_T_K1 <= 0;
   if (window_sum_K2 > threshold_value || window_sum_K2 <= -threshold_value) window_sum_T_K2 <= window_sum_K2; else window_sum_T_K2 <= 0;
   if (window_sum_K3 > threshold_value || window_sum_K3 <= -threshold_value) window_sum_T_K3 <= window_sum_K3; else window_sum_T_K3 <= 0;
   if (window_sum_K4 > threshold_value || window_sum_K4 <= -threshold_value) window_sum_T_K4 <= window_sum_K4; else window_sum_T_K4 <= 0;
   if (window_sum_K5 > threshold_value || window_sum_K5 <= -threshold_value) window_sum_T_K5 <= window_sum_K5; else window_sum_T_K5 <= 0;
   if (window_sum_K6 > threshold_value || window_sum_K6 <= -threshold_value) window_sum_T_K6 <= window_sum_K6; else window_sum_T_K6 <= 0;
   if (window_sum_K7 > threshold_value || window_sum_K7 <= -threshold_value) window_sum_T_K7 <= window_sum_K7; else window_sum_T_K7 <= 0;
   if (window_sum_K8 > threshold_value || window_sum_K8 <= -threshold_value) window_sum_T_K8 <= window_sum_K8; else window_sum_T_K8 <= 0;

   //For edge filter add the values, thresholding would be done after the addition
   if(window_sum_T_K1[bitwidth+12-1]) window_sum_unsigned_K1 <= -window_sum_K1; else window_sum_unsigned_K1 <= window_sum_K1;
   if(window_sum_T_K2[bitwidth+12-1]) window_sum_unsigned_K2 <= -window_sum_K2; else window_sum_unsigned_K2 <= window_sum_K2;

   // Pipe stage 6
   total_sum_p0_dav <= window_sum_T_dav;
   total_sum_p0[0] <= window_sum_T_K1 + window_sum_T_K2;
   total_sum_p0[1] <= window_sum_T_K3 + window_sum_T_K4;
   total_sum_p0[2] <= window_sum_T_K5 + window_sum_T_K6;
   total_sum_p0[3] <= window_sum_T_K7 + window_sum_T_K8;

   window_sum_edge_K1_K2 <= window_sum_unsigned_K1 + window_sum_unsigned_K2; 

   // Pipe stage 7
   total_sum_p1_dav <= total_sum_p0_dav;
   total_sum_p1[0] <= total_sum_p0[0] + total_sum_p0[1];
   total_sum_p1[1] <= total_sum_p0[2] + total_sum_p0[3];

   if (window_sum_edge_K1_K2 > threshold_value ) total_sum_edge_p0 <= window_sum_edge_K1_K2; else total_sum_edge_p0 <=0;


   // Pipe stage 8
   total_sum_dav <= total_sum_p1_dav;
   total_sum <= total_sum_p1[0] + total_sum_p1[1];

   //Pipe stage 9
   // Add the values with original video
   video_out_temp_dav <= total_sum_dav;
   video_out_temp <= video_data[8] + (total_sum >>> 4)*sharp_scale;
end

wire [bitwidth-1:0] video_out_temp_clip = (video_out_temp<0)?0:((video_out_temp>(2**bitwidth -1))?2**bitwidth-1:video_out_temp);

wire [bitwidth-1:0] total_sum_edge = (total_sum_edge_p0>2**bitwidth-1)?2**bitwidth-1:total_sum_edge_p0;

assign fifo_wr_en = (enable_filter_reg)?((enable_edge_filter_reg)?total_sum_p1_dav:video_out_temp_dav):total_sum_dav;
assign fifo_din = (enable_filter_reg)?((enable_edge_filter_reg)?total_sum_edge:video_out_temp_clip):video_data[8][bitwidth-1:0];


// wire [127:0] probe0;
// assign probe0 = {enable_edge_filter_reg,
//                  enable_filter_reg,
//                  fifo_wr_en,
//                  total_sum_p1_dav,
//                  video_out_temp_dav,
//                  total_sum_dav,
//                  video_out_temp_clip,
//                  video_out_temp,
//                  video_data[8],
//                  total_sum,
//                  sharp_scale,
//                  total_sum_p0_dav,
//                  total_sum_p1_dav,
//                  window_sum_T_dav,
//                  total_sum_p1[0],
//                  3'd0    
//                  };
// ila_0 ila2 (
// 	.clk(clk), // input wire clk
// 	.probe0(probe0) // input wire [127:0] probe0
// );




end

if(SHARP_EDGE==0) begin


reg [bitwidth+16-1:0] Opwindow[0:2][0:2];
reg Opwindow_dav;

reg [15:0] kernel[0:2][0:2]; // Q8.8 format (1st bit for sign)

/*
   Initial blurring kernel values
   1/16 2/16 1/16
   2/16 4/16 2/16
   1/16 2/16 1/16

   Since we are using kernel in the 8.8 format, we multiply by 256
*/
initial begin
   kernel[0][0] <= 16'd16; kernel[1][0] <= 16'd32; kernel[2][0] <= 16'd16; 
   kernel[0][1] <= 16'd32; kernel[1][1] <= 16'd64; kernel[2][1] <= 16'd32;
   kernel[0][2] <= 16'd16; kernel[1][2] <= 16'd32; kernel[2][2] <= 16'd16;
end

always_ff @(posedge clk) begin : proc_op_window
   Opwindow_dav <= img_window_dav;
   for(int i=0;i<3;i++) begin
      for(int j=0;j<3;j++) begin
         Opwindow[i][j] <= img_window[i][j]*kernel[i][j];
      end 
   end
end


reg [bitwidth+16+1-1:0] partial_sum_l0[0:4];
reg [bitwidth+16+2-1:0] partial_sum_l1[0:2];
reg [bitwidth+16+3-1:0] partial_sum_l2[0:1];
reg [bitwidth+16+4-1:0] window_sum;

reg partial_sum_l0_dav;
reg partial_sum_l1_dav;
reg partial_sum_l2_dav;
reg window_sum_dav;

// Addition pipeline for 3x3 multiplier output
always_ff @(posedge clk) begin : proc_addition_pipeline

   // Pipe stage 1
   partial_sum_l0_dav <= Opwindow_dav;
   partial_sum_l0[0] <= Opwindow[0][0] + Opwindow[0][1];
   partial_sum_l0[1] <= Opwindow[0][2] + Opwindow[1][0];
   partial_sum_l0[2] <= Opwindow[1][1] + Opwindow[1][2];
   partial_sum_l0[3] <= Opwindow[2][0] + Opwindow[2][1];
   partial_sum_l0[4] <= Opwindow[2][2];


   // Pipe stage 2
   partial_sum_l1_dav <= partial_sum_l0_dav;
   partial_sum_l1[0] <= partial_sum_l0[0] + partial_sum_l0[1];
   partial_sum_l1[1] <= partial_sum_l0[2] + partial_sum_l0[3];
   partial_sum_l1[2] <= partial_sum_l0[4];

   // Pipe stage 3
   partial_sum_l2_dav <= partial_sum_l1_dav;
   partial_sum_l2[0] <= partial_sum_l1[0] + partial_sum_l1[1];
   partial_sum_l2[1] <= partial_sum_l1[2];

   // Pipe stage 4
   window_sum_dav <= partial_sum_l2_dav;
   window_sum <= partial_sum_l2[0] + partial_sum_l2[1];

end

wire [bitwidth-1:0] window_sum_clip = (window_sum[bitwidth+16+4-1:8]>(2**bitwidth -1))?2**bitwidth-1:window_sum[bitwidth+8-1:8];

assign fifo_wr_en = enable_filter_reg?window_sum_dav:img_window_dav;
assign fifo_din = enable_filter_reg?window_sum_clip:img_window[1][1];

end
endgenerate


reg rd_en;
wire empty, full;

xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(16),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(4),    // DECIMAL
      .PROG_FULL_THRESH(3),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(5),   // DECIMAL
      .READ_DATA_WIDTH(bitwidth),      // DECIMAL
      .READ_MODE("std"),         // String
      .USE_ADV_FEATURES("1000"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(bitwidth),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(5)    // DECIMAL
   )
   xpm_fifo_video_out_buffer (
      .almost_empty(),
      .almost_full(),
      .data_valid(video_o_dav),
      .dbiterr(),
      .dout(video_o_data),
      .empty(empty),
      .full(full),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(fifo_din),
      .injectdbiterr(1'b0),
      .injectsbiterr(1'b0),
      .rd_en(rd_en),
      .rst(rst),
      .sleep(1'b0),
      .wr_clk(clk),
      .wr_en(fifo_wr_en)
   );

reg [3:0] video_out_fsm;

reg [PIX_BITS-1:0] xcounter_out;
reg [LIN_BITS-1:0] ycounter_out;


localparam s_start_frame = 4'd0,
            s_send_v = 4'd1,
            s_send_h = 4'd2,
            s_send_line = 4'd3,
            s_end_line = 4'd4,
            s_send_eoi = 4'd5,
            s_pre_end_line = 4'd6;

// Video output statemachine
always_ff @(posedge clk or posedge rst) begin : proc_video_out
   if(rst) begin
      video_o_v <= 0;
      video_o_h <= 0;
      video_o_eoi <= 0;
      xcounter_out <= 0;
      ycounter_out <= 0;
      rd_en <= 0;
      video_out_fsm <= s_start_frame;
   end else begin
      video_o_v <= 0;
      video_o_h <= 0;
      video_o_eoi <= 0;
      rd_en <= 0;

      case (video_out_fsm)
         s_start_frame: begin 
            if(empty==0) begin 
               video_out_fsm <= s_send_v;
            end               
         end
         s_send_v: begin 
            video_o_v <= 1'b1;
            video_out_fsm <= s_send_h;
         end
         s_send_h: begin 
            video_o_h <= 1'b1;
            video_out_fsm <= s_send_line;
         end
         s_send_line: begin 
            if(empty==0) begin 
               rd_en <= 1'b1;
               xcounter_out <= xcounter_out + 1;
               if(xcounter_out==VIDEO_XSIZE-1) begin 
                  xcounter_out <= 0;
                  ycounter_out <= ycounter_out + 1;
                  if(ycounter_out==VIDEO_YSIZE-1)begin
                     video_out_fsm <= s_send_eoi;   
                  end else begin
                     video_out_fsm <= s_pre_end_line;
                  end
               end
            end
         end
         s_pre_end_line: begin 
            // if(empty) begin 
               video_out_fsm <= s_end_line;
            // end
         end
         s_end_line: begin 
            if(empty==0) begin 
               video_out_fsm <= s_send_h;
            end
         end
         s_send_eoi: begin 
            video_o_eoi <= 1'b1;
            ycounter_out <= 0;
            video_out_fsm <= s_start_frame;
         end
         default : /* default */;
      endcase

   end
end

always_ff @(posedge clk or posedge rst) begin : proc_register_enable_signals
   if(rst) begin
      enable_filter_reg <= 0;
      enable_edge_filter_reg <= 0;
      enable_fixed_kernel_reg <= 0;
   end else begin
      if(video_o_eoi) begin 
         enable_filter_reg <= enable_filter;
         enable_edge_filter_reg <= enable_edge_filter;
         enable_fixed_kernel_reg <= enable_fixed_kernel;
      end
   end
end

endmodule // filter3x3