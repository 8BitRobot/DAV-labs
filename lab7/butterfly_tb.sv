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
        Aa = 32'b01001110001000000111010100110000;
        Bb = 32'b00100111000100001001110001000000;
        Ww = 32'b01000000000000000000000000000000;
    end

    always begin
        #10;
        clk = ~clk;
    end

    // always @(posedge clk) begin
    //     case (Ww)
    //         32'b01000000000000000000000000000000: begin
    //             Ww <= 32'b00000000000000001111111111111110;
    //         end
    //         32'b00000000000000001111111111111110: begin
    //             Ww <= 32'b11111111111111100000000000000000;
    //         end
    //         32'b00000000000000001111111111111110: begin
    //             Ww <= 32'b00000000000000000000000000000010;
    //         end
    //         default: begin
    //             Ww <= 32'b0;
    //         end
    //     endcase
    // end

    assign plus = plus_out;
    assign minus = minus_out;

    butterfly #(32) icantbelieveitsnot(Aa, Bb, Ww, plus_out, minus_out);
endmodule