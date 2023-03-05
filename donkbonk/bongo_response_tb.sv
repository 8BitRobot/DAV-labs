`timescale 1ns/1ns
module bongo_response_tb (clk, dataPort, dig0, dig1, dataOut, dataClock, readClock, sendingPoll);
	output reg clk = 0;
    output dataPort;
	output dataOut;
	output [7:0] dig0;
	output [7:0] dig1;
	output dataClock;
	output readClock;
	output [1:0] sendingPoll;
	
	always begin
		#1;
		clk = ~clk;
	end
	
	bonk UUT(clk, dataPort, dig0, dig1, dataOut, dataClock, readClock, sendingPoll);

endmodule