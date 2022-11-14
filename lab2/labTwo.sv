module labTwo(switches, leds, dig5, dig4, dig3, dig2, dig1, dig0);
	//since this is the top level, it should include all of your IO as ports
	//Inputs: switches
	input [9:0] switches;
	//Outputs: leds, 6 seven segment signals (dig5, dig4, dig3, dig2, dig1, dig0) that are 8 bits each
	output [9:0] leds;
	output [7:0] dig5, dig4, dig3, dig2, dig1, dig0;
	//Other reg/wires:
	reg [3:0] input5, input4, input3, input2, input1, input0; //These are inputs for your six seven-seg displays 
//	reg [19:0] decimalValue;
	reg [23:0] decimalValue;

	/*
	----------PART ONE----------
	Assign your LED pin outs based on your switch inputs. 
	This should be very simple (assign statements) and can go directly in the top level
	----------PART ONE----------
	*/
	assign leds[0] = switches[0];
	assign leds[1] = switches[1];
	assign leds[2] = switches[2];
	assign leds[3] = switches[3];
	assign leds[4] = switches[4];
	assign leds[5] = switches[5];
	assign leds[6] = switches[6];
	assign leds[7] = switches[7];
	assign leds[8] = switches[8];
	assign leds[9] = switches[9];
	/*
	----------PART TWO----------
	First, fill out the code for the sevenSegDigit module.

	Instantiate 6 copies of sevenSegDigit, using the dig5, dig4, etc as inputs like so:
	sevenSegDigit digit5(input5, dig5); //Instantiation of the leftmost seven-seg display. Note that dig5 should be connected to the pins corresponding to the leftmost display

	In an always_comb block, you can set inputs to these digits to numbers you want to check!

	After finishing part two, comment out these 6 instantiations and the logic to set the inputs so that it does not interfere with part three
	----------PART TWO----------
	*/
	
//	sevenSegDigit digit5(4'b0000, switches[0], 8'b11000000, dig5);
//	sevenSegDigit digit4(4'b0001, switches[0], 8'b10001001, dig4);
//	sevenSegDigit digit3(4'b0010, switches[0], 8'b10001110, dig3);
//	sevenSegDigit digit2(4'b0011, switches[0], 8'b11000001, dig2);
//	sevenSegDigit digit1(4'b0100, switches[0], 8'b11000110, dig1);
//	sevenSegDigit digit0(4'b0101, switches[0], 8'b11000110, dig0);

	sevenSegDisp disp(decimalValue, switches[0], dig5, dig4, dig3, dig2, dig1, dig0);

	/*
	----------PART FOUR----------
	First, fill out the code for the sevenSegDisp module.
	Instantiate the sevenSegDisp module using decimalValue as the input, and connecting the outputs to the six 8-bit seven segment display signal pins in your top level
	Instantiate miniALU with the appropriate signals from the switch inputs as inputs (based on the spec) and decimalValue as the output.
	----------PART FOUR----------
	*/
	
	// miniALU alu(switches[9:6], switches[5:2], switches[1], decimalValue);

	/*
	----------PART FIVE----------
	We've used 8 of the switches for inputs A and B that are four bits each. One switch is the operation.
	Now, the last switch will act as an enable for the display. If the last switch is high, the display should work as intended.
	If the last switch is low, the display should be blank regardless of the math in part four. 
	We want to add a step between the output for sevenSegDisp and the actual output that goes to the display that sets the actual output to drive a blank display if the switch is low.
	----------PART FIVE----------
	*/

endmodule