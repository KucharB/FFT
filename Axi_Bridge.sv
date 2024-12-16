`include "Axi_Bridge_fsm.sv"
import Axi_Bridge_fsm::*;
module Axi_Bridge #(
  parameter DATA_WIDTH = 32
)
(
  input i_clk, i_rstn,
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

bridge_fsm state, next_state;
logic [11:0] index_cnt;
bit cnt_en, cnt_clr;

// FSM
always_ff @(posedge i_clk or negedge i_rstn) begin : p_fsm_sync
  if (~i_rstn) begin
    state <= bridge_IDLE;
    index_cnt <= '0;
  end
  else begin
    state <= next_state;
    if(cnt_clr) begin
      index_cnt <= '0;
    end
    else if(cnt_en) begin
      index_cnt <= index_cnt + 1; //tu chyba bedzie ARBURST
    end
  end
end : p_fsm_sync

always_comb begin : p_fsm_comb
  {o_ARREADY, o_AWVALID, o_WRITE_ram, o_READ_ram, o_DATA_LOADED} = 5'b00000;
  {cnt_clr, cnt_en} = 2'b00;
  {o_AWDATA, o_SAMPLE_ram, o_AWBURST, o_ARBURST, o_SAMPLE_INDEX_ram} = 'x;
  case(state)
    bridge_IDLE : begin
      o_ARREADY = 1'b1;
      if(i_ARVALID) begin
        next_state = bridge_READ;
      end
    end

    bridge_READ : begin //Odczyt próbek z wejscia
      o_ARREADY = 1'b1;
      o_WRITE_ram = 1'b1;
      o_SAMPLE_INDEX_ram = index_cnt;
      o_SAMPLE_ram = i_ARDATA;
      //o_ARBURST = ?? TODO
      if(index_cnt == (i_SAMPLES_NUMBER - 1)) begin
        o_DATA_LOADED = 1'b1;
        next_state = bridge_WAIT;
        cnt_clr = 1'b1;
      end
      else if(i_ARVALID) begin
        cnt_en = 1'b1;
      end
    end

    bridge_WAIT : begin
      o_AWVALID = 1'b1;
      if(i_CALC_END && i_AWREADY) begin
        next_state = bridge_WRITE;
      end
    end

    bridge_WRITE : begin
      o_AWVALID = 1'b1;
      o_READ_ram = 1'b1;
      o_SAMPLE_INDEX_ram = index_cnt;
      o_AWDATA = i_DATA_FROM_RAM;
      if (index_cnt == (i_SAMPLES_NUMBER - 1)) begin
        cnt_clr = 1'b1;
        next_state = bridge_IDLE;
      end
      else if (i_AWREADY) begin
        cnt_en = 1'b1;
      end
    end

    default : next_state = bridge_IDLE;
  endcase
end : p_fsm_comb

assign current_state = state; //current state at the output

endmodule