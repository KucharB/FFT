export PYTHONPATH := $(PWD):$(PWD)/../tests:$(PYTHONPATH)

TOPLEVEL_LANG = verilog
SIM = icarus
#TOPLEVEL = top_axi_lite_tb # Moduł top-level z pliku FFT
#MODULE = test_axi_lite  # Nazwa pliku testowego Python (bez .py)

TOPLEVEL = top_fft_tb 
MODULE = test_mac

IVERILOG_FLAGS += -g2012 -I../FFT/
IVERILOG_FLAGS += --trace

# Ścieżki do plików designu 
VERILOG_SOURCES += $(PWD)/../Axi_Bridge_fsm.sv
VERILOG_SOURCES += $(PWD)/../RAM.sv
VERILOG_SOURCES += $(PWD)/../Cache_memory.sv
VERILOG_SOURCES += $(PWD)/../MUL_UNIT.sv
VERILOG_SOURCES += $(PWD)/../Rounding_unit.sv
VERILOG_SOURCES += $(PWD)/../Accumulation_unit.sv
VERILOG_SOURCES += $(PWD)/../Axi_Bridge.sv
VERILOG_SOURCES += $(PWD)/../counter.sv
VERILOG_SOURCES += $(PWD)/../fsm.sv
VERILOG_SOURCES += $(PWD)/../twidle_fac_gen.sv
VERILOG_SOURCES += $(PWD)/../top_fft.sv
VERILOG_SOURCES += $(PWD)/../top_axi_lite_tb.sv
VERILOG_SOURCES += $(PWD)/../top_fft_tb.sv
dump = dump.vcd


# Debug: pokaż zmienną PYTHONPATH
sim:
	@echo "PYTHONPATH=$(PYTHONPATH)"
gtkwave:
	@gtkwave $(dump) dump.gtkw

all: sim gtkwave

# Automatyczna konfiguracja Makefile Cocotb
include $(shell cocotb-config --makefiles)/Makefile.sim