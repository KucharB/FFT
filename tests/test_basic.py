#test/test_basic.py
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from verif.driver import Driver
from verif.monitor import Monitor
from verif.generator import Generator
from verif.scoreboard import Scoreboard

@cocotb.test()
async def basic_test(dut):
  """Basic functional test"""
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