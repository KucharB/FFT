`include "RAM.sv"
`include "MUL_UNIT.sv"
`include "Rounding_unit.sv"
`include "Accumulation_unit.sv"
`include "Axi_Bridge.sv"
`include "counter.sv"
`include "fsm.sv"
`include "twidle_fac_gen.sv"
`include "Cache_memory.sv"
/////////////////////////////////////////////////////////
// Missing things:


module top_fft #(parameter N = 2)(
    // AXI BUS
    input               [15:0]  RDATA,
    input                       RVALID,
    output logic                RREADY,
    output logic        [N-1:0] RBURST,
    output logic        [31:0]  WDATA,
    output logic                WVALID,
    input logic                 WREADY,
    output logic        [N-1:0] WBURST,


    input [11:0] SAMP_NUMBER,
    input clk,
    input MAC_nRADIX,
    input n_Reset
);


logic [15:0] CACHE_DATA_IN;
logic [15:0] CACHE_DATA_OUT;
logic [15:0] TW_VAL_REAL;
logic [15:0] TW_VAL_IMAG;
logic [31:0] ACUMULATION_INPUT;
logic [31:0] MUL_REAL_RESULT;
logic [31:0] MUL_IMAG_RESULT;
logic [31:0] SEND_DATA;
logic [11:0] SEND_ADDR;

logic [11:0] N_INDEX;
logic l_nComp;
logic CALC_END;
logic counter_n_en;
logic counter_k_en;
logic counter_n_ovf;
logic device_clear;

logic [15:0] RAM_in_axi;
logic [31:0] DATA_FROM_RAM;
logic [11:0] SAMPLE_INDEX_ram;
logic READ_ram;
logic WRITE_ram;
logic LOADED_DATA;

//
logic ram_to_cache;
logic [1:0] fsm_state;

Axi_Bridge slave(.i_clk(clk), .i_rstn(n_Reset), .i_ARDATA(RDATA),
        .i_DATA_FROM_RAM(DATA_FROM_RAM), .i_ARVALID(RVALID), .i_AWREADY(WREADY),
        .i_CALC_END(CALC_END), .i_SAMPLES_NUMBER(SAMP_NUMBER),
        .o_ARREADY(RREADY), .o_AWVALID(WVALID), .o_DATA_LOADED(LOADED_DATA), 
        .o_AWDATA(WDATA), .o_SAMPLE_ram(RAM_in_axi), .o_AWBURST(WBURST), 
        .o_ARBURST(RBURST), .o_SAMPLE_INDEX_ram(SAMPLE_INDEX_ram),
        .o_WRITE_ram(WRITE_ram), .o_READ_ram(READ_ram)
);

RAM ram1(
        .axi_data_in(RAM_in_axi), 
         .axi_adr_in(SAMPLE_INDEX_ram), 
         .axi_write(WRITE_ram),
         .axi_read(READ_ram),
         .axi_data_out(DATA_FROM_RAM),
         .SEND_DATA(SEND_DATA),
         .SEND_ADDR(SEND_ADDR),
         .READ_ADDRESS(N_INDEX),
         .READ_DATA(CACHE_DATA_IN),
         //
        .write_to_cache(ram_to_cache),
         //
         .mode(l_nComp), // '1' AXI write and read, load to cache, '0' Circiut write
         .clk(clk)
);

Cache_memory c_mem(
        .data_in(CACHE_DATA_IN),
        .write_adr(N_INDEX),
        .read_adr(N_INDEX),
        .read_data(CACHE_DATA_OUT),
        .clk(clk),
        .write(ram_to_cache)
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
        .clear(device_clear),
        //
        .load_to_cache(ram_to_cache),
        //
        .data_to_cache_loaded(counter_n_ovf),
        .state(fsm_state)

);

twiddle_rom tw_gen(
        .clk(clk),
        .N(SAMP_NUMBER), 
        .k_index(SEND_ADDR), 
        .n_index(N_INDEX), 
        .data({TW_VAL_REAL,TW_VAL_IMAG})
);

endmodule : top_fft

