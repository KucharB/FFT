//`include "RAM.sv"
//`include "mux.sv"
//`include "MUL_UNIT.sv"
//`include "Rounding_unit.sv"
//`include "Accumulation_unit.sv"
//`include "Axi_Bridge.sv"
//`include "counter.sv"
//`include "fsm.sv"
//`include "twidle_fac_gen.sv"
/////////////////////////////////////////////////////////
// Missing things:


module top_fft #(parameter N = 4)(
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
    input MAC_nRADIX,
    input n_Reset
);

wire [11:0] RAM2CACHE_ADDRESS;
wire [11:0] READ_ADDDRESS;
wire [15:0] CACHE_DATA_IN;
wire [15:0] CACHE_DATA_OUT;
wire [15:0] TW_VAL_REAL;
wire [15:0] TW_VAL_IMAG;
wire [31:0] ACUMULATION_INPUT;
wire [31:0] MUL_REAL_RESULT;
wire [31:0] MUL_IMAG_RESULT;
wire [35:0] SEND_DATA;
wire [11:0] SEND_ADDR;

wire [11:0] N_INDEX;
wire l_nComp;
wire CALC_END;
wire counter_n_en;
wire counter_k_en;
wire counter_n_ovf;
wire device_clear;

wire [15:0] RAM_in_axi;
wire [11:0] SAMPLE_INDEX_ram;
wire READ_ram;
wire WRITE_ram;
wire LOADED_DATA;

Axi_Bridge slave(.i_clk(clk), .i_rstn(n_Reset), .i_ARDATA(ARDATA), 
        .i_DATA_FROM_RAM(), .i_ARVALID(ARVALID), .i_AWREADY(AWREADY), 
        .i_CALC_END(CALC_END), .i_SAMPLES_NUMBER(SAMP_NUMBER),
        .o_ARREADY(ARREADY), .o_AWVALID(AWVALID), .o_DATA_LOADED(LOADED_DATA), 
        .o_AWDATA(AWDATA), .o_SAMPLE_ram(RAM_in_axi), .o_AWBURST(AWBURST), 
        .o_ARBURST(ARBURST), .o_SAMPLE_INDEX_ram(SAMPLE_INDEX_ram),
        .o_WRITE_ram(WRITE_ram), .o_READ_ram(READ_ram)
);

RAM ram1(.axi_data_in(RAM_in_axi), 
         .axi_adr_in(o_SAMPLE_INDEX_ram), 
         .axi_write(WRITE_ram),
         .axi_read(READ_ram),
         .axi_data_out(i_DATA_FROM_RAM),
         .cir_data_in(SEND_DATA),
         .cir_adr_in(SEND_ADDR),
         .read_ram_to_cache(RAM2CACHE_ADDRESS),
         .cir_data_out(CACHE_DATA_IN),
         .mode(l_nComp), // '1' AXI write and read, load to cache, '0' Circiut write
         .clk(clk)
);

Cache_memory c_mem(
        .data_in(CACHE_DATA_IN),
        .write_adr(RAM2CACHE_ADDRESS),
        .read_adr(RAM2CACHE_ADDRESS),
        .read_data(CACHE_DATA_OUT),
        .clk(clk),
        .write(l_nComp)
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
        .ce(counter_k_en),
        .nrst(device_clear)
);

counter n_counter(
        .clk(clk), 
        .ce(counter_n_en), 
        .nrst(device_clear), 
        .max_val(SAMP_NUMBER), 
        .o_data(N_INDEX), 
        .over(counter_n_ovf)
);

counter k_counter(
        .clk(clk), 
        .ce(counter_k_en & counter_n_ovf), 
        .nrst(device_clear), 
        .max_val(SAMP_NUMBER), 
        .o_data(SEND_ADDR), 
        .over(CALC_END)
);

fsm finit_state(
        .clk(clk),
        .ce(MAC_nRADIX),
        .nrst(n_Reset),
        .sample_num(SAMP_NUMBER),
        .data_loaded(LOADED_DATA),
        .calc_end(CALC_END),
        .load_nCompute(l_nComp),
        .count_n_en(counter_n_en),
        .count_k_en(counter_k_en),
        .clear(device_clear)
);

twiddle_rom tw_gen(
        .N(SAMP_NUMBER), 
        .k_index(SEND_ADDR), 
        .n_index(N_INDEX), 
        .data({TW_VAL_REAL,TW_VAL_IMAG})
);

endmodule : top_fft

