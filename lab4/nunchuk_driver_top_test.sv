module nunchuk_driver_top_test(
	input clk,
	output [7:0] test_out,
	output scl,
	inout sda
);

	wire tmc;
	wire i2c_clock;
	wire polling_clock;

	wire [7:0] test_out_nd;
	
	clockDivider #(50000000) cd1(clk, 25000000, 0, i2c_clock);
	clockDivider #(25000000) cd2(i2c_clock, 500000, 0, polling_clock);
	
	wire [7:0] data_read_regs [0:5];
	
	nunchuk_driver nd(
		i2c_clock,
		polling_clock,
		data_read_regs,
		test_out_nd,
		scl,
		sda
	);
	
	assign test_out = {  test_out_nd[7:2], 2'b0 };
	
	//sevenSegDigit s1(data_read_regs[0][7:4], 0, 0, segments[15:8]);
	//sevenSegDigit s2(data_read_regs[0][3:0], 0, 0, segments[7:0]);

endmodule