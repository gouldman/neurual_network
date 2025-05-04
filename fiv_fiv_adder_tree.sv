module twenty_five_adder_tree#(
    parameter SIGN = 1,
    parameter WIDTH = 8, // Width of the input data
    parameter FP_POSITIONS = 4 // Number of positions for the fixed point representation
)(
    input logic clk,
    input logic rst_n, // Active low reset
    input logic [WIDTH-1:0] in[24:0], // 25 input signals
    output logic [WIDTH-1:0] result // Result of the addition, registered output
);

    logic [WIDTH-1:0] sum_group0;
    logic [WIDTH-1:0] sum_group1;
    logic [WIDTH-1:0] sum_group2;
    logic [WIDTH-1:0] sum_group3;
    logic [WIDTH-1:0] sum_group4;
    logic [WIDTH-1:0] final_sum_unregistered;

    // First level: Five 5-input adder trees
    five_adder_tree #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_group0 (
        .clk(clk),
        .rst_n(rst_n),
        .a(in[0]),
        .b(in[1]),
        .c(in[2]),
        .d(in[3]),
        .e(in[4]),
        .result(sum_group0)
    );

    five_adder_tree #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_group1 (
        .clk(clk),
        .rst_n(rst_n),
        .a(in[5]),
        .b(in[6]),
        .c(in[7]),
        .d(in[8]),
        .e(in[9]),
        .result(sum_group1)
    );

    five_adder_tree #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_group2 (
        .clk(clk),
        .rst_n(rst_n),
        .a(in[10]),
        .b(in[11]),
        .c(in[12]),
        .d(in[13]),
        .e(in[14]),
        .result(sum_group2)
    );

    five_adder_tree #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_group3 (
        .clk(clk),
        .rst_n(rst_n),
        .a(in[15]),
        .b(in[16]),
        .c(in[17]),
        .d(in[18]),
        .e(in[19]),
        .result(sum_group3)
    );

    five_adder_tree #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_group4 (
        .clk(clk),
        .rst_n(rst_n),
        .a(in[20]),
        .b(in[21]),
        .c(in[22]),
        .d(in[23]),
        .e(in[24]),
        .result(sum_group4)
    );

    // Second level: One 5-input adder tree to sum the results of the first level
    five_adder_tree #(
        .SIGN(SIGN),
        .WIDTH(WIDTH), // The intermediate sums have the same width
        .FP_POSITIONS(FP_POSITIONS)
    ) final_adder (
        .clk(clk),
        .rst_n(rst_n),
        .a(sum_group0),
        .b(sum_group1),
        .c(sum_group2),
        .d(sum_group3),
        .e(sum_group4),
        .result(final_sum_unregistered)
    );

    // Register the final result
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= '0;
        end else begin
            result <= final_sum_unregistered;
        end
    end

endmodule
