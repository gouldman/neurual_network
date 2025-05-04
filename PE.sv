module PE#(
    parameter SIGN = 1,
    parameter WIDTH = 8,
    parameter FP_POSITIONS = 4, 
    parameter kernel_size = 5 // Kernel size
)(
    input logic clk,
    input logic rst_n,
    input logic in_valid,
    input logic [WIDTH - 1:0] pic [kernel_size * kernel_size - 1:0], // Input picture
    input logic [WIDTH - 1:0] weight [kernel_size * kernel_size - 1:0], // Input kernel
    output logic [WIDTH - 1:0] result, // Output result
    output logic result_valid // Output valid signal
);
    logic [WIDTH - 1:0] fm_results [kernel_size * kernel_size - 1:0];
    generate
        for (genvar i = 0; i < kernel_size * kernel_size; i = i + 1) begin : fm_unit
            FPMU #(
                .SIGN(SIGN),
                .WIDTH(WIDTH),
                .FP_POSITIONS(FP_POSITIONS)
            ) fpmult (
                .a(pic[i]),
                .b(weight[i]),
                .result(fm_results[i])
            );
        end
    endgenerate
    twenty_five_adder_tree #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) adder_tree (
        .clk(clk),
        .rst_n(rst_n),
        .in(fm_results),
        .result(result)
    );
    delay_module #(.DELAY_TIME(3)) delay_3 (
        .clk(clk),
        .rst_n(rst_n),
        .in_signal(in_valid),
        .out_signal(result_valid)
    );
endmodule
