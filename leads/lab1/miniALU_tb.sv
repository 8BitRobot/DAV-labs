`timescale 1ns/1ns
module miniALU_tb_0(
	output [9:0] leds
);
	
	reg [9:0] switches;

	miniALU_top UUT(switches, leds);
	
	initial begin
		switches = 10'b0000000100;
		
		#5;
		
		switches = 10'b0000001001;
		
		#5;
		
		switches = 10'b0000000001;
	end

endmodule

module miniALU_tb_1(
	output [19:0] calcResult
);

	reg [3:0] operand1;
	reg [3:0] operand2;
	reg select;
	
	miniALU UUT(operand1, operand2, select, calcResult);
	
	reg [9:0] switches;
	initial begin
		for (integer i = 0; i < 16; i = i + 1) begin
			operand1 = i;
			
			for (integer j = 0; j < 16; j = j + 1) begin
				#5;
				operand2 = j;
			end
			
			#5;
			select = ~select;
			
			for (integer j = 0; j < 16; j = j + 1) begin
				#5;
				operand2 = j;
			end
			
			#5;
			select = ~select;
		end
	end
	
	miniALU_top mat(switches, leds);
endmodule