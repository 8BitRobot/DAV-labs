`timescale 1ns/1ns

module edge_detect #(parameter REACT = 1'b1) // 0 indicates negative edge, 1 indicates positive edge
(
	input clk, signal,
	output pulse
);

	reg signal_0, signal_1;
	
	generate 
		if (REACT) begin
			posedge_detect pos(signal_0, signal_1, pulse);
		end
		else begin
			negedge_detect neg(signal_0, signal_1, pulse);
		end
	endgenerate
	
	always @(posedge clk) begin
		signal_0 <= signal;
		signal_1 <= signal_0;
	end

endmodule 

module posedge_detect (input signal_0, input signal_1, output pulse);
	assign pulse = signal_0 && ~signal_1;
endmodule

module negedge_detect (input signal_0, input signal_1, output pulse);
	assign pulse = ~signal_0 && signal_1;
endmodule