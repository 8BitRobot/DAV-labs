module graphics_controller(
    input clk,
    input [9:0] x,
    input [9:0] y,
    input [35:0] frequencies [0:15],
    output [2:0] red_out,
    output [2:0] green_out,
    output [1:0] blue_out,
);

    always_comb begin
        if (x < 30 && y < frequencies[0][35:18]) begin
            // take the real one
            red_out = 3'b111;
            green_out = 3'b000;
            blue_out = 2'b00;
            
        end else if (x < 60 && y < frequencies[1][35:18]) begin
            red_out = 3'b001;
            green_out = 3'b001;
            blue_out = 2'b01;

        end else if (x < 90 && y < frequencies[2][35:18]) begin
            red_out = 3'b010;
            green_out = 3'b010;
            blue_out = 2'b10;

        end else if (x < 120 && y < frequencies[3][35:18]) begin
            red_out = 3'b001;
            green_out = 3'b010;
            blue_out = 2'b01;

        end else if (x < 150 && y < frequencies[4][35:18]) begin
            red_out = 3'b010;
            green_out = 3'b001;
            blue_out = 2'b10;

        end else if (x < 180 && y < frequencies[5][35:18]) begin
            red_out = 3'b100;
            green_out = 3'b100;
            blue_out = 2'b01;

        end else if (x < 210 && y < frequencies[6][35:18]) begin
            red_out = 3'b100;
            green_out = 3'b100;
            blue_out = 2'b01;

        end else if (x < 240 && y < frequencies[7][35:18]) begin
            red_out = 3'b100;
            green_out = 3'b100;
            blue_out = 2'b10;

        end else if (x < 270 && y < frequencies[8][35:18]) begin
            red_out = 3'b100;
            green_out = 3'b011;
            blue_out = 2'b00;

        end else if (x < 300 && y < frequencies[9][35:18]) begin
            red_out = 3'b011;
            green_out = 3'b110;
            blue_out = 2'b00;

        end else if (x < 330 && y < frequencies[10][35:18]) begin
            red_out = 3'b111;
            green_out = 3'b111;
            blue_out = 2'b00;

        end else if (x < 360 && y < frequencies[11][35:18]) begin
            red_out = 3'b111;
            green_out = 3'b111;
            blue_out = 2'b10;

        end else if (x < 390 && y < frequencies[12][35:18]) begin
            red_out = 3'b111;
            green_out = 3'b111;
            blue_out = 2'b01;

        end else if (x < 420 && y < frequencies[13][35:18]) begin
            red_out = 3'b010;
            green_out = 3'b010;
            blue_out = 2'b11;

        end else if (x < 450 && y < frequencies[14][35:18]) begin
            red_out = 3'b100;
            green_out = 3'b100;
            blue_out = 2'b11;

        end else if (x < 480 && y < frequencies[15][35:18]) begin
            red_out = 3'b001;
            green_out = 3'b001;
            blue_out = 2'b11;

        end else begin
            red_out = 3'b000;
            green_out = 3'b000;
            blue_out = 2'b00;
        end
    end

endmodule