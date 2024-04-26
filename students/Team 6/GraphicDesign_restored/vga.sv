module vga(
	input vgaclk,
	// 8-bit color allocates 3 bits for red, 3 for green, 2 for blue
	input [2:0] input_red,
	input [2:0] input_green,
	input [1:0] input_blue,
	input rst,
	output [9:0] hc_out,
	output [9:0] vc_out,
	output hsync,
	output vsync,
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
	localparam TOTALH = HPIXELS + HFP + HSPULSE + HBP;
	
	localparam VPIXELS = 480;    // number of visible horizontal lines per frame
	localparam VFP = 10; 	      // length (in pixels) of vertical front porch
	localparam VSPULSE = 2;    // length (in pixels) of vsync pulse
	localparam VBP = 33; 		   // length (in pixels) of vertical back porch
	localparam TOTALV = VPIXELS + VFP + VSPULSE + VBP;
	
	// shift register for reset button
	reg [1:0] reset_shiftreg;
	
	/* no need to mess with this -- this is a basic sanity check that will
	 * cause the compiler to yell at you if the values above don't add up
	 */
	initial begin
		reset_shiftreg = 'b11; // shift reg filled with button unpressed
		
		if (HPIXELS + HFP + HSPULSE + HBP != 800 || VPIXELS + VFP + VSPULSE + VBP != 525) begin
			$error("Expected horizontal pixels to add up to 800 and vertical pixels to add up to 525");
		end
	end
	
	/* these registers are for storing the horizontal & vertical counters
	 * we're outputting the counter values from this module so that 
	 *     other modules can stay in sync with the VGA
	 * (it's a surprise tool that will help us later!)
	 */
	reg [9:0] hc;
	reg [9:0] vc;
	
	initial begin
		hc = 0;
		vc = 0;
	end
	
	assign hc_out = hc;
	assign vc_out = vc;
	
   // in the sequential block, we update hc and vc based on their current values
	always_ff @(posedge vgaclk) begin
		/* TODO(2): update the counters, paying careful attention to
		 *       a) the reset condition, and
		 *       b) the conditions that cause hc and vc to go back to 0
		 */
		 reset_shiftreg[0] <= reset_shiftreg[1];
		 reset_shiftreg[1] <= rst;
		 
		 if(reset_shiftreg == 'b01 || hc >= TOTALH-1)	hc <= 0;
		 else		hc <= hc+1;
		 
		 if(reset_shiftreg == 'b01)	vc <= 0;
		 else if(vc >= TOTALV-1 && hc >= TOTALH-1)	vc <= 0;
		 else		vc <= vc+1;
		 
	end
	
	/* TODO(3): when should hsync and vsync go low? */
	assign hsync = (hc >= HPIXELS+HFP && hc < HPIXELS+HFP+HSPULSE) ? 0 : 1;
	assign vsync = (vc >= VPIXELS+VFP && vc < VPIXELS+VFP+VSPULSE) ? 0 : 1;
	
   // in the combinational block, we set red, green, blue outputs
	always_comb begin
		/* TODO(4): check if we're within the active video range;
		 *       if we are, drive the RGB outputs with the input color values
		 *       if not, we're in the blanking interval, so set them all to 0
		 * NOTE: our inputs are fewer bits than the outputs, so left-shift accordingly!
		 */
		if(vc >= VPIXELS || hc >= HPIXELS) begin red=0; green=0; blue=0; end
		else begin red=input_red; green=input_green; blue=input_blue; end
	end

endmodule
