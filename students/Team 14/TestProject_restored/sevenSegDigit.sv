module sevenSegDigit(
	/* TODO: Ports go here (refer to lab spec) */
	input [3:0] number,
	input onOff,
   output reg [7:0] segments
    );

	 
	// The following block will contain the logic of your combinational circuit
	always_comb begin
		
		if (~onOff) begin
 			segments = 8'b11111111; 
		end
		else begin
			case (number)
				4'b0000: begin
					segments = 8'b11000000;
				end
				
				4'b0001: begin
					 segments = 8'b11111100;					
				end

			    4'b0010: begin
					 segments = 8'b10100100;
				end

				4'b0011: begin
					 segments = 8'b10110000;	
				end

				4'b0100: begin
					 segments = 8'b10011001;
				end			
				
				4'b0101: begin
					 segments = 8'b10010010;
				end

				4'b0110: begin
					 segments = 8'b10000011;				
				end

				4'b0111: begin
					segments = 8'b11111000;
				end

				4'b1000: begin
					 segments = 8'b10000000;
				end
				4'b1001: begin
					 segments = 8'b10011000;
				end
				default: begin
					segments = 8'b11111111;
				end
				
			endcase
		end
		
	end
endmodule
