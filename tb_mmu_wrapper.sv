`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/09 23:44:31
// Design Name: 
// Module Name: tb_mmu_wrapper
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


module tb_mmu_wrapper;
  // ------------------------------------------------------------------------
  // 参数
  // ------------------------------------------------------------------------
  localparam APB_ADDR_WIDTH = 12;
  localparam DATA_WIDTH     = 8;
  localparam IFM_SIZE       = 28;
  localparam PADDING        = 4;
  localparam KSIZE          = 5;
  localparam OFM_DEPTH      = IFM_SIZE * IFM_SIZE;

  // ------------------------------------------------------------------------
  // 时钟与复位
  // ------------------------------------------------------------------------
  logic HCLK, HRESETn;
  initial begin
    HCLK = 0;
    forever #5 HCLK = ~HCLK;  // 10ns 周期
  end
  initial begin
    HRESETn = 0;
    #20;
    HRESETn = 1;
  end

  // ------------------------------------------------------------------------
  // APB 从机接口信号
  // ------------------------------------------------------------------------
  logic [APB_ADDR_WIDTH-1:0] PADDR;
  logic [31:0]               PWDATA;
  logic                      PWRITE, PSEL, PENABLE;
  logic [31:0]               PRDATA;
  logic                      PREADY, PSLVERR;

  // ------------------------------------------------------------------------
  // DUT 实例化
  // ------------------------------------------------------------------------
  mmu_wrapper #(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
    .DATA_WIDTH    (DATA_WIDTH),
    .IFM_SIZE      (IFM_SIZE),
    .KSIZE         (KSIZE)
  ) dut (
    .HCLK     (HCLK),
    .HRESETn  (HRESETn),
    .PADDR    (PADDR),
    .PWDATA   (PWDATA),
    .PWRITE   (PWRITE),
    .PSEL     (PSEL),
    .PENABLE  (PENABLE),
    .PRDATA   (PRDATA),
    .PREADY   (PREADY),
    .PSLVERR  (PSLVERR)
  );

  // ------------------------------------------------------------------------
  // APB 写事务 task
  // ------------------------------------------------------------------------
  task apb_write(input logic [31:0] addr, input logic [31:0] data);
    begin
      // 地址+数据->总线
      @(posedge HCLK);
      PADDR   <= addr;
      PWDATA  <= data;
      PWRITE  <= 1;
      PSEL    <= 1;
      PENABLE <= 0;
      // 下一个时钟使能
      @(posedge HCLK);
      PENABLE <= 1;
      //wait (PREADY);
      // 事务结束，收手
//      @(posedge HCLK);
//      PSEL    <= 0;
//      PENABLE <= 0;
//      PWRITE  <= 0;
    end
  endtask

  // ------------------------------------------------------------------------
  // APB 读事务 task
  // ------------------------------------------------------------------------
  task apb_read(input  logic [31:0] addr,
                         output logic [31:0] data);
    begin
      /*
      @(posedge HCLK);
      PADDR   <= addr;
      PWRITE  <= 0;
      PSEL    <= 1;
      PENABLE <= 0;
      @(posedge HCLK);
      PENABLE <= 1;
//      //wait (PREADY);
      data <= PRDATA;
////      @(posedge HCLK);
////      PSEL    <= 0;
////      PENABLE <= 0;
*/
 // Phase 1: 设置读取操作
    @(posedge HCLK);
    PADDR   <= addr;
    PWRITE  <= 1'b0;
    PSEL    <= 1'b1;
    PENABLE <= 1'b0;

    // Phase 2: 使能读取
    @(posedge HCLK);
    PENABLE <= 1'b1;

    // Phase 3: 捕获数据（确保稳定）
    @(posedge HCLK);
    data = PRDATA;

    end
  endtask

  // ------------------------------------------------------------------------
  // 测试流程
  // ------------------------------------------------------------------------
  initial begin
    logic [31:0] status;
    logic [31:0] outd;
    integer      i;

    // 1) 先把所有 APB 信号拉低
    PADDR   = 0;
    PWDATA  = 0;
    PWRITE  = 0;
    PSEL    = 0;
    PENABLE = 0;

    // 2) 等复位完成
    @(posedge HRESETn);
    #10;

    // 3) 写 CTRL=1 => 启动卷积
    $display("[%0t] ==> Start convolution", $time);
    apb_write(32'h0, 32'h1);

    apb_read(32'h0, status);    // 读 STATUS
    if (!status[0]) begin
      $display("[%0t] ERROR: need_pic low", $time);
    end else begin
    $display("[%0t] need_pic detected (after fixed wait)", $time);
    apb_write(32'h4, 0);
    end
    
    // 5) 首次连续送入 3*28=84 个像素(padding)
    $display("[%0t] feeding first %0d pixels", $time, (KSIZE-PADDING/2)*IFM_SIZE);
    repeat ((KSIZE-PADDING/2)*IFM_SIZE) begin
      apb_write(32'h8, {24'd0, 8'd1});
      //apb_write(32'h8, {24'd0, $urandom_range(0,255)});
    end


//循环25次，送完整个IFM
for(i=0; i<25; i++) begin
//// 6) 再次等待 need_pic
$display("[%0t] Iteration %0d - Waiting for need_pic...", $time, i+1);

$display("[%0t] waiting second need_pic...", $time);


while (1) begin
  apb_read(32'h0, status);  // 调用任务读取 STATUS
  $display("[%0t] Read STATUS: %h", $time, status);
  
  if (status[0]) begin
    $display("[%0t] need_pic detected", $time);
    apb_write(32'h4, 32'd0);
    break;
  end
end

    // 7) 再送 IFM_SIZE=28 个像素
    $display("[%0t] feeding next %0d pixels", $time, IFM_SIZE);
    repeat (IFM_SIZE) begin
      apb_write(32'h8, {24'd0, 8'd1});
      //apb_write(32'h8, {24'd0, $urandom_range(0,255)});
    end
end  
//    // 8) 读回前 4 个输出 (OFM)
//    for (i = 0; i < 4; i = i + 1) begin
//      apb_read(32'h0C + i*4, outd);
//      $display("  OFM[%0d] = %0d", i, outd[7:0]);
//    end

//    $display("[%0t] ==> Testbench complete", $time);

 /////////// channel 2 ////////////
  $display("[%0t] channel 2 caculation begin...", $time);

   while (1) begin
  apb_read(32'h0, status);  // 调用任务读取 STATUS
  $display("[%0t] Read STATUS: %h", $time, status);
  
  if (status[0]) begin
    $display("[%0t] need_pic detected", $time);
    apb_write(32'h4, 32'd0);
    break;
  end
end
    
    // 5) 首次连续送入 3*28=84 个像素(padding)
    $display("[%0t] feeding first %0d pixels", $time, (KSIZE-PADDING/2)*IFM_SIZE);
    repeat ((KSIZE-PADDING/2)*IFM_SIZE) begin
      apb_write(32'h8, {24'd0, 8'd1});
      //apb_write(32'h8, {24'd0, $urandom_range(0,255)});
    end


//循环25次，送完整个IFM
for(i=0; i<25; i++) begin
//// 6) 再次等待 need_pic
$display("[%0t] Iteration %0d - Waiting for need_pic...", $time, i+1);

$display("[%0t] waiting second need_pic...", $time);


while (1) begin
  apb_read(32'h0, status);  // 调用任务读取 STATUS
  $display("[%0t] Read STATUS: %h", $time, status);
  
  if (status[0]) begin
    $display("[%0t] need_pic detected", $time);
    apb_write(32'h4, 32'd0);
    break;
  end
end

    // 7) 再送 IFM_SIZE=28 个像素
    $display("[%0t] feeding next %0d pixels", $time, IFM_SIZE);
    repeat (IFM_SIZE) begin
      apb_write(32'h8, {24'd0, 8'd1});
      //apb_write(32'h8, {24'd0, $urandom_range(0,255)});
    end
end  
//    // 8) 读回前 4 个输出 (OFM)
//    for (i = 0; i < 4; i = i + 1) begin
//      apb_read(32'h0C + i*4, outd);
//      $display("  OFM[%0d] = %0d", i, outd[7:0]);
//    end

//    $display("[%0t] ==> Testbench complete", $time);

/////////// channel 3 ////////////
  $display("[%0t] channel 3 caculation begin...", $time);

   while (1) begin
  apb_read(32'h0, status);  // 调用任务读取 STATUS
  $display("[%0t] Read STATUS: %h", $time, status);
  
  if (status[0]) begin
    $display("[%0t] need_pic detected", $time);
    apb_write(32'h4, 32'd0);
    break;
  end
end
    
    // 5) 首次连续送入 3*28=84 个像素(padding)
    $display("[%0t] feeding first %0d pixels", $time, (KSIZE-PADDING/2)*IFM_SIZE);
    repeat ((KSIZE-PADDING/2)*IFM_SIZE) begin
      apb_write(32'h8, {24'd0, 8'd1});
      //apb_write(32'h8, {24'd0, $urandom_range(0,255)});
    end


//循环25次，送完整个IFM
for(i=0; i<25; i++) begin
//// 6) 再次等待 need_pic
$display("[%0t] Iteration %0d - Waiting for need_pic...", $time, i+1);

$display("[%0t] waiting second need_pic...", $time);

#10000;
$finish;
while (1) begin
  apb_read(32'h0, status);  // 调用任务读取 STATUS
  $display("[%0t] Read STATUS: %h", $time, status);
  
  if (status[0]) begin
    $display("[%0t] need_pic detected", $time);
    apb_write(32'h4, 32'd0);
    break;
  end
end

    // 7) 再送 IFM_SIZE=28 个像素
    $display("[%0t] feeding next %0d pixels", $time, IFM_SIZE);
    repeat (IFM_SIZE) begin
      apb_write(32'h8, {24'd0, 8'd1});
      //apb_write(32'h8, {24'd0, $urandom_range(0,255)});
    end
end  
//    // 8) 读回前 4 个输出 (OFM)
//    for (i = 0; i < 4; i = i + 1) begin
//      apb_read(32'h0C + i*4, outd);
//      $display("  OFM[%0d] = %0d", i, outd[7:0]);
//    end

//    $display("[%0t] ==> Testbench complete", $time);

end

endmodule

