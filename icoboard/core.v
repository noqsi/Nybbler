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
		
	wire [11:0] data_in = host_word_in;	// Future mux
	wire [11:0] data_out;
	wire data_write = host_write && (mem_seg == 1);	// Future mux
	wire [11:0] data_addr = mem_addr;	// Future mux
	

	RAM data (
		.addr( data_addr ),
		.wdata( data_in ),
		.rdata( data_out ),
		.clock( clk ),
		.write( data_write )
	);

	wire [11:0] code_in = host_word_in;	// Future mux
	wire [11:0] code_out;
	wire code_write = host_write && (mem_seg == 2);	// Future mux
	wire [11:0] code_addr = mem_addr;	// Future mux

	RAM code (
		.addr( code_addr ),
		.wdata( code_in ),
		.rdata( code_out ),
		.clock( clk ),
		.write( code_write )
	);

	wire [11:0] number_in = host_word_in;	// Future mux
	wire [11:0] number_out;
        wire number_write = host_write && (mem_seg == 3);	// Future mux
	wire [7:0] number_addr = mem_addr[7:0];	// Future mux

	RAM #(
		.ABITS( 8 )
	) number_stack (
		.addr( number_addr ),
		.wdata( number_in ),
		.rdata( number_out ),
		.clock( clk ),
		.write( number_write )
	);

	wire [11:0] return_in = host_word_in;	// Future mux
	wire [11:0] return_out;
	wire return_write = host_write && (mem_seg == 4);	// Future mux
	wire [7:0] return_addr = mem_addr[7:0];	// Future mux

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
		
		1 : registers_out = RSP;
		
		2 : registers_out = TOS;
		
		3 : registers_out = SP;
		
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
	
	reg [11:0] RSP;
	
	wire rsp_write = reg_write && (mem_addr == 1);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( rsp_write ) RSP <= host_word_in;
		end
		// else do processor stuff
	
	reg [11:0] TOS;
	
	wire tos_write = reg_write && (mem_addr == 2);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( tos_write ) TOS <= host_word_in;
		end
		// else do processor stuff

	reg [11:0] SP;
	
	wire sp_write = reg_write && (mem_addr == 3);
	
	always @( posedge( clk ))
		if( !running ) begin
			if( sp_write ) SP <= host_word_in;
		end
		// else do processor stuff
	

	assign status = {15'b0, running};
	
endmodule
