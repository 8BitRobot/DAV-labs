module clockDivider(input clk, output reg new_clk);
	reg [7:0] count;
	
	initial begin
		count = 0;
		new_clk = 0;
	end
	
	always @(posedge clk) begin
		count <= count + 1;
		if (count == 0) begin
			new_clk = ~new_clk;
		end
	end
endmodule