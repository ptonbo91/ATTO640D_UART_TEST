//`include "TOII_TUVE_HEADER.vh"
// `define ILA_SNAP_CTRLR
module snapshot_controller 
  #( parameter PIX_BITS = 10,
  LIN_BITS = 10,
  WR_SIZE = 16,
  DMA_SIZE_BITS=5
  )(
  input clk,    // Clock
  input rst,

  input [2:0] channel_in,
  input [2:0] mode_in,
(* mark_debug = "true" *)  input       single_snapshot,
(* mark_debug = "true" *)  input       continuous_snapshot,
(* mark_debug = "true" *)  input       burst_snapshot, // burst mode capture example capture 5 image
(* mark_debug = "true" *)  input [7:0] burst_capture_size, // burst mode capture size
(* mark_debug = "true" *)  input [7:0] snapshot_counter,

  (* mark_debug = "true" *)input trigger,
    output reg busy_out,
    
  output reg done_out,

  input [7:0]     total_frames,

  input          src_1_v,
  input          src_1_h,
  input          src_1_eoi,
  input          src_1_dav,
  input [16-1:0]     src_1_data,
  input [PIX_BITS-1:0] src_1_xsize,
  input [LIN_BITS-1:0] src_1_ysize,

  input          src_2_v,
  input          src_2_h,
  input          src_2_eoi,
  input          src_2_dav,
  input [16-1:0]     src_2_data,
  input [PIX_BITS-1:0] src_2_xsize,
  input [LIN_BITS-1:0] src_2_ysize,

  input          src_3_v,
  input          src_3_h,
  input          src_3_eoi,
  input          src_3_dav,
  input [08-1:0]     src_3_data,
  input [PIX_BITS-1:0] src_3_xsize,
  input [LIN_BITS-1:0] src_3_ysize,
  
  input          src_4_v,
  input          src_4_h,
  input          src_4_eoi,
  input          src_4_dav,
  input [16-1:0]     src_4_data,
  input [PIX_BITS-1:0] src_4_xsize,
  input [LIN_BITS-1:0] src_4_ysize,

  input             dma_wrready,
  output            dma_wrreq,  
  output            dma_wrburst,
  output [DMA_SIZE_BITS-1:0]  dma_wrsize, 
  output [31:0]         dma_wraddr, 
  output [31:0]         dma_wrdata, 
  output [3:0]          dma_wrbe
  
);

`include "TOII_TUVE_HEADER.vh"
// For 1st two channels the total number of buffers will be TOTAL_FRAME_BUFFERS, however
// for 3rd channel it will be 2*TOTAL_FRAME_BUFFERS since the datasize is half of that of
// 1st two channels

/* define different modes of captures
 ^ continuous capture of frames - TOTAL_FRAME_BUFFERS number of frames
 ^ capture every 10 frames
 ^ capture every 50 frames

 Currently support only continuous capture mode. Due to realtime capture 
 requirements, we need to manage bandwidth manually, and thus we need to switch
 off NUC corrections, DMA_WRITE_BT656 and MEMORY_TO_SCALER modules
*/

localparam CONTINUOUS_CAPTURE='d0,
CAPTURE_NUC1PTM2_FRAME ='d1,
CAPTURE_PER_50_FRAMES ='d2,
CAPTURE_RING_BUFFER1 ='d3,
CAPTURE_RING_BUFFER2 = 'd7,
CAPTURE_SINGLE_FRAME = 'd4,
BURST_CAPTURE        = 'd5;

reg [31:0] frame_buffer_base_start_address = ADDR_SNAPSHOT_BASE;
reg [31:0] frame_buffer_base_offset_1 = ADDR_SNAPSHOT_OFFSET_1;
reg [31:0] frame_buffer_base_offset_2 = ADDR_SNAPSHOT_OFFSET_2;

reg [31:0] last_frame_address_1 = ADDR_SNAPSHOT_BASE + TOTAL_FRAME_BUFFERS*ADDR_SNAPSHOT_OFFSET_1;
reg [31:0] last_frame_address_2 = ADDR_SNAPSHOT_BASE + TOTAL_FRAME_BUFFERS*ADDR_SNAPSHOT_OFFSET_2;

reg [31:0] ncu1ptm2_addr = ADDR_OFFM_NUC1PTM2;

(* mark_debug = "true" *)reg [31:0] base_addr;

(* mark_debug = "true" *)reg [3:0] snap_fsm;

reg start;
(* mark_debug = "true" *)wire busy, done;

reg [2:0] channel;

(* mark_debug = "true" *)reg [2:0] channel_d;
(* mark_debug = "true" *)reg [2:0] mode_d;

(* mark_debug = "true" *)reg [7:0] number_frames;

reg [7:0] total_frames_d;
localparam  s_idle = 'd0,
      s_check_mode = 'd1,
      s_continuous_capture1 = 'd2,
      s_continuous_capture2 = 'd3,
      s_burst_capture1 = 'd4,
      s_burst_capture2 = 'd5;
      
always @(posedge clk or posedge rst) begin : proc_store_frames
  if(rst) begin
    snap_fsm <= s_idle;
    start <= 1'b0;
    channel_d <= 0;
    mode_d <= 0;
    done_out <= 0;
    busy_out <= 0;
    base_addr <= frame_buffer_base_start_address;
  end else begin
    done_out <= 0;
    case(snap_fsm)
      s_idle: begin 
        if(trigger) begin 
          channel_d <= channel_in;
          mode_d <= mode_in;
          snap_fsm <= s_check_mode; 
          busy_out <= 1'b1;
          number_frames <= total_frames;
//          if(channel_in==0 || channel_in==1 || mode_in == CAPTURE_SINGLE_FRAME) begin 
//            number_frames <= total_frames;
//          end else begin 
//            number_frames <= total_frames<<1;
//          end
        end 
        else if(single_snapshot)begin
          channel_d<= 3'd2;
          mode_d   <= CAPTURE_SINGLE_FRAME;
          snap_fsm <= s_check_mode; 
          busy_out <= 1'b1;
          number_frames <= snapshot_counter;        
        end  
        else if(continuous_snapshot)begin
          channel_d<= 3'd2;
          mode_d   <= CONTINUOUS_CAPTURE; //5
          snap_fsm <= s_check_mode; 
          busy_out <= 1'b1;
          number_frames <= 8'd64;        
        end 
        else if(burst_snapshot)begin
          channel_d<= 3'd2;
          mode_d   <= BURST_CAPTURE; //5
          snap_fsm <= s_check_mode; 
          busy_out <= 1'b1;
          number_frames <= burst_capture_size;        
        end 
      end
      s_check_mode: begin 
        case(mode_d)
          BURST_CAPTURE: begin
            snap_fsm <= s_burst_capture1;
            base_addr <= frame_buffer_base_start_address + (snapshot_counter - burst_capture_size)*frame_buffer_base_offset_2;
          end            
          CONTINUOUS_CAPTURE: begin
            snap_fsm <= s_continuous_capture1;
            base_addr <= frame_buffer_base_start_address;
          end
          CAPTURE_SINGLE_FRAME: begin 
//            if(channel_d==0 || channel_d==1) begin 
            if(channel_d==0 || channel_d==1 || channel_d== 3) begin
              base_addr <= frame_buffer_base_start_address+(number_frames-1)*frame_buffer_base_offset_1;
            end
            else begin 
              base_addr <= frame_buffer_base_start_address+(number_frames-1)*frame_buffer_base_offset_2;
            end
            number_frames <= 1;
            snap_fsm <= s_continuous_capture1;
          end
          CAPTURE_RING_BUFFER1,
          CAPTURE_RING_BUFFER2: begin 
//            if(channel_d==0 || channel_d==1) begin 
            if(channel_d==0 || channel_d==1 || channel_d==3) begin
              if(base_addr >= last_frame_address_1) begin 
                base_addr <= frame_buffer_base_start_address;
              end 
            end
            else begin 
              if(base_addr >= last_frame_address_2) begin 
                base_addr <= frame_buffer_base_start_address;
              end
            end
            snap_fsm <= s_continuous_capture1;
          end
          // CAPTURE_PER_10_FRAMES:
          CAPTURE_NUC1PTM2_FRAME: begin
            base_addr <= ncu1ptm2_addr;
            number_frames <= 1; 
            snap_fsm <= s_continuous_capture1;
          end
        //  CAPTURE_PER_50_FRAMES:
          default: begin
            snap_fsm <= s_continuous_capture1;
            base_addr <= frame_buffer_base_start_address;
          end
        endcase
      end
      s_continuous_capture1: begin 
        start <= 1'b1;
        channel <= channel_d;
        snap_fsm <= s_continuous_capture2;
      end
      s_continuous_capture2: begin 
        start <=1'b0;
        if(done) begin 
          number_frames <= number_frames -1;
//          if(channel_d==0 || channel_d==1) begin 
          if(channel_d==0 || channel_d==1 || channel_d==3) begin     
            base_addr <= base_addr + frame_buffer_base_offset_1;
          end else begin 
            base_addr <= base_addr + frame_buffer_base_offset_2;
          end
          if(number_frames==1) begin 
            done_out <= 1'b1;
            busy_out <= 1'b0;
            snap_fsm <= s_idle;
          end else begin 
            snap_fsm <= s_continuous_capture1;
          end
        end
      end
      s_burst_capture1: begin 
        start <= 1'b1;
        channel <= channel_d;
        snap_fsm <= s_burst_capture2;
      end
      s_burst_capture2: begin 
        start <=1'b0;
        if(done) begin 
          number_frames <= number_frames -1;
          base_addr <= base_addr + frame_buffer_base_offset_2;
          if(number_frames==1) begin 
            done_out <= 1'b1;
            busy_out <= 1'b0;
            snap_fsm <= s_idle;
          end else begin 
            snap_fsm <= s_burst_capture1;
          end
        end
      end      
    endcase // snap_fsm
  end
end


snapshot #(
  .PIX_BITS(PIX_BITS),
  .LIN_BITS(LIN_BITS),
  .WR_SIZE(WR_SIZE),
  .DMA_SIZE_BITS(DMA_SIZE_BITS)
  ) 
snapshot_inst(

  .clk(clk),
  .rst(rst),

  .start(start),
  .busy(busy),
  .done(done),
  .channel(channel),
  .base_addr(base_addr),

  .src_1_v(src_1_v),
  .src_1_h(src_1_h),
  .src_1_eoi(src_1_eoi),
  .src_1_dav(src_1_dav),
  .src_1_data(src_1_data),
  .src_1_xsize(src_1_xsize),
  .src_1_ysize(src_1_ysize),
  .src_2_v(src_2_v),
  .src_2_h(src_2_h),
  .src_2_eoi(src_2_eoi),
  .src_2_dav(src_2_dav),
  .src_2_data(src_2_data),
  .src_2_xsize(src_2_xsize),
  .src_2_ysize(src_2_ysize),
  .src_3_v(src_3_v),
  .src_3_h(src_3_h),
  .src_3_eoi(src_3_eoi),
  .src_3_dav(src_3_dav),
  .src_3_data(src_3_data),
  .src_3_xsize(src_3_xsize),
  .src_3_ysize(src_3_ysize),
  .src_4_v(src_4_v),
  .src_4_h(src_4_h),
  .src_4_eoi(src_4_eoi),
  .src_4_dav(src_4_dav),
  .src_4_data(src_4_data),
  .src_4_xsize(src_4_xsize),
  .src_4_ysize(src_4_ysize),
  .dma_wrready(dma_wrready),
  .dma_wrreq(dma_wrreq),  
  .dma_wrburst(dma_wrburst),
  .dma_wrsize(dma_wrsize), 
  .dma_wraddr(dma_wraddr), 
  .dma_wrdata(dma_wrdata), 
  .dma_wrbe(dma_wrbe)
  );


`ifdef  ILA_SNAP_CTRLR

wire [127:0] probe0;
TOII_TUVE_ila ila_snap_ctrlr(
    .CLK(clk),
    .PROBE0(probe0)
);

assign probe0 = {64'd0, snap_fsm, base_addr, mode_d, channel_d, trigger, busy, done, number_frames,
                  single_snapshot,    
                  continuous_snapshot,
                  burst_snapshot,
                  snapshot_counter   }; //53



`endif
endmodule