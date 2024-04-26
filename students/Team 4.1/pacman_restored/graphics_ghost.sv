module graphics_ghost (
    input [9:0] xpos,           // current x position read by vga
    input [9:0] ypos,           // current y position read by vga

    input [9:0] xloc,           // x coordinate of center of ghost location (7,7 in bitfield)
    input [9:0] yloc,           // y coordinate of center of ghost location (7,7 in bitfield)

    input [1:0] ghost_color,
    input [1:0] ghost_dir,      // RighT, UP, DowN, LefT
    input [1:0] ghost_state,     
    input animation_cycle,  

    input [2:0] pixel, 
    output reg [9:0] pixel_address,

    output reg [7:0] color
);

reg [7:0] bodycolor;
// ghost colors
localparam RED  = 8'b11100000;
localparam PNK = 8'b11101111;
localparam CYN = 8'b00011111;
localparam ORG = 8'b11110100;
localparam WHT = 8'b11111111;
localparam BLU = 8'b00000011;
localparam BLK  = 8'b00000000; 

// ghost directions
localparam RT   = 2'b00;
localparam UP   = 2'b01;
localparam DN   = 2'b10;
localparam LT   = 2'b11;

// pixel definitions 
localparam BLNK = 3'b000;   // BLaNK
localparam BODY = 3'b001;   // BODY color   
localparam EYES = 3'b010;   // shared EYE pixelS
localparam WHT0 = 3'b011;   // WHT for right/up, else body
localparam BLU0 = 3'b100;   // BLU for right/up, else body
localparam WHT1 = 3'b101;   // WHT for left/down, else body
localparam BLU1 = 3'b110;   // BLU for left/down, else body
localparam FRL0 = 3'b010;   // FRiLly thing, frame 0 
localparam FRL1 = 3'b011;   // FRiLly thing, frame 1

// reg [2:0] ghost_LUT [0:767] = '{
// //  0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15
// // 
// //  SPRITE0 - LOOKING RIGHT (0) OR LEFT (1) - FRILL ANIMATION FRAME 0 OR 1 
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 0
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 1
//     BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   // 2
//     BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   // 3
//     BLNK,   BLNK,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BLNK,   BLNK,   // 4
//     BLNK,   BLNK,   WHT1,   WHT1,   EYES,   EYES,   WHT0,   WHT0,   WHT1,   WHT1,   EYES,   EYES,   WHT0,   WHT0,   BLNK,   BLNK,   // 5
//     BLNK,   BLNK,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLNK,   BLNK,   // 6
//     BLNK,   BODY,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BODY,   BLNK,   // 7
//     BLNK,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   BLNK,   // 8
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 9
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 10
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 11
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 12
//     BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 13
//     BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 14
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 15
// // 
// //  SPRITE1 - LOOKING UP (0) OR DOWN (1) - FRILL ANIMATION FRAME 0 OR 1
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 16
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 17
//     BLNK,   BLNK,   BLNK,   BLNK,   BLU0,   BLU0,   BODY,   BODY,   BODY,   BODY,   BLU0,   BLU0,   BLNK,   BLNK,   BLNK,   BLNK,   // 18
//     BLNK,   BLNK,   BLNK,   WHT0,   BLU0,   BLU0,   WHT0,   BODY,   BODY,   WHT0,   BLU0,   BLU0,   WHT0,   BLNK,   BLNK,   BLNK,   // 19
//     BLNK,   BLNK,   BODY,   WHT0,   WHT0,   WHT0,   WHT0,   BODY,   BODY,   WHT0,   WHT0,   WHT0,   WHT0,   BODY,   BLNK,   BLNK,   // 20
//     BLNK,   BLNK,   BODY,   WHT0,   EYES,   EYES,   WHT0,   BODY,   BODY,   WHT0,   EYES,   EYES,   WHT0,   BODY,   BLNK,   BLNK,   // 21
//     BLNK,   BLNK,   BODY,   WHT1,   EYES,   EYES,   WHT1,   BODY,   BODY,   WHT1,   EYES,   EYES,   WHT1,   BODY,   BLNK,   BLNK,   // 22
//     BLNK,   BODY,   BODY,   WHT1,   WHT1,   WHT1,   WHT1,   BODY,   BODY,   WHT1,   WHT1,   WHT1,   WHT1,   BODY,   BODY,   BLNK,   // 23
//     BLNK,   BODY,   BODY,   WHT1,   BLU1,   BLU1,   WHT1,   BODY,   BODY,   WHT1,   BLU1,   BLU1,   WHT1,   BODY,   BODY,   BLNK,   // 24
//     BLNK,   BODY,   BODY,   BODY,   BLU1,   BLU1,   BODY,   BODY,   BODY,   BODY,   BLU1,   BLU1,   BODY,   BODY,   BODY,   BLNK,   // 25
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 26
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 27
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 28
//     BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 29
//     BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 30
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 31
// // 
// //  SPRITE2 - FRIGHTENED - FRILL ANIMATION FRAME 0 OR 1
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 32
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 33
//     BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   // 34
//     BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   // 35
//     BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 36
//     BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 37
//     BLNK,   BLNK,   BODY,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 38
//     BLNK,   BODY,   BODY,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 39
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 40
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 41
//     BLNK,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BLNK,   // 42
//     BLNK,   BODY,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   BODY,   BLNK,   // 43
//     BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 44
//     BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 45
//     BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 46
//     BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK    // 47
// }; 

always_comb begin
    // inside render area of sprite
    if ( ( (xloc < 7 || xloc-7 <= xpos) && xpos <= xloc+8) && ( (yloc < 7 || yloc-7 <= ypos) && ypos <= yloc+8) ) begin
        // normal or dead ghost appearance
        if (ghost_state == 2'b00 || ghost_state == 2'b11) begin
            // select pixel from LUT
            if (ghost_dir == RT || ghost_dir == LT) begin
                pixel_address = (ypos-yloc+7) * 16 + (xpos-xloc+7);
            end else begin
                pixel_address = 10'd256 + (ypos-yloc+7) * 16 + (xpos-xloc+7);
            end
            // assign correct color
            if (ghost_state == 2'b11) begin
                bodycolor = BLK;
            end else begin
                case (ghost_color)
                    2'b00: bodycolor = RED;
                    2'b01: bodycolor = PNK;
                    2'b10: bodycolor = CYN;
                    2'b11: bodycolor = ORG;
                    default: bodycolor = BLK;
                endcase
            end
        // frightened ghost appearance
        end else begin  // if (ghost_state == 2'b01) 
            pixel_address = 10'd512 + (ypos-yloc+7) * 16 + (xpos-xloc+7);
            bodycolor = BLU;
        end 

        // render eye area
        if ((ypos-yloc+7) < 12) begin
            case (pixel)
                BODY: color = bodycolor;
                EYES: color = WHT;
                WHT0: begin
                    if (ghost_dir == RT || ghost_dir == UP) color = WHT;
                    else color = bodycolor;
                end
                WHT1: begin
                    if (ghost_dir == LT || ghost_dir == DN) color = WHT;
                    else color = bodycolor;
                end
                BLU0: begin
                    if (ghost_dir == RT || ghost_dir == UP) color = BLU;
                    else color = bodycolor;
                end
                BLU1: begin
                    if (ghost_dir == LT || ghost_dir == DN) color = BLU;
                    else color = bodycolor;
                end
                BLNK: color = BLK;
                default: color = bodycolor;
            endcase

        // render animated frilly part
        end else begin
            if (animation_cycle == 0) begin
                case (pixel)
                    BODY,
                    FRL0: color = bodycolor;
                    FRL1,
                    BLNK: color = BLK;
                    default: color = BLK;
                endcase
            end else begin
                case (pixel)
                    BODY, 
                    FRL1: color = bodycolor;
                    FRL0, 
                    BLNK: color = BLK;
                    default: color = BLK;
                endcase      
            end
        end

    // outside render area of sprite
    end else begin
        pixel_address = 10'b0;
        bodycolor = BLK;
        color = bodycolor;
    end
end

endmodule

