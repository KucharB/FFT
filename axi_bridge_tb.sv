`include "Axi_Bridge.sv"
`timescale 1ns/100ps
module axi_bridge_tb #(
    parameter DATA_WIDTH = 32
);
// Inputs
logic i_clk, i_rstn;
logic[15:0] i_AWDATA;
logic [DATA_WIDTH-1:0] i_DATA_FROM_RAM;
logic i_AWVALID, i_ARREADY, i_CALC_END;
logic [11:0] i_SAMPLES_NUMBER;
logic o_AWREADY, o_ARVALID, o_DATA_LOADED;
logic [DATA_WIDTH-1:0] o_ARDATA; 
logic [15:0] o_SAMPLE_ram;
logic [1:0] o_AWBURST, o_ARBURST;
logic [11:0] o_SAMPLE_INDEX_ram;
logic o_WRITE_ram, o_READ_ram;
bridge_fsm current_state; 

Axi_Bridge uut(.*);

initial begin
    i_clk = 1'b0; i_rstn = 1'b0;
    i_AWDATA = '0; i_DATA_FROM_RAM = '0;
    i_CALC_END = 1'b0; i_SAMPLES_NUMBER = '0;
    forever #5 i_clk = ~i_clk;
end

always @(posedge i_clk) begin
    i_AWDATA += 1;
    i_DATA_FROM_RAM += 2;
end

initial begin
    @(negedge i_clk);
    i_rstn = 1'b1;
    @(posedge i_clk);
    // READ
    i_SAMPLES_NUMBER = 10;
    i_AWVALID = 1'b1;
    repeat(i_SAMPLES_NUMBER) @(posedge i_clk);
    // WAIT
    i_AWVALID = 1'b0;
    i_ARREADY = 1'b1;
    @(posedge i_clk);
    i_CALC_END = 1'b1;
    repeat(i_SAMPLES_NUMBER) @(posedge i_clk);
    @(posedge i_clk);
    @(posedge i_clk);
    $finish;
end

initial begin
    $dumpfile("bridge.vcd");
    $dumpvars(0,uut);
end


endmodule