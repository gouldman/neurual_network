module PE_integer#(
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size =5,
    parameter kernel_number = 1,
    parameter channel = 1, // Number of channels
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1
    // parameter SIGN = 1, // 1 for signed, 0 for unsigned
    // parameter FP_POSITIONS = 4, // Number of bits for the fractional part
)(
    input logic clk,
    input logic rst_n,
    input logic in_valid,
    input logic [pic_bits - 1:0] pic [kernel_size * kernel_size - 1:0], // Input picture
    input logic [weight_bits - 1:0] weight [kernel_size * kernel_size - 1:0], // Input kernel
    output logic [conv_result_bits - 1:0] result, // Output result
    output logic result_valid // Output valid signal
);
    logic [conv_result_bits - 1:0] fm_results [kernel_size * kernel_size - 1:0];
        for (genvar i = 0; i < kernel_size * kernel_size; i = i + 1) begin : fm_unit
            // FPMU #(
            //     .SIGN(SIGN),
            //     .WIDTH(WIDTH),
            //     .FP_POSITIONS(FP_POSITIONS)
            // ) fpmult (
            //     .a(pic[i]),
            //     .b(weight[i]),
            //     .result(fm_results[i])
            // );
            assign fm_results[i] = pic[i] * weight[i];
        end
    // twenty_five_adder_tree #(
    //     .SIGN(SIGN),
    //     .WIDTH(WIDTH),
    //     .FP_POSITIONS(FP_POSITIONS)
    // ) adder_tree (
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .in(fm_results),
    //     .result(result)
    // );
    twenty_five_adder_tree_integer #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_tree (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(fm_results),
        .result(result)
    );
    delay_module #(.DELAY_TIME(4)) delay_4 (
        .clk(clk),
        .rst_n(rst_n),
        .in_signal(in_valid),
        .out_signal(result_valid)
    );
endmodule