import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotbext.axi import AxiLiteMaster, AxiLiteBus
import numpy as np
from scipy.fft import fft

@cocotb.test()
async def test_top_fft_axi(top_fft):
    """Test AXI interfejsu i podstawowej funkcjonalności modułu top_fft"""
    dut = top_fft
    # Konfiguracja zegara
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Resetowanie układu
    dut.n_Reset.value = 0
    await Timer(20, units="ns")
    dut.n_Reset.value = 1
    await Timer(10, units="ns")
    dut._log.info("Reset completed.")

    # Inicjalizacja AXI Master
    axi_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, ""), dut.clk)

    # Liczba próbek (N) - parametr testowy
    sample_count = 8
    test_data = np.random.randint(-32768, 32767, size=sample_count)  # Dane 16-bitowe

    # 1. Zapis danych do RAM przez AXI
    base_address = 0x00
    dut._log.info("Starting AXI write operations...")
    for i, data in enumerate(test_data):
        packed_data = (data & 0xFFFF) | ((data & 0xFFFF) << 16)  # Format real+imag
        await axi_master.write(base_address + i * 4, packed_data)
        dut._log.info(f"Wrote {hex(packed_data)} to {hex(base_address + i * 4)}")

    # 2. Wyzwolenie obliczeń FFT
    dut.MAC_nRADIX.value = 1  # Tryb FFT Radix-4
    dut.SAMP_NUMBER.value = sample_count
    dut._log.info("Triggering FFT computation...")
    await RisingEdge(dut.CALC_END)  # Czekanie na zakończenie obliczeń

    # 3. Odczyt wyników FFT z RAM
    results = []
    for i in range(sample_count):
        data = await axi_master.read(base_address + i * 4)
        results.append(data)
        dut._log.info(f"Read {hex(data)} from {hex(base_address + i * 4)}")

    # 4. Porównanie wyników z referencyjnym FFT (scipy)
    reference_fft = fft(test_data)
    for i, result in enumerate(results):
        real = (result >> 16) & 0xFFFF
        imag = result & 0xFFFF
        dut._log.info(f"Result {i}: Real={real}, Imag={imag}, Expected={reference_fft[i]}")
