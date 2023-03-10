`timescale 1ns/1ns
// bönk
module bonk(clk, dataPort, dig0, dig1, dataOut, dataClock, readClock, sendingPoll);
	input logic clk;
	inout dataPort;
	output [7:0] dig1, dig0;

	output logic dataOut;

	output logic [1:0] sendingPoll;
	logic plsRespondClock;
	logic [1:0] plsRespondClock_sr = 2'b0; // shift reg
	output logic dataClock;
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

	logic [63:0] received_data = 64'b0;
	logic [7:0] bongoHit = 8'b0; // bongo button input
	logic [8:0] bongoScream = 12'b0; // microphone input
 	// in honor of cameron screaming because I (claire) was not willing to
	// #camsplain #camboss #camera
	 
    // clockDivider #(1000000) bonkClock(clk, dataClock, 0); // clock for sending bits
	// pll_clk phase_my_fears(0, clk, dataClock, pll_locked);
    clockDivider #(165) downBadClock(clk, plsRespondClock, 0); // clock for polling

    IOBuffer bonkData(dataIn, dataOut, sendingPoll == 1, dataPort);
	 
	sevenSegDispLetters disp(bongoHit[7:4], bongoHit[3:0], dig1, dig0);

	output logic readClock = 1;
   // clockDivider #(500000) readingDataClock(clk, readClock, sendingPoll != 2); // clock for reading bits

	always_comb begin
		// if (sendingPoll == 1 && counter < NUM_POLL_BITS-1) begin
		if (sendingPoll == 1) begin
			counter_d = counter + 1;
		end else begin
			counter_d = 0;
		end
		
		// if (sendingPoll == 2 && receive_counter < NUM_RECEIVE_BITS - 1) begin
		if (sendingPoll == 2) begin
			receive_counter_d = receive_counter + 1;
		end else begin
			receive_counter_d = 0;
		end

		bongoHit = received_data[63:56];
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
				if (receive_counter >= NUM_RECEIVE_BITS-1) begin
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
	
	// always @(posedge dataClock) begin
	always begin
		#1000;
		counter <= counter_d;
		sendingPoll <= sendingPoll_d;

		if (sendingPoll_d == 1) begin
			dataIn <= pollingMessage[NUM_POLL_BITS - 1 - counter_d];
		end

		plsRespondClock_sr <= {plsRespondClock_sr[0], plsRespondClock};
	end

	always @(posedge readClock) begin
	// always begin
		// #2000;
		received_data[NUM_RECEIVE_BITS - receive_counter_d] <= dataOut;
		if (readClock) begin
			receive_counter <= receive_counter_d;
		end
	end

	//always @(posedge readClock, posedge (sendingPoll == 1)) begin
	always begin
		#2000;
		readClock <= ~readClock;
	end
endmodule