`timescale 1ns/1ns

module clockDivider_tb (
    output logic out
);

    logic clock;
    clockDivider UUT(clock, 5000000, 0, out);

    initial begin
        clock = 0;
        #10000 $stop;
    end
    always begin
        #10 clock = ~clock; // 50 MHz clock
    end

endmodule