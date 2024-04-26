module vga(
	input vgaclk,
	// 8-bit color allocates 3 bits for red, 3 for green, 2 for blue
	input [2:0] input_red,
	input [2:0] input_green,
	input [1:0] input_blue,
	input rst,
	output [9:0] hc_out,
	output [9:0] vc_out,
	output reg hsync,
	output reg vsync,
	output reg [3:0] red,
	output reg [3:0] green,
	output reg [3:0] blue
);
	
	
	/* TODO(1): Video protocol constants
    * You can find these described in the VGA specification for 640x480
	 */
	localparam HPIXELS = 640;    // number of visible pixels per horizontal line
	localparam HFP = 16; 	      // length (in pixels) of horizontal front porch
	localparam HSPULSE = 96; 	// length (in pixels) of hsync pulse
	localparam HBP = 48; 	      // length (in pixels) of horizontal back porch
	
	localparam VPIXELS = 480;    // number of visible horizontal lines per frame
	localparam VFP = 10; 	      // length (in pixels) of vertical front porch
	localparam VSPULSE = 2;    // length (in pixels) of vsync pulse
	localparam VBP = 33; 		   // length (in pixels) of vertical back porch
	
	/* no need to mess with this -- this is a basic sanity check that will
	 * cause the compiler to yell at you if the values above don't add up
	 */
	initial begin
		if (HPIXELS + HFP + HSPULSE + HBP != 800 || VPIXELS + VFP + VSPULSE + VBP != 525) begin
			$error("Expected horizontal pixels to add up to 800 and vertical pixels to add up to 525");
		end
	end
	
	/* these registers are for storing the horizontal & vertical counters
	 * we're outputting the counter values from this module so that 
	 *     other modules can stay in sync with the VGA
	 * (it's a surprise tool that will help us later!)
	 */
	logic hsync_w;
	logic vsync_w;
	reg [9:0] hc;
	reg [9:0] vc;
	
	initial begin
		hc = 10'b0000000000;
		vc = 10'b0000000000;
	end
	
	assign hc_out = hc;
	assign vc_out = vc;
	
   // in the sequential block, we update hc and vc based on their current values
	
	always_ff @(posedge vgaclk) begin
    if (rst == 1'b0) begin
        hc <= 10'b0;
        vc <= 10'b0;
    end
    else begin
        if (hc < 799) begin
            hc <= hc + 1;
        end
        else begin
            hc <= 10'b0;
            if (vc < 524) begin
                vc <= vc + 1;
            end
            else begin
                vc <= 10'b0;
            end
        end
    end
end
		/* TODO(2): update the counters, paying careful attention to
		 *       a) the reset condition, and
		 *       b) the conditions that cause hc and vc to go back to 0
		 */
		 

	
	/* TODO(3): when should hsync and vsync go low?
	 */
	 
	 
	 assign hsync = hsync_w;
	 assign vsync = vsync_w;
	
 
	always_comb begin
    
    hsync_w = !(hc_out < HPIXELS + HFP + HSPULSE && hc_out > HPIXELS + HFP - 1); // Active for HSync Pulse
    vsync_w = !(vc_out < VPIXELS + VFP + VSPULSE && vc_out > VPIXELS + VFP - 1); // Active for VSync Pulse
    
    // Check if we're within the active video range
    if (hc_out < 640 && vc_out < 480) begin
     
        red = {input_red, 1'b0};
        green = {input_green, 1'b0};
        blue = {input_blue, 2'b00};
    end 
    else begin
       
        red = 4'b0000;
        green = 4'b0000;
        blue = 4'b0000;
    end
end

endmodule
