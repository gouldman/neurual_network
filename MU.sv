module MU#(
    parameter WIDTH = 8,
    parameter kernel_size = 5,
    parameter SIGN = 1, // 1 for signed, 0 for unsigned
    parameter FP_POSITIONS = 4 
)(
    input logic clk,
    input logic rst_n, // Active low reset
    input logic weight_valid,
    input logic data_valid,
    input logic [WIDTH - 1:0] weight,
    input logic [WIDTH - 1:0] data, // Input data
    input logic [WIDTH - 1:0] bias, // Bias for the multiplication
    output logic [WIDTH - 1:0] conv_result, // Result of the multiplication
    output logic conv_result_valid // Output valid signal
);

    logic [$clog2(kernel_size*kernel_size)-1:0] counter, counter_next; // Counter for kernel size
    logic [WIDTH - 1:0] A,B,A_mult_B;
    logic [WIDTH - 1:0] conv_result_next;
    logic conv_result_valid_next;

    FPMU #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) fpmu (
        .a(A),
        .b(B),
        .result(A_mult_B)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0; // Reset the counter to zero
            conv_result <= 0; // Reset the result to zero
            conv_result_valid <= 0; // Reset the valid signal
        end else begin
            // conv_result <= (counter == 0) ? A_mult_B + bias: A_mult_B + conv_result; // Add bias to the result
            // conv_result_valid <= (&counter); // Set the valid signal high
            // counter <= counter + 1; // Increment the counter
            conv_result <= conv_result_next; // Add bias to the result
            conv_result_valid <= conv_result_valid_next; // Set the valid signal high
            counter <= counter_next; // Increment the counter
        end
    end

    always_comb begin : comb_logic
        counter_next = counter; // Default to current counter value
        conv_result_next = conv_result; // Default to current result
        conv_result_valid_next = 0; // Default to current valid signal
        A = 0; // Reset A to zero
        B = 0; // Reset B to zero
        if (weight_valid && data_valid) begin
            A = weight; // Assign weight to A
            B = data; // Assign data to B
            conv_result_next = (counter == 0) ? A_mult_B + bias: A_mult_B + conv_result; // Add bias to the result
            conv_result_valid_next = (counter == kernel_size * kernel_size - 1); // Set the valid signal high
            counter_next = (counter ==kernel_size* kernel_size - 1) ? 0 : counter + 1; // Increment the counter
        end 
    end
endmodule
