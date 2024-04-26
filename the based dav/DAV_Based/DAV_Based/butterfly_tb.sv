//Timescale specifies the clock frequency/period
`timescale 1 ns/1 ns

module butterfly_tb(out_Add, out_Sub);
reg clk;

reg [15:0] a;
reg [15:0] b;
reg [15:0] twiddle;

output [15:0] out_Add;
output [15:0] out_Sub;

wire done;

initial begin
	clk = 0;

	a = 16'b0000001100000000;
	b = 16'b0000011100000000;
	twiddle = 16'b0111111100000000;
end

always begin
	#10
	clk = ~clk;
end

always @(posedge done) begin
$display("Finished for 16 bit!");
$display("out_Add: real: %d + imag %d", $signed(out_Add[15:8]), $signed(out_Add[7:0]));
$display("out_Sub: real: %d + imag %d", $signed(out_Sub[15:8]), $signed(out_Sub[7:0]));

end

butterflyUnit #(.WIDTH(16)) UUT1(a, b, twiddle, out_Add, out_Sub, done);

endmodule
