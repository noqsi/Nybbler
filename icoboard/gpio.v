module gpio #(
	parameter bits = 8,
	parameter corebits = 12,
	parameter base = 0		// Base address, effectively truncated to even
)(
	input [corebits-1:0] addr,
	output selected,		// to the input mux
	input write,			
	input [corebits-1:0] outbits,
	output reg [corebits-1:0] muxbits,
	input clk,
	inout [bits-1:0] pins
);

	reg [bits-1:0] enable;
	reg [bits-1:0] outreg;  // using the I/O pad register causes conflicts
	wire [bits-1:0] inbits;
	
	assign selected = addr[corebits-1:1] == base[corebits-1:1];
	
	always @(posedge clk)
		if( write & selected )
			if( addr[0] ) enable <= outbits[bits-1:0];
			else outreg <= outbits[bits-1:0];
	
	always @( selected )
		if( selected )
			 if (addr[0] ) muxbits = { {corebits-bits{1'b0}}, enable };
			 else muxbits = { {corebits-bits{1'b0}}, inbits };
		else muxbits = 'hbad;
		
	/* verilator lint_off PINMISSING */

	SB_IO #(
                .PIN_TYPE(6'b 1010_01),	//  unregistered 3 state
                .PULLUP(1'b 1)
        ) port [bits-1:0] (
                .PACKAGE_PIN(pins),
                .OUTPUT_ENABLE(enable),
		.OUTPUT_CLK(clk),
                .D_OUT_0(outreg),
                .D_IN_0(inbits)
        );
	
	/* verilator lint_on PINMISSING */
	
endmodule
