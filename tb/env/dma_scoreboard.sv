`include "uvm_macros.svh"
import uvm_pkg::*;

class dma_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(dma_scoreboard)

    // Export to receive transactions from the AXI Monitor
    uvm_analysis_imp #(axi4_seq_item, dma_scoreboard) ap_export;

    // Associative array acting as a sparse memory reference model for the DMA
    logic [31:0] expected_memory [*];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_export = new("ap_export", this);
    endfunction

    // The write function processes incoming transactions from the monitor
    virtual function void write(axi4_seq_item item);
        `uvm_info("SCB", $sformatf("Received AXI Transaction: Type=%s, Addr=%0h, Len=%0d",
                  item.trans_type.name(), item.addr, item.len), UVM_LOW);

        if (item.trans_type == AXI_WRITE) begin
            // If it's a write, store the payload into our reference model
            for (int i = 0; i <= item.len; i++) begin
                // Simple 32-bit aligned address calculation for the reference model
                logic [31:0] offset_addr = item.addr + (i * 4);
                expected_memory[offset_addr] = item.data[i];
                `uvm_info("SCB_WRITE", $sformatf("Writing Data %0h to Addr %0h", item.data[i], offset_addr), UVM_HIGH);
            end
        end
        else if (item.trans_type == AXI_READ) begin
            // If it's a read, check actual read data against what we expect
            for (int i = 0; i <= item.len; i++) begin
                logic [31:0] offset_addr = item.addr + (i * 4);

                if (expected_memory.exists(offset_addr)) begin
                    if (expected_memory[offset_addr] !== item.data[i]) begin
                        `uvm_error("SCB_FAIL", $sformatf("Data Mismatch at Addr %0h! Expected: %0h, Actual: %0h",
                                  offset_addr, expected_memory[offset_addr], item.data[i]));
                    end else begin
                        `uvm_info("SCB_PASS", $sformatf("Data Match at Addr %0h: %0h", offset_addr, item.data[i]), UVM_HIGH);
                    end
                end else begin
                    `uvm_warning("SCB_UNINIT", $sformatf("Read from uninitialized memory address %0h", offset_addr));
                end
            end
        end
    endfunction
endclass
