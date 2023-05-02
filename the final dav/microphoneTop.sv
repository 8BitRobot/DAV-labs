module microphoneTop(input clk, input rst, output [9:0] leds);
    wire [11:0] adc_out;

    micadc dasheng(.CLOCK(clk), .CH0(adc_out), .RESET(!rst));

    assign leds = 1 << (adc_out / 455);
endmodule