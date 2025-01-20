//`include "Axi_Bridge_fsm.sv"
import Axi_Bridge_fsm::*;
module Axi_Bridge #(
  parameter DATA_WIDTH = 32,
  parameter ID_W_WIDTH = 2, //obczaic szerokosc
  parameter ID_R_WIDTH = 2
)
(
  input i_clk, i_rstn,
  // WRITE DATA CHANNEL
  input [15:0] i_WDATA,
  input [1:0] i_WSTRB,
  input i_WVALID, i_WLAST,
  output logic o_WREADY,
  // READ DATA CHANNEL
  input i_RREADY,
  output logic [DATA_WIDTH-1:0] o_RDATA,
  output logic [ID_R_WIDTH-1:0] o_RID,
  output logic o_RVALID, o_RLAST,
  // ADDRESS WRITE CHANNEL
  input [11:0] i_AWADDR,
  input [7:0] i_AWLEN,
  input [2:0] i_AWSIZE,
  input [1:0] i_AWBURST,
  input [ID_W_WIDTH-1:0] i_AWID,
  input i_AWVALID,
  output logic o_AWREADY,
  // ADDRESS READ CHANNEL
  input [11:0] i_ARADDR,
  input [7:0] i_ARLEN,
  input [2:0] i_ARSIZE,
  input [1:0] i_ARBURST,
  input [ID_R_WIDTH-1:0] i_ARID,
  input i_ARVALID,
  output logic o_ARREADY,
  //WRITE RESPONSE CHANNEL
  input i_BREADY,
  output logic o_BVALID,
  output logic [ID_W_WIDTH-1:0] o_BID,
  // REST OF SIGNALS
  input [DATA_WIDTH-1:0] i_DATA_FROM_RAM,
  input i_CALC_END,
  input [11:0] i_SAMPLES_NUMBER,
  output logic o_DATA_LOADED,
  output logic [15:0] o_SAMPLE_ram,
  output logic [11:0] o_SAMPLE_INDEX_ram,
  output logic o_WRITE_ram, o_READ_ram
  //output bridge_fsm current_state // - ZAKOMENTOWAC
);

bridge_fsm state, next_state;
logic [11:0] index_cnt;
bit cnt_en, cnt_clr;
logic [2:0] size;
logic [7:0] length;
logic [ID_W_WIDTH-1:0] trans_id;

// FSM
always_ff @(posedge i_clk or negedge i_rstn) begin : p_fsm_sync
  if (~i_rstn) begin
    state <= bridge_IDLE;
    {index_cnt, size, length} <= '0;
    trans_id <= 'x;
  end
  else begin
    state <= next_state;
    if(cnt_clr) begin
      index_cnt <= 12'h0;
    end
    else if(cnt_en) begin
      index_cnt <= index_cnt + size; //size from AxSIZE
    end                              // INCR burst addressing

    if(next_state == bridge_ADDR_WRITE && i_AWBURST == 2'b01) begin
      trans_id <= i_AWID; //przypisanie ID transakcji
      index_cnt <= i_AWADDR;
      size <= (1<<i_AWSIZE); //zdekodowanie AxSIZE - 2^AxSIZE, 1 w prawo przesuniecie to 2
      length <= i_AWLEN;
    end

    if(next_state == bridge_ADDR_READ && i_ARBURST == 2'b01) begin
      index_cnt <= i_ARADDR;
      size <= (1<<i_ARSIZE);
      length <= i_ARLEN;
    end
  end
end : p_fsm_sync

always_comb begin : p_fsm_comb
  {o_WREADY, o_RVALID, o_RLAST, o_AWREADY, o_ARREADY} = '0;
  {o_WRITE_ram, o_READ_ram, o_DATA_LOADED, o_BID, o_RID, o_BVALID} = '0;
  {cnt_clr, cnt_en} = '0;
  {o_RDATA, o_SAMPLE_ram, o_SAMPLE_INDEX_ram} = 'x;

  case(state)
    bridge_IDLE : begin
      next_state = bridge_IDLE;
      o_AWREADY = 1'b1;
      if(i_AWVALID) begin
        next_state = bridge_ADDR_WRITE;
      end
    end

    bridge_ADDR_WRITE : begin
      next_state = bridge_ADDR_WRITE;
      o_AWREADY = 1'b1;
      if(!i_AWVALID) begin
      next_state = bridge_DATA_WRITE;
      end
    end

    bridge_DATA_WRITE : begin //Zapis probek do RAMU
    next_state = bridge_DATA_WRITE;
      o_WREADY = 1'b1;
      o_WRITE_ram = 1'b1;
      o_SAMPLE_INDEX_ram = (index_cnt / size);
      o_SAMPLE_ram = i_WDATA;
      if(i_WLAST || ((index_cnt/size) == length)) begin
        o_DATA_LOADED = 1'b1; 
        next_state = bridge_WRITE_RESPONSE;
        cnt_clr = 1'b1;
      end
      else if(i_WVALID) begin
        cnt_en = 1'b1;
      end
    end

    bridge_WRITE_RESPONSE : begin
      next_state = bridge_WRITE_RESPONSE;
      o_BVALID = 1'b1;
      o_BID = trans_id;
      if(i_BREADY) begin
        next_state = bridge_WAIT;
      end
    end

    bridge_WAIT : begin
      next_state = bridge_WAIT;
      o_ARREADY = 1'b1;
      if(i_CALC_END && i_ARVALID) begin
        next_state = bridge_ADDR_READ;
      end
    end

    // tu nizej do zrobienia, Dotestowania TODO
    bridge_ADDR_READ : begin
      next_state = bridge_ADDR_READ;
      o_ARREADY = 1'b1;
      if(!i_ARVALID) begin
      next_state = bridge_DATA_READ;
      end
    end

    bridge_DATA_READ : begin
      next_state = bridge_DATA_READ;
      o_ARREADY = 1'b1;
      o_READ_ram = 1'b1;
      o_SAMPLE_INDEX_ram = index_cnt;
      o_RDATA = i_DATA_FROM_RAM;
      o_RID = trans_id;
      if ((index_cnt/size) == length) begin
        o_RLAST = 1'b1;
        cnt_clr = 1'b1;
        next_state = bridge_IDLE;
      end
      else if (i_RREADY) begin
        cnt_en = 1'b1;
      end
    end

    default : next_state = bridge_IDLE;
  endcase
end : p_fsm_comb

assign current_state = state; //current state at the output, zakomentowac

endmodule