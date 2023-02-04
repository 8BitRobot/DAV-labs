//module i2c_driver(i2c_clock, reset, deviceAddr, addr, numBytes, dataIn, dataOut, write, start, done, SCLpin, SDApin);
module i2c_driver(i2c_clock, running, deviceAddr, SCLpin, SDApin, counter);
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
	
	output reg [1:0] counter = 0;
	reg [2:0] stage = 0;
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
	reg [2:0] deviceAddrBitsLeft = 7;
	
	// SCL
//	always @(posedge i2c_clock or posedge running) begin
	always @(posedge i2c_clock) begin
		totalBits <= totalBits + 1;
		stage <= stage_d;
		counter <= counter + 1;
	end
	
	always @(posedge (counter == 0)) begin
		if (stage == DEVICE) begin
			deviceAddrBitsLeft <= deviceAddrBitsLeft - 1;
		end
		else begin
			deviceAddrBitsLeft <= 7;
		end
	end

	always_comb begin
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
					0: begin SDApin = 1; end
					1: begin SDApin = 1; end
					2: begin SDApin = 0; end
					3: begin SDApin = 0; end
				endcase
			end
			DEVICE: begin
				SDApin = deviceAddr >> (deviceAddrBitsLeft - 1);
			end
			WRITE: begin
				SDApin = 1;
			end
			ACK: begin
				SDApin = 1'bz;
			end
			default: begin
				SDApin = 1'bz;
			end
		endcase
	end
	
endmodule