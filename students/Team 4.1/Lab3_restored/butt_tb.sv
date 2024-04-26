`timescale 1ns/1ns
module butt_tb #(parameter WIDTH=32) (
	output signed [(WIDTH - 1):0] out1, // A+BW
	output signed [(WIDTH - 1):0] out2 // A-BW
);	
	reg signed [(WIDTH - 1):0] a;
	reg signed [(WIDTH - 1):0] b; 
	reg signed [(WIDTH - 1):0] w;
	
	butt UUT(a, b, w, out1, out2);
	
	initial begin
		#10;
		a = 32'b00000000010000000000000001000000;
		b = 32'b00000000010000000000000001000000;
		w = 32'b00000000000000010000000000000001;
	end
	
endmodule