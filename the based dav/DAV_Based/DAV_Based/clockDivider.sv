module clockDivider #(parameter SPEED = 440)(input clock, output reg newClock, input rst);
    reg [25:0] counter = 0;
    reg [25:0] countForFreq = 26'd50000000 / SPEED;
    reg [25:0] dutyCycleForFreq = 26'd50000000 / SPEED / 2'd2;
  
    always@(posedge clock) begin
        if (counter < countForFreq)
            counter <= counter + 1;
        else
            counter <= 0;
            
        if (rst == 1)
            counter <= 0;
    end
    
    always_comb begin
        if (counter > dutyCycleForFreq)
            newClock = 1;
        else
            newClock = 0;
    end
    
endmodule