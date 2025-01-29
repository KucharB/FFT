//`include "top_fft.sv"

module top_fft_tb;
    logic clk;
    logic n_Reset;
    logic [15:0]  WDATA;
    logic [1:0] WSTRB;
    logic WVALID;
    logic WLAST;
    logic WREADY;
    logic RREADY;
    logic [31:0] RDATA;
    logic [1:0] RID;
    logic RVALID;
    logic RLAST;
    logic [11:0] AWADDR;
    logic [7:0] AWLEN;
    logic [2:0] AWSIZE;
    logic [1:0] AWBURST;
    logic [1:0] AWID;
    logic AWVALID;
    logic AWREADY;
    logic [11:0] ARADDR;
    logic [7:0] ARLEN;
    logic [2:0] ARSIZE;
    logic [1:0] ARBURST;
    logic [21:0] ARID;
    logic ARVALID;
    logic ARREADY;
    logic BREADY;
    logic BVALID;
    logic [1:0] BID;
    logic [1:0] RBURST;
    logic [1:0] WBURST;
    logic [11:0] SAMP_NUMBER;
    logic MAC_nRADIX;
//


top_fft dut(
    .clk(clk),
    .n_Reset(n_Reset),
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WVALID(WVALID),
    .WLAST(WLAST),
    .WREADY(WREADY),
    .RREADY(RREADY),
    .RDATA(RDATA),
    .RID(RID),
    .RVALID(RVALID),
    .RLAST(RLAST),
    .AWADDR(AWADDR),
    .AWLEN(AWLEN),
    .AWSIZE(AWSIZE),
    .AWBURST(AWBURST),
    .AWID(AWID),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),
    .ARADDR(ARADDR),
    .ARLEN(ARLEN),
    .ARSIZE(ARSIZE),
    .ARBURST(ARBURST),
    .ARID(ARID),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),
    .BREADY(BREADY),
    .BVALID(BVALID),
    .BID(BID),
    .SAMP_NUMBER(SAMP_NUMBER),
    .MAC_nRADIX(MAC_nRADIX)
);

initial begin
    $dumpfile("top.vcd");
    $dumpvars;
    $dumpon;
end

endmodule