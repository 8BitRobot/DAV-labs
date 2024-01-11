module alarmclock_top (
    input [9:0] switches, // hardware switches
    input start_b, // start button (active low)
    input reset_b, // reset button (active low)
    input clk, // base clock
    output [9:0] leds, // switch LEDs
    output buzzer, // IO pin to drive buzzer
    output reg [7:0] seg1, seg2, seg3, seg4, seg5, seg6 // 7-seg displays
    );

    assign leds = switches;
    wire speed = switches [0];
    wire [8:0] total_time = switches [9:1];

    reg [19:0] freq = 20'd100; 
    reg display_clk;
    
    reg clock;
    reg [19:0] time_remaining;
    reg buzzer_on;
    reg display_flash;
    wire display_on = 1'b1;
	 
    clockDivider FCK(clk, 20'd1, 1'b0, clock);
    alarmController ARND(total_time, start_b, reset_b, clock, time_remaining, buzzer_on, display_flash);
    sevenSegDisplay FND(time_remaining, display_on, seg1, seg2, seg3, seg4, seg5, seg6);
    //clockbuzzer OUT(clk, buzzer);

    //clockDivider DISPLAY_CLK(clk, 20'd1, 'b0, display_clk);
    //always_comb begin
        // if (speed)
        //     freq = 20'd100 * 'd2;
        // else 
        //     freq = 20'd100;
        
        //if (buzzer_on)
        //    buzzer_clk = clk; // == 1
        //else 
        //    buzzer_clk = 'b0;
        
        //if (display_flash)
        //    display_on = display_on && display_clk;
        //else
        //    display_on = 'b1; 
    //end
    
endmodule