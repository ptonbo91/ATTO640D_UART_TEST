`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2018 04:46:09 PM
// Design Name: 
// Module Name: Add_Border
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


module IMG_SHIFT_VERT_CONTROLLER
#( parameter PIX_BITS    =  10,
             LIN_BITS    =  10,
             DATA_BITS   =   8,
             VIDEO_XSIZE = 640,
             VIDEO_YSIZE = 480            
)
(
input                        CLK,
input                        RST,
input     [LIN_BITS-1 : 0]   IMG_SHIFT_VERT,
input                        SCALER_RUN,
input                        SCALER_REQ_V,        
input                        SCALER_REQ_H,             
input      [LIN_BITS-1 : 0]  SCALER_LINE_NO, 
input      [PIX_BITS-1 : 0]  SCALER_PIX_OFF,     
input      [PIX_BITS-1 : 0]  SCALER_REQ_XSIZE,    
input      [LIN_BITS-1 : 0]  SCALER_REQ_YSIZE,
input      [LIN_BITS-1 : 0]  IN_Y_OFF,    
output reg                   IMG_SHIFT_REQ_V,   
output reg                   IMG_SHIFT_REQ_H,   
//output reg                   IMG_SHIFT_FIELD,   
output reg [LIN_BITS-1 : 0]  IMG_SHIFT_LINE_NO, 
output reg [PIX_BITS-1 : 0]  IMG_SHIFT_REQ_XSIZE,
output reg [LIN_BITS-1 : 0]  IMG_SHIFT_REQ_YSIZE,
input                        IMG_SHIFT_I_V,     
input                        IMG_SHIFT_I_H,     
input                        IMG_SHIFT_I_DAV,   
input      [DATA_BITS-1 : 0] IMG_SHIFT_I_DATA,  
input                        IMG_SHIFT_I_EOI,   
input      [PIX_BITS-1 : 0]  IMG_SHIFT_I_XSIZE, 
input      [LIN_BITS-1 : 0]  IMG_SHIFT_I_YSIZE,
output reg                   IMG_SHIFT_O_V,     
output reg                   IMG_SHIFT_O_H,     
output reg                   IMG_SHIFT_O_EOI,   
output reg                   IMG_SHIFT_O_DAV,   
output reg [DATA_BITS-1 : 0] IMG_SHIFT_O_DATA,
output reg [PIX_BITS-1  : 0] IMG_SHIFT_O_XCNT,   
output reg [LIN_BITS-1  : 0] IMG_SHIFT_O_YCNT

 
    );



localparam [4:0] st_idle        = 5'd0,
                 st_req_v       = 5'd1,
                 st_wait_h      = 5'd2,
                 st_add_border  = 5'd3,
//                 st_add_lborder = 5'd4,
//                 st_add_rborder = 5'd5,
                 st_send_data   = 5'd4,
                 //st_req_v       = 5'd6,
                 st_req_new_line = 5'd5,
                 st_req_h       = 5'd6;
//                 st_wait        = 5'd9,
//                 st_wait1       = 5'd10,
//                 st_add_border_delay = 5'd11,
//                 st_add_lborder_delay = 5'd12,
//                 st_add_rborder_delay = 5'd13;
                 
localparam [7:0] BORDER_DELAY  = 8'd4;                
                    
(* mark_debug = "true" *)reg [4:0] state;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] line_count;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] internal_line_count;
(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] IMG_SHIFT_XCNT;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_YCNT;
//(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] IMG_SHIFT_LEFT_CNT;
//(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] IMG_SHIFT_RIGHT_CNT;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP_CNT;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN_CNT;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP_CNT_EVEN;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN_CNT_EVEN;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP_CNT_ODD;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN_CNT_ODD;

//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UD_D;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP_D;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN_D;
//(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] IMG_SHIFT_UD_SEL_D;
//(* mark_debug = "true" *)reg IMG_SHIFT_LR_UPDATE_LATCH;
//(* mark_debug = "true" *)reg IMG_SHIFT_UD_UPDATE_LATCH;
//(* mark_debug = "true" *)reg IMG_SHIFT_UD_UPDATE_LATCH_D;

//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] ADD_BORDER_LINE_NO_EVEN;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] ADD_BORDER_LINE_NO_ODD;

wire [127 : 0] probe0;

reg [7:0]delay_cnt;
reg img_shift_down;
reg [LIN_BITS-1:0] LATCH_IN_Y_OFF;

always @(posedge CLK or posedge RST)begin
    if(RST)begin
        IMG_SHIFT_REQ_V     <= 0;    
        IMG_SHIFT_REQ_H     <= 0;      
//        IMG_SHIFT_FIELD     <= 0;      
        IMG_SHIFT_LINE_NO   <= 0;    
        IMG_SHIFT_REQ_XSIZE <= VIDEO_XSIZE;
        IMG_SHIFT_REQ_YSIZE <= VIDEO_YSIZE;  
        IMG_SHIFT_O_V       <= 0;    
        IMG_SHIFT_O_H       <= 0;    
        IMG_SHIFT_O_EOI     <= 0;  
        IMG_SHIFT_O_DAV     <= 0;  
        IMG_SHIFT_O_DATA    <= 0;
        state               <= st_idle;
        line_count          <= 0; 
        IMG_SHIFT_O_XCNT <= 0;
        IMG_SHIFT_O_YCNT <= 1023;
        IMG_SHIFT_XCNT   <= 0;
        IMG_SHIFT_YCNT   <= 0;
        internal_line_count   <= 0;
        LATCH_IN_Y_OFF   <= 0;
    end
    else begin
    
      if (SCALER_REQ_V == 1'b1) begin
        IMG_SHIFT_O_YCNT <= 1023;   
        IMG_SHIFT_O_XCNT <= 0;   
      end    
      else if (SCALER_REQ_H == 1'b1) begin
        IMG_SHIFT_O_YCNT <= IMG_SHIFT_O_YCNT + 1;  
        IMG_SHIFT_O_XCNT <= 0;
      end
      else if (IMG_SHIFT_O_DAV == 1'b1) begin
        IMG_SHIFT_O_XCNT  <= IMG_SHIFT_O_XCNT  + 1;
      end
    
    
    case(state)
        
        st_idle: begin
            line_count          <= 0;
            internal_line_count <= 0;
            IMG_SHIFT_XCNT      <= 0;
            IMG_SHIFT_YCNT      <= 0;
            IMG_SHIFT_O_V       <= 0;    
            IMG_SHIFT_O_H       <= 0;    
            IMG_SHIFT_O_EOI     <= 0;  
            IMG_SHIFT_O_DAV     <= 0;  
            IMG_SHIFT_O_DATA    <= 0;
////        IMG_SHIFT_REQ_XSIZE <= VIDEO_XSIZE;
////        IMG_SHIFT_REQ_YSIZE <= VIDEO_YSIZE - IMG_UP_SHIFT_VERT;  
//          IMG_SHIFT_REQ_XSIZE <= SCALER_REQ_XSIZE;
//          IMG_SHIFT_REQ_YSIZE <= SCALER_REQ_YSIZE - IMG_UP_SHIFT_VERT;  
//          IMG_SHIFT_LINE_NO   <= IMG_UP_SHIFT_VERT;  
            
            IMG_SHIFT_REQ_XSIZE <= SCALER_REQ_XSIZE;
            if(IMG_SHIFT_VERT<= 128)begin      
                IMG_SHIFT_REQ_YSIZE <= SCALER_REQ_YSIZE - (128 - IMG_SHIFT_VERT);  
                IMG_SHIFT_LINE_NO   <= (LATCH_IN_Y_OFF +128) - IMG_SHIFT_VERT;
//                IMG_SHIFT_LINE_NO   <= 128 - IMG_SHIFT_VERT;
                img_shift_down      <= 1'b0;
            end
            else begin                
                IMG_SHIFT_REQ_YSIZE <= SCALER_REQ_YSIZE - (IMG_SHIFT_VERT - 128);  
//                IMG_SHIFT_LINE_NO   <= 0;
                IMG_SHIFT_LINE_NO   <= LATCH_IN_Y_OFF;
                img_shift_down      <= 1'b1;
            end
            IMG_SHIFT_REQ_V      <= 1'b0;
            IMG_SHIFT_REQ_H     <= 1'b0;
            if(SCALER_REQ_V)begin
                IMG_SHIFT_O_V   <= 1'b1;     
                IMG_SHIFT_REQ_V <= 1'b1;  
                state             <= st_req_v;                                            
            end
        end

        st_req_v : begin
            IMG_SHIFT_O_V     <= 1'b0;
            IMG_SHIFT_REQ_V   <= 1'b0;
            state             <= st_wait_h;            
        end 
               
        st_wait_h: begin    
            IMG_SHIFT_O_DAV <= 0;       
            if(SCALER_REQ_H)begin
                IMG_SHIFT_YCNT <= IMG_SHIFT_YCNT + 1;
                IMG_SHIFT_XCNT <= 0;
                IMG_SHIFT_O_H    <= 1'b1;
                line_count       <= line_count + 1;
                // if((line_count >= (((SCALER_REQ_YSIZE - IMG_SHIFT_REQ_YSIZE)>>1))) & (line_count < ((SCALER_REQ_YSIZE)-((SCALER_REQ_YSIZE - IMG_SHIFT_REQ_YSIZE)>>1))))begin
                //if(line_count < (SCALER_REQ_YSIZE - IMG_UP_SHIFT_VERT))begin
                if(img_shift_down == 1'b1)begin
                    if(line_count >= (IMG_SHIFT_VERT-128))begin
                        state      <= st_req_new_line;               
                    end
                    else begin
                        state      <= st_add_border;
                    end 
                end
                else begin
                    if(line_count < (SCALER_REQ_YSIZE - (128 - IMG_SHIFT_VERT)))begin
                        state      <= st_req_new_line;               
                    end
                    else begin
                        state      <= st_add_border;
                    end                   
                end                           
            end            
            if(line_count == (SCALER_REQ_YSIZE))begin
                state           <= st_idle;
                IMG_SHIFT_O_EOI <= 1'b1;         
            end            
        end
               
        st_add_border: begin
            IMG_SHIFT_O_H <= 1'b0;
            if(IMG_SHIFT_XCNT == SCALER_REQ_XSIZE)begin
                IMG_SHIFT_O_DAV  <= 1'b0;  
                IMG_SHIFT_O_DATA <= 0;
                IMG_SHIFT_XCNT <= 0;
                state            <= st_wait_h;
            end
            else begin
                IMG_SHIFT_XCNT <= IMG_SHIFT_XCNT + 1;
                IMG_SHIFT_O_DAV  <= 1'b1;  
                IMG_SHIFT_O_DATA <= 8'h10;
                state             <= st_add_border;
            end
        end
        
        st_req_new_line : begin
                IMG_SHIFT_O_H       <= 1'b0;
                state               <= st_req_h;
                internal_line_count <= internal_line_count +1;
        end        
               
        st_req_h : begin
                IMG_SHIFT_REQ_H <= 1'b1;
                state           <= st_send_data;        
        end
     
        st_send_data : begin
            IMG_SHIFT_REQ_H <= 1'b0;
            if(IMG_SHIFT_I_DAV)begin     
                IMG_SHIFT_O_DAV  <= 1'b1;  
                IMG_SHIFT_O_DATA <= IMG_SHIFT_I_DATA; 
                if(IMG_SHIFT_XCNT == IMG_SHIFT_REQ_XSIZE - 1 )begin
                    IMG_SHIFT_XCNT <= 0;
                    state             <= st_wait_h;
                    IMG_SHIFT_LINE_NO <= IMG_SHIFT_LINE_NO + 1 ;
//                    IMG_SHIFT_LINE_NO <= IMG_SHIFT_LINE_NO + 1 + LATCH_IN_Y_OFF;
                end
                else begin
                    IMG_SHIFT_XCNT <= IMG_SHIFT_XCNT + 1;
                    state            <= st_send_data;
                end
            end
            else begin
                state             <= st_send_data;
                IMG_SHIFT_O_DAV  <= 1'b0; 
                IMG_SHIFT_O_DATA <= 0;
            end   
             
        end    
    endcase
    
   if(SCALER_REQ_V)begin   
        line_count          <= 0;
        internal_line_count <= 0;
        IMG_SHIFT_XCNT      <= 0;
        IMG_SHIFT_YCNT      <= 0;
        IMG_SHIFT_O_V       <= 0;    
        IMG_SHIFT_O_H       <= 0;    
        IMG_SHIFT_O_EOI     <= 0;  
        IMG_SHIFT_O_DAV     <= 0;  
        IMG_SHIFT_O_DATA    <= 0;
//            IMG_SHIFT_REQ_XSIZE <= VIDEO_XSIZE;
//            IMG_SHIFT_REQ_YSIZE <= VIDEO_YSIZE - IMG_UP_SHIFT_VERT;           
//        IMG_SHIFT_REQ_XSIZE <= SCALER_REQ_XSIZE;
//        IMG_SHIFT_REQ_YSIZE <= SCALER_REQ_YSIZE - IMG_SHIFT_VERT;  
//        IMG_SHIFT_LINE_NO   <= IMG_SHIFT_VERT;
        IMG_SHIFT_REQ_XSIZE <= SCALER_REQ_XSIZE;
        LATCH_IN_Y_OFF      <= IN_Y_OFF;
        if(IMG_SHIFT_VERT<= 128)begin      
            IMG_SHIFT_REQ_YSIZE <= SCALER_REQ_YSIZE - (128 - IMG_SHIFT_VERT);  
//            IMG_SHIFT_LINE_NO   <= 128 - IMG_SHIFT_VERT;
            IMG_SHIFT_LINE_NO   <= (LATCH_IN_Y_OFF + 128) - IMG_SHIFT_VERT;
            img_shift_down      <= 1'b0;
        end
        else begin                
            IMG_SHIFT_REQ_YSIZE <= SCALER_REQ_YSIZE - (IMG_SHIFT_VERT - 128);  
//            IMG_SHIFT_LINE_NO   <= 0;
            IMG_SHIFT_LINE_NO   <= LATCH_IN_Y_OFF;
            img_shift_down      <= 1'b1;
        end
        IMG_SHIFT_REQ_V     <= 1'b0;
        IMG_SHIFT_REQ_H     <= 1'b0;        
        IMG_SHIFT_O_V       <= 1'b1;     
        IMG_SHIFT_REQ_V     <= 1'b1;  
        state               <= st_req_v;                                            
    end
    
    end



end

//wire [127 : 0] probe_add_border;

//assign probe_add_border = { state,
//                            BT656_REQ_V,           
//                            BT656_REQ_H,           
//                            BT656_FIELD,           
//                            BT656_LINE_NO,         
//                            BT656_REQ_XSIZE,       
//                            BT656_REQ_YSIZE,       
//                            ADD_BORDER_REQ_V,      
//                            ADD_BORDER_REQ_H,      
//                            ADD_BORDER_FIELD,      
//                            ADD_BORDER_LINE_NO,    
//                            ADD_BORDER_REQ_XSIZE,    
//                            ADD_BORDER_I_V,        
//                            ADD_BORDER_I_H,        
//                            ADD_BORDER_I_DAV,           
//                            ADD_BORDER_I_EOI,      
//                            ADD_BORDER_I_XSIZE,    
//                            ADD_BORDER_I_YSIZE,
//                            line_count, 
//                            ADD_BORDER_O_XCNT,
//                            ADD_BORDER_O_YCNT,
//                            SCALER_RUN,
//                            ADD_BORDER_O_DAV,
//                            ADD_BORDER_O_V,
//                            ADD_BORDER_O_EOI,
//                            ADD_BORDER_O_H,
//                            8'd0
//                            }; 

//ila_0 i_ila_add_border
//(
//  .clk(CLK),
//  .probe0(probe_add_border)
//);

//wire [127 : 0] probe_add_border;

//assign probe_add_border = { state,
//                            BT656_REQ_V,           
//                            BT656_REQ_H,           
//                            BT656_FIELD,           
////                            BT656_LINE_NO,         
////                            BT656_REQ_XSIZE,       
////                            BT656_REQ_YSIZE,       
//                            ADD_BORDER_REQ_V,      
//                            ADD_BORDER_REQ_H,      
//                            ADD_BORDER_FIELD,      
////                            ADD_BORDER_LINE_NO,    
////                            ADD_BORDER_REQ_XSIZE,    
//                            ADD_BORDER_I_V,        
//                            ADD_BORDER_I_H,        
//                            ADD_BORDER_I_DAV,           
//                            ADD_BORDER_I_EOI,      
////                            ADD_BORDER_I_XSIZE,    
////                            ADD_BORDER_I_YSIZE,
//                            line_count,
//                            internal_line_count, 
//                            ADD_BORDER_O_XCNT,
////                            ADD_BORDER_O_YCNT,
////                            SCALER_RUN,
//                            ADD_BORDER_O_DATA,
//                            ADD_BORDER_O_DAV,
//                            ADD_BORDER_O_V,
//                            ADD_BORDER_O_EOI,
//                            ADD_BORDER_O_H,
//                            LATCH_IMG_CROP_LEFT[7:0],  
//                            LATCH_IMG_CROP_RIGHT[6:0], 
//                            IMG_CROP_TOP,   
////                            IMG_CROP_BOTTOM, 
//                            IMG_CROP_TOP_D,
////                            IMG_CROP_BOTTOM_D, 
//                            LATCH_IMG_CROP_TOP, 
//                            LATCH_IMG_CROP_BOTTOM                         
////                            8'd0
//                            }; 


//ila_0 i_ila_add_border
//(
//  .clk(CLK),
//  .probe0(probe_add_border)
//);


//assign probe0 = { 2'd0, 
//                  SCALER_PIX_OFF,
//                  state,
//                  line_count,
//                  IMG_SHIFT_XCNT,
//                  IMG_SHIFT_YCNT,
//                  SCALER_RUN,         
//                  SCALER_REQ_V,       
//                  SCALER_REQ_H,       
//                  SCALER_LINE_NO,            
//                  IMG_SHIFT_REQ_V,    
//                  IMG_SHIFT_REQ_H,    
//                  IMG_SHIFT_LINE_NO,  
//                  IMG_SHIFT_REQ_XSIZE,
//                  IMG_SHIFT_REQ_YSIZE,
//                  IMG_SHIFT_I_V,      
//                  IMG_SHIFT_I_H,      
//                  IMG_SHIFT_I_DAV,    
//                  IMG_SHIFT_I_DATA,   
//                  IMG_SHIFT_I_EOI,    
////                  IMG_SHIFT_I_XSIZE,  
////                  IMG_SHIFT_I_YSIZE,  
//                  IMG_SHIFT_O_V,      
//                  IMG_SHIFT_O_H,      
//                  IMG_SHIFT_O_EOI,    
//                  IMG_SHIFT_O_DAV,    
//                  IMG_SHIFT_O_DATA,
//                  IMG_SHIFT_VERT  
                                                            
//                  };

// TOII_TUVE_ila img_shift_vert_ila (
//  .clk(CLK), // input wire clk
//  .probe0(probe0) // input wire [127:0] probe0
// );
          



endmodule

//////////////////// IMAGE UP ONLY /////////////////////////////////////////////////
//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 05/04/2018 04:46:09 PM
//// Design Name: 
//// Module Name: Add_Border
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module IMG_SHIFT_VERT_CONTROLLER
//#( parameter PIX_BITS    =  10,
//             LIN_BITS    =  10,
//             DATA_BITS   =   8,
//             VIDEO_XSIZE = 640,
//             VIDEO_YSIZE = 480            
//)
//(
//input                        CLK,
//input                        RST,
//input     [LIN_BITS-1 : 0]   IMG_UP_SHIFT_VERT,
//input                        SCALER_RUN,
//input                        SCALER_REQ_V,        
//input                        SCALER_REQ_H,             
//input      [LIN_BITS-1 : 0]  SCALER_LINE_NO, 
//input      [PIX_BITS-1 : 0]  SCALER_PIX_OFF,     
//input      [PIX_BITS-1 : 0]  SCALER_REQ_XSIZE,    
//input      [LIN_BITS-1 : 0]  SCALER_REQ_YSIZE,    
//output reg                   IMG_SHIFT_REQ_V,   
//output reg                   IMG_SHIFT_REQ_H,   
////output reg                   IMG_SHIFT_FIELD,   
//output reg [LIN_BITS-1 : 0]  IMG_SHIFT_LINE_NO, 
//output reg [PIX_BITS-1 : 0]  IMG_SHIFT_REQ_XSIZE,
//output reg [LIN_BITS-1 : 0]  IMG_SHIFT_REQ_YSIZE,
//input                        IMG_SHIFT_I_V,     
//input                        IMG_SHIFT_I_H,     
//input                        IMG_SHIFT_I_DAV,   
//input      [DATA_BITS-1 : 0] IMG_SHIFT_I_DATA,  
//input                        IMG_SHIFT_I_EOI,   
//input      [PIX_BITS-1 : 0]  IMG_SHIFT_I_XSIZE, 
//input      [LIN_BITS-1 : 0]  IMG_SHIFT_I_YSIZE,
//output reg                   IMG_SHIFT_O_V,     
//output reg                   IMG_SHIFT_O_H,     
//output reg                   IMG_SHIFT_O_EOI,   
//output reg                   IMG_SHIFT_O_DAV,   
//output reg [DATA_BITS-1 : 0] IMG_SHIFT_O_DATA,
//output reg [PIX_BITS-1  : 0] IMG_SHIFT_O_XCNT,   
//output reg [LIN_BITS-1  : 0] IMG_SHIFT_O_YCNT

 
//    );



//localparam [4:0] st_idle        = 5'd0,
//                 st_req_v       = 5'd1,
//                 st_wait_h      = 5'd2,
//                 st_add_border  = 5'd3,
////                 st_add_lborder = 5'd4,
////                 st_add_rborder = 5'd5,
//                 st_send_data   = 5'd4,
//                 //st_req_v       = 5'd6,
//                 st_req_new_line = 5'd5,
//                 st_req_h       = 5'd6;
////                 st_wait        = 5'd9,
////                 st_wait1       = 5'd10,
////                 st_add_border_delay = 5'd11,
////                 st_add_lborder_delay = 5'd12,
////                 st_add_rborder_delay = 5'd13;
                 
//localparam [7:0] BORDER_DELAY  = 8'd4;                
                    
//(* mark_debug = "true" *)reg [4:0] state;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] line_count;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] internal_line_count;
//(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] IMG_SHIFT_XCNT;
//(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_YCNT;
////(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] IMG_SHIFT_LEFT_CNT;
////(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] IMG_SHIFT_RIGHT_CNT;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP_CNT;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN_CNT;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP_CNT_EVEN;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN_CNT_EVEN;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP_CNT_ODD;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN_CNT_ODD;

////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UD_D;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_UP_D;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] IMG_SHIFT_DOWN_D;
////(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] IMG_SHIFT_UD_SEL_D;
////(* mark_debug = "true" *)reg IMG_SHIFT_LR_UPDATE_LATCH;
////(* mark_debug = "true" *)reg IMG_SHIFT_UD_UPDATE_LATCH;
////(* mark_debug = "true" *)reg IMG_SHIFT_UD_UPDATE_LATCH_D;

////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] ADD_BORDER_LINE_NO_EVEN;
////(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] ADD_BORDER_LINE_NO_ODD;

//wire [127 : 0] probe0;

//reg [7:0]delay_cnt;


//always @(posedge CLK or posedge RST)begin
//    if(RST)begin
//        IMG_SHIFT_REQ_V     <= 0;    
//        IMG_SHIFT_REQ_H     <= 0;      
////        IMG_SHIFT_FIELD     <= 0;      
//        IMG_SHIFT_LINE_NO   <= 0;    
//        IMG_SHIFT_REQ_XSIZE <= VIDEO_XSIZE;
//        IMG_SHIFT_REQ_YSIZE <= VIDEO_YSIZE;  
//        IMG_SHIFT_O_V       <= 0;    
//        IMG_SHIFT_O_H       <= 0;    
//        IMG_SHIFT_O_EOI     <= 0;  
//        IMG_SHIFT_O_DAV     <= 0;  
//        IMG_SHIFT_O_DATA    <= 0;
//        state               <= st_idle;
//        line_count          <= 0; 
//        IMG_SHIFT_O_XCNT <= 0;
//        IMG_SHIFT_O_YCNT <= 1023;
//        IMG_SHIFT_XCNT   <= 0;
//        IMG_SHIFT_YCNT   <= 0;
//        internal_line_count   <= 0;
//    end
//    else begin
    
//      if (SCALER_REQ_V == 1'b1) begin
//        IMG_SHIFT_O_YCNT <= 1023;   
//        IMG_SHIFT_O_XCNT <= 0;    
//      end    
//      else if (SCALER_REQ_H == 1'b1) begin
//        IMG_SHIFT_O_YCNT <= IMG_SHIFT_O_YCNT + 1;  
//        IMG_SHIFT_O_XCNT <= 0;
//      end
//      else if (IMG_SHIFT_O_DAV == 1'b1) begin
//        IMG_SHIFT_O_XCNT  <= IMG_SHIFT_O_XCNT  + 1;
//      end
    
    
//    case(state)
        
//        st_idle: begin
//            line_count          <= 0;
//            internal_line_count <= 0;
//            IMG_SHIFT_XCNT      <= 0;
//            IMG_SHIFT_YCNT      <= 0;
//            IMG_SHIFT_O_V       <= 0;    
//            IMG_SHIFT_O_H       <= 0;    
//            IMG_SHIFT_O_EOI     <= 0;  
//            IMG_SHIFT_O_DAV     <= 0;  
//            IMG_SHIFT_O_DATA    <= 0;
////            IMG_SHIFT_REQ_XSIZE <= VIDEO_XSIZE;
////            IMG_SHIFT_REQ_YSIZE <= VIDEO_YSIZE - IMG_UP_SHIFT_VERT;           
//            IMG_SHIFT_REQ_XSIZE <= SCALER_REQ_XSIZE;
//            IMG_SHIFT_REQ_YSIZE <= SCALER_REQ_YSIZE - IMG_UP_SHIFT_VERT;  
//            IMG_SHIFT_LINE_NO   <= IMG_UP_SHIFT_VERT;
//            IMG_SHIFT_REQ_V      <= 1'b0;
//            IMG_SHIFT_REQ_H     <= 1'b0;
//            if(SCALER_REQ_V)begin
//                IMG_SHIFT_O_V   <= 1'b1;     
//                IMG_SHIFT_REQ_V <= 1'b1;  
//                state             <= st_req_v;                                            
//            end
//        end

//        st_req_v : begin
//            IMG_SHIFT_O_V     <= 1'b0;
//            IMG_SHIFT_REQ_V   <= 1'b0;
//            state             <= st_wait_h;            
//        end 
               
//        st_wait_h: begin    
//            IMG_SHIFT_O_DAV <= 0;       
//            if(SCALER_REQ_H)begin
//                IMG_SHIFT_YCNT <= IMG_SHIFT_YCNT + 1;
//                IMG_SHIFT_XCNT <= 0;
//                IMG_SHIFT_O_H    <= 1'b1;
//                line_count       <= line_count + 1;
//                // if((line_count >= (((SCALER_REQ_YSIZE - IMG_SHIFT_REQ_YSIZE)>>1))) & (line_count < ((SCALER_REQ_YSIZE)-((SCALER_REQ_YSIZE - IMG_SHIFT_REQ_YSIZE)>>1))))begin
//                if(line_count < (SCALER_REQ_YSIZE - IMG_UP_SHIFT_VERT))begin
//                    state      <= st_req_new_line;               
//                end
//                else begin
//                    state      <= st_add_border;
//                end                          
//            end            
//            if(line_count == (SCALER_REQ_YSIZE))begin
//                state           <= st_idle;
//                IMG_SHIFT_O_EOI <= 1'b1;         
//            end            
//        end
               
//        st_add_border: begin
//            IMG_SHIFT_O_H <= 1'b0;
//            if(IMG_SHIFT_XCNT == SCALER_REQ_XSIZE)begin
//                IMG_SHIFT_O_DAV  <= 1'b0;  
//                IMG_SHIFT_O_DATA <= 0;
//                IMG_SHIFT_XCNT <= 0;
//                state            <= st_wait_h;
//            end
//            else begin
//                IMG_SHIFT_XCNT <= IMG_SHIFT_XCNT + 1;
//                IMG_SHIFT_O_DAV  <= 1'b1;  
//                IMG_SHIFT_O_DATA <= 8'h10;
//                state             <= st_add_border;
//            end
//        end
        
//        st_req_new_line : begin
//                IMG_SHIFT_O_H       <= 1'b0;
//                state               <= st_req_h;
//                internal_line_count <= internal_line_count +1;
//        end        
               
//        st_req_h : begin
//                IMG_SHIFT_REQ_H <= 1'b1;
//                state           <= st_send_data;        
//        end
     
//        st_send_data : begin
//            IMG_SHIFT_REQ_H <= 1'b0;
//            if(IMG_SHIFT_I_DAV)begin     
//                IMG_SHIFT_O_DAV  <= 1'b1;  
//                IMG_SHIFT_O_DATA <= IMG_SHIFT_I_DATA; 
//                if(IMG_SHIFT_XCNT == IMG_SHIFT_REQ_XSIZE - 1 )begin
//                    IMG_SHIFT_XCNT <= 0;
//                    state             <= st_wait_h;
//                    IMG_SHIFT_LINE_NO <= IMG_SHIFT_LINE_NO + 1;
//                end
//                else begin
//                    IMG_SHIFT_XCNT <= IMG_SHIFT_XCNT + 1;
//                    state            <= st_send_data;
//                end
//            end
//            else begin
//                state             <= st_send_data;
//                IMG_SHIFT_O_DAV  <= 1'b0; 
//                IMG_SHIFT_O_DATA <= 0;
//            end   
             
//        end    
//    endcase
    
//   if(SCALER_REQ_V)begin   
//        line_count          <= 0;
//        internal_line_count <= 0;
//        IMG_SHIFT_XCNT      <= 0;
//        IMG_SHIFT_YCNT      <= 0;
//        IMG_SHIFT_O_V       <= 0;    
//        IMG_SHIFT_O_H       <= 0;    
//        IMG_SHIFT_O_EOI     <= 0;  
//        IMG_SHIFT_O_DAV     <= 0;  
//        IMG_SHIFT_O_DATA    <= 0;
////            IMG_SHIFT_REQ_XSIZE <= VIDEO_XSIZE;
////            IMG_SHIFT_REQ_YSIZE <= VIDEO_YSIZE - IMG_UP_SHIFT_VERT;           
//        IMG_SHIFT_REQ_XSIZE <= SCALER_REQ_XSIZE;
//        IMG_SHIFT_REQ_YSIZE <= SCALER_REQ_YSIZE - IMG_UP_SHIFT_VERT;  
//        IMG_SHIFT_LINE_NO   <= IMG_UP_SHIFT_VERT;
//        IMG_SHIFT_REQ_V     <= 1'b0;
//        IMG_SHIFT_REQ_H     <= 1'b0;        
//        IMG_SHIFT_O_V       <= 1'b1;     
//        IMG_SHIFT_REQ_V     <= 1'b1;  
//        state               <= st_req_v;                                            
//    end
    
//    end



//end

////wire [127 : 0] probe_add_border;

////assign probe_add_border = { state,
////                            BT656_REQ_V,           
////                            BT656_REQ_H,           
////                            BT656_FIELD,           
////                            BT656_LINE_NO,         
////                            BT656_REQ_XSIZE,       
////                            BT656_REQ_YSIZE,       
////                            ADD_BORDER_REQ_V,      
////                            ADD_BORDER_REQ_H,      
////                            ADD_BORDER_FIELD,      
////                            ADD_BORDER_LINE_NO,    
////                            ADD_BORDER_REQ_XSIZE,    
////                            ADD_BORDER_I_V,        
////                            ADD_BORDER_I_H,        
////                            ADD_BORDER_I_DAV,           
////                            ADD_BORDER_I_EOI,      
////                            ADD_BORDER_I_XSIZE,    
////                            ADD_BORDER_I_YSIZE,
////                            line_count, 
////                            ADD_BORDER_O_XCNT,
////                            ADD_BORDER_O_YCNT,
////                            SCALER_RUN,
////                            ADD_BORDER_O_DAV,
////                            ADD_BORDER_O_V,
////                            ADD_BORDER_O_EOI,
////                            ADD_BORDER_O_H,
////                            8'd0
////                            }; 

////ila_0 i_ila_add_border
////(
////  .clk(CLK),
////  .probe0(probe_add_border)
////);

////wire [127 : 0] probe_add_border;

////assign probe_add_border = { state,
////                            BT656_REQ_V,           
////                            BT656_REQ_H,           
////                            BT656_FIELD,           
//////                            BT656_LINE_NO,         
//////                            BT656_REQ_XSIZE,       
//////                            BT656_REQ_YSIZE,       
////                            ADD_BORDER_REQ_V,      
////                            ADD_BORDER_REQ_H,      
////                            ADD_BORDER_FIELD,      
//////                            ADD_BORDER_LINE_NO,    
//////                            ADD_BORDER_REQ_XSIZE,    
////                            ADD_BORDER_I_V,        
////                            ADD_BORDER_I_H,        
////                            ADD_BORDER_I_DAV,           
////                            ADD_BORDER_I_EOI,      
//////                            ADD_BORDER_I_XSIZE,    
//////                            ADD_BORDER_I_YSIZE,
////                            line_count,
////                            internal_line_count, 
////                            ADD_BORDER_O_XCNT,
//////                            ADD_BORDER_O_YCNT,
//////                            SCALER_RUN,
////                            ADD_BORDER_O_DATA,
////                            ADD_BORDER_O_DAV,
////                            ADD_BORDER_O_V,
////                            ADD_BORDER_O_EOI,
////                            ADD_BORDER_O_H,
////                            LATCH_IMG_CROP_LEFT[7:0],  
////                            LATCH_IMG_CROP_RIGHT[6:0], 
////                            IMG_CROP_TOP,   
//////                            IMG_CROP_BOTTOM, 
////                            IMG_CROP_TOP_D,
//////                            IMG_CROP_BOTTOM_D, 
////                            LATCH_IMG_CROP_TOP, 
////                            LATCH_IMG_CROP_BOTTOM                         
//////                            8'd0
////                            }; 


////ila_0 i_ila_add_border
////(
////  .clk(CLK),
////  .probe0(probe_add_border)
////);


//assign probe0 = { 2'd0, 
//                  SCALER_PIX_OFF,
//                  state,
//                  line_count,
//                  IMG_SHIFT_XCNT,
//                  IMG_SHIFT_YCNT,
//                  SCALER_RUN,         
//                  SCALER_REQ_V,       
//                  SCALER_REQ_H,       
//                  SCALER_LINE_NO,            
//                  IMG_SHIFT_REQ_V,    
//                  IMG_SHIFT_REQ_H,    
//                  IMG_SHIFT_LINE_NO,  
//                  IMG_SHIFT_REQ_XSIZE,
//                  IMG_SHIFT_REQ_YSIZE,
//                  IMG_SHIFT_I_V,      
//                  IMG_SHIFT_I_H,      
//                  IMG_SHIFT_I_DAV,    
//                  IMG_SHIFT_I_DATA,   
//                  IMG_SHIFT_I_EOI,    
////                  IMG_SHIFT_I_XSIZE,  
////                  IMG_SHIFT_I_YSIZE,  
//                  IMG_SHIFT_O_V,      
//                  IMG_SHIFT_O_H,      
//                  IMG_SHIFT_O_EOI,    
//                  IMG_SHIFT_O_DAV,    
//                  IMG_SHIFT_O_DATA,
//                  IMG_UP_SHIFT_VERT  
                                                            
//                  };

// TOII_TUVE_ila img_shift_vert_ila (
//  .clk(CLK), // input wire clk
//  .probe0(probe0) // input wire [127:0] probe0
// );
          



//endmodule