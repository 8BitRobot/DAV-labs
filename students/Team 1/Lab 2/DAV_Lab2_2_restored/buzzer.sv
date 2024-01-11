module buzzer (
	input in_clock,
	input reset,
	output logic buzzer_out
);

clockDivider clkDiv (in_clock, 440, reset, buzzer_out);

endmodule