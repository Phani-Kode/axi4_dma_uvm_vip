`include "uvm_macros.svh"
import uvm_pkg::*;

class dma_base_sequence extends uvm_sequence #(axi4_seq_item);
    `uvm_object_utils(dma_base_sequence)

    function new(string name = "dma_base_sequence");
        super.new(name);
    endfunction

    task body();
        axi4_seq_item req_write;
        axi4_seq_item req_read;
        logic [31:0]  rand_addr;

        `uvm_info("SEQ", "Starting DMA Constrained-Random Sequence", UVM_LOW);

        // Generate 20 randomized Write-then-Read transactions
        repeat(20) begin
            // Generate a 4KB-aligned random base address
            rand_addr = $urandom_range(32'h0000_0000, 32'h0FFF_F000) & 32'hFFFF_F000;

            // 1. Send AXI WRITE Burst
            req_write = axi4_seq_item::type_id::create("req_write");
            start_item(req_write);
            if (!req_write.randomize() with {
                trans_type == AXI_WRITE;
                addr == rand_addr;
                burst == AXI_INCR;
            }) begin
                `uvm_fatal("SEQ", "Failed to randomize AXI Write Item");
            end
            finish_item(req_write);

            // 2. Send AXI READ Burst to the exact same address/length to trigger scoreboard checks
            req_read = axi4_seq_item::type_id::create("req_read");
            start_item(req_read);
            if (!req_read.randomize() with {
                trans_type == AXI_READ;
                addr == rand_addr;
                len  == req_write.len;   // Match write length
                size == req_write.size;  // Match write size
                burst == AXI_INCR;
            }) begin
                `uvm_fatal("SEQ", "Failed to randomize AXI Read Item");
            end
            finish_item(req_read);
        end

        `uvm_info("SEQ", "Finished DMA Constrained-Random Sequence", UVM_LOW);
    endtask
endclass
