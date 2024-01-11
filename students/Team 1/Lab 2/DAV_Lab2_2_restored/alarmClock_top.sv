module alarmClock_top(
	input base_clock,
	input reset,
	input start_stop,
	input [9:0] switches,
	output logic [47:0] disp,
	output logic buzzer_out
);

logic clock;
logic[13:0] counter;
logic disp_flash;
logic buzzer_onoff;
//logic [8:0] speed;
logic [30:0] speed;

clockDivider #(50000000) clk_div (base_clock, speed, 1, clock);
alarmController alarm_ctrl (clock, switches[9:1], reset, start_stop, disp_flash, counter, buzzer_onoff);
sevenSegDisplay time_display (counter, 1, disp);
buzzer bzz (base_clock, buzzer_onoff, buzzer_out);

always_comb begin
	if (switches[0] == 1'b1) begin
		//speed = 'd5000000; // centisecond clock (100 Hz)
		speed = 'd50; // centisecond clock (100 Hz)
	end else begin
		//speed = 'd10000000; // double pace (200 Hz)
		speed = 'd100; // double pace (200 Hz)
	end // CHANGE BACK TO 'd100 AND 'd200 FOR REAL MODEL
end

endmodule