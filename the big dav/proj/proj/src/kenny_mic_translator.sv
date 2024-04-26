`define _NUM_DATA_BITS 31
`define _NUM_SAMPLE_BITS 18
`define _CALIBRATION {13'd226, 5'd0}

module kenny_mic_translator(input input_clk, input reset, input DOUT, output reg LRCLK, output reg BCLK, output reg new_t,
							 output reg [17:0] t0, output reg [17:0] t1, output reg [17:0] t2, output reg [17:0] t3, 
							 output reg [17:0] t4, output reg [17:0] t5, output reg [17:0] t6, output reg [17:0] t7, 
							 output reg [17:0] t8, output reg [17:0] t9, output reg [17:0] t10, output reg [17:0] t11, 
							 output reg [17:0] t12, output reg [17:0] t13, output reg [17:0] t14, output reg [17:0] t15);
	
	wire clk;
	
	mic_pll _mic_pll(
		.inclk0(input_clk),
		.c0(clk)
	);
	
	reg [17:0] data_buffer;
	reg [6:0] data_counter;
	reg [31:0] bit_cnt;
	reg [17:0] calibrated_data_buffer;
	
	assign calibrated_data_buffer = data_buffer + `_CALIBRATION;
	
	always @ (clk, reset) begin
		if (reset == 1'b0) begin
			BCLK <= 1'b1;
		end
		else begin
			BCLK <= clk;
		end
	end
	
	always @ (negedge clk) begin
		if (reset == 1'b0) begin
			LRCLK <= 1'b1;
			bit_cnt <= 32'b0;
		end
		else if (bit_cnt < `_NUM_DATA_BITS) begin
			LRCLK <= LRCLK;
			bit_cnt <= bit_cnt + 32'b1;
		end
		else begin
			LRCLK <= ~LRCLK;
			bit_cnt <= 32'b0;
		end
	end
	
	always @ (posedge clk) begin
		if (reset == 1'b0) begin
			data_counter <= 7'b0;
			data_buffer <= 18'b0;
			new_t <= 1'b0;
			t15 <= 18'b0;
			t14 <= 18'b0;
			t13 <= 18'b0;
			t12 <= 18'b0;
			t11 <= 18'b0;
			t10 <= 18'b0;
			t9 <= 18'b0;
			t8 <= 18'b0;
			t7 <= 18'b0;
			t6 <= 18'b0;
			t5 <= 18'b0;
			t4 <= 18'b0;
			t3 <= 18'b0;
			t2 <= 18'b0;
			t1 <= 18'b0;
			t0 <= 18'b0;
		end
		else if (data_counter < `_NUM_SAMPLE_BITS) begin
			data_counter <= data_counter + 6'b1;
			data_buffer <= {data_buffer[16:0], DOUT};
			new_t <= 1'b0;
			t15 <= t15;
			t14 <= t14;
			t13 <= t13;
			t12 <= t12;
			t11 <= t11;
			t10 <= t10;
			t9 <= t9;
			t8 <= t8;
			t7 <= t7;
			t6 <= t6;
			t5 <= t5;
			t4 <= t4;
			t3 <= t3;
			t2 <= t2;
			t1 <= t1;
			t0 <= t0;
		end
		else if (data_counter == `_NUM_SAMPLE_BITS) begin
			data_counter <= data_counter + 6'b1;
			data_buffer <= 17'b0;
			if (LRCLK == 0) begin
				new_t <= 1'b1;
				t15 <= t14;
				t14 <= t13;
				t13 <= t12;
				t12 <= t11;
				t11 <= t10;
				t10 <= t9;
				t9 <= t8;
				t8 <= t7;
				t7 <= t6;
				t6 <= t5;
				t5 <= t4;
				t4 <= t3;
				t3 <= t2;
				t2 <= t1;
				t1 <= t0;
				t0 <= calibrated_data_buffer; //FFT Processor takes 18 bit 2's complement //use calibrated to remove base offset
			end
			else begin
				new_t <= 1'b0;
				t15 <= t15;
				t14 <= t14;
				t13 <= t13;
				t12 <= t12;
				t11 <= t11;
				t10 <= t10;
				t9 <= t9;
				t8 <= t8;
				t7 <= t7;
				t6 <= t6;
				t5 <= t5;
				t4 <= t4;
				t3 <= t3;
				t2 <= t2;
				t1 <= t1;
				t0 <= t0;
			end
		end
		else if (data_counter >= `_NUM_DATA_BITS) begin
			data_counter <= 0;
			data_buffer <= 10'b0;
			new_t <= 1'b0;
		end
		else begin
			data_counter <= data_counter + 6'b1;
			t15 <= t15;
			t14 <= t14;
			t13 <= t13;
			t12 <= t12;
			t11 <= t11;
			t10 <= t10;
			t9 <= t9;
			t8 <= t8;
			t7 <= t7;
			t6 <= t6;
			t5 <= t5;
			t4 <= t4;
			t3 <= t3;
			t2 <= t2;
			t1 <= t1;
			t0 <= t0;
		end
	end
	
endmodule

/*
`define _NUM_DATA_BITS 31
`define _NUM_SAMPLE_BITS 18
`define _CALIBRATION {13'd226, 5'd0}

module kenny_mic_translator(input input_clk, input reset, input DOUT, output reg LRCLK, output reg BCLK, output reg new_t, output reg [17:0] t0);
	
	wire clk;
	reg [17:0] data_buffer;
	reg [6:0] data_counter;
	reg [31:0] bit_cnt;
	reg [17:0] calibrated_data_buffer;
	
	mic_pll _mic_pll(
		.inclk0(input_clk),
		.c0(clk)
	);
	
	assign calibrated_data_buffer = data_buffer + `_CALIBRATION;
	
	always @ (clk, reset) begin
		if (reset == 1'b0) begin
			BCLK <= 1'b1;
		end
		else begin
			BCLK <= clk;
		end
	end
	
	always @ (negedge clk) begin
		if (reset == 1'b0) begin
			LRCLK <= 1'b1;
			bit_cnt <= 32'b0;
		end
		else if (bit_cnt < `_NUM_DATA_BITS) begin
			LRCLK <= LRCLK;
			bit_cnt <= bit_cnt + 32'b1;
		end
		else begin
			LRCLK <= ~LRCLK;
			bit_cnt <= 32'b0;
		end
	end
	
	always @ (posedge clk) begin
		if (reset == 1'b0) begin
			data_counter <= 7'b0;
			data_buffer <= 18'b0;
			new_t <= 1'b0;
			t0 <= 18'b0;
		end
		else if (data_counter < `_NUM_SAMPLE_BITS) begin
			data_counter <= data_counter + 6'b1;
			data_buffer <= {data_buffer[16:0], DOUT};
			new_t <= 1'b0;
			t0 <= t0;
		end
		else if (data_counter == `_NUM_SAMPLE_BITS) begin
			data_counter <= data_counter + 6'b1;
			data_buffer <= 17'b0;
			if (LRCLK == 0) begin
				new_t <= 1'b1;
				t0 <= calibrated_data_buffer; //FFT Processor takes 18 bit 2's complement //use calibrated to remove base offset
			end
			else begin
				new_t <= 1'b0;
				t0 <= t0;
			end
		end
		else if (data_counter >= `_NUM_DATA_BITS) begin
			data_counter <= 0;
			data_buffer <= 10'b0;
			new_t <= 1'b0;
		end
		else begin
			data_counter <= data_counter + 6'b1;
			t0 <= t0;
		end
	end
	
endmodule
*/