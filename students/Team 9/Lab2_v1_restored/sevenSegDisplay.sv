`timescale 1ns/1ns

module sevenSegDisplay(
	input [15:0] outputResult, //accepts 9 bit switch number
	input clk,
	input flash, 
	output [47:0] display
);

	reg [3:0] output0;
	reg [3:0] output1;
	reg [3:0] output2;
	reg [3:0] output3;
	reg [3:0] output4;
	reg [3:0] output5;
	
	
	 /* Instantiate six copies of sevenSegDigit, one for each digit */
    sevenSegDigit digit1 (output0, clk, flash, display[7:0]); 
	 sevenSegDigit digit2 (output1, clk, flash, display[15:8]);
	 sevenSegDigit digit3 (output2, clk, flash, display[23:16]);
	 sevenSegDigit digit4 (output3, clk, flash, display[31:24]);
	 sevenSegDigit digit5 (output4, clk, flash, display[39:32]);
	 sevenSegDigit digit6 (output5, clk, flash, display[47:40]);
	 

	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Convert a 20-bit input number to six individual digits (4 bits each) */
		output0 = (outputResult) % 10;
		output1 = ((outputResult) / 10) % 10;
		output2 = ((outputResult) / 100) % 10;
		output3 = ((outputResult) / 1000) % 6; //third digit
		output4 = ((outputResult) / 6000) % 10;
		output5 = ((outputResult) / 60000) % 6; //first digit
	end

endmodule