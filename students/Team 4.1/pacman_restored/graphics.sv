module graphics (
    input [9:0] hc_in,
    input [9:0] vc_in,
    input [9:0] switches, // testing outputs
    input btn,
    output reg [7:0] color,
    output reg [15:0] address
);

// 
// COLOR DEFINITIONS
localparam RED  = 8'b11100000;
localparam PNK  = 8'b11101111;
localparam CYN  = 8'b00011111;
localparam ORG  = 8'b11110100;
localparam YLW  = 8'b11111100;
localparam WHT  = 8'b11111111;
localparam CRM  = 8'b11111110;
localparam BLU  = 8'b00000011;
localparam BLK  = 8'b00000000; 

// 
// BLOCKING & ROTATION
localparam XMAX  = 160; // horizontal pixels
localparam YMAX  = 320; // vertical pixels
wire [9:0] xpos; 
wire [9:0] ypos;

always_comb begin
    if (hc_in < 640 && vc_in < 480) begin
        xpos = XMAX - 1 - vc_in / 3;
        ypos = hc_in / 2;
    end else if (vc_in < 480) begin
        xpos = XMAX - 1 - vc_in / 3;
        ypos = YMAX - 1;
    end else begin 
        xpos = 0;
        ypos = 0;
    end
    // address = ypos*XMAX + xpos;
    address = xpos*YMAX + ypos;
end


// // 
// // VGA DRIVER TESTING
// assign color [7:5] = switches[9:7];
// assign color [4:2] = switches[6:4];
// assign color [1:0] = switches[3:2];

//
// GHOST INSTANTIATION
wire [9:0] blinky_xloc;
wire [9:0] blinky_yloc;
wire [1:0] blinky_dir;
wire [1:0] blinky_state;
wire [9:0] blinky_address;
wire [2:0] blinky_pixel;
wire [7:0] blinky_color;

wire [9:0] pinky_xloc;
wire [9:0] pinky_yloc;
wire [1:0] pinky_dir;
wire [1:0] pinky_state;
wire [9:0] pinky_address;
wire [2:0] pinky_pixel;
wire [7:0] pinky_color;

wire [9:0] inky_xloc;
wire [9:0] inky_yloc;
wire [1:0] inky_dir;
wire [1:0] inky_state;
wire [9:0] inky_address;
wire [2:0] inky_pixel;
wire [7:0] inky_color;

wire [9:0] clyde_xloc;
wire [9:0] clyde_yloc;
wire [1:0] clyde_dir;
wire [1:0] clyde_state;
wire [9:0] clyde_address;
wire [2:0] clyde_pixel;
wire [7:0] clyde_color = BLK;

wire ghost_animation;

graphics_ghost_LUT GLUT(blinky_address, pinky_address, inky_address, clyde_address, blinky_pixel, pinky_pixel, inky_pixel, clyde_pixel);
graphics_ghost BLINKY(xpos, ypos, blinky_xloc, blinky_yloc, 2'b00, blinky_dir, blinky_state, ghost_animation, blinky_pixel, blinky_address, blinky_color);
graphics_ghost PINKY(xpos, ypos, pinky_xloc, pinky_yloc, 2'b01, pinky_dir, pinky_state, ghost_animation, pinky_pixel, pinky_address, pinky_color);
graphics_ghost INKY(xpos, ypos, inky_xloc, inky_yloc, 2'b10, inky_dir, inky_state, ghost_animation, inky_pixel, inky_address, inky_color);

// 
// MAZE INSTANTIATION
wire [7:0] maze_color;
graphics_maze MAZEPIN(xpos, ypos, maze_color);

// 
// TESTING WITH SWITCHES
assign blinky_xloc = switches[9:6] << 2;
assign blinky_yloc = switches[5:3] << 2;
assign blinky_dir = switches[2:1];
assign blinky_state [1] = switches[0];

assign pinky_xloc = 'd28;
assign pinky_yloc = 'd28;
assign pinky_dir = switches[2:1];
assign pinky_state [1] = switches[0];

assign inky_xloc = 'd154;
assign inky_yloc = 'd160;
assign inky_dir = switches[2:1];
assign inky_state [1] = switches[0];

assign ghost_animation = ~btn;

always_comb begin
    // instantiate blinky, pinky, etc. with like 'ghost1color', 'ghost2color', etc. for outputs instead of just 'color' (so they're split on different wires)
    // in comb block determine which wire (ghost1color, ghost2color, etc) has priority, and set that to drive color
    //      red > pink > blue > orange

    if (blinky_color != BLK) begin
        color = blinky_color;
    end else if (pinky_color != BLK) begin
        color = pinky_color;
    end else if (inky_color != BLK) begin
        color = inky_color;
    end else if (clyde_color != BLK) begin
        color = clyde_color;
    end else if (maze_color != BLK) begin
        color = maze_color;
    end else begin
        color = BLK;
    end
end

// always_comb begin
//     if (xpos < XMAX && ypos < YMAX) begin
//         address = ypos*XMAX + xpos;
//     end else if (ypos < YMAX) begin
//         address = ypos*XMAX + XMAX-1;
//     end else begin
//         address = XMAX*YMAX-1;
//     end
// end

endmodule
