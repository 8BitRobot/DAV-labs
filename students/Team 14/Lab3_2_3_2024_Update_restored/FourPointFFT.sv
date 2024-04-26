module FourPointFFT #(parameter WIDTH = 32)
(
	input[(WIDTH-1):0] sample1, input[(WIDTH-1):0] sample2, input[(WIDTH-1):0] sample3, input[(WIDTH-1):0] sample4,
	input clk, input reset, input start,
	
	output logic [(WIDTH-1):0] output1, output logic [(WIDTH-1):0] output2, output logic [(WIDTH-1):0] output3, output logic [(WIDTH-1):0] output4,
	output logic done
);

	//Getting the twiddle numbers
	logic[(WIDTH-1):0] twiddle0, twiddle1;
	logic [(WIDTH/2)-1:0] twiddle0_real, twiddle0_imag, twiddle1_real, twiddle1_imag;
	assign twiddle0_real = 1; assign twiddle0_imag = 0; assign twiddle1_real = 0; assign twiddle1_imag = -1;
	getComplexNum #(WIDTH) twiddle_zero_getter (twiddle0_real, twiddle0_imag, twiddle0);
	getComplexNum #(WIDTH) twiddle_one_getter (twiddle1_real, twiddle1_imag, twiddle1);

	
	//Setting up the butterfly modules
	logic [(WIDTH-1):0] eggs0, larva0, pupa0, butterfly0, eggs1, larva1, pupa1, butterfly1;
	Butterfly #(WIDTH) monarch (eggs0, larva0, twiddle0, pupa0, butterfly0);
	Butterfly #(WIDTH) birdwing (eggs1, larva1, twiddle1, pupa1, butterfly1);
	
	
	//Set-up for the FSM
	parameter RESET = 0; parameter STAGE1 = 1; parameter STAGE2 = 2; parameter DONE = 3;
	logic [1:0] state = RESET;
	logic [1:0] nextState;
	logic[(WIDTH-1):0] inter1, inter2, inter3, inter4;
	logic[(WIDTH-1):0] rememberedO1, rememberedO2, rememberedO3, rememberedO4;

	//FSM
		//SOME DEFAULTS:
			//Unless we're in STAGE2, the outputs are set to the remembered outputs
			//Unless we're in DONE, done is set to 0
			//Unless we're in STAGE1 or STAGE2, eggs and larva are set to 0
	always_comb
	begin
		if (state == RESET)
			begin				
				eggs0 = 0; larva0 = 0; eggs1 = 0; larva1 = 0;
				output1 = rememberedO1; output2 = rememberedO2; output3 = rememberedO3; output4 = rememberedO4;
				done = 0;
				nextState = start*STAGE1;
			end
			
		else if (state == STAGE1)
			begin
				eggs0 = sample1; larva0 = sample3; eggs1 = sample2; larva1 = sample4;
				output1 = rememberedO1; output2 = rememberedO2; output3 = rememberedO3; output4 = rememberedO4;				
				done = 0;
				nextState = STAGE2;
			end
			
		else if (state == STAGE2)
			begin
				eggs0 = inter1; larva0 = inter3; eggs1 = inter2; larva1 = inter4; 
				output1 = pupa0; output3 = butterfly0; output2 = pupa1; output4 = butterfly1;
				done = 0;
				nextState = DONE;
			end
			
		else //state = DONE
			begin
				eggs0 = 0; larva0 = 0; eggs1 = 0; larva1 = 0;
				output1 = rememberedO1; output2 = rememberedO2; output3 = rememberedO3; output4 = rememberedO4;
				done = 1;
				nextState = DONE;
			end
	end
	
	//Sequential block
	always_ff @(posedge clk)
	begin
		 if (state == STAGE1)
			begin
				inter1 <= pupa0; inter2 <= butterfly0; inter3 <= pupa1; inter4 <= butterfly1;
			end
		 if (state == STAGE2)
			begin
				rememberedO1 <= output1; rememberedO2 <= output2; rememberedO3 <= output3; rememberedO4 <= output4;
			end
		 if (reset==1) state <= RESET; else state <= nextState;
		 if (state == RESET)
		 begin
				inter1 <= 0; inter2 <= 0; inter3 <= 0; inter4 <= 0;
				rememberedO1 <= 0; rememberedO2 <= 0; rememberedO3 <= 0; rememberedO4 <= 0;
		 end
	end

endmodule