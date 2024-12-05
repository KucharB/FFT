module radix4_fft(
    input wire clk,                         // Sygnał zegarowy
    input wire reset,                       // Reset
    input wire [15:0] real_in[0:15],        // Rzeczywiste części wejścia
    input wire [15:0] imag_in[0:15],        // Urojone części wejścia
    output reg [15:0] real_out[0:15],       // Rzeczywiste części wyjścia
    output reg [15:0] imag_out[0:15]        // Urojone części wyjścia
);

    // Stałe wag trygonometrycznych (do Radix-4 dla N=16)
    // Dla uproszczenia zakładamy stałe, ale w rzeczywistości obliczamy z wzoru
    parameter W0_real = 16'h0001, W0_imag = 16'h0000; // W0 = 1 + 0j
    parameter W1_real = 16'h0000, W1_imag = 16'hFFFF; // W1 = 0 - j
    parameter W2_real = 16'hFFFF, W2_imag = 16'h0000; // W2 = -1 + 0j
    parameter W3_real = 16'h0000, W3_imag = 16'h0001; // W3 = 0 + j

    integer i;

    // Przechowywanie wyników pośrednich
    reg [15:0] temp_real[0:15];
    reg [15:0] temp_imag[0:15];

    // Proces FFT Radix-4
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Ustawianie wyjść na 0 w przypadku resetu
            for (i = 0; i < 16; i = i + 1) begin
                real_out[i] <= 16'h0000;
                imag_out[i] <= 16'h0000;
            end
        end else begin
            // Etap przetwarzania motyla dla czterech elementów
            for (i = 0; i < 4; i = i + 1) begin
                // Obliczenia FFT dla poszczególnych grup
                // W0
                temp_real[i]     = real_in[i] + real_in[i+4] + real_in[i+8] + real_in[i+12];
                temp_imag[i]     = imag_in[i] + imag_in[i+4] + imag_in[i+8] + imag_in[i+12];

                // W1
                temp_real[i+4]   = real_in[i] - imag_in[i+4] - real_in[i+8] + imag_in[i+12];
                temp_imag[i+4]   = imag_in[i] + real_in[i+4] - imag_in[i+8] - real_in[i+12];

                // W2
                temp_real[i+8]   = real_in[i] - real_in[i+4] + real_in[i+8] - real_in[i+12];
                temp_imag[i+8]   = imag_in[i] - imag_in[i+4] + imag_in[i+8] - imag_in[i+12];

                // W3
                temp_real[i+12]  = real_in[i] + imag_in[i+4] - real_in[i+8] - imag_in[i+12];
                temp_imag[i+12]  = imag_in[i] - real_in[i+4] - imag_in[i+8] + real_in[i+12];
            end

            // Przypisywanie wyników do wyjścia
            for (i = 0; i < 16; i = i + 1) begin
                real_out[i] <= temp_real[i];
                imag_out[i] <= temp_imag[i];
            end
        end
    end
endmodule
