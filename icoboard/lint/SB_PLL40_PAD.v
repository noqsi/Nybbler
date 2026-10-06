module SB_PLL40_PAD (
		PACKAGEPIN,		
//		PLLOUTCORE,		//PLL output to core logic
		PLLOUTGLOBAL,	   	//PLL output to global network
//		EXTFEEDBACK,  			//Driven by core logic
//		DYNAMICDELAY,		//Driven by core logic
		LOCK,				//Output of PLL
		BYPASS,				//Driven by core logic
		RESETB				//Driven by core logic
//		SDI,				//Driven by core logic. Test Pin
//		SDO,				//Output to RB Logic Tile. Test Pin
//		SCLK,				//Driven by core logic. Test Pin
//		LATCHINPUTVALUE 	//iCEGate signal
)/* synthesis syn_black_box black_box_pad_pin="PACKAGEPIN" syn_lib_cell=1*/;
input 	PACKAGEPIN;		
// output 	PLLOUTCORE;		//PLL output to core logic
output	PLLOUTGLOBAL;	   	//PLL output to global network
// input	EXTFEEDBACK;  			//Driven by core logic
// input	[7:0] DYNAMICDELAY;  	//Driven by core logic
output	LOCK;				//Output of PLL
input	BYPASS;				//Driven by core logic
input	RESETB;				//Driven by core logic
// input	LATCHINPUTVALUE; 	//iCEGate signal
//Test Pins
// output	SDO;				//Output of PLL
// input	SDI;				//Driven by core logic
// input	SCLK;				//Driven by core logic


//Feedback
parameter FEEDBACK_PATH = "SIMPLE";	//String  (simple, delay, phase_and_delay, external) 
parameter DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED"; 
parameter DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED"; 
parameter SHIFTREG_DIV_MODE = 2'b0; //0-->Divide by 4, 1-->Divide by 7.
parameter FDA_FEEDBACK = 0; 		//Integer. 

parameter FDA_RELATIVE = 0; 		//Integer. 
parameter PLLOUT_SELECT = "GENCLK"; //

//Use the Spreadsheet to populate the values below.
parameter DIVR = 4'b0000; 	//determine a good default value
parameter DIVF = 7'b0000000; //determine a good default value
parameter DIVQ = 3'b000; 	//determine a good default value
parameter FILTER_RANGE = 3'b000; 	//determine a good default value

//Additional cbits
parameter ENABLE_ICEGATE = 1'b0;

//Test Mode parameter
parameter TEST_MODE = 1'b0;
parameter EXTERNAL_DIVIDE_FACTOR = 1; //Not used by model. Added for PLL Config GUI.


endmodule // SB_PLL40_PAD
