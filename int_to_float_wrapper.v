`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 05:23:04 PM
// Design Name: 
// Module Name: int_to_float_wrapper
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

module int_to_float_wrapper(

    input  wire        clk,

    input  wire        valid_in,
    input  wire [31:0] int_in,

    output wire        valid_out,
    output wire [31:0] float_out

);

    //--------------------------------------------------
    // Xilinx Floating Point IP
    //--------------------------------------------------

    fp_int_to_float fp_converter (

        .aclk                 (clk),

        .s_axis_a_tvalid      (valid_in),
        .s_axis_a_tdata       (int_in),

        .m_axis_result_tvalid (valid_out),
        .m_axis_result_tdata  (float_out)

    );

endmodule
