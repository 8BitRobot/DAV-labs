module getComplexNum #(parameter WIDTH = 32)
(
	input [(WIDTH/2)-1:0] realPart,
	input [(WIDTH/2)-1:0] imagPart,
	output [(WIDTH)-1:0] result
);
	assign result[(WIDTH-1)     :(WIDTH/2)] = realPart;
	assign result[((WIDTH/2)-1) :0        ] = imagPart;

endmodule