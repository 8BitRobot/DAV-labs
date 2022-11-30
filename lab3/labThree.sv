//module labThree(input clock, input start, input reset, input selectClockDivider, output [7:0] dig0, output [7:0] dig1, output [7:0] dig2, output [7:0] dig3, output [7:0] dig4, output [7:0] dig5, output buttonLED);
module labThree(input [9:0] switches, input clock, input start, input reset, output [7:0] dig0, output [7:0] dig1, output [7:0] dig2, output [7:0] dig3, output [7:0] dig4, output [7:0] dig5, output buttonLED);

	reg [19:0] counter = 1;
	
	
	reg [19:0] counter_d = 1;
	
	reg RESET_COUNT = 0;
	reg RUNNING = 0;
	reg WHEN_TO_RUN = 1;
	
	
	
	parameter SET = 2'b00;
	parameter RUN = 2'b01;
	parameter PAUSE = 2'b10;
	parameter BEEP = 2'b11;
	
	reg [1:0] currentState = SET;
	reg [1:0] nextState = SET;
	
	// 00 - don't count up
	// 01 - count up
	// 10 - set to 0
	
	reg clockDivided100 = 0;
	// reg clockDivided200 = 0;
	
	// reg fullClock;
	
	assign buttonLED = start;
	// selectClockDivider: 0 - 100hz, 1 - 200hz
	
	sevenSegDisp(currentState, dig5, dig4, dig3, dig2, dig1, dig0);
	
	clockDivider100hz(clock, clockDivided100);
	// clockDivider200hz(clock, ~selectClockDivider, clockDivided200);
	
	always @(posedge clockDivided100) begin
		/*
		case(currentState) 
			SET: begin
				counter = switches;
			end
			
			RUN: begin
				counter -= 1;
			end
			
			PAUSE: begin
				counter = counter;
				// flash
			end
			BEEP: begin
				//beep
			end
		endcase
	*/
		currentState = nextState;
	end
	
	always_comb begin
		case(currentState) 
			SET: begin
				if (RUNNING == WHEN_TO_RUN) begin
					nextState = RUN;
				end
				else begin
					nextState = SET;
				end
			end
			
			RUN: begin
				if (RUNNING != WHEN_TO_RUN) begin
					nextState = PAUSE;
				end
				else if (RESET_COUNT) begin
					nextState = SET;
				end
				else if (counter == 0) begin
					nextState = BEEP;
				end
				else begin
					nextState = RUN;
				end
			end
			
			PAUSE: begin
				if (RUNNING == WHEN_TO_RUN) begin
					nextState = RUN;
				end
				else if (RESET_COUNT) begin
					nextState = SET;
				end
				else begin
					nextState = PAUSE;
				end
				// flash
			end
			BEEP: begin
				if (RESET_COUNT) begin
					nextState = SET;
				end
				else begin
					nextState = BEEP;
				end
				//beep
			end
			
			default: begin
				nextState = currentState;
			end
		endcase	
	end
	
	
	

	initial begin
		counter = switches;
		RUNNING = 0;
		RESET_COUNT = 0;
		WHEN_TO_RUN = 1;
	end
	
	
	
	/*
	always_comb begin
		if (RESET_COUNT) begin
			counter_d = switches;
		end
		else begin
			counter_d = counter;
		end
	end
	
	*/
	always @(posedge start) begin
		RUNNING <= ~RUNNING;
	end
	
	
	always @(reset) begin
		RESET_COUNT <= ~reset;
	end
	
	always @(posedge RESET_COUNT) begin
		WHEN_TO_RUN <= ~RUNNING;
	end
	
	
	/*
	always @(posedge clockDivided100) begin
		if (RUNNING == WHEN_TO_RUN) begin
			counter <= counter_d - 1;
		end
		else begin
			counter <= counter_d;
		end
	end
	*/
endmodule
