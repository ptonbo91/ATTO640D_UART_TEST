`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2018 04:46:09 PM
// Design Name: 
// Module Name: video
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
//`define ILA_DEBUG_USB_VIDEO_GEN

module usb_video_data_input_gen
#( parameter PIX_BITS  = 10,
             LIN_BITS  = 10,
             DATA_BITS = 16         
)
(
(* mark_debug = "true" *)input                        clk,
(* mark_debug = "true" *)input                        rst,
(* mark_debug = "true" *)input                        video_i_v,     
(* mark_debug = "true" *)input                        video_i_h,     
(* mark_debug = "true" *)input                        video_i_dav,   
(* mark_debug = "true" *)input      [DATA_BITS-1: 0]  video_i_data,  
(* mark_debug = "true" *)input                        video_i_eoi,   
(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  video_i_xsize, 
(* mark_debug = "true" *)input      [LIN_BITS-1 : 0]  video_i_ysize,
(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  video_req_xsize, 
(* mark_debug = "true" *)input      [LIN_BITS-1 : 0]  video_req_ysize,
(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  add_left_pix,
(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  add_right_pix,
(* mark_debug = "true" *)output reg                   video_o_v,     
(* mark_debug = "true" *)output reg                   video_o_h,     
(* mark_debug = "true" *)output reg                   video_o_eoi,   
(* mark_debug = "true" *)output reg                   video_o_dav,   
(* mark_debug = "true" *)output reg [DATA_BITS-1 : 0] video_o_data  

    );



localparam [4:0] st_idle        = 5'd0,
                 st_gen_h       = 5'd1,
                 st_wait_h      = 5'd2,
                 st_video       = 5'd3,
                 st_add_lborder = 5'd4,
                 st_add_rborder = 5'd5,
                 st_send_data   = 5'd6,
                 st_req_new_line = 5'd7,
                 st_req_h       = 5'd8,
                 st_wait        = 5'd9,
                 st_wait1       = 5'd10,
                 st_video_delay = 5'd11,
                 st_add_lborder_delay = 5'd12,
                 st_add_rborder_delay = 5'd13;
                 
localparam [7:0] BORDER_DELAY  = 8'd4;                
                    
(* mark_debug = "true" *)reg [4:0] state;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] line_count;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] internal_line_count;
(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] video_o_xcnt;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] video_o_ycnt;



reg [7:0]delay_cnt;


always @(posedge clk or posedge rst)begin
    if(rst)begin 
        video_o_v         <= 0;    
        video_o_h         <= 0;    
        video_o_eoi       <= 0;  
        video_o_dav       <= 0;  
        video_o_data      <= 0;
        state             <= st_idle;
        line_count        <= 0; 
        video_o_xcnt      <= 0;
        video_o_ycnt      <= 0;
        delay_cnt         <= 0;
        internal_line_count   <= 0;
    end
    else begin
    
    case(state)
        
        st_idle: begin
            line_count           <= 0;
            internal_line_count  <= 0; 
            video_o_h       <= 0;    
            video_o_v       <= 0; 
            video_o_eoi     <= 0;  
            video_o_dav     <= 0;  
            video_o_data    <= 0;
            if(video_i_v)begin  
                state          <= st_wait_h;                                                
            end
        end            

        st_wait_h: begin           
            if(video_i_h)begin
                line_count     <= line_count + 1;
                if((line_count >= (((video_i_ysize - video_req_ysize)>>1))) & (line_count < ((video_i_ysize)-((video_i_ysize - video_req_ysize)>>1))))begin
                    state <= st_gen_h;                      
                    if(line_count == (((video_i_ysize - video_req_ysize)>>1)))begin
                        video_o_v  <= 1'b1; 
                    end
                end
                else begin
//                    state <= st_video;
                    state <= st_wait_h;
                end                          
            end       
            if(line_count == (video_i_ysize))begin
                state       <= st_idle;
                video_o_eoi <= 1'b1;         
            end            
        end
               
        st_video: begin
            video_o_h <= 1'b0;
            if(video_o_xcnt == video_i_xsize)begin
                video_o_dav  <= 1'b0;  
                video_o_data <= 0;
                video_o_xcnt <= 0;
                state        <= st_wait_h;
            end
            else begin
                video_o_xcnt <= video_o_xcnt + 1;
                video_o_dav  <= 1'b1;  
                video_o_data <= 24'h108080;
                state        <= st_video;
            end
        end
        
        st_gen_h : begin
                video_o_v           <= 1'b0; 
                video_o_h           <= 1'b1;
                state               <= st_send_data;//st_add_lborder;
                internal_line_count <= internal_line_count +1;
        end
               
//        st_add_lborder: begin
//               video_o_h <= 1'b0; 
//               if(video_o_xcnt == add_left_pix)begin
//                    video_o_dav  <= 1'b0;  
//                    video_o_data <= 0;
//                    video_o_xcnt <= 0;
//                    state        <= st_send_data;
//                end
//                else begin
//                    video_o_xcnt <= video_o_xcnt + 1;
//                    video_o_dav  <= 1'b1;  
//                    video_o_data <= 24'h108080 ;
//                    state        <= st_add_lborder;        
//                end                              
//        end
        st_send_data : begin
            video_o_h <= 1'b0;
            if(video_i_dav)begin   
                if(video_o_xcnt >= (({1'b0,video_i_xsize[PIX_BITS-1:1]} - {1'b0,video_req_xsize[PIX_BITS-1:1]})- add_left_pix) && (video_o_xcnt < (({1'b0,video_i_xsize[PIX_BITS-1:1]} - {1'b0,video_req_xsize[PIX_BITS-1:1]}))+add_right_pix+video_req_xsize))begin
                    video_o_dav  <= 1'b1;  
                end
                else begin
                    video_o_dav  <= 1'b0;
                end
                video_o_data <= video_i_data; 
                if(video_o_xcnt == (({1'b0,video_i_xsize[PIX_BITS-1:1]} - {1'b0,video_req_xsize[PIX_BITS-1:1]}))+add_right_pix+video_req_xsize-1)begin
                    video_o_xcnt  <= 0;
                    state         <= st_wait1;
                end
                else begin
                    video_o_xcnt <= video_o_xcnt + 1;
                    state        <= st_send_data;
                end
            end
            else begin
                state        <= st_send_data;
                video_o_dav  <= 1'b0; 
                video_o_data <= 0;
            end   
             
        end
        st_wait1 : begin
            video_o_dav  <= 1'b0; 
            video_o_data <= 0;
            state        <= st_wait_h;//st_add_rborder;
        end
        
        st_add_rborder: begin
                if(video_o_xcnt == add_right_pix)begin
                    video_o_dav  <= 1'b0;  
                    video_o_data <= 0;
                    video_o_xcnt <= 0;
                    state        <= st_wait_h;
                end
                else begin
                    video_o_xcnt <= video_o_xcnt + 1;
                    video_o_dav  <= 1'b1;  
                    video_o_data <= 24'h108080;
                    state        <= st_add_rborder;     
                end                              
        end
    endcase
    end
end

`ifdef ILA_DEBUG_USB_VIDEO_GEN 

wire [127 : 0] probe_bt656;

assign probe_bt656 = { //state,  
                            3'd0,
                            state ,                        
                            video_i_v,          
                            video_i_h,          
                            video_i_dav,        
                            video_i_data,       
                            video_i_eoi,   
                            video_o_v,       
                            video_o_h,       
                            video_o_eoi,     
                            video_o_dav,     
                            video_o_data,                            
                            video_i_xsize,      
                            video_i_ysize, 
                            video_req_xsize, 
                            video_req_ysize, 
//                            add_left_pix,    
//                            add_right_pix,   
                            line_count,          
                            internal_line_count, 
                            video_o_xcnt,         
                            video_o_ycnt        
                                                         

                            }; 

ila_0 i_ila_bt656
(
	.clk(clk),
	.probe0(probe_bt656)
);
`endif    
endmodule