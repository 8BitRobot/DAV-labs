module sevenSegDisplay(
	input [19:0] number,
	input sw,
	output [47:0] displays
);

	
	/* TODO: Instantiate six copies of sevenSegDigit, one for each digit (calculated below)*/
	logic [3:0] digit0;
	logic [3:0] digit1;
	logic [3:0] digit2;
	logic [3:0] digit3;
	logic [3:0] digit4;
	logic [3:0] digit5;
	
	sevenSegDigit d0(digit0, sw, displays[7:0]);
	sevenSegDigit d1(digit1, sw, displays[15:8]);
	sevenSegDigit d2(digit2, sw, displays[23:16]);
	sevenSegDigit d3(digit3, sw, displays[31:24]);
	sevenSegDigit d4(digit4, sw, displays[39:32]);
	sevenSegDigit d5(digit5, sw, displays[47:40]);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Convert a 20-bit input number to six individual digits (4 bits each) */
		digit0 = 1;
		digit1 = 0;
		digit2 = (number / 'd100) % 'd10;
		digit3 = (number / 'd1000) % 'd10;
		digit4 = (number / 'd10000) % 'd10;
		digit5 = (number / 'd100000) % 'd10;
	end

endmodule