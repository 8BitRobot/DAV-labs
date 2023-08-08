module clockDivider_tb(clk);
	output reg clk;
	wire outClk;
	wire reset = 0;
	
	initial begin
		clk = 0;
		#10000 $stop;
	end
	
	always begin
		#5 clk = ~clk;
	end
	
	clockDivider #(16) cd (clk, 4, reset, outClk);
endmodule