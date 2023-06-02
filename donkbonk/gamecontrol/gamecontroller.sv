module gamecontroller #(parameter BOARD_WIDTH=10, BOARD_HEIGHT=12) (gameclk, rst, controls, colorValues);
    // ports
    input gameclk;
    input rst;
    input [2:0] controls;
    output logic [0:(BOARD_WIDTH * 8 - 1)] colorValues [0:(BOARD_HEIGHT - 1)];

    // clocks
    wire blockenspiel;
    wire sidetoside;
    wire gameclk;
    
    // clockDivider slowasfuck(clk, 120, 0, gameclk); // IF NOT SIMULATION
    // if we want to speed up dropping this needs to stay a clock divider
    clockDivider #(60) dropitlikeitshot(gameclk, 2, 0, blockenspiel); // IF NOT SIMULATION
    // clockDivider downbythebonks(clk, 500, 0, sidetoside); // IF NOT SIMULATION
    // clockDivider dropitlikeitshot(clk, 400000, 0, blockenspiel); // IF SIMULATION
    // clockDivider downbythebonks(clk, 16000000, 0, sidetoside); // IF SIMULATION
    reg [1:0] blockenspiel_sr;
    reg [1:0] sidetoside_sr;

    // board arrays
    logic [0:BOARD_WIDTH * 4 - 1] board [0:(BOARD_HEIGHT - 1)];
    logic [0:BOARD_WIDTH * 4 - 1] boardRotatedStates [0:3] [0:BOARD_HEIGHT -1];
    logic [0:BOARD_WIDTH - 1]     boardPieceOnly [0:(BOARD_HEIGHT - 1)];
    logic [0:BOARD_WIDTH - 1]     boardPieceOnlyRotatedStates [0:3] [0:BOARD_HEIGHT -1];
    logic [0:BOARD_WIDTH * 4 - 1] storeboard [0:BOARD_HEIGHT -1];
    logic [0:BOARD_WIDTH - 1]     storeboardPieceOnly [0:BOARD_HEIGHT -1];
    logic [0:BOARD_WIDTH * 4 - 1] fullboard [0:BOARD_HEIGHT -1];
    logic [0:BOARD_WIDTH - 1]     fullboardPieceOnly [0:(BOARD_HEIGHT - 1)];
    logic [0:BOARD_WIDTH - 1]     boardPieceOnlyIfMoveLeft [0:3] [0:(BOARD_HEIGHT - 1)];
    logic [0:BOARD_WIDTH - 1]     boardPieceOnlyIfMoveRight [0:3] [0:(BOARD_HEIGHT - 1)];
    logic [0:BOARD_WIDTH * 4 - 1] boardIfMoveLeft [0:3] [0:(BOARD_HEIGHT - 1)];
    logic [0:BOARD_WIDTH * 4 - 1] boardIfMoveRight [0:3] [0:(BOARD_HEIGHT - 1)];
    
    // piece codes
    localparam T_PIECE      = 4'b0001;
    localparam SQUARE_PIECE = 4'b0010;
    localparam J_PIECE      = 4'b0011;
    localparam L_PIECE      = 4'b0100;
    localparam Z_PIECE      = 4'b0101;
    localparam S_PIECE      = 4'b0110;
    localparam LINE_PIECE   = 4'b0111;
    localparam CURSED_PIECE = 4'b1000;
    localparam FLASH_COLOR  = 4'b1111;

    // piece fetch FSM
    localparam SEND_INDEX   = 3'b000;
    localparam SEND_ADDRESS = 3'b001;
    localparam GET_PIECE    = 3'b010;
    localparam ADD_PIECE    = 3'b011;
    localparam IDLE         = 3'b100;

    reg [2:0] piece_fetch_state;
    reg [2:0] piece_fetch_state_d;

    reg [7:0] current_piece_addr;
    wire [3:0] piece_to_get;
    reg [3:0] moving_piece [3:0] [0:3];

    // RNG
    lfsr thankschatgpt(piece_fetch_state == IDLE, 0, piece_to_get);

    //  piece drop FSM
    localparam READY      = 3'b000;
    localparam PREFALLING = 3'b111;
    localparam FALLING    = 3'b001;
    localparam MOVING     = 3'b110;
    localparam FLASHING   = 3'b010;
    localparam CLEARING   = 3'b011;
    localparam UPDATING   = 3'b100;
    localparam STORING    = 3'b101;

    reg [2:0] piece_drop_state;
    reg [2:0] piece_drop_state_d;

    reg [1:0] prefallDelay;
    reg [6:0] postfallDelay;
	 reg [6:0] postfallDelay_d;

    reg [0:(BOARD_HEIGHT - 1)] lineClearable;
	reg [0:(BOARD_HEIGHT - 1)] lineClearable_saved;
    reg [0:(BOARD_HEIGHT - 1)] linesToShift;

    reg [2:0] flashCounter;

    // controls
    localparam RIGHT  = 2'b01;
    localparam LEFT   = 2'b10;
    localparam DOWN   = 2'b00;
    localparam BOTH   = 2'b11;

    reg [1:0] controls_left_sr;
    reg [1:0] controls_right_sr;
    reg [1:0] controls_scream_sr;
	// reg [1:0] newPiece_sr = 2'b0;

    // control restrictions
    reg [1:0] controls_pulsed;
    reg [0:(BOARD_HEIGHT - 1)] canMoveLeft;
    reg [0:(BOARD_HEIGHT - 1)] canMoveRight;
    reg [1:0] canMoveLeftRight;

    reg [1:0] rotationState = 0;
    reg [0:(BOARD_HEIGHT - 1)] canRotateRows;
	reg canRotate;
	 
    reg [0:(BOARD_HEIGHT - 2)] nextFrameCollisions;
    
    // ROM
    reg [7:0] dataOut;
    reg [6:0] addrIn;
	reg [7:0] blockblock [0:89];
	 
    // iterators
    integer i, j, k, l, m, n, q, r, s, t, u, v;
	 
	 // storeboardPieceOnly initial value
	localparam SBPO_INIT = {1'b1, {(BOARD_WIDTH-2){1'b0}}, 1'b1};

    // Load the pieces in from a txt file + initialize the board
    initial begin
        $readmemb("C:/Users/premg/IEEE/DAV/donkbonk/rom/rom_init_formatted.txt", blockblock);
        for (i = 0; i < BOARD_HEIGHT; i = i + 1) begin
            boardRotatedStates[0][i] = 0;
            boardRotatedStates[1][i] = 0;
            boardRotatedStates[2][i] = 0;
            boardRotatedStates[3][i] = 0;
            boardPieceOnlyRotatedStates[0][i] = 0;
            boardPieceOnlyRotatedStates[1][i] = 0;
            boardPieceOnlyRotatedStates[2][i] = 0;
            boardPieceOnlyRotatedStates[3][i] = 0;
			storeboard[i] = 0;
            storeboardPieceOnly[i] = SBPO_INIT;
        end

        piece_fetch_state = SEND_ADDRESS;
        piece_drop_state = READY;

        controls_left_sr = 2'b0;
        controls_right_sr = 2'b0;
        controls_scream_sr = 2'b0;

        prefallDelay = 0;
        postfallDelay = 120;

        flashCounter = 0;

        // storeboard[0]  = 40'h0000000000;
        // storeboard[1]  = 40'h0000000000;
        // storeboard[2]  = 40'h0000000000;
        // storeboard[3]  = 40'h0000000000;
        // storeboard[4]  = 40'h0000000000;
        // storeboard[5]  = 40'h0000000000;
        // storeboard[6]  = 40'h0000000000;
        // storeboard[7]  = 40'h0000000000;
        // storeboard[8]  = 40'h0000000220;
        // storeboard[9]  = 40'h0000000220;
        // storeboard[10] = 40'h0222002220;
        // storeboard[11] = 40'h0222002220;
		
		// storeboardPieceOnly[0]  = 10'b1000000001;
		// storeboardPieceOnly[1]  = 10'b1000000001;
		// storeboardPieceOnly[2]  = 10'b1000000001;
		// storeboardPieceOnly[3]  = 10'b1000000001;
		// storeboardPieceOnly[4]  = 10'b1000000001;
		// storeboardPieceOnly[5]  = 10'b1000000001;
		// storeboardPieceOnly[6]  = 10'b1000000001;
		// storeboardPieceOnly[7]  = 10'b1000000001;
		// storeboardPieceOnly[8]  = 10'b1000000111;
		// storeboardPieceOnly[9]  = 10'b1000000111;
		// storeboardPieceOnly[10] = 10'b1111001111;
		// storeboardPieceOnly[11] = 10'b1111001111;
		
    end

    // translate the board to colors (duh)

    boardToColors #(BOARD_WIDTH, BOARD_HEIGHT) lettherebelight(fullboard, colorValues);

    always @(posedge gameclk) begin
        // Setting up shift registers
        // block moving down
        if (~rst) begin
            for (integer i = 0; i < BOARD_HEIGHT; i = i + 1) begin
                boardRotatedStates[0][i] = 0;
                boardRotatedStates[1][i] = 0;
                boardRotatedStates[2][i] = 0;
                boardRotatedStates[3][i] = 0;
                boardPieceOnlyRotatedStates[0][i] = 0;
                boardPieceOnlyRotatedStates[1][i] = 0;
                boardPieceOnlyRotatedStates[2][i] = 0;
                boardPieceOnlyRotatedStates[3][i] = 0;
                storeboard[i] = 0;
                storeboardPieceOnly[i] = SBPO_INIT;
            end

            piece_fetch_state = SEND_ADDRESS;
            piece_drop_state = READY;

            controls_left_sr = 2'b0;
            controls_right_sr = 2'b0;
            controls_scream_sr = 2'b0;

            prefallDelay = 0;
            postfallDelay = 120;

            flashCounter = 0;
        end else begin
            blockenspiel_sr <= {blockenspiel_sr[0], blockenspiel};
            // controls shift registers
            controls_right_sr <= {controls_right_sr[0], controls[0]};
            controls_left_sr <= {controls_left_sr[0], controls[1]};
            controls_scream_sr <= {controls_scream_sr[0], controls[2]};
            // press new piece button
            // newPiece_sr <= {newPiece_sr[0], newPiece};
            // sidetoside_sr <= {sidetoside_sr[0], sidetoside};
            
            if (controls_left_sr == 2'b01) begin
                controls_pulsed <= 2'b10;
            end else if (controls_right_sr == 2'b01) begin
                controls_pulsed <= 2'b01;
            end
            // first FSM: controlling how the piece falls
            case (piece_drop_state)
                MOVING: begin
                    if (controls_pulsed & canMoveLeftRight) begin
                        // moving left or right
                        case(controls_pulsed & canMoveLeftRight)
                            RIGHT: begin //  move right
                                for (i = BOARD_HEIGHT - 1; i > 0; i = i - 1) begin
                                    boardRotatedStates[0][i] <= boardIfMoveRight[0][i];
                                    boardPieceOnlyRotatedStates[0][i] <= boardPieceOnlyIfMoveRight[0][i];
                                    boardRotatedStates[1][i] <= boardIfMoveRight[1][i];
                                    boardPieceOnlyRotatedStates[1][i] <= boardPieceOnlyIfMoveRight[1][i];
                                    boardRotatedStates[2][i] <= boardIfMoveRight[2][i];
                                    boardPieceOnlyRotatedStates[2][i] <= boardPieceOnlyIfMoveRight[2][i];
                                    boardRotatedStates[3][i] <= boardIfMoveRight[3][i];
                                    boardPieceOnlyRotatedStates[3][i] <= boardPieceOnlyIfMoveRight[3][i];
                                end
                                controls_pulsed <= 2'b00;
                            end
                            LEFT: begin
                                for (i = BOARD_HEIGHT - 1; i > 0; i = i - 1) begin
                                    boardRotatedStates[0][i] <= boardIfMoveLeft[0][i];
                                    boardPieceOnlyRotatedStates[0][i] <= boardPieceOnlyIfMoveLeft[0][i];
                                    boardRotatedStates[1][i] <= boardIfMoveLeft[1][i];
                                    boardPieceOnlyRotatedStates[1][i] <= boardPieceOnlyIfMoveLeft[1][i];
                                    boardRotatedStates[2][i] <= boardIfMoveLeft[2][i];
                                    boardPieceOnlyRotatedStates[2][i] <= boardPieceOnlyIfMoveLeft[2][i];
                                    boardRotatedStates[3][i] <= boardIfMoveLeft[3][i];
                                    boardPieceOnlyRotatedStates[3][i] <= boardPieceOnlyIfMoveLeft[3][i];
                                end
                                controls_pulsed <= 2'b00;
                            end
                        endcase
                        // rotation - can only rotate 1 way
                    end else if (canRotate & controls_scream_sr == 2'b01) begin
                        rotationState <= rotationState + 1;
                    end
                end
                PREFALLING: begin
                    prefallDelay <= prefallDelay + 1;
                end
                FALLING: begin
                    // Moving the piece down - shifting all of the rotated board states
                    for (i = BOARD_HEIGHT - 1; i > 0; i = i - 1) begin
                        boardRotatedStates[0][i] <= boardRotatedStates[0][i-1];
                        boardPieceOnlyRotatedStates[0][i] <= boardPieceOnlyRotatedStates[0][i-1];
                        boardRotatedStates[1][i] <= boardRotatedStates[1][i-1];
                        boardPieceOnlyRotatedStates[1][i] <= boardPieceOnlyRotatedStates[1][i-1];
                        boardRotatedStates[2][i] <= boardRotatedStates[2][i-1];
                        boardPieceOnlyRotatedStates[2][i] <= boardPieceOnlyRotatedStates[2][i-1];
                        boardRotatedStates[3][i] <= boardRotatedStates[3][i-1];
                        boardPieceOnlyRotatedStates[3][i] <= boardPieceOnlyRotatedStates[3][i-1];
                    end
                    // Setting the top lines to 0
                    boardRotatedStates[0][0] <= 0;
                    boardRotatedStates[1][0] <= 0;
                    boardRotatedStates[2][0] <= 0;
                    boardRotatedStates[3][0] <= 0;
                    boardPieceOnlyRotatedStates[0][0] <= 0;
                    boardPieceOnlyRotatedStates[1][0] <= 0;
                    boardPieceOnlyRotatedStates[2][0] <= 0;
                    boardPieceOnlyRotatedStates[3][0] <= 0;
                    prefallDelay <= 0;
                end
                // Flash the line before clearing it
                FLASHING: begin
                    if (blockenspiel_sr == 2'b01) begin
                        flashCounter <= flashCounter + 1;
                    end
                end
                // Delete the lines and saved the lines that were cleared
                CLEARING: begin
                    for (n = 0; n < BOARD_HEIGHT; n = n + 1) begin
                        if (lineClearable[n]) begin
                            storeboard[n] <= 0;
                            boardRotatedStates[rotationState][n] <= 0;
                            boardPieceOnlyRotatedStates[rotationState][n] <= 0;
                            storeboardPieceOnly[n] <= SBPO_INIT;
                        end
                        lineClearable_saved[n] <= lineClearable[n];
                    end
                        flashCounter <= 0;
                end
                // Shifting lines down if there are any to be shifted
                UPDATING: begin
                    for (q = BOARD_HEIGHT - 1; q > 0; q = q - 1) begin
                        if ((q - linesToShift[q]) >= 0) begin
                            boardPieceOnlyRotatedStates[rotationState][q] <= boardPieceOnlyRotatedStates[rotationState][q - linesToShift[q]];
                            storeboardPieceOnly[q] <= storeboardPieceOnly[q - linesToShift[q]];
                            boardRotatedStates[rotationState][q] <= boardRotatedStates[rotationState][q - linesToShift[q]];
                            storeboard[q] <= storeboard[q - linesToShift[q]];
                            lineClearable_saved[q] <= lineClearable_saved[q - linesToShift[q]];
                        end else begin
                            boardPieceOnlyRotatedStates[rotationState][q] <= 0;
                            storeboardPieceOnly[q] <= SBPO_INIT;
                            boardRotatedStates[rotationState][q] <= 0;
                            storeboard[q] <= 0;
                        end
                    end
                end
                // Merging the board that only has the piece with the full board, which will be stored as memory.
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
                        postfallDelay <= postfallDelay_d;
                end
            endcase
            
            case (piece_fetch_state)
                SEND_ADDRESS: begin
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
                // Spawning a new piece in.
                ADD_PIECE: begin
                    for (i = 0; i < 4; i = i + 1) begin
                        for (j = (BOARD_WIDTH * 2 - 8); j < (BOARD_WIDTH * 2 + 8); j = j + 4) begin
                            // k = (j - ((BOARD_WIDTH / 2 - 1) * 4)) / 4;
                            k = (j - (BOARD_WIDTH * 2 - 8)) / 4;
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
                end
                // Just chilling
                IDLE: begin
                    addrIn <= 7'b0;
                end
            endcase

            piece_drop_state <= piece_drop_state_d;
            piece_fetch_state <= piece_fetch_state_d;
        end
    end
    
    always_comb begin
		  if (postfallDelay == 0 && piece_drop_state == STORING) begin
				postfallDelay_d = 120;
		  end else if (postfallDelay > 0) begin
				postfallDelay_d = postfallDelay - 1;
		  end else begin
			   postfallDelay_d = 0;
		  end
		  
        // Computations that require checking all of the lines
        for (l = 0; l < BOARD_HEIGHT; l = l + 1) begin
            fullboard[l]           = board[l] | storeboard[l];
            fullboardPieceOnly[l]  = boardPieceOnly[l] | storeboardPieceOnly[l];
            // aaaaaaaaaaahhhhhh
            boardPieceOnlyIfMoveLeft[0][l]  = boardPieceOnlyRotatedStates[0][l] << 1;
            boardPieceOnlyIfMoveLeft[1][l]  = boardPieceOnlyRotatedStates[1][l] << 1;
            boardPieceOnlyIfMoveLeft[2][l]  = boardPieceOnlyRotatedStates[2][l] << 1;
            boardPieceOnlyIfMoveLeft[3][l]  = boardPieceOnlyRotatedStates[3][l] << 1;

            boardPieceOnlyIfMoveRight[0][l] = boardPieceOnlyRotatedStates[0][l] >> 1;
            boardPieceOnlyIfMoveRight[1][l] = boardPieceOnlyRotatedStates[1][l] >> 1;
            boardPieceOnlyIfMoveRight[2][l] = boardPieceOnlyRotatedStates[2][l] >> 1;
            boardPieceOnlyIfMoveRight[3][l] = boardPieceOnlyRotatedStates[3][l] >> 1;

            boardIfMoveLeft[0][l]           = boardRotatedStates[0][l] << 4;
            boardIfMoveLeft[1][l]           = boardRotatedStates[1][l] << 4;
            boardIfMoveLeft[2][l]           = boardRotatedStates[2][l] << 4;
            boardIfMoveLeft[3][l]           = boardRotatedStates[3][l] << 4;

            boardIfMoveRight[0][l]          = boardRotatedStates[0][l] >> 4;
            boardIfMoveRight[1][l]          = boardRotatedStates[1][l] >> 4;
            boardIfMoveRight[2][l]          = boardRotatedStates[2][l] >> 4;
            boardIfMoveRight[3][l]          = boardRotatedStates[3][l] >> 4;

	         lineClearable[l]                = & (storeboardPieceOnly[l] | boardPieceOnly[l]);
            linesToShift[l]                 = | ((lineClearable | lineClearable_saved) & ( {BOARD_HEIGHT{1'b1}} >> l));
            canRotateRows[l]                = | (storeboardPieceOnly[l] & boardPieceOnlyRotatedStates[rotationState + 1][l]);

            canMoveLeft[l]                  = | (boardPieceOnlyIfMoveLeft[rotationState][l] & storeboardPieceOnly[l]);
            canMoveRight[l]                 = | (boardPieceOnlyIfMoveRight[rotationState][l] & storeboardPieceOnly[l]);
        end

        for (m = 0; m < BOARD_HEIGHT - 1; m = m + 1) begin
            nextFrameCollisions[m] = | (boardPieceOnly[m] & storeboardPieceOnly[m + 1]);
        end

        // halolo

        canRotate = ~(| canRotateRows);
        canMoveLeftRight[1] = ~(| canMoveLeft);
        canMoveLeftRight[0] = ~(| canMoveRight);

        for (integer z = 0; z < BOARD_HEIGHT; z = z + 1) begin
            if (piece_drop_state == FLASHING && flashCounter % 2 == 0 && lineClearable[z]) begin
                board[z] = {(BOARD_WIDTH-1){FLASH_COLOR}};
            end else begin
                board[z] = boardRotatedStates[rotationState][z];
            end
            boardPieceOnly[z] = boardPieceOnlyRotatedStates[rotationState][z];
        end

        // case(rotationState)
        //     2'b00: begin
        //         board = boardRotatedStates[0] ;
        //         boardPieceOnly = boardPieceOnlyRotatedStates[0];
        //     end
        //     2'b01: begin
        //         board = boardRotatedStates[1];
        //         boardPieceOnly = boardPieceOnlyRotatedStates[1];
        //     end
        //     2'b10: begin
        //         board = boardRotatedStates[2];
        //         boardPieceOnly = boardPieceOnlyRotatedStates[2];
        //     end
        //     2'b11: begin
        //         board = boardRotatedStates[3];
        //         boardPieceOnly = boardPieceOnlyRotatedStates[3];
        //     end
        // endcase

        case (piece_fetch_state) 
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
                if (piece_drop_state == READY) begin
                    piece_fetch_state_d = SEND_ADDRESS;
                end
                else begin
                    piece_fetch_state_d = IDLE;
                end
            end
            default: begin
                piece_fetch_state_d = IDLE;
            end
        endcase

        case(piece_drop_state)
            READY: begin
                if (piece_fetch_state == ADD_PIECE) begin
                    piece_drop_state_d = FALLING;
                end
                else begin
                    piece_drop_state_d = READY;
                end
            end
            PREFALLING: begin
                if (prefallDelay == 3) begin
                    piece_drop_state_d = FALLING;
                end else begin
                    piece_drop_state_d = PREFALLING;
                end
            end
            FALLING: begin
                piece_drop_state_d = MOVING;
            end
            MOVING: begin
                if ((| boardPieceOnly[BOARD_HEIGHT - 1]) || (| nextFrameCollisions)) begin
                    if (| lineClearable) begin
                        piece_drop_state_d = FLASHING;
                    end else begin
                        piece_drop_state_d = STORING;
                    end
                end else if (blockenspiel_sr == 2'b01) begin
                    piece_drop_state_d = PREFALLING;
                end else begin
                    piece_drop_state_d = MOVING;
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
					if (postfallDelay == 1) begin
						piece_drop_state_d = READY;
					end else begin
						piece_drop_state_d = STORING;
					end
            end
            default: begin
                piece_drop_state_d = IDLE;
            end
        endcase
    end
endmodule