module alarmClock_top (
    input clk50,
    input pause,
    input reset,
    input speedup,
    input [8:0] switches,
    output [9:0] leds,
    output logic [7:0] digitSegments [0:5],
    output logic buzzer
);

    assign leds = {switches, speedup};

    logic clk, flashClk;
    logic flashOn, buzzerOn;
    logic [16:0] out;

    // 100 Hz clock for counting time every hundredth of a second
    clockDivider normal(clk50, 1, 0, speedup, clk);

    alarmController alarm(clk, pause, reset, switches, out, flashOn, buzzerOn);

    // 4 Hz flashing frequency for flashing time during PAUSE and BEEP states; only turned on when in respective states
    clockDivider flash(clk50, 4, flashOn, 0, flashClk);

    // 440 Hz buzzer for buzzing when in BEEP state
    clockDivider buzz(clk50, 440, buzzerOn, 0, buzzer);

    // sevenSegDisplay display(out, flashClk, digitSegments); // the on/off of the display is controller by the flashClk
    //sevenSegDisplay display(out, 1, digitSegments);
	 
	 assign digitSegments[0][4] = clk;
    
endmodule