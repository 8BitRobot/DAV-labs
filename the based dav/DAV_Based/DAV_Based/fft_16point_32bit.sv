module fft_16point_32bit (clk, reset, start, in, out, done);
    parameter BITWIDTH = 6'd32;
    
    input clk, reset, start;
    input signed [BITWIDTH-1:0] in [15:0];
    output reg signed [BITWIDTH-1:0] out [15:0] ;
    output reg done;
	 
	 reg [15:0] DEBUG_REAL [15:0];
	 reg [15:0] DEBUG_IMAG [15:0];

    parameter RESET = 3'b000;
    parameter POINT_2 = 3'b001;
    parameter POINT_4 = 3'b010;
    parameter POINT_8 = 3'b011;
    parameter POINT_16 = 3'b100;
    parameter DONE = 3'b101;

    reg [2:0] state = RESET;
	reg [2:0] nextstate = RESET;
	 
    reg [BITWIDTH-1:0] butterfly1In_A, butterfly1In_B, butterfly1Out_Add, butterfly1Out_Subtract;
    reg [BITWIDTH-1:0] butterfly2In_A, butterfly2In_B, butterfly2Out_Add, butterfly2Out_Subtract;
    reg [BITWIDTH-1:0] butterfly3In_A, butterfly3In_B, butterfly3Out_Add, butterfly3Out_Subtract;
    reg [BITWIDTH-1:0] butterfly4In_A, butterfly4In_B, butterfly4Out_Add, butterfly4Out_Subtract;   
    reg [BITWIDTH-1:0] butterfly5In_A, butterfly5In_B, butterfly5Out_Add, butterfly5Out_Subtract;
    reg [BITWIDTH-1:0] butterfly6In_A, butterfly6In_B, butterfly6Out_Add, butterfly6Out_Subtract;
    reg [BITWIDTH-1:0] butterfly7In_A, butterfly7In_B, butterfly7Out_Add, butterfly7Out_Subtract;
    reg [BITWIDTH-1:0] butterfly8In_A, butterfly8In_B, butterfly8Out_Add, butterfly8Out_Subtract; 
	 
	 always_comb begin
		DEBUG_REAL[0] 	= butterfly1In_A[31:16];
		DEBUG_REAL[1] 	= butterfly1In_B[31:16];
		DEBUG_REAL[2] 	= butterfly2In_A[31:16];
		DEBUG_REAL[3] 	= butterfly2In_B[31:16];
		DEBUG_REAL[4] 	= butterfly3In_A[31:16];
		DEBUG_REAL[5] 	= butterfly3In_B[31:16];
		DEBUG_REAL[6] 	= butterfly4In_A[31:16];
		DEBUG_REAL[7] 	= butterfly4In_B[31:16];
		DEBUG_REAL[8] 	= butterfly5In_A[31:16];
		DEBUG_REAL[9] 	= butterfly5In_B[31:16];
		DEBUG_REAL[10] = butterfly6In_A[31:16];
		DEBUG_REAL[11] = butterfly6In_B[31:16];
		DEBUG_REAL[12] = butterfly7In_A[31:16];
		DEBUG_REAL[13] = butterfly7In_B[31:16];
		DEBUG_REAL[14] = butterfly8In_A[31:16];
		DEBUG_REAL[15] = butterfly8In_B[31:16];
		
		DEBUG_IMAG[0] 	= butterfly1In_A[15:0];
		DEBUG_IMAG[1] 	= butterfly1In_B[15:0];
		DEBUG_IMAG[2] 	= butterfly2In_A[15:0];
		DEBUG_IMAG[3] 	= butterfly2In_B[15:0];
		DEBUG_IMAG[4] 	= butterfly3In_A[15:0];
		DEBUG_IMAG[5] 	= butterfly3In_B[15:0];
		DEBUG_IMAG[6] 	= butterfly4In_A[15:0];
		DEBUG_IMAG[7] 	= butterfly4In_B[15:0];
		DEBUG_IMAG[8] 	= butterfly5In_A[15:0];
		DEBUG_IMAG[9] 	= butterfly5In_B[15:0];
		DEBUG_IMAG[10] = butterfly6In_A[15:0];
		DEBUG_IMAG[11] = butterfly6In_B[15:0];
		DEBUG_IMAG[12] = butterfly7In_A[15:0];
		DEBUG_IMAG[13] = butterfly7In_B[15:0];
		DEBUG_IMAG[14] = butterfly8In_A[15:0];
		DEBUG_IMAG[15] = butterfly8In_B[15:0];
	 end

    reg [BITWIDTH-1:0] butterfly1Twiddle, butterfly2Twiddle, butterfly3Twiddle, butterfly4Twiddle, butterfly5Twiddle, butterfly6Twiddle, butterfly7Twiddle, butterfly8Twiddle;

    // insert parameters for twiddle factors, which is right shifted 
    reg [BITWIDTH-1:0] twiddle0_16 = 32'b01111111111111110000000000000000;   // W0_2
    reg [BITWIDTH-1:0] twiddle1_16 = 32'b01110110010000010011000011111011;   // W1_4
    reg [BITWIDTH-1:0] twiddle2_16 = 32'b01011010100000100101101010000010;   // W1_8
    reg [BITWIDTH-1:0] twiddle3_16 = 32'b00110000111110110111011001000001;   // W3_8
    reg [BITWIDTH-1:0] twiddle4_16 = 32'b00000000000000000111111111111111;   
    reg [BITWIDTH-1:0] twiddle5_16 = 32'b11001111000001010111011001000001;
    reg [BITWIDTH-1:0] twiddle6_16 = 32'b10100101011111100101101010000010;
    reg [BITWIDTH-1:0] twiddle7_16 = 32'b10001001101111110011000011111011;
	 
    always@(posedge clk) begin
        state <= nextstate;
        case (state)
            RESET: begin
                butterfly1Twiddle <= 32'b0;
                butterfly2Twiddle <= 32'b0;
                butterfly3Twiddle <= 32'b0;
                butterfly4Twiddle <= 32'b0;
                butterfly5Twiddle <= 32'b0;
                butterfly6Twiddle <= 32'b0;
                butterfly7Twiddle <= 32'b0;
                butterfly8Twiddle <= 32'b0;
            end
            POINT_2: begin
                butterfly1In_A <= in[0];
                butterfly1In_B <= in[8];

                butterfly2In_A <= in[4];
                butterfly2In_B <= in[12];

                butterfly3In_A <= in[2];
                butterfly3In_B <= in[10];

                butterfly4In_A <= in[6];
                butterfly4In_B <= in[14];

                butterfly5In_A <= in[1];
                butterfly5In_B <= in[9];

                butterfly6In_A <= in[5];
                butterfly6In_B <= in[13];

                butterfly7In_A <= in[3];
                butterfly7In_B <= in[11];

                butterfly8In_A <= in[7];
                butterfly8In_B <= in[15];

                butterfly1Twiddle <= twiddle0_16;
                butterfly2Twiddle <= twiddle0_16;
                butterfly3Twiddle <= twiddle0_16;
                butterfly4Twiddle <= twiddle0_16;
                butterfly5Twiddle <= twiddle0_16;
                butterfly6Twiddle <= twiddle0_16;
                butterfly7Twiddle <= twiddle0_16;
                butterfly8Twiddle <= twiddle0_16;
            end
            POINT_4: begin
                butterfly1In_A <= butterfly1Out_Add;
                butterfly1In_B <= butterfly2Out_Add;
                butterfly2In_A <= butterfly1Out_Subtract;
                butterfly2In_B <= butterfly2Out_Subtract;

                butterfly3In_A <= butterfly3Out_Add;
                butterfly3In_B <= butterfly4Out_Add;
                butterfly4In_A <= butterfly3Out_Subtract;
                butterfly4In_B <= butterfly4Out_Subtract;

                butterfly5In_A <= butterfly5Out_Add;
                butterfly5In_B <= butterfly6Out_Add;
                butterfly6In_A <= butterfly5Out_Subtract;
                butterfly6In_B <= butterfly6Out_Subtract;

                butterfly7In_A <= butterfly7Out_Add;
                butterfly7In_B <= butterfly8Out_Add;
                butterfly8In_A <= butterfly7Out_Subtract;
                butterfly8In_B <= butterfly8Out_Subtract;

                butterfly1Twiddle <= twiddle0_16;
                butterfly2Twiddle <= twiddle4_16;
                butterfly3Twiddle <= twiddle0_16;
                butterfly4Twiddle <= twiddle4_16;
                butterfly5Twiddle <= twiddle0_16; 
                butterfly6Twiddle <= twiddle4_16;
                butterfly7Twiddle <= twiddle0_16;
                butterfly8Twiddle <= twiddle4_16;
            end
            POINT_8: begin
                butterfly1In_A <= butterfly1Out_Add;
                butterfly1In_B <= butterfly3Out_Add;
                butterfly2In_A <= butterfly2Out_Add;
                butterfly2In_B <= butterfly4Out_Add;
					 butterfly3In_A <= butterfly1Out_Subtract;
                butterfly3In_B <= butterfly3Out_Subtract;
                butterfly4In_A <= butterfly2Out_Subtract;
                butterfly4In_B <= butterfly4Out_Subtract;
                
                butterfly5In_A <= butterfly5Out_Add;
                butterfly5In_B <= butterfly7Out_Add;
					 butterfly6In_A <= butterfly6Out_Add;
                butterfly6In_B <= butterfly8Out_Add;
                butterfly7In_A <= butterfly5Out_Subtract;
                butterfly7In_B <= butterfly7Out_Subtract;
                butterfly8In_A <= butterfly6Out_Subtract;
                butterfly8In_B <= butterfly8Out_Subtract;

                butterfly1Twiddle <= twiddle0_16;
                butterfly2Twiddle <= twiddle2_16;
                butterfly3Twiddle <= twiddle4_16;
                butterfly4Twiddle <= twiddle6_16;
                butterfly5Twiddle <= twiddle0_16; 
                butterfly6Twiddle <= twiddle2_16;
                butterfly7Twiddle <= twiddle4_16;
                butterfly8Twiddle <= twiddle6_16;
            end
            POINT_16: begin
                butterfly1In_A <= butterfly1Out_Add;
                butterfly1In_B <= butterfly5Out_Add;
					 butterfly2In_A <= butterfly2Out_Add;
                butterfly2In_B <= butterfly6Out_Add;
					 butterfly3In_A <= butterfly3Out_Add;
                butterfly3In_B <= butterfly7Out_Add;
					 butterfly4In_A <= butterfly4Out_Add;
                butterfly4In_B <= butterfly8Out_Add;
					 
                butterfly5In_A <= butterfly1Out_Subtract;
                butterfly5In_B <= butterfly5Out_Subtract;
                butterfly6In_A <= butterfly2Out_Subtract;
                butterfly6In_B <= butterfly6Out_Subtract;
                butterfly7In_A <= butterfly3Out_Subtract;
                butterfly7In_B <= butterfly7Out_Subtract;
                butterfly8In_A <= butterfly4Out_Subtract;
                butterfly8In_B <= butterfly8Out_Subtract;

                butterfly1Twiddle <= twiddle0_16;
                butterfly2Twiddle <= twiddle1_16;
                butterfly3Twiddle <= twiddle2_16;
                butterfly4Twiddle <= twiddle3_16;
                butterfly5Twiddle <= twiddle4_16; 
                butterfly6Twiddle <= twiddle5_16;
                butterfly7Twiddle <= twiddle6_16;
                butterfly8Twiddle <= twiddle7_16;
            end
            DONE: begin
                out[0] <= butterfly1Out_Add;
                out[1] <= butterfly1Out_Subtract;
                out[2] <= butterfly2Out_Add;
                out[3] <= butterfly2Out_Subtract;
                out[4] <= butterfly3Out_Add;
                out[5] <= butterfly3Out_Subtract;
                out[6] <= butterfly4Out_Add;
                out[7] <= butterfly4Out_Subtract;
                out[8] <= butterfly5Out_Add;
                out[9] <= butterfly5Out_Subtract;
                out[10] <= butterfly6Out_Add;
                out[11] <= butterfly6Out_Subtract;
                out[12] <= butterfly7Out_Add;
                out[13] <= butterfly7Out_Subtract;
                out[14] <= butterfly8Out_Add;
                out[15] <= butterfly8Out_Subtract;
            end
        endcase
    end

    always_comb begin
        case (state)
            RESET: begin
                if (start)
                    nextstate = POINT_2;
                else 
                    nextstate = RESET;
                done = 0;
            end
            POINT_2: begin
                nextstate = POINT_4;
                done = 0;
            end
            POINT_4: begin
                nextstate = POINT_8;
                done = 0;
            end
            POINT_8: begin
                nextstate = POINT_16;
                done = 0;
            end
            POINT_16: begin
                nextstate = DONE;
                done = 0;
            end
            DONE: begin
                nextstate = RESET;
                done = 1;
            end

        endcase
    end

    butterflyUnit #(.WIDTH(BITWIDTH)) butterflyUnit1(butterfly1In_A, butterfly1In_B, butterfly1Twiddle, butterfly1Out_Add, butterfly1Out_Subtract);
	butterflyUnit #(.WIDTH(BITWIDTH)) butterflyUnit2(butterfly2In_A, butterfly2In_B, butterfly2Twiddle, butterfly2Out_Add, butterfly2Out_Subtract);
    butterflyUnit #(.WIDTH(BITWIDTH)) butterflyUnit3(butterfly3In_A, butterfly3In_B, butterfly3Twiddle, butterfly3Out_Add, butterfly3Out_Subtract);
	butterflyUnit #(.WIDTH(BITWIDTH)) butterflyUnit4(butterfly4In_A, butterfly4In_B, butterfly4Twiddle, butterfly4Out_Add, butterfly4Out_Subtract);
    butterflyUnit #(.WIDTH(BITWIDTH)) butterflyUnit5(butterfly5In_A, butterfly5In_B, butterfly5Twiddle, butterfly5Out_Add, butterfly5Out_Subtract);
	butterflyUnit #(.WIDTH(BITWIDTH)) butterflyUnit6(butterfly6In_A, butterfly6In_B, butterfly6Twiddle, butterfly6Out_Add, butterfly6Out_Subtract);
    butterflyUnit #(.WIDTH(BITWIDTH)) butterflyUnit7(butterfly7In_A, butterfly7In_B, butterfly7Twiddle, butterfly7Out_Add, butterfly7Out_Subtract);
	butterflyUnit #(.WIDTH(BITWIDTH)) butterflyUnit8(butterfly8In_A, butterfly8In_B, butterfly8Twiddle, butterfly8Out_Add, butterfly8Out_Subtract);

endmodule