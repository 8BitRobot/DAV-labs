module alarmController(        
	input logic clk,                      //clock input
	input logic reset,                    //reset button
	input logic pause_start_stop_btn,     //start/stop button
	input logic [8:0] switches,           //set initial time
	output reg [15:0] time_remaining,     //seven-seg display 
	output logic flash,                   //determines whether to flash or not 
	output logic buzzer                   //buzzer
);

initial begin
	time_remaining = 9'b000000000;
	flash = 1'b0;
	buzzer = 1'b0;
end

reg [1:0] reset_sr = 2'b11;
reg [1:0] pause_start_stop_btn_sr = 2'b11;
reg [1:0] currentState = 2'b00;
reg [1:0] nextState = 2'b00; // the next state to be assigned
reg [8:0] time_remaining_update = 9'b0;  // the next output value to be assigned
reg flash_update = 1'b0;
reg buzzer_update = 1'b0;


always @(posedge clk) begin
	/* shift the shift register left by 1 and
   store the current button value */
	reset_sr <= { reset_sr[0], reset };
	pause_start_stop_btn_sr <= { pause_start_stop_btn_sr[0], pause_start_stop_btn };

	/* state transition */
	currentState <= nextState;

	/* output assignment */
	time_remaining <= time_remaining_update;
	flash <= flash_update;
	buzzer <= buzzer_update;
end

localparam SET = 2'b00; //SET
localparam RUN = 2'b01; //RUN
localparam PAUSE = 2'b10; //PAUSE
localparam BEEP = 2'b11; //BEEP

always_comb begin
	case (currentState)
		SET: begin
		/* remember that this won't be "assigned"
			until the sequential block executes (on
			the clock edge! */

		/* if the button has a positive edge (i.e.
			it was just pressed, transition states */
			if (pause_start_stop_btn_sr == 2'b10) begin
				nextState = RUN;
				time_remaining_update = switches * 100 - 1'b1;
				flash_update = 1'b0; //flash off
				buzzer_update = 1'b0;
			end 
			else if (reset_sr == 2'b10) begin
				nextState = SET;
				time_remaining_update = switches * 100;
				flash_update = 1'b0; //flash off
				buzzer_update = 1'b0;
			end
			else begin
				nextState = currentState;
				time_remaining_update = switches * 100;
				flash_update = flash;
				buzzer_update = 1'b0;
			end
		end
		RUN: begin
			if (pause_start_stop_btn_sr == 2'b10 /*|| pause_start_stop_btn_sr == 2'b00*/) begin //added change
				nextState = PAUSE; 
				time_remaining_update = time_remaining;
				flash_update = 1'b1; //flash on
				buzzer_update = 1'b0;
			end
			else if (reset_sr == 2'b10) begin //added change
				nextState = SET;
				time_remaining_update = switches;
				flash_update = 1'b0; //flash off
				buzzer_update = 1'b0;
			end
			else if (time_remaining == 9'b000000000) begin 
				nextState = BEEP;
				time_remaining_update = 9'b000000000; 
				flash_update = 1'b1; //flash on
				buzzer_update = 1'b1;
			end
			else begin
				nextState = currentState;
				time_remaining_update = time_remaining - 1'b1;
				flash_update = flash;
				buzzer_update = 1'b0;
			end
		end
		PAUSE: begin 
			if (pause_start_stop_btn_sr == 2'b10 /*|| pause_start_stop_btn_sr == 2'b00*/) begin //added change
				nextState = RUN;
				time_remaining_update = time_remaining - 1'b1;
				flash_update = 1'b0; //flash off
				buzzer_update = 1'b0;
			end
			else if (reset_sr == 2'b10) begin
				nextState = SET;
				time_remaining_update = switches;
				flash_update = 1'b0; //flash off
				buzzer_update = 1'b0;
			end
			else begin
				nextState = currentState;
				time_remaining_update = time_remaining;
				flash_update = flash;
				buzzer_update = 1'b0;
			end
		end
		BEEP: begin
			if (pause_start_stop_btn_sr == 2'b10) begin
				nextState = BEEP;
				time_remaining_update = 9'b000000000;
				flash_update = 1'b1; //flash on
				buzzer_update = 1'b1;
			end
			else if (reset_sr == 2'b10) begin
				nextState = SET;
				time_remaining_update = switches;
				flash_update = 1'b0; //flash on
				buzzer_update = 1'b0;
			end
			else begin
				nextState = currentState;
				time_remaining_update = time_remaining;
				flash_update = flash;
				buzzer_update = 1'b1;
			end
		end
		default: begin
				nextState = currentState;
				time_remaining_update = time_remaining;
				flash_update = flash;
				buzzer_update = 1'b0;
		end
	endcase
end

endmodule



