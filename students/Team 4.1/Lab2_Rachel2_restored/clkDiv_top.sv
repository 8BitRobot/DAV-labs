module clkDiv_top (
	input clk,
	output outClk
);
	
	clkDiv c(clk, 440, 0, outClk);
	
	
endmodule