module miniALU_top (input [9:0] switches, output [47:0] display);
	
	wire [3:0] operand_1 = switches[9:6];
	wire [3:0] operand_2 = switches[5:2];
	wire mode = switches[1];
	wire onOff = switches[0];
	
	//convert to 20 bit number
	wire [19:0] twenty_bit;
	
	mini_ALU minnie_mouse (operand_1, operand_2, mode, twenty_bit);
	
	sevenSegDisplay result (twenty_bit, onOff, display[47:40], display[39:32], display[31:24], display[23:16], display[15:8], display[7:0]);
	
	
	
	
	
endmodule
