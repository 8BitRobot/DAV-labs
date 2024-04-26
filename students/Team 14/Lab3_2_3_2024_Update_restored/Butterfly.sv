module Butterfly #(parameter WIDTH = 32)
(
	input [WIDTH-1:0] A,
	input [WIDTH-1:0] B,
	input [WIDTH-1:0] W,
	output [WIDTH-1:0] sum,
	output [WIDTH-1:0] diff
);

	logic [(WIDTH/2)-1:0] A_real, A_imag, B_real, B_imag, W_real, W_imag, sum_real, sum_imag, diff_real, diff_imag;
	
	getRealAndImag #(WIDTH) partsOfA (A, A_real, A_imag);
	getRealAndImag #(WIDTH) partsOfB (B, B_real, B_imag);
	getRealAndImag #(WIDTH) partsOfW (W, W_real, W_imag);

	assign sum_real = A_real + (B_real*W_real - B_imag*W_imag);
	assign sum_imag = A_imag + (B_real*W_imag + B_imag*W_real);
	assign diff_real = A_real - (B_real*W_real - B_imag*W_imag);
	assign diff_imag = A_imag - (B_real*W_real + B_imag*W_imag);
	
	getComplexNum #(WIDTH) sumComplex(sum_real, sum_imag, sum);
	getComplexNum #(WIDTH) diffComplex(diff_real, diff_imag, diff);
	
endmodule