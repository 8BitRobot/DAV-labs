module alarmController (
input PSS_button, input reset_button, input clk, input [8:0] time_switches, 
output logic [19:0] time_remaining, output logic buzzer
);
	
	localparam SET = 2'b00;
	localparam RUN = 2'b01;
	localparam PAUSE = 2'b10;
	localparam BEEP = 2'b11;

	logic [1:0] PSS_sr;
	logic [1:0] reset_sr;
	logic [1:0] currentState;	
	logic [2:0] nextState;
	logic [19:0] next_time;
	logic nextBuzzer;

	always @(posedge clk) begin
		
		PSS_sr <= {PSS_sr[0], PSS_button};
		reset_sr <= {reset_sr[0], reset_button};
		
		currentState <= nextState;
		time_remaining <= next_time;
		buzzer <= nextBuzzer;

	end
	
	
	
	always_comb begin
		case (currentState)
			SET: begin
				if (PSS_sr == 2'b01) begin
					nextState = RUN;
					next_time = time_switches*100;
				end else begin
					nextState = SET;
					next_time = time_switches*100;
					nextBuzzer = 0;
				end
			end
			
			RUN: begin
				if (PSS_sr == 2'b01) begin
					nextState = PAUSE;
				end else if (reset_sr == 2'b01) begin
					nextState = SET;
				end else if (next_time == 0) begin
					nextState = BEEP;
				end else begin
					nextState = RUN;
					next_time = next_time - 1;
					nextBuzzer = 0;
				end
			end
			
			PAUSE: begin
				if (PSS_sr == 2'b01) begin
					nextState = RUN;
				end else if (reset_sr == 2'b01) begin
					nextState = SET;
				end else begin
					nextState = PAUSE;
					//FLASH DISPLAY
					nextBuzzer = 0;
				end
			end
			
			BEEP: begin
				if (reset_sr == 2'b01) begin
					nextState = SET;
					nextBuzzer = 0;
				end else begin
					nextState = BEEP;
					next_time = 0;
					//FLASH DISPLAY 00:00:00
					nextBuzzer = 1;
				end
			end
			
		endcase
	
	end




endmodule