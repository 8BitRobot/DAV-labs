module alarmClockController(
	input mainClk,
	input timeClk,
	input [8:0] switches,
	input pauseResume,
	input reset,
	output reg [15:0] timeRemaining,
	output shouldBeep
);

	
	localparam SET = 2'b00;
	localparam RUN = 2'b01;
	localparam PAUSE = 2'b10;
	localparam BEEP = 2'b11;
	
	reg [1:0] alarmClockState = SET;
	reg [1:0] alarmClockState_d;
	
	assign shouldBeep = alarmClockState == BEEP;
	
	reg [21:0] timeRemaining_d;
	
	reg [1:0] timeClk_sr;
	reg [1:0] pauseResume_sr;
	reg [1:0] reset_sr;
	
	always @(posedge mainClk) begin
		timeClk_sr <= {timeClk_sr[0], timeClk};
		pauseResume_sr <= {pauseResume_sr[0], pauseResume};
		reset_sr <= {reset_sr[0], reset};
		
		alarmClockState <= alarmClockState_d;
		timeRemaining <= timeRemaining_d;
	end
	
	always_comb begin
		case (alarmClockState)
			SET: begin
				if (pauseResume_sr == 2'b01) alarmClockState_d = RUN;
				else alarmClockState_d = SET;
				
				timeRemaining_d = switches * 100;
			end
			RUN: begin
				if (pauseResume_sr == 2'b01) alarmClockState_d = PAUSE;
				else if (reset_sr == 2'b01) alarmClockState_d = SET;
				else if (timeRemaining == 0) alarmClockState_d = BEEP;
				else alarmClockState_d = RUN;
				
				if (timeClk_sr == 2'b01) timeRemaining_d = timeRemaining - 1;
				else timeRemaining_d = timeRemaining;
			end
			PAUSE: begin
				if (pauseResume_sr == 2'b01) alarmClockState_d = RUN;
				else if (reset_sr == 2'b01) alarmClockState_d = SET;
				else alarmClockState_d = PAUSE;
				
				timeRemaining_d = timeRemaining;
			end
			BEEP: begin
				if (reset_sr == 2'b01) alarmClockState_d = SET;
				else alarmClockState_d = BEEP;
				
				timeRemaining_d = 0;
			end
		endcase
	end
endmodule