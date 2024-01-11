module clock_divider(input clk, input reset, input logic [25:0] speed, output logic outClk);

parameter BASE_SPEED = 'd50000000;

logic [25:0] counter = 'd0;

logic outClk_d;

always @(posedge clk) begin
	 outClk <= outClk_d;
	
    if (reset == 'd0) begin
      counter <= 'd0; end // reset counter if reset is pressed
    else if (counter == (BASE_SPEED / speed) - 'd1) begin
      counter <= 'd0; end// reset counter if it reaches max value
    else begin
      counter <= counter + 'd1; end // increment counter 
end
 
always_comb begin
	if (counter < (BASE_SPEED / speed) / 2) begin
		outClk_d = 'd0; end
	else begin
		outClk_d = 'd1; end
end

endmodule
