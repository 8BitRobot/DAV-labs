/*
module PingPongRam(
    input logic clk,
    input logic rst,
    input logic [18:0] addrWrite, // Adjusted to 19 bits
    input logic [9:0] addrRead_h,
    input logic [9:0] addrRead_v,
    input logic [7:0] dataWrite, // Adjusted for 12-bit color depth
    output logic [7:0] dataRead // Matched with dataWrite for consistency
);

localparam RAM_SIZE = 307200;
localparam SCREEN_WIDTH = 640;


// Define your RAM arrays
reg [7:0] ram1 [RAM_SIZE-1:0];
reg [7:0] ram2 [RAM_SIZE-1:0]; // Second RAM array

reg writeEnable_reg;

// Toggle write enable sequentially
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        writeEnable_reg <= 0;
    end else if (addrRead_h == 0 && addrRead_v == 0) begin
        writeEnable_reg <= ~writeEnable_reg; // Toggle writeEnable
    end
end


// Read and write data to the RAM
always_comb begin
    if (writeEnable_reg) begin
        // Write data to ram1
        ram1[addrWrite] = dataWrite;
        // Read data from ram2
        dataRead = ram2[addrRead_h + addrRead_v * SCREEN_WIDTH]; //addrWrite = addrRead_h + addrRead_v * SCREEN_WIDTH
    end else begin
        // Write data to ram2
        ram2[addrWrite] = dataWrite;
        // Read data from ram1
        dataRead = ram1[addrRead_h + addrRead_v * SCREEN_WIDTH];
    end
end

endmodule
*/

module PingPongRam(
    input logic clk,
    input logic rst,
    input logic [18:0] addrWrite, // Ensure this doesn't exceed the new RAM bounds
    input logic [9:0] addrRead_h, 
    input logic [9:0] addrRead_v, 
    input logic [7:0] dataWrite,   // Adjusted for 12-bit color depth
    output logic [7:0] dataRead    // Matched with dataWrite for consistency
);

localparam BLOCK_SIZE = 10; // creates a 10x10 block
localparam NEW_SCREEN_WIDTH = 640 / BLOCK_SIZE;
localparam NEW_SCREEN_HEIGHT = 480 / BLOCK_SIZE;
localparam NEW_RAM_SIZE = NEW_SCREEN_WIDTH * NEW_SCREEN_HEIGHT;

reg [7:0] ram1 [NEW_RAM_SIZE-1:0];
reg [7:0] ram2 [NEW_RAM_SIZE-1:0];

reg writeEnable_reg; 

// Toggle write enable sequentially
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        writeEnable_reg <= 0;
    end else if (addrRead_h == 0 && addrRead_v == 0) begin
        writeEnable_reg <= ~writeEnable_reg; // Toggle writeEnable_reg
    end
end


always_ff @(posedge clk) begin
    if (writeEnable_reg) begin
        ram1[addrWrite % NEW_RAM_SIZE] <= dataWrite; // write to ram1 when writeEnable = high
    end else begin
        ram2[addrWrite % NEW_RAM_SIZE] <= dataWrite; // write to ram2 when writeEnable = low
    end
end

always_comb begin
    dataRead = 8'b00000000; // default value just in case
    if (writeEnable_reg) begin
        dataRead = ram2[(addrRead_h / BLOCK_SIZE) + (addrRead_v / BLOCK_SIZE) * NEW_SCREEN_WIDTH];
    end else begin
        dataRead = ram1[(addrRead_h / BLOCK_SIZE) + (addrRead_v / BLOCK_SIZE) * NEW_SCREEN_WIDTH];
    end
end

endmodule

