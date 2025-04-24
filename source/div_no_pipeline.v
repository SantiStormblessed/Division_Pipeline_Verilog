// Restoring division algorithm implementation (non-pipelined)
// Source: https://web.mit.edu/6.111/volume2/www/f2019/handouts/L09.pdf
// Source: http://en.wikipedia.org/wiki/Division_(digital)#Restoring_division
module div_no_pipeline 
(   input clk, start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divider,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output ready);

    parameter WIDTH = 8;     // Bit width for inputs/outputs
    parameter sign = 0;      // If 1, enables signed division

    reg en_proceso;          // Division in progress flag

    reg [WIDTH-1:0] quotient_temp;  // Accumulator for quotient result
    reg [WIDTH*2-1:0] dividend_copy, divider_copy, diff; // Intermediate registers
    reg negative_output;     // Indicates if result should be negative

    reg [5:0] bit;           // Counter for number of bits processed
    reg del_ready = 1;       // Delayed ready signal for synchronization
    wire ready = (!bit) & ~del_ready; // Indicates division completion
    wire [WIDTH-2:0] zeros = 0;       // Zero padding

    initial bit = 0;
    initial negative_output = 0;
    initial en_proceso = 0;

    // Main control logic
    always @( posedge clk ) begin
        del_ready <= !bit;  // Update delayed ready signal
        if (start && !en_proceso) begin
            // Initialize division
            en_proceso = 1;
            bit = WIDTH;
            quotient = 0;
            remainder = 0;
            quotient_temp = 0;

            // Sign handling and operand preparation
            dividend_copy = (!sign || !dividend[WIDTH-1]) ? {1'b0, zeros, dividend} : {1'b0, zeros, ~dividend + 1'b1};
            divider_copy  = (!sign || !divider[WIDTH-1])  ? {1'b0, divider, zeros}  : {1'b0, ~divider + 1'b1, zeros};
            negative_output = sign && ((divider[WIDTH-1] && !dividend[WIDTH-1]) || (!divider[WIDTH-1] && dividend[WIDTH-1]));
        end
        else if (bit > 0) begin
            // One iteration of restoring division
            diff = dividend_copy - divider_copy;
            quotient_temp = quotient_temp << 1;
            if (!diff[WIDTH*2-1]) begin
                dividend_copy = diff;
                quotient_temp[0] = 1'b1;
            end
            divider_copy = divider_copy >> 1;
            bit = bit - 1;
            if (bit == 0) en_proceso = 0;
        end
    end

    // Final output assignment after division completes
    always @(posedge ready) begin
        quotient  = (!negative_output) ? quotient_temp : ~quotient_temp + 1'b1;
        remainder = (!negative_output) ? dividend_copy[WIDTH-1:0] : ~dividend_copy[WIDTH-1:0] + 1'b1;
    end
endmodule
