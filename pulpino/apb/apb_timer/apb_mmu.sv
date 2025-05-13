`define OUT_DATA_NUM 'd7
module apb_timer
#(
    parameter APB_ADDR_WIDTH = 12  //APB slaves are 4KB by default
)
(
    input  logic                      HCLK,
    input  logic                      HRESETn,
    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic               [31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic               [31:0] PRDATA
);

// top top_i (
//     .clk (HCLK),         // 全局时钟
//     .reset_n(HRESETn),     // 异步复位，低有效
//     .data(data),        // 示例：输入数据位宽
//     .data_valid(data_valid),  // data 有效信号
//     .finish(finish)      // 表示整个运算流程完成
// )

localparam REGS_ADDR_WIDTH =$clog2(`OUT_DATA_NUM+1);
logic [REGS_ADDR_WIDTH-1:0]       register_adr;
assign register_adr = PADDR[REGS_ADDR_WIDTH + 2:2];
logic [0:`OUT_DATA_NUM] [31:0]  out_data_q, out_data_n;

always_ff @(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn)
    begin
        out_data_q       <= '{default: 32'b0};
    end
    else
    begin
        out_data_q       <= out_data_n;
    end
end

always_comb
begin
    PRDATA = 'b0;
    out_data_n = out_data_q;
    // 这里可以添加逻辑来更新 out_data_n 的值
    // 例如：out_data_n[0] = PWDATA; // 将 PWDATA 写入 out_data_n 的第一个元素
    if(PSEL && PENABLE && PWRITE)
    begin
        out_data_n[register_adr] = PWDATA;
    end else if(PSEL && PENABLE && !PWRITE)
    begin
        PRDATA = out_data_q[register_adr];
    end
end


endmodule