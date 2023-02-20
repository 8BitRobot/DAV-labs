`timescale 1ns/1ns
module bonk_tb (clk, dataBonk, dataOut);
	output reg clk = 0;
    output dataBonk;
	output dataOut;
	
	always begin
		#1;
		clk = ~clk;
	end
	
	bonk UUT(clk, dataBonk, dataOut);
    
endmodule