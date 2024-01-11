module clockbuzzer (
	input clk,
	output reg buzzer
	);
	
	clockDivider BUZZER(clk, 20'd1, 'b0, buzzer);
	
endmodule