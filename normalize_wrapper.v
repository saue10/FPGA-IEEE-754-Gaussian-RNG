`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 05:55:08 PM
// Design Name: 
// Module Name: normalize_wrapper
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

module normalize_wrapper(

    input  wire        clk,

    input  wire        valid_in,
    input  wire [31:0] float_in,

    output wire        valid_out,
    output wire [31:0] norm_out

);

    //--------------------------------------------------
    // Constant = 2^-32
    // IEEE-754 Single Precision
    //--------------------------------------------------

    localparam [31:0] SCALE = 32'h2F800000;

    //--------------------------------------------------
    // Floating Point Multiplier
    //--------------------------------------------------

    fp_multiplier fp_mul (

        .aclk(clk),

        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata(float_in),

        .s_axis_b_tvalid(valid_in),
        .s_axis_b_tdata(SCALE),

        .m_axis_result_tvalid(valid_out),
        .m_axis_result_tdata(norm_out)

    );

endmodule
