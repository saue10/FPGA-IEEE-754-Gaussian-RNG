`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 04:45:01 PM
// Design Name: 
// Module Name: taus_rng
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

module taus_rng(

    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] seed0,
    input  wire [31:0] seed1,

    output wire [31:0] u0,
    output wire [31:0] u1

);

taus_core rng0 (

    .clk(clk),
    .rst(rst),
    .seed(seed0),
    .random(u0)

);

taus_core rng1 (

    .clk(clk),
    .rst(rst),
    .seed(seed1),
    .random(u1)

);

endmodule
