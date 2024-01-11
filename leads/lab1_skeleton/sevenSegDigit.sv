module sevenSegDigit(
	/* TODO: Ports go here (refer to lab spec) */
);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
	
		if (/* TODO: what if your display "on-switch" is off? */) begin
			/* TODO: set your output bits */
		end
		else begin
			case (/* TODO: your decimal number input */)
			
				4'b0000: begin
					/* TODO: set your output bits */
				end
				4'b0001: begin
					/* TODO: set your output bits */
				end
				
				/* TODO: more cases */
				
				default: begin // this is the "catch-all" case 
					/* TODO: set your output bits */
				end
				
			endcase
		end
		
	end
endmodule
