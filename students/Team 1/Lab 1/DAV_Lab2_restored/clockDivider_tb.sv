`timescale 1ns/1ns

module clock_divider_tb (
	output logic out_clock
);

reg clock;
reg reset;
clockDivider #(50000000) UUT (clock, 10000000, reset, out_clock);

initial begin
	clock = 1'b0;
	#10000 $stop;
	
	reset = 1'b0;
end

always begin
	#10 clock = ~clock;
end

endmodule