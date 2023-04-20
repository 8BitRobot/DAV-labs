module graphicscontroller(clk, newPieceTrigger, x, y, dataOut, controls, address);
    input clk;
	input newPieceTrigger;
    input [5:0] x; // 40 // 800 // goes from 0 to 40
    input [5:0] y; // 24 // 525 // goes from 0 to 26 ig
    input [1:0] controls;
    output reg [7:0] dataOut; // color going out
    output reg [9:0] address;
    wire [0:79] colorValues [0:11];
        // row and column are 640 by 480
        // divided by 20, that's 32 by 24
    gamecontroller hollowknight(clk, newPieceTrigger, controls, colorValues);

    always_comb begin
        if (x >= 32 || y >= 24) begin
            address = 0;
        end
        else begin
            address = y * 32 + x;
        end

        if (x == 9 || x == 26) begin
            dataOut = 8'b11111111;
        end
        else if ((9 < x) && (26 > x)) begin
            // find
            // dataOut = 8'b11100000;
            dataOut = colorValues[y/2][((x - 8)/2 * 8) +: 8];
        end
        else begin
            dataOut = 8'b0;
        end
    end

endmodule