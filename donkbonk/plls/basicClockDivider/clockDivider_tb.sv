`timescale 1ns/1ns

module clockDivider_tb (clk);
	output reg clk = 1;
	/*output outClk;
	wire outClk;
	
	initial begin
		clk = 0;
	end

	always begin
		#5 clk = ~clk;
	end
	
	clockDivider #(BASE_SPEED=100) cd(clk, 1, 0, outClk);*/
endmodule