// `timescale 1ns/1ns
// module vga_top(clk, rst, hsync, vsync, red, green, blue);
//     // input clk, rst;
//     output reg clk;
//     output reg rst;
//     output hsync, vsync;
//     output reg [3:0] red, green, blue;

//     wire vga_clk;

//     initial begin
//         clk = 0;
//         rst = 1;
//     end

//     always begin
//         #10;
//         clk = ~clk;
//     end

//     clockDivider #(50000000) vgaClock(clk, vga_clk, 0);
    
//     wire [9:0] hc, vc;
//     wire blanking;
//     assign blanking = (hc > 640 || vc > 480);

//     wire [7:0] dataOut;

//     // wire [7:0] dataOut;
//     memory_controller sheep(vga_clk, hc, vc, dataOut);
    
//     wire [2:0] input_red, input_green;
//     wire [1:0] input_blue;

//     assign input_red = dataOut[7:5];
//     assign input_green = dataOut[4:2];
//     assign input_blue = dataOut[1:0];

//     vga disp(vga_clk, input_red, input_green, input_blue, rst, hc, vc, hsync, vsync, red, green, blue);
// endmodule

// module vga_top(clk, rst, hsync, vsync, red, green, blue);
//     input clk, rst;
//     output hsync, vsync;
//     output [2:0] red, green;
//     output [1:0] blue;

//     wire vga_clk;
//     pll_clk pll(clk, vga_clk);

//     wire [9:0] hc, vc;
//     localparam COLS = 799;
// 	localparam ROWS = 524;

//     // reg [11:0] dataOut = 0;

// 	// always @(posedge vga_clk) begin
// 	// 	if (rst == 0) begin
// 	// 		hc <= 0;
// 	// 		vc <= 0;
// 	// 	end else
// 	// 	begin
// 	// 		if (hc == COLS) begin
// 	// 			hc <= 0;
// 	// 			if (vc == ROWS) begin
// 	// 				vc <= 0;
// 	// 			end else begin
// 	// 				vc <= vc + 1;
// 	// 			end
// 	// 		end else begin
// 	// 			hc <= hc + 1;
// 	// 		end
// 	// 	end
//     // end

//     // clk, x, y, address, dataIn, dataOut)
//     // input: clk, counts; outputs: address, data. only for writing
//     wire [7:0] dataIn;
//     wire [7:0] dataOut;
//     wire [9:0] address;
//     assign address = (hc / 20) + (vc / 20) * 32;
    
//     // graphicscontroller graphicdesignismypassion(vga_clk, hc, vc, dataIn, address);
//     // input: clk, addrIn, dataIn, addrOut; output: dataOut
//     memory_controller memes(vga_clk, address, dataIn, address, dataOut);

//     // assign dataOut = address[7:0];

//     wire [2:0] input_red, input_green;
//     wire [1:0] input_blue;
//     assign input_red = dataOut[7:5];
//     assign input_green = dataOut[4:2];
//     assign input_blue = dataOut[1:0];
//     // we need to give this a red, green, and blue from memory_controller
//     // dataOut
//     vga disp(vga_clk, input_red, input_green, input_blue, rst, hc, vc, hsync, vsync, red, green, blue);
// endmodule

module vga_top(clk, rst, hsync, vsync, red, green, blue);
    input clk, rst;
    output hsync, vsync;
    output [3:0] red, green, blue;

    wire vga_clk;
    pll_clk pll(clk, vga_clk);
    
    wire [9:0] hc, vc;
    wire [4:0] x, y;
    assign x = hc / 20;
    assign y = vc / 20;
    wire [7:0] dataOut;

    wire [9:0] addrWrite;
    wire [7:0] dataIn;

    graphicscontroller graphicdesignismypassion(vga_clk, x, y, dataIn, addrWrite);
    memory_controller sheep(vga_clk, addrWrite, dataIn, hc, vc, dataOut);
    
    wire [2:0] input_red, input_green;
    wire [1:0] input_blue;

    assign input_red = dataOut[7:5];
    assign input_green = dataOut[4:2];
    assign input_blue = dataOut[1:0];

    vga disp(vga_clk, input_red, input_green, input_blue, rst, hc, vc, hsync, vsync, red, green, blue);
endmodule