module clockDivider (clk, speed, reset, outClk);
	input clk;
	input [$clog2(1000000)-1:0] speed;
	input reset;
	output logic outClk;
	
	parameter BASE_SPEED = 50000000;
	
	logic [$clog2(BASE_SPEED)-1:0] counter = 0;
	logic [$clog2(BASE_SPEED)-1:0] nextCounter = 0;
	logic nextClk = 0;
	
	
	always_comb begin	
		if (reset == 1)
			nextClk = 0;
		else if (counter > ((BASE_SPEED/speed)-1)/2)
			nextClk = 1;
		else
			nextClk = 0;	
			
		if (reset == 1)
			nextCounter = 0;
		else if (counter == (BASE_SPEED/speed)-1)
			nextCounter = 0;
		else
			nextCounter = nextCounter + 1;
		
	end
	
	always @(posedge clk) begin
		outClk <= nextClk;
		counter <= nextCounter;
		
	end
	
endmodule