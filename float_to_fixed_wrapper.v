`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:28:11 PM
// Design Name: 
// Module Name: float_to_fixed_wrapper
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

module float_to_fixed_wrapper(

    input  wire        clk,
    input  wire        valid_in,
    input  wire [31:0] float_in,

    output wire        valid_out,
    output wire [31:0] fixed_out

);

    //--------------------------------------------------
    // Floating Point to Fixed Point IP
    //--------------------------------------------------

    fp_float_to_fixed fp_converter (

        .aclk(clk),

        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata(float_in),

        .m_axis_result_tvalid(valid_out),
        .m_axis_result_tdata(fixed_out)

    );

endmodule
