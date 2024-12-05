module fsm
(
    input clk,
    input ce,
    input nrst,
    input [11:0] sample_num,
    input resault_ready,
    input data_loaded,
    input calc_end,
    output logic load_nCompute,
    output logic [11:0] read_adr,
    output logic count_en,
    output logic clear

);

logic states;

IDLE = 2'b0;
COMPUTE = 2'b1;

alwasys_ff @(posedge clk) begin
if (!nrst) begin
    states <= IDLE;
    load_nCompute <= 1'b1;
    read_adr <= 12'b0;
    count_en <= 1'b0;
    clear <= 1'b0;
end
else if(ce)begin
    case(states)
        IDLE:
            if(data_loaded)
            states <= COMPUTE;
        COMPUTE:
            clear <= 1'b1;
            count_en <= 1'b1;
            load_nCompute <= 1'b0;
            if(calc_end) begin

            end
    endcase
end
end

endmodule