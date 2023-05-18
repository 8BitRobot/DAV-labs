module big_top_fr(clk, rst, newPiece, threshold, dataPort, seg, leds, hsync, vsync, red, green, blue);
    //toptoptop
    input clk, rst;
    input newPiece;
	 input [3:0] threshold;
    inout dataPort;
    output [7:0] seg [5:0];
    // output reg [9:0] leds = 10'b0000100000;
    output [0:9] leds;
    output hsync, vsync;
    output [3:0] red, green, blue;

    wire [2:0] controls;
    wire [11:0] scream;
    wire gameclk;
	 
	 assign leds = {6'b0, threshold};

    // dataClock is 1 MHz, vga_clk is 25 MHz
    plls pll(clk, dataClock, vga_clk);

    clockDivider #(1000000) slowasfuck(dataClock, 60, 0, gameclk);
    // rip shiftry
    vga_top whenthemoduleisabottom(vga_clk, gameclk, rst, ~newPiece, controls, hsync, vsync, red, green, blue, _, seg); // prem said this
    bongoTranslator plumbum(clk, dataClock, threshold, dataPort, controls, scream);
endmodule