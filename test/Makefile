# Makefile de cocotb (ejecutar: make -C test)
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.v ripple_carry_4.v full_adder.v

VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
VERILOG_SOURCES += $(PWD)/tb.v
COMPILE_ARGS += -I$(SRC_DIR)

TOPLEVEL = tb
COCOTB_TOPLEVEL = tb
MODULE = test
COCOTB_TEST_MODULES = test

include $(shell cocotb-config --makefiles)/Makefile.sim
