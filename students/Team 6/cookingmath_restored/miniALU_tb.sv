`timescale 1ns/1ns
// tell what the time scale is: how many of ns of simulation correspond to real time

module miniALU_tb(output [19:0] result);

reg [3:0] operand1 = 4'b0000;
reg [3:0] operand2 = 4'b0000;
reg select = 1'b0;

miniALU UUT(operand1, operand2, select, result);

initial begin

	for(integer i = 0; i <= 1'b1; i = i+1) begin
		select = i;
		for(integer j = 0; j <= 4'b1111; j = j+1) begin
		operand1 = j;
			for(integer k = 0; k <= 4'b1111; k = k+1) begin
				operand2 = k;
				#10;
			end
		end
	end
	$stop;
end

endmodule


//`timescale 1ns/1ns //one nanosecond of simulation time per 1 ns of real time
//
//module miniALU_tb(output [9:0] leds);
//	
//	reg [9:0] switches;
//	//wire [9:0] leds; //can be wire because output of module is driving them logically and combinationally
//	
//	miniALU_top UUT(switches, leds); //instantiating the module. UUT = Unit Under Test
//	//inside parenthesis, passing in ports
//	//instantiating in test bench so we can test it
//	
//	//define value for switches
//	
//	integer i; //iteration variable
//	
//	
//	//start with defining value of switches at beginning
//	initial begin //initial block runs at very beginning of test bench
//		switches = 10'b0; //10 is number of bits, b means binary
//		//Assigning ten bit binary number to switches with value 0 (ten 0s)
//		
//		//simulation delay: want to hold value for switches for some amount of time and then change
//		//#10; //10 nanoseconds
//		//switches = 10'b1;
//		//#10
//		//switches = 10'b10;
//		//this is tedious, can use for loops instead
//		
//		for(i = 0; i < 10'b1111111111; i = i+1) begin
//			#10;
//			switches = switches + 1;
//		end
//		
//		$stop; //tell simulation to stop
//	
//	end
//
//endmodule