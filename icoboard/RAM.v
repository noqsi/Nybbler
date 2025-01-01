module RAM #(
	parameter ABITS = 12,
	parameter DBITS = 12
) (
	input [ABITS-1:0] addr,
	input [DBITS-1:0] wdata,
	output reg [DBITS-1:0] rdata,
	input clock, 
	input write
);

	reg [DBITS-1:0] memory [0:(1<<(ABITS))-1];
	
	always @(posedge clock) begin
		if( write ) memory[addr] <= wdata;
		else rdata <= memory[addr];
	end
endmodule

