module fft_32point_36bit(clk, reset, start, time_domain_in, freq_domain_out, done);
	input clk;
	input reset;
	input start;
	input [35:0] time_domain_in [31:0];
	output reg [35:0] freq_domain_out [31:0];
	output wire done;
	
	parameter WIDTH = 36;
	parameter POINTS = 32;
	
	reg [35:0] a [15:0];
	reg [35:0] b [15:0];
	reg [35:0] w [15:0];
	reg [35:0] p_d[15:0];
	reg [35:0] n_d[15:0];
	
	reg [35:0] p[15:0];
	reg [35:0] n[15:0];
	
	reg [35:0] last_p[15:0];
	reg [35:0] last_n[15:0];
	
	// Compute twiddle components

	// W0
	wire signed[17:0] twiddle_0_32_real = 18'b011111111111111111;
	wire signed[17:0] twiddle_0_32_imag = 0 << 17;
	wire [35:0] w_0_32 = {twiddle_0_32_real, twiddle_0_32_imag};
	
	// W1
	wire signed[17:0] twiddle_1_32_real = 18'd128553;
	wire signed[17:0] twiddle_1_32_imag = 18'd25571;
	wire [35:0] w_1_32 = {twiddle_1_32_real, twiddle_1_32_imag};
	
	// W2
	wire signed[17:0] twiddle_2_32_real = 18'd121095;
	wire signed[17:0] twiddle_2_32_imag = 18'd50159;
	wire [35:0] w_2_32 = {twiddle_2_32_real, twiddle_2_32_imag};
	
	// W3
	wire signed[17:0] twiddle_3_32_real = 18'd108982;
	wire signed[17:0] twiddle_3_32_imag = 18'd72820;
	wire [35:0] w_3_32 = {twiddle_3_32_real, twiddle_3_32_imag};
	
	// W4
	wire signed[17:0] twiddle_4_32_real = 18'd92682;
	wire signed[17:0] twiddle_4_32_imag = 18'd92682;
	wire [35:0] w_4_32 = {twiddle_4_32_real, twiddle_4_32_imag};
	
	// W5
	wire signed[17:0] twiddle_5_32_real = 18'd72820;
	wire signed[17:0] twiddle_5_32_imag = 18'd108982;
	wire [35:0] w_5_32 = {twiddle_5_32_real, twiddle_5_32_imag};
	
	// W6
	wire signed[17:0] twiddle_6_32_real = 18'd50159;
	wire signed[17:0] twiddle_6_32_imag = 18'd121095;
	wire [35:0] w_6_32 = {twiddle_6_32_real, twiddle_6_32_imag};
	
	// W7
	wire signed[17:0] twiddle_7_32_real = 18'd25571;
	wire signed[17:0] twiddle_7_32_imag = 18'd128553;
	wire [35:0] w_7_32 = {twiddle_7_32_real, twiddle_7_32_imag};
	
	// W8
	wire signed[17:0] twiddle_8_32_real = 0 << 17;
	wire signed[17:0] twiddle_8_32_imag = 18'b011111111111111111;
	wire [35:0] w_8_32 = {twiddle_8_32_real, twiddle_8_32_imag};
	
	// W9
	wire signed[17:0] twiddle_9_32_real = -18'd25571;
	wire signed[17:0] twiddle_9_32_imag = 18'd128553;
	wire [35:0] w_9_32 = {twiddle_9_32_real, twiddle_9_32_imag};
	
	// W10
	wire signed[17:0] twiddle_10_32_real = -18'd50159;
	wire signed[17:0] twiddle_10_32_imag = 18'd121095;
	wire [35:0] w_10_32 = {twiddle_10_32_real, twiddle_10_32_imag};
	
	// W11
	wire signed[17:0] twiddle_11_32_real = -18'd72820;
	wire signed[17:0] twiddle_11_32_imag = 18'd108982;
	wire [35:0] w_11_32 = {twiddle_11_32_real, twiddle_11_32_imag};
	
	// W12
	wire signed[17:0] twiddle_12_32_real = -18'd92682;
	wire signed[17:0] twiddle_12_32_imag = 18'd92682;
	wire [35:0] w_12_32 = {twiddle_12_32_real, twiddle_12_32_imag};
	
	// W13
	wire signed[17:0] twiddle_13_32_real = -18'd108982;
	wire signed[17:0] twiddle_13_32_imag = 18'd72820;
	wire [35:0] w_13_32 = {twiddle_13_32_real, twiddle_13_32_imag};
		
	// W14
	wire signed[17:0] twiddle_14_32_real = -18'd121095;
	wire signed[17:0] twiddle_14_32_imag = 18'd50159;
	wire [35:0] w_14_32 = {twiddle_14_32_real, twiddle_14_32_imag};
	
	// W15
	wire signed[17:0] twiddle_15_32_real = -18'd128553;
	wire signed[17:0] twiddle_15_32_imag = 18'd25571;
	wire [35:0] w_15_32 = {twiddle_15_32_real, twiddle_15_32_imag};
	
	genvar i;
	
	generate
		for (i = 0; i < POINTS/2; i = i + 1) begin: BUTTERFLY_GEN
			butterfly #(.WIDTH(WIDTH)) BUTTERFLY_MOD(a[i], b[i], w[i], p_d[i], n_d[i]);
		end
	endgenerate
	
	// State names
	parameter RESET = 3'b000;
	parameter STAGE_1 = 3'b001;
	parameter STAGE_2 = 3'b010;
	parameter STAGE_3 = 3'b011;
	parameter STAGE_4 = 3'b100;
	parameter STAGE_5 = 3'b101;
	parameter DONE = 3'b110;
	
	// State registers
	reg[2:0] state = RESET;
	reg[2:0] next_state = RESET;
	
	assign done = (state == DONE) ? 1 : 0;
	
	// Wire up all the butterfly units according to diagram
	always_comb begin
		case(state) 
			RESET:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_domain_out[i] = 0;
					end
					// Zero all inputs to bufferfly units
					for (int i = 0; i < POINTS/2; i++) begin
						a[i] = 0;
						b[i] = 0;
						w[i] = 0;
					end
				end
			STAGE_1:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_domain_out[i] = 0;
					end
					
					// Set butterfly inputs for stage 1
					a[0] = time_domain_in[0];
					a[1] = time_domain_in[8];
					a[2] = time_domain_in[4];
					a[3] = time_domain_in[12];
					a[4] = time_domain_in[2];
					a[5] = time_domain_in[10];
					a[6] = time_domain_in[6];
					a[7] = time_domain_in[14];
					a[8] = time_domain_in[1];
					a[9] = time_domain_in[9];
					a[10] = time_domain_in[5];
					a[11] = time_domain_in[13];
					a[12] = time_domain_in[3];
					a[13] = time_domain_in[11];
					a[14] = time_domain_in[7];
					a[15] = time_domain_in[15];
					
					b[0] = time_domain_in[16];
					b[1] = time_domain_in[24];
					b[2] = time_domain_in[20];
					b[3] = time_domain_in[28];
					b[4] = time_domain_in[14];
					b[5] = time_domain_in[26];
					b[6] = time_domain_in[22];
					b[7] = time_domain_in[30];
					b[8] = time_domain_in[17];
					b[9] = time_domain_in[25];
					b[10] = time_domain_in[21];
					b[11] = time_domain_in[29];
					b[12] = time_domain_in[19];
					b[13] = time_domain_in[27];
					b[14] = time_domain_in[23];
					b[15] = time_domain_in[31];
					
					w[0] = w_0_32;
					w[1] = w_0_32;
					w[2] = w_0_32;
					w[3] = w_0_32;
					w[4] = w_0_32;
					w[5] = w_0_32;
					w[6] = w_0_32;
					w[7] = w_0_32;
					w[8] = w_0_32;
					w[9] = w_0_32;
					w[10] = w_0_32;
					w[11] = w_0_32;
					w[12] = w_0_32;
					w[13] = w_0_32;
					w[14] = w_0_32;
					w[15] = w_0_32;
				end
			STAGE_2:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_domain_out[i] = 0;
					end
					
					// Set butterfly inputs for stage 2
					a[0] = p[0];
					a[1] = n[0];
					a[2] = p[2];
					a[3] = n[2];
					a[4] = p[4];
					a[5] = n[4];
					a[6] = p[6];
					a[7] = n[6];
					a[8] = p[8];
					a[9] = n[8];
					a[10] = p[10];
					a[11] = n[10];
					a[12] = p[12];
					a[13] = n[12];
					a[14] = p[14];
					a[15] = n[14];
					
					b[0] = p[1];
					b[1] = n[1];
					b[2] = p[3];
					b[3] = n[3];
					b[4] = p[5];
					b[5] = n[5];
					b[6] = p[7];
					b[7] = n[7];
					b[8] = p[9];
					b[9] = n[9];
					b[10] = p[11];
					b[11] = n[11];
					b[12] = p[13];
					b[13] = n[13];
					b[14] = p[15];
					b[15] = n[15];
					
					w[0] = w_0_32;
					w[1] = w_8_32;
					w[2] = w_0_32;
					w[3] = w_8_32;
					w[4] = w_0_32;
					w[5] = w_8_32;
					w[6] = w_0_32;
					w[7] = w_8_32;
					w[8] = w_0_32;
					w[9] = w_8_32;
					w[10] = w_0_32;
					w[11] = w_8_32;
					w[12] = w_0_32;
					w[13] = w_8_32;
					w[14] = w_0_32;
					w[15] = w_8_32;
				end
			STAGE_3:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_domain_out[i] = 0;
					end
					
					// Set butterfly inputs for stage 3
					a[0] = p[0];
					a[1] = p[1];
					a[2] = n[0];
					a[3] = n[1];
					a[4] = p[4];
					a[5] = p[5];
					a[6] = n[4];
					a[7] = n[5];
					a[8] = p[8];
					a[9] = p[9];
					a[10] = n[8];
					a[11] = n[9];
					a[12] = p[12];
					a[13] = p[13];
					a[14] = n[12];
					a[15] = n[13];
					
					b[0] = p[2];
					b[1] = p[3];
					b[2] = n[2];
					b[3] = n[3];
					b[4] = p[6];
					b[5] = p[7];
					b[6] = n[6];
					b[7] = n[7];
					b[8] = p[10];
					b[9] = p[11];
					b[10] = n[10];
					b[11] = n[11];
					b[12] = p[14];
					b[13] = p[15];
					b[14] = n[14];
					b[15] = n[15];
					
					w[0] = w_0_32;
					w[1] = w_4_32;
					w[2] = w_8_32;
					w[3] = w_12_32;
					w[4] = w_0_32;
					w[5] = w_4_32;
					w[6] = w_8_32;
					w[7] = w_12_32;
					w[8] = w_0_32;
					w[9] = w_4_32;
					w[10] = w_8_32;
					w[11] = w_12_32;
					w[12] = w_0_32;
					w[13] = w_4_32;
					w[14] = w_8_32;
					w[15] = w_12_32;
				end
			STAGE_4:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_domain_out[i] = 0;
					end
					
					// Set butterfly inputs for stage 4
					a[0] = p[0];
					a[1] = p[1];
					a[2] = p[2];
					a[3] = p[3];
					a[4] = n[0];
					a[5] = n[1];
					a[6] = n[2];
					a[7] = n[3];
					a[8] = p[8];
					a[9] = p[9];
					a[10] = p[10];
					a[11] = p[11];
					a[12] = n[8];
					a[13] = n[9];
					a[14] = n[10];
					a[15] = n[11];
					
					b[0] = p[4];
					b[1] = p[5];
					b[2] = p[6];
					b[3] = p[7];
					b[4] = n[4];
					b[5] = n[5];
					b[6] = n[6];
					b[7] = n[7];
					b[8] = p[12];
					b[9] = p[13];
					b[10] = p[14];
					b[11] = p[15];
					b[12] = n[12];
					b[13] = n[13];
					b[14] = n[14];
					b[15] = n[15];
					
					w[0] = w_0_32;
					w[1] = w_2_32;
					w[2] = w_4_32;
					w[3] = w_6_32;
					w[4] = w_8_32;
					w[5] = w_10_32;
					w[6] = w_12_32;
					w[7] = w_14_32;
					w[8] = w_0_32;
					w[9] = w_2_32;
					w[10] = w_4_32;
					w[11] = w_6_32;
					w[12] = w_8_32;
					w[13] = w_10_32;
					w[14] = w_12_32;
					w[15] = w_14_32;
				end
			STAGE_5:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_domain_out[i] = 0;
					end
					
					// Set butterfly inputs for stage 4
					a[0] = p[0];
					a[1] = p[1];
					a[2] = p[2];
					a[3] = p[3];
					a[4] = p[4];
					a[5] = p[5];
					a[6] = p[6];
					a[7] = p[7];
					a[8] = n[0];
					a[9] = n[1];
					a[10] = n[2];
					a[11] = n[3];
					a[12] = n[4];
					a[13] = n[5];
					a[14] = n[6];
					a[15] = n[7];
					
					b[0] = p[8];
					b[1] = p[9];
					b[2] = p[10];
					b[3] = p[11];
					b[4] = p[12];
					b[5] = p[13];
					b[6] = p[14];
					b[7] = p[15];
					b[8] = n[8];
					b[9] = n[9];
					b[10] = n[10];
					b[11] = n[11];
					b[12] = n[12];
					b[13] = n[13];
					b[14] = n[14];
					b[15] = n[15];
					
					w[0] = w_0_32;
					w[1] = w_1_32;
					w[2] = w_2_32;
					w[3] = w_3_32;
					w[4] = w_4_32;
					w[5] = w_5_32;
					w[6] = w_6_32;
					w[7] = w_7_32;
					w[8] = w_8_32;
					w[9] = w_9_32;
					w[10] = w_10_32;
					w[11] = w_11_32;
					w[12] = w_12_32;
					w[13] = w_13_32;
					w[14] = w_14_32;
					w[15] = w_15_32;
				end
			DONE:
				begin
					// Set final output values
					freq_domain_out[0] = p[0];
					freq_domain_out[1] = p[1];
					freq_domain_out[2] = p[2];
					freq_domain_out[3] = p[3];
					freq_domain_out[4] = p[4];
					freq_domain_out[5] = p[5];
					freq_domain_out[6] = p[6];
					freq_domain_out[7] = p[7];
					freq_domain_out[8] = p[8];
					freq_domain_out[9] = p[9];
					freq_domain_out[10] = p[10];
					freq_domain_out[11] = p[11];
					freq_domain_out[12] = p[12];
					freq_domain_out[13] = p[13];
					freq_domain_out[14] = p[14];
					freq_domain_out[15] = p[15];
					freq_domain_out[16] = n[0];
					freq_domain_out[17] = n[1];
					freq_domain_out[18] = n[2];
					freq_domain_out[19] = n[3];
					freq_domain_out[20] = n[4];
					freq_domain_out[21] = n[5];
					freq_domain_out[22] = n[6];
					freq_domain_out[23] = n[7];
					freq_domain_out[24] = n[8];
					freq_domain_out[25] = n[9];
					freq_domain_out[26] = n[10];
					freq_domain_out[27] = n[11];
					freq_domain_out[28] = n[12];
					freq_domain_out[29] = n[13];
					freq_domain_out[30] = n[14];
					freq_domain_out[31] = n[15];
					
					// Set butterfly inputs to last stage
					a[0] = last_p[0];
					a[1] = last_p[1];
					a[2] = last_p[2];
					a[3] = last_p[3];
					a[4] = last_p[4];
					a[5] = last_p[5];
					a[6] = last_p[6];
					a[7] = last_p[7];
					a[8] = last_n[0];
					a[9] = last_n[1];
					a[10] = last_n[2];
					a[11] = last_n[3];
					a[12] = last_n[4];
					a[13] = last_n[5];
					a[14] = last_n[6];
					a[15] = last_n[7];
					
					b[0] = last_p[8];
					b[1] = last_p[9];
					b[2] = last_p[10];
					b[3] = last_p[11];
					b[4] = last_p[12];
					b[5] = last_p[13];
					b[6] = last_p[14];
					b[7] = last_p[15];
					b[8] = last_n[8];
					b[9] = last_n[9];
					b[10] = last_n[10];
					b[11] = last_n[11];
					b[12] = last_n[12];
					b[13] = last_n[13];
					b[14] = last_n[14];
					b[15] = last_n[15];
					
					w[0] = w_0_32;
					w[1] = w_1_32;
					w[2] = w_2_32;
					w[3] = w_3_32;
					w[4] = w_4_32;
					w[5] = w_5_32;
					w[6] = w_6_32;
					w[7] = w_7_32;
					w[8] = w_8_32;
					w[9] = w_9_32;
					w[10] = w_10_32;
					w[11] = w_11_32;
					w[12] = w_12_32;
					w[13] = w_13_32;
					w[14] = w_14_32;
					w[15] = w_15_32;
				end
		endcase
	end
	
	// State transistion logic
	always_comb begin
		case(state) 
			RESET:
				if (start == 1) begin // Start pushed
					next_state = STAGE_1;
				end
				else begin
					next_state = RESET;
				end
			STAGE_1:
				if (reset == 0) begin // Reset pushed
					next_state = RESET;
				end
				else begin
					next_state = STAGE_2;
				end
			STAGE_2:
				if (reset == 0) begin // Reset pushed
					next_state = RESET;
				end
				else begin
					next_state = STAGE_3;
				end
			STAGE_3:
				if (reset == 0) begin // Reset pushed
					next_state = RESET;
				end
				else begin
					next_state = STAGE_4;
				end
			STAGE_4:
				if (reset == 0) begin // Reset pushed
					next_state = RESET;
				end
				else begin
					next_state = STAGE_5;
				end
			STAGE_5:
				if (reset == 0) begin // Reset pushed
					next_state = RESET;
				end
				else begin
					next_state = DONE;
				end
			DONE:
				if (reset == 0 || start == 0) begin // Start not pushed, reset pushed
					next_state = RESET;
				end
				else begin
					next_state = DONE;
				end
		endcase
	end	
	
	always @ (posedge clk) begin
		if (state == STAGE_5) begin
			last_p <= p;
			last_n <= n;
		end
	end
	
	
	// Sequential logic
	always @ (posedge clk) begin
		state <= next_state;
		// Update intermediate registers
		p <= p_d;
		n <= n_d;
	end
	
endmodule