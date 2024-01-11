module sevenSegDisplay(
		input [19:0] number,
		input on,
		output reg [7:0] seg1, seg2, seg3, seg4, seg5, seg6
	);
	reg [3:0] one, two, thr, four, fiv, six;
	
	sevenSegDigit dp1(one, on, 1'b0, seg1);
	sevenSegDigit dp2(two, on, 1'b0, seg2);
	sevenSegDigit dp3(thr, on, 1'b1, seg3);
	sevenSegDigit dp4(four, on, 1'b0, seg4);
	sevenSegDigit dp5(fiv, on, 1'b1, seg5);
	sevenSegDigit dp6(six, on, 1'b0, seg6);

	always_comb begin
		one <= number % 4'd10;
		two <= (number / 20'd10) % 4'd10;
		thr <= (number / 20'd100) % 4'd10;
		four <= (number / 20'd1000) % 4'd6;
		fiv <= (number / 20'd6000) % 4'd10;
		six <= (number / 20'd60000) % 4'd10;
	end

endmodule