`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:49:06 PM
// Design Name: 
// Module Name: tb_cordic_float_wrapper
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

module tb_cordic_float_wrapper;

    //--------------------------------------------------
    // Inputs
    //--------------------------------------------------

    reg         clk;
    reg         valid_in;
    reg [31:0]  angle_float;

    //--------------------------------------------------
    // Outputs
    //--------------------------------------------------

    wire        valid_out;
    wire [31:0] cos_float;
    wire [31:0] sin_float;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    cordic_float_wrapper dut (

        .clk(clk),
        .valid_in(valid_in),
        .angle_float(angle_float),

        .valid_out(valid_out),
        .cos_float(cos_float),
        .sin_float(sin_float)

    );

    //--------------------------------------------------
    // Clock Generation
    //--------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------
    // Test Stimulus
    //--------------------------------------------------

    initial begin

        valid_in    = 0;
        angle_float = 32'h00000000;

        #20;

        valid_in = 1;

        //--------------------------------------------------
        // Test 1 : 0 rad
        //--------------------------------------------------
        angle_float = 32'h00000000;
        #300;

        //--------------------------------------------------
        // Test 2 : π/2
        //--------------------------------------------------
        angle_float = 32'h3FC90FDB;
        #300;

        //--------------------------------------------------
        // Test 3 : π
        //--------------------------------------------------
        angle_float = 32'h40490FDB;
        #300;

        valid_in = 0;

        #200;

        $finish;

    end

    //--------------------------------------------------
    // Monitor
    //--------------------------------------------------

    always @(posedge clk)
    begin
        if(valid_out)
        begin
            $display("--------------------------------------------------");
            $display("Time      : %0t", $time);
            $display("Angle In  : %h", angle_float);
            $display("Cos Float : %h", cos_float);
            $display("Sin Float : %h", sin_float);
        end
    end

endmodule

