module vga_top(
	input clk,
	input rst,
	output hsync,
	output vsync,
	output reg [3:0] red,
	output reg [3:0] green,
	output reg [3:0] blue
);

logic vgaclk;
pll vga_clockDivider(.inclk0 (clk), .c0 (vgaclk));

logic [9:0] hc_out, vc_out;

logic [2:0] input_red;
logic [2:0] input_green;
logic [1:0] input_blue;

initial begin
	input_red = 'b001;
	input_green = 'b111;
	input_blue = 'b00;
end

// instantiate vga display module
vga display(
	vgaclk,
	input_red, input_green, input_blue,
	rst,
	hc_out, vc_out, hsync, vsync,
	red, green, blue
);

endmodule