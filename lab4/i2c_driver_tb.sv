`timescale 1ns/1ns
module i2c_driver_tb(output out);
	localparam IDLE_CMD       = 0;
	localparam START          = 1;
	localparam STOP           = 2;
	localparam WRITE_BYTE     = 3;
	localparam READ_BYTE_ACK  = 4;
	localparam READ_BYTE_NACK = 5;

	reg clk                 = 0;
	wire [7:0] test_out;
	reg polling_clk         = 0;
	
	reg [6:0] device_addr   = 7'b1010101;
	reg [7:0] reg_addr      = 8'b11000110;
	
	reg [3:0] num_bytes     = 4;
	reg write               = 0;
	
	reg [7:0] data_to_write [0:5] = '{8'haa, 8'h00, 8'h11, 8'h22, 8'h33, 8'h44};
	
	wire [7:0] data_read [0:5];
	
	wire scl;
	wire sda;
	
	nunchuk_driver_top_test UUT(
		clk,
		test_out,
		scl,
		sda
	);
	
	always begin
		#5 clk = ~clk;
	end
endmodule