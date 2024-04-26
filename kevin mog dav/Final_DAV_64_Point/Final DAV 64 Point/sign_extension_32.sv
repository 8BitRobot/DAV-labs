module sign_extension_32(mic_samples, fft_samples);
	parameter POINTS = 32;
	input wire [11:0] mic_samples [POINTS-1:0];
	output wire [35:0] fft_samples [POINTS-1:0];
	
	genvar i;
	generate
		for (i = 0; i < POINTS; i++) begin: SIGN_EXT
			assign fft_samples[i] = {6'b000000, mic_samples[i], 18'b000000000000000000};
		end
	endgenerate

endmodule