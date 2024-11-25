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
    
    logic [31:0] interial_a;
    logic [31:0] interial_b;
    
    always_comb begin
    interial_a = {16{a_val[15]},a_val};
    interial_b = {16{b_val[15]},b_val};

    result = interial_a * interial_b;
    end
endmodule
