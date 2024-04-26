module clockDivider #(BASE_SPEED=50000000) (
	input inClock,
	input [19:0] speed,
	input reset,
	output reg outClock
);

	reg outClock_d;
	
	reg [31:0] counter = 0;
	reg [31:0] counter_d;
	
	wire [31:0] threshold = BASE_SPEED / speed;
    
	initial begin
		outClock = 0;
	end
	
	always@(posedge inClock) begin
		counter <= counter_d;
		outClock <= outClock_d;
	end
	
	always_comb begin
		if (reset || counter == threshold / 2) begin
			counter_d = 0;
		end else begin
			counter_d = counter + 1;
		end
		
		if (reset) begin
			outClock_d = 0;
		end else if (counter == threshold / 2 || counter == threshold) begin
			outClock_d = ~outClock;
		end else begin
			outClock_d = outClock;
		end
	end
endmodule