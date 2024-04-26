module pacman_top ( 
    input clk, 
    input rst,
    input btn,
    
    input [9:0] switches,
	output [9:0] leds,
	
    output [9:0] hc_out, 
    output [9:0] vc_out,

    // vga outputs
    output hsync, 
    output vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);
	assign leds = switches;
    
    wire vgaclk;
    wire [15:0] address;
    wire [7:0] color;
    wire [7:0] vga_data;
    
    // wire [2:0] input_red = switches[9:7];
    // wire [2:0] input_green = switches[6:4];
    // wire [1:0] input_blue = switches[3:2];

    // wire [2:0] input_red = color [7:5];
    // wire [2:0] input_green = color [4:2];
    // wire [1:0] input_blue = color [1:0];

    wire [2:0] input_red = vga_data [7:5];
    wire [2:0] input_green = vga_data [4:2];
    wire [1:0] input_blue = vga_data [1:0];

    clk_vga TICK(clk, vgaclk);
    vga TOCK(vgaclk, input_red, input_green, input_blue, rst, hc_out, vc_out, hsync, vsync, red, green, blue);
    vga_ram PONG(vgaclk, address, hc_out, vc_out, color, vga_data);
    graphics BOO(hc_out, vc_out, switches, btn, color, address);

endmodule

// vga_graphics -> vga_ram -> vga