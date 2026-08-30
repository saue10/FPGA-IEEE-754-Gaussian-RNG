`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 06:37:51 PM
// Design Name: 
// Module Name: tb_mul_2pi_wrapper
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

module tb_mul_2pi_wrapper;

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
        norm_in  = 0;

        #20;

        valid_in = 1;

        // 0.0
        norm_in = 32'h00000000;
        #180;

        // 0.5
        norm_in = 32'h3F000000;
        #180;

        // 1.0
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
