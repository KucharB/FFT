module fsm
(
    input logic clk,
    input logic ce,
    input logic nrst,
    input logic [11:0] sample_num,
    input logic data_loaded,
    input logic calc_end,
    input logic data_to_cache_loaded,
    output logic load_nCompute,
    output logic [11:0] read_adr,
    output logic count_n_en,
    output logic count_k_en,
    output logic clear
);

logic [1:0] states;

IDLE = 2'b00;
LOAD_TO_CACHE = 2'b01;
CLEAR = 2'b11;
COMPUTE = 2'b11;

alwasys_ff @(posedge clk) begin
if (!nrst) begin
    states <= IDLE;
    load_nCompute <= 1'b1;
    read_adr <= 12'b0;
    count_n_en <= 1'b0;
    count_k_en <= 1'b0;
    clear <= 1'b0;
end
else if(ce)begin
    case(states)
        IDLE:
            if(data_loaded) begin
            states <= LOAD_TO_CACHE;
            count_n_en <= 1'b1;
            clear <= 1'b1;
            end
        LOAD_TO_CACHE:
            if(data_to_cache_loaded) begin
                states <= CLEAR;
                clear <= 1'b0;
            end
        CLEAR: begin
            clear <= 1'b1;
            count_n_en <= 1'b1;
            count_k_en <= 1'b1;
            stats <= COMPUTE;
        end
        COMPUTE:
            clear <= 1'b1;
            count_en <= 1'b1;
            load_nCompute <= 1'b0;
            if(calc_end) begin
                state <= IDLE;
                load_nCompute <= 1'b1;
            end
    endcase
end
end

endmodule