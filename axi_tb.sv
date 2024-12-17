`include "Axi_Bridge.sv"
`include "RAM.sv"

`timescale 1ns/100ps
module axi_tb #(
    parameter DATA_WIDTH = 32
);
// Inputs
logic i_clk, i_rstn;
logic [15:0] i_ARDATA; 
logic [31:0] i_DATA_FROM_RAM;
logic i_ARVALID, i_AWREADY, i_CALC_END;
logic [11:0] i_SAMPLES_NUMBER;
// Outputs
logic o_ARREADY, o_AWVALID, o_DATA_LOADED;
logic [DATA_WIDTH-1:0] o_AWDATA;
logic [15:0] o_SAMPLE_ram;
logic [1:0] o_AWBURST, o_ARBURST;
logic [11:0] o_SAMPLE_INDEX_ram;
logic o_WRITE_ram, o_READ_ram;
bridge_fsm current_state;

//
logic [31:0] i_RAM_DATA;
logic [11:0] i_RAM_ADDR;
logic LOAD_TO_CACHE;
logic [15:0] o_RAM_DATA;
logic [11:0] ADDR_RAM_TO_CACHE;
logic axi_ncir;
logic [31:0] RAM_interior;
//

//
Axi_Bridge uut(.*);
RAM RAM_uut(
    .axi_data_in(o_SAMPLE_ram),
    .axi_adr_in(o_SAMPLE_INDEX_ram),
    .axi_write(o_WRITE_ram),
    .axi_read(o_READ_ram),
    .axi_data_out(i_DATA_FROM_RAM),
    .SEND_DATA(i_RAM_DATA),
    .SEND_ADDR(i_RAM_ADDR),
    .READ_ADDRESS(ADDR_RAM_TO_CACHE),
    .READ_DATA(o_RAM_DATA),
    .write_to_cache(LOAD_TO_CACHE),
    .mode(axi_ncir),
    .clk(~i_clk)
    );
//
initial begin
    ADDR_RAM_TO_CACHE = 32'd0;
    i_clk = 1'b0; i_rstn = 1'b0;
    i_ARDATA = '0; 
    //i_DATA_FROM_RAM = '0;
    i_CALC_END = 1'b0; i_SAMPLES_NUMBER = '0;
    forever #5 i_clk = ~i_clk;
end

always @(posedge i_clk) begin
    i_ARDATA += 1;
    //i_DATA_FROM_RAM += 2;
end

initial begin

    @(negedge i_clk);
    i_rstn = 1'b1;
    @(posedge i_clk);
    // READ
    i_SAMPLES_NUMBER = 10;
    i_ARVALID = 1'b1;
    @(negedge i_clk);
    axi_ncir = 1'b1;
    repeat(i_SAMPLES_NUMBER) @(posedge i_clk);
    RAM_interior = RAM_uut.MEM[12'd0];
    // WAIT
    i_ARVALID = 1'b0;
    i_AWREADY = 1'b1;
    @(posedge i_clk);
    axi_ncir = 1'b0;
    LOAD_TO_CACHE = 1'b1;
        repeat(i_SAMPLES_NUMBER - 1)begin 
            @(posedge i_clk);
            RAM_interior = RAM_uut.MEM[ADDR_RAM_TO_CACHE];
            ADDR_RAM_TO_CACHE = ADDR_RAM_TO_CACHE + 1;
    end
    i_CALC_END = 1'b0;
    repeat(i_SAMPLES_NUMBER) @(posedge i_clk);
    @(posedge i_clk);
    @(posedge i_clk);
    $finish;
end

initial begin
    $dumpfile("bridge.vcd");
    $dumpvars;
    $dumpon;
end


endmodule