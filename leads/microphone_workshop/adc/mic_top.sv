module mic_top(input clk, input adc_clk, output [9:0] leds);

	wire [11:0] mic_output;
	adc mic_adc(
		.CLOCK(adc_clk),
		.RESET(0),
		.CH0(mic_output)
	);
	
	assign leds = mic_output[11:2];

endmodule