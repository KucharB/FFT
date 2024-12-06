module top_fft#(parameter N = 4)(
    // AXI BUS
    input [31:0] ARDATA,
    input ARVALID,
    output logic ARREADY,
    output logic [N:0] ARBURST,
    output logic [32:0] AWDATA,
    output logic AWVALID,
    input logic AWREADY,
    output logic [N:0] AWBURST,

    input [11:0] SAMP_NUMBER,
    input clk,
    input MAC_RADIX
);

endmodule