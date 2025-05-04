`timescale 1ns/1ps

module tb_FPMU();
    // Test parameters
    parameter SIGN = 0;          // Test both 0 (unsigned) and 1 (signed)
    parameter WIDTH = 8;
    parameter FP_POSITIONS = 4;
    parameter NUM_TESTS = 20;
    
    // Clock and reset
    logic clk;
    logic rst_n;
    
    // DUT signals
    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [WIDTH-1:0] result;
    
    // Expected results
    logic [WIDTH-1:0] expected_result;
    
    // Instantiate the DUT
    FPMU #(
        .SIGN(SIGN),
        .WIDTH(WIDTH),
        .FP_POSITIONS(FP_POSITIONS)
    ) dut (
        .a(a),
        .b(b),
        .result(result)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        a = 0;
        b = 0;
        rst_n = 0;
        
        // Reset sequence
        #10 rst_n = 1;
        
        // Test cases for both signed and unsigned
        if (SIGN) begin
            $display("Testing SIGNED mode");
            // Test case 1: Positive numbers
            a = 8'b00010000; // 1.0 in Q4.4
            b = 8'b00010100; // 1.25 in Q4.4
            expected_result = 8'b00010100; // 1.25 (1.0 * 1.25 = 1.25)
            #10 check_result("Positive numbers");
            
            // Test case 2: Negative * Positive
            a = 8'b11110000; // -1.0 in Q4.4
            b = 8'b00010100; // 1.25 in Q4.4
            expected_result = 8'b11101100; // -1.25
            #10 check_result("Negative * Positive");
            
            // Test case 3: Negative * Negative
            a = 8'b11110000; // -1.0 in Q4.4
            b = 8'b11101100; // -1.25 in Q4.4
            expected_result = 8'b00010100; // 1.25
            #10 check_result("Negative * Negative");
            
            // Test case 4: Fractional multiplication
            a = 8'b00001000; // 0.5 in Q4.4
            b = 8'b00000100; // 0.25 in Q4.4
            expected_result = 8'b00000010; // 0.125
            #10 check_result("Fractional multiplication");
            
            // Test case 5: Edge case - max positive * max positive
            a = 8'b01111111; // 7.9375 in Q4.4
            b = 8'b01111111; // 7.9375 in Q4.4
            expected_result = 8'b00111111; // 3.9375 (saturated)
            #10 check_result("Max positive * max positive");
            
            // Test case 6: Edge case - max negative * max negative
            a = 8'b10000000; // -8.0 in Q4.4
            b = 8'b10000000; // -8.0 in Q4.4
            expected_result = 8'b01000000; // 4.0 (overflow handled by truncation)
            #10 check_result("Max negative * max negative");
            
        end else begin
            $display("Testing UNSIGNED mode");
            // Test case 1: Basic multiplication
            a = 8'b00010000; // 1.0 in Q4.4
            b = 8'b00010100; // 1.25 in Q4.4
            expected_result = 8'b00010100; // 1.25
            #10 check_result("Basic multiplication");
            
            // Test case 2: Fractional multiplication
            a = 8'b00001000; // 0.5 in Q4.4
            b = 8'b00000100; // 0.25 in Q4.4
            expected_result = 8'b00000010; // 0.125
            #10 check_result("Fractional multiplication");
            
            // Test case 3: Max value multiplication
            a = 8'b11111111; // 15.9375 in Q4.4
            b = 8'b00010000; // 1.0 in Q4.4
            expected_result = 8'b11111111; // 15.9375
            #10 check_result("Max value * 1.0");
            
            // Test case 4: Overflow case
            a = 8'b11111111; // 15.9375 in Q4.4
            b = 8'b00010000; // 1.0 in Q4.4
            expected_result = 8'b11111111; // 15.9375
            #10 check_result("Max value * 1.0");
            
            // Test case 5: Large multiplication
            a = 8'b10100000; // 10.0 in Q4.4
            b = 8'b00110000; // 3.0 in Q4.4
            expected_result = 8'b00011110; // 1.875 (30.0 >> 4 = 1.875 - overflow)
            #10 check_result("Large multiplication");
        end
        
        // Random tests
        $display("Starting random tests...");
        for (int i = 0; i < NUM_TESTS; i++) begin
            a = $random;
            b = $random;
            #10;
            
            // Calculate expected result
            if (SIGN) begin
                automatic logic signed [WIDTH-1:0] sa = a;
                automatic logic signed [WIDTH-1:0] sb = b;
                automatic logic signed [2*WIDTH-1:0] sproduct = sa * sb;
                expected_result = sproduct[WIDTH + FP_POSITIONS - 1:FP_POSITIONS];
            end else begin
                automatic logic [2*WIDTH-1:0] product = a * b;
                expected_result = product[WIDTH + FP_POSITIONS - 1:FP_POSITIONS];
            end
            
            check_result($sformatf("Random test %0d", i));
        end
        
        $display("All tests completed");
        $finish;
    end
    
    // Task to check results
    task check_result(string test_name);
        if (result === expected_result) begin
            $display("[PASS] %s: a=%b (%0f), b=%b (%0f), result=%b (%0f)", 
                     test_name, a, real'(a)/(2**FP_POSITIONS), 
                     b, real'(b)/(2**FP_POSITIONS), 
                     result, real'(result)/(2**FP_POSITIONS));
        end else begin
            $display("[FAIL] %s: a=%b (%0f), b=%b (%0f), got=%b (%0f), expected=%b (%0f)", 
                     test_name, a, real'(a)/(2**FP_POSITIONS), 
                     b, real'(b)/(2**FP_POSITIONS), 
                     result, real'(result)/(2**FP_POSITIONS),
                     expected_result, real'(expected_result)/(2**FP_POSITIONS));
        end
    endtask
    
    // Dump waveforms
    initial begin
        $dumpfile("tb_FPMU.vcd");
        $dumpvars(0, tb_FPMU);
    end
endmodule
