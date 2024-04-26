module sevenSegDigit(input [3:0] decimalNum, output reg [7:0] dispBits);
	always_comb begin
		case (decimalNum)
			4'b0000: begin
				dispBits = 8'b11000000;
			end
			4'b0001: begin
				dispBits = 8'b11111001;
			end
			4'b0010: begin
				dispBits = 8'b10100100;
			end
			4'b0011: begin
				dispBits = 8'b10110000;
			end
			4'b0100: begin
				dispBits = 8'b10011001;
			end
			4'b0101: begin
				dispBits = 8'b10010010;
			end
			4'b0110: begin
				dispBits = 8'b10000010;
			end
			4'b0111: begin
				dispBits = 8'b11111000;
			end
			4'b1000: begin
				dispBits = 8'b10000000;
			end
			4'b1001: begin
				dispBits = 8'b10010000;
			end
			4'b1111: begin
				dispBits = 8'b11111111;
			end
			default: begin
				dispBits = 8'b11111111;
			end
		endcase
	end
	
endmodule