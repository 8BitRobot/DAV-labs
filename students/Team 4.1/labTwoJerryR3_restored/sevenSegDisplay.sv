module sevenSegDisplay (
    input [16:0] in,
    input on,
    output logic [7:0] digitSegments [0:5] // array of 6x 8-bit numbers for segments
);

    // array of 6x 4-bit numbers (for sevenSegDigit to convert to 8-bit numbers)
    logic [3:0] digitNums [0:5];

    // 6x sevenSegDigit displays
    sevenSegDigit d0(digitNums[0], on, digitSegments[0]);
    sevenSegDigit d1(digitNums[1], on, digitSegments[1]);
    sevenSegDigit d2(digitNums[2], on, digitSegments[2]);
    sevenSegDigit d3(digitNums[3], on, digitSegments[3]);
    sevenSegDigit d4(digitNums[4], on, digitSegments[4]);
    sevenSegDigit d5(digitNums[5], on, digitSegments[5]);

    always_comb begin
        // hundredths digits
        digitNums[0] = in % 10;
        digitNums[1] = (in / 10) % 10;

        // seconds digits
        digitNums[2] = (in / 100) % 10;
        digitNums[3] = (in / 1000) % 6;

        // minutes digits
        digitNums[4] = in / 6000;
        digitNums[5] = 0;
    end

endmodule
