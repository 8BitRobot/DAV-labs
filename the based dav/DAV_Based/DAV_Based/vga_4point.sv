module vga_4point(
		input vgaclk,           //input pixel clock: how fast should this be?
		input rst,              //synchronous reset
		input [9:0] data [3:0], // adjusted FFT data
		output hsync,			//horizontal sync out
		output vsync,			//vertical sync out
		output reg [3:0] red,	//red vga output
		output reg [3:0] green, //green vga output
		output reg [3:0] blue,	//blue vga output
		output reg done
   );
	
	//Video protocol constants
    // You can find these described in the VGA specification for 640x480
	localparam HPIXELS = 10'd800;  // horizontal pixels per line
	localparam HPULSE = 10'd96; 	// hsync pulse length
	localparam HBPW = 10'd48; 	    // width of horizontal back porch
	localparam HFPW = 10'd16;		// width of hoziontal front porch
	localparam HFP = 10'd640; 	    // beginning of horizontal front porch
	
	localparam VLINES = 10'd525;   // scanlines per frame (aka the # of vertical pixels)
	localparam VPULSE = 10'd2; 	// vsync pulse length
	localparam VBPW = 10'd33; 		// width of vertical back porch
	localparam VFP = 10'd480; 	    // beginning of vertical front porch
	localparam VFPW = 10'd10; 	    // width of vertical front porch
	
	localparam BARW = 10'd40;		// width of 16 bars
	localparam BARH = 10'd480;		// height of each bar
	
	reg [1:0] barnum;
	
	// registers for storing the horizontal & vertical counters
	reg [10:0] hc;
	reg [10:0] vc;

    //Counter block: change hc and vc correspondingly to the current state.
	always @(posedge vgaclk) begin
		 //reset condition
		if (rst == 1)
		begin
			hc <= 0;
			vc <= 0;
		end
		else
		begin
			//Implement logic to move counters properly!
			if (hc + 1 < HPIXELS)
				hc <= hc + 1;
			else begin
				hc <= 0;	
				
				if (vc + 1 < VLINES)
					vc <= vc + 1;
				else 
					vc <= 0;	
			end	
			
		end
	end

	assign hsync = !((hc > HFP + HFPW) && (hc < HFP + HFPW + HPULSE)); // low if between range
	assign vsync = !((vc > VFP + VFPW) && (vc < VFP + VFPW + VPULSE)); // low if between range
	//assign barnum = hc/160; //only 4 bars
	
	
	//assign barnum = hc/40;
	always_comb begin
	
		if (hc < 160) begin
			barnum = 0;
			end
		else if (hc < 320 && hc >= 160) begin
			barnum = 1;
			end
		else if (hc < 480 && hc >= 320) begin
			barnum = 2;
			end
		else begin
			barnum = 3;
			end
			
	end

    //RGB output block: set red, green, blue outputs here.
	always_comb begin
		
		// check if we're within vertical active video range
		if (vc < VFP)
		begin
			// check if within horizontal active video range
			if (hc < HFP) 
			begin
			//draw something!
				if (vc < VFP - data[barnum]) begin
					red = 0;
					green = 0;
					blue = 0;
				end
				else begin
					red = 4'b1111; 
					green = 0;
					blue = 0;
				end
				
			end
			
			// Horizontal Blanking Interval
			else begin
				red = 0;
				green = 0;
				blue = 0;
			end
			
			done = 0;
		end
		// Vertical Blanking Interval
		else begin
          red = 0;
			 green = 0;
			 blue = 0;
			 done = 1;
		end
		
	end

endmodule
