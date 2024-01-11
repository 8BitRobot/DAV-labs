module clockDivider (
	input clk,
	input [19:0] speed,
	input reset,
	output reg outClk	
);
	parameter BASESPEED = 26'd50000000; 

	reg outClk_d;
	
	wire [25:0] threshold = BASESPEED / speed;
	
	reg [25:0] count = 1'd0;
	reg [25:0] count_d;
	
	always@ (posedge clk) begin
		count <= count_d;
		outClk <= outClk_d;
	end
	
	always_comb begin
		if (reset || count > threshold - 1'd1) begin
			count_d = 1'd0;
		end else begin
			count_d = count + 1'd1;
		end
		
		if (count < threshold/2'd2 ) begin
			outClk_d = 1'd0;
		end else begin
			outClk_d = 1'd1;
		end
	end
	
endmodule