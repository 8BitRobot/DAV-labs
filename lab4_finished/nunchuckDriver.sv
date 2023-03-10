module nunchuckDriver(clock, SDApin, SCLpin, stick_x, stick_y, accel_x, accel_y, accel_z, z, c, rst);
	input clock, rst;
	inout SDApin;
	output SCLpin;
	output [7:0] stick_x, stick_y;
	output [9:0] accel_x, accel_y, accel_z;
	output z, c;
	
	
	// State name parameters:
	localparam HANDSHAKE1 = 0;
	localparam HANDSHAKE2 = 1;
	localparam WRITE = 2;
	localparam READ = 3;
	localparam READ2 = 5;
	localparam DONE = 4;

	localparam MAX_BYTES = 6; //Parameter for I2C low-level (LL) driver, max # of bytes to read/write at once, determines dataIn / Out width.
	
	localparam I2C_CLOCK_SPEED = 400000; //100kHz
	localparam MESSAGE_RATE = 70; 		 //100Hz is the rate at which we send/read messages
	
	
	
	wire [7:0] dataOut_d [MAX_BYTES-1:0]; //This should be an array of MAX_BYTES bytes 
	reg [7:0] dataOut [MAX_BYTES-1:0];
	//For more advanced designs such as your capstone, we would use RAM instead of a massive port;
	
	//clocks
	wire i2c_clock, polling_clock;
	reg [1:0] polling_clock_vals = 2'b00;	//controls shift register for polling clock
	
	
	// FSM state
	reg [2:0] state = DONE;						//current driver FSM state
	reg [2:0] next_state = 3'b0;				//next state for FSM, determined by combinational logic
	
	
	// LL driver command arguments
	reg write; 											//write enable for LL (low level) driver
	reg [$clog2(MAX_BYTES)-1: 0] numBytes_d; 	//this is the number of bytes to read/write for the particular instruction
	reg [$clog2(MAX_BYTES)-1: 0] numBytes;
	reg communicate = 1'b0; 						//Flag that determines whether its time for us to send a new message. Controlled by the polling rate
	reg [6:0] regAddress; 							//memory address for the peripheral device
	reg [6:0] deviceAddr;
	reg [7:0] addr;
	reg [7:0] dataIn [MAX_BYTES-1:0] = '{default: '0};
	
	
	wire driverDisable = state == DONE;			//disables LL driver when idle
	wire done;											//carries done flag from LL driver
	
	reg [2:0] handshakeDone = 0;
	

	// submodule declarations
	I2C #(MAX_BYTES) UUT(i2c_clock, rst, driverDisable, deviceAddr, addr, numBytes_d, dataIn, dataOut_d, write, communicate, done, SCLpin, SDApin);
	
	nunchuck_translator UUT2(dataOut, stick_x, stick_y, accel_x, accel_y, accel_z, z, c);
	
	
	/*
			NOTE: 
			You will need to provide your own clockDivider module. It should take a speed as a parameter rather than be hardcoded to a specific freq
			As per the spec, one of these clock dividers should be replaced with a PLL IP by the end of the lab
			This requirement will make more sense after Lecture 5
	*/
	
	clockDivider #(I2C_CLOCK_SPEED) i2c_clock_uut(clock, i2c_clock, rst); 		//this clock corresponds to each I2C instruction 
	clockDivider #(MESSAGE_RATE) polling_clock_uut(clock, polling_clock, rst); //clock is for spacing out messages to send
	
	
	
	// Polling Clock 
	
	/*always@(posedge i2C_clock) begin
		if(!(dataOut_d[0] == 8'h00 && dataOut_d[1] == 8'h00 && dataOut_d[2] == 8'h00)) begin
			dataOut <= dataOut_d;
		end
	end*/
	
	
	// Sequential FSM Logic
	always@(posedge i2c_clock, posedge rst) begin
		if(rst) begin
			state <= DONE;
			communicate <= 0;
			handshakeDone <= 0;
		end else begin
			//Two bit shift register:
			if (done || communicate) begin
				state <= next_state;
				if(state == HANDSHAKE2) handshakeDone <= handshakeDone + 1;
				if(next_state == READ2) dataOut <= dataOut_d;
			end

			polling_clock_vals = {polling_clock_vals[0], polling_clock};
			communicate <= ^polling_clock_vals & polling_clock;
		end
	end
	
	
	// Combinational FSM Logic
	always_comb begin
		case (state)
			HANDSHAKE1: begin
				deviceAddr = 7'h52;
				addr = 8'hF0;
				dataIn[0] = 8'h55;
				numBytes_d = 1;
				write = 1;
				next_state = HANDSHAKE2;
			end
			HANDSHAKE2: begin
				deviceAddr = 7'h52;
				addr = 8'hFB;
				dataIn[0] = 8'h00;
				numBytes_d = 1;
				write = 1;
				next_state = WRITE;                     
		
			end
			WRITE: begin
				deviceAddr = 7'h52;
				addr = 8'h00;
				dataIn[0] = 8'h00;
				numBytes_d = 0;
				write = 1;
				
				next_state = READ;
			end
			READ: begin
				deviceAddr = 7'h52;
				addr = 8'h00;
				dataIn[0] = 8'h00;
				write = 0;
				numBytes_d = 6;
				next_state = READ2;
			end
			READ2: begin
				deviceAddr = 7'h52;
				addr = 8'h00;
				dataIn[0] = 8'h00;
				write = 0;
				numBytes_d = 6;
				next_state = DONE;
			end
			DONE: begin
				deviceAddr = 7'bZZZZZZZ;
				addr = 8'bZZZZZZZZ;
				dataIn[0] = 8'bZZZZZZZZ;
				write = 1'b0;
				numBytes_d = 0;
				if(handshakeDone == 3'b1) begin
					next_state = WRITE;
				end else begin
					next_state = HANDSHAKE1;
				end
				//next_state = HANDSHAKE1;
				//next_state = (handshakeDone == 3'd8) ? WRITE : HANDSHAKE1;
			end
		endcase
	end
	
	
endmodule