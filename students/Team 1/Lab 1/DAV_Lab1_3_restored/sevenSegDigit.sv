module sevenSegDigit(
	/* TODO: Ports go here (refer to lab spec) */
	input [3:0] num,
	input onoff,
	output reg [7:0] segments
	
);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
	
		if (/* TODO: what if your display "on-switch" is off? */onoff == 1'b0) begin
			/* TODO: set your output bits */
			segments = 8'b11111111; // active low display
		end
		else begin
			case (/* TODO: your decimal number input */ num)
			
				4'b0000: begin
					/* TODO: set your output bits */
					segments = 8'b11000000; // 0
				end
				4'b0001: begin
					segments = 8'b11111001; // 1
				end
				
				/* TODO: more cases */
				4'b0010: begin
					segments = 8'b10100100; // 2
				end
				4'b0011: begin
					segments = 8'b10110000; // 3
				end
				4'b0100: begin
					segments = 8'b10011001; // 4
				end
				4'b0101: begin
					segments = 8'b10010010; // 5
				end
				4'b0110: begin
					segments = 8'b10000010; // 6
				end
				4'b0111: begin
					segments = 8'b11111000; // 7
				end
				4'b1000: begin
					segments = 8'b10000000; // 8
				end
				4'b1001: begin
					segments = 8'b10011000; // 9
				end
				
				default: begin // this is the "catch-all" case 
					/* TODO: set your output bits */
					segments = 8'b10110110; // failure state pattern
				end
				
			endcase
		end
		
	end
endmodule
