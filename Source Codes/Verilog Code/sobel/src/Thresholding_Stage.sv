//This stage decides if a pixel is an edge or not
//It compares the edge magnitude with a fixed threshold
//If the magnitude is strong enough, the pixel is marked as an edge
module Thresholding_Stage (
    input  wire        clk,   
    input  wire        rst, 
    input  wire        valid_in,  //indicates mag_in is valid data
    input  wire [12:0] mag_in,    //edge magnitude from mag stage

    output reg  [12:0] edge_out,  //final binary edge result
    output reg         valid_out  //valid signal passed to output
);
  
    parameter TH = 13'd300; //edge detection threshold

    always @(posedge clk) begin
        if (rst) begin
            edge_out  <= 13'd0;
            valid_out <= 1'b0;
        end else begin
            //compare magnitude with threshold
            //if mag_in is larger or equal, output an edge
            //edge is represented as 1
            edge_out <= (mag_in >= TH) ? 1'b1 : 1'b0;
            valid_out <= valid_in;
        end
    end

endmodule
