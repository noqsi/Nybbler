module core (
	input clk,

// host interface

	input [15:0] host_addr_in,
	input [11:0] host_word_in,
	output reg [11:0] host_word_out,
	output [15:0] status,
	input host_read, host_write, start, halt
);
	wire [11:0] mem_addr = host_addr_in[11:0];
	wire [3:0] mem_seg = host_addr_in[15:12];
	
// Host data mux
	
	always @( mem_seg or data_out or code_out or number_out 
		or return_out or registers_out )
		case( mem_seg )
		
		1 : host_word_out = data_out;
		
		2 : host_word_out = code_out;
		
		3 : host_word_out = number_out;
		
		4 : host_word_out = return_out;
		
		5 : host_word_out = registers_out;
		
		default : host_word_out = 'hBAD;
		endcase

	wire [3:0] instruction = 0;	// stub
	
	wire i_nop = instruction == 0;
	wire i_half = instruction == 1;
	wire i_neg = instruction == 2;
	wire i_not = instruction == 3;
	wire i_return = instruction == 4;
	wire i_tsz = instruction == 5;
	wire i_add = instruction == 6;
	wire i_and = instruction == 7;
	wire i_fetch = instruction == 8;
	wire i_store = instruction == 9;
	wire i_swap = instruction == 10;
	wire i_dup = instruction == 11;
	wire i_call = instruction == 12;
	wire i_jump = instruction == 13;
	wire i_literal = instruction == 14;
	wire i_extend = instruction == 15;
	
// The multiplexing here implements data flows for
// the fetch and store instructions.
		
	wire [11:0] data_in = running ? number_out : host_word_in;	
	wire [11:0] data_out;
	wire data_write = 
		running ? ( execute && i_store )
		: ( host_write && (mem_seg == 1));
	wire [11:0] data_addr = running ? TOS : mem_addr;
	

	RAM data (
		.addr( data_addr ),
		.wdata( data_in ),
		.rdata( data_out ),
		.clock( clk ),
		.write( data_write )
	);

// Only the host can write code, so these flows are simple

	wire [11:0] code_in = host_word_in;
	wire [11:0] code_out;
	wire code_write = host_write && (mem_seg == 2);
	wire [11:0] code_addr = running ? PC : mem_addr;

	RAM code (
		.addr( code_addr ),
		.wdata( code_in ),
		.rdata( code_out ),
		.clock( clk ),
		.write( code_write )
	);
	
// Number stack data comes from TOS, address from SP

	wire [11:0] number_in = running ? TOS : host_word_in;
	wire [11:0] number_out;
        wire number_write = running ? ( i_swap || i_literal )
		: ( host_write && (mem_seg == 3));
	wire [7:0] number_addr = running ? SP : mem_addr[7:0];

	RAM #(
		.ABITS( 8 )
	) number_stack (
		.addr( number_addr ),
		.wdata( number_in ),
		.rdata( number_out ),
		.clock( clk ),
		.write( number_write )
	);

// Return stack data comes from PC, address from RSP

	wire [11:0] return_in = running ? PC : host_word_in;
	wire [11:0] return_out;
	wire return_write = running ? i_call : ( host_write && (mem_seg == 4));
	wire [7:0] return_addr = running ? RSP : mem_addr[7:0];

	RAM #(
		.ABITS( 8 )
	) return_stack (
		.addr( return_addr ),
		.wdata( return_in ),
		.rdata( return_out ),
		.clock( clk ),
		.write( return_write )
	);
	
// START/HALT logic

	reg running, halt_request;
	
	always @( posedge( clk ))
		if( start ) running <= 1;
		else if( halt_request ) running <= 0;
	
	always @( posedge( clk ))
		if( halt ) halt_request <= 1;	  
		else if( !running ) halt_request <= 0;
							  	  
	
// Processor registers

	reg [11:0] registers_out;	// Mux'd for host

	always @( mem_addr or PC or RSP or TOS or SP )
		case( mem_addr )
		
		0 : registers_out = PC;
		
		1 : registers_out = { 4'h0, RSP };
		
		2 : registers_out = TOS;
		
		3 : registers_out = { 4'h0, SP };
		
		default : registers_out = 'hbad;
		endcase

	wire reg_write = host_write && (mem_seg == 5);

	reg [11:0] PC;
	
	wire pc_write = reg_write && (mem_addr == 0);
	
	always @( posedge( clk )) 
		if( !running ) begin
			if( pc_write ) PC <= host_word_in;
		end
		// else do processor stuff
	
	reg [7:0] RSP;
	
	wire rsp_write = reg_write && (mem_addr == 1);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( rsp_write ) RSP <= host_word_in[7:0];
		end
		// else do processor stuff
	
	reg [11:0] TOS;
	
	wire tos_write = reg_write && (mem_addr == 2);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( tos_write ) TOS <= host_word_in;
		end
		// else do processor stuff

	reg [7:0] SP;
	
	wire sp_write = reg_write && (mem_addr == 3);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( sp_write ) SP <= host_word_in[7:0];
		end
		// else do processor stuff
	
// For now, alternate execute and memory cycles

	reg execute;
	
	always @( posedge( clk ))
		if( !running )
			execute <= 0;
		else
			execute <= !execute;

	assign status = {15'b0, running};
	
endmodule
