module nunchuk_driver_top(
	input clk,
	output [7:0] test_out,
	output scl,
	inout sda
);

	wire tmc;
	wire i2c_clock;
	wire polling_clock;

	wire [7:0] test_out_nd;

	plls p(clk, tmc); // 4 MHz
	clockDivider #(4000000) cd1(tmc, 400000, 0, i2c_clock);
	clockDivider #(400000) cd2(i2c_clock, 100, 0, polling_clock);
	
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

endmodule