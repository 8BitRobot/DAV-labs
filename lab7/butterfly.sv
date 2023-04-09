module butterfly (A, B, W, plus, minus);
// For WIDTH-1=32, each port will be 32 bits wide. 
// The top 16 bits will represent the real portion, and the bottom 16 the imaginary portion.
    parameter WIDTH = 32;
    input signed [WIDTH-1:0] A;
    input signed [WIDTH-1:0] B;
    input signed [WIDTH-1:0] W;
    output signed [WIDTH-1:0] plus; // A + W*B
    output signed [WIDTH-1:0] minus;

    wire [(WIDTH/2-1):0] w_real;
    wire [(WIDTH/2-1):0] w_imag;
    wire [(WIDTH/2-1):0] be_real;
    wire [(WIDTH/2-1):0] b_imag;
    
    assign w_real = W[WIDTH-1:WIDTH/2];
    assign w_imag = W[WIDTH/2-1:0];
    assign be_real = B[WIDTH-1:WIDTH/2];
    assign b_imag = B[WIDTH/2-1:0];
    
    wire [WIDTH-1:0] product;

    wire [WIDTH-1:0] product_real;
    wire [WIDTH-1:0] product_imag;
    
    wire [(WIDTH/2 - 1):0] product_real_trunc;
    wire [(WIDTH/2 - 1):0] product_imag_trunc;

    assign product_real = (w_real*be_real) - (w_imag*b_imag);
    assign product_imag = (w_imag*be_real) + (w_real*b_imag);

    assign product_real_trunc = product_real[(WIDTH-1):(WIDTH-1 - WIDTH/2)];
    assign product_imag_trunc = product_imag[(WIDTH-1):(WIDTH-1 - WIDTH/2)];
    
    assign plus = {A[WIDTH-1:WIDTH/2] + product_real_trunc, A[WIDTH/2-1:0] + product_imag_trunc};
    assign minus = {A[WIDTH-1:WIDTH/2] - product_real_trunc, A[WIDTH/2-1:0] - product_imag_trunc};
endmodule