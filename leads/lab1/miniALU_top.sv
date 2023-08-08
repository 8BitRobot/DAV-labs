module miniALU_top(switches, leds);
	input [9:0] switches;
	output [9:0] leds;
	
	assign leds = 1 << (switches - 1);
endmodule