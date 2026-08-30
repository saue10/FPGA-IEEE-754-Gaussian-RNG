# FPGA-Based Gaussian Random Number Generator

## Overview

This project implements a high-throughput Gaussian random number generator
(GRNG) on a Xilinx Zynq-7000 XC7Z020 FPGA using the Box--Muller
transformation.

The architecture combines two independently seeded 32-bit TAUS-based
pseudorandom number generators with an IEEE-754 single-precision floating-point
radial datapath and LUT-based trigonometric computation. The design generates
two Gaussian outputs, `z0` and `z1`, concurrently.

The implementation is deeply pipelined to support continuous generation of one
Gaussian output pair per clock cycle after pipeline filling.

---

## Key Features

- FPGA-based Gaussian random number generation
- Box--Muller transformation
- Two independent 32-bit TAUS-based PRNGs
- IEEE-754 single-precision floating-point arithmetic
- Parallel radial and angular processing paths
- 4096-entry sine and cosine lookup tables
- Two Gaussian outputs per Box--Muller input pair
- Deeply pipelined architecture
- AXI4-Stream interface
- AXI DMA integration for DDR data collection
- Floating-point logarithm and square-root operations using Xilinx IP
- Protection against the `u0 = 0` / `ln(0)` condition
- RTL-based statistical validation
- NIST Statistical Test Suite (NIST STS) evaluation of the uniform streams

---

## Architecture

The overall processing flow is:

    TAUS PRNG 0 ──> u0 ──> Radial Path ─────────┐
                                                 │
                                                 ├──> z0
                                                 │
    TAUS PRNG 1 ──> u1 ──> Angular LUT Path ────┤
                                                 │
                                                 └──> z1

The Box--Muller transformation is given by

    z0 = sqrt(-2 ln(u0)) cos(2 pi u1)

    z1 = sqrt(-2 ln(u0)) sin(2 pi u1)

The radial component is calculated as

    r = sqrt(-2 ln(u0))

while the angular component is obtained from the sine and cosine lookup
tables.

---

## Radial Processing Path

The radial datapath performs the following operations:

    TAUS output
        |
        v
    Integer-to-Floating-Point Conversion
        |
        v
    Normalization by 2^-32
        |
        v
    Natural Logarithm
        |
        v
    Multiplication by -2
        |
        v
    Square Root
        |
        v
        r

The nonlinear floating-point operations use Xilinx Floating-Point IP cores
configured for IEEE-754 single precision.

To avoid the singularity at `ln(0)`, a zero-valued PRNG output is protected
before normalization.

---

## Angular Processing Path

The second TAUS generator supplies the angular input.

A 12-bit address is derived from the 32-bit uniform stream and used to access
two independent 4096-entry lookup tables:

- `sin_rom`
- `cos_rom`

The angular resolution is

    Δθ = 2π / 4096
       = 0.00153398 rad
       = 0.087890625°

The sine and cosine values are generated in parallel and forwarded to the
final floating-point multipliers.

---

## Gaussian Output Generation

The radial and angular paths are combined using two parallel floating-point
multipliers:

    z0 = r × cos(θ)

    z1 = r × sin(θ)

Therefore, one Box--Muller input pair produces two Gaussian outputs.

After pipeline filling, the architecture supports one Gaussian pair per clock
cycle.

---

## TAUS PRNG Configuration

Two independently seeded TAUS generators are used:

| Stream | Seed | Purpose |
|--------|------|---------|
| `TAUS_0` | `0x12345678` | Radial input `u0` |
| `TAUS_1` | `0x87654321` | Angular input `u1` |

Each TAUS generator consists of three 32-bit state registers and uses shift,
mask, and XOR operations to update the generator state.

The two streams were evaluated for cross-stream linear dependence.

Measured Pearson cross-correlation:

    -0.004188

This indicates negligible linear dependence over the evaluated sequence.

---

## AXI4-Stream and DMA

The Gaussian core provides a 32-bit AXI4-Stream output for hardware data
collection.

The data path is:

    Gaussian Core
          |
          v
    AXI4-Stream
          |
          v
       AXI DMA
          |
          v
      DDR Memory

An AXI4-Stream transfer occurs when:

    TVALID && TREADY

The source maintains the current data until the handshake is completed.

The implemented collection path streams `z0` to DDR memory. The second output
`z1` remains available at the Gaussian core output and is evaluated separately
during RTL simulation.

---

## FPGA Implementation

### Target Device

- **FPGA:** Xilinx Zynq-7000 XC7Z020
- **Tool:** Vivado 2025.1
- **Operating frequency:** 155 MHz

### Resource Utilization

| Resource | Utilization |
|----------|-------------|
| LUTs | 3219 |
| Registers | 4888 |
| Block RAMs | 5 |
| DSP Slices | 19 |

### Timing

Post-implementation timing at 155 MHz:

| Parameter | Result |
|-----------|--------|
| WNS | +0.393 ns |
| TNS | 0.000 ns |
| WHS | +0.290 ns |
| THS | 0.000 ns |
| Setup violations | 0 |
| Hold violations | 0 |

The design therefore achieves timing closure at the reported 155 MHz
operating point.

---

## Pipeline Performance

The measured pipeline latency is:

    86 cycles

At 155 MHz:

    Clock period ≈ 6.4516 ns

    Latency = 86 × 6.4516
            ≈ 554.84 ns

After pipeline filling, one Gaussian pair is generated per clock cycle.

### Throughput

Measured RTL throughput:

    154.87 Mpairs/s

Since each pair contains two Gaussian samples:

    309.74 MSamples/s

The theoretical steady-state throughput at 155 MHz is:

    155 Mpairs/s

    310 MSamples/s

---

## Statistical Validation

The Gaussian outputs were evaluated using:

- Mean
- Variance
- Standard deviation
- Skewness
- Pearson kurtosis
- `z0`--`z1` cross-correlation
- Tail probabilities
- Floating-point exception checks

The expanded RTL evaluation used:

    100,000 Gaussian output pairs

corresponding to:

    200,000 Gaussian samples

### Gaussian Output Statistics

| Metric | z0 | z1 | Ideal |
|--------|----:|----:|----:|
| Mean | 0.004990 | -0.000506 | 0 |
| Variance | 0.997038 | 1.000860 | 1 |
| Standard deviation | 0.998518 | 1.000430 | 1 |
| Skewness | 0.002389 | -0.004158 | 0 |
| Pearson kurtosis | 3.005732 | 2.984174 | 3 |

Measured output cross-correlation:

    z0-z1 correlation = -0.001270

The generated outputs therefore show close agreement with the target standard
normal distribution over the evaluated sequence.

No NaN or infinity outputs were observed during the evaluation.

---

## Tail Evaluation

The generated Gaussian samples were evaluated at thresholds from:

    |z| >= 1σ

through

    |z| >= 6σ

The observed probabilities through approximately 3σ closely follow the
theoretical Gaussian probabilities.

The absence of samples beyond 5σ and 6σ in the finite evaluation is consistent
with the very small expected occurrence rate at those thresholds for the
available sample size.

---

## Angular LUT Accuracy

All 4096 sine and cosine entries were compared against their corresponding
ideal values.

Measured errors:

| Parameter | Result |
|-----------|--------:|
| Cosine peak error | 2.979808 × 10^-8 |
| Cosine RMS error | 1.502588 × 10^-8 |
| Sine peak error | 2.979808 × 10^-8 |
| Sine RMS error | 1.502589 × 10^-8 |
| Vector peak error | 4.208319 × 10^-8 |
| Vector RMS error | 2.124981 × 10^-8 |

The measured LUT errors are very small relative to the generated Gaussian
output statistics.

---

## NIST STS Validation

The underlying TAUS-based uniform streams were additionally evaluated using
the NIST Statistical Test Suite (NIST STS).

The purpose of this evaluation is to assess the statistical quality of the
uniform pseudorandom sources before the Box--Muller transformation.

Both TAUS streams were evaluated independently, and the resulting NIST STS
reports were examined for the applicable statistical tests.

The NIST STS results complement the Gaussian-domain validation by testing the
random sources at the input of the transformation rather than only testing
the final Gaussian outputs.

---

## Verification Flow

The verification process consists of multiple levels:

    TAUS PRNG Verification
            |
            +--> NIST STS
            |
            +--> Cross-stream correlation
            |
            v
    Box--Muller Transformation
            |
            v
    Gaussian Outputs
            |
            +--> Mean
            +--> Variance
            +--> Skewness
            +--> Kurtosis
            +--> Cross-correlation
            +--> Tail analysis
            +--> Floating-point checks
            |
            v
    FPGA Timing / Resource Verification

This provides both source-level and output-level validation of the proposed
Gaussian random number generator.

---

## Project Structure

The exact file structure may vary depending on the Vivado project, but the
repository contains the RTL and supporting files required for the FPGA
implementation.

Typical components include:

    RTL/
        TAUS PRNG modules
        Gaussian generator
        Radial processing
        Angular LUT processing
        Output generation
        AXI4-Stream interface

    Simulation/
        Testbench
        Simulation sources
        Verification files

    IP/
        Floating-point IP configurations
        Supporting Vivado IP

    LUT/
        Sine lookup table
        Cosine lookup table

    Documentation/
        Architecture diagrams
        Results
        Paper-related material

---

## Requirements

- Xilinx Vivado 2025.1
- Xilinx Zynq-7000 XC7Z020 FPGA
- Xilinx Floating-Point IP
- AXI DMA
- AXI4-Stream infrastructure
- Verilog/SystemVerilog RTL simulation environment

NIST STS is additionally required to reproduce the uniform-stream statistical
testing.

---

## Reproducibility

The RTL verification uses fixed seeds:

    seed0 = 0x12345678
    seed1 = 0x87654321

Using the same RTL, IP configuration, seeds, lookup tables, and simulation
configuration allows the reported verification results to be reproduced.

---

## Performance Summary

| Parameter | Result |
|-----------|--------|
| FPGA | Zynq-7000 XC7Z020 |
| Clock frequency | 155 MHz |
| Pipeline latency | 86 cycles |
| Latency | 554.84 ns |
| Gaussian pairs/cycle | 1 |
| Gaussian samples/cycle | 2 |
| Measured throughput | 309.74 MSamples/s |
| LUTs | 3219 |
| Registers | 4888 |
| BRAMs | 5 |
| DSP slices | 19 |
| Gaussian pairs evaluated | 100,000 |
| Gaussian samples evaluated | 200,000 |
| z0-z1 correlation | -0.001270 |
| TAUS cross-stream correlation | -0.004188 |

---

## Research Paper

This implementation accompanies the research work on an IEEE-754-compliant
pipelined Box--Muller architecture for high-throughput Gaussian random number
generation.

The repository is intended to provide the RTL implementation, verification
methodology, FPGA implementation details, and statistical evaluation associated
with the proposed architecture.

---

## Author

**Saurabh Rai**

FPGA / Machine Learning / Data Science Research
