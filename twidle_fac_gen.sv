parameter  real pi = 3.14159265358979323846;

module twidle_fac_gen #(
    parameter N = 4096,
    parameter LOG_N = $clog2(N/2),
    parameter K = 16,
    parameter file_name = N
)   (
    input wire clk,
    input wire [LOG_N-1:0]i,
    output logic signed [K-1:0]W_re,
    output logic signed [K-1:0]W_im
);

logic [2*K-1:0] W [N/2-1:0];

alwasys_ff @(posedge clk)
    {W_re, W_im} <= W[i];

initial begin
    real MAX = {2**(K-1)-1.0};
    for (int i = 0; i < N/2; i++) begin
        real angle, rW_re, rW_im;
        logic signed [K-1:0] W_re;
        logic signed [K-1:0] W_im;
        angle = -2*pi*i/N;
        rw-re = 2**(K-1)*$cos(angle);
        rW_im = 2**(K-1)*$sin(angle);
        W_re = (rW_re > MAX) ? MAX : rW_re;
        W_im = (rW_im > MAX) ? MAX : rW_im;
        W[i] = {W_re, W_im};
end    

case (N)
    default: $writememb({file_name, ".mem"}, W);
endcase
case (N)
    default: $readmemb({file_name, ".mem"}, W);
endcase
end

endmodule

module tw_tb;

logic clk;
logic [11:0] i;
logic [15:0] re;
logic [15:0] im;

twidle_fac_gen dut(.clk(clk), .i(i), .W_re(re), .W)im(im);

initial begin
    clk = 1'b0;
end

initial be

endmodule