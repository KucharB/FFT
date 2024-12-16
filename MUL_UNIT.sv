`timescale 1ns / 1ps


module MUL_UNIT(
    input [15:0] a_val,
    input [15:0] b_val,
    output logic [31:0] result
);

    always_comb begin
        result = a_val * b_val;
    end
endmodule
