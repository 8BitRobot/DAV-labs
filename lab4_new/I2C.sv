`timescale 1ns/1ns
module I2C #(parameter MAX_BYTES = 6) (clk, rst, poll_clk, scl, sda);
	input clk, rst, poll_clk;
	output logic scl;
	inout sda;
	
	localparam RESET = 0;
	localparam START = 1;
	localparam IDLE = 2;
	
	reg [2:0] state = RESET;
	reg [2:0] next_state = RESET;
	
	reg dataIn;
	reg dataOut;
	reg enable = 1'b1;
	
	reg doneSending;
	
	IOBuffer iobuf(dataIn, dataOut, enable, sda);
	
	reg [1:0] subbit_count = 2'b0;
	
	always @(posedge clk) begin
		subbit_count <= subbit_count + 1;
		case (subbit_count)
			0: begin
				scl <= 1;
				dataIn <= 1;
			end
			1: begin
				dataIn <= 0;
			end
			2: begin
				scl <= 0;
			end
			3: begin
				dataIn <= 1;
				doneSending = 1;
			end
		endcase
	end
	
	always @(negedge clk) begin
		state <= next_state;
	end
	
	always_comb begin
		case (state) begin
			RESET: begin
				if (poll) begin
					nextState = START;
				end else begin
					nextState = RESET;
				end
			end
			START: begin
				if (doneSending) begin
					nextState = IDLE;
				end else begin
					nextState = START;
				end
			end
			IDLE: begin
				if (delayCounter > 8'd250) begin
					nextState = RESET;
				end else begin
					nextState = IDLE;
				end
			end
		end
	end
endmodule