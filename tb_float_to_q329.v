`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2026 04:37:59 PM
// Design Name: 
// Module Name: tb_float_to_q329
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

module tb_float_to_q329;

reg clk;
reg valid_in;
reg [31:0] float_in;

wire valid_out;
wire [31:0] fixed_out;

float_to_q329_wrapper dut (

    .clk(clk),
    .valid_in(valid_in),
    .float_in(float_in),

    .valid_out(valid_out),
    .fixed_out(fixed_out)

);

//--------------------------------------------------
// Clock
//--------------------------------------------------

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//--------------------------------------------------
// Stimulus
//--------------------------------------------------

initial begin

    valid_in = 0;
    float_in = 0;

    #20;

    valid_in = 1;

    // 0
    float_in = 32'h00000000;
    #150;

    // π/2
    float_in = 32'h3FC90FDB;
    #150;

    // π
    float_in = 32'h40490FDB;
    #150;

    // 3π/2
    float_in = 32'h4096CBE4;
    #150;

    // 2π
    float_in = 32'h40C90FDB;
    #150;

    valid_in = 0;

    #100;

    $finish;

end

//--------------------------------------------------

always @(posedge clk)
begin
    if(valid_out)
    begin
        $display("--------------------------------");
        $display("Float = %h", float_in);
        $display("Fixed = %h", fixed_out);
    end
end

endmodule

