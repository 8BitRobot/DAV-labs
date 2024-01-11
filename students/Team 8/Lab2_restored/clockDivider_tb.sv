`timescale 1ns/1ns

module clockDivider_tb (output outClk);

	logic clk;
	logic [$clog2(1000000)-1:0] speed;
	logic reset;
	
	clockDivider UUT(clk, speed, reset, outClk);
	
	initial begin
		clk = 0;
		speed = 1000000;
		reset = 0;
		#1000000 $stop;
		
	end
	
	always begin
		#10 clk = ~clk;
		
	end
	
endmodule