`timescale 1ns/1ns

module AlarmClock_tb(
	output outClk
);

	reg clk;
	reg [19:0] speed;
	reg reset;
	
	AlarmClock_top #(50000000) UUT(clk, speed, reset, outClk);
	
	//create a 1 bit clock register
	initial begin 			// we run this block once when execution begins
			clk = 0;    	// initialize the clock
			speed = 20'b11110100001001000000;
			reset = 0;
			#100000 $stop; 	// after 10000 time ticks, we end simulation. 
	end
	
	always begin // always w/ no sensitivity only works in simulation
			#10 clk = ~clk;	// we toggle the clock every 10 nanoseconds
									// this runs in parallel to the initial
									// block, so it will stop after 10000
									// nanoseconds
	end
endmodule