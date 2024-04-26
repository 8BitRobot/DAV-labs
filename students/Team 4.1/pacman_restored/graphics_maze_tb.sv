`timescale 1ns/1ns

module graphics_maze_tb (
    output reg [9:0] xpos,
    output reg [9:0] ypos
);

wire [7:0] color;

graphics_maze UUT(xpos, ypos, color);

initial begin
    xpos = 0;
    ypos = 0;
end

always begin
    if (xpos < 159) begin
        #5 xpos <= xpos + 1;
    end else if (ypos < 319) begin
        #5 ypos <= ypos + 1;
        xpos <= 0;
    end else begin
        $stop;
    end
end



endmodule