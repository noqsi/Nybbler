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
	
	always @( mem_seg or data_out or code_out )
		case( mem_seg )
		
		1 : host_word_out = data_out;
		
		2 : host_word_out = code_out;
		
		3 : host_word_out = number_out;
		
		4 : host_word_out = return_out;
		
		default : host_word_out = 'hBAD;
		endcase
		
	wire [11:0] data_in = host_word_in;	// Future mux
	wire [11:0] data_out;
	wire data_write = host_write & mem_seg == 1;	// Future mux
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
	wire code_write = host_write & mem_seg == 2;	// Future mux
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
	wire number_write = host_write & mem_seg == 3;	// Future mux
	wire [7:0] number_addr = mem_addr;	// Future mux

	RAM #(
		.ABITS( 8 )
	) number (
		.addr( number_addr ),
		.wdata( number_in ),
		.rdata( number_out ),
		.clock( clk ),
		.write( number_write )
	);

	wire [11:0] return_in = host_word_in;	// Future mux
	wire [11:0] return_out;
	wire return_write = host_write & mem_seg == 4;	// Future mux
	wire [7:0] return_addr = mem_addr;	// Future mux

	RAM #(
		.ABITS( 8 )
	) return (
		.addr( return_addr ),
		.wdata( return_in ),
		.rdata( return_out ),
		.clock( clk ),
		.write( return_write )
	);

	assign status = 1983;
endmodule
