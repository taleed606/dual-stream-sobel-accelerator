//Connects all pipeline blocks to form a complete Sobel edge detector
module Top_One_Wide (
    input  wire        clk,       //System clock
    input  wire        rst,     
    input  wire        valid_in,  //Input pixel valid
    input  wire [7:0]  pxl_in,    //Grayscale input pixel

    output wire [12:0] edge_out,  //Final edge result
    output wire        valid_out  //Output valid
);	

    //Stage 1:Fetch
    wire [7:0] w00,w01,w02;
    wire [7:0] w10,w11,w12;
    wire [7:0] w20,w21,w22;
    wire       v1;

    //Stage 2:Sobel convolution
    wire signed [11:0] Gx, Gy;
    wire               v2;

    //Stage 3:Absolute values
    wire [11:0] abs_Gx, abs_Gy;
    wire         v3;

    //Stage 4:Magnitude calculation
    wire [12:0] mag;
    wire         v4; 	  

    //Stage 5:Thresholding
    wire [12:0] edge_post;
    wire        v5;

    Fetch_Stage u_stage1 (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .pxl_in(pxl_in),
        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),
        .valid_out(v1)
    );

    Convolution_Stage u_stage2 (
        .clk(clk),
        .rst(rst),
        .valid_in(v1),
        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),
        .Gx(Gx),
        .Gy(Gy),
        .valid_out(v2)
    );

    Absolute_Stage u_stage3 (
        .clk(clk),
        .rst(rst),
        .valid_in(v2),
        .Gx(Gx),
        .Gy(Gy),
        .abs_Gx(abs_Gx),
        .abs_Gy(abs_Gy),
        .valid_out(v3)
    );

    Magnitude_Stage u_stage4 (
        .clk(clk),
        .rst(rst),
        .valid_in(v3),
        .abs_Gx(abs_Gx),
        .abs_Gy(abs_Gy),
        .edge_out(mag),
        .valid_out(v4)
    );	
	
    Thresholding_Stage #(
        .TH(13'd300) 
    ) u_stage5 ( 
        .clk(clk),
        .rst(rst),
        .valid_in(v4),
        .mag_in(mag),
        .edge_out(edge_post),
        .valid_out(v5)
    );
	
    //Final outputs
    assign edge_out  = edge_post;
    assign valid_out = v5;

endmodule
