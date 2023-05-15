`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2017 12:32:24 PM
// Design Name: 
// Module Name: Top_CLHE_Impl_With_BRAM_IP
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


module new_hist_mem #(parameter VIDEO_I_DATA_WIDTH = 12,
                                     HIST_BIN_WIDTH            = 19,
                                     NUMBER_OF_IN_PIXELS       = 308160
)
(
(* mark_debug = "true" *)input                             VIDEO_I_PCLK,
(* mark_debug = "true" *)input                             VIDEO_I_VSYNC,
(* mark_debug = "true" *)input                             VIDEO_I_HSYNC,
(* mark_debug = "true" *)input                             VIDEO_I_EOI,
(* mark_debug = "true" *)input                             VIDEO_I_DAV,
(* mark_debug = "true" *)input  [VIDEO_I_DATA_WIDTH-1 : 0] VIDEO_I_DATA,
(* mark_debug = "true" *)input                              RESET,
(* mark_debug = "true" *)input                              HISTEQ_B_RDREQ,
(* mark_debug = "true" *)output  [HIST_BIN_WIDTH-1:0]       HISTEQ_B_RDDATA,
(* mark_debug = "true" *)input   [VIDEO_I_DATA_WIDTH-1 : 0] HISTEQ_B_ADDR,
(* mark_debug = "true" *)input                              HISTEQ_A_WRREQ,
(* mark_debug = "true" *)input [HIST_BIN_WIDTH-1:0]         HISTEQ_A_WRDATA,
(* mark_debug = "true" *)input [VIDEO_I_DATA_WIDTH-1 : 0]   HISTEQ_A_ADDR
 );

reg     VIDEO_I_VSYNC_D;   
reg     VIDEO_I_HSYNC_D;

wire VIDEO_I_VSYNC_POS_EDGE;
wire VIDEO_I_VSYNC_NEG_EDGE;
wire VIDEO_I_HSYNC_POS_EDGE;
wire VIDEO_I_HSYNC_NEG_EDGE;

(* mark_debug = "true" *)reg PING_PONG_ENABLE; 

///////// Histogram and Excess Pixel  Calculation ////
wire                            HISTCAL_B_RDREQ;
wire   [HIST_BIN_WIDTH-1:0]      HISTCAL_B_RDDATA;
wire  [VIDEO_I_DATA_WIDTH-1 : 0] HISTCAL_B_ADDR;
wire                            HISTCAL_A_WRREQ;
wire  [HIST_BIN_WIDTH-1:0]       HISTCAL_A_WRDATA;
wire  [VIDEO_I_DATA_WIDTH-1 : 0] HISTCAL_A_ADDR;
///////////////////////////////////////////////////////

///////// Excess Pixel  Redistribution AND CDF Calculation////




///////////////////////////////////////////


// PING  HIST////
(* mark_debug = "true" *)wire                             PING_B_RDREQ;
(* mark_debug = "true" *)wire [HIST_BIN_WIDTH-1:0]        PING_B_RDDATA;
(* mark_debug = "true" *)wire  [VIDEO_I_DATA_WIDTH-1 : 0] PING_B_ADDR;
(* mark_debug = "true" *)wire                             PING_A_WRREQ;
(* mark_debug = "true" *)wire  [HIST_BIN_WIDTH-1:0]       PING_A_WRDATA;
(* mark_debug = "true" *)wire  [VIDEO_I_DATA_WIDTH-1 : 0] PING_A_ADDR;
////////////////

// PONG  HIST////
(* mark_debug = "true" *)wire                             PONG_B_RDREQ;
(* mark_debug = "true" *)wire [HIST_BIN_WIDTH-1:0]        PONG_B_RDDATA;
(* mark_debug = "true" *)wire  [VIDEO_I_DATA_WIDTH-1 : 0] PONG_B_ADDR;
(* mark_debug = "true" *)wire                             PONG_A_WRREQ;
(* mark_debug = "true" *)wire  [HIST_BIN_WIDTH-1:0]       PONG_A_WRDATA;
(* mark_debug = "true" *)wire  [VIDEO_I_DATA_WIDTH-1 : 0] PONG_A_ADDR;
////////////////




//reg  [VIDEO_I_DATA_WIDTH-1 : 0] HISTCAL_B_ADDR_D;
//reg  [VIDEO_I_DATA_WIDTH-1 : 0] HISTCAL_A_ADDR_D;
//reg                             HISTCAL_A_WRREQ_D;
//reg                             HISTCAL_B_RDREQ_D;
//reg  [HIST_BIN_WIDTH-1:0]       HISTCAL_A_WRDATA_D;

reg [HIST_BIN_WIDTH-1:0] HISTCAL_B_RDDATA_Temp;
(* mark_debug = "true" *)reg                      Data_Forwarding_En;
//assign B_RDDATA =PING_B_RDDATA;

always @(posedge VIDEO_I_PCLK or posedge RESET)begin
    if(RESET)begin
        VIDEO_I_VSYNC_D  <= 0;
        VIDEO_I_HSYNC_D  <= 0;
        PING_PONG_ENABLE <= 0;       
//        HISTCAL_A_ADDR_D  <= 0;
//        HISTCAL_B_ADDR_D  <= 0; 
//        HISTCAL_A_WRREQ_D <= 0;
//        HISTCAL_B_RDREQ_D <= 0;   
//        HISTCAL_A_WRDATA_D <=0;
    end
    else begin    
        VIDEO_I_VSYNC_D  <=  VIDEO_I_VSYNC;
        VIDEO_I_HSYNC_D  <=  VIDEO_I_HSYNC;
    
        if(VIDEO_I_VSYNC)begin
            PING_PONG_ENABLE <= (~PING_PONG_ENABLE);
        end
        else begin
            PING_PONG_ENABLE <= PING_PONG_ENABLE; 
        end
//        HISTCAL_A_ADDR_D  <= HISTCAL_A_ADDR;
//        HISTCAL_B_ADDR_D  <= HISTCAL_B_ADDR; 
//        HISTCAL_A_WRREQ_D <= HISTCAL_A_WRREQ;
//        HISTCAL_B_RDREQ_D <= HISTCAL_B_RDREQ;   
//        HISTCAL_A_WRDATA_D <= HISTCAL_A_WRDATA;

        if((HISTCAL_A_ADDR == HISTCAL_B_ADDR) && (HISTCAL_A_WRREQ) && (HISTCAL_B_RDREQ))begin
            HISTCAL_B_RDDATA_Temp <= HISTCAL_A_WRDATA;
            Data_Forwarding_En <= 1'b1;
        end
        else begin
            if(HISTCAL_B_RDREQ)begin
                Data_Forwarding_En <= 1'b0;
            end
        end        
        
    end

end

assign            PING_B_RDREQ   = (PING_PONG_ENABLE) ? HISTCAL_B_RDREQ  : HISTEQ_B_RDREQ ;
assign            HISTCAL_B_RDDATA = (Data_Forwarding_En)? HISTCAL_B_RDDATA_Temp: (PING_PONG_ENABLE) ? PING_B_RDDATA  : PONG_B_RDDATA;

//assign            HISTCAL_B_RDDATA = ((HISTCAL_A_ADDR_D == HISTCAL_B_ADDR_D) && (HISTCAL_A_WRREQ_D) && (HISTCAL_B_RDREQ_D))?HISTCAL_A_WRDATA_D :((PING_PONG_ENABLE) ? PING_B_RDDATA  : PONG_B_RDDATA);
//assign            HISTCAL_B_RDDATA = (PING_PONG_ENABLE) ? PING_B_RDDATA  : PONG_B_RDDATA;
assign            PING_B_ADDR    = (PING_PONG_ENABLE) ? HISTCAL_B_ADDR   : HISTEQ_B_ADDR;
assign            PING_A_WRREQ   = (PING_PONG_ENABLE) ? HISTCAL_A_WRREQ  : HISTEQ_A_WRREQ ;
assign            PING_A_WRDATA  = (PING_PONG_ENABLE) ? HISTCAL_A_WRDATA : HISTEQ_A_WRDATA;
assign            PING_A_ADDR    = (PING_PONG_ENABLE) ? HISTCAL_A_ADDR   : HISTEQ_A_ADDR;
            
assign            PONG_B_RDREQ    = (PING_PONG_ENABLE) ? HISTEQ_B_RDREQ  : HISTCAL_B_RDREQ;
assign            HISTEQ_B_RDDATA = (PING_PONG_ENABLE) ? PONG_B_RDDATA   : PING_B_RDDATA;
assign            PONG_B_ADDR     = (PING_PONG_ENABLE) ? HISTEQ_B_ADDR   : HISTCAL_B_ADDR;
assign            PONG_A_WRREQ    = (PING_PONG_ENABLE) ? HISTEQ_A_WRREQ  : HISTCAL_A_WRREQ;
assign            PONG_A_WRDATA   = (PING_PONG_ENABLE) ? HISTEQ_A_WRDATA : HISTCAL_A_WRDATA;
assign            PONG_A_ADDR     = (PING_PONG_ENABLE) ? HISTEQ_A_ADDR   : HISTCAL_A_ADDR;
            

Histogram_Calculation 
#(.VIDEO_I_DATA_WIDTH(VIDEO_I_DATA_WIDTH),
  .HIST_BIN_WIDTH(HIST_BIN_WIDTH),
  .NUMBER_OF_IN_PIXELS(NUMBER_OF_IN_PIXELS))
HISTCAL (
.VIDEO_I_PCLK(VIDEO_I_PCLK),           //input                                 
.VIDEO_I_VSYNC(VIDEO_I_VSYNC),         //input                                                                  
.VIDEO_I_HSYNC(VIDEO_I_HSYNC),         //input                                                    
.VIDEO_I_DAV(VIDEO_I_DAV),             //input
.VIDEO_I_DATA(VIDEO_I_DATA),           //input      [VIDEO_I_DATA_WIDTH-1 : 0] 
.RESET(RESET),                         //input                               
.B_RDREQ(HISTCAL_B_RDREQ),              //output reg                           
.B_RDDATA(HISTCAL_B_RDDATA),              // output reg [HIST_BIN_WIDTH-1:0]       
.B_ADDR(HISTCAL_B_ADDR),                //output reg [VIDEO_I_DATA_WIDTH-1 : 0] 
.A_WRREQ(HISTCAL_A_WRREQ),              //output reg                            
.A_WRDATA(HISTCAL_A_WRDATA),           // output reg [HIST_BIN_WIDTH-1:0]      
.A_ADDR(HISTCAL_A_ADDR)              // output reg [VIDEO_I_DATA_WIDTH-1 : 0]
);


DPRAM_GENERIC_DC1 #(.ADDR_WIDTH (VIDEO_I_DATA_WIDTH),  
                   .DATA_WIDTH (HIST_BIN_WIDTH))
PING_HIST_MEMORY(
    .A_CLK(VIDEO_I_PCLK),
    .A_ADDR(PING_A_ADDR),//input  [7:0]
    .A_WRREQ(PING_A_WRREQ), 
    .A_WRDATA(PING_A_WRDATA),  //input  [35:0]
    .A_RDREQ(),    // input        
    .A_RDDATA(), //output [35:0]
    .B_CLK(VIDEO_I_PCLK), //input         
    .B_ADDR(PING_B_ADDR), //input  [7:0]  
    .B_WRREQ(), //input       
    .B_WRDATA(), //input  [35:0] 
    .B_RDREQ(PING_B_RDREQ), //input        
    .B_RDDATA(PING_B_RDDATA) //output [35:0]
    );

DPRAM_GENERIC_DC1 #(.ADDR_WIDTH (VIDEO_I_DATA_WIDTH),  
                   .DATA_WIDTH (HIST_BIN_WIDTH))
PONG_HIST_MEMORY(
    .A_CLK(VIDEO_I_PCLK),
    .A_ADDR(PONG_A_ADDR),//input  [7:0]
    .A_WRREQ(PONG_A_WRREQ), 
    .A_WRDATA(PONG_A_WRDATA),  //input  [35:0]
    .A_RDREQ(),    // input        
    .A_RDDATA(), //output [35:0]
    .B_CLK(VIDEO_I_PCLK), //input         
    .B_ADDR(PONG_B_ADDR), //input  [7:0]  
    .B_WRREQ(), //input       
    .B_WRDATA(), //input  [35:0] 
    .B_RDREQ(PONG_B_RDREQ), //input        
    .B_RDDATA(PONG_B_RDDATA) //output [35:0]
    ); 


//wire [127:0] clhe_probe;

//assign clhe_probe = {VIDEO_I_PCLK,PING_A_ADDR,PING_A_WRREQ,PING_A_WRDATA,PING_B_ADDR,PING_B_RDREQ,PING_B_RDDATA,HISTEQ_B_ADDR,HISTEQ_B_RDREQ,HISTEQ_B_RDDATA,
//                     VIDEO_I_DAV,VIDEO_I_DATA,VIDEO_I_VSYNC,VIDEO_I_HSYNC,VIDEO_I_EOI,Data_Forwarding_En,RESET,PING_PONG_ENABLE,4'd0};
                         

//ila_0 clhe_ila_1 (
//	.clk(VIDEO_I_PCLK),
//	.probe0(clhe_probe)
//);



endmodule





