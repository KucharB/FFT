module counter(
    input clk,
    input ce,
    input nrst,
    input [11:0] max_val,
    output logic [11:0] o_data,
    output logic over
)

logic [11:0] coun_val;

alwasys_ff @(posedge clk)
begin
if (!nrst) begin
    coun_val <= 0;
end
else if (ce) begin
    if(coun_val < max_val)
    coun_val <= coun_val + 1;
    else 
    coun_val <= 0;
end
end

always_comb begin
    o_data = o_data
    over = ((o_data == max_val) && ce);
end
endmodule