`timescale 1ns/1ns

module tb_lab3(output reg clk100, output reg clk200);
	reg clock = 0;
	integer i;
	clockDivider100hz clk1(clock, clk100);
	clockDivider200hz clk2(clock, clk200);

	always begin
		#20 clock = ~clock;
	end
	
	initial begin
		#10000 $stop;
	end
endmodule