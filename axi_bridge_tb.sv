`include "Axi_Bridge.sv"
`timescale 1ns/100ps
module axi_bridge_tb #(
    parameter DATA_WIDTH = 32
);
  logic i_clk, i_rstn;

  logic [15:0] i_WDATA;
  logic [1:0] i_WSTRB;
  logic i_WVALID, i_WLAST;
  logic o_WREADY;

  logic i_RREADY;
  logic [31:0] o_RDATA;
  logic o_RVALID, o_RLAST;

  logic [11:0] i_AWADDR;
  logic [7:0] i_AWLEN;
  logic [2:0] i_AWSIZE;
  logic [1:0] i_AWBURST;
  logic i_AWVALID;
  logic o_AWREADY;

  logic [11:0] i_ARADDR;
  logic [7:0] i_ARLEN;
  logic [2:0] i_ARSIZE;
  logic [1:0] i_ARBURST;
  logic i_ARVALID;
  logic o_ARREADY;

  logic [DATA_WIDTH-1:0] i_DATA_FROM_RAM;
  logic i_CALC_END;
  logic [11:0] i_SAMPLES_NUMBER;
  logic o_DATA_LOADED;
  logic [15:0] o_SAMPLE_ram;
  logic [11:0] o_SAMPLE_INDEX_ram;
  logic o_WRITE_ram, o_READ_ram;
  bridge_fsm current_state; // - ZAKOMENTOWAC

Axi_Bridge uut(.*);

initial begin
    i_clk = 1'b0; i_rstn = 1'b0;
    i_WDATA = '0; i_DATA_FROM_RAM = '0;
    i_CALC_END = 1'b0; i_SAMPLES_NUMBER = '0;
    forever #5 i_clk = ~i_clk;
end

always @(posedge i_clk) begin
    i_WDATA += 1;
    i_DATA_FROM_RAM += 2;
end

initial begin
    @(negedge i_clk);
    i_rstn = 1'b1;
    @(posedge i_clk);
    // AW
    i_AWADDR = 0; i_AWLEN = 5; i_AWSIZE = 3'b001;
    i_AWVALID = 1'b1; i_AWBURST = 2'b01;
    @(posedge i_clk);
    i_AWVALID = 1'b0;
    //WRITE DATA
    i_WVALID = 1'b1;
    repeat(5) @(posedge i_clk);
    // WAIT
    @(posedge i_clk);
    @(posedge i_clk);
    $finish;
end

initial begin
    $dumpfile("bridge.vcd");
    $dumpvars(0,uut);
end


endmodule