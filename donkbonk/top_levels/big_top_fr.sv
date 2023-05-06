module big_top_fr(clk, rst, newPiece, dataPort, seg0, seg1, leds, hsync, vsync, red, green, blue);
    //toptoptop
    input clk, rst;
	 input newPiece;
    inout dataPort;
    output [7:0] seg0, seg1;
    output reg [9:0] leds = 10'b0000100000;
    output hsync, vsync;
    output [3:0] red, green, blue;

    wire [1:0] controls;

    
    
    plls pll(clk, dataClock, vga_clk);

    sevenSegDispLetters shiftry(controls[1], controls[0], seg1, seg0);
    vga_top whenthemoduleisabottom(vga_clk, rst, ~newPiece, controls, hsync, vsync, red, green, blue); // prem said this
    bongoTranslator plumbum(clk, dataClock, dataPort, controls);
endmodule