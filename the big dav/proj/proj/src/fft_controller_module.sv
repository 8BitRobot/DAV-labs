module fft_controller_module #(
	parameter MAW = 10
)
(
	input clk, rst,
	input start_wr, start_rd,
	output idle,
	
	output reg [MAW-1:0] address_a, address_b,
	output [$clog2(MAW)-1:0] stage,
	output wren_a, wren_b,
	output rd_mic,
	output rd_active,
	input [3:0] sel_addr_wth
);
	
	localparam MAX_ADDR = 2**MAW-1;
	localparam MSW = $clog2(MAW); // MAX_STAGE_WIDTH
	
	reg c_idle;
	reg [2:0] c_state;
	reg [MAW-1:0] c_address_a, c_address_b;
	reg [MSW-1:0] c_stage;
	reg c_wren_a, c_wren_b;
	reg c_rd_mic;
	reg [MAW-1:0] c_max_addr;
	reg [MSW-1:0] c_max_stage;
	reg c_rd_active;
	
	reg n_idle;
	reg [2:0] n_state;
	reg [MAW-1:0] n_address_a, n_address_b;
	reg [MSW-1:0] n_stage;
	reg n_wren_a, n_wren_b;
	reg n_rd_mic;
	reg [MAW-1:0] n_max_addr;
	reg [MSW-1:0] n_max_stage;
	reg n_rd_active;
	
	reg [MAW-1:0] compare;
	
	wire [MAW-1:0] switch_addr;
	
	assign idle = c_idle;
	//assign address_a = c_address_a;
	assign address_b = c_address_b;
	assign wren_a = c_wren_a;
	assign wren_b = c_wren_b;
	assign rd_mic = c_rd_mic;
	assign rd_active = c_rd_active;
	assign stage = c_stage;
	
	bit_switch_box 
	#(.MAW(MAW)) box
	(
	.input_address(c_address_a),  // Input address to be flipped
	.sel_addr_width({1'b0, sel_addr_wth}), // unsigned from 1 to MAW. Minimum is 1. Expects one as a number. 
	.output_address(switch_addr)	 // output address
	);
	
	always_comb begin // code for doing the input switching at the beginning.
		if (c_rd_mic) begin
			address_a = switch_addr;
		end
		else begin
			address_a = c_address_a;
		end
	end
	
	reg [3:0] addr_width;
	
	always_comb begin 
		compare = 0;
		for (int i = 0; i < MAW; i++) begin
			if (i <= c_stage) begin
				compare[i] = c_address_a[i];
			end
		end
	end
	
	localparam IDLE 		= 3'b000;
	localparam ITERATE 	= 3'b001;
	localparam FETCH		= 3'b010;
	localparam COMPUTE 	= 3'b011;
	localparam FINISH 	= 3'b100;
	
	always @(*) begin
		
		n_state		= c_state;
		n_stage		= c_stage;
		n_address_a	= c_address_a;
		n_address_b	= c_address_b;
		n_wren_a 	= c_wren_a;
		n_wren_b 	= c_wren_b;
		n_rd_mic 	= c_rd_mic;
		n_idle		= c_idle;
		n_rd_active = c_rd_active;
		n_max_addr	= c_max_addr;
		n_max_stage	= c_max_stage;
		
		case (c_state)
			IDLE:
			begin
				if (start_wr) begin
					n_address_a = 0;
					n_rd_mic = 1'b1;
					n_wren_a = 1'b1;
					n_idle	= 0;
					n_rd_active = 1'b0;
					n_state = ITERATE;
				end
				else if (start_rd) begin
					n_address_a = 0;
					n_rd_mic = 1'b0;
					n_wren_a = 1'b0;
					n_idle	= 0;
					n_state = ITERATE;
					n_idle	= 0;
					n_rd_active = 1'b1;
				end
				else begin
					n_idle	= 1'b1;
					n_state = IDLE;
					
					n_max_addr = {MAW{1'b1}};
					n_max_addr = n_max_addr << sel_addr_wth;
					n_max_addr = ~n_max_addr; 
					
					n_max_stage = sel_addr_wth-4'd1;
					
					n_rd_active = 1'b0;
				end
			end
			
			ITERATE:
			begin
				if (c_address_a < c_max_addr) begin
					n_address_a = c_address_a + 1'b1;
					n_state = ITERATE;
				end
				else if (c_rd_mic) begin
					n_address_a = 0;
					n_address_b = 1'b1;
					n_wren_a = 0;
					n_wren_b = 0;
					n_rd_mic = 0;
					n_state = FETCH; 
				end
				else begin
					n_address_a = 0;
					n_state = FINISH;
				end
			end
			
			FETCH:
			begin
				n_wren_a	= 1'b1;
				n_wren_b	= 1'b1;
				n_state	= COMPUTE;
			end
			
			COMPUTE:
			begin
				n_wren_a = 0;
				n_wren_b = 0;
				n_state = FETCH;
				
				if (compare < (10'b0001 << c_stage) - 1'b1) begin // Is the value ready to skip over?
					n_address_a = c_address_a + 1'b1; // if not, add one
					n_address_b = c_address_b + 1'b1;
				end 
				else begin
					if (c_address_a + (10'b0001 << c_stage) < c_max_addr) begin // If skipping over, will the value meet or exceed 15?
						n_address_a = c_address_a + 1'b1 + (10'b0001 << c_stage); // Perform the Skipping function
						n_address_b = n_address_a + (10'b0001 << c_stage);
					end 
					else begin // if value exceeds, don't do skipping function and move onto last stage
						if (c_stage == c_max_stage) begin // Did we just finish the last stage?
							n_address_a = 0;
							n_address_b = 1'b1;
							n_stage = 0;
							n_wren_a = 0; // set write to zero. 
							n_wren_b = 0;
							n_state = FINISH;
						end
						else begin
							n_address_a = 0; // set next addr to zero
							n_address_b = n_address_a + (10'b0001 << c_stage + 1);
							n_stage = c_stage + 1'b1; // add one to stage 
						end
					end
				end
			end
			
			FINISH:
			begin
				n_idle  = 1'b1;
				n_rd_active = 1'b0;
				n_state = IDLE;
			end
			
			default:
			begin
				n_state = IDLE;
			end
			
		endcase
	end
	
	always @(posedge clk) begin
		if (rst) begin
				c_idle		= 1;
				c_state		= 0;
				c_address_a	= 0;
				c_address_b	= 0;
				c_stage		= 0;
				c_wren_a		= 0;
				c_wren_b		= 0;
				c_rd_mic		= 0;
				c_max_addr	= 15;
				c_max_stage	= 3;
				c_rd_active = 0;
		end
		else begin
			c_idle		= n_idle;
			c_state		= n_state;
			c_address_a	= n_address_a;
			c_address_b	= n_address_b;
			c_stage		= n_stage;
			c_wren_a		= n_wren_a;
			c_wren_b		= n_wren_b;
			c_rd_mic		= n_rd_mic;
			c_max_addr	= n_max_addr;
			c_max_stage	= n_max_stage;
			c_rd_active	= n_rd_active;
		end
	end
	
endmodule 