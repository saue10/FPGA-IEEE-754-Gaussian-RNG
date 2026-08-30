`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 04:17:16 PM
// Design Name: 
// Module Name: tb_taus_core
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

module tb_taus_core;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] seed;

    // Output
    wire [31:0] random;

    // Instantiate DUT
    taus_core dut (
        .clk(clk),
        .rst(rst),
        .seed(seed),
        .random(random)
    );

    // Clock Generation (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin

        // Initialize
        rst  = 1;
        seed = 32'h12345678;

        // Hold reset for two clock cycles
        #20;

        rst = 0;

        // Run for 500 ns
        #500;

        $finish;

    end

endmodule
