module sevenSegDisplay(
	input logic [19:0] number, input logic switch, output logic [7:0] segments [5:0]
);
	logic [3:0] digits [5:0];
	
	sevenSegDigit digit0module (digits[0], switch, segments[0]);
	sevenSegDigit digit1module (digits[1], switch, segments[1]);
	sevenSegDigit digit2module (digits[2], switch, segments[2]);
	sevenSegDigit digit3module (digits[3], switch, segments[3]);
	sevenSegDigit digit4module (digits[4], switch, segments[4]);
	sevenSegDigit digit5module (digits[5], switch, segments[5]);
	
	// The following block will contain the logic of your combinational circuit
	integer i;
	
	always_comb begin
	
		for(i = 0; i < 6; i = i + 1) begin
			if(i == 0)
				digits[i] = number % 10;
			else
				digits[i] = (number / (10**i)) % 10;
			
		end
	end

endmodule