module top_axi_lite;
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

logic [31:0] DATA_FROM_RAM;
logic [15:0] RAM_in_axi;
logic [11:0] SAMPLE_INDEX_ram;
logic CALC_END;
logic WRITE_TO_CACHE;

 

Axi_Bridge slave(.i_clk(clk), .i_rstn(n_Reset), .i_AWDATA(WDATA),
        .i_DATA_FROM_RAM(DATA_FROM_RAM), .i_AWVALID(WVALID), .i_ARREADY(RREADY),
        .i_CALC_END(CALC_END), .i_SAMPLES_NUMBER(SAMP_NUMBER),
        .o_AWREADY(WREADY), .o_ARVALID(RVALID), .o_DATA_LOADED(LOADED_DATA), 
        .o_ARDATA(RDATA), .o_SAMPLE_ram(RAM_in_axi), .o_AWBURST(WBURST), 
        .o_ARBURST(RBURST), .o_SAMPLE_INDEX_ram(SAMPLE_INDEX_ram),
        .o_WRITE_ram(WRITE_ram), .o_READ_ram(READ_ram)
);

RAM ram1(
        .axi_data_in(RAM_in_axi), 
         .axi_adr_in(SAMPLE_INDEX_ram), 
         .axi_write(WRITE_ram),
         .axi_read(READ_ram),
         .axi_data_out(DATA_FROM_RAM),
         .SEND_DATA(),
         .SEND_ADDR(),
         .READ_ADDRESS(),
         .READ_DATA(),
         //
         .write_to_cache(WRITE_TO_CACHE),
         //
         .mode(1'b1), // '1' AXI write and read, load to cache, '0' Circiut write
         .clk(clk)
);

initial begin
    $dumpon;
    $dumpvars;
    $dumpfile("top_axi_lite.vcd");
end
endmodule
