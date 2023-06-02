module lfsr(
  input clk, // clock input
  input rst, // reset input
  output reg [3:0] randOut // 4-bit random output
);

    localparam T_PIECE      = 4'b0001;
    localparam SQUARE_PIECE = 4'b0010;
    localparam J_PIECE      = 4'b0011;
    localparam L_PIECE      = 4'b0100;
    localparam Z_PIECE      = 4'b0101;
    localparam S_PIECE      = 4'b0110;
    localparam LINE_PIECE   = 4'b0111;
    localparam CURSED_PIECE = 4'b1000;

    reg [7:0] state; // LFSR state register

    // 10111000

    initial begin
        state <= 8'b10101010;
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= 8'b10101010; // reset to initial state
        end else begin
            // calculate next state using XOR feedback
            state <= {state[6:0], state[7] ^ state[5] ^ state[4] ^ state[3]};
        end
    end

    always_comb begin
        if (state[5:0] < 2) begin
            randOut = CURSED_PIECE;
        end else if (state[5:0] < 10)  begin
            randOut = T_PIECE;
        end else if (state[5:0] < 19) begin
            randOut = SQUARE_PIECE;
        end else if (state[5:0] < 28) begin
            randOut = J_PIECE;
        end else if (state[5:0] < 37) begin
            randOut = L_PIECE;
        end else if (state[5:0] < 46) begin
            randOut = Z_PIECE;
        end else if (state[5:0] < 55) begin
            randOut = S_PIECE;
        end else begin
            randOut = LINE_PIECE;
        end
    end

    // assign randOut = {1'b0, state[2:0]} + 1; // use the LFSR output as random number

endmodule