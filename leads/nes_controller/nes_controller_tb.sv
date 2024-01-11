`timescale 1ns/1ns
module nes_controller_tb(clk);
	output logic clk;
	logic [7:0] nes_data;
	logic nes_data_last_bit;
	logic nes_latch, nes_clock;
	
	initial begin
		clk = 0;
	end
	
	always begin
		#10 clk = ~clk;
	end
	
	always @(posedge nes_clock) begin
		if (nes_latch) begin
			nes_data <= 8'b10110001;
		end else begin
		   nes_data <= nes_data >> 1;
		end
	end
	
	assign nes_data_last_bit = nes_data[0];
	
	nes_controller_top NESController(clk, nes_data_last_bit, nes_latch, nes_clock);
endmodule