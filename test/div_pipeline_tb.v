`timescale 1ns / 1ps
`include "div_pipeline.v"
`include "div_no_pipeline.v"

module div_pipeline_tb;
    reg clk;
    reg reset;
    reg start;
    reg [7:0] dividend;
    reg [7:0] divisor;
    wire valid;
    wire [7:0] quotient;
    wire [7:0] remainder;
    wire [7:0] quotient_no_pip;
    wire [7:0] remainder_no_pip;
    wire ready;
    wire ready_no_pip;

    div_no_pipeline  div_no_pipeline_inst (
        .clk(clk),
        .dividend(dividend),
        .divider(divisor),
        .quotient(quotient_no_pip),
        .start(start),
        .remainder(remainder_no_pip),
        .ready(ready_no_pip)
    );

    div_pipeline uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .valid(valid),
        .quotient(quotient),
        .remainder(remainder),
        .result_ready(ready)
    );

    // Clock generator
    always #5 clk = ~clk;

    // Test cases: dividend / divisor
    reg [7:0] test_dividends [0:7];
    reg [7:0] test_divisors [0:7];
    integer i;

    task send_operands;
        input [7:0] operand_a;
        input [7:0] operand_b;
        begin
            @(posedge clk);
            divisor = operand_a;
            dividend = operand_b;
            start = 1;
            $display("Time %t: Sending operands A=%d, B=%d", $time, operand_a, operand_b);
            @(posedge clk);
            start = 0;
        end
    endtask

    reg [7:0] test1;
    reg [7:0] test2;

    initial begin
        $dumpfile("div_pipeline_tb.vcd");
        $dumpvars(0, div_pipeline_tb);
        $display("Starting div_pipeline testbench...");
        clk = 0;
        reset = 1;
        start = 0;
        dividend = 1;
        divisor = 1;
        
        // Release reset
        #20 reset = 0;

        // Continuously feed data
        for (i = 1; i < 100; i = i + 1) begin
            test1 = $random;
            test2 = $random;

            if (test1 > test2) begin
                send_operands(test2, test1);
            end else begin
                send_operands(test1, test2);              
            end
            // Wait enough time between operations
        end
        
        // Wait enough cycles to empty the pipeline
        #200;

        $finish;
    end

    // Display results when they are ready
    always @(posedge clk) begin
        if (valid) begin
            $display("Valid output -> Quotient = %0d, Remainder = %0d", quotient, remainder);
        end
    end

endmodule
