#verif/monitor.py
import cocotb
from cocotb.triggers import RisingEdge

class Monitor:
  def __init__(self, dut):
    self.dut = dut
    self.observed = []

  async def capture(self):
    """Monitoring DUT outputs"""
    while True:
      await RisingEdge(self.dut.clk)
      self.observed.append(int(self.dut.data_out.value))