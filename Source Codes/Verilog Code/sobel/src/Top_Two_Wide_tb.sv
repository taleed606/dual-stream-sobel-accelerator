`timescale 1ns / 1ps

module Top_Two_Wide_tb();

    reg         clk;
    reg         rst;
    reg [23:0]  pxl_in_upper;
    reg [23:0]  pxl_in_lower;

    wire [12:0] edge_out_upper;
    wire [12:0] edge_out_lower;	 
    wire        valid_out_upper;
    wire        valid_out_lower;

    //DUT
    Top_Two_Wide dut (
        .clk(clk),
        .rst(rst),
        .pxl_in_upper(pxl_in_upper),
        .pxl_in_lower(pxl_in_lower),  
        .edge_out_upper(edge_out_upper),   
        .edge_out_lower(edge_out_lower),
        .valid_out_upper(valid_out_upper),
        .valid_out_lower(valid_out_lower)
    );				  
	
    //clock generation:100MHz
    always #5 clk = ~clk;  

    //Image memory
    reg [23:0] image_mem [0:65535];
    integer i, j;
    integer fout_upper, fout_lower;	

    initial begin
        //Initial values
        clk = 0;
        rst = 1;
        pxl_in_upper = 0;
        pxl_in_lower = 0;	
		
        //Load input image
        $readmemh("../../../input_image/img_input.mem", image_mem);
        $display("here");
		
        //Open output files
        fout_upper = $fopen("../../output_image/img_output_upper.txt", "w");	
        fout_lower = $fopen("../../output_image/img_output_lower.txt", "w");	

        #20 rst = 0;
		
        //Feed pixels to both streams
        for (i = 0, j = 65536/2 - 1;
             i < 65536/2 + 1 && j < 65536;
             i = i + 1, j = j + 1) begin
            @(posedge clk);
            pxl_in_upper <= image_mem[i];
            pxl_in_lower <= image_mem[j];
        end	 

        //Make sure all pixels continue in the pipe
        repeat (20) @(posedge clk);

        $fclose(fout_upper);
        $fclose(fout_lower);
        $stop;
    end

    //Write outputs when valid
    always @(posedge clk) begin
        if (!rst) begin
            if (valid_out_upper)
                $fwrite(fout_upper, "%h\n", edge_out_upper);
            else
                $fwrite(fout_upper, "%h\n", 13'd0);

            if (valid_out_lower)
                $fwrite(fout_lower, "%h\n", edge_out_lower);
            else
                $fwrite(fout_lower, "%h\n", 13'd0);
        end
    end

endmodule
