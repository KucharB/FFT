////////////////////////////////////////////
//
// Dear diary, today is 30.10.2024 when i'am writing this is 21:53
// I have been working on this project for 2 hours now
// I have made some progress, but I still have a lot to do
// My eys is closing right now
// I will try to finish this project tomorrow
// I hate Katowice for traffic
// I hope, this things will not require too many changes
// Good luck, have fun, i am going to play war thunder, drink some
// some alchol and go to sleep, bye :D
// 
////////////////////////////////////////////
parameter  real pi = 3.14159265358979323846;

module twidle_fac_gen #(
    parameter N = 2,
    parameter LOG_N = $clog2(N/2),
    parameter K = 9,
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
    4 : $writememb("04.mem", W);
    8 : $writememb("08.mem", W);
    16 : $writememb("16.mem", W);
    32 : $writememb("32.mem", W);
endcase
case (N)
    4 : $readmemb("04.mem", W);
    8 : $readmemb("08.mem", W);
    16 :$ readmemb("16.mem", W);
    32 :$ readmemb("32.mem", W);
endcase
end

endmodule