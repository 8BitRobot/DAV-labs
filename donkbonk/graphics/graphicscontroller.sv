module graphicscontroller(gameclk, rst, x, y, dataOut, controls, address);
	localparam BOARD_WIDTH = 12; // 12x14
    localparam BOARD_HEIGHT = 14;

    localparam BOARD_LEFT = 0;
    localparam BOARD_RIGHT = BOARD_LEFT + (BOARD_WIDTH-2) + 1;
    localparam BOARD_BOTTOM = 0;
    localparam BOARD_TOP = BOARD_BOTTOM + BOARD_HEIGHT + 1;
    input gameclk;
	input rst;
    input [5:0] x; // 40 // 800 // goes from 0 to 40
    input [5:0] y; // 24 // 525 // goes from 0 to 26 ig
    input [2:0] controls;
    output reg [7:0] dataOut; // color going out
    output reg [9:0] address;
    wire [0:(BOARD_WIDTH * 8 - 1)] colorValues [0:(BOARD_HEIGHT - 1)];
        // row and column are 640 by 480
        // divided by 20, that's 32 by 24
    gamecontroller #(BOARD_WIDTH, BOARD_HEIGHT) hollowknight(gameclk, rst, controls, colorValues);

    wire [5:0] x_scaled = x / 2;
    wire [5:0] y_scaled = y / 2;

    always_comb begin
        if (x >= 32 || y >= 24) begin
            address = 0;
        end
        else begin
            address = y * 32 + x;
        end

        if (y_scaled == BOARD_LEFT ||
            y_scaled == BOARD_RIGHT ||
            (x_scaled == BOARD_BOTTOM && BOARD_LEFT <= y_scaled && y_scaled <= BOARD_RIGHT) ||
            (x_scaled == BOARD_TOP && BOARD_LEFT <= y_scaled && y_scaled <= BOARD_RIGHT)) begin
            dataOut = 8'b11111111;
        end
        // Board
        else if ((BOARD_LEFT < y_scaled) && (y_scaled < BOARD_RIGHT) && (BOARD_BOTTOM < x_scaled) && (BOARD_TOP > x_scaled)) begin
            dataOut = colorValues[(BOARD_TOP - 1) - x_scaled][((y_scaled - BOARD_LEFT) * 8) +: 8];
        end
        else begin
            dataOut = 8'b0;
        end
    end

endmodule