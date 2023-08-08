module clockDivider #(BASE_SPEED=50000000) (clk, speed, reset, outClk);

	input clk;
	input [$clog2(1000000):0] speed;
	input reset;
	output reg outClk;
	
	reg [$clog2(1000000):0] currentSpeed = BASE_SPEED;
	reg [$clog2(BASE_SPEED)+1:0] counter = 0;
	wire [$clog2(BASE_SPEED)+1:0] threshold = BASE_SPEED / currentSpeed;
	
	//assign threshold = BASE_SPEED / currentSpeed;
	
	always @(posedge clk) begin
		if (reset || counter == threshold - 1) begin
			counter <= 0;
			currentSpeed <= speed;
		end else begin
			counter <= counter + 1;
		end
	end
	
	always_comb begin
		if (counter < threshold / 2) begin
			outClk = 0;
		end else begin
			outClk = 1;
		end
	end

endmodule