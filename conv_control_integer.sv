module conv_control_integer#(
    parameter pic_bits = 2,
    parameter weight_bits = 3,
    parameter kernel_size =5,
    parameter pic_size = 28,
    parameter kernel_number = 1,
    parameter channel = 1, // Number of channels
    parameter conv_result_bits = $clog2(kernel_size*kernel_size*kernel_number*channel) + weight_bits + 1
    // parameter SIGN = 1, // 1 for signed, 0 for unsigned
    // parameter FP_POSITIONS = 4, // Number of bits for the fractional part

)(
    input logic clk,
    input logic rst_n, // Active low reset
    input logic [pic_bits - 1:0] pic,
    input logic pic_valid, // Picture valid signal
    input logic conv_start,
    output logic need_pic,
    output logic conv_finish,
    output logic conv_result_valid, // Output valid signal
    output logic [conv_result_bits - 1:0] conv_result, // Result of the multiplication
    output logic [$clog2(pic_size*pic_size)-1:0] conv_result_addr // Counter for picture size
);
typedef enum logic [1:0] {IDLE, RD, CAL, WD} state_t; // State machine for control
localparam int PADDING = 4;

logic [pic_bits - 1:0] pic_buffer[kernel_size - 1:0] [pic_size - 1 + PADDING:0]; // 2D array for the picture
logic [$clog2(pic_size)-1:0] row_counter, row_counter_next; // Counter for picture size
logic [$clog2(pic_size)-1:0] col_counter, col_counter_next; // Counter for picture size
logic [$clog2(channel)-1:0] channel_counter, channel_counter_next; // Counter for channel size
logic update_pic_buffer,update_pic_buffer_n; // Update picture buffer signal
logic init_pic_buffer,init_pic_buffer_n; // Initialize picture buffer signal
logic need_pic_reg, need_pic_reg_n; // Register for need picture signal
logic need_weight_reg, need_weight_reg_n; // Register for need weight signal
logic [1 : 0] update_first_r_counter, update_first_r_counter_n; // Update first row counter signal
logic [$clog2(pic_size) - 1:0] update_c_counter, update_c_counter_n; // Update first column counter signal
logic [conv_result_bits - 1:0] result_buffer [pic_size*pic_size - 1:0];
logic [$clog2(kernel_number)-1:0] kernel_counter, kernel_counter_next; // Counter for filter number
logic [$clog2(kernel_size*kernel_size*kernel_number*channel)-1:0] weight_addr, weight_addr_n; // Address for weight RAM
logic [$clog2(kernel_size*kernel_size)-1:0] weight_counter,weight_counter_n; // Address for kernel RAM
logic weight_addr_valid, weight_addr_valid_n; // Address valid signal for weight RAM
logic [weight_bits - 1:0] weight_buffer [kernel_size * kernel_size - 1:0]; // Buffer for weight data
logic [weight_bits - 1:0] weight_data; // Data from weight RAM
logic weight_data_valid; // Data valid signal from weight RAM
logic PE_enable;
logic [pic_bits - 1:0] shift_window [kernel_size * kernel_size - 1:0];
logic [conv_result_bits - 1:0] middle_conv_result, middle_conv_result_temp; // Result of the convolution
logic middle_conv_result_valid; // Valid signal for the convolution result
state_t state, state_n; // State machine for control

logic [$clog2(pic_size * pic_size)-1:0] middle_result_counter, middle_result_counter_next; // Counter for picture size
logic [$clog2(pic_size * pic_size)-1:0] WD_counter, WD_counter_next; // Counter for picture size
logic [$clog2(kernel_number) - 1:0] WD_kernel_counter, WD_kernel_counter_next; // Counter for filter number
logic conv_finish_reg, conv_finish_reg_n; // Register for convolution finish signal

assign need_pic = need_pic_reg; // Assign the need picture signal to the output
assign conv_finish = conv_finish_reg; // Assign the convolution finish signal to the output

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        update_pic_buffer <= 0; // Reset the update picture buffer signal
        init_pic_buffer <= 0; // Reset the initialize picture buffer signal
        row_counter <= 0; // Reset the row counter
        col_counter <= 0; // Reset the column counter
        channel_counter <= 0; // Reset the channel counter
        need_pic_reg <= 0; // Reset the need picture register
        need_weight_reg <= 0; // Reset the need weight register
        update_first_r_counter <= 0; // Reset the update first row counter signal
        update_c_counter <= 0; // Reset the update first column counter signal
        state <= IDLE; // Reset the state machine to IDLE state
        kernel_counter <= 0; // Reset the filter counter
        weight_addr <= 0; // Reset the weight address
        weight_addr_valid <= 0; // Reset the weight address valid signal
        weight_counter <= 0;
        middle_result_counter <= 0;
        WD_counter <= 0;
        conv_finish_reg <= 0; // Reset the convolution finish signal
        WD_kernel_counter <= 0; // Reset the filter counter
    end else begin 
        
        update_pic_buffer <= update_pic_buffer_n; // Update the picture buffer signal
        init_pic_buffer <= init_pic_buffer_n; // Initialize the picture buffer signal
        row_counter <= row_counter_next; // Update the row counter
        col_counter <= col_counter_next; // Update the column counter
        channel_counter <= channel_counter_next; // Update the channel counter
        need_pic_reg <= need_pic_reg_n; // Update the need picture register
        need_weight_reg <= need_weight_reg_n; // Update the need weight register
        update_first_r_counter <= update_first_r_counter_n; // Update the first row counter signal
        update_c_counter <= update_c_counter_n; // Update the first column counter signal
        weight_counter <= weight_counter_n; // Update the weight counter
        state <= state_n; // Update the state machine
        kernel_counter <= kernel_counter_next; // Update the filter counter
        weight_addr <= weight_addr_n; // Update the weight address
        weight_addr_valid <= weight_addr_valid_n; // Update the weight address valid signal
        middle_result_counter <= middle_result_counter_next; // Update the result counte
        WD_counter <= WD_counter_next; // Update the result counter
        conv_finish_reg <= conv_finish_reg_n; // Update the convolution finish signal
        WD_kernel_counter <= WD_kernel_counter_next; // Update the filter counter
    end
end

always_ff @(posedge clk or negedge rst_n) begin

    if(state == IDLE && conv_start) begin
        for (integer i = 0; i < pic_size * pic_size; i = i + 1) begin
            result_buffer[i]<= 0;
        end
    end        
    // if(state == CAL && col_counter == pic_size - 1 && row_counter == pic_size - 1 && channel_counter == channel - 1) begin
    //     for(integer i = 0; i< kernel_size * kernel_size; i = i + 1) begin
    //         result_buffer[i] <= 0;
    //     end
    // end
    if(middle_conv_result_valid) begin
        result_buffer[middle_result_counter] <= middle_conv_result; // Store the result in the buffer
    end
end

always_comb begin
    middle_result_counter_next = middle_result_counter; // Default to current result counter

    if(middle_conv_result_valid) begin
        if(middle_result_counter == pic_size * pic_size - 1) begin
            middle_result_counter_next = 0; // Reset the result counter
        end else begin
            middle_result_counter_next = middle_result_counter + 1; // Increment the result counter
        end
    end
end

always_comb begin
    conv_result_valid = 0; // Default to zero
    conv_result = 0; // Default to zero
    conv_result_addr = 0;
    PE_enable = 0;
    WD_counter_next = WD_counter; // Default to current result counter
    state_n = state; // Default to current state
    need_pic_reg_n = need_pic_reg; // Default to current need picture register value
    update_pic_buffer_n = update_pic_buffer; // Default to current update picture buffer signal
    init_pic_buffer_n = init_pic_buffer; // Default to current initialize picture buffer signal
    update_first_r_counter_n = update_first_r_counter; // Default to current update first row counter signal]
    update_c_counter_n = update_c_counter; // Default to current update first column counter signal
    row_counter_next = row_counter; // Default to current row counter
    col_counter_next = col_counter; // Default to current column counter
    channel_counter_next = channel_counter; // Default to current channel counter
    kernel_counter_next = kernel_counter; // Default to current filter counter
    weight_addr_n = weight_addr; // Default to current weight address
    weight_addr_valid_n = weight_addr_valid; // Default to current weight address valid signal
    need_weight_reg_n = need_weight_reg; // Default to current need weight register signal
    weight_counter_n = weight_counter;
    conv_finish_reg_n = 0; // Default to current convolution finish signal
    WD_kernel_counter_next = WD_kernel_counter; // Default to current filter counter
    for(integer i = 0; i< kernel_size * kernel_size; i = i + 1) begin
        shift_window[i] = 0; // Initialize the weight buffer to zero
    end
    case(state)
        IDLE: begin
            if(conv_start) begin
                for(integer i = 0; i< kernel_size * kernel_size; i = i + 1) begin
                    weight_buffer[i] = 0; // Initialize the weight buffer to zero
                end
                state_n = RD;
                init_pic_buffer_n = 1; // Set the initialize picture buffer signal
                need_weight_reg_n = 1;
                weight_addr_valid_n = 1;
            end
        end
        RD: begin
            if(need_weight_reg) begin
                if(weight_counter < 25) begin
                    weight_addr_n = weight_addr + 1; // Increment the weight address
                end
                if(weight_counter == 24) begin
                    weight_addr_valid_n = 0;
                end
                if(weight_counter == 25) begin
                    if(channel_counter == channel - 1) begin
                        weight_addr_n = 0; // Reset the weight address
                    end    
                    need_weight_reg_n = 0;
                    weight_counter_n = 0; // Reset the weight counter
                end else begin
                    weight_counter_n = weight_counter + 1; // Increment the weight address
                end
                if(weight_data_valid) begin
                    weight_buffer[weight_counter - 1] = weight_data;
                end
            end
            if(init_pic_buffer) begin
                update_pic_buffer_n = 1; // Set the update picture buffer signal
                if(row_counter < 26) begin
                    need_pic_reg_n = 1;
                end else begin
                    update_pic_buffer_n = 0; // Reset the update picture buffer signal
                    need_pic_reg_n = 0; // Reset the need picture register signal
                    state_n = CAL; // Move to CAL state                                   
                end
                init_pic_buffer_n = 0; // Initialize the picture buffer signal
                if(row_counter == 0) begin
                    for(integer i = 0; i < kernel_size ; i = i + 1) begin
                        for(integer j = 0; j < pic_size + PADDING; j = j + 1) begin
                            pic_buffer[i][j] = 0; // Initialize the picture buffer to zero
                        end
                    end
                end else begin
                    for(integer i = 0; i<kernel_size ; i = i + 1) begin
                        for(integer j = 0; j < pic_size + PADDING; j = j + 1) begin
                            pic_buffer[i][j] = pic_buffer[i + 1][j]; // Keep the picture buffer unchanged
                        end
                    end
                    for(integer j = 0; j < pic_size + PADDING; j = j + 1) begin
                        pic_buffer[kernel_size - 1][j] = 0; // Keep the picture buffer unchanged
                    end
                end
            end else if(update_pic_buffer) begin
                need_pic_reg_n = 0; // Reset the need picture register signal
                if(pic_valid) begin
                    if(row_counter == 0) begin
                        pic_buffer[update_first_r_counter+2][update_c_counter+2] = pic; // Update the picture buffer with the new picture
                        if(update_c_counter == pic_size - 1) begin
                            update_c_counter_n = 0; // Reset the column counter
                            if(update_first_r_counter == kernel_size - PADDING/2 -1) begin
                                update_first_r_counter_n = 0; // Reset the row counter
                                update_pic_buffer_n = 0; // Reset the update picture buffer signal
                                state_n = CAL; // Move to CAL state
                            end else
                                update_first_r_counter_n = update_first_r_counter + 1; // Increment the row counter
                        end else begin
                            update_c_counter_n = update_c_counter + 1;
                        end
                    end else begin
                        pic_buffer[kernel_size - 1][update_c_counter + 2] = pic; // Update the picture buffer with the new picture
                        if(update_c_counter == pic_size - 1) begin
                            update_c_counter_n = 0; // Reset the column counter
                            update_pic_buffer_n = 0; // Reset the update picture buffer signal
                            state_n = CAL; // Move to CAL state
                        end else begin
                            update_c_counter_n = update_c_counter + 1;
                        end
                    end
                end
            end
        end
        CAL:begin
            PE_enable = 1;
            for(integer i = 0; i < kernel_size; i = i + 1) begin
                for(integer j = 0; j < kernel_size; j = j + 1) begin
                    shift_window[i * kernel_size + j] = pic_buffer[i][j + col_counter]; // Pass the first row of the picture buffer
                end
            end
            if(col_counter == pic_size - 1) begin
                state_n = RD;
                init_pic_buffer_n = 1; // Set the update picture buffer signal
                col_counter_next = 0; // Reset the column counter
                if(row_counter == pic_size - 1) begin
                    row_counter_next = 0;
                    need_weight_reg_n = 1;
                    init_pic_buffer_n = 1;
                    weight_addr_valid_n = 1;
                    if(channel_counter == channel -1) begin
                        need_weight_reg_n = 0;
                        weight_addr_valid_n = 0;
                        state_n = WD;
                        init_pic_buffer_n = 0;
                        channel_counter_next = 0; // Reset the channel counter
                        PE_enable = 0; // Disable the PE module
                        if(kernel_counter == kernel_number - 1) begin
                            kernel_counter_next = 0; // Reset the filter counter
                        end else begin
                            kernel_counter_next = kernel_counter + 1;
                        end
                    end else begin
                        channel_counter_next = channel_counter + 1; // Increment the channel counter
                    end
                end else begin
                    row_counter_next = row_counter + 1; // Increment the row counter
                end
            end else begin
                col_counter_next = col_counter + 1;
            end
        end
        WD: begin
            conv_result = result_buffer[WD_counter]; // Pass the result to the output
            conv_result_valid = 1; // Set the output valid signal
            conv_result_addr = WD_counter; // Pass the result address to the output
            if(WD_counter == pic_size * pic_size - 1) begin
                if(WD_kernel_counter == kernel_number - 1) begin
                    WD_kernel_counter_next = 0; // Reset the filter counter
                    state_n = IDLE; // Move to IDLE state
                    conv_finish_reg_n = 1; // Set the convolution finish signal
                end else begin
                    WD_kernel_counter_next = WD_kernel_counter + 1; // Increment the filter counter
                    need_weight_reg_n = 1;
                    init_pic_buffer_n = 1; // Set the need picture register signal
                    weight_addr_valid_n = 1;
                    state_n = RD; // Move to RD state
                end
                WD_counter_next = 0; // Reset the result counter
            end else begin
                WD_counter_next = WD_counter + 1; // Increment the result counter
            end
        end
        default: begin
            state_n = IDLE; // Default to IDLE state
        end
    endcase
end

weight_ram_wrapper #(
    .DATA_WIDTH(weight_bits),
    .DATA_DEPTH(256) // Adjust as needed
) weight_ram (
    .clk(clk),
    .rst_n(rst_n),
    .address(weight_addr),
    .address_valid(weight_addr_valid), // Always valid for this example
    .read_data(weight_data), // Connect to the output result
    .read_data_valid(weight_data_valid) // Connect to the output valid signal
);

// PE #(
//     .SIGN(SIGN),
//     .WIDTH(WIDTH),
//     .FP_POSITIONS(FP_POSITIONS),
//     .kernel_size(kernel_size)
// ) pe (
//     .clk(clk),
//     .rst_n(rst_n),
//     .in_valid(PE_enable),
//     .pic(shift_window), // Pass the first row of the picture buffer
//     .weight(weight_buffer), // Pass the weight buffer
//     .result(middle_conv_result_temp), // Connect to the output result
//     .result_valid(middle_conv_result_valid) // Connect to the output valid signal 
// );

PE_integer #(
    .pic_bits(pic_bits),
    .weight_bits(weight_bits),
    .kernel_size(kernel_size),
    .kernel_number(kernel_number),
    .channel(channel),
    .conv_result_bits(conv_result_bits)
) pe ( // Instantiate the PE module
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(PE_enable),
    .pic(shift_window), // Pass the first row of the picture buffer
    .weight(weight_buffer), // Pass the weight buffer
    .result(middle_conv_result_temp), // Connect to the output result
    .result_valid(middle_conv_result_valid) // Connect to the output valid signal 
);
// FPAU #(
//     .SIGN(SIGN),
//     .WIDTH(WIDTH),
//     .FP_POSITIONS(FP_POSITIONS)
// ) fpa (
//     .a(middle_conv_result_temp),
//     .b(result_buffer[middle_result_counter]),
//     .result(middle_conv_result) // Connect to the output result
// );

assign middle_conv_result = middle_conv_result_temp + result_buffer[middle_result_counter]; // Add the result to the buffer
endmodule
