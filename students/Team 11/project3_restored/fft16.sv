`timescale 1ns/1ns

module fft16 #(parameter WIDTH = 16)(
  input [WIDTH-1:0] samples[0:3],
  input clk,rst,start,
  output reg [WIDTH-1:0] outputs[0:3],
  output reg done
);
  
  parameter RESET = 0;
  parameter STAGE1 = 1;
  parameter STAGE2 = 2;
  parameter FIN = 3;
  reg[2:0] state = 0; 
  
  reg[WIDTH-1:0] a1,b1,w1;
  reg[WIDTH-1:0] a2,b2,w2;
  butterfly16 but1(a1,b1,w1,outputs[0],outputs[2]);
  butterfly16 but2(a2,b2,w2,outputs[1],outputs[3]);
  
  always @(posedge clk) begin
    case (state)
      RESET: begin
        //outputs[0]<=0;
        //outputs[1]<=0;
        //outputs[2]<=0;
        //outputs[3]<=0;
        
        if(start == 1)
          state <= STAGE1;
      end 
      
      STAGE1: begin
        a1 <= samples[0];
        b1 <= samples[2];
        w1 <= 16'b0111111100000000; // 1
        a2 <= samples[1];
        b2 <= samples[3];
        w2 <= 16'b0111111100000000; // 1
        state <= STAGE2;
      end
      
      STAGE2: begin
        a1 <= outputs[0];
        b1 <= outputs[1];
        w1 <= 16'b0111111100000000; // 1
        a2 <= outputs[2];
        b2 <= outputs[3];
        // w2 <= 16'b0000000010000001; // -j
		  w2 <= 16'b0000000001111111; // +j
        state <= FIN;
      end
      
      FIN: begin
        done <= 1;
        
        if(rst == 1) begin
          	done <= 0;
          	state <= RESET;
        end
      end
    endcase
  end 
endmodule

module butterfly16 #(parameter WIDTH = 16)(
    input signed[WIDTH-1:0] a,b,w,
    output signed[WIDTH-1:0] plus,minus
);
  reg signed[WIDTH-1:0] a_real=0,a_im=0,b_real=0,b_im=0,w_real=0,w_im=0;
  
  reg signed [WIDTH-1:0] wb_real, wb_im;
  assign plus = {a_real[WIDTH/2-1:0]+wb_real[WIDTH-2:WIDTH/2-1],a_im[WIDTH/2-1:0]+wb_im[WIDTH-2:WIDTH/2-1]};
  assign minus = {a_real[WIDTH/2-1:0]-wb_real[WIDTH-2:WIDTH/2-1],a_im[WIDTH/2-1:0]-wb_im[WIDTH-2:WIDTH/2-1]};

  always @(*) begin
    a_real <= a[WIDTH-1:WIDTH/2];
    a_im <= a[WIDTH/2-1:0];
    b_real <= b[WIDTH-1:WIDTH/2];
    b_im <= b[WIDTH/2-1:0];
    w_real <= w[WIDTH-1:WIDTH/2];
    w_im <= w[WIDTH/2-1:0];  

    wb_real <= (w_real*b_real - w_im*b_im);
    wb_im <= (w_im*b_real+w_real*b_im);
  end
  
endmodule