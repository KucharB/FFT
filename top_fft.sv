`include "RAM.sv"
`include "mux.sv"

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

wire [11:0] RAM2CACHE_ADDRESS;
wire [11:0] READ_ADDDRESS;
//wire [11:0] CACHE_ADDR;
wire [15:0] CACHE_DATA_IN;

RAM ram1(.axi_data_in(), 
         .axi_adr_in(), 
         .axi_write(),
         .axi_read(),
         .axi_data_out(),
         .cir_data_in(),
         .cir_adr_in(),
         .cir_data_out(),
         .mode(), // '1' AXI write and read, load to cache, '0' Circiut write
         .clk(clk));

/*mux MUX(.a(RAM2CACHE_ADDRESS),
        .b(READ_ADDDRESS),
        .c(CACHE_ADDR));*/

Cache_memory c_mem(
        .data_in(CACHE_DATA_IN),
        .write_adr(READ_ADDDRESS),
        .read_adr(),
        .read_data(),
        .clk(clk),
        .write()
);
endmodule

