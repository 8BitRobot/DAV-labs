module AlarmClock_top #(BASE_SPEED = 50000000) (
	input clk,
	input [19:0] speed, 
	input reset,
	output logic outClk
);
	// input freq: 50MHz
	// output freq: outClk 

	reg [19:0] counter = 0;
	reg [19:0] counter_d = 0;
	reg outClk_d;
	//reg counter_max = (BASE_SPEED / speed) - 1;

	//combinational block
	always_comb begin
		if (reset == 1 || counter_d <= ((BASE_SPEED / speed - 1) / 2)) begin
			outClk_d = 0;
			counter_d = 0;
		end
		else begin
			outClk_d = 1;
			counter_d = counter + 1;
		end
	end

	//sequential block
	//update the values of output clock register and counter
	always @(posedge clk) begin
		outClk <= outClk_d;
		counter <= counter_d;
	end

endmodule