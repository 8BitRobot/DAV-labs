module sevenSeg_tb(
	output reg [19:0] num,
	output [41:0] result
);
	
	integer i;
	
	sevenSegDisplay UUT(num, 1, result);
	
	initial begin
		num = 0;
		
		for (i = 0; i < 10'b1111111111; i = i + 1) begin
			#5;
			num = num + 1;
		end
	end

endmodule