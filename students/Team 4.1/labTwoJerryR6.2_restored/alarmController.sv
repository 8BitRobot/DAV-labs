module alarmController (
    input clk,
    input pause,
    input reset,
    input [8:0] switches, // 9-bit input in seconds
    output logic [15:0] out, // 16-bit output in centiseconds (hundredths of a second)
    output logic flashOn, // 1 if display needs to flash, 0 otherwise
    output logic buzzerOn
);

    localparam SET = 2'b00;
    localparam RUN = 2'b01;
    localparam PAUSE = 2'b10;
    localparam BEEP = 2'b11;

    logic [1:0] pause_sr, reset_sr; // pause and reset button shift registers
    logic [1:0] currState, nextState;
    logic [15:0] out_d;
    logic flashOn_d, buzzerOn_d;

    initial begin
        out = 0;

        pause_sr = 2'b11;
        reset_sr = 2'b11;

        currState = SET;
    end

    always_comb begin
        case (currState)
            SET : begin
                flashOn_d = 0;
                buzzerOn_d = 0;
                if (pause_sr == 2'b10) begin // pause button clicked (rising edge)
                    nextState = RUN;
                end else begin
                    nextState = SET;
                end
                out_d = switches * 100; // converts seconds from switches to centiseconds for out
            end

            RUN : begin
                flashOn_d = 0;
                buzzerOn_d = 0;
                if (pause_sr == 2'b10) begin
                    nextState = PAUSE;
                    out_d = out;
                end else if (reset_sr == 2'b10) begin
                    nextState = SET;
                    out_d = switches * 100;
                end else if (out_d <= 0) begin
                    nextState = BEEP;
                    out_d = 0;
                end else begin
                    nextState = RUN;
                    out_d = out - 1; // decrement output by 1 every clock cycle
                end
            end

            PAUSE : begin
                buzzerOn_d = 0;
                if (pause_sr == 2'b10) begin
                    nextState = RUN;
                    out_d = out;
                    flashOn_d = 0;
                end else if (reset_sr == 2'b10) begin
                    nextState = SET;
                    out_d = switches * 100;
                    flashOn_d = 0;
                end else begin
                    nextState = PAUSE;
                    out_d = out;
                    flashOn_d = 1;
                end
            end

            BEEP : begin
                if (reset_sr == 2'b10) begin
                    nextState = SET;
                    out_d = switches * 100;
                    flashOn_d = 0;
                    buzzerOn_d = 0;
                end else begin
                    nextState = BEEP;
                    out_d = 0;
                    flashOn_d = 1;
                    buzzerOn_d = 1;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        pause_sr <= {pause_sr[0], pause}; // concatenation
        reset_sr <= {reset_sr[0], reset};

        currState <= nextState;
        out <= out_d;
        flashOn <= flashOn_d;
        buzzerOn <= buzzerOn_d;
    end
    
endmodule