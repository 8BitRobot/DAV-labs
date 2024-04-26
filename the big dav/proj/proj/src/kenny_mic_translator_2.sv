`define _NUM_DATA_BITS 31
`define _NUM_SAMPLE_BITS 18
`define _CALIBRATION {13'd226, 5'd0}

module kenny_mic_translator(input clk, input reset, input DOUT, output reg LRCLK, output reg BCLK, output reg new_t,
							 output reg [17:0] t);
	
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
			t <= 18'b0;
		end
		else if (data_counter < `_NUM_SAMPLE_BITS) begin
			data_counter <= data_counter + 6'b1;
			data_buffer <= {data_buffer[16:0], DOUT};
			new_t <= 1'b0;
			t <= t;
		end
		else if (data_counter == `_NUM_SAMPLE_BITS) begin
			data_counter <= data_counter + 6'b1;
			data_buffer <= 17'b0;
			if (LRCLK == 0) begin
				new_t <= 1'b1;
				t <= calibrated_data_buffer; //FFT Processor takes 18 bit 2's complement //use calibrated to remove base offset
			end
			else begin
				new_t <= 1'b0;
				t <= t;
			end
		end
		else if (data_counter >= `_NUM_DATA_BITS) begin
			data_counter <= 0;
			data_buffer <= 10'b0;
			new_t <= 1'b0;
		end
		else begin
			data_counter <= data_counter + 6'b1;
			t <= t;
		end
	end
	
endmodule