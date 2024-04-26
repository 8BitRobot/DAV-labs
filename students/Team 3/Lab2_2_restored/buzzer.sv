module buzzer (
    output reg buzzerClk
);

    reg clk;
    logic [$clog2(1000000):0] speed = 10000;
    clockDivider buzzer(clk, speed, 0, buzzerClk);

    initial begin
        clk = 0;
    end

    always begin
        #5
        if (clk == 1)
            clk = 0;
        else
            clk = 1;
    end

endmodule