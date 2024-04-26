module sevenSegDisp(value, dig5, dig4, dig3, dig2, dig1, dig0, blank); // GOOD DEBUGGING TOOL
	input [19:0] value;
	input blank;
	output [7:0] dig5, dig4, dig3, dig2, dig1, dig0; //5 to 0 are the 6 displays on the board from left to right
	reg [3:0] input5; //You will need more of these
	reg [3:0] input4;
	reg [3:0] input3;
	reg [3:0] input2;
	reg [3:0] input1;
	reg [3:0] input0;
	reg [19:0] valueCopy;

	/* 
	----------PART THREE----------
	Instantiate six of the sevenSegDigit modules that you wrote, one corresponding to each physical display
	*/
	always @ (*)
	begin
		if (blank == 1) begin
			valueCopy = value;
			input0 = valueCopy % 10;
			valueCopy = valueCopy / 10;
			input1 = valueCopy % 10;
			valueCopy = valueCopy / 10;
			input2 = valueCopy % 10;
			valueCopy = valueCopy / 10;
			input3 = valueCopy % 10;
			valueCopy = valueCopy / 10;
			input4 = valueCopy % 10;
			valueCopy = valueCopy / 10;
			input5 = valueCopy % 10;
		end
		else if (blank==0) begin
			input5 = 10;
			input4 = 10;
			input3 = 10;
			input2 = 10;
			input1 = 10;
			input0 = 10;
		end
	end
	 
	sevenSegDigit digit5(input5, dig5); //Instantiation of the leftmost seven-seg display
	sevenSegDigit digit4(input4, dig4);
	sevenSegDigit digit3(input3, dig3);
	sevenSegDigit digit2(input2, dig2);
	sevenSegDigit digit1(input1, dig1);
	sevenSegDigit digit0(input0, dig0);	
	/*

	Next, you should write logic to convert the 20 bit value into 6 different 4 bit inputs for each of your displays.
	For example, if your value is 146, you want the three leftmost digits to get 0, dig2 to get input 1, dig1 to get input 4, and dig0 to get input 6.
	You will likely need to use the division and mod operators to convert from binary to base10.

	Please wrap your logic in an always_comb block to ensure combinational logic only.
	----------PART THREE----------
	*/
	
	
endmodule