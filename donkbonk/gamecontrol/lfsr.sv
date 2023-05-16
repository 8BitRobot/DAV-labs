module lfsr(
  input clk, // clock input
  input rst, // reset input
  output [3:0] randOut // 4-bit random output
);

    reg [7:0] state; // LFSR state register

    // 10111000

    initial begin
        state <= 4'b0010;
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= 4'b0001; // reset to initial state
        end else begin
            // calculate next state using XOR feedback
            state <= {state[6:0], state[7] ^ state[5] ^ state[4] ^ state[3]};
        end
    end

    assign randOut = {1'b0, state[2:0]} + 1; // use the LFSR output as random number

endmodule