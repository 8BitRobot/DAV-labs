module fft_4point_16bit (clk, reset, start, in0, in1, in2, in3, out0, out1, out2, out3, done);
    input clk;
    input reset;
    input reg [15:0] in0, in1, in2, in3;
    input start;
    
    output reg [15:0] out0, out1, out2, out3;

    output reg done;

    wire [15:0] W_0_2 = 16'b1000000000000000;
    wire [15:0] W_0_4 = 16'b1000000000000000;
    wire [15:0] W_1_4 = 16'b0000000010000000;

    reg [15:0] butter_A;
    reg [15:0] butter_B;
    reg [15:0] butter_W;
    reg [15:0] butter_plus;
    reg [15:0] butter_minus;

    reg [15:0] fly_A;
    reg [15:0] fly_B;
    reg [15:0] fly_W;
    reg [15:0] fly_plus;
    reg [15:0] fly_minus;

    reg [1:0] current_stage = 2'b00;
    reg [1:0] current_stage_d = 2'b00;
    parameter RESET = 2'b00;
    parameter STAGE_1 = 2'b01;
    parameter STAGE_2 = 2'b10;
    parameter DONE = 2'b11;

    // state machine time??
    // another definition of fsm: f-word s-word machines (man)

    butterfly #(16) butter(butter_A, butter_B, butter_W, butter_plus, butter_minus);
    butterfly #(16) fly(fly_A, fly_B, fly_W, fly_plus, fly_minus);

    always @(posedge clk) begin

        current_stage <= current_stage_d;
        
        case (current_stage)
            RESET: begin
                // hold at 0 whatever that means
                out0 <= 16'b0;
                out1 <= 16'b0;
                out2 <= 16'b0;
                out3 <= 16'b0;
            end
            STAGE_1: begin
                // assign values
                // run first butterfly units
                // bA - X0, bB - X2, fA - X1, fB - X3
                butter_A <= in0;
                butter_B <= in2;
                fly_A <= in1;
                fly_B <= in3;
                butter_W <= W_0_2;
                fly_W <= W_0_2;

            end
            STAGE_2: begin
                // reassign values
                // run second butterfly units
                butter_A <= butter_plus;
                butter_B <= fly_plus;
                fly_A <= butter_minus;
                fly_B <= fly_minus;
                butter_W <= W_0_4;
                fly_W <= W_1_4;
            end
            DONE: begin
                //outputs set here
                out0 <= butter_plus;
                out1 <= fly_plus;
                out2 <= butter_minus;
                out3 <= fly_minus;
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
                current_stage_d = DONE;
            end
            DONE: begin
                if (!start) current_stage_d = RESET;
                else current_stage_d = DONE;
            end
        endcase
    end

endmodule