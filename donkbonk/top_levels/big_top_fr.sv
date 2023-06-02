module big_top_fr(clk, rst, dataPort, hsync, vsync, red, green, blue, leds);
    //toptoptop
    input clk;
    input rst;
	// input [3:0] threshold;
    inout dataPort;
    // output reg [9:0] leds = 10'b0000100000;
    output hsync, vsync;
    output [3:0] red, green, blue;
    output [9:0] leds;

    assign leds[3:0] = controls;

    wire [3:0] controls;
    wire [11:0] scream;
    wire gameclk;
	 
	// assign leds = {6'b0, threshold};

    // dataClock is 1 MHz, vga_clk is 25 MHz
    plls pll(clk, dataClock, vga_clk);

    clockDivider #(1000000) slowasfuck(dataClock, 60, 0, gameclk);
    // rip shiftry
    vga_top whenthemoduleisabottom(vga_clk, gameclk, {rst, ~controls[3]}, controls[2:0], hsync, vsync, red, green, blue); // prem said this
    bongoTranslator plumbum(clk, dataClock, threshold, dataPort, controls);
endmodule