module mic_16sample (start, clk, mic, samples, done);
	
	input reg start;
	input reg clk;
	input reg [11:0] mic;
	output reg [11:0] samples [15:0];
	output reg done;
	
	reg [4:0] state = 0;
	reg [4:0] nextstate = 0;
	
	parameter READY = 0;
	parameter DONE = 17;
	
	always@(posedge clk) begin
        state <= nextstate;
		  
		  if (state >= 1 && state <= 16) begin
				samples[state-1] <= mic;
		  end
   end
	 
	always_comb begin
		case (state)
			default: begin // this is the same as ready
				// wait until start is high
				done = 0;
				if(start)
					nextstate = 1;
				else
					nextstate = READY;
			end
			READY: begin
				// wait until start is high
				done = 0;
				if(start)
					nextstate = 1;
				else
					nextstate = READY;
			end
			1, 
			2, 
			3, 
			4, 
			5, 
			6, 
			7, 
			8, 
			9, 
			10,
			11,
			12, 
			13,
			14,
			15,
			16: begin
				done = 0;
				nextstate = nextstate + 1; // increment state
			end
			DONE: begin
				// wait until start is high
				done = 1;
				if(start)
					nextstate = READY;
				else
					nextstate = DONE;
			end
		endcase
		
	end
	
endmodule