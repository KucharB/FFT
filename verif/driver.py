#verif/driver.py
import cocotb
from cocotb.triggers import RisingEdge

class Driver:
  def __init__(self, dut):
    self.dut = dut

  async def send(self, data):
    """Sending data to DUT"""
    self.dut.data_in.value = data
    await RisingEdge(self.dut.clk)