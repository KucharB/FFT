//`include "top_fft.sv"

module top_fft_tb;
    logic [31:0] RDATA;
    logic RVALID;
    logic RREADY;
    logic [1:0] RBURST;
    logic [15:0]  WDATA;
    logic WVALID;
    logic WREADY;
    logic [1:0] WBURST;
    logic [11:0] SAMP_NUMBER;
    logic clk;
    logic n_Reset;
    logic MAC_nRADIX;
//


top_fft dut(
    .clk(clk),
    .n_Reset(n_Reset),
    .MAC_nRADIX(MAC_nRADIX),
    .SAMP_NUMBER(SAMP_NUMBER),
    .RDATA(RDATA),
    .RVALID(RVALID),
    .RREADY(RREADY),
    .RBURST(RBURST),
    .WDATA(WDATA),
    .WVALID(WVALID),
    .WREADY(WREADY),
    .WBURST(WBURST)
);

initial begin
    $dumpfile("top.vcd");
    $dumpvars;
    $dumpon;
end

endmodule