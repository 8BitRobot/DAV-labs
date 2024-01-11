module i2c_driver_new(
	input clk,
	input polling_clk,
	input [2:0] commands [0:15],
	input [7:0] data_write [0:5],
	output reg done,
	output reg [7:0] data_read [0:5],
	/* */
	output [7:0] test_out,
	/* */
	output reg scl,
    inout sda
);
	
	reg  sda_in = 0;
	wire sda_out;
	reg  sda_write_enable;

	IOBuffer sdaTristateBuffer(sda_in, sda_write_enable, sda_out, sda);
	
	localparam IDLE       = 0;
	localparam RUNNING    = 1;
	
	reg state = IDLE;
	reg next_state;
	
	localparam IDLE_CMD       = 0;
	localparam START          = 1;
	localparam STOP           = 2;
	localparam WRITE_BYTE     = 3;
	localparam READ_BYTE_ACK  = 4;
	localparam READ_BYTE_NACK = 5;
	localparam NACK_STOP      = 6;
	
	reg [2:0] current_command = START;
	reg [2:0] next_command;
	
	reg [3:0] commands_done = 0;
	reg [3:0] commands_done_d;
	
	reg [1:0] polling_clk_sr;
	reg       polling_clk_pulsed;
	
	reg [1:0] subbit = 0;
	reg [1:0] subbit_d;
	
	assign test_out = { commands_done[1:0], current_command, state, 2'b0 };
	
	reg [2:0] bytes_written = 0;
	reg [2:0] bytes_written_d;
	reg [8:0] current_byte_to_write;
	
	reg [2:0] bytes_read = 0;
	reg [2:0] bytes_read_d;
	reg [7:0] current_byte_being_read;
	reg bit_ready;
	reg byte_read;
	
	reg [3:0] bit_cnt = 0;
	reg [3:0] bit_cnt_d;

	reg [1:0] state_sr = 2'b00;
	reg failed = 0;
	reg failed_d;

	reg acked = 0;
	reg acked_d;
	
	always @(posedge clk) begin
		subbit <= subbit_d;
		polling_clk_sr <= { polling_clk_sr[0], polling_clk };
		
		state <= next_state;
		state_sr <= { state_sr[0], next_state };
		
		commands_done <= commands_done_d;
		current_command <= next_command;

		acked <= acked_d;
		
		bit_cnt <= bit_cnt_d;
		bytes_written <= bytes_written_d;
		
		bytes_read <= bytes_read_d;
		failed <= failed_d;
		
		if (bit_ready) begin
			current_byte_being_read[bit_cnt - 1] <= sda_out;
		end
		
		if (byte_read) begin
			data_read[bytes_read] <= current_byte_being_read;
		end
	end
	
	always_comb begin
		done = state_sr[1] == RUNNING && state_sr[0] == IDLE && ~failed;
	
		if (state == IDLE || current_command == IDLE_CMD) subbit_d = 0;
		else subbit_d = subbit + 1;
		
		scl = (subbit == 1 || subbit == 2);
		
		current_byte_to_write = { data_write[bytes_written], 1'bz};
		
		polling_clk_pulsed = (polling_clk_sr == 2'b01);
		
		bit_ready =
			state == RUNNING &&
			(current_command == READ_BYTE_ACK || current_command == READ_BYTE_NACK) &&
			subbit == 1 &&
			bit_cnt != 0;
			
		byte_read = 
			state == RUNNING &&
			(current_command == READ_BYTE_ACK || current_command == READ_BYTE_NACK) &&
			subbit == 3 &&
			bit_cnt == 0;
		
		if (state == IDLE) begin
			acked_d = 0;
			commands_done_d = 0;
			sda_in = 1'bz;
			sda_write_enable = 0;
			bit_cnt_d = 0;
			bytes_written_d = 0;
			bytes_read_d = 0;
			
			next_command = START;
		
			if (polling_clk_pulsed) begin
				next_state = RUNNING;
				failed_d = 0;
			end else begin
				next_state = state;
				failed_d = failed;
			end
		end else begin
			if (current_command == IDLE_CMD) next_state = IDLE;
			else next_state = state;
			
			case (current_command)
				IDLE_CMD: begin
					acked_d = acked;
					commands_done_d = 0;
					next_command = IDLE_CMD;
					bit_cnt_d = 0;
					bytes_written_d = 0;
					bytes_read_d = 0;
					sda_in = 1'bz;
					sda_write_enable = 1;
					failed_d = failed;
				end
				
				START: begin
					acked_d = acked;
					sda_write_enable = 1;
					bytes_written_d = bytes_written;
					bytes_read_d = bytes_read;
					failed_d = failed;
				
					if (subbit == 0 || subbit == 1) begin
						sda_in = 1;
					end else begin
						sda_in = 0;
					end
				
					if (subbit == 3) begin
						if (
							commands[commands_done + 1] == WRITE_BYTE ||
							commands[commands_done + 1] == READ_BYTE_ACK ||
							commands[commands_done + 1] == READ_BYTE_NACK
						) begin
							bit_cnt_d = 8;
						end else begin
							bit_cnt_d = bit_cnt;
						end
						
						next_command = commands[commands_done + 1];
						commands_done_d = commands_done + 1;
					end else begin
						next_command = current_command;
						commands_done_d = commands_done;
						bit_cnt_d = bit_cnt;
					end
				end
				
				WRITE_BYTE: begin
					if (bit_cnt == 0) begin
						sda_write_enable = 0;
					end else begin
						sda_write_enable = 1;
					end
					
					sda_in = current_byte_to_write[bit_cnt];
					bytes_read_d = bytes_read;
					
					if (subbit == 2 && bit_cnt == 0) begin
						bit_cnt_d = bit_cnt;
						commands_done_d = commands_done;
						next_command = current_command;
						bytes_written_d = bytes_written;
						failed_d = failed;
						acked_d = (sda_out == 0);
					end	else if (subbit == 3) begin
						acked_d = acked;

						if (bit_cnt == 0) begin
						
							commands_done_d = commands_done + 1;
							bytes_written_d = bytes_written + 1;
							
							if (acked) begin
								if (
									commands[commands_done + 1] == WRITE_BYTE ||
									commands[commands_done + 1] == READ_BYTE_ACK ||
									commands[commands_done + 1] == READ_BYTE_NACK
								) begin
									bit_cnt_d = 8;
								end else begin
									bit_cnt_d = bit_cnt;
								end
								
								next_command = commands[commands_done + 1];
								failed_d = failed;
							end else begin
								bit_cnt_d = 0;
								next_command = NACK_STOP;
								failed_d = 1;
							end
						end else begin
							bit_cnt_d = bit_cnt - 1;
							bytes_written_d = bytes_written;
							commands_done_d = commands_done;
							next_command = current_command;
							failed_d = failed;
						end
					end else begin
						bit_cnt_d = bit_cnt;
						commands_done_d = commands_done;
						next_command = current_command;
						bytes_written_d = bytes_written;
						failed_d = failed;
						acked_d = acked;
					end
				end
				
				READ_BYTE_ACK: begin
					acked_d = acked;

					if (bit_cnt == 0) begin
						sda_write_enable = 1;
					end else begin
						sda_write_enable = 0;
					end
					
					sda_in = 0;
					bytes_written_d = bytes_written;
					failed_d = failed;
					
					if (subbit == 3) begin
						if (bit_cnt == 0) begin
						
							commands_done_d = commands_done + 1;
							bytes_read_d = bytes_read + 1;
							
							if (
								commands[commands_done + 1] == WRITE_BYTE ||
								commands[commands_done + 1] == READ_BYTE_ACK ||
								commands[commands_done + 1] == READ_BYTE_NACK
							) begin
								bit_cnt_d = 8;
							end else begin
								bit_cnt_d = bit_cnt;
							end
							
							next_command = commands[commands_done + 1];
						end else begin
							bit_cnt_d = bit_cnt - 1;
							bytes_read_d = bytes_read;
							commands_done_d = commands_done;
							next_command = current_command;
						end
					end else begin
						bit_cnt_d = bit_cnt;
						commands_done_d = commands_done;
						next_command = current_command;
						bytes_read_d = bytes_read;
					end
				end
				
				READ_BYTE_NACK: begin
					acked_d = acked;

					if (bit_cnt == 0) begin
						sda_write_enable = 1;
					end else begin
						sda_write_enable = 0;
					end
					
					sda_in = 1;
					bytes_written_d = bytes_written;
					failed_d = failed;
					
					if (subbit == 3) begin
						if (bit_cnt == 0) begin
							bit_cnt_d = bit_cnt;
							next_command = NACK_STOP;
							commands_done_d = commands_done + 1;
							bytes_read_d = bytes_read + 1;
						end else begin
							bit_cnt_d = bit_cnt - 1;
							bytes_read_d = bytes_read;
							commands_done_d = commands_done;
							next_command = current_command;
						end
					end else begin
						bit_cnt_d = bit_cnt;
						commands_done_d = commands_done;
						next_command = current_command;
						bytes_read_d = bytes_read;
					end
				end
				
				STOP: begin
					acked_d = acked;

					sda_write_enable = 1;
					
					bytes_written_d = bytes_written;
					bytes_read_d = bytes_read;
					bit_cnt_d = 0;
					failed_d = failed;
				
					if (subbit == 0 || subbit == 1) begin
						sda_in = 0;
					end else begin
						sda_in = 1;
					end
				
					if (subbit == 3) begin
						next_command = commands[commands_done + 1];
						commands_done_d = commands_done + 1;
					end else begin
						next_command = current_command;
						commands_done_d = commands_done;
					end
				end
				
				NACK_STOP: begin
					acked_d = acked;

					sda_write_enable = 1;
					
					bytes_written_d = 0;
					bytes_read_d = 0;
					bit_cnt_d = 0;
					failed_d = failed;
					
					if (subbit == 0 || subbit == 1) begin
						sda_in = 0;
					end else begin
						sda_in = 1;
					end
					
					if (subbit == 3) begin
						next_command = IDLE_CMD;
						commands_done_d = 0;
					end else begin
						next_command = current_command;
						commands_done_d = commands_done;
					end
				end
				
				default: begin
					acked_d = acked;
					commands_done_d = 0;
					next_command = commands[0];
					sda_in = 1'bz;
					sda_write_enable = 0;
					bit_cnt_d = 0;
					bytes_written_d = 0;
					bytes_read_d = 0;
					failed_d = 0;
				end
			endcase
		end
	end

endmodule