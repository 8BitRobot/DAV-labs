module fft_64point_36bit(clk, reset, start, time_in, freq_out, done);
	input clk;
	input reset;
	input start;
	input [35:0] time_in [63:0];
	output reg [35:0] freq_out [63:0];
	output wire done;
	
	parameter WIDTH = 36;
	parameter POINTS = 64;
	
	reg [35:0] a [31:0];
	reg [35:0] b [31:0];
	reg [35:0] w [31:0];
	reg [35:0] p_d[31:0];
	reg [35:0] n_d[31:0];
	
	reg [35:0] p[31:0];
	reg [35:0] n[31:0];
	
	reg [35:0] last_p[31:0];
	reg [35:0] last_n[31:0];
	
	// Compute twiddle components

	// W0
	wire signed[17:0] twiddle_0_64_real = 18'b011111111111111111;
	wire signed[17:0] twiddle_0_64_imag = 0 << 17;
	wire [35:0] w_0_64 = {twiddle_0_64_real, twiddle_0_64_imag};
	
	// W1
	wire signed[17:0] twiddle_1_64_real = 18'd130441;
	wire signed[17:0] twiddle_1_64_imag = 18'd12847;
	wire [35:0] w_1_64 = {twiddle_1_64_real, twiddle_1_64_imag};
	
	// W2
	wire signed[17:0] twiddle_2_64_real = 18'd128553;
	wire signed[17:0] twiddle_2_64_imag = 18'd25571;
	wire [35:0] w_2_64 = {twiddle_2_64_real, twiddle_2_64_imag};
	
	// W3
	wire signed[17:0] twiddle_3_64_real = 18'd125428;
	wire signed[17:0] twiddle_3_64_imag = 18'd38048;
	wire [35:0] w_3_64 = {twiddle_3_64_real, twiddle_3_64_imag};
	
	// W4
	wire signed[17:0] twiddle_4_64_real = 18'd121095;
	wire signed[17:0] twiddle_4_64_imag = 18'd50159;
	wire [35:0] w_4_64 = {twiddle_4_64_real, twiddle_4_64_imag};
	
	// W5
	wire signed[17:0] twiddle_5_64_real = 18'd115595;
	wire signed[17:0] twiddle_5_64_imag = 18'd61787;
	wire [35:0] w_5_64 = {twiddle_5_64_real, twiddle_5_64_imag};
	
	// W6
	wire signed[17:0] twiddle_6_64_real = 18'd108982;
	wire signed[17:0] twiddle_6_64_imag = 18'd72820;
	wire [35:0] w_6_64 = {twiddle_6_64_real, twiddle_6_64_imag};
	
	// W7
	wire signed[17:0] twiddle_7_64_real = 18'd101320;
	wire signed[17:0] twiddle_7_64_imag = 18'd83151;
	wire [35:0] w_7_64 = {twiddle_7_64_real, twiddle_7_64_imag};
	
	// W8
	wire signed[17:0] twiddle_8_64_real = 18'd92682;
	wire signed[17:0] twiddle_8_64_imag = 18'd92682;
	wire [35:0] w_8_64 = {twiddle_8_64_real, twiddle_8_64_imag};
	
	// W9
	wire signed[17:0] twiddle_9_64_real = 18'd83151;
	wire signed[17:0] twiddle_9_64_imag = 18'd101320;
	wire [35:0] w_9_64 = {twiddle_9_64_real, twiddle_9_64_imag};
	
	// W10
	wire signed[17:0] twiddle_10_64_real = 18'd72820;
	wire signed[17:0] twiddle_10_64_imag = 18'd108982;
	wire [35:0] w_10_64 = {twiddle_10_64_real, twiddle_10_64_imag};
	
	// W11
	wire signed[17:0] twiddle_11_64_real = 18'd61787;
	wire signed[17:0] twiddle_11_64_imag = 18'd115595;
	wire [35:0] w_11_64 = {twiddle_11_64_real, twiddle_11_64_imag};
	
	// W12
	wire signed[17:0] twiddle_12_64_real = 18'd50159;
	wire signed[17:0] twiddle_12_64_imag = 18'd121095;
	wire [35:0] w_12_64 = {twiddle_12_64_real, twiddle_12_64_imag};
	
	// W13
	wire signed[17:0] twiddle_13_64_real = 18'd38048;
	wire signed[17:0] twiddle_13_64_imag = 18'd125428;
	wire [35:0] w_13_64 = {twiddle_13_64_real, twiddle_13_64_imag};
	
	// W14
	wire signed[17:0] twiddle_14_64_real = 18'd25571;
	wire signed[17:0] twiddle_14_64_imag = 18'd128553;
	wire [35:0] w_14_64 = {twiddle_14_64_real, twiddle_14_64_imag};
	
	// W15
	wire signed[17:0] twiddle_15_64_real = 18'd12847;
	wire signed[17:0] twiddle_15_64_imag = 18'd130441;
	wire [35:0] w_15_64 = {twiddle_15_64_real, twiddle_15_64_imag};
	
	// W16
	wire signed[17:0] twiddle_16_64_real = 0 << 17;
	wire signed[17:0] twiddle_16_64_imag = 18'b011111111111111111;
	wire [35:0] w_16_64 = {twiddle_16_64_real, twiddle_16_64_imag};
	
	// W17
	wire signed[17:0] twiddle_17_64_real = -18'd12847;
	wire signed[17:0] twiddle_17_64_imag = 18'd130441;
	wire [35:0] w_17_64 = {twiddle_17_64_real, twiddle_17_64_imag};
	
	// W18
	wire signed[17:0] twiddle_18_64_real = -18'd25571;
	wire signed[17:0] twiddle_18_64_imag = 18'd128553;
	wire [35:0] w_18_64 = {twiddle_18_64_real, twiddle_18_64_imag};
	
	// W19
	wire signed[17:0] twiddle_19_64_real = -18'd38048;
	wire signed[17:0] twiddle_19_64_imag = 18'd125428;
	wire [35:0] w_19_64 = {twiddle_19_64_real, twiddle_19_64_imag};
	
	// W20
	wire signed[17:0] twiddle_20_64_real = -18'd50159;
	wire signed[17:0] twiddle_20_64_imag = 18'd121095;
	wire [35:0] w_20_64 = {twiddle_20_64_real, twiddle_20_64_imag};
	
	// W21
	wire signed[17:0] twiddle_21_64_real = -18'd61787;
	wire signed[17:0] twiddle_21_64_imag = 18'd115595;
	wire [35:0] w_21_64 = {twiddle_21_64_real, twiddle_21_64_imag};
	
	// W22
	wire signed[17:0] twiddle_22_64_real = -18'd72820;
	wire signed[17:0] twiddle_22_64_imag = 18'd108982;
	wire [35:0] w_22_64 = {twiddle_22_64_real, twiddle_22_64_imag};
	
	// W23
	wire signed[17:0] twiddle_23_64_real = -18'd83151;
	wire signed[17:0] twiddle_23_64_imag = 18'd101320;
	wire [35:0] w_23_64 = {twiddle_23_64_real, twiddle_23_64_imag};
	
	// W24
	wire signed[17:0] twiddle_24_64_real = -18'd92682;
	wire signed[17:0] twiddle_24_64_imag = 18'd92682;
	wire [35:0] w_24_64 = {twiddle_24_64_real, twiddle_24_64_imag};
	
	// W25
	wire signed[17:0] twiddle_25_64_real = -18'd101320;
	wire signed[17:0] twiddle_25_64_imag = 18'd83151;
	wire [35:0] w_25_64 = {twiddle_25_64_real, twiddle_25_64_imag};
	
	// W26
	wire signed[17:0] twiddle_26_64_real = -18'd108982;
	wire signed[17:0] twiddle_26_64_imag = 18'd72820;
	wire [35:0] w_26_64 = {twiddle_26_64_real, twiddle_26_64_imag};
	
	// W27
	wire signed[17:0] twiddle_27_64_real = -18'd115595;
	wire signed[17:0] twiddle_27_64_imag = 18'd61787;
	wire [35:0] w_27_64 = {twiddle_27_64_real, twiddle_27_64_imag};
	
	// W28
	wire signed[17:0] twiddle_28_64_real = -18'd121095;
	wire signed[17:0] twiddle_28_64_imag = 18'd50159;
	wire [35:0] w_28_64 = {twiddle_28_64_real, twiddle_28_64_imag};
	
	// W29
	wire signed[17:0] twiddle_29_64_real = -18'd125428;
	wire signed[17:0] twiddle_29_64_imag = 18'd38048;
	wire [35:0] w_29_64 = {twiddle_29_64_real, twiddle_29_64_imag};
	
	// W30
	wire signed[17:0] twiddle_30_64_real = -18'd128553;
	wire signed[17:0] twiddle_30_64_imag = 18'd25571;
	wire [35:0] w_30_64 = {twiddle_30_64_real, twiddle_30_64_imag};
	
	// W31
	wire signed[17:0] twiddle_31_64_real = -18'd130441;
	wire signed[17:0] twiddle_31_64_imag = 18'd12847;
	wire [35:0] w_31_64 = {twiddle_31_64_real, twiddle_31_64_imag};
	
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
	parameter STAGE_6 = 3'b110;
	parameter DONE = 3'b111;
	
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
						freq_out[i] = 0;
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
						freq_out[i] = 0;
					end
					
					// Set butterfly inputs for stage 1
					a[0] = time_in[0];
					a[1] = time_in[16];
					a[2] = time_in[8];
					a[3] = time_in[24];
					a[4] = time_in[4];
					a[5] = time_in[20];
					a[6] = time_in[12];
					a[7] = time_in[28];
					a[8] = time_in[2];
					a[9] = time_in[18];
					a[10] = time_in[10];
					a[11] = time_in[26];
					a[12] = time_in[6];
					a[13] = time_in[22];
					a[14] = time_in[14];
					a[15] = time_in[30];
					a[16] = time_in[1];
					a[17] = time_in[17];
					a[18] = time_in[9];
					a[19] = time_in[25];
					a[20] = time_in[5];
					a[21] = time_in[21];
					a[22] = time_in[13];
					a[23] = time_in[29];
					a[24] = time_in[3];
					a[25] = time_in[19];
					a[26] = time_in[11];
					a[27] = time_in[27];
					a[28] = time_in[7];
					a[29] = time_in[23];
					a[30] = time_in[15];
					a[31] = time_in[31];
					
					b[0] = time_in[32];
					b[1] = time_in[48];
					b[2] = time_in[40];
					b[3] = time_in[56];
					b[4] = time_in[28];
					b[5] = time_in[52];
					b[6] = time_in[44];
					b[7] = time_in[60];
					b[8] = time_in[34];
					b[9] = time_in[50];
					b[10] = time_in[42];
					b[11] = time_in[58];
					b[12] = time_in[38];
					b[13] = time_in[54];
					b[14] = time_in[46];
					b[15] = time_in[62];
					b[16] = time_in[33];
					b[17] = time_in[49];
					b[18] = time_in[41];
					b[19] = time_in[57];
					b[20] = time_in[29];
					b[21] = time_in[53];
					b[22] = time_in[45];
					b[23] = time_in[61];
					b[24] = time_in[35];
					b[25] = time_in[51];
					b[26] = time_in[43];
					b[27] = time_in[59];
					b[28] = time_in[39];
					b[29] = time_in[55];
					b[30] = time_in[47];
					b[31] = time_in[63];
					
					// Twiddles for Stage 1
					w[0] = w_0_64;
					w[1] = w_0_64;
					w[2] = w_0_64;
					w[3] = w_0_64;
					w[4] = w_0_64;
					w[5] = w_0_64;
					w[6] = w_0_64;
					w[7] = w_0_64;
					w[8] = w_0_64;
					w[9] = w_0_64;
					w[10] = w_0_64;
					w[11] = w_0_64;
					w[12] = w_0_64;
					w[13] = w_0_64;
					w[14] = w_0_64;
					w[15] = w_0_64;
					w[16] = w_0_64;
					w[17] = w_0_64;
					w[18] = w_0_64;
					w[19] = w_0_64;
					w[20] = w_0_64;
					w[21] = w_0_64;
					w[22] = w_0_64;
					w[23] = w_0_64;
					w[24] = w_0_64;
					w[25] = w_0_64;
					w[26] = w_0_64;
					w[27] = w_0_64;
					w[28] = w_0_64;
					w[29] = w_0_64;
					w[30] = w_0_64;
					w[31] = w_0_64;
				end
			STAGE_2:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_out[i] = 0;
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
					a[16] = p[16];
					a[17] = n[16];
					a[18] = p[18];
					a[19] = n[18];
					a[20] = p[20];
					a[21] = n[20];
					a[22] = p[22];
					a[23] = n[22];
					a[24] = p[24];
					a[25] = n[24];
					a[26] = p[26];
					a[27] = n[26];
					a[28] = p[28];
					a[29] = n[28];
					a[30] = p[30];
					a[31] = n[30];
					
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
					b[16] = p[17];
					b[17] = n[17];
					b[18] = p[19];
					b[19] = n[19];
					b[20] = p[21];
					b[21] = n[21];
					b[22] = p[23];
					b[23] = n[23];
					b[24] = p[25];
					b[25] = n[25];
					b[26] = p[27];
					b[27] = n[27];
					b[28] = p[29];
					b[29] = n[29];
					b[30] = p[31];
					b[31] = n[31];
					
					// Twiddles for Stage 2
					w[0] = w_0_64;
					w[1] = w_16_64;
					w[2] = w_0_64;
					w[3] = w_16_64;
					w[4] = w_0_64;
					w[5] = w_16_64;
					w[6] = w_0_64;
					w[7] = w_16_64;
					w[8] = w_0_64;
					w[9] = w_16_64;
					w[10] = w_0_64;
					w[11] = w_16_64;
					w[12] = w_0_64;
					w[13] = w_16_64;
					w[14] = w_0_64;
					w[15] = w_16_64;
					w[16] = w_0_64;
					w[17] = w_16_64;
					w[18] = w_0_64;
					w[19] = w_16_64;
					w[20] = w_0_64;
					w[21] = w_16_64;
					w[22] = w_0_64;
					w[23] = w_16_64;
					w[24] = w_0_64;
					w[25] = w_16_64;
					w[26] = w_0_64;
					w[27] = w_16_64;
					w[28] = w_0_64;
					w[29] = w_16_64;
					w[30] = w_0_64;
					w[31] = w_16_64;
				end
			STAGE_3:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_out[i] = 0;
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
					a[16] = p[16];
					a[17] = p[17];
					a[18] = n[16];
					a[19] = n[17];
					a[20] = p[20];
					a[21] = p[21];
					a[22] = n[20];
					a[23] = n[21];
					a[24] = p[24];
					a[25] = p[25];
					a[26] = n[24];
					a[27] = n[25];
					a[28] = p[28];
					a[29] = n[29];
					a[30] = n[28];
					a[31] = n[29];
					
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
					b[16] = p[18];
					b[17] = p[19];
					b[18] = n[18];
					b[19] = n[19];
					b[20] = p[22];
					b[21] = p[23];
					b[22] = n[22];
					b[23] = n[23];
					b[24] = p[26];
					b[25] = p[27];
					b[26] = n[26];
					b[27] = n[27];
					b[28] = p[30];
					b[29] = p[31];
					b[30] = n[30];
					b[31] = n[31];
					
					// Twiddles for Stage 3
					w[0] = w_0_64;
					w[1] = w_8_64;
					w[2] = w_16_64;
					w[3] = w_24_64;
					w[4] = w_0_64;
					w[5] = w_8_64;
					w[6] = w_16_64;
					w[7] = w_24_64;
					w[8] = w_0_64;
					w[9] = w_8_64;
					w[10] = w_16_64;
					w[11] = w_24_64;
					w[12] = w_0_64;
					w[13] = w_8_64;
					w[14] = w_16_64;
					w[15] = w_24_64;
					w[16] = w_0_64;
					w[17] = w_8_64;
					w[18] = w_16_64;
					w[19] = w_24_64;
					w[20] = w_0_64;
					w[21] = w_8_64;
					w[22] = w_16_64;
					w[23] = w_24_64;
					w[24] = w_0_64;
					w[25] = w_8_64;
					w[26] = w_16_64;
					w[27] = w_24_64;
					w[28] = w_0_64;
					w[29] = w_8_64;
					w[30] = w_16_64;
					w[31] = w_24_64;
				end
			STAGE_4:
				begin
					// Hold outputs at 0
					for (int i = 0; i < POINTS; i++) begin
						freq_out[i] = 0;
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
					a[16] = p[16];
					a[17] = p[17];
					a[18] = p[18];
					a[19] = p[19];
					a[20] = n[16];
					a[21] = n[17];
					a[22] = n[18];
					a[23] = n[19];
					a[24] = p[24];
					a[25] = p[25];
					a[26] = p[26];
					a[27] = p[27];
					a[28] = n[24];
					a[29] = n[25];
					a[30] = n[26];
					a[31] = n[27];
					
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
					b[16] = p[20];
					b[17] = p[21];
					b[18] = p[22];
					b[19] = p[23];
					b[20] = n[20];
					b[21] = n[21];
					b[22] = n[22];
					b[23] = n[23];
					b[24] = p[28];
					b[25] = p[29];
					b[26] = p[30];
					b[27] = p[31];
					b[28] = n[28];
					b[29] = n[29];
					b[30] = n[30];
					b[31] = n[31];
					
					// Twiddles for Stage 4
					w[0] = w_0_64;
					w[1] = w_4_64;
					w[2] = w_8_64;
					w[3] = w_12_64;
					w[4] = w_16_64;
					w[5] = w_20_64;
					w[6] = w_24_64;
					w[7] = w_28_64;
					w[8] = w_0_64;
					w[9] = w_4_64;
					w[10] = w_8_64;
					w[11] = w_12_64;
					w[12] = w_16_64;
					w[13] = w_20_64;
					w[14] = w_24_64;
					w[15] = w_28_64;
					w[16] = w_0_64;
					w[17] = w_4_64;
					w[18] = w_8_64;
					w[19] = w_12_64;
					w[20] = w_16_64;
					w[21] = w_20_64;
					w[22] = w_24_64;
					w[23] = w_28_64;
					w[24] = w_0_64;
					w[25] = w_4_64;
					w[26] = w_8_64;
					w[27] = w_12_64;
					w[28] = w_16_64;
					w[29] = w_20_64;
					w[30] = w_24_64;
					w[31] = w_28_64;
				end
			STAGE_5:
				begin
					// Hold outputs at zero
					for (int i = 0; i < POINTS; i++) begin
						freq_out[i] = 0;
					end
					
					// Set butterfly inputs for stage 5
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
					a[16] = p[16];
					a[17] = p[17];
					a[18] = p[18];
					a[19] = p[19];
					a[20] = p[20];
					a[21] = p[21];
					a[22] = p[22];
					a[23] = p[23];
					a[24] = n[16];
					a[25] = n[17];
					a[26] = n[18];
					a[27] = n[19];
					a[28] = n[20];
					a[29] = n[21];
					a[30] = n[22];
					a[31] = n[23];
					
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
					b[16] = p[24];
					b[17] = p[25];
					b[18] = p[26];
					b[19] = p[27];
					b[20] = p[28];
					b[21] = p[29];
					b[22] = p[30];
					b[23] = p[31];
					b[24] = n[24];
					b[25] = n[25];
					b[26] = n[26];
					b[27] = n[27];
					b[28] = n[28];
					b[29] = n[29];
					b[30] = n[30];
					b[31] = n[31];
					
					// Twiddles for Stage 5
					w[0] = w_0_64;
					w[1] = w_2_64;
					w[2] = w_4_64;
					w[3] = w_6_64;
					w[4] = w_8_64;
					w[5] = w_10_64;
					w[6] = w_12_64;
					w[7] = w_14_64;
					w[8] = w_16_64;
					w[9] = w_18_64;
					w[10] = w_20_64;
					w[11] = w_22_64;
					w[12] = w_24_64;
					w[13] = w_26_64;
					w[14] = w_28_64;
					w[15] = w_30_64;
					w[16] = w_0_64;
					w[17] = w_2_64;
					w[18] = w_4_64;
					w[19] = w_6_64;
					w[20] = w_8_64;
					w[21] = w_10_64;
					w[22] = w_12_64;
					w[23] = w_14_64;
					w[24] = w_16_64;
					w[25] = w_18_64;
					w[26] = w_20_64;
					w[27] = w_22_64;
					w[28] = w_24_64;
					w[29] = w_26_64;
					w[30] = w_28_64;
					w[31] = w_30_64;
				end
			STAGE_6:
				begin
					for (int i = 0; i < POINTS; i++) begin
						freq_out[i] = 0;
					end
					
					// Set butterfly inputs for stage 6
					a[0] = p[0];
					a[1] = p[1];
					a[2] = p[2];
					a[3] = p[3];
					a[4] = p[4];
					a[5] = p[5];
					a[6] = p[6];
					a[7] = p[7];
					a[8] = p[8];
					a[9] = p[9];
					a[10] = p[10];
					a[11] = p[11];
					a[12] = p[12];
					a[13] = p[13];
					a[14] = p[14];
					a[15] = p[15];
					a[16] = p[0];
					a[17] = n[1];
					a[18] = n[2];
					a[19] = n[3];
					a[20] = n[4];
					a[21] = n[5];
					a[22] = n[6];
					a[23] = n[7];
					a[24] = n[8];
					a[25] = n[9];
					a[26] = n[10];
					a[27] = n[11];
					a[28] = n[12];
					a[29] = n[13];
					a[30] = n[14];
					a[31] = n[15];
					
					b[0] = p[16];
					b[1] = p[17];
					b[2] = p[18];
					b[3] = p[19];
					b[4] = p[20];
					b[5] = p[21];
					b[6] = p[22];
					b[7] = p[23];
					b[8] = p[24];
					b[9] = p[25];
					b[10] = p[26];
					b[11] = p[27];
					b[12] = p[28];
					b[13] = p[29];
					b[14] = p[30];
					b[15] = p[31];
					b[16] = n[16];
					b[17] = n[17];
					b[18] = n[18];
					b[19] = n[19];
					b[20] = n[20];
					b[21] = n[21];
					b[22] = n[22];
					b[23] = n[23];
					b[24] = n[24];
					b[25] = n[25];
					b[26] = n[26];
					b[27] = n[27];
					b[28] = n[28];
					b[29] = n[29];
					b[30] = n[30];
					b[31] = n[31];
					
					// Twiddles for Stage 6
					w[0] = w_0_64;
					w[1] = w_1_64;
					w[2] = w_2_64;
					w[3] = w_3_64;
					w[4] = w_4_64;
					w[5] = w_5_64;
					w[6] = w_6_64;
					w[7] = w_7_64;
					w[8] = w_8_64;
					w[9] = w_9_64;
					w[10] = w_10_64;
					w[11] = w_11_64;
					w[12] = w_12_64;
					w[13] = w_13_64;
					w[14] = w_14_64;
					w[15] = w_15_64;
					w[16] = w_16_64;
					w[17] = w_17_64;
					w[18] = w_18_64;
					w[19] = w_19_64;
					w[20] = w_20_64;
					w[21] = w_21_64;
					w[22] = w_22_64;
					w[23] = w_23_64;
					w[24] = w_24_64;
					w[25] = w_25_64;
					w[26] = w_26_64;
					w[27] = w_27_64;
					w[28] = w_28_64;
					w[29] = w_29_64;
					w[30] = w_30_64;
					w[31] = w_31_64;
				end
			DONE:
				begin
					// Set final output values
					for (int i = 0; i < POINTS/2; i++) begin
						freq_out[i] = p[i];
					end
					for (int i = POINTS/2; i < POINTS; i++) begin
						freq_out[i] = n[i-POINTS/2];
					end
//					
//					freq_out[0] = p[0];
//					freq_out[1] = p[1];
//					freq_out[2] = p[2];
//					freq_out[3] = p[3];
//					freq_out[4] = p[4];
//					freq_out[5] = p[5];
//					freq_out[6] = p[6];
//					freq_out[7] = p[7];
//					freq_out[8] = p[8];
//					freq_out[9] = p[9];
//					freq_out[10] = p[10];
//					freq_out[11] = p[11];
//					freq_out[12] = p[12];
//					freq_out[13] = p[13];
//					freq_out[14] = p[14];
//					freq_out[15] = p[15];
//					freq_out[16] = p[16];
//					freq_out[17] = p[17];
//					freq_out[18] = p[18];
//					freq_out[19] = p[19];
//					freq_out[20] = p[20];
//					freq_out[21] = p[21];
//					freq_out[22] = p[22];
//					freq_out[23] = p[23];
//					freq_out[24] = p[24];
//					freq_out[25] = p[25];
//					freq_out[26] = p[26];
//					freq_out[27] = p[27];
//					freq_out[28] = p[28];
//					freq_out[29] = p[29];
//					freq_out[30] = p[30];
//					freq_out[31] = p[31];
//					freq_out[32] = n[0];
//					freq_out[33] = n[1];
//					freq_out[34] = n[2];
//					freq_out[35] = n[3];
//					freq_out[36] = n[4];
//					freq_out[37] = n[5];
//					freq_out[38] = n[6];
//					freq_out[39] = n[7];
//					freq_out[40] = n[8];
//					freq_out[41] = n[9];
//					freq_out[42] = n[10];
//					freq_out[43] = n[11];
//					freq_out[44] = n[12];
//					freq_out[45] = n[13];
//					freq_out[46] = n[14];
//					freq_out[47] = n[15];
//					freq_out[48] = n[16];
//					freq_out[49] = n[17];
//					freq_out[50] = n[18];
//					freq_out[51] = n[19];
//					freq_out[52] = n[20];
//					freq_out[53] = n[21];
//					freq_out[54] = n[22];
//					freq_out[55] = n[23];
//					freq_out[56] = n[24];
//					freq_out[57] = n[25];
//					freq_out[58] = n[26];
//					freq_out[59] = n[27];
//					freq_out[60] = n[28];
//					freq_out[61] = n[29];
//					freq_out[62] = n[30];
//					freq_out[63] = n[31];
					
					// Set butterfly inputs to last stage
					a[0] = last_p[0];
					a[1] = last_p[1];
					a[2] = last_p[2];
					a[3] = last_p[3];
					a[4] = last_p[4];
					a[5] = last_p[5];
					a[6] = last_p[6];
					a[7] = last_p[7];
					a[8] = last_p[8];
					a[9] = last_p[9];
					a[10] = last_p[10];
					a[11] = last_p[11];
					a[12] = last_p[12];
					a[13] = last_p[13];
					a[14] = last_p[14];
					a[15] = last_p[15];
					a[16] = last_p[0];
					a[17] = last_n[1];
					a[18] = last_n[2];
					a[19] = last_n[3];
					a[20] = last_n[4];
					a[21] = last_n[5];
					a[22] = last_n[6];
					a[23] = last_n[7];
					a[24] = last_n[8];
					a[25] = last_n[9];
					a[26] = last_n[10];
					a[27] = last_n[11];
					a[28] = last_n[12];
					a[29] = last_n[13];
					a[30] = last_n[14];
					a[31] = last_n[15];
					
					b[0] = last_p[16];
					b[1] = last_p[17];
					b[2] = last_p[18];
					b[3] = last_p[19];
					b[4] = last_p[20];
					b[5] = last_p[21];
					b[6] = last_p[22];
					b[7] = last_p[23];
					b[8] = last_p[24];
					b[9] = last_p[25];
					b[10] = last_p[26];
					b[11] = last_p[27];
					b[12] = last_p[28];
					b[13] = last_p[29];
					b[14] = last_p[30];
					b[15] = last_p[31];
					b[16] = last_n[16];
					b[17] = last_n[17];
					b[18] = last_n[18];
					b[19] = last_n[19];
					b[20] = last_n[20];
					b[21] = last_n[21];
					b[22] = last_n[22];
					b[23] = last_n[23];
					b[24] = last_n[24];
					b[25] = last_n[25];
					b[26] = last_n[26];
					b[27] = last_n[27];
					b[28] = last_n[28];
					b[29] = last_n[29];
					b[30] = last_n[30];
					b[31] = last_n[31];
					
					w[0] = w_0_64;
					w[1] = w_1_64;
					w[2] = w_2_64;
					w[3] = w_3_64;
					w[4] = w_4_64;
					w[5] = w_5_64;
					w[6] = w_6_64;
					w[7] = w_7_64;
					w[8] = w_8_64;
					w[9] = w_9_64;
					w[10] = w_10_64;
					w[11] = w_11_64;
					w[12] = w_12_64;
					w[13] = w_13_64;
					w[14] = w_14_64;
					w[15] = w_15_64;
					w[16] = w_16_64;
					w[17] = w_17_64;
					w[18] = w_18_64;
					w[19] = w_19_64;
					w[20] = w_20_64;
					w[21] = w_21_64;
					w[22] = w_22_64;
					w[23] = w_23_64;
					w[24] = w_24_64;
					w[25] = w_25_64;
					w[26] = w_26_64;
					w[27] = w_27_64;
					w[28] = w_28_64;
					w[29] = w_29_64;
					w[30] = w_30_64;
					w[31] = w_31_64;
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
					next_state = STAGE_6;
				end
			STAGE_6:
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
		if (state == STAGE_6) begin
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