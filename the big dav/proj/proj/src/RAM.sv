`timescale 1ns/1ns

module RAM #
(
	parameter ADDR_WIDTH = 4
)
( 
	input [ADDR_WIDTH-1:0] address_a, address_b,
	input clock,
	input [17:00] data_a, data_b,
	input wren_a, wren_b,
	output [17:00] q_a, q_b
);

	reg [17:00] dat_a, dat_b;
	reg [ADDR_WIDTH-1:0] addra, addrb;
	reg wr_a, wr_b;
	
	reg [17:00] memory [(2**ADDR_WIDTH-1):00];
	
	always @(posedge clock) begin
		addra <= address_a;
		addrb <= address_b;
		dat_a <= data_a;
		dat_b <= data_b;
		wr_a	<= wren_a;
		wr_b	<= wren_b;
	end
	
	always @(wr_a, wr_b, addra, addrb, dat_a, dat_b) begin
		if (wr_a) begin
			memory[addra] <= dat_a;
		end
		else begin
			memory[addra] <= memory[addra];
		end
		if (wr_b) begin
			memory[addrb] <= dat_b;
		end
		else begin
			memory[addrb] <= memory[addrb];
		end
	end
	
	assign q_a = memory[addra];
	assign q_b = memory[addrb];

endmodule