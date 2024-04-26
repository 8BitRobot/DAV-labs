module vga_test(clock, ADCclock, rst, leds, hsync, vsync, red, green, blue);
	input clock;
	input ADCclock;
	input rst;
	
	wire clock, ADCclock, rst;
	
	output hsync;		//horizontal sync out
	output vsync;			//vertical sync out
	
	output reg [3:0] red;	//red vga output
	output reg [3:0] green; //green vga output
	output reg [3:0] blue;	//blue vga output
	
	output [9:0] leds;	//leds for mic testing
	
	reg [11:0] mic;		//mic is pin A0
	reg [11:0] samples [15:0];
	reg MICstart;
	wire MICdone;
	integer i;
	wire VGAdone;
	
	reg clock4; // 4 kHz
	
	/* for FFT */
	reg FFTstart;
	reg [31:0] in [15:0];
	reg [31:0] out [15:0];
	wire FFTdone;
	
	reg [15:0] amp [15:0];
	
	reg [15:0] namp [15:0];
	
	/* for FFT */
	
	reg [9:0] data [15:0];
	
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
	
	MyPLL gamer2(.areset(0), .inclk0(clock), .c0(clock4));
	
	vga U1T(.vgaclk(newClock), .rst(0), .data(data), .hsync(hsync), .vsync(vsync), .red(red), .green(green), .blue(blue), .done(VGAdone));
	
	BasedADC U2T(.CLOCK(ADCclock), .CH0(mic), .RESET(0));
	
	fft_16point_32bit U3T(.clk(clock), .reset(0), .start(FFTstart), .in(in), .out(out), .done(FFTdone));
	
	mic_16sample U4T(.start(MICstart), .clk(clock4), .mic(mic), .samples(samples), .done(MICdone));
	
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
				for(integer index = 0; index < 16; index = index + 1) begin
				
					in[index] <= {{4{samples[index][11]}}, samples[index], 16'b0}; 
					
				end
				//
		  end
		  
		  if (state == FFTSTART && nextstate == DONE) begin
				// take real parts of fft 
				for(integer index = 0; index < 16; index = index + 1) begin
				
					amp[index] <= out[index][31:16]; 
					
					end
				// 
		  end
		  
		  if (state == DONE) begin
				// input data to VGA
			
					for(integer index = 0; index < 16; index = index + 1) begin
						
						if (amp[index][15] == 1) begin
							namp[index] <= ~amp[index]+1;
							data[index] <= namp[index][14:6];
						end
						else
							data[index] <= amp[index][14:6];//
					
					end
		
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