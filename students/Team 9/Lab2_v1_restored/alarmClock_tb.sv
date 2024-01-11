`timescale 1ns/1ns

module alarmClock_tb(output logic [8:0] time_remaining, output logic flash, output logic buzzer);   

  parameter CLK_PERIOD = 10; // Clock period in ns

  // Signals
  reg clk = 0;
  reg reset;
  reg pause_start_stop_btn;
  reg [8:0] switches;

  // Instantiate the module
  alarmController alarm (
    clk,
    reset,
    pause_start_stop_btn,
    switches,
	 time_remaining,
    flash,
    buzzer
  );

  // Clock generation
  always begin
    #((CLK_PERIOD / 2)) clk = ~clk;
  end

  initial begin
    reset = 1'b1;
    pause_start_stop_btn = 1'b1;
    switches = 9'b000000000;

    // Test scenario 1: Set initial time
    #10 switches = 9'b001100000; // Set initial time to 300 nanoseconds

    // Test scenario 2: Start the timer
    #10 pause_start_stop_btn = 1'b0;
	 #10 pause_start_stop_btn = 1'b1;

    // Wait 
    #100;

    // Test scenario 3: Pause the timer
    #10 pause_start_stop_btn = 1'b0;
	 #10 pause_start_stop_btn = 1'b1;

    // Wait
    #100;

    //Test scenario 4: Reset the timer
    reset = 1'b0;
    #10 reset = 1'b1;

    // End simulation
    $stop;
  end

endmodule