//module i2c_driver(i2c_clock, reset, deviceAddr, addr, numBytes, dataIn, dataOut, write, start, done, SCLpin, SDApin);
module i2c_driver(i2c_clock, running, deviceAddr, SCLpin, SDApin, counter, stage);
	input i2c_clock;
	input running;
	input [6:0] deviceAddr;
	
//	input [7:0] addr;
//	input [2:0] numBytes;
//	input [5:0] dataIn[7:0];
//	output [5:0] dataOut[7:0];
//	input write;
//	input start;
//	output done;

	output SCLpin;
	inout SDApin;
	
	output reg [1:0] counter = 3;
	output reg [2:0] stage = 0;
	reg [2:0] stage_d = 0;
	reg [31:0] totalBits = 0;
	
	parameter START = 0;
	parameter DEVICE = 1;
	parameter ACK = 2;
	parameter WRITE = 3;
	parameter REGISTER = 4;
	parameter DATA = 5;
	parameter READ = 6;
	
	reg acknowledged = 1;
	reg [4:0] deviceAddrBitsLeft = 25;

	reg SDApin_d;

	initial begin
		SDApin = 1'b1;
		counter = 3;
	end
	
	// SCL
	// end
	// me

	always @(posedge i2c_clock) begin
		counter <= counter + 1;
		totalBits <= totalBits + 1;
		SDApin <= SDApin_d;
		
		if (stage == DEVICE) begin
			deviceAddrBitsLeft <= deviceAddrBitsLeft - 1;
			stage <= stage_d;
		end
		else begin
			deviceAddrBitsLeft <= deviceAddrBitsLeft;
			stage <= stage_d;
		end

		// if (stage == START) begin
		// 	SDApin <= ~counter[1];
		// end
		// else begin
		// 	SDApin <= SDApin_d;
		// end
	end

	always_comb begin
		counterIsZero = (counter == 0);
		case (stage)
			START: begin
				if (totalBits > 3) begin
					stage_d = DEVICE;
				end
				else begin
					stage_d = START;
				end
			end
			DEVICE: begin
				if (totalBits > 31) begin
					stage_d = WRITE;
				end
				else begin
					stage_d = DEVICE;
				end
			end
			WRITE: begin
				if (totalBits > 35) begin
					stage_d = ACK;
				end else begin
					stage_d = WRITE;
				end
			end
			ACK: begin
				if (counter == 3 && SDApin == 1) begin
					stage_d = REGISTER;
				end
				else begin
					stage_d = ACK;
				end
			end
			default: begin
				stage_d = START;
			end
		endcase

		if (counter == 2'd1 || counter == 2'd2) begin
			SCLpin = 1;
		end
		else begin
			SCLpin = 0;
		end
		
		case (stage)
			START: begin
				case (counter)
					0: begin
						SDApin_d = 1;
					end
					1: begin
						SDApin_d  = 0;
					end
					2: begin 
						SDApin_d = 0; 
					end
					3: begin
						SDApin_d = 1;
					end
				endcase
			end
			DEVICE: begin
				SDApin_d = deviceAddr[deviceAddrBitsLeft / 4];
			end
			WRITE: begin
				SDApin_d = 1;
			end
			ACK: begin
				SDApin_d = 1'bz;
			end
			default: begin
				SDApin_d = 1'bz;
			end
		endcase
	end
endmodule