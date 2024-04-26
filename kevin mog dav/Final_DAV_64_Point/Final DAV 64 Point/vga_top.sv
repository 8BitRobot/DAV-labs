`timescale 1 ns/1 ns

module vga_top(
		output reg hsync,			//horizontal sync out
		output reg vsync,			//vertical sync out
		output reg [3:0] red,	//red vga output
		output reg [3:0] green, //green vga output
		output reg [3:0] blue	//blue vga output
	);
	
	reg ADC_clock = 0;
	reg board_clock = 0;
	reg vga_clock = 0;
	
	always begin
		#100
		ADC_clock = ~ADC_clock;
	end
	
	always begin
		#20
		board_clock = ~board_clock;
	end
	
	always begin
		#40
		vga_clock = ~vga_clock;
	end
	
	//DAVMicrophone UUT (board_clock, ADC_clock, 1, hsync, vsync, red, green, blue, vga_clock);
	
	initial begin
		#100000000;
		$stop;
	end
	//VGA_Clk PLL(board_clk, vgaclk);
endmodule