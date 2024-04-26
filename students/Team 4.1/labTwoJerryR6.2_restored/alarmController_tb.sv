`timescale 1ns/1ns

module alarmController_tb (
    output logic [15:0] out
);

	/*
	input clk50,
    input pause,
    input reset,
    input speedUp,
    input [8:0] switches,
    output [9:0] leds,
    output logic [7:0] digitSegments [0:5],
    output logic buzzer
	*/
    
    logic clock, pause, reset, flashOn, buzzerOn;
    logic [8:0] switches;
	 
    logic speedUp;
    logic [9:0] leds;
    logic [7:0] digitSegments [0:5];
    logic buzzer;
	 
   alarmClock_top UUT(clock, pause, reset, speedUp, switches, leds, digitSegments, buzzer);

    initial begin
        clock = 0;
        pause = 1;
        reset = 1;
        switches = 0;
    end

    always begin
        #5 clock = ~clock;
    end

endmodule