`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 06:11:23 PM
// Design Name: 
// Module Name: tb_ln_wrapper
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

module tb_ln_wrapper;

    // Inputs
    reg clk;
    reg valid_in;
    reg [31:0] float_in;

    // Outputs
    wire valid_out;
    wire [31:0] ln_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    ln_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .float_in(float_in),

        .valid_out(valid_out),
        .ln_out(ln_out)

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
        float_in = 0;

        #20;

        valid_in = 1;

        // ln(1.0) = 0
        float_in = 32'h3F800000;
        #120;

        // ln(0.5)
        float_in = 32'h3F000000;
        #120;

        // ln(0.25)
        float_in = 32'h3E800000;
        #120;

        // ln(0.125)
        float_in = 32'h3E000000;
        #120;

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
            $display("Time   : %0t", $time);
            $display("Input  : %h", float_in);
            $display("Ln Out : %h", ln_out);
        end
    end

endmodule
