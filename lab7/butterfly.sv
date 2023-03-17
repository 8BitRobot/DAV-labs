module butterfly (A, B, W, plus, minus);
// For WIDTH-1=32, each port will be 32 bits wide. 
// The top 16 bits will represent the real portion, and the bottom 16 the imaginary portion.
    parameter WIDTH = 32;
    input signed [WIDTH-1:0] A;
    input signed [WIDTH-1:0] B;
    input signed [WIDTH-1:0] W;
    output signed [WIDTH-1:0] plus; // A + W*B
    output signed [WIDTH-1:0] minus;

    // wire HALF;
    // assign HALF = WIDTH-1 / 2;

    // B[WIDTH-1:WIDTH-1 / 2]: real (a1)
    // B[WIDTH-1 / 2 : 0]: imaginary (b1)
    // W[WIDTH-1:WIDTH-1 / 2]: real (a2)
    // W[WIDTH-1 / 2 : 0]: imaginary (b2)

    signed [(WIDTH/2-1):0] b1;
    signed [(WIDTH/2-1):0] b2;
    signed [(WIDTH/2-1):0] w1;
    signed [(WIDTH/2-1):0] w2;

    //31 - 16
    //15 - 0
    assign w1 = W[WIDTH-1:WIDTH/2]; // a2
    assign w2 = W[WIDTH/2-1:0];  //b2
    assign b1 = B[WIDTH-1:WIDTH/2]; //a1
    assign b2 = B[WIDTH/2-1:0]; // b1
    
    signed [WIDTH-1:0] product;

    // a1a2 - b1b2
    // b1a2 + b2a1
    assign product = {((b1*w1) - (b2*w2)), ((w2*w1) + (b2*b1))};
    //assign product[WIDTH/2-1:0] = ((w2*w1) + (b2*b1));

    // truncating time woohoo
    // 30 - 15 this is right
    
    signed [WIDTH/2-1:0] truncated;
    assign truncated = product[WIDTH-2:WIDTH - (1 + (WIDTH/2))];

    assign plus = A + truncated;
    assign minus = A - truncated;
endmodule