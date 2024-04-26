module vga_64(
		input vgaclk,           //input pixel clock: how fast should this be?
		input rst,              //synchronous reset
		output hsync,			//horizontal sync out
		output vsync,			//vertical sync out
		output reg [3:0] red,	//red vga output
		output reg [3:0] green, //green vga output
		output reg [3:0] blue,	//blue vga output
		input reg [8:0] points [63:0]);
	
    // You can find these described in the VGA specification for 640x480
	localparam HPIXELS = 800;  // horizontal pixels per line
	localparam HPULSE = 96; 	// hsync pulse length
	localparam HBLANKING = 160; // horizontal blanking interval length
	localparam HBP = 752; 	    // end of horizontal back porch
	localparam HFP = 657; 	    // beginning of horizontal front porch
	
	localparam VLINES = 525;   // vertical lines per frame
	localparam VPULSE = 2; 	// vsync pulse length
	localparam VBLANKING = 45; // vertical blanking interval length
	localparam VBP = 493; 		// end of vertical back porch
	localparam VFP = 490; 	    // beginning of vertical front porch
	
	// registers for storing the horizontal & vertical counters
	reg [9:0] hc = 0;
	reg [9:0] vc = 0;	

    //Counter block: change hc and vc correspondingly to the reset state.
	always @(posedge vgaclk) begin
		 //reset condition
		if (rst == 0) begin // Reset button is ACTIVE LOW
			hc <= 0;
			vc <= 0;
		end
		else begin
			//TODO: Implement logic to move counters properly!
			hc <= (hc + 1) % HPIXELS;
			if (hc == HPIXELS-1) begin
				vc <= (vc + 1) % VLINES;
			end
		end
	end
	
	assign hsync = (hc > HFP && hc < HBP) ? 0 : 1; // Check if we are in the hsync interval, if so, pull hsync down
	assign vsync = (vc < VBP && vc > VFP) ? 0 : 1; // Check if we are in the vsync interval, if so, pull vsync down
	
	reg [6:0] frame_counter = 0;
	reg [3:0] green_d = 4;
	reg direction = 1;
	always @ (posedge vsync) begin
		frame_counter <= frame_counter + 1;
		if (frame_counter == 0) begin
			if (green_d == 12 || green_d == 4) begin
				direction = ~direction;
			end
		end
		else if (frame_counter == 1) begin
			if (direction == 0) begin
				green_d <= green_d + 1;
			end
			else begin
				green_d <= green_d - 1;
			end
		end
	end
	
    //RGB output block: set red, green, blue outputs here.
	always_comb begin
		// check if we're within vertical active video range
		if (vc < VLINES-VBLANKING && hc < HPIXELS-HBLANKING) begin
			if (hc == 20 || hc == 40 || hc == 60 || hc == 80 || 
				 hc == 100 || hc == 120 || hc == 140 || hc == 160 || 
				 hc == 180 || hc == 200 || hc == 220 || hc == 240 || 
				 hc == 260 || hc == 280 || hc == 300 || hc == 320 || 
				 hc == 340 || hc == 360 || hc == 380 || hc == 400 || 
				 hc == 420 || hc == 440 || hc == 460 || hc == 480 || 
				 hc == 500 || hc == 520 || hc == 540 || hc == 560 || 
				 hc == 580 || hc == 600 || hc == 620 || hc == 10 || 
				 hc == 30 || hc == 50 || hc == 70 || hc == 90 || 
				 hc == 110 || hc == 130 || hc == 150 || hc == 170 ||
				 hc == 190 || hc == 210 || hc == 230 || hc == 250 ||
				 hc == 270 || hc == 290 || hc == 310 || hc == 330 ||
				 hc == 350 || hc == 370 || hc == 390 || hc == 410 ||
				 hc == 430 || hc == 450 || hc == 470 || hc == 490 || 
				 hc == 510 || hc == 530 || hc == 550 || hc == 570 || 
				 hc == 590 || hc == 610 || hc == 630) begin // Vertical bars
				 red = 15;
				 green = 15;
				 blue = 15;
			end
			else if (hc < 20 && hc > 0) begin // DC component
				if ((480-vc) < points[hc/10]) begin
					if (vc < 40) begin
						red = 11;
						green = green_d;
						blue = hc/40;
					end else if (vc > 39 && vc < 80) begin
						red = 10;
						green = green_d;
						blue = hc/40;
					end else if (vc > 79 && vc < 120) begin
						red = 9;
						green = green_d;
						blue = hc/40;
					end else if (vc > 119 && vc < 160) begin
						red = 8;
						green = green_d;
						blue = hc/40;
					end else if (vc > 159 && vc < 200) begin
						red = 7;
						green = green_d;
						blue = hc/40;
					end else if (vc > 199 && vc < 240) begin
						red = 6;
						green = green_d;
						blue = hc/40;
					end else if (vc > 239 && vc < 280) begin
						red = 5;
						green = green_d;
						blue = hc/40;
					end else if (vc > 279 && vc < 320) begin
						red = 4;
						green = green_d;
						blue = hc/40;
					end else if (vc > 319 && vc < 360) begin
						red = 3;
						green = green_d;
						blue = hc/40;
					end else if (vc > 359 && vc < 400) begin
						red = 2;
						green = green_d;
						blue = hc/40;
					end else if (vc > 399 && vc < 440) begin
						red = 1;
						green = green_d;
						blue = hc/40;
					end else if (vc > 439 && vc < 480) begin
						red = 0;
						green = green_d;
						blue = hc/40;
					end else begin 
						red = 0;
						green = 0;
						blue = 0;
					end
				end
				else begin // Not in this vertical line
					red = 0;
					green = 0;
					blue = 0;
				end
			end 
			else begin
				if (points[hc/10] > 480) begin // If greater than 480, just display zero
					red = 0;
					green = 0;
					blue = 0;
				end
				else if ((480-vc) < (points[hc/10] << 2)) begin // If less than 480, display the bar, multiplied by 4
					if (vc < 40) begin
						red = 11;
						green = green_d;
						blue = hc/40;
					end else if (vc > 39 && vc < 80) begin
						red = 10;
						green = green_d;
						blue = hc/40;
					end else if (vc > 79 && vc < 120) begin
						red = 9;
						green = green_d;
						blue = hc/40;
					end else if (vc > 119 && vc < 160) begin
						red = 8;
						green = green_d;
						blue = hc/40;
					end else if (vc > 159 && vc < 200) begin
						red = 7;
						green = green_d;
						blue = hc/40;
					end else if (vc > 199 && vc < 240) begin
						red = 6;
						green = green_d;
						blue = hc/40;
					end else if (vc > 239 && vc < 280) begin
						red = 5;
						green = green_d;
						blue = hc/40;
					end else if (vc > 279 && vc < 320) begin
						red = 4;
						green = green_d;
						blue = hc/40;
					end else if (vc > 319 && vc < 360) begin
						red = 3;
						green = green_d;
						blue = hc/40;
					end else if (vc > 359 && vc < 400) begin
						red = 2;
						green = green_d;
						blue = hc/40;
					end else if (vc > 399 && vc < 440) begin
						red = 1;
						green = green_d;
						blue = hc/40;
					end else if (vc > 439 && vc < 480) begin
						red = 0;
						green = green_d;
						blue = hc/40;
					end else begin 
						red = 0;
						green = 0;
						blue = 0;
					end
				end
				else begin // Not at this vertical line
					red = 0;
					green = 0;
					blue = 0;
				end
			end 
		end
		else begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end

endmodule
