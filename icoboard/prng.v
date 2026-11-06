// Quick and dirty pseudo-random number generator
// Lagged Fibonacci XNOR method

module prng #(
	parameter bits = 12,
	parameter degree = 31,
	parameter tap = 3,
	parameter pad = 'h33b80e19	// randomly chosen seed padding
)(
	input [ bits-1:0 ] seed,
	input reseed,
	output [ bits-1:0 ] number,
	input clk
);

	reg[ degree:1 ] work;
	
	always @( posedge clk )
		if( reseed )
			work = { pad[ degree-1:bits ], seed };
		else
			work = { work[ degree-1:1 ], ~work[ degree ] ^ work[ tap ] };
	
	assign number = work[ bits:1 ];
	
endmodule