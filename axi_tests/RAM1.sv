module RAM1(
    input logic clk,
    input logic [11:0] i_adr,
    input logic [31:0] i_data,
    input logic write,

    output logic [31:0] o_data,
    input logic [11:0] o_adr

);

logic [31:0] MEM [0:4095];

always @(posedge clk) begin
    if(write)
    MEM[i_adr] = i_data;
    else 
    o_data = MEM[o_adr];
end

endmodule