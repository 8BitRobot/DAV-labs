`timescale 1ns/1ns
module alarmClock_tb (
	output [7:0] one, two, three, four, five, six
);

	alarmController ac(clk, switches, ssp, reset, t_d);

endmodule