`timescale 1ns/1ps

module serial_conv_control_integer_tb;
    parameter pic_bits = 8;
    parameter pic_size = 28;
    parameter kernel_size = 5;
    parameter channel_size = 3;
    parameter input_data_bits = 32;
    parameter serial_to_parallel_coe = input_data_bits / pic_bits;
    parameter conv_result_bits = 5 + 1 + pic_bits * 2;
    parameter padding = 4;
  // ----------------------------
  // Parameters
  // ----------------------------
  // ----------------------------
  // Interface signals
  // ----------------------------
logic clk;                                    // Clock signal
logic rst_n;                                  // Active-low reset signal
logic conv_start;                             // Convolution start signal
logic [input_data_bits-1:0] parallel_pic;      // Input picture data
logic parallel_pic_valid;                      // Valid signal for picture data
logic [pic_bits-1:0] previous_result; // Previous convolution result
logic previous_result_valid;          // Valid signal for previous result
logic [input_data_bits-1:0] parallel_weight_data; // Weight data for convolution
logic parallel_weight_data_valid;              // Valid signal for weight data
logic need_pic;                               // Output signal indicating need for picture data
logic conv_finish;                            // Output signal indicating convolution completion
logic [pic_bits - 1:0] conv_result; // Convolution result
logic [$clog2(pic_size*pic_size)-1:0] conv_result_addr; // Address for convolution result
logic conv_result_valid;              // Valid signal for convolution result
logic read_previous_result_enable;

  // ----------------------------
  // Clock Generation
  // ----------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  // ----------------------------
  // DUT instantiation
  // ----------------------------
serial_conv_control_integer dut (
    .clk(clk),
    .rst_n(rst_n),
    .conv_start(conv_start),
    .parallel_pic(parallel_pic),
    .parallel_pic_valid(parallel_pic_valid),
    .previous_result(previous_result),
    .previous_result_valid(previous_result_valid),
    .parallel_weight_data(parallel_weight_data),
    .parallel_weight_data_valid(parallel_weight_data_valid),
    .need_pic(need_pic),
    .conv_finish(conv_finish),
    .conv_result(conv_result),
    .conv_result_addr(conv_result_addr),
    .conv_result_valid(conv_result_valid),
    .read_previous_result_enable(read_previous_result_enable)
);

fake_sram fake_sram_inst(
  .clk(clk),
  .rst_n(rst_n),
  .ce(read_previous_result_enable || conv_result_valid),
  .we(conv_result_valid),
  .addr(conv_result_addr),
  .wdata(conv_result),
  .rdata(previous_result),
  .previous_result_valid(previous_result_valid),
  .read_previous_result_enable(read_previous_result_enable)
);
  // ----------------------------
  // Reset Task
  // ----------------------------
  task automatic reset_dut();
    begin
      rst_n = 0;
      parallel_pic = '0;
      parallel_pic_valid = 0;
      conv_start = 0;
      parallel_weight_data_valid = '0;
      parallel_weight_data = '0;
      @(posedge clk);
      @(posedge clk);
      rst_n = 1;
      @(posedge clk);
    end
  endtask

  // ----------------------------
  // Test Sequence
  // ----------------------------
  initial begin
    reset_dut(); 
    conv_start = 1;
    #100;
    parallel_pic_valid = 1;
    parallel_pic =  32'h01010101;
    parallel_weight_data_valid = 1;
    parallel_weight_data = 32'h01010101;
    #100000;

    $finish;
  end

endmodule