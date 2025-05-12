`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/11 12:08:21
// Design Name: 
// Module Name: ofm_sram_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ofm_sram_1 #(
 parameter DATA_WIDTH = 8,
  parameter ADDR_BITS  = 11  // ceil(log2(28*28)) = 10
)(
  input  logic                   clk,
  input  logic                   write_en,  // 1 = 写入, 0 = 读取
  input  logic [ADDR_BITS-1:0]   addr,
  input  logic [DATA_WIDTH-1:0]  wdata,
  output logic [DATA_WIDTH-1:0]  rdata,
  output logic ry_out
);

  // ST SRAM 的控制信号：
  //  - CSN 低有效，这里始终选中
  //  - WEN 低有效，write_en=1 时拉低 WEN 以写入
  //  - TBYPASS 拉低，表示直接走 SRAM 而不旁路
 // localparam ADDR_WIDTH = 22;          // ST_SPHDL_2048x8m8_L 模型里 Addr=11

  logic tbypass_n = 1'b0;
  logic csn_sram1 = 1'b0;
  logic wen_sram1;
  logic ry;

  assign wen_sram1 = ~write_en;
  assign ry_out = ry;
  
  // 实例化 ST 的 2048×8 SRAM
  ST_SPHDL_2048x8m8_L u_sram (
    .Q      (rdata),
    .RY     (ry),           
    .CK     (clk),
    .CSN    (csn_sram1),
    .TBYPASS(tbypass_n),
    .WEN    (wen_sram1),
    .A      (addr),
    .D      (wdata)
  );
endmodule
