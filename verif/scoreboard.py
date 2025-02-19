#verif/scoreboard.py
import os
import sys
import numpy as np
from scipy.fft import fft
import matplotlib.pyplot as plt

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
        
        real_part = []
        imag_part = []
        for sublist in dut_output_data:
            for value in sublist:
              real_part.append((value >> 16) & 0xFFFF) 
              imag_part.append(value & 0xFFFF)
        reals = np.array([(x if x < (1 << 15) else x - (1 << 16)) / (2**15) for x in real_part])
        imags = np.array([(x if x < (1 << 15) else x - (1 << 16)) / (2**15) for x in imag_part])
  
        dut_complex = reals + 1j * imags
        ref_complex = np.array(self._ref_output_data)  
    
        error = np.abs(dut_complex - ref_complex)  
        mse = np.mean(error ** 2)  
        mae = np.mean(error)  
        max_error = np.max(error)  
    
        # --- WIZUALIZACJA ---
        fig, axs = plt.subplots(2, 1, figsize=(10, 8))
    
        # Wykres wartości zespolonych (moduł)
        axs[0].plot(np.abs(ref_complex), label="Reference Output", linestyle="dashed", marker="o", markersize=3)
        axs[0].plot(np.abs(dut_complex), label="DUT Output", linestyle="dashed", marker="x", markersize=3)
        axs[0].set_title("Comparison of DUT vs Reference (Magnitude)")
        axs[0].set_ylabel("Magnitude")
        axs[0].legend()
        axs[0].grid()
    
        # Wykres błędu
        axs[1].plot(error, label="Error (|DUT - Reference|)", color="red", marker="x", markersize=3)
        axs[1].set_title("Error between DUT and Reference")
        axs[1].set_ylabel("Error Magnitude")
        axs[1].set_xlabel("Sample Index")
        axs[1].legend()
        axs[1].grid()
    
        plt.tight_layout()
        plt.savefig("fft_comparison.png")
    
        # Wypisanie wyników numerycznych
        print("DUT Complex Output:", dut_complex)
        print("Reference Complex Output:", ref_complex)
        print(f"MSE: {mse:.6f}") #Mean Squared Error - średni błąd kwadratowy
        print(f"MAE: {mae:.6f}") #Mean Absolute Error - średnia odchyła
        print(f"Max Error: {max_error:.6f}") 
        assert  mse <= 1, f"MSE is too big"
        return mse, mae, max_error  # Możesz zwrócić wartości, jeśli chcesz je dalej analizować

    