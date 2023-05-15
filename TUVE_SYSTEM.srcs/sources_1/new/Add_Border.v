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


module Add_Border
#( parameter PIX_BITS  = 10,
             LIN_BITS  = 10,
             DATA_BITS = 24,
             VIDEO_XSIZE = 640,
             VIDEO_YSIZE = 480            
)
(
(* mark_debug = "true" *)input                        CLK,
(* mark_debug = "true" *)input                        RST,
(* mark_debug = "true" *)input                        SCALER_RUN,
(* mark_debug = "true" *)input                        ZOOM_ENABLE,
(* mark_debug = "true" *)output reg                   ZOOM_ENABLE_LATCH,
input                                                 fit_to_screen_en,
(* mark_debug = "true" *)input                        RETICLE_ENABLE,
(* mark_debug = "true" *)output reg                   RETICLE_ENABLE_LATCH,
(* mark_debug = "true" *)input                        OSD_ENABLE,
(* mark_debug = "true" *)output reg                   OSD_ENABLE_LATCH,
                         input                        CROP_START,
(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  IMG_CROP_LEFT, 
(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  IMG_CROP_RIGHT, 
(* mark_debug = "true" *)input      [LIN_BITS-1 : 0]  IMG_CROP_TOP, 
(* mark_debug = "true" *)input      [LIN_BITS-1 : 0]  IMG_CROP_BOTTOM, 

//(* mark_debug = "true" *)input                        IMG_SHIFT_LR_UPDATE,
//(* mark_debug = "true" *)input                        IMG_SHIFT_LR_SEL,     
//(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  IMG_SHIFT_LR, 
//(* mark_debug = "true" *)input                        IMG_SHIFT_UD_UPDATE,   
//(* mark_debug = "true" *)input                        IMG_SHIFT_UD_SEL,     
//(* mark_debug = "true" *)input      [LIN_BITS-1 : 0]  IMG_SHIFT_UD, 
(* mark_debug = "true" *)input                        BT656_REQ_V,        
(* mark_debug = "true" *)input                        BT656_REQ_H,        
(* mark_debug = "true" *)input                        BT656_FIELD,        
(* mark_debug = "true" *)input      [LIN_BITS-1 : 0]  BT656_LINE_NO,      
(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  BT656_REQ_XSIZE,    
(* mark_debug = "true" *)input      [LIN_BITS-1 : 0]  BT656_REQ_YSIZE,    
(* mark_debug = "true" *)output reg                   ADD_BORDER_REQ_V,   
(* mark_debug = "true" *)output reg                   ADD_BORDER_REQ_H,   
(* mark_debug = "true" *)output reg                   ADD_BORDER_FIELD,   
(* mark_debug = "true" *)output reg [LIN_BITS-1 : 0]  ADD_BORDER_LINE_NO, 
(* mark_debug = "true" *)output reg [PIX_BITS-1 : 0]  ADD_BORDER_REQ_XSIZE,
(* mark_debug = "true" *)output reg [LIN_BITS-1 : 0]  ADD_BORDER_REQ_YSIZE,
(* mark_debug = "true" *)input                        ADD_BORDER_I_V,     
(* mark_debug = "true" *)input                        ADD_BORDER_I_H,     
(* mark_debug = "true" *)input                        ADD_BORDER_I_DAV,   
(* mark_debug = "true" *)input      [DATA_BITS-1 : 0] ADD_BORDER_I_DATA,  
(* mark_debug = "true" *)input                        ADD_BORDER_I_EOI,   
(* mark_debug = "true" *)input      [PIX_BITS-1 : 0]  ADD_BORDER_I_XSIZE, 
(* mark_debug = "true" *)input      [LIN_BITS-1 : 0]  ADD_BORDER_I_YSIZE,
(* mark_debug = "true" *)output reg [PIX_BITS-1 : 0]  RETICLE_OFFSET_X, 
(* mark_debug = "true" *)output reg [LIN_BITS-1 : 0]  RETICLE_OFFSET_Y, 
//(* mark_debug = "true" *)output reg [PIX_BITS-1 : 0]  IMG_SHIFT_POS_X, 
//(* mark_debug = "true" *)output reg [LIN_BITS-1 : 0]  IMG_SHIFT_POS_Y, 
(* mark_debug = "true" *)output reg                   ADD_BORDER_O_V,     
(* mark_debug = "true" *)output reg                   ADD_BORDER_O_H,     
(* mark_debug = "true" *)output reg                   ADD_BORDER_O_EOI,   
(* mark_debug = "true" *)output reg                   ADD_BORDER_O_DAV,   
(* mark_debug = "true" *)output reg [DATA_BITS-1 : 0] ADD_BORDER_O_DATA  
//(* mark_debug = "true" *)output reg [PIX_BITS-1 : 0]  ADD_BORDER_O_XSIZE, 
//(* mark_debug = "true" *)output reg [LIN_BITS-1 : 0]  ADD_BORDER_O_YSIZE

 
    );



localparam [4:0] st_idle        = 5'd0,
                 st_req_v       = 5'd1,
                 st_wait_h      = 5'd2,
                 st_add_border  = 5'd3,
                 st_add_lborder = 5'd4,
                 st_add_rborder = 5'd5,
                 st_send_data   = 5'd6,
                 //st_req_v       = 5'd6,
                 st_req_new_line = 5'd7,
                 st_req_h       = 5'd8,
                 st_wait        = 5'd9,
                 st_wait1       = 5'd10,
                 st_add_border_delay = 5'd11,
                 st_add_lborder_delay = 5'd12,
                 st_add_rborder_delay = 5'd13;
                 
localparam [7:0] BORDER_DELAY  = 8'd4;                
                    
(* mark_debug = "true" *)reg [4:0] state;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] line_count;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] internal_line_count;
(* mark_debug = "true" *)reg [PIX_BITS-1 : 0] ADD_BORDER_O_XCNT;
(* mark_debug = "true" *)reg [LIN_BITS-1 : 0] ADD_BORDER_O_YCNT;
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

(* mark_debug = "true" *) reg [PIX_BITS-1 : 0] LATCH_IMG_CROP_LEFT  ; 
(* mark_debug = "true" *) reg [PIX_BITS-1 : 0] LATCH_IMG_CROP_RIGHT ; 
(* mark_debug = "true" *) reg [LIN_BITS-1 : 0] LATCH_IMG_CROP_TOP   ;
(* mark_debug = "true" *) reg [LIN_BITS-1 : 0] LATCH_IMG_CROP_BOTTOM;
(* mark_debug = "true" *) reg [LIN_BITS-1 : 0] IMG_CROP_TOP_D   ;
(* mark_debug = "true" *) reg [LIN_BITS-1 : 0] IMG_CROP_BOTTOM_D;

reg [7:0]delay_cnt;


always @(posedge CLK or posedge RST)begin
    if(RST)begin
        ADD_BORDER_REQ_V     <= 0;    
        ADD_BORDER_REQ_H     <= 0;      
        ADD_BORDER_FIELD     <= 0;      
        ADD_BORDER_LINE_NO   <= 0;    
        ADD_BORDER_REQ_XSIZE <= VIDEO_XSIZE;
        ADD_BORDER_REQ_YSIZE <= VIDEO_YSIZE;  
        ADD_BORDER_O_V       <= 0;    
        ADD_BORDER_O_H       <= 0;    
        ADD_BORDER_O_EOI     <= 0;  
        ADD_BORDER_O_DAV     <= 0;  
        ADD_BORDER_O_DATA    <= 0;
//        ADD_BORDER_O_XSIZE   <= 0;
//        ADD_BORDER_O_YSIZE   <= 0;
        state      <= st_idle;
        line_count <= 0; 
        ADD_BORDER_O_XCNT <= 0;
        ADD_BORDER_O_YCNT <= 0;
        ZOOM_ENABLE_LATCH <= 0;
        RETICLE_ENABLE_LATCH <= 0;
        delay_cnt      <= 0;
//        IMG_SHIFT_LEFT_CNT  <= 0;
//        IMG_SHIFT_RIGHT_CNT <= 0;
//        IMG_SHIFT_UP_CNT    <= 0;
//        IMG_SHIFT_DOWN_CNT  <= 0;
//        IMG_SHIFT_UP_CNT_EVEN    <= 0;
//        IMG_SHIFT_DOWN_CNT_EVEN  <= 0;
//        IMG_SHIFT_UP_CNT_ODD     <= 0;
//        IMG_SHIFT_DOWN_CNT_ODD   <= 0;                
//        //IMG_SHIFT_UD_D   <= 0;
//        IMG_SHIFT_UD_SEL_D   <= 0;
//        IMG_SHIFT_LR_UPDATE_LATCH <= 1'b1;
//        IMG_SHIFT_UD_UPDATE_LATCH <= 1'b1;
//        ADD_BORDER_LINE_NO_EVEN <= 0;
//        ADD_BORDER_LINE_NO_ODD <= 0;
//        IMG_SHIFT_UP <= 0;
//        IMG_SHIFT_DOWN <= 0;
//        IMG_SHIFT_UP_D <= 0;
//        IMG_SHIFT_DOWN_D <= 0;
        RETICLE_OFFSET_X   <= (716 - VIDEO_XSIZE)>>1;
        RETICLE_OFFSET_Y   <= (576 - VIDEO_YSIZE)>>1;
//        IMG_SHIFT_POS_X    <= (720 - VIDEO_XSIZE)>>1;
//        IMG_SHIFT_POS_Y    <= (576 - VIDEO_YSIZE)>>1;
        LATCH_IMG_CROP_LEFT   <= 0;
        LATCH_IMG_CROP_RIGHT  <= 0;
        LATCH_IMG_CROP_TOP    <= 0;
        LATCH_IMG_CROP_BOTTOM <= 0;
        IMG_CROP_TOP_D        <= 0;
        IMG_CROP_BOTTOM_D     <= 0;
        internal_line_count   <= 0;
        OSD_ENABLE_LATCH <= 1'b0;
    end
    else begin
//        if(IMG_SHIFT_LR_UPDATE == 1'b1)begin
//            IMG_SHIFT_LR_UPDATE_LATCH <= 1'b1;
//        end
        
//        if(IMG_SHIFT_UD_UPDATE == 1'b1)begin
//            IMG_SHIFT_UD_UPDATE_LATCH <= 1'b1;
//        end
    
    case(state)
        
        st_idle: begin
            line_count           <= 0;
            internal_line_count  <= 0;
            ADD_BORDER_O_XCNT    <= 0;
            ADD_BORDER_O_YCNT    <= 0;
            ADD_BORDER_O_V       <= 0;    
            ADD_BORDER_O_H       <= 0;    
            ADD_BORDER_O_EOI     <= 0;  
            ADD_BORDER_O_DAV     <= 0;  
            ADD_BORDER_O_DATA    <= 0;
//            ADD_BORDER_O_XSIZE   <= BT656_REQ_XSIZE;
//            ADD_BORDER_O_YSIZE   <= BT656_REQ_YSIZE;
            ADD_BORDER_REQ_XSIZE <= ADD_BORDER_I_XSIZE;//VIDEO_XSIZE;
            ADD_BORDER_REQ_YSIZE <= ADD_BORDER_I_YSIZE;//VIDEO_YSIZE;
            
            ADD_BORDER_REQ_V <= 1'b0;
            ADD_BORDER_REQ_H <= 1'b0;
            //ADD_BORDER_REQ_XSIZE <= ADD_BORDER_I_XSIZE;
            //ADD_BORDER_REQ_YSIZE <= ADD_BORDER_I_YSIZE;
            if(BT656_REQ_V)begin
                 delay_cnt      <= 0;
                 if(!BT656_FIELD)begin              
                     ZOOM_ENABLE_LATCH     <= ZOOM_ENABLE;
                     RETICLE_ENABLE_LATCH  <= RETICLE_ENABLE;
                     OSD_ENABLE_LATCH      <= OSD_ENABLE;
                     if(CROP_START == 1'b1)begin
                         IMG_CROP_TOP_D        <= IMG_CROP_TOP;
                         IMG_CROP_BOTTOM_D     <= IMG_CROP_BOTTOM;
                         if(IMG_CROP_LEFT > ADD_BORDER_REQ_XSIZE)begin
                            LATCH_IMG_CROP_LEFT   <= ADD_BORDER_REQ_XSIZE  ;
                         end
                         else begin
                            LATCH_IMG_CROP_LEFT  <= IMG_CROP_LEFT ;                     
                         end   
    
                         if(IMG_CROP_RIGHT > ADD_BORDER_REQ_XSIZE)begin
                            LATCH_IMG_CROP_RIGHT   <= ADD_BORDER_REQ_XSIZE  ;
                         end
                         else begin
                            LATCH_IMG_CROP_RIGHT  <= IMG_CROP_RIGHT ;                     
                         end  
     
                         if(IMG_CROP_TOP > ADD_BORDER_REQ_YSIZE)begin
                            LATCH_IMG_CROP_TOP   <= ADD_BORDER_REQ_YSIZE;
                         end
                         else begin
                            if(IMG_CROP_TOP[0]==1'b1)begin
                                LATCH_IMG_CROP_TOP  <= (IMG_CROP_TOP) + 1; 
                            end
                            else begin
                                LATCH_IMG_CROP_TOP  <= IMG_CROP_TOP; 
                            end                              
                         end  
                         
                         if(IMG_CROP_BOTTOM > ADD_BORDER_REQ_YSIZE)begin
                            LATCH_IMG_CROP_BOTTOM   <= ADD_BORDER_REQ_YSIZE;
                         end
                         else begin
                            LATCH_IMG_CROP_BOTTOM  <= IMG_CROP_BOTTOM;                             
                         end

                     end 
                     else begin
                        IMG_CROP_TOP_D        <= 0;   
                        IMG_CROP_BOTTOM_D     <= 0;
                        LATCH_IMG_CROP_LEFT   <= 0; 
                        LATCH_IMG_CROP_RIGHT  <= 0;
                        LATCH_IMG_CROP_TOP    <= 0; 
                        LATCH_IMG_CROP_BOTTOM <= 0;
                     
                     end
                   
//                     if(IMG_SHIFT_UD_UPDATE_LATCH == 1'b1)begin
//                        if(IMG_SHIFT_UD_SEL==1'b0)begin
//                            if(IMG_SHIFT_UD <= ((((BT656_REQ_YSIZE - VIDEO_YSIZE)>>1) + IMG_SHIFT_DOWN)-IMG_SHIFT_UP))begin
//                                if(IMG_SHIFT_UP + IMG_SHIFT_UD >= IMG_SHIFT_DOWN)begin
//                                    IMG_SHIFT_UP <= (IMG_SHIFT_UP + IMG_SHIFT_UD) - IMG_SHIFT_DOWN;
//                                    IMG_SHIFT_DOWN          <= 0;
//                                    IMG_SHIFT_DOWN_CNT_EVEN <= 0;
//                                    IMG_SHIFT_DOWN_CNT_ODD <= 0;
//                                    IMG_SHIFT_UD_SEL_D     <= 1'b0;
//                                end
//                                else begin
//                                    IMG_SHIFT_DOWN <= IMG_SHIFT_DOWN - (IMG_SHIFT_UP + IMG_SHIFT_UD);
//                                    IMG_SHIFT_UP   <= 0;
//                                    IMG_SHIFT_UP_CNT_EVEN <= 0;
//                                    IMG_SHIFT_UP_CNT_ODD <= 0;
//                                    IMG_SHIFT_UD_SEL_D     <= 1'b1;
//                                end    
//                            end
//                            else begin
//                                IMG_SHIFT_UP <= ((BT656_REQ_YSIZE - VIDEO_YSIZE)>>1);
//                                IMG_SHIFT_DOWN          <= 0;
//                                IMG_SHIFT_DOWN_CNT_EVEN <= 0;
//                                IMG_SHIFT_DOWN_CNT_ODD <= 0;
//                                IMG_SHIFT_UD_SEL_D     <= 1'b0;
//                            end    
//                        end
//                        else begin
//                            if(IMG_SHIFT_UD <= ((((BT656_REQ_YSIZE - VIDEO_YSIZE)>>1) + IMG_SHIFT_UP)-IMG_SHIFT_DOWN))begin
//                                if(IMG_SHIFT_DOWN + IMG_SHIFT_UD >= IMG_SHIFT_UP)begin
//                                    IMG_SHIFT_DOWN <= (IMG_SHIFT_DOWN + IMG_SHIFT_UD) - IMG_SHIFT_UP;
//                                    IMG_SHIFT_UP <= 0;
//                                    IMG_SHIFT_UP_CNT_EVEN <= 0;
//                                    IMG_SHIFT_UP_CNT_ODD  <= 0;
//                                    IMG_SHIFT_UD_SEL_D    <= 1'b1;
                                    
//                                end
//                                else begin
//                                    IMG_SHIFT_UP <= IMG_SHIFT_UP -(IMG_SHIFT_DOWN + IMG_SHIFT_UD) ;
//                                    IMG_SHIFT_DOWN <= 0;
//                                    IMG_SHIFT_DOWN_CNT_EVEN <= 0;
//                                    IMG_SHIFT_DOWN_CNT_ODD <= 0;
//                                    IMG_SHIFT_UD_SEL_D     <= 1'b0;
//                                end    
                                    
//                            end
//                            else begin
//                                IMG_SHIFT_DOWN <= ((BT656_REQ_YSIZE - VIDEO_YSIZE)>>1);
//                                IMG_SHIFT_UP <= 0;
//                                IMG_SHIFT_UP_CNT_EVEN <= 0;
//                                IMG_SHIFT_UP_CNT_ODD  <= 0;
//                                IMG_SHIFT_UD_SEL_D     <= 1'b1;
//                            end
//                        end
//                     end
                 end
                else begin
                   LATCH_IMG_CROP_LEFT   <= LATCH_IMG_CROP_LEFT;
                   LATCH_IMG_CROP_RIGHT  <= LATCH_IMG_CROP_RIGHT;                   
                     if(IMG_CROP_TOP_D > ADD_BORDER_REQ_YSIZE)begin
                        LATCH_IMG_CROP_TOP   <= ADD_BORDER_REQ_YSIZE;
                     end
                     else begin
                        LATCH_IMG_CROP_TOP  <= IMG_CROP_TOP_D;                            
                     end  
                     
                     if(IMG_CROP_BOTTOM_D > ADD_BORDER_REQ_YSIZE)begin
                        LATCH_IMG_CROP_BOTTOM   <= ADD_BORDER_REQ_YSIZE;
                     end
                     else begin
                        if(IMG_CROP_BOTTOM_D[0]==1'b1)begin
                             LATCH_IMG_CROP_BOTTOM  <= (IMG_CROP_BOTTOM_D) +1; 
                        end
                        else begin
                             LATCH_IMG_CROP_BOTTOM  <= IMG_CROP_BOTTOM_D; 
                        end                              
                     end                
                end
                ADD_BORDER_O_V <= 1'b1;     
                ADD_BORDER_REQ_V <= 1'b1;
                ADD_BORDER_FIELD <= BT656_FIELD;  
                if(!fit_to_screen_en)begin  
                    state          <= st_req_v;
                end  
                else begin
                    state          <= st_idle;
                end                              
                
            end
        end
        st_req_v : begin
//            if(!BT656_FIELD)begin
//                //IMG_SHIFT_UD_SEL_D <= IMG_SHIFT_UD_SEL;
//                //IMG_SHIFT_UD_D     <= IMG_SHIFT_UD; 
//                IMG_SHIFT_UP_D    <= IMG_SHIFT_UP;
//                IMG_SHIFT_DOWN_D  <= IMG_SHIFT_DOWN;
//                if(IMG_SHIFT_LR_UPDATE_LATCH == 1'b1)begin
//                   IMG_SHIFT_LR_UPDATE_LATCH <= 1'b0;
//                   if(IMG_SHIFT_LR_SEL == 1'b0)begin
//                       if(IMG_SHIFT_LR <= ((((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1) + IMG_SHIFT_RIGHT_CNT)-IMG_SHIFT_LEFT_CNT))begin
//                           IMG_SHIFT_LEFT_CNT   <= IMG_SHIFT_LR + IMG_SHIFT_LEFT_CNT;    
//                       end
//                       else begin
//                           IMG_SHIFT_LEFT_CNT   <= (((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1) + IMG_SHIFT_RIGHT_CNT);
//                       end                          
//                   end
//                   else begin
//                       if(IMG_SHIFT_LR <= ((((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1) + IMG_SHIFT_LEFT_CNT)-IMG_SHIFT_RIGHT_CNT))begin
//                           IMG_SHIFT_RIGHT_CNT   <= IMG_SHIFT_LR+IMG_SHIFT_RIGHT_CNT;    
//                       end
//                       else begin
//                           IMG_SHIFT_RIGHT_CNT   <= (((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1) + IMG_SHIFT_LEFT_CNT);
//                       end
//                   end
//                end
//                if(IMG_SHIFT_UD_UPDATE_LATCH == 1'b1)begin
//                   IMG_SHIFT_UD_UPDATE_LATCH <= 1'b0;
//                   IMG_SHIFT_UD_UPDATE_LATCH_D <= 1'b1;
//                   if(IMG_SHIFT_UD_SEL_D==1'b0)begin
////                       IMG_SHIFT_UP_CNT_EVEN  <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]}; //+ IMG_SHIFT_UP_CNT_EVEN;
////                       IMG_SHIFT_UP_CNT       <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]};// + IMG_SHIFT_UP_CNT;
//                       IMG_SHIFT_UP_CNT_EVEN  <= {1'b0,IMG_SHIFT_UP[LIN_BITS-1 : 1]}; //+ IMG_SHIFT_UP_CNT_EVEN;
//                       IMG_SHIFT_UP_CNT       <= {1'b0,IMG_SHIFT_UP[LIN_BITS-1 : 1]};// + IMG_SHIFT_UP_CNT;
//                       if(IMG_SHIFT_UP[0]==1'b0)begin
//                        ADD_BORDER_LINE_NO_EVEN  <= 0;
//                        ADD_BORDER_LINE_NO       <= 0;
//                       end
//                       else begin
//                        ADD_BORDER_LINE_NO_EVEN  <= 1;
//                        ADD_BORDER_LINE_NO       <= 1;
//                       end                     
//                   end
//                   else begin
//                       if(IMG_SHIFT_DOWN[0]==1'b0)begin
////                        IMG_SHIFT_DOWN_CNT_EVEN  <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]};// + IMG_SHIFT_DOWN_CNT_EVEN;
////                        IMG_SHIFT_DOWN_CNT       <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]};// + IMG_SHIFT_DOWN_CNT; 
//                        IMG_SHIFT_DOWN_CNT_EVEN  <= {1'b0,IMG_SHIFT_DOWN[LIN_BITS-1 : 1]};// + IMG_SHIFT_DOWN_CNT_EVEN;
//                        IMG_SHIFT_DOWN_CNT       <= {1'b0,IMG_SHIFT_DOWN[LIN_BITS-1 : 1]};// + IMG_SHIFT_DOWN_CNT; 
                        
//                        ADD_BORDER_LINE_NO_EVEN  <= 0;
//                        ADD_BORDER_LINE_NO       <= 0;
//                       end
//                       else begin
////                        IMG_SHIFT_DOWN_CNT_EVEN  <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]}+1'b1;// + IMG_SHIFT_DOWN_CNT_EVEN;
////                        IMG_SHIFT_DOWN_CNT       <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]}+1'b1;// + IMG_SHIFT_DOWN_CNT; 
//                        IMG_SHIFT_DOWN_CNT_EVEN  <= {1'b0,IMG_SHIFT_DOWN[LIN_BITS-1 : 1]}+1'b1;// + IMG_SHIFT_DOWN_CNT_EVEN;
//                        IMG_SHIFT_DOWN_CNT       <= {1'b0,IMG_SHIFT_DOWN[LIN_BITS-1 : 1]}+1'b1;// + IMG_SHIFT_DOWN_CNT; 
//                        ADD_BORDER_LINE_NO_EVEN  <= 1;
//                        ADD_BORDER_LINE_NO       <= 1;
//                       end                      
                       
//                   end
//                end
//                else begin
//                   ADD_BORDER_LINE_NO  <= ADD_BORDER_LINE_NO_EVEN; 
//                   IMG_SHIFT_UP_CNT    <= IMG_SHIFT_UP_CNT_EVEN;
//                   IMG_SHIFT_DOWN_CNT  <= IMG_SHIFT_DOWN_CNT_EVEN;
//                end                
//            end
//            else begin
//                IMG_SHIFT_LEFT_CNT <= IMG_SHIFT_LEFT_CNT;
//                IMG_SHIFT_RIGHT_CNT <= IMG_SHIFT_RIGHT_CNT;
//                if(IMG_SHIFT_UD_UPDATE_LATCH_D == 1'b1)begin
//                    IMG_SHIFT_UD_UPDATE_LATCH_D <= 1'b0;
//                    if(IMG_SHIFT_UD_SEL_D ==1'b0)begin
//                        if(IMG_SHIFT_UP[0]== 1'b0)begin
////                         IMG_SHIFT_UP_CNT_ODD  <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]};// + IMG_SHIFT_UP_CNT_ODD;
////                         IMG_SHIFT_UP_CNT      <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]};// + IMG_SHIFT_UP_CNT;
//                         IMG_SHIFT_UP_CNT_ODD  <= {1'b0,IMG_SHIFT_UP[LIN_BITS-1 : 1]};// + IMG_SHIFT_UP_CNT_ODD;
//                         IMG_SHIFT_UP_CNT      <= {1'b0,IMG_SHIFT_UP[LIN_BITS-1 : 1]};// + IMG_SHIFT_UP_CNT;                        
//                         ADD_BORDER_LINE_NO_ODD  <= 1;
//                         ADD_BORDER_LINE_NO      <= 1;
//                        end
//                        else begin
////                         IMG_SHIFT_UP_CNT_ODD  <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]}+1'b1; //+ IMG_SHIFT_UP_CNT_ODD;
////                         IMG_SHIFT_UP_CNT      <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]}+1'b1;// + IMG_SHIFT_UP_CNT;
//                         IMG_SHIFT_UP_CNT_ODD  <= {1'b0,IMG_SHIFT_UP[LIN_BITS-1 : 1]}+1'b1; //+ IMG_SHIFT_UP_CNT_ODD;
//                         IMG_SHIFT_UP_CNT      <= {1'b0,IMG_SHIFT_UP[LIN_BITS-1 : 1]}+1'b1;// + IMG_SHIFT_UP_CNT;
//                         ADD_BORDER_LINE_NO_ODD  <= 0;
//                         ADD_BORDER_LINE_NO      <= 0;
//                        end  
//                    end
//                    else begin
////                        IMG_SHIFT_DOWN_CNT_ODD  <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]};// + IMG_SHIFT_DOWN_CNT_ODD;
////                        IMG_SHIFT_DOWN_CNT      <= {1'b0,IMG_SHIFT_UD[LIN_BITS-1 : 1]};// + IMG_SHIFT_DOWN_CNT;
//                        IMG_SHIFT_DOWN_CNT_ODD  <= {1'b0,IMG_SHIFT_DOWN[LIN_BITS-1 : 1]};// + IMG_SHIFT_DOWN_CNT_ODD;
//                        IMG_SHIFT_DOWN_CNT      <= {1'b0,IMG_SHIFT_DOWN[LIN_BITS-1 : 1]};// + IMG_SHIFT_DOWN_CNT;
//                        if(IMG_SHIFT_DOWN[0]== 1'b0)begin
//                         ADD_BORDER_LINE_NO_ODD  <= 1;
//                         ADD_BORDER_LINE_NO      <= 1;
//                        end
//                        else begin
//                         ADD_BORDER_LINE_NO_ODD  <= 0;
//                         ADD_BORDER_LINE_NO      <= 0;
//                        end  
//                    end 
//                 end  
//                 else begin
//                     ADD_BORDER_LINE_NO  <= ADD_BORDER_LINE_NO_ODD; 
//                     IMG_SHIFT_UP_CNT    <= IMG_SHIFT_UP_CNT_ODD;
//                     IMG_SHIFT_DOWN_CNT  <= IMG_SHIFT_DOWN_CNT_ODD;                             
//                 end                                   
//            end
            ADD_BORDER_O_V <= 1'b0;
            ADD_BORDER_REQ_V <= 1'b0;
            state          <= st_wait_h;
            ADD_BORDER_LINE_NO  <= 0;
//            if(!BT656_FIELD) begin 
//               ADD_BORDER_LINE_NO  <= 0;
//            end
//            else  begin
//               ADD_BORDER_LINE_NO  <= 1; 
////               ADD_BORDER_LINE_NO  <= 240;
//            end 
            
        end 
               
        st_wait_h: begin
            RETICLE_OFFSET_X  <= ((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1);
            RETICLE_OFFSET_Y  <=  ((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>1);        
//            if(IMG_SHIFT_LEFT_CNT >= IMG_SHIFT_RIGHT_CNT)begin
//                RETICLE_OFFSET_X   <= ((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1)- (IMG_SHIFT_LEFT_CNT - IMG_SHIFT_RIGHT_CNT) ;
//                IMG_SHIFT_POS_X    <= ((720 - ADD_BORDER_REQ_XSIZE)>>1)- (IMG_SHIFT_LEFT_CNT - IMG_SHIFT_RIGHT_CNT) ;
//            end
//            else begin
//                RETICLE_OFFSET_X   <= ((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1)+ (IMG_SHIFT_RIGHT_CNT - IMG_SHIFT_LEFT_CNT) ;
//                IMG_SHIFT_POS_X    <= ((720 - ADD_BORDER_REQ_XSIZE)>>1)+ (IMG_SHIFT_RIGHT_CNT - IMG_SHIFT_LEFT_CNT) ;
//            end
            
//            if(IMG_SHIFT_UP >= IMG_SHIFT_DOWN)begin
//                RETICLE_OFFSET_Y   <= ((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>1) - (IMG_SHIFT_UP - IMG_SHIFT_DOWN) ; 
//                IMG_SHIFT_POS_Y    <= ((576 - ADD_BORDER_REQ_YSIZE)>>1) - (IMG_SHIFT_UP - IMG_SHIFT_DOWN) ; 
//            end
//            else begin
//                RETICLE_OFFSET_Y   <= ((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>1) + (IMG_SHIFT_DOWN - IMG_SHIFT_UP) ; 
//                IMG_SHIFT_POS_Y    <= ((576 - ADD_BORDER_REQ_YSIZE)>>1) + (IMG_SHIFT_DOWN - IMG_SHIFT_UP) ; 
//            end
           
            if(BT656_REQ_H)begin
                ADD_BORDER_O_YCNT <= ADD_BORDER_O_YCNT + 1;
                ADD_BORDER_O_XCNT <= 0;
                ADD_BORDER_O_H    <= 1'b1;
                line_count        <= line_count + 1;
//                if((line_count >= ((((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>2)- IMG_SHIFT_UP_CNT ) + IMG_SHIFT_DOWN_CNT)) & (line_count < ((((BT656_REQ_YSIZE>>1)-((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>2))- IMG_SHIFT_UP_CNT ) + IMG_SHIFT_DOWN_CNT)))begin
                if((line_count >= (((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>1))) & (line_count < ((BT656_REQ_YSIZE)-((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>1))))begin
//                if((line_count >= (((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>2))) & (line_count < ((BT656_REQ_YSIZE>>1)-((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>2))))begin
                    state              <= st_req_new_line;  
                    //state              <= st_req_v;                 
                end
                else begin
                    //state      <= st_add_border_delay;
                    state      <= st_add_border;
                end                          
            end
            
//            if(line_count == (BT656_REQ_YSIZE>>1))begin
            if(line_count == (BT656_REQ_YSIZE))begin
                state      <= st_idle;
                ADD_BORDER_O_EOI <= 1'b1;         
            end
            
        end
       
//        st_add_border_delay : begin
//             ADD_BORDER_O_H <= 1'b0;
//            if(delay_cnt == BORDER_DELAY)begin
//                state      <= st_add_border;
//                delay_cnt  <= 0; 
//            end
//            else begin
//                state      <= st_add_border_delay;
//                delay_cnt  <= delay_cnt + 1;
//            end    
//        end
        
        st_add_border: begin
            ADD_BORDER_O_H <= 1'b0;
            if(ADD_BORDER_O_XCNT == BT656_REQ_XSIZE)begin
                ADD_BORDER_O_DAV  <= 1'b0;  
                ADD_BORDER_O_DATA <= 0;
                ADD_BORDER_O_XCNT <= 0;
                state      <= st_wait_h;
            end
            else begin
                ADD_BORDER_O_XCNT <= ADD_BORDER_O_XCNT + 1;
                ADD_BORDER_O_DAV  <= 1'b1;  
                ADD_BORDER_O_DATA <= 8'h10;//24'h108080;
                state             <= st_add_border;
            end
        end
        
        //st_req_v : begin
        st_req_new_line : begin
                ADD_BORDER_O_H   <= 1'b0;
                //ADD_BORDER_REQ_V <= 1'b1;
                //state            <= st_add_lborder_delay;
                state            <= st_add_lborder;
                internal_line_count <= internal_line_count +1;
        end
        
//        st_add_lborder_delay : begin
//            if(delay_cnt == BORDER_DELAY)begin
//                state      <= st_add_lborder;
//                delay_cnt  <= 0; 
//            end
//            else begin
//                state      <= st_add_lborder_delay;
//                delay_cnt  <= delay_cnt + 1;
//            end    
//        end 
               
        st_add_lborder: begin
                //ADD_BORDER_REQ_V <= 1'b0;
////                if(ADD_BORDER_O_XCNT == ((((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1) - IMG_SHIFT_LEFT_CNT) + IMG_SHIFT_RIGHT_CNT))begin
               if(ADD_BORDER_O_XCNT == ((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1))begin
//               if(ADD_BORDER_O_XCNT == 0)begin
                    ADD_BORDER_O_DAV  <= 1'b0;  
                    ADD_BORDER_O_DATA <= 0;
                    ADD_BORDER_O_XCNT <= 0;
                    state      <= st_req_h;
                end
                else begin
                    ADD_BORDER_O_XCNT <= ADD_BORDER_O_XCNT + 1;
                    ADD_BORDER_O_DAV  <= 1'b1;  
                    ADD_BORDER_O_DATA <= 8'h10 ;//24'h108080 ;
                    state      <= st_add_lborder;        
                end                              
        end
               
        st_req_h : begin
                ADD_BORDER_REQ_H <= 1'b1;
                state            <= st_send_data;        
        end
     
        st_send_data : begin
            ADD_BORDER_REQ_H <= 1'b0;
            if(ADD_BORDER_I_DAV)begin     
                ADD_BORDER_O_DAV  <= 1'b1;  
////                if((ADD_BORDER_O_YCNT == ((BT656_REQ_YSIZE>>1)-((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>2))) & (ZOOM_ENABLE_LATCH == 1'b1) & (ADD_BORDER_FIELD == 1'b1))begin
////                    ADD_BORDER_O_DATA <= 24'h108080 ;
////                end
////                else begin
////                    ADD_BORDER_O_DATA <= ADD_BORDER_I_DATA;
////                end       
////                ADD_BORDER_O_DATA <= ADD_BORDER_I_DATA;  
////                if((ADD_BORDER_O_YCNT <= ((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>2)+LATCH_IMG_CROP_TOP))begin
////                    ADD_BORDER_O_DATA <= 24'h108080 ;
////                end
////                else if((ADD_BORDER_O_YCNT > (((BT656_REQ_YSIZE - ADD_BORDER_REQ_YSIZE)>>2)+(ADD_BORDER_REQ_YSIZE>>1)-LATCH_IMG_CROP_BOTTOM)))begin
////                    ADD_BORDER_O_DATA <= 24'h108080 ;
////                end

//                if((internal_line_count <= LATCH_IMG_CROP_TOP))begin
//                    ADD_BORDER_O_DATA <= 24'h108080 ;
//                end
//                else if(internal_line_count > ((ADD_BORDER_REQ_YSIZE)-LATCH_IMG_CROP_BOTTOM))begin
//                    ADD_BORDER_O_DATA <= 24'h108080 ;
//                end
//                else if((ADD_BORDER_O_XCNT < LATCH_IMG_CROP_LEFT))begin
//                    ADD_BORDER_O_DATA <= 24'h108080;
//                end
//                else if(ADD_BORDER_O_XCNT >= (ADD_BORDER_REQ_XSIZE -LATCH_IMG_CROP_RIGHT))begin
//                    ADD_BORDER_O_DATA <= 24'h108080;
//                end
//                else begin
//                    ADD_BORDER_O_DATA <= ADD_BORDER_I_DATA; 
//                end 
                ADD_BORDER_O_DATA <= ADD_BORDER_I_DATA; 
                if(ADD_BORDER_O_XCNT == ADD_BORDER_REQ_XSIZE - 1 )begin
                    ADD_BORDER_O_XCNT <= 0;
                    state             <= st_wait1;
                end
                else begin
                    ADD_BORDER_O_XCNT <= ADD_BORDER_O_XCNT + 1;
                    state             <= st_send_data;
                end
            end
            else begin
                state             <= st_send_data;
                ADD_BORDER_O_DAV  <= 1'b0; 
                ADD_BORDER_O_DATA <= 0;
            end   
             
        end
        st_wait1 : begin
            ADD_BORDER_O_DAV  <= 1'b0; 
            ADD_BORDER_O_DATA <= 0;
            state <= st_add_rborder;
        end
        
        st_add_rborder: begin
////                if(ADD_BORDER_O_XCNT == ((((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1) + IMG_SHIFT_LEFT_CNT) - IMG_SHIFT_RIGHT_CNT))begin
                if(ADD_BORDER_O_XCNT == ((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)>>1))begin
//                if(ADD_BORDER_O_XCNT == ((BT656_REQ_XSIZE - ADD_BORDER_REQ_XSIZE)))begin
                    ADD_BORDER_O_DAV  <= 1'b0;  
                    ADD_BORDER_O_DATA <= 0;
                    ADD_BORDER_O_XCNT <= 0;
                    state      <= st_wait_h;
//                    ADD_BORDER_LINE_NO <= ADD_BORDER_LINE_NO  + 2;
                    ADD_BORDER_LINE_NO <= ADD_BORDER_LINE_NO  + 1;
                end
                else begin
                    ADD_BORDER_O_XCNT <= ADD_BORDER_O_XCNT + 1;
                    ADD_BORDER_O_DAV  <= 1'b1;  
                    ADD_BORDER_O_DATA <= 8'h10 ;//24'h108080 ;
                    state      <= st_add_rborder;     
                end                              
        end
        
        
 
    
    endcase
    
    
    
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
//	.clk(CLK),
//	.probe0(probe_add_border)
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
//	.clk(CLK),
//	.probe0(probe_add_border)
//);




endmodule