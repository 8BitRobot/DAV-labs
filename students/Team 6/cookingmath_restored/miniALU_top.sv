module miniALU_top(
	input [9:0] switches, 
	output [9:0] leds, 
	output [47:0] displays
); //receiving ten bit number and outputting 10 bit #
	// variable in verilog is just a wire (cannot change sequentially)
	
	logic [19:0] bigNum;
	// receiving 10 bit number and outputting 10 bit number
	assign leds = switches; //connecting switches directly to leds (basically connecting the two wires together)
	//assign statement takes value of whatever switches 10 bit number and assigning that to the leds directly
	
	miniALU ALU(switches[9:6], switches[5:2], switches[1], bigNum);
	sevenSegDisplay display(10, 1, displays);
	
endmodule