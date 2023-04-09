`timescale 1ns/1ns
module vga_top(clk, rst, hsync, vsync, red, green, blue);
    // input clk, rst;
    output reg clk;
    output reg rst;
    output hsync, vsync;
    output reg [3:0] red, green, blue;

    wire vga_clk;

    initial begin
        clk = 0;
        rst = 0;
    end

    always begin
        #10;
        clk = ~clk;
    end

    // pll_clk pll(clk, vga_clk);
    clockDivider #(25000000) vgaClock(clk, vga_clk, 0);
    vga disp(vga_clk, rst, hsync, vsync, red, green, blue);
endmodule

// module vga_top(clk, rst, hsync, vsync, red, green, blue);
//     input clk, rst;
//     output hsync, vsync;
//     output reg [3:0] red, green, blue;

//     wire vga_clk;

//     pll_clk pll(clk, vga_clk);
//     vga disp(vga_clk, rst, hsync, vsync, red, green, blue);
// endmodule