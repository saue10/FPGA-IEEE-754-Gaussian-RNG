`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2026 07:31:42 PM
// Design Name: 
// Module Name: fp_mul_wrapper
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
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module fp_mul_wrapper(

    input  wire        clk,
    input  wire        valid_in,

    input  wire [31:0] a,
    input  wire [31:0] b,

    output wire        valid_out,
    output wire [31:0] result

);

fp_multiplier fp_mul(

    .aclk(clk),

    .s_axis_a_tvalid(valid_in),
    .s_axis_a_tdata(a),

    .s_axis_b_tvalid(valid_in),
    .s_axis_b_tdata(b),

    .m_axis_result_tvalid(valid_out),
    .m_axis_result_tdata(result)

);

endmodule
