/*
 * sdram.v
 *
 * SDRAM controller, targeted for 16Mx16 -6A memory with 100 MHz clock
 *
 * (C) Arlet Ottens, <arlet@c-scape.nl>
 */

 /*
	Modified for 16Mx32 -6A memory with 100MHz clock
	Aneesh M. U.
 */

`timescale 1ns/1ps

module sdram( 
	input clk,

	// SDRAM interface
	inout [31:0] sdram_dq, 
	output reg [12:0] sdram_addr, 
	output reg [1:0] sdram_ba, 
	output sdram_cs,
	output reg sdram_ras, 
	output reg sdram_cas, 
	output reg sdram_we, 
	output reg [3:0] sdram_dqm,

	output sdram_init_done,

	// read/write address
        input [23:0] addr, 

	// write port
	input wr_req, 		// write request 
	output reg wr_ack, 	// write acknowledgement 
	output next_wr_ack,
	input [31:0] wr_data, 

	// read port
	input rd_req, 
	output rd_ack, 
	output reg rd_valid, 
	output reg next_rd_valid,
        output reg [31:0] rd_data
       );

wire [8:0] col  = addr[8:0];
wire [1:0] bank = addr[10:9];
wire [12:0] row = addr[23:11];

assign sdram_cs = 1'b0;

parameter
    MODE	= 4'd0,
    REFRESH	= 4'd1,
    PRECHARGE	= 4'd2,
    ACTIVE	= 4'd3,
    WRITE	= 4'd4,
    READ	= 4'd5,
    TERMINATE   = 4'd6,
    NOP		= 4'd7,
    WAIT	= 4'd10,
    RAS		= 4'd11,
    EXTMODE = 4'd13,
    PRECH_ALL = 4'd12;

reg [3:0] state = WAIT;
reg [3:0] next;

`ifdef SIM
reg [9*8-1:0] statename;
always @(state)
    case( state )
    MODE: 		statename <= "MODE";
	REFRESH:	statename <= "REFR";
	PRECHARGE:	statename <= "PRECH";
	PRECH_ALL:	statename <= "PRECH_ALL";
	ACTIVE:		statename <= "ACT";
	WRITE:		statename <= "WRITE";
	READ:		statename <= "READ";
	TERMINATE:	statename <= "TERMINATE";
	NOP:		statename <= "NOP";
	WAIT:		statename <= "WAIT";
	RAS:		statename <= "RAS";
	EXTMODE: 	statename <= "EXTENDED MODE"
    endcase
`endif

parameter
	REFRESH1  = 3'd0,
	REFRESH2  = 3'd1,
	INIT_MODE      = 3'd2,
	READY	       = 3'd3,
	START_REFRESH  = 3'd4,
	EXT_MODE 	   = 3'd5;

reg [2:0] action = REFRESH1;
reg [2:0] next_action = REFRESH1;

`ifdef SIM
reg [9*8-1:0] actionname;
always @(action)
    case( action )
	REFRESH1:	actionname <= "INIT1";
	REFRESH2:	actionname <= "INIT2";
	INIT_MODE:	actionname <= "MODE";
	EXT_MODE:   actionname <= "EXTENDED MODE";
	READY:		actionname <= "READY";
        START_REFRESH:  actionname <= "REFRESH";
    endcase
`endif
reg [31:0] wr_data_d;
// always@(posedge clk)
always@(wr_data)
	wr_data_d <= wr_data;

assign  sdram_dq = (state == WRITE) ? wr_data_d : 32'hZ;

`ifdef SIM
reg [14:0] sdram_delay = 15'h0100;
`else
reg [14:0] sdram_delay = 15'h2C00;
`endif
wire sdram_wait = sdram_delay != 0;

reg init_done;

/*
 * 8192 refresh cycles are needed every 64 ms. (once per 7.8 us avg)
 *
 * we run a 9 bit counter at 100 MHz. If counter >= 1024 we attempt to do refresh.
 * For every refresh, decrement counter by 768.  If counter > 32k, refreshes become urgent.
 */

reg [15:0] refresh_count = 16'd1600;

wire need_refresh = |refresh_count[15:10];
wire urgent_refresh = refresh_count[15];

always @(posedge clk)
    if( state == REFRESH )
        refresh_count <= refresh_count - 16'd768;
    else 
        refresh_count <= refresh_count + 1;

assign next_wr_ack = (next == WRITE);
assign rd_ack = (next == READ);

reg [1:0] rd_shift = 0;
reg rd_valid_d;
always @(posedge clk)
    wr_ack <= next_wr_ack;

always @(posedge clk) begin
//    next_rd_valid <= rd_shift[0];
    rd_valid_d <= rd_shift[0];
    next_rd_valid <= rd_valid_d;
end 

always @(posedge clk)
    rd_valid <= next_rd_valid;
    
always @(posedge clk )
    rd_shift <= { rd_shift[0], state == READ };

wire rw_ok = ~rd_shift[0];

reg [31:0] sdram_dq_delayed;

 always @(posedge clk)
//always @(sdram_dq)
    sdram_dq_delayed <= #1 sdram_dq;

always @(posedge clk)
    if( next_rd_valid )
		rd_data <= sdram_dq_delayed;
    else
        rd_data <= 0;

always @(posedge clk)
	if(action==READY & init_done==1'b0)
		init_done <= 1'b1;
	else if(init_done==1'b1)
		init_done <= 1'b1;
	else
		init_done <= 1'b0;
	/* code */

assign sdram_init_done = init_done;

/* 
 * outputs 
 */

always @(posedge clk)
    case( next )
	READ,
        WRITE: 		sdram_dqm <= 4'h0;

	default:	sdram_dqm <= 4'hf;
    endcase

always @(posedge clk)
    case( next )
	REFRESH,
	MODE,
	EXTMODE,
	ACTIVE,
	PRECHARGE,
	PRECH_ALL:	sdram_ras <= 0;

        default:	sdram_ras <= 1;
    endcase

always @(posedge clk)
    case( next )
	REFRESH,
	MODE,
	EXTMODE,
	READ,
	WRITE:		sdram_cas <= 0;

	default:	sdram_cas <= 1;
    endcase

always @(posedge clk)
    case( next )
        WRITE,
	TERMINATE,
	PRECHARGE,
	PRECH_ALL,
	EXTMODE,
	MODE:		sdram_we <= 0;
        
	default:	sdram_we <= 1;
    endcase

always @(posedge clk)
	case(next)
		MODE:  sdram_ba <= 2'b00;
		EXTMODE: sdram_ba <= 2'b10;
		default: sdram_ba <= bank;
	endcase

always @(posedge clk)
    case( next )
	PRECHARGE:	sdram_addr[10] <= 0;
	PRECH_ALL:	sdram_addr[10] <= 1;
	MODE:		sdram_addr <= 13'b0000000100111;
	EXTMODE :  sdram_addr <= 13'b0000000000000;
	READ, WRITE:	sdram_addr <= col;
	ACTIVE: 	sdram_addr <= row;
    endcase

/*
 * per bank states
 */

reg [1:0] cur_bank;
reg [3:0] ras = 0;
reg [12:0] active_row[3:0];
reg [3:0] active = 4'b1111;

wire ras_ok = (ras == 0);

`ifdef SIM
wire [12:0] row0 = active_row[0];
wire [12:0] row1 = active_row[1];
wire [12:0] row2 = active_row[2];
wire [12:0] row3 = active_row[3];
`endif

always @(posedge clk)
    if( next == ACTIVE || next == NOP )
        cur_bank <= bank;

always @(posedge clk)
    if( state == ACTIVE )
        active_row[bank] <= row;

always @(posedge clk)
    if( state == PRECH_ALL ) begin
	active <= 4'b0000;
    end else if( state == ACTIVE )
	active[bank] <= 1;
    else if( state == PRECHARGE )
	active[bank] <= 0;

always @(posedge clk)
    if( state == ACTIVE )
	ras <= 3;
    else if( !ras_ok )
	ras <= ras - 1;

wire same_row = active_row[bank] == row;
wire row_open = active[bank] & same_row;
wire row_closed = !row_open;
wire wrong_row = active[bank] & !same_row;

/*
 * sdram_wait, contains number of cycles we wait
 */
always @(posedge clk)
    if( sdram_wait & (state == WAIT) )
        sdram_delay <= sdram_delay - 1; 
    else case( next )
	PRECH_ALL:	sdram_delay <= 3;

	PRECHARGE:	sdram_delay <= 3;

	REFRESH:	sdram_delay <= 17;

	MODE:		sdram_delay <= 2;

	EXTMODE: 	sdram_delay <= 2;

    ACTIVE:		sdram_delay <= 3;

	READ:		sdram_delay <= 3;

	WRITE:		sdram_delay <= 3;
    endcase

/*
 * action: high level state machine
 */

always @(posedge clk )
    action <= next_action;

always @* begin
    next_action = action;
    case( action )
        REFRESH1:	if( state == REFRESH ) 		next_action = REFRESH2;
        REFRESH2:	if( state == REFRESH ) 		next_action = INIT_MODE;
    	INIT_MODE:	if( state == MODE ) 		next_action = EXT_MODE;
    	EXT_MODE:	if( state == EXTMODE ) 		next_action = READY;
        READY: 		if( need_refresh )		next_action = START_REFRESH;
        START_REFRESH:	if( state == REFRESH )		next_action = READY;
    endcase
end

/*
 * state: detailed bus state
 */

always @(posedge clk )
    state <= next;

always @* begin
    next = state;
    case( state )
	NOP:
	   case( action )
	       START_REFRESH,
	       REFRESH1,
	       REFRESH2: 
			if( ras_ok )		
			    if( |active )	next = PRECH_ALL;
			    else		next = REFRESH;

	       INIT_MODE:			next = MODE;
	       EXT_MODE: 			next = EXTMODE;

	       READY: if( rd_req | wr_req ) 
			  if( wrong_row )
			      if( ras_ok )	next = PRECHARGE;
			      else 		next = NOP;
			  else if( row_closed )	next = ACTIVE;
			  else if( rd_req )	next = READ;
			  else if( rw_ok )	next = WRITE;
	   endcase

	ACTIVE:					next = WAIT;

	READ: if( ~rd_req | urgent_refresh )	next = NOP;
	      else if( row_closed )		next = PRECHARGE;
	      else if( ras_ok & wrong_row ) 	next = PRECHARGE; 

	WRITE: if( urgent_refresh )		next = NOP;
	       else if( ras_ok & wrong_row ) 	next = PRECHARGE; 
	       else if( rd_req )		next = READ;
	       else if( ~wr_req )		next = NOP;

	PRECH_ALL:				next = WAIT;

	PRECHARGE: 				next = WAIT;

	REFRESH: 				next = WAIT;

	MODE: 					next = WAIT;

	EXTMODE: 				next = WAIT;

        WAIT: if( !sdram_wait )			next = NOP;
    endcase
end

// Just for printing proper messages

//synopsis translate off
// reg [8:0] col_d;
// always @(posedge clk)begin
// 	col_d <= col;
//     if( state == WRITE && sdram_dq != 0 )
//         $display( "write %h at %h", sdram_dq, col_d );
// end
//synopsis translate on
endmodule