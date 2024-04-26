`timescale 1ns/1ns

module Variable_FFT_top (
	input clk, rstn,
	input DOUT,
	output LRCLK, BCLK,
	output [3:0] r, g, b,
	output hsync, vsync,
	input [3:0] switch_arr
);

	parameter MAW = 10; // MAX_ADDR_WIDTH

	wire rd_mic_start, wr_mic_en, wr_vga_start;
	wire [17:00] mic_data;
	wire [23:00] vga_data;
	wire new_t;
	wire [17:00] t;
	wire [23:00] storage_2_data;
	wire [MAW-1:0] rd_vga_addr;
	wire wr_addr_wth;
	reg [3:0] sel_addr_wth;
	
	always_comb begin
		if (switch_arr < 4) begin
			sel_addr_wth = 4'd4;
		end else if (switch_arr > 10) begin
			sel_addr_wth = 4'd10;
		end else begin
			sel_addr_wth = switch_arr;
		end
	end
	
	kenny_mic_translator _kenny_mic_translator(
		.clk(clk),
		.reset(rstn),
		.DOUT(DOUT),
		.LRCLK(LRCLK),
		.BCLK(BCLK),
		.new_t(new_t),
		.t(t)
	);
	
	storage_1_block #(.MAW(MAW)) _storage_1_block // CHECK
	(
		.clk(clk), 
		.rst(~rstn),
		.new_t(new_t),
		.t(t),
		.rd_mic_start(rd_mic_start),
		.wr_mic_en(wr_mic_en),
		.q_a(mic_data),
		
		.sel_addr_wth(sel_addr_wth)
	);

	FFT_block #(.MAW(MAW)) _FFT_block // Note: gives all zeros when the sel_addr is not equal to the current addr
	(
		.clk(clk), 
		.rst(~rstn),
		.wr_mic_en(wr_mic_en),				// freezes block until write sequence is done
		.mic_data(mic_data), 
		.v_sync(vsync),						// on negedge, starts read sequence before starting write sequence
		.rd_mic_start(rd_mic_start),		// tells storage_2_block reading will start
		.vga_data(vga_data),					// FFT data to VGA data
		.wr_vga_start(wr_vga_start),
		
		.sel_addr_wth(sel_addr_wth)
	);
	
	storage_2_block #(.MAW(MAW)) _block
	(
		.clk(clk), 
		.rst(~rstn),
		.d_a(vga_data),
		.wr_vga_start(wr_vga_start),
		.rd_vga_addr(rd_vga_addr),
		.q_a(storage_2_data),
		
		.sel_addr_wth(sel_addr_wth)
	);
	
	VGA_generator #(.MAW(MAW)) _VGA_generator
	(
		.input_clk(clk), 
		.rst(~rstn),
		.data_in(storage_2_data),
		.vsync(vsync), 
		.hsync(hsync),
		.r(r), 
		.g(g), 
		.b(b),
		.rd_addr(rd_vga_addr),
		
		.sel_addr_wth(sel_addr_wth)
	);
	
endmodule 