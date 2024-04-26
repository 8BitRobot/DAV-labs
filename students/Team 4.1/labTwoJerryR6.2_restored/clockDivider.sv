module clockDivider #(BASE_SPEED = 50000000) (
    input clk,
    input [$clog2(BASE_SPEED):0] speed,
    input reset,
    output logic outClk
);

    logic [5:0] counter = 0;
    logic [5:0] counter_d = 0; // counter for next clock cycle
    logic outClk_d = 0; // outClk for next clock cycle

    initial begin
        outClk = 0;
    end

    always_comb begin
        if (reset || counter <= (BASE_SPEED / speed - 1) / 2) begin
            outClk_d = 0;
        end else begin
            outClk_d = 1;
        end

        if (reset || counter == BASE_SPEED / speed - 1) begin
            counter_d = 0;
        end else begin
            counter_d = counter + 1;
        end
    end

    always @(posedge clk) begin
        counter <= counter_d;
        outClk <= outClk_d;
    end
    
endmodule