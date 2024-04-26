module miniALU(
	input [3:0] operand1,
	input [3:0] operand2,
	input select,
	output logic [19:0] result
);
	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Depending on the value of your select bit, output the result of a different operation.
		 * Refer to the lab spec for details. 
		 */
		if (select == 1'b1)
			result = operand1 + operand2;
		else
			result = operand1 << operand2;
		
	end
endmodule