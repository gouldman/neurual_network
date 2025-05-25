module fake_sram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = $clog2(28*28), // 2^10 = 1024 words
    parameter MEM_DEPTH  = 1 << ADDR_WIDTH
)(
    input  wire                  clk,
    input  wire                  rst_n,    // 异步低电平复位
    input  wire                  ce,       // 片选
    input  wire                  we,       // 写使能
    input  wire [ADDR_WIDTH-1:0] addr,     // 地址
    input  wire [DATA_WIDTH-1:0] wdata,    // 写入数据
    output reg  [DATA_WIDTH-1:0] rdata,     // 读取数据
    input logic read_previous_result_enable,
    output logic previous_result_valid
);

    // 内存数组
    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // 主逻辑：同步写、读，异步复位清空rdata
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata <= '0;
            previous_result_valid <= '0;
        end else if (ce) begin
            previous_result_valid <= read_previous_result_enable;
            if (we) begin
                mem[addr] <= wdata;       // 写入数据
            end else begin
                rdata <= mem[addr];       // 读取数据
            end
        end else begin
            previous_result_valid <= read_previous_result_enable;
        end
    end

endmodule