module sevenSegDigit (
    input [3:0] in,
    input on,
    output logic [7:0] segments
);

    always_comb begin
        if (!on) begin
            segments = 8'b11111111;
        end else begin
            case (in)
                0 : begin
                    segments = 8'b11000000;
                end
                1 : begin
                    segments = 8'b11111001;
                end
                2 : begin
                    segments = 8'b10100100;
                end
                3 : begin
                    segments = 8'b10110000;
                end
                4 : begin
                    segments = 8'b10011001;
                end
                5 : begin
                    segments = 8'b10010010;
                end
                6 : begin
                    segments = 8'b10000010;
                end
                7 : begin
                    segments = 8'b11111000;
                end
                8 : begin
                    segments = 8'b10000000;
                end
                9 : begin
                    segments = 8'b10010000;
                end
                default: begin
                    segments = 8'b10111111;
                end
            endcase
        end
    end
endmodule
