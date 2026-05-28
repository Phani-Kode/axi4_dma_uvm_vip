# AXI4 Interconnect & DMA Verification Environment (UVM VIP)

## Overview
This repository contains a constrained-random Universal Verification Methodology (UVM) verification environment for an AXI4 Direct Memory Access (DMA) controller. The core of this project is a custom-developed **AXI4 Verification IP (VIP)** built from scratch in SystemVerilog.

This environment stresses the DMA through rigorous Clock Domain Crossing (CDC) and data-routing scenarios, demonstrating proficiency in standard pre-silicon verification methodologies for complex SoC architectures.

## Key Features
* **AXI4 VIP:** Reusable UVM agents, drivers, monitors, and sequence items for AXI4 Master and Slave interfaces.
* **Constrained-Random Stimulus:** UVM sequences designed to stress-test corner cases, varying burst lengths, sizes, and unaligned transfers.
* **SystemVerilog Assertions (SVA):** Integrated assertions strictly validating AXI handshake protocols (VALID/READY), ordering, and burst rules.
* **Checking & Coverage:** Self-checking UVM scoreboards and functional coverage models tracking protocol compliance.
* **Tools:** SystemVerilog, UVM, QuestaSim / Synopsys VCS, Linux Makefiles.

## Directory Structure
```
axi4_dma_uvm_vip/
├── docs/               # AXI4 Protocol specs and verification plan
├── rtl/                # Dummy DUT or open-source AXI DMA RTL for testing
├── vip/                # Reusable AXI4 Verification IP
│   └── axi4/
│       ├── axi4_if.sv          # SystemVerilog Interface with SVA
│       ├── axi4_seq_item.sv    # Transaction items
│       ├── axi4_driver.sv      # UVM Driver
│       ├── axi4_monitor.sv     # UVM Monitor
│       └── axi4_agent.sv       # UVM Agent
├── tb/                 # DMA Verification Environment
│   ├── env/            # Environment, Scoreboard, Coverage
│   ├── sequences/      # Constrained-random DMA traffic sequences
│   ├── tests/          # Top-level UVM tests
│   └── tb_top.sv       # Top-level module
├── scripts/            # Makefiles for QuestaSim/VCS
└── README.md
```
