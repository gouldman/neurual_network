module twenty_five_adder_tree_integer#(
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1
)(
    input logic clk,
    input logic rst_n,
    input logic [conv_result_bits-1:0] input_data[24:0],
    output logic [conv_result_bits-1:0] result
);

    // Input array for thirty_two_adder (32 inputs)
    logic [conv_result_bits-1:0] adder_inputs[0:31];

    // Assign the 25 inputs and pad the remaining 7 with zeros
    always_comb begin
        for (int i = 0; i < 25; i++) begin
            adder_inputs[i] = input_data[i];
        end
        for (int i = 25; i < 32; i++) begin
            adder_inputs[i] = '0; // Pad with zeros
        end
    end

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
        .input_data(adder_inputs),
        .result(result)
    );

endmodule

module thirty_two_adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1
)(
    input logic clk,
    input logic rst_n,
    input logic [conv_result_bits-1:0] input_data[0:31], // 32 input data
    output logic [conv_result_bits-1:0] result
);

    // Intermediate results
    logic [conv_result_bits-1:0] sum0, sum1;

    // Instantiate first sixteen_adder: processes input_data[0] to input_data[15]
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
        .input_data('{input_data[0], input_data[1], input_data[2], input_data[3], 
                     input_data[4], input_data[5], input_data[6], input_data[7],
                     input_data[8], input_data[9], input_data[10], input_data[11], 
                     input_data[12], input_data[13], input_data[14], input_data[15]}),
        .result(sum0)
    );

    // Instantiate second sixteen_adder: processes input_data[16] to input_data[31]
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
        .input_data('{input_data[16], input_data[17], input_data[18], input_data[19], 
                     input_data[20], input_data[21], input_data[22], input_data[23],
                     input_data[24], input_data[25], input_data[26], input_data[27], 
                     input_data[28], input_data[29], input_data[30], input_data[31]}),
        .result(sum1)
    );

    // Instantiate adder: adds sum0 and sum1
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
        .input_data('{sum0, sum1}), // sum0 and sum1 as inputs
        .result(result)
    );

endmodule

module sixteen_adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1
)(
    input logic clk,
    input logic rst_n,
    input logic [conv_result_bits-1:0] input_data[0:15], // 16 input data
    output logic [conv_result_bits-1:0] result
);

    // Intermediate results
    logic [conv_result_bits-1:0] sum0, sum1;

    // Instantiate first eight_adder: processes input_data[0] to input_data[7]
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
        .input_data('{input_data[0], input_data[1], input_data[2], input_data[3], 
                     input_data[4], input_data[5], input_data[6], input_data[7]}),
        .result(sum0)
    );

    // Instantiate second eight_adder: processes input_data[8] to input_data[15]
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
        .input_data('{input_data[8], input_data[9], input_data[10], input_data[11], 
                     input_data[12], input_data[13], input_data[14], input_data[15]}),
        .result(sum1)
    );

    // Instantiate four_adder: adds sum0 and sum1
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
        .input_data('{sum0, sum1}), // sum0 and sum1 as inputs, unused inputs set to 0
        .result(result)
    );

endmodule

module eight_adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1
)(
    input logic clk,
    input logic rst_n,
    input logic [conv_result_bits-1:0] input_data[0:7], // 8 输入数据
    output logic [conv_result_bits-1:0] result
);

    // 中间结果
    logic [conv_result_bits-1:0] sum0, sum1;

    // 实例化第一个 four_adder：处理 input_data[0], input_data[1], input_data[2], input_data[3]
    four_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_0 (
        .clk(clk),
        .rst_n(rst_n),
        .input_data('{input_data[0], input_data[1], input_data[2], input_data[3]}),
        .result(sum0)
    );

    // 实例化第二个 four_adder：处理 input_data[4], input_data[5], input_data[6], input_data[7]
    four_adder #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) adder_1 (
        .clk(clk),
        .rst_n(rst_n),
        .input_data('{input_data[4], input_data[5], input_data[6], input_data[7]}),
        .result(sum1)
    );

    // 实例化第三个 four_adder：将 sum0 和 sum1 相加
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
        .input_data('{sum0, sum1}), // sum0 和 sum1 作为输入
        .result(result)
    );

endmodule


module four_adder#(
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size = 5,
    parameter kernel_number = 1,
    parameter channel = 1,
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1
)(
    input logic clk,
    input logic rst_n,
    input logic [conv_result_bits-1:0] input_data[0:3],
    output logic [conv_result_bits-1:0] result
);

    // 中间结果
    logic [conv_result_bits-1:0] sum0, sum1;

    // 实例化第一个 adder：input_data[0] + input_data[1]
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
        .input_data('{input_data[0], input_data[1]}),
        .result(sum0)
    );

    // 实例化第二个 adder：input_data[2] + input_data[3]
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
        .input_data('{input_data[2], input_data[3]}),
        .result(sum1)
    );

    // 实例化第三个 adder：sum0 + sum1
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
        .input_data('{sum0, sum1}),
        .result(result)
    );

endmodule


module adder#(    
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size =5,
    parameter kernel_number = 1,
    parameter channel = 1, // Number of channels
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1)
(
    input logic clk,
    input logic rst_n, // Active low reset
    input logic [conv_result_bits-1:0] input_data [1:0], // First input signal
    output logic [conv_result_bits-1:0] result // Result of the addition, registered output
);

logic [conv_result_bits-1:0] result_n; // Intermediate sum
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= '0;
        end else begin
            result <=result_n; // Perform addition
        end
    end

always_comb begin
        result_n = input_data[0] + input_data[1]; // Perform addition
    end
endmodule

