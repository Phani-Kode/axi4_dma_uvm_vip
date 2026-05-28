# Makefile for AXI4 Interconnect & DMA UVM Verification
# Target EDA Tool: QuestaSim / ModelSim

# Directory Paths
VIP_DIR  = ../vip/axi4
TB_DIR   = ../tb
WORK_DIR = work

# SystemVerilog Interface (must be compiled before components that use it)
IF_FILE = $(VIP_DIR)/axi4_if.sv

# AXI VIP Files
VIP_FILES = $(VIP_DIR)/axi4_seq_item.sv \
            $(VIP_DIR)/axi4_monitor.sv \
            $(VIP_DIR)/axi4_driver.sv \
            $(VIP_DIR)/axi4_agent.sv

# DMA Testbench Files
TB_FILES  = $(TB_DIR)/env/dma_scoreboard.sv \
            $(TB_DIR)/env/dma_env.sv \
            $(TB_DIR)/sequences/dma_sequence.sv \
            $(TB_DIR)/tests/dma_test.sv \
            $(TB_DIR)/tb_top.sv

# UVM Flags (QuestaSim includes pre-compiled UVM libraries)
UVM_FLAGS = -L mtiUvm -uvmcontrol=all

.PHONY: all clean compile simulate

# Default target
all: clean compile simulate

# Compile the VIP and Testbench
compile:
	@echo "--- Compiling AXI VIP and DMA Testbench ---"
	vlib $(WORK_DIR)
	vmap work $(WORK_DIR)
	# Compile Interface first, then VIP and TB
	vlog -work $(WORK_DIR) +acc $(UVM_FLAGS) $(IF_FILE) $(VIP_FILES) $(TB_FILES)

# Run the UVM Simulation
simulate:
	@echo "--- Running UVM Simulation ---"
	vsim -c -do "coverage save -onexit axi_cov.ucdb; run -all; exit" $(WORK_DIR).tb_top +UVM_TESTNAME=dma_test

# Clean up generated files
clean:
	@echo "--- Cleaning up ---"
	rm -rf $(WORK_DIR) transcript vsim.wlf *.vcd *.ucdb
