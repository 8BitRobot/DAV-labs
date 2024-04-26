module nunchuck_translator(data_in, stick_x, stick_y, accel_x, accel_y, accel_z, z, c);
	input[7:0] data_in[5:0];
	output[7:0] stick_x, stick_y;
	output[9:0] accel_x, accel_y, accel_z;
	output z, c;
	
	assign stick_x = data_in[5];
	assign stick_y = data_in[4];
	assign accel_x[9:2] = data_in[3];
	assign accel_x[1:0] = data_in[0][1:0];
	assign accel_y[9:2] = data_in[2];
	assign accel_y[1:0] = data_in[0][5:4];
	assign accel_z[9:2] = data_in[1];
	assign accel_z[1:0] = data_in[0][3:2];
	assign z = ~data_in[0][1];
	assign c = ~data_in[0][0];
endmodule