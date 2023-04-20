module bongoTranslator(clk, dataClock, dataPort, controls);
    input logic clk;
    input logic dataClock;
	inout dataPort;
    output [1:0] controls;
    
    logic sampleClk;
    wire [3:0] dig0, dig1;
    
    logic [1:0] mostRecentlyPressed = 2'b00;

    bonk donk(clk, dataClock, dataPort, dig0, dig1, seg0, seg1);

    clockDivider samplingClock(clk, 100000 * 4, 0, sampleClk); // clock for polling

    always @(posedge sampleClk) begin
        if (dig0[3] || dig0[1]) begin
            controls[1] <= 1;
        end else begin
            controls[1] <= 0;
        end

        if (dig0[2] || dig0[0]) begin
            controls[0] <= 1;
        end else begin
            controls[0] <= 0;
        end

        // if ((dig0[3] && dig0[2]) || (dig0[3] && dig0[0]) || (dig0[1] && dig0[2]) || (dig0[1] && dig0[0])) begin  // everything!!
        //     controls <= 2'b11;
        // end
        // else if (dig0[3] || dig0[1]) begin // Left
        //     controls <= 2'b10;
        // end
        // else if (dig0[2] || dig0[0]) begin // Right
        //     controls <= 2'b01;
        // end
        // else begin
        //     controls <= 2'b00;
        // end
    end
endmodule