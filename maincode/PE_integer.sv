module PE_integer#(
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size =5,
    parameter kernel_number = 1,
    parameter channel = 3, // Number of channels
    parameter conv_result_bits = 16
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
    // Connect each element of fm_results to the corresponding individual input port
    .input_data_0(fm_results[0]),
    .input_data_1(fm_results[1]),
    .input_data_2(fm_results[2]),
    .input_data_3(fm_results[3]),
    .input_data_4(fm_results[4]),
    .input_data_5(fm_results[5]),
    .input_data_6(fm_results[6]),
    .input_data_7(fm_results[7]),
    .input_data_8(fm_results[8]),
    .input_data_9(fm_results[9]),
    .input_data_10(fm_results[10]),
    .input_data_11(fm_results[11]),
    .input_data_12(fm_results[12]),
    .input_data_13(fm_results[13]),
    .input_data_14(fm_results[14]),
    .input_data_15(fm_results[15]),
    .input_data_16(fm_results[16]),
    .input_data_17(fm_results[17]),
    .input_data_18(fm_results[18]),
    .input_data_19(fm_results[19]),
    .input_data_20(fm_results[20]),
    .input_data_21(fm_results[21]),
    .input_data_22(fm_results[22]),
    .input_data_23(fm_results[23]),
    .input_data_24(fm_results[24]),
    .result(result)
);
    delay_module #(.DELAY_TIME(4)) delay_4 (
        .clk(clk),
        .rst_n(rst_n),
        .in_signal(in_valid),
        .out_signal(result_valid)
    );
endmodule