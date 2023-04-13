module graphicscontroller(clk, x, y, dataOut, address);
    input clk;
    input [4:0] x; // 32 // 800
    input [4:0] y; // 24 // 525
    output [7:0] dataOut; // color going out
    output [9:0] address;
// row and column are 640 by 480
// divided by 20, that's 32 by 24

    always_comb begin
        if (x >= 32 || y >= 24) begin
            address = 0;
        end
        else begin
            address = y * 32 + x;
        end

        if (x == 9 || x == 23 || (y == 23 && x > 9 && x < 23 )) begin
            dataOut = 8'b11111111;
        end
        else if ((9 < x) && (23 > x)) begin
            dataOut = 8'b11100011;
        end
        else begin
            dataOut = 8'b0;
        end
    end

endmodule