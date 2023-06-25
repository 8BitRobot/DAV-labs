module clockDivider #(BASE_SPEED=200000000) (inClock, speed, reset, outClock);
	input inClock;
	input [19:0] speed;
	input reset;
	output reg outClock;
	// parameter SPEED = 100; //default of 100Hz
	integer counter = 0;
	wire [31:0] threshold = BASE_SPEED / (2 * speed);
    
	initial begin
		outClock = 0;
		counter = 0;
	end
	
	always@(posedge inClock) begin
		if(reset) begin
			counter <= 0;
			outClock <= 0;
		end
		else begin
			if(counter == threshold) begin
				outClock <= ~outClock;
				counter <= 0;
			end
			else begin
				counter <= counter + 1;
			end
		end
	end
endmodule