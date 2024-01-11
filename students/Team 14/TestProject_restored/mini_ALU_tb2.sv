`timescale 1ns/1ns

module mini_ALU_tb2 
(
    output [9:0] leds
);
    reg [3:0] input_1;
    reg [3:0] input_2;
    reg select;
    wire [9:0] output_1;
    
    initial begin
        for (integer i = 0; i < 16; i = i + 1)
        begin
            #5; // simulation delay
            input_1 = input_1 + 1;
            input_2 = input_2 + 1;
            select = ~select; 
        end
	 $stop;
    end

    miniALU UUT (
        .input_1(input_1),
        .input_2(input_2),
        .select(select), 
        .result(output_1)
    );

    miniALU_top switches (
        .switches(output_1), 
        .leds(leds)
    );

endmodule