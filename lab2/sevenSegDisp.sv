module sevenSegDisp(value, onSwitch, dig5, dig4, dig3, dig2, dig1, dig0 );
	input onSwitch;
//	input [19:0] value;
	input [23:0] value;
	output [7:0] dig5, dig4, dig3, dig2, dig1, dig0; //5 to 0 are the 6 displays on the board from left to right
	reg [3:0] input5, input4, input3, input2, input1, input0; //You will need more of these

	/* 
	----------PART THREE----------
	Instantiate six of the sevenSegDigit modules that you wrote, one corresponding to each physical display
	*/
	sevenSegDigit digit5(input5, onSwitch, 8'b00000000, dig5); //Instantiation of the leftmost seven-seg display
	sevenSegDigit digit4(input4, onSwitch, 8'b00000000, dig4);
	sevenSegDigit digit3(input3, onSwitch, 8'b00000000, dig3);
	sevenSegDigit digit2(input2, onSwitch, 8'b00000000, dig2);
	sevenSegDigit digit1(input1, onSwitch, 8'b00000000, dig1);
	sevenSegDigit digit0(input0, onSwitch, 8'b00000000, dig0);
	/*

	Next, you should write logic to convert the 20 bit value into 6 different 4 bit inputs for each of your displays.
	For example, if your value is 146, you want the three leftmost digits to get 0, dig2 to get input 1, dig1 to get input 4, and dig0 to get input 6.
	You will likely need to use the division and mod operators to convert from binary to base10.

	Please wrap your logic in an always_comb block to ensure combinational logic only.
	----------PART THREE----------
	*/
	
	always_comb begin
		input0 = value % 16;
		input1 = (value / 16) % 16;
		input2 = (value / 256) % 16;
		input3 = (value / 4096) % 16;
		input4 = (value / 65536) % 16;
		input5 = (value / 1048576) % 16;
//		input0 = value % 10;
//		input1 = (value / 10) % 10;
//		input2 = (value / 100) % 10;
//		input3 = (value / 1000) % 10;
//		input4 = (value / 10000) % 10;
//		input5 = (value / 100000) % 10;
	end
endmodule