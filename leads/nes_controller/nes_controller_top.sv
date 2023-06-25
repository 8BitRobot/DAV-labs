module nes_controller_top(clk, nes_data, nes_latch, nes_clock);
	input clk;
	input nes_data;
	output logic nes_latch;
	output logic nes_clock;
	
	logic polling_clock;
	logic clock_not_started = 1;
	
	logic [0:7] controls = 8'b0;
	
	//plls DataClock(0, clk, nes_clock); // 1 MHz
	clockDivider #(50000000) DataClock(clk, 1000000, 0, nes_clock); // 1 MHz
	clockDivider #( 1000000) PollingClock(nes_clock, 750, 0, polling_clock); // 750 Hz
	
	always @(posedge nes_clock) begin
		if (clock_not_started) begin
			clock_not_started <= 0;
			nes_latch <= 1;
		end else begin
			nes_latch <= 0;
		end
	end
endmodule