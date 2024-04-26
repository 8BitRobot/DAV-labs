module butt #(parameter WIDTH=32) (
	input signed [(WIDTH - 1):0] a,
	input signed [(WIDTH - 1):0] b, 
	input signed [(WIDTH - 1):0] w, 
	output signed [(WIDTH - 1):0] out1, // A+WB
	output signed [(WIDTH - 1):0] out2 // A-WB
);
	wire signed [(WIDTH/2 - 1):0] reA = a[(WIDTH - 1):WIDTH/2];
	wire signed [(WIDTH/2 - 1):0] imA = a[(WIDTH/2 - 1):0];
	wire signed [(WIDTH/2 - 1):0] reB = b[(WIDTH - 1):WIDTH/2];
	wire signed [(WIDTH/2 - 1):0] imB = b[(WIDTH/2 - 1):0];
	wire signed [(WIDTH/2 - 1):0] reW = w[(WIDTH - 1):WIDTH/2];
	wire signed [(WIDTH/2 - 1):0] imW = w[(WIDTH/2 - 1):0];

	wire signed [(WIDTH - 1):0] reWB = (reW * reB) - (imW * imB);
	wire signed [(WIDTH - 1):0] imWB = (imW * reB) + (reW * imB);
	
	wire signed [(WIDTH/2 - 1):0] reBW = reWB[(WIDTH - 2):(WIDTH/2 - 1)];	
	wire signed [(WIDTH/2 - 1):0] imBW = imWB[(WIDTH - 2):(WIDTH/2 - 1)];
	
	wire signed [(WIDTH/2 - 1):0] reOut1 = (reA + reBW);
	wire signed [(WIDTH/2 - 1):0] imOut1 = (imA + imBW);
	assign out1[(WIDTH - 1):WIDTH/2] = reOut1;
	assign out1[(WIDTH/2 - 1):0] = imOut1;
	
	wire signed [(WIDTH/2 - 1):0] reOut2 = (reA - reBW);
	wire signed [(WIDTH/2 - 1):0] imOut2 = (imA - imBW);
	assign out2[(WIDTH - 1):WIDTH/2] = reOut2;
	assign out2[(WIDTH/2 - 1):0] = imOut2;
	
endmodule