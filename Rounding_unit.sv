`timescale 1ns / 1ps

module Rounding_unit(
    input [31:0] val_in,
    output  [15:0] val_out
    );

        assign val_out = val_in[31:16];

endmodule
