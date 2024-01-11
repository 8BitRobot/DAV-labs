module alarmClock_top(
	input base_clock,
	input reset,
	input start_stop,
	input [9:0] switches,
	output logic [47:0] disp,
	output logic buzzer_out
);

logic clock;
logic[9:0] counter;
logic disp_flash;
logic buzzer_onoff;
logic [8:0] speed;

clockDivider #(50000000) clk_div (base_clock, speed, reset, clock);
alarmController alarm_ctrl (clock, switches[9:1], reset, start_stop, disp_flash, counter, buzzer_onoff);
//sevenSegDisplay time_display (counter, disp_flash, disp);
sevenSegDisplay time_display (counter, 1, disp);
buzzer bzz (base_clock, buzzer_onoff, buzzer_out);

always_comb begin
	if (switches[0] == 1'b1) begin
		speed = 'd100; // centisecond clock (100 Hz)
	end else begin
		speed = 'd200; // double pace (200 Hz)
	end
end

endmodule