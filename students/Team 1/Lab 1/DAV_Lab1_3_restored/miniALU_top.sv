`timescale 1ns/1ns

module miniALU_top(input [9:0] switches, output [41:0] disp);

	reg [19:0] res;

	miniALU alu(switches[9:6], switches[5:2], switches[1], res);
	sevenSegDisplay sevSegDisp(res, switches[0], disp);

endmodule