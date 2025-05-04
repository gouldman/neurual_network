module five_adder_tree#(
    parameter SIGN = 1,
    parameter WIDTH = 8, // Width of the input data
    parameter FP_POSITIONS = 4 // Number of positions for the fixed point representation
)(
    input logic clk,
    input logic rst_n, // Active low reset
    input logic [WIDTH-1:0] a, // Input A
    input logic [WIDTH-1:0] b, // Input B
    input logic [WIDTH-1:0] c, // Input C
    input logic [WIDTH-1:0] d, // Input D
    input logic [WIDTH-1:0] e, // Input E
    output logic [WIDTH-1:0] result // Result of the addition, now a registered output
);
    logic [WIDTH - 1:0] sum_ab, sum_cd, final_sum_temp;
    logic [WIDTH - 1:0] result_unregistered; // Intermediate unregistered result

    FPAU #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_ab (
        .a(a),
        .b(b),
        .result(sum_ab)
    );

    FPAU #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_cd (
        .a(c),
        .b(d),
        .result(sum_cd)
    );

    FPAU #(
        .SIGN(SIGN),
        .WIDTH(WIDTH), // Increase width to avoid intermediate overflow
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_abc (
        .a(sum_ab),
        .b(e), // Align width by adding a leading zero
        .result(final_sum_temp)
    );

    FPAU #(
        .SIGN(SIGN),
        .WIDTH(WIDTH), // Maintain increased width
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_abcd (
        .a(final_sum_temp),
        .b(sum_cd), // Align width by adding a leading zero
        .result(result_unregistered)
    );

    // Register the final result
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= '0;
        end else begin
            result <= result_unregistered[WIDTH-1:0]; // Take lower WIDTH bits
        end
    end

endmodule
