//Timescale specifies the clock frequency/period
`timescale 1 ns/1 ns

module fft_16point_tb(out);
reg clk;
reg reset;
reg start;
reg signed [31:0] in [15:0];

output signed [31:0] out [15:0];
wire done;
integer i;
reg [15:0] temp;

initial begin
	clk = 0;
	reset = 0;
	start = 1;
	
	for (i = 0; i < 16; i++) begin
		temp = i*100;
		in[i] = {temp, 16'd0};
	end
	
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
for (i = 0; i < 16; i++) begin
		$display("Fr %d: real: %d + imaginary %d", i, $signed(out[i][31:16]), $signed(out[i][15:0]));
	end

end
fft_16point_32bit UUT1(.clk(clk), .reset(reset), .start(start), .in(in), .out(out), .done(done));
endmodule
