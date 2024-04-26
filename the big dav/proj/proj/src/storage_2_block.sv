`timescale 1ns/1ns

module storage_2_block #
(
	parameter MAW = 10
)
(
	input clk, 
	input rst,
	input [23:00] d_a,
	input wr_vga_start,
	input [MAW-1:0] rd_vga_addr,
	output [23:0] q_a,
		
	input [3:0] sel_addr_wth
);

	wire [MAW-1:0] address_a;
	reg wren;
	reg [MAW-1:0] count, max_addr;
	
	always @(posedge clk) begin
		max_addr = {MAW{1'b1}};
		max_addr = max_addr << sel_addr_wth;
		max_addr = ~max_addr; 
	end
	
	vga_ram _vga_ram (
		.address({32'b0, address_a}),
		.clock(clk),
		.data(d_a),
		.wren(wren),
		.q(q_a)
	);

	
	assign address_a = wren ? count : rd_vga_addr;
	
	always @(posedge clk) begin
		if (rst) begin
			count <= max_addr;
			wren	<= 0;
		end
		else if (wr_vga_start) begin
			count <= 0;
			wren	<= 1'b1;
		end
		else if (count < max_addr) begin
			count <= count + 1'b1;
			wren	<= 1'b1;
		end
		else begin
			count <= count;
			wren <= 1'b0;
		end
	end

endmodule 