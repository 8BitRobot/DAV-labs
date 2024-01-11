`timescale 1ns/1ns

module clock_divider_tb(output logic outClk_test);

logic clk_test;
logic reset_test;
logic [25:0] speed_test;

clock_divider TEST(clk_test, reset_test, speed_test, outClk_test);

initial begin
 // we run this block once when execution begins
   clk_test = 'd0;    // initialize the clock
	reset_test = 'd1;
	speed_test = 'd1000000;
	#100000 $stop; // after 10000 time ticks, we end simulation. 
end

always begin // always w/ no sensitivity only works in simulation

      #10 clk_test = ~clk_test; // we toggle the clock every 10 nanoseconds
	                    // this runs in parallel to the initial
                          // block, so it will stop after 10000
                          // nanoseconds
end

endmodule