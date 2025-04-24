# Division Modules with and without Pipelines

This project contains Verilog implementations of division algorithms, both with and without pipelining, along with a testbench to verify their functionality.

## File Descriptions

1. **div_no_pipeline.v**:

   - Implements a non-pipelined division module using the restoring division algorithm.
   - Processes one bit of the quotient per clock cycle.
   - Supports both signed and unsigned division, configurable via the `sign` parameter.
   - Outputs the quotient and remainder after the division is complete.

2. **div_pipeline.v**:

   - Implements a pipelined division module.
   - Uses pipelining to improve throughput by dividing the operation into multiple stages.
   - Outputs results with a delay corresponding to the number of pipeline stages.

3. **div_pipeline_tb.v**:
   - Testbench for both the non-pipelined and pipelined division modules.
   - Generates random test cases and compares the results of both modules.
   - Outputs simulation results to a `.vcd` file for waveform analysis.

---

## Non-Pipelined Division Module (div_no_pipeline.v)

- **Algorithm**: Restoring division.
- **Key Features**:
  - Handles signed and unsigned division.
  - Configurable bit width via the `WIDTH` parameter.
  - Outputs a `ready` signal to indicate when the division is complete.
- **Ports**:
  - `clk`: Clock signal.
  - `start`: Start signal for initiating division.
  - `dividend`: Dividend input.
  - `divider`: Divisor input.
  - `quotient`: Quotient output.
  - `remainder`: Remainder output.
  - `ready`: Indicates when the division is complete.

---

## Pipelined Division Module (div_pipeline.v)

- **Algorithm**: Pipelined division.
- **Key Features**:
  - Higher throughput due to pipelining.
  - Outputs a `valid` signal to indicate when the result is ready.
- **Ports**:
  - `clk`: Clock signal.
  - `reset`: Reset signal for the pipeline.
  - `start`: Start signal for initiating division.
  - `dividend`: Dividend input.
  - `divisor`: Divisor input.
  - `quotient`: Quotient output.
  - `remainder`: Remainder output.
  - `valid`: Indicates when the output is valid.

---

## Testbench (div_pipeline_tb.v)

- **Purpose**: Verifies the functionality of both the non-pipelined and pipelined division modules.
- **Key Features**:
  - Generates random test cases for division.
  - Compares the results of the non-pipelined and pipelined modules.
  - Outputs simulation results to a `.vcd` file for waveform analysis.
- **Simulation Flow**:
  1. Initializes the modules and resets signals.
  2. Generates random dividend and divisor values.
  3. Feeds the operands to both modules and waits for results.
  4. Displays the quotient and remainder when the results are ready.

---

## Comparison: Pipelined vs Non-Pipelined

| Feature    | Non-Pipelined (div_no_pipeline) | Pipelined (div_pipeline)               |
| ---------- | ------------------------------- | -------------------------------------- |
| Throughput | Low (one operation at a time)   | High (multiple operations in parallel) |
| Latency    | Short                           | Longer (depends on pipeline stages)    |
| Complexity | Simple                          | Higher (requires pipeline registers)   |
| Use Case   | Low-speed applications          | High-speed applications                |

## GTKWave

1. **General view of the results**:

![general_view]

[general_view]: https://github.com/SantiStormblessed/Division_Pipeline_Verilog/blob/main/images/muestra_general.png "General view"

This are the results visualized on GTKWave.

2. **Data loss on non-pipeline algorithm**:

![Algorithm_comparison]

[Algorithm_comparison]: https://github.com/SantiStormblessed/Division_Pipeline_Verilog/blob/main/images/ejemplo_datos_perdidos.png "Algorithm comparison"

In the first picture we can appreciate that both algorithms successfully performed the division, with the non-pipeline version
providing a result a couple clock cycles faster.

This speed comes at the cost of some data being lost as seen in the second picture circled in red. The pipeline version of the algorithm
doesn't have any trouble performing this operation at a rate of one per clock cycle (yellow circle).
