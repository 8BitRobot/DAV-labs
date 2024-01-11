`timescale 1ns/1ns

module alarmClock_tb (
	output logic [47:0] disp,
	output logic buzzer_out
);

reg clock;
reg reset;
reg start_stop;
reg [9:0] switches;

alarmClock_top UUT (clock, reset, start_stop, switches[9:0], disp[47:0], buzzer_out);

initial begin
	reset = 1'b1;
	start_stop = 1'b1;
	switches = 10'b1110111111;
	
	clock = 1'b0;
	#10000 $stop;
end

always begin
	#10 clock = ~clock;
end

endmodule