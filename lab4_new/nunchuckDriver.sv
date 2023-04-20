module nunchuckDriver(clk, rst, scl, sda);
	input clk;
	input rst;
	output scl;
	output sda;

	
	clockDivider #(400000) i2c_clock(clk, i2c_clk, rst);
	clockDivider #(70) polling_clock(clk, poll_clk, rst);
	
	I2C uut(i2c_clk, 0, poll_clk, scl, sda);

endmodule