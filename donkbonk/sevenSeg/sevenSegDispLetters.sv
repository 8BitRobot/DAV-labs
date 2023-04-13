module sevenSegDispLetters(b1, b0, segment1, segment0);
	input [3:0] b1, b0;
	output [7:0] segment1, segment0;
	
	sevenSegDigit digit1(b1, segment1);
	sevenSegDigit digit0(b0, segment0);
endmodule