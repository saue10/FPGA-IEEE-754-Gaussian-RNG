`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:11:59 PM
// Design Name: 
// Module Name: cordic_wrapper
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

module cordic_wrapper(

    input  wire        clk,
    input  wire        valid_in,
    input  wire [31:0] angle_in,

    output wire        valid_out,
    output wire [31:0] cos_out,
    output wire [31:0] sin_out

);

    //--------------------------------------------------
    // Packed output from CORDIC
    //--------------------------------------------------

    wire [63:0] cordic_out;

    //--------------------------------------------------
    // CORDIC IP
    //--------------------------------------------------

    cordic_sincos cordic_ip (

        .aclk(clk),

        .s_axis_phase_tvalid(valid_in),
        .s_axis_phase_tdata(angle_in),

        .m_axis_dout_tvalid(valid_out),
        .m_axis_dout_tdata(cordic_out)

    );

    //--------------------------------------------------
    // Split output
    //--------------------------------------------------

    assign cos_out = cordic_out[63:32];
    assign sin_out = cordic_out[31:0];

endmodule
