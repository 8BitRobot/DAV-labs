`timescale 1ns/1ns
/*module buzzerTest(
    input clk,
    input shouldBuzz,
    output outClk
);

    logic [19:0] speed = 500;
    logic reset; //should be zero when we aren't pressing the reset button

    // Instantiate clockDivider conditionally based on shouldBuzz
	 clockDivider UUT(
                .clk(clk),
                .speed(speed),
                .reset(reset), 
                .outClk(outClk),
					 
            ); 
				
    always_comb begin
        if (shouldBuzz == 1) begin
            clockDivider clkInstance(clk, speed, reset, outClk);  
        end
		  else ( (shouldBuzz == 0)
    end

endmodule */

module buzzerTest(input clk, input shouldBuzz, output outClk);

	 logic [19:0] speed = 500;
	 logic reset;
	 
	 clockDivider UUT (
		clk, speed, reset, outClk
		);


endmodule
