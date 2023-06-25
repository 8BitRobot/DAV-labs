`timescale 1ns/1ns
module nes_controller_tb(clk);
	output logic clk;
	logic nes_data, nes_latch, nes_clock;
	
	initial begin
		clk = 0;
	end
	
	always begin
		#10 clk = ~clk;
	end
	
	nes_controller_top NESController(clk, nes_data, nes_latch, nes_clock);
endmodule