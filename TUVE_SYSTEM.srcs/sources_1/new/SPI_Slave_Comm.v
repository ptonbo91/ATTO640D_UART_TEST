///////////////////////////////////////////////////////////////////////////////
// Description: SPI (Serial Peripheral Interface) Slave
//              Creates slave based on input configuration.
//              Receives a byte one bit at a time on MOSI
//              Will also push out byte data one bit at a time on MISO.  
//              Any data on input byte will be shipped out on MISO.
//              Supports multiple bytes per transaction when CS_n is kept 
//              low during the transaction.
//
// Note:        i_clk must be at least 4x faster than spi_sclk
//              MISO is tri-stated when not communicating.  Allows for multiple
//              SPI Slaves on the same interface.
//
// Parameters:  SPI_MODE, can be 0, 1, 2, or 3.  See above.
//              Can be configured in one of 4 modes:
//              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
//               0   |             0             |        0
//               1   |             0             |        1
//               2   |             1             |        0
//               3   |             1             |        1
//              More info: https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus#Mode_numbers
///////////////////////////////////////////////////////////////////////////////

//`define ILA_DEBUG_SPI_Slave_Commm
module SPI_Slave_Comm
//  #(parameter SPI_MODE = 0)
  (
   (* mark_debug = "true" *) input              rst,    // FPGA Reset
   (* mark_debug = "true" *) input              clk,      // FPGA Clock
   (* mark_debug = "true" *) input      [1:0]   spi_mode,
   (* mark_debug = "true" *) output reg         read_data_valid,    // Data Valid pulse (1 clock cycle)
   (* mark_debug = "true" *) output reg [7:0]   read_data,  // Byte received on MOSI
   (* mark_debug = "true" *) input              write_data_valid,    // Data Valid pulse to register write_data
   (* mark_debug = "true" *) input      [7:0]   write_data,  // Byte to serialize to MISO.
   (* mark_debug = "true" *) input              spi_sclk,
   (* mark_debug = "true" *) output reg         spi_miso,
   (* mark_debug = "true" *) input              spi_mosi,
   (* mark_debug = "true" *) input              spi_ss
   );


  // SPI Interface (All Runs at SPI Clock Domain)
 (* mark_debug = "true" *)wire w_CPOL;     // Clock polarity
 (* mark_debug = "true" *)wire w_CPHA;     // Clock phase
 (* mark_debug = "true" *)wire w_SPI_clk;  // Inverted/non-inverted depending on settings
 (* mark_debug = "true" *)wire w_SPI_MISO_Mux;
  
  (* mark_debug = "true" *)reg [2:0] r_RX_Bit_Count;
  (* mark_debug = "true" *)reg [2:0] r_TX_Bit_Count;
  (* mark_debug = "true" *)reg [7:0] r_Temp_RX_Byte;
  (* mark_debug = "true" *)reg [7:0] r_RX_Byte;
  (* mark_debug = "true" *)reg r_RX_Done, r2_RX_Done, r3_RX_Done;
  (* mark_debug = "true" *)reg [7:0] r_TX_Byte;
  (* mark_debug = "true" *)reg r_SPI_MISO_Bit, r_Preload_MISO;

  // CPOL: Clock Polarity
  // CPOL=0 means clock idles at 0, leading edge is rising edge.
  // CPOL=1 means clock idles at 1, leading edge is falling edge.
  assign w_CPOL  = (spi_mode == 2) | (spi_mode == 3);

  // CPHA: Clock Phase
  // CPHA=0 means the "out" side changes the data on trailing edge of clock
  //              the "in" side captures data on leading edge of clock
  // CPHA=1 means the "out" side changes the data on leading edge of clock
  //              the "in" side captures data on the trailing edge of clock
  assign w_CPHA  = (spi_mode == 1) | (spi_mode == 3);

  assign w_SPI_clk = w_CPHA ? ~spi_sclk : spi_sclk;



  // Purpose: Recover SPI Byte in SPI Clock Domain
  // Samples line on correct edge of SPI Clock
  
  always @(posedge spi_sclk or posedge spi_ss)
//  always @(posedge w_SPI_clk or posedge spi_ss)
  begin
    if (spi_ss)begin
      r_RX_Bit_Count <= 0;
      r_RX_Done      <= 1'b0;
    end
    else begin
      // Receive in LSB, shift up to MSB
      r_Temp_RX_Byte <= {r_Temp_RX_Byte[6:0], spi_mosi};
      if(r_RX_Done == 1'b0)begin
        if ((r_RX_Bit_Count == 3'b111))begin
            r_RX_Done <= 1'b1;
            r_RX_Byte <= {r_Temp_RX_Byte[6:0], spi_mosi};
        end
        else begin
            r_RX_Bit_Count <= r_RX_Bit_Count + 1;
        end
      end
//      else if (r_RX_Bit_Count == 3'b010)begin
//        r_RX_Done <= 1'b0;        
//      end
      
    end // else: !if(spi_ss)
  end // always @ (posedge w_SPI_clk or posedge spi_ss)



  // Purpose: Cross from SPI Clock Domain to main FPGA clock domain
  // Assert read_data_valid for 1 clock cycle when read_data has valid data.
  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      r2_RX_Done <= 1'b0;
      r3_RX_Done <= 1'b0;
      read_data_valid    <= 1'b0;
      read_data  <= 8'h00;
    end
    else
    begin
      // Here is where clock domains are crossed.
      // This will require timing constraint created, can set up long path.
      r2_RX_Done <= r_RX_Done;

      r3_RX_Done <= r2_RX_Done;

      if (r3_RX_Done == 1'b0 && r2_RX_Done == 1'b1) // rising edge
      begin
        read_data_valid   <= 1'b1;  // Pulse Data Valid 1 clock cycle
        read_data <= r_RX_Byte;
      end
      else
      begin
        read_data_valid <= 1'b0;
      end
    end // else: !if(~rst)
  end // always @ (posedge i_Bus_clk)


  // Control preload signal.  Should be 1 when CS is high, but as soon as
  // first clock edge is seen it goes low.
//  always @(posedge w_SPI_clk or posedge spi_ss)
//  begin
//    if (spi_ss)
//    begin
//      r_Preload_MISO <= 1'b1;
//    end
//    else
//    begin
//      r_Preload_MISO <= 1'b0;
//    end
//  end


  // Purpose: Transmits 1 SPI Byte whenever SPI clock is toggling
  // Will transmit read data back to SW over MISO line.
  // Want to put data on the line immediately when CS goes low.
  always @(posedge spi_sclk or posedge spi_ss) begin
    if (spi_ss)begin
      r_TX_Bit_Count <= 3'b111;  // Send MSb first
//      r_SPI_MISO_Bit <= r_TX_Byte[3'b111];  // Reset to MSb
      spi_miso <= 1'b0; 
    end
    else begin
      r_TX_Bit_Count <= r_TX_Bit_Count - 1;

      // Here is where data crosses clock domains from i_clk to w_SPI_clk
      // Can set up a timing constraint with wide margin for data path.
//      r_SPI_MISO_Bit <= r_TX_Byte[r_TX_Bit_Count];
      spi_miso <= r_TX_Byte[r_TX_Bit_Count];
    end // else: !if(spi_ss)
  end // always @ (negedge w_SPI_clk or posedge spi_ss_SW)


  // Purpose: Register TX Byte when DV pulse comes.  Keeps registed byte in 
  // this module to get serialized and sent back to master.
  always @(posedge clk or posedge rst)begin
    if (rst)begin
      r_TX_Byte <= 8'h00;
    end
    else begin
      if (write_data_valid)begin
        r_TX_Byte <= write_data; 
      end
    end 
  end  


`ifdef ILA_DEBUG_SPI_Slave_Commm 

wire [127 : 0] probe_bt656;

assign probe_bt656 = { 
    60'd0,
    rst               ,  
    r_TX_Bit_Count    ,    
    r_TX_Byte         ,  
    write_data_valid  ,
    write_data        ,
    spi_sclk          ,
    spi_miso          ,
    spi_mosi          ,
    spi_ss            ,
    read_data_valid   ,
    read_data         ,
    write_data_valid  ,
    write_data        ,
    r_RX_Bit_Count    ,
    r_RX_Byte         ,
    r_Temp_RX_Byte    ,
    r_RX_Done         ,
    r2_RX_Done        ,
    r3_RX_Done        ,
    w_CPHA            ,
    w_CPOL            ,
    w_SPI_clk         
                              }; 

ila_0 i_ila_slave_comm
(
	.clk(clk),
	.probe0(probe_bt656)
);
`endif  

endmodule // SPI_Slave