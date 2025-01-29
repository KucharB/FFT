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
from verif.generator import Generator

@cocotb.test()
async def test_axi_lite(dut):
  __input_samp_num__ = 1024
  __input_burst_num__ = 64

  """Test for AXI4-Lite"""
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start())

  driver = AxiLiteDriver(dut, dut.clk)
  monitor = AxiLiteMonitor(dut, dut.clk)
  generator = Generator()
  cocotb.start_soon(monitor.monitor())
  random_val = generator.generate(__input_samp_num__)
  #print("rand_val", [hex(val) for val in random_val])
  #data_to_write = [0xBEEF, 0xBABE, 0xBABA, 0xA9C6, 0xD560, 0xEDA4]
  data_to_write = random_val
  data_to_write_under_lists = [data_to_write[i:i + __input_burst_num__] for i in range(0,len(data_to_write), __input_burst_num__)]
  wrong_data = [0xBEEF, 0xBABE, 0xBABA, 0xA9C6, 0xD560]
  print("Data to write: ", [hex(value) for value in data_to_write])
  dut.SAMP_NUMBER.value = __input_samp_num__
  dut.n_Reset.value = 0
  dut.CALC_END.value = 0
  dut.WRITE_TO_CACHE.value = 0
  await Timer(20, units="ns")
  dut.n_Reset.value = 1
  await Timer(10, units="ns")
  for i, data_to_write_under_list in enumerate(data_to_write_under_lists):
    address = int((i * __input_burst_num__ * 4)/2)
    await driver.write(address, data_to_write_under_list, 0x3, __input_burst_num__-1, 1)
    await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)
  dut.CALC_END.value = 1
  data1 = []
  for i, data_to_write_under_list in enumerate(data_to_write_under_lists):
    address = int((i * __input_burst_num__ * 4)/2)
    data = await driver.read(address, __input_burst_num__-1, 1)
    data1.append(data)
  print("Data get by driver", [hex(value) for sublist in data1 for value in sublist])

  assert  data1 == data_to_write_under_lists, f"Wrong data, got {data1}"
  #assert data2 == 0xBABE, f"Expected 0xBABE, got {data2}"

  print("Test ended sucessfully")