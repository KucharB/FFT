`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2024 11:22:18
// Design Name: 
// Module Name: Accumulation_unit
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


module Accumulation_unit(
    input [15:0] val_a,
    output logic [15:0] val_out,
    input clk,
    input ce,
    input nrst
    );
    
    reg [16:0] accumulated_val;
    
    always_ff @(posedge clk) begin
        if (!nrst) begin
            accumulated_val = 0;
        end
        else if(ce)
        accumulated_val <= accumulated_val + val_a;
    end
    
    always_comb val_out <= (accumulated_val >> 1);
endmodule
