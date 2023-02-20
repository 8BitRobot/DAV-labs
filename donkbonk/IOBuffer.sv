module IOBuffer(in, out, enable, port);
	input in, enable;
	output out;
	inout port;
	
	assign port = enable ? in : 1'bz;
	assign out = ~enable ? port : 1'b0;

endmodule