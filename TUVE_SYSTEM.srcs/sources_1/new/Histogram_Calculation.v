`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2017 02:01:07 PM
// Design Name: 
// Module Name: Histogram_And_Excess_Pixels_Calculation
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


module Histogram_Calculation#(parameter VIDEO_I_DATA_WIDTH = 12,
                                        HIST_BIN_WIDTH     = 19,
                                        NUMBER_OF_IN_PIXELS = 308160
                                                          )
(
input                                 VIDEO_I_PCLK,
input                                 VIDEO_I_VSYNC,
input                                 VIDEO_I_HSYNC,
input                                 VIDEO_I_DAV,            
input      [VIDEO_I_DATA_WIDTH-1 : 0] VIDEO_I_DATA,
input                                 RESET,
input      [HIST_BIN_WIDTH-1:0]       B_RDDATA,
output reg                            B_RDREQ,
output reg [VIDEO_I_DATA_WIDTH-1 : 0] B_ADDR,
output reg                            A_WRREQ,
output reg [HIST_BIN_WIDTH-1:0]       A_WRDATA,
output reg [VIDEO_I_DATA_WIDTH-1 : 0] A_ADDR
);
    


reg [VIDEO_I_DATA_WIDTH-1 : 0] VIDEO_I_DATA_D;
//reg [VIDEO_I_DATA_WIDTH-1 : 0] VIDEO_I_DATA_DD;

reg  [VIDEO_I_DATA_WIDTH -1:0]  RD_ADDR,B_ADDR_D,B_ADDR_DD;//B_ADDR_DDD;
    
reg [19:0] Temp_Data_Count;  
//reg [6:0]temp_Count;
//reg [6:0]temp_Count1;

reg First_Time_Read;


reg VIDEO_I_DAV_D;
reg VIDEO_I_DAV_DD;
reg VIDEO_I_DAV_DDD;

reg [2:0] VIDEO_I_DAV_Count;
reg First_Time_VIDEO_I_DAV;

reg [HIST_BIN_WIDTH :0 ]Pixel_Count;

always @(posedge VIDEO_I_PCLK or posedge RESET)begin
if(RESET)begin
    VIDEO_I_DATA_D    <= 0;
    VIDEO_I_DAV_DD    <= 0;
    //VIDEO_I_DATA_DD   <= 0;
    First_Time_Read   <= 1;
        
    Temp_Data_Count   <= 0;
    B_ADDR            <= 0;
    B_ADDR_D          <= 0;
    B_ADDR_DD         <= 0;
    B_RDREQ           <= 0;
    A_ADDR            <= 0;
    A_WRREQ           <= 0;
    A_WRDATA          <= 0;  
    VIDEO_I_DAV_D     <= 0;
    VIDEO_I_DAV_DD    <= 0;
    VIDEO_I_DAV_DDD   <= 0;   
    Pixel_Count       <= 0; 
    
    VIDEO_I_DAV_Count        <= 0;
    First_Time_VIDEO_I_DAV   <= 1;  
end
else begin
    VIDEO_I_DATA_D    <= VIDEO_I_DATA;
    if(VIDEO_I_VSYNC)begin
        First_Time_Read <=  1'b1;
        Temp_Data_Count <= 0;
        Pixel_Count     <= 0;
        First_Time_VIDEO_I_DAV<= 1;
        
    end
        
    if(VIDEO_I_DAV)begin
        if(First_Time_VIDEO_I_DAV)begin
            if(VIDEO_I_DAV_Count == 1)begin
                VIDEO_I_DAV_DDD        <= 1;
                VIDEO_I_DAV_Count      <=0;
                First_Time_VIDEO_I_DAV <= 0;
            end
            else begin
                VIDEO_I_DAV_Count <= VIDEO_I_DAV_Count +1;
                VIDEO_I_DAV_DDD   <= 0;
            end
        end
        else begin 
            VIDEO_I_DAV_DDD <= 1;
        end    
        
        B_RDREQ     <= VIDEO_I_DAV;
        B_ADDR      <= VIDEO_I_DATA;
        B_ADDR_D    <= B_ADDR;
        B_ADDR_DD   <= B_ADDR_D;
    end
    else begin
        B_RDREQ         <= 1'b0;
        VIDEO_I_DAV_DDD <= 0;
    end
              
    if((VIDEO_I_DAV_DDD) || (Pixel_Count==(NUMBER_OF_IN_PIXELS -1)))begin
            Pixel_Count <= Pixel_Count +1;               
            if((B_ADDR_D == B_ADDR) && (Pixel_Count < (NUMBER_OF_IN_PIXELS-1)))begin
                if(First_Time_Read)begin
                    First_Time_Read <= 0; 
                    Temp_Data_Count  <= B_RDDATA + 2;
                end
                else begin
                    Temp_Data_Count <=  Temp_Data_Count + 1;                            
                end
                A_WRREQ    <= 1'b0;              
            end
            else begin
            if(Pixel_Count == (NUMBER_OF_IN_PIXELS -1))begin
                A_WRREQ    <= 1'b1; 
                if((B_ADDR_D == B_ADDR))begin
                    A_WRDATA   <= Temp_Data_Count;
                end
                else begin
                    A_WRDATA <= B_RDDATA +1;                 
                end    
                Temp_Data_Count <= 0;
                A_ADDR          <= B_ADDR;
                First_Time_Read <= 1;
            end
            else begin 
                if((B_ADDR_DD == B_ADDR_D))begin
                    Temp_Data_Count  <= 0;
                    A_WRDATA         <= Temp_Data_Count;
                    A_ADDR           <= B_ADDR_D;
                    First_Time_Read  <= 1;
                end
                else begin
                    A_WRDATA      <= B_RDDATA +1 ;
                    A_ADDR        <= B_ADDR_D; 
                end
                A_WRREQ    <= 1'b1;
            end 
            end
    end
    else begin
       A_WRREQ    <= 1'b0;
    end   
end
end

endmodule