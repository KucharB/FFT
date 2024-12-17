`timescale 1ns / 1ps


module Cache_memory(
    input [15:0] data_in,
    input [11:0] write_adr,
    
    input [11:0] read_adr,
    output logic [15:0] read_data,
    
    input clk,
    input write
    );
    
reg [15:0] MEM [0:4095];

initial MEM[0]=16'd0;

always @(posedge clk) begin
if(write)begin
    MEM[write_adr] <= data_in;
    end
else
read_data <= MEM[read_adr];
end
endmodule
