module miniALU(input [3:0] operand1, input [3:0] operand2, input operation, output reg [23:0] result);
	always_comb begin
		case (operation)
			1'b0: begin
				result = operand1 + operand2;
			end
			1'b1: begin
				result = operand1 << operand2;
			end
		endcase
	end

endmodule