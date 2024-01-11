module miniALU_top(input [9:0] switches, output[9:0] leds, output [47:0] display);
	assign leds = switches;
	
	wire [19:0] mathResult;
	wire onOff;
	
	miniALU alu(switches[8:5], switches[4:1], switches[0], mathResult);
	
	sevenSegDisplay disp(mathResult, switches[9], display);
	
endmodule

     