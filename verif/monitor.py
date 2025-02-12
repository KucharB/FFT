#verif/monitor.py
import os
import sys

# Ustalanie folderu wyżej jako ścieżki i zapis do zmiennej 
parent_path = os.path.abspath(os.path.join(os.path.dirname(__file__),".."))
# Sprawdzanie czy ścieżka z folderem wyżej istnieje w ścieżce, jak nie to jest dodawana
if parent_path not in sys.path:
    sys.path.append(parent_path)

import cocotb
from cocotb.triggers import RisingEdge


class AxiLiteMonitor:
  def __init__(self, dut, clk):
    self.dut = dut
    self.clk = clk
    self.transactions = []

  async def monitor(self):
    """Monitoring data AXI4-Lite"""
    while True:
      #if self.dut.AWVALID.value and self.dut.AWREADY.value:
      #  addr = int(self.dut.AWADDR.value)
      #  data = int(self.dut.WDATA.value)
      #  self.transactions.append(("write", addr, data))
      #  print(f"Monitor: Write to addr {addr} data {data}")

      #if self.dut.ARVALID.value and self.dut.ARREADY.value:
      #  addr = int(self.dut.ARADDR.value)
      #  print(f"Monitor: Read request addr {addr}")

      if self.dut.RVALID.value and self.dut.RREADY.value:
        await RisingEdge(self.dut.clk)
        while self.dut.RVALID.value and self.dut.RREADY.value:
          data = hex(self.dut.RDATA.value)
          self.transactions.append(("read", data))
          print(f"Monitor: Read response data {data}")
          await RisingEdge(self.dut.clk)
      else:
        await RisingEdge(self.clk)

# czy ta funkcja jest gdzieś użyta?
async def monitor_axi_transactions(monitor, scoreboard):
  while True:
    if monitor.dut.AWVALID.value and monitor.dut.AWREADY.value:
      addr = int(monitor.dut.AWADDR.value)
      data = int(monitor.dut.WDATA.value)
      scoreboard.check_write(addr, data)

    if monitor.dut.ARVALID.value and monitor.dut.ARREADY.value:
      addr = int(monitor.dut.ARADR.value)
      data = int(monitor.dut.RDATA.value)
      scoreboard.check_read(addr, data)

    await RisingEdge(monitor.clk)
