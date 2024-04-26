module butterfree 
	# (parameter WIDTH = 32) (
	input reg signed [WIDTH-1:0] A, B, W,
	output wire signed [WIDTH-1:0] out0, out1
	);
	// out0 = A + B*W, out1 = A - B*W
	
	assign out0[WIDTH-1:WIDTH/2] = A[WIDTH-1:WIDTH/2] + ( (W[WIDTH-1:WIDTH/2] * B[WIDTH-1:WIDTH/2]) - (W[WIDTH/2-1:0] * B[WIDTH/2-1:0]) );
	assign out0[WIDTH/2-1:0] = A[WIDTH/2-1:0] + ( (W[WIDTH-1:WIDTH/2] * B[WIDTH/2-1:0]) + (W[WIDTH/2-1:0] * B[WIDTH-1:WIDTH/2]) );
	assign out1[WIDTH-1:WIDTH/2] = A[WIDTH-1:WIDTH/2] - ( (W[WIDTH-1:WIDTH/2] * B[WIDTH-1:WIDTH/2]) - (W[WIDTH/2-1:0] * B[WIDTH/2-1:0]) );
	assign out1[WIDTH/2-1:0] = A[WIDTH/2-1:0] - ( (W[WIDTH-1:WIDTH/2] * B[WIDTH/2-1:0]) + (W[WIDTH/2-1:0] * B[WIDTH-1:WIDTH/2]) );

endmodule