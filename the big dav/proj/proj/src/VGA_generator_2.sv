// HMMMM THIS SHOULD LOOK FAMILIAR

module vga640x480(
		input wire i_clk,           // base clock
		input wire i_rst,           // reset: restarts frame
		output wire o_hs,           // horizontal sync
		output wire o_vs,           // vertical sync
		output wire o_blanking,     // blanking
		output wire [10:0] o_x,      // current pixel x position
		output wire [10:0] o_y       // current pixel y position
	);

   // VGA timings https://timetoexplore.net/blog/video-timings-vga-720p-1080p
	localparam HS_STA = 639 + 16;              // horizontal sync start
   localparam HS_END = 639 + 16 + 96;         // horizontal sync end
   localparam HA_END = 639;    // horizontal active pixel end
   localparam VS_STA = 479 + 10;        // vertical sync start
   localparam VS_END = 479 + 10 + 2;    // vertical sync end
   localparam VA_END = 479;             // vertical active pixel end
   localparam LINE   = 799;             // complete line (pixels)
   localparam SCREEN = 524;             // complete screen (lines)

   reg [10:0] h_count;  // line position
   reg [10:0] v_count;  // screen position
	
	initial begin
		h_count = 0;
		v_count = 0;
	end

   // generate sync signals (active low for 640x480)
   assign o_hs = ~((h_count >= HS_STA) & (h_count < HS_END));
   assign o_vs = ~((v_count >= VS_STA) & (v_count < VS_END));

   // keep x and y bound within the active pixels
   assign o_x = h_count;
   assign o_y = v_count;
	
	// blanking: high within the blanking period
   assign o_blanking = ((h_count > HA_END) | (v_count > VA_END));

   always @ (posedge i_clk) begin
			if (h_count == LINE)  // end of line
			begin
				h_count <= 0;
            v_count <= (v_count == SCREEN) ? 0 : v_count + 1'b1;
         end
         else begin
            h_count <= h_count + 1'b1;
			end
	end
endmodule


module data #(parameter DATA_WIDTH = 18) 
(
	input clk, hblank, vblank, 
	input [10:0] horizontal_count, vertical_count, 
	input [DATA_WIDTH - 1:0] data_in,
	output reg [3:0] r, output reg [3:0] g, output reg [3:0] b
);
		
	wire signed [DATA_WIDTH:0] signed_data;
	
	assign signed_data = {1'b0, data_in};
	
	wire signed [2*DATA_WIDTH:0] data_product;
	wire signed [2*DATA_WIDTH:0] scaled_data;
	
	// TODO: Map data and values to correct ranges and assign to
	// filtered_product and unfiltered_product
	// Note: Rather than going to 480 - 0 we do 240 - 0 ranges for split screen
	assign data_product = signed_data * 479;
	
	// TODO: Offset products to achieve split screen and assign to scaled_data
	assign scaled_data = (data_product >> DATA_WIDTH - 1);
	
	wire [10:0] data_high_bound;
	
	//assign data_high_bound = (scaled_data > 479) ? 479 : scaled_data;
	assign data_high_bound = 479 - scaled_data;
	
	always @ (posedge clk) begin
		// TODO: Color Assignment
		// If we're blanking, set all colors to black
		if (hblank || vblank) begin
			r = 0;
			g = 0;
			b = 0;
		end
		// If we're in the mathematical bounds for data signal, set color to blue
		else if (vertical_count > data_high_bound) begin
			r = 4'hF;
			g = 0;
			b = 0;
		end
		// Default black
		else begin
			r = 0;
			g = 0;
			b = 0;
		end
	end

endmodule

module VGA_generator
(
	input clk, rst,
	input signed [23:0] data_in,
	output vsync, hsync,
	output [3:0] r, g, b,
	output [3:0] rd_addr
);

	wire blanking;
	reg [17:0] data_unsigned;
	wire [10:0] horizontal_count, vertical_count;
	
	vga640x480 _vga640x480 (
		.i_clk(clk), 
		.i_rst(rst), 
		.o_hs(hsync), 
		.o_vs(vsync), 
		.o_blanking(blanking), 
		.o_x(horizontal_count),
		.o_y(vertical_count)
	);
	
	assign rd_addr = (horizontal_count > 639) ? 0 : (horizontal_count / 40);
	
	always @(posedge clk) begin
		if (blanking || rst) begin
			data_unsigned = 0;
		end
		else begin
			/*
			if (rd_addr == 0) begin
				data_unsigned = (data_in[23]) ? data_in * -1: data_in;
			end 
			else begin
				data_unsigned = (data_in[23]) ? data_in * -1: data_in;
				data_unsigned = data_unsigned << 4;
			end
			*/
			data_unsigned = (data_in[23]) ? data_in * -1: data_in;
			data_unsigned = (data_unsigned < 100000) ? data_unsigned : 100000; 
			//data_unsigned = data_unsigned << 2;
			//data_unsigned = 600;
		end
	end
	
	// TODO: Instantiate data module as defined above
	data _data(
		.clk(clk), 
		.hblank(blanking), 
		.vblank(blanking), 
		.horizontal_count(horizontal_count), 
		.vertical_count(vertical_count), 
		.data_in(data_unsigned), 
		.r(r), 
		.g(g), 
		.b(b)
	);
	
endmodule