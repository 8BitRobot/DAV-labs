
module Combined_Seven_Seg(in, sign, out_0, out_1, out_2, out_3, out_4, out_5);
	input reg [19:0] in;
	input reg sign;
	
	output reg [7:0] out_0;
	output reg [7:0] out_1;
	output reg [7:0] out_2;
	output reg [7:0] out_3;
	output reg [7:0] out_4;
	output reg [7:0] out_5;
	
	// Extracting each digit
	wire [4:0] d_0;
	wire [4:0] d_1;
	wire [4:0] d_2;
	wire [4:0] d_3;
	wire [4:0] d_4;
	wire [4:0] d_5;
	wire [4:0] d_5_temp;
	
	wire [19:0] signed_in;
	assign signed_in = sign ? (~in + 1) : in;
	
	assign d_0 = signed_in % 10;
	assign d_1 = (signed_in / 10) % 10;
	assign d_2 = (signed_in / 10 / 10) % 10;
	assign d_3 = (signed_in / 10 / 10 / 10) % 10;
	assign d_4 = (signed_in / 10 / 10 / 10 / 10) % 10;
	assign d_5_temp = (in / 10 / 10 / 10 / 10 / 10) % 10;
	
	assign d_5 = sign ? 11 : d_5_temp;
	
	Seven_Seg sevenseg(.val_0(d_0), .val_1(d_1), .val_2(d_2), .val_3(d_3), .val_4(d_4), .val_5(d_5), 
			.decode_0(out_0), .decode_1(out_1), .decode_2(out_2), .decode_3(out_3), .decode_4(out_4), .decode_5(out_5));
	
endmodule 
