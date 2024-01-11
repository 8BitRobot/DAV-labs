module sevenSegDisplay(
	/* TODO: Ports go here (refer to lab spec) */
	input [19:0] n,
	input sw,
	output reg [7:0] one, two, three, four, five, six
);

	logic [3:0] arr [0:5];
	/* TODO: Instantiate six copies of sevenSegDigit, one for each digit (calculated below)*/
	sevenSegDigit(arr[0], sw, six);
	sevenSegDigit(arr[1], sw, five);
	sevenSegDigit(arr[2], sw, four);
	sevenSegDigit(arr[3], sw, three);
	sevenSegDigit(arr[4], sw, two);
	sevenSegDigit(arr[5], sw, one);
	
	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Convert a 20-bit input number to six individual digits (4 bits each) */
		arr[0] = n % 10;
		arr[1] = (n/10) % 10;
		arr[2] = (n/100) % 10;
		arr[3] = (n/1000) % 10;
		arr[4] = (n/10000) % 10;
		arr[5] = (n/100000) % 10;
	end

endmodule