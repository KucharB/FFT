#verif/driver.py
import os
import sys

# Ustalanie folderu wyżej jako ścieżki i zapis do zmiennej 
parent_path = os.path.abspath(os.path.join(os.path.dirname(__file__),".."))
# Sprawdzanie czy ścieżka z folderem wyżej istnieje w ścieżce, jak nie to jest dodawana
if parent_path not in sys.path:
    sys.path.append(parent_path)

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
  #initialization of axi slave
  #async def init(self, burst_len, burst_size):
  
#burst_len liczba próbek - 1

  async def write(self, addr, data, strb=0x3, burst_len=0, burst_size = 1):
    burst_cnt = 0
    self.dut.AWLEN.value = burst_len
    self.dut.AWSIZE.value = burst_size
    self.dut.AWBURST.value = 1
    self.dut.AWID.value = 0
    self.dut.AWADDR.value = addr
    self.dut.AWVALID.value = 1
    await RisingEdge(self.clk)
    await RisingEdge(self.clk)
    while self.dut.AWREADY.value == 0:
      await RisingEdge(self.clk)
    self.dut.AWVALID = 0
    for x in data:
      self.dut.WDATA.value = x
      self.dut.WSTRB.value = strb
      self.dut.WVALID.value = 1
      self.dut.WLAST.value = 1 if burst_len - burst_cnt == 0 else 0
      burst_cnt = burst_cnt + 1
      await RisingEdge(self.clk)
    while self.dut.WREADY.value == 0:
      await RisingEdge(self.clk)
    self.dut.WVALID.value = 0
    self.dut.WLAST.value = 0
    self.dut.BREADY.value = 1
    while self.dut.BVALID.value == 0:
      await RisingEdge(self.clk)
    await RisingEdge(self.clk)
    self.dut.BREADY.value = 0
    #while self.dut.WREADY.value == 0:
      #await RisingEdge(self.clk)
    #self.dut.WVALID.value = 0
    #self.dut.WLAST.value = 0

  async def read(self, addr, burst_len = 0, burst_size = 1):
    self.dut.ARLEN.value = burst_len
    self.dut.ARSIZE.value = burst_size
    self.dut.ARBURST.value = 1
    self.dut.ARID.value = 0
    self.dut.ARADDR.value = addr
    self.dut.ARVALID.value = 1
    self.dut.ARLEN.value = burst_len
    await RisingEdge(self.clk)
    while self.dut.ARREADY.value == 0:
     await RisingEdge(self.clk)
    self.dut.ARVALID.value = 0
    data = []
    self.dut.RREADY.value = 1
    #await RisingEdge(self.clk)
    while self.dut.RVALID.value == 0:
        await RisingEdge(self.clk)
    await RisingEdge(self.clk)
    for _ in range(burst_len + 1):
      data.append(self.dut.RDATA.value)
      await RisingEdge(self.clk)
    self.dut.RREADY.value = 0
    return data
  #async def write(self, addr, data):
  async def write1(self, data):
    """Writing operation into slave via AXI4-Lite"""
    #self.dut.AWADDR.value = addr
    #self.dut.AWVALID.velue = 1
    #self.dut.WVALID.value = 1
    self.dut.WVALID.value = 1
    await RisingEdge(self.clk)
    for x in data:
      self.dut.WDATA.value = x
      await RisingEdge(self.clk)
    self.dut.WVALID.value = 0
    #while not self.dut.AWREADY.value:
    #  await RisingEdge(self.clk)

    #while not self.dut.WREADY.value:
    #  await RisingEdge(self.clk)

    #self.dut.AWVALID.value = 0
    #self.dut.WVALID.value = 0

    #while not self.dut.BVALID.value:
    #  await RisingEdge(self.clk)
    #self.dut.BREADY.value = 1
    #await RisingEdge(self.clk)
    #self.dut.BREADY.value = 0

    #async def read(self, addr):
  async def read1(self, samp_num):
    data = [1, 2]
    data.clear()
    """Reading operaton from slave via AXI4-Lite"""
     #self.dut.ARADDR.value = addr
     #self.dut.ARVALID.value = 1
    #while not self.dut.ARREADY.value:
    #  await RisingEdge(self.clk)

    #self.dut.ARVALID.value = 0

    while not self.dut.RVALID.value:
      await RisingEdge(self.clk)
    await RisingEdge(self.clk)
    for x in range(samp_num):
      data.append(int(self.dut.RDATA.value))
      await RisingEdge(self.clk)
    #self.dut.RREADY.value = 1
    #await RisingEdge(self.clk)
    #self.dut.RREADY.value = 0

    return data