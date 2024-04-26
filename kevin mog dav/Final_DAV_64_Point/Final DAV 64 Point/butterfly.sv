module butterfly (a, b, w, pos_prod, neg_prod);
	parameter WIDTH = 36; // Must be even
	// Define inputs and outputs
	input signed [WIDTH-1:0] a, b, w;
	output signed [WIDTH-1:0] pos_prod, neg_prod;
	
	// Separate the real and imaginary parts of a, b, and w
	wire signed[WIDTH/2 - 1:0] a_real = a[WIDTH-1: WIDTH/2];
	wire signed[WIDTH/2 - 1:0] a_imag = a[WIDTH/2 - 1: 0];
	wire signed[WIDTH/2 - 1:0] b_real = b[WIDTH-1: WIDTH/2];
	wire signed[WIDTH/2 - 1:0] b_imag = b[WIDTH/2 - 1: 0];
	wire signed[WIDTH/2 - 1:0] w_real = w[WIDTH-1: WIDTH/2];
	wire signed[WIDTH/2 - 1:0] w_imag = w[WIDTH/2 - 1: 0];
	
	// FOIL multiplication of b and w
	wire signed[WIDTH - 1:0] product_real = b_real * w_real - b_imag * w_imag;
	wire signed[WIDTH - 1:0] product_imag = b_imag * w_real + b_real * w_imag;
	
	// Truncate the product
	wire signed[WIDTH/2 - 1:0] product_real_trunc = product_real[WIDTH - 2: WIDTH/2 - 1];
	wire signed[WIDTH/2 - 1:0] product_imag_trunc = product_imag[WIDTH - 2: WIDTH/2 - 1];
	
	// A + B*W, real and imaginary
	wire signed[WIDTH/2 - 1:0] pos_prod_real = a_real + product_real_trunc;
	wire signed[WIDTH/2 - 1:0] pos_prod_imag = a_imag + product_imag_trunc;
	
	// A - B*W, real and imaginary
	wire signed[WIDTH/2 - 1:0] neg_prod_real = a_real - product_real_trunc;
	wire signed[WIDTH/2 - 1:0] neg_prod_imag = a_imag - product_imag_trunc;
	
	// Output
	assign pos_prod = {pos_prod_real, pos_prod_imag};
	assign neg_prod = {neg_prod_real, neg_prod_imag};
endmodule