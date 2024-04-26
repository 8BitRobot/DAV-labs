module sevenSegDigit(
	input [3:0] number,
   input switch,
   output reg [7:0] segments
);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
	
		if (switch == 1'b0) begin
			segments[0] = 1'b1;
			segments[1] = 1'b1;
			segments[2] = 1'b1;
			segments[3] = 1'b1;
			segments[4] = 1'b1;
			segments[5] = 1'b1;
			segments[6] = 1'b1;
			segments[7] = 1'b1;
		end
		else begin
			case (number)
			
				4'b0000: begin
					segments[0] = 1'b0;
					segments[1] = 1'b0;
					segments[2] = 1'b0;
					segments[3] = 1'b0;
					segments[4] = 1'b0;
					segments[5] = 1'b0;
					segments[6] = 1'b1;
					segments[7] = 1'b1;
				end
				4'b0001: begin
					segments[0] = 1'b1;
					segments[1] = 1'b0;
					segments[2] = 1'b0;
					segments[3] = 1'b1;
					segments[4] = 1'b1;
					segments[5] = 1'b1;
					segments[6] = 1'b1;
					segments[7] = 1'b1;
				end
				4'b0010: begin
					segments[0] = 1'b0;
					segments[1] = 1'b0;
					segments[2] = 1'b1;
					segments[3] = 1'b0;
					segments[4] = 1'b0;
					segments[5] = 1'b1;
					segments[6] = 1'b0;
					segments[7] = 1'b1;
				end
				4'b0011: begin
					segments[0] = 1'b0;
					segments[1] = 1'b0;
					segments[2] = 1'b0;
					segments[3] = 1'b0;
					segments[4] = 1'b1;
					segments[5] = 1'b1;
					segments[6] = 1'b0;
					segments[7] = 1'b1;
				end
				4'b0100: begin
					segments[0] = 1'b1;
					segments[1] = 1'b0;
					segments[2] = 1'b0;
					segments[3] = 1'b1;
					segments[4] = 1'b1;
					segments[5] = 1'b0;
					segments[6] = 1'b0;
					segments[7] = 1'b1;
				end
				4'b0101: begin
					segments[0] = 1'b0;
					segments[1] = 1'b1;
					segments[2] = 1'b0;
					segments[3] = 1'b0;
					segments[4] = 1'b1;
					segments[5] = 1'b0;
					segments[6] = 1'b0;
					segments[7] = 1'b1;
				end
				4'b0110: begin
					segments[0] = 1'b0;
					segments[1] = 1'b1;
					segments[2] = 1'b0;
					segments[3] = 1'b0;
					segments[4] = 1'b0;
					segments[5] = 1'b0;
					segments[6] = 1'b0;
					segments[7] = 1'b1;
				end
				4'b0111: begin
					segments[0] = 1'b0;
					segments[1] = 1'b0;
					segments[2] = 1'b0;
					segments[3] = 1'b1;
					segments[4] = 1'b1;
					segments[5] = 1'b1;
					segments[6] = 1'b1;
					segments[7] = 1'b1;;
				end
				4'b1000: begin
					segments[0] = 1'b0;
					segments[1] = 1'b0;
					segments[2] = 1'b0;
					segments[3] = 1'b0;
					segments[4] = 1'b0;
					segments[5] = 1'b0;
					segments[6] = 1'b0;
					segments[7] = 1'b1;
				end
				4'b1001: begin
					segments[0] = 1'b0;
					segments[1] = 1'b0;
					segments[2] = 1'b0;
					segments[3] = 1'b0;
					segments[4] = 1'b1;
					segments[5] = 1'b0;
					segments[6] = 1'b0;
					segments[7] = 1'b1;
				end
				default: begin // this is the "catch-all" case 
					segments[0] = 1'b1;
					segments[1] = 1'b1;
					segments[2] = 1'b1;
					segments[3] = 1'b1;
					segments[4] = 1'b1;
					segments[5] = 1'b1;
					segments[6] = 1'b0;
					segments[7] = 1'b1;
				end
				
			endcase
		end
		
	end
endmodule
