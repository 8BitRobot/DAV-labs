module gamecontroller(clk, newPieceTrigger, controls, colorValues);
    localparam BOARD_WIDTH = 40;

    // ports
    input clk;
    input newPieceTrigger;
    input [1:0] controls;
    output logic [0:79] colorValues [0:11];

    // board arrays
    logic [0:BOARD_WIDTH-1] board [0:11];
    logic [0:(BOARD_WIDTH/4) - 1] boardPieceOnly [0:11];
    logic [0:BOARD_WIDTH - 1] storeboard [0:11];
    logic [0:(BOARD_WIDTH/4) - 1] storeboardPieceOnly [0:11];
    logic [0:BOARD_WIDTH-1] fullboard [0:11];
    logic [0:(BOARD_WIDTH/4) - 1] fullboardPieceOnly [0:11];
    logic [0:(BOARD_WIDTH/4) - 1] boardIfMoveLeft [0:11];
    logic [0:(BOARD_WIDTH/4) - 1] boardIfMoveRight [0:11];
    
    // piece codes
    parameter T_PIECE      = 4'b0001;
    parameter SQUARE_PIECE = 4'b0010;
    parameter J_PIECE      = 4'b0011;
    parameter L_PIECE      = 4'b0100;
    parameter Z_PIECE      = 4'b0101;
    parameter S_PIECE      = 4'b0110;
    parameter LINE_PIECE   = 4'b0111;
    parameter CURSED_PIECE = 4'b1000;

    // piece fetch FSM
    parameter SEND_INDEX   = 3'b000;
    parameter SEND_ADDRESS = 3'b001;
    parameter GET_PIECE_1  = 3'b010;
    parameter GET_PIECE_2  = 3'b011;
    parameter ADD_PIECE    = 3'b100;
    parameter IDLE         = 3'b101;

    reg [2:0] piece_fetch_state = SEND_INDEX;
    reg [2:0] piece_fetch_state_d;

    reg [7:0] current_piece_addr;
    reg [3:0] piece_to_get = SQUARE_PIECE;
    reg [3:0] moving_piece [3:0];

    //  piece drop FSM
    parameter READY    = 3'b000;
    parameter FALLING  = 3'b001;
    parameter CLEARING = 3'b010;
    parameter UPDATING = 3'b011;
    parameter STORING  = 3'b100;

    reg [2:0] piece_drop_state = READY;
    reg [2:0] piece_drop_state_d;
    reg [0:11] lineClearable;
	reg [0:11] lineClearable_saved;
    wire [1:0] linesToShift [0:11];
	reg [1:0] linesToShift_saved [0:11];
    // reg [1:0] linesToShift_ [0:11];

    // controls
    parameter RIGHT = 2'b01;
    parameter LEFT = 2'b10;
    parameter DOWN = 2'b00;
    parameter BOTH = 2'b11;

    reg [1:0] controls_left_sr = 2'b0;
    reg [1:0] controls_right_sr = 2'b0;

    // control restrictions
    reg [1:0] controls_pulsed;
    reg [0:10] canMoveLeft;
    reg [0:10] canMoveRight;
    reg [1:0] canMoveLeftRight;
    reg [0:10] nextFrameCollisions;
    
    // ROM
    reg [7:0] dataOut;
    reg [5:0] addrIn;
	reg [7:0] blockblock [0:127];
	 
    // iterators
    integer i, j, k, l, m, n, q, r;

    // piece falling clock
    wire blockenspiel;
    clockDivider dropitlikeitshot(clk, 4 * 4, 0, blockenspiel); // IF NOT SIMULATION
    wire sidetoside;
    clockDivider downbythebonks(clk, 500, 0, sidetoside);
    // clockDivider dropitlikeitshot(clk, 4000000, 0, blockenspiel); // IF SIMULATION
    reg [1:0] blockenspiel_sr;
    reg [1:0] sidetoside_sr;
    
    initial begin
        $readmemb("C:/Users/premg/IEEE/DAV/donkbonk/rom/rom_init.txt", blockblock);
        for (i = 0; i < 12; i = i + 1) begin
            board[i] = 40'b0;
            boardPieceOnly[i] = 10'b0;
			storeboard[i] = 40'b0;
            storeboardPieceOnly[i] = 10'b1000000001;
        end
		// storeboardPieceOnly[0]  = 10'b1000000001;
		// storeboardPieceOnly[1]  = 10'b1000000001;
		// storeboardPieceOnly[2]  = 10'b1000000001;
		// storeboardPieceOnly[3]  = 10'b1000000001;
		// storeboardPieceOnly[4]  = 10'b1000000001;
		// storeboardPieceOnly[5]  = 10'b1000000001;
		// storeboardPieceOnly[6]  = 10'b1000000001;
		// storeboardPieceOnly[7]  = 10'b1000000001;
		// storeboardPieceOnly[8]  = 10'b1000000001;
		// storeboardPieceOnly[9]  = 10'b1110000001;
		// storeboardPieceOnly[10] = 10'b1111001111;
		// storeboardPieceOnly[11] = 10'b1111111011;
    end
	// IF NOT SIMULATION
	
    // rom blockblockbitch(addrIn, clk, dataOut);
    // rip blockblockbitch, you will be missed o7

    boardToColors lettherebelight(fullboard, colorValues);

    genvar p;
    generate
        for (p = 0; p < 12; p = p + 1) begin: NUM_ONES_GEN
            num_ones_for countOnes(lineClearable & (12'b111111111111 >> p), linesToShift[p]);
        end
    endgenerate

    always @(posedge clk) begin
        blockenspiel_sr <= {blockenspiel_sr[0], blockenspiel};
        controls_left_sr <= {controls_left_sr[0], controls[1]};
        controls_right_sr <= {controls_right_sr[0], controls[0]};
        sidetoside_sr <= {sidetoside_sr[0], sidetoside};
		  
        if (controls_left_sr == 2'b01) begin
            controls_pulsed <= 2'b10;
        end else if (controls_right_sr == 2'b01) begin
            controls_pulsed <= 2'b01;
        end
        
        case (piece_drop_state)
            READY: begin
            end
            FALLING: begin
                if (sidetoside_sr == 2'b01) begin
                    case(controls_pulsed & canMoveLeftRight)
                        RIGHT: begin //  move right
                            for (i = 11; i > 0; i = i - 1) begin
                                board[i] <= board[i] >> 4;
                                boardPieceOnly[i] <= boardPieceOnly[i] >> 1;
                            end
                        end
                        LEFT: begin
                            for (i = 11; i > 0; i = i - 1) begin
                                board[i] <= board[i] << 4;
                                boardPieceOnly[i] <= boardPieceOnly[i] << 1;
                            end
                        end
                    endcase
                    controls_pulsed <= 2'b00;
                end
                if (blockenspiel_sr == 2'b01) begin
                    for (i = 11; i > 0; i = i - 1) begin
                        board[i] <= board[i-1];
                        boardPieceOnly[i] <= boardPieceOnly[i-1];
                    end
                    board[0] <= 0;
                    boardPieceOnly[0] <= 0;
                end
            end
            CLEARING: begin
                for (n = 0; n < 12; n = n + 1) begin
                    if (lineClearable[n]) begin
                        board[n] <= 0;
                        boardPieceOnly[n] <= 0;
                        storeboard[n] <= 0;
                        storeboardPieceOnly[n] <= 0;
                    end
					lineClearable_saved[n] <= lineClearable[n];
					linesToShift_saved[n] <= linesToShift[n];
                end
            end
            UPDATING: begin
                // num ones for
                for (q = 11; q > 0; q = q - 1) begin
                    if ((q - linesToShift_saved[q]) >= 0) begin
                        boardPieceOnly[q] <= boardPieceOnly[q - linesToShift_saved[q]];
                        storeboardPieceOnly[q] <= storeboardPieceOnly[q - linesToShift_saved[q]];
                        board[q] <= board[q - linesToShift_saved[q]];
                        storeboard[q] <= storeboard[q - linesToShift_saved[q]];
                    end else begin
                        boardPieceOnly[q] <= 0;
                        storeboardPieceOnly[q] <= 10'b1000000001;
                        board[q] <= 0;
                        storeboard[q] <= 0;
                    end
                    /*
                    if (lineClearable_saved[q]) begin
                        continue;
                    end else begin
                        boardPieceOnly[q] <= boardPieceOnly[(q - linesToShift_saved[q] >= 0) ? (q - linesToShift_saved[q]) : 0];
                        storeboardPieceOnly[q] <= storeboardPieceOnly[(q - linesToShift_saved[q] >= 0) ? (q - linesToShift_saved[q]) : q];
                    end
                    */
                end
                for (r = 0; r < 12; r = r + 1) begin
                    linesToShift_saved[r] <= 0;
                    lineClearable_saved[n] <= 0;
                end
            end
            STORING: begin
                for (i = 0; i < 12; i = i + 1) begin
                    storeboard[i] <= board[i] | storeboard[i];
                    storeboardPieceOnly[i] <= boardPieceOnly[i] | storeboardPieceOnly[i];
                end
                for (i = 11; i > 0; i = i - 1) begin
                    board[i] <= 0;
                    boardPieceOnly[i] <= 0;
                end
            end
        endcase
        
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

        piece_drop_state <= piece_drop_state_d;
        
        if (newPieceTrigger && piece_fetch_state == IDLE) begin
            // piece_to_get <= (piece_to_get % 8) + 1;
            piece_to_get <= S_PIECE;
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
            boardIfMoveLeft[l] = boardPieceOnly[l] << 1;
            boardIfMoveRight[l] = boardPieceOnly[l] >> 1;
				lineClearable[l] = & fullboardPieceOnly[l];
        end

        for (m = 0; m < 11; m = m + 1) begin
            canMoveLeft[m] = | (boardIfMoveLeft[m] & storeboardPieceOnly[m + 1]);
            canMoveRight[m] = | (boardIfMoveRight[m] & storeboardPieceOnly[m + 1]);
            nextFrameCollisions[m] = | (boardPieceOnly[m] & storeboardPieceOnly[m + 1]);
        end
		  
		  //for (r = 0; r < 12; r = r + 1) begin
		  //end

        // halolo

        canMoveLeftRight[1] = ~(| canMoveLeft);
        canMoveLeftRight[0] = ~(| canMoveRight);

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
                if ((| boardPieceOnly[11]) || (| nextFrameCollisions)) begin
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
            CLEARING: begin
                piece_drop_state_d = UPDATING;
            end
            UPDATING: begin
                if (~(| lineClearable)) begin
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