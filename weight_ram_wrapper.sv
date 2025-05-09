`timescale 1ns / 1ps

module weight_ram_wrapper #(
    parameter DATA_WIDTH = 8,  // Data bit width
    parameter DATA_DEPTH = 256  // Number of data entries
) (
    input  logic                  clk,
    input  logic                  rst_n,    // Active Low reset
    input  logic [7:0]            address,
    input  logic                  address_valid, // Write enable signal
    output logic [DATA_WIDTH-1:0] read_data,
    output logic                  read_data_valid // Read data valid signal
);

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        read_data <= '0;
        read_data_valid <= 1'b0;
    end else begin
        read_data_valid <= address_valid;
        read_data <= 1;
    end
end

    // // Internal signals for SRAM wrapper
    // logic        sram_cs_n;
    // logic        sram_we_n;
    // logic        sram_ry;
    // logic [31:0] sram_write_data;
    // logic [31:0] sram_read_data;
    
    // // Internal register for output data
    // logic [DATA_WIDTH-1:0] read_data_reg;
    
    // // Instantiate the SRAM wrapper
    // sram_wrapper sram_inst (
    //     .clk        (clk),
    //     .cs_n       (sram_cs_n),
    //     .we_n       (sram_we_n),
    //     .address    (address),
    //     .ry         (sram_ry),
    //     .write_data (sram_write_data),
    //     .read_data  (sram_read_data)
    // );

    // // Control logic
    // always_ff @(posedge clk) begin
    //     if (!rst_n) begin
    //         read_data_reg <= '0;
    //         sram_cs_n     <= 1'b1;
    //         sram_we_n     <= 1'b1;
    //     end else begin
    //         // Always enable chip select for read operation
    //         sram_cs_n    <= 1'b0;
    //         sram_we_n    <= 1'b1;  // Disable write
            
    //         // Register the output data (one cycle delay)
    //         read_data_reg <= sram_read_data[DATA_WIDTH-1:0];
    //     end
    // end

    // // Connect internal register to output
    // assign read_data = read_data_reg;
    // // Tie unused inputs
    // assign sram_write_data = '0;

endmodule