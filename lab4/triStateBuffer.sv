module triStateBuffer(input in, input we, output out, inout SDA);
	always_comb begin
		if (we) begin
			out <= 1'b0;
			SDA <= in;
		end
		else begin
			out <= SDA;
			SDA <= 1'bz;
		end
	end
endmodule