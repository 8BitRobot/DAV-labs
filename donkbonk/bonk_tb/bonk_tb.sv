`timescale 1ns/1ns
module bonk_tb(colorValues);
	reg clk;
	reg newPieceTrigger;
   reg [1:0] controls;
	output logic [0:79] colorValues [0:11];
	
	initial begin
		clk = 0;
		newPieceTrigger = 0;
		controls = 2'b00;
	end
	
	always begin
		#10 clk = ~clk;
	end
	
	gamecontroller gamermoment(clk, newPieceTrigger, controls, colorValues);
endmodule