`include "top_fft.sv"

module top_fft_tb;
parameter DATA_WIDTH = 32;
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
logic MAC_nRADIX;

top_fft dut(
    .clk(i_clk),
    .n_Reset(i_rstn),
    .MAC_nRADIX(MAC_nRADIX),
    .SAMP_NUMBER(i_SAMPLES_NUMBER),
    .RDATA(i_ARDATA),
    .RVALID(i_ARVALID),
    .RREADY(o_ARREADY),
    .RBURST(o_ARBURST),
    .WDATA(o_AWDATA),
    .WVALID(o_AWVALID),
    .WREADY(i_AWREADY),
    .WBURST(o_AWBURST)
);

initial begin
    MAC_nRADIX = 1'b1;
    i_clk = 1'b0; i_rstn = 1'b0;
    i_ARDATA = '0; 
    //i_DATA_FROM_RAM = '0;
    i_SAMPLES_NUMBER = '0;
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
    i_SAMPLES_NUMBER = 3;
    i_ARVALID = 1'b1;
    repeat(i_SAMPLES_NUMBER) @(posedge i_clk);
    // WAIT
    i_ARVALID = 1'b0;
    i_AWREADY = 1'b1;
    @(posedge i_clk);
    @(posedge i_clk);
    #500 $finish;
end

initial begin
    $dumpfile("top.vcd");
    $dumpvars;
    $dumpon;
end

endmodule