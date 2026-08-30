`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:40:36 PM
// Design Name: 
// Module Name: tb_fixed_to_float_wrapper
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

module tb_fixed_to_float_wrapper;

    // Inputs
    reg clk;
    reg valid_in;
    reg [31:0] fixed_in;

    // Outputs
    wire valid_out;
    wire [31:0] float_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    fixed_to_float_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .fixed_in(fixed_in),

        .valid_out(valid_out),
        .float_out(float_out)

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
        fixed_in = 32'h00000000;

        #20;

        valid_in = 1;

        // 0.0
        fixed_in = 32'h00000000;
        #100;

        // +0.5 (Q1.31)
        fixed_in = 32'h40000000;
        #100;

        // Maximum positive (≈1.0)
        fixed_in = 32'h7FFFFFFF;
        #100;

        // -0.5 (Q1.31)
        fixed_in = 32'hC0000000;
        #100;

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
            $display("Fixed In  : %h", fixed_in);
            $display("Float Out : %h", float_out);
        end
    end

endmodule
