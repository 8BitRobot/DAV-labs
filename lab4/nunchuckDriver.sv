module nunchuckDriver(clock, SDApin, SCLpin, reset, counter);
	input clock, reset;
	output SCLpin;
	output [1:0] counter;
	inout SDApin;
	
	reg [6:0] deviceAddr = 7'h52;
	
	reg polling_clock;
	reg i2c_clock;
	
	reg running = 0;
	
	clockDivider #(.SPEED(400000)) i2c (clock, i2c_clock);
	clockDivider #(.SPEED(100)) polling (clock, polling_Clock);
	
	i2c_driver UUT(i2c_clock, running, deviceAddr, SCLpin, SDApin, counter);
	
	always @(negedge reset) begin
		running = ~running;
	end
endmodule

/*
module nunchuckDriver(clock, SDApin, SCLpin, reset);
	input clock, reset;
	output SCLpin;
	inout SDApin;
	
	reg polling_Clock;
	reg i2c_clock;
	
	parameter H1 = 0;
	parameter H2 = 1;
	parameter W = 2;
	parameter R = 3;
	reg [1:0] current_step = H1;
	reg [1:0] next_step = H2;
	
	reg reset;
	reg [6:0] deviceAddr = 7'h52;
	reg [7:0] addr;
	reg [2:0] numBytes;
	reg [6:0] dataIn; 
	reg [6:0] dataOut; 
	reg write;
	reg start;
	reg done;
	
	
	clockDivider polling #(.SPEED(100))(clock, polling_Clock);
	clockDivider i2c #(.SPEED(400000))(clock, i2c_clock);
	
	I2C UUT(i2c_clock, reset, deviceAddr, addr, numBytes, dataIn, dataOut, write, start, done, SCLpin, SDApin);
	
	always_comb begin
		case (current_step)
			H1: begin
				addr = 8'hF0;
				dataIn[0] = 8'h55;
				numBytes = 1;
				write = 1;
				if (done) begin
					next_step = H2;
					start = 1;
				end
				else begin:
					next_step = H1;
					start = 0;
				end
			end
			H2: begin
				addr = 8'hFB;
				dataIn[0] = 8'h00;
				numBytes = 1;
				write = 1;
				if (done) begin
					next_step = W;
					start = 1;
				end
				else begin:
					next_step = H2;
					start = 0;
				end
			end
			W: begin
				addr = 8'h00;
				dataIn[0] = 8'h00;
				numBytes = 1;
				write = 0;
				if (done) begin
					next_step = R;
					start = 1;
				end
				else begin:
					next_step = W;
					start = 0;
				end
			end
			R: begin
				
				if (done) begin
					next_step = H1;
					start = 1;
				end
				else begin:
					next_step = R;
					start = 0;
				end
			end
		endcase
	end
	
	
	
endmodule
*/