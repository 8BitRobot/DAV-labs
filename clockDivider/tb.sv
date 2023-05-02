module tb(output new_clk);
	reg clk = 0;
	
	always begin
		#10 clk = ~clk;
	end
	
	clockDivider cd(clk, new_clk);
endmodule