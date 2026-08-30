`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 06:17:58 PM
// Design Name: 
// Module Name: mul_minus2_wrapper
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

module mul_minus2_wrapper(

    input  wire        clk,

    input  wire        valid_in,
    input  wire [31:0] ln_in,

    output wire        valid_out,
    output wire [31:0] mul_out

);

    //--------------------------------------------------
    // Constant = -2.0
    // IEEE-754 Single Precision
    //--------------------------------------------------

    localparam [31:0] NEG_TWO = 32'hC0000000;

    //--------------------------------------------------
    // Floating Point Multiplier
    //--------------------------------------------------

    fp_multiplier fp_mul (

        .aclk(clk),

        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata(ln_in),

        .s_axis_b_tvalid(valid_in),
        .s_axis_b_tdata(NEG_TWO),

        .m_axis_result_tvalid(valid_out),
        .m_axis_result_tdata(mul_out)

    );

endmodule
