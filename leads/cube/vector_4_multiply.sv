module vector_4_multiply(
    input clk,
	input source_ready,
	input input_valid,
    input [15:0] A [0:3] [0:3],
    input [15:0] v [0:3],
	output reg [15:0] Av [0:3],
	output sink_ready,
	output reg output_valid
);

    localparam CYCLE_COUNT = 4;
	
	reg running = 0;

	reg [$clog2(CYCLE_COUNT):0] counter = 0;
	reg [$clog2(CYCLE_COUNT):0] counter_d;

    reg [15:0] A_reg [0:3] [0:3];
    reg [15:0] v_reg [0:3];

    reg [15:0] Av [0:3];

    always @(posedge clk) begin
        if (input_valid && sink_ready) begin
			running <= 1;
            A_reg <= A;
            v_reg <= v;
		end else if (counter == CYCLE_COUNT) begin
			running <= 0;
		end
		
		if (counter == CYCLE_COUNT) begin
			output_valid <= 1;
		end else if (source_ready && output_valid) begin
			output_valid <= 0;
		end
		
		Av <= Av_d;
		
		counter <= counter_d;
    end

    always_comb begin
        if (running) counter_d = counter + 1;
		else counter_d = 0;
    end

    if (running) begin
        if (counter == 0) begin
            for (integer i = 0; i < 3; i = i + 1) begin
                Av_d[i] = A[0][i] * v[i];
            end
            Av_d[3] = 1;
        end else begin
            for (integer i = 0; i < 3; i = i + 1) begin
                Av_d[i] = Av[i] + A[counter][i] * v[i];
            end
            Av_d[3] = 1;
        end
    end else begin
        Av_d = Av;
    end
endmodule