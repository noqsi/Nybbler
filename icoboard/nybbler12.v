module top (
	input clk_100mhz,
	output reg led1, led2, led3,
	output pmod1_1, pmod1_2, pmod1_3, pmod1_4, pmod1_7, pmod1_8, pmod1_9, pmod1_10,
	output pmod2_1, pmod2_2, pmod2_3, pmod2_4, pmod2_7, pmod2_8, pmod2_9, pmod2_10,
	output pmod3_1, pmod3_2, pmod3_3, pmod3_4, pmod3_7, pmod3_8, pmod3_9, pmod3_10,
	output pmod4_1, pmod4_2, pmod4_3, pmod4_4, pmod4_7, pmod4_8, pmod4_9, pmod4_10,
	input pi_clk, 
	input pi_regsel,
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


// Synchronize the Pi clock, making a pulse 1 cycle wide

	reg [1:0] pi_sync;
	wire pi_clk_sync;
	
	always @(negedge clk) pi_sync <= { pi_sync, pi_clk };
	assign pi_clk_sync = pi_sync == 2'b01;
	
// Parallel port

	wire [7:0] d_to_pi, d_from_pi;
	
	SB_IO #(
                .PIN_TYPE(6'b 1010_01),
                .PULLUP(1'b 0)
        ) raspi_io [7:0] (
                .PACKAGE_PIN({pi_d7, pi_d6, pi_d5, pi_d4,
			 pi_d3, pi_d2, pi_d1, pi_d0}),
                .OUTPUT_ENABLE(!pi_dir),
                .D_OUT_0(d_to_pi),
                .D_IN_0(d_from_pi)
        );

	reg [7:0] rr;
	
	always @(posedge clk) if( pi_clk_sync && pi_dir ) rr <= d_from_pi;
	
	assign d_to_pi = rr;
	
	assign pmod4_4 = 0;
	
	assign {pmod1_10, pmod1_9, pmod1_8, pmod1_7,
		pmod1_4, pmod1_3, pmod1_2, pmod1_1 } = rr;
	
	assign {pmod2_10, pmod2_9, pmod2_8, pmod2_7,
		pmod2_4, pmod2_3, pmod2_2, pmod2_1 } = d_from_pi;
		
	assign {pmod3_10, pmod3_9, pmod3_8, pmod3_7,
		pmod3_4, pmod3_3, pmod3_2, pmod3_1 } = d_from_pi;
	
	assign pmod4_1 = pi_regsel;
	assign pmod4_2 = pi_dir;
	assign pmod4_3 = pi_clk;
	assign pmod4_10= clk;
	assign {pmod4_9, pmod4_8} = pi_sync;
	assign pmod4_7 = pi_clk_sync;
	
	
	
	
endmodule
