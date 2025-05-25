module serial_conv_control_integer#(
    parameter pic_bits = 8,
    parameter pic_size = 28,
    parameter kernel_size = 5,
    parameter channel_size = 3,
    parameter input_data_bits = 32,
    parameter serial_to_parallel_coe = input_data_bits / pic_bits,
    parameter conv_result_bits = 5 + 1 + pic_bits * 2,
    parameter padding = 4
)(
    input logic clk,
    input logic rst_n,
    input logic conv_start,
    input logic [input_data_bits-1:0] parallel_pic,
    input logic parallel_pic_valid,
    input logic [input_data_bits-1:0] parallel_previous_result,
    input logic parallel_previous_result_valid,
    input logic [input_data_bits-1:0] parallel_weight_data,
    input logic parallel_weight_data_valid,

    output logic need_pic,
    output logic conv_finish,
    output logic [8 - 1:0] conv_result,
    output logic [$clog2(pic_size*pic_size/serial_to_parallel_coe) - 1:0] conv_result_addr,
    output logic conv_result_valid,
    output logic read_previous_result_enable
);


//declare state_machine
typedef enum logic [1:0] {IDLE, RD, CAL} state_t; // State machine for control
state_t state_c, state_n; // State machine for control

//declare the three buffers 
logic [pic_bits-1:0] pic_buffer [kernel_size-1:0][pic_size + padding -1:0];
logic [pic_bits-1:0] pic_buffer_n [kernel_size-1:0][pic_size + padding -1:0];
logic [pic_bits-1:0] previous_result_buffer [pic_size -1:0];    
logic [pic_bits-1:0] previous_result_buffer_n [pic_size -1:0];
logic [pic_bits-1:0] weight_buffer [kernel_size * kernel_size-1:0];
logic [pic_bits-1:0] weight_buffer_n [kernel_size * kernel_size-1:0];

//declare the RD state counters
logic [1:0] update_first_row_counter, update_first_row_counter_n;
logic [$clog2(pic_size / serial_to_parallel_coe) - 1:0] update_col_counter, update_col_counter_n;
logic [$clog2(pic_size / serial_to_parallel_coe) - 1:0] update_previous_result_buffer_counter, update_previous_result_buffer_counter_n;
logic [$clog2(pic_size * pic_size / serial_to_parallel_coe) - 1:0] previous_result_addr_counter, previous_result_addr_counter_n;
logic [$clog2(7) - 1:0] update_weight_buffer_counter, update_weight_buffer_counter_n;

//declare the CAL state counters
logic [$clog2(pic_size) - 1:0] cal_row_counter, cal_row_counter_n;
logic [$clog2(pic_size) - 1:0] cal_col_counter, cal_col_counter_n;
logic [$clog2(channel_size) - 1:0] cal_channel_counter, cal_channel_counter_n;

//declare the output result counters
logic [$clog2(pic_size * pic_size / serial_to_parallel_coe) - 1:0] conv_result_addr_counter, conv_result_addr_counter_n;
//logic [1:0] serial_to_parallel_conv_result_counter, serial_to_parallel_conv_result_counter_n;
logic [$clog2(pic_size / serial_to_parallel_coe) - 1:0] conv_result_counter, conv_result_counter_n;

//declare the control flags
logic init_pic_buffer_flag, init_pic_buffer_flag_n;
logic update_pic_buffer_flag, update_pic_buffer_flag_n;
logic update_previous_result_buffer_flag, update_previous_result_buffer_flag_n;
logic update_weight_buffer_flag, update_weight_buffer_flag_n;

//output and input registers
logic need_pic_reg, need_pic_reg_n;
logic PE_enable_reg, PE_enable_reg_n;
logic conv_finish_reg, conv_finish_reg_n;
logic read_previous_result_enable_reg, read_previous_result_enable_reg_n;
logic conv_result_valid_reg, conv_result_valid_reg_n;
logic [pic_bits - 1:0] conv_result_reg, conv_result_reg_n;

//declare the middle wires
logic [pic_bits-1:0] shift_window [kernel_size * kernel_size-1:0];
logic [pic_bits - 1:0] conv_result_temp;

//declare the middle wires for PE
logic [pic_bits * 2 + 5 - 1:0] pe_result;
logic pe_result_valid;
logic pe_enable;

always_comb begin
    for(integer i = 0; i < kernel_size; i = i + 1) begin
        for(integer j = 0; j < kernel_size; j = j + 1) begin
            shift_window[i * kernel_size + j] = pic_buffer[i][j + cal_col_counter]; // Pass the first row of the picture buffer
        end
    end
end

PE_integer pe ( // Instantiate the PE module
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(pe_enable),
    .pic(shift_window), // Pass the first row of the picture buffer
    .weight(weight_buffer), // Pass the weight buffer
    .result(pe_result), // Connect to the output result
    .result_valid(pe_result_valid) // Connect to the output valid signal 
);

//logic for state machine
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_c <= IDLE;
    end else begin
        state_c <= state_n;
    end
end

always_comb begin
    state_n = state_c;
    case(state_c)
        IDLE: begin
            if(conv_start) begin
                state_n = RD;
            end else begin
                state_n = IDLE;
            end
        end
        RD: begin
            if(!init_pic_buffer_flag && !update_pic_buffer_flag && !update_previous_result_buffer_flag && !update_weight_buffer_flag) begin
                state_n = CAL;
            end else begin
                state_n = RD;
            end
        end
        CAL: begin
            if(!pe_result_valid && cal_col_counter == pic_size - 1 && cal_row_counter == pic_size - 1 && cal_channel_counter == channel_size - 1) begin
                state_n = IDLE;
            end else if(!pe_result_valid &&cal_col_counter ==pic_size - 1) begin
                state_n = RD;
            end else begin
                state_n = CAL;
            end
        end
    endcase
end

//logic for buffers
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(integer i = 0; i< kernel_size * kernel_size; i = i + 1) begin
            weight_buffer[i] <= 0; // Initialize the weight buffer to zero
        end
        for(integer i = 0; i< pic_size; i = i + 1) begin
            previous_result_buffer[i] <= 0; // Initialize the weight buffer to zero
        end     
        for(integer i = 0; i< kernel_size; i = i + 1) begin
            for(integer j = 0; j< pic_size + padding; j = j + 1) begin 
                pic_buffer[i][j] <= 0; // Initialize the weight buffer to zero
            end
        end        
    end else begin
        for(integer i = 0; i< kernel_size * kernel_size; i = i + 1) begin
            weight_buffer[i] <= weight_buffer_n[i];
        end
        for(integer i = 0; i< pic_size; i = i + 1) begin
            previous_result_buffer[i] <= previous_result_buffer_n[i]; 
        end     
        for(integer i = 0; i< kernel_size; i = i + 1) begin
            for(integer j = 0; j< pic_size + padding; j = j + 1) begin 
                pic_buffer[i][j] <= pic_buffer_n[i][j]; 
            end
        end     
    end
end

always_comb begin
    weight_buffer_n = weight_buffer;
    previous_result_buffer_n = previous_result_buffer;
    pic_buffer_n = pic_buffer;
    if(state_c == RD) begin
        //update the pic_buffer
        if(init_pic_buffer_flag) begin
            if(cal_row_counter == 0) begin
                for(integer i = 0; i < kernel_size ; i = i + 1) begin
                    for(integer j = 0; j < pic_size + padding; j = j + 1) begin
                        pic_buffer_n[i][j] = 0; // Initialize the picture buffer to zero
                    end
                end                
            end else begin
                for(integer i = 0; i < kernel_size - 1 ; i = i + 1) begin
                    for(integer j = 0; j < pic_size + padding; j = j + 1) begin
                        pic_buffer_n[i][j] = pic_buffer[i+1][j]; 
                    end
                end     
                for(integer j = 0; j < pic_size + padding; j = j + 1) begin
                    pic_buffer_n[kernel_size - 1][j] = 0;
                end             
            end
        end else if(update_pic_buffer_flag) begin
            if(parallel_pic_valid) begin
                if(cal_row_counter == 0) begin
                    pic_buffer_n[update_first_row_counter + 2][update_col_counter * 4 + 2] = parallel_pic[31:24]; //plus 2 for padding
                    pic_buffer_n[update_first_row_counter + 2][update_col_counter * 4 + 3] = parallel_pic[23:16];
                    pic_buffer_n[update_first_row_counter + 2][update_col_counter * 4 + 4] = parallel_pic[15:8];
                    pic_buffer_n[update_first_row_counter + 2][update_col_counter * 4 + 5] = parallel_pic[7:0];
                end else begin
                    pic_buffer_n[kernel_size - 1][update_col_counter * 4 + 2] = parallel_pic[31:24];
                    pic_buffer_n[kernel_size - 1][update_col_counter * 4 + 3] = parallel_pic[23:16];
                    pic_buffer_n[kernel_size - 1][update_col_counter * 4 + 4] = parallel_pic[15:8];
                    pic_buffer_n[kernel_size - 1][update_col_counter * 4 + 5] = parallel_pic[7:0];
                end
            end 
        end

        //update the weight_buffer
        if(update_weight_buffer_flag && parallel_weight_data_valid) begin
                if(update_weight_buffer_counter == 6) begin
                    weight_buffer_n[24] = parallel_weight_data[31:24];
                end else begin
                    weight_buffer_n[(update_weight_buffer_counter) * 4] = parallel_weight_data[31:24];
                    weight_buffer_n[(update_weight_buffer_counter) * 4 + 1] = parallel_weight_data[23:16];
                    weight_buffer_n[(update_weight_buffer_counter) * 4 + 2] = parallel_weight_data[15:8];
                    weight_buffer_n[(update_weight_buffer_counter) * 4 + 3] = parallel_weight_data[7:0];
                end
        end

        //update the previous_result_buffer
        if(update_previous_result_buffer_flag && parallel_previous_result_valid && update_previous_result_buffer_counter != 0) begin
            previous_result_buffer_n[(update_previous_result_buffer_counter - 1)*4] = parallel_previous_result[31:24];//minus one due to 1 cycle delay of sram read
            previous_result_buffer_n[(update_previous_result_buffer_counter - 1)*4 + 1] = parallel_previous_result[23:16];
            previous_result_buffer_n[(update_previous_result_buffer_counter - 1)*4 + 2] = parallel_previous_result[15:8];
            previous_result_buffer_n[(update_previous_result_buffer_counter - 1)*4 + 3] = parallel_previous_result[7:0];
        end
    end
end

//logic for counters
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        update_first_row_counter <= 0;
        update_col_counter <= 0;
        update_previous_result_buffer_counter <= 0;
        previous_result_addr_counter <= 0;
        update_weight_buffer_counter <= 0;
        cal_row_counter <= 0;
        cal_col_counter <= 0;
        cal_channel_counter <= 0;
        // parallel_conv_result_addr_counter <= 0;
        // serial_to_parallel_conv_result_counter <= 0;
        // parallel_conv_result_counter <=0;
    end else begin
        update_first_row_counter <= update_first_row_counter_n;
        update_col_counter <= update_col_counter_n;
        update_previous_result_buffer_counter <= update_previous_result_buffer_counter_n;
        previous_result_addr_counter <= previous_result_addr_counter_n;
        update_weight_buffer_counter <= update_weight_buffer_counter_n;
        cal_row_counter <= cal_row_counter_n;
        cal_col_counter <= cal_col_counter_n;
        cal_channel_counter <= cal_channel_counter_n;
        // parallel_conv_result_addr_counter <= parallel_conv_result_addr_counter_n;
        // serial_to_parallel_conv_result_counter <= serial_to_parallel_conv_result_counter_n;   
        // parallel_conv_result_counter <= parallel_conv_result_counter_n;     
    end
end

always_comb begin
    update_first_row_counter_n = update_first_row_counter;
    update_col_counter_n = update_col_counter;
    update_previous_result_buffer_counter_n = update_previous_result_buffer_counter;
    previous_result_addr_counter_n = previous_result_addr_counter;
    update_weight_buffer_counter_n = update_weight_buffer_counter;

    cal_row_counter_n = cal_row_counter;
    cal_col_counter_n = cal_col_counter;
    cal_channel_counter_n = cal_channel_counter;

    // parallel_conv_result_addr_counter_n = parallel_conv_result_addr_counter;
    // serial_to_parallel_conv_result_counter_n = serial_to_parallel_conv_result_counter;
    // parallel_conv_result_counter_n = parallel_conv_result_counter;

    if(state_c == RD) begin
        //control the picture update counter
        if(parallel_pic_valid && update_pic_buffer_flag) begin
            if(update_col_counter == pic_size / serial_to_parallel_coe - 1) begin
                update_col_counter_n = 0;
                if(cal_row_counter == 0) begin
                    if(update_first_row_counter == 3 - 1) begin
                        update_first_row_counter_n = 0;
                    end else begin
                        update_first_row_counter_n = update_first_row_counter + 1;
                    end
                end else begin
                    update_first_row_counter_n = 0;
                end
            end else begin
                update_col_counter_n = update_col_counter + 1;
            end
        end
        //control the weight update counter
        if(parallel_weight_data_valid && update_weight_buffer_flag) begin
            if(update_weight_buffer_counter == 7 - 1) begin
                update_weight_buffer_counter_n = 0;
            end else begin
                update_weight_buffer_counter_n = update_weight_buffer_counter + 1;
            end
        end
        //update previous result buffer
        // if(parallel_previous_result_valid && update_previous_result_buffer_flag) begin
        //     if(update_previous_result_buffer_counter == 7 - 1) begin
        //         update_previous_result_buffer_counter_n = 0;
        //     end else begin
        //         update_previous_result_buffer_counter_n = update_previous_result_buffer_counter + 1;
        //     end
        // end
        if(update_previous_result_buffer_flag) begin
            if(update_previous_result_buffer_counter == 8 - 1) begin
                update_previous_result_buffer_counter_n = 0;
            end else begin
                update_previous_result_buffer_counter_n = update_previous_result_buffer_counter + 1;
            end
            if(previous_result_addr_counter == pic_size * pic_size /serial_to_parallel_coe - 1 ) begin
                previous_result_addr_counter_n =0;
            end else if(update_previous_result_buffer_counter < 7)begin
                previous_result_addr_counter_n = previous_result_addr_counter + 1;
            end
        end
    end else if(state_c == CAL) begin
        if(!pe_result_valid && cal_col_counter == pic_size - 1) begin
            cal_col_counter_n = 0;
            if(cal_row_counter == pic_size - 1) begin
                cal_row_counter_n = 0;
                if(cal_channel_counter == channel_size - 1) begin
                    cal_channel_counter_n = 0;
                end else begin
                    cal_channel_counter_n = cal_channel_counter + 1;
                end
            end else begin
                cal_row_counter_n = cal_row_counter + 1;
            end
        end else if(cal_col_counter < pic_size - 1) begin
            cal_col_counter_n = cal_col_counter + 1;
        end 
    end

    //update conv result counter
    if(pe_result_valid) begin
        if(conv_result_counter == pic_size - 1) begin
            conv_result_counter_n = 0; 
        end else begin
            conv_result_counter_n = conv_result_counter + 1;
        end
        if(conv_result_addr_counter == pic_size * pic_size - 1) begin
            conv_result_addr_counter_n = 0;
        end else begin
            conv_result_addr_counter_n = conv_result_addr_counter + 1;
        end
        // if(serial_to_parallel_conv_result_counter == serial_to_parallel_coe - 1) begin
        //     serial_to_parallel_conv_result_counter_n = 0;
        // end else begin
        //     serial_to_parallel_conv_result_counter_n = serial_to_parallel_conv_result_counter + 1;
        // end
    end
    // if(parallel_conv_result_valid) begin
    //     if(parallel_conv_result_addr_counter == pic_size * pic_size / serial_to_parallel_coe - 1) begin
    //         parallel_conv_result_addr_counter_n = 0;
    //     end else begin
    //         parallel_conv_result_addr_counter_n = parallel_conv_result_addr_counter + 1;
    //     end
    
    // end
end

assign conv_result_addr = conv_result_addr_counter;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        init_pic_buffer_flag <= 0;
        update_pic_buffer_flag <= 0;
        update_previous_result_buffer_flag <= 0;
        update_weight_buffer_flag <= 0;
        need_pic_reg <= 0;
        PE_enable_reg <= 0;
        conv_finish_reg <= 0;
        read_previous_result_enable_reg <= 0;
        conv_result_valid_reg <= 0;
        conv_result_reg <= 0;
    end else begin
        init_pic_buffer_flag <= init_pic_buffer_flag_n;
        update_pic_buffer_flag <= update_pic_buffer_flag_n;
        update_previous_result_buffer_flag <= update_previous_result_buffer_flag_n;
        update_weight_buffer_flag <= update_weight_buffer_flag_n;
        need_pic_reg <= need_pic_reg_n;
        PE_enable_reg <= PE_enable_reg_n;
        conv_finish_reg <= conv_finish_reg_n;
        read_previous_result_enable_reg <= read_previous_result_enable_reg_n;
        conv_result_valid_reg <= conv_result_valid_reg_n;
        conv_result_reg <= conv_result_reg_n;        
    end
end

//update flags in read state
always_comb begin
    init_pic_buffer_flag_n = init_pic_buffer_flag;
    update_pic_buffer_flag_n = update_pic_buffer_flag;
    update_previous_result_buffer_flag_n = update_previous_result_buffer_flag;
    update_weight_buffer_flag_n = update_weight_buffer_flag;
    need_pic_reg_n = need_pic_reg;

    if(state_c == IDLE) begin
        if(conv_start) begin
            init_pic_buffer_flag_n = 1'b1;
            update_weight_buffer_flag_n = 1'b1;
            need_pic_reg_n = 1'b1;
        end
    end else if(state_c == RD) begin
        if(init_pic_buffer_flag) begin
            need_pic_reg_n = 1'b0;
            init_pic_buffer_flag_n = 1'b0;
            if(cal_row_counter < 26) begin
                update_pic_buffer_flag_n = 1'b1;
            end else begin
                update_pic_buffer_flag_n = 1'b0;
            end
        end
        if(update_pic_buffer_flag) begin
            need_pic_reg_n = 1'b0;
            if(cal_row_counter == 0) begin
                if(parallel_pic_valid && update_first_row_counter == 2 && update_col_counter == pic_size / serial_to_parallel_coe - 1) begin
                    update_pic_buffer_flag_n = 1'b0;
                end
            end else begin 
                if(parallel_pic_valid && update_col_counter == pic_size / serial_to_parallel_coe - 1) begin
                    update_pic_buffer_flag_n = 1'b0;
                end
            end
        end 
        if(update_weight_buffer_flag) begin
            if(parallel_weight_data_valid && (update_weight_buffer_counter == 7 - 1)) begin
                update_weight_buffer_flag_n = 1'b0;
            end
        end
        if(update_previous_result_buffer_flag) begin
            if(update_previous_result_buffer_counter == pic_size / serial_to_parallel_coe  && parallel_previous_result_valid) begin
                update_previous_result_buffer_flag_n = 1'b0;
            end
        end
    end else if(state_c == CAL) begin
        if(cal_col_counter == pic_size - 1 && !pe_result_valid) begin
            if(cal_row_counter == pic_size - 1 && cal_channel_counter ==2) begin
                init_pic_buffer_flag_n = 1'b0;
                need_pic_reg_n = 1'b0;
                update_previous_result_buffer_flag_n = 1'b0;
                update_weight_buffer_flag_n = 1'b0;
            end else begin
                init_pic_buffer_flag_n = 1'b1;
                need_pic_reg_n = 1'b1;
                if(cal_channel_counter == 0) begin
                    update_previous_result_buffer_flag_n = 1'b0;
                end else begin
                    update_previous_result_buffer_flag_n = 1'b1;
                end
                if(cal_row_counter == pic_size - 1) begin
                    update_weight_buffer_flag_n = 1'b1;
                    update_previous_result_buffer_flag_n = 1'b1;
                end
            end
        end
    end
end

assign need_pic = need_pic_reg;

//update some IO registers
always_comb begin
    PE_enable_reg_n = PE_enable_reg;
    conv_finish_reg_n = 1'b0;
    read_previous_result_enable_reg_n = 1'b0;
    conv_result_valid_reg_n = 1'b0;
    conv_result_reg_n = conv_result_reg;

    if(state_c == RD) begin
        if(update_previous_result_buffer_flag) begin
            if(update_previous_result_buffer_counter < pic_size / serial_to_parallel_coe - 1) begin
                read_previous_result_enable_reg_n = 1'b1;
            end else begin
                read_previous_result_enable_reg_n = 1'b0;
            end
        end
         if(!init_pic_buffer_flag && !update_pic_buffer_flag && !update_previous_result_buffer_flag && !update_weight_buffer_flag) begin
            PE_enable_reg_n = 1'b1;
        end
    end else if(state_c == CAL) begin
        if(cal_col_counter == pic_size - 1) begin
            PE_enable_reg_n = 1'b0;
        end else begin
            PE_enable_reg_n = 1'b1;
        end
        if(!pe_result_valid && cal_col_counter == pic_size - 1 && cal_row_counter == pic_size - 1 && cal_channel_counter == channel_size - 1) begin
            conv_finish_reg_n = 1'b1;
        end

        if(cal_col_counter == pic_size - 1 && !pe_result_valid) begin
            if(cal_channel_counter ==0 ||((cal_row_counter == pic_size - 1 && cal_channel_counter == 2))) begin
                read_previous_result_enable_reg_n = 1'b0;
            end else begin
                read_previous_result_enable_reg_n = 1'b1;
            end
            if(cal_row_counter == pic_size - 1 && cal_channel_counter == 0) begin
                read_previous_result_enable_reg_n = 1'b1;
            end
        end

        if(pe_result_valid) begin
            // if(serial_to_parallel_conv_result_counter == serial_to_parallel_coe - 1) begin
            //     parallel_conv_result_valid_reg_n = 1'b1;
            // end
            conv_result_valid_reg_n = 1'b1;
            conv_result_reg_n = (conv_result_temp > 255) ? 255 : conv_result_temp;
            // case(serial_to_parallel_conv_result_counter)
            //     2'b00: parallel_conv_result_reg_n[31:24] = (conv_result >255) ? 255 : conv_result;
            //     2'b01: parallel_conv_result_reg_n[23:16] = (conv_result >255) ? 255 : conv_result;
            //     2'b10: parallel_conv_result_reg_n[15:8] = (conv_result >255) ? 255 : conv_result;
            //     2'b11: parallel_conv_result_reg_n[7:0] = (conv_result >255) ? 255 : conv_result;
            //     default:parallel_conv_result_reg_n = parallel_conv_result_reg;
            // endcase
        end
    end

end

assign pe_enable = PE_enable_reg;
assign conv_finish = conv_finish_reg;
assign conv_result = conv_result_reg;
assign conv_result_valid = conv_result_valid_reg;
assign read_previous_result_enable = read_previous_result_enable_reg;
assign conv_result_temp = pe_result + previous_result_buffer[conv_result_counter];


endmodule


//reference code
    // if(state_c == IDLE) begin

    // end else if(state_c == RD) begin

    // end else if(state_c == CAL) begin

    // end