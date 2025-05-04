`timescale 1ns/1ps

module MU_tb;
    // Parameters
    localparam WIDTH = 8;
    localparam kernel_size = 3;
    localparam SIGN = 1;
    localparam FP_POSITIONS = 4;
    localparam CLK_PERIOD = 10; // Clock period in ns

    // Testbench signals
    logic clk;
    logic rst_n;
    logic weight_valid;
    logic data_valid;
    logic [WIDTH-1:0] weight;
    logic [WIDTH-1:0] data;
    logic [WIDTH-1:0] bias;
    logic [WIDTH-1:0] conv_result;
    logic conv_result_valid;

    // Instantiate the DUT (Device Under Test)
    MU #(
        .WIDTH(WIDTH),
        .kernel_size(kernel_size),
        .SIGN(SIGN),
        .FP_POSITIONS(FP_POSITIONS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .weight_valid(weight_valid),
        .data_valid(data_valid),
        .weight(weight),
        .data(data),
        .bias(bias),
        .conv_result(conv_result),
        .conv_result_valid(conv_result_valid)
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
        weight_valid = 0;
        data_valid = 0;
        weight = 0;
        data = 0;
        bias = 8'h10; // Example bias value (16 in decimal)

        // Reset sequence
        #20;
        rst_n = 1;
        #20;

        // Test case 1: Simple convolution
        // Send kernel_size*kernel_size (9) pairs of weights and data
        for (int i = 0; i < kernel_size*kernel_size; i++) begin
            weight_valid = 1;
            data_valid = 1;
            weight = 8'h02; // Weight = 2
            data = 8'h03;   // Data = 3
            #10;
        end

        // Wait for result
        weight_valid = 0;
        data_valid = 0;

        // Wait for computation to complete
        #50;

        // Test case 2: Reset during operation
        weight_valid = 1;
        data_valid = 1;
        weight = 8'h04; // Weight = 4
        data = 8'h05;   // Data = 5
        
        #20;
        rst_n = 0; // Assert reset
        #20;
        rst_n = 1; // Release reset

        // Test case 3: Different values
        for (int i = 0; i < kernel_size*kernel_size; i++) begin

            weight_valid = 1;
            data_valid = 1;
            weight = i + 1; // Incremental weights
            data = i + 2;   // Incremental data
            #10;
        end

        // Finish simulation
        #100;
        $display("Simulation completed");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t rst_n=%b weight_valid=%b data_valid=%b weight=%h data=%h bias=%h conv_result=%h conv_result_valid=%b",
                 $time, rst_n, weight_valid, data_valid, weight, data, bias, conv_result, conv_result_valid);
    end

    // Dump variables for waveform viewing
    initial begin
        $dumpfile("MU_tb.vcd");
        $dumpvars(0, MU_tb);
    end
endmodule