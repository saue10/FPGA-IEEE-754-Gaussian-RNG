`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:46:48 PM
// Design Name: 
// Module Name: cordic_float_wrapper
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

module cordic_float_wrapper(

    input  wire        clk,
    input  wire        valid_in,
    input  wire [31:0] angle_float,

    output wire        valid_out,
    output wire [31:0] cos_float,
    output wire [31:0] sin_float

);

    //--------------------------------------------------
    // Internal Signals
    //--------------------------------------------------

    wire        valid_fixed_in;
    wire [31:0] angle_fixed;

    wire        valid_cordic;
    wire [31:0] cos_fixed;
    wire [31:0] sin_fixed;

    wire        valid_cos_float;
    wire        valid_sin_float;

    //--------------------------------------------------
    // Float -> Fixed
    //--------------------------------------------------

    float_to_fixed_wrapper u_float_to_fixed (

        .clk(clk),

        .valid_in(valid_in),
        .float_in(angle_float),

        .valid_out(valid_fixed_in),
        .fixed_out(angle_fixed)

    );

    //--------------------------------------------------
    // CORDIC
    //--------------------------------------------------

    cordic_wrapper u_cordic (

        .clk(clk),

        .valid_in(valid_fixed_in),
        .angle_in(angle_fixed),

        .valid_out(valid_cordic),
        .cos_out(cos_fixed),
        .sin_out(sin_fixed)

    );

    //--------------------------------------------------
    // Cos : Fixed -> Float
    //--------------------------------------------------

    fixed_to_float_wrapper u_cos_float (

        .clk(clk),

        .valid_in(valid_cordic),
        .fixed_in(cos_fixed),

        .valid_out(valid_cos_float),
        .float_out(cos_float)

    );

    //--------------------------------------------------
    // Sin : Fixed -> Float
    //--------------------------------------------------

    fixed_to_float_wrapper u_sin_float (

        .clk(clk),

        .valid_in(valid_cordic),
        .fixed_in(sin_fixed),

        .valid_out(valid_sin_float),
        .float_out(sin_float)

    );

    //--------------------------------------------------
    // Output Valid
    //--------------------------------------------------

    assign valid_out = valid_cos_float & valid_sin_float;

endmodule
