module fake_conv_control#(
    parameter WIDTH = 8,
    parameter kernel_size =5,
    parameter pic_size = 28,
    parameter SIGN = 1, // 1 for signed, 0 for unsigned
    parameter FP_POSITIONS = 4, // Number of bits for the fractional part
    parameter channel = 3, // Number of channels
    parameter kernel_number = 1
)(
    input logic clk,
    input logic rst_n, // Active low reset
    input logic [WIDTH - 1:0] pic,
    input logic pic_valid, // Picture valid signal
    input logic conv_start,
    output logic need_pic,
    output logic conv_finish,
    output logic conv_result_valid, // Output valid signal
    output logic [WIDTH - 1:0] conv_result, // Result of the multiplication
    output logic [$clog2(pic_size*pic_size)-1:0] conv_result_addr // Counter for picture size
);



logic [$clog2(pic_size*pic_size * 3)-1:0] conv_counter,conv_counter_n;
logic [6:0] wait_counter,wait_counter_n;
logic write_begin,write_begin_n;
logic [$clog2(pic_size*pic_size)-1:0] write_counter,write_counter_n;
logic conv_counte_begin,conv_counte_begin_n;

assign conv_result = write_counter;
assign conv_result_valid = write_begin;
assign conv_result_addr = write_counter;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        conv_counter <= '0;
        wait_counter <= '0;
        write_begin <= 1'b0;
        write_counter <= '0;
        conv_counte_begin <= 1'b0;
    end else begin
        conv_counter <= conv_counter_n;
        wait_counter <= wait_counter_n; 
        write_begin <= write_begin_n;       
        write_counter <= write_counter_n; 
        conv_counte_begin <= conv_counte_begin_n;
    end
end

always_comb begin
    conv_counter_n = conv_counter;
    wait_counter_n = wait_counter;
    write_begin_n = write_begin;
    write_counter_n = write_counter;
    conv_counte_begin_n = conv_counte_begin;
    conv_finish = 1'b0;
    need_pic = 1'b0;
    if(conv_start) begin
        conv_counte_begin_n = 1;
    end
    if(conv_counte_begin) begin
        if(conv_counter == 26*3-1)begin
            if(wait_counter == 7'd68)begin
                wait_counter_n = 0;
                write_begin_n = 1'b1;
                conv_counter_n = 0;
                conv_counte_begin_n = 1'b0;
            end else begin
                wait_counter_n = wait_counter + 1'b1;
            end
            if(wait_counter == 0) begin
                need_pic = 1'b1;
            end
        end else begin
            if(wait_counter == 7'd68)begin
                wait_counter_n = 0;
                conv_counter_n = conv_counter + 1'b1;
            end else begin
                wait_counter_n = wait_counter + 1'b1;
            end
            if(wait_counter == 0) begin
                need_pic = 1'b1;
            end
        end
    end

        if(write_begin)begin
            if(write_counter == pic_size*pic_size-1)begin
                write_counter_n = 0;
                conv_finish = 1'b1;
                write_begin_n = 1'b0;
            end else begin
                write_counter_n = write_counter + 1'b1;
            end
        end

end





endmodule