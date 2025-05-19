`timescale 1ns/1ps

module conv_control_integer_tb;

  // ----------------------------
  // Parameters
  // ----------------------------
  parameter pic_bits = 2;
  parameter weight_bits = 3;
  parameter kernel_size = 5;
  parameter pic_size = 28;
  parameter kernel_number = 1;
  parameter channel = 3;
  parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1;

  // ----------------------------
  // Interface signals
  // ----------------------------
  logic clk;
  logic rst_n;
  logic [pic_bits-1:0] pic;
  logic pic_valid;
  logic conv_start;
  logic need_pic;
  logic conv_finish;
  logic conv_result_valid;
  logic [conv_result_bits-1:0] conv_result;
  logic [$clog2(pic_size*pic_size)-1:0] conv_result_addr;
  logic read_sram_enable;
  logic [pic_bits - 1:0] sram_data_valid;
  logic [pic_bits - 1:0] sram_data;
  logic weight_data_valid;
  logic [weight_bits - 1:0] weight_data;

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
  conv_control_integer #(
    .pic_bits(pic_bits),
    .weight_bits(weight_bits),
    .kernel_size(kernel_size),
    .pic_size(pic_size),
    .kernel_number(kernel_number),
    .channel(channel),
    .conv_result_bits(conv_result_bits)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .pic(pic),
    .pic_valid(pic_valid),
    .conv_start(conv_start),
    .need_pic(need_pic),
    .conv_finish(conv_finish),
    .conv_result_valid(conv_result_valid),
    .conv_result(conv_result),
    .conv_result_addr(conv_result_addr),
    .read_sram_enable(read_sram_enable),
    .sram_data_valid(sram_data_valid),
    .sram_data(sram_data),
    .weight_data_valid(weight_data_valid),
    .weight_data(weight_data)

  );

  // ----------------------------
  // Reset Task
  // ----------------------------
  task automatic reset_dut();
    begin
      rst_n = 0;
      pic = '0;
      pic_valid = 0;
      conv_start = 0;
      sram_data_valid = '0;
      sram_data = '0;
      weight_data_valid = '0;
      weight_data = '0;
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
    sram_data_valid = 1;
    sram_data = 1;
    #100;
    pic_valid = 1;
    pic = 1;
    weight_data_valid = 1;
    weight_data = 2;
    #100000;

    $finish;
  end

endmodule