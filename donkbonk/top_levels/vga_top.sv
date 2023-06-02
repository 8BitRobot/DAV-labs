module vga_top(clk, gameclk, rsts, controls, hsync, vsync, red, green, blue);
    input clk, gameclk;
    input [1:0] rsts;
    input [2:0] controls;
    output hsync, vsync;
    output [3:0] red, green, blue;
    
    wire [9:0] hc, vc;
    wire [6:0] x, y;
    assign x = hc / 20; // hc is 0 to 799
    assign y = vc / 20; // vc is 0 to 524
    wire [7:0] dataOut;

    wire [9:0] addrWrite;
    wire [7:0] dataIn;

    graphicscontroller graphicdesignismypassion(gameclk, rsts[0], x, y, dataIn, controls, addrWrite);
    memory_controller sheep(clk, addrWrite, dataIn, hc, vc, dataOut);
    
    wire [2:0] input_red, input_green;
    wire [1:0] input_blue;

    assign input_red = dataOut[7:5];
    assign input_green = dataOut[4:2];
    assign input_blue = dataOut[1:0];

    vga disp(clk, input_red, input_green, input_blue, rsts[1], hc, vc, hsync, vsync, red, green, blue);
endmodule

// `timescale 1ns/1ns
// module vga_top(clk, rst, newPiece, hsync, vsync, red, green, blue);
//     output reg clk, rst;
// 	output reg newPiece;
//     output hsync, vsync;
//     output [3:0] red, green, blue;
	 
// 	 initial begin
// 		clk = 0;
// 		rst = 1;
// 		newPiece = 1;
// 	 end
	 
// 	 always begin
// 		#20
// 		clk = ~clk;
// 	 end
    
//     wire [9:0] hc, vc;
//     wire [6:0] x, y;
//     assign x = hc / 20; // hc is 0 to 799
//     assign y = vc / 20; // vc is 0 to 524
//     wire [7:0] dataOut;

//     wire [9:0] addrWrite;
//     wire [7:0] dataIn;
	 
// 	 reg [1:0] newPiece_sr;
// 	 wire newPieceTrigger = newPiece_sr == 2'b01;
	 
// 	 always @(posedge clk) begin
// 	    newPiece_sr = {newPiece_sr[0], newPiece};
// 	 end

//     graphicscontroller graphicdesignismypassion(clk, newPieceTrigger, x, y, dataIn, addrWrite);
//     // memory_controller sheep(clk, addrWrite, dataIn, hc, vc, dataOut);
    
//     wire [2:0] input_red, input_green;
//     wire [1:0] input_blue;

//     assign input_red = dataOut[7:5];
//     assign input_green = dataOut[4:2];
//     assign input_blue = dataOut[1:0];

//     vga disp(clk, input_red, input_green, input_blue, rst, hc, vc, hsync, vsync, red, green, blue);
// endmodule
