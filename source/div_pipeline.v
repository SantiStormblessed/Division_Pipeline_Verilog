module div_pipeline (
    input clk,
    input reset,
    input start,
    input [7:0] dividend,
    input [7:0] divisor,
    output reg valid,            // High for one cycle when result is ready
    output reg [7:0] quotient,   // Cleared after one cycle
    output reg [7:0] remainder,   // Cleared after one cycle
    output reg result_ready // Internal flag for new result
);
    // Pipeline stages (0 for load, 1-8 for bit processing)
    reg [7:0] dividend_pipe [0:8];
    reg [7:0] divisor_pipe  [0:8];
    reg [7:0] quotient_pipe [0:8];
    reg [8:0] remainder_pipe [0:8]; // 9 bits for overflow
    reg valid_pipe [0:8];
    
    integer i;
    reg [8:0] temp; // Temporary calculation value
    

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all outputs and pipeline
            valid <= 0;
            quotient <= 0;
            remainder <= 0;
            result_ready <= 0;
            for (i = 0; i <= 8; i = i + 1) begin
                valid_pipe[i]    <= 0;
                quotient_pipe[i] <= 0;
                remainder_pipe[i] <= 0;
                dividend_pipe[i] <= 0;
                divisor_pipe[i]  <= 0;
            end
        end else begin
            // Default outputs (will be overridden if new result)
            valid <= 0;
            quotient <= 0;
            remainder <= 0;
            
            // Set outputs for one cycle when result is ready
            if (result_ready) begin
                valid <= 1;
                quotient <= quotient_pipe[8];
                remainder <= remainder_pipe[8][7:0];
                result_ready <= 0; // Clear the flag after output
            end
            
            // Check if new result is available from pipeline
            if (valid_pipe[8] && !result_ready) begin
                result_ready <= 1; // Flag that we have a new result
            end
            
            // Pipeline propagation
            // Stage 8 gets from stage 7
            valid_pipe[8] <= valid_pipe[7];
            quotient_pipe[8] <= quotient_pipe[7];
            remainder_pipe[8] <= remainder_pipe[7];
            dividend_pipe[8] <= dividend_pipe[7];
            divisor_pipe[8] <= divisor_pipe[7];
            
            // Stage 0: load new operation
            if (start) begin
                dividend_pipe[0] <= dividend;
                divisor_pipe[0]  <= divisor;
                quotient_pipe[0] <= 0;
                remainder_pipe[0] <= 0;
                valid_pipe[0]    <= 1;
            end else begin
                valid_pipe[0] <= 0;
            end
            
            // Stages 1-8: bit processing
            for (i = 1; i <= 8; i = i + 1) begin
                // Operand propagation
                dividend_pipe[i] <= dividend_pipe[i-1];
                divisor_pipe[i]  <= divisor_pipe[i-1];
                
                // Extract bit from dividend and shift into remainder
                temp = (remainder_pipe[i-1] << 1) | dividend_pipe[i-1][7 - (i - 1)];
                
                // Subtract divisor if possible
                if (temp >= divisor_pipe[i-1]) begin
                    remainder_pipe[i] <= temp - divisor_pipe[i-1];
                    quotient_pipe[i] <= quotient_pipe[i-1] | (1 << (7 - (i - 1)));
                end else begin
                    remainder_pipe[i] <= temp;
                    quotient_pipe[i] <= quotient_pipe[i-1];
                end
                
                valid_pipe[i] <= valid_pipe[i-1];
            end
        end
    end
endmodule