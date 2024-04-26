module alarmController (
	input clk, 
	input [9:0] switches, // 9 switches for time in sec (eg. switches[9:1]), rightmost one (eg. switches[0]) for clock speed
	// can also do input [8:0] switches, and pass in 9 bit variable in top module
	input ssp, // start stop pause button
	input reset, // reset button
	output logic [15:0] t // time in binary centi-seconds
);

	localparam SET = 2'b00;
	localparam RUN = 2'b01;
	localparam PAUSE = 2'b10;
	localparam BEEP = 2'b11;
	
	logic [1:0] ssp_sr;
	logic [1:0] reset_sr;
	logic [15:0] t_d; // 9 bit number in centi-second (1/100 of a second)

	reg [1:0] currentState = SET;
	reg [1:0] nextState = SET; // the next state to be assigned

	// sequential block
	always @(posedge clk) begin
		/* shift the shift register left by 1 and store the current button value */
		ssp_sr <= { ssp_sr[0], ssp };
		reset_sr <= { reset_sr[0], reset };

		/* state transition */
		currentState <= nextState;

		/* output assignment */
		t <= t_d;
	end

	// combinational block	
	always_comb begin
		case (currentState)
			// state 1
			SET: begin
				/* remember that this won't be "assigned" until the 
					sequential block executes (on the clock edge! */
				/* if the button has a positive edge 
					(i.e. it was just pressed, transition states */
				if (ssp_sr == 2'b10) begin // posedge since active low buttons
					nextState = RUN;
				end
				else begin
					nextState = SET;
				end
				
				t_d = 100 * switches[9:1];
			end
			// state 2
			RUN: begin
				if (reset_sr == 2'b10) begin // reset
					nextState = SET;
				end
				else if (ssp_sr == 2'b10) begin
					nextState = PAUSE;
				end 
				else if (t <= 0) begin 
					nextState = BEEP;
				end
				else begin
					nextState = RUN;
				end
				
				t_d = t - 1;
			end
			// state 3
			PAUSE: begin
				if (reset_sr == 2'b10) begin // reset
					nextState = SET;
				end
				else if (ssp_sr == 2'b10) begin // unpause
					nextState = RUN;
				end
				else begin // keep pause
					nextState = PAUSE;
				end
				
				t_d = t;
			end
			// state 4
			BEEP: begin
				if (reset_sr == 2'b00) begin // reset
					nextState = SET;
				end
				else begin // keep beep
					nextState = BEEP;
				end
				
				t_d = 0;
			end
		endcase
	end
	
endmodule