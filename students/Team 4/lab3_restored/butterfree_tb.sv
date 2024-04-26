`timescale 1ns/1ns

module butterfree_tb (output reg signed [15:0] A_real, A_imag, B_real, B_imag, W_real, W_imag, 
																out1_real, out1_imag, out2_real, out2_imag);

	wire signed [31:0] A, B, W, out1, out2;
	
	assign A[31:16] = A_real;
	assign A[15:0] = A_imag;
	assign B[31:16] = B_real;
	assign B[15:0] = B_imag;
	assign W[31:16] = W_real;
	assign W[15:0] = W_imag;
	assign out1_real = out1[31:16];
	assign out1_imag = out1[15:0];
	assign out2_real = out2[31:16];
	assign out2_imag = out2[15:0];
	
	butterfree BUG_BUZZ(A, B, W, out1, out2);
	
	integer i;
	
	initial begin
	
		for (i = 0; i < 10; i=i+1) begin
			#10;
			A_real = i * 'd7;
			A_imag = i * ('d0-'d5);
			B_real = i * ('d0-'d13);
			B_imag = i * 'd3;
			W_real = i * 'd2;
			W_imag = i * ('d0-'d1);
		end
		
		$stop;
	end
	
endmodule