`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2026 06:33:41 PM
// Design Name: 
// Module Name: tb_sin_cos_lut
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


`timescale 1ns/1ps

module tb_sin_cos_lut;

reg clk;
reg [11:0] addr;

wire [31:0] cos_out;
wire [31:0] sin_out;

sin_cos_lut uut(
    .clk(clk),
    .addr(addr),
    .cos_out(cos_out),
    .sin_out(sin_out)
);

always #5 clk = ~clk;

initial begin

    clk = 0;

    // θ = 0
    addr = 12'd0;
    #10;

    // θ = π/2
    addr = 12'd1024;
    #10;

    // θ = π
    addr = 12'd2048;
    #10;

    // θ = 3π/2
    addr = 12'd3072;
    #10;

    // θ = 2π (wraps to 0)
    addr = 12'd4095;
    #10;

    $finish;

end

endmodule
