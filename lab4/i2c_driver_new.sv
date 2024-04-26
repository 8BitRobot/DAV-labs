module i2c_driver_new(
	input clk, 								 // Input clock that drives the subbit counter
	input polling_clk, 					 // Input clock whose posedge signifies a new
												 // "poll" of the nunchuck
	input [2:0] commands [0:15],		 // The I2C commands to execute (e.g. START,
												 // WRITE_BYTE, etc.)
	input [7:0] data_write [0:5],		 // The data we want to write with each WRITE_BYTE
												 // command
	output reg done,						 // A 1-bit flag that goes high if a command
												 // completes successfully
	output reg [7:0] data_read [0:5], // The data that was read from the nunchuck in
												 // READ_BYTE commands
	output reg scl,						 // SCL that gets fed to the nunchuck
   inout sda								 // SDA that goes between the nunchuck and FPGA
);
	
	/* Tri-state buffer ports */
	reg  sda_in = 0;
	wire sda_out;
	reg  sda_write_enable;
	
	IOBuffer sdaTristateBuffer(sda_in, sda_write_enable, sda_out, sda);
	
	// your I2C driver can either be running (currently acting on
	// commands) or idle (in between polls)
	localparam IDLE       = 0;
	localparam RUNNING    = 1;
	
	reg state = IDLE;
	reg next_state;
	
	// these are the commands your I2C driver will have to respond to	
	localparam IDLE_CMD       = 0;
	localparam START          = 1;
	localparam STOP           = 2;
	localparam WRITE_BYTE     = 3;
	localparam READ_BYTE_ACK  = 4;
	localparam READ_BYTE_NACK = 5;
	localparam NACK_STOP      = 6;
	
	reg [2:0] current_command = START;
	reg [2:0] next_command;
	
	// the number of commands that have been completed so far
	reg [3:0] commands_done = 0;
	reg [3:0] commands_done_d;
	
	// helper reg for your polling clock, which we will use to capture
	// its posedges
	reg [1:0] polling_clk_sr;
	
	// your subbit counter
	reg [1:0] subbit = 0;
	reg [1:0] subbit_d;
	
	// helper regs to track which byte needs to be written next
	reg [2:0] bytes_written = 0;
	reg [2:0] bytes_written_d;
	reg [8:0] current_byte_to_write;
	
	// helper regs to track where to store the next byte that we read
	reg [2:0] bytes_read = 0;
	reg [2:0] bytes_read_d;
	reg [7:0] current_byte_being_read;
	
	// 1-bit flags that we use to record bits and bytes as the
	// nunchuck sends them
	reg bit_ready;
	reg byte_read;
	
	// the number of bits that are left to be written in one WRITE
	// command
	reg [3:0] bit_cnt = 0;
	reg [3:0] bit_cnt_d;

	// we use these to calculate whether the poll was completed
	// successfully, i.e. whether `done` should be driven high
	// at the end of a poll
	reg [1:0] state_sr = 2'b00;
	reg failed = 0;
	reg failed_d;

	// after each command that requires acknowledgement, we track
	// whether or not it was ACKed in this register
	reg acked = 0;
	reg acked_d;
	
	// sequential block -- update all of our registers and conditionally
	// update the read bytes
	always @(posedge clk) begin
	
		/* TODO(1.1.1):
		You need to update the following registers every clock cycle:
		  - subbit
		  - polling_clk_sr
		  - state
		  - state_sr
		
		Here, `polling_clk_sr` and `state_sr` are shift registers that should
		enable us to capture the edge of `polling_clk` and `state`,
		respectively.
		*/
		
		subbit <= subbit_d;
		polling_clk_sr <= { polling_clk_sr[0], polling_clk };
		
		state <= next_state;
		state_sr <= { state_sr[0], next_state };
		
		commands_done <= commands_done_d;
		current_command <= next_command;
		bit_cnt <= bit_cnt_d;
		
		bytes_written <= bytes_written_d;

		acked <= acked_d;
		
		bytes_read <= bytes_read_d;
		failed <= failed_d;
		
		/* TODO(1.4.5):
		Using the flags you just created, do the following:
		- If a bit is ready, store the current bit (read from `sda_out`) into
		  `current_byte_being_read` at the appropriate position. The index at
		  which to store this byte will be given by `(bit_cnt - 1)`.
		- If the whole byte is ready, store that byte into `data_read`, this
		  time using `bytes_read` as your index.
		*/
		if (bit_ready) begin
			current_byte_being_read[bit_cnt - 1] <= sda_out;
		end
		
		if (byte_read) begin
			data_read[bytes_read] <= current_byte_being_read;
		end
	end
	
	always_comb begin	
		/* TODO(1.1.2):
		Determine the new value of the subbit counter based on the current value:
		- If the current state is IDLE, subbit_d should be reset to 0.
		- If the current command is IDLE_CMD, subbit_d should be reset to 0.
		- Otherwise, we should increment subbit, resetting to 0 when
		  subbit is 3 (the max value).
		*/
		
		if (state == IDLE || current_command == IDLE_CMD) subbit_d = 0;
		else subbit_d = subbit + 1;
		
		done = state_sr[1] == RUNNING && state_sr[0] == IDLE && ~failed;
		
		scl = (subbit == 1 || subbit == 2);
		
		// Here, we get the next unwritten byte from `data_write` by using the
		// number of bytes written so far as an index into the `data_write` array
		current_byte_to_write = data_write[bytes_written];
		
		/* TODO(1.4.3):
		Design a logic expression for `bit_ready`, a 1-bit flag that is high only when
		a new bit can be read from the current byte being read in a READ_BYTE command.
		The requirements for a bit being ready are:
		- The I2C driver is currently RUNNING
		- The current command is one of the two READ_BYTE commands
		- We're in the middle of an SCL high-phase where the bit should be stable
		  (i.e. the subbit is 2)
		- The peripheral is currently sending a bit (i.e. the bit count is nonzero)
		*/
		bit_ready =
			state == RUNNING &&
			(current_command == READ_BYTE_ACK || current_command == READ_BYTE_NACK) &&
			subbit == 2 &&
			bit_cnt != 0;
			
		/* TODO(1.4.4):
		Design a logic expression for `byte_read`, a 1-bit flag that is high only when
		a full byte has been successfully read in a READ_BYTE command.
		The requirements for a byte having being read are:
		- The I2C driver is currently RUNNING
		- The current command is one of the two READ_BYTE commands
		- The FPGA just finished sending the ACK or NACK (i.e. subbit is 3 and bit count
		  is zero)
		*/
		byte_read = 
			state == RUNNING &&
			(current_command == READ_BYTE_ACK || current_command == READ_BYTE_NACK) &&
			subbit == 3 &&
			bit_cnt == 0;
		
		if (state == IDLE) begin
			// If the state is idle, keep everything at the reset state.
			// Note that we set next_command to be START because this will
			// always be the first command we execute.
			acked_d = 0;
			commands_done_d = 0;
			sda_in = 1'bz;
			sda_write_enable = 0;
			bit_cnt_d = 0;
			bytes_written_d = 0;
			bytes_read_d = 0;
			
			next_command = START;
		
			if (polling_clk_sr == 2'b01) begin
				next_state = RUNNING;
				failed_d = 0;
			end else begin
				next_state = state;
				failed_d = failed;
			end
		end else begin
			// We reset the state to IDLE if the current command is IDLE_CMD,
			// which indicates that our command list has no more commands to
			// execute.
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
					bytes_written_d = bytes_written;
					bytes_read_d = bytes_read;
					failed_d = failed;
					
					/* TODO(1.2.1):
					Fill out the values corresponding to the START command.
					We've filled the following out for you above:
					- `acked`         remains as-is, i.e. `acked_d` takes on the value
						of `acked`
					- `bytes_written` remains as-is
					- `bytes_read`    remains as-is
					- `failed`        remains as-is
					
					You must ensure that:
					- SDA writing should be ENABLED (drive `sda_write_enable` for this)
					- The appropriate start signal value should be written to `sda_in` --
					  it's determined based on the current subbit!
					*/
					
					sda_write_enable = 1;
				
					if (subbit == 0 || subbit == 1) begin
						sda_in = 1;
					end else begin
						sda_in = 0;
					end
				
					if (subbit == 3) begin
						/* TODO(1.2.3):
						If the subbit isn't 3, our start signal is still running, so we
						don't change anything. However, if it IS 3, you must increment
						the command counter and set up a potential read/write:
						- Set `next_command` to the following command in the `commands`
						  array (using `commands_done` as the index of the current
						  command).
						- Increment `commands_done`, the number of finished commands.
						- If the next command is a read or write, set the new bit count
						  to 8; otherwise, keep it as-is.
						*/
						
						commands_done_d = commands_done + 1;
						next_command = commands[commands_done_d];
						
						if (
							next_command == WRITE_BYTE ||
							next_command == READ_BYTE_ACK ||
							next_command == READ_BYTE_NACK
						) begin
							bit_cnt_d = 8;
						end else begin
							bit_cnt_d = bit_cnt;
						end
						
					end else begin
						next_command = current_command;
						commands_done_d = commands_done;
						bit_cnt_d = bit_cnt;
					end
				end
				
				STOP: begin
					/* TODO(1.2.2):
					Fill out the values corresponding to the STOP command.
					Ensure that:
					- `acked`         remains as-is
					- `bytes_written` remains as-is
					- `bytes_read`    remains as-is
					- `failed`        remains as-is
					- SDA writing should be ENABLED (drive `sda_write_enable` for this)
					- The appropriate stop signal value should be written to `sda_in` --
					  it's determined based on the current subbit!
					  
					Hint: This one is VERY similar to the START command!
					*/
					acked_d = acked;					
					bytes_written_d = bytes_written;
					bytes_read_d = bytes_read;
					failed_d = failed;

					sda_write_enable = 1;
				
					if (subbit == 0 || subbit == 1) begin
						sda_in = 0;
					end else begin
						sda_in = 1;
					end
				
					if (subbit == 3) begin
						/* TODO(1.2.3):
						If the subbit isn't 3, our stop signal is still running, so we
						don't change anything. However, if it IS 3, you must increment
						the command counter and set up a potential read/write:
						- Set `next_command` to the following command in the `commands`
						  array (using `commands_done` as the index of the current
						  command).
						- Increment `commands_done`, the number of finished commands.
						- If the next command is a read or write, set the new bit count
						  to 8; otherwise, keep it as-is.
						
						Hint: This part is IDENTICAL to that of the START command!
						*/
						
						commands_done_d = commands_done + 1;
						next_command = commands[commands_done_d];
						
						if (
							next_command == WRITE_BYTE ||
							next_command == READ_BYTE_ACK ||
							next_command == READ_BYTE_NACK
						) begin
							bit_cnt_d = 8;
						end else begin
							bit_cnt_d = bit_cnt;
						end
						
					end else begin
						next_command = current_command;
						commands_done_d = commands_done;
						bit_cnt_d = bit_cnt;
					end
				end
				
				WRITE_BYTE: begin
					bytes_read_d = bytes_read;
					
					/* TODO(1.3.1):
					Once we have no more bits left to send, we must receive an ACK bit.
					Therefore, disable SDA writing in this case and keep it enabled at
					all other times.
					
					Additionally, using `bit_cnt` to index the current bit to be written
					in `current_byte_to_write`, write a bit to `sda_in`.
					*/
					if (bit_cnt == 0) begin
						sda_write_enable = 0;
					end else begin
						sda_write_enable = 1;
					end
					
					sda_in = current_byte_to_write[bit_cnt - 1];
					
					/* TODO(1.3.2):
					Determine whether the byte was ACKed and set `acked_d` accordingly.
					Namely, when `bit_cnt` is 0, we must read the ACK bit on subbit 2.
					(At all other points, `acked` should remain unchanged.)
					*/
					if (subbit == 2 && bit_cnt == 0) begin
						acked_d = (sda_out == 0);
					end else begin
						acked_d = acked;
					end
					
					if (subbit == 3) begin
						if (bit_cnt == 0) begin
							/* TODO(1.3.3):
							When we have written all bits and the subbit is 3, we must
							figure out the switch to the next command. Both `commands_done`
							and `bytes_written` should be incremented at this point.
							
							Additionally, we have a few pathways that determine our next
							command here:
							- If the byte was successfully ACKed, we must set the next command
							  (and, once again, prepare the `bit_cnt` if the next command is a
							  read or write). We must also keep `failed` as-is.
							- If the byte was NACKed, we should set `bit_cnt` to 0, the next
							  command should be STOP, and we should set the `failed` flag.
							*/
							commands_done_d = commands_done + 1;
							bytes_written_d = bytes_written + 1;
							
							if (acked) begin
								next_command = commands[commands_done + 1];
								failed_d = failed;
								
								if (
									next_command == WRITE_BYTE ||
									next_command == READ_BYTE_ACK ||
									next_command == READ_BYTE_NACK
								) begin
									bit_cnt_d = 8;
								end else begin
									bit_cnt_d = bit_cnt;
								end
								
							end else begin
								bit_cnt_d = 0;
								next_command = STOP;
								failed_d = 1;
							end
							
						end else begin
							// Here, if the subbit is 3 but we aren't out of bits to write,
							// we decrement the bit count and change nothing else.
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
					end
				end
				
				READ_BYTE_ACK: begin
					// The peripheral does not need to send any ACK bits in this phase, so
					// we can just leave `acked` constantly unchanged. Since we're reading
					// and not writing, we also won't change the number of bytes written.
					// And since we have no interest in complicating our I2C driver, we will
					// assume that all reads succeed :)
					acked_d = acked;
					bytes_written_d = bytes_written;
					failed_d = failed;
					
					/* TODO(1.4.1):
					Enable SDA writing when it's time for the FPGA to send an ACK bit (i.e.
					when there are no more bits left to write).
					
					Hint: It's basically the opposite of what we did when writing!
					*/

					if (bit_cnt == 0) begin
						sda_write_enable = 1;
					end else begin
						sda_write_enable = 0;
					end
					
					// In a more general scenario, you'd probably need some logic to determine
					// whether we're able to accept more bytes from the peripheral (and change
					// the ACK bit accordingly). However, to simplify the logic, we will just
					// ACK all bytes read with the READ_BYTE_ACK command.
					sda_in = 0;
					
					if (subbit == 3) begin
						if (bit_cnt == 0) begin
							/* TODO(1.4.2):
							Use the solutions form to get the solutions to this part of the lab,
							then type them in here. (They're similar enough to another part to
							where it would give away answers if we filled it in ourselves.)
							*/
							commands_done_d = commands_done + 1;
							bytes_read_d = bytes_read + 1;
							next_command = commands[commands_done + 1];
							
							if (
								next_command == WRITE_BYTE ||
								next_command == READ_BYTE_ACK ||
								next_command == READ_BYTE_NACK
							) begin
								bit_cnt_d = 8;
							end else begin
								bit_cnt_d = bit_cnt;
							end
							
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
							next_command = STOP;
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