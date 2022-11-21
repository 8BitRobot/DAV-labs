//module labThree(input start, input reset, input speed, input clock, output [47:0] displays)
module labThree(input clock, input start, input reset, input selectClockDivider, output [7:0] dig0, output [7:0] dig1, output [7:0] dig2, output [7:0] dig3, output [7:0] dig4, output [7:0] dig5, output buttonLED);
	
	reg [19:0] counter = 0;
	reg [19:0] counter_d = 0;
	
	reg RESET_COUNT = 0;
	reg RUNNING = 0;
	// 00 - don't count up
	// 01 - count up
	// 10 - set to 0
	
	reg clockDivided100 = 0;
	reg clockDivided200 = 0;
	
	reg fullClock;
	
	assign buttonLED = start;
	// selectClockDivider: 0 - 100hz, 1 - 200hz
	
	sevenSegDisp(counter, dig5, dig4, dig3, dig2, dig1, dig0);
	
	clockDivider100hz(clock, selectClockDivider, clockDivided100);
	clockDivider200hz(clock, ~selectClockDivider, clockDivided200);
	
	initial begin
		counter = 0;
		RUNNING = 0;
		RESET_COUNT = 0;
	end
	
	always_comb begin
		fullClock = clockDivided100 | clockDivided200;
		if (RESET_COUNT) begin
			counter_d = 0;
		end
		else begin
			counter_d = counter;
		end
	end
	
	always @(posedge start) begin
		RUNNING <= ~RUNNING;
	end
	
	always @(posedge reset) begin
		RESET_COUNT = ~RESET_COUNT;
	end
	
	always @(posedge fullClock) begin
		if (RUNNING & ~RESET_COUNT) begin
			counter <= counter_d + 1;
		end
		else if (~RUNNING & RESET_COUNT) begin
			counter <= 0;
		end
		else begin
			counter <= counter_d;
		end
	end
	
//	always @(posedge clockDivided200) begin
////		if (reset) begin
////			RUNNING <= 0;
////		end
////		else if (start) begin
////			RUNNING <= ~RUNNING;
////		end
////		else begin
////			RUNNING <= RUNNING;
////		end
//	if(~start) begin
//		counter <= counter + 1;
//		if(debounceCounter == 2'd0) begin
//		RUNNING <= ~ RUNNING;
//		end
//	end
//	else begin
//		debounceCounter = 0;
//	end
//	
//	if(RUNNING) begin
//		counter <= counter + 1;
//	end
//	end
//	
////	always @(posedge clockDivided100) begin
//////		counter <= RUNNING;
////	end
endmodule
