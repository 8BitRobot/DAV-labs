module alarmController (
    input clk,
    input pause,
    input reset,
    input [8:0] switches, // 9-bit input in seconds
    output logic [16:0] out, // 16-bit output in centiseconds (hundredths of a second)
    output logic flashOn, // 1 if display needs to flash, 0 otherwise
    output logic buzzerOn
);

	 initial begin
		  out = 0;
	 end

    // pause and reset button shift registers
    logic [1:0] pause_sr = 2'b11;
    logic [1:0] reset_sr = 2'b11;

    localparam SET = 2'b00;
    localparam RUN = 2'b01;
    localparam PAUSE = 2'b10;
    localparam BEEP = 2'b11;

    logic [1:0] currState = SET;
    logic [1:0] nextState = SET;
    logic [16:0] out_d = 0;
    logic flashOn_d = 0;
    logic buzzerOn_d = 0;

    always_comb begin
        case (currState)
            SET : begin
                flashOn_d = 0;
                buzzerOn_d = 0;
                if (pause_sr == 2'b10) begin // pause button clicked (rising edge)
                    nextState = RUN;
                    out_d = switches * 100; // converts seconds from switches to centiseconds for out
                end else begin
                    nextState = SET;
                    out_d = switches * 100;
                end
            end
            RUN : begin
                out_d = out - 1; // decrement output by 1 every clock cycle
                flashOn_d = 0;
                buzzerOn_d = 0;
                if (pause_sr == 2'b10) begin
                    nextState = PAUSE;
                end else if (reset_sr == 2'b10) begin
                    nextState = SET;
                    out_d = switches * 100;
                end else if (out_d <= 0) begin
                    nextState = BEEP;
                    out_d = 0;
                end else begin
                    nextState = RUN;
                end
            end
            PAUSE : begin
                out_d = out;
                flashOn_d = 1;
                buzzerOn_d = 0;
                if (pause_sr == 2'b10) begin
                    nextState = RUN;
                end else if (reset_sr == 2'b10) begin
                    nextState = SET;
                    out_d = switches * 100;
                end else begin
                    nextState = PAUSE;
                end
            end
            BEEP : begin
                out_d = 0;
                flashOn_d = 1;
                buzzerOn_d = 1;
                if (reset_sr == 2'b10) begin
                    nextState = SET;
                    out_d = switches * 100;
                end else begin
                    nextState = BEEP;
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