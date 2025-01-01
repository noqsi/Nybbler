module core (
	input clk,

// host interface

	input [15:0] addr_in,
	input [11:0] data_in,
	output [11:0] data_out,
	output [15:0] status,
	input read, write, start, halt
);
	wire [11:0] mem_addr = addr_in[11:0];

	RAM data (
		.addr( mem_addr ),
		.wdata( data_in ),
		.rdata( data_out ),
		.clock( clk ),
		.write( write )
	);

	assign status = 1983;
endmodule
