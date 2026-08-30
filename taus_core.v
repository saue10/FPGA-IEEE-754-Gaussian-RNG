`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 04:07:22 PM
// Design Name: 
// Module Name: taus_core
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

module taus_core(

    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] seed,

    output wire [31:0] random

);
//--------------------------------------------------
// Internal State Registers
//--------------------------------------------------

reg [31:0] s0;
reg [31:0] s1;
reg [31:0] s2;

//--------------------------------------------------
// Intermediate Signals
//--------------------------------------------------

wire [31:0] b0;
wire [31:0] b1;
wire [31:0] b2;

wire [31:0] s0_next;
wire [31:0] s1_next;
wire [31:0] s2_next;

//--------------------------------------------------
// Tausworthe Generator Stage 0
//--------------------------------------------------

assign b0 = (((s0 << 13) ^ s0) >> 19);

assign s0_next = (((s0 & 32'hFFFFFFFE) << 12) ^ b0);

//--------------------------------------------------
// Tausworthe Generator Stage 1
//--------------------------------------------------

assign b1 = (((s1 << 2) ^ s1) >> 25);

assign s1_next = (((s1 & 32'hFFFFFFF8) << 4) ^ b1);

//--------------------------------------------------
// Tausworthe Generator Stage 2
//--------------------------------------------------

assign b2 = (((s2 << 3) ^ s2) >> 11);

assign s2_next = (((s2 & 32'hFFFFFFF0) << 17) ^ b2);

//--------------------------------------------------
// Final Random Number
//--------------------------------------------------

assign random = s0_next ^ s1_next ^ s2_next;

//--------------------------------------------------
// State Update
//--------------------------------------------------

always @(posedge clk)
begin
    if (rst)
    begin
        s0 <= (seed < 32'd2) ? 32'h00000002 : seed;

        s1 <= ((seed ^ 32'hA5A5A5A5) < 32'd8) ?
              32'h00000008 :
              (seed ^ 32'hA5A5A5A5);

        s2 <= ((seed ^ 32'h5A5A5A5A) < 32'd16) ?
              32'h00000010 :
              (seed ^ 32'h5A5A5A5A);
    end
    else
    begin
        s0 <= s0_next;
        s1 <= s1_next;
        s2 <= s2_next;
    end
end
endmodule