//Timescale specifies the clock frequency/period
`timescale 1ns/1ns

module fft_4point_tb(out0, out1, out2, out3, out0_16, out1_16, out2_16, out3_16);
reg clk;
reg reset;
reg start;

reg [31:0] in0;
reg [31:0] in1;
reg [31:0] in2;
reg [31:0] in3;
reg [15:0] in0_16;
reg [15:0] in1_16;
reg [15:0] in2_16;
reg [15:0] in3_16;

output [31:0] out0;
output [31:0] out1;
output [31:0] out2;
output [31:0] out3;
output [15:0] out0_16;
output [15:0] out1_16;
output [15:0] out2_16;
output [15:0] out3_16;
wire done;
wire done_16;


initial begin
	clk = 0;
	reset = 0;
	start = 1;
	in0 = 100;
	in1 = 200;
	in2 = 300;
	in3 = 400;
end

always begin
	#10
	clk = ~clk;
end

always @(posedge done) begin
	$display("Finished for 32 bit!");
	$display("Fr 0: imaginary: %d + real %d", $signed(out0[31:16]), $signed(out0[15:0]));
	$display("Fr 1: imaginary: %d + real %d", $signed(out1[31:16]), $signed(out1[15:0]));
	$display("Fr 2: imaginary: %d + real %d", $signed(out2[31:16]), $signed(out2[15:0]));
	$display("Fr 3: imaginary: %d + real %d", $signed(out3[31:16]), $signed(out3[15:0]));
end

always @(posedge done_16) begin
	$display("Finished for 16 bit!");
	$display("Fr 0: imaginary: %d + real %d", $signed(out0_16[15:8]), $signed(out0_16[7:0]));
	$display("Fr 1: imaginary: %d + real %d", $signed(out1_16[15:8]), $signed(out1_16[7:0]));
	$display("Fr 2: imaginary: %d + real %d", $signed(out2_16[15:8]), $signed(out2_16[7:0]));
	$display("Fr 3: imaginary: %d + real %d", $signed(out3_16[15:8]), $signed(out3_16[7:0]));
end

fft_4point_32bit UUT1(.clk(clk), .reset(reset), .start(start), .in0(in0), .in1(in1), .in2(in2), .in3(in3),
	.out0(out0), .out1(out1), .out2(out2), .out3(out3), .done(done));

fft_4point_16bit UUT2(.clk(clk), .reset(reset), .start(start), .in0(in0), .in1(in1), .in2(in2), .in3(in3), 
	.out0(out0_16), .out1(out1_16), .out2(out2_16), .out3(out3_16), .done(done_16));
endmodule
