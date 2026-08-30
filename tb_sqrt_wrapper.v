`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 06:28:51 PM
// Design Name: 
// Module Name: tb_sqrt_wrapper
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

module tb_sqrt_wrapper;

    // Inputs
    reg clk;
    reg valid_in;
    reg [31:0] mul_in;

    // Outputs
    wire valid_out;
    wire [31:0] sqrt_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    sqrt_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .mul_in(mul_in),

        .valid_out(valid_out),
        .sqrt_out(sqrt_out)

    );

    //--------------------------------------------------
    // Clock (100 MHz)
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
        mul_in = 0;

        #20;

        valid_in = 1;

        // sqrt(0.0) = 0.0
        mul_in = 32'h00000000;
        #180;

        // sqrt(1.0) = 1.0
        mul_in = 32'h3F800000;
        #180;

        // sqrt(4.0) = 2.0
        mul_in = 32'h40800000;
        #180;

        // sqrt(9.0) = 3.0
        mul_in = 32'h41100000;
        #180;

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
            $display("Time     : %0t", $time);
            $display("Input    : %h", mul_in);
            $display("Sqrt Out : %h", sqrt_out);
        end
    end

endmodule