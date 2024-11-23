`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2024 23:45:49
// Design Name: 
// Module Name: Cache_memory
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


module Cache_memory(
    input [15:0] data_in,
    input [11:0] write_adr,
    
    input [11:0] read_adr,
    output logic [15:0] read_data,
    
    input clk,
    input write
    );
    
reg [15:0] MEM [0:4095];

always @(posedge clk) begin
if(write)begin
    MEM[write_adr] <= data_in;
    end
read_data <= MEM[read_adr];
end
endmodule
