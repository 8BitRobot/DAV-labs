module bongoTranslator(clk, dataClock, threshold, dataPort, controls, bongoScream);
    input logic clk;
    input logic dataClock;
	input [3:0] threshold;
	inout dataPort;
    output [2:0] controls;
    output [11:0] bongoScream;
    // output scream;
    
    logic sampleClk = 0;
    // wire [3:0] dig0, dig1;
    wire [7:0] bongoHit;
    wire [11:0] bongoScream;
    wire [7:0] seg0, seg1;
    // assign { dig1, dig0 } = bongoHit;
    
    // logic [1:0] mostRecentlyPressed = 2'b00;

    bonk donk(clk, dataClock, dataPort, bongoHit, bongoScream);

    // always @(posedge dataClock) begin
    //     sampleClk <= ~sampleClk;
    // end

    clockDivider #(1000000) samplingClock(clk, 500000, 0, sampleClk); // clock for polling

    always @(posedge sampleClk) begin
        if (bongoHit[3] || bongoHit[1]) begin
            controls[1] <= 1;
        end else begin
            controls[1] <= 0;
        end

        if (bongoHit[2] || bongoHit[0]) begin
            controls[0] <= 1;
        end else begin
            controls[0] <= 0;
        end

        if (bongoScream[7:0] >= {4'h8, threshold}) begin
            controls[2] <= 1;
        end else begin
            controls[2] <= 0;
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