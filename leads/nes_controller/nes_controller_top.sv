module nes_controller_top(input clk, input nes_data, output nes_latch, output nes_clock, output [9:0] leds);

	plls DataClock(clk, nes_clock); // 1 MHz
	// assign nes_clock = clk;
	
	wire [7:0] controls;
	nes_controller nc(nes_clock, nes_data, nes_latch, controls);
	
	assign leds = { 2'b00, controls };
	
endmodule