`timescale 1ns/1ns

module miniALU_tb(output [19:0] res);
	reg [8:0] switches;
	miniALU UUT(switches[8:5], switches[4:1], switches[0], res);

	integer i;

	initial begin

		switches = 9'b000000000;
	
		for (i = 0; i < 9'b111111111; i = i + 1) begin
			#5; // simulation delay
			switches = switches + 1;
		end

		$stop;

	end


endmodule