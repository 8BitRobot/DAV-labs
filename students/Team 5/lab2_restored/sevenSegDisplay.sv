module sevenSegDisplay(
	input [19:0] number,
   input powerSwitch,
   output reg [7:0] digit0,
	output reg [7:0] digit1,
	output reg [7:0] digit2,
	output reg [7:0] digit3,
	output reg [7:0] digit4,
	output reg [7:0] digit5
);

	/* TODO: Instantiate six copies of sevenSegDigit, one for each digit (calculated below)*/
	sevenSegDigit instance0(num0, powerSwitch, digit0);
	sevenSegDigit instance1(num1, powerSwitch, digit1);   // one powerSwitch goes to each of the digits since the math is figured out by the always_comb block
	sevenSegDigit instance2(num2, powerSwitch, digit2);
	sevenSegDigit instance3(num3, powerSwitch, digit3);
	sevenSegDigit instance4(num4, powerSwitch, digit4);
	sevenSegDigit instance5(num5, powerSwitch, digit5);
	// The following block will contain the logic of your combinational circuit
	reg [3:0] num0, num1, num2, num3, num4, num5;
	always_comb begin
		/* TODO: Convert a 20-bit input number to six individual digits (4 bits each) */
		num0 = number % 10;
		num1 =  (number/ 10) % 10;
		num2 = (number/ 100) % 10;
		num3 = (number/ 1000) % 6;
		num4 = (number/ 6000) % 10;
		num5 = (number/ 60000) % 10;
		
		
		
	end

endmodule