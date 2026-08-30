//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 07/25/2026 07:54:13 PM
//// Design Name: 
//// Module Name: gaussian_rng_top
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

//`timescale 1ns / 1ps

//module gaussian_rng_top(

//    input  wire        clk,
//    input  wire        rst,

//    input  wire [31:0] seed0,
//    input  wire [31:0] seed1,

//    output wire [31:0] z0,
//    output wire [31:0] z1,

//    output wire        valid_out,
//    output wire [31:0] debug_u0
//);

////--------------------------------------------------
//// RNG Outputs
////--------------------------------------------------

//wire [31:0] u0;
//wire [31:0] u1;

////--------------------------------------------------
//// Radius Pipeline
////--------------------------------------------------

//wire [31:0] float_u0;
//wire [31:0] norm_u0;
//wire [31:0] ln_u0;
//wire [31:0] minus2_ln;
//wire [31:0] radius;

////--------------------------------------------------
//// Angle Pipeline
////--------------------------------------------------

//wire [31:0] float_u1;
//wire [31:0] norm_u1;
//wire [31:0] angle_fp;

//wire [11:0] angle_addr;

//wire [31:0] cos_theta;
//wire [31:0] sin_theta;

////--------------------------------------------------
//// Final Outputs
////--------------------------------------------------

//wire [31:0] z0_wire;
//wire [31:0] z1_wire;

////--------------------------------------------------
//// Valid Signals
////--------------------------------------------------

//reg start;

//wire v0;
//wire v1;
//wire v2;
//wire v3;
//wire v4;

//wire a0;
//wire a1;
//wire a2;

//wire vz0;
//wire vz1;
//always @(posedge clk)
//begin
//    if (rst)
//        start <= 1'b0;
//    else
//        start <= 1'b1;
//end

////--------------------------------------------------
//// Random Number Generator
////--------------------------------------------------

//taus_rng RNG (

//    .clk   (clk),
//    .rst   (rst),

//    .seed0 (seed0),
//    .seed1 (seed1),

//    .u0    (u0),
//    .u1    (u1)

//);

////--------------------------------------------------
//// Radius Path : Integer to Float
////--------------------------------------------------

//int_to_float_wrapper INT2FLOAT_RADIUS (

//    .clk       (clk),

//    .valid_in  (start),
//    .int_in    (u0),

//    .valid_out (v0),
//    .float_out (float_u0)

//);

////--------------------------------------------------
//// Angle Path : Integer to Float
////--------------------------------------------------

//int_to_float_wrapper INT2FLOAT_ANGLE (

//    .clk       (clk),

//    .valid_in  (start),
//    .int_in    (u1),

//    .valid_out (a0),
//    .float_out (float_u1)

//);

////--------------------------------------------------
//// Radius Path : Normalize
////--------------------------------------------------

//normalize_wrapper NORMALIZE_RADIUS (

//    .clk       (clk),

//    .valid_in  (v0),
//    .float_in  (float_u0),

//    .valid_out (v1),
//    .norm_out  (norm_u0)

//);

////--------------------------------------------------
//// Angle Path : Normalize
////--------------------------------------------------

//normalize_wrapper NORMALIZE_ANGLE (

//    .clk       (clk),

//    .valid_in  (a0),
//    .float_in  (float_u1),

//    .valid_out (a1),
//    .norm_out  (norm_u1)

//);

////--------------------------------------------------
//// Radius Path : Natural Log
////--------------------------------------------------

//ln_wrapper LN_STAGE (

//    .clk       (clk),

//    .valid_in  (v1),
//    .float_in  (norm_u0),

//    .valid_out (v2),
//    .ln_out    (ln_u0)

//);

////--------------------------------------------------
//// Angle Path : Multiply by 2π
////--------------------------------------------------

//mul_2pi_wrapper MUL_2PI (

//    .clk       (clk),

//    .valid_in  (a1),
//    .norm_in   (norm_u1),

//    .valid_out (a2),
//    .angle_out (angle_fp)

//);

////--------------------------------------------------
//// Radius Path : Multiply by -2
////--------------------------------------------------

//mul_minus2_wrapper MUL_MINUS2 (

//    .clk       (clk),

//    .valid_in  (v2),
//    .ln_in      (ln_u0),

//    .valid_out (v3),
//    .mul_out   (minus2_ln)

//);

////--------------------------------------------------
//// Radius Path : Square Root
////--------------------------------------------------

//sqrt_wrapper SQRT_STAGE (

//    .clk       (clk),

//    .valid_in  (v3),
//    .mul_in    (minus2_ln),

//    .valid_out (v4),
//    .sqrt_out  (radius)

//);

////--------------------------------------------------
//// LUT Address Generation
////--------------------------------------------------

//angle_address ANGLE_ADDR (

//    .random_in (u1),
//    .addr      (angle_addr)

//);

////--------------------------------------------------
//// Sine/Cosine LUT
////--------------------------------------------------

//sin_cos_lut LUT (

//    .clk     (clk),
//    .addr    (angle_addr),

//    .cos_out (cos_theta),
//    .sin_out (sin_theta)

//);

////--------------------------------------------------
//// Z0 = Radius × Cos(theta)
////--------------------------------------------------

//fp_mul_wrapper MUL_Z0 (

//    .clk       (clk),

//    .valid_in  (v4),

//    .a         (radius),
//    .b         (cos_theta),

//    .valid_out (vz0),
//    .result    (z0_wire)

//);

////--------------------------------------------------
//// Z1 = Radius × Sin(theta)
////--------------------------------------------------

//fp_mul_wrapper MUL_Z1 (

//    .clk       (clk),

//    .valid_in  (v4),

//    .a         (radius),
//    .b         (sin_theta),

//    .valid_out (vz1),
//    .result    (z1_wire)

//);

////--------------------------------------------------
//// Outputs
////--------------------------------------------------

//assign z0 = z0_wire;
//assign z1 = z1_wire;
//assign debug_u0 = z0_wire;
//assign valid_out = vz0 & vz1;
//endmodule
`timescale 1ns / 1ps

module gaussian_rng_top(

    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] seed0,
    input  wire [31:0] seed1,

    output wire [31:0] z0,
    output wire [31:0] z1,

    output wire        valid_out,
    output wire [31:0] debug_u0,
    output wire [31:0] debug_u1
);

wire [31:0] u0;
wire [31:0] u1;

/* Zero guard for Box-Muller logarithm input.
 * If u0 = 0, replace it with 1 so that after
 * normalization the minimum input becomes 2^-32,
 * preventing ln(0).
 */
wire [31:0] u0_safe;

assign u0_safe = (u0 == 32'd0) ? 32'd1 : u0;

//--------------------------------------------------
// Radius Pipeline
//--------------------------------------------------

wire [31:0] float_u0;
wire [31:0] norm_u0;
wire [31:0] ln_u0;
wire [31:0] minus2_ln;
wire [31:0] radius;


//--------------------------------------------------
// Angle Pipeline
//--------------------------------------------------

wire [31:0] float_u1;
wire [31:0] norm_u1;
wire [31:0] angle_fp;

wire [11:0] angle_addr;

wire [31:0] cos_theta_lut;
wire [31:0] sin_theta_lut;


//--------------------------------------------------
// DELAYED SINE/COSINE VALUES
//
// These registers synchronize the LUT outputs
// with the radius pipeline.
//--------------------------------------------------

reg [31:0] cos_delay_0;
reg [31:0] cos_delay_1;
reg [31:0] cos_delay_2;
reg [31:0] cos_delay_3;
reg [31:0] cos_delay_4;
reg [31:0] cos_delay_5;
reg [31:0] cos_delay_6;
reg [31:0] cos_delay_7;

reg [31:0] sin_delay_0;
reg [31:0] sin_delay_1;
reg [31:0] sin_delay_2;
reg [31:0] sin_delay_3;
reg [31:0] sin_delay_4;
reg [31:0] sin_delay_5;
reg [31:0] sin_delay_6;
reg [31:0] sin_delay_7;

wire [31:0] cos_theta;
wire [31:0] sin_theta;


//--------------------------------------------------
// Final Outputs
//--------------------------------------------------

wire [31:0] z0_wire;
wire [31:0] z1_wire;


//--------------------------------------------------
// Valid Signals
//--------------------------------------------------

reg start;

wire v0;
wire v1;
wire v2;
wire v3;
wire v4;

wire a0;
wire a1;
wire a2;

wire vz0;
wire vz1;


//--------------------------------------------------
// Start Signal
//--------------------------------------------------

always @(posedge clk)
begin
    if (rst)
        start <= 1'b0;
    else
        start <= 1'b1;
end


//--------------------------------------------------
// Random Number Generator
//--------------------------------------------------

taus_rng RNG (

    .clk   (clk),
    .rst   (rst),

    .seed0 (seed0),
    .seed1 (seed1),

    .u0    (u0),
    .u1    (u1)

);


//==================================================
// RADIUS PATH
//==================================================


//--------------------------------------------------
// Integer to Float
//--------------------------------------------------

int_to_float_wrapper INT2FLOAT_RADIUS (

    .clk       (clk),

    .valid_in  (start),
    .int_in    (u0_safe),

    .valid_out (v0),
    .float_out (float_u0)

);


//--------------------------------------------------
// Normalize
//--------------------------------------------------

normalize_wrapper NORMALIZE_RADIUS (

    .clk       (clk),

    .valid_in  (v0),
    .float_in  (float_u0),

    .valid_out (v1),
    .norm_out  (norm_u0)

);


//--------------------------------------------------
// Natural Logarithm
//--------------------------------------------------

ln_wrapper LN_STAGE (

    .clk       (clk),

    .valid_in  (v1),
    .float_in  (norm_u0),

    .valid_out (v2),
    .ln_out    (ln_u0)

);


//--------------------------------------------------
// Multiply by -2
//--------------------------------------------------

mul_minus2_wrapper MUL_MINUS2 (

    .clk       (clk),

    .valid_in  (v2),
    .ln_in     (ln_u0),

    .valid_out (v3),
    .mul_out   (minus2_ln)

);


//--------------------------------------------------
// Square Root
//--------------------------------------------------

sqrt_wrapper SQRT_STAGE (

    .clk       (clk),

    .valid_in  (v3),
    .mul_in    (minus2_ln),

    .valid_out (v4),
    .sqrt_out  (radius)

);


//==================================================
// ANGLE PATH
//
// This path is retained for the complete Box-Muller
// floating-point pipeline.
//==================================================


//--------------------------------------------------
// Integer to Float
//--------------------------------------------------

int_to_float_wrapper INT2FLOAT_ANGLE (

    .clk       (clk),

    .valid_in  (start),
    .int_in    (u1),

    .valid_out (a0),
    .float_out (float_u1)

);


//--------------------------------------------------
// Normalize
//--------------------------------------------------

normalize_wrapper NORMALIZE_ANGLE (

    .clk       (clk),

    .valid_in  (a0),
    .float_in  (float_u1),

    .valid_out (a1),
    .norm_out  (norm_u1)

);


//--------------------------------------------------
// Multiply by 2*pi
//--------------------------------------------------

mul_2pi_wrapper MUL_2PI (

    .clk       (clk),

    .valid_in  (a1),
    .norm_in   (norm_u1),

    .valid_out (a2),
    .angle_out (angle_fp)

);


//==================================================
// LUT ANGLE GENERATION
//
// The 12 MSBs of u1 select one of 4096 angle entries.
//==================================================


//--------------------------------------------------
// LUT Address Generation
//--------------------------------------------------

angle_address ANGLE_ADDR (

    .random_in (u1),
    .addr      (angle_addr)

);


//--------------------------------------------------
// Sine/Cosine LUT
//--------------------------------------------------

sin_cos_lut LUT (

    .clk     (clk),
    .addr    (angle_addr),

    .cos_out (cos_theta_lut),
    .sin_out (sin_theta_lut)

);


//==================================================
// PIPELINE SYNCHRONIZATION
//
// The radius path contains several pipelined FP stages,
// while the LUT produces its result much earlier.
//
// Delay the sine and cosine values so that the LUT
// result corresponding to a particular u1 reaches the
// final multiplier together with the radius generated
// from the corresponding u0.
//==================================================

always @(posedge clk)
begin
    if (rst)
    begin

        cos_delay_0 <= 32'd0;
        cos_delay_1 <= 32'd0;
        cos_delay_2 <= 32'd0;
        cos_delay_3 <= 32'd0;
        cos_delay_4 <= 32'd0;
        cos_delay_5 <= 32'd0;
        cos_delay_6 <= 32'd0;
        cos_delay_7 <= 32'd0;

        sin_delay_0 <= 32'd0;
        sin_delay_1 <= 32'd0;
        sin_delay_2 <= 32'd0;
        sin_delay_3 <= 32'd0;
        sin_delay_4 <= 32'd0;
        sin_delay_5 <= 32'd0;
        sin_delay_6 <= 32'd0;
        sin_delay_7 <= 32'd0;

    end

    else
    begin

        //--------------------------------------------------
        // Cosine pipeline
        //--------------------------------------------------

        cos_delay_0 <= cos_theta_lut;
        cos_delay_1 <= cos_delay_0;
        cos_delay_2 <= cos_delay_1;
        cos_delay_3 <= cos_delay_2;
        cos_delay_4 <= cos_delay_3;
        cos_delay_5 <= cos_delay_4;
        cos_delay_6 <= cos_delay_5;
        cos_delay_7 <= cos_delay_6;


        //--------------------------------------------------
        // Sine pipeline
        //--------------------------------------------------

        sin_delay_0 <= sin_theta_lut;
        sin_delay_1 <= sin_delay_0;
        sin_delay_2 <= sin_delay_1;
        sin_delay_3 <= sin_delay_2;
        sin_delay_4 <= sin_delay_3;
        sin_delay_5 <= sin_delay_4;
        sin_delay_6 <= sin_delay_5;
        sin_delay_7 <= sin_delay_6;

    end
end


//--------------------------------------------------
// Synchronized LUT Outputs
//--------------------------------------------------

assign cos_theta = cos_delay_7;
assign sin_theta = sin_delay_7;


//==================================================
// FINAL BOX-MULLER OUTPUTS
//==================================================


//--------------------------------------------------
// Z0 = Radius x Cos(theta)
//--------------------------------------------------

fp_mul_wrapper MUL_Z0 (

    .clk       (clk),

    .valid_in  (v4),

    .a         (radius),
    .b         (cos_theta),

    .valid_out (vz0),
    .result    (z0_wire)

);


//--------------------------------------------------
// Z1 = Radius x Sin(theta)
//--------------------------------------------------

fp_mul_wrapper MUL_Z1 (

    .clk       (clk),

    .valid_in  (v4),

    .a         (radius),
    .b         (sin_theta),

    .valid_out (vz1),
    .result    (z1_wire)

);


//==================================================
// OUTPUTS
//==================================================

assign z0 = z0_wire;
assign z1 = z1_wire;


// Debug output
// Debug outputs: direct TAUS streams
assign debug_u0 = u0;
assign debug_u1 = u1;


// Both outputs must be valid
assign valid_out = vz0 & vz1;


endmodule