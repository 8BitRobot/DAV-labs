module buzzer_top (
	input in_clock,
	output logic buzzer_out
);

buzzer buzz (in_clock, 1, buzzer_out);

endmodule