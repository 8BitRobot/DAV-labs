`timescale 1ns/1ns
module clkDiv_tb (
	output reg outClk
);

	localparam BASE_SPEED = 50000000;
	reg clock; 
	reg [$clog2(BASE_SPEED):0] speed = 12500000;
	
	logic [9:0] switches = 0;
	logic ssp = 1;
	logic reset = 1;
	wire [7:0] one, two, three, four, five, six;

	
	alarmClock_top UUT(
		clock, // 50MHz
		switches, // rightmost switch that determines speed (regular vs 2x as fast)
		ssp, // start stop pause button
		reset, // reset button
		one, two, three, four, five, six
	);
	
	initial begin // we run this block once when execution begins
		clock = 0;    // initialize the clock
		#10000 $stop; // after 10000 time ticks, we end simulation. 
	end
	always begin // always w/ no sensitivity only works in simulation

			#10 clock = ~clock; // we toggle the clock every 10 nanoseconds
									  // this runs in parallel to the initial
									  // block, so it will stop after 10000
									  // nanoseconds
	end

endmodule