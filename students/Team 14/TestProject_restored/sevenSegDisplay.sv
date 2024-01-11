module sevenSegDisplay(
    input [19:0] number,
	 input onOff,
    output [5:0] segment_array_1,
	 output [5:0] segment_array_2,
	 output [5:0] segment_array_3,
	 output [5:0] segement_array_4,
	 output [5:0] segment_array_5,
	 output [5:0] segment_array_6
);
	
	/* TODO: Instantiate six copies of sevenSegDigit, one for each digit (calculated below)*/
	
	reg [3:0] won;
	reg [3:0] too;
	reg [3:0] tree;
	reg [3:0] fore;
	reg [3:0] fife;
	reg [3:0] seggs;
	
	sevenSegDigit one(won,onOff,segment_array_1);
	sevenSegDigit two(too, onOff, segment_array_2);
	sevenSegDigit three(tree, onOff, segment_array_3);
	sevenSegDigit four(fore, onOff, segment_array_4);
	sevenSegDigit five(fife, onOff, segment_array_5);
	sevenSegDigit six(seggs, onOff, segment_array_6);


	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Convert a 20-bit input number to six individual digits (4 bits each) */
		won = number%10;
		too = (number/10)%10;
		tree = (number/100)%10;
		fore = (number/1000)%10;
		fife = (number/10000)%10;
		seggs = (number/100000)%10;
	end

endmodule