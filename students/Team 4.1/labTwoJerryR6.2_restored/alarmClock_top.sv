module alarmClock_top (
    input clk50,
    input pause,
    input reset,
    input speedUp,
    input [8:0] switches,
    output [9:0] leds,
    output logic [7:0] digitSegments [0:5],
    output logic buzzer
);

    assign leds = {switches, speedUp};

    logic clk, flashClk;
    logic flashOn, buzzerOn;
    logic [15:0] t;

    // 100 Hz clock for counting time every hundredth of a second, 200 Hz when speedUp enabled
    clockDivider div(clk50, 100 * (1 + speedUp), 0, clk);

    // alarmController alarm(clk, pause, reset, switches, t, flashOn, buzzerOn);
    alarmController alarm(clk, pause, 0, switches, t, flashOn, buzzerOn);

    // 3 Hz flashing frequency for flashing time during PAUSE and BEEP states; only turned on when in respective states
    clockDivider flash(clk50, 3, !flashOn, flashClk);

    // 440 Hz buzzer for buzzing when in BEEP state
    clockDivider buzz(clk50, 440, !buzzerOn, buzzer);

    wire w = !flashOn || flashClk;

    sevenSegDisplay display(t, w, digitSegments); // the on/off of the display is controller by the flashClk
    // sevenSegDisplay display(t, 1, digitSegments);
    
endmodule