module sevenSegDisplay(
	/* TODO: Ports go here (refer to lab spec) */
	input [19:0] in,
	input onoff,
	output [41:0] disp
);

	
	/* TODO: Instantiate six copies of sevenSegDigit, one for each digit (calculated below)*/
	reg [3:0] num1;
	sevenSegDigit dig1(num1, onoff, disp[41:35]);
	
	reg [3:0] num2;
	sevenSegDigit dig2(num2, onoff, disp[34:28]);
	
	reg [3:0] num3;
	sevenSegDigit dig3(num3, onoff, disp[27:21]);
	
	reg [3:0] num4;
	sevenSegDigit dig4(num4, onoff, disp[20:14]);
	
	reg [3:0] num5;
	sevenSegDigit dig5(num5, onoff, disp[13:7]);
	
	reg [3:0] num6;
	sevenSegDigit dig6(num6, onoff, disp[6:0]);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Convert a 20-bit input number to six individual digits (4 bits each) */
		num6 = in % 10;
		num5 = (in / 10) % 10;
		num4 = (in / 100) % 10;
		num3 = (in / 1000) % 10;
		num2 = (in / 10000) % 10;
		num1 = (in / 100000) % 10;
	end

endmodule