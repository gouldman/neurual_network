`timescale 1ns/1ps

module sv_study_tb;
    parameter WIDTH = 8;
    
    logic clk;
    logic rst_n;
    logic enable;
    logic [WIDTH-1:0] count;
    
    // 实例化计数器模块
    counter #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .count(count)
    );
    
    // 生成时钟信号
    always #5 clk = ~clk;
    
    // 测试过程
    initial begin
        // 初始化信号
        clk = 0;
        rst_n = 0;
        enable = 0;
        
        #10 rst_n = 1; // 释放复位
        #10 enable = 1; // 开启计数
        
        #50 enable = 0; // 暂停计数
        #20 enable = 1; // 重新计数
        
        #50 rst_n = 0; // 再次复位
        #10 rst_n = 1;
        
        #30 $finish; // 结束仿真
    end
    
    // 监视信号变化
    initial begin
        $monitor("Time=%0t | clk=%b | rst_n=%b | enable=%b | count=%d", 
                 $time, clk, rst_n, enable, count);
    end
endmodule
