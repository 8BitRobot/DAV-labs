`timescale 1ns/1ns
module bongo_response_tb (clk, pll_clk, dataPort, dataClock, readClock, sendingPoll);
	const logic [99:0] POLLING_MESSAGE = 100'b0001011100010001000100010001000100010001000100010001000101110111000100010001000100010001000100010111;
	const logic [255:0] RETURN_MESSAGE = 256'b0001000100010111000101110001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010111000101110001;	
	output logic clk = 0;
	output logic pll_clk = 0;
	inout wire dataPort;
	output logic dataClock;
	output logic readClock;
	output logic [1:0] sendingPoll;

// 10100000000000000000000000000000000000000000000000000000001010
	reg why = 1'bZ;
	logic [99:0] received_bits = 100'b0;
	logic receiving = 1;
	integer i;

	assign dataPort = receiving ? 1'bZ : why;

	always begin
		#20;
		clk = ~clk;
	end
	
	always begin
		// #( (2000 + ($random & 63) * (-1 * ($random & 1))) );
		if (receiving) begin
			#500;
			pll_clk = ~pll_clk;
			received_bits = {received_bits[98:0], dataPort};
			if (received_bits == POLLING_MESSAGE) begin
				// no longer receiving?
				receiving = 0;
				i = 255;
				$display("polled!");
			end
			#500;
		end
		else begin
			why = RETURN_MESSAGE[i];
			if (i == 0) begin
				receiving = 1;
			end
			i -= 1;
			#1000;
		end
	end
	
	bonk UUT(clk, dataPort, dig0, dig1, dataOut, dataClock, readClock, sendingPoll);

endmodule