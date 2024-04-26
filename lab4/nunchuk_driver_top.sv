module nunchuk_driver_top(
	input clk,
	output scl,
	output [47:0] segs,
	inout sda
);

	wire tmc;
	wire i2c_clock;
	wire polling_clock;

	wire [7:0] test_out;
	wire [7:0] test_out_nd;

	plls p(clk, tmc); // 4 MHz
	clockDivider #(4000000) cd1(tmc, 400000, 0, i2c_clock);
	clockDivider #(400000) cd2(i2c_clock, 100, 0, polling_clock);
	
	wire [7:0] data_read_regs [0:5];
	
	nunchuk_driver nd(
		i2c_clock,
		polling_clock,
		data_read_regs,
		scl,
		sda
	);
	
	wire [7:0] stick_x, stick_y;
	wire [9:0] accel_x, accel_y, accel_z;
	wire z, c;
	
	nunchuck_translator nt(data_read_regs, stick_x, stick_y, accel_x, accel_y, accel_z, z, c);
	
	assign test_out = {  test_out_nd[7:2], 2'b0 };
	
	sevenSegDigit s1( (stick_x / 100) % 10, 0, 0, segs[47:40] );
	sevenSegDigit s2( (stick_x / 10) % 10, 0, 0, segs[39:32] );
	sevenSegDigit s3( (stick_x) % 10, 0, 0, segs[31:24] );
	sevenSegDigit s4( (stick_y / 100) % 10, 0, 0, segs[23:16] );
	sevenSegDigit s5( (stick_y / 10) % 10, 0, 0, segs[15:8] );
	sevenSegDigit s6( (stick_y) % 10, 0, 0, segs[7:0] );

endmodule