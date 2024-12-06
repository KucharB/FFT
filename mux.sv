module mux(
    input [11:0] a,
    input [11:0] b,
    input sel,
    output logic [11:0] c
)

always_comb begin
    if(sel)
    c = b;
    else
    c = a;
end

endmodule;