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

  data_to_write = [0xBEEF, 0xBABE, 0xBABA, 0xA9C6, 0xD560, 0xEDA4]
  wrong_data = [0xBEEF, 0xBABE, 0xBABA, 0xA9C6, 0xD560]
  print("Data to write: ", [hex(value) for value in data_to_write])
  dut.SAMP_NUMBER.value = len(data_to_write)
  dut.n_Reset.value = 0
  dut.CALC_END.value = 0
  dut.WRITE_TO_CACHE.value = 0
  await Timer(20, units="ns")
  dut.n_Reset.value = 1
  await Timer(10, units="ns")
  await driver.write(0, data_to_write, 0x3, len(data_to_write)-1, 1)
  
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  dut.CALC_END.value = 1
  data1 = await driver.read(0, len(data_to_write)-1, 1)
  print("Data get by driver", [hex(value) for value in data1])

  assert data1 == data_to_write, f"Wrong data, got {data1}"
  #assert data2 == 0xBABE, f"Expected 0xBABE, got {data2}"

  print("Test ended sucessfully")