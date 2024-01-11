module sevenSegDigit(
	/* TODO: Ports go here (refer to lab spec) */
	 input [3:0] inputNumber,
    input onOffSwitch,
	 output logic [7:0] digitResult
);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
	
		if (onOffSwitch == 1'b1) begin
			/* TODO: set your output bits */
			digitResult = 8'b11111111;
		end
		else begin
		/* TODO: your decimal number input */
			case (inputNumber)
			
				4'b0000: begin
					/* TODO: set your output bits */
					digitResult = 8'b11000000;
				end
				4'b0001: begin
					/* TODO: set your output bits */
					digitResult = 8'b11111001;
				end
				4'b0010: begin
					/* TODO: set your output bits */
					digitResult = 8'b10100100;
				end
				4'b0011: begin
					/* TODO: set your output bits */
					digitResult = 8'b10110000;
				end
				4'b0100: begin
					/* TODO: set your output bits */
					digitResult = 8'b10011001;
				end
				4'b0101: begin
					/* TODO: set your output bits */
					digitResult = 8'b10010010;
				end
				4'b0110: begin
					/* TODO: set your output bits */
					digitResult = 8'b10000010;
				end
				4'b0111: begin
					/* TODO: set your output bits */
					digitResult = 8'b11111000;
				end
				4'b1000: begin
					/* TODO: set your output bits */
					digitResult = 8'b10000000;
				end
				4'b1001: begin
					/* TODO: set your output bits */
					digitResult = 8'b10011000;
				end
				
				/* TODO: more cases */
				
				default: begin
					digitResult = 8'b11000000;	// this is the "catch-all" case 
					/* TODO: set your output bits */
				end
				
			endcase
		end
		
	end
endmodule
