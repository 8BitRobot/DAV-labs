`timescale 1ns/1ns

// bönk
module bonk(clk, dataPort, dataClock, dig0, dig1, seg0, seg1);
	input logic clk;
	output logic dataClock;
	inout dataPort;
	logic dataOut;

	logic [1:0] sendingPoll;
	logic plsRespondClock;
	logic [1:0] plsRespondClock_sr = 2'b0; // shift reg
	logic pll_locked;
	
	logic dataIn = 1'b1;
	logic [99:0] pollingMessage = 100'b0001011100010001000100010001000100010001000100010001000101110111000100010001000100010001000100010111;
	parameter NUM_POLL_BITS = 100;
	parameter NUM_RECEIVE_BITS = 64;
	
	logic [6:0] counter = 7'b0;
	logic [6:0] counter_d = 7'b0;
	
	logic [8:0] receive_counter = 9'b0;
	logic [8:0] receive_counter_d = 9'b0;

	logic [1:0] sendingPoll_d = 1'b0;

	logic [1:0] portEdge = 2'b00;
	logic [1:0] sendingPollEdge = 2'b00;
	logic measuring = 0;
	logic [11:0] bitLength;

	logic [63:0] received_data = 64'b0;
	logic [7:0] bongoHit = 8'b0; // bongo button input
	logic [8:0] bongoScream = 12'b0; // microphone input
 	// in honor of cameron screaming because I (claire) was not willing to
	// #camsplain #camboss #camera

	logic dataClockTest;
	 
	// `ifdef SIMULATION
	// 	clockDivider #(1000000) bonkClock(clk, dataClock, 0); // clock for sending bits
	// `else
	plls phase_my_fears(clk, dataClock);
	//`endif
	
	clockDivider #(165) downBadClock(clk, plsRespondClock, 0); // clock for polling

	// `ifdef SIMULATION
	// 	initial begin
	// 		dataClock = 0;
	// 		plsRespondClock = 0;
	// 	end
		
	// 	always begin
	// 		#500;
	// 		dataClock = ~dataClock;
	// 	end

	// 	always begin
	// 		#3000000;
	// 		plsRespondClock = ~plsRespondClock;
	// 	end
	// `endif
	

    IOBuffer bonkData(dataIn, dataOut, sendingPoll == 1, dataPort);
	 
	output logic [3:0] dig0, dig1;
	output logic [7:0] seg0, seg1;
	sevenSegDispLetters disp(dig1, dig0, seg1, seg0);

	always @(posedge clk) begin
		if (sendingPoll == 2) begin
			portEdge <= {portEdge[0], dataPort};
		end
		else begin
			portEdge <= 2'b0;
		end

		sendingPollEdge <= {sendingPollEdge[0], sendingPoll == 0};

		if (portEdge == 2'b10 || sendingPollEdge == 2'b01) begin
			receive_counter <= receive_counter_d;
		end

		if (measuring) begin
			bitLength <= bitLength + 1;
		end
		else begin
			bitLength <= 0;
		end
	end

	always @(posedge (portEdge == 2'b01), posedge (portEdge == 2'b10)) begin
		if (portEdge == 2'b01) begin
			measuring <= 1;
		end
		// if (sendingPoll == 2'b00) then set to or reset to counter_d
		else begin
			if (bitLength >= 100) begin
				received_data[NUM_RECEIVE_BITS - receive_counter - 1] <= 1;
			end else begin
				received_data[NUM_RECEIVE_BITS - receive_counter - 1] <= 0;
			end
			measuring <= 0;
		end
	end

	always @(posedge dataClock) begin
		counter <= counter_d;
		sendingPoll <= sendingPoll_d;

		if (sendingPoll_d == 1) begin
			dataIn <= pollingMessage[NUM_POLL_BITS - 1 - counter_d];
		end

		plsRespondClock_sr <= {plsRespondClock_sr[0], plsRespondClock};
	end
	
	always_comb begin
		if (sendingPoll == 1) begin
			counter_d = counter + 1;
		end else begin
			counter_d = 0;
		end
		
		if (sendingPoll == 2 && receive_counter != 63) begin
			receive_counter_d = receive_counter + 1;
		end else begin
			receive_counter_d = 0;
		end

		if (received_data[63:56] > 8'h35) begin
			bongoHit = received_data[63:56] >> 1;
		end else begin
			bongoHit = received_data[63:56];
		end
		
		dig1 = bongoHit[7:4];
		dig0 = bongoHit[3:0];
		
		bongoScream = received_data[11:0];

		case (sendingPoll)
			0: begin //nothing happening
				if (^plsRespondClock_sr & plsRespondClock) begin
					sendingPoll_d <= 1;
				end
				else begin
					sendingPoll_d <= 0;
				end
			end
			1: begin
				if (counter >= NUM_POLL_BITS - 1) begin
					sendingPoll_d <= 2;
				end
				else begin
					sendingPoll_d <= 1;
				end
			end
			2: begin
				if (receive_counter >= NUM_RECEIVE_BITS-1 || ~plsRespondClock) begin
					sendingPoll_d <= 0;
				end
				else begin
					sendingPoll_d <= 2;
				end
			end
			default: begin
				sendingPoll_d <= 0;
			end
		endcase
	end
endmodule