`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 05:56:48 PM
// Design Name: 
// Module Name: tb_normalize_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_normalize_wrapper;

    // Inputs
    reg clk;
    reg valid_in;
    reg [31:0] float_in;

    // Outputs
    wire valid_out;
    wire [31:0] norm_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    normalize_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .float_in(float_in),

        .valid_out(valid_out),
        .norm_out(norm_out)

    );

    //--------------------------------------------------
    // Clock
    //--------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------
    // Test Stimulus
    //--------------------------------------------------

    initial begin

        valid_in = 0;
        float_in = 0;

        #20;

        valid_in = 1;

        // 0.0
        float_in = 32'h00000000;
        #90;

        // 1.0
        float_in = 32'h3F800000;
        #90;

        // 2.0
        float_in = 32'h40000000;
        #90;

        // 100.0
        float_in = 32'h42C80000;
        #90;

        valid_in = 0;

        #100;

        $finish;

    end

    //--------------------------------------------------
    // Monitor
    //--------------------------------------------------

    always @(posedge clk)
    begin
        if(valid_out)
        begin
            $display("--------------------------------");
            $display("Time      : %0t", $time);
            $display("Input     : %h", float_in);
            $display("Normalized: %h", norm_out);
        end
    end

endmodule
