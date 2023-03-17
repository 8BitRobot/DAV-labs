`timescale 1ns/1ns
module butterfly_tb(plus, minus);
    logic clk;
    logic [31:0] Aa;
    logic [31:0] Bb;
    logic [31:0] Ww;
    output [31:0] plus;
    output [31:0] minus;
    wire [31:0] plus_out;
    wire [31:0] minus_out;

    initial begin
        clk = 0;
        Aa = 32'b00000000000000100000000000000011;
        Bb = 32'b00000000000000010000000000000100;
        Ww = 32'b00000000000000010000000000000000;
    end

    always begin
        #10;
        clk = ~clk;
    end

    assign plus = plus_out;
    assign minus = minus_out;

    butterfly #(32) icantbelieveitsnot(Aa, Bb, Ww, plus_out, minus_out);
endmodule