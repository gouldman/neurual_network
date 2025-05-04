module MU_array#(
    parameter WIDTH = 8,
    parameter kernel_size = 3,
    parameter pic_size = 28,
    parameter SIGN = 1, // 1 for signed, 0 for unsigned
    parameter FP_POSITIONS = 4 
)(
    input logic clk,
    input logic rst_n,
    input logic pic_ready,
    input logic [WIDTH - 1:0] pic,
    input logic pic_valid,
    output logic [$clog2(kernel_size*kernel_size)-1:0] pic_addr, // Counter for kernel size
    output logic pic_read,
    output logic [WIDTH - 1:0] conv_result, // Result of the multiplication
    output logic conv_result_valid
);

logic[WIDTH - 1:0] weight_array [kernel_size*kernel_size-1:0] = '{
    8'h01, 8'h02, 8'h03,
    8'h04, 8'h05, 8'h06,
    8'h07, 8'h08, 8'h09
  };; // 2D array for the picture
logic [WIDTH - 1:0] pic_buffer[pic_size - kernel_size:0];
logic [$clog2(pic_size)-1:0] pic_buffer_addr; // Counter for picture size

enum int unsigned {IDLE = 0, LOAD = 1, CAL = 3} cs, ns;

always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cs <= IDLE;
    end else begin
        cs <= ns;
    end
end

always_comb begin:state_switch
    ns = cs; // Default to current state
    pic_addr = 0; // Default to zero
    pic_buffer_addr = 0;
    pic_read = 0; // Default to zero
    conv_result_valid = 0; // Default to zero
    conv_result = 0; // Default to zero

    case (cs)
        IDLE: begin
            if (pic_ready) begin
                ns = LOAD;
            end
        end

        LOAD: begin
            if (pic_valid) begin
                pic_buffer[pic_buffer_addr] = pic; // Store the picture in the buffer
                pic_addr = pic_addr + 1; // Increment the address counter
                if ((pic_addr % (pic_size - kernel_size))) begin
                    ns = CAL;
                end
            end else begin
                ns = LOAD;
            end
        end

        CAL: begin
            if (pic_valid) begin
                pic_read = 1; // Set the read signal high for the picture buffer
                conv_result_valid = 1; // Set the valid signal high for the result
                conv_result = pic_buffer[pic_addr] * weight_array[pic_addr]; // Perform the convolution operation
                pic_addr = pic_addr + 1; // Increment the address counter
                if (pic_addr == pic_size - kernel_size) begin
                    ns = IDLE;
                end else begin
                    ns = CAL;
                end
            end else begin
                ns = CAL;
            end
        end

        default: ns = IDLE; // Default case to handle unexpected states

    endcase
end

endmodule
