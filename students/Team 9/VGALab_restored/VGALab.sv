// Top-level module
module VGALab(
    input wire clk,  
    input wire rst,     
	 output wire hsync,
	 output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);


   logic clk_25MHz;
	 
	
	logic [2:0] input_red;
	logic [2:0] input_green;
	logic [1:0] input_blue;
	
	logic [7:0] dataRead;
	logic [7:0] dataWrite;
	logic [18:0] addrWrite;
	
	//assign input_red   = dataRead[7:5]; 
	//assign input_green = dataRead[4:2];  
	//assign input_blue  = dataRead[1:0];   
	
	assign input_red = 3'b111;
	assign input_green = 3'b100;
	assign input_blue = 2'b00;
   wire [9:0] hc_out, vc_out;

  
    myPLL pll_instance (
    .areset(rst),        
    .inclk0(clk),        
    .c0(clk_25MHz),      
    .locked()            
);


    // Instantiate the VGA module
    vga vga_inst (
        .vgaclk(clk_25MHz),
        .input_red(input_red),
        .input_green(input_green),
        .input_blue(input_blue),
        .rst(rst),
		  
        .hc_out(hc_out), 
        .vc_out(vc_out),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );
	 /*
	PingPongRam ping(
		.clk(clk_25MHz), 
		.rst(rst),
		.addrWrite(addrWrite),
		.addrRead_h(hc_out),
		.addrRead_v(vc_out),
		.dataWrite(dataWrite),
		
		.dataRead(dataRead) 
	);

	graphics grap(
		.hc_out(hc_out), 
		.vc_out(vc_out),
		
		.color(dataWrite), 
		.addrWrite(addrWrite)
	);

 */
endmodule