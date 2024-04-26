/*module graphics(
	input [9:0] hc_out,
	input [9:0] vc_out,
	output [7:0] color,
	output [18:0] addrWrite
);

always_comb begin
	if (hc_out < 640 && vc_out < 480) begin
		color = 8'b11110000; //purple, allegedly 
		addrWrite = vc_out * 640 + hc_out;
	end
	else begin
		color = 8'b0;
		addrWrite = 19'b0;
	end
end

endmodule
*/

module graphics(
    input [9:0] hc_out,
    input [9:0] vc_out,
    output reg [7:0] color,
    output reg [18:0] addrWrite
);

localparam BLOCK_SIZE = 10; // each pixel turns into a 10x10 block of pixels technically
localparam SCREEN_WIDTH = 640 / BLOCK_SIZE; // adjust for blocking
localparam SCREEN_HEIGHT = 480 / BLOCK_SIZE; 

always_comb begin
	 color = 8'b00000000; // default value
	 addrWrite = 18'b000000000000000000; //default value (will change later), but we put it here just in case
	 
    if (hc_out / BLOCK_SIZE < SCREEN_WIDTH && vc_out / BLOCK_SIZE < SCREEN_HEIGHT) begin
        color = 8'b11110000; // Purple, allegedly
        addrWrite = (vc_out / BLOCK_SIZE) * SCREEN_WIDTH + (hc_out / BLOCK_SIZE);
    end
    else begin
        color = 8'b00000000;
        addrWrite = 0;
    end
end

endmodule
