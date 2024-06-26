// bongoInput = all binary. just. base bongo data
// clk = 50mhz clock

module ledControl(clk, dataClock, dataPort, seg0, seg1, leds);
    input logic clk;
    input logic dataClock;
	inout dataPort;
    
    logic sampleClk;

    wire [3:0] dig0, dig1;
	output [7:0] seg0, seg1;
    output reg [9:0] leds = 10'b0000100000;
    
    reg [1:0] mostRecentlyPressed;

    initial begin
        mostRecentlyPressed = 2'b00;
    end

    bonk donk(clk, dataClock, dataPort, dig0, dig1, seg0, seg1);

    clockDivider samplingClock(clk, 100000 * 4, 0, sampleClk); // clock for polling

    always @(posedge sampleClk) begin
        if ((dig0[3] && dig0[2]) || (dig0[3] && dig0[0]) || (dig0[1] && dig0[2]) || (dig0[1] && dig0[0])) begin  // everything!!
            if (!(mostRecentlyPressed == 2'b11)) begin
                leds <= leds << 1 | leds >> 1;
                mostRecentlyPressed <= 2'b11;
            end
        end
        else if (dig0[3] || dig0[1]) begin // Left
            if (!(mostRecentlyPressed == 2'b10)) begin
                leds <= (leds << 1) | (leds >> 9);
                mostRecentlyPressed <= 2'b10;
            end
        end
        else if (dig0[2] || dig0[0]) begin // Right
            if (!(mostRecentlyPressed == 2'b01)) begin
                leds <= (leds >> 1) | (leds << 9);
                mostRecentlyPressed <= 2'b01;
            end
        end
        else begin
            mostRecentlyPressed <= 2'b00;
        end
    end
endmodule