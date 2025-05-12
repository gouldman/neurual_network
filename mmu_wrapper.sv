`define REG_CTRL       2'd0   // 偏移 0x00: CTRL（读写共址，写=启动，读=STATUS 返回）
`define REG_STATUS     2'd0   // STATUS 和 CTRL 共用偏移 0x00，读时输出 STATUS
`define REG_PIXEL_IN   2'd2   // 偏移 0x08: PIXEL_IN（写像素）
`define REG_SRAM       2'd3   // 偏移 0x0C: OFM_SRAM（读输出特征图）
`define REG_NEED_PIC   2'd1   // 偏移 0x04: 用于将need_pic_reg置零

module mmu_wrapper #(
  parameter APB_ADDR_WIDTH = 12,   // APB 地址宽度
  parameter DATA_WIDTH     = 8,
  parameter IFM_SIZE       = 28,
  parameter KSIZE          = 5
)(
  input  logic                     HCLK,
  input  logic                     HRESETn,

  // -- APB 从机接口 -- 
  input  logic [APB_ADDR_WIDTH-1:0] PADDR,
  input  logic               [31:0] PWDATA,
  input  logic                    PWRITE,
  input  logic                    PSEL,
  input  logic                    PENABLE,
  output logic              [31:0] PRDATA,
  output logic                    PREADY,
  output logic                    PSLVERR
);

  // --------------------------------------------------------------------------
  // 本地参数
  // --------------------------------------------------------------------------
  localparam OFM_DEPTH = IFM_SIZE * IFM_SIZE;
  localparam ADDR_BITS = $clog2(OFM_DEPTH);

  // --------------------------------------------------------------------------
  // 将 APB 事务对齐到寄存器索引
  // --------------------------------------------------------------------------
  logic [1:0] reg_adr;
  assign reg_adr = PADDR[3:2];

  assign PREADY  = 1'b1;
  assign PSLVERR = 1'b0;

  // --------------------------------------------------------------------------
  // 与 conv_control 握手信号
  // --------------------------------------------------------------------------
  logic                   conv_start;
  logic                   need_pic;        // 来自 conv_control
  //logic                   pic_valid;       // 发给    conv_control
  logic [DATA_WIDTH-1:0]  pic;             // 发给    conv_control
  

  // --------------------------------------------------------------------------
  // CTRL & REG_PIXEL_IN 寄存器 (0x00 & 0x10) -- APB写 (conv_start, pic, pic_valid)
  // --------------------------------------------------------------------------
  logic conv_start_reg;
  //, conv_start_n
  logic pic_valid, pic_valid_n;
  logic [DATA_WIDTH-1:0] pic_reg, pic_reg_n;
  logic need_pic_reg;



  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)begin             
      //conv_start_reg <= 1'b0;
      pic_valid <= 1'b0;
      pic_reg <= '0;
    end else begin                    
      //conv_start_reg <= conv_start_n;
      pic_reg <= pic_reg_n;
      pic_valid <= pic_valid_n;
    end
  end
  
always_comb begin
    //conv_start_n = conv_start_reg;
    //conv_start_n = 0;
    conv_start_reg = 0;
    pic_reg_n   = pic_reg;
    pic_valid_n = 1'b0;
    if (need_pic == 1'b1) begin
      need_pic_reg = 1'b1;
    end
    if (PSEL && PENABLE && PWRITE) begin
      case (reg_adr)
        `REG_CTRL: begin
          conv_start_reg = PWDATA[0];
        end
        `REG_PIXEL_IN: begin
          pic_reg_n = PWDATA[DATA_WIDTH-1:0];
          pic_valid_n  = 1'b1;
        end
        `REG_NEED_PIC: begin
          need_pic_reg = PWDATA[0];
        end
        default: begin
          // 其他地址，不改动这两个寄存器
          //conv_start_n = conv_start_reg;
          pic_reg_n   = pic_reg;
        end
      endcase
    end
  end

  assign conv_start = conv_start_reg;
  assign pic        = pic_reg;
 // assign pic_valid  = (PSEL && PENABLE && PWRITE && reg_adr==`REG_PIXEL_IN);

  // --------------------------------------------------------------------------
  // STATUS 寄存器 (0x00 读) + OFM SRAM 读 (0x0C 起) APB读
  // --------------------------------------------------------------------------
  logic [1:0] status_reg;


  logic [DATA_WIDTH-1:0] ofm_read_data;
  
always_comb begin
    PRDATA = 32'b0;
    if (PSEL && PENABLE && !PWRITE) begin
      case (reg_adr)
        `REG_STATUS: // 偏移 0x00,将conv_finish, conv_res_valid, need_pic送到总线
          PRDATA = {30'b0, status_reg};
        `REG_SRAM:   // 偏移 0x0C，将SRAM中的结果送入总线
          PRDATA = {24'b0, ofm_read_data};
        default:
          PRDATA = 32'b0;
      endcase
    end
  end

logic [21:0]            sram_addr,sram_addr_n;
//logic [1:0]             channel_counter,channel_counter_n;     // 通道选择（00, 01, 10, 11）
logic                   conv_res_valid;      // 来自 conv_control
logic [DATA_WIDTH-1:0]  conv_res, conv_res_reg;            // 来自 conv_control
logic                   conv_finish;         // 来自 conv_control
logic [ADDR_BITS-1:0]   conv_res_addr,conv_res_addr_reg;       // 来自 conv_control
logic                   sram_we, sram_we_n;             // SRAM 写使能
logic                    read_sram_enable; // conv_ctrl发来的读使能
logic                    sram_data_valid, sram_data_valid_n,sram_data_valid_delay;  // SRAM发给conv_ctrl的valid
logic                    sram_rd_en, sram_rd_en_n;
logic [DATA_WIDTH - 1:0] sram_data, sram_data_n;
logic [10:0]             sram_addr_rd, sram_addr_rd_n,  sram_addr_rd_reg;
//logic [1:0]              rd_cycle_counter, rd_cycle_counter_n;
logic [4:0]              RD_counter, RD_counter_n;
logic [4:0]              RD_enable_counter, RD_enable_counter_n; // 记录28周期的计数器
logic [1:0]              counter, counter_n;
  assign status_reg = {conv_finish, need_pic_reg};
  // 将握手信号连给 conv_control
  // --------------------------------------------------------------------------
  //fake_
  conv_control_integer u_conv (
    .clk               (HCLK),
    .rst_n             (HRESETn),
    .pic               (pic),
    .pic_valid         (pic_valid),
    .conv_start        (conv_start),
    .need_pic          (need_pic),
    .conv_finish       (conv_finish),
    .conv_result_valid (conv_res_valid),
    .conv_result       (conv_res),
    .conv_result_addr  (conv_res_addr),
    .read_sram_enable  (read_sram_enable),
    .sram_data_valid   (sram_data_valid),
    .sram_data         (sram_data)
  );
  
  // --------------------------------------------------------------------------
  // 写ofm_sram
  // --------------------------------------------------------------------------


assign conv_res_addr_reg = conv_res_addr;

// --------------------------------------------------------------------------
// 通道切换和计数控制
// --------------------------------------------------------------------------
always_ff @(posedge HCLK or negedge HRESETn) begin
  if (!HRESETn) begin             
    conv_res_reg <= '0;
    //conv_res_addr_reg <= '0;
    sram_we <= 1'b0;
   // channel_counter <= 2'b00;
    sram_addr <= '0;

  end else begin
    conv_res_reg <= conv_res;
    //conv_res_addr_reg <= conv_res_addr_n;
    sram_we <= sram_we_n;
    //channel_counter <= channel_counter_n;
    sram_addr <= sram_addr_n;
    
  end
end
//assign sram_w_data = conv_res_reg;
// --------------------------------------------------------------------------
// 地址选择（根据通道选择）
// --------------------------------------------------------------------------
always_comb begin
  //channel_counter_n = channel_counter;
  sram_addr_n = sram_addr;
  sram_we_n = sram_we;
  //conv_res_addr_n = conv_res_addr_reg;
  sram_addr_n = conv_res_addr_reg;

   if (conv_res_valid) begin
      sram_we_n = 1;  // 写入使能
    end else begin
      sram_we_n = 0;
    end
end

// --------------------------------------------------------------------------
// 读 ofm_sram
// --------------------------------------------------------------------------

always_ff @(posedge HCLK or negedge HRESETn) begin
  if (!HRESETn) begin             
    sram_data_valid <= 1'b0;
    sram_rd_en <= 1'b0;
    sram_addr_rd <= '0;
    RD_counter <= 5'b0;
    RD_enable_counter <= 5'b0;
    sram_data_valid_delay <= 1'b0;
    counter <= 2'b0;
  end else begin
    sram_addr_rd <= sram_addr_rd_n;
    sram_rd_en <= sram_rd_en_n;
    RD_counter <= RD_counter_n;
    RD_enable_counter <= RD_enable_counter_n;
    sram_data_valid_delay <= sram_data_valid_n;
    sram_data_valid <= sram_data_valid_delay;
    counter <= counter_n;
  end
end

// SRAM 读取地址寄存器，延迟 28 地址
//assign sram_addr_rd_reg = conv_res_addr_reg - 28;

always_comb begin
  sram_data_valid_n = sram_data_valid_delay;
  sram_rd_en_n = sram_rd_en;
  RD_counter_n = RD_counter;
  counter_n = counter;
  RD_enable_counter_n = RD_enable_counter;

  if(counter == 2'b0)begin
    sram_addr_rd_reg = conv_res_addr_reg - 28;
  end else begin
    sram_addr_rd_reg = conv_res_addr_reg;
  end

  if (read_sram_enable) begin
    sram_rd_en_n = 1'b1; // 启用读使能
    sram_data_valid_n = 1'b1;
    sram_addr_rd_n = sram_addr_rd_reg;
    if (RD_enable_counter == 5'd27) begin
      RD_enable_counter_n = 5'b0;
      if (RD_counter < 5'd27) begin
      RD_counter_n = RD_counter + 1; // 完成一个28周期计数
      end else begin
        RD_counter_n = 5'd0;
        counter_n = counter + 1;
      end  
    end else begin
      RD_enable_counter_n = RD_enable_counter + 1;
    end

  if (counter == 2'b0 && RD_counter == 5'd0) begin
      sram_rd_en_n = 1'b0;
      sram_data_valid_n = 1'b0;
      sram_addr_rd_n = '0;
  end

  end else begin
    sram_rd_en_n = 1'b0;
    sram_data_valid_n = 1'b0;
    RD_enable_counter_n = 5'b0;
    RD_counter_n = RD_counter; // 保持不变
  end

end
/*
always_comb begin
  rd_cycle_counter_n = rd_cycle_counter;
  sram_data_valid_n = sram_data_valid;
  sram_rd_en_n = sram_rd_en;
  RD_counter_n = RD_counter;
  RD_enable_counter_n = RD_enable_counter;

  // 仅在 read_sram_enable 高时启用读操作
  
  if (read_sram_enable) begin
    sram_rd_en_n = 1'b1; // 启用读使能
  end else begin
    sram_rd_en_n = 1'b0;
  end    

  if (sram_rd_en_n) begin
    sram_addr_rd_n = (RD_enable_counter == 0) ? sram_addr_rd_reg : sram_addr_rd_delay; // 初次加载初始地址
    //sram_addr_rd_n = sram_addr_rd_reg;
    // 每两个时钟周期改变地址
    if (rd_cycle_counter == 2'b00) begin
      rd_cycle_counter_n = rd_cycle_counter + 1;
      sram_data_valid_n = 1'b0; // 第一个周期：无效数据
      
    end else if (rd_cycle_counter == 2'b01) begin
      rd_cycle_counter_n = 2'b00; // 第二个周期：数据有效
      sram_data_valid_n = 1'b1;
      sram_addr_rd_n = sram_addr_rd_n + 1; // 地址在此周期递增
      
    end

    if (RD_enable_counter == 5'd27) begin
      RD_enable_counter_n = 5'b0;
      if (RD_counter < 5'd27) begin
      RD_counter_n = RD_counter + 1; // 完成一个28周期计数
      end else begin
        RD_counter_n = 5'd0;
      end  
    end else begin
      RD_enable_counter_n = RD_enable_counter + 1;
    end

    if (RD_counter == 5'd0) begin
      sram_rd_en_n = 1'b0;
      sram_data_valid_n = 1'b0;
      sram_addr_rd_n = '0;
    end

  end else begin
    sram_data_valid_n = 1'b0;
    rd_cycle_counter_n = 2'b00;
    RD_enable_counter_n = 5'b0;
    RD_counter_n = RD_counter; // 保持不变
  end

end
*/
assign sram_data = ofm_read_data;

//读写使能信号选择
logic  write_en ;
assign write_en = sram_rd_en ? 1'b0 : sram_we;

logic  [10:0] addr;
assign addr = sram_rd_en? sram_addr_rd : sram_addr;

logic ry;

// --------------------------------------------------------------------------
// 实例化 ofm_sram，直接写入
// --------------------------------------------------------------------------
ofm_sram_1 #(
  .DATA_WIDTH(DATA_WIDTH),
  .ADDR_BITS (11)  // SPHDL100909，每个11位地址，一共4KB
) u_ofm (
  .clk      (HCLK),
  //.write_en (sram_rd_en),
  //.write_en (sram_we),
  .write_en (write_en),
  .addr     (addr),
  //.addr     (sram_addr),
  //.addr     (sram_addr_rd),
  .wdata    (conv_res_reg),
  .rdata    (ofm_read_data),
  .ry_out   (ry)
);

endmodule
