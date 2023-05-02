module fft_16point_36bit (clk, reset, start, inputs, outputs, done);

    localparam WIDTH = 35;
    
    input clk;
    input reset;
    input [WIDTH:0] inputs [0:15];
    input start;
    
    output reg [WIDTH:0] outputs [0:15];

    output reg done;

    // R = 1, I = 0
    // [WIDTH:0] W_0_16 = 36'b100000000000000000000000000000000000;
    wire [WIDTH:0] W_0_16 = 36'b011111111111111111000000000000000000;
    // cos(2pi/8) - jsin(2pi/8)
    wire [WIDTH:0] W_1_16 = 36'b011101100100010111110011110001101010;
    // cos(4pi/8) - jsin(4pi/8)
    wire [WIDTH:0] W_2_16 = 36'b010110100111111100101001011000000100;
    // cos(6pi/8) - jsin(6pi/8)
    wire [WIDTH:0] W_3_16 = 36'b001100001110010101100010011011101001;
    // cos(8pi/8) - jsin(8pi/8)
    wire [WIDTH:0] W_4_16 = 36'b000000000000000000100000000000000000;
    // cos(10pi/8) - jsin(10pi/8)
    wire [WIDTH:0] W_5_16 = 36'b110011110001101010100010011011101001;
    // cos(12pi/8) - jsin(12pi/8)
    wire [WIDTH:0] W_6_16 = 36'b101001011000000100101001011000000100;
    // cos(14pi/8) - jsin(14pi/8)
    wire [WIDTH:0] W_7_16 = 36'b100010011011101001110011101101100100;

    reg [WIDTH:0] A_vals     [0:7];
    reg [WIDTH:0] B_vals     [0:7];
    reg [WIDTH:0] W_vals     [0:7];
    reg [WIDTH:0] plus_values  [0:7];
    reg [WIDTH:0] minus_values [0:7];

    reg [2:0] current_stage = 2'b00;
    reg [2:0] current_stage_d = 2'b00;
    parameter RESET = 3'b000;
    parameter STAGE_1 = 3'b001;
    parameter STAGE_2 = 3'b010;
    parameter STAGE_3 = 3'b011;
    parameter STAGE_4 = 3'b100;
    parameter DONE = 3'b101;

    // state machine time??
    // anotheSr definition of fsm: f-word s-word machines (man)

    integer i, j, k, l, m;
    genvar h;

    generate
        for (h = 0; h < 8; h = h + 1) begin: BUTTERFLY_GEN
            butterfly #(WIDTH+1) icbinbeb(A_vals[h], B_vals[h], W_vals[h], plus_values[h], minus_values[h]);
        end
    endgenerate

    always @(posedge clk) begin
        current_stage <= current_stage_d;
        
        case (current_stage)
            RESET: begin
                // hold at 0 whatever that means
                for (l = 0; l < 16; l = l + 1) begin
                    outputs[l] <= 0;
                end
                done <= 0;
            end
            STAGE_1: begin
                // assign values
                // run first butterfly units
                // bA - X0, bB - X2, fA - X1, fB - X3
                
                for (i = 0; i < 8; i = i + 1) begin
                    // A_vals[i] <= inputs[i * 2];
                    // B_vals[i] <= inputs[i * 2 + 1];
                    W_vals[i] <= W_0_16;
                end
                A_vals[0] <= inputs[0];
                B_vals[0] <= inputs[8];

                A_vals[1] <= inputs[4];
                B_vals[1] <= inputs[12];

                A_vals[2] <= inputs[2];
                B_vals[2] <= inputs[10];

                A_vals[3] <= inputs[6];
                B_vals[3] <= inputs[14];

                A_vals[4] <= inputs[1];
                B_vals[4] <= inputs[9];

                A_vals[5] <= inputs[5];
                B_vals[5] <= inputs[13];

                A_vals[6] <= inputs[3];
                B_vals[6] <= inputs[11];
                
                A_vals[7] <= inputs[7];
                B_vals[7] <= inputs[15];
            end
            STAGE_2: begin
                // reassign values
                // run second butterfly units
                A_vals[0] <= plus_values[0];
                B_vals[0] <= plus_values[1];

                A_vals[1] <= minus_values[0];
                B_vals[1] <= minus_values[1];

                A_vals[2] <= plus_values[2];
                B_vals[2] <= plus_values[3];

                A_vals[3] <= minus_values[2];
                B_vals[3] <= minus_values[3];

                A_vals[4] <= plus_values[4];
                B_vals[4] <= plus_values[5];

                A_vals[5] <= minus_values[4];
                B_vals[5] <= minus_values[5];

                A_vals[6] <= plus_values[6];
                B_vals[6] <= plus_values[7];
                
                A_vals[7] <= minus_values[6];
                B_vals[7] <= minus_values[7];

                for (j = 0; j < 8; j = j + 1) begin
                    if (j % 2 == 0) begin
                        W_vals[j] <= W_0_16;
                    end else begin
                        W_vals[j] <= W_4_16;
                    end
                end
            end
            STAGE_3: begin
                A_vals[0] <= plus_values[0];
                B_vals[0] <= plus_values[2];

                A_vals[1] <= plus_values[1];
                B_vals[1] <= plus_values[3];

                A_vals[2] <= minus_values[0];
                B_vals[2] <= minus_values[2];

                A_vals[3] <= minus_values[1];
                B_vals[3] <= minus_values[3];

                A_vals[4] <= plus_values[4];
                B_vals[4] <= plus_values[6];

                A_vals[5] <= plus_values[5];
                B_vals[5] <= plus_values[7];

                A_vals[6] <= minus_values[4];
                B_vals[6] <= minus_values[6];
                
                A_vals[7] <= minus_values[5];
                B_vals[7] <= minus_values[7];

                for (m = 0; m < 8; m = m + 1) begin
                    if (m % 4 == 0) begin
                        W_vals[m] <= W_0_16;
                    end else if (m % 4 == 1) begin
                        W_vals[m] <= W_2_16;
                    end else if (m % 4 == 2) begin
                        W_vals[m] <= W_4_16;
                    end else begin
                        W_vals[m] <= W_6_16;
                    end
                end
            end
            STAGE_4: begin
                A_vals[0] <= plus_values[0];
                B_vals[0] <= plus_values[4];

                A_vals[1] <= plus_values[1];
                B_vals[1] <= plus_values[5];

                A_vals[2] <= plus_values[2];
                B_vals[2] <= plus_values[6];
                
                A_vals[3] <= plus_values[3];
                B_vals[3] <= plus_values[7];

                A_vals[4] <= minus_values[0];
                B_vals[4] <= minus_values[4];

                A_vals[5] <= minus_values[1];
                B_vals[5] <= minus_values[5];

                A_vals[6] <= minus_values[2];
                B_vals[6] <= minus_values[6];
                
                A_vals[7] <= minus_values[3];
                B_vals[7] <= minus_values[7];

                W_vals[0] <= W_0_16;
                W_vals[1] <= W_1_16;
                W_vals[2] <= W_2_16;
                W_vals[3] <= W_3_16;
                W_vals[4] <= W_4_16;
                W_vals[5] <= W_5_16;
                W_vals[6] <= W_6_16;
                W_vals[7] <= W_7_16;
                
            end
            DONE: begin
                //outputs set here
                for (k = 0; k < 16; k = k + 1) begin
                    if (k < 8) begin
                        outputs[k] <= plus_values[k];
                    end
                    else begin
                        outputs[k] <= minus_values[k - 8];
                    end
                end
                done <= 1;
            end
        endcase
    end

    always_comb begin
        case(current_stage)
            RESET: begin
                if (start) current_stage_d = STAGE_1;
                else current_stage_d = RESET;
            end
            STAGE_1: begin
                current_stage_d = STAGE_2;
            end
            STAGE_2: begin
                current_stage_d = STAGE_3;
            end
            STAGE_3: begin
                current_stage_d = STAGE_4;
            end
            STAGE_4: begin
                current_stage_d = DONE;
            end
            DONE: begin
                if (!start) current_stage_d = RESET;
                else current_stage_d = DONE;
            end
        endcase
    end

endmodule