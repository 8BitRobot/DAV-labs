`timescale 1ns/1ns
module m2w_tb();
    reg [31:0] point [0:3] = '{ 1, 0, 0, 1 };

    wire [15:0] scale1 [0:3] [0:3];
    wire [15:0] rotate1 [0:3] [0:3];
    wire [15:0] scale2 [0:3] [0:3];
    wire [15:0] rotate2 [0:3] [0:3];

    scale s1(200, 200, 200, scale1);
    scale s1(10, 1, 1, scale1);

    reg [15:0] current_transformation [0:3] [0:3];

    reg clk = 0;
    always begin
        #5 clk = ~clk;
    end

    matrix_3_multiply 

    initial begin
        
    end
endmodule