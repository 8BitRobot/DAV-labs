module sampling_buffer_32(sampling_clock, vsync, adc_in, samples_out, done);
	parameter POINTS = 32;
	input sampling_clock; // When to sample
	input vsync; // When to start sampling
	input [11:0] adc_in; // Wire ADC into sampling module
	
	output reg [11:0] samples_out [POINTS-1:0]; // Output of sampling module
	
	reg [11:0] samples_internal [POINTS-1:0];
	reg [$clog2(POINTS):0] sample_counter = 0;	
	output wire done;
	
	assign done = (sample_counter > POINTS-1) ? 1 : 0;
	
	always @ (posedge done) begin
		samples_out <= samples_internal;
	end
	
	always @ (posedge sampling_clock) begin // Incrememnt counter every sampling clock edge
		if (vsync == 0) begin // During vsync, reset the counter
			sample_counter <= 0;
		end
		else if (vsync == 1) begin
			if (done == 0) begin // Sampling not done
				sample_counter <= sample_counter + 1; // Increment counter
				samples_internal[sample_counter] <= adc_in; 
			end
			else if (done == 1) begin
				sample_counter <= POINTS;
			end
		end
	end
	
endmodule	