`timescale 1ns/1ns
module bonk_tb (clk, dataPort, dataClock, dig0, dig1, seg0, seg1);
	output reg clk = 0;
   output dataPort;
	output dataClock;
	output [3:0] dig0, dig1;
	output [7:0] seg0, seg1;
	
	always begin
		#10;
		clk = ~clk;
	end
	
	bonk UUT(clk, dataPort, dataClock, dig0, dig1, seg0, seg1);

endmodule