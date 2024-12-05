module sum(
    input [31:0] a,
    input [31:0] b,
    output logic [33:0] c
);

always_comb begin : 
    c [16:0] = a[15:0] + b[15:0];
    c [33:17] = a[31:16] + b[31:16];
end

endmodule