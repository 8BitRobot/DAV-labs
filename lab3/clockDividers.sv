module clockDivider100hz(input clock, output reg newClock);

	reg [18:0] counter = 0;
	always @(posedge clock) begin
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

module clockDividerFlash(input clock, output reg newClock);
	reg [31:0] counter = 0;
	always @(posedge clock) begin
		if (counter == 50000000) begin
			counter = 0;
		end
		else begin
			counter = counter + 1;
		end
	end
	
	always_comb begin
		if (counter < 25000000) begin
			newClock = 0;
		end
		else begin
			newClock = 1;
		end
	end
endmodule

module clockDividerBuzzer(input clock, output reg newClock);
// 420 Hz
	reg [31:0] counter = 0;
	always @(posedge clock) begin
		if (counter == 238080) begin
			counter = 0;
		end
		else begin
			counter = counter + 1;
		end
	end
	
	always_comb begin
		if (counter < 119040) begin
			newClock = 0;
		end
		else begin
			newClock = 1;
		end
	end
endmodule