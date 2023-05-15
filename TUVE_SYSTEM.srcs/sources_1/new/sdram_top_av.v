

module sdram_top_av (
	      // WB bus
                    av_rst_i            ,
                    av_clk_i            ,

                    av_busy_o 			,
                    av_addr_i           ,
                    av_size_i 			,
                    av_wr_i             ,
                    av_wrburst_i        ,
                    av_data_i           ,
//                    av_addr_dec         ,
                    av_byteenable_i 	,
                    av_rd_i             ,
                    av_data_o           ,
                    av_rddav_o 			,

                    sdram_init_done     ,


      				sdram_clk           ,
                    sdram_resetn        ,
                    sdr_cs_n            ,
                    sdr_cke             ,
                    sdr_ras_n           ,
                    sdr_cas_n           ,
                    sdr_we_n            ,
                    sdr_dqm             ,
                    sdr_ba              ,
                    sdr_addr            , 
                    sdr_dq              
);

parameter      AV_FREQ = 27000000;
parameter 	   SDRAM_FREQ = 100000000;

parameter      APP_AW   = 32;  // Application Address Width
parameter 	   APP_AW_VALID = 26; // Application Valid Address Width 26bits for 512Mb SDRAM
parameter      APP_DW   = 32;  // Application Data Width 
parameter      APP_BW   = 4;   // Application Byte Width
parameter      APP_RW   = 5;   // Application Request Width

parameter      SDR_DW   = 32;  // SDR Data Width 
parameter      SDR_BW   = 4;   // SDR Byte Width

localparam  	   AV_GT_SDRAM_FREQ  = AV_FREQ>SDRAM_FREQ? 1: 0;
localparam 		   AV_EQ_SDRAM_FREQ  = AV_FREQ==SDRAM_FREQ? 1:0;
localparam 		   AV_LT_SDRAM_FREQ  = AV_FREQ<SDRAM_FREQ? 1:0;

localparam 	   FREQ_DIV = AV_GT_SDRAM_FREQ?AV_FREQ/SDRAM_FREQ:(AV_LT_SDRAM_FREQ?SDRAM_FREQ/AV_FREQ:1);
             

//-----------------------------------------------
// Global Variable
// ----------------------------------------------
input                   sdram_clk          ; // SDRAM Clock 
input 					sdram_resetn 	   ;
//--------------------------------------------
// AVALON BUS Interface 
//--------------------------------------------
input 					av_clk_i			;
input 					av_rst_i			;

(* mark_debug = "true" *)output 					av_busy_o			;
(* mark_debug = "true" *)input 	[APP_AW-1:0] 	av_addr_i			;
(* mark_debug = "true" *)input 	[APP_RW-1:0] 	av_size_i			;
(* mark_debug = "true" *)input 					av_wr_i				;
input 					av_wrburst_i		;
(* mark_debug = "true" *)input 					av_rd_i 			;
(* mark_debug = "true" *)input 	[APP_DW-1:0] 	av_data_i			;
//input av_addr_dec;
input 	[APP_BW-1:0] 	av_byteenable_i		;
output 	[APP_DW-1:0] 	av_data_o			;
output 					av_rddav_o			;

output 					sdram_init_done 	;

//------------------------------------------------
// Interface to SDRAMs
//------------------------------------------------
output                  sdr_cke             ; // SDRAM CKE
output 					sdr_cs_n            ; // SDRAM Chip Select
output                  sdr_ras_n           ; // SDRAM ras
output                  sdr_cas_n           ; // SDRAM cas
output					sdr_we_n            ; // SDRAM write enable
output 	[SDR_BW-1:0] 	sdr_dqm             ; // SDRAM Data Mask
output 	[1:0] 			sdr_ba              ; // SDRAM Bank Enable
output 	[12:0] 			sdr_addr            ; // SDRAM Address
inout 	[SDR_DW-1:0] 	sdr_dq              ; // SDRA Data Input/output


assign sdr_cke = 1'b1;

(* mark_debug = "true" *)reg [APP_AW_VALID-2-1:0] addr;
reg wr_req_s;
(* mark_debug = "true" *)wire wr_req;
(* mark_debug = "true" *)wire [31:0] wr_data;
(* mark_debug = "true" *)wire wr_ack;
wire next_wr_ack;

(* mark_debug = "true" *)reg rd_req;
(* mark_debug = "true" *)wire rd_ack;
(* mark_debug = "true" *)wire rd_valid;
wire next_rd_valid;
(* mark_debug = "true" *)wire [31:0] rd_data;

wire sdr_init_done;

assign sdram_init_done = sdr_init_done;

// Instantiate sdram controller
sdram u_sdram_ctrl( 
	.clk(sdram_clk),

	// SDRAM interface
	.sdram_dq(sdr_dq), 
	.sdram_addr(sdr_addr), 
	.sdram_ba(sdr_ba), 
	.sdram_cs(sdr_cs_n),
	.sdram_ras(sdr_ras_n), 
	.sdram_cas(sdr_cas_n), 
	.sdram_we(sdr_we_n), 
	.sdram_dqm(sdr_dqm),

	.sdram_init_done(sdr_init_done),

	// read/write address
        // input [26:0] addr, 
    .addr(addr),

	// write port
	// input wr_req, 		// write request 
	.wr_req(wr_req),
	// output reg wr_ack, 	// write acknowledgement 
	.wr_ack(wr_ack),
	// output next_wr_ack,
	.next_wr_ack(next_wr_ack),
	// input [31:0] wr_data, 
	.wr_data(wr_data),

	// read port
	// input rd_req, 
	.rd_req(rd_req),
	// output rd_ack, 
	.rd_ack(rd_ack),
	// output reg rd_valid, 
	.rd_valid(rd_valid),
	// output reg next_rd_valid,
	.next_rd_valid(next_rd_valid),
        // output reg [31:0] rd_data
    .rd_data(rd_data)
       );


(* mark_debug = "true" *)wire                    cmdfifo_full       ;
(* mark_debug = "true" *)wire                    cmdfifo_empty      ;
(* mark_debug = "true" *)wire                    wrdatafifo_full    ;
(* mark_debug = "true" *)wire                    wrdatafifo_empty   ;
(* mark_debug = "true" *)wire                    wrdatafifo_aempty  ;

(* mark_debug = "true" *)wire                    rddatafifo_empty   ;
(* mark_debug = "true" *)wire                    rddatafifo_full    ;

wire cmdfifo_afull;
wire wrdatafifo_afull;

wire [APP_RW-1:0] burst_length = av_size_i;
// reg [APP_RW-1:0] burst_length;
reg [APP_RW-1:0] burst;
reg [APP_RW-1:0] av_burst;
reg av_burst_wr;
reg av_burst_wr_d;

(* mark_debug = "true" *)wire [APP_RW-1:0] sdr_req_len; 
//reg  sdr_reg_addr_dec;
wire sdr_addr_dec;
wire sdr_req_wr_n;
(* mark_debug = "true" *)wire [APP_AW_VALID-2-1:0] sdr_req_addr;
wire [APP_DW-1:0] sdr_wr_data;
wire [APP_BW-1:0] sdr_wr_en_n;


reg [APP_RW-1:0] rdburst;
(* mark_debug = "true" *)wire [APP_RW-1:0] rdcmdfifo_burst;
wire rd_i;
wire [APP_AW_VALID-2-1:0] av_addr_s_o;
(* mark_debug = "true" *)wire rdcmdfifo_full;
(* mark_debug = "true" *)wire rdcmdfifo_empty;
(* mark_debug = "true" *)wire rdcmdfifo_aempty;
reg rddatafifo_rd_r;


wire rddatafifo_afull;

assign         sdr_req      = !cmdfifo_empty;

assign av_busy_o = cmdfifo_full | wrdatafifo_full | !(rdcmdfifo_empty & rddatafifo_empty);

reg         cmdfifo_rd ;

// reg 		we_i;
// reg 	[APP_AW_VALID-2-1:0] av_addr_s;
wire [APP_AW_VALID-2-1:0] av_addr_s = av_addr_i[25:2];

reg 	[APP_DW-1:0] av_data_s;
reg 	[APP_BW-1:0] av_byteenable_s;

// reg cmdfifo_wr;
(* mark_debug = "true" *)wire cmdfifo_wr = (av_rd_i | (av_wr_i & !av_burst_wr & !av_burst_wr_d)) & !av_busy_o;
wire we_i = !av_rd_i | (av_wr_i & !av_burst_wr & !av_burst_wr_d);

//generate just one burst write command from the avalon signals
always @(posedge av_clk_i or posedge av_rst_i) begin : proc_write_burst
	if(av_rst_i) begin
		 av_burst_wr<= 0;
		 av_burst <=0;
		 av_burst_wr_d <=0;
	end else begin
		 av_burst_wr_d	<= av_burst_wr;
		 if(av_wr_i & !av_burst_wr & !av_busy_o) begin
		 	av_burst <= av_size_i -1;
		 	av_burst_wr <=1;
		 	if(av_size_i==1) begin
		 		av_burst_wr <=0;
		 	end
		 end
		 else if(av_wr_i & av_burst_wr & !av_busy_o) begin
		 	av_burst <= av_burst-1;
		 	if(av_burst==1) begin 
		 		av_burst_wr <=0;
		 	end
		 end
		 else if(!av_wr_i) begin
		 	av_burst_wr <= 0;
		 	av_burst <= 0;
		 end
	end
end

(* mark_debug = "true" *)reg [3:0] fifo_state;
reg [3:0] fifo_state_temp;

reg [15:0] wait_cnt;

parameter
	IDLE  = 4'd0,
	WAIT  = 4'd1,
	CHECK_RW = 4'd2,
	GO_READ = 4'd3,
	GO_WRITE = 4'd4,
	BURST_SPLIT = 4'd5;

//handle reading data from fifo and feeding it to sdram controller
always @(posedge sdram_clk or negedge sdram_resetn) begin : proc_feed_fifo
	if(!sdram_resetn) begin
		cmdfifo_rd <= 1'b0;
		rd_req <= 1'b0;
		wr_req_s <= 1'b0;
		fifo_state <= IDLE;
		fifo_state_temp <= IDLE;
		addr <= 'h0;
		burst <= 'h0;
		wait_cnt <= 0;
//		sdr_reg_addr_dec <= 1'b0;
	end else begin
		cmdfifo_rd <=1'b0;
		rd_req <= 1'b0;
		wr_req_s <= 1'b0;
		case(fifo_state)
			IDLE :begin
				if(~cmdfifo_empty) begin
					fifo_state<= WAIT;
					wait_cnt <= 0;
					fifo_state_temp <= CHECK_RW;
					cmdfifo_rd <=1'b1;
				end // if(~cmdfifo_empty)
			end // IDLE
			WAIT : begin
				if(wait_cnt==0)
					fifo_state <= fifo_state_temp;
				else
					wait_cnt <= wait_cnt-1;
			end // WAIT 
			CHECK_RW : begin 
				if(sdr_req_wr_n) begin
					fifo_state <= GO_READ;
					addr <= sdr_req_addr;
					burst <= sdr_req_len;
					rd_req <= 1'b1;
				end // if(sdr_req_wr_n)
				else begin
					addr <= sdr_req_addr;
					burst <= sdr_req_len;
//					sdr_reg_addr_dec <=sdr_addr_dec;
					if(AV_LT_SDRAM_FREQ) begin
						fifo_state_temp <= GO_WRITE;
						wait_cnt <= sdr_req_len*FREQ_DIV-1;
						fifo_state <=WAIT;
					end
					else begin 
						fifo_state <= GO_WRITE;
						wr_req_s <= 1'b1;	
					end
				end
			end
			GO_READ: begin
				rd_req <= 1'b1;
				if(rd_ack) begin
					if(burst == 1) begin
						wait_cnt <= 2;
						fifo_state <= WAIT;
						fifo_state_temp <= IDLE;
						rd_req <= 1'b0;
					end
					else if(addr[8:0]==9'h1FF) begin
						rd_req <= 1'b0;
						addr <= addr +1;
						burst <= burst -1;
						fifo_state <= BURST_SPLIT;
						fifo_state_temp <= GO_READ;
					end
					else begin					
						addr <= addr +1;   
						burst <= burst -1;
					end
				end
			end // GO_READ
			GO_WRITE: begin 
				wr_req_s <= 1'b1;
				if(next_wr_ack)begin
					if (burst==1) begin
						wait_cnt <= 2;
						fifo_state <= WAIT;
						fifo_state_temp <= IDLE;
						wr_req_s <= 1'b0;
					end
					else if(addr[8:0]==9'h1FF) begin
						wr_req_s <= 1'b0;
//					    if(sdr_reg_addr_dec)begin
//                          addr <= addr -1;  
//                        end
//                        else begin
//                          addr <= addr +1;
//                        end
						
						addr <= addr +1;
						burst <= burst-1;
						fifo_state <= BURST_SPLIT;
						fifo_state_temp <= GO_WRITE;
					end
					else begin
						addr <= addr +1;
						burst <= burst-1;
//                        if(sdr_reg_addr_dec)begin
//                          addr <= addr -1;  
//                        end
//                        else begin
//                          addr <= addr +1;
//                        end    
						
					end
				end
			end // GO_WRITE
			BURST_SPLIT: begin
				if(fifo_state_temp==GO_READ)begin
					rd_req <= 1'b1;
					fifo_state <= GO_READ;
				end
				else begin
					wr_req_s <= 1'b1;
					fifo_state <= GO_WRITE;
				end
			end // BURST_SPLIT
		endcase // fifo_state
	end
end
reg wr_req_d;

always @(posedge sdram_clk) begin
	wr_req_d <= wr_req;
end
assign wr_req = wr_req_s & ((~wrdatafifo_aempty && ~wrdatafifo_empty) | ((burst==1) & ~wrdatafifo_empty & ~wr_req_d));
(* mark_debug = "true" *)assign	wr_data = sdr_wr_data;
assign wrdatafifo_rd = wr_ack & ~wrdatafifo_empty;
//---------------------------------------------------------------------
// Async Command FIFO. This block handle the clock domain change from
// Application layer to SDRAM Controller
// --------------------------------------------------------------------
   // Address + Burst Length + W/R Request 
    async_fifo #(.W(APP_AW_VALID-2+APP_RW+1),.DP(4),.WR_FAST(1'b0), .RD_FAST(1'b0)) u_cmdfifo (
     // Write Path Sys CLock Domain
          .wr_clk             (av_clk_i           ),
          .wr_reset_n         (!av_rst_i          ),
          .wr_en              (cmdfifo_wr         ),
          .wr_data            ({burst_length, 
	                        	!we_i, 
								av_addr_s}        ),
          .afull              (cmdfifo_afull      ),
          .full               (cmdfifo_full       ),

     // Read Path, SDRAM clock domain
          .rd_clk             (sdram_clk          ),
          .rd_reset_n         (sdram_resetn       ),
          .aempty             (                   ),
          .empty              (cmdfifo_empty      ),
          .rd_en              (cmdfifo_rd         ),
          .rd_data            ({sdr_req_len,
	                        sdr_req_wr_n,
		                sdr_req_addr}     )
     );


 // synopsys translate_off
always @(posedge av_clk_i) begin
  if (cmdfifo_full == 1'b1 && cmdfifo_wr == 1'b1)  begin
     $display("ERROR:%m COMMAND FIFO WRITE OVERFLOW");
  end 
end 
// synopsys translate_on
// synopsys translate_off
always @(posedge sdram_clk) begin
   if (cmdfifo_empty == 1'b1 && cmdfifo_rd == 1'b1) begin
      $display("ERROR:%m COMMAND FIFO READ OVERFLOW");
   end
end 
// synopsys translate_on

//---------------------------------------------------------------------
// Write Data FIFO Write Generation, when ever Acked + Write Request
//   Note: Ack signal generation already taking account of FIFO full condition
// ---------------------------------------------------------------------

(* mark_debug = "true" *)wire  wrdatafifo_wr  = av_wr_i & !av_busy_o;

//------------------------------------------------------------------------
// Write Data FIFO Read Generation, When ever Next Write request generated
// from SDRAM Controller
// ------------------------------------------------------------------------
// wire  wrdatafifo_rd  = sdr_wr_next;


//------------------------------------------------------------------------
// Async Write Data FIFO
//    This block handle the clock domain change over + Write Data + Byte mask 
//    From Application layer to SDRAM controller layer
//------------------------------------------------------------------------

   // Write DATA + Data Mask FIFO
    async_fifo #(.W(APP_DW+(APP_DW/8)), .DP(256), .WR_FAST(1'b0), .RD_FAST(1'b1)) u_wrdatafifo (
       // Write Path , System clock domain
          .wr_clk             (av_clk_i           ),
          .wr_reset_n         (!av_rst_i          ),
          .wr_en              (wrdatafifo_wr      ),
          .wr_data            ({~av_byteenable_i, 
	                         	av_data_i}        ),
          .afull              (wrdatafifo_afull   ),
          .full               (wrdatafifo_full    ),


       // Read Path , SDRAM clock domain
          .rd_clk             (sdram_clk          ),
          .rd_reset_n         (sdram_resetn       ),
          .aempty             (wrdatafifo_aempty  ),
          .empty              (wrdatafifo_empty   ),
          .rd_en              (wrdatafifo_rd      ),
          .rd_data            ({sdr_wr_en_n,
                                sdr_wr_data}      )
     );
// synopsys translate_off
always @(posedge av_clk_i) begin
  if (wrdatafifo_full == 1'b1 && wrdatafifo_wr == 1'b1)  begin
     $display("ERROR:%m WRITE DATA FIFO WRITE OVERFLOW");
  end 
end 

always @(posedge sdram_clk) begin
   if (wrdatafifo_empty == 1'b1 && wrdatafifo_rd == 1'b1) begin
      $display("ERROR:%m WRITE DATA FIFO READ OVERFLOW");
   end
end 
// synopsys translate_on

// -------------------------------------------------------------------
//  READ DATA FIFO
//  ------------------------------------------------------------------
wire    rd_eop; // last read indication
(* mark_debug = "true" *)wire rddatafifo_aempty;
// Read FIFO write generation, when ever SDRAM controller issues the read
// valid signal
(* mark_debug = "true" *)wire    rddatafifo_wr = rd_valid;

// wire    rddatafifo_rd = rddatafifo_empty?0:1;
(* mark_debug = "true" *)reg rddatafifo_rd;

(* mark_debug = "true" *)wire rdcmdfifo_wr = av_rd_i  & !av_busy_o;
(* mark_debug = "true" *)reg rdcmdfifo_rd;

async_fifo #(.W(APP_AW_VALID-2+APP_RW+1), .DP(4), .WR_FAST(1'b0), .RD_FAST(1'b1) ) u_rdcmdfifo (
       // Write Path , SDRAM clock domain
          .wr_clk             (av_clk_i          ),
          .wr_reset_n         (!av_rst_i         ),
          .wr_en              (rdcmdfifo_wr      ),
          .wr_data            ({burst_length, 
	                        	av_rd_i, 
								av_addr_s}	      ),
          .afull              (   ),
          .full               (rdcmdfifo_full    ),


       // Read Path , SYS clock domain
          .rd_clk             (av_clk_i           ),
          .rd_reset_n         (!av_rst_i          ),
          .empty              (rdcmdfifo_empty   ),
          .aempty             (rdcmdfifo_aempty  ),
          .rd_en              (rdcmdfifo_rd      ),
          .rd_data            ({rdcmdfifo_burst, rd_i,av_addr_s_o})
     );


reg [15:0] wait_cnt2;
(* mark_debug = "true" *)reg [3:0] st;
reg [3:0] st_temp;  



localparam ST_IDLE = 4'd0,
			ST_CHECK_BURST = 4'd1,
			ST_WAIT = 4'd2,
			ST_SEND_DATA = 4'd3;

always @(posedge av_clk_i or posedge av_rst_i) begin
	if(av_rst_i) begin
		rddatafifo_rd <= 1'b0;
		rdcmdfifo_rd <= 1'b0;
		wait_cnt2 <= 0;
		rdburst <= 0;
		st <= ST_IDLE;
		st_temp <= ST_IDLE;
		rddatafifo_rd_r <= 1'b0;
	end else begin
		rddatafifo_rd_r <= rddatafifo_rd;
		rdcmdfifo_rd <= 1'b0;
		case(st)
		 ST_IDLE:begin 
		 	if(~rddatafifo_empty & ~rdcmdfifo_empty) begin // New burst, read cached readaddr, and size
		 		rdcmdfifo_rd <= 1'b1;
		 		// wait_cnt2 <= 0;
		 		rdburst <= rdcmdfifo_burst;
		 		st <= ST_CHECK_BURST;
		 		// st_temp <= ST_CHECK_BURST;
		 	end
		 end
		 ST_CHECK_BURST: begin 
		 	
		 	if(AV_GT_SDRAM_FREQ) begin
			 	wait_cnt2 <= rdcmdfifo_burst*FREQ_DIV -1;
			 	st <= ST_WAIT;
			 	st_temp <= ST_SEND_DATA;
			end else begin 
				st <= ST_SEND_DATA;
			end
		 end
		 ST_WAIT: begin
		 	if(wait_cnt2==0) begin 
		 		st <= st_temp;
		 	end else begin
		 		wait_cnt2 <= wait_cnt2-1;
		 	end
		 end
		 ST_SEND_DATA: begin 
		 	if(rdburst==0) begin 
		 		st <= ST_IDLE;
		 		rddatafifo_rd <= 1'b0;
		 	end else begin 
		 		if((~rddatafifo_aempty && ~rddatafifo_empty) | (rdburst==1 && ~rddatafifo_empty && ~rddatafifo_rd)) begin 
		 			rddatafifo_rd <=1'b1;
		 			rdburst <= rdburst -1;
		 		end
		 		else begin 
		 			rddatafifo_rd <=1'b0;
		 		end
		 	end
		 end
		endcase // st
	end
end

assign av_rddav_o = rddatafifo_rd_r;



//-------------------------------------------------------------------------
// Async Read FIFO
// This block handles the clock domain change over + Read data from SDRAM
// controller to Application layer.
//  Note: 
//    1. READ DATA FIFO depth is kept small, assuming that Sys-CLock > SDRAM Clock
//       READ DATA + EOP
//    2. EOP indicate, last transfer of Burst Read Access. use-full for future
//       Tag handling per burst
//
// ------------------------------------------------------------------------
    async_fifo #(.W(APP_DW), .DP(256), .WR_FAST(1'b0), .RD_FAST(1'b0) ) u_rddatafifo (
       // Write Path , SDRAM clock domain
          .wr_clk             (sdram_clk          ),
          .wr_reset_n         (sdram_resetn       ),
          .wr_en              (rddatafifo_wr      ),
          .wr_data            (rd_data 		      ),
          .afull              (   ),
          .full               (rddatafifo_full    ),


       // Read Path , SYS clock domain
          .rd_clk             (av_clk_i           ),
          .rd_reset_n         (!av_rst_i          ),
          .empty              (rddatafifo_empty   ),
          .aempty             (rddatafifo_aempty  ),
          .rd_en              (rddatafifo_rd      ),
          .rd_data            (av_data_o          )
     );

// synopsys translate_off
always @(posedge sdram_clk) begin
  if (rddatafifo_full == 1'b1 && rddatafifo_wr == 1'b1)  begin
     $display("ERROR:%m READ DATA FIFO WRITE OVERFLOW");
  end 
end 

always @(posedge av_clk_i) begin
   if (rddatafifo_empty == 1'b1 && rddatafifo_rd == 1'b1) begin
      $display("ERROR:%m READ DATA FIFO READ OVERFLOW");
   end
end 
// synopsys translate_on

// assign av_rddav_o = rd_valid;
// assign av_data_o = rd_data;
//wire [155:0] probe0;
//assign probe0 = {cmdfifo_full,cmdfifo_empty, rddatafifo_empty, rddatafifo_full, rdcmdfifo_empty, rdcmdfifo_full, av_rd_i, av_wr_i, av_size_i, av_busy_o, wr_req, wr_ack,
//                  rd_req, rd_ack, fifo_state, st, cmdfifo_wr, cmdfifo_rd, wrdatafifo_rd, rddatafifo_rd, rdcmdfifo_rd, rdcmdfifo_wr, wrdatafifo_empty, wrdatafifo_aempty,
//                 av_addr_i, burst, wr_data, rd_data};
//ila_0 ila_sdram (
//	.clk(sdram_clk), // input wire clk


//	.probe0(probe0) // input wire [127:0] probe0
//);      


endmodule