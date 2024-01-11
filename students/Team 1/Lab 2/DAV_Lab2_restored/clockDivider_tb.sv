`timescale 1ns/1ns

module clockDivider_tb (
	output logic out_clock
);

reg base_clock = 0;
reg pause = 1;
reg reset = 1;
reg [9:0] switches = 0;
wire [47:0] disp;
wire buzzer_out;

alarmClock_top UUT (
	base_clock,
	reset,
	start_stop,
	switches,
	disp,
	buzzer_out
);

always begin
	#10 base_clock = ~base_clock;
end

endmodule