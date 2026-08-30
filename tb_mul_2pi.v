`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 10:46:44 PM
// Design Name: 
// Module Name: tb_mul_2pi
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

module tb_mul_2pi;

    // Inputs
    reg clk;
    reg valid_in;
    reg [31:0] norm_in;

    // Outputs
    wire valid_out;
    wire [31:0] angle_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    mul_2pi_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .norm_in(norm_in),

        .valid_out(valid_out),
        .angle_out(angle_out)

    );

    //--------------------------------------------------
    // Clock Generation (100 MHz)
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
        norm_in  = 32'h00000000;

        #20;

        valid_in = 1;

        // 0.0 × 2π = 0
        norm_in = 32'h00000000;
        #180;
        norm_in = 32'h3E800000;
        #180;
        // 0.5 × 2π = π
        norm_in = 32'h3F000000;
        #180;
        // 0.75 × 2π = 3π/2
        norm_in = 32'h3F400000;
        #180;
        // 1.0 × 2π = 2π
        norm_in = 32'h3F800000;
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
            $display("Time      : %0t", $time);
            $display("Input     : %h", norm_in);
            $display("Angle Out : %h", angle_out);
        end
    end

endmodule
