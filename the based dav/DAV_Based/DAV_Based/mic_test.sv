module mic_test (clk, leds, rst);
	
	// should be unused in this project
	
	input reg clk;
	input reg rst;
	
	output [9:0] leds;
	
	reg [11:0] mic;
	
	always_comb begin
	
		leds[0] = (mic > 400);
		leds[1] = (mic > 800);
		leds[2] = (mic > 1200);
		leds[3] = (mic > 1600);
		leds[4] = (mic > 2000);
		leds[5] = (mic > 2400);
		leds[6] = (mic > 2800);
		leds[7] = (mic > 3200);
		leds[8] = (mic > 3600);
		leds[9] = (mic > 4000);
	
	end
	
	DAVADC U1T(.CLOCK(clk), .CH0(mic), .RESET(~rst));
	
endmodule