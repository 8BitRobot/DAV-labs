module bongoTranslator(clk, dataClock, threshold, dataPort, controls);
    input logic clk;
    input logic dataClock;
	input [3:0] threshold;
	inout dataPort;
    output [3:0] controls;

    assign controls = {startBtnDebounced, controls_reg};
    
    logic sampleClk = 0;
    // wire [3:0] dig0, dig1;
    wire [7:0] bongoHit;
    wire [11:0] bongoScream;

    logic [11:0] startBtn_sr = 12'h0;
    logic startBtnDebounced = 1'b0;

    bonk donk(clk, dataClock, dataPort, bongoHit, bongoScream);

    clockDivider #(1000000) samplingClock(dataClock, 660, 0, sampleClk); // clock for polling

    logic [2:0] controls_reg;

    always @(posedge sampleClk) begin
        startBtn_sr <= { startBtn_sr[10:0], bongoHit[4] };
        if (&startBtn_sr) begin
            startBtnDebounced <= 1'b1;
        end else if (&(~startBtn_sr)) begin
            startBtnDebounced <= 1'b0;
        end

        if (bongoHit[3] || bongoHit[1]) begin
            controls_reg[1] <= 1;
        end else begin
            controls_reg[1] <= 0;
        end

        if (bongoHit[2] || bongoHit[0]) begin
            controls_reg[0] <= 1;
        end else begin
            controls_reg[0] <= 0;
        end

        if (bongoScream[7:0] >= 8'h80) begin
            controls_reg[2] <= 1;
        end else begin
            controls_reg[2] <= 0;
        end
    end
endmodule