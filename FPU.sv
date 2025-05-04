module FPMU#(
    parameter SIGN = 1,
    parameter WIDTH = 8, // Width of the input data
    parameter FP_POSITIONS = 4 // Number of positions for the fixed point representation
)(
    input logic [WIDTH-1:0] a, // Input A
    input logic [WIDTH-1:0] b, // Input B
    output logic [WIDTH-1:0] result // Result of the multiplication
);
    logic [2*WIDTH-1:0] product;
    assign product = SIGN ? $signed(a) * $signed(b) : a * b ; // Perform multiplication based on SIGN
            // Perform the multiplication and shift the result to the right by FP_POSITIONS
    assign result = product[WIDTH + FP_POSITIONS - 1:FP_POSITIONS];

endmodule


