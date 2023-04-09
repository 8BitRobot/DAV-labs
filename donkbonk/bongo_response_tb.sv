`timescale 1ns/1ns
`define SIMULATION
module bongo_response_tb (clk, dataPort, dataClock, seg0, seg1, leds);
	const logic [99:0] POLLING_MESSAGE = 100'b0001011100010001000100010001000100010001000100010001000101110111000100010001000100010001000100010111;
	const logic [255:0] RETURN_MESSAGE = 256'h1717171111111111111111111111111111111111111111111111111111171717;
	output logic clk = 0;
	output logic dataClock;
	inout wire dataPort;
	
	output logic [7:0] seg0, seg1;
	output logic [9:0] leds;

	// 10100000000000000000000000000000000000000000000000000000001010
	reg why = 1'bZ;
	logic [99:0] received_bits = 100'b0;
	logic receiving = 1;
	integer i;

	assign dataPort = receiving ? 1'bZ : why;

	always begin
		#10;
		clk = ~clk;
	end
	
	always @(posedge dataClock) begin
		if (receiving) begin
			why = 0;
			received_bits = {received_bits[98:0], dataPort};
			if (received_bits == POLLING_MESSAGE) begin
				// no longer receiving?
				receiving = 0;
				i = 255;
				$display("polled!");
			end
		end
		else begin
			why = RETURN_MESSAGE[i];
			if (i == 0) begin
				receiving = 1;
			end
			i -= 1;
		end
	end
	
	ledControl UUT(clk, dataPort, dataClock, seg0, seg1, leds);

endmodule