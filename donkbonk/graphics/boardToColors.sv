module boardToColors #(parameter BOARD_WIDTH=10, BOARD_HEIGHT=12)(board, colorValues);
    input [0:BOARD_WIDTH * 4 - 1] board [0:BOARD_HEIGHT-1];
    output reg [0:BOARD_WIDTH * 8 - 1] colorValues [0:BOARD_HEIGHT-1];

    parameter T_PIECE      = 4'b0001;
    parameter SQUARE_PIECE = 4'b0010;
    parameter J_PIECE      = 4'b0011;
    parameter L_PIECE      = 4'b0100;
    parameter Z_PIECE      = 4'b0101;
    parameter S_PIECE      = 4'b0110;
    parameter LINE_PIECE   = 4'b0111;
	parameter CURSED_PIECE = 4'b1000;
    parameter FLASH_COLOR     = 4'b1111;

    integer i;
    integer j;

    always_comb begin
        for (i = 0; i < BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < BOARD_WIDTH; j = j + 1) begin
                case (board[i][(j*4) +: 4])
                    T_PIECE: begin
                        colorValues[i][(j*8) +: 8] = 8'b11110000;
                    end
                    SQUARE_PIECE: begin
                        colorValues[i][(j*8) +: 8] = 8'b11111001;
                    end
                    J_PIECE: begin
                        colorValues[i][(j*8) +: 8] = 8'b00010100;
                    end
                    L_PIECE: begin
                        colorValues[i][(j*8) +: 8] = 8'b01111111;
                    end
                    Z_PIECE: begin
                        colorValues[i][(j*8) +: 8] = 8'b01001111;
                    end
                    S_PIECE: begin
                        colorValues[i][(j*8) +: 8] = 8'b10001111;
                    end
                    LINE_PIECE: begin
                        colorValues[i][(j*8) +: 8] = 8'b11110011;
                    end
                    CURSED_PIECE: begin
                        colorValues[i][(j*8) +: 8] = 8'b11000000;
                    end
                    FLASH_COLOR: begin
                        colorValues[i][(j*8) +: 8] = 8'b10010010;
                    end
                    default: begin
                        colorValues[i][(j*8) +: 8] = 8'b00000000;
                    end
                endcase
            end
        end
    end
endmodule