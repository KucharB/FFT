// jeżeli coś jest tb, to powinno się tak nazywać. nie powinno być w jednym katalogu TB i RTL

module top_axi_lite_tb;
    parameter DATA_WIDTH = 32;
    parameter ID_W_WIDTH = 2; //obczaic szerokosc
    parameter ID_R_WIDTH = 2;

    logic clk;
    logic n_Reset;
    logic [15:0]  WDATA;
    logic [1:0] WSTRB;
    logic WVALID;
    logic WLAST;
    logic WREADY;

    logic RREADY;
    logic [DATA_WIDTH-1:0] RDATA;
    logic [ID_R_WIDTH-1:0] RID;
    logic RVALID;
    logic RLAST;

    logic [11:0] AWADDR;
    logic [7:0] AWLEN;
    logic [2:0] AWSIZE;
    logic [1:0] AWBURST;
    logic [ID_W_WIDTH-1:0] AWID;
    logic AWVALID;
    logic AWREADY;

    logic [11:0] ARADDR;
    logic [7:0] ARLEN;
    logic [2:0] ARSIZE;
    logic [1:0] ARBURST;
    logic [ID_R_WIDTH-1:0] ARID;
    logic ARVALID;
    logic ARREADY;
    logic BREADY;
    logic BVALID;
    logic [ID_W_WIDTH-1:0] BID;

    logic [1:0] RBURST;
    
    
    logic [1:0] WBURST;
    logic [11:0] SAMP_NUMBER;

logic [31:0] DATA_FROM_RAM;
logic [15:0] RAM_in_axi;
logic [11:0] SAMPLE_INDEX_ram;
logic CALC_END;
logic WRITE_TO_CACHE;
logic LOADED_DATA;
logic WRITE_ram;
logic READ_ram;

Axi_Bridge #(.DATA_WIDTH(DATA_WIDTH), .ID_W_WIDTH(ID_W_WIDTH), .ID_R_WIDTH(ID_R_WIDTH))
slave
(
    .i_clk(clk), .i_rstn(n_Reset),
    // WRITE DATA CHANNEL
    .i_WDATA(WDATA),
    .i_WSTRB(WSTRB),
    .i_WVALID(WVALID), 
    .i_WLAST(WLAST),
    .o_WREADY(WREADY),
    // READ DATA CHANNEL
    .i_RREADY(RREADY),
    .o_RDATA(RDATA),
    .o_RID(RID),
    .o_RVALID(RVALID), 
    .o_RLAST(RLAST),
    // ADDRESS WRITE CHANNEL
    .i_AWADDR(AWADDR),
    .i_AWLEN(AWLEN),
    .i_AWSIZE(AWSIZE),
    .i_AWBURST(AWBURST),
    .i_AWID(AWID),
    .i_AWVALID(AWVALID),
    .o_AWREADY(AWREADY),
    // ADDRESS READ CHANNEL
    .i_ARADDR(ARADDR),
    .i_ARLEN(ARLEN),
    .i_ARSIZE(ARSIZE),
    .i_ARBURST(ARBURST),
    .i_ARID(ARID),
    .i_ARVALID(ARVALID),
    .o_ARREADY(ARREADY),
    // RESPONSE CHANNEL
    .i_BREADY(BREADY),
    .o_BVALID(BVALID),
    .o_BID(BID),
    // REST OF SIGNALS
    .i_DATA_FROM_RAM(DATA_FROM_RAM),
    .i_CALC_END(CALC_END),
    .i_SAMPLES_NUMBER(SAMP_NUMBER),
    .o_DATA_LOADED(LOADED_DATA),
    .o_SAMPLE_ram(RAM_in_axi),
    .o_SAMPLE_INDEX_ram(SAMPLE_INDEX_ram),
    .o_WRITE_ram(WRITE_ram), 
    .o_READ_ram(READ_ram)
    //._fsm current_state // - ZAKOMENTOWAC
); 

/*Axi_Bridge slave(.i_clk(clk), .i_rstn(n_Reset), .i_AWDATA(WDATA),
        .i_DATA_FROM_RAM(DATA_FROM_RAM), .i_AWVALID(WVALID), .i_ARREADY(RREADY),
        .i_CALC_END(CALC_END), .i_SAMPLES_NUMBER(SAMP_NUMBER),
        .o_AWREADY(WREADY), .o_ARVALID(RVALID), .o_DATA_LOADED(LOADED_DATA), 
        .o_ARDATA(RDATA), .o_SAMPLE_ram(RAM_in_axi), .o_AWBURST(WBURST), 
        .o_ARBURST(RBURST), .o_SAMPLE_INDEX_ram(SAMPLE_INDEX_ram),
        .o_WRITE_ram(WRITE_ram), .o_READ_ram(READ_ram)
);*/

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
