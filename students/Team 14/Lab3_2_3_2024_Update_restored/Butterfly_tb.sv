`timescale 1ns / 1ns

module Butterfly_tb 
(
	output[9:0] Outcome1, output[9:0] Outcome2
);

	logic [4:0] realA, imagA, realB, imagB, realW, imagW;
	logic [9:0] A, B, W;
	
	getComplexNum #(10) A_getter(.realPart(realA), .imagPart(imagA), .result(A) );
	getComplexNum #(10) B_getter(.realPart(realB), .imagPart(imagB), .result(B) );
	getComplexNum #(10) W_getter(.realPart(realW), .imagPart(imagW), .result(W) );
	Butterfly #(10) getStreams(.A(A), .B(B), .W(W), .sum(Outcome1), .diff(Outcome2));

	initial begin
		realA = 1;
		imagA = 4;
		realB = 2;
		imagB = 1;
		realW = 1;
		imagW = 1;
		
		#100
		
		realA = 0;
		imagA = 0;
		realB = 0;
		imagB = 0;
		realW = 0;
		imagW = 0;
		
	end

endmodule