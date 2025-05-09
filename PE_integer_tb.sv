`timescale 1ns / 1ps

module PE_integer_tb;

    // Parameters
    parameter pic_bits = 2;
    parameter weight_bits = 3;
    parameter kernel_size = 5;
    parameter kernel_number = 1;
    parameter channel = 1;
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1;
    parameter CLK_PERIOD = 10; // Clock period in ns (100 MHz)

    // Signals
    logic clk;
    logic rst_n;
    logic in_valid;
    logic [pic_bits-1:0] pic [kernel_size*kernel_size-1:0];
    logic [weight_bits-1:0] weight [kernel_size*kernel_size-1:0];
    logic [conv_result_bits-1:0] result;
    logic result_valid;

    // Instantiate the DUT (Device Under Test)
    PE_integer #(
        .pic_bits(pic_bits),
        .weight_bits(weight_bits),
        .kernel_size(kernel_size),
        .kernel_number(kernel_number),
        .channel(channel),
        .conv_result_bits(conv_result_bits)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .pic(pic),
        .weight(weight),
        .result(result),
        .result_valid(result_valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        in_valid = 0;
        for (int i = 0; i < kernel_size*kernel_size; i++) begin
            pic[i] = 0;
            weight[i] = 0;
        end

        // Apply reset
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD);

        // Test Case 1: Simple multiplication and addition
        // pic = {1, 1, ..., 1} (25 ones), weight = {1, 1, ..., 1} (25 ones)
        // Expected result: 1*1 + 1*1 + ... (25 times) = 25
        $display("Test Case 1: All inputs and weights = 1");
        for (int i = 0; i < kernel_size*kernel_size; i++) begin
            pic[i] = 2'd1;
            weight[i] = 3'd1;
        end
        in_valid = 1;
        #(CLK_PERIOD);
        in_valid = 0;
        for (int i = 0; i < kernel_size*kernel_size; i++) begin
            pic[i] = 2'd2;
            weight[i] = 3'd2;
        end
        // Wait for result_valid and check result
        wait(result_valid);
        #(CLK_PERIOD/2); // Small delay to ensure stable output
        if (result == 25) begin
            $display("Test Case 1 PASSED: result = %d (expected 25)", result);
        end else begin
            $display("Test Case 1 FAILED: result = %d (expected 25)", result);
        end

        // Wait a few cycles before next test
        #(CLK_PERIOD*5);

        // Test Case 2: Different values
        // pic = {1, 2, 1, 2, ..., 1} (alternating 1, 2), weight = {2, 2, ..., 2} (all 2s)
        // Expected result: (1*2 + 2*2 + 1*2 + 2*2 + ... for 25 elements)
        // = 13*2 + 12*4 = 26 + 48 = 74
        $display("Test Case 2: Alternating pic values, weights = 2");
        for (int i = 0; i < kernel_size*kernel_size; i++) begin
            pic[i] = (i % 2 == 0) ? 2'd1 : 2'd2;
            weight[i] = 3'd2;
        end
        in_valid = 1;
        #(CLK_PERIOD);
        in_valid = 0;

        // Wait for result_valid and check result
        wait(result_valid);
        #(CLK_PERIOD/2);
        if (result == 74) begin
            $display("Test Case 2 PASSED: result = %d (expected 74)", result);
        end else begin
            $display("Test Case 2 FAILED: result = %d (expected 74)", result);
        end

        // Test Case 3: Reset during operation
        $display("Test Case 3: Reset during operation");
        for (int i = 0; i < kernel_size*kernel_size; i++) begin
            pic[i] = 2'd1;
            weight[i] = 3'd1;
        end
        in_valid = 1;
        #(CLK_PERIOD*2);
        rst_n = 0; // Apply reset
        #(CLK_PERIOD);
        rst_n = 1; // Release reset
        in_valid = 0;
        #(CLK_PERIOD*5);

        // Apply same inputs again
        in_valid = 1;
        #(CLK_PERIOD);
        in_valid = 0;

        // Wait for result_valid and check result
        wait(result_valid);
        #(CLK_PERIOD/2);
        if (result == 25) begin
            $display("Test Case 3 PASSED: result = %d (expected 25)", result);
        end else begin
            $display("Test Case 3 FAILED: result = %d (expected 25)", result);
        end

        // End simulation
        #(CLK_PERIOD*5);
        $display("Simulation completed");
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t rst_n=%b in_valid=%b result_valid=%b result=%d",
                 $time, rst_n, in_valid, result_valid, result);
    end

endmodule