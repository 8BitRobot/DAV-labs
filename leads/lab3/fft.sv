module fft32 (
	input      [31:0] samples     [0:3],
	input             clk,
	input             reset,
	input             start,
	output reg [31:0] frequencies [0:3],
	output            done
);

	localparam WIDTH = 32;

	localparam RESET = 2'd0;
	localparam STAGE1 = 2'd1;
	localparam STAGE2 = 2'd2;
	localparam DONE = 2'd3;

	reg [1:0] fft_state = RESET;
	reg [1:0] fft_state_d;
	
	assign done = fft_state == DONE;
	
	reg signed [WIDTH-1:0] butterfly_inputs  [0:3];
	reg signed [WIDTH-1:0] butterfly_twiddles [0:1];
	reg signed [WIDTH-1:0] butterfly_outputs [0:3];
	reg signed [WIDTH-1:0] butterfly_outputs_saved [0:3];
	localparam W_0_4 = 32'h7fff0000;
	localparam W_1_4 = 32'h00008000;
	
	butterfly #(WIDTH) b1(
		butterfly_inputs[0],
		butterfly_inputs[1],
		butterfly_twiddles[0],
		butterfly_outputs[0],
		butterfly_outputs[1]
	);
	butterfly #(WIDTH) b2(
		butterfly_inputs[2],
		butterfly_inputs[3],
		butterfly_twiddles[1],
		butterfly_outputs[2],
		butterfly_outputs[3]
	);
	
	reg [1:0] start_sr = 0;
	reg [1:0] reset_sr = 0;
	
	always @(posedge clk) begin
		start_sr  <= {start_sr[0], start};
		reset_sr  <= {reset_sr[0], reset};
		fft_state <= fft_state_d;
		
		for (integer i = 0; i < 4; i = i + 1) begin
			butterfly_outputs_saved[i] <= butterfly_outputs[i];
		end
		
		if (fft_state == DONE) begin
			frequencies[0] <= butterfly_outputs_saved[0];
			frequencies[1] <= butterfly_outputs_saved[2];
			frequencies[2] <= butterfly_outputs_saved[1];
			frequencies[3] <= butterfly_outputs_saved[3];
		end
	end
	
	always_comb begin
		case (fft_state)
			RESET: begin
				if (start_sr == 2'b01) begin
					fft_state_d = STAGE1;
				end else begin
					fft_state_d = RESET;
				end
				
				butterfly_inputs[0] = 0;
				butterfly_inputs[1] = 0;
				butterfly_inputs[2] = 0;
				butterfly_inputs[3] = 0;
				butterfly_twiddles[0] = 0;
				butterfly_twiddles[1] = 0;
			end
			STAGE1: begin
				fft_state_d = STAGE2;
				
				butterfly_inputs[0] = samples[0];
				butterfly_inputs[1] = samples[2];
				butterfly_inputs[2] = samples[1];
				butterfly_inputs[3] = samples[3];
				butterfly_twiddles[0] = W_0_4;
				butterfly_twiddles[1] = W_0_4;
			end
			STAGE2: begin
				fft_state_d = DONE;
				
				butterfly_inputs[0] = butterfly_outputs_saved[0];
				butterfly_inputs[1] = butterfly_outputs_saved[2];
				butterfly_inputs[2] = butterfly_outputs_saved[1];
				butterfly_inputs[3] = butterfly_outputs_saved[3];
				butterfly_twiddles[0] = W_0_4;
				butterfly_twiddles[1] = W_1_4;
			end
			DONE: begin
				if (reset_sr == 2'b01) begin
					fft_state_d = RESET;
				end else begin
					fft_state_d = DONE;
				end
				
				butterfly_inputs[0] = 0;
				butterfly_inputs[1] = 0;
				butterfly_inputs[2] = 0;
				butterfly_inputs[3] = 0;
				butterfly_twiddles[0] = 0;
				butterfly_twiddles[1] = 0;
			end
		endcase
	end

endmodule

module fft16 (
	input      [15:0] samples     [0:3],
	input             clk,
	input             reset,
	input             start,
	output reg [15:0] frequencies [0:3],
	output            done
);

	localparam WIDTH = 16;

	localparam RESET = 2'd0;
	localparam STAGE1 = 2'd1;
	localparam STAGE2 = 2'd2;
	localparam DONE = 2'd3;

	reg [1:0] fft_state = RESET;
	reg [1:0] fft_state_d;
	
	assign done = fft_state == DONE;
	
	reg signed [WIDTH-1:0] butterfly_inputs  [0:3];
	reg signed [WIDTH-1:0] butterfly_twiddles [0:1];
	reg signed [WIDTH-1:0] butterfly_outputs [0:3];
	reg signed [WIDTH-1:0] butterfly_outputs_saved [0:3];
	localparam W_0_4 = 16'h7f00;
	localparam W_1_4 = 16'h0080;
	
	butterfly #(WIDTH) b1(
		butterfly_inputs[0],
		butterfly_inputs[1],
		butterfly_twiddles[0],
		butterfly_outputs[0],
		butterfly_outputs[1]
	);
	butterfly #(WIDTH) b2(
		butterfly_inputs[2],
		butterfly_inputs[3],
		butterfly_twiddles[1],
		butterfly_outputs[2],
		butterfly_outputs[3]
	);
	
	reg [1:0] start_sr = 0;
	reg [1:0] reset_sr = 0;
	
	always @(posedge clk) begin
		start_sr  <= {start_sr[0], start};
		reset_sr  <= {reset_sr[0], reset};
		fft_state <= fft_state_d;
		
		for (integer i = 0; i < 4; i = i + 1) begin
			butterfly_outputs_saved[i] <= butterfly_outputs[i];
		end
		
		if (fft_state == DONE) begin
			frequencies[0] <= butterfly_outputs_saved[0];
			frequencies[1] <= butterfly_outputs_saved[2];
			frequencies[2] <= butterfly_outputs_saved[1];
			frequencies[3] <= butterfly_outputs_saved[3];
		end
	end
	
	always_comb begin
		case (fft_state)
			RESET: begin
				if (start_sr == 2'b01) begin
					fft_state_d = STAGE1;
				end else begin
					fft_state_d = RESET;
				end
				
				butterfly_inputs[0] = 0;
				butterfly_inputs[1] = 0;
				butterfly_inputs[2] = 0;
				butterfly_inputs[3] = 0;
				butterfly_twiddles[0] = 0;
				butterfly_twiddles[1] = 0;
			end
			STAGE1: begin
				fft_state_d = STAGE2;
				
				butterfly_inputs[0] = samples[0];
				butterfly_inputs[1] = samples[2];
				butterfly_inputs[2] = samples[1];
				butterfly_inputs[3] = samples[3];
				butterfly_twiddles[0] = W_0_4;
				butterfly_twiddles[1] = W_0_4;
			end
			STAGE2: begin
				fft_state_d = DONE;
				
				butterfly_inputs[0] = butterfly_outputs_saved[0];
				butterfly_inputs[1] = butterfly_outputs_saved[2];
				butterfly_inputs[2] = butterfly_outputs_saved[1];
				butterfly_inputs[3] = butterfly_outputs_saved[3];
				butterfly_twiddles[0] = W_0_4;
				butterfly_twiddles[1] = W_1_4;
			end
			DONE: begin
				if (reset_sr == 2'b01) begin
					fft_state_d = RESET;
				end else begin
					fft_state_d = DONE;
				end
				
				butterfly_inputs[0] = 0;
				butterfly_inputs[1] = 0;
				butterfly_inputs[2] = 0;
				butterfly_inputs[3] = 0;
				butterfly_twiddles[0] = 0;
				butterfly_twiddles[1] = 0;
			end
		endcase
	end

endmodule