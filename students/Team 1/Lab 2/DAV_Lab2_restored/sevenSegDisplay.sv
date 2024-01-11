module sevenSegDisplay(
	input [9:0] in, // a number in seconds
	input onoff,
	output [47:0] disp
);

	reg [2:0] num1; // Base 6
	sevenSegDigit dig1(num1, onoff, disp[47:40]);
	
	reg [3:0] num2;
	sevenSegDigit dig2(num2, onoff, disp[39:32]);
	
	reg [2:0] num3; // Base 6
	sevenSegDigit dig3(num3, onoff, disp[31:24]);
	
	reg [3:0] num4;
	sevenSegDigit dig4(num4, onoff, disp[23:16]);
	
	reg [3:0] num5;
	sevenSegDigit dig5(num5, onoff, disp[15:8]);
	
	reg [3:0] num6;
	sevenSegDigit dig6(num6, onoff, disp[7:0]);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/*Convert a time to min/sec/centisec */
		num6 = in % 10;
		num5 = (in / 10) % 10;
		num4 = (in / 100) % 10;
		num3 = (in / 1000) % 6;
		num2 = (in / 6000) % 10;
		num1 = (in / 60000) % 6;
	end

endmodule