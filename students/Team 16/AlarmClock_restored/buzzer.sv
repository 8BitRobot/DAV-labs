module buzzer(
	input clk,
	input reset,
	output outClk
);

reg [23:0] count;

AlarmClock_top #(50000000) UUT(clk, speed, reset, outClk);




endmodule