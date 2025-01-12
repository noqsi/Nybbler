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
		if( cycle == 0 ) instruction_word <= code_out;

	reg [3:0] instruction;
	
	always @(cycle or instruction_word )
		case( cycle )
		
		1: instruction = instruction_word[11:8];
		
		3: instruction = instruction_word[7:4];
		
		5: instruction = instruction_word[3:0];
		
		6: instruction = instruction_word[3:0];  // for literal and call
		
		default : instruction = 0;
		
		endcase
	
	parameter i_nop = 0 ;
	parameter i_half = 1 ;
	parameter i_neg = 2 ;
	parameter i_not = 3 ;
	parameter i_return = 4 ;
	parameter i_tsz = 5 ;
	parameter i_add = 6 ;
	parameter i_and = 7 ;
	parameter i_fetch = 8 ;
	parameter i_store = 9 ;
	parameter i_swap = 10 ;
	parameter i_drop = 11 ;
	parameter i_extend = 12 ;
	parameter i_call = 13 ;
	parameter i_jump = 14 ;
	parameter i_literal = 15 ;
	
	wire long_inst = instruction[3:2] == 2'b11; // long instruction
	
	reg [11:0] signed_arg, unsigned_arg;
	
	always @( cycle or instruction_word or code_out )
		case( cycle[2:1] )
		
		0: begin
			signed_arg = 
			{ {4{ instruction_word[7] }}, instruction_word[ 7:0] };
			unsigned_arg = { 4'h0, instruction_word[ 7:0] };
		end
		
		1: begin
			signed_arg = 
			{ {8{ instruction_word[3] }}, instruction_word[ 3:0] };
			unsigned_arg = { 8'h00, instruction_word[ 3:0] };
		end
		
		2: begin
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
		running ? instruction == i_store && execute 
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
        wire number_write = running 
		? instruction == i_swap && execute 
			|| instruction == i_literal && cycle == 6
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

// Return stack data comes from TEMP, address from RSP

	wire [11:0] return_in = running ? TEMP : host_word_in;
	wire [11:0] return_out;
	wire return_write = running ? instruction == i_call && cycle == 6 
		: ( host_write && (mem_seg == 4));
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
	
// Temp register for delayed operand handling

	reg [11:0] TEMP;
	
	always @( posedge( clk )) 
		if( execute )
		case( instruction )
		
		i_literal : TEMP <= signed_arg;
		
		i_call : TEMP <= PC;
		
		endcase
	
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
	
// Program counter (PC)

	reg [11:0] PC;
	
	wire pc_write = reg_write && (mem_addr == 0);
	
	always @( posedge( clk )) 
		if( !running ) begin
			if( pc_write ) PC <= host_word_in;
		end
		else if( execute )
		case( instruction )
		
		i_return : PC <= return_out;
		
		i_tsz : if( TOS == 0 ) PC <= PC + 1;
		
		i_call : PC <= unsigned_arg;
		
		i_jump : PC <= PC + signed_arg;
		
		i_extend : if( cycle == 5 ) PC <= PC + 1;
		
		i_literal : if( cycle == 5 ) PC <= PC + 1;
		
		endcase
		else if( cycle == 0 ) PC <= PC + 1;
		

// Return stack pointer (RSP)
	
	reg [7:0] RSP;
	
	wire rsp_write = reg_write && (mem_addr == 1);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( rsp_write ) RSP <= host_word_in[7:0];
		end
		else if( execute )
		case( instruction )
		
		i_call : RSP <= RSP + 1;
		
		i_return : RSP <= RSP - 1;
		
		endcase
		
// Top of stack (TOS), where arithmetic happens
	
	reg [11:0] TOS;
	
	wire tos_write = reg_write && (mem_addr == 2);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( tos_write ) TOS <= host_word_in;
		end
		else if( execute )
		case( instruction )
		
		i_neg : TOS <= -TOS;

		i_not : TOS <= ~TOS;

		i_half : TOS <= { TOS[11], TOS[11:1] };

		i_add : TOS <= TOS + number_out;

		i_and : TOS <= TOS & number_out;

		i_fetch : TOS <= data_out;

		i_store : TOS <= number_out;

		i_swap : TOS <= number_out;

		i_drop : TOS <= number_out;

		endcase
		else if( instruction == i_literal && cycle == 6 ) TOS <= TEMP;

		
// Number stack pointer (SP)

	reg [7:0] SP;
	
	wire sp_write = reg_write && (mem_addr == 3);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( sp_write ) SP <= host_word_in[7:0];
		end
		else if( execute )
		case( instruction )
		
		i_literal : SP <= SP + 1;
			
		i_add : SP <= SP - 1;
		
		i_and : SP <= SP - 1;
		
		i_store : SP <= SP - 1;
		
		i_drop : SP <= SP - 1;
		
		endcase
	
// Instruction cycle

	reg [2:0] cycle;
	
	wire last_cycle = cycle == 6;
	
	always @( posedge( clk ))
		if( !running ) cycle <= 0;
		else case( cycle )
		
		0: 	cycle <= 1;
		
		1:	if( long_inst ) cycle <= 6;
			else cycle <= 2;
			
		2:	cycle <= 3;
		
		3:	if( long_inst ) cycle <= 6;
			else cycle <= 4;
			
		4:	cycle <= 5;
		
		5:	cycle <= 6;
		
		default: cycle <= 0;
		
		endcase


	wire execute = cycle[0];	// odd numbered steps

	assign status = {8'b0, cycle == 0, cycle == 1, cycle == 2, cycle == 3, cycle == 4, cycle == 5, cycle == 6, running};
	
endmodule
