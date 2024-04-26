`timescale 1ns/1ns
//C:/intelFPGA_lite/20.1/quartus/eda/sim_lib/altera_mf.v
module FFT_block #
(
	parameter MAW = 4
)
(
	input clk, rst,
	input wr_mic_en,				// tells the FFT_block to wait until the writing is over (one clock cycle)
	input [17:00] mic_data, 
	input v_sync,					// on negedge, will activate the start_rd sequence before starting the start_wr sequence afterwards
	output rd_mic_start,			// tells the storage_1_block to output values in bursts following clock cycle
	output [23:00] vga_data,	// data to vga_memory
	output wr_vga_start,
	
	input [3:0] sel_addr_wth
);
		
	wire start_wr, start_rd, idle;
	
	fft_module #(.MAW(MAW)) _fft_module
	(
		.clk(clk), 
		.rst(rst),
		.start_wr(start_wr),			// activates write mode: takes in 2^N data points on following clock cycle
		.start_rd(start_rd),			// activates read mode:  cycles through all 2^N frequencies immediately following clock cycle
		.wr_data({{6{mic_data[17]}}, mic_data}),			// port for inputting information, only takes in real numbers for data
		.idle(idle),    				// indicates that FFT is currently not in either mode
		.rd_data(vga_data),				// port for outputting the information
		.sel_addr_wth(sel_addr_wth)
	);
	
	fft_block_controller _fft_block_controller
	(
		.clk(clk),
		.rst(rst),
		.wr_mic_en(wr_mic_en),			// external control signals
		.v_sync(v_sync),					// external control
		.idle(idle),
		.rd_mic_start(rd_mic_start), 	// interal control
		.wr_vga_start(wr_vga_start), 	// 
		.start_wr(start_wr),
		.start_rd(start_rd)
	);
	
endmodule 

module fft_block_controller
(
	input clk, rst,
	input wr_mic_en, v_sync,
	input idle,
	output reg rd_mic_start, wr_vga_start,
	output reg start_wr, start_rd
);

	localparam IDLE 	= 0;
	localparam RD 		= 1;
	localparam RD1 	= 2;
	localparam WAIT1 	= 3;
	localparam WR 		= 4;
	localparam WR1 	= 5;
	localparam WR2		= 6;
	localparam WAIT2	= 7;
	
	reg n_rd_mic_start, n_wr_vga_start, n_start_wr, n_start_rd;
	reg [2:0] c_state, n_state;
	
	always @(posedge clk) begin
		if (rst) begin
			rd_mic_start	= 0;
			wr_vga_start	= 0;
			start_wr			= 0;
			start_rd			= 0;
			c_state			= IDLE;
		end
		else begin
			rd_mic_start	= n_rd_mic_start;
			wr_vga_start	= n_wr_vga_start;
			start_wr			= n_start_wr;
			start_rd			= n_start_rd;
			c_state			= n_state;
		end
	end

	always @(*) begin
		n_rd_mic_start	=  rd_mic_start;
		n_wr_vga_start	=  wr_vga_start;
		n_start_wr    	=  start_wr;	
		n_start_rd    	=  start_rd;	
	
		case (c_state)
			IDLE:
			begin
				if (~v_sync) begin
					n_state = RD;
					n_start_rd = 1'b1;
				end
				else begin
					n_state = IDLE;
				end
			end
			
			RD:
			begin
				n_start_rd = 1'b0;
				n_wr_vga_start = 1'b1;
				n_state = RD1;
			end
			
			RD1:
			begin
				n_wr_vga_start = 1'b0;
				n_state = WAIT1;
			end
			
			WAIT1:
			begin
				if (~idle || wr_mic_en) begin
					n_state = WAIT1;
				end
				else begin
					n_rd_mic_start = 1'b1;
					n_state = WR;
				end
			end
			
			WR:
			begin
				n_rd_mic_start = 1'b0;
				n_state = WR1;
			end
			
			WR1:
			begin
				n_start_wr = 1'b1;
				n_state = WR2;
			end
			
			WR2:
			begin
				n_state = WAIT2;
				n_start_wr = 1'b0;
			end
			
			WAIT2:
			begin
				if (~idle) begin
					n_state = WAIT2;
				end
				else begin
					n_state = IDLE;
				end
			end
			
			default n_state = IDLE;
			
		endcase
	end

endmodule 