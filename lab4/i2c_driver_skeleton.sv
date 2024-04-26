module i2c_driver_new(
	input clk,
	input polling_clk,
	input [2:0] commands [0:15],
	input [7:0] data_write [0:5],
	output reg done,
	output reg [7:0] data_read [0:5],
	output reg scl,
   inout sda
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
		
		// YOUR CODE HERE
		
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
		
		// YOUR CODE HERE
	end
	
	always_comb begin	
		/* TODO(1.1.2):
		Determine the new value of the subbit counter based on the current value:
		- If the current state is IDLE, subbit_d should be reset to 0.
		- If the current command is IDLE_CMD, subbit_d should be reset to 0.
		- Otherwise, we should increment subbit, resetting to 0 when
		  subbit is 3 (the max value).
		*/
		
		// YOUR CODE HERE
		
		// The `done` output is pulsed high only if the `failed` flag is false at
		// the instant when we transition back to the idle state.
		done = state_sr[1] == RUNNING && state_sr[0] == IDLE && ~failed;
		
		// We generate SCL by driving it high on the middle two subbits, generating
		// a clock with 50% duty cycle and one period for every 4 clock ticks of our
		// input clock.
		scl = (subbit == 1 || subbit == 2);
		
		current_byte_to_write = data_write[bytes_written];
		
		/* TODO(1.4.3):
		Design a logic expression for `bit_ready`, a 1-bit flag that is high only when
		a new bit can be read from the current byte being read in a READ_BYTE command.
		The requirements for a bit being ready are:
		- The I2C driver is currently RUNNING
		- The current command is one of the two READ_BYTE commands
		- SCL just had a posedge (i.e. the subbit is 1)
		- The peripheral is currently sending a bit (i.e. the bit count is nonzero)
		*/
		
		// YOUR CODE HERE
			
		/* TODO(1.4.4):
		Design a logic expression for `byte_read`, a 1-bit flag that is high only when
		a full byte has been successfully read in a READ_BYTE command.
		The requirements for a byte having being read are:
		- The I2C driver is currently RUNNING
		- The current command is one of the two READ_BYTE commands
		- The FPGA just finished sending the ACK or NACK (i.e. subbit is 3 and bit count
		  is zero)
		*/
		
		// YOUR CODE HERE
		
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
					
					// YOUR CODE HERE
				
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
						
						// YOUR CODE HERE
						
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
					
					// YOUR CODE HERE
				
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
						
						// YOUR CODE HERE
						
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
					
					// YOUR CODE HERE
					
					/* TODO(1.3.2):
					Determine whether the byte was ACKed and set `acked_d` accordingly.
					Namely, when `bit_cnt` is 0, we must read the ACK bit on subbit 2.
					(At all other points, `acked` should remain unchanged.)
					*/
					
					// YOUR CODE HERE
					
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
							
							// YOUR CODE HERE
							
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

					// YOUR CODE HERE
					
					// In a more general scenario, you'd probably need some logic to determine
					// whether we're able to accept more bytes from the peripheral (and change
					// the ACK bit accordingly). However, to simplify the logic, we will just
					// ACK all bytes read with the READ_BYTE_ACK command.
					sda_in = 0;
					
					if (subbit == 3) begin
						if (bit_cnt == 0) begin
							/* TODO(1.4.2):
							Type the code "READMeMyRights" into the solutions form to get
							the solutions to this part of the lab, then paste them here.
							*/
							
							// YOUR CODE HERE							
							
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
					/* TODO(1.4.6):
					Type the code "EpicAtNACKerman" into the solutions form to get
					the solutions to this part of the lab, then paste them here.
					*/
					
					// YOUR CODE HERE
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