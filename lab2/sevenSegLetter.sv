module sevenSegLetter(input [4:0] letter, input onSwitch, input [7:0] extra, output reg [7:0] dispBits);
	//Note that it is legal to do input/output and bitwidth declarations within the port list like above!

	always_comb begin
		//Remember we can only use reg logic in always blocks. 
		//always_comb is similar to always@(*) but it is a compiler directive that will cause a compilation error if the logic inside is not actually combinational. 
		//As such, when we want to use combinational logic, it is better practice to use always_comb to catch errors!
		/*
		----------PART TWO----------
		Your logic to convert decimal number to the bits corresponding to a seven-seg goes here.
		4 bit input -> values from 0 to 15. We can only display 0 to 9 but you should still deal with cases where 10-15 are passed in. In this case, set it so the display is just blank.
		We reccomend a case statement. Make sure all of the cases have outputs assigned.
		----------PART TWO----------
		*/
		if (onSwitch) begin
			dispBits = 8'b11111111;
		end
		else if (extra != 8'b0) begin
			dispBits = extra;
		end
		else begin
			case (letter)
				5'b00000: begin
					dispBits = 8'b10001000; // A
				end
				5'b00001: begin
					dispBits = 8'b10000011; // b
				end
				5'b00010: begin
					dispBits = 8'b10000110; // c
				end
				5'b00011: begin
					dispBits = 8'b10100001; // d
				end
				5'b00100: begin
					dispBits = 8'b10000110; // E
				end
				5'b00101: begin
					dispBits = 8'b10001110; // F
				end
				5'b00110: begin
					dispBits = 8'b11000010; // G
				end
				5'b00111: begin
					dispBits = 8'b10001011; // h
				end
				5'b01000: begin
					dispBits = 8'b11111001; // I
				end
				5'b01001: begin
					dispBits = 8'b11110001; // J
				end
				5'b01011: begin
					dispBits = 8'b11000111; // L
				end
				5'b01100: begin
					dispBits = 8'b00101011; // m
				end
				5'b01101: begin
					dispBits = 8'b10101011; // n
				end
				5'b01110: begin
					dispBits = 8'b10100011; // o
				end
				5'b01111: begin
					dispBits = 8'b10001100; // P
				end
				5'b10000: begin
					dispBits = 8'b10011000; // Q
				end
				5'b10001: begin
					dispBits = 8'b10101111; // r
				end
				5'b10010: begin
					dispBits = 8'b10010010; // s
				end
				5'b10011: begin
					dispBits = 8'b10000111; // t
				end
				5'b10100: begin
					dispBits = 8'b11100011; // u
				end
				5'b10101: begin
					dispBits = 8'b11100011; // v
				end
				5'b11000: begin
					dispBits = 8'b00010001; // y
				end
				5'b11000: begin
					dispBits = 8'b00100100; // Z
				end
				default: begin
					dispBits = 8'b11100011; // blank
				end
			endcase
		end
	end
endmodule