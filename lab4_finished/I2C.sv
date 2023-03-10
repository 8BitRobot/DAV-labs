`timescale 1ns/1ns
module I2C #(parameter MAX_BYTES = 6) (clk, rst, driverDisable, deviceAddr_d, regAddr_d, numBytes_d, dataIn_d, dataOut, write_d, start, done, scl, sda);
	
	// bus width parameter:
	localparam NUMBYTES_WIDTH = $clog2(MAX_BYTES + 2);
	
	// FSM state declarations
	localparam RESET = 0;
	localparam START = 1;
	localparam DEV_ADDR = 2;
	localparam REG_ADDR = 3;
	localparam DATA = 4;
	localparam STOP = 5;
	localparam IDLE = 6;
	
	// input / output ports
	input clk; 								//note: clk is 3x the actual speed of i2c communication
	input rst;
	input write_d;							//write = write enable
	input start; 				 			//start = triggers FSM to start when start == 1
	input driverDisable;					//driverDisable = disables FSM when == 1
	input[6:0] deviceAddr_d;						//device address
	input[7:0] regAddr_d;							//register address to read/write from
	input[NUMBYTES_WIDTH-1:0] numBytes_d;		//number of bytes to read/write
	input[7:0] dataIn_d [MAX_BYTES-1:0];		// data input bus
	
	output reg [7:0] dataOut[MAX_BYTES-1:0] = '{default: '0};	//dataOut = data output bus, note '{default: '0}; is a parameterized version of setting = 0;
	output done; 							//done = 1 when finished with a transmission
	output reg scl = 1'b0;				//scl = I2C clock output
	inout sda;								//sda = I2C data in/out
	
	
	// Tri-state buffer
	reg in = 0;		//input value to write when we=1
	reg we = 1;		//write enable for tri-state buffer
	wire out;		//output from buffer when we=0
	IOBuffer sdaBuff(in, out, we, sda);

	// FSM state
	reg [2:0] state = RESET;
	reg [2:0] next_state = RESET;
	
	
	// input buffers
	// These are essentially just registers that hold commands after start is triggered.
	reg write = 1'b0;							// determines if writing/reading to peripheral
	reg [6:0] deviceAddr;					//device address to talk to
	reg [NUMBYTES_WIDTH-1:0] numBytes;	//input # of bytes to read/write
	reg [7:0] dataIn [MAX_BYTES-1:0];	//data input register
	reg [7:0] regAddr;						//register address
	
	// internal variables
	reg [7:0] data2send;				//data to send (used as buffer for individual bytes)
	reg [7:0] byteOut;						//byte output (used as buffer for individual bytes)
	reg [NUMBYTES_WIDTH-1:0] byte_cnt = '{default: '0};	//counts # of bytes sent/received
	reg [3:0] bit_cnt = 3'b0;			//counts # of bits
	reg [1:0] subbit_cnt = 2'b0;		//counts # of sub-bit ticks
	reg [7:0] delayCounter = 8'b0;	//counts # of delay ticks after command is finished
	
	// flags
	reg done_sending = 0;	//triggered when each state is finished
	reg sending_byte = 0;	//high if currently writing, low if currently reading
	reg data_start = 0;		//high if currently sending / receiving data
	reg notAcked = 0;			//high if peripheral returned NACK
	
	assign done = state == RESET; //set done output HIGH when FSM returns to RESET.
	
	
	// FSM sequential logic
	// This block handles setting state=next_state
	always @(negedge clk) begin
		if(rst || driverDisable) begin
			state <= IDLE;
			write <= 0;
			deviceAddr = 0;
			numBytes <= 0;
			dataIn <= '{default: '0};
			regAddr <= 0;
		end
		else begin
			state <= next_state;
			write <= write_d;
			deviceAddr <= deviceAddr_d;
			if (write_d) begin
				numBytes = numBytes_d + 2;
			end
			else begin
				numBytes = numBytes_d + 1;
			end
			dataIn <= dataIn_d;
			regAddr <= regAddr_d;
		end
	end
	
	// I2C communication logic
	// This block does the dirty work!
	always @(posedge clk) begin
		
		// Set everything to 0 on reset or disable
		if(rst || driverDisable) begin
			subbit_cnt <= 0;
			bit_cnt <= 0;
			done_sending <= 0;
			we <= 0;
			in <= 0;
			scl <= 0;
			notAcked <= 0;
			byteOut <= 8'b0;
			if(rst) begin
				dataOut <= '{default: '0};
			end
		end else begin		

			// increase subbit_cnt each cycle if not idle
			if(state != RESET && state != IDLE) begin
				subbit_cnt <= subbit_cnt + 1;
			end else begin
				subbit_cnt <= 0;
			end
			
			if(state == IDLE) begin
				delayCounter <= delayCounter + 1;
			end else begin
				delayCounter <= 0;
			end
			
			// send start or stop signal
			if (state == START || state == STOP) begin
				byte_cnt <= 0;
				case (subbit_cnt)
					0: begin
						done_sending <= 0;
						we <= 1;
						in <= (state == START);
					end
					1: begin
						we <= 1;
						scl <= 1;
					end
					2: begin
						in <= !(state == START);
					end
					3: begin
						scl <= 0;
						done_sending <= 1;
					end
				endcase
				
			// send or receive data
			end else if (data_start) begin
				if(bit_cnt < 8) begin
					done_sending <= 0;
					case (subbit_cnt)
						0: begin
							scl <= 0;
							if(sending_byte) begin
								we <= 1;
								in <= data2send[7 - bit_cnt];
							end else begin
								we <= 0;
								byteOut[7-bit_cnt] <= out;
							end
						end
						1: begin
							scl <= 1;
						end
						2: begin
							scl <= 1;
						end
						3: begin
							bit_cnt <= bit_cnt + 1;
							scl <= 0;
						end
					endcase
					
				//check or send ACK
				end else begin
					case (subbit_cnt)
						0: begin
							scl <= 0;
							done_sending <= 0;
							if (!write) begin
								we <= 1;
								in <= (numBytes == byte_cnt+1);
								dataOut[byte_cnt-1] <= byteOut;
							end else begin
								we <= 0;
							end
						end
						1: begin
							scl <= 1;
						end
						2: begin
							scl <= 1;
							if (write) begin
								notAcked <= 0;
							end
							// if(out == 1)	//check ack for validity
							// 	notAcked <= 1;
							// else
							// 	notAcked <= 0;
						end
						3: begin
							scl <= 0;
							subbit_cnt <= 0;
							bit_cnt <= 0;
							done_sending <= 1;
							we <= 0;
							byte_cnt <= byte_cnt + 1;
						end
					endcase
				end
			// idle state
			end else begin
				// done <= 1;
				done_sending <= 0;
			end
		end
	end

	
	// FSM combinational logic
	always_comb begin
		case (state)
			
			// Reset state
			RESET: begin
				data_start = 0;
				sending_byte = 0;
				data2send = '{default: '0};
				if(start) begin
					next_state = START;
				end else begin
					next_state = IDLE;
				end
			end
			
			// Send START signal
			START: begin
				data_start = 0;
				sending_byte = 0;
				data2send = '{default: '0};
				if(done_sending) begin
					next_state = DEV_ADDR;
				end else begin
					next_state = START;
				end
			end
			
			// Send device address
			DEV_ADDR: begin
				//send 7 bits for address
				data2send = {deviceAddr, ~write};
				data_start = 1;
				sending_byte = 1;
				if(done_sending) begin
					if(notAcked) begin
						next_state = STOP;
					end else begin
						next_state = write ? REG_ADDR : DATA; //write signal determines whether we need to send a reg address or can go to read
					end
				end
				else begin
					next_state = DEV_ADDR;
				end
				
			end
			
			// Send register address
			REG_ADDR: begin
				data2send = regAddr;
				data_start = 1;
				sending_byte = 1;
				if(done_sending && (subbit_cnt == 3 || subbit_cnt == 0)) begin
					if(notAcked) begin
						next_state = STOP;
					end else begin
						next_state = (numBytes == byte_cnt) ? STOP : DATA; 
					end
				end
				else begin
					next_state = REG_ADDR;
				end
			end
			
			// read / write bulk DATA
			DATA: begin

				sending_byte = write;
				data2send = dataIn[byte_cnt-2];
				data_start = 1;

				if(done_sending && (subbit_cnt == 3 || subbit_cnt == 0)) begin
					if(notAcked) begin
						next_state = STOP;
					end else begin
						if (numBytes == byte_cnt) begin
							next_state = STOP;
						end
						else begin
							next_state = DATA;
						end
					end
				end
				else begin
					next_state = DATA;
				end
			end
			
			
			// Send STOP signal
			STOP: begin
				sending_byte = 0;
				data_start = 0;
				
				data2send = '{default: '0};
				if(done_sending) begin
					next_state = RESET;
				end else begin
					next_state = STOP;
				end
			end

			// Adds delay to space out individual commands
			IDLE: begin
				data_start = 0;
				sending_byte = 0;
				data2send = '{default: '0};
				
				if(delayCounter > 8'd250) begin
					next_state = START;
				end else begin
					next_state = IDLE;
				end
			end
			
			default: next_state = IDLE;
		endcase
	end
endmodule