module clockDivider(input inClock, output reg outClock, input reset);
	parameter SPEED = 100; //default of 100Hz
	integer counter = 0;
	localparam threshold = 50000000 / (2*SPEED);
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
			counter <= counter + 1;
			if(counter == threshold) begin
				outClock <= ~outClock;
				counter <=0;
			end
		end
	end
endmodule