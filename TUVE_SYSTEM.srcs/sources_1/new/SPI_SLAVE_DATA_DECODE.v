//`define ILA_DEBUG_SPI_SLAVE_DATA_DECODE

module SPI_SLAVE_DATA_DECODE
  #(parameter DATA_WIDTH = 8)
  (
   (* mark_debug = "true" *) input                         rst,   
   (* mark_debug = "true" *) input                         clk,      
   (* mark_debug = "true" *) input                         data_in_valid,    
   (* mark_debug = "true" *) input      [DATA_WIDTH-1:0]   data_in, 
   (* mark_debug = "true" *) output reg                    data_out_valid,    
   (* mark_debug = "true" *) output reg [DATA_WIDTH-1:0]   data_out,           
   (* mark_debug = "true" *) output reg [DATA_WIDTH-1:0]   debug_reg,
   (* mark_debug = "true" *) output reg                    usb_video_data_out_sel,
   (* mark_debug = "true" *) output reg                    pal_ntsc_sel
        
   );

localparam [3:0] ADDR_BITS = 4,
                 DATA_BITS = 4;
localparam [3:0] USB_DATA_OUT_SEL_REG_ADDR_WR = 4'h1,
                 USB_DATA_OUT_SEL_REG_ADDR_RD = 4'h9,
                 PAL_NTSC_SEL_REG_ADDR_WR     = 4'h2,
                 PAL_NTSC_SEL_REG_ADDR_RD     = 4'hA;

(* mark_debug = "true" *)reg [3:0] usb_data_out_sel_reg_data;                 
(* mark_debug = "true" *)reg [3:0] pal_ntsc_sel_reg_data;

  always @(posedge clk or posedge rst) begin
    if(rst)begin
      usb_video_data_out_sel    <= 1'b0;
      debug_reg                 <= 8'h0;
      data_out_valid            <= 1'b0;
      data_out                  <= 8'h0;
      usb_data_out_sel_reg_data <= 4'h0;
      pal_ntsc_sel_reg_data     <= 4'h0;  
      pal_ntsc_sel              <= 1'b0; 
    end
    else begin
      if(data_in_valid)begin
       debug_reg <= data_in;       
       case(data_in[DATA_WIDTH-1:DATA_WIDTH-DATA_BITS])
        USB_DATA_OUT_SEL_REG_ADDR_WR : begin
          usb_data_out_sel_reg_data <= data_in[DATA_BITS-1:0];
          if(data_in[DATA_BITS-1:0]== 4'h0)begin
            usb_video_data_out_sel <= 1'b0;
          end
          else if(data_in[DATA_BITS-1:0]== 4'h1)begin
            usb_video_data_out_sel <= 1'b1;
          end
          else begin
            usb_video_data_out_sel <= usb_video_data_out_sel;
          end
          data_out_valid         <= 1'b0;  
        end        
        
        USB_DATA_OUT_SEL_REG_ADDR_RD : begin
             data_out_valid         <= 1'b1;
             data_out               <= {USB_DATA_OUT_SEL_REG_ADDR_WR,usb_data_out_sel_reg_data};
        end
        
        PAL_NTSC_SEL_REG_ADDR_WR : begin
          pal_ntsc_sel_reg_data <= data_in[DATA_BITS-1:0];
          if(data_in[DATA_BITS-1:0]== 4'h0)begin
            pal_ntsc_sel <= 1'b0;
          end
          else if(data_in[DATA_BITS-1:0]== 4'h1)begin
            pal_ntsc_sel <= 1'b1;
          end
          else begin
            pal_ntsc_sel <= pal_ntsc_sel;
          end
          data_out_valid         <= 1'b0;  
        end        
        
        PAL_NTSC_SEL_REG_ADDR_RD : begin
             data_out_valid         <= 1'b1;
             data_out               <= {PAL_NTSC_SEL_REG_ADDR_WR,pal_ntsc_sel_reg_data};
        end

        
        default:begin
            data_out_valid         <= 1'b0;  
        end
       endcase 
      end
      else begin
        data_out_valid         <= 1'b0;  
      end
    end 
  end 


`ifdef ILA_DEBUG_SPI_SLAVE_DATA_DECODE

wire [127 : 0] probe_bt656;

assign probe_bt656 = { 
    108'h0,
    rst,  
    data_in,
    data_in_valid,   
    data_out,
    data_out_valid,
    usb_video_data_out_sel
             }; 

ila_0 i_ila_SPI_SLAVE_DATA_DECODE
(
	.clk(clk),
	.probe0(probe_bt656)
);
`endif  

endmodule // SPI_Slave