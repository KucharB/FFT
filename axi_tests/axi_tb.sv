`include "Axi_Bridge.sv"
`include "RAM1.sv"

`timescale 1ns/100ps



module axi_tb #(
    parameter DATA_WIDTH = 32
);
// Inputs
logic i_clk, i_rstn;
logic [DATA_WIDTH-1:0] i_ARDATA, i_DATA_FROM_RAM;
logic i_ARVALID, i_AWREADY, i_CALC_END;
logic [11:0] i_SAMPLES_NUMBER;
// Outputs
logic o_ARREADY, o_AWVALID, o_DATA_LOADED;
logic [DATA_WIDTH-1:0] o_AWDATA, o_SAMPLE_ram;
logic [1:0] o_AWBURST, o_ARBURST;
logic [11:0] o_SAMPLE_INDEX_ram;
logic o_WRITE_ram, o_READ_ram;
bridge_fsm current_state;

logic [11:0] counter = 12'd0;
logic [31:0] ram_in;
logic [11:0] RAM_o_adr = 12'd0;
logic [31:0] RAM_o_data;

Axi_Bridge uut(.*);
RAM1 ram_uut(.clk(i_clk), .i_adr(o_SAMPLE_INDEX_ram), .i_data(o_SAMPLE_ram), .write(o_WRITE_ram), .o_data(RAM_o_data), .o_adr(RAM_o_adr));

initial begin
    i_clk = 1'b0; i_rstn = 1'b0;
    i_ARDATA = '0; i_DATA_FROM_RAM = '0;
    i_CALC_END = 1'b0; i_SAMPLES_NUMBER = '0;
    forever #5 i_clk = ~i_clk;
end

always @(posedge i_clk) begin
    i_ARDATA += 1;
    i_DATA_FROM_RAM += 2;
end

initial begin
    @(negedge i_clk);
    i_rstn = 1'b1;
    @(posedge i_clk);
    // READ
    i_SAMPLES_NUMBER = 10;
    i_ARVALID = 1'b1;
    repeat(i_SAMPLES_NUMBER) @(posedge i_clk);
    // WAIT
    i_ARVALID = 1'b0;
    i_AWREADY = 1'b1;
    @(posedge i_clk);
    @(posedge i_clk);
    i_CALC_END = 1'b1;
    repeat(i_SAMPLES_NUMBER) @(posedge i_clk);
    @(posedge i_clk);
    @(posedge i_clk);

    repeat(i_SAMPLES_NUMBER)begin 
    ram_in = ram_uut.MEM[counter];
    counter = counter + 1;
    @(posedge i_clk);
    RAM_o_adr = RAM_o_adr + 1;
    end
    $finish;
end

initial begin
    $dumpfile("bridge.vcd");
    $dumpvars;
    $dumpon;
end


endmodule