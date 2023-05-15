// `define ILA_COARSE_OFFSET_CORRECTION
module coarse_offset_corr
    #( parameter VIDEO_XSIZE = 640,
       VIDEO_YSIZE = 480
       )
    (
      input                   clk,
      input                   rst,

      input                   enable_coarse_offset,
      (* mark_debug = "true" *)                   input                   area_switch_done,
      (* mark_debug = "true" *)                   input                   video_o_v,
      (* mark_debug = "true" *)                   input                   video_o_eoi,
      (* mark_debug = "true" *)                   input                   video_o_h,
      (* mark_debug = "true" *)                   input                   video_o_dav,

      (* mark_debug = "true" *)                   input                   av_coarse_waitrequest,
      (* mark_debug = "true" *)                   output                  av_coarse_read,
      (* mark_debug = "true" *)                   output [31:0]           av_coarse_address,
      output [5:0]            av_coarse_size,
      (* mark_debug = "true" *)                   input                   av_coarse_readdatavalid,
      input [31:0]            av_coarse_readdata,

      (* mark_debug = "true" *)input [31:0]            base_address,

      input [7:0]             coarse_offset_dc,
      input [9:0]             coarse_ycounter_start,

      input                   mclk,
      input                   rst_m,
      input                   line_1,
      input                   line_even,
      input                   line_odd,

      input                   line_even_d [0:1],                  

      (* mark_debug = "true" *)                  input [9:0]             xcounter,
      (* mark_debug = "true" *)                  input [9:0]             ycounter,

      output [11:0]           sensor_cmd_data
      );

    localparam
    PIX_BITS                = 10,
    LIN_BITS                = 10;

    (* mark_debug = "true" *)reg enable_coarse_offset_reg;
    reg coarse_read;

    localparam rd_size_max = 16;

    reg [5:0] rd_size;
    assign av_coarse_read = coarse_read;
    assign av_coarse_size = rd_size;

    reg [LIN_BITS-1:0] line_count;
    reg [31:0] base_address_reg;

    reg [7:0] coarse_offset_dc_reg;
    reg [PIX_BITS-1:0]coarse_address;

    reg [PIX_BITS-1:0] coarse_ycounter_start_reg;

    reg [7:0] wait_cycles;


//////////////////////////////////////////////////////////////////////////////////
// CDC  signals here
wire xcounter_lt_5 = (xcounter<5)?1'b1:1'b0;
reg xcounter_lt_5_reg;
xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_0 (
      .dest_out(xcounter_lt_5_reg), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(mclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(xcounter_lt_5)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

wire ycounter_eq_0 = (ycounter==0)?1'b1:1'b0;
(* mark_debug = "true" *)reg ycounter_eq_0_reg;
xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_1 (
      .dest_out(ycounter_eq_0_reg), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(mclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(ycounter_eq_0)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );
wire ycounter_eq_1 = (ycounter==1)?1'b1:1'b0;
reg ycounter_eq_1_reg;
xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_2 (
      .dest_out(ycounter_eq_1_reg), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(mclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(ycounter_eq_1)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

wire ycounter_eq_coarse_ycounter_start = (ycounter==coarse_ycounter_start_reg)?1'b1:1'b0;
reg ycounter_eq_coarse_ycounter_start_reg;
xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_3 (
      .dest_out(ycounter_eq_coarse_ycounter_start_reg), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(mclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(ycounter_eq_coarse_ycounter_start)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );
wire ycounter_eq_ysize_plus_coarse_start = (ycounter==coarse_ycounter_start_reg+VIDEO_YSIZE)?1'b1:1'b0;
reg ycounter_eq_ysize_plus_coarse_start_reg;
xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_4 (
      .dest_out(ycounter_eq_ysize_plus_coarse_start_reg), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(mclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(ycounter_eq_ysize_plus_coarse_start)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

wire ycounter_gteq_ysize_plus_coarse_start_minus_1 = (ycounter>=coarse_ycounter_start_reg+VIDEO_YSIZE-1)?1'b1:1'b0;
reg ycounter_gteq_ysize_plus_coarse_start_minus_1_reg;
xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_5 (
      .dest_out(ycounter_gteq_ysize_plus_coarse_start_minus_1_reg), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(mclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(ycounter_gteq_ysize_plus_coarse_start_minus_1)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

//////////////////////////////////////////////////////////////////////////////////
// Detect start of frame synchronized to clk

(* mark_debug = "true" *)reg ycounter_eq_0_reg_d;
always_ff @(posedge clk) begin 
  ycounter_eq_0_reg_d <= ycounter_eq_0_reg;
end

(* mark_debug = "true" *)wire line_0_rising_edge = (ycounter_eq_0_reg==1 && ycounter_eq_0_reg_d==0)?1'b1:1'b0;

//////////////////////////////////////////////////////////////////////////////////

// FSM to fetch coarse offset data coefficient from SDRAM
(* mark_debug = "true" *)reg [2:0] coarse_offset_fsm;
localparam sc_idle = 0,
    sc_fetch_line = 1,
    sc_request_coarse_offset = 2,
    sc_end = 3,
    sc_wait_cycles=4;

always_ff @(posedge clk or posedge rst) begin : proc_update_coarse_offset_map
  if(rst) begin
    coarse_offset_fsm <= sc_idle;
    coarse_address <= 0;
    coarse_read <= 1'b0;
    enable_coarse_offset_reg <= 0;
    line_count <= 0;
    base_address_reg <= 0;
    coarse_offset_dc_reg <= 0;
    coarse_ycounter_start_reg <= 0;
    wait_cycles <= 0;
    rd_size <= 0;
  end else begin
    coarse_read <= 1'b0;
    if(line_0_rising_edge) begin
        enable_coarse_offset_reg <= enable_coarse_offset;
        base_address_reg <= base_address;
        coarse_offset_dc_reg <= coarse_offset_dc;
        coarse_ycounter_start_reg <= coarse_ycounter_start - 1;
    end 
    case(coarse_offset_fsm)
        sc_idle: begin 
            if(enable_coarse_offset_reg && ycounter_eq_coarse_ycounter_start_reg) begin
               line_count <= 0;
               coarse_offset_fsm <= sc_fetch_line;
           end
        end
        sc_fetch_line: begin
            coarse_offset_fsm <= sc_request_coarse_offset;
            coarse_read <= 1'b1;
            coarse_address <= 0;
            rd_size <= rd_size_max;
        end
        sc_request_coarse_offset: begin 
            coarse_read <= 1'b1;
            if(!av_coarse_waitrequest && coarse_read) begin
              coarse_read <= 1'b0;
              wait_cycles <= rd_size_max;
              coarse_address <= coarse_address + rd_size*4;
              coarse_offset_fsm <= sc_wait_cycles;
              if(coarse_address==VIDEO_XSIZE-rd_size*4) begin
                  coarse_read <= 1'b0;
                  coarse_offset_fsm <= sc_end;
              end
            end
        end
        sc_wait_cycles: begin
            if(wait_cycles==0) begin
              // Modify read_size if VIDEO_XSIZE is not an exact multple of rd_size_max
              if(coarse_address>VIDEO_XSIZE-rd_size*4) begin 
                rd_size <= (VIDEO_XSIZE - coarse_address) >> 2;
              end
              coarse_offset_fsm <= sc_request_coarse_offset;
            end else begin
                wait_cycles <= wait_cycles -1;
            end
        end
        sc_end: begin
            coarse_read <= 1'b0;
            if(xcounter_lt_5_reg) begin
                if(ycounter_eq_ysize_plus_coarse_start_reg) begin
                 coarse_offset_fsm <= sc_idle;
                end
                else begin
                    line_count <= line_count + 1;
                    coarse_offset_fsm <= sc_fetch_line;
                end 
            end
        end
    endcase
  end
end

assign av_coarse_address = line_count*VIDEO_XSIZE + base_address_reg + coarse_address; 


reg fifo_read;

(* mark_debug = "true" *)wire fifo_wr_en  = av_coarse_readdatavalid;
wire [31:0] fifo_din = av_coarse_readdata;

wire wr_clk = clk;

wire fifo_almost_empty;
wire fifo_almost_full;
(* mark_debug = "true" *)wire fifo_data_valid;
wire [31:0] fifo_dout;
(* mark_debug = "true" *)wire fifo_overflow;
(* mark_debug = "true" *)wire fifo_underflow;

wire fifo_wr_ack;
wire [5:0] fifo_wr_data_count;
wire [5:0] fifo_rd_data_count;

wire fifo_prog_empty;
wire fifo_prog_full;

wire fifo_wr_rst_busy;
wire fifo_rd_rst_busy;

(* mark_debug = "true" *)wire fifo_rd_en = fifo_read;

(* mark_debug = "true" *)wire fifo_empty;
(* mark_debug = "true" *)wire fifo_full;


xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(2),     // DECIMAL
      .FIFO_WRITE_DEPTH(1024),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(6),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("std"),         // String
      .USE_ADV_FEATURES("1707"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(6)    // DECIMAL
      )
xpm_fifo_coarse_offset (
  .almost_empty(fifo_almost_empty),   
  .almost_full(fifo_almost_full),     
  .data_valid(fifo_data_valid),       
  .dbiterr(),             
  .dout(fifo_dout),
  .empty(fifo_empty),
  .full(fifo_full),
  .overflow(fifo_overflow),
  .prog_empty(fifo_prog_empty),
  .prog_full(fifo_prog_full),
  .rd_data_count(fifo_rd_data_count),
  .rd_rst_busy(fifo_rd_rst_busy),
  .sbiterr(),
  .underflow(fifo_underflow),
  .wr_ack(fifo_wr_ack),
  .wr_data_count(fifo_wr_data_count),
  .wr_rst_busy(fifo_wr_rst_busy),
  .din(fifo_din),
  .injectdbiterr(1'b0),
  .injectsbiterr(1'b0),
  .rd_en(fifo_rd_en),
  .rst(rst),
  .sleep(1'b0),
  .wr_clk(wr_clk),
  .wr_en(fifo_wr_en)
  );


// reg [PIX_BITS-1:0] ram_address;
(* mark_debug = "true" *)reg [PIX_BITS-1:0] count;
(* mark_debug = "true" *)reg ram_write;
reg [7:0] ram_din;
(* mark_debug = "true" *)reg ram_select;

(* mark_debug = "true" *)reg fifo_request;

// FSM to write the coarse offset data memory to ping-pong LUTs
(* mark_debug = "true" *)reg [3:0] ram_fsm;

wire ram_select_init = coarse_ycounter_start_reg[0];

localparam sr_idle = 1,
sr_read_fifo = 2,
sr_write_to_ram = 3,
sr_write_dc_to_ram1 = 4,
sr_write_dc_to_ram2 = 5,
sr_select_buffer = 6
;


always_ff @(posedge clk) begin : proc_write_ram
  if(rst) begin
      fifo_read <= 1'b0;
      count <= -1;
      ram_write <= 1'b0; 
      ram_select <= ram_select_init;
      ram_fsm <= sr_idle;
      ram_din <= 0;
      fifo_request <= 0;
  end else begin
      fifo_read <= 1'b0;
      ram_write <= 1'b0; 
      case(ram_fsm)
          sr_idle: begin
              if(!fifo_wr_rst_busy && !fifo_rd_rst_busy && ycounter_eq_1_reg) begin
                  count <= -1;
                  ram_select <= ram_select_init;
                  if(enable_coarse_offset_reg) begin
                    ram_fsm <= sr_select_buffer;      
                end
                else begin
                  ram_fsm <= sr_write_dc_to_ram1 ;
                  end
              end
          end
          sr_write_dc_to_ram1: begin
              if(count==VIDEO_XSIZE-1) begin
                  count <= -1;
                  // ram_write <= 1'b1;
                  ram_select <= ~ram_select;
                  if(ram_select!=ram_select_init) begin
                  // ram_write <= 1'b0;
                      ram_fsm <= sr_write_dc_to_ram2;
                  end
              end else begin
                  ram_write <= 1'b1;
                  ram_din   <= coarse_offset_dc_reg;
                  count <= count + 1;
              end
          end
          sr_write_dc_to_ram2: begin
              if(ycounter_eq_1_reg) begin
                  ram_fsm <= sr_idle;
              end
          end
          sr_select_buffer: begin
              ram_select <= ~ram_select;
              ram_fsm <= sr_read_fifo;
          end

          sr_read_fifo: begin
              if(!fifo_empty) begin
                fifo_read <= 1'b1; 
                fifo_request <= 1'b1;
                ram_fsm <= sr_write_to_ram;
              end
          end
          sr_write_to_ram: begin
              if(fifo_data_valid) begin
                  fifo_request <= 0;
                  ram_write <= 1'b1;
                  ram_din <= fifo_dout[7:0];
                  count <= count+1;
              end
              if(count[1:0]==0) begin
                  ram_write <= 1'b1;
                  ram_din <= fifo_dout[15:8];
                  count <= count+1;
                  if(!fifo_empty && count<VIDEO_XSIZE-3) begin
                      fifo_read <= 1'b1;
                      fifo_request <= 1;
                  end
              end
              else if(count[1:0]==1) begin
                  ram_write <= 1'b1;
                  ram_din <= fifo_dout[23:16];
                  count <= count+1;
                  if(!fifo_empty && !fifo_request && count<VIDEO_XSIZE-2) begin
                      fifo_read <= 1'b1;
                      fifo_request <= 1;
                  end
              end
              else if(count[1:0]==2) begin
                  ram_write <= 1'b1;
                  ram_din <= fifo_dout[31:24];
                  count <= count+1;
                  if(!fifo_request && !fifo_empty && count<VIDEO_XSIZE-1) begin
                      fifo_read <= 1'b1;
                      fifo_request <= 1;
                  end
              end
              else if(count[1:0]==3) begin
                  if(!fifo_request && !fifo_data_valid) begin
                      ram_fsm <= sr_read_fifo;
                  end
              end
              if(count==VIDEO_XSIZE-1) begin
                  count <= -1;                                
                  if(ycounter_gteq_ysize_plus_coarse_start_minus_1_reg) begin
                      ram_fsm <= sr_idle;
                  end else begin
                      ram_fsm <= sr_select_buffer;
                  end
              end
              // else if(ycoun)

          end
      endcase
  end
end


wire [PIX_BITS-1:0]addrb_lx1 = xcounter;
(* mark_debug = "true" *)wire enb_lx1 = !line_1 & line_even;
wire [11:0]doutb_lx1;

(* mark_debug = "true" *)wire ena_lx1 = !ram_select & ram_write;
wire [PIX_BITS-1:0]addra_lx1 = count + 15;
wire [11:0]dina_lx1 = {4'h0, ram_din};

xpm_memory_sdpram #(
      .ADDR_WIDTH_A(10),               // DECIMAL
      .ADDR_WIDTH_B(10),               // DECIMAL
      .AUTO_SLEEP_TIME(0),            // DECIMAL
      .BYTE_WRITE_WIDTH_A(12),        // DECIMAL
      .CLOCKING_MODE("independent_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .MEMORY_INIT_FILE("line_x.mem"),      // String
      .MEMORY_INIT_PARAM("0"),        // String
      .MEMORY_OPTIMIZATION("true"),   // String
      .MEMORY_PRIMITIVE("auto"),      // String
      .MEMORY_SIZE(780*12),             // DECIMAL
      .MESSAGE_CONTROL(0),            // DECIMAL
      .READ_DATA_WIDTH_B(12),         // DECIMAL
      .READ_LATENCY_B(2),             // DECIMAL
      .READ_RESET_VALUE_B("0"),       // String
      .RST_MODE_A("SYNC"),            // String
      .RST_MODE_B("SYNC"),            // String
      .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
      .USE_MEM_INIT(1),               // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String
      .WRITE_DATA_WIDTH_A(12),        // DECIMAL
      .WRITE_MODE_B("no_change")      // String
      )
xpm_memory_sdpram_line_x1 (
  .dbiterrb(),
  .doutb(doutb_lx1),
  .sbiterrb(),
  .addra(addra_lx1),
  .addrb(addrb_lx1),
  .clka(clk),
  .clkb(mclk),
  .dina(dina_lx1),
  .ena(ena_lx1),
  .enb(enb_lx1),
  .injectdbiterra(1'b0),
  .injectsbiterra(1'b0),
  .regceb(1'b1),
  .rstb(rst_m),
  .sleep(1'b0),
  .wea(1'b1)
  );


wire [PIX_BITS-1:0]addrb_lx2 = xcounter;
(* mark_debug = "true" *)wire enb_lx2 = !line_1 & line_odd;
wire [11:0]doutb_lx2;

(* mark_debug = "true" *)wire ena_lx2 = ram_select & ram_write;
wire [PIX_BITS-1:0]addra_lx2 = count + 15;
wire [11:0]dina_lx2 = {4'h0, ram_din};

xpm_memory_sdpram #(
      .ADDR_WIDTH_A(10),               // DECIMAL
      .ADDR_WIDTH_B(10),               // DECIMAL
      .AUTO_SLEEP_TIME(0),            // DECIMAL
      .BYTE_WRITE_WIDTH_A(12),        // DECIMAL
      .CLOCKING_MODE("independent_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .MEMORY_INIT_FILE("line_x.mem"),      // String
      .MEMORY_INIT_PARAM("0"),        // String
      .MEMORY_OPTIMIZATION("true"),   // String
      .MEMORY_PRIMITIVE("auto"),      // String
      .MEMORY_SIZE(780*12),             // DECIMAL
      .MESSAGE_CONTROL(0),            // DECIMAL
      .READ_DATA_WIDTH_B(12),         // DECIMAL
      .READ_LATENCY_B(2),             // DECIMAL
      .READ_RESET_VALUE_B("0"),       // String
      .RST_MODE_A("SYNC"),            // String
      .RST_MODE_B("SYNC"),            // String
      .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
      .USE_MEM_INIT(1),               // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String
      .WRITE_DATA_WIDTH_A(12),        // DECIMAL
      .WRITE_MODE_B("no_change")      // String
      )
xpm_memory_sdpram_line_x2 (
  .dbiterrb(),
  .doutb(doutb_lx2),
  .sbiterrb(),
  .addra(addra_lx2),
  .addrb(addrb_lx2),
  .clka(clk),
  .clkb(mclk),
  .dina(dina_lx2),
  .ena(ena_lx2),
  .enb(enb_lx2),
  .injectdbiterra(1'b0),
  .injectsbiterra(1'b0),
  .regceb(1'b1),
  .rstb(rst_m),
  .sleep(1'b0),
  .wea(1'b1)
  );

assign sensor_cmd_data = line_even_d[1]? doutb_lx1:doutb_lx2;


`ifdef ILA_COARSE_OFFSET_CORRECTION

wire [127:0] probe0;
TOII_TUVE_ila ila_inst3(
    .CLK(clk),
    .PROBE0(probe0)
    );

assign probe0 = {2'd0, av_coarse_waitrequest, av_coarse_read, av_coarse_address, av_coarse_readdatavalid, // 35bits
                 enable_coarse_offset_reg, ena_lx1, enb_lx1, ena_lx2, enb_lx2, ram_select, ram_write, // 7 bits
                 fifo_empty, fifo_full, fifo_overflow, fifo_underflow, coarse_offset_fsm, ram_fsm, // 11 bits
                 fifo_request, xcounter, ycounter, fifo_wr_en, fifo_rd_en, count, ycounter_eq_0_reg, ycounter_eq_0_reg_d, //35 bits
                 area_switch_done,
                 line_0_rising_edge,
                 base_address,
                 video_o_v,  
                video_o_eoi,
                video_o_h,  
                video_o_dav};

                 `endif
             endmodule