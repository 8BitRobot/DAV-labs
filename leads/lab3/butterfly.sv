module butterfly #(WIDTH=32) (
	input signed [WIDTH-1:0] A,
	input signed [WIDTH-1:0] B,
	input signed [WIDTH-1:0] W,
	output signed [WIDTH-1:0] plus,
	output signed [WIDTH-1:0] minus
);

	wire signed [WIDTH/2-1:0] w_real = W[ WIDTH-1   : WIDTH/2 ];
	wire signed [WIDTH/2-1:0] w_imag = W[ WIDTH/2-1 : 0       ];
	wire signed [WIDTH/2-1:0] b_real = B[ WIDTH-1   : WIDTH/2 ];
	wire signed [WIDTH/2-1:0] b_imag = B[ WIDTH/2-1 : 0       ];
	wire signed [WIDTH/2-1:0] a_real = A[ WIDTH-1   : WIDTH/2 ];
	wire signed [WIDTH/2-1:0] a_imag = A[ WIDTH/2-1 : 0       ];

	wire signed [WIDTH-1:0] wb_real = (w_real * b_real) - (w_imag * b_imag);
	wire signed [WIDTH-1:0] wb_imag = (w_imag * b_real) + (w_real * b_imag);
	
	wire signed [WIDTH/2-1:0] wb_real_trunc = wb_real[WIDTH-2:WIDTH/2-1];
	wire signed [WIDTH/2-1:0] wb_imag_trunc = wb_imag[WIDTH-2:WIDTH/2-1];
	
	wire signed [WIDTH/2-1:0] plus_real  = a_real + wb_real_trunc;
	wire signed [WIDTH/2-1:0] plus_imag  = a_imag + wb_imag_trunc;
	wire signed [WIDTH/2-1:0] minus_real = a_real - wb_real_trunc;
	wire signed [WIDTH/2-1:0] minus_imag = a_imag - wb_imag_trunc;
	
	assign plus  = {  plus_real,  plus_imag };
	assign minus = { minus_real, minus_imag };
	
endmodule