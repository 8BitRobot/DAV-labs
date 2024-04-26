//Timescale specifies the clock frequency/period
`timescale 1 ns/1 ns

module fft_4point_tb(out0, out1, out2, out3);
reg clk;
reg reset;
reg start;
reg [31:0] in0;
reg [31:0] in1;
reg [31:0] in2;
reg [31:0] in3;

output [31:0] out0;
output [31:0] out1;
output [31:0] out2;
output [31:0] out3;
wire done;

initial begin
		clk = 0;
	reset = 0;
	start = 1;
	in0 = {16'd100, 16'd0};
	in1 = {16'd200, 16'd0};
	in2 = {16'd300, 16'd0};
	in3 = {16'd400, 16'd0};
	#20 start = 0;
	#100 start = 1;
	#20 start = 0;
	#100 start = 1;
	#20 start = 0;
	#100 start = 1;
	$stop;
end

always begin
	#10
	clk = ~clk;
end

always @(posedge done) begin
$display("Finished for 32 bit!");
$display("Fr 0: real: %d + imaginary %d", $signed(out0[31:16]), $signed(out0[15:0]));
$display("Fr 1: real: %d + imaginary %d", $signed(out1[31:16]), $signed(out1[15:0]));
$display("Fr 2: real: %d + imaginary %d", $signed(out2[31:16]), $signed(out2[15:0]));
$display("Fr 3: real: %d + imaginary %d", $signed(out3[31:16]), $signed(out3[15:0]));
end
fft_4point_32bit UUT1(.clk(clk), .reset(reset), .start(start), .in0(in0), .in1(in1), .in2(in2), .in3(in3),
	.out0(out0), .out1(out1), .out2(out2), .out3(out3), .done(done));
endmodule
