module vga_top_top
(
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue,
    output hsync,
    output vsync
);
	
	reg clk = 0;
	
	always #1 clk = ~clk;

	wire [$clog2(526)-1:0]  vc_count;
	wire [$clog2(801)-1:0]  hc_count;
		
   vga VGA(
        .vgaclk(clk),
        // input [2:0] input_red,
        // input [2:0] input_green,
        // input [1:0] input_blue,
        // input rst,
        .hc_out(hc_count),
        .vc_out(vc_count),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );


endmodule