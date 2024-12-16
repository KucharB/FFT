`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2024 11:19:11
// Design Name: 
// Module Name: Rounding_unit
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


module Rounding_unit(
    input [31:0] val_in,
    output logic [15:0] val_out
    );
    
    always_comb begin
        val_out = (val_in >> 16);
    end
endmodule
