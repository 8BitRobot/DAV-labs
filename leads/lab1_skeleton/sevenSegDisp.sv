module sevenSegDisp(
	input [19:0] value,
	input        onSwitch,
	output [7:0] digs [0:5]
);

	reg [3:0] digitInput [0:5];

	sevenSegDigit digit5(digitInput[5], onSwitch, digs[5]);
	sevenSegDigit digit4(digitInput[4], onSwitch, digs[4]);
	sevenSegDigit digit3(digitInput[3], onSwitch, digs[3]);
	sevenSegDigit digit2(digitInput[2], onSwitch, digs[2]);
	sevenSegDigit digit1(digitInput[1], onSwitch, digs[1]);
	sevenSegDigit digit0(digitInput[0], onSwitch, digs[0]);
	
	always_comb begin
		digitInput[0] = value % 10;
		digitInput[1] = (value / 10) % 10;
		digitInput[2] = (value / 100) % 10;
		digitInput[3] = (value / 1000) % 10;
		digitInput[4] = (value / 10000) % 10;
		digitInput[5] = (value / 100000) % 10;
	end
	
endmodule