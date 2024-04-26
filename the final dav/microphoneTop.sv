module microphoneTop(
    input clk,
    input adc_clk,
    input rst,
    output [9:0] leds,
    output [47:0] segs
    // output hsync,
    // output vsync
    // output [3:0] red,
    // output [3:0] green,
    // output [3:0] blue
);
    wire [11:0] adc_out;

    micadc dasheng(.CLOCK(adc_clk), .CH0(adc_out), .RESET(!rst));

    assign leds = (adc_out[11:2] / 10) * 100 - 400;
	 
	sevenSegDisplay(frequencies[1][35:18], segs[7:0], segs[15:8], segs[23:16], segs[31:24], segs[39:32], segs[47:40]);

    wire div_clk;
    reg vga_clk = 0;
    
    clockDivider cd(clk, 40000, 0, div_clk);

    logic [1:0] start_sr = 2'b00;
    wire start = start_sr == 2'b01;

    always @(posedge clk) begin
        start_sr <= { start_sr[0], div_clk };
        vga_clk <= ~vga_clk;
    end

    logic [35:0] samples [0:15];

    always @(posedge div_clk) begin
        // adding 1 more sample to the end (with sign-extension)
        for (integer i = 0; i < 15; i = i + 1) begin
            samples[i] <= samples[i + 1];
        end
        samples[15] <= { {6{adc_out[11]}}, adc_out, {18{1'b0}} };
    end

    wire [35:0] frequencies [0:15];
    wire done;
    
    fft_16point_36bit f(clk, rst, start, samples, frequencies, done);

    wire [2:0] input_red;
    wire [2:0] input_green;
    wire [1:0] input_blue;
    wire [9:0] hc_out, vc_out;

    // graphics_controller gc();

    // vga disp(
    //     vga_clk,
	// 	input_red,
	// 	input_green,
	// 	input_blue,
	// 	rst,
	// 	hc_out,
	// 	vc_out,
	// 	hsync,
	// 	vsync,
	// 	red,
	// 	green,
	// 	blue
    // );

endmodule