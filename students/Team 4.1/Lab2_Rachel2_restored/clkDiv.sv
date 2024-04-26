module clkDiv #(parameter BASE_SPEED = 50000000) (
	input clk, 
	input [$clog2(BASE_SPEED):0] speed, // speed switch (high means speed twice as fast)
	input reset, 
	output logic outClk
);

	logic [26:0] counter = 0; 
	logic [26:0] counter_d;
	logic outClk_d; 
	
	always_comb begin
		if (reset || counter <= ((BASE_SPEED/speed) - 1)/2) begin
			outClk_d = 0;
		end
		else begin
			outClk_d = 1;
		end
		  
		if (reset || counter == (BASE_SPEED/speed) - 1) begin
			counter_d = 0;
		end
		else begin
			counter_d = counter + 1;
		end
		// speed = 200 (multiply by 2)
	end
	
	always @(posedge clk) begin
		outClk <= outClk_d;
		counter <= counter_d;
	end

endmodule