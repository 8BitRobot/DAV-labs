module vga_top(
	input clk,
	input rst,
	output hsync,
	output vsync,
	output [3:0] red,
	output [3:0] green,
	output [3:0] blue
);

	wire vga_clk;
	pll vgaclk(clk, vga_clk);
	
	wire [9:0] hc_out;
	wire [9:0] vc_out;

	vga display(
		vga_clk,
		3'b111,
		3'b000,
		2'b11,
		~rst,
		hc_out,
		vc_out,
		hsync,
		vsync,
		red,
		green,
		blue
	);

endmodule