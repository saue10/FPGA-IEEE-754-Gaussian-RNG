`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 06:09:52 PM
// Design Name: 
// Module Name: ln_wrapper
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

module ln_wrapper(

    input  wire        clk,

    input  wire        valid_in,
    input  wire [31:0] float_in,

    output wire        valid_out,
    output wire [31:0] ln_out

);

    //--------------------------------------------------
    // Floating Point Natural Logarithm IP
    //--------------------------------------------------

    fp_ln ln_ip (

        .aclk(clk),

        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata(float_in),

        .m_axis_result_tvalid(valid_out),
        .m_axis_result_tdata(ln_out)

    );

endmodule