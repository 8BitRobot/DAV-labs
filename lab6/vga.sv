module vga(
		input vgaclk,           //input pixel clock: how fast should this be?
		input rst,              //synchronous reset
		output hsync,			//horizontal sync out
		output vsync,			//vertical sync out
		output reg [3:0] red,	//red vga output
		output reg [3:0] green, //green vga output
		output reg [3:0] blue	//blue vga output
   );
	
	//TODO: Video protocol constants
    // You can find these described in the VGA specification for 640x480
	localparam HPIXELS = 640;   // horizontal pixels per line
	localparam HPULSE = 96; 	// hsync pulse length
	localparam HBP = 799; 	    // end of horizontal back porch
	localparam HFP = 656; 	    // end of horizontal front porch
	
	localparam HLINES = 480;    // vertical lines per frame
	localparam VPULSE = 2; 	    // vsync pulse length
	localparam VBP = 524; 		// end of vertical back porch
	localparam VFP = 490; 	    // end of vertical front porch
	
	// registers for storing the horizontal & vertical counters
	reg [9:0] hc;
	reg [9:0] vc;

	initial begin
		hc = 0;
		vc = 0;
	end

    //Counter block: change hc and vc correspondingly to the current state.
	always @(posedge vgaclk) begin
		 //reset condition
		if (rst == 1) begin
			hc <= 0;
			vc <= 0;
		end else
		begin
			//TODO: Implement logic to move counters properly!
			if (hc == HBP) begin
				hc <= 0;
				if (vc == VBP) begin
					vc <= 0;
				end else begin
					vc <= vc + 1;
				end
			end else begin
				hc <= hc + 1;
			end
		end
	end

	assign hsync = ~((hc >= HFP) && (hc < (HFP + HPULSE))); //TODO
	assign vsync = ~((vc >= VFP) && (vc < (VFP + VPULSE))); //TODO
	
    //RGB output block: set red, green, blue outputs here.
	always_comb begin
		// check if we're within active video range
		if (vc < HLINES && hc < HPIXELS)
		begin
			//TODO: draw something!
			red = 4'b1111;
			green = 0;
			blue = 0;
		end
		else begin
            //TODO: we're not in active video range, what do we do?
			red = 0;
			green = 0;
			blue = 0;
		end
	end

endmodule
