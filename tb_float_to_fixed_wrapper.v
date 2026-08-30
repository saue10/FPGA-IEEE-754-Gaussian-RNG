`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:29:32 PM
// Design Name: 
// Module Name: tb_float_to_fixed_wrapper
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

module tb_float_to_fixed_wrapper;

    // Inputs
    reg clk;
    reg valid_in;
    reg [31:0] float_in;

    // Outputs
    wire valid_out;
    wire [31:0] fixed_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    float_to_fixed_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .float_in(float_in),

        .valid_out(valid_out),
        .fixed_out(fixed_out)

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
        float_in = 32'h00000000;

        #20;

        valid_in = 1;

        // 0.0
        float_in = 32'h00000000;
        #100;

        // 0.5
        float_in = 32'h3F000000;
        #100;

        // 1.0
        float_in = 32'h3F800000;
        #100;

        // -0.5
        float_in = 32'hBF000000;
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
            $display("Float In  : %h", float_in);
            $display("Fixed Out : %h", fixed_out);
        end
    end

endmodule
