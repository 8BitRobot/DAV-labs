`timescale 1ns/1ns
module alarmClock_tb(clk);
	output reg clk;
	
	initial begin
		clk = 0;
	end
	
	always begin
		#5 clk = ~clk;
	end
	
	reg [9:0] switches = 9'b0;
	reg pause = 1;
	reg reset = 1;
	reg [7:0] segs [0:5];
	
	alarmClock_top act(clk, switches, pause, reset, segs);

endmodule