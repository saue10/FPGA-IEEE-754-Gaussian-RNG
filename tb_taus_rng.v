`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 04:53:14 PM
// Design Name: 
// Module Name: tb_taus_rng
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

module tb_taus_rng;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] seed0;
    reg [31:0] seed1;

    // Outputs
    wire [31:0] u0;
    wire [31:0] u1;

    //--------------------------------------------------
    // Instantiate DUT
    //--------------------------------------------------

    taus_rng dut (

        .clk(clk),
        .rst(rst),
        .seed0(seed0),
        .seed1(seed1),
        .u0(u0),
        .u1(u1)

    );

    //--------------------------------------------------
    // Clock Generation (100 MHz)
    //--------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------
    // Test Sequence
    //--------------------------------------------------

    initial begin

        rst   = 1;

        seed0 = 32'h12345678;
        seed1 = 32'h87654321;

        #20;

        rst = 0;

        #200;

        $finish;

    end

    //--------------------------------------------------
    // Monitor Output
    //--------------------------------------------------

    always @(posedge clk)
    begin
        if (!rst)
        begin
            $display("--------------------------------------------");
            $display("Time = %0t ns", $time);
            $display("U0   = %h", u0);
            $display("U1   = %h", u1);
        end
    end

endmodule