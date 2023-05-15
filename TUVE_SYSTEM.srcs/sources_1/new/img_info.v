`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2018 10:27:25 AM
// Design Name: 
// Module Name: frame_info
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


module img_info #(
parameter [9:0] VIDEO_XSIZE   = 640,
parameter [9:0] VIDEO_YSIZE   = 480,
parameter       BIT_WIDTH     = 14
           
)
(

    input                      clk,
    input                      reset,
    input                      Sensor_Linevalid,
    input                      Sensor_Framevalid,
    input                      Sensor_EOI,
    input                      Sensor_Data_Valid,
    input      [BIT_WIDTH-1:0] Sensor_Data,
    input      [BIT_WIDTH-1:0] Img_Min_Limit,
    input      [BIT_WIDTH-1:0] Img_Max_Limit,
    output reg [BIT_WIDTH-1:0] Img_Avg
    );

localparam  [33:0] NUMBER_OF_IN_PIXELS = (VIDEO_XSIZE * VIDEO_YSIZE);

    
reg [33:0] img_sum;    
   
reg DIV_Start;
reg [33:0] dvsr;
reg [33:0] dvnd;
wire DIV_Done;
wire [33:0]quo;
wire [33:0]rmd;
    
always @(posedge clk or posedge reset)begin
    if(reset)begin
        Img_Avg  <= 0;
        img_sum  <= 0;
        dvsr     <= 0;
        dvnd     <= 0;
        DIV_Start<= 1'b0;
    end
    else begin
        dvsr      <= NUMBER_OF_IN_PIXELS;
        
        if(Sensor_Data_Valid)begin
            if((Img_Min_Limit<= Sensor_Data) && (Sensor_Data <= Img_Max_Limit))begin
                img_sum <= img_sum + Sensor_Data;
            end 
        end 
        else begin
            img_sum <= img_sum;
        end
 
        if(Sensor_EOI)begin
            img_sum <= 0;
            dvnd      <= img_sum;
            DIV_Start <= 1'b1;
        end
        else begin
            dvnd      <= 0; 
            DIV_Start <= 1'b0;
        end
        
        if(DIV_Done)begin
             Img_Avg <= quo[BIT_WIDTH -1:0];
        end
        
     
    end
    
end        
    

div	# (.W(34),
	   .CBIT(6))
DIVISION_Distribution_Value(
		.clk(clk), 
		.reset(reset), 
		.start(DIV_Start),
		.dvsr(dvsr), 
		.dvnd(dvnd) ,
		.done_tick(DIV_Done), 
		.quo(quo),
		.rmd(rmd) 
		);

    
endmodule
