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

class AxiScoreboard:
  def __init__(self):
    self.expected_writes = []
    self.expected_reads = []
    self.errors = 0
    self.error_log = []

  def add_expected_write(self, addr, data):
    """Add expected write transactions"""
    self.expected_writes.append((addr, data))

  def add_expected_read(self, addr, data):
    """Add expected read transactions"""
    self.expected_reads.append((addr,data))

  def check_write(self, addr, data):
    """Compare real write transacion with expected"""
    if not self.expected_writes:
      self.errors += 1
      self.error_log.append(f"ERROR: Unexpected write to addr {addr} with data {data}")
      print(f"ERROR: Unexpected write to addr {addr} with data {data}")
    else:
      expected_addr, expected_data = self.expected_writes.pop(0)
      if addr != expected_addr or data != expected_data:
        self.errors += 1
        self.error_log.append(
          f"ERROR: Write mismatch. Expected addr {expected_addr}, data {expected_data}, "
          f"got addr {addr}, data {data}"
        )
        print(f"ERROR: Write mismatch. Expected addr {expected_addr}, data {expected_data}, "
              f"got addr {addr}, data {data}")
        
  def check_read(self, addr, data):
    """Compare real read transaction with expected"""
    if not self.expected_reads:
      self.errors += 1
      self.error_log.append(f"ERROR: Unexpected read from addr {addr} with data {data}")
      print(f"ERROR: Unexpected read from addr {addr} with data {data}")
    else:
      expected_addr, expected_data = self.expected_reads.pop(0)
      if addr != expected_addr or data != expected_data:
        self.errors += 1
        self.error_log.append(
          f"ERROR: Read mismatch. Expected addr {expected_addr}, data {expected_data}, "
          f"got addr {addr}, data {data}"
        )
        print(f"ERROR: Read mismatch. Expected addr {expected_addr}, data {expected_data}, "
              f"got addr {addr}, data {data}")
        
  def summary(self):
    """Results summary"""
    if self.errors == 0:
      print("AXI Scoreboard: All transactions are correct!")
    else:
      print(f"AXI Scoreboard: {self.errors} errors detected.")
      for error in self.error_log:
        print(error)

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
        a następnie konwertuje wynik do formatu 16+16 bit fixed-point.
        """
        # 1. Konwersja z 32-bitowego "słowa" do par liczb 16-bitowych (real, imag).
        real_samples = []
        imag_samples = []

        for word in self._input_data:
            # W Pythonie maskujemy i przesuwamy, by wyłuskać real/imag:
            real_16 = np.int16(word & 0xFFFF)        # dolne 16 bitów
            imag_16 = np.int16((word >> 16) & 0xFFFF) # górne 16 bitów
            real_samples.append(real_16)
            imag_samples.append(imag_16)

        # 2. Łączymy real i imag w liczby zespolone typu float (dla numpy.fft).
        complex_input = np.array(real_samples, dtype=np.float32) \
                        + 1j * np.array(imag_samples, dtype=np.float32)

        # 3. Wywołujemy FFT z numpy (uwaga: numpy domyślnie używa DFT):
        fft_result = np.fft.fft(complex_input, n=self.num_samples)

        # 4. Konwersja wyników na 16+16 bit.
        #    Tu jest miejsce na skalowanie, zaokrąglanie, saturację itp.
        #    Zakładamy proste zaokrąglenie do int16.
        ref_output_data = []
        for val in fft_result:
            real_val = val.real
            imag_val = val.imag

            # Ewentualne skalowanie (jeśli wymagane), np. / self.num_samples
            # Tutaj przykład bez skalowania, jedynie konwersja do int16:
            real_i16 = np.int16(np.round(real_val))
            imag_i16 = np.int16(np.round(imag_val))

            # Składamy 16-bit real i 16-bit imag w jedno 32-bit słowo:
            # real = lower 16 bits, imag = upper 16 bits
            out_word = (np.uint32(imag_i16 & 0xFFFF) << 16) | (np.uint32(real_i16 & 0xFFFF))
            ref_output_data.append(out_word)

        self._ref_output_data = ref_output_data

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
  