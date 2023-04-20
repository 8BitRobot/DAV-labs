module gamecontroller(clk, newPieceTrigger, controls, colorValues);
    localparam BOARD_WIDTH = 40;
    input clk;
    input newPieceTrigger;
    input reg [1:0] controls;
    output logic [0:79] colorValues [0:11];
    logic [0:BOARD_WIDTH-1] board [0:11];
    logic [0:(BOARD_WIDTH/4) - 1] boardPieceOnly [0:11];
    logic [0:BOARD_WIDTH - 1] storeboard [0:11];
    logic [0:(BOARD_WIDTH/4) - 1] storeboardPieceOnly [0:11];
    logic [0:BOARD_WIDTH-1] fullboard [0:11];
    logic [0:(BOARD_WIDTH/4) - 1] fullboardPieceOnly [0:11];
    // parameter LINE_SEGMENTY_PIECE = 3'b000;
    // parameter TEEEEEEEEEEEE_PIECE = 3'b001;
    // parameter QUADRILATERAL_PIECE = 3'b010;
    // parameter BACKWARDS___L_PIECE = 3'b011;
    // parameter NOTBACKWARDSL_PIECE = 3'b100;
    // parameter KINDOFLIKEA_Z_PIECE = 3'b101;
    // parameter KINDOFLIKEANS_PIECE = 3'b110;
    // parameter CLAIRESCURSED_PIECE = 3'b111;

    parameter NO_PIECE     = 4'b0000;
    parameter T_PIECE      = 4'b0001;
    parameter SQUARE_PIECE = 4'b0010;
    //parameter ㅁロㄖ口_PIECE = 4'b0010;
    parameter J_PIECE      = 4'b0011;
    parameter L_PIECE      = 4'b0100;
    parameter Z_PIECE      = 4'b0101;
    parameter S_PIECE      = 4'b0110;
    parameter LINE_PIECE   = 4'b0111;
    parameter CURSED_PIECE = 4'b1000;

    parameter SEND_INDEX   = 3'b000;
    parameter SEND_ADDRESS = 3'b001;
    parameter GET_PIECE_1  = 3'b010;
    parameter GET_PIECE_2  = 3'b011;
    parameter ADD_PIECE    = 3'b100;
    parameter IDLE         = 3'b101;
    

    parameter RIGHT = 2'b01;
    parameter LEFT = 2'b10;
    parameter BOTH = 2'b11;

    reg [2:0] piece_fetch_state = SEND_INDEX;
    reg [2:0] piece_fetch_state_d;

    reg [7:0] current_piece_addr;
    reg [3:0] piece_to_get = LINE_PIECE;
    reg [3:0] moving_piece [3:0];

    reg [7:0] dataOut;
    reg [5:0] addrIn;
	
	// IF SIMULATION
	reg [7:0] blockblock [0:63];

    reg [1:0] controls_left_sr = 2'b0;
    reg [1:0] controls_right_sr = 2'b0;

    reg [1:0] controls_pulsed;
	 
    integer i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, a, b, c, d, e, f, g, h; // iterators
    
    reg [0:10] nextFrameCollisions;

    wire blockenspiel;
    clockDivider dropitlikeitshot(clk, 2 * 4, 0, blockenspiel);
	 
    // clockDivider dropitlikeitshot(clk, 400000, 0, blockenspiel);
    reg [1:0] blockenspiel_sr;
    
    initial begin
        $readmemb("C:/Users/premg/IEEE/DAV/donkbonk/rom/rom_init.txt", blockblock);
        for (i = 0; i < 12; i = i + 1) begin
            board[i] = 40'b0;
            boardPieceOnly[i] = 10'b0;
			storeboard[i] = 40'b0;
            storeboardPieceOnly[i] = 10'b0;
        end
    end
	 // IF NOT SIMULATION
	 
    // rom blockblockbitch(addrIn, clk, dataOut);
    // rip blockblockbitch, you will be missed o7

    boardToColors lettherebelight(fullboard, colorValues);

    always @(posedge clk) begin
        blockenspiel_sr <= {blockenspiel_sr[0], blockenspiel};
        controls_left_sr <= {controls_left_sr[0], controls[0]};
        controls_right_sr <= 2'b0;
        
        if (blockenspiel_sr == 2'b01) begin
            if ((| board[11]) || (| nextFrameCollisions)) begin
                for (i = 0; i < 12; i = i + 1) begin
                    storeboard[i] <= board[i] | storeboard[i];
                    storeboardPieceOnly[i] <= boardPieceOnly[i] | storeboardPieceOnly[i];
                end
                for (i = 11; i > 0; i = i - 1) begin
                    board[i] <= 0;
                    boardPieceOnly[i] <= 0;
                end
            end else begin
                case(controls_pulsed)
                    2'b01: begin //  move right
                        for (i = 11; i > 0; i = i - 1) begin
                            board[i] <= board[i-1] >> 4;
                            boardPieceOnly[i] <= boardPieceOnly[i-1] >> 1;
                        end
                    end
                    2'b10: begin
                        for (i = 11; i > 0; i = i - 1) begin
                            board[i] <= board[i-1] << 4;
                            boardPieceOnly[i] <= boardPieceOnly[i-1] << 1;
                        end
                    end
                    2'b00: begin
                        for (i = 11; i > 0; i = i - 1) begin
                            board[i] <= board[i-1] >> 4;
                            boardPieceOnly[i] <= boardPieceOnly[i-1] >> 1;
                        end
                    end
                    default: begin
                        for (i = 11; i > 0; i = i - 1) begin
                            board[i] <= board[i-1] >> 4;
                            boardPieceOnly[i] <= boardPieceOnly[i-1] >> 1;
                        end
                    end
                endcase
                board[0] <= 0;
                boardPieceOnly[0] <= 0;
            end
        end
        
        case (piece_fetch_state)
            SEND_INDEX: begin
                for (i = 0; i < 12; i = i + 1) begin
                    board[i] <= 0;
                end
                addrIn <= {3'b0, piece_to_get};
            end
            SEND_ADDRESS: begin
                current_piece_addr <= dataOut;
                addrIn <= {1'b0, dataOut[3:0], 1'b0};
            end
            GET_PIECE_1: begin
                addrIn <= addrIn + 1;
                moving_piece[0] <= dataOut[7:4];
                moving_piece[1] <= dataOut[3:0];
            end
            GET_PIECE_2: begin
                addrIn <= 6'b0;
                moving_piece[2] <= dataOut[7:4];
                moving_piece[3] <= dataOut[3:0];
            end
            ADD_PIECE: begin
                for (i = 0; i < 4; i = i + 1) begin
                    for (j = 12; j < 28; j = j + 4) begin
                        k = (j - 12) / 4;
                        if (moving_piece[i][k]) begin
                            board[i][j +: 4] <= piece_to_get;
                            boardPieceOnly[i][j / 4] <= 1;
                        end
                    end
                end
            end
            IDLE: begin
                addrIn <= 6'b0;
            end
        endcase
        
        if (newPieceTrigger && piece_fetch_state == IDLE) begin
            piece_to_get <= (piece_to_get + 1) % 9;
            piece_fetch_state <= SEND_INDEX;
        end
        else begin
            piece_fetch_state <= piece_fetch_state_d;
        end
    end
	 
	always @(negedge clk) begin
		dataOut <= blockblock[addrIn];
	end

    always_comb begin
        for (l = 0; l < 12; l = l + 1) begin
            fullboard[l] = board[l] | storeboard[l];
            fullboardPieceOnly[l] = boardPieceOnly[l] | storeboardPieceOnly[l];
        end
        for (m = 0; m < 11; m = m + 1) begin
            nextFrameCollisions[m] = | (boardPieceOnly[m] & storeboardPieceOnly[m + 1]);
        end

        controls_pulsed[1] = controls_left_sr == 2'b01;
        controls_pulsed[0] = controls_right_sr == 2'b01;

        case(piece_fetch_state) 
            SEND_INDEX: begin
                piece_fetch_state_d = SEND_ADDRESS;
            end
            SEND_ADDRESS: begin
                piece_fetch_state_d = GET_PIECE_1;
            end
            GET_PIECE_1: begin
                piece_fetch_state_d = GET_PIECE_2;
            end
            GET_PIECE_2: begin
                piece_fetch_state_d = ADD_PIECE;
            end
            ADD_PIECE: begin
                piece_fetch_state_d = IDLE;
            end
            IDLE: begin
                piece_fetch_state_d = IDLE;
            end
        endcase
    end


endmodule