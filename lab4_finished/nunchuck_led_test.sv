module nunchuck_led_test(clk, rst, sda, scl, leds, dig0, dig1, dig2, dig3, dig4, dig5);
	input clk, rst;
	inout sda;
	output scl;
	output [9:0] leds;
	output [7:0] dig0, dig1, dig2, dig3, dig4, dig5;

	wire [7:0] stick_x, stick_y;
	wire [9:0] accel_x, accel_y, accel_z;
	wire z, c;
	nunchuckDriver UUT2(clk, sda, scl, stick_x, stick_y, accel_x, accel_y, accel_z, z, c, ~rst);
	
	wire [19:0] disp = stick_y * 1000 + stick_x;
	
	Combined_Seven_Seg(disp, 1'b0, dig0, dig1, dig2, dig3, dig4, dig5);
	
	assign leds[7:0] = stick_x;
	assign leds[9] = c;
	assign leds[8] = z;
endmodule