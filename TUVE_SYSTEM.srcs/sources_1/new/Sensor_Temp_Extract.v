`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2018 01:24:56 PM
// Design Name: 
// Module Name: Sensor_Temp_Extract
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


module Sensor_Temp_Extract #(
    parameter Total_Temperature_Byte = 16,
    parameter shift_right_bit        = 4,
    parameter VIDEO_XSIZE            = 640,             //320,
    parameter VIDEO_YSIZE            = 480             //240   
    ) 
    (
    input             clk,
    input             reset,
(* mark_debug = "true" *)    input             Sensor_Linevalid,
(* mark_debug = "true" *)    input             Sensor_Framevalid,
(* mark_debug = "true" *)    input             Sensor_Data_Valid,
(* mark_debug = "true" *)    input      [15:0] Sensor_Data,
(* mark_debug = "true" *)    output     [31:0] Sensor_Temperature
    );

   

localparam [21:0]I_VIDEO_YSIZE = (2**20)/VIDEO_YSIZE;

// reg  [15:0]Sensor_Data_D;
(* mark_debug = "true" *)reg  Sensor_Linevalid_D,Sensor_Framevalid_D;
(* mark_debug = "true" *)reg  Sensor_Data_Valid_D;
(* mark_debug = "true" *)wire Sensor_Linevalid_Posedge,Sensor_Linevalid_Negedge,Sensor_Framevalid_Posedge,Sensor_Framevalid_Negedge;
(* mark_debug = "true" *)reg [2:0] state;
// reg        Sensor_Temperature_Valid;
(* mark_debug = "true" *)reg [31:0] Line_Temperature_Sum;
reg [4:0]  Sensor_Temperature_Data_Cnt;
(* mark_debug = "true" *)reg [31:0] Frame_Temperature_Sum;
(* mark_debug = "true" *)reg [65:0] Sensor_Temperature_d;

(* mark_debug = "true" *)reg flag;

assign Sensor_Linevalid_Posedge = !Sensor_Linevalid_D & Sensor_Linevalid;
assign Sensor_Linevalid_Negedge =  Sensor_Linevalid_D & !Sensor_Linevalid;
 
assign Sensor_Framevalid_Posedge = !Sensor_Framevalid_D & Sensor_Framevalid;
assign Sensor_Framevalid_Negedge =  Sensor_Framevalid_D & !Sensor_Framevalid; 

assign Sensor_Temperature = Sensor_Temperature_d[20+31:20];


//reg [31:0] Line_Temperature_Sum;
// reg [31:0] Line_Temperature_Avg;
// reg [31:0] Frame_Temperature_Sum;
// reg [31:0] Frame_Temperature_Avg;
//reg [4:0]  Sensor_Temperature_Data_Cnt;
    
always @(posedge clk or posedge reset)begin
    if(reset)begin
        Sensor_Temperature_d <= 0;
        // Sensor_Temperature_Valid <= 0;
        state <= 0;
        Line_Temperature_Sum <= 0;
        // Line_Temperature_Avg <= 0;
        Frame_Temperature_Sum <= 0;
        // Frame_Temperature_Avg <= 0;
        Sensor_Temperature_Data_Cnt <= 0;
        flag <= 1;
    end
    else begin
        Sensor_Linevalid_D  <= Sensor_Linevalid;
        Sensor_Framevalid_D <= Sensor_Framevalid;
        Sensor_Data_Valid_D <= Sensor_Data_Valid;
        // Sensor_Data_D       <= Sensor_Data;
        
        
        if(Sensor_Framevalid_Posedge)begin
            Sensor_Temperature_Data_Cnt <= 0;
            Line_Temperature_Sum        <= 0; 
            Frame_Temperature_Sum    <= 0;
            //Sensor_Temperature_d       <= ((Frame_Temperature_Sum + {{shift_right_bit{1'b0}},Line_Temperature_Sum[31:shift_right_bit]}) *I_VIDEO_YSIZE); 
            Sensor_Temperature_d       <= Frame_Temperature_Sum *I_VIDEO_YSIZE; 
            // Sensor_Temperature_Valid <= 1'b1;  
//            state <= 3'd1;
        end
        else begin
            if(Sensor_Linevalid==0 && flag)begin
//                if(Sensor_Data_Valid == 1)begin
                    if(Sensor_Temperature_Data_Cnt== 16)begin
                        Sensor_Temperature_Data_Cnt <= 0;
                        Frame_Temperature_Sum       <= Frame_Temperature_Sum + {{shift_right_bit{1'b0}},Line_Temperature_Sum[31:shift_right_bit]}; 
                        flag                        <= 0; 
//                        state <= 3'd2; 
                    end
                    else begin
                        Line_Temperature_Sum        <= Line_Temperature_Sum + Sensor_Data[13:0];  
                        Sensor_Temperature_Data_Cnt <= Sensor_Temperature_Data_Cnt + 1;    
//                        state <= 3'd3; 
                    end   
                    
//                end
            end
            else begin
                if(Sensor_Linevalid ==1)begin
                    Line_Temperature_Sum <= 0;
                    Sensor_Temperature_Data_Cnt <= 0;
                    flag <= 1;
//                    state <= 3'd4; 
                end
//                else begin
//                    state <= 3'd5; 
//                end    
                
            end
        
        end
        

    end

end    

//wire [127:0]probe0;

//assign probe0={
//                Sensor_Linevalid,
//                Sensor_Framevalid,
//                Sensor_Data_Valid,
//                Sensor_Data,      
//                Frame_Temperature_Sum,
//                Line_Temperature_Sum,
////                Sensor_Temperature_d[43:0],
//                Sensor_Temperature_d[43:8],
//                Sensor_Temperature_Data_Cnt,
//                state,
//                flag               
//                };


//ila_0 temp_ila(
//	.clk( clk),
//	.probe0( probe0)
//);    
    
    
endmodule
