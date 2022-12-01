module sevenSegDisp(value, flash, dig5, dig4, dig3, dig2, dig1, dig0);
	input [19:0] value;
	//input clock;
	input [3:0] flash;
	
	output [7:0] dig5, dig4, dig3, dig2, dig1, dig0;
	reg [3:0] input5, input4, input3, input2, input1, input0;
	
	sevenSegDigit digit5(input5, flash, dig5);
	sevenSegDigit digit4(input4, flash, dig4);
	sevenSegDigit digit3(input3, flash, dig3);
	sevenSegDigit digit2(input2, flash, dig2);
	sevenSegDigit digit1(input1, flash, dig1);
	sevenSegDigit digit0(input0, flash, dig0);
	
	always_comb begin
		input5 = ((value / 60000) % 6);
		input4 = ((value / 6000) % 10);
		input3 = ((value / 1000) % 6);
		input2 = ((value / 100) % 10);
		input1 = ((value / 10) % 10);
		input0 = (value % 10);
	end
endmodule