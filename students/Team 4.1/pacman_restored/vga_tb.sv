`timescale 1ns/1ns

module vga_tb (
    output reg clk,    
	output reg hsync, 
    output reg vsync,
    output reg [3:0] red,
    output reg [3:0] green, 
    output reg [3:0] blue
);

    reg rst;
    reg btn;
    reg [9:0] switches = 10'b1000101100; 
    reg [9:0] hc_out; 
    reg [9:0] vc_out;

    wire [15:0] address;
    wire [7:0] color;
    wire [7:0] vga_data;
    wire [2:0] input_red = vga_data [7:5];
    wire [2:0] input_green = vga_data [4:2];
    wire [1:0] input_blue = vga_data [1:0];

    // vga VGA(clk, input_red, input_green, input_blue, rst, hc_out, vc_out, hsync, vsync, red, green, blue);
    vga_ram RAM(clk, address, hc_out, vc_out, color, vga_data);
    vga_graphics GRAPHICS(hc_out, vc_out, switches, btn, color, address);

    initial begin
        clk = 0;
        hc_out = 0;
        vc_out = 0;
        #420000 switches = 10'b0100001100;
		  #420000 switches = 10'b1100001000;
		  #420000 $stop;
    end

    always begin
        #1 clk = ~clk;
        if (hc_out < 800 - 1) begin
            hc_out <= hc_out + 1'b1;
        end else if (vc_out < 525 - 1) begin
            vc_out <= vc_out + 1'b1;
            hc_out <= 0;
        end else begin
            hc_out <= 0;
            vc_out <= 0;
        end
    end

endmodule