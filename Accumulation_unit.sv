`timescale 1ns / 1ps


module Accumulation_unit(
    input [31:0] val_a,
    output logic [31:0] val_out,
    input clk,
    input ce,
    input nrst
    );
    
    reg [15:0] accumulated_val_real;
    reg [15:0] accumulated_val_imag;
    
    always_ff @(posedge clk) begin
        if (!nrst) begin
            accumulated_val_real <= 0;
            accumulated_val_imag <= 0;
        end
        else if(ce) begin
        accumulated_val_real <= accumulated_val_real + val_a[31:16];
        accumulated_val_imag <= accumulated_val_imag + val_a[15:0];
        end
    end
    
    always_comb val_out = {accumulated_val_real, accumulated_val_imag};
endmodule
