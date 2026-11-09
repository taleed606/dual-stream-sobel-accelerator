//This module converts incoming RGB pixels into grayscale values
//It uses shift-based arithmetic to compute grayscale efficiently in hardware
module RGB_to_grayscale (
    input  wire        clk,     
    input  wire        rst,     
    input  wire [23:0] pxl_in_upper, //RGB pixel for upper stream
    input  wire [23:0] pxl_in_lower, //for lower stream

    output reg  [7:0]  pxl_out_upper, //grayscale pixel for upper stream
    output reg  [7:0]  pxl_out_lower, //for lower stream

    output reg         valid       //output pixel is valid
);

    parameter WIDTH  = 256;
    parameter HEIGHT = 256;
	
    //Split RGB channels for upper pixel
	wire [7:0] r_upper = pxl_in_upper[23:16];
    wire [7:0] g_upper = pxl_in_upper[15:8];
    wire [7:0] b_upper = pxl_in_upper[7:0];	
	
    //Split RGB channels for lower pixel
	wire [7:0] r_lower = pxl_in_lower[23:16];
    wire [7:0] g_lower = pxl_in_lower[15:8];
    wire [7:0] b_lower = pxl_in_lower[7:0];
	
	//Gray = (77*R + 150*G + 29*B)/256	  
	// 77 = 64 + 8 + 4 + 1
	// 150 = 128 + 16 + 4 + 2
	// 29 = 16 + 8 + 4 + 1 				  
	//To accelerate the above calculation, we will use the shift operations instead of multiplication
	wire [15:0] gray_value_upper;
    assign gray_value_upper =
        (r_upper << 6) + (r_upper << 3) + (r_upper << 2) + r_upper +
        (g_upper << 7) + (g_upper << 4) + (g_upper << 2) + (g_upper << 1) +
        (b_upper << 4) + (b_upper << 3) + (b_upper << 2) + b_upper;    
						   
	wire [15:0] gray_value_lower;
    assign gray_value_lower =
        (r_lower << 6) + (r_lower << 3) + (r_lower << 2) + r_lower +
        (g_lower << 7) + (g_lower << 4) + (g_lower << 2) + (g_lower << 1) +
        (b_lower << 4) + (b_lower << 3) + (b_lower << 2) + b_lower; 
	

    always @(posedge clk) begin
        if (rst) begin
            pxl_out_upper <= 8'd0;	 
			pxl_out_lower <= 8'd0;
            valid <= 1'b0;
        end else begin
            //take the upper 8 bits as the grayscale value
          	pxl_out_upper <= gray_value_upper[15:8];
			pxl_out_lower <= gray_value_lower[15:8];
			valid <= 1'b1;
        end
    end

endmodule
