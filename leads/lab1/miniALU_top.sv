module miniALU_top(
	input [9:0] switches,
	output [9:0] leds,
	output [7:0] digits [0:5]
);

	assign leds = 1 << (switches - 1);
	
	wire [19:0] result;
	miniALU mat(switches[9:6], switches[5:2], switches[1], result);
	sevenSegDisp ssd(result, switches[0], digits);
	
endmodule