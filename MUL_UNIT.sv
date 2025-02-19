`timescale 1ns / 1ps


module MUL_UNIT(
    input [15:0] a_val,
    input [15:0] b_val,
    output logic [31:0] result
);

 logic signed [31:0] mul_res;

   always_comb begin
        mul_res = $signed(a_val) * $signed(b_val);
        result = mul_res >>> 15;
    end
endmodule
