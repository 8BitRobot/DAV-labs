`timescale 1ns/1ns

module fft_module #
(
	parameter MAW = 10
) 
(
	input clk, rst,
	input start_wr,			// reads 2^N data points next posedge
	input start_rd,			// outputs 2^N data points next posedge
	input [23:00] wr_data,	// input real numbers only.
	output idle,    			// module is idle
	output [23:00] rd_data,	// output real numbers only
	input [3:0] sel_addr_wth
);
	
	wire [MAW-1:0] address_a, address_b;
	wire [$clog2(MAW)-1:0] stage;
	wire wren_a, wren_b, rd_mic;
	wire [47:00] d_a, d_b, q_a, q_b, twiddle, result1, result2;
	reg [23:00] buffer; // buffers inputs for timing reasons
	wire rd_active;


	/*DEBUG SIGNALS
		wire [23:00] d_ar, d_ai, d_br, d_bi;
		wire [23:00] q_ar, q_ai, q_br, q_bi;
		wire [23:00] result1r, result1i;
		wire [23:00] result2r, result2i;
		assign d_ar = d_a[47:24];
		assign d_ai = d_a[23:00];
		assign d_br = d_b[47:24];
		assign d_bi = d_b[23:00];
		assign q_ar = q_a[47:24]; 
		assign q_ai = q_a[23:00]; 
		assign q_br = q_b[47:24]; 
		assign q_bi = q_b[23:00];
		assign result1r = result1[47:24];
		assign result1i = result1[23:00];
		assign result2r = result2[47:24];
		assign result2i = result2[23:00];
	//DEBUG SIGNALS END*/
	
	fft_controller_module #(.MAW(MAW)) _fft_controller_module
	(
		// External Control Signals
		.clk(clk),
		.rst(rst),
		.start_wr(start_wr),
		.start_rd(start_rd),
		.idle(idle),
		
		// Internal Control Signals
		.address_a(address_a),	// also tells twiddle module which twiddle to use
		.address_b(address_b),
		.stage(stage),				// Tells twiddle module which twiddle set to use
		.wren_a(wren_a),			
		.wren_b(wren_b),
		.rd_mic(rd_mic),			// Routes either the buffer or result1 information
		.rd_active(rd_active),	// Indicates that reading cycle is active
		
		.sel_addr_wth(sel_addr_wth)
	);
	
	always @(posedge clk) begin
		buffer <= wr_data;
	end
	
	assign d_a = rd_mic ? {buffer, 24'b0} : result1;
	assign d_b = result2;
	assign rd_data = rd_active ? q_a[47:24] : 0;

	fft_ram _fft_ram(
		.address_a({32'b0, address_a}), 
		.address_b({32'b0, address_b}),
		.clock(clk),
		.data_a(d_a), 
		.data_b(d_b),
		.wren_a(wren_a), 
		.wren_b(wren_b),
		.q_a(q_a),
		.q_b(q_b)
	);
	
	
	butterfly_module _butterfly_module
	(
		.num1(q_a),
		.num2(q_b),
		.twiddle(twiddle),
		.result1(result1),
		.result2(result2)
	);
	
	twiddle_module _twiddle_module
	(
		.clk(clk),
		.stage({32'b0, stage}),
		.address_a({32'b0, address_a}),
		.twiddle(twiddle)
	);
	
endmodule 
