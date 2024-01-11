`timescale 1ns/1ns

module sevenSegDisplay(
	/* TODO: Ports go here (refer to lab spec) */
	input [19:0] outputResult,
	input onOff,
	output [47:0] display
);

	reg [3:0] output0;
	reg [3:0] output1;
	reg [3:0] output2;
	reg [3:0] output3;
	reg [3:0] output4;
	reg [3:0] output5;
	
	/* TODO: Instantiate six copies of sevenSegDigit, one for each digit (calculated below)*/
	
	/*
	for (integer j = 19; j >= 0; j = j - 1)  begin
				outputDecimal = outputDecimal + outputResult[i]*(2**j)
	end
	*/
	
	
	    /* Instantiate six copies of sevenSegDigit, one for each digit */
    sevenSegDigit digit1 (output0, onOff, display[7:0]); 
	 sevenSegDigit digit2 (output1, onOff, display[15:8]);
	 sevenSegDigit digit3 (output2, onOff, display[23:16]);
	 sevenSegDigit digit4 (output3, onOff, display[31:24]);
	 sevenSegDigit digit5 (output4, onOff, display[39:32]);
	 sevenSegDigit digit6 (output5, onOff, display[47:40]);
	 

	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Convert a 20-bit input number to six individual digits (4 bits each) */
		output0 = (outputResult) % 10;
		output1 = (outputResult / 10) % 10;
		output2 = (outputResult / 100) % 10;
		output3 = (outputResult / 1000) % 10;
		output4 = (outputResult / 10000) % 10;
		output5 = (outputResult / 100000) % 10;
	end

endmodule