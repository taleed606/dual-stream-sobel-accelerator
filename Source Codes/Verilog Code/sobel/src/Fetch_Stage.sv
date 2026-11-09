//This stage receives the image as a 1-pixel-per-clock stream
//It stores previous pixels using line buffers
//From the current pixel and stored rows, it builds a sliding 3x3 window
//The window moves left to right, then top to bottom
//This window is required by the convolution stage (next one)
module Fetch_Stage (
    input  wire        clk,   
    input  wire        rst, 
	input  wire		   valid_in, //tells us if pxl_in is a real pixel
    input  wire [7:0]  pxl_in, //incoming grayscale pixel stream		   
	
    //3x3 window outputs
    //these feed directly into the convolution stage
    output reg  [7:0]  w00, w01, w02, //top row of the window
    output reg  [7:0]  w10, w11, w12, //middle row of the window
    output reg  [7:0]  w20, w21, w22, //bottom row of the window

    output reg         valid_out   //when the 3×3 window is valid
);

    parameter WIDTH  = 256;	//Number of columns in the image
    parameter HEIGHT = 256; //Rows

    //line1 stores the previous row
    //line2 stores the row before that
    reg [7:0] line1 [0:WIDTH-1];
    reg [7:0] line2 [0:WIDTH-1];

    integer i;
	
	//column and row counters
    reg [8:0] col;   // 0..255 9 bit because width + 1 (255+1)
    reg [8:0] row; 

    always @(posedge clk) begin
        if (rst) begin
            col   <= 0;
            row   <= 0;
            valid_out <= 0;
            w00 <= 0; w01 <= 0; w02 <= 0;
            w10 <= 0; w11 <= 0; w12 <= 0;
            w20 <= 0; w21 <= 0; w22 <= 0;
            for (i = 0; i < WIDTH; i = i + 1) begin
                line1[i] <= 0;
                line2[i] <= 0;
            end
        end else begin
            //Shift the 3×3 window horizontally (left)
            //Old pixels move left as a new column arrives
            w00 <= w01;  w01 <= w02;
            w10 <= w11;  w11 <= w12;
            w20 <= w21;  w21 <= w22;
			
            //Insert the new rightmost column of the window
            w02 <= line2[col];
            w12 <= line1[col];
            w22 <= pxl_in;
           
			//Update line buffers with the new pixel
            line2[col] <= line1[col];
            line1[col] <= pxl_in;

            //A valid 3×3 window exists only if:
            //at least 2 full rows have been received
            //at least 2 columns have been received
            valid_out <= ((row >= 2) && (col >= 2) && valid_in) ;

            if (col == WIDTH-1) begin
                //End of row
                col <= 0;
                if (row != HEIGHT-1)
                    row <= row + 1;
            end else begin
                //Move to next column
                col <= col + 1;
            end
        end
    end
endmodule