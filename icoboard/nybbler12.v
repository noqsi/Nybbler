module top (
	input clk_100mhz,
	output reg led1, led2, led3,
	output pmod1_1, pmod1_2, pmod1_3, pmod1_4, pmod1_7, pmod1_8, pmod1_9, pmod1_10,
	output pmod2_1, pmod2_2, pmod2_3, pmod2_4, pmod2_7, pmod2_8, pmod2_9, pmod2_10,
	output pmod3_1, pmod3_2, pmod3_3, pmod3_4, pmod3_7, pmod3_8, pmod3_9, pmod3_10,
	output pmod4_1, pmod4_2, pmod4_3, pmod4_4, pmod4_7, pmod4_8, pmod4_9, pmod4_10,
	input pi_clk, 
	input pi_select,
	input pi_dir,
	inout pi_d0, pi_d1, pi_d2, pi_d3, pi_d4, pi_d5, pi_d6, pi_d7
);

	// Clock Generator

	wire clk_25mhz;
	wire pll_locked;

	SB_PLL40_PAD #(
		.FEEDBACK_PATH("SIMPLE"),
		.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
		.PLLOUT_SELECT("GENCLK"),
		.FDA_FEEDBACK(4'b1111),
		.FDA_RELATIVE(4'b1111),
		.DIVR(4'b0000),
		.DIVF(7'b0000111),
		.DIVQ(3'b101),
		.FILTER_RANGE(3'b101)
	) pll (
		.PACKAGEPIN   (clk_100mhz),
		.PLLOUTGLOBAL (clk_25mhz ),
		.LOCK         (pll_locked),
		.BYPASS       (1'b0      ),
		.RESETB       (1'b1      )
	);

	wire clk = clk_25mhz;

	// Reset Generator

	reg [3:0] resetn_gen = 0;
	reg resetn;

	always @(posedge clk) begin
		resetn <= &resetn_gen;
		resetn_gen <= {resetn_gen, pll_locked};
	end



// Parallel port


	wire [7:0] byte_from_pi;
	reg [7:0] byte_to_pi;
	
	SB_IO #(
                .PIN_TYPE(6'b 1010_01),
                .PULLUP(1'b 0)
        ) raspi_io [7:0] (
                .PACKAGE_PIN({pi_d7, pi_d6, pi_d5, pi_d4,
			 pi_d3, pi_d2, pi_d1, pi_d0}),
                .OUTPUT_ENABLE(!pi_dir),
                .D_OUT_0(byte_to_pi),
                .D_IN_0(byte_from_pi)
        );
	
// Interface between the byte-oriented Pi world and the word-oriented
// nybbler world.

	wire [15:0] unified_addr;
	wire [11:0] pi_to_nybbler;
	wire [11:0] nybbler_to_pi;
	wire [15:0] nybbler_status;
	wire read, write, start, halt;

	pi_interface pif (
		.clk( clk ),
		.pi_bus_clk( pi_clk ),
		.pi_select( pi_select ),
		.pi_dir( pi_dir ),
		.byte_from_pi( byte_from_pi ),
		.byte_to_pi( byte_to_pi ),
		.address( unified_addr ),
		.word_from_pi( pi_to_nybbler ),
		.read( read ),
		.write( write ),
		.start( start ),
		.halt( halt ),
		.word_to_pi( nybbler_to_pi ),
		.status_to_pi( nybbler_status ),
		.debug( front_left_leds )
	);

// Nybbler core

	core c1 (
		.host_addr_in( unified_addr ),
		.host_word_in( pi_to_nybbler ),
		.host_word_out( nybbler_to_pi ),
		.clk( clk ),
		.host_read( read ),
		.host_write( write ),
		.start( start ),
		.halt( halt ),
		.status( nybbler_status )
	);


// Monitor LED assignments

	assign {back_left_leds, back_right_leds} = unified_addr;
	assign front_right_leds = nybbler_status;
	

// PMOD LEDs
// Assume PMOD 1 is front left. Bits arranged so MSB is left

wire [7:0] front_left_leds, front_right_leds, back_left_leds, back_right_leds;

	assign {pmod1_10, pmod1_9, pmod1_8, pmod1_7,
	 	pmod1_4, pmod1_3, pmod1_2, pmod1_1} = front_left_leds;
	
	assign {pmod2_10, pmod2_9, pmod2_8, pmod2_7,
		pmod2_4, pmod2_3, pmod2_2, pmod2_1 } = front_right_leds;
		
	assign {pmod3_1, pmod3_2, pmod3_3, pmod3_4,
		pmod3_7, pmod3_8, pmod3_9, pmod3_10 } = back_right_leds;
		
	assign {pmod4_1, pmod4_2, pmod4_3, pmod4_4,
		pmod4_7, pmod4_8, pmod4_9, pmod4_10 } = back_left_leds;
	
		
	
endmodule
