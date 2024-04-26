module clockDivider #(BASE_SPEED=50000000) (
	input clk,
	input [19:0] speed,             //log2(1000000) = 19.93
	input reset,
	output logic outClk
);

logic [25:0] counter = 0;
logic [25:0] counter_d;
logic outClk_d;

	 always @(posedge clk) begin
         outClk <= outClk_d;        //nonblocking assignment for sequential
		   counter <= counter_d;	
    end

    always_comb begin
         if (!reset) begin
				counter_d = 0;
			end else if (counter == (BASE_SPEED / speed) - 1) begin //threshold condition for a certain amount of pulses before incrementing the counter
				counter_d = 0;
			end else begin
				counter_d = counter + 1;
			end
			
         if (!reset || counter < ((BASE_SPEED / speed)/2 - 1)) begin
				outClk_d = 0;
			end else begin
			   outClk_d = 1;	
			end
    end
	 
endmodule