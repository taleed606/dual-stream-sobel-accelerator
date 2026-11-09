//This stage performs the Sobel convolution
//It calculates how strong the edge is in X and Y directions
module Convolution_Stage (
    input  wire        clk,  
    input  wire        rst,  
    input  wire        valid_in,  //indicates the 3x3 window is valid

    //3x3 pixel window coming from the fetch stage
    //Each wXY is an 8-bit grayscale pixel
    input  wire [7:0]  w00, w01, w02, //top row of the window
    input  wire [7:0]  w10, w11, w12, //middle row of the window
    input  wire [7:0]  w20, w21, w22, //bottom row of the window
	
	//Results are signed because edges have direction
    output reg  signed [11:0] Gx, //Horizontal Sobel gradient
    output reg  signed [11:0] Gy, //Vertical
    output reg         valid_out //valid signal passed to next stage
);



    always @(posedge clk) begin
        if (rst) begin
            Gx        <= 0;
            Gy        <= 0;
            valid_out <= 0;
        end else begin
            //Sobel X kernel:
            //[-1  0 +1]
            //[-2  0 +2]
            //[-1  0 +1]
            //this detects vertical edges
            Gx <= (-w00 + w02)
                + (-2*w10 + 2*w12)
                + (-w20 + w22);

            //Sobel Y kernel:
            //[-1 -2 -1]
            //[ 0  0  0]
            //[+1 +2 +1]
            //this detects horizontal edges
            Gy <= (-w00 -2*w01 -w02)
                + ( w20 +2*w21 +w22);
            valid_out <= valid_in;
        end
    end

endmodule
