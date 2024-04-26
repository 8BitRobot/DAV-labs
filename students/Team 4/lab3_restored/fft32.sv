module fft32
    # (parameter WIDTH = 32) (
    input reg [WIDTH-1:0] inputs [0:3], // in0, in1, in2, in3, 
    input reg clk,
    input reg reset, 
    input reg start, 
    output reg [WIDTH-1:0] outputs [0:3], // out0, out1, out2, out3,
    output reg done
    );

    // twiddly factors
    localparam W_04 = 32'b01111111111111110000000000000000;
    localparam W_14 = 32'b00000000000000001000000000000000; // RAHHH MERCEDES-AMG PETRONAS F1 TEAM MENTIONED

    // butterfly units 
    reg signed [WIDTH-1:0] bf0_in0;
    reg signed [WIDTH-1:0] bf0_in1;
    reg signed [WIDTH-1:0] bf0_w;
    wire signed [WIDTH-1:0] bf0_out0;
    wire signed [WIDTH-1:0] bf0_out1;
    reg signed [WIDTH-1:0] bf1_in0;
    reg signed [WIDTH-1:0] bf1_in1;
    reg signed [WIDTH-1:0] bf1_w;
    wire signed [WIDTH-1:0] bf1_out0;
    wire signed [WIDTH-1:0] bf1_out1;

    butterfree CATERPIE(bf0_in0, bf0_in1, bf0_w, bf0_out0, bf0_out1);
    butterfree METAPOD(bf1_in0, bf1_in1, bf1_w, bf1_out0, bf1_out1);

    // button shift registers
    reg [1:0] start_sr;
    reg [1:0] reset_sr;

    // 4pt fft: 2 stages + reset/done
    reg [1:0] currentState;
    reg [1:0] nextState;

    localparam STATE_SET = 2'b00;
    localparam STATE_S1 = 2'b01;
    localparam STATE_S2 = 2'b10;
    localparam STATE_DONE = 2'b11;

    // update state
    always @(posedge clk) begin
        start_sr <= {start_sr[0], start};
        reset_sr <= {reset_sr[0], reset};
        currentState <= nextState;

        if (currentState == STATE_SET) begin
            bf0_in0 <= inputs[0];
            bf0_in1 <= inputs[2]; 
            bf0_w <= W_04;
            bf1_in0 <= inputs[1];
            bf1_in1 <= inputs[3];
            bf1_w <= W_04;
        end else if (currentState == STATE_S1) begin
            bf0_in0 <= bf0_out0;
            bf0_in1 <= bf1_out0;
            bf0_w <= W_04;
            bf1_in0 <= bf0_out1; 
            bf1_in1 <= bf1_out1;
            bf1_w <= W_14;
        end

    end

    // states
    always_comb begin
        case (currentState)
            STATE_SET: begin
                if (start_sr == 2'b10) begin
                    nextState = STATE_S1;
                    outputs[0] = 32'b0;
                    outputs[1] = 32'b0;
                    outputs[2] = 32'b0;
                    outputs[3] = 32'b0;
                    done = 1'b0;
                end else begin
                    nextState = STATE_SET;
                    outputs[0] = 32'b0;
                    outputs[1] = 32'b0;
                    outputs[2] = 32'b0;
                    outputs[3] = 32'b0;
                    done = 1'b0;
                end
            end

            STATE_S1: begin
                nextState = STATE_S2;
                outputs[0] = 32'b0;
                outputs[1] = 32'b0;
                outputs[2] = 32'b0;
                outputs[3] = 32'b0;
                done = 1'b0;
            end

            STATE_S2: begin
                nextState = STATE_DONE;
                outputs[0] = 32'b0;
                outputs[1] = 32'b0;
                outputs[2] = 32'b0;
                outputs[3] = 32'b0;
                done = 1'b0;
            end

            STATE_DONE: begin
                if (reset_sr == 2'b10) begin
                    nextState = STATE_SET;
                    outputs[0] = 32'b0;
                    outputs[1] = 32'b0;
                    outputs[2] = 32'b0;
                    outputs[3] = 32'b0;
                    done = 1'b0;
                end else begin
                    nextState = STATE_DONE;
                    outputs[0] = bf0_out0;
                    outputs[1] = bf1_out0;
                    outputs[2] = bf0_out1;
                    outputs[3] = bf1_out1;
                    done = 1'b1;
                end
            end

            default: begin
                nextState = STATE_SET;
                outputs[0] = 32'b0;
                outputs[1] = 32'b0;
                outputs[2] = 32'b0;
                outputs[3] = 32'b0;
                done = 1'b0;
            end
        endcase
    end

    initial begin
        start_sr = 2'b11;
        reset_sr = 2'b11;
        currentState = STATE_SET;
    end

endmodule