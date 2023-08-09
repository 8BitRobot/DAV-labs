module alarmClock_top(
	input        clk,
	input  [9:0] switches,
	input        pause,
	input        reset,
	output [7:0] segs [0:5],
	output       buzzer
);
	
	wire divClk;
	wire flashClk;

	clockDivider clockCD(clk, switches[0] ? 100 : 200, ~reset, divClk);
	clockDivider buzzerCD(clk, 420, ~reset, buzzerClk);
	clockDivider flashCD(clk, 1, ~reset, flashClk);
	
	wire [15:0] timeRemaining;
	wire buzzerEnable;
	
	assign buzzer = buzzerEnable & buzzerClk;
	
	alarmClockController ac(.mainClk(clk),
									.timeClk(divClk),
									.switches(switches[9:1]),
									.pauseResume(~pause),
									.reset(~reset),
									.timeRemaining(timeRemaining),
									.shouldBeep(buzzerEnable));
	
	sevenSegDisp disp(.value(timeRemaining), .enable(~buzzerEnable | flashClk), .segs(segs));
endmodule