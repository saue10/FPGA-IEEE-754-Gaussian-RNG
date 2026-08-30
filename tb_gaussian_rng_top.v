`timescale 1ns/1ps

module gaussian_rng_tb;

    //--------------------------------------------------
    // Parameters
    //--------------------------------------------------

    parameter PIPELINE_LATENCY = 87;
    parameter TOTAL_SAMPLES    = 10000;

    //--------------------------------------------------
    // Clock / Reset
    //--------------------------------------------------

    reg clk;
    reg rst;

    //--------------------------------------------------
    // Seeds
    //--------------------------------------------------

    reg [31:0] seed0;
    reg [31:0] seed1;

    //--------------------------------------------------
    // DUT Outputs
    //--------------------------------------------------

    wire [31:0] z0;
    wire [31:0] z1;
    wire        valid_out;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    gaussian_rng_top dut
    (
        .clk       (clk),
        .rst       (rst),
        .seed0     (seed0),
        .seed1     (seed1),
        .z0        (z0),
        .z1        (z1),
        .valid_out (valid_out)
    );

    //--------------------------------------------------
    // 100 MHz Clock
    //--------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------
    // Input Alignment Pipeline
    //--------------------------------------------------

    reg [31:0] u0_delay [0:PIPELINE_LATENCY-1];
    reg [31:0] u1_delay [0:PIPELINE_LATENCY-1];
    reg        input_valid_delay [0:PIPELINE_LATENCY-1];

    integer i;

    always @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < PIPELINE_LATENCY; i = i + 1) begin
                u0_delay[i]          <= 32'd0;
                u1_delay[i]          <= 32'd0;
                input_valid_delay[i] <= 1'b0;
            end

        end
        else begin

            //--------------------------------------------------
            // Capture the exact RNG inputs entering the
            // Gaussian processing pipeline
            //--------------------------------------------------

            u0_delay[0]          <= dut.u0;
            u1_delay[0]          <= dut.u1;
            input_valid_delay[0] <= 1'b1;

            //--------------------------------------------------
            // Shift pipeline
            //--------------------------------------------------

            for (i = 1; i < PIPELINE_LATENCY; i = i + 1) begin

                u0_delay[i]          <= u0_delay[i-1];
                u1_delay[i]          <= u1_delay[i-1];
                input_valid_delay[i] <= input_valid_delay[i-1];

            end

        end

    end

    //--------------------------------------------------
    // Output File / Counters
    //--------------------------------------------------

    integer outfile;
    integer pair_count;
    integer cycle_count;
    integer first_valid_cycle;

    reg first_valid_seen;

    //--------------------------------------------------
    // Initialization
    //--------------------------------------------------

    initial begin

        outfile = $fopen("gaussian_samples_aligned.txt", "w");

        if (outfile == 0) begin
            $display("ERROR: Could not open output file.");
            $finish;
        end

        rst = 1'b1;

        seed0 = 32'h12345678;
        seed1 = 32'h87654321;

        pair_count        = 0;
        cycle_count       = 0;
        first_valid_cycle = 0;
        first_valid_seen  = 1'b0;

        //--------------------------------------------------
        // Reset
        //--------------------------------------------------

        #50;
        rst = 1'b0;

        $display("");
        $display("==============================================");
        $display(" Gaussian RNG Error Analysis Simulation");
        $display("==============================================");
        $display("Clock frequency  : 100 MHz");
        $display("Clock period     : 10 ns");
        $display("Input delay      : %0d cycles", PIPELINE_LATENCY);
        $display("Target samples   : %0d", TOTAL_SAMPLES);
        $display("==============================================");
        $display("");

    end

    //--------------------------------------------------
    // Cycle Counter
    //--------------------------------------------------

    always @(posedge clk) begin

        if (rst)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;

    end

    //--------------------------------------------------
    // Store Correctly Aligned U0 U1 Z0 Z1
    //--------------------------------------------------

    always @(posedge clk) begin

        if (!rst &&
            valid_out &&
            input_valid_delay[PIPELINE_LATENCY-1]) begin

            //--------------------------------------------------
            // First valid output
            //--------------------------------------------------

            if (!first_valid_seen) begin

                first_valid_seen  = 1'b1;
                first_valid_cycle = cycle_count;

                $display("");
                $display("==============================================");
                $display(" FIRST VALID GAUSSIAN OUTPUT");
                $display("==============================================");
                $display("Cycle : %0d", cycle_count);
                $display("Time  : %0t ns", $time);
                $display("U0    : %08h",
                         u0_delay[PIPELINE_LATENCY-1]);
                $display("U1    : %08h",
                         u1_delay[PIPELINE_LATENCY-1]);
                $display("Z0    : %08h", z0);
                $display("Z1    : %08h", z1);
                $display("==============================================");
                $display("");

            end

            //--------------------------------------------------
            // Write one correctly aligned Box-Muller pair
            //
            // U0 U1 Z0 Z1
            //--------------------------------------------------

            $fdisplay(
                outfile,
                "%08h %08h %08h %08h",
                u0_delay[PIPELINE_LATENCY-1],
                u1_delay[PIPELINE_LATENCY-1],
                z0,
                z1
            );

            pair_count = pair_count + 1;

            //--------------------------------------------------
            // Stop after 10,000 Gaussian samples
            // = 5,000 output pairs
            //--------------------------------------------------

            if ((pair_count * 2) >= TOTAL_SAMPLES) begin

                $display("");
                $display("==============================================");
                $display(" SIMULATION COMPLETE");
                $display("==============================================");
                $display("Gaussian sample pairs generated : %0d",
                         pair_count);
                $display("Gaussian samples generated      : %0d",
                         pair_count * 2);
                $display("First valid cycle               : %0d",
                         first_valid_cycle);
                $display("==============================================");

                $fclose(outfile);

                #20;
                $finish;

            end

        end

    end

endmodule