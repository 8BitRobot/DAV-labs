module matrix_4_multiply(
	input clk,
	input source_ready,
	input input_valid,
	input [15:0] A [0:3] [0:3],
	input [15:0] B [0:3] [0:3],
	input normalize,
	output reg [15:0] M [0:3] [0:3],
	output sink_ready,
	output reg output_valid
);
	localparam SIZE = 4;
	localparam SYSTOLIC_ARRAY_SIZE = 2 * SIZE - 1;
	localparam PADDED_ARRAY_SIZE = 2 * SYSTOLIC_ARRAY_SIZE - 1;
	localparam CYCLE_COUNT = 2 * SIZE + 1;
	
	reg running = 0;
	
	assign sink_ready = !running;

	reg [31:0] M_d [0:(SIZE-1)] [0:(SIZE-1)];

	reg [$clog2(CYCLE_COUNT):0] counter = 0;
	reg [$clog2(CYCLE_COUNT):0] counter_d;
	
	reg [15:0] A_sys [0:(SIZE-1)] [0:(PADDED_ARRAY_SIZE-1)];
	reg [15:0] A_sys_d [0:(SIZE-1)] [0:(PADDED_ARRAY_SIZE-1)];
	reg [15:0] B_sys [0:(PADDED_ARRAY_SIZE-1)] [0:(SIZE-1)];
	reg [15:0] B_sys_d [0:(PADDED_ARRAY_SIZE-1)] [0:(SIZE-1)];

	reg normalize_reg = 0;

	initial begin
		output_valid = 0;
		for (integer i = 0; i < SIZE; i = i + 1) begin
			for (integer j = 0; j < SIZE; j = j + 1) begin
				
			end
		end
	end

	always @(posedge clk) begin
		if (input_valid && sink_ready) begin
			running <= 1;
			A_sys <= A_sys_d;
			B_sys <= B_sys_d;
			normalize_reg <= normalize;
		end else if (counter == CYCLE_COUNT) begin
			running <= 0;
		end
		
		if (counter == CYCLE_COUNT) begin
			output_valid <= 1;
		end else if (source_ready && output_valid) begin
			output_valid <= 0;
		end
		
		M <= M_d;
		
		counter <= counter_d;
	end
	
	always_comb begin
		if (running) counter_d = counter + 1;
		else counter_d = 0;
		
		for (integer i = 0; i < SIZE; i = i + 1) begin
			for (integer j = 0; j < PADDED_ARRAY_SIZE; j = j + 1) begin
				if (j >= SYSTOLIC_ARRAY_SIZE - i - 1 && j < SYSTOLIC_ARRAY_SIZE + SIZE - 1 - i) begin
					A_sys_d[i][j] = A[i][PADDED_ARRAY_SIZE - SIZE - j - i];
					B_sys_d[j][i] = B[PADDED_ARRAY_SIZE - SIZE - j - i][i];
				end else begin
					A_sys_d[i][j] = 0;
					B_sys_d[j][i] = 0;
				end
			end
		end
		
		if (running) begin
			for (integer i = 0; i < SIZE; i = i + 1) begin
				for (integer j = 0; j < SIZE; j = j + 1) begin
					if (normalize_reg) begin
						M_d[i][j] = (counter == 0 ? 0 : M[i][j]) + (A_sys[i][PADDED_ARRAY_SIZE - SIZE - counter + j] * B_sys[PADDED_ARRAY_SIZE - SIZE - counter + i][j]) >> 15;
					end else begin
						M_d[i][j] = (counter == 0 ? 0 : M[i][j]) + (A_sys[i][PADDED_ARRAY_SIZE - SIZE - counter + j] * B_sys[PADDED_ARRAY_SIZE - SIZE - counter + i][j])
					end
				end
			end
		end else begin
			M_d <= M;
		end
		
	end

endmodule