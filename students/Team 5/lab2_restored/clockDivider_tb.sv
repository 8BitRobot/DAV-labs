`timescale 1ns/1ns

module clockDivider_tb(output outClk);

    logic clk;
	 logic [19:0] speed = 1000000;
	 logic reset;


    clockDivider UUT (
			clk, speed, reset, outClk
    );

    initial begin 
      clk = 0;    
		#10000 $stop;  
	 end
	 always begin 
		#10 clk = ~clk;  
	 end                    

endmodule