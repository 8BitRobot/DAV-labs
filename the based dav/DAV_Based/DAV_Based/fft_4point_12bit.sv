module fft_4point_12bit(clk, reset, start, mic_in, out0, out1, out2, out3, done);
    input reg clk, reset, start;
    input reg signed [11:0] mic_in [3:0];
    output reg signed [11:0] out0, out1, out2, out3;
    output reg done;

    parameter RESET = 2'b00;
    parameter STAGE_1 = 2'b01;
    parameter STAGE_2 = 2'b10;
    parameter DONE = 2'b11;

    reg [1:0] state = RESET;
	 reg [1:0] nextstate = RESET;
	 
    reg [11:0] butterfly1In_A, butterfly1In_B, butterfly1Out_Add, butterfly1Out_Subtract;
    reg [11:0] butterfly2In_A, butterfly2In_B, butterfly2Out_Add, butterfly2Out_Subtract;
    reg [11:0] butterfly1Twiddle, butterfly2Twiddle;
	 
    reg signed [11:0] temp_out0, temp_out1, temp_out2, temp_out3;

    // insert parameters for twiddle factors, which is right shifted by 11

    reg [11:0] twiddle240 = 12'b011111000000; // already left shifted W^0_2 = W^0_4
    reg [11:0] twiddle41 =  12'b000000011111; // shifted W^1_4
	 
	 always@(posedge clk) begin
        state <= nextstate;
		  if (state == STAGE_2) begin
				out0 = temp_out0;
            out1 = temp_out2;
            out2 = temp_out1;
            out3 = temp_out3;
		  end
    end
	 
    // state machine
    always_comb begin
        case (state)
            RESET: begin
               if (start) 
						nextstate = STAGE_1;
               else 
                  nextstate = RESET;
					
					done = 0;
					// hold outputs as zero
					butterfly1In_A = 12'b0;
               butterfly1In_B = 12'b0;
               butterfly2In_A = 12'b0;
               butterfly2In_B = 12'b0;
					butterfly1Twiddle = 12'b0;
               butterfly2Twiddle = 12'b0;
					
					temp_out0 = 12'b0;
               temp_out1 = 12'b0;
               temp_out2 = 12'b0;
               temp_out3 = 12'b0;
               
               end
					 
            STAGE_1: begin
					
               //first stage of 2 butterfly units, set inputs/outputs
					done = 0;
					
               butterfly1In_A = mic_in[0];
               butterfly1In_B = mic_in[2];
               butterfly2In_A = mic_in[1];
               butterfly2In_B = mic_in[3];

               butterfly1Twiddle = twiddle240;
               butterfly2Twiddle = twiddle240;
                
               //store outputs
               temp_out0 = butterfly1Out_Add;
               temp_out1 = butterfly1Out_Subtract;
               temp_out2 = butterfly2Out_Add;
               temp_out3 = butterfly2Out_Subtract;

               nextstate = STAGE_2;
					end

            STAGE_2: begin
				
               //second stage of 2 butterfly units, set inputs/outputs
					done = 0;

               butterfly1In_A = temp_out0;
               butterfly1In_B = temp_out2;
               butterfly2In_A = temp_out1;
               butterfly2In_B = temp_out3;

               butterfly1Twiddle = twiddle240;
               butterfly2Twiddle = twiddle41;

               temp_out0 = butterfly1Out_Add;
               temp_out1 = butterfly1Out_Subtract;
               temp_out2 = butterfly2Out_Add;
               temp_out3 = butterfly2Out_Subtract;

               nextstate = DONE;
					end
					
            DONE: begin
               done = 1;
               if(start)
                  nextstate = DONE;
               else
                  nextstate = RESET;
					
					// set outputs to final values
					
					butterfly1In_A = 12'b0;
               butterfly1In_B = 12'b0;
               butterfly2In_A = 12'b0;
               butterfly2In_B = 12'b0;
					butterfly1Twiddle = 12'b0;
               butterfly2Twiddle = 12'b0;
					
					temp_out0 = 12'b0;
               temp_out1 = 12'b0;
               temp_out2 = 12'b0;
               temp_out3 = 12'b0;
					end
        endcase
	end
   
   butterflyUnit #(.WIDTH(12)) butterflyUnit1(butterfly1In_A, butterfly1In_B, butterfly1Twiddle, butterfly1Out_Add, butterfly1Out_Subtract);
	butterflyUnit #(.WIDTH(12)) butterflyUnit2(butterfly2In_A, butterfly2In_B, butterfly2Twiddle, butterfly2Out_Add, butterfly2Out_Subtract);

endmodule