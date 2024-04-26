module graphics_maze (
    input [9:0] xpos, 
    input [9:0] ypos, 

    output reg [7:0] color
);

localparam BLU  = 8'b00000011;
localparam BLK  = 8'b00000000; 

// outer walls
// localparam EMPTY = 4'b0000;
// localparam CORDR = 4'b0001;
// localparam STRLD = 4'b0010;
// localparam STRRD = 4'b0011;
// localparam CORDL = 4'b0100;
// localparam STRUR = 4'b0101;
// localparam STRUL = 4'b0110;
// localparam STRDR = 4'b0111;
// localparam STRDL = 4'b1000;
// localparam CORUR = 4'b1001;
// localparam STRLU = 4'b1010;
// localparam STRRU = 4'b1011;
// localparam CORUL = 4'b1100;

// ROTATIONS
localparam NM = 2'b00;      // NorMal
localparam CC = 2'b01;      // Counter-Clockwise
localparam CW = 2'b10;      // ClockWise
localparam FL = 2'b11;      // FLipped (180)

// MAZE WALL TYPES
localparam BLNK = 3'b000;   // BLaNK
localparam OCOR = 3'b001;   // Outer CORner (outer top-left corner, inner top-left corner)
localparam OSC0 = 3'b010;   // Outer Straight, inner Corner 0 (outer top straight, inner bottom-left corner)
localparam OSC1 = 3'b011;   // Outer Straight, inner Corner 1 (outer left straight, inner top-right corner)
localparam OSTR = 3'b100;   // Outer STRaight (outer top straight, inner top straight)
localparam ICR0 = 3'b101;   // Inner CoRner 0 (inner top-left corner, inner edge)
localparam ICR1 = 3'b110;   // Inner CoRner 1 (inner top-left corner, outer edge)
localparam ISTR = 3'b111;   // Inner STRaight (inner top straight)

// reg [63:0] outer_walls [0:3] = '{
//     64'b00001111 00110000 01000000 01000111 10001000 10010000 10010000 10010000,    // outer top-left corner, inner top-left corner
//     64'b11111111 00000000 00000000 11100000 00010000 00001000 00001000 00001000,    // outer top straight, inner bottom-left corner
//     64'b10010000 10010000 10010000 10001000 10000111 10000000 10000000 10000000,    // outer left straight, inner top-right corner
//     64'b11111111 00000000 00000000 11111111 00000000 00000000 00000000 00000000     // outer top straight, inner top straight
// };

// reg [0:63] outer_walls [0:3] = '{
//     64'b0000111100110000010000000100011110001000100100001001000010010000,   // outer top-left corner, inner top-left corner
//     64'b1111111100000000000000001110000000010000000010000000100000001000,   // outer top straight, inner bottom-left corner
//     64'b1001000010010000100100001000100010000111100000001000000010000000,   // outer left straight, inner top-right corner
//     64'b1111111100000000000000001111111100000000000000000000000000000000    // outer top straight, inner top straight
// };

reg [63:0] wall_types [0:7] = '{
    64'h0000000000000000,   // blank
    64'h0f30404788909090,   // outer top-left corner, inner top-left corner
    64'hff0000e010080808,   // outer top straight, inner bottom-left corner
    64'h9090908887808080,   // outer left straight, inner top-right corner
    64'hff0000ff00000000,   // outer top straight, inner top straight
    64'h0000000003040808,   // inner top-left corner, inner edge
    64'h0000000708101010,   // inner top-left corner, outer edge
    64'h00000000ff000000    // inner bottom straight
};

// 
// MAZE DEFINITION
// 20W x 33H = 660 total tiles
// 
reg [4:0] maze [0:659] = '{
//  0           1           2           3           4           5           6           7           8           9           10          11          12          13          14          15          16          17          18          19
    {OCOR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSC0,NM},  {OSC1,CW},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OCOR,CW},      // 0
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 1
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 2
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 3
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 4
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 5
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 6
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 7
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ICR1,CC},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR1,FL},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 8
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 9
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 10
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ICR1,FL},  {ICR1,CC},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 11
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 12
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 13
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 14
    {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},      // 15
    {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},      // 16
    {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},      // 17
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 18
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 19
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 20
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ICR1,CW},  {ICR1,NM},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 21
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 22
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 23
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 24
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 25
    {OSC1,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {OSC0,CW},      // 26
    {OSC0,CC},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ICR1,CW},  {ICR1,NM},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {OSC1,FL},      // 27
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 28
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ICR1,FL},  {ICR1,CC},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ICR1,FL},  {ICR1,CC},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 29
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 30
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 31
    {OCOR,CC},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OCOR,FL}       // 32
};

wire [7:0] xtile = xpos / 8;
wire [7:0] ytile = ypos / 8;
wire [4:0] wall;
// wire [4:0] wall = maze [ytile * 20 + xtile];
// wire [4:0] wall = maze [xtile];
wire [1:0] wall_rot; 
wire [0:63] wall_sprite;

reg pixel;
wire [2:0] xpixel = xpos % 8;
wire [2:0] ypixel = ypos % 8;

always_comb begin
    if (ytile < 33) begin
        wall = maze [ytile * 20 + xtile];
    end else begin
        wall = {BLNK,NM};
    end

    wall_rot = wall [1:0];
    wall_sprite = wall_types [wall [4:2]];

    case (wall_rot)
        NM: begin
            pixel = wall_sprite [6'd8 * ypixel + xpixel];
        end

        CC: begin
            pixel = wall_sprite [6'd7 + 8 * xpixel - ypixel];
        end

        CW: begin
            pixel = wall_sprite [6'd56 - 8 * xpixel + ypixel];
        end

        FL: begin
            pixel = wall_sprite [6'd63 - 8 * ypixel - xpixel];
        end
    endcase

    if (pixel) begin
        color = BLU;
    end else begin
        color = BLK;
    end
end

endmodule