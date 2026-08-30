`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 05:31:00 PM
// Design Name: 
// Module Name: tb_int_to_float_wrapper
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

module tb_int_to_float_wrapper;

    // Inputs
    reg clk;
    reg valid_in;
    reg [31:0] int_in;

    // Outputs
    wire valid_out;
    wire [31:0] float_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    int_to_float_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .int_in(int_in),

        .valid_out(valid_out),
        .float_out(float_out)

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
        int_in   = 0;

        #20;

        valid_in = 1;

        int_in = 32'd0;
        #60;

        int_in = 32'd1;
        #60;

        int_in = 32'd2;
        #60;

        int_in = 32'd100;
        #60;

        int_in = 32'd123456789;
        #60;

        int_in = 32'hFFFFFFFF;
        #60;
        valid_in = 0;

        #100;

        $finish;

    end;

    //--------------------------------------------------
    // Monitor
    //--------------------------------------------------

    always @(posedge clk)
    begin
        if(valid_out)
        begin
            $display("-----------------------------------");
            $display("Time      : %0t", $time);
            $display("Float Out : %h", float_out);
        end
    end

endmodule