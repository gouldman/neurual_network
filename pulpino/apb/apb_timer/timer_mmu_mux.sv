module timer_mmu_mux
#(
    parameter APB_ADDR_WIDTH = 12,  //APB slaves are 4KB by default
    parameter TIMER_CNT = 2 // how many timers should be instantiated
)
(
    input  logic                      HCLK,
    input  logic                      HRESETn,
    input  logic [31:0] PADDR,
    input  logic               [31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic               [31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    output logic [(TIMER_CNT * 2) - 1:0] irq_o // overflow and cmp interrupt
);

logic [31:0] PWDATA_TIMER;
logic PWRITE_TIMER;
logic PSEL_TIMER;
logic PENABLE_TIMER;
logic [31:0] PRDATA_TIMER;

logic [31:0] PWDATA_MMU;
logic PWRITE_MMU;
logic PSEL_MMU;
logic PENABLE_MMU;
logic [31:0] PRDATA_MMU;

assign PWDATA_TIMER = (PADDR >=  32'h2000_0000) ? 0 : PWDATA;
assign PWITE_TIMER = (PADDR >=  32'h2000_0000) ? 0 : PWRITE;
assign PSEL_TIMER = (PADDR >=  32'h2000_0000) ? 0 : PSEL;
assign PENABLE_TIMER = (PADDR >=  32'h2000_0000) ? 0 : PENABLE;


assign PRDATA = (PADDR >=  32'h2000_0000) ? PRDATA_MMU : PRDATA_TIMER;


// MMU信号分配
assign PWDATA_MMU = (PADDR >= 32'h2000_0000) ? PWDATA : 0;
assign PWRITE_MMU = (PADDR >= 32'h2000_0000) ? PWRITE : 0;
assign PSEL_MMU = (PADDR >= 32'h2000_0000) ? PSEL : 0;
assign PENABLE_MMU = (PADDR >= 32'h2000_0000) ? PENABLE : 0;
assign PRDATA_MMU = 0;

apb_mmu #(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH)
) apb_mmu_i (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .PADDR(PADDR[11:0]),
    .PWDATA(PWDATA_TIMER),
    .PWRITE(PWITE_TIMER),
    .PSEL(PSEL_TIMER),
    .PENABLE(PENABLE_TIMER),
    .PRDATA(PRDATA_TIMER)
);

apb_timer #(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
    .TIMER_CNT(TIMER_CNT)
) apb_timer_i (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .PADDR(PADDR[11:0]),
    .PWDATA(PWDATA_TIMER),
    .PWRITE(PWITE_TIMER),
    .PSEL(PSEL_TIMER),
    .PENABLE(PENABLE_TIMER),
    .PRDATA(PRDATA_TIMER),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),

    .irq_o(irq_o)
);

endmodule