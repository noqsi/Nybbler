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
	
	reg [11:0] instruction_word;
	
	always @( posedge( clk ))
		if( cycle == 1 ) instruction_word <= code_out;

	reg [3:0] instruction;
	
	always @(cycle or instruction_word )
		case( cycle )
		
		2: instruction = instruction_word[11:8];
		
		4: instruction = instruction_word[7:4];
		
		6: instruction = instruction_word[3:0];
		
		default : instruction = 0;
		
		endcase
	
	wire i_nop = execute && ( instruction == 0 );
	wire i_half = execute && ( instruction == 1 );
	wire i_neg = execute && ( instruction == 2 );
	wire i_not = execute && ( instruction == 3 );
	wire i_return = execute && ( instruction == 4 );
	wire i_tsz = execute && ( instruction == 5 );
	wire i_add = execute && ( instruction == 6 );
	wire i_and = execute && ( instruction == 7 );
	wire i_fetch = execute && ( instruction == 8 );
	wire i_store = execute && ( instruction == 9 );
	wire i_swap = execute && ( instruction == 10 );
	wire i_dup = execute && ( instruction == 11 );
	wire i_call = execute && ( instruction == 12 );
	wire i_extend = execute && ( instruction == 13 );
	wire i_jump = execute && ( instruction == 14 );
	wire i_literal = execute && ( instruction == 15 );
	
	reg [11:0] signed_arg, unsigned_arg;
	
	always @( cycle or instruction_word or code_out )
		case( cycle[2:1] )
		
		1: begin
			signed_arg = 
			{ {4{ instruction_word[7] }}, instruction_word[ 7:0] };
			unsigned_arg = { 4'h0, instruction_word[ 7:0] };
		end
		
		2: begin
			signed_arg = 
			{ {8{ instruction_word[3] }}, instruction_word[ 3:0] };
			unsigned_arg = { 8'h00, instruction_word[ 3:0] };
		end
		
		3: begin
			signed_arg = code_out;
			unsigned_arg = code_out;
		end
		
		default: begin
			signed_arg = 0;
			unsigned_arg = 0;
		end
		endcase

		
	
// The multiplexing here implements data flows for
// the fetch and store instructions.
		
	wire [11:0] data_in = running ? number_out : host_word_in;	
	wire [11:0] data_out;
	wire data_write = 
		running ? i_store : ( host_write && (mem_seg == 1));
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
		else if( halt_request && last_cycle ) running <= 0;
	
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
		else begin
			if( i_return ) PC <= return_out;
			if( i_tsz && TOS == 0 ) PC <= PC + 1;
			if( i_call ) PC <= unsigned_arg;
			if( i_jump ) PC <= PC + signed_arg;
			if( cycle == 0 ) PC <= PC + 1;
		end
	
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
	
// Intruction cycle

	reg [2:0] cycle;
	
	wire last_cycle = cycle == 6 || execute && instruction[3:2] == 2'b11;
	
	always @( posedge( clk ))
		if( !running || last_cycle ) 
			cycle <= 0;
		else
			cycle = cycle + 1 ;

	wire execute = ( cycle == 2 ) || ( cycle == 4 ) || ( cycle == 6 );

	assign status = {8'b0, cycle == 0, cycle == 1, cycle == 2, cycle == 3, cycle == 4, cycle == 5, cycle == 6, running};
	
endmodule
