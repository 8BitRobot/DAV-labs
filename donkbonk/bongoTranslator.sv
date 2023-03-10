/*
This is a useless file. Just like me.
*/

// bongoInput = all binary. just. base bongo data
// clk = 50hz clock

module bongoTranslator(bongoInput, clk, dig0, dig1);
    reg [7:0] counter = 8'b11111111;
    reg [63:0] actualInput = 64'b0;
    input[255:0] bongoInput;
    input clk;
    output [7:0] dig0;
    output [7:0] dig1;

    sevenSegDispLetters(actualInput[63:60], actualInput[59:56], dig0, dig1);

    // Will add case statement??
endmodule