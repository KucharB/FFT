#verif/scoreboard.py
import os
import sys
import numpy as np
from scipy.fft import fft

# Ustalanie folderu wyżej jako ścieżki i zapis do zmiennej 
parent_path = os.path.abspath(os.path.join(os.path.dirname(__file__),".."))
# Sprawdzanie czy ścieżka z folderem wyżej istnieje w ścieżce, jak nie to jest dodawana
if parent_path not in sys.path:
    sys.path.append(parent_path)

class Scoreboard:
  def __init__(self):
    self.expected = []
    self.errors = 0

  def add_expected(self, value):
    self.expected.append(value)

  def check(self, observed):
    """Comparing output value with expected value"""
    for exp, obs in zip(self.expected, observed):
      if exp != obs:
        self.errors += 1
        print(f"ERROR: Expected {exp}, got {obs}")

    if self.errors == 0:
      print("All outputs are correct!")
    else:
      print(f"{self.errors} errors detected")

  def compute_and_compare_fft(self, input_data, reference_data):
    # Normalize input data
    data = [(x - (1 << 15)) / (2**15 - 1) for x in input_data]
    print(data)
    # Compute FFT
    computed_fft = fft(data)
    
    # Take the magnitude of the FFT if reference data is real
    computed_fft = np.abs(computed_fft)
    print("Computed FFT (complex numbers):")
    for idx, value in enumerate(computed_fft):
        print(f"Index {idx}: {value.real:.6f} + {value.imag:.6f}j")
    
    # Flatten the computed FFT
    computed_fft = computed_fft.flatten()
    
    comparisons = []

    print("Length of computed FFT:", len(computed_fft))
    
    for ref in reference_data:
        # Initialize list to store complex numbers
        ref_complex = []
        
        # Extract real and imaginary parts from each 32-bit value in the reference data
        for value in ref:
            real_part = (value >> 16) & 0xFFFF  # Extract the upper 16 bits (real part)
            imag_part = value & 0xFFFF  # Extract the lower 16 bits (imaginary part)

            # Convert the parts to signed integers (16-bit signed integers)
            if real_part >= 0x8000:
                real_part -= 0x10000  # Convert to signed 16-bit
            if imag_part >= 0x8000:
                imag_part -= 0x10000  # Convert to signed 16-bit
            
            # Construct complex number from real and imaginary parts
            ref_complex.append(real_part + 1j * imag_part)
        
        # Take the magnitude of the reference data's complex numbers
        ref_complex = np.abs(ref_complex)

        # Flatten the reference data for comparison
        ref_flattened = np.array(ref_complex).flatten()
        print(ref_flattened)
        ref_flattened = ref_flattened[:8]
        
        #print("Length of reference data (flattened):", len(ref_flattened))

        # Compare computed FFT with each reference data
        if len(computed_fft) != len(ref_flattened):
            print("ERROR: Mismatched sizes. FFT length:", len(computed_fft), "Reference length:", len(ref_flattened))
        
        comparisons.append(np.allclose(computed_fft, ref_flattened, atol=1e-6))
    
    return computed_fft, reference_data, comparisons



class FftRadix4Scoreboard:
    """
    Klasa scoreboardu do weryfikacji wyjść z FFT radix-4 (lub dowolnej FFT)
    w porównaniu z modelem referencyjnym opartym o numpy.fft.

    Założenia:
      - Liczba próbek: 4096 (ale można dostosować parametrem).
      - Dane wejściowe: 16-bit int (część rzeczywista) + 16-bit int (część urojona),
        pakowane w jeden 32-bitowy 'word'.
      - Dane wyjściowe: również 16+16 bit w jednym 32-bitowym słowie.
      - Raportowanie procentu błędnych bitów.
      - Zakładamy block processing (najpierw wprowadzamy cały blok, potem odbieramy cały blok).
      - Brak rozróżnienia na potokowanie (pipeline latencje) – scoreboard otrzymuje
        cały zestaw wyjść DUT po przetworzeniu całego bloku.
    """

    def __init__(self, num_samples=4096):
        self.num_samples = num_samples
        
        # Przechowywane wewnętrznie listy wejść i oczekiwanych wyjść (referencja).
        self._input_data = []
        self._ref_output_data = []

        # Przechowywane na potrzeby statystyk i porównania:
        self.bit_errors = 0
        self.total_bits_checked = 0

    def add_input_samples(self, samples):
        """
        samples: lista (lub iterowalny obiekt) 32-bitowych słów,
                 gdzie 16 bitów to część rzeczywista, 16 bitów to część urojona.
                 Format (real, imag) = (lower 16 bits, upper 16 bits) lub odwrotnie –
                 zależnie od ustaleń. Tutaj przykładowo przyjmujemy
                 lower 16 bits = real, upper 16 bits = imag (little-endian).
        """
        if len(samples) != self.num_samples:
            print(f"WARNING: Otrzymano {len(samples)} próbek, "
                  f"a w założeniach jest {self.num_samples}.")
        self._input_data = samples

    def run_reference_model(self):
        """
        Uruchamia model referencyjny (numpy.fft) na danych wejściowych,
        """
        
        data = [(x if x < (1 << 15) else x - (1 << 16)) / (2**15) for x in self._input_data]
 

        fft_ = np.fft.fft(data)
        self._ref_output_data = fft_

    def compare_to_dut_output(self, dut_output_data):
        """
        Otrzymuje listę 32-bitowych wyjść z DUT (również 16 bitów real + 16 bitów imag),
        i porównuje z _ref_output_data bit-po-bicie.
        """
        if len(dut_output_data) != len(self._ref_output_data):
            print(f"WARNING: Liczba wyjść DUT ({len(dut_output_data)}) "
                  f"różni się od liczby wyjść modelu ({len(self._ref_output_data)}).")

        # Porównujemy do najmniejszej wspólnej długości:
        compare_len = min(len(dut_output_data), len(self._ref_output_data))

        for i in range(compare_len):
            ref_word = self._ref_output_data[i]
            dut_word = dut_output_data[i]

            # Teraz sprawdzamy każdy z 32 bitów:
            diff = ref_word ^ dut_word  # bitwise XOR – bity różne dadzą '1'
            # Liczymy ile bitów się różni:
            bit_diff_count = bin(diff).count('1')

            self.bit_errors += bit_diff_count
            self.total_bits_checked += 32  # porównujemy 32 bity na próbkę

    def report(self):
        """
        Końcowa statystyka: procent błędnych bitów.
        """
        if self.total_bits_checked == 0:
            print("Brak porównań – nie można wyliczyć statystyk.")
            return

        error_percent = (self.bit_errors / self.total_bits_checked) * 100.0
        print(f"[FFT Radix-4 Scoreboard] Liczba sprawdzonych bitów: {self.total_bits_checked}")
        print(f"[FFT Radix-4 Scoreboard] Liczba błędnych bitów:   {self.bit_errors}")
        print(f"[FFT Radix-4 Scoreboard] Procent błędnych bitów: {error_percent:.4f}%")
  