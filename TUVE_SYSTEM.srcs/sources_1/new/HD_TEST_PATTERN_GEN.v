//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 10/29/2021 02:17:48 PM
//// Design Name: 
//// Module Name: HD_TEST_PATTERN_GEN
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


//module HD_TEST_PATTERN_GEN(
//input hd_clk,
//input rst,
//output reg vsync,
//output reg hsync,
//output reg data_enable,
//output reg [15:0] hd_data
//    );

//localparam [3:0] st_idle       = 4'd0,
//                 st_code1      = 4'd1,
//                 st_code2      = 4'd2,
//                 st_code3      = 4'd3,
//                 st_code4      = 4'd4,
//                 st_blank_data = 4'd5,
//                 st_data       = 4'd6;
                 
//localparam [10:0] BLANK_PIX   = 692 , //(700-4-4 : 700-EAV-SAV)
//                  BLANK_LINE  = 30  ,
//                  ACTIVE_PIX  = 1280,
//                  ACTIVE_LINE = 720 ;                 
    
//reg [3:0]state;
//reg sigf;
//reg sigv;
//reg sigh;
//reg [10:0] pix_cnt;
//reg [10:0] line_cnt;
//reg [10:0] blank_cnt;
//reg eav;
//reg y_c;
    
//always @(posedge hd_clk or posedge rst)begin
//    if(rst) begin
//     sigf     <=1'b0;
//     sigv     <=1'b1;
//     sigh     <=1'b0; 
//     eav      <=1'b1;
//     pix_cnt  <= 0;
//     line_cnt <= 0;
//     blank_cnt<= 0;
//     state    <= st_idle;
//     y_c      <= 1'b0;
//     hsync    <= 1'b0;
//     vsync    <= 1'b0;
//     data_enable <= 1'b0; 
//    end
//    else begin
//           hsync <= 1'b0;
//           case (state)
//                st_idle: begin
//                    state   <= st_code1;
//                end
//                st_code1: begin
//                    data_enable<= 1'b0;
//                    hd_data[7:0]  <= 128;
//                    hd_data[15:8] <= 16;
//                    state         <= st_code2;
//                    blank_cnt <= 0;
//                    pix_cnt   <= 0; 
//                    if(line_cnt == 0 || line_cnt == 750)begin
//                       if(eav == 1'b1) begin
//                        vsync <= 1'b1;
//                       end 
//                    end 
//                    else if(eav == 1'b1)begin
//                        vsync <= 1'b0;
//                    end 
//                    if(line_cnt == 750)begin
//                        line_cnt =0;
//                    end    
//                    if(line_cnt>=25 && line_cnt < 745)begin
//                        sigv  <= 0;
//                    end    
//                    else begin
//                        sigv  <= 1;
//                    end              
//                end
//                st_code2: begin
//                    hd_data <= 0;
//                    state   <= st_code3;
//                    if(eav == 1'b0)begin
//                        hsync    <= 1'b1;
//                    end    
//                end                               
//                st_code3: begin
//                    hd_data <= 0;
//                    if(eav)begin
//                      sigh <= 1'b1;
//                    end
//                    else begin
//                      sigh <= 1'b0;  
//                    end
//                    state   <= st_code4;
//                end  
                
//                st_code4: begin
//                    hd_data[7] <= 1'b1;
//                    hd_data[6] <= sigf;
//                    hd_data[5] <= sigv;
//                    hd_data[4] <= sigh;
//                    case ({sigf,sigv,sigh})
//                        'h0: begin
//                             hd_data[3:0] <= 0;
//                        end
//                        'h1: begin
//                             hd_data[3:0] <= 13;
//                        end
//                        'h2: begin
//                             hd_data[3:0] <= 11;
//                        end
//                        'h3: begin
//                             hd_data[3:0] <= 6;
//                        end
//                        'h4: begin
//                             hd_data[3:0] <= 7;
//                        end
//                        'h5: begin
//                             hd_data[3:0] <= 10;
//                        end
//                        'h6: begin
//                             hd_data[3:0] <= 12;
//                        end
//                        default: begin
//                             hd_data[3:0] <= 1;
//                        end    
//                    endcase   
//                    if(eav)begin
//                        state   <= st_blank_data;   
//                    end                      
//                    else begin
//                        state   <= st_data; 
//                    end                                
//                end  
                
//                st_blank_data: begin
//                    hd_data[7:0]  <= 16;
//                    hd_data[15:8] <= 128;
//                    blank_cnt     <= blank_cnt +1;                  
//                    eav           <= 1'b0;
//                    if(blank_cnt == BLANK_PIX-1)begin
//                        state   <= st_code1; 
//                    end
//                    else begin
//                        state   <= st_blank_data;
//                    end
//                end
                 
//                st_data: begin
//                    if(line_cnt>=24 && line_cnt < 744)begin
//                        hd_data[7:0] <= line_cnt[7:0];
//                        hd_data[15:8]<= 16;
//                        data_enable  <= 1'b1;
//                    end
//                    else begin    
//                        hd_data[7:0]  <= 128;
//                        hd_data[15:8] <= 16;
//                    end    

//                    pix_cnt <= pix_cnt +1;
//                    if(pix_cnt == ACTIVE_PIX -1)begin   
//                        state    <= st_code1;  
//                        line_cnt <= line_cnt + 1;                    
//                    end
//                    else begin
//                        state <= st_data;  
//                    end   
//                    eav <= 1'b1;                                                       
//                end
//            endcase   
//        end         
//end    
//endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2021 02:17:48 PM
// Design Name: 
// Module Name: HD_TEST_PATTERN_GEN
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


module HD_TEST_PATTERN_GEN(
input hd_clk,
input rst,
output reg vsync,
output reg hsync,
output reg data_enable,
output reg [15:0] hd_data
    );

localparam [3:0] st_idle       = 4'd0,
                 st_code1      = 4'd1,
                 st_code2      = 4'd2,
                 st_code3      = 4'd3,
                 st_code4      = 4'd4,
                 st_blank_data = 4'd5,
                 st_data       = 4'd6;
                 
//localparam [10:0] BLANK_PIX   = 692 , //(700-4-4 : 700-EAV-SAV)
//                  BLANK_LINE  = 30  ,
//                  ACTIVE_PIX  = 1280,
//                  ACTIVE_LINE = 720 ;      

localparam [10:0] BLANK_PIX   = 280 , //(700-4-4 : 700-EAV-SAV)
                  BLANK_LINE  = 49  ,
                  ACTIVE_PIX  = 720,
                  ACTIVE_LINE = 576 ;                 
                                 
    
reg [3:0]state;
reg sigf;
reg sigv;
reg sigh;
reg [10:0] pix_cnt;
reg [10:0] line_cnt;
reg [10:0] blank_cnt;
reg eav;
reg y_c;
    
always @(posedge hd_clk or posedge rst)begin
    if(rst) begin
     sigf     <=1'b0;
     sigv     <=1'b1;
     sigh     <=1'b0; 
     eav      <=1'b1;
     pix_cnt  <= 0;
     line_cnt <= 0;
     blank_cnt<= 0;
     state    <= st_idle;
     y_c      <= 1'b0;
     hsync    <= 1'b0;
     vsync    <= 1'b0;
     data_enable <= 1'b0; 
    end
    else begin
           hsync <= 1'b0;
           case (state)
                st_idle: begin
                    state   <= st_code1;
                end
                st_code1: begin
                    data_enable<= 1'b0;
                    hd_data[7:0]  <= 128;
                    hd_data[15:8] <= 16;
                    state         <= st_code2;
                    blank_cnt <= 0;
                    pix_cnt   <= 0; 
//                    if(line_cnt == 0 || line_cnt == 750)begin
                    if(line_cnt == 0 || line_cnt == 625)begin
                       if(eav == 1'b1) begin
                        vsync <= 1'b1;
                       end 
                    end 
                    else if(line_cnt == 5)begin
                       if(eav == 1'b1) begin
                        vsync <= 1'b0;
                       end 
                    end 
//                    if(line_cnt == 750)begin
                    if(line_cnt == 625)begin
                        line_cnt =0;
                    end    
//                    if(line_cnt>=25 && line_cnt < 745)begin
                    if(line_cnt>=44 && line_cnt < 620)begin
                        sigv  <= 0;
                    end    
                    else begin
                        sigv  <= 1;
                    end              
                end
                st_code2: begin
                    hd_data <= 0;
                    state   <= st_code3;
//                    if(eav == 1'b0)begin
//                        hsync    <= 1'b1;
//                    end    
                end                               
                st_code3: begin
                    hd_data <= 0;
                    if(eav)begin
                      sigh <= 1'b1;
                    end
                    else begin
                      sigh <= 1'b0;  
                    end
                    state   <= st_code4;
                end  
                
                st_code4: begin
                    hd_data[7] <= 1'b1;
                    hd_data[6] <= sigf;
                    hd_data[5] <= sigv;
                    hd_data[4] <= sigh;
                    case ({sigf,sigv,sigh})
                        'h0: begin
                             hd_data[3:0] <= 0;
                        end
                        'h1: begin
                             hd_data[3:0] <= 13;
                        end
                        'h2: begin
                             hd_data[3:0] <= 11;
                        end
                        'h3: begin
                             hd_data[3:0] <= 6;
                        end
                        'h4: begin
                             hd_data[3:0] <= 7;
                        end
                        'h5: begin
                             hd_data[3:0] <= 10;
                        end
                        'h6: begin
                             hd_data[3:0] <= 12;
                        end
                        default: begin
                             hd_data[3:0] <= 1;
                        end    
                    endcase   
                    if(eav)begin
                        state   <= st_blank_data;   
                    end                      
                    else begin
                        state   <= st_data; 
                    end                                
                end  
                
                st_blank_data: begin
                    hd_data[7:0]  <= 16;
                    hd_data[15:8] <= 128;
                    blank_cnt     <= blank_cnt +1;                  
                    eav           <= 1'b0;
                    if(blank_cnt == BLANK_PIX-1)begin
                        state   <= st_code1; 
                    end
                    else begin
                        state   <= st_blank_data;
                    end
//                    if(blank_cnt>=436 && blank_cnt<476 )begin
                    if(blank_cnt>=198 && blank_cnt<238 )begin
                        hsync    <= 1'b1;
                    end  
                end
                 
                st_data: begin
//                    if(line_cnt>=24 && line_cnt < 744)begin
                    if(line_cnt>=43 && line_cnt < 619)begin
                        hd_data[7:0] <= pix_cnt[7:0];//line_cnt[7:0];
                        hd_data[15:8]<= 128;
                        data_enable  <= 1'b1;
                    end
                    else begin    
                        hd_data[7:0]  <= 16;
                        hd_data[15:8] <= 128;
                    end    

                    pix_cnt <= pix_cnt +1;
                    if(pix_cnt == ACTIVE_PIX -1)begin   
                        state    <= st_code1;  
                        line_cnt <= line_cnt + 1;                    
                    end
                    else begin
                        state <= st_data;  
                    end   
                    eav <= 1'b1;                                                       
                end
            endcase   
        end         
end    
endmodule
