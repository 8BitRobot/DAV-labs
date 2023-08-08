`timescale 1ns/1ns
module miniALU_tb(leds);
	output [9:0] leds;
	
	reg [9:0] switches;
	initial begin
		switches = 10'b0000000100;
		
		#5;
		
		switches = 10'b0000001001;
		
		#5;
		
		switches = 10'b0000000001;
	end
	
	miniALU_top mat(switches, leds);
endmodule