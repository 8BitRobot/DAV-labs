module vga_4point_test(clock, ADCclock, rst, leds, hsync, vsync, red, green, blue/*, pll*/);
	input clock;
	input ADCclock;
	input rst;
	
	wire clock, ADCclock, rst;
	
	output hsync;		//horizontal sync out
	output vsync;			//vertical sync out
	output reg [3:0] red;	//red vga output
	output reg [3:0] green; //green vga output
	output reg [3:0] blue;	//blue vga output
	
	//output reg pll;
	
	output [9:0] leds;	//leds for mic testing
	
	reg [11:0] mic;		//mic is pin A0
	reg [11:0] samples [3:0];
	reg MICstart;
	wire MICdone;
	integer i;
	wire VGAdone;
	
	reg clock4; // 4 kHz
	
	/* for FFT */
	reg FFTstart;
	reg [31:0] in0;
	reg [31:0] in1;
	reg [31:0] in2;
	reg [31:0] in3;
	reg [31:0] out0;
	reg [31:0] out1;
	reg [31:0] out2;
	reg [31:0] out3;
	wire FFTdone;
	
	reg [15:0] amp0;
	reg [15:0] amp1;
	reg [15:0] amp2;
	reg [15:0] amp3;
	
	reg [15:0] namp0;
	reg [15:0] namp1;
	reg [15:0] namp2;
	reg [15:0] namp3;
	/* for FFT */
	
	reg [9:0] data [3:0];
	
	always_comb begin
	
		leds[0] = (mic > 400);
		leds[1] = (mic > 800);
		leds[2] = (mic > 1200);
		leds[3] = (mic > 1600);
		leds[4] = (mic > 2000);
		leds[5] = (mic > 2400);
		leds[6] = (mic > 2800);
		leds[7] = (mic > 3200);
		leds[8] = (mic > 3600);
		leds[9] = (mic > 4000);
	
	end
	
	reg newClock = 0;
	reg [1:0] counter;
	 
	
	always@(posedge clock) begin
        newClock = ~newClock;
	end
	
	MyPLL gamer2(.areset(~rst), .inclk0(clock), .c0(clock4));
	
	vga_4point U1T(.vgaclk(newClock), .rst(~rst), .data(data), .hsync(hsync), .vsync(vsync), .red(red), .green(green), .blue(blue), .done(VGAdone));
	
	BasedADC U2T(.CLOCK(ADCclock), .CH0(mic), .RESET(~rst));
	
	fft_4point_32bit U3T(.clk(clock), .reset(~rst), .start(FFTstart), .in0(in0), .in1(in1), .in2(in2), .in3(in3),
	.out0(out0), .out1(out1), .out2(out2), .out3(out3), .done(FFTdone));
	
	mic_4sample U4T(.start(MICstart), .clk(clock4), .mic(mic), .samples(samples), .done(MICdone));
	
	// sampling to FFT state machine
	/*
	pseudocode:
		stage 1: bring 'start' high. wait until 'done' is high, then go to next state
		stage 2: feed samples into fft. wait until 'done' is high, then go to next state
		stage 3: feed new data into VGA, return to first state
	*/
	parameter RESET = 2'b00;
   parameter MICSTART = 2'b01;
   parameter FFTSTART = 2'b10;
   parameter DONE = 2'b11;
	
	reg [1:0] state = MICSTART;
	reg [1:0] nextstate;
	 
	always@(posedge clock) begin
        state <= nextstate;
		  if(~rst) begin
				state <= RESET;
		  end
		  
		  if (state == MICSTART && nextstate == FFTSTART) begin
				// assign samples to FFT
					in0 <= {{4{samples[0][11]}}, samples[0], 16'b0}; //{16'd100, 16'd0};
					in1 <= {{4{samples[1][11]}}, samples[1], 16'b0}; //{16'd200, 16'd0};
					in2 <= {{4{samples[2][11]}}, samples[2], 16'b0}; //{16'd300, 16'd0};
					in3 <= {{4{samples[3][11]}}, samples[3], 16'b0}; //{16'd400, 16'd0};
				//
		  end
		  
		  if (state == FFTSTART && nextstate == DONE) begin
				// take real parts of fft 
			
					amp0 <= out0[31:16];
					amp1 <= out1[31:16];
					amp2 <= out2[31:16];
					amp3 <= out3[31:16];
				// 
		  end
		  
		  if (state == DONE) begin
				// input data to VGA
					/*
					if (amp0 > 15'd10)
						data[0] <= 10'd480;
					else
						data[0] <= amp0/200;//amp0[9:0]/3;//
						
					if (amp1 > 0)
						data[1] <= 10'd480;
					else
						data[1] <= amp1/200;//amp1[9:0]/3;//

					
					if (amp0[15] == 1)
						data[0] <= (~amp0+1)/70;
					else
						data[0] <= amp0/70;//
						
					if (amp1[15] == 1)
						data[1] <= (~amp1+1)/70;
					else
						data[1] <= amp1/70;//
					
					if (amp2[15] == 1)
						data[2] <= (~amp2+1)/70;
					else
						data[2] <= amp2/70;//
				
					if (amp3[15] == 1)
						data[3] <= (~amp3+1)/70;
					else
						data[3] <= amp3/70;//
					*/
					
					if (amp0[15] == 1) begin
						namp0 <= ~amp0+1;
						data[0] <= namp0[14:6];
						end
					else
						data[0] <= amp0[14:6];//
						
					if (amp1[15] == 1) begin
						namp1 <= ~amp1+1;
						data[1] <= namp1[14:6];
						end
					else
						data[1] <= amp1[14:6];//
					
					if (amp2[15] == 1) begin
						namp2 <= ~amp2+1;
						data[2] <= namp2[14:6];
						end
					else
						data[2] <= amp2[14:6];
				
					if (amp3[15] == 1) begin
						namp3 <= ~amp3+1;
						data[3] <= namp3[14:6];
						end
					else
						data[3] <= amp3[14:6];//

		  end
		  
    end
	
    always_comb begin
        case (state)
            RESET: begin
               
					MICstart = 0;
					FFTstart = 0;
					
					nextstate = MICSTART;
					
					end
					
            MICSTART: begin
					
					MICstart = 1; // start mic sampling
					FFTstart = 0;
					
					if (MICdone)
						nextstate = FFTSTART;
					else
						nextstate = MICSTART;
					
					end

            FFTSTART: begin
					
					MICstart = 0;
					FFTstart = 1; // start fft
					
					if (FFTdone) begin
						nextstate = DONE;
						FFTstart = 0;
					end
					else
						nextstate = FFTSTART;
						
					end
					
            DONE: begin
               
					MICstart = 0;
					FFTstart = 0;
					
					if (VGAdone)
						nextstate = MICSTART;
					else
						nextstate = DONE;
					
					end
					
        endcase
	end

endmodule