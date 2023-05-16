`timescale 1ns/1ns
module bonk_tb(newPiece);
	logic clk;
	output logic newPiece;
	logic [2:0] controls;
	logic [0:79] colorValues [0:11];
	logic [0:9] leds;
    logic [7:0] seg [5:0];

	
	initial begin
		clk = 0;
		newPiece = 0;
		controls = 3'b00;
	end
	
	always begin
		#10 clk = ~clk;
	end
	
	gamecontroller gamermoment(clk, newPiece, controls, colorValues, leds, seg);
endmodule