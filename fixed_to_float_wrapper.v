`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:39:16 PM
// Design Name: 
// Module Name: fixed_to_float_wrapper
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

module fixed_to_float_wrapper(

    input  wire        clk,
    input  wire        valid_in,
    input  wire [31:0] fixed_in,

    output wire        valid_out,
    output wire [31:0] float_out

);

    //--------------------------------------------------
    // Fixed Point to Floating Point IP
    //--------------------------------------------------

    fp_fixed_to_float fp_converter (

        .aclk(clk),

        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata(fixed_in),

        .m_axis_result_tvalid(valid_out),
        .m_axis_result_tdata(float_out)

    );

endmodule
