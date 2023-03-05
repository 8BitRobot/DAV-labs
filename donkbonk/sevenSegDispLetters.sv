module sevenSegDispLetters(b1, b0, dig1, dig0);
	input [3:0] b1, b0;
	output [7:0] dig1, dig0;
	
	sevenSegDigit digit1(b1, dig1);
	sevenSegDigit digit0(b0, dig0);
endmodule