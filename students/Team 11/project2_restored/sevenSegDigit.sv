module sevenSegDigit(
    input [3:0] num,
    input onoff,
    output [7:0] segs
);
  reg [7:0] ans = 8'b00000000;

  always @* begin
        if (onoff == 1'b1) begin
            ans = 8'b11111111;
        end
        else begin
            case (num)
                4'b0000: begin
                    ans = 8'b11000000;
                end
                4'b0001: begin
               ans = 8'b11111001;
            end
            4'b0010: begin
                    ans = 8'b10100100;
                end
                4'b0011: begin
               ans = 8'b10110000;
            end
            4'b0100: begin
                    ans = 8'b10011001;
                end
                4'b0101: begin
               ans = 8'b10010010;
            end
            4'b0110: begin
                    ans = 8'b10000010;
                end
                4'b0111: begin
               ans = 8'b11111000;
            end
                4'b1000: begin
                   ans = 8'b10000000;
                end
            4'b1001: begin
                   ans = 8'b10010000;
                end
                
                default: begin 
                    ans = 8'b01111111;
                end
            endcase
        end
  end
assign segs = ans;
  
endmodule