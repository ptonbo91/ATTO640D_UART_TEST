`timescale 1ns / 1ps

module mipi_csi_ip_controller(
input  wire          m_axi_aclk,
input  wire          m_axi_aresetn,
output reg  [7 : 0]  m_axi_awaddr,
output reg           m_axi_awvalid,
input  wire          m_axi_awready,
output reg  [31 : 0] m_axi_wdata,
output reg  [3 : 0]  m_axi_wstrb,
output reg           m_axi_wvalid,
input  wire          m_axi_wready,
input  wire [1 : 0]  m_axi_bresp,
input  wire          m_axi_bvalid,
output reg           m_axi_bready,
output reg  [7 : 0]  m_axi_araddr,
output reg           m_axi_arvalid,
input  wire          m_axi_arready,
input  wire [31 : 0] m_axi_rdata,
input  wire [1 : 0]  m_axi_rresp,
input  wire          m_axi_rvalid,
output reg           m_axi_rready,
input                frame_valid_signal,
output reg           resetn
    );

////////////// Axi QSPI ///////////////////////////////////////


///////////////////////////////////////////////////////////

parameter [5:0]   Idle                     = 6'd0,
                  Wait                     = 6'd1,
                  Write_Wait               = 6'd2,
                  Soft_Reset_En_SEND       = 6'd3,
                  Soft_Reset_En_WAIT       = 6'd4,
                  Soft_Reset_Dis_SEND      = 6'd5,
                  Soft_Reset_Dis_WAIT      = 6'd6,
                  Rd_Core_Config_SEND_CMD  = 6'd7,
                  Rd_Core_Config_WAIT_CMD  = 6'd8,
                  Rd_Core_Config_DATA      = 6'd9,
                  Check_Core_Config_DATA   = 6'd10,
                  Wr_Timing_reg1_SEND      = 6'd11,
                  Wr_Timing_reg1_WAIT      = 6'd12,
                  Wr_Timing_reg2_SEND      = 6'd13,
                  Wr_Timing_reg2_WAIT      = 6'd14,
                  Wr_Timing_reg3_SEND      = 6'd15,
                  Wr_Timing_reg3_WAIT      = 6'd16,
                  Wr_Timing_reg4_SEND      = 6'd17,
                  Wr_Timing_reg4_WAIT      = 6'd18,
                  Rd_Line_Time_SEND_CMD    = 6'd19,
                  Rd_Line_Time_WAIT_CMD    = 6'd20,
                  Rd_Line_Time_DATA        = 6'd21,
                  Rd_Blip_Time_SEND_CMD    = 6'd22,
                  Rd_Blip_Time_WAIT_CMD    = 6'd23,
                  Rd_Blip_Time_DATA        = 6'd24,
                  Wr_Core_Enbale_SEND      = 6'd25,
                  Wr_Core_Enbale_WAIT      = 6'd26,
                  Rd_Intr_Status_SEND_CMD  = 6'd27,
                  Rd_Intr_Status_WAIT_CMD  = 6'd28,
                  Rd_Intr_Status_DATA      = 6'd29,                  
                  Config_Done              = 6'd30,
                  Wr_Line_Cnt_VC0_SEND     = 6'd31,
                  Wr_Line_Cnt_VC0_WAIT     = 6'd32;


(* mark_debug = "true" *) reg [5:0] st;   
 (* mark_debug = "true" *)reg [5:0] st_temp;   
(* mark_debug = "true" *) reg [31:0] Core_Config_DATA;
reg [31:0] Blip_Time_DATA;
reg [31:0] Line_Time_DATA;
reg [31:0] Intr_Status_DATA;
reg [15:0]cnt;
reg [7:0]frame_counter;
reg frame_valid_signal_d;  



always @(posedge m_axi_aclk or posedge m_axi_aresetn)begin
    if(!m_axi_aresetn)begin
        st                     <= Idle;
        Core_Config_DATA       <= 32'd0;
        Line_Time_DATA         <= 32'd0;
        Blip_Time_DATA         <= 32'd0;
        Intr_Status_DATA       <= 32'd0;
        m_axi_awaddr           <= 8'h00;  
        m_axi_wdata            <= 32'h00;  
        m_axi_awvalid          <= 1'b0;
        m_axi_wvalid           <= 1'b0;
        m_axi_araddr           <= 8'h00;
        m_axi_arvalid          <= 1'b0;   
        cnt                    <= 0; 
        m_axi_wstrb            <= 0;
        m_axi_bready           <= 1'b0;
        resetn                 <= 1'b0;
        frame_counter          <= 8'd0;
        frame_valid_signal_d   <= 1'b0;
    end
    else begin
//        frame_valid_signal_d <= frame_valid_signal;
//        if(!frame_valid_signal & (frame_valid_signal_d))begin
//            frame_counter <= frame_counter+1;
//        end
//        if(frame_counter == 4)begin
//            resetn <= 1'b0;
//        end
        case(st)
            Idle  : begin
                            //st                   <= Wr_En_CMD0;
                            m_axi_awaddr           <= 8'h00;  
                            m_axi_wdata            <= 32'h00;  
                            m_axi_awvalid          <= 1'b0;
                            m_axi_wvalid           <= 1'b0;
                            m_axi_araddr           <= 8'h00;
                            m_axi_arvalid          <= 1'b0; 
                            st                     <= Rd_Core_Config_SEND_CMD;//Wr_Timing_reg1_SEND;//Soft_Reset_En_SEND;//Wr_Timing_reg1;//Rd_Core_Config_CMD;
//                            if(cnt == 16'h00FF)begin
//                                st<= Rd_Core_Config_CMD;//Soft_Reset;
//                                cnt    <= 0;
//                            end
//                            else begin
//                                cnt     <= cnt +1; 
//                                st <= Idle;
//                            end                          
                         
                         end

            Wait         : begin
                            if(m_axi_bvalid)begin
                                m_axi_bready  <= 1'b0;
                                st           <= st_temp;
                            end
                            else begin
                                st <= Wait;
                            end
                         end

            Write_Wait : begin
                          if(m_axi_wready)begin
                              m_axi_wdata   <= 32'h00;
                              m_axi_wvalid  <= 1'b0;
                          end
                          if(m_axi_bvalid)begin 
                              st <= st_temp;
                          end
            end

            Soft_Reset_En_SEND : begin// 
                                   m_axi_awaddr  <= 8'h00;    // Core config reg
                                   m_axi_wdata   <= 32'h02;  // Soft Reset
                                   m_axi_awvalid <= 1'b1;
                                   m_axi_wvalid  <= 1'b1;
                                   m_axi_bready  <= 1'b1;
                                   st            <= Soft_Reset_En_WAIT ;                                                    
                                end
            Soft_Reset_En_WAIT : begin// 
                               if(m_axi_awready)begin
                                   m_axi_awaddr  <= 8'h00;  
                                   m_axi_awvalid <= 1'b0;
                                   st            <= Wait;
                                   st_temp       <= Soft_Reset_Dis_SEND;
                                  if(m_axi_wready)begin
                                     m_axi_wdata   <= 32'h00;
                                     m_axi_wvalid  <= 1'b0;
                                   end
                                   else begin
                                      st            <= Write_Wait;
                                   end                                  
                               end                                  
                           end  
 
            Soft_Reset_Dis_SEND : begin// 
                                   m_axi_awaddr  <= 8'h00;    // Core config reg
                                   m_axi_wdata   <= 32'h00;  // Reset release
                                   m_axi_awvalid <= 1'b1;
                                   m_axi_wvalid  <= 1'b1;
                                   m_axi_bready  <= 1'b1;
                                   st            <= Soft_Reset_Dis_WAIT ;                                 
                            end  

            Soft_Reset_Dis_WAIT : begin// 
                               if(m_axi_awready)begin
                                   m_axi_awaddr  <= 8'h00;  
                                   m_axi_awvalid <= 1'b0;
                                   st            <= Wait;
                                   st_temp       <= Rd_Core_Config_SEND_CMD;
                                  if(m_axi_wready)begin
                                     m_axi_wdata   <= 32'h00;
                                     m_axi_wvalid  <= 1'b0;
                                   end
                                   else begin
                                      st            <= Write_Wait;
                                   end                                  
                               end                                  
                            end  

            Rd_Core_Config_SEND_CMD :begin // Read controller ready bit 2
                                           m_axi_araddr  <= 8'h00;    // Read core configure reg
                                           m_axi_arvalid <= 1'b1;
                                           m_axi_rready  <= 1'b1;  
                                           st            <= Rd_Core_Config_WAIT_CMD;
                                    end  
             Rd_Core_Config_WAIT_CMD :begin // Read controller ready bit 2
                                       if(m_axi_arready)begin
                                           st            <= Rd_Core_Config_DATA;
                                           m_axi_araddr  <= 8'h00;
                                           m_axi_arvalid <= 1'b0;
                                       end
                                    end 
          
            Rd_Core_Config_DATA:begin 
                                       if(m_axi_rvalid)begin
                                           Core_Config_DATA <= m_axi_rdata;
                                           m_axi_rready     <= 1'b0;
                                           st               <= Check_Core_Config_DATA;
                                       end
                                    end  
          Check_Core_Config_DATA : begin
                                       if(Core_Config_DATA[2]==1)begin
                                           st <= Wr_Line_Cnt_VC0_SEND;//Wr_Core_Enbale_SEND;//Wr_Timing_reg1_SEND;//Wr_Line_Cnt_VC0_SEND;//Wr_Core_Enbale_SEND;//Wr_Timing_reg1_SEND;
                                       end
                                       else begin
                                           st <= Rd_Core_Config_SEND_CMD;
                                       end   
          end

          Wr_Timing_reg1_SEND : begin  // HSA-BLIP
                                m_axi_awaddr  <= 8'h04; //8'h50;    // Timing reg 1
                                m_axi_wdata   <= 32'h00008000;//32'h003c00d5;//32'h00600140;  // HSA = 0x0060 BLIP = 0x0140
                                m_axi_awvalid <= 1'b1;
                                m_axi_wvalid  <= 1'b1; 
                                m_axi_bready  <= 1'b1;                           
                                st            <= Wr_Timing_reg1_WAIT;
                            end    

          Wr_Timing_reg1_WAIT : begin
                            if(m_axi_awready)begin
                                st            <= Wait;
                                st_temp       <= Wr_Line_Cnt_VC0_SEND;//Wr_Timing_reg2_SEND;
                                m_axi_awaddr  <= 8'h00;  
                                m_axi_awvalid <= 1'b0;
                                if(m_axi_wready) begin 
                                  m_axi_wdata   <= 32'h00;
                                  m_axi_wvalid  <= 1'b0;
                                end
                                else begin
                                  st            <= Write_Wait;
                                end                    
                            end
           end

          Wr_Timing_reg2_SEND : begin  // HSA-BLIP
                                m_axi_awaddr  <= 8'h54;    // Timing reg 2
                                m_axi_wdata   <= 32'h078001E0;  // HACT = 0x0780 VACT = 0x01E0
                                m_axi_awvalid <= 1'b1;
                                m_axi_wvalid  <= 1'b1; 
                                m_axi_bready  <= 1'b1;                           
                                st            <= Wr_Timing_reg2_WAIT ;
                        end

          Wr_Timing_reg2_WAIT : begin  // HSA-BLIP
                            if(m_axi_awready)begin
                                st            <= Wait;
                                st_temp       <= Wr_Timing_reg3_SEND;
                                m_axi_awaddr  <= 8'h00;  
                                m_axi_awvalid <= 1'b0;
                                if(m_axi_wready) begin 
                                  m_axi_wdata   <= 32'h00;
                                  m_axi_wvalid  <= 1'b0;
                                end
                                else begin
                                  st            <= Write_Wait;
                                end                    
                            end   
                        end


          Wr_Timing_reg3_SEND : begin  // HSA-BLIP
                                m_axi_awaddr  <= 8'h58;    // Timing reg 3
                                m_axi_wdata   <= 32'h003c003D;//32'h00600060;  // HBP = 0x0060 HFP = 0x0140
                                m_axi_awvalid <= 1'b1;
                                m_axi_wvalid  <= 1'b1; 
                                m_axi_bready  <= 1'b1;                           
                                st            <= Wr_Timing_reg3_WAIT ;  
                        end
                        
          Wr_Timing_reg3_WAIT : begin  // HSA-BLIP
                            if(m_axi_awready)begin
                                st            <= Wait;
                                st_temp       <= Wr_Timing_reg4_SEND;
                                m_axi_awaddr  <= 8'h00;  
                                m_axi_awvalid <= 1'b0;
                                if(m_axi_wready) begin 
                                  m_axi_wdata   <= 32'h00;
                                  m_axi_wvalid  <= 1'b0;
                                end
                                else begin
                                  st            <= Write_Wait;
                                end                    
                            end 
                        end


          Wr_Timing_reg4_SEND : begin  // HSA-BLIP
                                m_axi_awaddr  <= 8'h5C;    // Timing reg 4
                                m_axi_wdata   <= 32'h00050505;//32'h00050505;  // VSA = 0x05 VBP = 0x05 VFP =0x05
                                m_axi_awvalid <= 1'b1;
                                m_axi_wvalid  <= 1'b1; 
                                m_axi_bready  <= 1'b1;                           
                                st            <= Wr_Timing_reg4_WAIT ;    
                        end   

          Wr_Timing_reg4_WAIT : begin  // HSA-BLIP
                            if(m_axi_awready)begin
                                st            <= Wait;
                                st_temp       <= Rd_Line_Time_SEND_CMD;//Wr_Core_Enbale;
                                m_axi_awaddr  <= 8'h00;  
                                m_axi_awvalid <= 1'b0;
                                if(m_axi_wready) begin 
                                  m_axi_wdata   <= 32'h00;
                                  m_axi_wvalid  <= 1'b0;
                                end
                                else begin
                                  st            <= Write_Wait;
                                end                    
                            end 
                        end   

             Rd_Line_Time_SEND_CMD :begin 
                                           m_axi_araddr  <= 8'h60;    // Read line time in bytes
                                           m_axi_arvalid <= 1'b1;
                                           m_axi_rready  <= 1'b1;  
                                           st            <= Rd_Line_Time_WAIT_CMD;
                                    end  
                                    
             Rd_Line_Time_WAIT_CMD :begin 
                                       if(m_axi_arready)begin
                                           st            <= Rd_Line_Time_DATA;
                                           m_axi_araddr  <= 8'h00;
                                           m_axi_arvalid <= 1'b0;
                                       end
                                    end 
          
             Rd_Line_Time_DATA:begin 
                                       if(m_axi_rvalid)begin
                                           Line_Time_DATA   <= m_axi_rdata;
                                           m_axi_rready     <= 1'b0;
                                           st               <= Rd_Blip_Time_SEND_CMD;
                                       end
                                    end  

             Rd_Blip_Time_SEND_CMD :begin 
                                           m_axi_araddr  <= 8'h64;    // Read lip time in counts
                                           m_axi_arvalid <= 1'b1;
                                           m_axi_rready  <= 1'b1;  
                                           st            <= Rd_Blip_Time_WAIT_CMD;
                                    end  
                                    
             Rd_Blip_Time_WAIT_CMD :begin 
                                       if(m_axi_arready)begin
                                           st            <= Rd_Blip_Time_DATA;
                                           m_axi_araddr  <= 8'h00;
                                           m_axi_arvalid <= 1'b0;
                                       end
                                    end 
          
             Rd_Blip_Time_DATA:begin 
                                       if(m_axi_rvalid)begin
                                           Blip_Time_DATA   <= m_axi_rdata;
                                           m_axi_rready     <= 1'b0;
                                           st               <= Wr_Core_Enbale_SEND;
                                       end
                                    end

          Wr_Line_Cnt_VC0_SEND : begin
                                m_axi_awaddr  <= 8'h40;    // 
                                m_axi_wdata   <= 32'h000001E0;//32'h00000258;//32'h000001E0; //32'h00000080;        
                                m_axi_awvalid <= 1'b1;                 
                                m_axi_wvalid  <= 1'b1;                 
                                m_axi_bready  <= 1'b1;                 
                                st            <= Wr_Line_Cnt_VC0_WAIT ; 
          end
          
          Wr_Line_Cnt_VC0_WAIT: begin
                           if(m_axi_awready)begin
                                st            <= Wait;
                                st_temp       <= Wr_Core_Enbale_SEND;
                                resetn        <= 1'b1;
                                m_axi_awaddr  <= 8'h00;  
                                m_axi_awvalid <= 1'b0;
                                if(m_axi_wready) begin 
                                  m_axi_wdata   <= 32'h00;
                                  m_axi_wvalid  <= 1'b0;
                                end
                                else begin
                                  st            <= Write_Wait;
                                end                    
                            end            
          end
          Wr_Core_Enbale_SEND : begin 
                                m_axi_awaddr  <= 8'h00;    // Core enable
                                m_axi_wdata   <= 32'h00000001;  
                                m_axi_awvalid <= 1'b1;
                                m_axi_wvalid  <= 1'b1; 
                                m_axi_bready  <= 1'b1;                           
                                st            <= Wr_Core_Enbale_WAIT ; 
                        end 
          Wr_Core_Enbale_WAIT : begin 
                            if(m_axi_awready)begin
                                st            <= Wait;
                                st_temp       <= Rd_Intr_Status_SEND_CMD;
                                resetn        <= 1'b1;
                                m_axi_awaddr  <= 8'h00;  
                                m_axi_awvalid <= 1'b0;
                                if(m_axi_wready) begin 
                                  m_axi_wdata   <= 32'h00;
                                  m_axi_wvalid  <= 1'b0;
                                end
                                else begin
                                  st            <= Write_Wait;
                                end                    
                            end  
                        end

             Rd_Intr_Status_SEND_CMD :begin 
                                           m_axi_araddr  <= 8'h24;//8'h24;//8'h40;    // Read Interrupt status
                                           m_axi_arvalid <= 1'b1;
                                           m_axi_rready  <= 1'b1;  
                                           st            <= Rd_Intr_Status_WAIT_CMD;
                                    end  
                                    
             Rd_Intr_Status_WAIT_CMD :begin 
                                       if(m_axi_arready)begin
                                           st            <= Rd_Intr_Status_DATA;
                                           m_axi_araddr  <= 8'h00;
                                           m_axi_arvalid <= 1'b0;
                                       end
                                    end 
          
             Rd_Intr_Status_DATA:begin 
                                       if(m_axi_rvalid)begin
                                           Intr_Status_DATA <= m_axi_rdata;
                                           m_axi_rready     <= 1'b0;
                                           st               <= Rd_Intr_Status_SEND_CMD;
                                       end
                                    end          

          Config_Done : begin
                    st <= Config_Done ;    
          end                                                              
        endcase
    
    end
end
           
endmodule
