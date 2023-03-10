
module Seven_Seg(val_0, val_1, val_2, val_3, val_4, val_5, decode_0, decode_1, decode_2, decode_3, decode_4, decode_5);

	input [3:0] val_0;
	input [3:0] val_1;
	input [3:0] val_2;
	input [3:0] val_3;
	input [3:0] val_4;
	input [3:0] val_5;
	
	
	output [7:0] decode_0;
	output [7:0] decode_1;
	output [7:0] decode_2;
	output [7:0] decode_3;
	output [7:0] decode_4;
	output [7:0] decode_5;
	
	
	assign decode_0 = decode_val(val_0);
	assign decode_1 = decode_val(val_1);
	assign decode_2 = decode_val(val_2);
	assign decode_3 = decode_val(val_3);
	assign decode_4 = decode_val(val_4);
	assign decode_5 = decode_val(val_5);
	
	function [7:0] decode_val;
		input [3:0] in;
		
		begin
			decode_val[0] = ~(
				(in == 0) ||
				(in == 2) ||
				(in == 3) ||
				(in == 5) ||
				(in == 6) ||
				(in == 7) ||
				(in == 8) ||
				(in == 9));
				
			decode_val[1] = ~(
				(in == 0) ||
				(in == 1) ||
				(in == 2) ||
				(in == 3) ||
				(in == 4) ||
				(in == 7) ||
				(in == 8) ||
				(in == 9));
				
			decode_val[2] = ~(
				(in == 0) ||
				(in == 1) ||
				(in == 3) ||
				(in == 4) ||
				(in == 5) ||
				(in == 6) ||
				(in == 7) ||
				(in == 8) ||
				(in == 9));
				
			decode_val[3] = ~(
				(in == 0) ||
				(in == 2) ||
				(in == 3) ||
				(in == 5) ||
				(in == 6) ||
				(in == 8) ||
				(in == 9));
				
			decode_val[4] = ~(
				(in == 0) ||
				(in == 2) ||
				(in == 6) ||
				(in == 8));
				
			decode_val[5] = ~(
				(in == 0) ||
				(in == 4) ||
				(in == 5) ||
				(in == 6) ||
				(in == 8) ||
				(in == 9));
				
			decode_val[6] = ~(
				(in == 2) ||
				(in == 3) ||
				(in == 4) ||
				(in == 5) ||
				(in == 6) ||
				(in == 8) ||
				(in == 9) ||
				(in == 11));
				
			decode_val[7] = ~(in == 10);
		end		
	endfunction
endmodule
