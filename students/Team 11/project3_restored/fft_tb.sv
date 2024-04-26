`timescale 1ns/1ns

module fft_tb(
	output reg clk
);

	reg [31:0] samples_32 [0:3];
	wire [31:0] frequencies_32 [0:3];
	reg [15:0] samples_16 [0:3];
	wire [15:0] frequencies_16 [0:3];
	reg reset;
	reg start;
	wire done;
	
	fft32 UUT32 (
		samples_32,
		clk,
		reset,
		start,
		frequencies_32,
		done
	);
	
	fft16 UUT16 (
		samples_16,
		clk,
		reset,
		start,
		frequencies_16,
		done
	);

	initial begin
		clk = 0;
		reset = 0;
		start = 0;
		
		samples_32[0] = {16'd100, 16'd0};
		samples_32[1] = {16'd150, 16'd0};
		samples_32[2] = {16'd200, 16'd0};
		samples_32[3] = {16'd250, 16'd0};
		
		samples_16[0] = {8'd10, 8'd0};
		samples_16[1] = {8'd15, 8'd0};
		samples_16[2] = {8'd20, 8'd0};
		samples_16[3] = {8'd25, 8'd0};
		

		#100 start = 1;
	end
	
	always begin
		#5 clk = ~clk;
		
		if (done) begin
			$stop;
		end
	end

endmodule