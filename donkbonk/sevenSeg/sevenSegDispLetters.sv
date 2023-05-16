module sevenSegDispLetters(b5, b4, b3, b2, b1, b0, seg);
	input [3:0] b5, b4, b3, b2, b1, b0;
    output [7:0] seg [5:0];

	sevenSegDigit digit5(b5, seg[5]);
	sevenSegDigit digit4(b4, seg[4]);
	sevenSegDigit digit3(b3, seg[3]);
	sevenSegDigit digit2(b2, seg[2]);
	sevenSegDigit digit1(b1, seg[1]);
	sevenSegDigit digit0(b0, seg[0]);
endmodule