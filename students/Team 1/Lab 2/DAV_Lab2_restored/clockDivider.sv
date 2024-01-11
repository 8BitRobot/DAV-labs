module clockDivider #(BASE_SPEED=50000000) (
	input clk, // clk input has a speed of BASE_SPEED
	input[$clog2(50000000):0] speed,
	input reset,
	output logic outClk
);

	reg[$clog2(BASE_SPEED / 1000000):0] counter;

	initial begin
		counter = 'd0;
	end
	
	always@(posedge clk) begin
	
		counter <= counter + 'd1;
		
		if ((counter >= (BASE_SPEED / speed) - 1) || (reset == 1'b0)) begin
		
			counter <= 'd0;
			
		end
	
	end
	
	always_comb begin
	
		if (counter < (BASE_SPEED / speed) / 2) begin
		
			outClk = 1'b0;
			
		end else begin
		
			outClk = 1'b1;
			
		end
		
	end

endmodule