`timescale 1ns/1ns
module mmu_tb();
	reg clk;
	
	initial begin
		clk = 0;
	end
	
	reg [15:0] A [0:3][0:3] = '{'{0,1,2,3},'{4,5,6,7},'{8,9,0,1},'{2,3,4,5}};
	reg [15:0] B [0:3][0:3] = '{'{1,2,1,2},'{2,4,2,4},'{1,2,1,2},'{2,4,2,4}};

	reg [15:0] M [0:3][0:3];
	reg [15:0] M2 [0:3][0:3];
	
	reg source_ready = 0;
	reg input_valid = 0;
	
	wire sink_ready;
	wire output_valid;

	initial begin
		#50;
		input_valid = 1;
		#10;
		input_valid = 0;
	end

	always begin
		#5 clk = ~clk;
		if (output_valid) $stop;
	end
	
	matrix_4_multiply mmu(
		clk,
		source_ready,
		input_valid,
		A,
		B,
		M,
		sink_ready,
		output_valid
	);
endmodule