module vga_ram (
    input clk, 
    input [15:0] addrWrite,
    input [9:0] addrRead_h, 
    input [9:0] addrRead_v,
    input [7:0] dataWrite, 
    output reg [7:0] dataRead
);

reg writeEnable; // HIGH when writing to ram1
reg writeEnable_d;

reg [7:0] ram1_in;
reg [7:0] ram1_out;
reg [7:0] ram2_in; 
reg [7:0] ram2_out;

ram_ip PING(addrWrite, clk, ram1_in, writeEnable, ram1_out);
ram_ip PONG(addrWrite, clk, ram2_in, ~writeEnable, ram2_out);

localparam HPIXELS = 640; 
localparam VPIXELS = 480;

initial begin
    writeEnable = 0;
    writeEnable_d = 0;
end

always @(posedge clk) begin
    writeEnable <= writeEnable_d;

    if (addrRead_h == HPIXELS-1 && addrRead_v == VPIXELS-1) begin // finished drawing last frame
        writeEnable_d <= ~writeEnable;
    end

end

always_comb begin
    // idk what goes here
    if (writeEnable) begin
        dataRead = ram2_out;
        ram1_in = dataWrite;
        ram2_in = 8'hz;
    end else begin
        dataRead = ram1_out;
        ram1_in = 8'hz;
        ram2_in = dataWrite;
    end
end

endmodule

// sequential:
// WRITE dataWrite to one ram at addrRead_h, addrRead_v
// READ to dataRead from other ram at addrRead_h, addrRead_v

// combinational:
// when writeEnable is 0:
//      set ram1 to read-only
//      set ram2 to write-only
// else
//     set ram1 to write-only
//     set ram2 to read-only
