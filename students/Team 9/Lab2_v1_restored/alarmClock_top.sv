module alarmClock_top(input [9:0] switches, input reset_test, input pause_start_stop_btn_test, input clk_test, output[9:0] leds, output [47:0] display, output logic buzzer);
    reg [25:0] speed_test = 26'd100; // Initialize speed_test

    assign leds = switches;

    wire outClk_test;
    logic [15:0] time_remaining;
    logic flash;

    always @(posedge clk_test) begin
        if (switches[0] == 1'b0) begin // speed switch pressed
            speed_test <= 26'd200;
        end else begin
            speed_test <= 26'd100; // Reset speed_test if switch is not pressed
        end
    end

    clock_divider clockTest(clk_test, reset_test, speed_test, outClk_test);
    alarmController alarmTest(outClk_test, reset_test, pause_start_stop_btn_test, switches[9:1], time_remaining, flash, buzzer);
    sevenSegDisplay displayTest(time_remaining, outClk_test, flash, display);
	 
endmodule