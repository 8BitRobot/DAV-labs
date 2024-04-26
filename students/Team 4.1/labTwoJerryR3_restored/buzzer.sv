module buzzer (
    input clock,
    output logic out
);

    clockDivider clk(clock, 440, 0, out);
    
endmodule