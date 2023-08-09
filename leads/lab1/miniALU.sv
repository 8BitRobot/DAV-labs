module miniALU(
	input  [3:0]  operand1,
	input  [3:0]  operand2,
	input         select,
	output [19:0] result
);

	// The following block will contain the logic of your combinational circuit
	always_comb begin
		if (select) begin
			result = operand1 + operand2;
		end else begin
			result = operand1 << operand2;
		end
	end
endmodule