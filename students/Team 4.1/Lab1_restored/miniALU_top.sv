module miniALU_top(input [9:0] switches, 
						output [9:0] leds,
						output [7:0] one, two, three, four, five, six);

	logic [3:0] op1;
	assign op1 = switches[9:6];
	logic [3:0] op2;
	assign op2 = switches[5:2];
	assign sel = switches[1];
	assign sw = switches[0];

	assign leds = switches;
	
	miniALU hello(op1, op2, sel, out);
	
	sevenSegDisplay UUT(out, sw, one, two, three, four, five, six);
	
endmodule