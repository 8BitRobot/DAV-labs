//Timescale specifies the clock frequency/period
`timescale 1ns/1ns

module fft_16point_tb(outputs);
reg clk;
reg reset;
reg start;

reg [35:0] inputs [0:15];
output [35:0] outputs [0:15];

wire done;
// wire done_16;

initial begin
	clk = 0;
	reset = 0;
	start = 1;
	inputs[0] = {18'd100, 18'b0};
	inputs[1] = {18'd100, 18'b0};
	inputs[2] = {18'd100, 18'b0};
	inputs[3] = {18'd100, 18'b0};
	inputs[4] = {18'd200, 18'b0};
	inputs[5] = {18'd200, 18'b0};
	inputs[6] = {18'd200, 18'b0};
	inputs[7] = {18'd200, 18'b0};
	inputs[8] = {18'd300, 18'b0};
	inputs[9] = {18'd300, 18'b0};
	inputs[10] = {18'd300, 18'b0};
	inputs[11] = {18'd300, 18'b0};
	inputs[12] = {18'd400, 18'b0};
	inputs[13] = {18'd400, 18'b0};
	inputs[14] = {18'd400, 18'b0};
	inputs[15] = {18'd400, 18'b0};
end

always begin
	#10
	clk = ~clk;
end

always @(posedge done) begin
	$display("Finished for 36 bit!");
// 	$display("Fr 0: imaginary: %d + real %d", $signed(out0[31:16]), $signed(out0[15:0]));
// 	$display("Fr 1: imaginary: %d + real %d", $signed(out1[31:16]), $signed(out1[15:0]));
// 	$display("Fr 2: imaginary: %d + real %d", $signed(out2[31:16]), $signed(out2[15:0]));
// 	$display("Fr 3: imaginary: %d + real %d", $signed(out3[31:16]), $signed(out3[15:0]));
end

fft_16point_36bit UUT1(.clk(clk), .reset(reset), .start(start), .inputs(inputs), .outputs(outputs), .done(done));

// fft_4point_16bit UUT2(.clk(clk), .reset(reset), .start(start), .in0(in0), .in1(in1), .in2(in2), .in3(in3), 
// 	.out0(out0_16), .out1(out1_16), .out2(out2_16), .out3(out3_16), .done(done_16));
endmodule
