//Top module
//Runs two Sobel pipelines in parallel for upper and lower image halves
module Top_Two_Wide (
    input  wire        clk,    
    input  wire        rst,   
    input  wire [23:0] pxl_in_upper, //RGB pixel for upper stream
    input  wire [23:0] pxl_in_lower, //RGB pixel for lower stream

    output wire [12:0] edge_out_upper, //edge output for upper half
    output wire [12:0] edge_out_lower, //edge output for lower half
    output wire        valid_out_upper, //valid for upper output
    output wire        valid_out_lower  //valid for lower output
);	 	 	

    //Grayscale pixels for each stream
	wire [7:0] pxl_in_gray_upper;
    wire [7:0] pxl_in_gray_lower;
    wire       valid_in;

    //Convert RGB inputs to grayscale
	RGB_to_grayscale u_stage1(
	  	.clk(clk),
      	.rst(rst),
        .pxl_in_upper(pxl_in_upper),
		.pxl_in_lower(pxl_in_lower),
        .pxl_out_upper(pxl_in_gray_upper), 
		.pxl_out_lower(pxl_in_gray_lower),
        .valid(valid_in)
	);

    //Upper Sobel pipeline
    Top_One_Wide upper (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .pxl_in(pxl_in_gray_upper),
        .edge_out(edge_out_upper),
        .valid_out(valid_out_upper)
    ); 	  
	
    //Lower Sobel pipeline
	Top_One_Wide lower (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .pxl_in(pxl_in_gray_lower),
        .edge_out(edge_out_lower),
        .valid_out(valid_out_lower)
    );

endmodule
