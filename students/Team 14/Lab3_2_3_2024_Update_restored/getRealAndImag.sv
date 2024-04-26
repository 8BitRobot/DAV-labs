module getRealAndImag #(parameter WIDTH = 32)
(
	input [(WIDTH)-1:0] result,
	output [(WIDTH/2)-1:0] realPart,
	output [(WIDTH/2)-1:0] imagPart
);

	assign realPart = result[(WIDTH-1)     :(WIDTH/2)];
	assign imagPart = result[((WIDTH/2)-1) :0        ];

endmodule