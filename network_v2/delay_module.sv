module delay_module#(
    parameter DELAY_TIME = 3 // Default delay of 5 clock cycles
)(
    input logic clk,
    input logic rst_n,
    input logic in_signal,
    output logic out_signal
);

    reg [DELAY_TIME-1:0] delayed_signals; // Shift register to store delayed signals

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delayed_signals <= '0;
            out_signal <= 1'b0;
        end else begin
            // Shift the delayed signals register
            delayed_signals <= {delayed_signals[DELAY_TIME-2:0], in_signal};
            if (DELAY_TIME == 0) begin
                out_signal <= in_signal;
            end else begin
                out_signal <= delayed_signals[DELAY_TIME-1];
            end
        end
    end

endmodule
