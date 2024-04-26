module graphics_ghost_LUT (
    input [9:0] blinky_address, 
    input [9:0] pinky_address, 
    input [9:0] inky_address, 
    input [9:0] clyde_address, 
    output [2:0] blinky_pixel,
    output [2:0] pinky_pixel,
    output [2:0] inky_pixel, 
    output [2:0] clyde_pixel
);

// bitfield definition 
localparam BLNK = 3'b000;   // BLaNK
localparam BODY = 3'b001;   // BODY color   
localparam EYES = 3'b010;   // shared EYE pixelS
localparam WHT0 = 3'b011;   // WHT for right/up, else body
localparam BLU0 = 3'b100;   // BLU for right/up, else body
localparam WHT1 = 3'b101;   // WHT for left/down, else body
localparam BLU1 = 3'b110;   // BLU for left/down, else body
localparam FRL0 = 3'b010;   // FRiLly thing, frame 0 
localparam FRL1 = 3'b011;   // FRiLly thing, frame 1

// 3x256x4
// EACH SPRITE IS 8X8 PIXELS, EACH PIXEL IS 3 BITS WIDE
// 

reg [2:0] ghost_LUT [0:767] = '{
//  0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15
// 
//  SPRITE0 - LOOKING RIGHT (0) OR LEFT (1)
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 1
    BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   // 2
    BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   // 3
    BLNK,   BLNK,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BLNK,   BLNK,   // 4
    BLNK,   BLNK,   WHT1,   WHT1,   EYES,   EYES,   WHT0,   WHT0,   WHT1,   WHT1,   EYES,   EYES,   WHT0,   WHT0,   BLNK,   BLNK,   // 5
    BLNK,   BLNK,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLNK,   BLNK,   // 6
    BLNK,   BODY,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BODY,   BLNK,   // 7
    BLNK,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   BLNK,   // 8
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 9
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 10
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 11
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 12
    BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 13
    BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 14
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 15
// 
//  SPRITE1 - LOOKING UP (0) OR DOWN (1)
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 16
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 17
    BLNK,   BLNK,   BLNK,   BLNK,   BLU0,   BLU0,   BODY,   BODY,   BODY,   BODY,   BLU0,   BLU0,   BLNK,   BLNK,   BLNK,   BLNK,   // 18
    BLNK,   BLNK,   BLNK,   WHT0,   BLU0,   BLU0,   WHT0,   BODY,   BODY,   WHT0,   BLU0,   BLU0,   WHT0,   BLNK,   BLNK,   BLNK,   // 19
    BLNK,   BLNK,   BODY,   WHT0,   WHT0,   WHT0,   WHT0,   BODY,   BODY,   WHT0,   WHT0,   WHT0,   WHT0,   BODY,   BLNK,   BLNK,   // 20
    BLNK,   BLNK,   BODY,   WHT0,   EYES,   EYES,   WHT0,   BODY,   BODY,   WHT0,   EYES,   EYES,   WHT0,   BODY,   BLNK,   BLNK,   // 21
    BLNK,   BLNK,   BODY,   WHT1,   EYES,   EYES,   WHT1,   BODY,   BODY,   WHT1,   EYES,   EYES,   WHT1,   BODY,   BLNK,   BLNK,   // 22
    BLNK,   BODY,   BODY,   WHT1,   WHT1,   WHT1,   WHT1,   BODY,   BODY,   WHT1,   WHT1,   WHT1,   WHT1,   BODY,   BODY,   BLNK,   // 23
    BLNK,   BODY,   BODY,   WHT1,   BLU1,   BLU1,   WHT1,   BODY,   BODY,   WHT1,   BLU1,   BLU1,   WHT1,   BODY,   BODY,   BLNK,   // 24
    BLNK,   BODY,   BODY,   BODY,   BLU1,   BLU1,   BODY,   BODY,   BODY,   BODY,   BLU1,   BLU1,   BODY,   BODY,   BODY,   BLNK,   // 25
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 26
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 27
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 28
    BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 29
    BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 30
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 31
// 
//  SPRITE2 - FRIGHTENED
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 32
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 33
    BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   // 34
    BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   // 35
    BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 36
    BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 37
    BLNK,   BLNK,   BODY,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 38
    BLNK,   BODY,   BODY,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 39
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 40
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 41
    BLNK,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BLNK,   // 42
    BLNK,   BODY,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   BODY,   BLNK,   // 43
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 44
    BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 45
    BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 46
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK    // 47
}; 

assign blinky_pixel = ghost_LUT [blinky_address];
assign pinky_pixel = ghost_LUT [pinky_address]; 
assign inky_pixel = ghost_LUT [inky_address];
assign clyde_pixel = ghost_LUT [clyde_address]; 

endmodule