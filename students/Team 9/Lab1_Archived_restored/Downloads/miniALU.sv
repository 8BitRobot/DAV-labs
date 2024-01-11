module miniALU(
	 input [3:0] inputA,
    input [3:0] inputB,
    input operationSelect,
    output reg [19:0] outputResult
);

	
	// The following block will contain the logic of your combinational circuit
	always_comb begin
		/* TODO: Depending on the value of your select bit, output the result of a different operation.
		 * Refer to the lab spec for details. 
		 */
		 case (operationSelect)
        1'b0: // Addition
            outputResult = {1'b0, inputA} + {1'b0, inputB};
        1'b1: // Left Shift
            outputResult = {16'b0, inputA} << inputB;
		 endcase
		 
	end
endmodule