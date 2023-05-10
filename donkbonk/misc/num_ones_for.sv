module num_ones_for(input [11:0] A, output reg [3:0] ones);
    integer i;

    always_comb begin
        ones = 0;  //initialize count variable.
        for (i = 0; i < 12; i = i + 1)   //check for all the bits.
            if (A[i])    //check if the bit is '1'
                ones = ones + 1;    //if its one, increment the count.
    end
endmodule