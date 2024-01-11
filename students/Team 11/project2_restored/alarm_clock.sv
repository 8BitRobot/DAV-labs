`timescale 1ns/1ns
module alarm_clock(
    input but,
    input rst,
    input [9:0] switches,
    input clk,
    output[47:0] segs,
    output buzzer
);
reg[1:0] state = 2'b0;
parameter SET = 2'b0;
parameter RUN = 2'b1;
parameter PAUSE = 2'b10;
parameter BEEP = 2'b11;

reg[8:0] remtime = 9'b0;
reg outclk;
reg oldclk=0;
clockDivider clkdiv (.clk(clk),.speed(1<<switches[0]),.outClk(outclk));

sevenSegDisplay ssd(.num(remtime),.o(0),.segs(segs));

/*always @(posedge clk) begin
    if(oldclk != outclk)begin
            oldclk <= outclk;
            remtime <= remtime + 1;
    end
        //$display("%d",remtime);

end*/

always @(posedge clk) begin
    case(state)
    SET: begin
        if(but==0)
            state <= RUN;
        remtime <= switches[9:1];
    end
    RUN: begin
        if(rst == 0)
            state <= SET;
        else if(but == 0)
            state <= PAUSE;

        if(remtime == 0)
            state <= BEEP;
        
        if(oldclk != outclk)begin
            oldclk <= outclk;
            remtime <= remtime - 1;
        end

    end
    PAUSE: begin
        if(but == 0)
            state <= RUN;
        else if (rst == 0)
            state <= SET;
    end
    BEEP: begin
        if(rst == 0)
            state <= SET;
        //buzzer stuff
        buzzer <= 1'b1;
    end
    endcase
end
endmodule