module pi_interface ( 
	input clk,

// Raspberry Pi GPIO interface
	
        input pi_bus_clk, 
        input pi_select,
        input pi_dir,
        input [7:0] byte_from_pi,
	output [7:0] byte_to_pi,

// Interface to nybbler

	output [15:0] address,
	output [11:0] word_from_pi,
	output read, write, start, halt,
	
	input [11:0] word_to_pi,
	input [15:0] status_to_pi,
	
	output [7:0] debug
);

// Four registers capture the interface state
//
// ar (8 bits), address LSBs
// arx (8 bits), address MSBs (including segment number)
// dr (8 bits), data LSBs
// drx (4 bits), data MSBs

	reg [7:0] ar, arx, dr;
	reg [3:0] drx;

// Synchronize the Pi clock, making a pulse 1 cycle wide

        reg [1:0] pi_sync;
        wire pi_clk_sync;
        
        always @(negedge clk) pi_sync <= { pi_sync, pi_bus_clk };
        assign pi_clk_sync = pi_sync == 2'b01;
	
// Debug

	reg [7:0] debug_reg;
	
	always @( posedge clk ) 
		if( cmd ) debug_reg <= debug_reg + 1;
	
	assign debug = dr;

// Command decoding

	wire cmd = pi_clk_sync & pi_dir & pi_select;
	
	wire dr2drx = cmd & byte_from_pi[0];
	wire dr2ar = cmd & byte_from_pi[1];
	wire dr2arx = cmd & byte_from_pi[2];
	wire incar = cmd & byte_from_pi[3];
	wire read = cmd & byte_from_pi[4];
	wire write = cmd & byte_from_pi[5];
	wire start = cmd & byte_from_pi[6];
	wire halt = cmd & byte_from_pi[7];

// Outputs to nybbler core

	assign address = {arx,ar};
	assign word_from_pi = {drx,dr};


// Data to Pi

	always @ ( word_to_pi or status_to_pi or pi_select or pi_clk )
		if( pi_bus_clk )
			if( pi_select ) byte_to_pi = {4'b0000,drx};
			else byte_to_pi = ar;
		else if( pi_select ) byte_to_pi = status_to_pi[15:8];
			else byte_to_pi = status_to_pi[7:0];

// Data register management

	always @ ( posedge clk )
		if( read ) dr <= word_to_pi;	// priority
		else if( dr2drx ) drx <= dr;
		else if( pi_dir & pi_clk_sync & !pi_select ) dr <= byte_from_pi;
			
// Address register management
		
	always @ ( posedge clk )			
		if( incar ) begin	// priority
			if( ar == 8'hff ) arx[3:0] <= arx[3:0] + 1; // carry
			ar <= ar + 1;
		end
		else begin
			if( dr2ar ) ar <= dr;
			if( dr2arx ) arx <= dr;
		end
	
endmodule		
		
