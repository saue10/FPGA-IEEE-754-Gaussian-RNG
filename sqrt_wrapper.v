`timescale 1ns / 1ps

module sqrt_wrapper(

    input  wire        clk,

    input  wire        valid_in,
    input  wire [31:0] mul_in,

    output wire        valid_out,
    output wire [31:0] sqrt_out

);

    //--------------------------------------------------
    // Guarded Square-Root Input
    //
    // For the Box-Muller transformation:
    //
    // mul_in = -2 * ln(u0)
    //
    // Ideally mul_in is always non-negative because
    // 0 < u0 <= 1 implies ln(u0) <= 0.
    //
    // As a protection against unexpected negative values
    // caused by invalid inputs or numerical/exceptional
    // conditions, any negative input is clamped to +0.0.
    //--------------------------------------------------

    wire [31:0] sqrt_in;

    assign sqrt_in =
        (mul_in[31] == 1'b1) ?
        32'h00000000 :
        mul_in;


    //--------------------------------------------------
    // Floating-Point Square Root IP
    //--------------------------------------------------

    fp_sqrt sqrt_ip (

        .aclk(clk),

        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata(sqrt_in),

        .m_axis_result_tvalid(valid_out),
        .m_axis_result_tdata(sqrt_out)

    );

endmodule