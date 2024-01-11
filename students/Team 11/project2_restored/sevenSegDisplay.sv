module sevenSegDisplay(
    input [19:0] num,
  	input o,
  	output [47:0] segs
);
    //reg[19:0] n = num;
  reg[3:0] dig1 = 4'b0;
  reg[3:0] dig2 = 4'b0;
  reg[3:0] dig3 = 4'b0;
  reg[3:0] dig4 = 4'b0;
  reg[3:0] dig5 = 4'b0;
  reg[3:0] dig6 = 4'b0;
  wire[47:0] digOutput;
  
  sevenSegDigit d1(.num(dig1),.onoff(o),.segs(digOutput[7:0]));
  sevenSegDigit d2(.num(dig2),.onoff(o),.segs(digOutput[15:8]));
  sevenSegDigit d3(.num(dig3),.onoff(o),.segs(digOutput[23:16]));
  sevenSegDigit d4(.num(dig4),.onoff(o),.segs(digOutput[31:24]));
  sevenSegDigit d5(.num(dig5),.onoff(o),.segs(digOutput[39:32]));
  sevenSegDigit d6(.num(dig6),.onoff(o),.segs(digOutput[47:40]));
  
  always @* begin
  	dig1 = num%10;
    dig2 = (num/10)%10;
    dig3 = (num/100)%10;
    dig4 = (num/1000)%10;
    dig5 = (num/10000)%10;
    dig6 = (num/100000)%10;
  end
assign segs = digOutput;
endmodule