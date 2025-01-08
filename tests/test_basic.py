#test/test_basic.py
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
from verif.driver import Driver
from verif.monitor import Monitor
from verif.generator import Generator
from verif.scoreboard import Scoreboard

@cocotb.test()
async def basic_test(top_fft):
  """Basic functional test"""
  dut = top_fft
  rst = n_Reset
  #Clock Initialization
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start())

  #Initialization of test components
  driver = Driver(dut)
  monitor = Monitor(dut)
  generator = Generator(seed=123)
  scoreboard = Scoreboard()

  #Monitor start
  cocotb.start_soon(monitor.capture())

  #DUT reset
  dut.rst.value = 1
  await Timer(20, units="ns")
  dut.rst.value = 0

  #Testing
  for _ in range(10):
    data = generator.generate()
    scoreboard.add_expected(data)
    await driver.send(data)

  #Reasults cheking
  await Timer(100, units="ns")
  scoreboard.check(monitor.observed)