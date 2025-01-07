TOPLEVEL_LANG = verilog
SIM = icarus
TOPLEVEL = top_fft  # Moduł top-level z pliku FFT
MODULE = ../tests/test_basic  # Nazwa pliku testowego Python (bez .py)

IVERILOG_FLAGS += -I ../FFT/ -g2012
IVERILOG_FLAGS += --trace

# Ścieżki do plików designu
VERILOG_SOURCES += $(PWD)/../FFT/RAM.sv
VERILOG_SOURCES += $(PWD)/../FFT/Cache_memory.sv
# VERILOG_SOURCES += $(PWD)/../FFT/mux.sv
VERILOG_SOURCES += $(PWD)/../FFT/MUL_UNIT.sv
VERILOG_SOURCES += $(PWD)/../FFT/Rounding_unit.sv
VERILOG_SOURCES += $(PWD)/../FFT/Accumulation_unit.sv
# VERILOG_SOURCES += $(PWD)/../FFT/Axi_Bridge_fsm.sv
VERILOG_SOURCES += $(PWD)/../FFT/Axi_Bridge.sv
VERILOG_SOURCES += $(PWD)/../FFT/counter.sv
VERILOG_SOURCES += $(PWD)/../FFT/fsm.sv
VERILOG_SOURCES += $(PWD)/../FFT/twidle_fac_gen.sv
VERILOG_SOURCES += $(PWD)/../FFT/top_fft.sv

# Automatyczna konfiguracja Makefile Cocotb
include $(shell cocotb-config --makefiles)/Makefile.sim