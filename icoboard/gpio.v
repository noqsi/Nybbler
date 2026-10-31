module gpio #(
	parameter bits = 8,
	parameter corebits = 12,
	parameter base = 0		// Base address, effectively truncated to even
)(
	input [corebits-1:0] addr,
	output selected,		// to the input mux
	input write,			
	input [corebits-1:0] outbits,
	output logic [corebits-1:0] muxbits,
	input clk,
	inout [bits-1:0] pins
);

	reg [bits-1:0] enable;
	wire [bits-1:0] inbits;
	
	assign selected = addr == base;
	
	always_ff @(posedge clk)
		if( addr[0] & write & selected ) enable <= outbits[bits-1:0];
	
	always_comb
		if( selected )
			 if (addr[0] ) muxbits = { {corebits-bits{1'b0}}, enable };
			 else muxbits = { {corebits-bits{1'b0}}, inbits };
		else muxbits = 'hbad;
		
	/* verilator lint_off PINMISSING */

	SB_IO #(
                .PIN_TYPE(6'b 1001_01),	// registerd output with enable, simple input
                .PULLUP(1'b 1)
        ) port [bits-1:0] (
                .PACKAGE_PIN(pins),
                .OUTPUT_ENABLE(enable),
		.OUTPUT_CLK(clk),
		.CLOCK_ENABLE (write & selected & ~addr[0] ),
                .D_OUT_0(outbits[bits-1:0]),
                .D_IN_0(inbits)
        );
	
	/* verilator lint_on PINMISSING */
	
endmodule