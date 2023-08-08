module sevenSegDisp(value, enable, segs);
	input enable;
	input [23:0] value;
	output [7:0] segs [0:5];
	reg [3:0] inputs [0:5];

	sevenSegDigit digit5(inputs[5], enable, segs[5]);
	sevenSegDigit digit4(inputs[4], enable, segs[4]);
	sevenSegDigit digit3(inputs[3], enable, segs[3]);
	sevenSegDigit digit2(inputs[2], enable, segs[2]);
	sevenSegDigit digit1(inputs[1], enable, segs[1]);
	sevenSegDigit digit0(inputs[0], enable, segs[0]);
	
	always_comb begin
		inputs[0] = value % 10;
		inputs[1] = (value / 10) % 10;
		inputs[2] = (value / 100) % 10;
		inputs[3] = (value / 1000) % 6;
		inputs[4] = (value / 6000) % 10;
		inputs[5] = (value / 60000) % 6;
	end
endmodule