

module SB_IO (
	PACKAGE_PIN, 
//	LATCH_INPUT_VALUE, 
//	CLOCK_ENABLE, 
//	INPUT_CLK, 
//	OUTPUT_CLK,   
	OUTPUT_ENABLE, 
//	D_OUT_1, 
	D_OUT_0, 
//	D_IN_1, 
	D_IN_0
 ) /* synthesis syn_black_box syn_lib_cell=1 black_box_pad_pin="PACKAGE_PIN" */;

parameter PIN_TYPE			= 6'b000000;	  // The default is set to report IO macros that do not define what IO type is used. 
parameter PULLUP = 1'b0; // by default the IO will have NO pullup, this parameter is used only on bank 0, 1, and 2. Will be ignored when it is placed at bank 3
parameter NEG_TRIGGER = 1'b0; // specify the polarity of all FFs in the IO to be falling edge when NEG_TRIGGER = 1, default is rising edge
parameter IO_STANDARD = "SB_LVCMOS"; // more standards are supported in bank 3 only: SB_SSTL2_CLASS_2, SB_SSTL2_CLASS_1, SB_SSTL18_FULL, SB_SSTL18_HALF
						 // SB_MDDR10, SB_MDDR8, SB_MDDR4, SB_MDDR2
// input D_OUT_1;  		// Input output 1
input D_OUT_0;  		// Input output 0

// input CLOCK_ENABLE;    		// Clock enables NEW - common to in/out clocks

// output D_IN_1;    		// Output input 1
output D_IN_0;    		// Output input 0

input OUTPUT_ENABLE;   		// Ouput-Enable 
// input LATCH_INPUT_VALUE;    		// Input control
// input INPUT_CLK ; /* synthesis syn_isclock = 1 */ 		// Input clock
// input OUTPUT_CLK ; /* synthesis syn_isclock = 1 */  		// Output clock

inout 	PACKAGE_PIN; 		//' User's package pin - 'PAD' output

endmodule

