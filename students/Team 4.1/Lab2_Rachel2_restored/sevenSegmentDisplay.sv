module sevenSegmentDisplay(
	/* TODO: Ports go here (refer to lab spec) */
	input [15:0] n, // time (in binary centi-seconds) to be displayed
	output reg [7:0] one, two, three, four, five, six
);
	
	logic sw = 1;
	
	logic [3:0] arr [0:5]; // array of 4x6 (6 values, 4 bits each)
	/* TODO: Instantiate six copies of sevenSegDigit, one for each digit (calculated below)*/
	sevenSegmentDigit(arr[0], sw, one);
	sevenSegmentDigit(arr[1], sw, two);
	sevenSegmentDigit(arr[2], sw, three);
	sevenSegmentDigit(arr[3], sw, four);
	sevenSegmentDigit(arr[4], sw, five);
	sevenSegmentDigit(arr[5], sw, six);
	
	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Convert a 16-bit input number to six individual digits (4 bits each) */
		arr[5] = 0; // max minutes will be less than 10
		arr[4] = n/6000; // minutes
		arr[3] = ((n%6000)/100)/10;
		arr[2] = ((n%6000)/100)%10;
		arr[1] = ((n%6000)%100)/10;
		arr[0] = ((n%6000)%100)%10;
	end

endmodule