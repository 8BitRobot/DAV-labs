`timescale 1ns/1ns
module trig_tb();
    // Simulate the cos module in the trig.sv file.
    reg [$clog2(359):0] angle;
    wire signed [15:0] cos;
    cos cos_inst(
        .angle(angle),
        .cos(cos)
    );

    initial begin
        // Test the cos module for angles 0, 45, 90, 135, 180, 225, 270, 315, and 359.
        angle = 0;
        #10;
        angle = 45;
        #10;
        angle = 90;
        #10;
        angle = 135;
        #10;
        angle = 180;
        #10;
        angle = 225;
        #10;
        angle = 270;
        #10;
        angle = 315;
        #10;
        angle = 359;
        #10;
        $stop;
    end
endmodule