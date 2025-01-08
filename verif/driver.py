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

class AxiLiteDriver:
  def __init__(self, dut, clk):
    self.dut = dut
    self.clk = clk

  async def write(self, addr, data):
    """Writing operation into slave via AXI4-Lite"""
    self.dut.AWADDR.value = addr
    self.dut.AWVALID.velue = 1
    self.dut.WDATA.value = data
    self.dut.WVALID.value = 1

    while not self.dut.AWREADY.value:
      await RisingEdge(self.clk)

    while not self.dut.WREADY.value:
      await RisingEdge(self.clk)

    self.dut.AWVALID.value = 0
    self.dutWVALID.value = 0

    while not self.dut.BVALID.value:
      await RisingEdge(self.clk)
    self.dut.BREADY.value = 1
    await RisingEdge(self.clk)
    self.dut.BREADY.value = 0

    async def read(self, addr):
      """Reading operaton from slave via AXI4-Lite"""
      self.dut.ARADDR.value = addr
      self.dut.ARVALID.value = 1

      while not self.dut.ARREADY.value:
        await RisingEdge(self.clk)

      self.dut.ARVALID.value = 0

      while not self.dut.RVALID.value:
        await RisingEdge(self.clk)

      data = int(self.dut.RDATA.value)
      self.dut.RREADY.value = 1
      await RisingEdge(self.clk)
      self.dut.RREADY.value = 0

      return data