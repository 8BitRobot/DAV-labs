`timescale 1ns/1ns

module address_width_selection #
(
	parameter MAW = 10
)
(
	input [MAW-1:0] input_address,
	input [3:0] sel_addr_wth,
	output [MAW-1:0] output_address 
);

	reg [MAW-1:0] selection_arr;

	always_comb begin
		
		selection_arr = 0;
		
		for (int i = 0; i < MAW; i++) begin
			if (i < sel_addr_wth) begin
				selection_arr[i] = 1'b1;
			end
		end
		
	end
	
	assign output_address = selection_arr & input_address;

endmodule

module memory_component #
(
	parameter MAW = 10 // MAX_ADDR_WIDTH
)
(
	input clk, rst,
	input wr_mic_en, // from buffer
	input [17:00] buffer_data, // from buffer
	input rd_mic_start, // from FFT
	output rd_mic_en, // signal to buffer
	output [17:00] q_a, // to FFT
		
	input [3:0] sel_addr_wth
);

	wire wr_en;
	reg [MAW-1:0] head, count, max_addr;
	wire [MAW-1:0] address_a;
	wire [MAW-1:0] selected_address;
	
	//localparam max_addr = 2**MAW - 1;
	
	always @(posedge clk) begin
		max_addr = {MAW{1'b1}};
		max_addr = max_addr << sel_addr_wth;
		max_addr = ~max_addr; 
	end
	
	mic_ram _mic_ram(
		.address({32'b0, address_a}),
		.clock(clk),
		.data(buffer_data),
		.wren(wr_en),
		.q(q_a)
	);
	
	assign wr_en = wr_mic_en;
	
	address_width_selection #(10) select (head + count, sel_addr_wth, selected_address);
	
	assign address_a = wr_en ? head : selected_address;
	
	assign rd_mic_en = (count != max_addr);
	
	always @(posedge clk) begin
		if (wr_en) head = (head < max_addr) ? head + 1'b1 : 0;
		if (rst) head = 0;
	end
	
	always @(posedge clk) begin
		if (rst) begin
			count = max_addr;
		end
		else if (rd_mic_start) begin
			count = 0;
		end
		else if (count < max_addr) begin
			count = count + 1'b1;
		end
	end
	
endmodule 

module buffer_component 
(
	input clk, rst,
	input new_t_edge,
	input [17:00] mic_data,
	input rd_mic_en,
	output reg wr_mic_en,
	output reg [17:00] buffer_out
);

	reg full;

	always @ (posedge clk) begin
	
		if (rst) begin
			full 		<= 1'b0; 
			buffer_out  <= buffer_out;
			wr_mic_en	<= 1'b0;
		end 
		else if (new_t_edge) begin
			full		<= 1'b1;
			buffer_out	<= mic_data;
			wr_mic_en	<= 1'b0;
		end
		else if (~rd_mic_en && full) begin
			full		<= 1'b0;
			buffer_out	<= buffer_out;
			wr_mic_en	<= 1'b1;
		end
		else begin
			full		<= full;
			buffer_out	<= buffer_out;
			wr_mic_en	<= 1'b0;
		end
	
	end
	
	// new_t_edge comes in
	// registers first into the buffer
	// if rd_mic_en is low, will write immediately to the memory
	// if rd_mic_en is high, will wait until rd_mic_en low again to write immediately. 
	// What if both happen at the same time? The FFT will take precedence and the buffer will have a dropped input. Can't do much about it. 
	
endmodule 

module storage_1_block #
(
	parameter MAW = 10
)
(
	input clk, rst,
	input new_t,
	input [17:00] t,
	input rd_mic_start,
	output wr_mic_en,
	output [17:0] q_a,
		
	input [3:0] sel_addr_wth
);
	
	wire rd_mic_en;
	wire new_t_edge;
	reg detect1, detect2;
	wire [17:00] buffer_out;
	
	always @(posedge clk) begin
		detect1 <= new_t;
		detect2 <= detect1;
	end
	
	assign new_t_edge = detect1 && ~detect2;
	
	buffer_component _buffer_component (
		.clk(clk),
		.rst(rst),
		.new_t_edge(new_t_edge),
		.mic_data(t),
		.rd_mic_en(rd_mic_en),
		.wr_mic_en(wr_mic_en),
		.buffer_out(buffer_out)
	);
	
	memory_component #
	(
		.MAW(MAW)
	)
	_memory_component (
		.clk(clk), 
		.rst(rst),
		.wr_mic_en(wr_mic_en),
		.buffer_data(buffer_out),
		.rd_mic_en(rd_mic_en),
		.rd_mic_start(rd_mic_start), 
		.q_a(q_a),
		.sel_addr_wth(sel_addr_wth)
	);
	
endmodule 