parameter real pi = 3.14159265358979323846;

module twidle_fac_gen #(
    parameter N = 4096,
    parameter LOG_N = $clog2(N/2),
    parameter K = 16,
    parameter file_name = N
) (
    input wire clk,
    input wire [LOG_N-1:0] i,
    output logic signed [K-1:0] W_re,
    output logic signed [K-1:0] W_im
);

logic [2*K-1:0] W [0:N/2-1]; // Declare W array properly

// Output values are updated on clock edge
always_ff @(posedge clk) begin
    {W_re, W_im} <= W[i];
end

// Initialize W array and populate twiddle factors
initial begin
    real MAX = (2**(K-1)) - 1.0; // Proper parenthesis for arithmetic expressions
    for (int idx = 0; idx < N/2; idx++) begin
        real angle, rW_re, rW_im;
        angle = -2 * pi * idx / N; // Correct calculation for angle
        rW_re = MAX * $cos(angle); // Compute real part
        rW_im = MAX * $sin(angle); // Compute imaginary part

        // Saturate and convert to fixed-point logic
        logic signed [K-1:0] tmp_W_re = (rW_re > MAX) ? MAX : (rW_re < -MAX) ? -MAX : $rtoi(rW_re);
        logic signed [K-1:0] tmp_W_im = (rW_im > MAX) ? MAX : (rW_im < -MAX) ? -MAX : $rtoi(rW_im);

        W[idx] = {tmp_W_re, tmp_W_im}; // Assign to W array
    end

    // Write the computed values to a memory file
    $writememb({file_name, ".mem"}, W);

    // Read the values back into W array (optional, for verification)
    $readmemb({file_name, ".mem"}, W);
end

endmodule



module tw_tb;

logic clk;
logic [11:0] i; // LOG_N should be 12 for N=4096
logic signed [15:0] re;
logic signed [15:0] im;

// Instantiate the twiddle factor generator
twidle_fac_gen #(
    .N(4096),
    .LOG_N(12),
    .K(16),
    .file_name("twiddle")
) dut (
    .clk(clk),
    .i(i),
    .W_re(re),
    .W_im(im)
);

initial begin
    clk = 1'b0;
    i = 0;
    while (i < 2048) begin // Loop for half the points (N/2 twiddle factors)
        @(posedge clk);
        i++;
    end
    #10 $finish;
end

initial begin
    forever #5 clk = ~clk; // Generate clock with period of 10 units
end

initial begin
    $dumpfile("tw_gen.vcd");
    $dumpvars(0, tw_tb); // Dump all variables in testbench
end

endmodule
