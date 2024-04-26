`timescale 1ns/1ns

module bit_switch_box #(
	parameter MAW = 10
)
(
	input [MAW-1:0] input_address,  // Input address to be flipped
	input [$clog2(MAW):0] sel_addr_width, // unsigned from 1 to MAW. Minimum is 1. Expects one as a number. 
	output reg [MAW-1:0] output_address	 // output address
);
		
		// creates an individual case for each bit flip
		// first demux the input into the correct location. Default is zero
		// all the outputs will be OR'd together. 
		
		
		reg [MAW-1:0] flip_input_arr [MAW:1];
		reg [MAW-1:0] flip_output_arr [MAW:1];
		reg [$clog2(MAW):0] addr_width;
		
		// Filter for the value
		always_comb begin
			addr_width = 0;
			if (sel_addr_width == 0) begin
				addr_width = 1;
			end 
			else if (sel_addr_width > MAW) begin
				addr_width = MAW;
			end
			else begin
				addr_width = sel_addr_width;
			end
		end
		
		// Demux operation
		
		always_comb begin
		
			for (int j = 1; j < MAW+1; j++) begin // sets all input values to zero
				flip_input_arr[j] = 0;
			end
			
			flip_input_arr[addr_width] = input_address; // sets the chosen value to input value
			
		end
		
		// Bit flipping operations
		always_comb begin
			for (int j = 1; j < MAW+1; j++) begin // selects each one address width and does the bit flipping
				for (int i = 0; i < MAW; i++) begin
					flip_output_arr[j][i] = 0;
				end
				for (int i = 0; i < j; i++) begin
					flip_output_arr[j][i] = flip_input_arr[j][j - 1 - i];
				end
			end
		end
		
		// OR operations
		// with a transpose
		
		always_comb begin
			output_address = 0;
			for (int i = 0; i < MAW; i++) begin
				for (int j = 1; j < MAW+1; j++) begin
					if (flip_output_arr[j][i] == 1'b1) begin
						output_address[i] = 1'b1;
					end
				end
			end
		end

		// assign output_address = |flip_output_arr;
		
endmodule 