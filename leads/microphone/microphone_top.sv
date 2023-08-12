module microphone_top(
	input        clk,
	input 		 reset,
	output [9:0] leds
);

	logic [11:0] out;
	
	micADC microphone(
		.CLOCK(clk),
		.CH0(out),
		.RESET(~reset)
	);
	
	assign leds = 10'b1000000000 >> (out[11:8] - 7);

endmodule