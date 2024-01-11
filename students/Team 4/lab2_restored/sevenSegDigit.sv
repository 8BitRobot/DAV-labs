module sevenSegDigit(
	input [3:0] number, 
	input on, 
	input decimal,
	output reg [7:0] segments
	/* TODO: Ports go here (refer to lab spec) */
);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
		if (!on) begin
			/* TODO: set your output bits */
			segments = 8'b11111111;
		end
		else begin
			if (!decimal) begin
				case (number)
				
					4'd0: begin
						segments = 8'b11000000;
					end
					4'd1: begin
						segments = 8'b11111001;
					end
					4'd2: begin
						segments = 8'b10100100;
					end
					4'd3: begin
						segments = 8'b10110000;
					end
					4'd4: begin
						segments = 8'b10011001;
					end
					4'd5: begin
						segments = 8'b10010010;
					end
					4'd6: begin
						segments = 8'b10000010;
					end
					4'd7: begin
						segments = 8'b11111000;
					end
					4'd8: begin
						segments = 8'b10000000;
					end
					4'd9: begin
						segments = 8'b10010000;
					end
					
					default: begin
						segments = 8'b11111111;
					end
				endcase
			end
			else begin
				case (number)
				
					4'd0: begin
						segments = 8'b01000000;
					end
					4'd1: begin
						segments = 8'b01111001;
					end
					4'd2: begin
						segments = 8'b00100100;
					end
					4'd3: begin
						segments = 8'b00110000;
					end
					4'd4: begin
						segments = 8'b00011001;
					end
					4'd5: begin
						segments = 8'b00010010;
					end
					4'd6: begin
						segments = 8'b00000010;
					end
					4'd7: begin
						segments = 8'b01111000;
					end
					4'd8: begin
						segments = 8'b00000000;
					end
					4'd9: begin
						segments = 8'b00010000;
					end
					
					default: begin
						segments = 8'b11111111;
					end
				endcase
			end
		end
	end
endmodule
