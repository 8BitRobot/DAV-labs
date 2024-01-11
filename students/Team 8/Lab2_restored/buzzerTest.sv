module buzzerTest (clk, outClk);

	input clk;
	logic [$clog2(1000000)-1:0] speed = 1000;
	logic reset = 0;
	output logic outClk;
	
	clockDivider divider (clk, speed, reset, outClk);
	
endmodule