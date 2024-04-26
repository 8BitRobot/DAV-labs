module fft_4point_32bit(clk, reset, start, in0, in1, in2, in3, out0, out1, out2, out3, done);
    input reg clk, reset, start;
    input reg signed [31:0] in0, in1, in2, in3;
    output reg signed [31:0] out0, out1, out2, out3;
	 reg [31:0] out0d, out1d, out2d, out3d;
    output reg done;

    parameter RESET = 2'b00;
    parameter STAGE_1 = 2'b01;
    parameter STAGE_2 = 2'b10;
    parameter DONE = 2'b11;

    reg [1:0] state = RESET;
	 reg [1:0] nextstate = RESET;
	 
    reg [31:0] butterfly1In_A, butterfly1In_B, butterfly1Out_Add, butterfly1Out_Subtract;
    reg [31:0] butterfly2In_A, butterfly2In_B, butterfly2Out_Add, butterfly2Out_Subtract;
    reg [31:0] butterfly1Twiddle, butterfly2Twiddle;
	 
    //reg signed [31:0] temp_out0, temp_out1, temp_out2, temp_out3, in_A;

    // insert parameters for twiddle factors, which is right shifted by 15

    reg [31:0] twiddle240 = 32'b01111111111111110000000000000000; // already left shifted W^0_2 <= W^0_4
    reg [31:0] twiddle41 =  32'b00000000000000000111111111111111; // shifted W^1_4
	 
	 always@(posedge clk) begin
        state <= nextstate;
        case (state)
            RESET: begin	
					// hold inputs as zero
					
					butterfly1Twiddle <= 32'b0;
               butterfly2Twiddle <= 32'b0;
               end
					 
            STAGE_1: begin
					
               //first stage of 2 butterfly units, set inputs/outputs
					
               butterfly1In_A <= in0;
               butterfly1In_B <= in2;
               butterfly2In_A <= in1;
               butterfly2In_B <= in3;

               butterfly1Twiddle <= twiddle240;
               butterfly2Twiddle <= twiddle240;

					
					end

            STAGE_2: begin
				
               //second stage of 2 butterfly units, set inputs/outputs
               butterfly1In_A <= out0d;
               butterfly1In_B <= out2d;
               butterfly2In_A <= out1d;
               butterfly2In_B <= out3d;

               butterfly1Twiddle <= twiddle240;
               butterfly2Twiddle <= twiddle41; // flips sign
					
					end
				DONE: begin
					out0 <= out0d;
					out1 <= out1d;
					out2 <= out2d;
					out3 <= out3d;
					
				end
					
				
					
        endcase
		  end
		  always_comb begin
		  case (state)
				RESET: begin
               if (start) 
						nextstate = STAGE_1;
               else 
                  nextstate = RESET;
					done = 0;
             end
					 
            STAGE_1: begin
               //first stage of 2 butterfly units, set inputs/outputs
					done = 0;
               nextstate = STAGE_2;
					
				end

            STAGE_2: begin
               nextstate = DONE;
					done = 0;
				end
				
				DONE: begin
					nextstate = RESET;
					done = 1;
					
				end
				endcase
		  end
   
   butterflyUnit #(.WIDTH(32)) butterflyUnit1(butterfly1In_A, butterfly1In_B, butterfly1Twiddle, out0d, out1d);
	butterflyUnit #(.WIDTH(32)) butterflyUnit2(butterfly2In_A, butterfly2In_B, butterfly2Twiddle, out2d, out3d);

endmodule