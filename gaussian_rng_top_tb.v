`timescale 1ns / 1ps

module gaussian_rng_top_tb;

    //--------------------------------------------------
    // Clock Configuration
    //--------------------------------------------------

    localparam real CLK_FREQ_MHZ  = 155.0;
    localparam real CLK_PERIOD_NS = 1000.0 / CLK_FREQ_MHZ;


    //--------------------------------------------------
    // Number of Valid Gaussian Output Pairs Required
    //--------------------------------------------------

    localparam integer TARGET_GAUSSIAN_PAIRS = 100000;


    //--------------------------------------------------
    // Number of PRNG Samples for Statistical Analysis
    //--------------------------------------------------

    localparam integer TARGET_PRNG_SAMPLES = 100000;


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
    // Gaussian Outputs
    //--------------------------------------------------

    wire [31:0] z0;
    wire [31:0] z1;
    wire        valid_out;


    //--------------------------------------------------
    // Debug TAUS Outputs
    //--------------------------------------------------

    wire [31:0] debug_u0;
    wire [31:0] debug_u1;


    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    gaussian_rng_top DUT (

        .clk       (clk),
        .rst       (rst),

        .seed0     (seed0),
        .seed1     (seed1),

        .z0        (z0),
        .z1        (z1),

        .valid_out (valid_out),

        .debug_u0  (debug_u0),
        .debug_u1  (debug_u1)

    );


    //==================================================
    // CLOCK GENERATION
    //==================================================

    initial begin

        clk = 1'b0;

        forever begin

            #(CLK_PERIOD_NS / 2.0);
            clk = ~clk;

        end

    end


    //==================================================
    // FUNCTION:
    // UNSIGNED 32-BIT INTEGER TO REAL
    //==================================================

    function real uint32_to_real;

        input [31:0] value;

        reg [15:0] upper;
        reg [15:0] lower;

        begin

            upper = value[31:16];
            lower = value[15:0];

            uint32_to_real =
                $itor(upper) * 65536.0 +
                $itor(lower);

        end

    endfunction


    //==================================================
    // FUNCTION:
    // POWER OF TWO
    //==================================================

    function real power_of_two;

        input integer exponent;

        integer i;
        real result;

        begin

            result = 1.0;

            if (exponent >= 0) begin

                for (i = 0; i < exponent; i = i + 1)
                    result = result * 2.0;

            end

            else begin

                for (i = 0; i < (-exponent); i = i + 1)
                    result = result / 2.0;

            end

            power_of_two = result;

        end

    endfunction


    //==================================================
    // FUNCTION:
    // IEEE-754 SINGLE-PRECISION TO REAL
    //==================================================

    function real fp32_to_real;

        input [31:0] fp_value;

        reg sign_bit;
        integer exponent_bits;
        integer fraction_bits;

        real mantissa;
        real result;

        begin

            sign_bit      = fp_value[31];
            exponent_bits = fp_value[30:23];
            fraction_bits = fp_value[22:0];

            // Zero
            if (exponent_bits == 0 &&
                fraction_bits == 0) begin

                result = 0.0;

            end

            // Subnormal Number
            else if (exponent_bits == 0) begin

                mantissa =
                    uint32_to_real({9'd0, fp_value[22:0]})
                    / 8388608.0;

                result =
                    mantissa * power_of_two(-126);

            end

            // Infinity / NaN
            else if (exponent_bits == 255) begin

                // Special values are checked separately
                result = 0.0;

            end

            // Normal IEEE-754 Number
            else begin

                mantissa =
                    1.0 +
                    uint32_to_real({9'd0, fp_value[22:0]})
                    / 8388608.0;

                result =
                    mantissa *
                    power_of_two(exponent_bits - 127);

            end

            // Apply Sign
            if (sign_bit)
                result = -result;

            fp32_to_real = result;

        end

    endfunction


    //==================================================
    // SIMULATION VARIABLES
    //==================================================

    integer cycle_count;
    integer first_valid_cycle;

    integer gaussian_pair_count;
    integer prng_sample_count;

    integer zero_u0_count;
    integer zero_u1_count;

    integer valid_gap_count;
    integer consecutive_valid_count;

    integer sample_print_count;

    integer nan_inf_z0_count;
    integer nan_inf_z1_count;

    reg first_valid_seen;
    reg previous_valid;


    //==================================================
    // PRNG STATISTICAL VARIABLES
    //==================================================

    real u0_real;
    real u1_real;

    real sum_u0;
    real sum_u1;

    real sum_u0_sq;
    real sum_u1_sq;

    real sum_u0_u1;

    real mean_u0;
    real mean_u1;

    real var_u0;
    real var_u1;

    real std_u0;
    real std_u1;

    real covariance_u0_u1;
    real correlation_u0_u1;

    real expected_u_product;
    real prng_denominator;


    //==================================================
    // GAUSSIAN STATISTICAL VARIABLES
    //==================================================

    real z0_real;
    real z1_real;

    real sum_z0;
    real sum_z1;

    real sum_z0_sq;
    real sum_z1_sq;

    real sum_z0_cube;
    real sum_z1_cube;

    real sum_z0_fourth;
    real sum_z1_fourth;

    real sum_z0_z1;


    //--------------------------------------------------
    // Final Gaussian Statistics
    //--------------------------------------------------

    real mean_z0;
    real mean_z1;

    real variance_z0;
    real variance_z1;

    real std_z0;
    real std_z1;

    real skewness_z0;
    real skewness_z1;

    real kurtosis_z0;
    real kurtosis_z1;

    real covariance_z0_z1;
    real correlation_z0_z1;

    real expected_z_product;
    real gaussian_denominator;


    //--------------------------------------------------
    // Temporary Central-Moment Variables
    //--------------------------------------------------

    real raw_m2_z0;
    real raw_m2_z1;

    real raw_m3_z0;
    real raw_m3_z1;

    real raw_m4_z0;
    real raw_m4_z1;

    real central_m3_z0;
    real central_m3_z1;

    real central_m4_z0;
    real central_m4_z1;


    //--------------------------------------------------
    // Minimum / Maximum
    //--------------------------------------------------

    real min_z0;
    real max_z0;

    real min_z1;
    real max_z1;


    //--------------------------------------------------
    // Gaussian Tail Analysis
    //
    // Counts samples where |z| >= 1,2,3,4,5,6
    //--------------------------------------------------

    integer z0_tail_1;
    integer z0_tail_2;
    integer z0_tail_3;
    integer z0_tail_4;
    integer z0_tail_5;
    integer z0_tail_6;

    integer z1_tail_1;
    integer z1_tail_2;
    integer z1_tail_3;
    integer z1_tail_4;
    integer z1_tail_5;
    integer z1_tail_6;

    real abs_z0;
    real abs_z1;


    //--------------------------------------------------
    // Throughput Variables
    //--------------------------------------------------

    real total_simulation_time_ns;
    real measured_pair_throughput;
    real measured_sample_throughput;


    //==================================================
    // MAIN SIMULATION
    //==================================================

    initial begin


        //--------------------------------------------------
        // Initial Values
        //--------------------------------------------------

        rst   = 1'b1;

        seed0 = 32'h12345678;
        seed1 = 32'h87654321;


        cycle_count       = 0;
        first_valid_cycle = 0;

        gaussian_pair_count = 0;
        prng_sample_count   = 0;

        zero_u0_count = 0;
        zero_u1_count = 0;

        valid_gap_count        = 0;
        consecutive_valid_count = 0;

        sample_print_count = 0;

        nan_inf_z0_count = 0;
        nan_inf_z1_count = 0;

        first_valid_seen = 1'b0;
        previous_valid   = 1'b0;


        //--------------------------------------------------
        // Initialize PRNG Statistics
        //--------------------------------------------------

        sum_u0    = 0.0;
        sum_u1    = 0.0;

        sum_u0_sq = 0.0;
        sum_u1_sq = 0.0;

        sum_u0_u1 = 0.0;


        //--------------------------------------------------
        // Initialize Gaussian Statistics
        //--------------------------------------------------

        sum_z0        = 0.0;
        sum_z1        = 0.0;

        sum_z0_sq     = 0.0;
        sum_z1_sq     = 0.0;

        sum_z0_cube   = 0.0;
        sum_z1_cube   = 0.0;

        sum_z0_fourth = 0.0;
        sum_z1_fourth = 0.0;

        sum_z0_z1     = 0.0;


        //--------------------------------------------------
        // Initialize Min / Max
        //--------------------------------------------------

        min_z0 =  1.0e30;
        max_z0 = -1.0e30;

        min_z1 =  1.0e30;
        max_z1 = -1.0e30;


        //--------------------------------------------------
        // Initialize Gaussian Tail Counters
        //--------------------------------------------------

        z0_tail_1 = 0;
        z0_tail_2 = 0;
        z0_tail_3 = 0;
        z0_tail_4 = 0;
        z0_tail_5 = 0;
        z0_tail_6 = 0;

        z1_tail_1 = 0;
        z1_tail_2 = 0;
        z1_tail_3 = 0;
        z1_tail_4 = 0;
        z1_tail_5 = 0;
        z1_tail_6 = 0;


        //--------------------------------------------------
        // Simulation Header
        //--------------------------------------------------

        $display("");
        $display("==========================================================");
        $display("       GAUSSIAN RNG RTL SIMULATION");
        $display("==========================================================");

        $display(
            "Clock Frequency       : %0f MHz",
            CLK_FREQ_MHZ
        );

        $display(
            "Clock Period          : %0f ns",
            CLK_PERIOD_NS
        );

        $display(
            "Seed0                 : %h",
            seed0
        );

        $display(
            "Seed1                 : %h",
            seed1
        );

        $display(
            "Target Gaussian Pairs : %0d",
            TARGET_GAUSSIAN_PAIRS
        );

        $display(
            "PRNG Samples          : %0d",
            TARGET_PRNG_SAMPLES
        );

        $display("==========================================================");
        $display("");


        //--------------------------------------------------
        // Hold Reset
        //--------------------------------------------------

        repeat (10) @(posedge clk);


        //--------------------------------------------------
        // Release Reset
        //--------------------------------------------------

        rst = 1'b0;

        $display("Reset released.");
        $display("");


        //==================================================
        // RUN UNTIL TARGET VALID GAUSSIAN PAIRS
        //==================================================

        while (gaussian_pair_count < TARGET_GAUSSIAN_PAIRS) begin

            @(posedge clk);

            cycle_count = cycle_count + 1;


            //--------------------------------------------------
            // PRNG DATA COLLECTION
            //--------------------------------------------------

            if (prng_sample_count < TARGET_PRNG_SAMPLES) begin

                u0_real =
                    uint32_to_real(debug_u0)
                    / 4294967296.0;

                u1_real =
                    uint32_to_real(debug_u1)
                    / 4294967296.0;

                prng_sample_count =
                    prng_sample_count + 1;

                sum_u0 =
                    sum_u0 + u0_real;

                sum_u1 =
                    sum_u1 + u1_real;

                sum_u0_sq =
                    sum_u0_sq +
                    (u0_real * u0_real);

                sum_u1_sq =
                    sum_u1_sq +
                    (u1_real * u1_real);

                sum_u0_u1 =
                    sum_u0_u1 +
                    (u0_real * u1_real);


                //--------------------------------------------------
                // Zero Checks
                //--------------------------------------------------

                if (debug_u0 == 32'h00000000) begin

                    zero_u0_count =
                        zero_u0_count + 1;

                end


                if (debug_u1 == 32'h00000000) begin

                    zero_u1_count =
                        zero_u1_count + 1;

                end

            end


            //--------------------------------------------------
            // VALID OUTPUT CONTINUITY CHECK
            //--------------------------------------------------

            if (first_valid_seen) begin

                if (previous_valid && !valid_out)
                    valid_gap_count =
                        valid_gap_count + 1;

            end


            if (valid_out)
                consecutive_valid_count =
                    consecutive_valid_count + 1;

            previous_valid = valid_out;


            //==================================================
            // VALID GAUSSIAN OUTPUT
            //==================================================

            if (valid_out) begin


                //--------------------------------------------------
                // First Valid Output
                //--------------------------------------------------

                if (!first_valid_seen) begin

                    first_valid_seen  = 1'b1;
                    first_valid_cycle = cycle_count;

                    $display("");
                    $display("==========================================================");
                    $display(" FIRST VALID GAUSSIAN OUTPUT");
                    $display("==========================================================");

                    $display(
                        "First Valid Cycle    : %0d",
                        first_valid_cycle
                    );

                    $display(
                        "Pipeline Latency     : %0d cycles",
                        first_valid_cycle
                    );

                    $display(
                        "Pipeline Latency     : %0f ns",
                        first_valid_cycle *
                        CLK_PERIOD_NS
                    );

                    $display(
                        "z0                   : %h",
                        z0
                    );

                    $display(
                        "z1                   : %h",
                        z1
                    );

                    $display("==========================================================");
                    $display("");

                end


                //--------------------------------------------------
                // Check NaN / Infinity
                //--------------------------------------------------

                if (z0[30:23] == 8'hFF)
                    nan_inf_z0_count =
                        nan_inf_z0_count + 1;

                if (z1[30:23] == 8'hFF)
                    nan_inf_z1_count =
                        nan_inf_z1_count + 1;


                //--------------------------------------------------
                // Convert IEEE-754 Outputs to Real
                //--------------------------------------------------

                z0_real = fp32_to_real(z0);
                z1_real = fp32_to_real(z1);


                //--------------------------------------------------
                // Gaussian Tail Analysis
                //--------------------------------------------------

                if (z0_real < 0.0)
                    abs_z0 = -z0_real;
                else
                    abs_z0 = z0_real;

                if (z1_real < 0.0)
                    abs_z1 = -z1_real;
                else
                    abs_z1 = z1_real;


                // z0 tails

                if (abs_z0 >= 1.0)
                    z0_tail_1 = z0_tail_1 + 1;

                if (abs_z0 >= 2.0)
                    z0_tail_2 = z0_tail_2 + 1;

                if (abs_z0 >= 3.0)
                    z0_tail_3 = z0_tail_3 + 1;

                if (abs_z0 >= 4.0)
                    z0_tail_4 = z0_tail_4 + 1;

                if (abs_z0 >= 5.0)
                    z0_tail_5 = z0_tail_5 + 1;

                if (abs_z0 >= 6.0)
                    z0_tail_6 = z0_tail_6 + 1;


                // z1 tails

                if (abs_z1 >= 1.0)
                    z1_tail_1 = z1_tail_1 + 1;

                if (abs_z1 >= 2.0)
                    z1_tail_2 = z1_tail_2 + 1;

                if (abs_z1 >= 3.0)
                    z1_tail_3 = z1_tail_3 + 1;

                if (abs_z1 >= 4.0)
                    z1_tail_4 = z1_tail_4 + 1;

                if (abs_z1 >= 5.0)
                    z1_tail_5 = z1_tail_5 + 1;

                if (abs_z1 >= 6.0)
                    z1_tail_6 = z1_tail_6 + 1;


                //--------------------------------------------------
                // Count Valid Gaussian Pair
                //--------------------------------------------------

                gaussian_pair_count =
                    gaussian_pair_count + 1;


                //--------------------------------------------------
                // Collect Gaussian Statistics
                //--------------------------------------------------

                sum_z0 =
                    sum_z0 + z0_real;

                sum_z1 =
                    sum_z1 + z1_real;


                sum_z0_sq =
                    sum_z0_sq +
                    (z0_real * z0_real);

                sum_z1_sq =
                    sum_z1_sq +
                    (z1_real * z1_real);


                sum_z0_cube =
                    sum_z0_cube +
                    (z0_real * z0_real * z0_real);

                sum_z1_cube =
                    sum_z1_cube +
                    (z1_real * z1_real * z1_real);


                sum_z0_fourth =
                    sum_z0_fourth +
                    (z0_real *
                     z0_real *
                     z0_real *
                     z0_real);

                sum_z1_fourth =
                    sum_z1_fourth +
                    (z1_real *
                     z1_real *
                     z1_real *
                     z1_real);


                sum_z0_z1 =
                    sum_z0_z1 +
                    (z0_real * z1_real);


                //--------------------------------------------------
                // Min / Max
                //--------------------------------------------------

                if (z0_real < min_z0)
                    min_z0 = z0_real;

                if (z0_real > max_z0)
                    max_z0 = z0_real;

                if (z1_real < min_z1)
                    min_z1 = z1_real;

                if (z1_real > max_z1)
                    max_z1 = z1_real;


                //--------------------------------------------------
                // Print First 20 Gaussian Pairs
                //--------------------------------------------------

                if (sample_print_count < 20) begin

                    sample_print_count =
                        sample_print_count + 1;

                    $display(
                        "Gaussian Pair %0d : z0 = %f   z1 = %f",
                        sample_print_count,
                        z0_real,
                        z1_real
                    );

                end

            end

        end


        //==================================================
        // FINAL PRNG STATISTICAL ANALYSIS
        //==================================================

        mean_u0 =
            sum_u0 / prng_sample_count;

        mean_u1 =
            sum_u1 / prng_sample_count;


        var_u0 =
            (sum_u0_sq / prng_sample_count)
            -
            (mean_u0 * mean_u0);

        var_u1 =
            (sum_u1_sq / prng_sample_count)
            -
            (mean_u1 * mean_u1);


        if (var_u0 < 0.0)
            var_u0 = 0.0;

        if (var_u1 < 0.0)
            var_u1 = 0.0;


        std_u0 = $sqrt(var_u0);
        std_u1 = $sqrt(var_u1);


        expected_u_product =
            sum_u0_u1 / prng_sample_count;


        covariance_u0_u1 =
            expected_u_product -
            (mean_u0 * mean_u1);


        prng_denominator =
            std_u0 * std_u1;


        if (prng_denominator != 0.0)
            correlation_u0_u1 =
                covariance_u0_u1 /
                prng_denominator;
        else
            correlation_u0_u1 = 0.0;


        //==================================================
        // FINAL GAUSSIAN STATISTICAL ANALYSIS
        //==================================================

        mean_z0 =
            sum_z0 / gaussian_pair_count;

        mean_z1 =
            sum_z1 / gaussian_pair_count;


        // Raw Moments

        raw_m2_z0 =
            sum_z0_sq / gaussian_pair_count;

        raw_m2_z1 =
            sum_z1_sq / gaussian_pair_count;

        raw_m3_z0 =
            sum_z0_cube / gaussian_pair_count;

        raw_m3_z1 =
            sum_z1_cube / gaussian_pair_count;

        raw_m4_z0 =
            sum_z0_fourth / gaussian_pair_count;

        raw_m4_z1 =
            sum_z1_fourth / gaussian_pair_count;


        // Variance

        variance_z0 =
            raw_m2_z0 -
            (mean_z0 * mean_z0);

        variance_z1 =
            raw_m2_z1 -
            (mean_z1 * mean_z1);


        if (variance_z0 < 0.0)
            variance_z0 = 0.0;

        if (variance_z1 < 0.0)
            variance_z1 = 0.0;


        // Standard Deviation

        std_z0 = $sqrt(variance_z0);
        std_z1 = $sqrt(variance_z1);


        // Third Central Moment

        central_m3_z0 =
            raw_m3_z0
            -
            3.0 * mean_z0 * raw_m2_z0
            +
            2.0 * mean_z0 *
            mean_z0 *
            mean_z0;

        central_m3_z1 =
            raw_m3_z1
            -
            3.0 * mean_z1 * raw_m2_z1
            +
            2.0 * mean_z1 *
            mean_z1 *
            mean_z1;


        // Fourth Central Moment

        central_m4_z0 =
            raw_m4_z0
            -
            4.0 * mean_z0 * raw_m3_z0
            +
            6.0 * mean_z0 *
            mean_z0 *
            raw_m2_z0
            -
            3.0 *
            mean_z0 *
            mean_z0 *
            mean_z0 *
            mean_z0;

        central_m4_z1 =
            raw_m4_z1
            -
            4.0 * mean_z1 * raw_m3_z1
            +
            6.0 * mean_z1 *
            mean_z1 *
            raw_m2_z1
            -
            3.0 *
            mean_z1 *
            mean_z1 *
            mean_z1 *
            mean_z1;


        // Skewness

        if (std_z0 != 0.0)
            skewness_z0 =
                central_m3_z0 /
                (std_z0 * std_z0 * std_z0);
        else
            skewness_z0 = 0.0;

        if (std_z1 != 0.0)
            skewness_z1 =
                central_m3_z1 /
                (std_z1 * std_z1 * std_z1);
        else
            skewness_z1 = 0.0;


        // Kurtosis

        if (variance_z0 != 0.0)
            kurtosis_z0 =
                central_m4_z0 /
                (variance_z0 * variance_z0);
        else
            kurtosis_z0 = 0.0;

        if (variance_z1 != 0.0)
            kurtosis_z1 =
                central_m4_z1 /
                (variance_z1 * variance_z1);
        else
            kurtosis_z1 = 0.0;


        // z0-z1 Covariance

        expected_z_product =
            sum_z0_z1 / gaussian_pair_count;

        covariance_z0_z1 =
            expected_z_product -
            (mean_z0 * mean_z1);

        gaussian_denominator =
            std_z0 * std_z1;

        if (gaussian_denominator != 0.0)
            correlation_z0_z1 =
                covariance_z0_z1 /
                gaussian_denominator;
        else
            correlation_z0_z1 = 0.0;


        //==================================================
        // THROUGHPUT CALCULATION
        //==================================================

        total_simulation_time_ns =
            cycle_count * CLK_PERIOD_NS;

        if (total_simulation_time_ns > 0.0) begin

            measured_pair_throughput =
                gaussian_pair_count *
                1.0e9 /
                total_simulation_time_ns;

            measured_sample_throughput =
                gaussian_pair_count *
                2.0 *
                1.0e9 /
                total_simulation_time_ns;

        end

        else begin

            measured_pair_throughput   = 0.0;
            measured_sample_throughput = 0.0;

        end


        //==================================================
        // FINAL RESULTS
        //==================================================

        $display("");
        $display("==========================================================");
        $display(" FINAL SIMULATION RESULTS");
        $display("==========================================================");

        $display(
            "Total Simulation Cycles      : %0d",
            cycle_count
        );

        $display(
            "Valid Gaussian Output Pairs  : %0d",
            gaussian_pair_count
        );


        // Latency

        $display("");
        $display("LATENCY:");

        if (first_valid_seen) begin

            $display(
                "First Valid Cycle            : %0d",
                first_valid_cycle
            );

            $display(
                "Pipeline Latency             : %0d cycles",
                first_valid_cycle
            );

            $display(
                "Pipeline Latency             : %0f ns",
                first_valid_cycle *
                CLK_PERIOD_NS
            );

        end

        else begin

            $display(
                "ERROR: No valid Gaussian output detected!"
            );

        end


        // Uniform Input Check

        $display("");
        $display("UNIFORM RANDOM INPUT CHECK:");

        $display(
            "debug_u0 = 0 occurrences     : %0d",
            zero_u0_count
        );

        $display(
            "debug_u1 = 0 occurrences     : %0d",
            zero_u1_count
        );


        // PRNG Statistics

        $display("");
        $display("TAUS CROSS-STREAM STATISTICAL ANALYSIS:");

        $display(
            "Number of PRNG Samples       : %0d",
            prng_sample_count
        );

        $display(
            "Mean u0                      : %f",
            mean_u0
        );

        $display(
            "Mean u1                      : %f",
            mean_u1
        );

        $display(
            "Variance u0                  : %f",
            var_u0
        );

        $display(
            "Variance u1                  : %f",
            var_u1
        );

        $display(
            "Covariance(u0,u1)            : %f",
            covariance_u0_u1
        );

        $display(
            "Pearson Cross-Correlation    : %f",
            correlation_u0_u1
        );


        // Gaussian Statistics

        $display("");
        $display("GAUSSIAN OUTPUT STATISTICAL ANALYSIS:");

        $display(
            "Number of Gaussian Pairs     : %0d",
            gaussian_pair_count
        );

        $display("");

        $display(
            "Mean z0                      : %f",
            mean_z0
        );

        $display(
            "Mean z1                      : %f",
            mean_z1
        );

        $display("");

        $display(
            "Variance z0                  : %f",
            variance_z0
        );

        $display(
            "Variance z1                  : %f",
            variance_z1
        );

        $display("");

        $display(
            "Standard Deviation z0        : %f",
            std_z0
        );

        $display(
            "Standard Deviation z1        : %f",
            std_z1
        );

        $display("");

        $display(
            "Skewness z0                  : %f",
            skewness_z0
        );

        $display(
            "Skewness z1                  : %f",
            skewness_z1
        );

        $display("");

        $display(
            "Kurtosis z0                  : %f",
            kurtosis_z0
        );

        $display(
            "Kurtosis z1                  : %f",
            kurtosis_z1
        );

        $display("");

        $display(
            "Minimum z0                   : %f",
            min_z0
        );

        $display(
            "Maximum z0                   : %f",
            max_z0
        );

        $display(
            "Minimum z1                   : %f",
            min_z1
        );

        $display(
            "Maximum z1                   : %f",
            max_z1
        );

        $display("");

        $display(
            "Covariance(z0,z1)            : %f",
            covariance_z0_z1
        );

        $display(
            "Pearson Cross-Correlation    : %f",
            correlation_z0_z1
        );


        //--------------------------------------------------
        // Gaussian Tail Analysis
        //--------------------------------------------------

        $display("");
        $display("==========================================================");
        $display("GAUSSIAN TAIL ANALYSIS");
        $display("==========================================================");
        $display("Tail definition: |z| >= k sigma");
        $display("");

        $display("THEORETICAL TWO-SIDED TAIL PROBABILITIES:");
        $display("|z| >= 1 sigma : 0.3173105");
        $display("|z| >= 2 sigma : 0.0455003");
        $display("|z| >= 3 sigma : 0.0026998");
        $display("|z| >= 4 sigma : 0.0000633");
        $display("|z| >= 5 sigma : 0.000000573");
        $display("|z| >= 6 sigma : 0.00000000197");

        $display("");
        $display("Z0 OBSERVED TAILS:");

        $display("|z0| >= 1 sigma : %0d  Probability = %f",
                 z0_tail_1,
                 z0_tail_1 * 1.0 / gaussian_pair_count);

        $display("|z0| >= 2 sigma : %0d  Probability = %f",
                 z0_tail_2,
                 z0_tail_2 * 1.0 / gaussian_pair_count);

        $display("|z0| >= 3 sigma : %0d  Probability = %f",
                 z0_tail_3,
                 z0_tail_3 * 1.0 / gaussian_pair_count);

        $display("|z0| >= 4 sigma : %0d  Probability = %f",
                 z0_tail_4,
                 z0_tail_4 * 1.0 / gaussian_pair_count);

        $display("|z0| >= 5 sigma : %0d  Probability = %f",
                 z0_tail_5,
                 z0_tail_5 * 1.0 / gaussian_pair_count);

        $display("|z0| >= 6 sigma : %0d  Probability = %f",
                 z0_tail_6,
                 z0_tail_6 * 1.0 / gaussian_pair_count);


        $display("");
        $display("Z1 OBSERVED TAILS:");

        $display("|z1| >= 1 sigma : %0d  Probability = %f",
                 z1_tail_1,
                 z1_tail_1 * 1.0 / gaussian_pair_count);

        $display("|z1| >= 2 sigma : %0d  Probability = %f",
                 z1_tail_2,
                 z1_tail_2 * 1.0 / gaussian_pair_count);

        $display("|z1| >= 3 sigma : %0d  Probability = %f",
                 z1_tail_3,
                 z1_tail_3 * 1.0 / gaussian_pair_count);

        $display("|z1| >= 4 sigma : %0d  Probability = %f",
                 z1_tail_4,
                 z1_tail_4 * 1.0 / gaussian_pair_count);

        $display("|z1| >= 5 sigma : %0d  Probability = %f",
                 z1_tail_5,
                 z1_tail_5 * 1.0 / gaussian_pair_count);

        $display("|z1| >= 6 sigma : %0d  Probability = %f",
                 z1_tail_6,
                 z1_tail_6 * 1.0 / gaussian_pair_count);


        //--------------------------------------------------
        // NaN / Infinity Check
        //--------------------------------------------------

        $display("");
        $display("FLOATING-POINT EXCEPTION CHECK:");

        $display(
            "z0 NaN/Infinity occurrences : %0d",
            nan_inf_z0_count
        );

        $display(
            "z1 NaN/Infinity occurrences : %0d",
            nan_inf_z1_count
        );


        //--------------------------------------------------
        // Pipeline Continuity
        //--------------------------------------------------

        $display("");
        $display("PIPELINE CONTINUITY:");

        $display(
            "Consecutive Valid Cycles     : %0d",
            consecutive_valid_count
        );

        $display(
            "Valid Output Gaps            : %0d",
            valid_gap_count
        );


        //--------------------------------------------------
        // Throughput
        //--------------------------------------------------

        $display("");
        $display("THROUGHPUT ANALYSIS:");

        $display(
            "Measured Pair Throughput     : %0f pairs/sec",
            measured_pair_throughput
        );

        $display(
            "Measured Sample Throughput   : %0f samples/sec",
            measured_sample_throughput
        );


        //--------------------------------------------------
        // Theoretical Steady State
        //--------------------------------------------------

        $display("");
        $display("THEORETICAL STEADY-STATE:");

        $display(
            "Clock Frequency              : %0f MHz",
            CLK_FREQ_MHZ
        );

        $display(
            "Theoretical Pair Rate        : %0f pairs/sec",
            CLK_FREQ_MHZ * 1_000_000.0
        );

        $display(
            "Theoretical Sample Rate      : %0f samples/sec",
            2.0 * CLK_FREQ_MHZ * 1_000_000.0
        );


        //==================================================
        // BASIC GAUSSIAN PROPERTY ASSESSMENT
        //==================================================

        $display("");
        $display("GAUSSIAN PROPERTY ASSESSMENT:");

        $display(
            "Ideal Mean                   : approximately 0"
        );

        $display(
            "Ideal Variance               : approximately 1"
        );

        $display(
            "Ideal Std. Deviation         : approximately 1"
        );

        $display(
            "Ideal Skewness               : approximately 0"
        );

        $display(
            "Ideal Kurtosis               : approximately 3"
        );

        $display(
            "Ideal z0-z1 Correlation      : approximately 0"
        );


        //--------------------------------------------------
        // Final Status
        //--------------------------------------------------

        $display("");
        $display("==========================================================");

        if (first_valid_seen &&
            gaussian_pair_count == TARGET_GAUSSIAN_PAIRS &&
            nan_inf_z0_count == 0 &&
            nan_inf_z1_count == 0 &&
            valid_gap_count == 0) begin

            $display(
                "SIMULATION COMPLETED SUCCESSFULLY"
            );

        end

        else begin

            $display(
                "SIMULATION COMPLETED WITH WARNINGS"
            );

        end

        $display("==========================================================");
        $display("");


        //--------------------------------------------------
        // Finish
        //--------------------------------------------------

        repeat (5) @(posedge clk);

        $finish;

    end

endmodule