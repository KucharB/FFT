#tests/test_mac.py
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
from cocotb.triggers import RisingEdge
from verif.driver import AxiLiteDriver
from verif.monitor import AxiLiteMonitor
from verif.generator import Generator
from verif.scoreboard import FftRadix4Scoreboard

@cocotb.test()
async def test_mac(dut):
    __input_samp_num__ = 8
    __input_burst_num__ = 8

    clock = Clock(dut.clk, 10, units='ns')
    cocotb.start_soon(clock.start())
    driver = AxiLiteDriver(dut, dut.clk)
    monitor = AxiLiteMonitor(dut, dut.clk)
    generator = Generator()
    scoreboard = FftRadix4Scoreboard()
    cocotb.start_soon(monitor.monitor())
    data_to_write = generator.generate(__input_samp_num__)
    print("Data to write", [hex(value) for value in data_to_write])
    print([hex(value) for value in data_to_write])
    data_to_write_under_lists = [data_to_write[i:i + __input_burst_num__] for i in range(0,len(data_to_write), __input_burst_num__)]
    dut.SAMP_NUMBER.value = __input_samp_num__

    dut.WVALID.value = 0
    dut.RREADY.value = 0
    dut.n_Reset.value = 0
    dut.MAC_nRADIX.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.n_Reset.value = 1
    await RisingEdge(dut.clk)
    for i, data_to_write_under_list in enumerate(data_to_write_under_lists):
        address = int((i * __input_burst_num__ * 4)/2)
        await driver.write(address, data_to_write_under_list, 0x3, __input_burst_num__-1, 1)
        await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    data1 = []
    for i, data_to_write_under_list in enumerate(data_to_write_under_lists):
        address = int((i * __input_burst_num__ * 4)/2)
        data = await driver.read(address, __input_burst_num__-1, 1)
        data1.append(data)
    print("Data get by driver", [hex(value) for sublist in data1 for value in sublist])    
    await Timer(40, units="ns")
    scoreboard.__init__(__input_samp_num__)
    scoreboard.add_input_samples(data_to_write)
    scoreboard.run_reference_model()
    scoreboard.compare_to_dut_output(data1)
 


    print("Test ended sucessfully")



