module Final_DAV_64(board_clock, ADC_clock, reset, hsync, vsync, red, green, blue, leds);

	input wire board_clock; // 50MHz clock
	input wire reset; // Reset button
	input wire ADC_clock; // ADC 10MHz clock
	output wire [9:0] leds; // LEDs 
	
	// VGA pins
	output reg hsync; 
	output reg vsync;
	output reg [3:0] red;
	output reg [3:0] green;
	output reg [3:0] blue;
	
	parameter POINTS = 64;
	
	wire[11:0] CH0, CH1, CH2, CH3, CH4, CH5, CH6, CH7; // ADC wires
	//assign CH0 = 3234; // FOR TESTING ONLY
	
	wire vga_comm_clk; // VGA clock
	wire sampling_clock; // Sampling clock
	wire [11:0] time_samples [POINTS-1:0]; // Output from ADC, input into reformatter
	wire [35:0] fft_in [POINTS-1:0]; // Output of reformatter (sign extends to 18 bits, add imaginary part), input to FFT
	wire [35:0] fft_out [POINTS-1:0]; // Output of FFT
	reg [35:0] freq_points [POINTS-1:0]; // Samples FFT output
	wire [8:0] vga_fft [POINTS-1:0]; // Output of second reformatter
	
	// Instantiate ADC
	
	wire sclk;
	wire cs_n;
	wire dout;
	assign dout = 1;
	wire din;
	digital_mic_adc ADC_MOD(ADC_clock, CH0, CH1, CH2, CH3, CH4, CH5, CH6, CH7, ~reset);
	
	// Instantiate sampler
	wire sampling_done;
	sampling_buffer_32 #(.POINTS(POINTS)) SAMPLER_BUFFER(sampling_clock, vsync, CH0, time_samples, sampling_done);
	
	// Instantiate sign extension module
	sign_extension_32 #(.POINTS(POINTS)) TIME_REFORMAT(time_samples, fft_in);
	
	// Instantiate FFT module
	wire fft_done;
	fft_64point_36bit FFT_PROC(sampling_clock, reset, sampling_done, fft_in, fft_out, fft_done);
	
	// Grab the FFT output at a vsync edge only (prevents screen tearing)
	always @ (negedge vsync) begin
		freq_points <= fft_out;
	end
	
	// Instantiate FFT output reformatter
	make_real_32 #(.POINTS(POINTS)) FREQ_SCALAR(freq_points, vga_fft);
	
	// Insantiate VGA module
	vga_64 VGA_MOD(vga_comm_clk, reset, hsync, vsync, red, green, blue, vga_fft);
	
	// Instantiate clock divider for sampling clock
	clockDivider #(.RATE(8000), .INPUT(25200000)) SAMPLE_CLK(vga_comm_clk, sampling_clock, reset); 
	
	// Instantiate VGA PLL 25.2MHz
	vga_plls VGA_CLK(board_clock, vga_comm_clk);
	
	// On-board outputs
	assign leds = vga_fft[0];
endmodule