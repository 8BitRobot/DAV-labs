module memory_controller(clk, addrWrite, dataWrite, addrRead_h, addrRead_v, dataRead);
// ping pong :D
    input clk;
    input [9:0] addrWrite;
    input [7:0] dataWrite;

    input [9:0] addrRead_h;
    input [9:0] addrRead_v;
    output reg [7:0] dataRead;

    wire [9:0] addrRead;
    assign addrRead = (addrRead_h / 20) + (addrRead_v / 20) * 32;

    reg [9:0] addrA, addrB;
    
    wire [7:0] outputA;
    wire [7:0] outputB;

    ram ramA(addrA, clk, dataWrite, writeEnableA, outputA);
    ram ramB(addrB, clk, dataWrite, writeEnableB, outputB);

    reg writeEnableA = 1'b1;
    wire writeEnableB;
    assign writeEnableB = ~writeEnableA;

    always @(posedge clk) begin
        if (addrRead_h == 0 && addrRead_v == 0) begin
            writeEnableA <= ~writeEnableA;
        end
    end

    always_comb begin
        if (writeEnableA) begin
            addrA = addrWrite;
            addrB = addrRead;
            dataRead = outputB;
        end
        else begin
            addrA = addrRead;
            addrB = addrWrite;
            dataRead = outputA;
        end
    end
endmodule