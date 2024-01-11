//module clockDivider #(BASE_SPEED=500000000) (
module clockDivider #(BASE_SPEED=50000000) (
	input clk, // clk input has a speed of BASE_SPEED
	//input[$clog2(50000000):0] speed,
	//input[8:0] speed,
	input[30:0] speed,
	input reset,
	output logic outClk
);

	//reg[$clog2(BASE_SPEED / 1000000):0] counter;
	reg[30:0] counter;
	
	reg outClk_d;

	initial begin
		counter = 'd0;
	end
	
	always@(posedge clk) begin
	
		outClk <= outClk_d;
		
		if ((counter >= (BASE_SPEED / speed) - 1) || (reset == 1'b0)) begin
			counter <= 'd0;
		end else begin
			counter <= counter + 'd1;
		end
	
	end
	
	always_comb begin
	
		if (counter < (BASE_SPEED / speed) / 2) begin
		
			outClk_d = 1'b0;
			
		end else begin
		
			outClk_d = 1'b1;
			
		end
		
	end

endmodule