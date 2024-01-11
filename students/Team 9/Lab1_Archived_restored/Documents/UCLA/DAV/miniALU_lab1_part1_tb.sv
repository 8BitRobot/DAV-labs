`timescale 1ns/1ns

module miniALU_lab1_part1_tb(output [19:0] outputResult);

	 reg [3:0] inputA;
    reg [3:0] inputB;
    reg operationSelect;
	 
	 miniALU HI(inputA, inputB, operationSelect, outputResult);
	 
	 initial begin
		inputA = 4'b0;
		inputB = 4'b0;
		operationSelect = 1'b0;
		
		for (integer i = 0; i < 16; i = i + 1) begin
			for (integer j = 0; j < 16; j = j + 1)  begin
				inputA = inputA + i;
				inputB = inputB + j;
				#5; // simulation delay
			end
		end
		
		inputA = 4'b0;
		inputB = 4'b0;
		operationSelect = 1'b1;
		
		for (integer i = 0; i < 16; i = i + 1) begin
			for (integer j = 0; j < 16; j = j + 1)  begin
				inputA = inputA + i;
				inputB = inputB + j;
				#5; // simulation delay
			end
		end
		
		$stop;
	 end

		
endmodule

