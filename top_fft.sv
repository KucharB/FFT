`include "RAM.sv"
`include "mux.sv"
`include "MUL_UNIT.sv"
`include "Rounding_unit.sv"
`include "Accumulation_unit.sv"

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
wire [15:0] CACHE_DATA_OUT;
wire [15:0] TW_VAL_REAL;
wire [15:0] TW_VAL_IMAG;
wire [31:0] ACUMULATION_INPUT;
wire [31:0] MUL_REAL_RESULT;
wire [31:0] MUL_IMAG_RESULT;
wire [35:0] SEND_DATA;


/*
module Axi_Bridge #(
  parameter DATA_WIDTH = 32
)
(
  input i_clk, i_rst,
  input [DATA_WIDTH-1:0] i_ARDATA, i_DATA_FROM_RAM,
  input i_ARVALID, i_AWREADY, i_CALC_END,
  input [11:0] i_SAMPLES_NUMBER,
  output logic o_ARREADY, o_AWVALID, o_DATA_LOADED,
  output logic [DATA_WIDTH-1:0] o_AWDATA, o_SAMPLE_ram,
  output logic [1:0] o_AWBURST, o_ARBURST,
  output logic [11:0] o_SAMPLE_INDEX_ram,
  output logic o_WRITE_ram, o_READ_ram,
  output bridge_fsm current_state
);
*/

RAM ram1(.axi_data_in(o_DATA_LOADED), 
         .axi_adr_in(o_SAMPLE_INDEX_ram), 
         .axi_write(o_WRITE_ram),
         .axi_read(o_READ_ram),
         .axi_data_out(i_DATA_FROM_RAM),
         .cir_data_in(),
         .cir_adr_in(READ_ADDDRESS),
         .cir_data_out(CACHE_DATA_IN),
         .mode(), // '1' AXI write and read, load to cache, '0' Circiut write
         .clk(clk));

/*mux MUX(.a(RAM2CACHE_ADDRESS),
        .b(READ_ADDDRESS),
        .c(CACHE_ADDR));*/

Cache_memory c_mem(
        .data_in(CACHE_DATA_IN),
        .write_adr(READ_ADDDRESS),
        .read_adr(),
        .read_data(CACHE_DATA_OUT),
        .clk(clk),
        .write()
);

MUL_UNIT mul_real(
        .a_val(CACHE_DATA_OUT),
        .b_val(TW_VAL_REAL),
        .result(MUL_REAL_RESULT)
);

MUL_UNIT mul_imag(
        .a_val(CACHE_DATA_OUT),
        .b_val(TW_VAL_IMAG),
        .result(MUL_IMAG_RESULT)
);

Rounding_unit round_real(
        .val_in(MUL_REAL_RESULT),
        .val_out(ACUMULATION_INPUT[31:16])
);

Rounding_unit round_imag(
        .val_in(MUL_IMAG_RESULT),
        .val_out(ACUMULATION_INPUT[15:0])
);

Accumulation_unit acumulation(
        .val_a(ACUMULATION_INPUT),
        .val_out(SEND_DATA),
        .clk(clk),
        .ce(),
        .nrst()
);
endmodule

/*module counter(
    input clk,
    input ce,
    input nrst,
    input [11:0] max_val,
    output logic [11:0] o_data,
    output logic over
)

logic [11:0] coun_val;

alwasys_ff @(posedge clk)
begin
if (!nrst) begin
    coun_val <= 0;
end
else if (ce) begin
    if(coun_val < max_val)
    coun_val <= coun_val + 1;
    else 
    coun_val <= 0;
end
end

always_comb begin
    o_data = o_data
    over = ((o_data == max_val) && ce);
end
endmodule*/