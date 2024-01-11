module nunchuk_driver(
	input clk,
	input polling_clk,
	output reg [7:0] data_read_regs [0:5],
	/* */
	output [7:0] test_out,
	/* */
	output reg scl,
   inout sda
);

	localparam IDLE = 0;
	localparam HANDSHAKE1 = 1;
	localparam HANDSHAKE2 = 2;
	localparam DUMMY_WRITE = 3;
	localparam READING = 4;
	localparam TEST_STATE = 5;
	
	localparam IDLE_CMD       = 0;
	localparam START          = 1;
	localparam STOP           = 2;
	localparam WRITE_BYTE     = 3;
	localparam READ_BYTE_ACK  = 4;
	localparam READ_BYTE_NACK = 5;
	
	localparam DEVICE_ADDR_WRITE = { 7'h52, 1'b0 };
	localparam DEVICE_ADDR_READ = { 7'h52, 1'b1 };
	
	reg [2:0] state = HANDSHAKE1;
	reg [2:0] next_state;
	
	reg [2:0] commands [0:15];
	reg [7:0] data_write [0:5];
	wire done;
	
	wire [7:0] data_read [0:5];
	
	wire [7:0] test_out_i;
	
	assign test_out = { test_out_i[5:2], state, 1'b0 };
	
	i2c_driver_new I2C(
		clk,
		polling_clk,
		commands,
		data_write,
		done,
		data_read,
		test_out_i,
		scl,
		sda
	);
	
	initial begin
		for (integer i = 0; i < 6; i = i + 1) begin
			data_read_regs[i] <= 0;
		end
	end
	
	always @(posedge clk) begin
		if (done) begin
			state <= next_state;
			for (integer i = 0; i < 6; i = i + 1) begin
				data_read_regs[i] <= data_read[i];
			end
		end
	end
	
	always_comb begin
		case (state)
			HANDSHAKE1: begin
				next_state = HANDSHAKE2;
				
				commands =
					'{ START, WRITE_BYTE, WRITE_BYTE, WRITE_BYTE, STOP, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD,
					   IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD };
						
				data_write = '{ DEVICE_ADDR_WRITE, 8'hF0, 8'h55, 8'h00, 0, 0 };
			end
			HANDSHAKE2: begin
				next_state = DUMMY_WRITE;
				
				commands =
					'{ START, WRITE_BYTE, WRITE_BYTE, WRITE_BYTE, STOP, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD,
					   IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD };
						
				data_write = '{ DEVICE_ADDR_WRITE, 8'hFB, 8'h00, 0, 0, 0 };
			end
			
			DUMMY_WRITE: begin
				next_state = READING;
				
				commands =
					'{ START, WRITE_BYTE, WRITE_BYTE, START, WRITE_BYTE, READ_BYTE_ACK, READ_BYTE_ACK, READ_BYTE_ACK,
					   READ_BYTE_ACK, READ_BYTE_ACK, READ_BYTE_NACK, STOP, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD };
				
				data_write = '{ DEVICE_ADDR_WRITE, 8'h00, DEVICE_ADDR_READ, 0, 0, 0 };
			end

			READING: begin
				next_state = READING;
				
				commands =
					'{ START, WRITE_BYTE, WRITE_BYTE, START, WRITE_BYTE, READ_BYTE_ACK, READ_BYTE_ACK, READ_BYTE_ACK,
					   READ_BYTE_ACK, READ_BYTE_ACK, READ_BYTE_NACK, STOP, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD };
				
				data_write = '{ DEVICE_ADDR_WRITE, 8'h00, DEVICE_ADDR_READ, 0, 0, 0 };
			end
			TEST_STATE: begin
				next_state = TEST_STATE;
				commands =
					'{ START, STOP, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD,
						IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD };
						
				data_write = '{ DEVICE_ADDR_WRITE, 8'hF0, 8'h55, 0, 0, 0 };
			end
			default: begin
				next_state = IDLE;
				
				commands =
					'{ IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD,
					   IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD, IDLE_CMD };
				data_write = '{ DEVICE_ADDR_WRITE, 8'h00, DEVICE_ADDR_READ, 0, 0, 0 };
			end
		endcase
	end
	
endmodule