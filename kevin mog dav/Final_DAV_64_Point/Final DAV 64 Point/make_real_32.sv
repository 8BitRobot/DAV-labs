module make_real_32(fft_full, fft_vga);
	input wire [35:0] fft_full [POINTS-1:0];
	output wire [8:0] fft_vga [POINTS-1:0];
	
	parameter POINTS = 32;
	
	assign fft_vga[0] = {fft_full[0][32:24]}; // Treat the DC component a bit different
	
	genvar i;
	
	generate
		for (i = 1; i < POINTS; i++) begin: SIGN_EXT
			assign fft_vga[i] = {fft_full[i][30:22]};
		end
	endgenerate
	
endmodule