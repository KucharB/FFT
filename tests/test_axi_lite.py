#tests/test_axi_lite.py
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
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

  dut.rst.value = 1
  await Timer(20, units="ns")
  dut.rst.value = 0

  await driver.write(0x10, 0xDEADBEEF)
  await driver.write(0x20, 0xCAFEBABE)

  data1 = await driver.read(0x10)
  data2 = await driver.read(0x20)

  assert data1 == 0xDEADBEEF, f"Expected 0xDEADBEEF, got {data1}"
  assert data2 == 0xCAFEBABE, f"Expected 0xCAFEBABE, got {data2}"

  print("Test ended sucessfully")