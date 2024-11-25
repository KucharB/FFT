`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2024 23:57:36
// Design Name: 
// Module Name: MUL_UNIT
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MUL_UNIT(
    input [15:0] a_val,
    input [15:0] b_val,
    output logic [31:0] result
);

    always_comb begin
        result = a_val * b_val;
    end
endmodule
