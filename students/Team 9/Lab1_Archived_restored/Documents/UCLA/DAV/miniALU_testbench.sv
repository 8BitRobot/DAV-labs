`timescale 1ns/1ns

module miniALU_testbench(output [47:0] display);

	 reg [19:0] outputResult;
	 reg onorOff;
	
	 sevenSegDisplay BYE(outputResult, onOff, display);
	 
	 initial begin
		outputResult = 20'b00000000000000000000;
		onorOff = 1'b1;
		
		for (integer i = 0; i < 16; i = i + 1) begin
				outputResult = outputResult + i;
				#5; // simulation delay
		end
		
		
		$stop;
	 end

		
endmodule

