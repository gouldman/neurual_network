module twenty_five_adder_tree_integer#(
    parameter pic_bits = 2,
    parameter weight_bits = 8,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = 16
)(
    input logic clk,
    input logic rst_n,
    input logic [conv_result_bits-1:0] input_data_0,
    input logic [conv_result_bits-1:0] input_data_1,
    input logic [conv_result_bits-1:0] input_data_2,
    input logic [conv_result_bits-1:0] input_data_3,
    input logic [conv_result_bits-1:0] input_data_4,
    input logic [conv_result_bits-1:0] input_data_5,
    input logic [conv_result_bits-1:0] input_data_6,
    input logic [conv_result_bits-1:0] input_data_7,
    input logic [conv_result_bits-1:0] input_data_8,
    input logic [conv_result_bits-1:0] input_data_9,
    input logic [conv_result_bits-1:0] input_data_10,
    input logic [conv_result_bits-1:0] input_data_11,
    input logic [conv_result_bits-1:0] input_data_12,
    input logic [conv_result_bits-1:0] input_data_13,
    input logic [conv_result_bits-1:0] input_data_14,
    input logic [conv_result_bits-1:0] input_data_15,
    input logic [conv_result_bits-1:0] input_data_16,
    input logic [conv_result_bits-1:0] input_data_17,
    input logic [conv_result_bits-1:0] input_data_18,
    input logic [conv_result_bits-1:0] input_data_19,
    input logic [conv_result_bits-1:0] input_data_20,
    input logic [conv_result_bits-1:0] input_data_21,
    input logic [conv_result_bits-1:0] input_data_22,
    input logic [conv_result_bits-1:0] input_data_23,
    input logic [conv_result_bits-1:0] input_data_24,
    output logic [conv_result_bits-1:0] result
);

    // Instantiate thirty_two_adder
    thirty_two_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_inst (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(input_data_0),
        .input_data_1(input_data_1),
        .input_data_2(input_data_2),
        .input_data_3(input_data_3),
        .input_data_4(input_data_4),
        .input_data_5(input_data_5),
        .input_data_6(input_data_6),
        .input_data_7(input_data_7),
        .input_data_8(input_data_8),
        .input_data_9(input_data_9),
        .input_data_10(input_data_10),
        .input_data_11(input_data_11),
        .input_data_12(input_data_12),
        .input_data_13(input_data_13),
        .input_data_14(input_data_14),
        .input_data_15(input_data_15),
        .input_data_16(input_data_16),
        .input_data_17(input_data_17),
        .input_data_18(input_data_18),
        .input_data_19(input_data_19),
        .input_data_20(input_data_20),
        .input_data_21(input_data_21),
        .input_data_22(input_data_22),
        .input_data_23(input_data_23),
        .input_data_24(input_data_24),
        .input_data_25('0),
        .input_data_26('0),
        .input_data_27('0),
        .input_data_28('0),
        .input_data_29('0),
        .input_data_30('0),
        .input_data_31('0),
        .result(result)
    );

endmodule

module thirty_two_adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 8,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = 16
)(
    input logic clk,
    input logic rst_n,
    // 32 individual input data signals
    input logic [conv_result_bits-1:0] input_data_0,
    input logic [conv_result_bits-1:0] input_data_1,
    input logic [conv_result_bits-1:0] input_data_2,
    input logic [conv_result_bits-1:0] input_data_3,
    input logic [conv_result_bits-1:0] input_data_4,
    input logic [conv_result_bits-1:0] input_data_5,
    input logic [conv_result_bits-1:0] input_data_6,
    input logic [conv_result_bits-1:0] input_data_7,
    input logic [conv_result_bits-1:0] input_data_8,
    input logic [conv_result_bits-1:0] input_data_9,
    input logic [conv_result_bits-1:0] input_data_10,
    input logic [conv_result_bits-1:0] input_data_11,
    input logic [conv_result_bits-1:0] input_data_12,
    input logic [conv_result_bits-1:0] input_data_13,
    input logic [conv_result_bits-1:0] input_data_14,
    input logic [conv_result_bits-1:0] input_data_15,
    input logic [conv_result_bits-1:0] input_data_16,
    input logic [conv_result_bits-1:0] input_data_17,
    input logic [conv_result_bits-1:0] input_data_18,
    input logic [conv_result_bits-1:0] input_data_19,
    input logic [conv_result_bits-1:0] input_data_20,
    input logic [conv_result_bits-1:0] input_data_21,
    input logic [conv_result_bits-1:0] input_data_22,
    input logic [conv_result_bits-1:0] input_data_23,
    input logic [conv_result_bits-1:0] input_data_24,
    input logic [conv_result_bits-1:0] input_data_25,
    input logic [conv_result_bits-1:0] input_data_26,
    input logic [conv_result_bits-1:0] input_data_27,
    input logic [conv_result_bits-1:0] input_data_28,
    input logic [conv_result_bits-1:0] input_data_29,
    input logic [conv_result_bits-1:0] input_data_30,
    input logic [conv_result_bits-1:0] input_data_31,
    output logic [conv_result_bits-1:0] result
);

    // Intermediate results
    logic [conv_result_bits-1:0] sum0, sum1;

    // Instantiate first sixteen_adder: processes input_data_0 to input_data_15
    sixteen_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_0 (
        .clk(clk),
        .rst_n(rst_n),
        // Pass individual inputs to sixteen_adder's individual input ports
        .input_data_0(input_data_0),
        .input_data_1(input_data_1),
        .input_data_2(input_data_2),
        .input_data_3(input_data_3),
        .input_data_4(input_data_4),
        .input_data_5(input_data_5),
        .input_data_6(input_data_6),
        .input_data_7(input_data_7),
        .input_data_8(input_data_8),
        .input_data_9(input_data_9),
        .input_data_10(input_data_10),
        .input_data_11(input_data_11),
        .input_data_12(input_data_12),
        .input_data_13(input_data_13),
        .input_data_14(input_data_14),
        .input_data_15(input_data_15),
        .result(sum0)
    );

    // Instantiate second sixteen_adder: processes input_data_16 to input_data_31
    sixteen_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_1 (
        .clk(clk),
        .rst_n(rst_n),
        // Pass individual inputs to sixteen_adder's individual input ports
        .input_data_0(input_data_16),
        .input_data_1(input_data_17),
        .input_data_2(input_data_18),
        .input_data_3(input_data_19),
        .input_data_4(input_data_20),
        .input_data_5(input_data_21),
        .input_data_6(input_data_22),
        .input_data_7(input_data_23),
        .input_data_8(input_data_24),
        .input_data_9(input_data_25),
        .input_data_10(input_data_26),
        .input_data_11(input_data_27),
        .input_data_12(input_data_28),
        .input_data_13(input_data_29),
        .input_data_14(input_data_30),
        .input_data_15(input_data_31),
        .result(sum1)
    );

    // Instantiate adder: adds sum0 and sum1 (assuming 'adder' module sums two inputs)
    // The 'adder' module needs to be defined to take two individual inputs.
    adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_2 (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(sum0), // Assuming input_data_0 for the first input
        .input_data_1(sum1), // Assuming input_data_1 for the second input
        .result(result)
    );
endmodule
module sixteen_adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 8,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = 16
)(
    input logic clk,
    input logic rst_n,
    // 16 individual input data signals
    input logic [conv_result_bits-1:0] input_data_0,
    input logic [conv_result_bits-1:0] input_data_1,
    input logic [conv_result_bits-1:0] input_data_2,
    input logic [conv_result_bits-1:0] input_data_3,
    input logic [conv_result_bits-1:0] input_data_4,
    input logic [conv_result_bits-1:0] input_data_5,
    input logic [conv_result_bits-1:0] input_data_6,
    input logic [conv_result_bits-1:0] input_data_7,
    input logic [conv_result_bits-1:0] input_data_8,
    input logic [conv_result_bits-1:0] input_data_9,
    input logic [conv_result_bits-1:0] input_data_10,
    input logic [conv_result_bits-1:0] input_data_11,
    input logic [conv_result_bits-1:0] input_data_12,
    input logic [conv_result_bits-1:0] input_data_13,
    input logic [conv_result_bits-1:0] input_data_14,
    input logic [conv_result_bits-1:0] input_data_15,
    output logic [conv_result_bits-1:0] result
);

    // Intermediate results
    logic [conv_result_bits-1:0] sum0, sum1;

    // Instantiate first eight_adder: processes input_data_0 to input_data_7
    eight_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_0 (
        .clk(clk),
        .rst_n(rst_n),
        // Pass individual inputs to eight_adder's individual input ports
        .input_data_0(input_data_0),
        .input_data_1(input_data_1),
        .input_data_2(input_data_2),
        .input_data_3(input_data_3),
        .input_data_4(input_data_4),
        .input_data_5(input_data_5),
        .input_data_6(input_data_6),
        .input_data_7(input_data_7),
        .result(sum0)
    );

    // Instantiate second eight_adder: processes input_data_8 to input_data_15
    eight_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_1 (
        .clk(clk),
        .rst_n(rst_n),
        // Pass individual inputs to eight_adder's individual input ports
        .input_data_0(input_data_8),
        .input_data_1(input_data_9),
        .input_data_2(input_data_10),
        .input_data_3(input_data_11),
        .input_data_4(input_data_12),
        .input_data_5(input_data_13),
        .input_data_6(input_data_14),
        .input_data_7(input_data_15),
        .result(sum1)
    );

    // Instantiate an 'adder' module to sum sum0 and sum1
    // (This assumes the 'adder' module takes two individual inputs, as defined previously)
    adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) final_adder_inst (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(sum0),
        .input_data_1(sum1),
        .result(result)
    );

endmodule

// eight_adder.sv
module eight_adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 8,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = 16
)(
    input logic clk,
    input logic rst_n,
    // 8 individual input data signals
    input logic [conv_result_bits-1:0] input_data_0,
    input logic [conv_result_bits-1:0] input_data_1,
    input logic [conv_result_bits-1:0] input_data_2,
    input logic [conv_result_bits-1:0] input_data_3,
    input logic [conv_result_bits-1:0] input_data_4,
    input logic [conv_result_bits-1:0] input_data_5,
    input logic [conv_result_bits-1:0] input_data_6,
    input logic [conv_result_bits-1:0] input_data_7,
    output logic [conv_result_bits-1:0] result
);

    // Intermediate results
    logic [conv_result_bits-1:0] sum_quad0, sum_quad1;

    // Instantiate first four_adder: processes input_data_0 to input_data_3
    four_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) four_adder_0 (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(input_data_0),
        .input_data_1(input_data_1),
        .input_data_2(input_data_2),
        .input_data_3(input_data_3),
        .result(sum_quad0)
    );

    // Instantiate second four_adder: processes input_data_4 to input_data_7
    four_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) four_adder_1 (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(input_data_4),
        .input_data_1(input_data_5),
        .input_data_2(input_data_6),
        .input_data_3(input_data_7),
        .result(sum_quad1)
    );

    // Instantiate an 'adder' module to sum sum_quad0 and sum_quad1
    adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) final_adder_inst (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(sum_quad0),
        .input_data_1(sum_quad1),
        .result(result)
    );

endmodule

module four_adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 8,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits =16
)(
    input logic clk,
    input logic rst_n,
    // Four individual input data signals
    input logic [conv_result_bits-1:0] input_data_0,
    input logic [conv_result_bits-1:0] input_data_1,
    input logic [conv_result_bits-1:0] input_data_2,
    input logic [conv_result_bits-1:0] input_data_3,
    output logic [conv_result_bits-1:0] result
);

    // Intermediate results
    logic [conv_result_bits-1:0] sum0, sum1;

    // Instantiate first adder: sums input_data_0 and input_data_1
    adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_0 (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(input_data_0), // Direct connection
        .input_data_1(input_data_1), // Direct connection
        .result(sum0)
    );

    // Instantiate second adder: sums input_data_2 and input_data_3
    adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_1 (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(input_data_2), // Direct connection
        .input_data_1(input_data_3), // Direct connection
        .result(sum1)
    );

    // Instantiate third adder: sums sum0 and sum1
    adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_2 (
        .clk(clk),
        .rst_n(rst_n),
        .input_data_0(sum0), // Direct connection
        .input_data_1(sum1), // Direct connection
        .result(result)
    );

endmodule

module adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 8,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1, // Number of channels
    parameter conv_result_bits = 16
)(
    input logic clk,
    input logic rst_n, // Active low reset
    input logic [conv_result_bits-1:0] input_data_0, // First input signal
    input logic [conv_result_bits-1:0] input_data_1, // Second input signal
    output logic [conv_result_bits-1:0] result // Result of the addition, registered output
);

    logic [conv_result_bits-1:0] result_n; // Intermediate combinatorial sum

    // Combinatorial logic for the addition
    always_comb begin
        result_n = input_data_0 + input_data_1; // Perform addition of two distinct inputs
    end

    // Sequential logic for registering the output
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= '0; // Reset output
        end else begin
            result <= result_n; // Register the sum
        end
    end

endmodule

