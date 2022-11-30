module clockDivider100hz(input clock, output reg newClock);

	reg [18:0] counter = 0;
	always @(posedge clock) begin
		/*if (enable) begin
			counter = 1;
		end
		else*/
		if (counter == 500000) begin
			counter = 0;
		end
		else begin
			counter = counter + 1;
		end
	end
	
	always_comb begin
		if (counter == 0) begin
			newClock = 1;
		end
		else begin
			newClock = 0;
		end
	end
endmodule

module clockDivider200hz(input clock, input enable, output reg newClock);
	reg [17:0] counter = 0;
	always @(posedge clock) begin
		if (enable) begin
			counter = 1;
		end
		else if (counter == 250000) begin
			counter = 0;
		end
		else begin
			counter = counter + 1;
		end
	end
	
	always_comb begin
		if (counter == 0) begin
			newClock = 1;
		end
		else begin
			newClock = 0;
		end
	end
endmodule