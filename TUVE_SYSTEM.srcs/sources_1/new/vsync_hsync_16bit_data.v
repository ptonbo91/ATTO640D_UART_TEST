`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2019 12:17:13 PM
// Design Name: 
// Module Name: vsync_hsync_16bit_data
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`define ILA_DEBUG_VSYNC_HYSNC

module vsync_hsync_16bit_data(
    clk,
    reset,
    tick1s,
    video_i_v,
    video_i_h,
    video_i_dav,
    video_i_data,
    video_i_eoi,
    video_i_xsize,
    video_i_ysize,
    bt656_req_v,
    bt656_req_h,
    bt656_run,
    


    PAL_nNTSC,

    pclk,
    video_o_frame_pulse,
    video_o_frame_valid,
    video_o_line_valid,
    video_o_data
    );
parameter LIN_BITS = 10;
parameter PIX_BITS = 10;
//parameter HSYNC_START_DELAY = 41; // 716*576
//parameter HBLANK            = 37; // 716*576
parameter HSYNC_START_DELAY = 8; // 640*480
parameter HBLANK            = 4; // 640*480

parameter VBLANK            = 3840;
// parameter VIDEO_IN_XSIZE = 640;
// parameter VIDEO_IN_YSIZE = 512;
// localparam BLANK_LINES = (576 - VIDEO_IN_YSIZE)/4;
// localparam BLANK_PIXELS = (720 - VIDEO_IN_XSIZE)/2;

input clk;
input reset;
(* mark_debug = "true" *)input tick1s;
(* mark_debug = "true" *)input video_i_v;
(* mark_debug = "true" *)input video_i_h;
(* mark_debug = "true" *)input video_i_dav;
(* mark_debug = "true" *)input [15:0] video_i_data;
(* mark_debug = "true" *)input [PIX_BITS-1:0] video_i_xsize;
(* mark_debug = "true" *)input [LIN_BITS-1:0] video_i_ysize;

(* mark_debug = "true" *)input video_i_eoi;
input PAL_nNTSC;
(* mark_debug = "true" *)input bt656_req_v;
(* mark_debug = "true" *)input bt656_req_h;
input bt656_run;


input pclk;
output video_o_frame_pulse;
(* mark_debug = "true" *)output    reg video_o_frame_valid;
(* mark_debug = "true" *)output    reg video_o_line_valid;

(* mark_debug = "true" *)output reg [15:0]  video_o_data;

//(* mark_debug = "true" *)
//localparam FIFO_DEPTH = 11;
localparam FIFO_DEPTH = 12;
localparam FIFO_WIDTH = 16;

reg [PIX_BITS-1:0] BLANK_PIXELS;
reg [LIN_BITS-1:0] BLANK_LINES;

//reg [PIX_BITS-1:0] VIDEO_IN_XSIZE;
//reg [LIN_BITS-1:0] VIDEO_IN_YSIZE;



(* mark_debug = "true" *)wire [FIFO_DEPTH-1:0] fifo_usedw;
(* mark_debug = "true" *)wire [FIFO_DEPTH-1:0] fifo_cnt;
(* mark_debug = "true" *)reg fifo_clr;
(* mark_debug = "true" *)wire fifo_clr_rd;
(* mark_debug = "true" *)reg fifo_afull;
(* mark_debug = "true" *)reg fifo_aempty;
(* mark_debug = "true" *)reg fifo_full;
(* mark_debug = "true" *)wire fifo_empty;
//(* mark_debug = "true" *)reg [0:0] vstate;
//reg [2:0] state;
// reg run;
reg [9:0] lcount;
wire fifo_wr;
(* mark_debug = "true" *)reg fifo_rd;
(* mark_debug = "true" *)wire [FIFO_WIDTH-1:0] fifo_out;
wire [FIFO_WIDTH-1:0] fifo_in;
reg field;
reg eav;
reg chroma;
reg bt656_sigv;
reg bt656_sigh;
reg bt656_sigf;
reg [10:0] bt656_cnt_pix;
reg [10:0] bt656_cnt_lin;
reg PALnNTSC_l;

// assign fifo_clr = 1'd0;

(* mark_debug = "true" *)reg [3:0] bt656_st;
(* mark_debug = "true" *)reg [3:0]video_out_sig_gen_st;
(* mark_debug = "true" *)reg [PIX_BITS-1:0] vxcount;
(* mark_debug = "true" *)reg [LIN_BITS-1:0] vycount;

(* mark_debug = "true" *)reg [9:0]  out_frame_cnt; 
(* mark_debug = "true" *)reg [15:0] out_line_cnt; 
(* mark_debug = "true" *)reg video_o_frame_valid_d;
(* mark_debug = "true" *)reg video_o_line_valid_d;

//assign bt656_req_xsize = video_i_xsize;
//assign bt656_req_ysize = video_i_ysize;



localparam SC_IDLE = 4'd0,
            SC_REQ_V = 4'd1,
            SC_REQ_H = 4'd2,
            SC_WAIT_DAV = 4'd3,
            SC_WAIT_FIFO = 4'd4,
            SC_WAIT = 4'd5;

localparam SC_GEN_IDLE    = 4'd0,
            SC_GEN_V      = 4'd1,
            SC_GEN_V_WAIT = 4'd2,
            SC_GEN_FIFO_RD_REQ = 4'd3,
            SC_GEN_FIFO_RD_WAIT = 4'd4,
            SC_GEN_H      = 4'd5,
            SC_GEN_H_WAIT = 4'd6;
            
reg [PIX_BITS-1:0] hsync_delay_counter;
reg [PIX_BITS-1:0] hblank_counter;
(* mark_debug = "true" *)reg [PIX_BITS-1:0] video_o_pix_cnt;
(* mark_debug = "true" *)reg [LIN_BITS-1:0] video_o_line_cnt;
(* mark_debug = "true" *)reg data_wr_en;
(* mark_debug = "true" *)reg [PIX_BITS-1:0] latch_video_i_xsize;
(* mark_debug = "true" *)reg [LIN_BITS-1:0] latch_video_i_ysize;
(* mark_debug = "true" *)reg [PIX_BITS-1:0] out_latch_video_i_xsize;
(* mark_debug = "true" *)reg [LIN_BITS-1:0] out_latch_video_i_ysize;
(* mark_debug = "true" *)reg start_rd;
(* mark_debug = "true" *)reg start_rd_d;
(* mark_debug = "true" *)reg start_video_out;

always @(posedge clk, posedge reset) begin:bt656_req
    if(reset==1) begin 
        bt656_st <= SC_IDLE;

        vycount <= 'd0;
        vxcount <= 'd0;
        field <= 1'b1;
        fifo_clr<=1'b0;
        data_wr_en <= 1'b0;
        latch_video_i_xsize <= 0; 
        latch_video_i_ysize <= 0;
        start_rd   <= 1'b0;
    end
    else begin 
        fifo_clr<=1'b0;
        case (bt656_st)
            SC_IDLE: begin 
                
//                if((fifo_usedw == 0) && bt656_run) begin 
//                    fifo_clr  <= 1'b1;
//                    bt656_st  <= SC_REQ_V;
//                end
                bt656_st  <= SC_REQ_V;
            end
            SC_REQ_V: begin
//                if(bt656_req_v == 1'b1)begin 
                if(video_i_v   == 1'b1)begin
                    bt656_st <= SC_WAIT;
                    data_wr_en <= 1'b1;
                    latch_video_i_xsize <= video_i_xsize;
                    latch_video_i_ysize <= video_i_ysize;
                end    
                else begin
                    bt656_st <= SC_REQ_V;
                end    
            end
            SC_WAIT:begin 
//              if(bt656_req_h == 1'b1)begin
              start_rd   <= 1'b1;
              if(video_i_h   == 1'b1)begin
//                bt656_st <= SC_REQ_H;
                bt656_st <= SC_WAIT_DAV;
                vycount  <= vycount + 1;
              end 
              else begin
                bt656_st <= SC_WAIT;
              end  
            end
//            SC_REQ_H:begin 
//                vycount <= vycount + 1;
//                bt656_st <= SC_WAIT_DAV;
//            end
            SC_WAIT_DAV: begin                 
                if(video_i_dav) begin            
//                  if(vxcount==lvideo_i_xsize-1) begin
                  if(vxcount==latch_video_i_xsize-1) begin
                    vxcount <= 'd0; 
                    if(vycount==latch_video_i_ysize)begin
                        data_wr_en <= 1'b0;
                    end
                    bt656_st <= SC_WAIT_FIFO;
                  end
                  else begin
                    vxcount <= vxcount + 1;
                    bt656_st <= SC_WAIT_DAV;
                  end
                end
            end
            SC_WAIT_FIFO:begin 
//                if(fifo_usedw<video_i_xsize-video_i_xsize/2) begin 
//                    if(vycount==VIDEO_IN_YSIZE) begin 
//                    if(vycount==video_i_ysize)begin
                    if(vycount==latch_video_i_ysize)begin
                        vycount  <= 'd0;
                        bt656_st <= SC_IDLE;  
                    end else begin 
//                        bt656_st <= SC_REQ_H;
                        bt656_st <= SC_WAIT_DAV;
                        vycount  <= vycount + 1;
                    end
//                end
            end
            default : bt656_st <= SC_IDLE;
        endcase
    end
end

assign video_o_frame_pulse   = (!video_o_frame_valid_d) &(video_o_frame_valid);

always @(posedge pclk, posedge reset) begin:video_out_sig_gen
    if(reset==1) begin 
        video_out_sig_gen_st <= SC_GEN_IDLE;
        video_o_frame_valid <= 1'b0;
        video_o_line_valid <= 1'b0;  
        hsync_delay_counter <= 0;
        video_o_pix_cnt     <= 0;
        video_o_line_cnt    <= 0;
        hblank_counter      <= 0;
        video_o_frame_valid_d <=  1'b0;
        video_o_line_valid_d  <=  1'b0;
        out_frame_cnt  <= 0;
        out_line_cnt <= 0;
        fifo_rd      <= 1'b0;
        out_latch_video_i_xsize <= 0;
        out_latch_video_i_ysize <= 0;
        start_video_out         <= 1'b0;
    end
    else begin 
        video_o_frame_valid_d <= video_o_frame_valid;
        video_o_line_valid_d  <= video_o_line_valid;
        
//        start_rd_d            <= start_rd;
        if(tick1s)begin
            out_frame_cnt <= 0;
        end
        else if((!video_o_frame_valid_d) &(video_o_frame_valid))begin
            out_frame_cnt <= out_frame_cnt +1;
        end

        if((!video_o_frame_valid_d) &(video_o_frame_valid))begin
            out_line_cnt <= 0;
        end
        else if((!video_o_line_valid_d) &(video_o_line_valid))begin
            out_line_cnt <= out_line_cnt +1;
        end        
        
//        if((!start_rd_d)& (start_rd))begin
//            out_latch_video_i_xsize <= latch_video_i_xsize;
//            out_latch_video_i_ysize <= latch_video_i_ysize;
//            start_video_out         <= 1'b1;
//        end
        
         
        case (video_out_sig_gen_st)
            SC_GEN_IDLE: begin 
                out_latch_video_i_xsize <= latch_video_i_xsize;
                out_latch_video_i_ysize <= latch_video_i_ysize;
//                if((fifo_cnt>latch_video_i_xsize-1) && start_rd) begin 
                if((fifo_cnt>{latch_video_i_xsize,2'b00}-1) && start_rd) begin 
                    video_out_sig_gen_st  <= SC_GEN_V;
                end
                video_o_pix_cnt     <= 0;
            end
            SC_GEN_V: begin
                video_o_frame_valid  <= 1'b1;
                video_out_sig_gen_st <= SC_GEN_V_WAIT; 
            end
            SC_GEN_V_WAIT:begin 
              if(hsync_delay_counter >= HSYNC_START_DELAY)begin
                hsync_delay_counter  <= 0; 
                video_out_sig_gen_st <= SC_GEN_FIFO_RD_REQ;
//                fifo_rd              <= 1'b1;
              end 
              else begin
                hsync_delay_counter <= hsync_delay_counter + 1;
                video_out_sig_gen_st <= SC_GEN_V_WAIT;
              end  
            end
            SC_GEN_FIFO_RD_REQ : begin
                if((fifo_cnt>out_latch_video_i_xsize-1) && start_rd) begin 
                     video_out_sig_gen_st  <= SC_GEN_FIFO_RD_WAIT;  
                     fifo_rd               <= 1'b1;          
                end
            end
            SC_GEN_FIFO_RD_WAIT : begin
                fifo_rd               <= 1'b1;
                video_out_sig_gen_st  <= SC_GEN_H; 
            end
            SC_GEN_H:begin 
                if(video_o_pix_cnt >= out_latch_video_i_xsize -2)begin
                    fifo_rd              <= 1'b0;
                end
                else begin
                    fifo_rd              <= 1'b1;
                end
                if(video_o_pix_cnt == out_latch_video_i_xsize)begin
                    video_o_line_valid  <= 1'b0;
                    video_o_pix_cnt     <= 0;
                    video_out_sig_gen_st <= SC_GEN_H_WAIT;
                end
                else begin
                 video_o_line_valid <= 1'b1;
                 video_o_data         <= {fifo_out[7:0],fifo_out[15:8]}; 
                 video_o_pix_cnt      <= video_o_pix_cnt + 1;
                 video_out_sig_gen_st <= SC_GEN_H;
                end
            end
            SC_GEN_H_WAIT: begin 
              if(hblank_counter >= HBLANK)begin
                hblank_counter       <= 0; 
                if(video_o_line_cnt >= out_latch_video_i_ysize -1)begin
                    video_o_line_cnt     <= 0;
                    video_o_frame_valid  <= 1'b0;
                    video_out_sig_gen_st <= SC_GEN_IDLE;

                end
                else begin
                    video_o_line_cnt     <= video_o_line_cnt + 1;
                    video_out_sig_gen_st <= SC_GEN_FIFO_RD_REQ;
                end
              end 
              else begin
                hblank_counter       <= hblank_counter + 1;
                video_out_sig_gen_st <= SC_GEN_H_WAIT;
              end  
            end
            default : video_out_sig_gen_st <= SC_GEN_IDLE;
        endcase
    end
end



FIFO_DUAL_CLK #(
    .FIFO_DEPTH(FIFO_DEPTH),
    .FIFO_WIDTH(FIFO_WIDTH)
    ) fifo_inst (
    .CLK_WR(clk),         
    .RST_WR(reset),         
    .CLR_WR(fifo_clr),         
    .WRREQ(fifo_wr),          
    .WRDATA(fifo_in),         
    .CLK_RD(pclk),         
    .RST_RD(reset),         
    .CLR_RD(fifo_clr_rd),         
    .RDREQ(fifo_rd),          
    .RDDATA(fifo_out),         
    .EMPTY_RD(fifo_empty),       
    .FIFO_CNT_RD(fifo_cnt)    
    );
META_HARDEN meta_harden_inst1(
    .CLK_DST         (pclk),
    .RST_DST         (reset),
    .SIGNAL_SRC      (fifo_clr),
    .SIGNAL_DST      (fifo_clr_rd)
    );
META_HARDEN_VECTOR #(.bit_width(FIFO_DEPTH)) meta_harden_inst2(
    .CLK_DST         (clk),
    .RST_DST         (reset),
    .SIGNAL_SRC      (fifo_cnt),
    .SIGNAL_DST      (fifo_usedw)
    );

assign fifo_wr = video_i_dav & data_wr_en;
assign fifo_in = video_i_data;
// always @(posedge clk, posedge reset) begin: BT656_GEN_RUN_LOGIC
//     if (reset == 1) begin
//         fifo_in <= 0;
//         lcount <= 0;
//         fifo_wr <= 0;
//         vstate <= 1'b0;
//         run <= 0;
//         field <= 1;
//     end
//     else begin
//         if (video_i_v) begin
//             lcount <= 0;
//         end
//         if (video_i_h) begin
//             lcount <= (lcount + 1);
//         end
//         case (vstate)
//             1'b0: begin
//                 if (video_i_v) begin
//                     field <= (!field);
//                     vstate <= 1'b1;
//                 end
//             end
//             1'b1: begin
//                 if ((video_i_dav && (((!field) && lcount[0]) || (field && (!lcount[0]))))) begin
//                     fifo_wr <= 1'b1;
//                     fifo_in <= video_i_data;
//                 end
//                 else begin
//                     fifo_wr <= 1'b0;
//                 end
//                 if (((!run) && (lcount == (480 >>> 3)))) begin
//                     run <= (1 != 0);
//                 end
//                 if (video_i_eoi) begin
//                     vstate <= 1'b0;
//                 end
//             end
//         endcase
//     end
// end

//`ifdef ILA_DEBUG_VSYNC_HYSNC 

//wire [127 : 0] probe_bt656;

//assign probe_bt656 = { //state,
////                            video_o_data,
////                            2'd0,
//                            start_rd,       
//                            start_rd_d,     
//                            start_video_out,                            
////                            bt656_run,          
////                            bt656_req_v,        
////                            bt656_req_h,                                 
////                            fifo_cnt,
//                            out_latch_video_i_xsize,                             
//                            bt656_st,  
//                            data_wr_en, 
                                   
//                            video_i_v,          
//                            video_i_h,          
//                            video_i_dav,        
////                            video_i_data,       
//                            video_i_eoi,   
////                            fifo_out,     
//                            video_i_xsize,      
////                            video_i_ysize,                         
//                            latch_video_i_xsize, 
////                            bt656_field,        
////                            bt656_line_no,      
////                            bt656_req_xsize,    
////                            bt656_req_ysize,  
//                            video_o_frame_valid,
//                            video_o_line_valid,  
                                                                                                   
//                            pclk,              
////                            bt656_data ,
//                            vxcount,
//                            vycount,
////                            out_line_cnt,
//                            out_frame_cnt,
//                            video_o_data,
////                            video_o_frame_valid_d,
////                            video_o_line_valid_d,
//                            tick1s,                           
//                            fifo_rd,
//                            fifo_clr,
////                            fifo_wr,
//                            fifo_empty,
//                            fifo_usedw,
////                            fifo_clr_rd,
//                            video_out_sig_gen_st,
//                            video_o_pix_cnt,
//                            video_o_line_cnt  
//                            }; 

//ila_0 i_ila_bt656
//(
//	.clk(clk),
//	.probe0(probe_bt656)
//);
//`endif    
endmodule
