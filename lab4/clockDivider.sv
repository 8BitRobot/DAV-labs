module clockDivider(input clock, output reg newClock);
	parameter SPEED = 100000;
	localparam frequency = 50000000 / SPEED;
	
	reg[18:0] counter = 0;
	always @(posedge clock) begin
		if (counter == (frequency)) begin
			counter = 0;
		end
		else begin
			counter = counter + 1;
		end
	
	end
	
	always_comb begin
		if (counter < (frequency/2)) begin
			newClock = 0;
		end
		else begin
			newClock = 1;
		end
	end
		
	
endmodule