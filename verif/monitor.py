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

class AxiLiteMonitor:
  def __init__(self, dut, clk):
    self.dut = dut
    self.clk = clk
    self.transactions = []

  async def monitor(self):
    """Monitoring data AXI4-Lite"""
    while True:
      await RisingEdge(self.clk)

      if self.dut.AWVALID.value and self.dut.AWREADY.value:
        addr = int(self.dut.AWADDR.value)
        data = int(self.dut.WDATA.value)
        self.transactions.append(("write", addr, data))
        print(f"Monitor: Write to addr {addr} data {data}")

      if self.dut.ARVALID.value and self.dut.ARREADY.value:
        addr = int(self.dut.ARADDR.value)
        print(f"Monitor: Read request addr {addr}")

      if self.dut.RVALID.value and self.dut.RREADY.value:
        data = int(self.dut.RDATA.value)
        self.transactions.append(("read", addr, data))
        print(f"Monitor: REad response addr {addr} data {data}")