module bonk(clk, dataBonk, dataOut);
    inout dataBonk;
    output logic dataOut = 0;
    input logic clk;

    reg dataBonkIn;

    //0001 = 0; 0111 = high
    reg[6:0] pollingMessage = 96'b000101110001000100010001000100010001000100010001000100010111011100010001000100010001000100010001;
    
    wire dbClock, plsRespondClock;
    // bit counter
    reg[6:0] counter = 7'b0000000;

    reg sendingPoll = 0;

    clockDivider #(1000000) bonkClock(clk, dbClock, 0); // reset is 0 lmao
    clockDivider #(12000) downBadClock(clk, plsRespondClock, 0); // reset is 0 lmao

    IOBuffer bonkData(dataBonkIn, dataOut, sendingPoll, dataBonk);


    always@ (posedge dbClock) begin
        if (sendingPoll && counter != 96) begin
            dataBonkIn <= pollingMessage[95-counter];
            counter <= counter + 1;
        end
        else begin
            dataBonkIn <= 1'bz;
            counter <= 0;
        end
    end

    always@ (posedge plsRespondClock) begin
        sendingPoll <= ~sendingPoll;
    end

    // always_comb begin
    //     dataOut = dataBonk;
    // end
endmodule