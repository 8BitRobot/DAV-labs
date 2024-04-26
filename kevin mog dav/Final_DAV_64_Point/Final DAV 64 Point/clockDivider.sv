module clockDivider(input clock, output reg newClock, input reset);
	// Module outputs a variable frequency clock
	parameter RATE;
	parameter INPUT;
	localparam DIVIDER = (INPUT)/(RATE);
	localparam BITS = $clog2(DIVIDER); // 50MHz is the speed of the onboard clock
	reg [(BITS-1):0] counter = 0; // Initial value
	
	always@(posedge clock) begin
		counter <= (counter + 1) % DIVIDER; //Nonblocking assignment
	end
	
	always_comb begin
		if (reset == 1) begin // Reset button is ACTIVE LOW
			if(counter < DIVIDER/2) 
				newClock = 0;
			else
				newClock = 1;
		end
		else
			newClock = 0;
	end
endmodule