module nes_controller(
	input nes_clock, 
	input nes_data, 
	output logic nes_latch, 
	output logic [7:0] controls
);	
	// divide the NES clock here to determine when to pulse the latch :)
	clockDivider #(1000000) PollingClock(nes_clock, 80000, 0, polling_clock); // 80 kHz
	
	logic polling_clock;
	logic [1:0] polling_clock_sr = 2'b0;
	
	logic reading = 0;
	logic [2:0] read_count = 0;
	
	logic [7:0] controls_read = 8'b0;
	
	always @(posedge nes_clock) begin
		// capture the edge of the polling clock
		polling_clock_sr <= { polling_clock_sr[0], polling_clock };
		
		// if it's time to poll (i.e. if the polling clock has a posedge),
		// raise LATCH
		if (polling_clock_sr == 2'b01) begin
			nes_latch <= 1;
		end
		// otherwise, lower LATCH and enable DATA reading
		else begin
			if (nes_latch == 1) begin
				reading <= 1;
			end
			nes_latch <= 0;
		end
		
		// if we're supposed to read from the controller (i.e. 8 bits
		// not yet consumed), do so and increment the read count
		if (reading) begin
			read_count <= read_count + 1;
			controls_read[read_count] <= nes_data;
			
			if (read_count == 7) begin
				reading <= 0;
			end
		end
	end
	
	// a button press also triggers the bit next to it for some reason,
	// so we must take an extra step to decode it
	always_comb begin
		controls[0] = controls_read == 8'b11111110;
		controls[1] = controls_read == 8'b11111100;
		controls[2] = controls_read == 8'b11111001;
		controls[3] = controls_read == 8'b11110011;
		controls[4] = controls_read == 8'b11100111;
		controls[5] = controls_read == 8'b11001111;
		controls[6] = controls_read == 8'b10011111;
		controls[7] = controls_read == 8'b00111111;
	end
endmodule