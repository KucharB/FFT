`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Bartłomiej Kucharek
// 
// Create Date: 23.11.2024 23:24:49
// Module Name: RAM
// Project Name: FFT

// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RAM(
    input logic [15:0] axi_data_in,
    input logic [11:0] axi_adr_in,
    input logic axi_write,
    input logic axi_read,
    output logic [31:0] axi_data_out,
    
    input logic [31:0] cir_data_in,
    input logic [11:0] cir_adr_in,

    input logic [11:0] read_ram_to_cache,
    
    output logic [15:0] cir_data_out,
    
    input logic mode,
    input logic clk
    );
 
 reg [31:0] MEM [0:4095];
 
 always @(posedge clk) begin
    if(mode) begin
        if(axi_write)begin
           MEM[axi_adr_in] <= axi_data_in;
           cir_data_out <= MEM[read_ram_to_cache];
        end
        if(axi_read) axi_data_out <= MEM[axi_adr_in];
    end
    else begin
        MEM[cir_adr_in] <= cir_data_in;
    end
 end   
    
endmodule
