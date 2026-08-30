`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 06:19:40 PM
// Design Name: 
// Module Name: tb_mul_minus2_wrapper
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

module tb_mul_minus2_wrapper;

    // Inputs
    reg clk;
    reg valid_in;
    reg [31:0] ln_in;

    // Outputs
    wire valid_out;
    wire [31:0] mul_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    mul_minus2_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .ln_in(ln_in),

        .valid_out(valid_out),
        .mul_out(mul_out)

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
        ln_in = 0;

        #20;

        valid_in = 1;

        // 0.0
        ln_in = 32'h00000000;
        #90;

        // -0.693147
        ln_in = 32'hBF317217;
        #90;

        // -1.386294
        ln_in = 32'hBFB17218;
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
            $display("Time    : %0t", $time);
            $display("Input   : %h", ln_in);
            $display("Output  : %h", mul_out);
        end
    end

endmodule