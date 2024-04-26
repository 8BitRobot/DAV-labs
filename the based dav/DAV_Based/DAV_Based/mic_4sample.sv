module mic_4sample (start, clk, mic, samples, done);
	
	input reg start;
	input reg clk;
	input reg [11:0] mic;
	output reg [11:0] samples [3:0];
	output reg done;
	
	reg [3:0] state = 0;
	reg [3:0] nextstate = 0;
	
	parameter READY = 0;
	parameter DONE = 5;
	
	always@(posedge clk) begin
        state <= nextstate;
		  
		  if (state >= 1 && state <= 4) begin
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
			4: begin
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