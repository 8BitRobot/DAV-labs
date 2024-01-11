module sevenSegDigit(
	/* TODO: Ports go here (refer to lab spec) */
	input [3:0] num, 
	input sw, 
	output reg [7:0] out
);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
	
		if (sw == 1'b0) begin
			out = 8'b11111111;
		end
		else begin
			case (num)
			
				4'b0000: begin // 0
					out = 8'b01000000;
				end
				4'b0001: begin // 1
					out = 8'b11111001;
				end
				4'b0010: begin // 2
					out = 8'b10100100;
				end
				4'b0011: begin // 3
					out = 8'b00110000;
				end
				4'b0100: begin // 4
					out = 8'b10011001;
				end
				4'b0101: begin // 5
					out = 8'b00010010;
				end
				4'b0110: begin // 6
					out = 8'b00000010;
				end
				4'b0111: begin // 7
					out = 8'b11111000;
				end
				4'b1000: begin // 8
					out = 8'b00000000;
				end
				4'b1001: begin // 9
					out = 8'b00011000;
				end
				
				default: begin // this is the "catch-all" case 
					out = 8'b11111111;
				end
				
			endcase
		end
		
	end
endmodule
