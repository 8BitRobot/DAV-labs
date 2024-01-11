module miniALU(
	/* TODO: Ports go here (refer to lab spec) */
	input [3:0] op1, 
	input [3:0] op2, 
	input sel, 
	output reg [19:0] out
);
	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Depending on the value of your select bit, output the result of a different operation.
		 * Refer to the lab spec for details. 
		 */
		if (sel == 1'b1)
			out = op1 + op2;
		else
			out = op1 << op2;
	end
endmodule