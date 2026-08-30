`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2026 06:31:36 PM
// Design Name: 
// Module Name: sin_cos_lut
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


module sin_cos_lut(

    input wire clk,
    input wire [11:0] addr,

    output reg [31:0] cos_out,
    output reg [31:0] sin_out

);

    //==============================
    // ROM Arrays
    //==============================
    reg [31:0] cos_rom [0:4095];
    reg [31:0] sin_rom [0:4095];

    //==============================
    // Load Memory Files
    //==============================
    initial begin
        $readmemh("cos_lut.mem", cos_rom);
        $readmemh("sin_lut.mem", sin_rom);
    end

    //==============================
    // Synchronous Read
    //==============================
    always @(posedge clk)
    begin
        cos_out <= cos_rom[addr];
        sin_out <= sin_rom[addr];
    end

endmodule
