module alarmController(
	input  in_clock,
	input [8:0] switches,
	input reset,
	input start_stop,
	output logic disp_flash,
	output logic [30:0] counter,
	output logic buzzer_onoff
);

localparam SET = 2'b00;
localparam RUN = 2'b01;
localparam BEEP = 2'b10;
localparam PAUSE = 2'b11;

reg[13:0] next_counter;
reg[2:0] state;
reg[2:0] next_state;

// create clock div for disp_flash
// clockDivider df (in_clock, 5, buzzer_onoff, disp_flash);

assign buzzer_onoff = (state == BEEP);

initial begin
	state = SET;
	counter = switches * 100;
end

reg[1:0] pause_sr;
reg[1:0] reset_sr;


always@(posedge in_clock) begin
	/* shift the shift register left by 1 and
	store the current button value */
	pause_sr <= { pause_sr[0], start_stop };
	reset_sr <= { reset_sr[0], reset };

	state <= next_state;
	counter <= next_counter; 
end

always_comb begin
	// FSM
	
	case(state)
		SET:
			if (pause_sr == 2'b01) begin
				next_state = RUN;
				next_counter = counter;
			end
			else begin
				next_state = state;
				next_counter = 100 * switches[8:0];
			end
		RUN:
			if (reset_sr == 2'b01) begin
				next_state = SET;
				next_counter = counter;
			end
			else if (counter == 'd0) begin
				next_state = BEEP;
				next_counter = counter;
			end
			else if (pause_sr == 2'b01) begin
				next_state = PAUSE;
				next_counter = counter;
			end
			else begin
				next_state = state;
				next_counter = counter - 1;
			end
		BEEP:
			if (reset_sr == 2'b01) begin
				next_state = SET;
				next_counter = counter;
			end
			else begin
				next_state = state;
				next_counter = counter;
			end
		PAUSE:
			if (reset_sr == 2'b01) begin
				next_state = SET;
				next_counter = counter;
			end
			else if (pause_sr == 2'b01) begin
				next_state = RUN; // ERROR HERE
				next_counter = counter;
			end
			else begin
				next_state = state;
				next_counter = counter;
			end
		default: begin
			next_state = PAUSE;
			next_counter = 'd0;
		end
	endcase
end

endmodule