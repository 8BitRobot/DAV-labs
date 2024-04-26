module butterflyUnit #(WIDTH) (in_A, in_B, twiddle, out_add, out_sub);
	input reg [WIDTH-1:0] in_A, in_B;
	input reg [WIDTH-1:0] twiddle;
	output reg [WIDTH-1:0] out_add, out_sub;

   reg signed [WIDTH-1:0] product_W_B_r, product_W_B_x;
	reg signed [(WIDTH / 2)-1:0] processed_product_W_B_r, processed_product_W_B_x;
	reg signed [(WIDTH / 2)-1:0] out_add_r, out_add_x, out_sub_r, out_sub_x;
   reg signed [(WIDTH / 2)-1:0] in_A_r, in_A_x, in_B_r, in_B_x, twiddle_r, twiddle_x;
	
   always_comb begin
		
		// separate real and imag components
		in_A_r = in_A[WIDTH-1:(WIDTH / 2)];
		in_A_x = in_A[(WIDTH/2)-1:0];
		in_B_r = in_B[WIDTH-1:(WIDTH / 2)];
		in_B_x = in_B[(WIDTH/2)-1:0];
		twiddle_r = twiddle[WIDTH-1:(WIDTH / 2)];
		twiddle_x = twiddle[(WIDTH/2)-1:0];
		
		// multiply twiddle W by B
      product_W_B_r = (in_B_r * twiddle_r - in_B_x * twiddle_x); //real part
		product_W_B_x = (in_B_x * twiddle_r + in_B_r * twiddle_x); //imag part
		
		// extract and right shift useful bits
      processed_product_W_B_r = product_W_B_r[(WIDTH)-2:(WIDTH / 2)-1]; // real part
		processed_product_W_B_x = product_W_B_x[(WIDTH)-2:(WIDTH / 2)-1]; // imag part

      // add A with product of W and B
      out_add_r = in_A_r + processed_product_W_B_r;
		out_add_x = in_A_x + processed_product_W_B_x;
		out_add = {out_add_r, out_add_x};

      // subtract B with product of W and B
      out_sub_r = in_A_r - processed_product_W_B_r;
		out_sub_x = in_A_x - processed_product_W_B_x;
		out_sub = {out_sub_r, out_sub_x};

   end
    
endmodule