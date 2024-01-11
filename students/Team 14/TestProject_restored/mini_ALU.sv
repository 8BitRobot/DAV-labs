module mini_ALU (
    input [3:0] operand_1,
	 input [3:0] operand_2,
	 input select,
    output [19:0] number
    );

    always_comb begin : select_block 
        if (select) 
            number = operand_1 + operand_2;
        else
            number = operand_1 << operand_2;
    end
    
endmodule