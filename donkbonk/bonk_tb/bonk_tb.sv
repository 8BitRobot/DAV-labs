`timescale 1ns/1ns
module bonk_tb(clk);
	output logic clk;
	logic rst;
	logic [2:0] controls;
	logic [0:79] colorValues [0:11];
	logic [7:0] dataOut;
	logic [9:0] address;
	logic [5:0] x;
	logic [5:0] y;

	
	initial begin
		clk = 0;
		// newPiece = 0;
		controls = 3'b00;
	end
	
	always begin
		#10 clk = ~clk;
	end
	
	// gamecontroller game(clk, rst, controls, colorValues);
endmodule