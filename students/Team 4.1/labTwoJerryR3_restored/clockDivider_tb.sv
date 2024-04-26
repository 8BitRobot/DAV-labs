`timescale 1ns/1ns

module clockDivider_tb (
    output logic out
);

	logic pause = 0;
	logic reset = 0;
	logic speedup = 0;
	logic [8:0] switches = 0;
	
	wire [9:0] leds;
	wire [7:0] digitSegments [0:5];
	wire buzzer;

    logic clock;
    alarmClock_top UUT(
		 clock,
		 pause,
		 reset,
		 speedup,
		 switches,
		 leds,
		 digitSegments,
		 buzzer
	 );

    initial begin
        clock = 0;
        #10000 $stop;
    end
    always begin
        #5 clock = ~clock; // 50 MHz clock
    end

endmodule