module alarmClock_top (
	input clk, // 50MHz
	input [9:0] switches, // rightmost switch that determines speed (regular vs 2x as fast)
	input ssp, // start stop pause button
	input reset, // reset button
	output [7:0] one, two, three, four, five, six
);

	wire outClk_1, outClk_2;
	
	clkDiv c1(clk, 100, !switches[0], outClk_1); // slow speed
	clkDiv c2(clk, 200, switches[0], outClk_2); // fast speed
	
	logic [15:0] t; // time in binary centi-seconds
	alarmController ac(outClk_1 | outClk_2, switches, ssp, reset, t);
	
	sevenSegmentDisplay ssd(t, one, two, three, four, five, six);

endmodule