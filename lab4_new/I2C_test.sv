`timescale 1ns/1ns
module I2C_test(clk, i2c_clk, rst, scl, sda);
	output reg clk, rst;
	output i2c_clk, scl, sda;
	
	initial begin
		clk = 0;
		rst = 0;
	end
	
	always begin
		#10
		clk = ~clk;
	end
endmodule