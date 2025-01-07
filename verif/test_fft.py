import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotbext.axi import AxiBus, AxiMaster

maxval = 11

@cocotb.test()
async def test_counter(dut):
    """Test modulu licznika z uzyciem generatora zegara"""
    #Start generatora zegara
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start()) 

    #Reset modulu
    dut.nrst.value = 0
    dut.max_val.value = maxval
    await RisingEdge(dut.clk)
    dut.nrst.value = 1

    dut.ce.value = 1

    for i in range(maxval-1):
        await RisingEdge(dut.clk)
        assert dut.o_data.value == i, f"Test failed: count={dut.o_data.value}, expected={i}"
    