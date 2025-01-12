#tests/test_mac.py
import os
import sys

# Ustalanie folderu wyżej jako ścieżki i zapis do zmiennej 
parent_path = os.path.abspath(os.path.join(os.path.dirname(__file__),".."))
# Sprawdzanie czy ścieżka z folderem wyżej istnieje w ścieżce, jak nie to jest dodawana
if parent_path not in sys.path:
    sys.path.append(parent_path)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
from verif.driver import AxiLiteDriver
from verif.monitor import AxiLiteMonitor
from verif.generator import Generator

@cocotb.test()
async def test_mac(dut):
    clock = Clock(dut.clk, 10, units='ns')
    cocotb.start_soon(clock.start())
    driver = AxiLiteDriver(dut, dut.clk)
    monitor = AxiLiteMonitor(dut, dut.clk)
    cocotb.start_soon(monitor.monitor())

    dut.WVALID.value = 0
    dut.RREADY.value = 0
    dut.n_Reset.value = 0
    dut.MAC_nRADIX.value = 1
    data_to_write = [0x0073, 0x0119, 0x019A, 0x01FE]
    dut.SAMP_NUMBER = len(data_to_write)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.n_Reset.value = 1
    await RisingEdge(dut.clk)
    await driver.write(data_to_write)
    dut.RREADY.value = 1
    await Timer(400, units="ns")



