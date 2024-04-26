//module clk_div(clk, rst, v_clk, fft_clk);
//	
//	input clk;
//	input rst;
//	output reg v_clk;
//	output reg fft_clk;
//	reg v_count;
//	reg [8:0] fft_count;
//	
//	always @(posedge clk) begin
//		if(rst) begin
//			v_count <= 0;
//			fft_count <= 0;
//			v_clk <= 0;
//			fft_clk <= 0;
//		end
//		else begin
//			if(v_count == 1) begin
//				v_clk <= ~v_clk;
//				v_count <= 0;
//			end
//			else begin
//				v_count <= v_count + 1;
//			end
//			
//			if(fft_count == 199) begin
//				fft_clk <= ~fft_clk;
//				fft_count <= 0;
//			end
//			else begin
//				fft_count <= fft_count + 1;
//			end
//		end
//	end
//endmodule

// Clock Divider
`timescale 1ns/1ns
module clk_div #(parameter count = 10) (in, out, reset);
	
	input in;
	input reset;
	output reg out;
	reg [$clog2(count) - 1:0] counter; //= 0;
	
	always @ (posedge in) begin
		if (reset) begin 
			counter <= 0;
			out <= 0;
		end
		else begin
		if (counter == count - 1) begin
			counter <= 0;
			out <= ~out;
		end
		else begin
			counter <= counter + 1;
		end
		end
	end
	
endmodule
