`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:13:37 PM
// Design Name: 
// Module Name: tb_cordic_wrapper
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

module tb_cordic_wrapper;

reg clk;
reg valid_in;
reg [31:0] angle_in;

wire valid_out;
wire [31:0] cos_out;
wire [31:0] sin_out;

cordic_wrapper DUT(

    .clk(clk),
    .valid_in(valid_in),
    .angle_in(angle_in),

    .valid_out(valid_out),
    .cos_out(cos_out),
    .sin_out(sin_out)

);

always #5 clk = ~clk;

initial begin

    clk = 0;
    valid_in = 0;
    angle_in = 0;

    #20;

    valid_in = 1;

    angle_in = 32'h00000000;
    @(posedge valid_out);

    angle_in = 32'h10000000;
    @(posedge valid_out);

    angle_in = 32'h20000000;
    @(posedge valid_out);

    angle_in = 32'h40000000;
    @(posedge valid_out);

    angle_in = 32'h60000000;
    @(posedge valid_out);

    angle_in = 32'h7FFFFFFF;
    @(posedge valid_out);

    valid_in = 0;

    #100;

    $finish;

end

endmodule