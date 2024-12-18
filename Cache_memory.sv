`timescale 1ns / 1ps


module Cache_memory(
    input [15:0] data_in,
    input [11:0] write_adr,
    
    input [11:0] read_adr,
    output logic [15:0] read_data,
    
    input clk,
    input write
    );
    
logic [11:0] shifted_write_adr;

d_flip_flop d1(.clk(clk), .d(write_adr), .q(shifted_write_adr));

reg [15:0] MEM [0:4095];

initial MEM[0]=16'd0;

always @(posedge clk) begin
if(write)begin
    MEM[shifted_write_adr] <= data_in;
    end
else
read_data <= MEM[read_adr];
end
endmodule


module d_flip_flop(
    input logic clk,
    input logic [11:0] d,
    output logic [11:0] q
);
always_ff @(posedge clk)
q <= d;
endmodule