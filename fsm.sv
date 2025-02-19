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
    output logic count_n_en,
    output logic count_k_en,
    //
    output logic load_to_cache,
    //
    output logic clear,
    output [1:0] state
);

logic [1:0] states;

localparam  IDLE           = 2'b00;
localparam  LOAD_TO_CACHE  = 2'b01;
localparam  CLEAR          = 2'b10;
localparam  COMPUTE        = 2'b11;

reg calc_end1;
reg calc_end2;

always_ff @(posedge clk) begin
    calc_end1 <= calc_end;
    calc_end2 <= calc_end1;
end

always_ff @(posedge clk) begin
if (!nrst) begin
    states <= IDLE;
    load_nCompute <= 1'b1;
    count_n_en <= 1'b0;
    count_k_en <= 1'b0;
    clear <= 1'b0;
    load_to_cache <= 1'b0;
end
else if(ce)begin
    case(states)
        IDLE:
            if(data_loaded) begin
                states <= LOAD_TO_CACHE;
                clear <= 1'b1;
                //
                load_nCompute <= 1'b0;
                load_to_cache <= 1'b1;
            end
        LOAD_TO_CACHE:begin
        count_n_en <= 1'b1;
            if(data_to_cache_loaded) begin
                states <= CLEAR;
                clear <= 1'b0;
                
            end
        end
        CLEAR: begin
            load_to_cache <= 1'b0;
            clear <= 1'b1;
            count_n_en <= 1'b1;
            count_k_en <= 1'b1;
            states <= COMPUTE;
            load_nCompute <= 1'b0;
        end
        COMPUTE: begin
            if(calc_end2) begin
                states <= IDLE;
                load_nCompute <= 1'b1;
                count_n_en <= 1'b0;
                count_k_en <= 1'b0;
                end
            end
    endcase
end
end

assign state = states;

endmodule