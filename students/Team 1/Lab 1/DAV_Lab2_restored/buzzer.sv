module buzzer (
	input in_clock,
	input reset,
	output logic buzzer_out
);

clockDivider #(50000000) clkDiv (in_clock, 'd440, reset, buzzer_out);

endmodule