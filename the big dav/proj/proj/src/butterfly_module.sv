`timescale 1ns/1ns

module TwiddleMultiplier(number, twiddleShift, result);

	input [47:0] number, twiddleShift;
	output [47:0] result;
		
	wire signed [23:0] twiddleShiftR;
	wire signed [23:0] twiddleShiftI;
	wire signed [23:0] NumberR;
	wire signed [23:0] NumberI;
	
	wire signed [47:0] interRR;
	wire signed [47:0] interRI;
	wire signed [47:0] interIR;
	wire signed [47:0] interII;
	
	assign twiddleShiftR = twiddleShift[47:24];
	assign twiddleShiftI = twiddleShift[23:0];
	assign NumberR = number[47:24];
	assign NumberI = number[23:0];
	
	assign interRR = NumberR * twiddleShiftR;
	assign interRI = NumberR * twiddleShiftI;
	assign interIR = NumberI * twiddleShiftR;
	assign interII = NumberI * twiddleShiftI;
	
	assign result[47:24] = interRR[46:23] - interII[46:23];
	assign result[23:0]  = interRI[46:23] + interIR[46:23];
	
endmodule

module butterfly_module(num1, num2, twiddle, result1, result2);

	input [47:00] num1, num2, twiddle;
	output [47:00] result1, result2;
	
	wire [23:00] result1r, result2r;
	wire [23:00] result1i, result2i;
	
	wire [47:0] multResult;
	
	TwiddleMultiplier multiplier(num2, twiddle, multResult);
	
	assign result1[47:24] = num1[47:24] + multResult[47:24];
	assign result1[23:00] = num1[23:00] + multResult[23:00];
	
	assign result2[47:24] = num1[47:24] - multResult[47:24];
	assign result2[23:00] = num1[23:00] - multResult[23:00];
	
endmodule 