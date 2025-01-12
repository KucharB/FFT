#tests/test_axi_lite.py
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

@cocotb.test()
async def test_axi_lite(dut):
  """Test for AXI4-Lite"""
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start())

  driver = AxiLiteDriver(dut, dut.clk)
  monitor = AxiLiteMonitor(dut, dut.clk)
  cocotb.start_soon(monitor.monitor())

  data_to_write = [0xBEEF, 0xBABE, 0xBABA, 0xA9C6, 0xD56A]
  dut.SAMP_NUMBER.value = len(data_to_write)
  dut.WVALID.value = 0
  dut.RREADY.value = 0
  dut.n_Reset.value = 0
  dut.CALC_END.value = 0
  dut.WRITE_TO_CACHE.value = 0
  await Timer(20, units="ns")
  dut.n_Reset.value = 1
  await Timer(10, units="ns")
  await driver.write(data_to_write)
  dut.RREADY.value = 1
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  dut.CALC_END.value = 1

  data1 = await driver.read(dut.SAMP_NUMBER.value)
  #await RisingEdge(dut.clk)
  #data2 = await driver.read()

  assert data1 == data_to_write, f"Wrong data, got {data1}"
  #assert data2 == 0xBABE, f"Expected 0xBABE, got {data2}"

  print("Test ended sucessfully")