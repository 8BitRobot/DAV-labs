module IOBuffer(in, out, enable, port);
	input in, enable;
	output out;
	inout port;
	//TODO: complete IOBuffer as described in the lab spec.
	
	assign out = (~enable) ? port : 1'b0;
	assign port = (enable) ? in : 1'bz;
endmodule