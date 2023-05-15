`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2018 04:55:44 PM
// Design Name: 
// Module Name: BINARY_TO_BCD
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


module BINARY_TO_BCD #(parameter DATA_IN_WIDTH  = 8,
                                 DATA_OUT_WIDTH = 12)
(
input                         CLK,
input                         RST,
input  [DATA_IN_WIDTH-1:0]    BIN_DATA_IN,
input                         BIN_DATA_IN_VALID,
output [DATA_OUT_WIDTH-1:0]   BCD_DATA_OUT,
output                        BCD_DATA_OUT_VALID
);

localparam [2:0] s_IDLE              = 3'b000,
                 s_SHIFT             = 3'b001,
                 s_CHECK_SHIFT_INDEX = 3'b010,
                 s_ADD               = 3'b011,
                 s_CHECK_DIGIT_INDEX = 3'b100,
                 s_BCD_DONE          = 3'b101;

reg [2:0] r_SM_Main = s_IDLE;

reg [DATA_OUT_WIDTH-1:0] r_BCD = 0;

reg [DATA_IN_WIDTH-1:0]      r_Binary = 0;

reg [(DATA_OUT_WIDTH/4)-1:0]   r_Digit_Index = 0;


reg [7:0]                  r_Loop_Count = 0;

wire [3:0]                 w_BCD_Digit;
reg                        r_DV = 1'b0;                       

always @(posedge CLK)
begin

  case (r_SM_Main) 

    // Stay in this state until BIN_DATA_IN_VALID comes along
    s_IDLE :
      begin
        r_DV <= 1'b0;
         
        if (BIN_DATA_IN_VALID == 1'b1)
          begin
            r_Binary  <= BIN_DATA_IN;
            r_SM_Main <= s_SHIFT;
            r_BCD     <= 0;
          end
        else
          r_SM_Main <= s_IDLE;
      end
             

    // Always shift the BCD Vector until we have shifted all bits through
    // Shift the most significant bit of r_Binary into r_BCD lowest bit.
    s_SHIFT :
      begin
        r_BCD     <= r_BCD << 1;
        r_BCD[0]  <= r_Binary[DATA_IN_WIDTH-1];
        r_Binary  <= r_Binary << 1;
        r_SM_Main <= s_CHECK_SHIFT_INDEX;
      end          
     

    // Check if we are done with shifting in r_Binary vector
    s_CHECK_SHIFT_INDEX :
      begin
        if (r_Loop_Count == DATA_IN_WIDTH-1)
          begin
            r_Loop_Count <= 0;
            r_SM_Main    <= s_BCD_DONE;
          end
        else
          begin
            r_Loop_Count <= r_Loop_Count + 1;
            r_SM_Main    <= s_ADD;
          end
      end
             

    // Break down each BCD Digit individually.  Check them one-by-one to
    // see if they are greater than 4.  If they are, increment by 3.
    // Put the result back into r_BCD Vector.  
    s_ADD :
      begin
        if (w_BCD_Digit > 4)
          begin                                     
            r_BCD[(r_Digit_Index*4)+:4] <= w_BCD_Digit + 3;  
          end
         
        r_SM_Main <= s_CHECK_DIGIT_INDEX; 
      end       
     
     
    // Check if we are done incrementing all of the BCD Digits
    s_CHECK_DIGIT_INDEX :
      begin
        if (r_Digit_Index == (DATA_OUT_WIDTH/4)-1)
          begin
            r_Digit_Index <= 0;
            r_SM_Main     <= s_SHIFT;
          end
        else
          begin
            r_Digit_Index <= r_Digit_Index + 1;
            r_SM_Main     <= s_ADD;
          end
      end
     


    s_BCD_DONE :
      begin
        r_DV      <= 1'b1;
        r_SM_Main <= s_IDLE;
      end
     
     
    default :
      r_SM_Main <= s_IDLE;
        
  endcase
end // always @ (posedge i_Clock)  


assign w_BCD_Digit = r_BCD[r_Digit_Index*4 +: 4];
   
assign BCD_DATA_OUT = r_BCD;
assign BCD_DATA_OUT_VALID  = r_DV;
              
endmodule
