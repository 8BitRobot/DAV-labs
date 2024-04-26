module nunchuck_translator(data_in, stick_x, stick_y, accel_x, accel_y, accel_z, z, c);
	input[7:0] data_in[5:0];
	output[7:0] stick_x, stick_y;
	output[9:0] accel_x, accel_y, accel_z;
	output z, c;
	
	
	//these may be flipped, but at least the buttons are right
	assign stick_x = data_in[0];
	assign stick_y = data_in[1];
	assign accel_x[9:2] = data_in[2];
	assign accel_x[1:0] = data_in[5][1:0];
	assign accel_y[9:2] = data_in[3];
	assign accel_y[1:0] = data_in[5][5:4];
	assign accel_z[9:2] = data_in[4];
	assign accel_z[1:0] = data_in[5][3:2];
	assign z = ~data_in[5][1];
	assign c = ~data_in[5][0];
endmodule
/*
module nunchuck_translator(data_in, stick_x, stick_y, accel_x, accel_y, accel_z, z, c);
	input[7:0] data_in[5:0];
	output[7:0] stick_x, stick_y;
	output[9:0] accel_x, accel_y, accel_z;
	output z, c;
	
	
	//these may be flipped, but at least the buttons are right
	assign stick_x = { data_in[0] };
	assign stick_y = { data_in[1] };
	assign accel_x[9:2] = 0;
	assign accel_x[1:0] = 0;
	assign accel_y[9:2] = 0;
	assign accel_y[1:0] = 0;
	assign accel_z[9:2] = 0;
	assign accel_z[1:0] = 0;
	assign z = 0;
	assign c = 0;
endmodule*/