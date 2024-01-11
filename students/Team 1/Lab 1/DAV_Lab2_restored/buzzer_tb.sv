`timescale 1ns/1ns

module buzzer_tb(output logic buzzer_out);

	logic in_clock;
	
	initial begin
		in_clock = 0;
	end
	
	always begin
		#5 in_clock = ~in_clock;
	end

	buzzer_top UUT(
		in_clock,
		buzzer_out
	);
endmodule