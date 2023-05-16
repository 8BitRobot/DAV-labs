module gamecontroller #(parameter BOARD_WIDTH=10, BOARD_HEIGHT=12) (clk, newPiece, controls, colorValues, leds, seg);
    // ports
    input clk;
    input newPiece;
    input [2:0] controls;
    output logic [0:79] colorValues [0:11];

    // board arrays
    logic [0:BOARD_WIDTH * 4 - 1] board [0:11];
    logic [0:BOARD_WIDTH * 4 - 1] boardRotatedStates [0:3] [0:11];
    logic [0:BOARD_WIDTH - 1]     boardPieceOnly [0:11];
    logic [0:BOARD_WIDTH - 1]     boardPieceOnlyRotatedStates [0:3] [0:11];
    logic [0:BOARD_WIDTH * 4 - 1] storeboard [0:11];
    logic [0:BOARD_WIDTH - 1]     storeboardPieceOnly [0:11];
    logic [0:BOARD_WIDTH * 4 - 1] fullboard [0:11];
    logic [0:BOARD_WIDTH - 1]     fullboardPieceOnly [0:11];
    logic [0:BOARD_WIDTH - 1]     boardIfMoveLeft [0:11];
    logic [0:BOARD_WIDTH - 1]     boardIfMoveRight [0:11];
    
    output [0:9] leds;
    output [7:0] seg [5:0];
    assign leds = storeboardPieceOnly[11];
    
    // piece codes
    localparam T_PIECE      = 4'b0001;
    localparam SQUARE_PIECE = 4'b0010;
    localparam J_PIECE      = 4'b0011;
    localparam L_PIECE      = 4'b0100;
    localparam Z_PIECE      = 4'b0101;
    localparam S_PIECE      = 4'b0110;
    localparam LINE_PIECE   = 4'b0111;
    localparam CURSED_PIECE = 4'b1000;
    localparam FLASH_COLOR  = 4'b1001;

    // piece fetch FSM
    localparam SEND_INDEX   = 3'b000;
    localparam SEND_ADDRESS = 3'b001;
    localparam GET_PIECE    = 3'b010;
    localparam ADD_PIECE    = 3'b011;
    localparam IDLE         = 3'b100;

    reg [2:0] piece_fetch_state = SEND_ADDRESS;
    reg [2:0] piece_fetch_state_d;

    reg [7:0] current_piece_addr;
    reg [3:0] piece_to_get = SQUARE_PIECE;
    reg [3:0] moving_piece [3:0] [0:3];
    // reg [3:0] moving_piece_x = 0;
    // reg [3:0] moving_piece_y = 0;

    //  piece drop FSM
    localparam READY    = 3'b000;
    localparam FALLING  = 3'b001;
    localparam FLASHING = 3'b010;
    localparam CLEARING = 3'b011;
    localparam UPDATING = 3'b100;
    localparam STORING  = 3'b101;

    reg [2:0] piece_drop_state = READY;
    reg [2:0] piece_drop_state_d;
    reg [0:(BOARD_HEIGHT - 1)] lineClearable;
	reg [0:(BOARD_HEIGHT - 1)] lineClearable_saved;
    reg [0:(BOARD_HEIGHT - 1)] linesToShift;
	// reg [2:0] linesToShift_saved [0:(BOARD_HEIGHT - 1)];

    reg [2:0] flashCounter = 0;

    // controls
    localparam RIGHT  = 2'b01;
    localparam LEFT   = 2'b10;
    localparam DOWN   = 2'b00;
    localparam BOTH   = 2'b11;

    reg [1:0] controls_left_sr = 2'b0;
    reg [1:0] controls_right_sr = 2'b0;
    reg [1:0] controls_scream_sr = 2'b0;
	reg [1:0] newPiece_sr = 2'b0;

    // control restrictions
    reg [1:0] controls_pulsed;
    reg [0:(BOARD_HEIGHT - 2)] canMoveLeft;
    reg [0:(BOARD_HEIGHT - 2)] canMoveRight;
    reg [1:0] canMoveLeftRight;

    reg [1:0] rotationState = 0;
    reg [0:(BOARD_HEIGHT - 1)] canRotateRows;
	 reg canRotate;
	 
    reg [0:10] nextFrameCollisions;
    
    // ROM
    reg [7:0] dataOut;
    reg [6:0] addrIn;
	 reg [7:0] blockblock [0:89];
	 
    // iterators
    integer i, j, k, l, m, n, q, r, s, t, u, v;

    // piece falling clock
    wire blockenspiel;
    wire sidetoside;
	wire gameclk;
    clockDivider slowasfuck(clk, 2000, 0, gameclk); // IF NOT SIMULATION
    clockDivider dropitlikeitshot(clk, 4 * 4, 0, blockenspiel); // IF NOT SIMULATION
    clockDivider downbythebonks(clk, 500, 0, sidetoside); // IF NOT SIMULATION
    // clockDivider dropitlikeitshot(clk, 400000, 0, blockenspiel); // IF SIMULATION
    // clockDivider downbythebonks(clk, 16000000, 0, sidetoside); // IF SIMULATION
    reg [1:0] blockenspiel_sr;
    reg [1:0] sidetoside_sr;
	 
	 // storeboardPieceOnly initial value
	localparam SBPO_INIT = {1'b1, {(BOARD_WIDTH-2){1'b0}}, 1'b1};

    sevenSegDispLetters boardtodeath(boardPieceOnly[11][1:4], boardPieceOnly[11][5:8], storeboardPieceOnly[11][1:4], storeboardPieceOnly[11][5:8], fullboardPieceOnly[11][1:4], fullboardPieceOnly[11][5:8], seg);

    // Load the pieces in from a txt file + initialize the board
    initial begin
        $readmemb("C:/Users/premg/IEEE/DAV/donkbonk/rom/rom_init_formatted.txt", blockblock);
        for (i = 0; i < 12; i = i + 1) begin
            boardRotatedStates[0][i] = 0;
            boardRotatedStates[1][i] = 0;
            boardRotatedStates[2][i] = 0;
            boardRotatedStates[3][i] = 0;
            boardPieceOnlyRotatedStates[0][i] = 0;
            boardPieceOnlyRotatedStates[1][i] = 0;
            boardPieceOnlyRotatedStates[2][i] = 0;
            boardPieceOnlyRotatedStates[3][i] = 0;
			// storeboard[i] = 0;
            // storeboardPieceOnly[i] = SBPO_INIT;
        end

        storeboard[0]  = 40'h0000000000;
        storeboard[1]  = 40'h0000000000;
        storeboard[2]  = 40'h0000000000;
        storeboard[3]  = 40'h0000000000;
        storeboard[4]  = 40'h0000000000;
        storeboard[5]  = 40'h0000000000;
        storeboard[6]  = 40'h0000000000;
        storeboard[7]  = 40'h0000000000;
        storeboard[8]  = 40'h0000000220;
        storeboard[9]  = 40'h0000000220;
        storeboard[10] = 40'h0222002220;
        storeboard[11] = 40'h0222002220;
		
		storeboardPieceOnly[0]  = 10'b1000000001;
		storeboardPieceOnly[1]  = 10'b1000000001;
		storeboardPieceOnly[2]  = 10'b1000000001;
		storeboardPieceOnly[3]  = 10'b1000000001;
		storeboardPieceOnly[4]  = 10'b1000000001;
		storeboardPieceOnly[5]  = 10'b1000000001;
		storeboardPieceOnly[6]  = 10'b1000000001;
		storeboardPieceOnly[7]  = 10'b1000000001;
		storeboardPieceOnly[8]  = 10'b1000000111;
		storeboardPieceOnly[9]  = 10'b1000000111;
		storeboardPieceOnly[10] = 10'b1111001111;
		storeboardPieceOnly[11] = 10'b1111001111;
		
    end
	// IF NOT SIMULATION
	
    // rom blockblockbitch(addrIn, clk, dataOut);
    // rip blockblockbitch, you will be missed o7

    // translate the board to colors (duh)

    boardToColors lettherebelight(fullboard, colorValues);

    // Generating the lines to shift based on the number of 1's that come after a position
    // lineClearable will be a BOARD_HEIGHT long bit stream of 0's and 1's, 1's indicating a clearable line.
    // &'ing it with all 1's shifted by the iterator lets us zero out the 1's that come on top of the line.
    // num_ones_for counts how many 1's there are and puts it into linesToShift[p].
    // genvar p;
    // generate
    //     for (p = 0; p < 12; p = p + 1) begin: NUM_ONES_GEN
    //         num_ones_for countOnes(lineClearable & ( {BOARD_HEIGHT{1'b1}} >> p), linesToShift[p]);
    //     end
    // endgenerate

    always @(posedge gameclk) begin
        // Setting up shift registers
        // block moving down
        blockenspiel_sr <= {blockenspiel_sr[0], blockenspiel};
        // controls shift registers
        controls_left_sr <= {controls_left_sr[0], controls[1]};
        controls_right_sr <= {controls_right_sr[0], controls[0]};
        controls_scream_sr <= {controls_scream_sr[0], controls[2]};
        // press new piece button
		newPiece_sr <= {newPiece_sr[0], newPiece};
        // sidetoside_sr <= {sidetoside_sr[0], sidetoside};
		  
        if (controls_left_sr == 2'b01) begin
            controls_pulsed <= 2'b10;
        end else if (controls_right_sr == 2'b01) begin
            controls_pulsed <= 2'b01;
		end
        
        case (piece_drop_state)
            FALLING: begin
                if (controls_pulsed & canMoveLeftRight) begin
                    case(controls_pulsed & canMoveLeftRight)
                        RIGHT: begin //  move right
                            for (i = BOARD_HEIGHT - 1; i > 0; i = i - 1) begin
                                // board[i] <= board[i] >> 4;
                                // boardPieceOnly[i] <= boardPieceOnly[i] >> 1;
                                //for (j = 0; j < 4; j = j + 1) begin
                                //    boardRotatedStates[j][i] <= boardRotatedStates[j][i] >> 4;
                                //    boardPieceOnlyRotatedStates[j][i] <= boardPieceOnlyRotatedStates[j][i] >> 1;
                                //end
                                boardRotatedStates[0][i] <= boardRotatedStates[0][i] >> 4;
                                boardPieceOnlyRotatedStates[0][i] <= boardPieceOnlyRotatedStates[0][i] >> 1;
                                boardRotatedStates[1][i] <= boardRotatedStates[1][i] >> 4;
                                boardPieceOnlyRotatedStates[1][i] <= boardPieceOnlyRotatedStates[1][i] >> 1;
                                boardRotatedStates[2][i] <= boardRotatedStates[2][i] >> 4;
                                boardPieceOnlyRotatedStates[2][i] <= boardPieceOnlyRotatedStates[2][i] >> 1;
                                boardRotatedStates[3][i] <= boardRotatedStates[3][i] >> 4;
                                boardPieceOnlyRotatedStates[3][i] <= boardPieceOnlyRotatedStates[3][i] >> 1;
                            end
                            controls_pulsed <= 2'b00;
                            // moving_piece_x <= moving_piece_x - 1;
                        end
                        LEFT: begin
                            for (i = BOARD_HEIGHT - 1; i > 0; i = i - 1) begin
                                // board[i] <= board[i] << 4;
                                // boardPieceOnly[i] <= boardPieceOnly[i] << 1;
                                //for (j = 0; j < 4; j = j + 1) begin
                                //    boardRotatedStates[j][i] <= boardRotatedStates[j][i] << 4;
                                //    boardPieceOnlyRotatedStates[j][i] <= boardPieceOnlyRotatedStates[j][i] << 1;
                                //end
                                boardRotatedStates[0][i] <= boardRotatedStates[0][i] << 4;
                                boardPieceOnlyRotatedStates[0][i] <= boardPieceOnlyRotatedStates[0][i] << 1;
                                boardRotatedStates[1][i] <= boardRotatedStates[1][i] << 4;
                                boardPieceOnlyRotatedStates[1][i] <= boardPieceOnlyRotatedStates[1][i] << 1;
                                boardRotatedStates[2][i] <= boardRotatedStates[2][i] << 4;
                                boardPieceOnlyRotatedStates[2][i] <= boardPieceOnlyRotatedStates[2][i] << 1;
                                boardRotatedStates[3][i] <= boardRotatedStates[3][i] << 4;
                                boardPieceOnlyRotatedStates[3][i] <= boardPieceOnlyRotatedStates[3][i] << 1;
                            end
                            controls_pulsed <= 2'b00;
                            //moving_piece_x <= moving_piece_x + 1;
                        end
                    endcase
                end else if (canRotate & controls_scream_sr == 2'b01) begin
                    rotationState <= rotationState + 1;
                end
                    
                // end
                if (blockenspiel_sr == 2'b01) begin
                    for (i = BOARD_HEIGHT - 1; i > 0; i = i - 1) begin
                        // board[i] <= board[i-1];
                        // boardPieceOnly[i] <= boardPieceOnly[i-1];
                        boardRotatedStates[0][i] <= boardRotatedStates[0][i-1];
                        boardPieceOnlyRotatedStates[0][i] <= boardPieceOnlyRotatedStates[0][i-1];
						boardRotatedStates[1][i] <= boardRotatedStates[1][i-1];
                        boardPieceOnlyRotatedStates[1][i] <= boardPieceOnlyRotatedStates[1][i-1];
						boardRotatedStates[2][i] <= boardRotatedStates[2][i-1];
                        boardPieceOnlyRotatedStates[2][i] <= boardPieceOnlyRotatedStates[2][i-1];
						boardRotatedStates[3][i] <= boardRotatedStates[3][i-1];
                        boardPieceOnlyRotatedStates[3][i] <= boardPieceOnlyRotatedStates[3][i-1];
                    end
                    boardRotatedStates[0][0] <= 0;
                    boardRotatedStates[1][0] <= 0;
                    boardRotatedStates[2][0] <= 0;
                    boardRotatedStates[3][0] <= 0;
                    boardPieceOnlyRotatedStates[0][0] <= 0;
                    boardPieceOnlyRotatedStates[1][0] <= 0;
                    boardPieceOnlyRotatedStates[2][0] <= 0;
                    boardPieceOnlyRotatedStates[3][0] <= 0;
                    // moving_piece_y <= moving_piece_y + 1;
                end
            end
            FLASHING: begin
                if (blockenspiel_sr == 2'b01) begin
                    flashCounter <= flashCounter + 1;
                end
            end
            CLEARING: begin
                for (n = 0; n < BOARD_HEIGHT; n = n + 1) begin
                    if (lineClearable[n]) begin
                        storeboard[n] <= 0;
                        boardRotatedStates[rotationState][n] <= 0;
                        boardPieceOnlyRotatedStates[rotationState][n] <= 0;
                        storeboardPieceOnly[n] <= 0;
                    end
                    lineClearable_saved[n] <= lineClearable[n];
                    // linesToShift_saved[n] <= linesToShift[n];
                end
            end
            UPDATING: begin
                // num ones for
                for (q = BOARD_HEIGHT - 1; q > 0; q = q - 1) begin
                    if ((q - linesToShift[q]) >= 0) begin
                        boardPieceOnlyRotatedStates[rotationState][q] <= boardPieceOnlyRotatedStates[rotationState][q - linesToShift[q]];
                        storeboardPieceOnly[q] <= storeboardPieceOnly[q - linesToShift[q]];
                        boardRotatedStates[rotationState][q] <= boardRotatedStates[rotationState][q - linesToShift[q]];
                        storeboard[q] <= storeboard[q - linesToShift[q]];
                        lineClearable_saved[q] <= lineClearable_saved[q - linesToShift[q]];
                    end else begin
                        boardPieceOnlyRotatedStates[rotationState][q] <= 0;
                        storeboardPieceOnly[q] <= 10'b1000000001;
                        boardRotatedStates[rotationState][q] <= 0;
                        storeboard[q] <= 0;
                    end
                end
            end
            STORING: begin
                for (u = 0; u < BOARD_HEIGHT; u = u + 1) begin
                    storeboard[u] <= board[u] | storeboard[u];
                    storeboardPieceOnly[u] <= boardPieceOnly[u] | storeboardPieceOnly[u];
                    lineClearable_saved[n] <= 0;
                end
                for (v = BOARD_HEIGHT - 1; v > 0; v = v - 1) begin
                    boardRotatedStates[0][v] <= 0;
                    boardRotatedStates[1][v] <= 0;
                    boardRotatedStates[2][v] <= 0;
                    boardRotatedStates[3][v] <= 0;
                    boardPieceOnlyRotatedStates[0][v] <= 0;
                    boardPieceOnlyRotatedStates[1][v] <= 0;
                    boardPieceOnlyRotatedStates[2][v] <= 0;
                    boardPieceOnlyRotatedStates[3][v] <= 0;
                end
            end
        endcase
        
        case (piece_fetch_state)
            /*SEND_INDEX: begin
                for (i = 0; i < 12; i = i + 1) begin
                    boardRotatedStates[0][i] <= 0;
                    boardRotatedStates[1][i] <= 0;
                    boardRotatedStates[2][i] <= 0;
                    boardRotatedStates[3][i] <= 0;
                end
                addrIn <= {3'b0, piece_to_get};
            end*/
            SEND_ADDRESS: begin
                // current_piece_addr <= dataOut;
                addrIn <= blockblock[piece_to_get];
            end
            GET_PIECE: begin
                addrIn <= 0;
                moving_piece[0][0] <= blockblock[addrIn][7:4];
                moving_piece[0][1] <= blockblock[addrIn][3:0];
                moving_piece[0][2] <= blockblock[addrIn + 1][7:4];
                moving_piece[0][3] <= blockblock[addrIn + 1][3:0];
                moving_piece[1][0] <= blockblock[addrIn + 2][7:4];
                moving_piece[1][1] <= blockblock[addrIn + 2][3:0];
                moving_piece[1][2] <= blockblock[addrIn + 3][7:4];
                moving_piece[1][3] <= blockblock[addrIn + 3][3:0];
                moving_piece[2][0] <= blockblock[addrIn + 4][7:4];
                moving_piece[2][1] <= blockblock[addrIn + 4][3:0];
                moving_piece[2][2] <= blockblock[addrIn + 5][7:4];
                moving_piece[2][3] <= blockblock[addrIn + 5][3:0];
                moving_piece[3][0] <= blockblock[addrIn + 6][7:4];
                moving_piece[3][1] <= blockblock[addrIn + 6][3:0];
                moving_piece[3][2] <= blockblock[addrIn + 7][7:4];
                moving_piece[3][3] <= blockblock[addrIn + 7][3:0];
            end
            ADD_PIECE: begin
                for (i = 0; i < 4; i = i + 1) begin
                    for (j = (BOARD_WIDTH * 2 - 8); j < (BOARD_WIDTH * 2 + 8); j = j + 4) begin
                        k = (j - 12) / 4;
                        if (moving_piece[0][i][k]) begin
                            boardRotatedStates[0][i][j +: 4] <= piece_to_get;
                            boardPieceOnlyRotatedStates[0][i][j / 4] <= 1;
                        end
                        if (moving_piece[1][i][k]) begin
                            boardRotatedStates[1][i][j +: 4] <= piece_to_get;
                            boardPieceOnlyRotatedStates[1][i][j / 4] <= 1;
                        end
                        if (moving_piece[2][i][k]) begin
                            boardRotatedStates[2][i][j +: 4] <= piece_to_get;
                            boardPieceOnlyRotatedStates[2][i][j / 4] <= 1;
                        end
                        if (moving_piece[3][i][k]) begin
                            boardRotatedStates[3][i][j +: 4] <= piece_to_get;
                            boardPieceOnlyRotatedStates[3][i][j / 4] <= 1;
                        end
                    end
                end
                // moving_piece_x <= 3;
                // moving_piece_y <= 0;
            end
            IDLE: begin
                addrIn <= 7'b0;
            end
        endcase

        piece_drop_state <= piece_drop_state_d;
        
        if (newPiece_sr == 2'b01 && piece_fetch_state == IDLE) begin
            // piece_to_get <= (piece_to_get % 8) + 1;
            piece_to_get <= SQUARE_PIECE;
            piece_fetch_state <= SEND_ADDRESS;
        end
        else begin
            piece_fetch_state <= piece_fetch_state_d;
        end
    end
	 
	//always @(negedge clk) begin
	//	dataOut <= blockblock[addrIn];
	//end

    always_comb begin
        for (l = 0; l < BOARD_HEIGHT; l = l + 1) begin
            fullboard[l]          = board[l] | storeboard[l];
            fullboardPieceOnly[l] = boardPieceOnly[l] | storeboardPieceOnly[l];
            boardIfMoveLeft[l]    = boardPieceOnly[l] << 1;
            boardIfMoveRight[l]   = boardPieceOnly[l] >> 1;
	        lineClearable[l]      = & (storeboardPieceOnly[l] | boardPieceOnly[l]);
            linesToShift[l]       = | ((lineClearable | lineClearable_saved) & ( {BOARD_HEIGHT{1'b1}} >> l));
            canRotateRows[l]      = | (storeboardPieceOnly[l] & boardPieceOnlyRotatedStates[rotationState + 1][l]);
        end

        for (m = 0; m < BOARD_HEIGHT - 1; m = m + 1) begin
            canMoveLeft[m]         = | (boardIfMoveLeft[m] & storeboardPieceOnly[m + 1]);
            canMoveRight[m]        = | (boardIfMoveRight[m] & storeboardPieceOnly[m + 1]);
            nextFrameCollisions[m] = | (boardPieceOnly[m] & storeboardPieceOnly[m + 1]);
        end

        // for (r = 0; r < 4; r = r + 1) begin
        //     canRotateRows[r] = | (storeboardPieceOnly[moving_piece_y + r][moving_piece_x :+ 4] & moving_piece[rotationState + 1][r]);
        // end
        // halolo

        canRotate = ~(| canRotateRows);
        canMoveLeftRight[1] = ~(| canMoveLeft);
        canMoveLeftRight[0] = ~(| canMoveRight);

        case(rotationState)
            2'b00: begin
                board = boardRotatedStates[0];
                boardPieceOnly = boardPieceOnlyRotatedStates[0];
            end
            2'b01: begin
                board = boardRotatedStates[1];
                boardPieceOnly = boardPieceOnlyRotatedStates[1];
            end
            2'b10: begin
                board = boardRotatedStates[2];
                boardPieceOnly = boardPieceOnlyRotatedStates[2];
            end
            2'b11: begin
                board = boardRotatedStates[3];
                boardPieceOnly = boardPieceOnlyRotatedStates[3];
            end
        endcase

        case(piece_fetch_state) 
            /*SEND_INDEX: begin
                piece_fetch_state_d = SEND_ADDRESS;
            end*/
            SEND_ADDRESS: begin
                piece_fetch_state_d = GET_PIECE;
            end
            GET_PIECE: begin
                piece_fetch_state_d = ADD_PIECE;
            end
            ADD_PIECE: begin
                piece_fetch_state_d = IDLE;
            end
            IDLE: begin
                piece_fetch_state_d = IDLE;
            end
            default: begin
                    piece_fetch_state_d = IDLE;
            end
        endcase

        case(piece_drop_state)
            READY: begin
                if ((piece_fetch_state) == IDLE) begin
                    piece_drop_state_d = FALLING;
                end
                else begin
                    piece_drop_state_d = READY;
                end
            end
            FALLING: begin
                if ((| boardPieceOnly[BOARD_HEIGHT - 1]) || (| nextFrameCollisions)) begin
                    if (| lineClearable) begin
                        piece_drop_state_d = CLEARING;
                    end else begin
                        piece_drop_state_d = STORING;
                    end
                end
                else begin
                    piece_drop_state_d = FALLING;
                end
            end
            FLASHING: begin
                if (flashCounter == 6) begin
                    piece_drop_state_d = CLEARING;
                end else begin
                    piece_drop_state_d = FLASHING;
                end
            end
            CLEARING: begin
                piece_drop_state_d = UPDATING;
            end
            UPDATING: begin
                if (~(| (lineClearable | lineClearable_saved))) begin
                    piece_drop_state_d = STORING;
                end else begin
                    piece_drop_state_d = UPDATING;
                end
            end
            STORING: begin
                piece_drop_state_d = READY;
            end
        endcase
    end
endmodule