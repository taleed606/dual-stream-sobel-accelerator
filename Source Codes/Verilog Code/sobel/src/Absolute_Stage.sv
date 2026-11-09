//This stage runs every clock edge
//Its only job is to remove the sign from Gx and Gy
//Sobel produces signed values, but magnitude needs positive numbers
module Absolute_Stage (
    input  wire        clk,       
    input  wire        rst,       //Synchronous reset for the pipeline
    input  wire        valid_in,  //Tells us if Gx and Gy are real data or garbage
    input  wire signed [11:0] Gx, //Sobel gradient in X direction
    input  wire signed [11:0] Gy, // // // in Y direction

    output reg  [11:0] abs_Gx,    //Absolute value of Gx
    output reg  [11:0] abs_Gy,    //Absolute value of Gy
    output reg         valid_out  //Valid signal forwarded to next stage
);

    always @(posedge clk) begin
        if (rst) begin
            //when reset is active => clear everything
            abs_Gx   <= 0;
            abs_Gy   <= 0;
            valid_out <= 0;
        end else begin
            //Gx[11] is the sign bit (1 = negative)
            //if negative, take twos complement
            //if positive, keep the value
            abs_Gx <= Gx[11] ? -Gx : Gx;

            //same exact logic for Gy
            abs_Gy <= Gy[11] ? -Gy : Gy;
            valid_out <= valid_in;
        end
    end

endmodule
