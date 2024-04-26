`timescale 1ns / 1ns

module getComplexNum_tb
(
	output[11:0] Outcome
);

	logic [5:0] realNum;
	logic [5:0] imagNum;
	
	getComplexNum #(10) complexNumber 
	(
		.realPart(realNum), 
		.imagPart(imagNum),
		.result(Outcome)
	);
	
	
	initial begin
		realNum = 20;
		imagNum = 7;
		
		#100
	
		realNum = 0;
		imagNum = 0;
	end
	
endmodule