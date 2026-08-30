`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 06:36:02 PM
// Design Name: 
// Module Name: mul_2pi_wrapper
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

module mul_2pi_wrapper(

    input  wire        clk,

    input  wire        valid_in,
    input  wire [31:0] norm_in,

    output wire        valid_out,
    output wire [31:0] angle_out

);

    //--------------------------------------------------
    // Constant = 2π
    //--------------------------------------------------

    localparam [31:0] TWO_PI = 32'h40C90FDB;

    //--------------------------------------------------
    // Floating Point Multiplier
    //--------------------------------------------------

    fp_multiplier fp_mul (

        .aclk(clk),

        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata(norm_in),

        .s_axis_b_tvalid(valid_in),
        .s_axis_b_tdata(TWO_PI),

        .m_axis_result_tvalid(valid_out),
        .m_axis_result_tdata(angle_out)

    );

endmodule
