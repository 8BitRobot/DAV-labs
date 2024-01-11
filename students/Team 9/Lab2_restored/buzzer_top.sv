module buzzer_top(input clock, input reset, output logic buzzer);
	 
	logic [25:0] speed_test = 'd1000;
	
	clock_divider BUZZ(clock, ~reset, speed_test, buzzer);
	
endmodule