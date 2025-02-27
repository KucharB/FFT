`timescale 1ns / 1ps


module Accumulation_unit(
    input [31:0] val_a,
    output logic [31:0] val_out,
    input clk,
    input ce,
    input nrst,
    input load,
    input [11:0] samp_num
    );
    
    reg signed [31:0] accumulated_val_real; 
    reg signed [31:0] accumulated_val_imag;

    logic signed [31:0] accumulated_val_real1;
    logic signed [31:0] accumulated_val_imag1;

    reg reset;
    reg load1;
    reg load2;

    always @(posedge clk) begin
        reset <= nrst;
        load1 <= load;
        load2 <= load1;
    end

    always_ff @(posedge clk) begin
        if (!reset) begin
            accumulated_val_real <= 0;
            accumulated_val_imag <= 0;
        end
        else if(load2) begin
        accumulated_val_real <= val_a[31:16];
        accumulated_val_imag <= val_a[15:0];
        end
        else if (ce) begin
            accumulated_val_real <= accumulated_val_real + $signed(val_a[31:16]); 
            accumulated_val_imag <= accumulated_val_imag + $signed(val_a[15:0]); 
            //val_out <= {accumulated_val_real[15:0], accumulated_val_imag[15:0]}; 
        end
    end

    always_comb begin
    accumulated_val_real1 = accumulated_val_real >> $clog2(samp_num);
    accumulated_val_imag1 = accumulated_val_imag >> $clog2(samp_num);
    val_out = {accumulated_val_real1[15:0], accumulated_val_imag1[15:0]};
    end

endmodule