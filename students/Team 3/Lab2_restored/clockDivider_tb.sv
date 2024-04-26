//`timescale 1ns/1ns

module clockDivider_tb(
    output reg clk
);
]
    logic [31:0] speed = 3'd4;
    logic reset_button = 0;
    logic outClk;

    clockDivider #(16) UUT(clk, speed, reset_button, outClk);

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