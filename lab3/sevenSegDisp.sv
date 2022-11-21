module sevenSegDisp(value, dig5, dig4, dig3, dig2, dig1, dig0);
	input [19:0] value;
	output [7:0] dig5, dig4, dig3, dig2, dig1, dig0;
	reg [3:0] input5, input4, input3, input2, input1, input0;
	
	sevenSegDigit digit5(input5, 0, dig5);
	sevenSegDigit digit4(input4, 1, dig4);
	sevenSegDigit digit3(input3, 0, dig3);
	sevenSegDigit digit2(input2, 1, dig2);
	sevenSegDigit digit1(input1, 0, dig1);
	sevenSegDigit digit0(input0, 0, dig0);
	
	always_comb begin
		input5 = (value / 60000) % 6;
		input4 = (value / 6000) % 10;
		input3 = (value / 1000) % 6;
		input2 = (value / 100) % 10;
		input1 = (value / 10) % 10;
		input0 = (value % 10);
		
	end
endmodule