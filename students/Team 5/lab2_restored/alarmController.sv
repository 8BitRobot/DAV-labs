module alarmController(
	input ss_button, // start stop pause
	input rs_button,  // reset 
	input [8:0] switches,
	input clockDivided, 
	
	/* TODO: */
	
	/* simplify logic --> in in run state, timer always decrements, if in pause, timer_d == timer --> no need to put it in a if statement*/

	
   output [19:0] outVal
);
   reg [19:0] timer;
	
	assign outVal = timer;
	
	reg [1:0] ss_button_sr;
	reg [1:0] rs_button_sr; //reset button shift reg
	reg [1:0] currentState;
	reg [1:0] nextState;
	reg [19:0] timer_d;
	 
	
	localparam SET = 2'b00;
	localparam RUN = 2'b01;
	localparam PAUSE = 2'b10;
	localparam BEEP = 2'b11;

	always @(posedge clockDivided) begin
		ss_button_sr <= {ss_button_sr[0], ss_button};
		rs_button_sr <= {rs_button_sr[0], rs_button};
		currentState <= nextState;
		timer <= timer_d;

	end
	
	always_comb begin
		case (currentState)
			SET: begin
				if (ss_button == 2'b01) begin  // 0 spot is the previous state and 1 spot is the current state 
					nextState = RUN;
				end else begin
					nextState = SET; 
				end
				timer_d = switches * 100; 
				
			end
			
			RUN: begin
				if (ss_button == 2'b01) begin
					nextState = PAUSE;
					timer_d = timer -1;
				end else if (rs_button == 2'b01) begin
					nextState = SET;
					timer_d = timer -1;
				end else if (timer == 0) begin //changed from timer_d to timer
					nextState = BEEP;
					timer_d = timer; 
		      end else begin
					nextState = RUN;
					timer_d = timer -1;
				end
				
				
			end
			
			PAUSE: begin
				if (ss_button == 2'b01) begin
					nextState = RUN;
				end else if (rs_button == 2'b01) begin
					nextState = SET;
		      end else begin
					nextState = PAUSE; 
				end
				
				timer_d = timer;
			end
			
			BEEP: begin
				nextState = BEEP;
				timer_d = 0;
			end
				
		endcase
	end

endmodule