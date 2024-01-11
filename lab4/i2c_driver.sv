module i2c_driver(
	input clk,
	input polling_clk,
	input [6:0] device_addr,
	input [7:0] reg_addr,
	input [3:0] num_bytes,
	input write, // 0 = write, 1 = read
	output reg [7:0] data_read [0:7],
	output reg scl,
   inout sda
);

	reg  sda_in = 0;
	wire sda_out;
	reg  sda_write_enable;

	IOBuffer sdaTristateBuffer(sda_in, sda_write_enable, sda_out, sda);

	reg [6:0] device_addr_valid   = 0;
	reg [7:0] reg_addr_valid      = 0;
	reg [3:0] num_bytes_valid     = 0;
	reg write_valid               = 0;
	
	reg [8:0] device_addr_write_valid_concat;
	reg [8:0] reg_addr_write_valid_concat;

	localparam START       = 0;
	localparam DEVICE_ADDR = 1;
	localparam REG_ADDR    = 2;
	localparam WRITING     = 3;
	localparam READING     = 4;
	localparam STOP        = 5;
	localparam IDLE        = 6;

	reg [1:0] subbit = 0;
	reg [1:0] subbit_d;
	
	reg [3:0] bit_cnt = 0;
	reg [3:0] bit_cnt_d = 0;
	
	reg [2:0] state = IDLE;
	reg [2:0] next_state;
	
	reg [1:0] polling_clk_sr;
	reg polling_clk_pulsed;
	
	always @(posedge clk) begin
		polling_clk_sr <= { polling_clk_sr[0], polling_clk };
		subbit <= subbit_d;
		state <= next_state;
		bit_cnt <= bit_cnt_d;
		
		//data_read[current_byte_num][bit_cnt] <= 
		
		if (polling_clk_pulsed) begin
			device_addr_valid <= device_addr;
			reg_addr_valid <= reg_addr;
			num_bytes_valid <= num_bytes;
			write_valid <= write;
		end
	end
	
	always_comb begin
		if (state == IDLE) subbit_d = 0;
		else subbit_d = subbit + 1;
		
		polling_clk_pulsed = polling_clk_sr == 2'b01;
		
		scl = (subbit == 1 || subbit == 2);
		
		device_addr_write_valid_concat = { device_addr_valid, write_valid, 1'bz };
		reg_addr_write_valid_concat    = { reg_addr_valid, 1'bz };
		
		case (state)
			IDLE: begin
				if (polling_clk_pulsed) begin
					next_state = START;
				end else begin
					next_state = IDLE;
				end
				
				bit_cnt_d = 0;
				sda_in = 'bz;
				sda_write_enable = 1;
			end
			
			START: begin
				sda_write_enable = 1;
				
				if (subbit == 3) begin
					next_state = DEVICE_ADDR;
					bit_cnt_d = 8;
				end else begin
					next_state = state;
					bit_cnt_d = 0;
				end				
					
				if (subbit == 0 || subbit == 1) begin
					sda_in = 1;
				end else begin
					sda_in = 0;
				end
			end
			
			DEVICE_ADDR: begin
				sda_in = device_addr_write_valid_concat[bit_cnt];
					
				if (bit_cnt == 0) begin
					sda_write_enable = 0;
				end else begin
					sda_write_enable = 1;
				end
				
				if (subbit == 3) begin		
				
					if (bit_cnt == 0) begin
					
						if (sda_out == 0) begin
							bit_cnt_d = 8;
							next_state = REG_ADDR;
						end else begin
							bit_cnt_d = 0;
							next_state = STOP;
						end
						
					end else begin
					   bit_cnt_d = bit_cnt - 1;
						next_state = state;
					end
				end else begin
					bit_cnt_d = bit_cnt;
					next_state = state;
				end
			end
			
			REG_ADDR: begin
				sda_in = reg_addr_write_valid_concat[bit_cnt];
				
				if (bit_cnt == 0) begin
					sda_write_enable = 0;
				end else begin
					sda_write_enable = 1;
				end
				
				if (subbit == 3) begin	
				
					if (bit_cnt == 0) begin
					
						if (sda_out == 0) begin
							
							if (write_valid == 0) begin
								bit_cnt_d = 8;
								next_state = START;
							end else begin
								bit_cnt_d = 8;
								next_state = READ;
							end
							
						end else begin
							bit_cnt_d = 0;
							next_state = STOP;
						end
						
					end else begin
					   bit_cnt_d = bit_cnt - 1;
						next_state = state;
					end
				end else begin
					bit_cnt_d = bit_cnt;
					next_state = state;
				end
			end
			
			//READING: begin
				//sda_in = 0;
				
				
				//if (subbit == 1) begin
				//end
			//end
			
			STOP: begin
				if (subbit == 3) begin
					next_state = IDLE;
				end else begin
					next_state = state;
				end
				
				if (subbit == 0 || subbit == 1) begin
					sda_in = 0;
				end else begin
					sda_in = 1;
				end
				
				bit_cnt_d = 0;
				sda_write_enable = 1;
			end
			
			default: begin
				 next_state = state;
				 sda_in = 1'bz;
				 bit_cnt_d = bit_cnt;
				 sda_write_enable = 0;
			end
		endcase
	end
endmodule