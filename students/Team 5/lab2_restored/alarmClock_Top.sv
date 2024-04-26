module alarmClock_Top(
 
	input ss_button,    //ss_button
	input rs_button, // will be 1 when we reset (pressed the button), 0 when we dont press the button 
	input [8:0] switches,
	input clk,      
	
	
	output reg [7:0] op_digit0,   ///SevenSegment
	output reg [7:0] op_digit1,
	output reg [7:0] op_digit2,
	output reg [7:0] op_digit3,
	output reg [7:0] op_digit4,
	output reg [7:0] op_digit5,
	output reg buzzer_clk

);
	
	
	reg outClk;
	reg [19:0] outAlarmController;
	wire shouldBuzz;

	clockDivider clkInstance(clk, 100, rs_button, outClk);
	
	alarmController alarmInstance(ss_button, rs_button, switches, outClk, outAlarmController);
	
	sevenSegDisplay displayInstance(outAlarmController, 1, op_digit0, op_digit1, op_digit2, op_digit3, op_digit4, op_digit5);

	always_comb begin
		if (outAlarmController == 0) 
			shouldBuzz = 1;	
		else
			shouldBuzz = 0;	
	end
	buzzerTest buzzInstance(outClk, shouldBuzz, buzzer_clk && shouldBuzz);
	
	
endmodule