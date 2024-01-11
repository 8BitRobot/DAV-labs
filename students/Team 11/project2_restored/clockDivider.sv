module clockDivider #(parameter BASE_SPEED = 50000000)(
    input clk, 
    input [$clog2(1000000)-1:0] speed,
    output reg outClk
);
    reg[$clog2(BASE_SPEED) - 1:0] counter = 0;
    always @ (posedge clk) begin
        counter <= counter + 1;
        outClk <= (counter < (BASE_SPEED/speed)/2) ? 1'b1 : 1'b0;
        if(counter >= BASE_SPEED/speed - 1)
            counter <= 0;
    end
endmodule