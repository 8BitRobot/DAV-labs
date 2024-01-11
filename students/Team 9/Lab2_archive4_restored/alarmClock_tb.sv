`timescale 1ns/1ns

module alarmClock_tb(output logic [8:0] time_remaining);   

  // Signals
  reg [9:0] switches;
  reg reset;
  reg pause_start_stop_btn;
  reg clk;
  wire [9:0] leds;
  wire [47:0] display;
  wire buzzer;

  // Instantiate the module
  alarmClock_top alarm (
    switches,
    reset,
    pause_start_stop_btn,
    clk,
	 leds,
    display,
    buzzer
  );

  // Clock generation
  always begin
    #5 clk = ~clk;
  end

  initial begin
    reset = 1'b1;
    pause_start_stop_btn = 1'b1;
    switches = 10'b0000000000;
	 clk = 0;
  end

endmodule