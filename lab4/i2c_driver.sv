//module i2c_driver(i2c_clock, reset, deviceAddr, addr, numBytes, dataIn, dataOut, write, start, done, SCLpin, SDApin);
module i2c_driver(i2c_clock, running, deviceAddr, SCLpin, SDApin, counter, stage, addr);
	input i2c_clock;
	input running;
	input [6:0] deviceAddr;
	input[7:0] addr;
	
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
	parameter DEVICE_ACK = 2;
	parameter DEVICE_WRITE = 3;
	parameter ACK = 4;
	parameter H1_NEXT = 5;
	parameter H1 = 6;
	parameter H1_ACK = 7;
	parameter H2_NEXT = 8;
	parameter H2 = 9;
	parameter H2_ACK = 10;
	parameter H2_ACK = 11;
	parameter DATA = 12;
	parameter READ = 13;
	
	reg acknowledged = 1;
	reg [4:0] deviceAddrBitsLeft = 27;
	reg [4:0] dataBitsLeft = 31;
	reg [4:0] dataBytesLeft = 1;
	
	reg [7:0] h1bytes [0:1];

	reg SDApin_d;

	initial begin
		SDApin = 1'b1;
		counter = 2;

		h1bytes 
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
					stage_d = DEVICE_WRITE;
				end
				else begin
					stage_d = DEVICE;
				end
			end
			DEVICE_WRITE: begin
				if (totalBits > 35) begin
					stage_d = DEVICE_ACK;
				end else begin
					stage_d = DEVICE_WRITE;
				end
			end
			DEVICE_ACK: begin
				if (counter == 2 && SDApin == 0) begin
					stage_d = H1_NEXT;
				end
				else begin
					stage_d = DEVICE_ACK;
				end
			end
			H1_NEXT: begin
				if (counter == 3) begin
					stage_d = H1;
				end
				else begin
					stage_d = H1_NEXT;
				end
			end
			H1: begin
				if (dataBitsLeft == 0 && dataBytesLeft == 0) begin
					stage_d = H1_ACK;
				end
				else begin
					stage_d = H1;
				end
			end
			H1_ACK: begin
				if (counter == 2 && SDApin == 0) begin
					stage_d = STOP;
				end
				else begin
					stage_d = H1_ACK
				end
			end
			H2_NEXT: begin
				if (counter == 3) begin
					stage_d = H2;
				end
				else begin
					stage_d = H2_NEXT;
				end	
			end
			STOP: begin
				if (dataBytesLeft)
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
			H1: begin
				SDApin_d = addr[dataBitsLeft / 4];
			end
			WRITE: begin
				SDApin_d = 1;
			end
			ACK: begin
				SDApin_d = 1'b0;
			end
			default: begin
				SDApin_d = 1'bz;
			end
		endcase
	end
endmodule