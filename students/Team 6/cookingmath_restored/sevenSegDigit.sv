module sevenSegDigit(
	input [3:0] number,
	input sw,
	output [7:0] display
);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
	
		if (sw == 0) begin
			/* If display on-off switch is off, turn the display off */
			display = 8'b11111111;
		end
		else begin
			case (number)
				4'b0000: begin
					display = 8'b11000000;
				end
				4'b0001: begin
					display = 8'b11111001;
				end
				4'b0010: begin
					display = 8'b10100100;
				end
				4'b0011: begin
					display = 8'b10110000;
				end
				4'b0100: begin
					display = 8'b10011001;
				end
				4'b0101: begin
					display = 8'b10010010;
				end
				4'b0110: begin
					display = 8'b10000010;
				end
				4'b0111: begin
					display = 8'b11111000;
				end
				4'b1000: begin
					display = 8'b10000000;
				end
				4'b1001: begin
					display = 8'b10011000;
				end
				
				/* TODO: more cases */
				
				default: begin // this is the "catch-all" case
					display = 8'b11111111;
				end
				
			endcase
		end
		
	end
endmodule
