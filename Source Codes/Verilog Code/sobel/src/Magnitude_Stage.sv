//This stage computes how strong the edge is at each pixel
//Instead of using sqrt(Gx^2 + Gy^2), which is expensive in hardware
//We use abs(Gx) + abs(Gy) as an approximation
module Magnitude_Stage (
    input  wire        clk, 
    input  wire        rst,    
    input  wire        valid_in,  //indicates abs_Gx and abs_Gy are valid

    input  wire [11:0] abs_Gx,    //absolute value of Sobel X gradient
    input  wire [11:0] abs_Gy,    //absolute value of Sobel Y gradient

    output reg  [12:0] edge_out,  //Magnitude
    output reg         valid_out  //valid signal passed to next stage
);


    always @(posedge clk) begin
        if (rst) begin
            edge_out  <= 0;
            valid_out <= 0;
        end else begin
            //add the absolute gradients
            edge_out <= abs_Gx + abs_Gy;
            valid_out <= valid_in;
        end
    end

endmodule
